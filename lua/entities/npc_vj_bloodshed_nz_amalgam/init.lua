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

ENT.SoundTbl_FootStep = GetSounds("bo6/npc/amalgam/step")
ENT.SoundTbl_CombatIdle = GetSounds("bo6/npc/amalgam/amb")
ENT.SoundTbl_Pain = GetSounds("bo6/npc/amalgam/pain")
ENT.SoundTbl_Death = GetSounds("bo6/npc/amalgam/death")
ENT.SoundTbl_Swing = GetSounds("bo6/npc/mangler/swing")
ENT.SoundTbl_MeleeAttack  = GetSounds("bo6/npc/mangler/damage")
ENT.SoundTbl_BeforeMeleeAttack = GetSounds("bo6/npc/amalgam/attack")
ENT.SoundTbl_Grab = GetSounds("bo6/npc/amalgam/grab")

ENT.Model = {"models/murdered/nz/bo6_amalgam.mdl"}
ENT.StartHealth = 1250
ENT.HullType = HULL_LARGE

ENT.VJ_NPC_Class = {"CLASS_BLOODSHED_ZOMBIE", "CLASS_ZOMBIE"}
ENT.BloodColor = "Red"
ENT.CustomBlood_Particle = {"blood_impact_red_01"}

ENT.HasMeleeAttack = true
ENT.MeleeAttackDamage = 40
ENT.MeleeAttackDamageType = DMG_SLASH
ENT.AnimTbl_MeleeAttack = {
	"nz_base_amalgam_run_attack_01",
	"nz_base_amalgam_run_attack_02",
	"nz_base_amalgam_run_attack_03",
	"nz_base_amalgam_stand_attack_01",
	"nz_base_amalgam_stand_attack_02" 
}
ENT.MeleeAttackDistance = 72
ENT.MeleeAttackDamageDistance = 80
ENT.TimeUntilMeleeAttackDamage = false

ENT.HasDeathAnimation = true
ENT.HasDeathCorpse = false
ENT.AnimTbl_Death = {"nz_base_amalgam_death"}

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
ENT.AnimTbl_Flinch = {"nz_base_amalgam_fatal_01", "nz_base_amalgam_fatal_02", "nz_base_amalgam_run_pain_01", "nz_base_amalgam_run_pain_02", "nz_base_amalgam_run_pain_03"}

ENT.GrabDistance = {120, 300}
ENT.AnimTbl_GrabLong = {"nz_base_amalgam_grab_long_in", "nz_base_amalgam_grab_long_out", "nz_base_amalgam_grab_release"}
ENT.GrabCooldown = 8
ENT.GrabDamage = 50

function ENT:CustomOnInitialize()
	self.NextGrabTime = 0
	self.GrabbedPlayer = nil
	self.GrabPhase = nil
	self:SetCollisionBounds(Vector(-16, -16, 0), Vector(16, 16, 72))
	self:CapabilitiesAdd(CAP_MOVE_CLIMB)
end

function ENT:CanGrab(ply)
	if not IsValid(ply) or not ply:Alive() then return false end
	if CurTime() < self.NextGrabTime then return false end
	if self.GrabbedPlayer then return false end
	
	local dist = self:GetPos():Distance(ply:GetPos())
	if dist > self.GrabDistance[2] then return false end
	if dist < self.GrabDistance[1] then return false end
	
	local tr = util.TraceLine({
		start = self:EyePos(),
		endpos = ply:EyePos(),
		filter = {self, ply}
	})
	if tr.Hit then return false end
	
	return true
end

function ENT:StartGrab(ply)
	if not self:CanGrab(ply) then return end
	
	self.GrabbedLastPos = ply:GetPos()
	self.GrabbedPlayer = ply
	self.GrabPhase = "in"
	
	local animTbl = self.AnimTbl_GrabLong
	
	VJ.EmitSound(self, VJ.PICK(self.SoundTbl_Grab), 75, math.random(95,105))
	
	local inAnim = animTbl[1]
	local seq = self:LookupSequence(inAnim)
	local dur = self:SequenceDuration(seq)
	
	self:SetState(VJ_STATE_ONLY_ANIMATION_NOATTACK)
	self:PlayAnim(inAnim, true, dur)
	
	timer.Simple(dur, function()
		if not IsValid(self) or not IsValid(self.GrabbedPlayer) then
			self:ReleaseGrab(false)
			return
		end
		self:GrabPhaseOut(animTbl)
	end)
end

