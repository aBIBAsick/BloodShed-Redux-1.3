local ragent = nil
local TFAAimFrac = 0
local TP_Shoulder = 1 
local TP_ShoulderFrac = 1
local TP_LastCaps = false
local TP_CamDist = 80
local TP_LastCamPos = Vector(0,0,0)
local TP_LastCamAng = Angle(0,0,0)

local function LerpAngleFT(lerp,source,set)
	return LerpAngle(math.min(lerp * 0.5,1),source,set)
end

local function HideHead()
	local ent = LocalPlayer()
	ent:ManipulateBoneScale(ent:LookupBone("ValveBiped.Bip01_Head1"), Vector(0, 0, 0))
	timer.Create("headbackrag" .. ent:EntIndex(), 0.1, 1, function()
		if !IsValid(ent) then return end
		ent:ManipulateBoneScale(ent:LookupBone("ValveBiped.Bip01_Head1"), Vector(1, 1, 1))
	end)
end

local function LookupMuzzle(ent)
    local muz = ent:LookupAttachment('muzzle')
    if muz < 1 then
        muz = ent:LookupAttachment('1')
        if muz < 1 then
            return 0
        else
            return muz
        end
    else
        return muz
    end
end

net.Receive("MuR.CalcView", function()
	local ent = net.ReadEntity()
	LocalPlayer():SetNW2Entity('RD_EntCam', ent)
end)

