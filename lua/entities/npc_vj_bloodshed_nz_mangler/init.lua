AddCSLuaFile("shared.lua")
include("shared.lua")

local function GetSounds(path)
	local sounds = {}
	local files = file.Find("sound/" .. path .. "/*", "GAME")
	for _, v in ipairs(files) do
		table.insert(sounds, path .. "/" .. v)
	end
	return sounds
end

ENT.SoundTbl_FootStep = GetSounds("bo6/npc/mangler/step")
ENT.SoundTbl_Breath = GetSounds("bo6/npc/mangler/breathe")
ENT.SoundTbl_CombatIdle = GetSounds("bo6/npc/mangler/lines")
ENT.SoundTbl_Enrage = GetSounds("bo6/npc/mangler/rage")
ENT.SoundTbl_Pain = GetSounds("bo6/npc/mangler/pain")
ENT.SoundTbl_Death = GetSounds("bo6/npc/mangler/death")
ENT.SoundTbl_Swing = GetSounds("bo6/npc/mangler/swing")
ENT.SoundTbl_MeleeAttack  = GetSounds("bo6/npc/mangler/damage")
ENT.SoundTbl_BeforeMeleeAttack = GetSounds("bo6/npc/mangler/attack")

ENT.Model = {"models/murdered/nz/bo6_mangler.mdl"}
ENT.StartHealth = 500
ENT.HullType = HULL_LARGE

ENT.VJ_NPC_Class = {"CLASS_BLOODSHED_ZOMBIE", "CLASS_ZOMBIE"}
ENT.BloodColor = "Red"
ENT.CustomBlood_Particle = {"blood_impact_red_01"}

ENT.HasMeleeAttack = true
ENT.MeleeAttackDamage = 50
ENT.MeleeAttackDamageType = DMG_BLAST
ENT.AnimTbl_MeleeAttack = {
	"nz_base_zmb_raz_attack_sickle_double_swing_1", 
	"nz_base_zmb_raz_attack_sickle_double_swing_2", 
	"nz_base_zmb_raz_attack_sickle_double_swing_3", 
	"nz_base_zmb_raz_attack_sickle_swing_down", 
	"nz_base_zmb_raz_attack_sickle_swing_l_to_r",
	"nz_base_zmb_raz_attack_sickle_swing_r_to_l",
	"nz_base_zmb_raz_attack_sickle_swing_uppercut",
	"nz_base_zmb_raz_attack_swing_l_to_r",
	"nz_base_zmb_raz_attack_swing_r_to_l",
}
ENT.MeleeAttackDistance = 72
ENT.MeleeAttackDamageDistance = 80
ENT.TimeUntilMeleeAttackDamage = false

ENT.HasRangeAttack = true
ENT.RangeAttackEntityToSpawn = "obj_vj_grenade"
ENT.AnimTbl_RangeAttack = {"nz_base_zmb_raz_attack_shoot_01"}
ENT.RangeDistance = 600
ENT.RangeToMeleeDistance = 300
ENT.TimeUntilRangeAttackProjectileRelease = false
ENT.NextRangeAttackTime = VJ.SET(12,16)

ENT.HasDeathAnimation = true
ENT.AnimTbl_Death = {"nz_base_zmb_raz_death_collapse_fallback_1", "nz_base_zmb_raz_death_collapse_fallback_2", "nz_base_zmb_raz_death_collapse_fallforward_1"}

ENT.JumpParams = {
	Enabled = true,
	MaxRise = 200,
	MaxDrop = 600,
	MaxDistance = 400,
}

ENT.HasLeapAttack = false
ENT.CanFlinch = true
ENT.HasFootstepSounds = false
ENT.FlinchChance = 10
ENT.FlinchCooldown = 4
ENT.AnimTbl_Flinch = {"nz_base_zmb_raz_attack_shoot_01_pain", "nz_base_zmb_raz_pain_chest_armor", "nz_base_zmb_raz_pain_facemask"}

ENT.InRageState = false
ENT.InArmorBody = true
ENT.InArmorHead = true
ENT.InArmorArm = true

