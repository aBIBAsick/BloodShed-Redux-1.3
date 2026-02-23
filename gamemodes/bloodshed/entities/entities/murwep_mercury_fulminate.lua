AddCSLuaFile()

ENT.Base = "obj_vj_projectile_base"
ENT.PrintName = "Mercury Fulminate"

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/props_lab/jar01a.mdl")
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
        if data.Speed > 10 then -- Very sensitive
            self:Explode()
        end
    end

    function ENT:OnTakeDamage(dmg)
        if self.Activated then return end
        self:Explode()
    end
    
    function ENT:Explode()
        if self.Activated then return end
        self.Activated = true
        
        local pos = self:GetPos()
        local owner = self.PlayerOwner or self
        
        local effectdata = EffectData()
        effectdata:SetOrigin(pos)
        util.Effect("Explosion", effectdata)
        
        util.BlastDamage(self, owner, pos, 200, 120)
        MakeExplosionReverb(self:GetPos())
        
        SafeRemoveEntity(self)
    end
end
