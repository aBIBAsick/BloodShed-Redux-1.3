AddCSLuaFile()

SWEP.Base = "mur_loot_base"
SWEP.Category = "Bloodshed - Civilian"
SWEP.Spawnable = true
SWEP.DisableSuicide = true

SWEP.PrintName = "Fire Extinguisher"
SWEP.DrawWeaponInfoBox = false

SWEP.Slot = 4
SWEP.SlotPos = 5
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.HoldType = "ar2"
SWEP.WorldModelPosition = Vector(3, -2, -2)
SWEP.WorldModelAngle = Angle(180, 0, 0)
SWEP.ViewModelPos = Vector(0, 0, 0)
SWEP.ViewModelAng = Angle(0, 0, 0)
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/murdered/weapons/v_tool_extinguisher.mdl"
SWEP.WorldModel = "models/murdered/weapons/w_tool_extinguisher.mdl"
SWEP.TPIKForce = true
SWEP.TPIKPos = Vector(-12,0,4)

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Thumper"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

local EXTINGUISH_RANGE = 200
local EXTINGUISH_RADIUS = 32
local SPRAY_COST = 1
local EXTINGUISH_CHANCE = 50

local SpraySound = Sound("weapons/tools/fire_extinguisher/fire_extinguisger_startloop.wav")
local EmptySound = Sound("weapons/tools/fire_extinguisher/fire_extinguisger_lever.wav")

if SERVER then
    util.AddNetworkString("ExtinguisherBlur")
end

function SWEP:CustomInit()
    self:SetHoldType(self.HoldType)
    self.Spraying = false
    self.SprayLoop = nil
    self.LastSprayState = false
end

function SWEP:PlayAnim(name)
    local vm = self:GetOwner():GetViewModel()
    if not IsValid(vm) then return end
    
    local seq = vm:LookupSequence(name)
    if seq and seq > 0 then
        vm:SendViewModelMatchingSequence(seq)
    end
end

function SWEP:Deploy()
    self:PlayAnim("hoseequip")
    self:SetHoldType(self.HoldType)
    self:SetNextPrimaryFire(CurTime() + 1)
    return true
end

