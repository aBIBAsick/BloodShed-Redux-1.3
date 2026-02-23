SWEP.Base = "weapon_vj_base"
SWEP.PrintName = "Suspect Primary"
SWEP.Author = "Hari"
SWEP.Category = "VJ Base Bloodshed"
SWEP.HoldType = "revolver"
SWEP.MadeForNPCsOnly = true

SWEP.NPC_NextPrimaryFire = 0.3
SWEP.NPC_TimeUntilFire = 0.2
SWEP.ViewModel     = ""
SWEP.WorldModel    = "models/weapons/w_rif_ak47.mdl"
SWEP.Primary.Delay = 0.3
SWEP.Primary.ClipSize = 17
SWEP.Primary.Sound = ")weapons/tfa_ins2/acr/fire.wav"

SWEP.Primary.AllowInWater = true
SWEP.Primary.Damage       = 12
SWEP.Primary.Recoil       = 0.3
SWEP.Primary.Cone         = 5
SWEP.Primary.Automatic    = false
SWEP.Primary.Ammo         = "Pistol"

SWEP.HasReloadSound = true
SWEP.ReloadSound = "vj_base/weapons/glock17/reload.wav"
SWEP.Reload_TimeUntilAmmoIsSet = 1.5

local Configs = {
    {
        wm    = "models/weapons/w_rif_ak47.mdl",
        delay = 0.11,
        clip  = 30,
        snd   = ")weapons/tfa_ins2/acr/fire.wav",
		dmg = 21,
        holdtype = "ar2",
        spread = 3,
    },
    {
        wm    = "models/weapons/w_snip_scout.mdl",
        delay = 0.6,
        clip  = 30,
        snd   = ")weapons/m24sws/m24_shoot_default.wav",
		dmg = 65,
        holdtype = "rpg",
        spread = 1,
    },
    {
        wm    = "models/weapons/w_shot_m3super90.mdl",
        delay = 0.6,
        clip  = 30,
        snd   = ")weapons/tfa_ins2/m1014/m1014_fire.wav",
		dmg = 14,
        holdtype = "rpg",
        spread = 6,
        num = 6,
    },
    {
        wm    = "models/weapons/w_smg_mac10.mdl",
        delay = 0.09,
        clip  = 30,
        snd   = ")weapons/tfa_ins2/mp7/fp.wav",
		dmg = 14,
        holdtype = "pistol",
        spread = 4,
    },
    
}

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", "DrawWorldModel")
    self:NetworkVar("String", "ReplaceModel")
	if SERVER then
		self:SetDrawWorldModel(true)
        self:SetReplaceModel("error")
	end
end

function SWEP:CreateCheckTimer()
    local id = self:EntIndex()
    timer.Create("CheckNewWeaponModel"..id, 1, 0, function()
        if !IsValid(self) then 
            timer.Remove("CheckNewWeaponModel"..id)
            return 
        end
        local om = self:GetModel()
        local nm = self:GetReplaceModel()
        if om != nm then
            self.WorldModel = nm
            self:SetModel(nm) 
        end
    end)
end

function SWEP:Init()
    if CLIENT then 
        self:CreateCheckTimer()
        return 
    end

    local cfg = Configs[math.random(#Configs)]
    self.WorldModel = cfg.wm
    self:SetModel(cfg.wm)
    self:SetReplaceModel(cfg.wm)
    self:SetHoldType(cfg.holdtype)
    self.Primary.Delay = cfg.delay
    self.NPC_NextPrimaryFire = cfg.delay
    if cfg.delay < 0.3 then
        self.Primary.Automatic = true
    end
    self.Primary.ClipSize = cfg.clip
    self.Primary.Sound = cfg.snd
	self.Primary.Damage = cfg.dmg
    if cfg.pumpsound then
        self.NPC_ExtraFireSound = cfg.pumpsound
        self.NPC_ExtraFireSoundTime = 0.5
    end
    if cfg.num then
        self.Primary.NumberOfShots = cfg.num
    end
    if cfg.spread then
        self.NPC_CustomSpread = cfg.spread
    end

    self:SetClip1(self.Primary.ClipSize)
end
