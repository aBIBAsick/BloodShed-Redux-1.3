AddCSLuaFile()

ENT.Base = "obj_vj_projectile_base"
ENT.PrintName = "Phosgene Gas"

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/props_junk/plasticbucket001a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
        self.Activated = false

        timer.Simple(2, function()
            if !IsValid(self) then return end
            self:Explode()
        end)
        self.VJ_ID_Grenade = true
        self.VJ_ID_Grabbable = true
    end

    function ENT:Think()
        if self.Activated then
            if CurTime() > self.DieTime then
                self:Remove()
                return
            end

            if CurTime() > self.NextGasEmit then
                self.NextGasEmit = CurTime() + 0.5
                
                local pos = self:GetPos()
                local owner = self.PlayerOwner or self
                
                -- Visuals
                local smoke = ents.Create("env_smoketrail")
                if IsValid(smoke) then
                    smoke:SetPos(pos)
                    smoke:SetKeyValue("startsize", "20")
                    smoke:SetKeyValue("endsize", "120")
                    smoke:SetKeyValue("spawnradius", "32")
                    smoke:SetKeyValue("minspeed", "10")
                    smoke:SetKeyValue("maxspeed", "50")
                    smoke:SetKeyValue("startcolor", "220 220 220") -- White/Grey
                    smoke:SetKeyValue("endcolor", "220 220 220")
                    smoke:SetKeyValue("opacity", "0.6")
                    smoke:SetKeyValue("spawnrate", "20")
                    smoke:SetKeyValue("lifetime", "1")
                    smoke:Spawn()
                    smoke:Activate()
                    SafeRemoveEntityDelayed(smoke, 1)
                end
                
                -- Damage
                for _, ply in player.Iterator() do
                    if ply:GetPos():Distance(pos) < 300 then
                        if ply:Alive() then
                            MuR.SubstanceSystem:ApplyPoisonFromCloud(ply, "phosgene", owner, 1)
                        end
                    end
                end
            end
            
            self:NextThink(CurTime())
            return true
        end
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
        self.DieTime = CurTime() + 10
        self.NextGasEmit = 0
        
        self:EmitSound("physics/metal/metal_box_break1.wav", 80, 100)
        
        self.GasSound = CreateSound(self, "ambient/gas/steam_loop1.wav")
        self.GasSound:Play()
        
        -- Visual effect for gas
        local ed = EffectData()
        ed:SetOrigin(self:GetPos())
        util.Effect("GlassImpact", ed)
    end

    function ENT:OnRemove()
        if self.GasSound then
            self.GasSound:Stop()
        end
    end
end
