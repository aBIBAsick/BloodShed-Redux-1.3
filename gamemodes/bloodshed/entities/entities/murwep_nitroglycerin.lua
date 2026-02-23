AddCSLuaFile()

ENT.Base = "obj_vj_projectile_base"
ENT.PrintName = "Nitroglycerin"

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/props_lab/jar01b.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
        self.Activated = false
        self.VJ_ID_Grenade = true
        self.VJ_ID_Grabbable = true
    end

    function ENT:PhysicsCollide(data, phys)
        if data.Speed > 50 then
            self:Explode()
        end
    end

    function ENT:OnTakeDamage(dmg)
        if self.Activated then return end
        if dmg:GetDamage() > 2 then
            self:Explode()
        end
    end
    
    function ENT:Explode()
        if self.Activated then return end
        self.Activated = true
        
        local pos = self:GetPos()
        local owner = self.PlayerOwner or self
        local count = math.random(1, 4)
        
        self:SetNoDraw(true)
        self:SetSolid(SOLID_NONE)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then phys:EnableMotion(false) end
        
        for i = 1, count do
            timer.Simple((i-1) * 0.15, function()
                if !IsValid(self) then return end
                local explPos = pos + Vector(math.random(-80, 80), math.random(-80, 80), math.random(0, 40))
                if i == 1 then explPos = pos end
                
                local effectdata = EffectData()
                effectdata:SetOrigin(explPos)
                util.Effect("Explosion", effectdata)
                
                util.BlastDamage(self, owner, explPos, 250, 150)
                MakeExplosionReverb(explPos)
            end)
        end
        
        timer.Simple(count * 0.15 + 0.1, function()
            if IsValid(self) then self:Remove() end
        end)
    end
end
