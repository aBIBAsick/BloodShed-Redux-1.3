AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Flash Powder"
ENT.Author = "Zippy"
ENT.Category = "Projectiles"

ENT.Model = "models/props_junk/garbage_metalcan001a.mdl"
ENT.FuseTime = 2

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(2)
	end
	
	if SERVER then
		timer.Simple(self.FuseTime, function()
			if IsValid(self) then
				self:DeathEffects()
			end
		end)
	end
end

function ENT:DeathEffects()
	local pos = self:GetPos()
	
	-- Flash Effect
	local effectdata = EffectData()
	effectdata:SetOrigin(pos)
	util.Effect("Explosion", effectdata) -- Standard explosion for sound/visual base
	
	-- Bright Flash
	local light = ents.Create("light_dynamic")
	light:SetPos(pos)
	light:SetKeyValue("_light", "255 255 255 255")
	light:SetKeyValue("distance", "1000")
	light:SetKeyValue("brightness", "5")
	light:Spawn()
	light:Fire("TurnOn", "", 0)
	light:Fire("Kill", "", 0.2)

	if SERVER then
		for k, v in pairs(ents.FindInSphere(pos, 600)) do
			if v:IsPlayer() and v:Alive() then
				-- Check line of sight
				local tr = util.TraceLine({
					start = pos,
					endpos = v:EyePos(),
					filter = self,
					mask = MASK_VISIBLE
				})
				
				if not tr.HitWorld then
					-- Apply flashblindness
					v:ScreenFade(SCREENFADE.IN, color_white, 2, 5)
					v:SetDSP(37) -- Stun DSP
					MuR.Drug:Apply(v, "flash_powder")
				end
			end
		end
	end

	self:Remove()
end