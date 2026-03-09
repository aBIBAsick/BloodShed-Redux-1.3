if SERVER then
    util.AddNetworkString("MuR.RagdollBloodSmear")
    util.AddNetworkString("MuR.BloodPoolEffect")
    util.AddNetworkString("MuR.BloodSplatterEffect")
    util.AddNetworkString("MuR.OrganBleedEffect")
    util.AddNetworkString("MuR.StandaloneBloodSpray")

    local ragdollBloodData = {}
    local BLOOD_BROADCAST_DIST_SQR = 5000 * 5000

    local function SendBloodNetMessage(pos)
        if not isvector(pos) then return end

        local recipients = {}
        for _, ply in player.Iterator() do
            if not IsValid(ply) then continue end

            local refEnt = IsValid(ply:GetRD()) and ply:GetRD() or ply
            local refPos = refEnt.WorldSpaceCenter and refEnt:WorldSpaceCenter() or refEnt:GetPos()
            if refPos:DistToSqr(pos) <= BLOOD_BROADCAST_DIST_SQR then
                recipients[#recipients + 1] = ply
            end
        end

        if #recipients > 0 then
            net.Send(recipients)
        else
            net.SendPVS(pos)
        end
    end

    local function SendBloodSmear(pos, normal, velocity, size)
        net.Start("MuR.RagdollBloodSmear")
        net.WriteVector(pos)
        net.WriteVector(normal)
        net.WriteVector(velocity)
        net.WriteFloat(size)
        SendBloodNetMessage(pos)
    end

    local function GetBloodEffectOrigin(ent, boneid)
        if not IsValid(ent) then return vector_origin end

        local origin = ent:WorldSpaceCenter()
        if isnumber(boneid) and boneid >= 0 and ent.GetBonePosition then
            local bonePos = ent:GetBonePosition(boneid)
            if isvector(bonePos) and (bonePos ~= vector_origin or origin:DistToSqr(vector_origin) <= 1) then
                origin = bonePos
            end
        end

        return origin
    end

    function MuR:BroadcastBloodPoolEffect(ent, boneid, flags, needvel)
        if not IsValid(ent) then return end

        boneid = math.max(math.floor(tonumber(boneid) or 0), 0)
        flags = math.Clamp(math.floor(tonumber(flags) or 0), 0, 255)
        needvel = tonumber(needvel) or 0

        local origin = GetBloodEffectOrigin(ent, boneid)

        net.Start("MuR.BloodPoolEffect")
        net.WriteEntity(ent)
        net.WriteUInt(boneid, 16)
        net.WriteUInt(flags, 8)
        net.WriteFloat(needvel)
        net.WriteVector(origin)
        SendBloodNetMessage(origin)
    end

    function MuR:BroadcastBloodSplatterEffect(ent, pos, normal, magnitude, radius, flags)
        if not isvector(pos) then return end

        net.Start("MuR.BloodSplatterEffect")
        net.WriteEntity(IsValid(ent) and ent or NULL)
        net.WriteVector(pos)
        net.WriteVector(isvector(normal) and normal or vector_up)
        net.WriteFloat(tonumber(magnitude) or 1)
        net.WriteFloat(tonumber(radius) or 0)
        net.WriteUInt(math.Clamp(math.floor(tonumber(flags) or 0), 0, 255), 8)
        SendBloodNetMessage(pos)
    end

    function MuR:BroadcastOrganBleedEffect(ent, pos, magnitude)
        if not isvector(pos) then return end

        net.Start("MuR.OrganBleedEffect")
        net.WriteEntity(IsValid(ent) and ent or NULL)
        net.WriteVector(pos)
        net.WriteFloat(tonumber(magnitude) or 1)
        SendBloodNetMessage(pos)
    end

    function MuR:BroadcastStandaloneBloodSpray(pos, normal, magnitude, radius)
        if not isvector(pos) then return end

        net.Start("MuR.StandaloneBloodSpray")
        net.WriteVector(pos)
        net.WriteVector(isvector(normal) and normal or vector_up)
        net.WriteFloat(tonumber(magnitude) or 1)
        net.WriteFloat(tonumber(radius) or 16)
        SendBloodNetMessage(pos)
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

    local function StampBloodDecal(pos, normal, scale, ent)
        if not isvector(pos) then return end

        normal = isvector(normal) and normal:GetNormalized() or Vector(0, 0, -1)
        if normal:LengthSqr() <= 0.001 then
            normal = Vector(0, 0, -1)
        end

        local traceFilter = function(traceEnt)
            if traceEnt == ent then return false end
            return true
        end

        local traceDistance = math.max(scale * 28, 24)
        local tr = util.TraceLine({
            start = pos,
            endpos = pos + normal * traceDistance,
            mask = MASK_SOLID,
            filter = traceFilter
        })

        if not tr.Hit then
            tr = util.TraceLine({
                start = pos + Vector(0, 0, 8),
                endpos = pos - Vector(0, 0, 56),
                mask = MASK_SOLID,
                filter = traceFilter
            })
        end

        if not tr.Hit then return end

        util.DecalEx(
            Material(bloodMaterials[math.random(#bloodMaterials)]),
            IsValid(tr.Entity) and tr.Entity or game.GetWorld(),
            tr.HitPos,
            tr.HitNormal,
            Color(255, 255, 255, 255),
            scale,
            scale
        )
    end

    local function StampBloodBurst(pos, normal, radius, ent)
        local decalCount = math.Clamp(math.floor((radius or 18) / 8), 2, 5)
        local burstScale = math.Clamp((radius or 18) / 20, 0.55, 1.6)

        for i = 1, decalCount do
            local offset = VectorRand() * math.Rand(0, math.max(radius or 18, 8) * 0.35)
            StampBloodDecal(pos + offset, normal, burstScale * math.Rand(0.8, 1.2), ent)
        end
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

    local function CreateStandaloneBloodSpray(pos, normal, magnitude, radius, ent)
        if not isvector(pos) then return end

        normal = isvector(normal) and normal:GetNormalized() or vector_up
        if normal:LengthSqr() <= 0.001 then
            normal = vector_up
        end

        magnitude = math.Clamp(tonumber(magnitude) or 1, 0.5, 3)
        radius = math.Clamp(tonumber(radius) or 16, 8, 36)

        ParticleEffect("blood_impact_red_01", pos, normal:Angle())

        local emitter = ParticleEmitter(pos, false)
        if emitter then
            local count = math.Clamp(math.floor(8 * magnitude), 8, 22)
            for i = 1, count do
                local sprayNormal = (normal + VectorRand() * 0.45):GetNormalized()
                local particle = emitter:Add(bloodMaterials[math.random(#bloodMaterials)], pos + VectorRand() * 1.5)
                if particle then
                    particle:SetVelocity(sprayNormal * math.Rand(135, 290) * magnitude + Vector(0, 0, math.Rand(15, 70)))
                    particle:SetDieTime(math.Rand(0.55, 1.05))
                    particle:SetStartAlpha(220)
                    particle:SetEndAlpha(0)
                    particle:SetStartSize(math.Rand(1.4, 2.8) * magnitude)
                    particle:SetEndSize(0)
                    particle:SetStartLength(math.Rand(5, 10) * magnitude)
                    particle:SetEndLength(math.Rand(10, 18) * magnitude)
                    particle:SetGravity(Vector(0, 0, -420))
                    particle:SetAirResistance(60)
                    particle:SetColor(160, 10, 10)
                    particle:SetCollide(true)
                    particle:SetBounce(0.12)
                    particle:SetCollideCallback(function(_, hitPos, hitNormal, hitEnt)
                        StampBloodDecal(hitPos, hitNormal, math.Rand(0.3, 0.7), hitEnt)
                    end)
                end
            end
            emitter:Finish()
        end

        StampBloodBurst(pos, normal, radius * 1.15, ent)
    end

    net.Receive("MuR.RagdollBloodSmear", function()
        local pos = net.ReadVector()
        local normal = net.ReadVector()
        local velocity = net.ReadVector()
        local size = net.ReadFloat()

        CreateBloodSmear(pos, normal, velocity, size)
    end)

    net.Receive("MuR.BloodPoolEffect", function()
        local ent = net.ReadEntity()
        local boneid = net.ReadUInt(16)
        local flags = net.ReadUInt(8)
        local needvel = net.ReadFloat()
        local origin = net.ReadVector()

        local effectdata = EffectData()
        effectdata:SetEntity(IsValid(ent) and ent or NULL)
        effectdata:SetAttachment(boneid)
        effectdata:SetFlags(flags)
        effectdata:SetRadius(needvel)
        effectdata:SetOrigin(origin)
        util.Effect("bloodshed_blood_pool", effectdata, true, true)
    end)

    net.Receive("MuR.BloodSplatterEffect", function()
        local ent = net.ReadEntity()
        local pos = net.ReadVector()
        local normal = net.ReadVector()
        local magnitude = net.ReadFloat()
        local radius = net.ReadFloat()
        local flags = net.ReadUInt(8)

        local effectdata = EffectData()
        effectdata:SetEntity(IsValid(ent) and ent or NULL)
        effectdata:SetOrigin(pos)
        effectdata:SetNormal(normal)
        effectdata:SetMagnitude(magnitude)
        effectdata:SetRadius(radius)
        effectdata:SetFlags(flags)
        if IsValid(ent) and ent:IsPlayer() and not IsValid(ent:GetRD()) then
            local legacyEffectData = EffectData()
            legacyEffectData:SetEntity(NULL)
            legacyEffectData:SetOrigin(pos)
            legacyEffectData:SetNormal(normal)
            legacyEffectData:SetMagnitude(math.max(magnitude, 1))
            legacyEffectData:SetRadius(radius)
            legacyEffectData:SetFlags(flags)
            util.Effect("mur_blood_splatter_effect", legacyEffectData, true, true)
            CreateStandaloneBloodSpray(pos, normal, math.max(magnitude, 1), radius > 0 and radius or 16, ent)
        else
            util.Effect("mur_blood_splatter_effect", effectdata, true, true)
            StampBloodBurst(pos, normal, radius > 0 and radius or 16, ent)
        end
    end)

    net.Receive("MuR.OrganBleedEffect", function()
        local ent = net.ReadEntity()
        local pos = net.ReadVector()
        local magnitude = net.ReadFloat()

        local effectdata = EffectData()
        effectdata:SetEntity(IsValid(ent) and ent or NULL)
        effectdata:SetOrigin(pos)
        effectdata:SetMagnitude(magnitude)
        util.Effect("mur_organ_bleed", effectdata, true, true)
        StampBloodDecal(pos, Vector(0, 0, -1), math.Clamp(0.7 + magnitude * 0.35, 0.7, 1.6), ent)
    end)

    net.Receive("MuR.StandaloneBloodSpray", function()
        local pos = net.ReadVector()
        local normal = net.ReadVector()
        local magnitude = net.ReadFloat()
        local radius = net.ReadFloat()

        CreateStandaloneBloodSpray(pos, normal, magnitude, radius, nil)
    end)
end
