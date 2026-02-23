if SERVER then 
    util.AddNetworkString("AnimFootstep")
    util.AddNetworkString("AnimJumpSound")
end

local SOUND_PREFIXES = {
    concrete = "concrete",
    metal = "metal",
    metalvehicle = "metal",
    combine_metal = "metal",
    solidmetal = "solidmetal",
    dirt = "dirt",
    grate = "grate",
    tile = "tile",
    wood = "wood",
    wood_crate = "woodcrate",
    glass = "glass",
    plastic = "plastic",
    paintcan = "plastic",
    plastic_barrel = "plastic",
    grass = "grass",
    sand = "sand",
    computer = "computer",
    flesh = "flesh",
    alienflesh = "alienflesh",
    bloodyflesh = "bloodyflesh",
    snow = "snow",
    default = "concrete",
    metalvent = "duct",
    wood_panel = "woodpanel",
    wood_plank = "woodplank",
    metalgrate = "metalgrate",
    rubber = "rubber",
    slosh = "slosh",
    gravel = "gravel",
    mud = "mud",
    chainlink = "chainlink",
    zombieflesh = "flesh",
    metalpanel = "metalpanel",
    ceiling_tile = "ceilingtile",
    paper = "cardboard",
    carpet = "dirt",
    cardboard = "cardboard",
    plaster = "plaster",
    metal_barrel = "metalbarrel",
    combine_glass = "glass"
}

local MAT_TYPE_MAP = {
    [MAT_GLASS] = "glass",
    [MAT_METAL] = "metal",
    [MAT_WOOD] = "wood",
    [MAT_CONCRETE] = "concrete",
    [MAT_DIRT] = "dirt",
    [MAT_SAND] = "sand",
    [MAT_GRASS] = "grass",
    [MAT_PLASTIC] = "plastic",
    [MAT_TILE] = "tile",
    [MAT_SLOSH] = "slosh",
    [MAT_GRATE] = "metalgrate",
    [MAT_VENT] = "vent",
    [MAT_FOLIAGE] = "foliage",
    [MAT_RUBBER] = "rubber",
    [MAT_SOLIDMETAL] = "solidmetal"
}

local SOUND_TEMPLATES = {
    slosh = {"player/footsteps/slosh%d.wav", 4},
    glass = {"physics/glass/glass_sheet_step%d.wav", 4},
    duct = {"player/footsteps/duct%d.wav", 4},
    woodpanel = {"player/footsteps/woodpanel%d.wav", 4},
    metalgrate = {"player/footsteps/metalgrate%d.wav", 4},
    concrete = {"player/footsteps/concrete%d.wav", 4},
    metal = {"player/footsteps/metal%d.wav", 4},
    solidmetal = {"player/footsteps/metal%d.wav", 4},
    metalpanel = {"player/footsteps/metalpanel%d.wav", 4},
    wood = {"player/footsteps/wood%d.wav", 4},
    woodplank = {"physics/wood/wood_box_footstep%d.wav", 4},
    woodcrate = {"physics/wood/wood_box_footstep%d.wav", 4},
    dirt = {"player/footsteps/dirt%d.wav", 4},
    tile = {"player/footsteps/tile%d.wav", 4},
    grate = {"player/footsteps/grate%d.wav", 4},
    rubber = {"physics/rubber/rubber_tire_impact_soft1.wav", 1},
    ceilingtile = {"physics/plaster/ceiling_tile_step%d.wav", 4},
    cardboard = {"physics/cardboard/cardboard_box_impact_soft%d.wav", 7},
    plaster = {"physics/plaster/drywall_footstep%d.wav", 4},
    plastic = {"physics/plastic/plastic_barrel_impact_soft%d.wav", 6},
    grass = {"player/footsteps/grass%d.wav", 4},
    sand = {"player/footsteps/sand%d.wav", 4},
    snow = {"player/footsteps/snow%d.wav", 4},
    gravel = {"player/footsteps/gravel%d.wav", 4},
    mud = {"player/footsteps/mud%d.wav", 4},
    chainlink = {"player/footsteps/chainlink%d.wav", 4}
}

