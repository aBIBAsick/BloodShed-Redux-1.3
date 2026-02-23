
util.AddNetworkString("MuR.RagdollMenu")
util.AddNetworkString("MuR.RagdollAction")
util.AddNetworkString("MuR.RagdollActionCancel")
util.AddNetworkString("MuR.RagdollPulseResult")
util.AddNetworkString("MuR.RagdollWoundsResult")
util.AddNetworkString("MuR.RagdollSearchResult")
util.AddNetworkString("MuR.RagdollBeingChecked")

local function GetWoundsFromRagdoll(ragdoll)
    local wounds = {}
    local owner = ragdoll.Owner or ragdoll.OwnerDead
    local isDead = not IsValid(ragdoll.Owner)

    local addedWounds = {}
    local function addWound(locKey, severity)
        if addedWounds[locKey] then return end
        addedWounds[locKey] = true
        table.insert(wounds, {locKey = locKey, severity = severity or 2})
    end

    local function getBool(key)

        if ragdoll.StoredWounds and ragdoll.StoredWounds[key] then
            return true
        end

        if ragdoll:GetNW2Bool(key, false) then
            return true
        end

        if IsValid(owner) then
            if owner:GetNW2Bool(key, false) then
                return true
            end
        end
        return false
    end

    local function getFloat(key, default)
        if ragdoll.StoredWounds and ragdoll.StoredWounds[key .. "_value"] then
            return ragdoll.StoredWounds[key .. "_value"]
        end
        if IsValid(owner) then
            return owner:GetNW2Float(key, default or 0)
        end
        return default or 0
    end

    if ragdoll.StoredWounds then
        if ragdoll.StoredWounds.had_bullet then addWound("wound_bullet", 3) end
        if ragdoll.StoredWounds.had_explosion then addWound("wound_explosion", 3) end
        if ragdoll.StoredWounds.had_slash then addWound("wound_slash", 3) end
        if ragdoll.StoredWounds.had_blunt then addWound("wound_blunt", 2) end
        if ragdoll.StoredWounds.had_burn then addWound("wound_burn", 2) end
    end

    local function checkDamageType(dmgType)
        local isBullet = bit.band(dmgType, DMG_BULLET) ~= 0 or bit.band(dmgType, DMG_BUCKSHOT) ~= 0
        local isBlast = bit.band(dmgType, DMG_BLAST) ~= 0
        local isSlash = bit.band(dmgType, DMG_SLASH) ~= 0
        local isBlunt = bit.band(dmgType, DMG_CLUB) ~= 0 or bit.band(dmgType, DMG_CRUSH) ~= 0
        local isBurn = bit.band(dmgType, DMG_BURN) ~= 0

        if isBullet then addWound("wound_bullet", 3) end
        if isBlast then addWound("wound_explosion", 3) end
        if isSlash then addWound("wound_slash", 3) end

        if isBlunt and not isBullet and not isBlast and not isSlash then
            addWound("wound_blunt", 2)
        end
        if isBurn then addWound("wound_burn", 2) end
    end

    if ragdoll.DamageHistory and istable(ragdoll.DamageHistory) then
        for _, dmgType in pairs(ragdoll.DamageHistory) do
            checkDamageType(dmgType)
        end
    end

    if ragdoll.LastDamageInfo then
        local dmgType = ragdoll.LastDamageInfo[1]
        if dmgType then
            checkDamageType(dmgType)
        end
    end

    local bleedLevel = getFloat("BleedLevel", 0)
    if ragdoll.RagdollBleedLevel then bleedLevel = math.max(bleedLevel, ragdoll.RagdollBleedLevel) end

    local hardBleed = getBool("HardBleed") or ragdoll.RagdollHardBleed

    if hardBleed then
        addWound("wound_arterial", 3)
    elseif bleedLevel >= 3 then
        addWound("wound_heavy_bleed", 3)
    elseif bleedLevel >= 2 then
        addWound("wound_moderate_bleed", 2)
    elseif bleedLevel >= 1 then
        addWound("wound_light_bleed", 1)
    end

    if getBool("LegBroken") then addWound("wound_leg_broken", 3) end
    if getBool("ShockState") then addWound("wound_shock", 3) end
    if getBool("RibFracture") then addWound("wound_rib_fracture", 2) end
    if getBool("SpineBroken") then addWound("wound_spine_broken", 3) end
    if getBool("Pneumothorax") then addWound("wound_pneumothorax", 3) end
    if getBool("Poison") then addWound("wound_poison", 3) end
    if getBool("Bredogen") then addWound("wound_bredogen", 2) end
    if getBool("IsUnconscious") then addWound("wound_unconscious", 3) end
    if getBool("ForceProneOnly") then addWound("wound_cant_stand", 3) end

    if getBool("had_concussion") then
        addWound("wound_concussion", 2)
    elseif IsValid(owner) and owner:GetNW2Float("ConcussionEnd", 0) > CurTime() then
        addWound("wound_concussion", 2)
    end

    if getBool("had_internal_bleed") or getBool("InternalBleeding") then
        addWound("wound_internal", 3)
    elseif IsValid(owner) and owner:GetNW2Float("InternalBleedEnd", 0) > CurTime() then
        addWound("wound_internal", 3)
    end

    if getBool("had_coordination_loss") then
        addWound("wound_coordination", 2)
    elseif IsValid(owner) and owner:GetNW2Float("CoordinationEnd", 0) > CurTime() then
        addWound("wound_coordination", 2)
    end

    if getBool("had_tinnitus") then
        addWound("wound_tinnitus", 1)
    elseif IsValid(owner) and owner:GetNW2Float("TinnitusEnd", 0) > CurTime() then
        addWound("wound_tinnitus", 1)
    end

    if getBool("Artery_neck") then addWound("wound_artery_neck", 3) end
    if getBool("Artery_heart") then addWound("wound_artery_heart", 3) end
    if getBool("Artery_arm") then addWound("wound_artery_arm", 3) end
    if getBool("Artery_leg") then addWound("wound_artery_leg", 3) end

    local hasDismemberment = false

    if ragdoll.Gibbed then
        hasDismemberment = true
    end

    if not hasDismemberment and ragdoll.ZippyGoreMod3_GibbedPhysBones then
        if istable(ragdoll.ZippyGoreMod3_GibbedPhysBones) then
            for k, v in pairs(ragdoll.ZippyGoreMod3_GibbedPhysBones) do
                if v then hasDismemberment = true break end
            end
        end
    end

    if not hasDismemberment and ragdoll.StoredWounds and ragdoll.StoredWounds.had_dismemberment then
        hasDismemberment = true
    end

    if not hasDismemberment then
        for i = 0, ragdoll:GetBoneCount() - 1 do
            local scale = ragdoll:GetManipulateBoneScale(i)
            if scale and scale.x < 0.01 then
                hasDismemberment = true
                break
            end
        end
    end

    if not hasDismemberment and IsValid(owner) then
        local ownerRD = owner.GetRD and owner:GetRD()
        if IsValid(ownerRD) and ownerRD ~= ragdoll then
            if ownerRD.Gibbed then
                hasDismemberment = true
            elseif ownerRD.ZippyGoreMod3_GibbedPhysBones then
                for k, v in pairs(ownerRD.ZippyGoreMod3_GibbedPhysBones) do
                    if v then hasDismemberment = true break end
                end
            end
        end
    end

    if hasDismemberment then
        addWound("wound_dismembered", 3)
    end

    local hp = ragdoll.StoredHealth or (IsValid(owner) and owner:Health()) or 0
    local maxHp = ragdoll.StoredMaxHealth or (IsValid(owner) and owner:GetMaxHealth()) or 100
    local hpRatio = maxHp > 0 and (hp / maxHp) or 0

    if isDead then
        addWound("wound_dead", 3)
    elseif hpRatio < 0.25 then
        addWound("wound_critical", 3)
    elseif hpRatio < 0.5 then
        addWound("wound_serious", 2)
    elseif hpRatio < 0.75 then
        addWound("wound_minor", 1)
    end

    return wounds
