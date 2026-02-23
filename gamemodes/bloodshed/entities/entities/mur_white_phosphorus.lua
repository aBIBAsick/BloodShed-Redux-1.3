AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "White Phosphorus Grenade"
ENT.Author = "Zippy"
ENT.Category = "Projectiles"

ENT.Model = "models/props_junk/garbage_metalcan002a.mdl"
ENT.FuseTime = 3

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
	
	-- Explosion Effect
	local effectdata = EffectData()
	effectdata:SetOrigin(pos)
	util.Effect("Explosion", effectdata)
	
	-- White Phosphorus Smoke (Thick White)
	local gas = ents.Create("env_smoketrail")
	gas:SetPos(pos)
	gas:SetKeyValue("startsize", "100")
	gas:SetKeyValue("endsize", "200")
	gas:SetKeyValue("spawnradius", "200")
	gas:SetKeyValue("minspeed", "10")
	gas:SetKeyValue("maxspeed", "50")
	gas:SetKeyValue("startcolor", "255 255 255")
	gas:SetKeyValue("endcolor", "255 255 255")
	gas:SetKeyValue("opacity", "1")
	gas:SetKeyValue("spawnrate", "20")
	gas:SetKeyValue("lifetime", "4")
	gas:Spawn()
	gas:Fire("Kill", "", 10)
	
	-- Fire and Damage
	if SERVER then
		-- Ignite area
		for i=1, 5 do
			local fire = ents.Create("env_fire")
			fire:SetPos(pos + Vector(math.random(-100, 100), math.random(-100, 100), 0))
			fire:SetKeyValue("health", "30")
			fire:SetKeyValue("firesize", "256")
			fire:SetKeyValue("fireattack", "4")
			fire:SetKeyValue("damagescale", "1.0")
			fire:SetKeyValue("startdisabled", "0")
			fire:SetKeyValue("firetype", "0")
			fire:SetKeyValue("ignitionpoint", "32")
			fire:Spawn()
			fire:Fire("StartFire", "", 0)
			fire:Fire("Kill", "", 10)
		end

        local pos = self:GetPos()
        timer.Create("WPGrenade_"..self:EntIndex(), 1, 12, function()
            -- Apply WP effect to players
            for k, v in pairs(ents.FindInSphere(pos, 300)) do
                if v:IsPlayer() and v:Alive() then
                    v:Ignite(10)
                    MuR.Drug:Apply(v, "white_phosphorus")
                end
            end
		end)
	end

	self:Remove()
end
