AddCSLuaFile()

SWEP.Base = "mur_loot_base"
SWEP.PrintName = "Medkit"
SWEP.Slot = 5

SWEP.WorldModel = "models/murdered/medkit/items/healthkit.mdl"
SWEP.ViewModel = "models/murdered/medkit/weapons/c_medkit.mdl"
SWEP.BandageSound = "murdered/medicals/medkit.wav"

SWEP.WorldModelPosition = Vector(5, -4, -9)
SWEP.WorldModelAngle =  Angle(-90, 90, -90)

SWEP.ViewModelPos = Vector(0, -1, -3)
SWEP.ViewModelAng = Angle(-5, -8, 10)
SWEP.ViewModelFOV = 65

SWEP.HoldType = "slam"

SWEP.TPIKForce = true
SWEP.TPIKPos = Vector(-10, 0, -3)

function SWEP:Deploy( wep )
    self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetHoldType(self.HoldType)
end

function SWEP:CustomPrimaryAttack()
	local ow = self:GetOwner()
	if ow:GetNW2Float('BleedLevel') <= 0 and not ow:GetNW2Bool('LegBroken') and ow:Health() >= 100 then return end
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    if SERVER then
		ow:EmitSound(self.BandageSound)
		
		local bleedLevel = ow:GetNW2Float('BleedLevel')
		local hardBleed = ow:GetNW2Bool('HardBleed')
		
		local healAmount = 40
		local bleedHealCount = 3
		
		if hardBleed then
			ow:DamagePlayerSystem("hard_blood", true)
			healAmount = 50
			bleedHealCount = 2
			MuR:GiveMessage("medkit_use_critical", ow)
		elseif bleedLevel >= 3 then
			healAmount = 45
			bleedHealCount = 3
			MuR:GiveMessage("medkit_use_severe", ow)
		else
			MuR:GiveMessage("medkit_use", ow)
		end
		
		for i=1, bleedHealCount do
			ow:DamagePlayerSystem("blood", true)
		end
		ow:SetHealth(math.Clamp(ow:Health() + healAmount, 1, 100))
		ow:DamagePlayerSystem("bone", true)
		self:Remove()
	end 
end

function SWEP:CustomInit() 
	self.Used = false
end

function SWEP:CustomSecondaryAttack() 
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
		if tar:GetNW2Float('BleedLevel') <= 0 and not tar:GetNW2Bool('LegBroken') and tar:Health() >= 100 then return end
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		if SERVER then
			ow:EmitSound(self.BandageSound)
			
			local bleedLevel = tar:GetNW2Float('BleedLevel')
			local hardBleed = tar:GetNW2Bool('HardBleed')
			
			local healAmount = 40
			local bleedHealCount = 3
			
			if hardBleed then
				tar:DamagePlayerSystem("hard_blood", true)
				healAmount = 50
				bleedHealCount = 2
				MuR:GiveMessage("medkit_use_target_critical", ow)
			elseif bleedLevel >= 3 then
				healAmount = 45
				bleedHealCount = 3
				MuR:GiveMessage("medkit_use_target_severe", ow)
			else
				MuR:GiveMessage("medkit_use_target", ow)
			end
			
			for i=1, bleedHealCount do
				tar:DamagePlayerSystem("blood", true)
			end
			tar:SetHealth(math.Clamp(tar:Health() + healAmount, 1, 100))
			tar:DamagePlayerSystem("bone", true)
			self:Remove()
		end
	end 
end

function SWEP:DrawHUD()
	local ply = self:GetOwner()
	draw.SimpleText(MuR.Language["loot_medic_left"], "MuR_Font1", ScrW()/2, ScrH()-He(100), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(MuR.Language["loot_medic_right"], "MuR_Font1", ScrW()/2, ScrH()-He(85), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
SWEP.Category = "Bloodshed - Civilian"
SWEP.Spawnable = true