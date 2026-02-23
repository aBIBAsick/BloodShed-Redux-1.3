AddCSLuaFile()

SWEP.Base = "weapon_vj_base"
SWEP.PrintName = "Suspect Melee"
SWEP.Author = "Hari"
SWEP.Category = "VJ Base Bloodshed"

SWEP.MadeForNPCsOnly = true
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
SWEP.HoldType = "knife"

SWEP.NPC_NextPrimaryFire = 0.8
SWEP.NPC_TimeUntilFire = 0.4

SWEP.Primary.Damage = 50
SWEP.MeleeWeaponSound_Miss = {")murdered/weapons/melee/knife_bayonet_swing1.wav", ")murdered/weapons/melee/knife_bayonet_swing2.wav"}
SWEP.MeleeWeaponSound_Hit = {")murdered/weapons/melee/knife_bayonet_hit1.wav", ")murdered/weapons/melee/knife_bayonet_hit2.wav"}
SWEP.IsMeleeWeapon = true

function SWEP:OnEquip(npc)
    npc.AnimTbl_WeaponAttack = {"seq_baton_swing"}
    npc.AnimTbl_WeaponAttackGesture = false
end