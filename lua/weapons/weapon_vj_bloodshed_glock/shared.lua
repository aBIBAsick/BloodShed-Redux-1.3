SWEP.Base = "weapon_vj_base"
SWEP.PrintName = "Glock"
SWEP.Author = "Hari"
SWEP.Category = "VJ Base Bloodshed"

	-- Main Settings ---------------------------------------------------------------------------------------------------------------------------------------------

SWEP.WorldModel_UseCustomPosition = true
SWEP.WorldModel_CustomPositionAngle = Vector(-10, 0, 180)
SWEP.WorldModel_CustomPositionOrigin = Vector(-4, -8, 4)

SWEP.ViewModel = "" -- The view model (First person)
SWEP.WorldModel = "models/sidearms/v_glock.mdl" -- The world model (Third person, when a NPC/Player is holding it, on ground, etc.)
SWEP.HoldType = "revolver" -- List of hold types are in the GMod wiki
SWEP.MadeForNPCsOnly = true -- Is this weapon meant to be for NPCs only?

SWEP.NPC_NextPrimaryFire = 0.3
SWEP.NPC_CustomSpread = 0.8

SWEP.Primary.AllowInWater = true
SWEP.Primary.Damage = 26

SWEP.Primary.ClipSize = 17
SWEP.Primary.Recoil = 0.3
SWEP.Primary.Cone = 5
SWEP.Primary.Delay = 0.3
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Sound = ")weapons/glock/glock17_close.wav"
SWEP.PrimaryEffects_MuzzleAttachment = 1
SWEP.PrimaryEffects_ShellType = "ShellEject"

SWEP.HasReloadSound = true
SWEP.ReloadSound = "vj_base/weapons/glock17/reload.wav"
SWEP.Reload_TimeUntilAmmoIsSet = 1.5

function SWEP:Init() 
	self:SetHoldType(math.random(1,3) != 1 and "revolver" or "pistol")
end