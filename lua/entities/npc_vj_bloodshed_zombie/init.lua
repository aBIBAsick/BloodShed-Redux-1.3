AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = {
	"models/murdered/npc/zombie/zombie_male_01.mdl", 
	"models/murdered/npc/zombie/zombie_male_02.mdl",
	"models/murdered/npc/zombie/zombie_male_03.mdl", 
	"models/murdered/npc/zombie/zombie_male_04.mdl",  
	"models/murdered/npc/zombie/zombie_male_05.mdl", 
	"models/murdered/npc/zombie/zombie_male_06.mdl", 
	"models/murdered/npc/zombie/zombie_male_07.mdl", 
	"models/murdered/npc/zombie/zombie_male_08.mdl", 
	"models/murdered/npc/zombie/zombie_male_09.mdl", 
}
ENT.StartHealth = 75

ENT.JumpParams = {
	Enabled = true, -- Can it do movement jumps?
	MaxRise = 600, -- How high it can jump up ((S -> A) AND (S -> E))
	MaxDrop = 600, -- How low it can jump down (E -> S)
	MaxDistance = 600, -- Maximum distance between Start and End
}

ENT.MeleeAttackDamage = 20
ENT.MeleeAttackDamageType = DMG_SLASH
ENT.MeleeAttackPlayerSpeed = true
ENT.AnimTbl_MeleeAttack = {"attackh_quick", "attackg_quick"}
ENT.HasLeapAttack = true
ENT.AnimTbl_LeapAttack = ACT_JUMP

ENT.SoundTbl_MeleeAttack = "Zombie.AttackHit"
ENT.SoundTbl_MeleeAttackExtra = "Zombie.AttackHit"
ENT.SoundTbl_MeleeAttackMiss = "Zombie.AttackHit"

ENT.VJ_NPC_Class = {"CLASS_BLOODSHED_ZOMBIE"}

function ENT:CustomOnInitialize()
    local skinCount = self:SkinCount()
	local randomSkin = math.random(0, skinCount - 1)
	self:SetSkin(randomSkin)

	for i = 0, self:GetNumBodyGroups() - 1 do
		local bodyGroupCount = self:GetBodygroupCount(i)
		local randomBodyGroup = math.random(0, bodyGroupCount - 1)
		self:SetBodygroup(i, randomBodyGroup)
	end
end

function ENT:OnLeapAttack(status, enemy)
	return math.abs(enemy:GetPos().z-self:GetPos().z) < 72
end