local anim_footsteps_enabled = CreateConVar("anim_footsteps_enabled", "1", FCVAR_ARCHIVE, "Включить синхронизацию шагов с анимацией")
local anim_footsteps_offset = CreateConVar("anim_footsteps_offset", "8", FCVAR_ARCHIVE, "Вертикальное смещение для проверки контакта ноги")
local anim_footsteps_delay = CreateConVar("anim_footsteps_delay", "0.15", FCVAR_ARCHIVE, "Минимальная задержка между шагами одной ноги")

local FOOT_BONES = {
    left = "ValveBiped.Bip01_L_Foot",
    right = "ValveBiped.Bip01_R_Foot"
}

local traceResult = {}

hook.Add("PlayerFootstep", "FuckDefaultOne", function(ply, pos, foot, sound, volume, rf)
    if ply:GetMoveType() == MOVETYPE_LADDER or ply:GetMoveType() == MOVETYPE_NOCLIP then
        return false
    end
    if not anim_footsteps_enabled:GetBool() then
        return false
    end
    return true
end)

local function GetSoundPrefix(materialName)
    if not materialName then return "concrete" end
    return SOUND_PREFIXES[string.lower(materialName)] or "concrete"
end

local function GetSurfaceFromTrace(trace)
    if trace.SurfaceProps ~= -1 then
        local surfaceData = util.GetSurfaceData(trace.SurfaceProps)
        if surfaceData then
            return surfaceData.name
        end
    end
    return MAT_TYPE_MAP[trace.MatType] or "default"
end

local function DoTrace(startPos, endPos, filter)
    return util.TraceLine({
        start = startPos,
        endpos = endPos,
        filter = filter,
        mask = MASK_PLAYERSOLID,
        collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
        output = traceResult
    })
end

local function GetFootSurface(ply, footPos)
    if not IsValid(ply) or not footPos then return nil end
    
    local trace = DoTrace(footPos, footPos - Vector(0, 0, anim_footsteps_offset:GetFloat()), ply)
    
    if not trace.Hit then return nil end
    
    return GetSurfaceFromTrace(trace), trace.HitPos
end

local function GetPlayerGroundSurface(ply)
    if not IsValid(ply) or not ply:IsPlayer() then 
        return ply and ply.lastSurface or "concrete" 
    end
    
    if ply:WaterLevel() == 1 then
        return "slosh"
    end
    
    local trace = DoTrace(ply:GetPos(), ply:GetPos() - Vector(0, 0, 150), ply)
    
    if not trace.Hit then 
        return ply.lastSurface or "concrete" 
    end
    
    local surfaceName = GetSurfaceFromTrace(trace)
    
    if surfaceName then
        ply.lastSurface = surfaceName
        return surfaceName
    end
    
    return ply.lastSurface or "concrete"
end

local function GetSoundForMaterial(materialName)
    if not materialName then return nil end

    local prefix = GetSoundPrefix(materialName)
    local template = SOUND_TEMPLATES[prefix]
    
    if template then
        if template[2] == 1 then
            return template[1]
        end
        return string.format(template[1], math.random(1, template[2]))
    end
    
    local sound = string.format("player/footsteps/%s%d.wav", prefix, math.random(1, 4))
    
    if CLIENT and not file.Exists("sound/" .. sound, "GAME") then
        return string.format("player/footsteps/concrete%d.wav", math.random(1, 4))
    end
    
    return sound
end

