AddCSLuaFile()

ENT.Base = "obj_vj_projectile_base"
ENT.PrintName = "Grenade"

game.AddParticles("particles/ac_explosions.pcf")

if SERVER then
    function ENT:Initialize()
        if self.F1 then
            self:SetModel("models/simpnades/w_f1.mdl")
        else
            self:SetModel("models/simpnades/w_m67.mdl")
        end
        self:PhysicsInit(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
        self.Activated = false

        if !IsValid(self.OwnerTrap) then
            timer.Simple(4, function()
                if !IsValid(self) then return end
                self:Explode()
            end)
            self.VJ_ID_Grenade = true
            self.VJ_ID_Grabbable = true
        else
            if IsValid(phys) then
                phys:Sleep()
                phys:EnableMotion(false)
            end
            self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
            if self.StakeLimit then
                self.Limited = true
            end
        end
    end

    function ENT:Think()
        if self.Activated then return end
        
        if not IsValid(self.StakeEnt) then
            return
        end

        if self.Limited and self:WorldSpaceCenter():Distance(self.StakeEnt:WorldSpaceCenter()) > self.StakeLimit then
            self:ActivateGrenade()
            return
        end
        
        local tr = util.TraceLine({
            start = self:GetPos() + Vector(0, 0, 5),
            endpos = self.StakeEnt:GetPos() + self.StakeEnt:GetUp() * 5,
            filter = {self, self.OwnerTrap, self:GetParent(), self.StakeEnt, self.StakeEnt:GetParent()},
            mask = MASK_SOLID
        })
        
        local hitEntity = tr.Entity
        if not IsValid(hitEntity) then return end
        
        local shouldActivate = false
        
        if hitEntity:IsPlayer() then
            if hitEntity:Alive() and hitEntity:Health() > 0 and !hitEntity:IsKiller() then
                shouldActivate = true
            end  
        elseif hitEntity:IsNPC() then
            if hitEntity:Health() > 0 then
                if hitEntity:GetClass() == "npc_vj_bloodshed_suspect" then
                    if IsValid(self.OwnerTrap) and self.OwnerTrap:IsPlayer() then
                        shouldActivate = true
                    elseif IsValid(self.OwnerTrap) and self.OwnerTrap:GetClass() == "npc_vj_bloodshed_suspect" then
                        shouldActivate = false
                    end
                else
                    shouldActivate = true
                end
            end
            
        else
            local phys = hitEntity:GetPhysicsObject()
            if IsValid(phys) and phys:IsMotionEnabled() then
                shouldActivate = true
            end
        end
        
        if hitEntity == self.OwnerTrap then
            shouldActivate = false
        end
        
        if shouldActivate then
            self:ActivateGrenade()
        end
    end

    function ENT:PhysicsCollide(data, phys)
        if data.Speed > 50 then
            self:EmitSound(")murdered/weapons/grenade/m67_bounce_01.wav", 60, math.random(80,120))
            sound.EmitHint(SOUND_DANGER, self:GetPos(), 400, 1, self)
        end
    end

    function ENT:OnTakeDamage(dmg)
        if self.Activated then return end
        if dmg:GetDamage() > 5 then
            self:Explode()
        end
    end

    function ENT:ActivateGrenade()
        if self.Activated then return end
        self.Activated = true
        if IsValid(self.StakeConst) then
            self.StakeConst:Remove()
            self:EmitSound("weapons/tripwire/ropeshoot.wav", 60, math.random(80,120)) 
        end
        timer.Simple(0.1, function()
            if !IsValid(self) then return end
            self:EmitSound(")murdered/weapons/grenade/f1_pinpull.wav", 60, math.random(80,120)) 
        end)
        timer.Simple(1, function()
            if !IsValid(self) then return end
            self:StopSound("weapons/tripwire/ropeshoot.wav")
            self:Explode()
        end)
    end

    function ENT:Bullets()
        local count, det = 14, 0
        timer.Create("grenbullets"..self:EntIndex(), 0.0001, count, function()
            if !IsValid(self) then return end
            det = det + 1
            for i = 1, 20 do
                local dir = VectorRand(-1,1)
                if self:OnGround() and dir.z < 0 then
                    dir.z = math.Rand(0,1)
                end
                local bullet = {} 
                bullet.Attacker = self.PlayerOwner or game.GetWorld()
                bullet.Damage = 50
                bullet.Force = 5
                bullet.Num = 1
                bullet.Src = self:WorldSpaceCenter()
                bullet.Dir = dir
                bullet.Spread = Vector(0, 0, 0)
                bullet.Tracer = 1
                bullet.TracerName = "Tracer"
                bullet.IgnoreEntity = self
                
                self:FireBullets(bullet)
            end
            if det == count then
                SafeRemoveEntityDelayed(self, 0.2)
            end
        end)
    end
    
    function ENT:Explode()
        self.Activated = true
        local num = 1
        if self.SuperGrenade then
            num = math.random(10,100)
        end
        for i=1, num do
            timer.Simple(i/10, function()
                if !IsValid(self) then return end
                self:EmitSound(")murdered/weapons/other/ied_detonate_dist_0"..math.random(1,3)..".wav", 120, math.random(90,110))
                util.ScreenShake(self:GetPos(), 25, 25, 3, 2000)
                ParticleEffect("AC_grenade_explosion", self:GetPos(), Angle(0,0,0))
                ParticleEffect("AC_grenade_explosion_air", self:GetPos(), Angle(0,0,0))
                util.Decal("Scorch", self:GetPos(), self:GetPos()-Vector(0,0,8), self)
                local att = self
                if IsValid(self.PlayerOwner) then
                    att = self.PlayerOwner
                end
                if self.F1 then
                    util.BlastDamage(att, att, self:GetPos(), 400, 200)
                else
                    util.BlastDamage(att, att, self:GetPos(), 300, 250)
                end
                if i == num then
                    self:Bullets()
                end
            end)
        end
    end
end