local LerpEyeRagdoll = Angle(0,0,0)
local oldexecang = Angle(0,0,0)
local aimfrac = 0
hook.Add("CalcView", "zRD_CamWork", function(ply, pos, angles, fov)
	ragent = ply:GetNW2Entity('RD_EntCam')
	local ent = ragent
	local anim = ply:GetSVAnimation()

	if IsValid(ent) and !ent:IsPlayer() and MuR:GetClient("blsd_viewperson") != 2 then
		if ent:LookupBone("ValveBiped.Bip01_Head1") then
			ent:ManipulateBoneScale(ent:LookupBone("ValveBiped.Bip01_Head1"), Vector(0, 0, 0))
		end

		timer.Create("headbackrag" .. ent:EntIndex(), 0.1, 1, function()
			if not IsValid(ent) then return end

			if ent:LookupBone("ValveBiped.Bip01_Head1") then
				ent:ManipulateBoneScale(ent:LookupBone("ValveBiped.Bip01_Head1"), Vector(1, 1, 1))
			end
		end)

		local t = ent:GetAttachment(ent:LookupAttachment("eyes"))

		if istable(t) then
			local oldang = t.Ang
			if ply:Alive() then
				LerpEyeRagdoll = t.Ang
			else
				LerpEyeRagdoll = oldang
			end

			t.Pos = LocalToWorld(Vector(0, 0, 0), t.Ang, t.Pos, t.Ang)

			local view = {
				origin = t.Pos + Vector(0, 0, 2),
				angles = LerpEyeRagdoll,
				fov = fov,
				drawviewer = false,
				znear = 1
			}

			return view
		end
	end

	if (string.match(anim, "mur_") or string.match(anim, "execution") or string.match(anim, "sequence_ron_")) and MuR:GetClient("blsd_viewperson") != 2 then
		if ply:IsExecuting() and MuR:GetClient("blsd_execution_3rd_person") then return end
		local t = ply:GetAttachment(ply:LookupAttachment("eyes"))
		local cpos, cang, cfov = t.Pos, t.Ang, fov
		local distvis = 1

		local an = ply:GetNW2Entity("AnimCamera")
		if IsValid(an) then
			local t = an:GetAttachment(an:LookupAttachment("custom_eyes"))
			if oldexecang:IsZero() then
				oldexecang = t.Ang
			end
			oldexecang = LerpAngle(0.2, oldexecang, t.Ang)
			cpos = t.Pos
			if string.match(anim, "victim_") then
				cpos = cpos + oldexecang:Forward()*4 + Vector(0,0,2)
			end
			cang = oldexecang
		end

		if istable(t) then
			local view = {
				origin = cpos,
				angles = cang,
				fov = cfov,
				drawviewer = true,
				znear = distvis
			}
			HideHead()
			ply.LastFPAng = cang
			return view
		end
	else
		oldexecang = Angle(0,0,0)
	end

	local na = ply.LastFPAng
	if isangle(na) then
		ply:SetEyeAngles(Angle(na.x, na.y, 0))
		ply.LastFPAng = nil
	end
	
	if MuR:GetClient("blsd_viewperson") == 1 and ply:Alive() then
		local hm = ply:GetAttachment(ply:LookupAttachment("eyes"))

		local wep = ply:GetActiveWeapon()
		local isTFA = IsValid(wep) and wep.IsTFAWeapon
		local targetFrac = (isTFA and ply:TPIK_IsAiming()) and 1 or 0
		TFAAimFrac = math.Approach(TFAAimFrac, targetFrac, FrameTime() * 12)

		local tp = ply:GetEyeTrace().HitPos
		local lpos = hm.Pos-hm.Ang:Up()*2+hm.Ang:Forward()*2
		local lang = (tp-hm.Pos):GetNormalized():Angle()
		if true or angles.x > 55 then
			lang = angles
		end
		if TFAAimFrac > 0.2 then
			return 
		end

		HideHead()
		local view = {
			origin = lpos,
			angles = lang,
			fov = fov,
			drawviewer = true,
			znear = 1
		}

		return view
	elseif MuR:GetClient("blsd_viewperson") == 2 and ply:Alive() then
		local tar = IsValid(ply:GetRD()) and ply:GetRD() or ply
		local plyeye = tar:GetAttachment(tar:LookupAttachment("eyes"))
		if not istable(plyeye) then return end

		local caps = input.IsKeyDown(KEY_CAPSLOCK)
		if caps and not TP_LastCaps then
			TP_Shoulder = -TP_Shoulder
		end
		TP_LastCaps = caps

		local frt = FrameTime()*32

		local shoulderTarget = TP_Shoulder
		TP_ShoulderFrac = Lerp(frt, TP_ShoulderFrac, shoulderTarget )

		local aimTarget = 0
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) and wep.IsTFAWeapon and ply:TPIK_IsAiming() then aimTarget = 1 end
		TFAAimFrac = math.Approach(TFAAimFrac, aimTarget, FrameTime() * 6)

		local basePos = plyeye.Pos
		local baseAng = plyeye.Ang

		local shoulderOffset = Vector(16 * TP_ShoulderFrac, 0 * TP_ShoulderFrac, -8)
		local camDist = Lerp( TFAAimFrac, 40, 15 )
		TP_CamDist = Lerp(FrameTime() * 8, TP_CamDist, camDist)

		local right = baseAng:Right()
		local forward = baseAng:Forward()
		local desiredPos = basePos + right * shoulderOffset.x + baseAng:Up() * shoulderOffset.z - forward * TP_CamDist

		local tr = util.TraceHull({
			start = basePos,
			endpos = desiredPos,
			filter = {ply},
			hull = Vector(8,8,8),
			mask = MASK_PLAYERSOLID,
			filter = function(ent)
				if ent:IsRagdoll() or ent == ply then return false end
				return true
			end
		})
		local finalPos = tr.Hit and tr.HitPos or desiredPos

		TP_LastCamPos = LerpVector(frt, TP_LastCamPos, finalPos)
		local eyeTr = ply:GetEyeTrace()
		local lookPos = (istable(eyeTr) and eyeTr.HitPos) or (basePos + forward * 1000)
		local desiredAng = (lookPos - TP_LastCamPos):GetNormalized():Angle()
		TP_LastCamAng = LerpAngle(frt, TP_LastCamAng, desiredAng)

		if TP_LastCamPos:DistToSqr(finalPos) < 100 then
			TP_LastCamPos = finalPos
		end

		local view = {
			origin = TP_LastCamPos,
			angles = TP_LastCamAng,
			fov = fov,
			drawviewer = true,
			znear = 1
		}

		if TFAAimFrac > 0.01 then
			local eyeTrA = ply:GetEyeTrace()
			local lookPosA = (istable(eyeTrA) and eyeTrA.HitPos) or (basePos + forward * 1000)
			local aimAng = (lookPosA - TP_LastCamPos):GetNormalized():Angle()
			view.angles = LerpAngle( math.min(FrameTime() * 12 * TFAAimFrac, 1), view.angles, aimAng )
		end

		return view
	elseif ply:Alive() then
		local hm = ply:GetAttachment(ply:LookupAttachment("eyes"))
		local nang = LerpAngle(aimfrac, angles, hm.Ang)
		if ply:TPIK_IsAiming() then
			aimfrac = math.Clamp(aimfrac-FrameTime(), 0, 0.2)
		else
			aimfrac = math.Clamp(aimfrac+FrameTime(), 0, 0.2)
		end

		local wep = ply:GetActiveWeapon()
		if IsValid(wep) and wep.IsTFAWeapon and wep.CalcView then
			local _, aa = ply:GetActiveWeapon():CalcView(ply, pos, nang, fov)
			nang = aa
		end

		local view = {
			origin = pos,
			angles = nang,
			fov = fov,
			drawviewer = false,
			znear = 1
		}

		return view
	end
end)

