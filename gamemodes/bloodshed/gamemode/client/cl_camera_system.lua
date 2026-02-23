local CameraSystem = {}
CameraSystem.Active = false
CameraSystem.StartTime = 0
CameraSystem.Duration = 15
CameraSystem.TargetPlayer = nil
CameraSystem.CameraPos = Vector()
CameraSystem.CameraAng = Angle()
CameraSystem.StartPos = Vector()
CameraSystem.StartAng = Angle()
CameraSystem.EndPos = Vector()
CameraSystem.EndAng = Angle()
CameraSystem.FOV = 75
CameraSystem.ZoomCycle = 0
CameraSystem.SwayTime = 0
CameraSystem.NoiseTime = 0

local function IsOutdoorPosition(pos)
    local tr = util.TraceLine({
        start = pos,
        endpos = pos + Vector(0, 0, 1000),
        mask = MASK_SOLID_BRUSHONLY
    })
    
    return tr.HitSky
end

local function FindValidCameraPosition(targetPos)
    local attempts = 0
    local maxAttempts = 50
    
    while attempts < maxAttempts do
        local angle = math.random() * math.pi * 2
        local distance = math.random(300, 800)
        local height = math.random(100, 300)
        
        local pos = targetPos + Vector(
            math.cos(angle) * distance,
            math.sin(angle) * distance,
            height
        )
        
        local tr = util.TraceLine({
            start = targetPos,
            endpos = pos,
            mask = MASK_SOLID
        })
        
        if not tr.Hit and IsOutdoorPosition(pos) then
            local groundTr = util.TraceLine({
                start = pos,
                endpos = pos - Vector(0, 0, 1000),
                mask = MASK_SOLID_BRUSHONLY
            })
            
            if groundTr.Hit and (pos.z - groundTr.HitPos.z) > 50 then
                return pos
            end
        end
        
        attempts = attempts + 1
    end
    
    return targetPos + Vector(0, 0, 200)
end

local function GetRandomCriminal()
    local criminals = {}
    
    for _, ply in pairs(player.GetAll()) do
        if ply:Alive() and ply:GetNW2String("Class") == "Criminal" then
            table.insert(criminals, ply)
        end
    end
    
    if #criminals > 0 then
        return table.Random(criminals)
    end
    
    return nil
end

local function StartCameraSystem()
    if CameraSystem.Active then return end
    
    local target = GetRandomCriminal()
    if not IsValid(target) then return end
    
    CameraSystem.Active = true
    CameraSystem.StartTime = CurTime()
    CameraSystem.TargetPlayer = target
    CameraSystem.SwayTime = 0
    CameraSystem.NoiseTime = 0
    CameraSystem.ZoomCycle = 0
    CameraSystem.FOV = 75
    
    local targetPos = target:GetPos()
    local startPos = FindValidCameraPosition(targetPos)
    local endPos = FindValidCameraPosition(targetPos + Vector(math.random(-200, 200), math.random(-200, 200), 0))
    
    CameraSystem.StartPos = startPos
    CameraSystem.EndPos = endPos
    CameraSystem.StartAng = (targetPos - startPos):Angle()
    CameraSystem.EndAng = (targetPos - endPos):Angle()
    CameraSystem.CameraPos = startPos
    CameraSystem.CameraAng = CameraSystem.StartAng
end

local function StopCameraSystem()
    CameraSystem.Active = false
    CameraSystem.TargetPlayer = nil
end

