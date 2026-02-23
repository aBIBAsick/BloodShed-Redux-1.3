AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Molotov Fire"
ENT.Spawnable = false

local BurnLoopSound = Sound("ambient/fire/fire_small_loop2.wav")

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "FireEndTime")
    self:NetworkVar("Float", 1, "FireRadius")
end

function ENT:Initialize()
    self:SetModel("models/props_junk/flare.mdl")
    self:SetNoDraw(true)
    
    if SERVER then
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_NONE)
        
        self.FireRadius = self.FireRadius or 150
        self.FireDuration = self.FireDuration or 8
        self.FireDamage = self.FireDamage or 5
        self.FireDamageInterval = self.FireDamageInterval or 0.3
        
        self:SetFireEndTime(CurTime() + self.FireDuration)
        self:SetFireRadius(self.FireRadius)
        
        self.NextDamageTime = CurTime()
        self.BurningEntities = {}
        
        -- Play looping fire sound
        self.FireSound = CreateSound(self, BurnLoopSound)
        if self.FireSound then
            self.FireSound:Play()
            self.FireSound:ChangeVolume(0.8)
        end
        
        -- Spread fire to nearby flammable props
        timer.Simple(0.5, function()
            if IsValid(self) then
                self:SpreadFireToProps()
            end
        end)
    end
    
    if CLIENT then
        self.Particles = {}
        self:StartFireEffects()
    end
end

function ENT:SpreadFireToProps()
    local pos = self:GetPos()
    local radius = self.FireRadius
    
    for _, ent in ipairs(ents.FindInSphere(pos, radius)) do
        if not IsValid(ent) then continue end
        
        -- Ignite physics props
        if IsValid(ent:GetPhysicsObject()) and ent:GetPhysicsObject():IsMotionEnabled() and not ent:IsOnFire() then
            ent:Ignite(self.FireDuration, radius * 0.5)
        end
    end
end

function ENT:Think()
    if SERVER then
        local curTime = CurTime()
        
        -- Check if fire should end
        if curTime >= self:GetFireEndTime() then
            if self.FireSound then
                self.FireSound:Stop()
            end
            SafeRemoveEntity(self)
            return
        end
        
        -- Deal damage at intervals
        if curTime >= self.NextDamageTime then
            self.NextDamageTime = curTime + self.FireDamageInterval
            self:DealFireDamage()
        end
        
        self:NextThink(curTime)
        return true
    end
end

