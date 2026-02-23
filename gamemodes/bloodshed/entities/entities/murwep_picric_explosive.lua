AddCSLuaFile()

ENT.Base = "obj_vj_projectile_base"
ENT.PrintName = "Melinite Charge"

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/props_junk/metal_paintcan001a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
        self.Activated = false
        self.VJ_ID_Grenade = true
        self.VJ_ID_Grabbable = true
        
        -- Fuse timer just in case it doesn't hit hard enough
        timer.Simple(4, function()
            if IsValid(self) then self:Explode() end
        end)
    end

    function ENT:PhysicsCollide(data, phys)
        if data.Speed > 50 then
            //self:Explode()
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
        
        local effectdata = EffectData()
        effectdata:SetOrigin(pos)
        util.Effect("Explosion", effectdata)
        util.Effect("HelicopterMegaBomb", effectdata)
        ParticleEffect("AC_rpg_explosion", self:GetPos(), Angle(0,0,0))
        ParticleEffect("AC_rpg_explosion_air", self:GetPos(), Angle(0,0,0))
        
        util.BlastDamage(self, owner, pos, 400, 250)
        MakeExplosionReverb(self:GetPos())
        
        SafeRemoveEntity(self)
    end
end
