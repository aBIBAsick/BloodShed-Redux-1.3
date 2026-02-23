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

ENT.SoundTbl_FootStep = GetSounds("bo6/npc/mimic/step")
ENT.SoundTbl_CombatIdle = GetSounds("bo6/npc/mimic/amb")
ENT.SoundTbl_Pain = GetSounds("bo6/npc/mimic/pain")
ENT.SoundTbl_Death = GetSounds("bo6/npc/mimic/death")
ENT.SoundTbl_Swing = GetSounds("bo6/npc/mangler/swing")
ENT.SoundTbl_MeleeAttack  = GetSounds("bo6/npc/mangler/damage")
ENT.SoundTbl_BeforeMeleeAttack = GetSounds("bo6/npc/mimic/attack")
ENT.SoundTbl_Grab = GetSounds("bo6/npc/mimic/grab")

ENT.Model = {"models/murdered/nz/bo6_mimic.mdl"}
ENT.StartHealth = 500
ENT.HullType = HULL_LARGE

ENT.VJ_NPC_Class = {"CLASS_BLOODSHED_ZOMBIE", "CLASS_ZOMBIE"}
ENT.BloodColor = "Red"
ENT.CustomBlood_Particle = {"blood_impact_red_01"}

ENT.HasMeleeAttack = true
ENT.MeleeAttackDamage = 20
ENT.MeleeAttackDamageType = DMG_SHOCK
ENT.AnimTbl_MeleeAttack = {
	"nz_ai_mimic_run_attack_01",
	"nz_ai_mimic_run_attack_02",
	"nz_ai_mimic_run_attack_03",
	"nz_ai_mimic_run_attack_04",
	"nz_ai_mimic_walk_attack_01",
	"nz_ai_mimic_stand_attack_01",
	"nz_ai_mimic_stand_attack_02",
	"nz_ai_mimic_stand_attack_03",
	"nz_ai_mimic_stand_attack_04",
	"nz_ai_mimic_stand_attack_05", 
}
ENT.MeleeAttackDistance = 72
ENT.MeleeAttackDamageDistance = 80
ENT.TimeUntilMeleeAttackDamage = false

ENT.HasDeathAnimation = true
ENT.HasDeathCorpse = false
ENT.AnimTbl_Death = {"nz_ai_mimic_death_01"}

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
ENT.AnimTbl_Flinch = {"nz_ai_mimic_stun_in", "nz_ai_mimic_flail_out"}

ENT.GrabDistance = {120, 260}
ENT.AnimTbl_GrabLong = {"nz_ai_mimic_command_grab_in_01", "nz_ai_mimic_command_grab_success_01"}
ENT.GrabCooldown = 10
ENT.GrabDamage = 30
ENT.NextSparkTime = 0

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
	
	timer.Simple(dur * 0.6, function()
		if IsValid(self) and IsValid(ply) and ply:Alive() then
			local dm = self.GrabDamage
			if ply:Health() <= ply:GetMaxHealth() * 0.5 then
				dm = 500
				ply.DeathBlowSpine = true
			end
			local dmg = DamageInfo()
			dmg:SetDamage(dm)
			dmg:SetAttacker(self)
			dmg:SetInflictor(self)
			dmg:SetDamageType(DMG_SHOCK)
			ply:TakeDamageInfo(dmg)
			self:ApplyShockEffect(ply)
		end
	end)
	
	timer.Simple(dur, function()
		if not IsValid(self) then
			if IsValid(ply) then
				ply:SetNWBool("AmalgamGrabbed", false)
			end
			return
		end
		self:ReleaseGrab(true)
	end)
end

function ENT:ApplyShockEffect(ply)
	if not IsValid(ply) then return end
	
	local effectData = EffectData()
	effectData:SetOrigin(ply:WorldSpaceCenter())
	effectData:SetEntity(ply)
	effectData:SetMagnitude(2)
	effectData:SetScale(1)
	util.Effect("TeslaHitboxes", effectData)
	
	if SERVER then
		ply:ScreenFade(SCREENFADE.IN, Color(100, 125, 255, 80), 0.3, 0.1)
		ply:ViewPunch(Angle(math.Rand(-5, 5), math.Rand(-5, 5), math.Rand(-3, 3)))
		
		local shockDur = math.Rand(1, 2)
		local shockTicks = math.random(4, 8)
		for i = 1, shockTicks do
			timer.Simple(i * (shockDur / shockTicks), function()
				if IsValid(ply) and ply:Alive() then
					ply:ViewPunch(Angle(math.Rand(-3, 3), math.Rand(-3, 3), math.Rand(-2, 2)))
				end
			end)
		end
	end
end

function ENT:SpawnRandomSparks()
	if CurTime() < self.NextSparkTime then return end
	self.NextSparkTime = CurTime() + math.Rand(0.1, 0.4)

	local arcData = EffectData()
	arcData:SetEntity(self)
	arcData:SetMagnitude(4)
	util.Effect("TeslaHitboxes", arcData)
	
	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) and ply:Alive() and self:GetPos():Distance(ply:GetPos()) <= 200 then
			local dmg = DamageInfo()
			dmg:SetDamage(2)
			dmg:SetAttacker(self)
			dmg:SetInflictor(self)
			dmg:SetDamageType(DMG_SHOCK)
			ply:TakeDamageInfo(dmg)
			
			self:ApplyShockEffect(ply)
		end
	end
