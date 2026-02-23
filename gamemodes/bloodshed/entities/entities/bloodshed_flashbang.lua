AddCSLuaFile()

local ExplodeSound = Sound(")weapons/cod2019/throwables/flashbang/flash_expl_02.ogg")

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Flashbang"
ENT.Spawnable = false

function ENT:Initialize()
    self:SetModel("models/simpnades/w_m84.mdl")
    if SERVER then
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetMass(4)
            phys:Wake()
        end
        
        timer.Simple(1.6, function()
            if IsValid(self) then
                self:Explode()
            end
        end)
    end
end

function ENT:Explode()
    if not IsValid(self) then return end
    
    local effect = EffectData()
    effect:SetOrigin(self:GetPos())
    effect:SetNormal(Vector(0,0,1))
    util.Effect("AR2Impact", effect)
    util.Effect("cball_explode", effect)
    
    self:EmitSound(ExplodeSound, 110)
    
    local pos = self:GetPos()
    for _, ply in pairs(player.GetAll()) do
        if not IsValid(ply) or not ply:Alive() then continue end

        local vis = ply:Visible(self)
        local distance = pos:Distance(ply:GetPos())
        if distance > 1000 and vis then continue end
        if distance > 200 and not vis then continue end
        
        local flashIntensity = math.max(0, ((1000 - distance) / 1000))
        
        if flashIntensity > 0.2 then
            local flashDuration = flashIntensity * 6
            
            net.Start("FlashbangEffect")
            net.WriteFloat(flashIntensity)
            net.WriteFloat(flashDuration)
            net.WriteEntity(ply)
            net.Send(ply)
            
            ply:SetDSP(31)
            if math.random(1,4) == 1 then
                ply:StartRagdolling()
            end
            
            timer.Simple(flashDuration, function()
                if IsValid(ply) then
                    ply:SetDSP(0)
                end
            end)
        end
    end
    for _, ply in pairs(ents.FindByClass("npc_vj_bloodshed_suspect")) do
        if not IsValid(ply) then continue end

        local vis = ply:Visible(self)
        local distance = pos:Distance(ply:GetPos())
        if distance > 1000 and vis then continue end
        if distance > 200 and not vis then continue end
        
        local flashIntensity = math.max(0, ((1000 - distance) / 1000))
        
        if flashIntensity > 0.2 then
            ply:FullSurrender()
        end
    end

    net.Start("FlashbangEffect")
    net.WriteFloat(0)
    net.WriteFloat(0)
    net.WriteEntity(self)
    net.Broadcast()

    SafeRemoveEntityDelayed(self, 0.1)
end

if CLIENT then
    net.Receive("FlashbangEffect", function()
        local intensity = net.ReadFloat()
        local duration = net.ReadFloat()
        local ent = net.ReadEntity()
        if IsValid(ent) and !ent:IsPlayer() then
            local dlight = DynamicLight(ent:EntIndex())
            dlight.pos = ent:GetPos()
            dlight.r = 255
            dlight.g = 255
            dlight.b = 255
            dlight.brightness = 4
            dlight.decay = 2500
            dlight.size = 1024
            dlight.dietime = CurTime() + 1
        else
            LocalPlayer():SetEyeAngles(Angle(math.random(-90,90),math.random(-180,180),0))
        end
        
        local flash = vgui.Create("DPanel")
        flash:SetSize(ScrW(), ScrH())
        flash:SetPos(0, 0)
        flash:MoveToFront()
        
        local alpha = intensity * 600
        
        surface.PlaySound("weapons/flashbang/flashbang_explode1.wav")
        
        flash.Paint = function(self, w, h)
            surface.SetDrawColor(255, 255, 255, alpha)
            surface.DrawRect(0, 0, w, h)
            
            alpha = math.max(0, alpha - FrameTime() * (255 / duration))
            
            if alpha <= 0 or !LocalPlayer():Alive() then
                self:Remove()
            end
        end
    end)
end

if SERVER then
    util.AddNetworkString("FlashbangEffect")
end