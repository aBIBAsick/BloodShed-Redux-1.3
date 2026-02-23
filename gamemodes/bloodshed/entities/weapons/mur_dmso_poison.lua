AddCSLuaFile()

SWEP.Base = "mur_loot_base"
SWEP.PrintName = "DMSO Poison"
SWEP.Slot = 5

SWEP.WorldModel = "models/props_lab/jar01b.mdl"
SWEP.ViewModel = "models/props_lab/jar01b.mdl"

SWEP.WorldModelPosition = Vector(4, -2, -2)
SWEP.WorldModelAngle =  Angle(0, 0, 0)

SWEP.ViewModelPos = Vector(16, 8, -5)
SWEP.ViewModelAng = Angle(0, 0, 20)
SWEP.ViewModelFOV = 65

SWEP.HoldType = "slam"

function SWEP:Deploy( wep )
    self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetHoldType(self.HoldType)
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
        self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
        
		if SERVER then
            -- DMSO transports toxins through skin rapidly
            MuR.Drug:Apply(tar, "ricin", 1.5) -- Enhanced intensity
            MuR.Drug:Apply(tar, "mercury", 1.5)
			self:Remove()
        else
            surface.PlaySound("physics/glass/glass_bottle_impact_hard" .. math.random(1, 3) .. ".wav")
		end 
    elseif SERVER then
        -- Apply to self if no target? Or maybe just splash on ground?
        -- Let's allow self-application via Primary if looking at nothing? No, usually Primary is attack.
        -- Let's stick to target only for Primary.
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

function SWEP:DrawHUD()
	draw.SimpleText(MuR.Language["loot_cyanide"] or "LMB to splash on target", "MuR_Font1", ScrW()/2, ScrH()-He(100), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

SWEP.Category = "Bloodshed - Agents"
SWEP.Spawnable = true
