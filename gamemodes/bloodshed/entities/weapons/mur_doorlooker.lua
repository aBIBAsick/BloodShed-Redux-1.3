AddCSLuaFile()

SWEP.Base = "mur_other_base"
SWEP.PrintName = "Surveillance Probe"

SWEP.VElements = {
	["main"] = { type = "Model", model = "models/props_canal/mattpipe.mdl", bone = "Base", rel = "", pos = Vector(-0.519, -2.597, 7.791), angle = Angle(3.506, -94.676, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "mechanics/metal2", skin = 0, bodygroup = {} },
	["monitor"] = { type = "Model", model = "models/props_lab/monitor01b.mdl", bone = "Base", rel = "", pos = Vector(1.2, -2.401, 2.25), angle = Angle(-85.325, 8.182, -85.325), size = Vector(0.2, 0.2, 0.2), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["main"] = { type = "Model", model = "models/props_canal/mattpipe.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(18, 1, -7), angle = Angle(75, 0, 180), size = Vector(0.95, 0.95, 0.95), color = Color(255, 255, 255, 255), surpresslightning = false, material = "mechanics/metal2", skin = 0, bodygroup = {} },
	["monitor"] = { type = "Model", model = "models/props_lab/monitor01b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(8, 3.635, -2.597), angle = Angle(0, 180, 180), size = Vector(0.4, 0.4, 0.4), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.HoldType = "ar2"
SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false
SWEP.UseHands = false
SWEP.ViewModel = "models/weapons/v_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_irifle.mdl"
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {
	["Base"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(-2.037, 3.888, 0), angle = Angle(5.556, -7.778, 5.556) }
}

SWEP.ProbeActive = false
SWEP.ProbeEntity = nil
SWEP.MaxProbeDistance = 100
SWEP.ProbePos = Vector(0, 0, 0)
SWEP.ProbeAng = Angle(0, 0, 0)

function SWEP:CustomInit()
    self.ProbeActive = false
    self:SetHoldType("ar2")
    
    if CLIENT then
        self.ScanlineTexture = surface.GetTextureID("effects/tvscreen_noise002a")
        self.StaticTexture = surface.GetTextureID("effects/combine_binocoverlay")
    end
end

function SWEP:PrimaryAttack()
    if SERVER and not self.ProbeActive then
        local owner = self:GetOwner()
        local trace = {}
        trace.start = owner:EyePos()
        trace.endpos = trace.start + owner:GetAimVector() * self.MaxProbeDistance
        trace.filter = owner
        
        local tr = util.TraceLine(trace)
        
        if tr.Hit and tr.HitPos:Distance(owner:GetPos()) < self.MaxProbeDistance and string.find(tr.Entity:GetClass(), "_door") then
            local pos = tr.Entity:WorldSpaceCenter()
            pos.z = owner:GetPos().z+8
            self:DeployProbe(pos, owner:GetAimVector())
            
            net.Start("ProbeActivated")
            net.WriteBool(true)
            net.Send(owner)
            self:SetHoldType("passive")
        end
    elseif SERVER and self.ProbeActive then
        self:RetrieveProbe()
        
        net.Start("ProbeActivated")
        net.WriteBool(false)
        net.Send(self:GetOwner())
        self:SetHoldType("ar2")
    end
    
    self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:SecondaryAttack()

end

function SWEP:DeployProbe(pos, normal)
    local probe = ents.Create("prop_physics")
    probe:SetModel("models/props_lab/huladoll.mdl")
    
    local ang = normal:Angle()
    ang:RotateAroundAxis(ang:Right(), 90)
    
    probe:SetPos(pos + normal * 8)
    probe:SetAngles(ang)
    probe:SetModelScale(0.5, 0)
    probe:Spawn()
    
    local phys = probe:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
    end
    
    probe.Owner = self:GetOwner()
    probe:SetNoDraw(true)
    
    self.ProbeEntity = probe
    self.ProbeActive = true
    self.ProbePos = probe:GetPos() + probe:GetForward() * 3
    self.ProbeAng = probe:GetAngles()
end

function SWEP:RetrieveProbe()
    if IsValid(self.ProbeEntity) then
        self.ProbeEntity:Remove()
    end
    
    self.ProbeEntity = nil
    self.ProbeActive = false
end

function SWEP:CustomHolster()
    if SERVER and self.ProbeActive then
        self:RetrieveProbe()
        
        net.Start("ProbeActivated")
        net.WriteBool(false)
        net.Send(self:GetOwner())
    end
    return true
end

function SWEP:OnRemove()
    if SERVER and self.ProbeActive then
        self:RetrieveProbe()
        
        if IsValid(self:GetOwner()) then
            net.Start("ProbeActivated")
            net.WriteBool(false)
            net.Send(self:GetOwner())
        end
    end
end

function SWEP:OnDrop()
    if SERVER and self.ProbeActive then
        self:RetrieveProbe()
        
        if IsValid(self:GetOwner()) then
            net.Start("ProbeActivated")
            net.WriteBool(false)
            net.Send(self:GetOwner())
        end
    end
end

function SWEP:Think()
    if SERVER and self.ProbeActive then
        if not IsValid(self.ProbeEntity) or self:GetOwner():GetPos():Distance(self.ProbeEntity:GetPos()) > self.MaxProbeDistance or self:GetNoDraw() then
            self:RetrieveProbe()
            
            net.Start("ProbeActivated")
            net.WriteBool(false)
            net.Send(self:GetOwner())
            return
        end
        
        self.ProbePos = self.ProbeEntity:GetPos() + self.ProbeEntity:GetForward() * 8
        self.ProbeAng = self.ProbeEntity:GetAngles()
        
        net.Start("ProbePosition")
        net.WriteVector(self.ProbePos)
        net.WriteAngle(self.ProbeAng)
        net.Send(self:GetOwner())
    end
end

if SERVER then
    util.AddNetworkString("ProbeActivated")
    util.AddNetworkString("ProbePosition")
end

if CLIENT then
    local probeActive = false
    local probePos = Vector(0, 0, 0)
    local probeAng = Angle(0, 0, 0)
    
    net.Receive("ProbeActivated", function()
        probeActive = net.ReadBool()
        if probeActive then
            surface.PlaySound("items/nvg_on.wav")
        else
            surface.PlaySound("items/nvg_off.wav")
        end
    end)
    
    net.Receive("ProbePosition", function()
        probePos = net.ReadVector()
        probeAng = Angle(-10,net.ReadAngle().y,0)
    end)
    
    hook.Add("CalcView", "SurveillanceProbeView", function(ply, origin, angles, fov)
        local activeWeapon = ply:GetActiveWeapon()
        if not IsValid(activeWeapon) or activeWeapon:GetClass() ~= "mur_doorlooker" then
            return
        end
        
        if probeActive then
            local view = {}
            view.origin = probePos
            view.angles = Angle(-15,angles.y,0)
            view.fov = 120
            view.drawviewer = true
            view.znear = 1
            
            return view
        end
    end)
    
    function SWEP:DrawHUD()
        if probeActive then
            local w, h = ScrW(), ScrH()
            
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawRect(0, 0, w, 20)
            surface.DrawRect(0, h - 20, w, 20)
            surface.DrawRect(0, 0, 20, h)
            surface.DrawRect(w - 20, 0, 20, h)
            
            surface.SetDrawColor(255, 255, 255, 20)
            surface.SetTexture(self.ScanlineTexture)
            surface.DrawTexturedRect(0, 0, w, h)
            
            surface.SetDrawColor(255, 255, 255, 5)
            surface.SetTexture(self.StaticTexture)
            surface.DrawTexturedRect(0, 0, w, h)
            
            draw.SimpleText("SURVEILLANCE MODE", "BudgetLabel", w / 2, 10, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER)
            draw.SimpleText("DISTANCE: " .. math.Round(LocalPlayer():GetPos():Distance(probePos)) .. " UNITS", "BudgetLabel", w / 2, h - 20, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER)
            
            local time = CurTime() % 60
            local timeStr = string.format("%02d:%02d", math.floor(time / 60), math.floor(time % 60))
            draw.SimpleText(timeStr, "BudgetLabel", 30, 10, Color(255, 255, 255, 200), TEXT_ALIGN_LEFT)
            
            local centerSize = 5
            surface.SetDrawColor(255, 255, 255, 200)
            surface.DrawLine(w / 2 - centerSize, h / 2, w / 2 + centerSize, h / 2)
            surface.DrawLine(w / 2, h / 2 - centerSize, w / 2, h / 2 + centerSize)
            
            surface.DrawOutlinedRect(w / 2 - 100, h / 2 - 100, 200, 200)
            
            if math.random(1, 100) == 1 then
                surface.SetDrawColor(255, 255, 255, math.random(10, 50))
                surface.DrawRect(0, 0, w, h)
            end
            
            if math.random(1, 500) == 1 then
                local glitchHeight = math.random(5, 20)
                local glitchY = math.random(0, h - glitchHeight)
                surface.SetDrawColor(255, 255, 255, 200)
                surface.DrawRect(0, glitchY, w, glitchHeight)
            end
        end
    end
    
    function SWEP:CalcViewModelView(vm, oldPos, oldAng, pos, ang)
        if probeActive then
            return Vector(0, 0, -10000), ang
        end
    end
end
SWEP.Category = "Bloodshed - Police"