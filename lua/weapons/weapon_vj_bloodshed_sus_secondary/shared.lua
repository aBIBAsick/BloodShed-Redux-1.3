SWEP.Base = "weapon_vj_base"
SWEP.PrintName = "Suspect Pistol"
SWEP.Author = "Hari"
SWEP.Category = "VJ Base Bloodshed"
SWEP.HoldType = "revolver"
SWEP.MadeForNPCsOnly = true

SWEP.NPC_NextPrimaryFire = 0.3
SWEP.NPC_TimeUntilFire = 0.2
SWEP.NPC_CustomSpread = 1.5
SWEP.ViewModel     = ""
SWEP.WorldModel    = "models/weapons/w_pist_glock18.mdl"
SWEP.Primary.Delay = 0.3
SWEP.Primary.ClipSize = 17
SWEP.Primary.Sound = "weapons/glock/glock17_close.wav"

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
        wm    = "models/weapons/w_pist_glock18.mdl",
        delay = 0.27,
        clip  = 17,
        snd   = ")weapons/glock/glock17_close.wav",
		dmg = 20,
    },
    {
        wm    = "models/weapons/w_pist_fiveseven.mdl",
        delay = 0.28,
        clip  = 15,
        snd   = ")weapons/p99/fire.wav",
		dmg = 22,
    },
    {
        wm    = "models/weapons/w_pist_deagle.mdl",
        delay = 0.6,
        clip  = 7,
        snd   = ")weapons/tfa_ins2/thanez_cobra/revolver_fp.wav",
		dmg = 48,
    },
    {
        wm    = "models/weapons/w_pist_p228.mdl",
        delay = 0.35,
        clip  = 8,
        snd   = ")weapons/tfa_ins2/pm/makarov_fp.wav",
		dmg = 24,
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
    self.Primary.Delay = cfg.delay
    self.NPC_NextPrimaryFire = cfg.delay
    self.Primary.ClipSize = cfg.clip
    self.Primary.Sound = cfg.snd
	self.Primary.Damage = cfg.dmg

    self:SetClip1(self.Primary.ClipSize)
    self:SetHoldType(math.random(1,3) ~= 1 and "revolver" or "pistol")
end
