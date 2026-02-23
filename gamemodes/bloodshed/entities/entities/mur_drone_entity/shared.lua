ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.PrintName = "Suicide Drone"
ENT.Spawnable = true 
ENT.AutomaticFrameAdvance = true

ENT.BatteryCount = 60
ENT.HealthCount = 60

if CLIENT then
    local function LoseDrone()
    surface.PlaySound("ambient/levels/prison/radio_random"..math.random(1,15)..".wav")
        hook.Add("HUDPaint", "DroneCamLost", function()
            if !LocalPlayer():Alive() then return end
            surface.SetDrawColor(40,40,40,255)
            surface.DrawRect(0, 0, ScrW(), ScrH())

            for i=1,100 do
                local posx = math.random(-ScrW(),ScrW())
                local posy = math.random(-ScrH(),ScrH())
                local size = math.random(100,600)
                surface.SetDrawColor(20,20,20,255)
                surface.DrawRect(posx, posy, size, size/math.random(5,10))
            end

            draw.SimpleText("NO SIGNAL", "MuR_Font6", ScrW()/2, ScrH()/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end)
        timer.Simple(2, function()
            hook.Remove("HUDPaint", "DroneCamLost")
        end)
    end
    net.Receive("MuR_DroneLost", LoseDrone)

    net.Receive("MuR_DroneCam", function()
        local ent = net.ReadEntity()
        local alpha = 0
        local downa = false
        local lastBattBeep = 0
        local lastDmgBeep = 0
        local tab = {
            [ "$pp_colour_addr" ] = 0,
            [ "$pp_colour_addg" ] = 0,
            [ "$pp_colour_addb" ] = 0,
            [ "$pp_colour_brightness" ] = -0.02,
            [ "$pp_colour_contrast" ] = 1.25,
            [ "$pp_colour_colour" ] = 0.55,
            [ "$pp_colour_mulr" ] = 0,
            [ "$pp_colour_mulg" ] = 0,
            [ "$pp_colour_mulb" ] = 0
        }
        
        hook.Add("RenderScreenspaceEffects", "DroneCam", function()
            DrawColorModify(tab)
        end)

    hook.Add("HUDPaint", "DroneCam", function()
            local sw, sh = ScrW(), ScrH()
            -- cinematic frame
            surface.SetDrawColor(255,255,255,180)
            surface.DrawOutlinedRect(50, 50, sw-100, sh-100, 2)
            -- center crosshair
            surface.SetDrawColor(255,255,255,220)
            surface.DrawRect(sw/2-15, sh/2-1, 30, 2)
            surface.DrawRect(sw/2-1, sh/2-16, 2, 30)

            --------------------------------------------------------------------------------
            draw.SimpleText("✷ FPV DRONE", "MuR_Font4", 100, 80, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText("CONTROLS", "MuR_Font3", 100, 110, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            draw.SimpleText("LMB — BOOST", "MuR_Font2", sw-100, sh-220, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            draw.SimpleText("SHIFT / CTRL — ALTITUDE", "MuR_Font2", sw-100, sh-190, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            if ent:GetPos():DistToSqr(LocalPlayer():GetPos()) < 50000 then
                draw.SimpleText("R — DISARM", "MuR_Font2", sw-100, sh-250, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            else
                draw.SimpleText("TOO FAR TO DISARM", "MuR_Font2", sw-100, sh-250, Color(200,200,0), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            end

            if downa then
                alpha = alpha - FrameTime()*512
                if alpha <= 0 then
                    downa = false
                end
            else
                alpha = alpha + FrameTime()*512
                if alpha >= 255 then
                    downa = true
                end
            end
            --------------------------------------------------------------------------------

            -- telemetry
            local timeLeft = math.max(ent:GetNW2Float('RemoveTime')-CurTime(), 0)
            local battFrac = math.Clamp(timeLeft/ent.BatteryCount, 0, 1)
            local hpFrac = math.Clamp(ent:Health()/ent.HealthCount, 0, 1)
            local cx, cy = sw-100, 120

            -- battery bar
            local battCol = Color(95,220,255)
            if battFrac < 0.2 then battCol = Color(255,90,60) elseif battFrac < 0.4 then battCol = Color(255,200,60) end
            surface.SetDrawColor(battCol)
            surface.DrawRect(75, sh-220, 300*battFrac, 15)
            surface.SetDrawColor(255,255,255,200)
            surface.DrawOutlinedRect(75, sh-220, 300, 15, 2)
            draw.SimpleText(string.format("BATTERY %d%%", math.Round(battFrac*100)), "MuR_Font2", 75, sh-250, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            -- health bar
            local hpCol = Color(120,255,120)
            if hpFrac < 0.3 then hpCol = Color(255,60,80) elseif hpFrac < 0.6 then hpCol = Color(255,200,60) end
            surface.SetDrawColor(hpCol)
            surface.DrawRect(75, sh-120, 300*hpFrac, 15)
            surface.SetDrawColor(255,255,255,200)
            surface.DrawOutlinedRect(75, sh-120, 300, 15, 2)
            draw.SimpleText("INTEGRITY", "MuR_Font2", 75, sh-150, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            -- speed / altitude / signal
            local vel = ent:GetVelocity():Length()
            local spd = math.Round(vel * 0.068) -- u/s -> km/h approx in Source scale
            local tr = util.TraceLine({start = ent:GetPos(), endpos = ent:GetPos() - Vector(0,0,10000), filter = ent})
            local agl = math.Round(ent:GetPos().z - tr.HitPos.z)
            local dist2 = LocalPlayer():GetPos():DistToSqr(ent:GetPos())
            local signal = math.Clamp(1 - (dist2 / (3000*3000)), 0, 1)
            local sigText = string.format("SIGNAL %d%%", math.Round(signal*100))
            local sigCol = signal < 0.25 and Color(255,80,60) or (signal < 0.5 and Color(255,200,60) or Color(120,255,120))

            draw.SimpleText("SPD "..spd.." km/h", "MuR_Font3", sw-100, 110, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            draw.SimpleText("ALT "..agl.." m", "MuR_Font3", sw-100, 140, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            draw.SimpleText(sigText, "MuR_Font3", sw-100, 170, sigCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

            -- warnings
            if battFrac < 0.15 then
                draw.SimpleText("LOW BATTERY", "MuR_Font5", sw/2, 90, Color(255,80,60), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                if CurTime() > lastBattBeep then
                    surface.PlaySound("buttons/blip1.wav")
                    lastBattBeep = CurTime() + 1.25
                end
            end
            if hpFrac < 0.25 then
                draw.SimpleText("STRUCTURE DAMAGED", "MuR_Font5", sw/2, 130, Color(255,200,60), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                if CurTime() > lastDmgBeep then
                    surface.PlaySound("ambient/alarms/klaxon1.wav")
                    lastDmgBeep = CurTime() + 3
                end
            end
        end)

        hook.Add("CreateMove", "DroneCam", function(cmd)
            cmd:SetForwardMove(0)
            cmd:SetSideMove(0)
            cmd:RemoveKey(IN_JUMP)
            cmd:RemoveKey(IN_USE)
        end)

    hook.Add("CalcView", "DroneCam", function( ply, pos, angles, fov )
            if IsValid(ent) then
        -- slightly behind and below drone to see body; align to entity angles for realistic banking
        local pos1 = ent:GetPos() - ent:GetUp()*1.5 - ent:GetForward()*5
        local ang1 = ent:GetAngles()
        -- subtle camera bob
        ang1.r = ang1.r + math.sin(CurTime()*2)*0.5
        -- dynamic fov with speed
        local spd = ent:GetVelocity():Length()
        local dfov = math.Clamp(spd*0.02, 0, 10)
                local view = {
                    origin = pos1,
                    angles = ang1,
            fov = math.Clamp(fov + dfov, 70, 110),
                    drawviewer = true
                }
            
                return view
            else
                hook.Remove("CalcView", "DroneCam")
                hook.Remove("CreateMove", "DroneCam")
                hook.Remove("RenderScreenspaceEffects", "DroneCam")
                hook.Remove("HUDPaint", "DroneCam")
            end
        end)
    end)
end
