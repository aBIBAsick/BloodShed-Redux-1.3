AddCSLuaFile()

SWEP.Base = "mur_loot_base"
SWEP.PrintName = "Strychnine"
SWEP.Slot = 5

SWEP.WorldModel = "models/murdered/heroin/syringe_out/syringe_out.mdl"
SWEP.ViewModel = "models/murdered/heroin/darky_m/c_syringe_v2.mdl"
SWEP.BandageSound = "murdered/medicals/syringe_heroin.wav"

SWEP.WorldModelPosition = Vector(4, -2, -2)
SWEP.WorldModelAngle =  Angle(-90, 0, 0)

SWEP.ViewModelPos = Vector(0, 0, -2)
SWEP.ViewModelAng = Angle(0, 0, 0)
SWEP.ViewModelFOV = 65

SWEP.HoldType = "slam"

SWEP.VElements = {
	["strychnine"] = { type = "Model", model = "models/murdered/heroin/syringe_out/syringe_out.mdl", bone = "main", rel = "", pos = Vector(0, -5.41, -0.205), angle = Angle(0, -90, -30), size = Vector(1.2, 1.2, 1.2), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.ViewModelBoneMods = {
	["main"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["button"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["cap"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["capup"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.TPIKForce = true
SWEP.TPIKPos = Vector(-4, 0, 2)

function SWEP:Deploy( wep )
    self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetHoldType(self.HoldType)
end

function SWEP:OnDrop()
    if self.Used then
        self:Remove()
    end
end

function SWEP:CustomInit() 
	self.Used = false
end

function SWEP:CustomPrimaryAttack() 
	if self.Used then return end
	local ow = self:GetOwner()
	local tr = util.TraceLine({
		start = ow:GetShootPos(),
		endpos = ow:GetShootPos() + ow:GetAimVector() * 64,
		filter = ow,
		mask = MASK_SHOT_HULL
	})
	local tar = tr.Entity
	if tar.isRDRag and IsValid(tar.Owner) then
		tar = tar.Owner
	end
	if IsValid(tar) and tar:IsPlayer() then
		self.Used = true
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
		if SERVER then
			ow:EmitSound(self.BandageSound)
			timer.Simple(1, function()
				if !IsValid(self) or !IsValid(ow) then return end
				MuR:GiveMessage("strychnine_use_target", ow)
				
                MuR.Drug:Apply(tar, "strychnine")

				self:Remove()
			end)
		end 
	end 
end

function SWEP:DrawHUD()
	local ply = self:GetOwner()
	draw.SimpleText(MuR.Language["loot_cyanide"], "MuR_Font1", ScrW()/2, ScrH()-He(100), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
SWEP.Category = "Bloodshed - Agents"
SWEP.Spawnable = true
