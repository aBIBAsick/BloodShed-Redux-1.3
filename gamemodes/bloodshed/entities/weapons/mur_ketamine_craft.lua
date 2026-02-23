AddCSLuaFile()

SWEP.Base = "mur_loot_base"
SWEP.PrintName = "Ketamine"
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
	self.Used = true
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	local ow = self:GetOwner()
    if SERVER then
		ow:EmitSound("npc/barnacle/barnacle_gulp1.wav")
		timer.Simple(0.5, function()
            if !IsValid(self) or !IsValid(ow) then return end
			MuR:GiveMessage("ketamine_use", ow)
			
            MuR.Drug:Apply(ow, "ketamine")
            
            self:Remove()
        end)
	end 
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
		self.Used = true
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
		if SERVER then
			ow:EmitSound("npc/barnacle/barnacle_gulp1.wav")
			timer.Simple(0.5, function()
				if !IsValid(self) or !IsValid(ow) then return end
				MuR:GiveMessage("ketamine_use_target", ow)
				
                MuR.Drug:Apply(tar, "ketamine")

				self:Remove()
			end)
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
	draw.SimpleText(MuR.Language["loot_medic_left"] or "LMB to consume", "MuR_Font1", ScrW()/2, ScrH()-He(100), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(MuR.Language["loot_medic_right"] or "RMB to give", "MuR_Font1", ScrW()/2, ScrH()-He(85), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

SWEP.Category = "Bloodshed - Agents"
SWEP.Spawnable = true