local getEventName = util.GetAnimEventNameByID
function ENT:OnAnimEvent(ev, evTime, evCycle, evType, evOptions)
	if evOptions == "melee" or evOptions == "melee_heavy" then
		self:ExecuteMeleeAttack()
	elseif evOptions == "step_left_large" or evOptions == "step_right_large" then
		VJ.EmitSound(self, VJ.PICK(self.SoundTbl_FootStep), 70, math.random(90,110))
		util.ScreenShake(self:GetPos(), 4, 4, 0.4, 400)
	elseif evOptions == "raz_melee_whoosh" then
		VJ.EmitSound(self, VJ.PICK(self.SoundTbl_Swing), 65, math.random(90,110))
	elseif evOptions == "raz_charge" then
		for i = 1, 5 do
			ParticleEffectAttach("vj_rifle_smoke_dark", PATTACH_POINT_FOLLOW, self, 13)
		end
		VJ.EmitSound(self, "bo6/npc/mangler/charge.mp3", 80, math.random(90,110))
	elseif evOptions == "raz_shoot" then
		self:ExecuteRangeAttack()
		VJ.EmitSound(self, "physics/body/body_medium_impact_hard6.wav", 80, math.random(90,110))
		ParticleEffectAttach("vj_rifle_full", PATTACH_POINT_FOLLOW, self, 13)
	end
end

function ENT:OnDamaged(dmginfo, hitgroup, status) 
	local dm = dmginfo:GetDamage()
	if dmginfo:IsExplosionDamage() then
		self:BreakArmor(table.Random({1,2,5}))
	end
	if hitgroup == HITGROUP_HEAD and self.InArmorHead then
		if dm > 100 or self:Health() < self:GetMaxHealth()*0.7 and math.random(1,5) == 1 then
			self:BreakArmor(1)
		end
		dmginfo:SetDamage(dm * 0.5)
	elseif hitgroup == HITGROUP_CHEST and self.InArmorBody then
		if dm > 100 or self:Health() < self:GetMaxHealth()*0.6 and math.random(1,5) == 1 then
			self:BreakArmor(2)
		end
		dmginfo:SetDamage(dm * 0.5)
	elseif hitgroup == HITGROUP_RIGHTARM and self.InArmorArm then
		if dm > 100 or self:Health() < self:GetMaxHealth()*0.8 and math.random(1,5) == 1 then
			self:BreakArmor(5)
		end
		dmginfo:SetDamage(dm * 0.5)
	end
	if (hitgroup == HITGROUP_HEAD and !self.InArmorHead) or (hitgroup == HITGROUP_CHEST and !self.InArmorBody) then
		dmginfo:SetDamage(dm * 2)
	else
		dmginfo:SetDamage(dm * 0.25)
	end
end

function ENT:BreakArmor(part)
	if part == 1 and self.InArmorHead then
		self.InArmorHead = false
		self:PlayAnim("nz_base_zmb_raz_pain_facemask", true, 2)
		self:SetBodygroup(2, 1)
	elseif part == 2 and self.InArmorBody then
		self.InArmorBody = false
		self:PlayAnim("nz_base_zmb_raz_pain_chest_armor", true, 2)
		self:SetBodygroup(3, 1)
	elseif part == 5 and self.InArmorArm then
		self.InArmorArm = false
		self.HasRangeAttack = false
		self:PlayAnim("nz_base_zmb_raz_attack_shoot_01_pain", true, 2)
		self:SetBodygroup(1, 1)
	end

	timer.Simple(2, function() 
		if !IsValid(self) then return end
		self:SetRageState(true)
	end)
end

function ENT:SetRageState(state)
	if state then
		if self.InRageState != state and self:Health() > 0 then
			VJ.EmitSound(self, VJ.PICK(self.SoundTbl_Enrage), 90, math.random(90,110))
			self:PlayAnim("nz_base_zmb_raz_enrage", true)
		end
	end
	self.InRageState = state
end

function ENT:CustomOnThink()
	if self.InRageState then
		self.AnimationTranslations[ACT_RUN] = ACT_RUN
	else
		self.AnimationTranslations[ACT_RUN] = ACT_WALK
	end
	self.AnimationTranslations[ACT_CLIMB_UP] = ACT_IDLE
	self.AnimationTranslations[ACT_CLIMB_DOWN] = ACT_IDLE
end

function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(-16, -16, 0), Vector(16, 16, 72))
	self:CapabilitiesAdd(CAP_MOVE_CLIMB)
end