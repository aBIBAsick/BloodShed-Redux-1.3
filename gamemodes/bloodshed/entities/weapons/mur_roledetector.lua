AddCSLuaFile()

SWEP.Base = "mur_loot_base"
SWEP.PrintName = "Role Detector"
SWEP.Slot = 0
SWEP.ViewModel = "models/weapons/c_bugbait.mdl"

SWEP.WorldModelPosition = Vector(4, -3, 3)
SWEP.WorldModelAngle =  Angle(180, 10, 0)

SWEP.ViewModelPos = Vector(0, -6, -7)
SWEP.ViewModelAng = Angle(0, -10, -40)
SWEP.ViewModelFOV = 70

SWEP.HoldType = "normal"

SWEP.ViewModelBoneMods = {
	["ValveBiped.cube3"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}
SWEP.VElements = {      
	["card"] = { type = "Model", model = "models/murdered/catsenya/props_pocox3nfc/catsenya_pocox3nfc.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 3, 3), angle = Angle(180, 0, 12), size = Vector(1.1, 1.1, 1.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

function SWEP:Deploy( wep )
	self:SetHoldType(self.HoldType)
end

function SWEP:CustomPrimaryAttack()
    if self.Called then return end     

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
        self.Called = true
		if SERVER then
            self:Remove()
        else
            ow:ChatPrint(MuR.Language["roledetector_detect"]..(MuR.Language[string.lower(tar:GetNW2String("Class"))] or tar:GetNW2String("Class")))
            surface.PlaySound("buttons/combine_button_locked.wav")
		end 
	end 
end

function SWEP:OnDrop()
    if self.Called then
        self:Remove()
    end
end

function SWEP:CustomSecondaryAttack() 

end

function SWEP:DrawWorldModel() end

function SWEP:DrawHUD()
	local ply = self:GetOwner()
	draw.SimpleText(MuR.Language["roledetector_desc"], "MuR_Font1", ScrW()/2, ScrH()-He(100), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
SWEP.Category = "Bloodshed - Civilian"
SWEP.Spawnable = true