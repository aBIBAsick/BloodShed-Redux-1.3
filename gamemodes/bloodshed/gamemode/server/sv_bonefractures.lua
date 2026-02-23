if not SERVER then return end

MuR = MuR or {}

local meta = FindMetaTable("Player")
if not meta then return end

local boneGroup = {
	["ValveBiped.Bip01_L_Clavicle"] = "arm",
	["ValveBiped.Bip01_L_UpperArm"] = "arm",
	["ValveBiped.Bip01_L_Forearm"] = "arm",
	["ValveBiped.Bip01_L_Hand"] = "arm",
	["ValveBiped.Bip01_R_Clavicle"] = "arm",
	["ValveBiped.Bip01_R_UpperArm"] = "arm",
	["ValveBiped.Bip01_R_Forearm"] = "arm",
	["ValveBiped.Bip01_R_Hand"] = "arm",

	["ValveBiped.Bip01_L_Thigh"] = "leg",
	["ValveBiped.Bip01_L_Calf"] = "leg",
	["ValveBiped.Bip01_L_Foot"] = "leg",
	["ValveBiped.Bip01_L_Toe0"] = "leg",
	["ValveBiped.Bip01_R_Thigh"] = "leg",
	["ValveBiped.Bip01_R_Calf"] = "leg",
	["ValveBiped.Bip01_R_Foot"] = "leg",
	["ValveBiped.Bip01_R_Toe0"] = "leg",

	["ValveBiped.Bip01_Pelvis"] = "pelvis",

	["ValveBiped.Bip01_Head1"] = "jaw",
	["ValveBiped.Bip01_Neck1"] = "jaw",
}

local function canDo(ply, key, t)
	ply._bf_cd = ply._bf_cd or {}
	if (ply._bf_cd[key] or 0) > CurTime() then return false end
	ply._bf_cd[key] = CurTime() + (t or 6)
	return true
end

hook.Add("EntityTakeDamage", "MuR_BoneFractures", function(ent, dmg)
	if not IsValid(ent) then return end
	if ent.Owner and ent.Owner:IsPlayer() then ent = ent.Owner end
	if not ent:IsPlayer() or not ent:Alive() then return end
	if ent.IsRoleWithoutOrgans and ent:IsRoleWithoutOrgans() then return end

	local force = dmg:GetDamageForce()
	local att = dmg:GetAttacker()
	if force:IsZero() and IsValid(att) and att:IsPlayer() then
		force = att:GetAimVector() * 100
	end

	local tar = ent
	local rd = ent.GetRD and ent:GetRD()
	if IsValid(rd) then tar = rd end
	local bone = tar:GetNearestBoneFromPos(dmg:GetDamagePosition(), force)
	if not bone then return end

	local grp = boneGroup[bone]
	if not grp then return end

	local dm = dmg:GetDamage()
	if dm < 8 then return end

	local dt = dmg:GetDamageType()
	local blunt = bit.band(dt, DMG_CLUB) ~= 0 or bit.band(dt, DMG_CRUSH) ~= 0 or dmg:IsFallDamage()
	local blast = bit.band(dt, DMG_BLAST) ~= 0
	if not blunt and not blast then return end

	local function chance(min, scale, max)
		if dm <= min then return false end
		local c = (dm - min) / scale
		if c > max then c = max end
		if c < 0 then c = 0 end
		return math.Rand(0, 1) < c
	end

	if grp == "leg" then
		if not ent:GetNW2Bool("LegBroken") and canDo(ent, "leg", 8) and chance(12, 50, 0.6) then
			if ent.DamagePlayerSystem then ent:DamagePlayerSystem("bone") end
			if MuR.GiveMessage2 then MuR:GiveMessage2("leg_fracture", ent) end
		end

	elseif grp == "arm" then
		if not ent:GetNW2Bool("ArmFracture") and canDo(ent, "arm", 8) and chance(18, 55, 0.45) then
			ent:SetNW2Bool("ArmFracture", true)
			if MuR.GiveMessage2 then MuR:GiveMessage2("arm_fracture", ent) end
			ent:ApplyCoordinationLoss(8, 1)
			local wep = ent:GetActiveWeapon()
			if IsValid(wep) and not wep.NeverDrop and not wep.CantDrop and math.random(1, 3) == 1 then
				ent:DropWeapon(wep)
			end
		end

	elseif grp == "jaw" then
		if not ent:GetNW2Bool("JawFracture") and canDo(ent, "jaw", 10) and blunt and chance(20, 60, 0.35) then
			ent:SetNW2Bool("JawFracture", true)
			if MuR.GiveMessage2 then MuR:GiveMessage2("jaw_fracture", ent) end
			ent:ApplyConcussion(dmg, 4, 1.1)
		end

	elseif grp == "pelvis" then
		if not ent:GetNW2Bool("PelvisFracture") and canDo(ent, "pelvis", 12) and chance(25, 55, 0.4) then
			ent:SetNW2Bool("PelvisFracture", true)
			if MuR.GiveMessage2 then MuR:GiveMessage2("pelvis_fracture", ent) end
			if ent.DamagePlayerSystem then ent:DamagePlayerSystem("bone") end
			ent:ApplyCoordinationLoss(10, 1.2)
		end
	end
end)

hook.Add("PlayerSpawn", "MuR_BoneFractures_Reset", function(ply)
	if not IsValid(ply) then return end
	ply:SetNW2Bool("ArmFracture", false)
	ply:SetNW2Bool("JawFracture", false)
	ply:SetNW2Bool("PelvisFracture", false)
	ply._bf_cd = nil
end)
