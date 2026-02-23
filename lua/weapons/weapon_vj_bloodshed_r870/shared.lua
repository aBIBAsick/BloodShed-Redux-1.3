SWEP.Base = "weapon_vj_base"
SWEP.PrintName = "R870"
SWEP.Author = "Hari"
SWEP.Category = "VJ Base Bloodshed"

-- Main Settings ---------------------------------------------------------------------------------------------------------------------------------------------

SWEP.WorldModel_UseCustomPosition = true
SWEP.WorldModel_CustomPositionAngle = Vector(-10, 0, 180)
SWEP.WorldModel_CustomPositionOrigin = Vector(0, 4.6, 2)

SWEP.ViewModel = ""
SWEP.WorldModel = "models/shotguns/w_m590.mdl"
SWEP.HoldType = "shotgun"
SWEP.MadeForNPCsOnly = true -- Is this weapon meant to be for NPCs only?

SWEP.NPC_NextPrimaryFire = 0.9
SWEP.NPC_TimeUntilFire = 0.2
SWEP.NPC_CustomSpread = 2.5
SWEP.NPC_ExtraFireSound = "murdered/weapons/toz_shotgun/pump.wav"
SWEP.NPC_FiringDistanceScale = 0.5

SWEP.Primary.Damage = 18
SWEP.Primary.Force = 1
SWEP.Primary.NumberOfShots = 6
SWEP.Primary.ClipSize = 8
SWEP.Primary.Cone = 12
SWEP.Primary.Delay = 0.8
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.Sound = ")tfa_ins2_wpns/tfa_ins2_mossberg590/fire.wav"
SWEP.PrimaryEffects_MuzzleAttachment = 1
SWEP.PrimaryEffects_ShellAttachment = 2
SWEP.PrimaryEffects_ShellType = "ShotgunShellEject"

SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "Buckshot"

SWEP.HasReloadSound = true
SWEP.ReloadSound = {"weapons/shotgun/shotgun_reload1.wav", "weapons/shotgun/shotgun_reload2.wav", "weapons/shotgun/shotgun_reload3.wav"}
SWEP.Reload_TimeUntilAmmoIsSet = 0.3