function SWEP:CustomPrimaryAttack()
    if self:Clip1() <= 0 then
        if SERVER and (not self.LastEmptySound or self.LastEmptySound < CurTime()) then
            self.Owner:EmitSound(EmptySound, 60, 100)
            self.LastEmptySound = CurTime() + 0.5
        end
        return
    end
    
    self:SetNextPrimaryFire(CurTime() + 0.1)
    self:TakePrimaryAmmo(SPRAY_COST)
    
    -- Start spray sound
    if SERVER then
        self.SprayLoop = self.SprayLoop or CreateSound(self, SpraySound)
        if not self.SprayLoop:IsPlaying() then
            self.SprayLoop:Play()
            self.SprayLoop:ChangeVolume(0.7)
            self.SprayLoop:ChangePitch(120)
        end
    end
    
    -- Play spray animation if just started
    if not self.LastSprayState then
        self:PlayAnim("hosespray")
        self.LastSprayState = true
    end
    
    self.Spraying = true
    
    -- Trace for target
    local owner = self:GetOwner()
    local tr = util.TraceLine({
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * EXTINGUISH_RANGE,
        filter = owner
    })
    
    -- Spray effect
    local effectData = EffectData()
    effectData:SetOrigin(tr.HitPos)
    effectData:SetNormal(tr.HitNormal)
    effectData:SetScale(1)
    util.Effect("WheelDust", effectData)
    
    -- Leave foam decal on surfaces
    if tr.Hit then
        util.Decal("PaintSplatPink", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
    end
    
    if CLIENT then return end
    
    -- Extinguish fires in radius
    local hitPos = tr.HitPos
    
    -- Find and extinguish VFire (with chance)
    for _, fire in ipairs(ents.FindByClass("vfire")) do
        if IsValid(fire) and fire:GetPos():DistToSqr(hitPos) < EXTINGUISH_RADIUS * EXTINGUISH_RADIUS then
            if math.random(1, 100) <= EXTINGUISH_CHANCE then
                fire:Remove()
            end
        end
    end
    
    -- Find and extinguish _vfire (with chance)
    for _, fire in ipairs(ents.FindByClass("_vfire")) do
        if IsValid(fire) and fire:GetPos():DistToSqr(hitPos) < EXTINGUISH_RADIUS * EXTINGUISH_RADIUS then
            if math.random(1, 100) <= EXTINGUISH_CHANCE then
                fire:Remove()
            end
        end
    end
    
    -- Find and extinguish env_fire (with chance)
    for _, fire in ipairs(ents.FindByClass("env_fire")) do
        if IsValid(fire) and fire:GetPos():DistToSqr(hitPos) < EXTINGUISH_RADIUS * EXTINGUISH_RADIUS then
            if math.random(1, 100) <= EXTINGUISH_CHANCE then
                fire:Fire("Extinguish")
            end
        end
    end
    
    -- Find and extinguish molotov fire zones (with chance)
    for _, fire in ipairs(ents.FindByClass("bloodshed_molotov_fire")) do
        if IsValid(fire) and fire:GetPos():DistToSqr(hitPos) < (EXTINGUISH_RADIUS * 2) * (EXTINGUISH_RADIUS * 2) then
            if math.random(1, 100) <= EXTINGUISH_CHANCE then
                SafeRemoveEntity(fire)
            end
        end
    end
    
    -- Extinguish entities on fire (with chance)
    for _, ent in ipairs(ents.FindInSphere(hitPos, EXTINGUISH_RADIUS)) do
        if IsValid(ent) and ent:IsOnFire() then
            if math.random(1, 100) <= EXTINGUISH_CHANCE then
                ent:Extinguish()
            end
        end
    end
    
    -- Cool down hit entity
    if IsValid(tr.Entity) and tr.Entity:IsOnFire() then
        tr.Entity:Extinguish()
    end
    
    -- Damage players and living ragdolls hit by spray
    local hitEnt = tr.Entity
    if IsValid(hitEnt) then
        -- Direct hit on player
        if hitEnt:IsPlayer() and hitEnt:Alive() then
            if math.random(1,5) == 1 then
                hitEnt.RandomPlayerSound = 0
                hitEnt:MakeRandomSound(tobool(math.random(0,1)))
                hitEnt:ViewPunch(AngleRand(-10,10))
            end
            
            -- Apply blur effect (accumulative)
            hitEnt.ExtinguisherBlurAmount = (hitEnt.ExtinguisherBlurAmount or 0) + 0.1
            hitEnt.ExtinguisherBlurAmount = math.min(hitEnt.ExtinguisherBlurAmount, 10) -- Max 10 seconds
            
            net.Start("ExtinguisherBlur")
            net.WriteFloat(hitEnt.ExtinguisherBlurAmount)
            net.Send(hitEnt)
        end
        
        -- Direct hit on living ragdoll (active ragdoll with owner)
        if hitEnt:GetClass() == "prop_ragdoll" and hitEnt.isRDRag and IsValid(hitEnt.Owner) and hitEnt.Owner:Alive() then
            if math.random(1,5) == 1 then
                hitEnt.Owner.RandomPlayerSound = 0
                hitEnt.Owner:MakeRandomSound(tobool(math.random(0,1)))
                hitEnt.Owner:ViewPunch(AngleRand(-10,10))
            end
            
            -- Apply blur effect to ragdoll owner (accumulative)
            hitEnt.Owner.ExtinguisherBlurAmount = (hitEnt.Owner.ExtinguisherBlurAmount or 0) + 0.1
            hitEnt.Owner.ExtinguisherBlurAmount = math.min(hitEnt.Owner.ExtinguisherBlurAmount, 10)
            
            net.Start("ExtinguisherBlur")
            net.WriteFloat(hitEnt.Owner.ExtinguisherBlurAmount)
            net.Send(hitEnt.Owner)
        end
    end
end

function SWEP:Think()
    local isSpraying = self.Owner:KeyDown(IN_ATTACK) and self:Clip1() > 0
    
    -- Stop spray sound when not firing
    if SERVER and self.SprayLoop then
        if not isSpraying then
            self.SprayLoop:Stop()
        end
    end
    
    -- Handle animation transitions
    if self.LastSprayState and not isSpraying then
        -- Stopped spraying, go back to idle
        self:PlayAnim("hoseidle")
        self.LastSprayState = false
    end
    
    self.Spraying = isSpraying
end

function SWEP:Holster()
    if SERVER and self.SprayLoop then
        self.SprayLoop:Stop()
    end
    self.Spraying = false
    self.LastSprayState = false
    self:PlayAnim("hoseholster")
    return true
end

function SWEP:OnRemove()
    if SERVER and self.SprayLoop then
        self.SprayLoop:Stop()
    end
end

function SWEP:CustomSecondaryAttack()
    -- No secondary attack
end

-- Spray particle effect on client
if CLIENT then
    local sprayMat = Material("particle/particle_smokegrenade")
    
    hook.Add("PostDrawOpaqueRenderables", "ExtinguisherSpray", function()
        for _, ply in player.Iterator() do
            if not IsValid(ply) then continue end
            
            local wep = ply:GetActiveWeapon()
            if not IsValid(wep) or wep:GetClass() ~= "mur_extinguisher" then continue end
            if not wep.Spraying then continue end
            
            local attach = ply:GetAttachment(ply:LookupAttachment("anim_attachment_RH"))
            if not attach then continue end
            
            local startPos = attach.Pos + ply:GetAimVector() * 10
            local endPos = startPos + ply:GetAimVector() * EXTINGUISH_RANGE
            
            local tr = util.TraceLine({
                start = ply:GetShootPos(),
                endpos = ply:GetShootPos() + ply:GetAimVector() * EXTINGUISH_RANGE,
                filter = ply
            })
            
            endPos = tr.HitPos
            
            -- Spray particles
            local emitter = ParticleEmitter(startPos)
            if emitter then
                for i = 1, 3 do
                    local dir = (endPos - startPos):GetNormalized()
                    dir = dir + VectorRand() * 0.1
                    
                    local particle = emitter:Add("particles/smokey", startPos + dir * math.random(10, 50))
                    if particle then
                        particle:SetVelocity(dir * math.random(300, 500))
                        particle:SetLifeTime(0)
                        particle:SetDieTime(math.Rand(0.3, 0.5))
                        particle:SetStartAlpha(5)
                        particle:SetEndAlpha(0)
                        particle:SetStartSize(math.Rand(5, 10))
                        particle:SetEndSize(math.Rand(20, 40))
                        particle:SetColor(255, 255, 255)
                        particle:SetGravity(Vector(0, 0, -50))
                        particle:SetAirResistance(100)
                    end
                end
                emitter:Finish()
            end
        end
    end)
end

function SWEP:DrawHUD()
    local ply = self:GetOwner()
    local ammo = self:Clip1()
    local maxAmmo = self.Primary.ClipSize
    
    local w, h = ScrW(), ScrH()
    local barW = w * 0.15
    local barH = h * 0.012
    local barX = w - barW - 20
    local barY = h - barH - 20
    
    -- Background
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(barX - 2, barY - 2, barW + 4, barH + 4)
    
    -- Border
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawOutlinedRect(barX - 2, barY - 2, barW + 4, barH + 4)
    
    -- Fill (blue for extinguisher)
    local fillW = (ammo / maxAmmo) * barW
    surface.SetDrawColor(100, 180, 255, 255)
    surface.DrawRect(barX, barY, fillW, barH)
    
    -- Percentage text
    draw.SimpleText(math.floor(ammo) .. "%", "MuR_Font1", barX + barW / 2, barY - 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end

-- Client-side blur effect from extinguisher
if CLIENT then
    local blurMat = Material("pp/blurscreen")
    local blurAmount = 0 -- Current blur intensity (0-10)
    local blurDecayRate = 1 -- How fast blur fades per second
    
    net.Receive("ExtinguisherBlur", function()
        local amount = net.ReadFloat()
        blurAmount = math.max(blurAmount, amount) -- Take the higher value
    end)
    
    hook.Add("RenderScreenspaceEffects", "ExtinguisherBlurEffect", function()
        if blurAmount <= 0 then return end
        
        -- Decay blur over time
        blurAmount = blurAmount - FrameTime() * blurDecayRate
        blurAmount = math.max(blurAmount, 0)
        
        local intensity = math.Clamp(blurAmount / 10, 0, 1) -- Normalize to 0-1
        
        -- Blur effect (stronger with more intensity)
        surface.SetMaterial(blurMat)
        surface.SetDrawColor(255, 255, 255, 255)
        
        local blurPasses = math.ceil(intensity * 5) -- More passes = more blur
        for i = 1, blurPasses do
            blurMat:SetFloat("$blur", intensity * 8)
            blurMat:Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        end
        
        -- White overlay (foam on screen)
        surface.SetDrawColor(255, 255, 255, intensity * 200)
        surface.DrawRect(0, 0, ScrW(), ScrH())
    end)
end
