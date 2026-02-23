AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Flashbang"
ENT.Spawnable = false

-- Realistic M84 Stun Grenade parameters
local FLASH_RADIUS = 600           -- ~11 meters effective range
local FLASH_RADIUS_INDIRECT = 200  -- Range for indirect flash (through walls/not looking)
local FLASH_FUSE_TIME = 2       -- Fuse time in seconds
local MAX_FLASH_DURATION = 8     -- Maximum blindness duration (direct hit, looking at it)
local MIN_FLASH_DURATION = 2     -- Minimum flash duration
local DEAFEN_DURATION_MULT = 1.5   -- Deafen duration multiplier vs flash

local ExplodeSound = Sound(")weapons/cod2019/throwables/flashbang/flash_expl_02.ogg")

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
        
        self.FuseStart = CurTime()
        
        timer.Simple(FLASH_FUSE_TIME, function()
            if IsValid(self) then
                self:Explode()
            end
        end)
    end
end

-- Calculate flash intensity based on angle, distance, and visibility
function ENT:CalculateFlashEffect(target, pos)
    if not IsValid(target) then return 0, 0 end
    
    local targetPos = target:EyePos()
    local distance = pos:Distance(targetPos)
    
    -- Check if too far away
    if distance > FLASH_RADIUS then return 0, 0 end
    
    -- Base intensity from distance (1.0 at 0 distance, 0.0 at max radius)
    local distanceFactor = 1 - (distance / FLASH_RADIUS)
    
    -- Check line of sight
    local tr = util.TraceLine({
        start = pos,
        endpos = targetPos,
        filter = {self, target},
        mask = MASK_SOLID_BRUSHONLY
    })
    
    local hasLineOfSight = not tr.Hit
    
    -- If no line of sight, reduce effect significantly
    if not hasLineOfSight then
        if distance > FLASH_RADIUS_INDIRECT then return 0, 0 end
        distanceFactor = distanceFactor * 0.3 -- 30% effect through walls
    end
    
    -- Calculate view angle factor (looking at flash = more effect)
    local eyeAngles = target:EyeAngles()
    local dirToFlash = (pos - targetPos):GetNormalized()
    local lookDir = eyeAngles:Forward()
    
    -- Dot product: 1 = looking directly at, -1 = looking away, 0 = perpendicular
    local dotProduct = lookDir:Dot(dirToFlash)
    
    -- Convert to 0-1 scale (0 = looking away, 1 = looking at)
    -- Players facing away get only 20% of the effect
    local viewFactor = math.Clamp((dotProduct + 1) / 2, 0.2, 1.0)
    
    -- If looking directly away, minimal effect
    if dotProduct < -0.5 then
        viewFactor = 0.15
    end
    
    -- Final intensity
    local intensity = distanceFactor * viewFactor
    intensity = math.Clamp(intensity, 0, 1)
    
    -- Duration based on intensity
    local duration = Lerp(intensity, MIN_FLASH_DURATION, MAX_FLASH_DURATION)
    
    return intensity, duration
end