local function UpdateCamera()
    if not CameraSystem.Active then return end
    
    local elapsed = CurTime() - CameraSystem.StartTime
    local progress = math.Clamp(elapsed / CameraSystem.Duration, 0, 1)
    
    if progress >= 1 then
        StopCameraSystem()
        return
    end
    
    if not IsValid(CameraSystem.TargetPlayer) or not CameraSystem.TargetPlayer:Alive() then
        StopCameraSystem()
        return
    end
    
    local smoothProgress = math.sin(progress * math.pi * 0.5)
    
    CameraSystem.CameraPos = LerpVector(smoothProgress, CameraSystem.StartPos, CameraSystem.EndPos)
    
    local targetPos = CameraSystem.TargetPlayer:GetPos() + Vector(0, 0, 50)
    local baseAng = (targetPos - CameraSystem.CameraPos):Angle()
    
    CameraSystem.SwayTime = CameraSystem.SwayTime + FrameTime()
    CameraSystem.NoiseTime = CameraSystem.NoiseTime + FrameTime()
    CameraSystem.ZoomCycle = CameraSystem.ZoomCycle + FrameTime() * 0.3
    
    local swayAmount = 0.5
    local noiseAmount = 0.2
    local swayX = math.sin(CameraSystem.SwayTime * 0.8) * swayAmount
    local swayY = math.cos(CameraSystem.SwayTime * 0.6) * swayAmount * 0.5
    
    local noiseX = (math.random() - 0.5) * noiseAmount
    local noiseY = (math.random() - 0.5) * noiseAmount
    
    CameraSystem.CameraAng = baseAng + Angle(swayX + noiseX, swayY + noiseY, 0)
    
    local baseFOV = 75
    local zoomVariation = math.sin(CameraSystem.ZoomCycle) * 10
    CameraSystem.FOV = baseFOV + zoomVariation
end

hook.Add("CalcView", "CameraSystem", function(ply, pos, angles, fov)
    if not CameraSystem.Active then return end
    
    local view = {}
    view.origin = CameraSystem.CameraPos
    view.angles = CameraSystem.CameraAng
    view.fov = CameraSystem.FOV
    view.drawviewer = true
    
    return view
end)

hook.Add("RenderScreenspaceEffects", "CameraSystem", function()
    if not CameraSystem.Active then return end
    
    local alpha = math.sin(CurTime() * 2) * 0.05 + 0.95
    
    local tab = {
        ["$pp_colour_addr"] = 0.02,
        ["$pp_colour_addg"] = 0.02, 
        ["$pp_colour_addb"] = 0.02,
        ["$pp_colour_brightness"] = -0.1,
        ["$pp_colour_contrast"] = 1.2,
        ["$pp_colour_colour"] = 0.8,
        ["$pp_colour_mulr"] = alpha,
        ["$pp_colour_mulg"] = alpha,
        ["$pp_colour_mulb"] = alpha
    }
    
    DrawColorModify(tab)
    
    local noiseIntensity = 0.05
    local staticEffect = {
        ["$pp_colour_addr"] = math.random() * noiseIntensity - noiseIntensity/2,
        ["$pp_colour_addg"] = math.random() * noiseIntensity - noiseIntensity/2,
        ["$pp_colour_addb"] = math.random() * noiseIntensity - noiseIntensity/2,
        ["$pp_colour_brightness"] = math.random() * 0.02 - 0.01,
        ["$pp_colour_contrast"] = 1 + (math.random() * 0.1 - 0.05),
        ["$pp_colour_colour"] = 1,
        ["$pp_colour_mulr"] = 1,
        ["$pp_colour_mulg"] = 1,
        ["$pp_colour_mulb"] = 1
    }
    
    if math.random() < 0.3 then
        DrawColorModify(staticEffect)
    end
end)

hook.Add("Think", "CameraSystem", function()
    local shouldBeActive = MuR.Gamemode == 14 and not LocalPlayer():Alive() and MuR.Data["PoliceState"] == 5
    
    if shouldBeActive and not CameraSystem.Active then
        StartCameraSystem()
    elseif not shouldBeActive and CameraSystem.Active then
        StopCameraSystem()
    end
    
    if CameraSystem.Active then
        UpdateCamera()
    end
end)

timer.Create("CameraSystemUpdate", 15, 0, function()
    if CameraSystem.Active and MuR.Gamemode == 14 and not LocalPlayer():Alive() and MuR.Data["PoliceState"] == 5 then
        StopCameraSystem()
        timer.Simple(0.1, function()
            StartCameraSystem()
        end)
    end
end)
