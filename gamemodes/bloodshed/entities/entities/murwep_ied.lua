AddCSLuaFile()

ENT.Base = "base_anim"
ENT.PrintName = "IED"

if SERVER then
    util.AddNetworkString("IEDMotionAlert")

    function ENT:Initialize()
        self:SetModel("models/murdered/weapons/insurgency/w_ied.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(true)
        end
        self:SetCollisionGroup(1)
        self.ExplosionDamageMult = 1
        self.IsZBaseGrenade = true
    end

    function ENT:PhysicsCollide(data, col)
        if self.Connected then return end
        self.Connected = true

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Sleep()
            phys:EnableMotion(false)
        end

        if game.GetWorld() != data.HitEntity then
            self:SetParent(data.HitEntity)
        end
        self:SetAngles(data.HitNormal:Angle()+Angle(0,270,0))
    end

    function ENT:OnTakeDamage(dmg)
        if self.Activated then return end
        if dmg:GetDamage() > 5 then
            self:Explode()
        end
    end

    function ENT:Think()
        local par = self:GetParent()
        if IsValid(par) and (IsValid(par:GetPhysicsObject()) and par:GetPhysicsObject():IsMotionEnabled() or istable(par.Inventory)) then
            self:SetNoDraw(true)
        end

        local ply = self.PlayerOwner
        if IsValid(ply) then
            local targetFound = false
            for _, ent in pairs(ents.FindInSphere(self:GetPos(), 400)) do
                if (ent:IsPlayer() and ent:Alive() or ent:IsNPC()) and ent:IsLineOfSightClear(self:GetPos()) and ent != ply then
                    targetFound = true
                    break
                end
            end
            
            if targetFound then
                net.Start("IEDMotionAlert")
                net.Send(ply)
            end
        end

        self:NextThink(CurTime()+0.2)
        return true
    end
    
    function ENT:Explode()
        self:SetParent(nil)
        timer.Simple(0.01, function()
            if !IsValid(self) then return end
            self.Activated = true
            self.Connected = true
            self:EmitSound(")murdered/weapons/other/ied_detonate_dist_0"..math.random(1,3)..".wav", 120, math.random(75,85))
            util.ScreenShake(self:GetPos(), 50, 25, 4, 2500)

            ParticleEffect("AC_rpg_explosion", self:GetPos(), Angle(0,0,0))
            ParticleEffect("AC_rpg_explosion_air", self:GetPos(), Angle(0,0,0))

            local att = self
            if IsValid(self.PlayerOwner) then
                att = self.PlayerOwner
            end

            util.Decal("Scorch", self:GetPos(), self:GetPos()-Vector(0,0,8), self)
            util.BlastDamage(att, att, self:GetPos()+Vector(0,0,2), 250*(self.ExplosionDamageMult*2), 500*self.ExplosionDamageMult)
            MakeExplosionReverb(self:GetPos())
            self:Remove()
        end)
    end
else
    net.Receive("IEDMotionAlert", function()
        surface.PlaySound("buttons/button15.wav")
        
        local startTime = CurTime()
        local displayTime = 0.02
        local fadeTime = 0.4
        
        hook.Add("HUDPaint", "IEDMotionAlert", function()
            local elapsed = CurTime() - startTime
            local alpha = 255
            
            if elapsed > displayTime then
                local fadeProgress = (elapsed - displayTime) / fadeTime
                if fadeProgress >= 1 then
                    hook.Remove("HUDPaint", "IEDMotionAlert")
                    return
                end
                alpha = 255 * (1 - fadeProgress)
            end
            
            local text = "Motion Detected [IED]"
            local font = "MuR_Font2"
            
            surface.SetFont(font)
            local textW, textH = surface.GetTextSize(text)
            
            local boxW = textW + We(20)
            local boxH = textH + He(10)
            local x = ScrW() / 2 - boxW / 2
            local y = ScrH() /2 + He(200)
            
            surface.SetDrawColor(0, 0, 0, alpha * 0.78)
            surface.DrawRect(x, y, boxW, boxH)
            
            surface.SetDrawColor(255, 0, 0, alpha)
            surface.DrawOutlinedRect(x, y, boxW, boxH)
            
            surface.SetTextColor(255, 255, 255, alpha)
            surface.SetTextPos(x + We(10), y + He(5))
            surface.DrawText(text)
        end)
    end)
end