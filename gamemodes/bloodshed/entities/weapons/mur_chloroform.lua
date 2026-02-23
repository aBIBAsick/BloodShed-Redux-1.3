AddCSLuaFile()

SWEP.Base = "mur_loot_base"
SWEP.PrintName = "Chloroform"
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
            -- Instant unconsciousness
            if tar.ApplyUnconsciousness then
                tar:ApplyUnconsciousness(30) -- 30 seconds sleep
            else
                tar:SetNW2Bool("IsUnconscious", true)
                tar:StartRagdolling(0, 30)
                timer.Simple(30, function() if IsValid(tar) then tar:SetNW2Bool("IsUnconscious", false) end end)
            end
            
            -- Apply drug for lingering effects
            MuR.Drug:Apply(tar, "chloroform")
            
            ow:EmitSound("physics/flesh/flesh_impact_bullet" .. math.random(1, 5) .. ".wav")
			self:Remove()
		end 
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
	local ply = self:GetOwner()
	draw.SimpleText(MuR.Language["loot_cyanide"] or "LMB to use", "MuR_Font1", ScrW()/2, ScrH()-He(100), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

SWEP.Category = "Bloodshed - Agents"
SWEP.Spawnable = true