function ENT:Explode()
    if not IsValid(self) then return end
    
    local pos = self:GetPos()
    
    -- Visual effect at explosion point
    local effect = EffectData()
    effect:SetOrigin(pos)
    effect:SetNormal(Vector(0, 0, 1))
    effect:SetMagnitude(8)
    effect:SetScale(1)
    util.Effect("AR2Impact", effect)
    util.Effect("cball_explode", effect)
    
    -- Explosion sound
    self:EmitSound(ExplodeSound, 140, 100, 1)
    
    -- Broadcast flash light effect to all clients
    net.Start("FlashbangEffect")
    net.WriteBool(false) -- Not a player effect, just visual
    net.WriteVector(pos)
    net.Broadcast()
    
    -- Affect players
    for _, ply in player.Iterator() do
        if not IsValid(ply) or not ply:Alive() then continue end
        
        local intensity, duration = self:CalculateFlashEffect(ply, pos)
        
        if intensity > 0.1 then
            -- Send flash effect to player
            net.Start("FlashbangEffect")
            net.WriteBool(true) -- Player effect
            net.WriteFloat(intensity)
            net.WriteFloat(duration)
            net.Send(ply)
            
            -- Deafen effect (DSP)
            local deafenDuration = duration * DEAFEN_DURATION_MULT
            if intensity > 0.3 then
                ply:SetDSP(31)
                timer.Simple(deafenDuration, function()
                    if IsValid(ply) then
                        ply:SetDSP(0)
                    end
                end)
            end
            
            -- Disorientation (camera shake)
            if intensity > 0.5 then
                local shake = intensity * 5
                ply:ViewPunch(Angle(
                    math.random(-shake, shake),
                    math.random(-shake, shake),
                    math.random(-shake * 0.5, shake * 0.5)
                ))
            end
        end
    end
    
    -- Affect NPCs
    for _, npc in ipairs(ents.FindByClass("npc_*")) do
        if not IsValid(npc) or npc:Health() <= 0 then continue end
        
        local distance = pos:Distance(npc:GetPos())
        if distance > FLASH_RADIUS then continue end
        
        -- Check visibility
        local vis = npc:Visible(self)
        if not vis and distance > FLASH_RADIUS_INDIRECT then continue end
        
        local intensity = 1 - (distance / FLASH_RADIUS)
        if not vis then intensity = intensity * 0.3 end
        
        if intensity > 0.3 then
            -- Stun NPC
            if npc.SetSchedule then
                npc:SetSchedule(SCHED_COMBAT_FACE)
            end
            
            -- For VJ suspects, trigger surrender
            if npc:GetClass() == "npc_vj_bloodshed_suspect" and intensity > 0.5 then
                if npc.FullSurrender then
                    npc:FullSurrender()
                end
            end
            
            -- MODE 18 ZOMBIE EFFECT: Stun for 10 seconds + 50% HP damage
            if MuR and MuR.Gamemode == 18 and npc.IsMode18Zombie then
                -- Deal 50% HP damage
                local dmg = npc:Health() * 0.5
                npc:TakeDamage(dmg, self:GetOwner(), self)
                
                -- Stun zombie for 10 seconds using VJ-compatible methods
                npc.Mode18Stunned = true
                npc.Mode18StunEnd = CurTime() + 10
                
                -- VJ NPC specific stun methods
                if npc.VJ_IsBeingControlled then
                    -- Already controlled, skip
                elseif npc.SetEnemy then
                    npc:SetEnemy(nil)
                end
                
                -- Stop movement
                if npc.StopMoving then
                    npc:StopMoving()
                end
                
                -- Set schedule to idle
                if npc.SetSchedule then
                    npc:SetSchedule(SCHED_IDLE_STAND)
                end
                
                -- Store original movespeed and set to 0
                npc.Mode18OrigMoveSpeed = npc.AnimTbl_Walk or 0
                npc.Mode18OrigRunSpeed = npc.AnimTbl_Run or 0
                
                -- Freeze using velocity and physics
                local phys = npc:GetPhysicsObject()
                if IsValid(phys) then
                    phys:SetVelocity(Vector(0,0,0))
                end
                npc:SetVelocity(Vector(0,0,0))
                
                -- VJ specific: disable AI temporarily
                if npc.VJ_AddCalmWalkType then
                    npc.Behaviour = VJ_BEHAVIOR_PASSIVE
                end
                
                -- Visual indicator
                npc:SetColor(Color(100, 100, 255, 255))
                
                -- Create a think hook to keep them frozen
                local uniqueID = "Mode18FlashStun_" .. npc:EntIndex()
                hook.Add("Think", uniqueID, function()
                    if not IsValid(npc) then
                        hook.Remove("Think", uniqueID)
                        return
                    end
                    
                    if CurTime() < npc.Mode18StunEnd then
                        -- Keep zombie frozen
                        npc:SetVelocity(Vector(0,0,0))
                        if npc.StopMoving then npc:StopMoving() end
                        if npc.SetSchedule then npc:SetSchedule(SCHED_IDLE_STAND) end
                    else
                        -- Unfreeze
                        npc.Mode18Stunned = false
                        npc:SetColor(Color(255, 255, 255, 255))
                        if npc.VJ_AddCalmWalkType then
                            npc.Behaviour = VJ_BEHAVIOR_AGGRESSIVE
                        end
                        hook.Remove("Think", uniqueID)
                    end
                end)
            end
        end
    end
    
    SafeRemoveEntityDelayed(self, 0.1)
end

