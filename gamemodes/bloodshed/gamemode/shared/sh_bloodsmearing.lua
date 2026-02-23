if SERVER then
    util.AddNetworkString("MuR.RagdollBloodSmear")
    
    local ragdollBloodData = {}
    
    local function SendBloodSmear(pos, normal, velocity, size)
        net.Start("MuR.RagdollBloodSmear")
        net.WriteVector(pos)
        net.WriteVector(normal)
        net.WriteVector(velocity)
        net.WriteFloat(size)
        net.Broadcast()
    end

    function MuR:RemoveSmearingBlood(ent)
        if !IsValid(ent) or !istable(ragdollBloodData[ent]) then return end
        ragdollBloodData[ent] = nil
    end

    function MuR:AddSmearingBlood(ent)
        if !IsValid(ent) or istable(ragdollBloodData[ent]) then return end
        ragdollBloodData[ent] = {
            lastPos = ent:WorldSpaceCenter(),
            lastVel = Vector(0, 0, 0),
            nextBloodTime = 0
        }
    end
    
    hook.Add("EntityRemoved", "MuR.CleanupRagdollBloodS", function(ent)
        if ragdollBloodData[ent] then
            ragdollBloodData[ent] = nil
        end
    end)
    
    hook.Add("Think", "MuR.RagdollBloodSmearing", function()
        local curTime = CurTime()
        
        for ragdoll, data in pairs(ragdollBloodData) do
            if not IsValid(ragdoll) then
                ragdollBloodData[ragdoll] = nil
                continue
            end
            
            do
                local physObj = ragdoll:GetPhysicsObjectNum(1)
                if IsValid(physObj) then
                    local pos = physObj:GetPos()
                    local vel = physObj:GetVelocity()
                    local speed = vel:Length()

                    if speed > 20 and curTime > data.nextBloodTime then
                        local trace = util.TraceLine({
                            start = pos,
                            endpos = pos + vel:GetNormalized() * 4 - Vector(0,0,16),
                            mask = MASK_SOLID,
                            filter = function(ent)
                                if ent == ragdoll then return false end
                                if ent:IsPlayer() or ent:IsNPC() then return false end
                                return true
                            end
                        })

                        if trace.Hit then
                            SendBloodSmear(trace.HitPos, vel:GetNormalized(), vel, 0.4)
                            data.nextBloodTime = curTime + 0.05
                            break
                        end
                    end
                end
            end
            
            data.lastPos = ragdoll:GetPos()
            data.lastVel = ragdoll:GetVelocity()
        end
    end)
end

if CLIENT then
    local bloodMaterials = {}
    for i = 1,21 do
        local imat = "rlb/blood"..i
        table.insert(bloodMaterials, imat)
    end
    
    local function CreateBloodSmear(pos, normal, velocity, size)
        local speed = velocity:Length()
        local smearDir = velocity:GetNormalized()
        
        if speed > 50 then
            local smearCount = math.Clamp(speed / 100, 2, 5)
            local smearLength = size * speed / 50
            
            for i = 0, smearCount do
                local offset = (i / smearCount) * smearLength
                local smearPos = pos + smearDir * offset
                local currentSize = size * (1 - i / smearCount * 0.3)
                local xsize, ysize = currentSize*math.Rand(2,3), currentSize*math.Rand(0.5,1.5)
                
                util.DecalEx(
                    Material(bloodMaterials[math.random(#bloodMaterials)]),
                    game.GetWorld(),
                    smearPos,
                    normal,
                    Color(255, 255, 255, 255),
                    currentSize*3,
                    currentSize
                )
            end
        else
            util.DecalEx(
                Material(bloodMaterials[math.random(#bloodMaterials)]),
                game.GetWorld(),
                pos,
                normal,
                Color(255, 255, 255, 255),
                size,
                size
            )
        end
    end
    
    net.Receive("MuR.RagdollBloodSmear", function()
        local pos = net.ReadVector()
        local normal = net.ReadVector()
        local velocity = net.ReadVector()
        local size = net.ReadFloat()
        
        CreateBloodSmear(pos, normal, velocity, size)
    end)
end