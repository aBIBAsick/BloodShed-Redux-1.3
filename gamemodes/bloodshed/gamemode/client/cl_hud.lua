MuR.DrawHUD = true
MuR.ShowDeathLog = false
MuR.GamemodeCount = 0
MuR.Data = {}
MuR.Data["PoliceState"] = 0
MuR.Data["PoliceArriveTime"] = 0
MuR.Data["ExfilPos"] = Vector()
MuR.Data["HeliArrived"] = false
MuR.Data["SniperArrived"] = false
MuR.Data["TimerActive"] = false
MuR.Data["TimerLeft"] = 0
MuR.Data["EnableDebug"] = false
MuR.TimerPausedTime = 0
MuR.TimerWasPaused = false
hook.Add("Think", "MuR.OtherThingsCL", function()
	MuR.EnableDebug = MuR.Data["EnableDebug"]
end)

MuR.AllyCheckConfig = {
	sameTeam = {
		team1 = true,
	},
	
	classGroups = {
		police = {"Officer", "ArmoredOfficer", "SWAT", "FBI", "Riot"},
		swat = {"SWAT"},
		terrorists = {"Terrorist2"},
		gangred = {"GangRed"},
		ganggreen = {"GangGreen"},
	},
	
	specialChecks = {
		policeFunction = true,
	}
}

function MuR:ArePlayersAllies(localPly, targetPly)
	local config = MuR.AllyCheckConfig
	
	if config.sameTeam.team1 and localPly:Team() == 1 and targetPly:Team() == 1 then
		return true
	end
	
	if config.specialChecks.policeFunction and localPly:IsRolePolice() and targetPly:IsRolePolice() then
		return true
	end
	
	local localClass = localPly:GetNW2String("Class")
	local targetClass = targetPly:GetNW2String("Class")
	
	for groupName, classes in pairs(config.classGroups) do
		local localInGroup = table.HasValue(classes, localClass)
		local targetInGroup = table.HasValue(classes, targetClass)
		
		if localInGroup and targetInGroup then
			return true
		end
	end
	
	if MuR.Gamemode == 6 and localPly:Team() == targetPly:Team() then
		return true
	end
	
	return false
end

net.Receive("MuR.SendDataToClient", function()
	local str = net.ReadString()
	local value = net.ReadTable()[1]
	MuR.Data[str] = value
end)

net.Receive("MuR.PlaySoundOnClient", function()
	local str = net.ReadString()
	surface.PlaySound(str)
end)