end

net.Receive("MuR.RagdollAction", function(len, ply)
    local ragdoll = net.ReadEntity()
    local action = net.ReadString()

    if not IsValid(ply) or not ply:Alive() then return end
    if not IsValid(ragdoll) or ragdoll:GetClass() ~= "prop_ragdoll" then return end
    if not ragdoll.isRDRag then return end
    if ply:GetPos():DistToSqr(ragdoll:GetPos()) > 15000 then return end

    local owner = ragdoll.Owner
    local ownerDead = ragdoll.OwnerDead
    local timerName = "MuR_RagdollAction_" .. ply:SteamID64() .. "_" .. action

    timer.Remove(timerName)

    if action == "pulse" then

        if IsValid(owner) and not owner:GetNW2Bool("IsUnconscious", false) then
            net.Start("MuR.RagdollBeingChecked")
            net.WriteString("pulse")
            net.WriteEntity(ply)
            net.Send(owner)
        end

        timer.Create(timerName, 2, 1, function()
            if not IsValid(ply) then return end

            local status
            if not IsValid(owner) or (IsValid(ownerDead) and not ownerDead:Alive()) then
                status = 0 
                MuR:GiveMessage2("corpse_dead", ply)
            elseif owner:GetNW2Bool("IsUnconscious", false) then
                status = 1 
                MuR:GiveMessage2("corpse_unconscious", ply)
            else
                status = 2 
                MuR:GiveMessage2("corpse_alive", ply)
            end

            net.Start("MuR.RagdollPulseResult")
            net.WriteUInt(status, 2)
            net.Send(ply)
        end)

    elseif action == "wounds" then

        if IsValid(owner) then
            net.Start("MuR.RagdollBeingChecked")
            net.WriteString("wounds")
            net.WriteEntity(ply)
            net.Send(owner)
        end

        timer.Create(timerName, 5, 1, function()
            if not IsValid(ply) or not IsValid(ragdoll) then return end

            local wounds = GetWoundsFromRagdoll(ragdoll)

            net.Start("MuR.RagdollWoundsResult")
            net.WriteTable(wounds)
            net.Send(ply)
        end)

    elseif action == "search" then

        local canSearch = true
        local reason = ""

        if IsValid(owner) and not owner:GetNW2Bool("IsUnconscious", false) then
            canSearch = false
            reason = "ragdoll_search_alive"
        end

        if IsValid(owner) and owner:GetNW2Bool("IsUnconscious", false) then
            net.Start("MuR.RagdollBeingChecked")
            net.WriteString("search")
            net.WriteEntity(ply)
            net.Send(owner)
        end

        timer.Create(timerName, 2, 1, function()
            if not IsValid(ply) or not IsValid(ragdoll) then return end

            net.Start("MuR.RagdollSearchResult")
            net.WriteBool(canSearch)
            net.WriteString(reason)
            net.Send(ply)

            if canSearch and istable(ragdoll.Inventory) then

                if IsValid(owner) and owner:GetNW2Bool("IsUnconscious", false) then
                    if not ragdoll.UnconsciousInventoryTransferred then
                        ragdoll.UnconsciousInventoryTransferred = true
                        for _, wep in pairs(owner:GetWeapons()) do
                            if not wep.CantDrop then
                                local cls = wep:GetClass()
                                if not table.HasValue(ragdoll.Inventory, cls) then
                                    table.insert(ragdoll.Inventory, cls)
                                end
                            end
                        end
                    end
                end

                if IsValid(ragdoll.Weapon) then
                    ragdoll.Weapon:Remove()
                end

                local tab = {}
                for _, item in pairs(ragdoll.Inventory) do
                    if IsValid(item) then
                        table.insert(tab, item:GetClass())
                    elseif isstring(item) then
                        table.insert(tab, item)
                    end
                end

                net.Start("MuR.BodySearch")
                net.WriteTable(tab)
                net.WriteEntity(ragdoll)
                net.Send(ply)
            end
        end)
    end
end)