if CLIENT then
    -- Flash state variables
    local flashAlpha = 0
    local flashStartTime = 0
    local flashEndTime = 0
    local flashDuration = 0
    local flashIntensity = 0
    local flashPeakHold = 0
    
    -- Distortion variables
    local chromaticOffset = 0
    local wobblePhase = 0
    local grainIntensity = 0
    
    -- Aftereffect variables (persist after main flash)
    local afterBlur = 0
    local afterBlurEndTime = 0
    local nextRandomShake = 0
    local shakeIntensity = 0
    
    net.Receive("FlashbangEffect", function()
        local isPlayerEffect = net.ReadBool()
        
        if not isPlayerEffect then
            -- Just the visual flash at position
            local pos = net.ReadVector()
            
            -- Dynamic light for explosion
            local dlight = DynamicLight(0)
            if dlight then
                dlight.pos = pos
                dlight.r = 255
                dlight.g = 255
                dlight.b = 255
                dlight.brightness = 8
                dlight.decay = 2000
                dlight.size = 1500
                dlight.dietime = CurTime() + 0.8
            end
            
            -- Play distant sound if not already deafened
            if flashAlpha < 100 then
                surface.PlaySound("weapons/flashbang/flashbang_explode1.wav")
            end
            return
        end
        
        -- Player flash effect
        local intensity = net.ReadFloat()
        local duration = net.ReadFloat()
        
        flashIntensity = intensity
        flashDuration = duration
        flashStartTime = CurTime()
        flashEndTime = CurTime() + duration
        flashAlpha = 255 -- Start at full white
        flashPeakHold = duration * 0.4 -- Hold peak brightness for 40% of duration
        
        -- Initialize distortion effects
        chromaticOffset = intensity * 15
        wobblePhase = 0
        grainIntensity = intensity * 0.5
        
        -- Aftereffects (motion blur persists after flash ends)
        afterBlur = intensity * 0.7
        afterBlurEndTime = CurTime() + duration + 3 -- Blur lasts 3 seconds after flash
        shakeIntensity = intensity
        nextRandomShake = CurTime() + 0.1
        
        -- Play flash sound
        surface.PlaySound("weapons/flashbang/flashbang_explode1.wav")
        
        -- Ringing sound for strong flashes
        if intensity > 0.4 then
            surface.PlaySound("player/damage3.wav")
        end
        
        -- Initial screen shake
        if intensity > 0.3 then
            util.ScreenShake(EyePos(), intensity * 10, intensity * 6, duration * 0.5, 500)
        end
    end)
    
    -- Render the flash overlay
    hook.Add("HUDPaint", "FlashbangOverlay", function()
        -- Manage afterBlur first (must run even when main effect is done)
        if CurTime() < afterBlurEndTime then
            local afterTimeLeft = afterBlurEndTime - CurTime()
            local afterProgress = afterTimeLeft / 3
            afterBlur = flashIntensity * 0.5 * afterProgress
        else
            afterBlur = math.max(0, afterBlur - FrameTime() * 0.5)
        end
        
        -- Early exit if no effects active
        if flashAlpha <= 0 and chromaticOffset <= 0 and afterBlur <= 0.01 then return end
        
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then
            flashAlpha = 0
            chromaticOffset = 0
            grainIntensity = 0
            afterBlur = 0
            return
        end
        
        local timeElapsed = CurTime() - flashStartTime
        local timeLeft = flashEndTime - CurTime()
        
        if timeLeft <= 0 then
            -- Fade out quickly after duration ends
            flashAlpha = math.max(0, flashAlpha - FrameTime() * 300)
            chromaticOffset = math.max(0, chromaticOffset - FrameTime() * 15)
            grainIntensity = math.max(0, grainIntensity - FrameTime() * 0.3)
        else
            -- Phase 1: Peak hold (full white)
            if timeElapsed < flashPeakHold then
                flashAlpha = 255
            else
                -- Phase 2: Gradual fade with pulsing
                local fadeTime = flashDuration - flashPeakHold
                local fadeProgress = (timeElapsed - flashPeakHold) / fadeTime
                
                -- Pulsing effect during fade
                local pulse = math.sin(timeElapsed * 3) * 0.1 + 0.9
                
                -- Non-linear fade (slower at start, faster at end)
                local fadeCurve = 1 - (fadeProgress * fadeProgress)
                flashAlpha = 255 * fadeCurve * flashIntensity * pulse
            end
            
            -- Slowly reduce distortions
            local distortFade = timeLeft / flashDuration
            chromaticOffset = flashIntensity * 15 * distortFade
            grainIntensity = flashIntensity * 0.5 * distortFade
        end
        
        -- Update wobble
        wobblePhase = wobblePhase + FrameTime() * 8
        
        local w, h = ScrW(), ScrH()
        
        -- Draw main white flash
        if flashAlpha > 0 then
            -- Core white flash
            surface.SetDrawColor(255, 255, 255, math.min(255, flashAlpha))
            surface.DrawRect(0, 0, w, h)
            
            -- Slight yellow/orange tint as it fades (afterimage effect)
            if flashAlpha < 200 and flashAlpha > 10 then
                local tintAlpha = (200 - flashAlpha) * 0.4
                surface.SetDrawColor(255, 240, 180, tintAlpha)
                surface.DrawRect(0, 0, w, h)
            end
            
            -- Very faint purple afterimage at low alpha
            if flashAlpha < 80 and flashAlpha > 5 then
                local purpleAlpha = (80 - flashAlpha) * 0.3
                surface.SetDrawColor(200, 180, 255, purpleAlpha)
                surface.DrawRect(0, 0, w, h)
            end
        end
        
        -- Film grain effect
        if grainIntensity > 0.01 then
            local grainAlpha = grainIntensity * 80
            for i = 1, math.floor(grainIntensity * 150) do
                local gx = math.random(0, w)
                local gy = math.random(0, h)
                local gs = math.random(1, 3)
                local gc = math.random(200, 255)
                surface.SetDrawColor(gc, gc, gc, grainAlpha)
                surface.DrawRect(gx, gy, gs, gs)
            end
        end
    end)
    
    -- Random screen shake during disorientation
    hook.Add("Think", "FlashbangRandomShake", function()
        if shakeIntensity <= 0.05 then return end
        
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then
            shakeIntensity = 0
            return
        end
        
        -- Decay shake intensity over time
        shakeIntensity = math.max(0, shakeIntensity - FrameTime() * 0.15)
        
        -- Random shake at intervals
        if CurTime() >= nextRandomShake then
            local shake = shakeIntensity * 4
            ply:SetEyeAngles(ply:EyeAngles() + Angle(
                math.Rand(-shake, shake),
                math.Rand(-shake, shake),
                0
            ))
            nextRandomShake = CurTime() + math.Rand(0.01, 0.1)
        end
    end)
    
    -- Advanced screen effects
    hook.Add("RenderScreenspaceEffects", "FlashbangEffects", function()
        local hasMainEffect = flashAlpha > 5 or chromaticOffset > 0.5
        local hasAfterEffect = afterBlur > 0.05
        
        if not hasMainEffect and not hasAfterEffect then return end
        
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return end
        
        local effectStrength = math.max(flashAlpha / 255, chromaticOffset / 15)
        local totalBlur = math.max(effectStrength, afterBlur)
        
        -- Strong motion blur (including aftereffect)
        if totalBlur > 0.05 then
            local blurAmount = totalBlur * 0.9
            DrawMotionBlur(0.15, blurAmount, 0.008)
        end
        
        -- Color modification (washed out, high contrast)
        if effectStrength > 0.1 then
            local tab = {
                ["$pp_colour_addr"] = effectStrength * 0.1,
                ["$pp_colour_addg"] = effectStrength * 0.1,
                ["$pp_colour_addb"] = effectStrength * 0.08,
                ["$pp_colour_brightness"] = effectStrength * 0.3,
                ["$pp_colour_contrast"] = 1 + effectStrength * 0.5,
                ["$pp_colour_colour"] = 1 - effectStrength * 0.6,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0,
            }
            DrawColorModify(tab)
        end
        
        -- Bloom effect
        if effectStrength > 0.2 then
            local bloom = effectStrength * 3
            DrawBloom(
                0.5,                    -- darken
                bloom * 2,              -- multiply
                effectStrength * 8,     -- sizex
                effectStrength * 8,     -- sizey
                3,                      -- passes
                effectStrength * 2,     -- colormul
                1,                      -- red
                1,                      -- green
                0.95                    -- blue
            )
        end
        
        -- Sharpen (creates uncomfortable visual)
        if effectStrength > 0.3 then
            DrawSharpen(effectStrength * 1.5, effectStrength * 0.8)
        end
        
        -- Sobel edge effect for disorientation at high intensity
        if effectStrength > 0.7 then
            local sobelAmount = (effectStrength - 0.7) / 0.3
            DrawSobel(sobelAmount * 0.3)
        end
    end)
    
    -- Camera wobble effect
    hook.Add("CalcView", "FlashbangWobble", function(ply, pos, angles, fov)
        if chromaticOffset <= 1 then return end
        
        local wobbleStrength = chromaticOffset / 15
        local wobble = math.sin(wobblePhase) * wobbleStrength * 2
        local wobble2 = math.cos(wobblePhase * 0.7) * wobbleStrength * 1.5
        
        local view = {
            origin = pos,
            angles = Angle(
                angles.p + wobble,
                angles.y + wobble2,
                angles.r + math.sin(wobblePhase * 1.3) * wobbleStrength
            ),
            fov = fov + wobbleStrength * 5,
            drawviewer = false
        }
        
        return view
    end)
end

if SERVER then
    util.AddNetworkString("FlashbangEffect")
end