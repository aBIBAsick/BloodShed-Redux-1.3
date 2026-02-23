SWEP.Base = "weapon_vj_base"
SWEP.PrintName = "M4A1"
SWEP.Author = "Hari"
SWEP.Category = "VJ Base Bloodshed"

-- Main Settings ---------------------------------------------------------------------------------------------------------------------------------------------

SWEP.WorldModel_UseCustomPosition = true
SWEP.WorldModel_CustomPositionAngle = Vector(-10, 0, 180)
SWEP.WorldModel_CustomPositionOrigin = Vector(-4, -6, 7)

SWEP.ViewModel = ""
SWEP.WorldModel = "models/rifles/w_m4a1.mdl"
SWEP.MadeForNPCsOnly = true -- Is this weapon meant to be for NPCs only?
SWEP.HoldType = "ar2"

SWEP.NPC_ReloadSound = "vj_base/weapons/smg1/reload.wav"
SWEP.Primary.Damage = 16
SWEP.Primary.ClipSize = 30
SWEP.Primary.Delay = 0.09
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Sound = ")inss_wpns/tfa_inss_m4a1/fire2.wav"
SWEP.PrimaryEffects_MuzzleAttachment = 1
SWEP.PrimaryEffects_ShellAttachment = 2
SWEP.PrimaryEffects_ShellType = "ShellEject"

SWEP.HasReloadSound = true
SWEP.ReloadSound = "weapons/smg1/smg1_reload.wav"