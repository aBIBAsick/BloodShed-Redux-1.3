AddCSLuaFile()

SWEP.Base = "mur_loot_base"
SWEP.PrintName = "Melinite Charge"
SWEP.Slot = 4
SWEP.WorldModel = "models/props_junk/metal_paintcan001a.mdl"
SWEP.ViewModel = "models/props_junk/metal_paintcan001a.mdl"
SWEP.Primary.Delay = 1
SWEP.WorldModelPosition = Vector(3.5, -2, 2)
SWEP.WorldModelAngle = Angle(0, 0, 0)
SWEP.ViewModelPos = Vector(20,4,-10)
SWEP.ViewModelAng = Angle(0, 0, 5)
SWEP.ViewModelFOV = 90
SWEP.HoldType = "grenade"
SWEP.PinPulled = false

SWEP.TPIKForce = true
SWEP.TPIKPos = Vector(10,0,6)

function SWEP:Deploy(wep)
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetHoldType(self.HoldType)
	self.PinPulled = false
end

function SWEP:CustomPrimaryAttack()
	if self.PinPulled then return end
	
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	self.PinPulled = true
end

function SWEP:Think()
	if self.PinPulled and !self:GetOwner():KeyDown(IN_ATTACK) then
		self:ThrowGrenade()
	end
end

function SWEP:ThrowGrenade()
	if !self.PinPulled then return end
	
	if SERVER then
        self:SendWeaponAnim(ACT_VM_THROW)
		self:GetOwner():EmitSound("weapon.Swing")

		timer.Simple(0.3, function()
			if not IsValid(self) or not IsValid(self:GetOwner()) then return end
			local ent = ents.Create("murwep_picric_explosive")
			ent:SetPos(self:GetOwner():EyePos() + self:GetOwner():GetAimVector() * 4 + self:GetOwner():GetRight() * 4)
			ent.PlayerOwner = self:GetOwner()
			ent:Spawn()
			ent:GetPhysicsObject():SetVelocity(self:GetOwner():GetAimVector() * 1000)
            ent:GetPhysicsObject():AddAngleVelocity(Vector(600, 0, 0))
			self:GetOwner():ViewPunch(Angle(5, 0, 0))
		end)

		timer.Simple(0.9, function()
			if not IsValid(self) then return end
			self:Remove()
		end)
	end
	
	self.PinPulled = false
end

function SWEP:CustomInit()
	self.Activated = false
	self.PinPulled = false
end

function SWEP:OnDrop()
	if self.Activated then
		self:Remove()
	end
end

function SWEP:DrawHUD()
	draw.SimpleText(MuR.Language["loot_grenade_1"] or "Hold LMB to throw", "MuR_Font1", ScrW()/2, ScrH()-He(100), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

SWEP.Category = "Bloodshed - Agents"
SWEP.Spawnable = true
