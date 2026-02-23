AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Silver Explosive"
ENT.Author = "Zippy"
ENT.Category = "Projectiles"

ENT.Model = "models/props_junk/garbage_metalcan001a.mdl"

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(3)
	end
end

function ENT:DeathEffects()
	local pos = self:GetPos()
	
	local effectdata = EffectData()
	effectdata:SetOrigin(pos)
	util.Effect("Explosion", effectdata)
	util.Effect("HelicopterMegaBomb", effectdata)
	
	if SERVER then
		util.BlastDamage(self, self:GetOwner() or self, pos, 150, 100) -- High damage, medium radius
		MakeExplosionReverb(pos)
	end

	self:Remove()
end

function ENT:PhysicsCollide(data, phys)
	-- Extremely sensitive: Explodes on any impact with sufficient force
	if data.Speed > 50 then
		self:DeathEffects()
	end
end