hook.Add("HUDPaint", "RD_CamWork", function()
	local ply = LocalPlayer()
	local ent = ply:GetNW2Entity('RD_EntCam')
	local time = ply:TimeGetUp() - CurTime() + 1
	local formattime = string.FormattedTime(time, "%02i:%02i")
	if !IsValid(ent) then
		return
	end

	if IsValid(ent) and ply:Alive() and !MuR:GetClient("blsd_ragdoll_nohud") and !ply:GetNW2Bool("IsUnconscious", false) then
		if time > 999 then
			local parsed = markup.Parse("<font=MuR_Font3><colour=200,20,20>"..MuR.Language["ragdoll_heavy"])
			parsed:Draw(ScrW() / 2, He(880) + He(32), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		elseif time > 1 then
			local parsed = markup.Parse("<font=MuR_Font3><colour=255,255,255>"..MuR.Language["ragdoll_getup"].."<colour=200,200,0>" .. math.floor(time) .. "<colour=255,255,255>"..MuR.Language["second"])
			parsed:Draw(ScrW() / 2, He(880) + He(32), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			if ply:CanGetUp() then
				local parsed = markup.Parse("<font=MuR_Font3><colour=255,255,255>"..MuR.Language["ragdoll_press"].."<colour=200,200,0>C<colour=255,255,255>"..MuR.Language["ragdoll_getup2"])
				parsed:Draw(ScrW() / 2, He(880) + He(32), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				local parsed = markup.Parse("<font=MuR_Font3><colour=255,200,200>"..MuR.Language["ragdoll_cant"])
				parsed:Draw(ScrW() / 2, He(880) + He(32), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end

		local parsed = markup.Parse("<font=MuR_Font1><colour=255,255,255>"..MuR.Language["ragdoll_hold"].."<colour=200,200,0>LMB or RMB<colour=255,255,255>"..MuR.Language["ragdoll_pull"])
		parsed:Draw(ScrW() / 2, He(880) + He(60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		local parsed = markup.Parse("<font=MuR_Font1><colour=255,255,255>"..MuR.Language["ragdoll_press"].."<colour=200,200,0>Shift or Alt<colour=255,255,255>"..MuR.Language["ragdoll_grab"])
		parsed:Draw(ScrW() / 2, He(880) + He(75), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		local parsed = markup.Parse("<font=MuR_Font1><colour=255,255,255>"..MuR.Language["ragdoll_press"].."<colour=200,200,0>Space<colour=255,255,255>"..MuR.Language["ragdoll_jump"])
		parsed:Draw(ScrW() / 2, He(880) + He(90), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		local parsed = markup.Parse("<font=MuR_Font1><colour=255,255,255>"..MuR.Language["ragdoll_press"].."<colour=200,200,0>F<colour=255,255,255>"..MuR.Language["ragdoll_stand"])
		parsed:Draw(ScrW() / 2, He(880) + He(105), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		local parsed = markup.Parse("<font=MuR_Font1><colour=255,255,255>"..MuR.Language["ragdoll_press"].."<colour=200,200,0>V<colour=255,255,255>"..MuR.Language["ragdoll_getup3"])
		parsed:Draw(ScrW() / 2, He(880) + He(120), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
		local wep = ply:GetNW2Entity('RD_Weapon')
		if IsValid(wep) then
			if wep:GetNW2Bool('IsItem') then
				local parsed = markup.Parse("<font=MuR_Font1><colour=255,255,255>"..MuR.Language["ragdoll_press"].."<colour=200,200,0>LMB<colour=255,255,255>"..MuR.Language["ragdoll_wep3"])
				parsed:Draw(ScrW() / 2, He(880) + He(135), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			elseif LookupMuzzle(wep) > 0 then
				local parsed = markup.Parse("<font=MuR_Font1><colour=255,255,255>"..MuR.Language["ragdoll_press"].."<colour=200,200,0>LMB<colour=255,255,255>"..MuR.Language["ragdoll_wep1"])
				parsed:Draw(ScrW() / 2, He(880) + He(135), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				local parsed = markup.Parse("<font=MuR_Font1><colour=255,255,255>"..MuR.Language["ragdoll_press"].."<colour=200,200,0>R<colour=255,255,255>"..MuR.Language["ragdoll_wep2"])
				parsed:Draw(ScrW() / 2, He(880) + He(150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end
end)

hook.Add("HUDPaint", "MuR.CrossHairRDTP", function()
	local ply = LocalPlayer()
	if MuR:GetClient("blsd_viewperson") == 2 then
		local tr = ply:GetEyeTrace()
		local aw = ply:GetActiveWeapon()
		local isAiming = (IsValid(aw) and aw.IsTFAWeapon and ply.TPIK_IsAiming and ply:TPIK_IsAiming())
		if isAiming then
			local hitpos = tr.HitPos or (EyePos() + EyeAngles():Forward() * 1000)
			local spos = hitpos:ToScreen()
			if spos.x and spos.y then
				surface.SetDrawColor(255,255,255,220)
				surface.DrawCircle(spos.x, spos.y, 3, 255,255,255,220)
			end
		end
	end
	if MuR:GetClient("blsd_crosshair_ragdoll") then
		local tr = ply:GetEyeTrace()
		local wep = ply:GetNW2Entity('RD_Weapon')
		local ent = ply:GetNW2Entity('RD_Ent')
		if IsValid(ent) and IsValid(wep) and LookupMuzzle(wep) > 0 then
			local att = wep:GetAttachment(LookupMuzzle(wep))
			local tr = util.TraceLine({
				start = att.Pos+att.Ang:Forward(),
				endpos = att.Pos+att.Ang:Forward()*1000,
				mask = MASK_SHOT,
				filter = wep,
			})
			local pos = tr.HitPos:ToScreen()
			if IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:GetClass() == "prop_ragdoll") then
				surface.DrawCircle(pos.x, pos.y, 2, 220, 40, 40, 200)
			else
				surface.DrawCircle(pos.x, pos.y, 2, 200, 200, 200, 200)
			end
		end
	end
end)