function ENT:DealFireDamage()
    local pos = self:GetPos()
    local radius = self.FireRadius
    local owner = self.Owner
    
    if not IsValid(owner) then
        owner = self
    end
    
    for _, ent in ipairs(ents.FindInSphere(pos, radius)) do
        if not IsValid(ent) then continue end
        
        local isPlayer = ent:IsPlayer()
        local isNPC = ent:IsNPC()
        
        if isPlayer or isNPC then
            -- Check if entity is alive
            if isPlayer and not ent:Alive() then continue end
            if isNPC and ent:Health() <= 0 then continue end
            
            -- Check line of sight (fire doesn't go through walls)
            local tr = util.TraceLine({
                start = pos + Vector(0, 0, 10),
                endpos = ent:WorldSpaceCenter(),
                filter = self,
                mask = MASK_SOLID_BRUSHONLY
            })
            
            if tr.Hit then continue end
            
            -- Calculate damage based on distance
            local distance = pos:Distance(ent:GetPos())
            local damageMult = 1 - (distance / radius)
            damageMult = math.Clamp(damageMult, 0.3, 1)
            
            local damage = self.FireDamage * damageMult
            
            -- Create damage info
            local dmgInfo = DamageInfo()
            dmgInfo:SetDamage(damage)
            dmgInfo:SetDamageType(DMG_BURN)
            dmgInfo:SetAttacker(owner)
            dmgInfo:SetInflictor(self)
            dmgInfo:SetDamagePosition(ent:WorldSpaceCenter())
            
            ent:TakeDamageInfo(dmgInfo)
            
            -- Ignite players/NPCs
            if not ent:IsOnFire() then
                local remainingTime = self:GetFireEndTime() - CurTime()
                ent:Ignite(math.min(remainingTime, 3))
            end
            
            -- Track burning entities for effects
            self.BurningEntities[ent] = CurTime() + 1
        end
    end
end

function ENT:OnRemove()
    if SERVER then
        if self.FireSound then
            self.FireSound:Stop()
        end
    end
    
    if CLIENT then
        self:StopFireEffects()
    end
end

-- CLIENT SIDE FIRE EFFECTS
if CLIENT then
    function ENT:StartFireEffects()
        self.NextParticleSpawn = 0
        self.FireLights = {}
    end
    
    function ENT:StopFireEffects()
        -- Cleanup is handled automatically by particle system
    end
    
    function ENT:Draw()
        -- Entity is invisible, fire is drawn via Think
    end
    
    function ENT:Think()
        local curTime = CurTime()
        local pos = self:GetPos()
        local radius = self:GetFireRadius()
        
        if radius <= 0 then radius = 150 end
        
        -- Spawn fire particles
        if curTime >= self.NextParticleSpawn then
            self.NextParticleSpawn = curTime + 0.02
            
            local emitter = ParticleEmitter(pos)
            if emitter then
                -- Random position within fire radius
                local offset = VectorRand() * radius * 0.8
                offset.z = 0
                local particlePos = pos + offset
                
                -- Trace down to find ground
                local tr = util.TraceLine({
                    start = particlePos + Vector(0, 0, 50),
                    endpos = particlePos - Vector(0, 0, 50),
                    mask = MASK_SOLID_BRUSHONLY
                })
                
                if tr.Hit then
                    particlePos = tr.HitPos + Vector(0, 0, 2)
                end
                
                -- Fire particle
                local fire = emitter:Add("sprites/flamelet" .. math.random(1, 4), particlePos)
                if fire then
                    local vel = Vector(math.Rand(-20, 20), math.Rand(-20, 20), math.Rand(80, 150))
                    fire:SetVelocity(vel)
                    fire:SetLifeTime(0)
                    fire:SetDieTime(math.Rand(0.4, 0.8))
                    fire:SetStartAlpha(255)
                    fire:SetEndAlpha(0)
                    fire:SetStartSize(math.Rand(25, 30))
                    fire:SetEndSize(0)
                    fire:SetRoll(math.Rand(0, 360))
                    fire:SetRollDelta(math.Rand(-2, 2))
                    fire:SetColor(255, math.random(100, 200), math.random(0, 50))
                    fire:SetGravity(Vector(0, 0, 100))
                    fire:SetCollide(false)
                    fire:SetBounce(0)
                    fire:SetAirResistance(50)
                end
                
                -- Smoke particle (less frequent)
                if math.random(1, 3) == 1 then
                    local smoke = emitter:Add("particles/smokey", particlePos + Vector(0, 0, 30))
                    if smoke then
                        smoke:SetVelocity(Vector(math.Rand(-10, 10), math.Rand(-10, 10), math.Rand(50, 100)))
                        smoke:SetLifeTime(0)
                        smoke:SetDieTime(math.Rand(1, 2))
                        smoke:SetStartAlpha(100)
                        smoke:SetEndAlpha(0)
                        smoke:SetStartSize(math.Rand(20, 40))
                        smoke:SetEndSize(math.Rand(60, 100))
                        smoke:SetRoll(math.Rand(0, 360))
                        smoke:SetRollDelta(math.Rand(-1, 1))
                        smoke:SetColor(50, 50, 50)
                        smoke:SetGravity(Vector(0, 0, 30))
                        smoke:SetCollide(false)
                        smoke:SetAirResistance(100)
                    end
                end
                
                -- Ember particles
                if math.random(1, 5) == 1 then
                    local ember = emitter:Add("effects/spark", particlePos)
                    if ember then
                        ember:SetVelocity(Vector(math.Rand(-50, 50), math.Rand(-50, 50), math.Rand(100, 200)))
                        ember:SetLifeTime(0)
                        ember:SetDieTime(math.Rand(0.5, 1.5))
                        ember:SetStartAlpha(255)
                        ember:SetEndAlpha(0)
                        ember:SetStartSize(2)
                        ember:SetEndSize(0)
                        ember:SetColor(255, math.random(150, 255), 0)
                        ember:SetGravity(Vector(0, 0, -200))
                        ember:SetCollide(true)
                        ember:SetBounce(0.3)
                    end
                end
                
                emitter:Finish()
            end
        end
        
        -- Dynamic light for fire
        local timeLeft = self:GetFireEndTime() - curTime
        if timeLeft > 0 then
            local flicker = math.sin(curTime * 15) * 0.2 + math.sin(curTime * 23) * 0.1 + 0.7
            
            local dlight = DynamicLight(self:EntIndex())
            if dlight then
                dlight.pos = pos + Vector(0, 0, 30)
                dlight.r = 255
                dlight.g = 150 + math.random(-20, 20)
                dlight.b = 50
                dlight.brightness = 3 * flicker
                dlight.decay = 1000
                dlight.size = radius * 2
                dlight.dietime = curTime + 0.1
            end
        end
        
        self:SetNextClientThink(curTime + 0.01)
        return true
    end
end