end

function ENT:ReleaseGrab(applyKnockback)
	local ply = self.GrabbedPlayer
	
	if IsValid(ply) then
		ply:SetNWBool("AmalgamGrabbed", false)
		ply:SetNWEntity("AmalgamGrabbedBy", NULL)
		
		if applyKnockback then
			local dir = (ply:GetPos() - self:GetPos()):GetNormalized()
			dir.z = 0.3
			local pos = self:WorldSpaceCenter() + self:GetForward() * 64
			ply:SetPos(pos)
			ply:SetVelocity(dir * 400)
		end
	end
	
	self.GrabbedPlayer = nil
	self.GrabPhase = nil
	self.NextGrabTime = CurTime() + self.GrabCooldown
	self:SetState(VJ_STATE_NONE)
end

function ENT:CustomOnDamageByTarget(dmginfo, hitEnt, isPropDamage)
	if IsValid(hitEnt) and hitEnt:IsPlayer() then
		self:ApplyShockEffect(hitEnt)
	end
end

function ENT:UpdateGrabbedPlayer()
	local ply = self.GrabbedPlayer
	if not IsValid(ply) then return end
	if self.GrabPhase ~= "out" and self.GrabPhase ~= "in" then return end
	
	local attach8 = self:GetAttachment(8)
	local attach10 = self:EyePos()
	local pos = attach8.Pos - Vector(0, 0, 48) + self:GetForward() * 4

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
	elseif evOptions == "melee_whoosh" then
		VJ.EmitSound(self, VJ.PICK(self.SoundTbl_Swing), 65, math.random(90,110))
	end
end

function ENT:CustomOnThink()
	self:UpdateGrabbedPlayer()
	self:SpawnRandomSparks()

	self.AnimationTranslations[ACT_CLIMB_UP] = ACT_IDLE
	self.AnimationTranslations[ACT_CLIMB_DOWN] = ACT_IDLE
	
	if self.GrabbedPlayer then return end
	
	local enemy = self:GetEnemy()
	if IsValid(enemy) and enemy:IsPlayer() and self:CanGrab(enemy) then
		if math.random(1, 100) <= 15 then
			self:StartGrab(enemy)
		end
	end
end

function ENT:CustomOnRemove()
	if IsValid(self.GrabbedPlayer) then
		self:ReleaseGrab(false)
	end
end

function ENT:OnDeath(dmginfo, hitgroup, status) 
	if IsValid(self.GrabbedPlayer) then
		self:ReleaseGrab(false)
	end

	if status == "DeathAnim" then
		timer.Simple(1.5, function()
			if !IsValid(self) then return end

			if self.HasGibOnDeathEffects then
				local effectData = EffectData()
				effectData:SetOrigin(self:GetPos() + self:OBBCenter())
				effectData:SetColor(VJ.Color2Byte(Color(130, 19, 10)))
				effectData:SetScale(120)
				util.Effect("VJ_Blood1", effectData)
				effectData:SetScale(8)
				effectData:SetFlags(3)
				effectData:SetColor(0)
				util.Effect("bloodspray", effectData)
				util.Effect("bloodspray", effectData)
			end

			for i=1,2 do
				self:CreateGibEntity("obj_vj_gib", "models/vj_base/gibs/human/gib1.mdl", {CollisionDecal="VJ_HLR1_Blood_Red", Pos=self:LocalToWorld(Vector(0, 0, 40))})
				self:CreateGibEntity("obj_vj_gib", "models/vj_base/gibs/human/gib2.mdl", {CollisionDecal="VJ_HLR1_Blood_Red", Pos=self:LocalToWorld(Vector(1, 0, 40))})
				self:CreateGibEntity("obj_vj_gib", "models/vj_base/gibs/human/gib3.mdl", {CollisionDecal="VJ_HLR1_Blood_Red", Pos=self:LocalToWorld(Vector(0, 1, 40))})
				self:CreateGibEntity("obj_vj_gib", "models/vj_base/gibs/human/gib4.mdl", {CollisionDecal="VJ_HLR1_Blood_Red", Pos=self:LocalToWorld(Vector(1, 1, 40))})
				self:CreateGibEntity("obj_vj_gib", "models/vj_base/gibs/human/gib5.mdl", {CollisionDecal="VJ_HLR1_Blood_Red", Pos=self:LocalToWorld(Vector(0, 0, 50))})
				self:CreateGibEntity("obj_vj_gib", "models/vj_base/gibs/human/gib6.mdl", {CollisionDecal="VJ_HLR1_Blood_Red", Pos=self:LocalToWorld(Vector(1, 2, 40))})
				self:CreateGibEntity("obj_vj_gib", "models/vj_base/gibs/human/gib7.mdl", {CollisionDecal="VJ_HLR1_Blood_Red", Pos=self:LocalToWorld(Vector(2, 1, 40))})
			end

			self:PlaySoundSystem("Gib", "vj_base/gib/splat.wav")

			self:Remove()
		end)
	end
end