net.Receive("MuR.RagdollActionCancel", function(len, ply)
    if not IsValid(ply) then return end

    local steamId = ply:SteamID64()

    timer.Remove("MuR_RagdollAction_" .. steamId .. "_pulse")
    timer.Remove("MuR_RagdollAction_" .. steamId .. "_wounds")
    timer.Remove("MuR_RagdollAction_" .. steamId .. "_search")
end)

hook.Add("PlayerButtonDown", "MuR_RagdollMenuInteraction", function(ply, but)
    if but ~= KEY_E then return end
    if not ply:Alive() or ply:GetNoDraw() then return end
    if IsValid(ply:GetRD()) then return end

    local tr = ply:GetEyeTrace().Entity
    if not IsValid(tr) then return end
    if tr:GetClass() ~= "prop_ragdoll" then return end
    if not tr.isRDRag then return end
    if tr:GetPos():DistToSqr(ply:GetPos()) > 10000 then return end

    if IsValid(ply:GetRD()) and tr == ply:GetRD() then return end

    net.Start("MuR.RagdollMenu")
    net.WriteEntity(tr)
    net.Send(ply)
end)

hook.Add("EntityTakeDamage", "MuR_StoreDamageHistory", function(target, dmginfo)
    if not IsValid(target) then return end

    local ply = target
    local rd = nil

    if target:GetClass() == "prop_ragdoll" then
        rd = target
        if target.Owner then
            ply = target.Owner
        end
    elseif target:IsPlayer() then
        ply = target
        rd = ply.GetRD and ply:GetRD()
    end

    if not IsValid(rd) then return end

    rd.DamageHistory = rd.DamageHistory or {}
    table.insert(rd.DamageHistory, dmginfo:GetDamageType())
    if #rd.DamageHistory > 10 then
        table.remove(rd.DamageHistory, 1)
    end
    rd.LastDamageInfo = {dmginfo:GetDamageType(), dmginfo:GetDamagePosition()}

    rd.StoredWounds = rd.StoredWounds or {}
    local dmgType = dmginfo:GetDamageType()

    local isBullet = bit.band(dmgType, DMG_BULLET) ~= 0 or bit.band(dmgType, DMG_BUCKSHOT) ~= 0
    local isBlast = bit.band(dmgType, DMG_BLAST) ~= 0
    local isSlash = bit.band(dmgType, DMG_SLASH) ~= 0
    local isBlunt = bit.band(dmgType, DMG_CLUB) ~= 0 or bit.band(dmgType, DMG_CRUSH) ~= 0
    local isBurn = bit.band(dmgType, DMG_BURN) ~= 0

    if isBullet then rd.StoredWounds.had_bullet = true end
    if isBlast then rd.StoredWounds.had_explosion = true end
    if isSlash then rd.StoredWounds.had_slash = true end

    if isBlunt and not isBullet and not isBlast and not isSlash then
        rd.StoredWounds.had_blunt = true
    end
    if isBurn then rd.StoredWounds.had_burn = true end
end)

