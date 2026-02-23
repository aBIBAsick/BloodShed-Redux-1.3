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

local ragStateFrac = 0
local aimfrac = 0
local oldexecang = Angle(0,0,0)
local LerpEyeRagdoll = Angle(0,0,0)

hook.Add("CalcView", "MuR.zRD_CamWork", function(ply, pos, angles, fov)
	if MuR.CutsceneActive or ply:InVehicle() then return end

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
				local isUnconscious = ply:GetNW2Bool("IsUnconscious", false)
				local isStanding = ply:GetNW2Bool("IsRagStanding", false)

				local targetFrac = (isUnconscious or !isStanding) and 1 or 0
				ragStateFrac = math.Approach(ragStateFrac, targetFrac, FrameTime() * 4)

				local mouseAng = Angle(angles.x, angles.y, oldang.z / 2)
				local lockAng = oldang

				if isUnconscious then
					local time = CurTime() * 0.5
					lockAng.z = lockAng.z + math.sin(time) * 15
					lockAng.p = lockAng.p + math.cos(time * 1.5) * 5
				end

				LerpEyeRagdoll = LerpAngle(ragStateFrac, mouseAng, lockAng)
			else
				LerpEyeRagdoll = oldang
				ragStateFrac = 1
			end

			local view = {
				origin = t.Pos,
				angles = LerpEyeRagdoll,
				fov = fov,
				drawviewer = true,
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

	local hostage = ply:Alive() and (ply:IsInHostage(true) or ply:IsInHostage(false))
	if !hostage and MuR:GetClient("blsd_viewperson") == 1 and ply:Alive() then
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
		
		if ply:IsRolePolice() then
			lpos = lpos + hm.Ang:Right()*6 - hm.Ang:Forward()*8
			fov = 70
		else
			HideHead()
		end
		
		local view = {
			origin = lpos,
			angles = lang,
			fov = fov,
			drawviewer = true,
			znear = 1
		}

		return view
	elseif (hostage or MuR:GetClient("blsd_viewperson") == 2) and ply:Alive() then
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
				if ent:IsRagdoll() or ent:IsPlayer() then return false end
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
		if ply:TPIK_IsAiming() or !MuR:GetClient("blsd_viewbob") then
			aimfrac = math.Clamp(aimfrac-FrameTime(), 0, 0.2)
		else
			aimfrac = math.Clamp(aimfrac+FrameTime(), 0, 0.2)
		end

		local wep = ply:GetActiveWeapon()
		if IsValid(wep) and wep.IsTFAWeapon and wep.CalcView then
			local _, aa = ply:GetActiveWeapon():CalcView(ply, pos, nang, fov)
			nang = aa
		elseif IsValid(wep) and wep:GetClass() == "mur_doorlooker" then
			return
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

hook.Add("HUDPaint", "MuR.RD_CamWork", function()
	local ply = LocalPlayer()
	local ent = ply:GetNW2Entity('RD_EntCam')
	local time = ply:TimeGetUp() - CurTime() + 1
	local formattime = string.FormattedTime(time, "%02i:%02i")
	if !IsValid(ent) then
		return
	end

	if IsValid(ent) and ply:Alive() and !MuR:GetClient("blsd_nohud") and !ply:GetNW2Bool("IsUnconscious", false) then
		if time > 999 then
			local parsed = markup.Parse("<font=MuR_Font2><colour=200,20,20>"..MuR.Language["ragdoll_heavy"])
			parsed:Draw(ScrW() / 2, He(880) + He(32), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		elseif time > 1 then
			local parsed = markup.Parse("<font=MuR_Font2><colour=255,255,255>"..MuR.Language["ragdoll_getup"].."<colour=200,200,0>" .. math.floor(time) .. "<colour=255,255,255>"..MuR.Language["second"])
			parsed:Draw(ScrW() / 2, He(880) + He(32), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			if ply:CanGetUp() then
				local keyName = input.GetKeyName(MuR:GetBind("mur_ragdoll")) or "KEY"
				local parsed = markup.Parse("<font=MuR_Font2><colour=255,255,255>"..MuR.Language["ragdoll_press"].."<colour=200,200,0>"..string.upper(keyName).."<colour=255,255,255>"..MuR.Language["ragdoll_getup2"])
				parsed:Draw(ScrW() / 2, He(880) + He(32), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				local parsed = markup.Parse("<font=MuR_Font2><colour=255,200,200>"..MuR.Language["ragdoll_cant"])
				parsed:Draw(ScrW() / 2, He(880) + He(32), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end

	end
end)

hook.Add("HUDPaint", "MuR.CrossHairRDTP", function()
	local ply = LocalPlayer()
	if MuR:GetClient("blsd_viewperson") == 2 or ply:IsInHostage(true) then
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
	if MuR:GetClient("blsd_crosshair_ragdoll") and ply:TPIK_IsAiming() then
		local tr = ply:GetEyeTrace()
		local wep = ply:GetActiveWeapon()
		local ent = ply:GetNW2Entity('RD_Ent')
		local fwm = ply.RagFakeWorldModel
		if IsValid(ent) and IsValid(fwm) and IsValid(wep) and LookupMuzzle(fwm) > 0 then
			local att = fwm:GetAttachment(LookupMuzzle(fwm))
			if att then
				local tr = util.TraceLine({
					start = att.Pos+att.Ang:Forward(),
					endpos = att.Pos+att.Ang:Forward()*1000,
					mask = MASK_SHOT,
					filter = {fwm, ent, ply},
				})
				local pos = tr.HitPos:ToScreen()
				if IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:GetClass() == "prop_ragdoll") then
					surface.DrawCircle(pos.x, pos.y, 2, 220, 40, 40, 200)
				else
					surface.DrawCircle(pos.x, pos.y, 2, 200, 200, 200, 200)
				end
			end
		end
	end
end)

hook.Add("GetMotionBlurValues", "MuR.UnconsciousBlur", function(h, v, f, r)
	local ply = LocalPlayer()
	if ply:GetNW2Bool("IsUnconscious", false) then
		return 0.1, 0.95, 0.05, 0.5
	end
end)