local hide = {
	["CHudHealth"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudBattery"] = true,
	["CHudCrosshair"] = true,
	["CHudDamageIndicator"] = true,
}

local voiceicon = Material("murdered/voice.png", "smooth")
local wantedicon = Material("murdered/wanted.png", "smooth")
local arresticon = Material("murdered/handcuffs.png", "smooth")
local policeicon = Material("murdered/police.png", "mips")
local swaticon = Material("murdered/swat.png", "mips")
local assaulticon = Material("murdered/assault.png", "mips")
local helipadicon = Material("murdered/exfil.png")
local pistolicon = Material("murdered/pistol.png", "smooth")
local brokenicon = Material("murdered/broken.png", "smooth")
local bcircleicon = Material("murdered/blurcircle.png", "smooth")
local stamicon = Material("murdered/run.png", "smooth")
local vinmat = Material("murdered/vin.png", "smooth")
local axonmat = Material("murdered/axon.png", "smooth")
local cal1 = Material("ui/9mm.png")
local cal2 = Material("ui/762.png")
local cal3 = Material("ui/556.png")
local cal4 = Material("ui/357.png")
local cal5 = Material("ui/12gauge.png")

function We(x)
	return x / 1920 * ScrW()
end

function He(y)
	return y / 1080 * ScrH()
end

hook.Add("HUDShouldDraw", "HideHUD", function(name)
	if hide[name] then return false end
end)

hook.Add("DrawDeathNotice", "DisableKillfeed", function() return 0, 0 end)
hook.Add("PlayerStartVoice", "ImageOnVoice", function(ply) 
	return ply == LocalPlayer() and false or not LocalPlayer():IsAdmin() or ply:Alive()
end)

local stamalpha = 0
local stamold = 0

hook.Add("HUDPaint", "MurderedHUD", function()
	local ply = LocalPlayer()
	local guilt = ply:GetNW2Float("Guilt", 0)

	if guilt >= 90 then
		local alpha = math.cos(CurTime() * 4) * 255

		if alpha < 0 then
			alpha = alpha * -1
		end

		draw.SimpleText(MuR.Language["guiltwarning"], "MuR_Font2", ScrW() / 2, ScrH() / 2 - He(300), Color(200, 200 - ((guilt / 100) * 200), 200 - ((guilt / 100) * 200), alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	end

	if MuR.DrawHUD and ply:Alive() and !MuR:GetClient("blsd_nohud") then
		if ply:GetNW2String("Class") == "Zombie" then
			surface.SetDrawColor(100, 0, 0, 50)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			if MuR.Data["ExfilPos"] and MuR.Data["PoliceState"] == 8 then
				if MuR.Data["ExfilPos"]:DistToSqr(ply:GetPos()) < 40000 then
					local alpha = math.abs(math.cos(CurTime() * 2) * 255)
					draw.SimpleText(MuR.Language["evac_zone"], "MuR_Font3", ScrW()/2, He(100), Color(200, 200, 20, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
				
				local pos = (MuR.Data["ExfilPos"] + Vector(0,0,32)):ToScreen()
				surface.SetMaterial(helipadicon)
				surface.SetDrawColor(255,255,255,200)
				surface.DrawTexturedRect(pos.x - 24, pos.y - 24, 48, 48)
				draw.SimpleText(math.floor(ply:GetPos():Distance(MuR.Data["ExfilPos"]) / 80) .. "m", "MuR_Font1", pos.x + 20, pos.y, Color(255,255,255,200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		end

		local tr = ply:GetEyeTrace().Entity

		if IsValid(tr) and tr:GetPos():DistToSqr(ply:GetPos()) < 10000 and !ply:GetNW2Bool("IsUnconscious", false) then
			local name = tr:GetNWString("Name", "")
			local candraw = ply:GetNW2Entity("RD_EntCam") ~= tr

			if tr:IsPlayer() and tr:GetNW2String("Class") == "Zombie" then
				candraw = false
			end
			if table.HasValue(MuR.LootableProps, tr:GetModel()) then
				local parsed = markup.Parse("<font=MuR_Font0><colour=255,255,255>E<colour=200,200,0>" .. MuR.Language["ragdoll_use"])
				parsed:Draw(ScrW() / 2, ScrH() / 2 + He(30), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			if candraw then
				if tr:GetClass() == "prop_ragdoll" then
					local parsed = markup.Parse("<font=MuR_Font0><colour=255,255,255>E<colour=200,200,0>" .. MuR.Language["ragdoll_use"])
					parsed:Draw(ScrW() / 2, ScrH() / 2 + He(30), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end

				draw.SimpleText(name, "MuR_Font5", ScrW() / 2, ScrH() / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			if tr:GetNW2Bool("BreakableThing") and tr.Health and tr:Health() > 0 then
				local parsed = markup.Parse("<font=MuR_Font1><colour=255,255,255>" .. MuR.Language["strength"] .. "<colour=200," .. math.floor((tr:Health() / tr:GetMaxHealth()) * 200) .. "," .. math.floor((tr:Health() / tr:GetMaxHealth()) * 200) .. ">" .. math.floor((tr:Health() / tr:GetMaxHealth()) * 100) .. "%")
				parsed:Draw(ScrW() / 2, ScrH() / 2 + He(30), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			if ply:IsRolePolice() then
				local tr2 = tr:IsPlayer() and tr or tr:GetNW2Entity("Owner", tr)
				local icon = false
				if tr2:GetNW2Float("ArrestState") == 2 then
					icon = pistolicon
				elseif tr2:GetNW2Float("ArrestState") == 1 then
					icon = arresticon
				end
				if icon then
					surface.SetDrawColor(255, 255, 255, 255)
					surface.SetMaterial(icon)
					surface.DrawTexturedRect(ScrW() / 2 - We(32), ScrH() / 2 + He(32), We(64), He(64))
				end
			end
		end

		local hunger = ply:GetNW2Float("Hunger")

		if hunger < 20 then
			draw.SimpleText(MuR.Language["hungermax"], "MuR_Font2", ScrW() / 2, ScrH() - He(10), Color(200, 50, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		elseif hunger < 50 then
			draw.SimpleText(MuR.Language["hungermedium"], "MuR_Font2", ScrW() / 2, ScrH() - He(10), Color(200, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		elseif hunger < 80 then
			draw.SimpleText(MuR.Language["hungersmall"], "MuR_Font2", ScrW() / 2, ScrH() - He(10), Color(225, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		end

		if ply:IsKiller() then
			local stab = ply:GetNW2Float("Stability")
			local stage = 0

			if stab < 60 then
				draw.SimpleText(MuR.Language["stability_message"], "MuR_Font1", We(20), ScrH() - He(10), Color(200, 20, 20, math.abs(math.sin(CurTime()*2)*255)), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			end

			if stab < 10 then
				for i = 1, math.random(16,24) do
					draw.SimpleText(MuR.Language["kill_them"], "MuR_Font3", We(math.random(-100, ScrW()+100)), He(math.random(-100, ScrH()+100)), Color(200, 20, 20, math.abs(math.sin(CurTime()*4)*255)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
				if math.random(1,50) == 1 then
					ply:ViewPunchClient(AngleRand(-5,5))
				end
				surface.SetDrawColor(20,0,0,math.abs(math.sin(CurTime()*4)*255))
				surface.SetMaterial(vinmat)
				surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
			elseif stab < 25 then
				for i = 1, math.random(8,16) do
					draw.SimpleText(MuR.Language["kill_them"], "MuR_Font2", We(math.random(-100, ScrW()+100)), He(math.random(-100, ScrH()+100)), Color(220, 160, 160, math.abs(math.sin(CurTime()*3)*255)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
				if math.random(1,75) == 1 then
					ply:ViewPunchClient(AngleRand(-3,3))
				end
				surface.SetDrawColor(10,0,0,math.abs(math.sin(CurTime()*3)*200))
				surface.SetMaterial(vinmat)
				surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
			elseif stab < 40 then
				for i = 1, math.random(4,8) do
					draw.SimpleText(MuR.Language["kill_them"], "MuR_Font1", We(math.random(-100, ScrW()+100)), He(math.random(-100, ScrH()+100)), Color(255, 255, 255, math.abs(math.sin(CurTime()*2)*255)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
				if math.random(1,100) == 1 then
					ply:ViewPunchClient(AngleRand(-1,1))
				end
				surface.SetDrawColor(0,0,0,math.abs(math.sin(CurTime()*2)*150))
				surface.SetMaterial(vinmat)
				surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
			elseif stab < 60 then
				for i = 1, math.random(1,4) do
					draw.SimpleText(MuR.Language["kill_them"], "MuR_Font1", We(math.random(-100, ScrW()+100)), He(math.random(-100, ScrH()+100)), Color(255, 255, 255, math.abs(math.sin(CurTime())*20)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end



			local parsed = markup.Parse("<font=MuR_Font2><colour=255,255,255>"..MuR.Language["stability"].."<colour=200," .. math.floor(stab/100 * 200) .. "," .. math.floor(stab/100 * 200) .. ">" .. math.floor(stab) .. "%")
			parsed:Draw(20, ScrH() - He(30), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		end

		stamold = Lerp(0.01, stamold, LocalPlayer():GetNW2Float('Stamina'))
		local stam = stamold/100

		if stam < 0.99 then
			stamalpha = math.Clamp(stamalpha + FrameTime(), 0, 1)
		else
			stamalpha = math.Clamp(stamalpha - FrameTime(), 0, 1)
		end

		surface.SetMaterial(stamicon)
		surface.SetDrawColor(200, 100 * stam + 50, 0, 255 * stamalpha)
		surface.DrawTexturedRect(ScrW() - We(45), ScrH() / 2 - He(180), We(20), He(20))
		surface.SetDrawColor(20, 20, 20, 200 * stamalpha)
		surface.DrawRect(ScrW() - We(40), ScrH() / 2 - He(150), We(8), He(300))
		surface.SetDrawColor(200, 100 * stam + 50, 0, 255 * stamalpha)
		surface.DrawRect(ScrW() - We(38), ScrH() / 2 - He(148), We(4), He(296 * stam))

		if ply:GetNW2Bool("LegBroken") then
			surface.SetMaterial(brokenicon)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(ScrW() - We(48), ScrH() / 2 - He(290), We(36), He(36))
			local alpha = math.cos(CurTime() * 4) * 255

			if alpha < 0 then
				alpha = alpha * -1
			end

			draw.SimpleText(MuR.Language["legbroken"], "MuR_Font2", ScrW() - We(55), ScrH() / 2 - He(272), Color(180, 0, 0, alpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end
	end
	if !MuR:GetClient("blsd_nohud") then
		if MuR.Data["PoliceState"] == 1 then
			local time = MuR.Data["PoliceArriveTime"] - CurTime() + 0.5
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(policeicon)
			surface.DrawTexturedRect(We(20 + math.cos(CurTime() * 4) * 8), He(20 + math.sin(CurTime() * 4) * 8), We(96), He(96))
			local red = math.cos(CurTime() * 6) > 0
			local alpha = math.cos(CurTime() * 10) * 200

			if alpha < 0 then
				alpha = alpha * -1
			end

			if red then
				surface.SetDrawColor(25, 25, 200, alpha)
				surface.SetMaterial(bcircleicon)
				surface.DrawTexturedRect(We(20 + math.cos(CurTime() * 4) * 8), He(15 + math.sin(CurTime() * 4) * 8), We(96), He(96))
			else
				surface.SetDrawColor(200, 25, 25, alpha)
				surface.SetMaterial(bcircleicon)
				surface.DrawTexturedRect(We(30 + math.cos(CurTime() * 4) * 8), He(10 + math.sin(CurTime() * 4) * 8), We(96), He(96))
			end

			draw.SimpleText(MuR.Language["policearecoming"], "MuR_Font3", We(140 + math.cos(CurTime() * 4) * 8), He(70 + math.sin(CurTime() * 4) * 8), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(string.FormattedTime(time, "%02i:%02i"), "MuR_Font2", We(140 + math.cos(CurTime() * 4) * 8), He(90 + math.sin(CurTime() * 4) * 8), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		elseif MuR.Data["PoliceState"] == 2 then
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(policeicon)
			surface.DrawTexturedRect(We(20 + math.cos(CurTime() * 4) * 4), He(20 + math.sin(CurTime() * 4) * 4), We(96), He(96))
			local red = math.cos(CurTime() * 6) > 0
			local alpha = math.cos(CurTime() * 10) * 200

			if alpha < 0 then
				alpha = alpha * -1
			end

			if red then
				surface.SetDrawColor(25, 25, 200, alpha)
				surface.SetMaterial(bcircleicon)
				surface.DrawTexturedRect(We(20 + math.cos(CurTime() * 4) * 4), He(15 + math.sin(CurTime() * 4) * 4), We(96), He(96))
			else
				surface.SetDrawColor(200, 25, 25, alpha)
				surface.SetMaterial(bcircleicon)
				surface.DrawTexturedRect(We(30 + math.cos(CurTime() * 4) * 4), He(10 + math.sin(CurTime() * 4) * 4), We(96), He(96))
			end

			draw.SimpleText(MuR.Language["policearehere"], "MuR_Font3", We(140 + math.cos(CurTime() * 4) * 4), He(70 + math.sin(CurTime() * 4) * 4), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		elseif MuR.Data["PoliceState"] == 3 then
			local time = MuR.Data["PoliceArriveTime"] - CurTime() + 0.5
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(swaticon)
			surface.DrawTexturedRect(We(20 + math.cos(CurTime() * 4) * 8), He(20 + math.sin(CurTime() * 4) * 8), We(96), He(96))
			local red = math.cos(CurTime() * 6) > 0
			local alpha = math.cos(CurTime() * 10) * 175

			if alpha < 0 then
				alpha = alpha * -1
			end

			if red then
				surface.SetDrawColor(25, 25, 200, alpha)
				surface.SetMaterial(bcircleicon)
				surface.DrawTexturedRect(We(20 + math.cos(CurTime() * 4) * 8), He(10 + math.sin(CurTime() * 4) * 8), We(96), He(96))
			else
				surface.SetDrawColor(200, 25, 25, alpha)
				surface.SetMaterial(bcircleicon)
				surface.DrawTexturedRect(We(30 + math.cos(CurTime() * 4) * 8), He(5 + math.sin(CurTime() * 4) * 8), We(96), He(96))
			end

			draw.SimpleText(MuR.Language["swatarecoming"], "MuR_Font3", We(140 + math.cos(CurTime() * 4) * 8), He(70 + math.sin(CurTime() * 4) * 8), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(string.FormattedTime(time, "%02i:%02i"), "MuR_Font2", We(140 + math.cos(CurTime() * 4) * 8), He(90 + math.sin(CurTime() * 4) * 8), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		elseif MuR.Data["PoliceState"] == 4 then
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(swaticon)
			surface.DrawTexturedRect(We(20 + math.cos(CurTime() * 4) * 4), He(20 + math.sin(CurTime() * 4) * 4), We(96), He(96))
			local red = math.cos(CurTime() * 6) > 0
			local alpha = math.cos(CurTime() * 10) * 175

			if alpha < 0 then
				alpha = alpha * -1
			end

			if red then
				surface.SetDrawColor(25, 25, 200, alpha)
				surface.SetMaterial(bcircleicon)
				surface.DrawTexturedRect(We(20 + math.cos(CurTime() * 4) * 4), He(10 + math.sin(CurTime() * 4) * 4), We(96), He(96))
			else
				surface.SetDrawColor(200, 25, 25, alpha)
				surface.SetMaterial(bcircleicon)
				surface.DrawTexturedRect(We(30 + math.cos(CurTime() * 4) * 4), He(5 + math.sin(CurTime() * 4) * 4), We(96), He(96))
			end

			draw.SimpleText(MuR.Language["swatarehere"], "MuR_Font3", We(140 + math.cos(CurTime() * 4) * 4), He(70 + math.sin(CurTime() * 4) * 4), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		elseif MuR.Data["PoliceState"] == 5 then
			local time = MuR.Data["PoliceArriveTime"] - CurTime() + 0.5
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(assaulticon)
			surface.DrawTexturedRect(We(20 + math.cos(CurTime() * 4) * 8), He(20 + math.sin(CurTime() * 4) * 8), We(96), He(96))
			draw.SimpleText(MuR.Language["policeassault1"], "MuR_Font3", We(140 + math.cos(CurTime() * 4) * 8), He(70 + math.sin(CurTime() * 4) * 8), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(string.FormattedTime(time, "%02i:%02i"), "MuR_Font2", We(140 + math.cos(CurTime() * 4) * 8), He(90 + math.sin(CurTime() * 4) * 8), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			if time < 42 then
				MuR:PlayMusic("murdered/theme/assault_theme.mp3")
			end
		elseif MuR.Data["PoliceState"] == 6 then
			local alpha = math.abs(math.sin(CurTime() * 2) * 255)
			local text = " / "..MuR.Language["policeassault"].." / "

			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(assaulticon)
			surface.DrawTexturedRect(We(20 + math.cos(CurTime() * 4) * 4), He(20 + math.sin(CurTime() * 4) * 4), We(96), He(96))
			draw.SimpleText(MuR.Language["policeassault2"], "MuR_Font3", We(140 + math.cos(CurTime() * 4) * 4), He(70 + math.sin(CurTime() * 4) * 4), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			draw.WordBox(4, ScrW()/2, He(40), text, "MuR_Font3", Color(160, 140, 0, 150), Color(220, 200, 0, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

			MuR:PlayMusic("murdered/theme/assault_theme.mp3")
		elseif MuR.Data["PoliceState"] == 7 then
			local time = MuR.Data["PoliceArriveTime"] - CurTime() + 0.5
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(helipadicon)
			surface.DrawTexturedRect(We(20 + math.cos(CurTime() * 4) * 8), He(20 + math.sin(CurTime() * 4) * 8), We(96), He(96))
			draw.SimpleText(MuR.Language["evac1"], "MuR_Font3", We(140 + math.cos(CurTime() * 4) * 8), He(70 + math.sin(CurTime() * 4) * 8), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(string.FormattedTime(time, "%02i:%02i"), "MuR_Font2", We(140 + math.cos(CurTime() * 4) * 8), He(90 + math.sin(CurTime() * 4) * 8), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		
			if time < 50 then
				MuR:PlayMusic("murdered/theme/evac_theme.mp3")
			else
				MuR:PlayMusic("murdered/theme/zombie_theme.mp3")
			end
		elseif MuR.Data["PoliceState"] == 8 then
			local time = MuR.Data["PoliceArriveTime"] - CurTime() + 0.5
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(helipadicon)
			surface.DrawTexturedRect(We(20 + math.cos(CurTime() * 4) * 8), He(20 + math.sin(CurTime() * 4) * 8), We(96), He(96))
			draw.SimpleText(MuR.Language["evac2"], "MuR_Font3", We(140 + math.cos(CurTime() * 4) * 8), He(70 + math.sin(CurTime() * 4) * 8), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(string.FormattedTime(time, "%02i:%02i"), "MuR_Font2", We(140 + math.cos(CurTime() * 4) * 8), He(90 + math.sin(CurTime() * 4) * 8), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		else
			if not MuR.ShowDeathLog then
				MuR:PlayMusic("")
			end
		end

		if ply:GetObserverMode() > 0 then
			if IsValid(ply:GetObserverTarget()) then
				draw.SimpleText(MuR.Language["spectating:"], "MuR_Font1", ScrW() / 2, ScrH() / 2 + He(170), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(ply:GetObserverTarget():Nick(), "MuR_Font4", ScrW() / 2, ScrH() / 2 + He(200), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			local parsed = markup.Parse("<font=MuR_Font2><colour=255,255,255>"..MuR.Language["spectate_1"])
			parsed:Draw(ScrW() / 2, ScrH() - He(200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			local parsed = markup.Parse("<font=MuR_Font1><colour=255,255,255>Space<colour=200,200,0>"..MuR.Language["spectate_2"])
			parsed:Draw(ScrW() / 2, ScrH() - He(170), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			local parsed = markup.Parse("<font=MuR_Font1><colour=255,255,255>LMB<colour=200,200,0>"..MuR.Language["spectate_3"])
			parsed:Draw(ScrW() / 2, ScrH() - He(150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			local parsed = markup.Parse("<font=MuR_Font1><colour=255,255,255>RMB<colour=200,200,0>"..MuR.Language["spectate_4"])
			parsed:Draw(ScrW() / 2, ScrH() - He(130), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		if ply:IsSpeaking() then
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(voiceicon)
			surface.DrawTexturedRect(We(20), ScrH() - He(250), We(72), He(72))
		end

		if player.GetCount() == 1 and !MuR.EnableDebug and !ply:Alive() then
			draw.SimpleText(MuR.Language["waitingplayers"], "MuR_Font6", ScrW() / 2, ScrH() - He(100), Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		---AXON BODY---

		if ply:IsRolePolice() and ply:Alive() and MuR.GamemodeCount != 14 then	
			local DateTime = os.date("%d/%m/%Y | %H : %M : %S", os.time())

			draw.RoundedBox(10, ScrW() - We(354), He(4), We(350), He(100), Color(35,35,35,220))

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(axonmat)
			surface.DrawTexturedRect(ScrW() - We(43), He(8), We(32), He(32))

			draw.SimpleText("REC", "MuR_Font2", ScrW() - We(325), He(25), Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			local alpha = (math.sin(RealTime() * math.pi / 0.40) + 1) * 250.5
			draw.RoundedBox(100, ScrW() - We(306), He(16.5), We(16), He(16), Color(255,0,0,alpha))
			
			draw.SimpleText("Axon BodyCam™", "MuR_Font2", ScrW() - We(120), He(25), Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(DateTime, "MuR_Font1", ScrW() - We(340), He(85), Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			surface.SetFont("MuR_Font2")
			surface.SetTextColor(255, 255, 255)
			surface.SetTextPos(ScrW() - We(340), He(50)) 
			surface.DrawText("OFFICER \t|\t" ..  ply:GetNWString("Name"))
		end
		
		if MuR.Data["TimerActive"] and MuR.Data["TimerLeft"] then
			local isPaused = MuR.Data["TimerPaused"] or false
			local timeLeft = MuR.Data["TimerLeft"]
			
			if isPaused then
				if not MuR.TimerWasPaused then
					MuR.TimerPausedTime = timeLeft
					MuR.TimerWasPaused = true
				end
				timeLeft = MuR.TimerPausedTime
			else
				MuR.TimerWasPaused = false
			end
			
			if timeLeft > 0 then
				local minutes = math.floor(timeLeft / 60)
				local seconds = math.floor(timeLeft % 60)
				local timeText = string.format("%02d:%02d", minutes, seconds)
				
				local color = Color(255, 255, 255, 255)
				
				if isPaused then
					local alpha = math.abs(math.sin(CurTime() * 3) * 255)
					color = Color(255, 165, 0, alpha)
					timeText = timeText
				elseif timeLeft <= 15 then
					local alpha = math.abs(math.sin(CurTime() * 5) * 255)
					color = Color(255, 50, 50, alpha)
				elseif timeLeft <= 60 then
					color = Color(255, 255, 50, 255)
				end
				
				surface.SetFont("MuR_Font4")
				local w, h = surface.GetTextSize(timeText)
				
				local bgColor = Color(0, 0, 0, 150)
				if isPaused then
					bgColor = Color(50, 25, 0, 180)
				end
				
				draw.RoundedBox(8, ScrW() / 2 - w / 2 - 10, He(10), w + 20, h + 5, bgColor)
				draw.SimpleText(timeText, "MuR_Font4", ScrW() / 2, He(30), color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end
end)

hook.Add("RenderScreenspaceEffects", "MuR_ColorHP", function()
	local ply = LocalPlayer()

	if ply:Alive() then
		local tab = {
			["$pp_colour_contrast"] = math.Clamp(ply:Health() / 40, 0.1, 1),
			["$pp_colour_colour"] = math.Clamp((ply:Health() / ply:GetMaxHealth()) / 1.25 + 0.2, 0.1, 1),
			[ "$pp_colour_addr" ] = 0,
			[ "$pp_colour_addg" ] = 0,
			[ "$pp_colour_addb" ] = 0,
			[ "$pp_colour_brightness" ] = 0,
			[ "$pp_colour_mulr" ] = 0,
			[ "$pp_colour_mulg" ] = 0,
			[ "$pp_colour_mulb" ] = 0
		}

		if ply:GetNW2Bool("GeroinUsed") then
			tab["$pp_colour_colour"] = 5
		end

		DrawColorModify(tab)
	end
end)

local musicname = ""
local currentchannel = nil
function MuR:PlayMusic(music1)
	local music = "sound/"..music1
	if music1 ~= "" then
		local disable = true 
		if IsValid(currentchannel) and (currentchannel:GetState() == 2 or currentchannel:GetState() == 0) then
			disable = false
		end
		if musicname == music1 and disable then 
			return
		else
			if IsValid(currentchannel) then
				currentchannel:Stop()
				currentchannel = nil
			end
			timer.Simple(1, function()
				sound.PlayFile(music, "noblock", function(station, s1, s2)
					if IsValid(station) then
						station:Play()
						station:SetVolume(GetConVar("snd_musicvolume"):GetFloat())
						currentchannel = station
					end
				end)
			end)
		end

		musicname = music1
	else
		musicname = ""
		if IsValid(currentchannel) then
			currentchannel:Stop()
			currentchannel = nil
		end
	end
end
hook.Add("Think", "MuR.MusicVolume", function()
	if IsValid(currentchannel) then
		currentchannel:SetVolume(GetConVar("snd_musicvolume"):GetFloat())
	end
end)

local function ShowAnnounce(type, ent)
	if MuR.EnableDebug then return end
	
	local pos = -100
	local start = true
	local text = ""
	local font = "MuR_Font4"

	if type == "you_killer" then
		text = MuR.Language["announce_traitor"]
	elseif type == "you_defender" then
		text = MuR.Language["announce_defender"]
	elseif type == "you_zombie" then
		text = MuR.Language["announce_zombie"]
	elseif type == "innocent_kill" then
		text = MuR.Language["announce_innokill"]
		font = "MuR_Font2"
		surface.PlaySound("npc/attack_helicopter/aheli_damaged_alarm1.wav")
	elseif type == "innocent_att_kill" then
		text = MuR.Language["announce_attkill"]
		font = "MuR_Font2"
	elseif type == "money_cancel" then
		text = MuR.Language["announce_moneycancel"]
		font = "MuR_Font2"
	elseif type == "spawn_damage" then
		text = MuR.Language["announce_spawndamage"]
		font = "MuR_Font2"
		surface.PlaySound("ambient/alarms/warningbell1.wav")
	elseif type == "officer_spawn" then
		text = MuR.Language["announce_officerspawn"]
		font = "MuR_Font2"
	elseif type == "arrested" then
		text = MuR.Language["announce_arrested"]
		font = "MuR_Font2"
	elseif type == "officer_killer" then
		text = MuR.Language["announce_officerguilt"]
		font = "MuR_Font2"
	elseif type == "officerguilt2" then
		text = MuR.Language["announce_officerguilt2"]
		font = "MuR_Font2"
	elseif type == "headhunter_kill" then
		text = MuR.Language["headhunter_kill"]
		font = "MuR_Font2"
		surface.PlaySound("murdered/vgui/buy.wav")
	elseif type == "headhunter_killed" then
		text = MuR.Language["headhunter_killed"]
		font = "MuR_Font2"
	end

	timer.Simple(6, function()
		start = false
	end)

	hook.Add("HUDPaint", "ShowAnnounceMuR", function()
		if start then
			pos = math.Clamp(pos + FrameTime() / 0.001, -100, 300)
		else
			pos = math.Clamp(pos - FrameTime() / 0.001, -100, 300)

			if pos == -100 then
				hook.Remove("HUDPaint", "ShowAnnounceMuR")
			end
		end

		draw.SimpleText(text, font, ScrW() / 2, He(pos), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end)
end

net.Receive("MuR.Announce", function()
	local str = net.ReadString()
	ShowAnnounce(str)
end)

local function ShowMessage(type, ent)
	local alpha = 0
	local start = true
	local text = ""
	local font = "MuR_Font1"

	if type == "corpse_alive" then
		text = MuR.Language["message_ragalive"]
		font = "MuR_Font2"
	elseif type == "corpse_dead" then
		text = MuR.Language["message_ragdead"]
		font = "MuR_Font2"
	elseif type == "bandage_use" then
		text = MuR.Language["message_bandageuse"]
		font = "MuR_Font2"
	elseif type == "medkit_use" then
		text = MuR.Language["message_medkituse"]
		font = "MuR_Font2"
	elseif type == "adrenaline_use" then
		text = MuR.Language["message_adrenalineuse"]
		font = "MuR_Font2"
	elseif type == "geroin_use" then
		text = MuR.Language["message_heroinuse"]
		font = "MuR_Font2"
	elseif type == "ducttape_use" then
		text = MuR.Language["message_tapeuse"]
		font = "MuR_Font2"
	elseif type == "bandage_use_target" then
		text = MuR.Language["message_targetbandageuse"]
		font = "MuR_Font2"
	elseif type == "medkit_use_target" then
		text = MuR.Language["message_targetmedkituse"]
		font = "MuR_Font2"
	elseif type == "adrenaline_use_target" then
		text = MuR.Language["message_targetadrenalineuse"]
		font = "MuR_Font2"
	elseif type == "geroin_use_target" then
		text = MuR.Language["message_targetheroinuse"]
		font = "MuR_Font2"
	elseif type == "cyanide_use_target" then
		text = MuR.Language["message_targetcyanideuse"]
		font = "MuR_Font2"
	elseif type == "poison_use" then
		text = MuR.Language["message_poisonuse"]
		font = "MuR_Font2"
	elseif type == "weapon_break" then
		text = MuR.Language["message_weaponbreak"]
		font = "MuR_Font3"
	elseif type == "ied_connected" then
		text = MuR.Language["loot_ied_4"]
		font = "MuR_Font2"
	elseif type == "targetbredogenuse" then
		text = MuR.Language["message_targetbredogenuse"]
		font = "MuR_Font2"
	elseif type == "mindcontroller_use" then
		text = MuR.Language["message_mindcontroller_use"]
		font = "MuR_Font2"
	elseif type == "mindcontroller_used" then
		text = MuR.Language["message_mindcontroller_used"]
		font = "MuR_Font6"
	else
		text = MuR.Language["message_"..type] or ""
		font = "MuR_Font2"
	end

	timer.Simple(5, function()
		start = false
	end)

	hook.Add("HUDPaint", "ShowMessageMuR", function()
		if start then
			alpha = math.Clamp(alpha + FrameTime() / 0.002, 0, 255)
		else
			alpha = math.Clamp(alpha - FrameTime() / 0.002, 0, 255)

			if alpha == 0 then
				hook.Remove("HUDPaint", "ShowMessageMuR")
			end
		end

		if !MuR:GetClient("blsd_nohud") and LocalPlayer():Alive() then
			draw.SimpleText(text, font, ScrW() / 2, ScrH() / 2 + He(200), Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end)
end

net.Receive("MuR.Message", function()
	local str = net.ReadString()
	ShowMessage(str)
end)

local function ShowMessage2(type)
	local start = true
	local text = ""
	local font = "MuR_Font1"
	if type == "neck_hit" then
		text = MuR.Language["neck_hit"]
		font = "MuR_Font2"
	elseif type == "lung_hit" then
		text = MuR.Language["lung_hit"]
		font = "MuR_Font2"
	elseif type == "heart_hit" then
		text = MuR.Language["heart_hit"]
		font = "MuR_Font2"
	elseif type == "leg_hit" then
		text = MuR.Language["leg_hit"]
		font = "MuR_Font2"
	elseif type == "arm_hit" then
		text = MuR.Language["arm_hit"]
		font = "MuR_Font2"
	elseif type == "down_hit" then
		text = MuR.Language["down_hit"]
		font = "MuR_Font2"
	else
		text = MuR.Language[type] or ""
		font = "MuR_Font2"
	end

	local startTime = CurTime()
	local revealSpeed = 0.02
	local vanishStart = nil
	local chars = {}
	for p, c in utf8.codes(text) do table.insert(chars, utf8.char(c)) end
	local charCount = #chars
	timer.Simple(5, function() start = false vanishStart = CurTime() end)

	hook.Add("HUDPaint", "ShowMessageMuR2", function()
		if !MuR:GetClient("blsd_nohud") and LocalPlayer():Alive() then
			local shown = 0
			if start then
				shown = math.min(math.floor((CurTime() - startTime) / revealSpeed) + 1, charCount)
			else
				if vanishStart then
					local gone = math.floor((CurTime() - vanishStart) / revealSpeed)
					shown = math.max(charCount - gone, 0)
				else
					shown = charCount
				end
			end
			if shown <= 0 then
				hook.Remove("HUDPaint", "ShowMessageMuR2")
				return
			end
			local partial = ""
			for i = 1, shown do partial = partial .. chars[i] end
			draw.SimpleText(partial, font, ScrW() / 2, ScrH() / 2 + He(250), Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end)
end

net.Receive("MuR.Message2", function()
	local str = net.ReadString()
	ShowMessage2(str)
end)

local nextBleedNotify = 0
local lastBleedStage = -1
hook.Add("Think", "MuR.BleedMessageNotifier", function()
	if MuR:GetClient("blsd_nohud") then return end
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:Alive() then return end
	local lvl = ply:GetNW2Float("BleedLevel") or 0
	local hbl = ply:GetNW2Bool("HardBleed") or false
	local stage = 0
	if hbl then
		stage = 4
	elseif lvl >= 3 then
		stage = 3
	elseif lvl == 2 then
		stage = 2
	elseif lvl == 1 then
		stage = 1
	end
	if stage == 0 then
		lastBleedStage = 0
		return
	end
	local t = CurTime()
	if stage ~= lastBleedStage then
		nextBleedNotify = 0
		lastBleedStage = stage
	end
	if t < nextBleedNotify then return end
	local key
	if stage == 1 then key = "smallbleed" elseif stage == 2 then key = "mediumbleed" elseif stage == 3 then key = "highbleed" elseif stage == 4 then key = "criticalbleed" end
	if key then
		ShowMessage2(key)
		local base = 14 - stage * 2
		nextBleedNotify = t + base + math.Rand(0,4)
	end
end)

local function Countdown(num, type)
	local alpha = 255
	if MuR.EnableDebug then return end
	for i = 0, num - 1 do
		timer.Simple(i, function()
			alpha = 255
			surface.PlaySound("buttons/lightswitch2.wav")

			hook.Add("HUDPaint", "MuRHUDTimer", function()
				alpha = math.max(alpha - FrameTime() / 0.004, 0)

				if alpha == 0 then
					hook.Remove("HUDPaint", "MuRHUDTimer")
				end

				draw.SimpleTextOutlined(num - i, "MuR_Font6", ScrW() / 2, He(250), Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0, 0, 0, alpha))
			end)
		end)
	end
end

net.Receive("MuR.Countdown", function()
	local f = net.ReadFloat()
	Countdown(f)
end)

hook.Add("AdjustMouseSensitivity", "Murdered", function(speed)
	if LocalPlayer():IsSprinting() and not LocalPlayer():GetNW2Entity("RD_Ent") then return 0.3 end
end)

local viewbob_speed = 10
local viewbob_amount = 0.01
local viewbob_offset = 0
local last_velocity = 0

hook.Add("CalcView", "ViewBob", function(ply, pos, angles, fov)
	local wep = ply:GetActiveWeapon()
	local allow = true
	if IsValid(wep) or IsValid(ply:GetNW2Entity("RD_EntCam")) or ply:GetSVAnimation() ~= "" or !IsValid(ply:GetActiveWeapon()) then allow = false end

	if ply:Alive() and not ply:ShouldDrawLocalPlayer() and allow then
		local velocity = ply:GetVelocity():Length()
		local head_z = 0
		local eyes = ply:GetAttachment(ply:LookupAttachment("eyes"))
		local draws = false
		head_z = math.Clamp(eyes.Ang.z/5, -45, 45)

		if velocity > 0 and last_velocity == 0 then
			viewbob_offset = 0
		end

		last_velocity = velocity

		viewbob_offset = viewbob_offset + (viewbob_speed * FrameTime())
		local bob_x = math.sin(viewbob_offset) * viewbob_amount * last_velocity
		local bob_y = math.cos(viewbob_offset) * viewbob_amount * last_velocity
		angles.roll = angles.roll + bob_y / 2
		angles.x = angles.x + bob_x / 4
		angles.z = head_z

		local view = {}
		view.origin = pos
		view.angles = angles
		view.fov = fov
		view.drawviewer = draws

		return view
	end
end)

hook.Add("HUDPaint", "MuR_ShowcaseTeammates", function()
	if MuR.DrawHUD and !MuR:GetClient("blsd_nohud") then
		for _, ply in ipairs(player.GetAll()) do
			local role = MuR:ArePlayersAllies(LocalPlayer(), ply)
			if ply ~= LocalPlayer() and role and ply:Alive() and LocalPlayer():IsLineOfSightClear(ply) then
				local pos = ply:EyePos():ToScreen()
				draw.SimpleText(ply:GetNWString("Name"), "MuR_FontDef", pos.x, pos.y + 8, Color(100,100,100,100), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				draw.SimpleText(MuR.Language["teammate"], "MuR_FontDef", pos.x, pos.y + 16, Color(0,150,0,100), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end
			if ply ~= LocalPlayer() and IsValid(LocalPlayer():GetNW2Entity("CurrentTarget")) and LocalPlayer():GetNW2Entity("CurrentTarget") == ply and ply:Alive() and LocalPlayer():IsLineOfSightClear(ply) then
				local pos = ply:EyePos():ToScreen()
				draw.SimpleText(MuR.Language["target"], "Trebuchet18", pos.x, pos.y + 16, Color(255,195,0,100), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end
			if LocalPlayer():GetObserverMode() > 0 and ply:Alive() and LocalPlayer():GetObserverTarget() ~= ply then
				local pos = ply:EyePos():ToScreen()
				draw.SimpleTextOutlined(ply:Nick(), "MuR_FontDef", pos.x, pos.y, Color(225, 225, 225), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
			end
		end
	end
end)

hook.Add("PreDrawHalos", "DrawLootHalo", function()
	if !MuR:GetClient("blsd_nohud") then return end
	local ply = LocalPlayer()
	local pos = ply:GetPos()
	local entsInRange = ents.FindInSphere(pos, 128)
	local lootEnts, wepsEnts = {}, {}

	for i = 1, #entsInRange do
		local ent = entsInRange[i]

		if string.match(ent:GetClass(), "mur_") and not IsValid(ent:GetOwner()) and not ent:GetNoDraw() then
			if ent.Melee or ent:IsWeapon() and ent:GetMaxClip1() > 0 then
				table.insert(wepsEnts, ent)
			else
				table.insert(lootEnts, ent)
			end
		end
	end

	halo.Add(lootEnts, Color(200, 200, 0), 2, 2, 1, true, false)
	halo.Add(wepsEnts, Color(255, 0, 0), 2, 2, 1, true, false)
end)

------------------------------------------------------------------------------------------------------

function MuR:ShowStartScreen(gamemode, class)
	if MuR.EnableDebug then return end
    MuR.DrawHUD = false
    surface.PlaySound("murdered/theme/theme_gamemode" .. gamemode .. ".mp3")
	if gamemode == 2 and class == "Shooter" then
		RunConsoleCommand("stopsound")
	end
    MuR.GamemodeCount = gamemode
    local ply = LocalPlayer()
    
    if not class then
        class = ply:GetNW2String("Class")
    end
    
	local gamemodeDel, gamemodeDelNum = CurTime(), math.random(0,1)
	local gamemodeBG = Material("murdered/modes/gamemode" .. gamemode .. ".png", "")
	local gamemodeBG2 = Material("murdered/modes/gamemode" .. gamemode .. "h.png", "")
	local gamemodeData = {name = "gamename"..gamemode, desc = "gamedesc"..gamemode}
	if gamemodeBG:IsError() and gamemode != 14 then
		gamemodeBG = Material("murdered/black.png", "")
		gamemodeBG2 = Material("murdered/black.png", "")
	end
    
    local classInfo = {
        ["Civilian"] = {name = "civilian", color = Color(100, 150, 200), desc = "civilian_desc", other = ""},
        ["Killer"] = {name = "murderer", color = Color(150, 10, 10), desc = "murderer_desc", other = ""},
        ["Attacker"] = {name = "rioter", color = Color(180, 80, 80), desc = "rioter_desc", other = ""},
        ["Traitor"] = {name = "traitor", color = Color(150, 10, 10), desc = "traitor_desc", other = ""},
        ["Zombie"] = {name = "zombie", color = Color(80, 0, 0), desc = "zombie_desc", other = ""},
        ["Maniac"] = {name = "maniac", color = Color(150, 10, 10), desc = "maniac_desc", other = ""},
        ["Shooter"] = {name = "shooter", color = Color(150, 10, 10), desc = "shooter_desc", other = ""},
        ["Terrorist"] = {name = "terrorist", color = Color(160, 20, 20), desc = "terrorist_desc", other = ""},
        ["Terrorist2"] = {name = "terrorist", color = Color(160, 20, 20), desc = "terrorist_desc2", other = ""},
        ["Hunter"] = {name = "civilian", color = Color(50, 75, 175), desc = "defender_desc", other = "defender_var_heavy"},
        ["Officer"] = {name = "officer", color = Color(25, 25, 255), desc = "officer_desc", other = ""},
		["ArmoredOfficer"] = {name = "swat", color = Color(25, 25, 255), desc = "swat_desc", other = ""},
        ["FBI"] = {name = "fbiagent", color = Color(25, 25, 255), desc = "fbiagent_desc", other = ""},
        ["Riot"] = {name = "riotpolice", color = Color(25, 25, 255), desc = "riotpolice_desc", other = ""},
        ["SWAT"] = {name = "swat", color = Color(25, 25, 255), desc = "swat_desc", other = ""},
        ["Defender"] = {name = "civilian", color = Color(50, 75, 175), desc = "defender_desc", other = "defender_var_light"},
        ["Soldier"] = {name = "soldier", color = Color(250, 150, 0), desc = "soldier_desc", other = ""},
        ["Medic"] = {name = "medic", color = Color(50, 120, 50), desc = "medic_desc", other = ""},
        ["Builder"] = {name = "builder", color = Color(50, 120, 50), desc = "builder_desc", other = ""},
        ["Criminal"] = {name = "criminal", color = Color(255, 120, 60), desc = "criminal_desc", other = ""},
        ["HeadHunter"] = {name = "headhunter", color = Color(255, 120, 60), desc = "headhunter_desc", other = ""},
        ["Witness"] = {name = "witness", color = Color(50, 120, 50), desc = "witness_desc", other = ""},
        ["Security"] = {name = "security", color = Color(25, 25, 255), desc = "security_desc", other = ""},
		["GangRed"] = {name = "gangred", color = Color(200, 50, 50), desc = "gang_desc", other = ""},
		["GangGreen"] = {name = "ganggreen", color = Color(50, 200, 50), desc = "gang_desc", other = ""}
    }
    
    local alpha = 300
    local alphago = false
    local lerppos = -We(400)
    local needlerppos = 0
    local rotationAngle = 0
    local pulseEffect = 0
    local versionY = -He(100)
    local versionScale = 0
    local particles = {}
    
    for i = 1, 30 do
        particles[i] = {
            x = math.random(0, ScrW()),
            y = math.random(0, ScrH()),
            size = math.random(1, 4),
            speed = math.random(10, 30),
            alpha = math.random(50, 150)
        }
    end
    
    local classData = classInfo[class] or classInfo["Civilian"]
	local sizeX, sizeY = ScrW()*1.1, ScrH()*1.1
	local size2X, size2Y = ScrW(), ScrH()
	local stX, stY = (ScrW()-sizeX)/2, (ScrH()-sizeY)/2
	local offX, offY = stX, stY
	local off2X, off2Y = 0, 0
    
    timer.Simple(10, function()
        alphago = true
        needlerppos = We(250)
    end)

    hook.Add("HUDPaint", "MurderedStartScreen", function()
        local curTime = CurTime()

		if gamemode == 14 and gamemodeDel < CurTime() then
			gamemodeDel = CurTime()+0.4
			gamemodeDelNum = math.abs(gamemodeDelNum-1)
			gamemodeBG = Material("murdered/modes/gamemode14_" .. gamemodeDelNum .. ".png", "")
		end
        
        if alphago then
            alpha = math.min(alpha + FrameTime() / 0.005, 255)
            lerppos = Lerp(FrameTime()/4, lerppos, needlerppos)
            versionY = Lerp(FrameTime()/3, versionY, He(500))
            versionScale = Lerp(FrameTime()/3, versionScale, 1)
        else
            alpha = math.max(alpha - FrameTime() / 0.015, 0)
            lerppos = Lerp(FrameTime(), lerppos, needlerppos)
            versionY = Lerp(FrameTime()/2, versionY, He(530))
            versionScale = Lerp(FrameTime()/2, versionScale, 0.85)
        end
        
        rotationAngle = math.sin(curTime * 0.5) * 2
        pulseEffect = math.sin(curTime * 3) * 5
        
        local classname = MuR.Language[classData.name]
        local otherdesc = MuR.Language[classData.other] or ""
        local desc = MuR.Language[classData.desc]
        local color = classData.color
        local gamename = MuR.Language[gamemodeData.name]
        local gamedesc = MuR.Language[gamemodeData.desc]
        
        local pulsingColor = color
        
        local titleColorPulse = Color(
            200 + math.sin(curTime*3)*25,
            175 + math.cos(curTime*3)*25,
            math.abs(math.sin(curTime*2.5))*25,
            255
        )

		local scrW, scrH = ScrW(), ScrH()
		local t = CurTime()

		local bg_sway = 30
		local bg_speed_x = 0.4
		local bg_speed_y = 0.6

		local char_sway = 60
		local char_speed_x = 0.5
		local char_speed_y = 0.5

		local idealX = (scrW - sizeX) / 2 + math.sin(t * bg_speed_x) * bg_sway
		local idealY = (scrH - sizeY) / 2 + math.cos(t * bg_speed_y) * bg_sway

		offX = math.Clamp(idealX, scrW - sizeX, 0)
		offY = math.Clamp(idealY, scrH - sizeY, 0)

		local ideal2X = (scrW - size2X) / 2 + math.sin(t * char_speed_x) * char_sway
		local ideal2Y = (scrH - size2Y) / 2 + math.cos(t * char_speed_y) * char_sway

		off2X = math.Clamp(ideal2X, -scrW/4, scrW/4)
		off2Y = math.Clamp(ideal2Y, 0, scrH/4)

		surface.SetDrawColor(0, 0, 0)
		surface.DrawRect(0, 0, scrW, scrH)

		surface.SetMaterial(gamemodeBG)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawTexturedRect(offX, offY, sizeX, sizeY)

		surface.SetMaterial(gamemodeBG2)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawTexturedRect(off2X, off2Y, size2X, size2Y)

        surface.SetDrawColor(pulsingColor.r, pulsingColor.g, pulsingColor.b, 5)
        surface.SetMaterial(vinmat)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        
        for i = 1, #particles do
            local p = particles[i]
            p.y = (p.y + p.speed * FrameTime()) % ScrH()
            
            surface.SetDrawColor(color.r, color.g, color.b, p.alpha)
            surface.DrawRect(p.x, p.y, p.size, p.size)
        end
        
        local centerX = ScrW() / 2 + lerppos
        
        local gamemodeFullText = MuR.Language["startscreen_gamemode"] .. gamename
        drawTextRotated(gamemodeFullText, "MuR_Font6", 
            centerX, 
            ScrH() / 2 - He(450) + math.sin(curTime*1.5)*He(8), 
            titleColorPulse, 
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 
            rotationAngle)
            
		local col = Color(255, 255, 255, 220 + pulseEffect*10)
		if gamemode == 9 then
			col = Color(0, 0, 0, 200 + pulseEffect*10)
		end
		drawTextRotated(gamedesc, "MuR_Font2", 
            centerX + math.cos(curTime)*We(10), 
            ScrH() / 2 - He(400) + math.sin(curTime)*He(5), 
            col, 
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
			rotationAngle)
            
        local roleY = ScrH() / 2 - He(60 + pulseEffect)
        draw.SimpleText(MuR.Language["startscreen_role"], "MuR_Font5", 
            centerX, roleY, col, 
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
        local sizeMultiplier = 1.0 + math.abs(math.sin(curTime*2))*0.1
        local classX = centerX
        local classY = ScrH() / 2
        
        drawTextRotated(classname, "MuR_Font6", 
            classX, classY, 
            pulsingColor, 
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 
            math.sin(curTime*0.7)*3, 
            sizeMultiplier, sizeMultiplier)
        
        if otherdesc ~= "" then
            drawTextRotated(otherdesc, "MuR_Font2", 
                centerX, 
                ScrH() / 2 + He(35), 
                Color(150, 150, 250, 200 + math.sin(curTime*2)*55), 
                TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 
				math.sin(curTime*0.7)*3, 
				sizeMultiplier, sizeMultiplier)
        end
        
        draw.SimpleText(desc, "MuR_Font2", 
            centerX, 
            ScrH() / 2 + He(350) + math.sin(curTime)*He(8), 
            color_white, 
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        surface.SetDrawColor(0, 0, 0, alpha)
        surface.DrawRect(0, 0, ScrW(), ScrH())
    end)

    timer.Simple(12, function()
        if IsValid(ply) then
            ply:ScreenFade(SCREENFADE.IN, color_black, 1, 0)
        end

        MuR.DrawHUD = true
        hook.Remove("HUDPaint", "MurderedStartScreen")
    end)
end

function drawTextRotated(text, font, x, y, color, alignX, alignY, angle, scaleX, scaleY)
	render.PushFilterMag( TEXFILTER.ANISOTROPIC )
    render.PushFilterMin( TEXFILTER.ANISOTROPIC )

    scaleX = scaleX or 1
    scaleY = scaleY or scaleX
    
    local m = Matrix()
	m:Translate(Vector(x, y, 0))
    m:SetAngles(Angle(0, angle, 0))
    m:SetScale(Vector(scaleX, scaleY, 1))

	surface.SetFont(font)
	local w, h = surface.GetTextSize(text)
	m:Translate(Vector( -w / 2, -h / 2, 0 ))

    cam.PushModelMatrix(m, true)
        draw.SimpleText(text, font, w/2, h/2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.PopModelMatrix()

	render.PopFilterMag()
    render.PopFilterMin()
end

net.Receive("MuR.StartScreen", function()
	local float = net.ReadFloat()
	local str = net.ReadString()
	MuR:ShowStartScreen(float, str)
end)

function GM:HUDDrawTargetID()
end

function GM:HUDDrawPickupHistory()
end

---------------------------------------------------------------------------------------------------------------------

local function CreateFonts()
	surface.CreateFont("MuR_FontDef", {
		font = "VK Sans Display DemiBold",
		extended = true,
		size = He(12),
		antialias = true
	})

	surface.CreateFont("MuR_Font0", {
		font = "VK Sans Display DemiBold",
		extended = true,
		size = He(12),
		antialias = true
	})

	surface.CreateFont("MuR_Font1", {
		font = "VK Sans Display DemiBold",
		extended = true,
		size = He(16),
		antialias = true
	})

	surface.CreateFont("MuR_Font2", {
		font = "VK Sans Display DemiBold",
		extended = true,
		size = He(24),
		antialias = true
	})

	surface.CreateFont("MuR_Font3", {
		font = "VK Sans Display DemiBold",
		extended = true,
		size = He(32),
		antialias = true
	})

	surface.CreateFont("MuR_Font4", {
		font = "VK Sans Display DemiBold",
		extended = true,
		size = He(40),
		antialias = true
	})

	surface.CreateFont("MuR_Font5", {
		font = "VK Sans Display DemiBold",
		extended = true,
		size = He(48),
		antialias = true
	})

	surface.CreateFont("MuR_Font6", {
		font = "VK Sans Display DemiBold",
		extended = true,
		size = He(56),
		antialias = true
	})
end
CreateFonts()
hook.Add("OnScreenSizeChanged", "MuR.Fonts", function()
	CreateFonts()
end)