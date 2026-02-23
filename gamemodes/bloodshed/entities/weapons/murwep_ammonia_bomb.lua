AddCSLuaFile()

SWEP.Base = "mur_loot_base"
SWEP.PrintName = "Ammonia Bomb"
SWEP.Slot = 4

SWEP.WorldModel = "models/props_junk/metal_paintcan001a.mdl"
SWEP.ViewModel = "models/props_junk/metal_paintcan001a.mdl"

SWEP.WorldModelPosition = Vector(4, -2, -2)
SWEP.WorldModelAngle =  Angle(0, 0, 0)

SWEP.ViewModelPos = Vector(16, 8, -5)
SWEP.ViewModelAng = Angle(0, 0, 20)
SWEP.ViewModelFOV = 65

SWEP.HoldType = "grenade"

function SWEP:CustomPrimaryAttack()
	if self.Used then return end
	self.Used = true
	self:SendWeaponAnim(ACT_VM_THROW)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	
	if SERVER then
		local ent = ents.Create("mur_ammonia_bomb")
		ent:SetPos(self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 32)
		ent:SetAngles(self:GetOwner():EyeAngles())
        ent:SetOwner(self:GetOwner())
		ent:Spawn()
		ent:Activate()
		
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(self:GetOwner():GetAimVector() * 800 + Vector(0, 0, 200))
			phys:AddAngleVelocity(Vector(math.random(-500, 500), math.random(-500, 500), math.random(-500, 500)))
		end
		
		self:Remove()
	end
end

function SWEP:DrawHUD()
	draw.SimpleText(MuR.Language["loot_grenade_1"] or "Hold LMB to throw", "MuR_Font1", ScrW()/2, ScrH()-He(100), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

SWEP.Category = "Bloodshed - Agents"
SWEP.Spawnable = true