hook.Add("PlayerDeath", "MuR_StoreDeathData", function(victim, inflictor, attacker)
    timer.Simple(0.1, function()
        if not IsValid(victim) then return end

        local ragdoll
        for _, ent in pairs(ents.FindByClass("prop_ragdoll")) do
            if ent.OwnerDead == victim or (ent.isRDRag and not IsValid(ent.Owner)) then
                if ent:GetPos():DistToSqr(victim:GetPos()) < 10000 then
                    ragdoll = ent
                    break
                end
            end
        end

        if not IsValid(ragdoll) then return end

        ragdoll.StoredWounds = ragdoll.StoredWounds or {}

        local boolKeys = {"HardBleed", "LegBroken", "ShockState", "RibFracture", "SpineBroken", 
            "Pneumothorax", "Poison", "Bredogen", "IsUnconscious", "ForceProneOnly",
            "Artery_neck", "Artery_heart", "Artery_arm", "Artery_leg", "InternalBleeding"}

        for _, key in ipairs(boolKeys) do
            if victim:GetNW2Bool(key, false) then
                ragdoll.StoredWounds[key] = true
            end
        end

        if victim:GetNW2Float("ConcussionEnd", 0) > CurTime() then
            ragdoll.StoredWounds.had_concussion = true
        end
        if victim:GetNW2Float("InternalBleedEnd", 0) > CurTime() then
            ragdoll.StoredWounds.had_internal_bleed = true
        end
        if victim:GetNW2Float("CoordinationEnd", 0) > CurTime() then
            ragdoll.StoredWounds.had_coordination_loss = true
        end
        if victim:GetNW2Float("TinnitusEnd", 0) > CurTime() then
            ragdoll.StoredWounds.had_tinnitus = true
        end

        ragdoll.StoredWounds.BleedLevel_value = victim:GetNW2Float("BleedLevel", 0)

        ragdoll.StoredHealth = victim:Health()
        ragdoll.StoredMaxHealth = victim:GetMaxHealth()

        local oldRD = victim.GetRD and victim:GetRD()
        if IsValid(oldRD) then

            if oldRD.Gibbed then
                ragdoll.Gibbed = true
                ragdoll.StoredWounds.had_dismemberment = true
            end

            if oldRD.StoredWounds then
                for k, v in pairs(oldRD.StoredWounds) do
                    ragdoll.StoredWounds[k] = v
                end
            end

            if oldRD.DamageHistory then
                ragdoll.DamageHistory = table.Copy(oldRD.DamageHistory)

                for _, dmgType in pairs(oldRD.DamageHistory) do
                    local isBullet = bit.band(dmgType, DMG_BULLET) ~= 0 or bit.band(dmgType, DMG_BUCKSHOT) ~= 0
                    local isBlast = bit.band(dmgType, DMG_BLAST) ~= 0
                    local isSlash = bit.band(dmgType, DMG_SLASH) ~= 0
                    local isBlunt = bit.band(dmgType, DMG_CLUB) ~= 0 or bit.band(dmgType, DMG_CRUSH) ~= 0
                    local isBurn = bit.band(dmgType, DMG_BURN) ~= 0

                    if isBullet then ragdoll.StoredWounds.had_bullet = true end
                    if isBlast then ragdoll.StoredWounds.had_explosion = true end
                    if isSlash then ragdoll.StoredWounds.had_slash = true end
                    if isBlunt and not isBullet and not isBlast and not isSlash then
                        ragdoll.StoredWounds.had_blunt = true
                    end
                    if isBurn then ragdoll.StoredWounds.had_burn = true end
                end
            end

            if oldRD.ZippyGoreMod3_GibbedPhysBones then
                ragdoll.ZippyGoreMod3_GibbedPhysBones = table.Copy(oldRD.ZippyGoreMod3_GibbedPhysBones)
                ragdoll.StoredWounds.had_dismemberment = true
                for k, v in pairs(oldRD.ZippyGoreMod3_GibbedPhysBones) do
                    if v then
                        ragdoll.StoredWounds.had_dismemberment = true
                        break
                    end
                end
            end
        end

        if ragdoll.ZippyGoreMod3_GibbedPhysBones then
            for k, v in pairs(ragdoll.ZippyGoreMod3_GibbedPhysBones) do
                if v then
                    ragdoll.StoredWounds.had_dismemberment = true
                    break
                end
            end
        end
    end)
end)