function ENT:GrabPhaseOut(animTbl)
	self.GrabPhase = "out"
	local ply = self.GrabbedPlayer
	
	if not IsValid(ply) or not ply:Alive() then
		self:ReleaseGrab(false)
		return
	end
	
	ply:SetNWBool("AmalgamGrabbed", true)
	ply:SetNWEntity("AmalgamGrabbedBy", self)
	
	local outAnim = animTbl[2]
	local seq = self:LookupSequence(outAnim)
	local dur = self:SequenceDuration(seq)
	
	self:PlayAnim(outAnim, true, dur)
	
	timer.Simple(dur, function()
		if not IsValid(self) then
			if IsValid(ply) then
				ply:SetNWBool("AmalgamGrabbed", false)
			end
			return
		end
		self:GrabPhaseRelease(animTbl)
	end)
end

function ENT:GrabPhaseRelease(animTbl)
	self.GrabPhase = "release"
	local ply = self.GrabbedPlayer
	
	local releaseAnim = animTbl[3]
	local seq = self:LookupSequence(releaseAnim)
	local dur = self:SequenceDuration(seq)
	
	self:PlayAnim(releaseAnim, true, dur)
	
	timer.Simple(dur * 0.1, function()
		if IsValid(self) and IsValid(ply) and ply:Alive() then
			local dm = self.GrabDamage
			if ply:Health() <= ply:GetMaxHealth() * 0.75 then
				dm = 500
				ply.DeathBlowSpine = true
			end
			local dmg = DamageInfo()
			dmg:SetDamage(dm)
			dmg:SetAttacker(self)
			dmg:SetInflictor(self)
			dmg:SetDamageType(DMG_SLASH)
			ply:TakeDamageInfo(dmg)
		end
		if IsValid(self) then
			self:ReleaseGrab(true)
		elseif IsValid(ply) then
			ply:SetNWBool("AmalgamGrabbed", false)
		end
	end)
end

function ENT:ReleaseGrab(applyKnockback)
	local ply = self.GrabbedPlayer
	
	if IsValid(ply) then
		ply:SetNWBool("AmalgamGrabbed", false)
		ply:SetNWEntity("AmalgamGrabbedBy", NULL)
		
		if applyKnockback then
			local dir = (ply:GetPos() - self:GetPos()):GetNormalized()
			dir.z = 0.3
			local pos = self:WorldSpaceCenter() + self:GetForward() * 32
			ply:SetPos(pos)
			ply:SetVelocity(dir * 400)
		end
	end
	
	self.GrabbedPlayer = nil
	self.GrabPhase = nil
	self.NextGrabTime = CurTime() + self.GrabCooldown
	self:SetState(VJ_STATE_NONE)
end

function ENT:UpdateGrabbedPlayer()
	local ply = self.GrabbedPlayer
	if not IsValid(ply) then return end
	if self.GrabPhase ~= "out" and self.GrabPhase ~= "in" and self.GrabPhase ~= "release" then return end
	
	local attach9 = self:GetAttachment(9)
	local attach10 = self:WorldSpaceCenter()
	local pos = attach9.Pos - Vector(0, 0, 48) + self:GetForward() * 4

	if self.GrabPhase == "in" then
		ply:SetPos(self.GrabbedLastPos)
		ply:SetVelocity(-ply:GetVelocity())
	else
		ply:SetPos(pos)
		ply:SetVelocity(-ply:GetVelocity())
	end
	
	if attach10 then
		local ang = (attach10 - ply:EyePos()):Angle()
		ply:SetEyeAngles(ang)
	end
end

local getEventName = util.GetAnimEventNameByID
function ENT:OnAnimEvent(ev, evTime, evCycle, evType, evOptions)
	if evOptions == "melee" or evOptions == "melee_heavy" then
		self:ExecuteMeleeAttack()
	elseif evOptions == "step_left_large" or evOptions == "step_right_large" then
		VJ.EmitSound(self, VJ.PICK(self.SoundTbl_FootStep), 70, math.random(90,110))
		util.ScreenShake(self:GetPos(), 4, 4, 0.4, 400)
	elseif evOptions == "raz_melee_whoosh" then
		VJ.EmitSound(self, VJ.PICK(self.SoundTbl_Swing), 65, math.random(90,110))
	end
end

function ENT:CustomOnThink()
	self:UpdateGrabbedPlayer()
	
	if self.GrabbedPlayer then return end
	
	local enemy = self:GetEnemy()
	if IsValid(enemy) and enemy:IsPlayer() and self:CanGrab(enemy) then
		if math.random(1, 100) <= 15 then
			self:StartGrab(enemy)
		end
	end

	self.AnimationTranslations[ACT_CLIMB_UP] = ACT_IDLE
	self.AnimationTranslations[ACT_CLIMB_DOWN] = ACT_IDLE
end

function ENT:CustomOnRemove()
	if IsValid(self.GrabbedPlayer) then
		self:ReleaseGrab(false)
	end
end