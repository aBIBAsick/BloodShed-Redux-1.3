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

ENT.SoundTbl_FootStep = GetSounds("bo6/npc/vermin/step")
ENT.SoundTbl_CombatIdle = GetSounds("bo6/npc/vermin/amb")
ENT.SoundTbl_Death = GetSounds("bo6/npc/vermin/death")
ENT.SoundTbl_LeapAttackJump = GetSounds("bo6/npc/vermin/behind")
ENT.SoundTbl_MeleeAttack  = GetSounds("bo6/npc/mangler/damage")
ENT.SoundTbl_BeforeMeleeAttack = GetSounds("bo6/npc/vermin/attack")

ENT.Model = {"models/murdered/nz/bo6_vermin.mdl"}
ENT.StartHealth = 50

ENT.VJ_NPC_Class = {"CLASS_BLOODSHED_ZOMBIE", "CLASS_ZOMBIE"}
ENT.BloodColor = "Red"
ENT.CustomBlood_Particle = {"blood_impact_red_01"}

ENT.HasMeleeAttack = true
ENT.MeleeAttackDamage = 10
ENT.MeleeAttackDamageType = DMG_SLASH
ENT.AnimTbl_MeleeAttack = {
	"nz_base_vermin_attack_01", 
	"nz_base_vermin_attack_02",
}
ENT.MeleeAttackDistance = 56
ENT.MeleeAttackDamageDistance = 64
ENT.TimeUntilMeleeAttackDamage = false

ENT.HasDeathAnimation = true
ENT.AnimTbl_Death = {"nz_base_vermin_dth_01", "nz_base_vermin_dth_02", "nz_base_vermin_dth_03"}

ENT.JumpParams = {
	Enabled = true,
	MaxRise = 200,
	MaxDrop = 600,
	MaxDistance = 400,
}

ENT.CanFlinch = true
ENT.HasFootstepSounds = false
ENT.FlinchChance = 2
ENT.FlinchCooldown = 8
ENT.AnimTbl_Flinch = {"nz_base_vermin_knockback"}

ENT.HasLeapAttack = true
ENT.AnimTbl_LeapAttack = {"nz_base_vermin_lunge_start"}
ENT.TimeUntilLeapAttackVelocity = 0.3
ENT.NextLeapAttackTime = VJ.SET(6,8)
ENT.TimeUntilLeapAttackDamage = 0.8
ENT.LeapAttackDamage = 15

local getEventName = util.GetAnimEventNameByID
function ENT:OnAnimEvent(ev, evTime, evCycle, evType, evOptions)
	if evOptions == "melee" or evOptions == "melee_heavy" then
		self:ExecuteMeleeAttack()
	elseif evOptions == "vermin_step" then
		VJ.EmitSound(self, VJ.PICK(self.SoundTbl_FootStep), 70, math.random(90,110))
	end
end

function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(12,12,48), Vector(-12,-12,0))
	self:CapabilitiesAdd(CAP_MOVE_CLIMB)
end

function ENT:CustomOnThink()
	self.AnimationTranslations[ACT_CLIMB_UP] = ACT_IDLE
	self.AnimationTranslations[ACT_CLIMB_DOWN] = ACT_IDLE
end