local function PlayJumpSound(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    
    local waterLevel = ply:WaterLevel()
    local surfaceName = waterLevel == 1 and "slosh" or GetPlayerGroundSurface(ply)
    local soundPath = GetSoundForMaterial(surfaceName) or string.format("player/footsteps/concrete%d.wav", math.random(1, 4))
    
    local volume = 0.6
    local pitch = math.random(95, 105)

    if ply:Crouching() then
        volume = volume * 0.7
    end

    if waterLevel == 3 then
        volume = volume * 0.4
    end
    
    if SERVER then
        if game.SinglePlayer() then
            ply:EmitSound(soundPath, 75, pitch, volume, CHAN_BODY)
        else
            net.Start("AnimJumpSound")
                net.WriteEntity(ply)
                net.WriteString(soundPath)
                net.WriteUInt(math.floor(volume * 100), 7)
                net.WriteUInt(pitch, 8)
            net.Broadcast()
        end
    else
        ply:EmitSound(soundPath, 75, pitch, volume, CHAN_BODY)
    end

    ply.lastSurface = surfaceName
end

local function PlayFootstepForBone(ply, boneName, side)
    if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
    
    local moveType = ply:GetMoveType()
    if moveType == MOVETYPE_NOCLIP or moveType == MOVETYPE_OBSERVER then return end
    
    local waterLevel = ply:WaterLevel()
    local boneIndex = ply:LookupBone(boneName)
    if not boneIndex then return end
    
    ply:SetupBones()
    
    local boneMatrix = ply:GetBoneMatrix(boneIndex)
    if not boneMatrix then return end
    
    local footPos = boneMatrix:GetTranslation()
    local surfaceName, hitPos
    local soundPath

    if waterLevel == 1 then
        surfaceName = "slosh"
        soundPath = GetSoundForMaterial("slosh")
        
        local trace = DoTrace(footPos, footPos - Vector(0, 0, anim_footsteps_offset:GetFloat()), ply)
        hitPos = trace.Hit and trace.HitPos or footPos
    else
        surfaceName, hitPos = GetFootSurface(ply, footPos)
        
        if surfaceName then
            ply.lastSurface = surfaceName
            soundPath = GetSoundForMaterial(surfaceName)
        end
    end

    if not soundPath then
        surfaceName = "concrete"
        soundPath = string.format("player/footsteps/concrete%d.wav", math.random(1, 4))
        ply.lastSurface = surfaceName
    end

    local velocity = ply:GetVelocity():Length2D()
    local volume = velocity > 150 and 0.5 or 0.35

    if waterLevel >= 1 then
        volume = volume * 1.2
    end

    if ply:Crouching() then
        volume = volume * 0.65
    end

    if waterLevel == 3 then
        volume = volume * 0.4
    end
    
    local emitPos = hitPos or footPos
    local pitch = math.random(95, 105)
    
    if SERVER then
        if game.SinglePlayer() then
            ply:EmitSound(soundPath, 75, pitch, volume, CHAN_BODY)
        end

        if not ply:IsBot() then
            net.Start("AnimFootstep")
                net.WriteEntity(ply)
                net.WriteVector(emitPos)
                net.WriteString(soundPath)
                net.WriteUInt(math.floor(volume * 100), 7)
            net.SendPAS(emitPos)
        end
    else
        ply:EmitSound(soundPath, 75, pitch, volume, CHAN_BODY)
    end
end

local function CheckForJump(ply, mv)
    if not IsValid(ply) or not ply:IsPlayer() then return false end

    if not ply.jumpData then
        ply.jumpData = {
            wasOnGround = ply:OnGround(),
            jumpPressed = false,
            jumpCooldown = 0
        }
    end
    
    local data = ply.jumpData
    local frameTime = FrameTime()

    if data.jumpCooldown > 0 then
        data.jumpCooldown = data.jumpCooldown - frameTime
        if data.jumpCooldown < 0 then data.jumpCooldown = 0 end
    end
    
    local isOnGround = ply:OnGround()
    local jumpKeyPressed = mv:KeyDown(IN_JUMP)

    if data.wasOnGround and not isOnGround and jumpKeyPressed and not data.jumpPressed and data.jumpCooldown <= 0 then
        PlayJumpSound(ply)
        data.jumpPressed = true
        data.jumpCooldown = 0.2
    end

    if isOnGround then
        data.jumpPressed = false
    end

    data.wasOnGround = isOnGround
    
    return data.jumpPressed
end

local function CheckAnimatedFootsteps()
    if not anim_footsteps_enabled:GetBool() then return end
    
    local players
    if SERVER then
        players = player.GetAll()
    else
        local localPlayer = LocalPlayer()
        if not IsValid(localPlayer) then return end
        players = {localPlayer}
    end
    
    local frameTime = FrameTime()
    local offset = anim_footsteps_offset:GetFloat()
    local delayTime = anim_footsteps_delay:GetFloat()
    
    for _, ply in ipairs(players) do
        if not IsValid(ply) or not ply:IsPlayer() then continue end
        if not ply:Alive() or ply:InVehicle() then continue end
        if ply:GetMoveType() == MOVETYPE_LADDER then continue end

        if not ply.footstepData then
            ply.footstepData = {
                left = {contact = false, delay = 0},
                right = {contact = false, delay = 0}
            }
        end
        
        local data = ply.footstepData

        if data.left.delay > 0 then
            data.left.delay = data.left.delay - frameTime
            if data.left.delay < 0 then data.left.delay = 0 end
        end
        if data.right.delay > 0 then
            data.right.delay = data.right.delay - frameTime
            if data.right.delay < 0 then data.right.delay = 0 end
        end

        for side, boneName in pairs(FOOT_BONES) do
            local boneIndex = ply:LookupBone(boneName)
            if not boneIndex then continue end

            ply:SetupBones()
            
            local boneMatrix = ply:GetBoneMatrix(boneIndex)
            if not boneMatrix then continue end
            
            local footPos = boneMatrix:GetTranslation()
            local trace = DoTrace(footPos, footPos - Vector(0, 0, offset), ply)
            
            local currentContact = trace.Hit and (footPos.z - trace.HitPos.z) < 10
            
            if currentContact and not data[side].contact and data[side].delay <= 0 then
                PlayFootstepForBone(ply, boneName, side)
                data[side].delay = delayTime
            end
            
            data[side].contact = currentContact
        end
    end
end

hook.Add("SetupMove", "AnimFootstepsMove", function(ply, mv, cmd)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    CheckForJump(ply, mv)
end)

hook.Add("Tick", "AnimFootstepsThink", CheckAnimatedFootsteps)

if CLIENT and not game.SinglePlayer() then
    net.Receive("AnimFootstep", function()
        local ply = net.ReadEntity()
        local pos = net.ReadVector()
        local soundPath = net.ReadString()
        local volume = net.ReadUInt(7) / 100
        
        if not IsValid(ply) or ply == LocalPlayer() or not ply:IsPlayer() then return end
        
        ply:EmitSound(soundPath, 75, math.random(95, 105), volume, CHAN_BODY)
    end)
    
    net.Receive("AnimJumpSound", function()
        local ply = net.ReadEntity()
        local soundPath = net.ReadString()
        local volume = net.ReadUInt(7) / 100
        local pitch = net.ReadUInt(8)
        
        if not IsValid(ply) or ply == LocalPlayer() then return end
        
        ply:EmitSound(soundPath, 75, pitch, volume, CHAN_BODY)
    end)
end

local function CleanupPlayerData(ply)
    ply.footstepData = nil
    ply.jumpData = nil
    ply.lastSurface = nil
end

hook.Add("PlayerDeath", "CleanupFootstepData", CleanupPlayerData)

hook.Add("PlayerSpawn", "CleanupFootstepDataSpawn", function(ply)
    ply.footstepData = nil
    ply.jumpData = nil
end)

hook.Add("EntityRemoved", "CleanupFootstepDataRemoved", function(ent)
    if ent:IsPlayer() then
        CleanupPlayerData(ent)
    end
end)