AddCSLuaFile()

ENT.Base = "obj_vj_projectile_base"
ENT.PrintName = "Nitrogen Mustard Gas"

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/props_junk/garbage_glassbottle003a.mdl")
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
                local ed = EffectData()
                ed:SetOrigin(self:GetPos())
                util.Effect("GlassImpact", ed)
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
                    smoke:SetKeyValue("spawnradius", "100")
                    smoke:SetKeyValue("minspeed", "10")
                    smoke:SetKeyValue("maxspeed", "50")
                    smoke:SetKeyValue("startcolor", "200 200 100")
                    smoke:SetKeyValue("endcolor", "200 200 100")
                    smoke:SetKeyValue("opacity", "0.5")
                    smoke:SetKeyValue("spawnrate", "50")
                    smoke:SetKeyValue("lifetime", "1")
                    smoke:Spawn()
                    smoke:Activate()
                    SafeRemoveEntityDelayed(smoke, 1)
                end
                
                -- Damage
                for _, ply in player.Iterator() do
                    if ply:GetPos():Distance(pos) < 200 then
                        if ply:Alive() then
                            MuR.SubstanceSystem:ApplyPoisonFromCloud(ply, "mustard_gas", owner, 1)
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
            self:EmitSound("physics/glass/glass_bottle_impact_hard" .. math.random(1,3) .. ".wav", 60, math.random(80,120))
        end
        -- Break on high impact? Maybe not, let it be timed as requested "explodes after 2 seconds"
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
        
        self:EmitSound("physics/glass/glass_bottle_break" .. math.random(1,2) .. ".wav", 80, 100)
        
        self.GasSound = CreateSound(self, "ambient/gas/steam_loop1.wav")
        self.GasSound:SetSoundLevel(60)
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
