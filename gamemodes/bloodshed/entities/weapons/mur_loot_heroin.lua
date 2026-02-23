AddCSLuaFile()

SWEP.Base = "mur_loot_base"
SWEP.PrintName = "Heroin"
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
	["heroin"] = { type = "Model", model = "models/murdered/heroin/syringe_out/syringe_out.mdl", bone = "main", rel = "", pos = Vector(0, -5.41, -0.205), angle = Angle(0, -90, -30), size = Vector(1.2, 1.2, 1.2), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
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

function SWEP:CustomPrimaryAttack()
	if self.Used then return end
	self.Used = true
	self:SendWeaponAnim(ACT_VM_THROW)
	local ow = self:GetOwner()
	local ind = ow:EntIndex()
    if SERVER then
		ow:EmitSound(self.BandageSound)
		timer.Simple(2.4, function()
            if !IsValid(self) or !IsValid(ow) then return end
			MuR:GiveMessage("geroin_use", ow)
			if ow:GetNW2Bool('GeroinUsed', false) then
				ow:TakeDamage(ow:Health(), ow)
				self:Remove()
				return
			elseif math.random(1,4) == 1 then
				ow:ApplyUnconsciousness(10)
				ow:TakeDamage(50, ow)
				self:Remove()
				return
			end
			ow:TakeDamage(20, ow)
			ow:SetNW2Bool('GeroinUsed', true)
			ow:ScreenFade(SCREENFADE.IN, color_black, 1, 1)
			timer.Create("GeroinUse"..ind, 60, 1, function()
				if !IsValid(ow) then 
					timer.Remove("GeroinUse"..ind)
					return
				end
				ow:ScreenFade(SCREENFADE.IN, color_black, 1, 1)
				ow:SetNW2Bool('GeroinUsed', false)
			end)
            self:Remove()
        end)
	end 
end

function SWEP:OnDrop()
    if self.Used then
        self:Remove()
    end
end

function SWEP:CustomInit() 
	self.Used = false
end

function SWEP:CustomSecondaryAttack() 
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
		local ind = tar:EntIndex()
		self.Used = true
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
		if SERVER then
			ow:EmitSound(self.BandageSound)
			timer.Simple(2.4, function()
				if !IsValid(self) or !IsValid(ow) then return end
				MuR:GiveMessage("geroin_use_target", ow)
				if tar:GetNW2Bool('GeroinUsed', false) then
					tar:TakeDamage(tar:Health(), ow)
					self:Remove()
					return
				elseif math.random(1,4) == 1 then
					tar:ApplyUnconsciousness(10)
					tar:TakeDamage(50, ow)
					self:Remove()
					return
				end
				tar:SetNW2Bool('GeroinUsed', true)
				tar:TakeDamage(20, ow)
				tar:ScreenFade(SCREENFADE.IN, color_black, 1, 1)
				timer.Create("GeroinUse"..ind, 60, 1, function()
					if !IsValid(tar) then 
						timer.Remove("GeroinUse"..ind)
						return
					end
					tar:ScreenFade(SCREENFADE.IN, color_black, 1, 1)
					tar:SetNW2Bool('GeroinUsed', false)
				end)
				self:Remove()
			end)
		end 
	end 
end

function SWEP:DrawHUD()
	local ply = self:GetOwner()
	draw.SimpleText(MuR.Language["loot_medic_left"], "MuR_Font1", ScrW()/2, ScrH()-He(100), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(MuR.Language["loot_medic_right"], "MuR_Font1", ScrW()/2, ScrH()-He(85), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
SWEP.Category = "Bloodshed - Illegal"
SWEP.Spawnable = true