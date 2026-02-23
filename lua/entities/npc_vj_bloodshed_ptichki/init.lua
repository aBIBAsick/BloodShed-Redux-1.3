AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = {"models/Zombie/Fast.mdl"}
ENT.StartHealth = 999999999

ENT.JumpParams = {
	Enabled = true, -- Can it do movement jumps?
	MaxRise = 1600, -- How high it can jump up ((S -> A) AND (S -> E))
	MaxDrop = 1600, -- How low it can jump down (E -> S)
	MaxDistance = 1600, -- Maximum distance between Start and End
}

ENT.MeleeAttackDistance = 64
ENT.HasMeleeAttackKnockBack = true
ENT.MeleeAttackDamage = math.huge
ENT.MeleeAttackDamageType = DMG_BLAST
ENT.MeleeAttackPlayerSpeed = true
ENT.AnimTbl_MeleeAttack = {""}
ENT.HasLeapAttack = true
ENT.AnimTbl_LeapAttack = ACT_JUMP
ENT.HasDeathCorpse = false
ENT.EnemyXRayDetection = true
ENT.VJ_NPC_Class = {"CLASS_BLOODSHED_ZOMBIE", "CLASS_ZOMBIE"}

function ENT:CustomOnInitialize()
    local skinCount = self:SkinCount()
	local randomSkin = math.random(0, skinCount - 1)
	self:SetSkin(randomSkin)
	self:CapabilitiesAdd(CAP_MOVE_CLIMB)
	self:SetNoDraw(true)
	self:DrawShadow(false)
	self.PtichkiSound = 0
	self:SetCollisionBounds(Vector(-4, -4, 0), Vector(4, 4, 16))

	local mod = ents.Create("base_anim")
	mod:SetModel("models/murdered/secret/pukeko.mdl")
	mod:SetPos(self:GetPos())
	mod:SetAngles(self:GetAngles())
	mod:SetParent(self)
	mod:Spawn()
	self:DeleteOnRemove(mod)

	for i = 0, self:GetNumBodyGroups() - 1 do
		local bodyGroupCount = self:GetBodygroupCount(i)
		local randomBodyGroup = math.random(0, bodyGroupCount - 1)
		self:SetBodygroup(i, randomBodyGroup)
	end
end

function ENT:OnLeapAttack(status, enemy)
	return math.abs(enemy:GetPos().z-self:GetPos().z) < 72
end

function ENT:CustomOnThink()
	self.AnimationTranslations[ACT_CLIMB_UP] = ACT_JUMP
	self.AnimationTranslations[ACT_CLIMB_DOWN] = ACT_JUMP

	if self.PtichkiSound < CurTime() then
		self:EmitSound("<murdered/ptichki.mp3", 90, 100)
		self.PtichkiSound = CurTime() + 12.2
	end

	util.ScreenShake(self:GetPos(), 4, 16, 1, 1024)

	for _, ent in ipairs(ents.FindInSphere(self:GetPos(), 72)) do
		if ent != self then
			local dmg = DamageInfo()
			dmg:SetDamageType(DMG_BLAST)
			dmg:SetDamage(math.huge)
			dmg:SetAttacker(self)
			dmg:SetInflictor(self)
			dmg:SetDamagePosition(ent:WorldSpaceCenter())
			dmg:SetDamageForce((ent:GetPos() - self:GetPos()):GetNormalized() * 100000)
			ent:TakeDamageInfo(dmg)
			if string.match(ent:GetClass(), "door") then
				ent:Fire("Unlock")
				ent:Fire("Open")
			end
		end
	end
end