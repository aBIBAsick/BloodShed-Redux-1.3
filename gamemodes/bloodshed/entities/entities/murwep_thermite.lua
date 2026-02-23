AddCSLuaFile()

ENT.Base = "obj_vj_projectile_base"
ENT.PrintName = "Thermite Grenade"

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/props_junk/garbage_metalcan001a.mdl") -- Using can model as placeholder/thermite can
        self:PhysicsInit(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
        self.Activated = false

        timer.Simple(4, function()
            if !IsValid(self) then return end
            self:Explode()
        end)
        self.VJ_ID_Grenade = true
        self.VJ_ID_Grabbable = true
    end

    function ENT:Think()
        -- Thermite doesn't need tripwire logic for now
    end

    function ENT:PhysicsCollide(data, phys)
        if data.Speed > 50 then
            self:EmitSound("physics/metal/metal_canister_impact_hard" .. math.random(1,3) .. ".wav", 60, math.random(80,120))
        end
    end

    function ENT:OnTakeDamage(dmg)
        if self.Activated then return end
        if dmg:GetDamage() > 5 then
            self:Explode()
        end
    end
    
    function ENT:Explode()
        if self.Activated then return end
        self.Activated = true
        
        self:EmitSound("ambient/fire/ignite.wav", 75, 100)
        
        -- Spawn VFire
        local pos = self:GetPos()
        local owner = self.PlayerOwner or self
        
        -- Create multiple fire balls to simulate thermite spread
        for i=1, 5 do
            local offset = VectorRand() * 50
            offset.z = 0
            local firePos = pos + offset
            
            -- Check if CreateVFireBall exists (it should based on mur_gasoline.lua)
            if CreateVFireBall then
                CreateVFireBall(20, 10, firePos, Vector(0,0,0), owner)
            end

            local fire = ents.Create("env_fire")
            fire:SetPos(firePos)
            fire:SetKeyValue("health", 30)
            fire:SetKeyValue("firesize", 128)
            fire:SetKeyValue("fireattack", 4)
            fire:SetKeyValue("damagescale", 1.0)
            fire:SetKeyValue("start_active", "1")
            fire:Spawn()
            fire:Activate()
            fire:Fire("StartFire", "", 0)
            SafeRemoveEntityDelayed(fire, 15)
        end
        
        SafeRemoveEntity(self)
    end
end
