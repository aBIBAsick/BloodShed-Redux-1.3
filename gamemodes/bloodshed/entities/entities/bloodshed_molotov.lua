AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Molotov Cocktail"
ENT.Spawnable = false

-- Molotov parameters
local FIRE_RADIUS = 72            -- Radius of the fire spread
local FIRE_DURATION = 8            -- How long the fire burns (seconds)
local FIRE_DAMAGE = 3              -- Damage per tick
local FIRE_DAMAGE_INTERVAL = 0.5   -- Damage tick interval

local BreakSound = Sound("physics/glass/glass_bottle_break2.wav")
local IgniteSound = Sound("ambient/fire/mtov_flame2.wav")
local BurnLoopSound = Sound("nades/molotov/molotov_burn_loop.wav")

function ENT:Initialize()
    self:SetModel("models/murdered/weapons/w_molotov.mdl")
    
    if SERVER then
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetMass(1)
            phys:Wake()
            phys:SetMaterial("glass")
        end
        
        self.Armed = true
        self.HasExploded = false
    end
    
    -- Trail effect for the burning wick
    if CLIENT then
        local emitter = ParticleEmitter(self:GetPos())
        if emitter then
            timer.Create("MolotovTrail_" .. self:EntIndex(), 0.05, 0, function()
                if not IsValid(self) then
                    timer.Remove("MolotovTrail_" .. self:EntIndex())
                    return
                end
                
                local particle = emitter:Add("particles/smokey", self:GetPos() + Vector(0, 0, 5))
                if particle then
                    particle:SetVelocity(VectorRand() * 20 + Vector(0, 0, 30))
                    particle:SetLifeTime(0)
                    particle:SetDieTime(0.5)
                    particle:SetStartAlpha(150)
                    particle:SetEndAlpha(0)
                    particle:SetStartSize(3)
                    particle:SetEndSize(8)
                    particle:SetColor(255, 150, 50)
                    particle:SetGravity(Vector(0, 0, 50))
                end
            end)
        end
    end
end

function ENT:PhysicsCollide(data, phys)
    if SERVER and self.Armed and not self.HasExploded then
        -- Only explode on significant impact
        if data.Speed > 50 then
            self:Explode(data.HitPos, data.HitNormal)
        end
    end
end

function ENT:Explode(hitPos, hitNormal)
    if self.HasExploded then return end
    self.HasExploded = true
    
    local pos = hitPos or self:GetPos()
    local normal = hitNormal or Vector(0, 0, 1)
    
    -- Break sound
    self:EmitSound(BreakSound, 80, math.random(95, 105))
    
    -- Ignite sound
    timer.Simple(0.1, function()
        if not IsValid(self) then return end
        sound.Play(IgniteSound, pos, 85, math.random(95, 105))
    end)
    
    -- Create the fire zone entity
    local fireZone = ents.Create("bloodshed_molotov_fire")
    if IsValid(fireZone) then
        fireZone:SetPos(pos)
        fireZone:SetAngles(normal:Angle())
        fireZone.FireRadius = FIRE_RADIUS
        fireZone.FireDuration = FIRE_DURATION
        fireZone.FireDamage = FIRE_DAMAGE
        fireZone.FireDamageInterval = FIRE_DAMAGE_INTERVAL
        fireZone.Owner = self:GetOwner()
        fireZone:Spawn()
        fireZone:Activate()
    end
    
    CreateVFireBall(FIRE_DURATION, 8, pos, Vector(0, 0, 1), self:GetOwner())
    
    -- Glass shards effect
    local effectData = EffectData()
    effectData:SetOrigin(pos)
    effectData:SetNormal(normal)
    effectData:SetMagnitude(2)
    effectData:SetScale(1)
    util.Effect("GlassImpact", effectData)
    
    -- Initial fire burst effect
    effectData:SetOrigin(pos)
    effectData:SetScale(FIRE_RADIUS)
    util.Effect("HelicopterMegaBomb", effectData)
    
    SafeRemoveEntity(self)
end

function ENT:OnRemove()
    if CLIENT then
        timer.Remove("MolotovTrail_" .. self:EntIndex())
    end
end

function ENT:Draw()
    self:DrawModel()
end