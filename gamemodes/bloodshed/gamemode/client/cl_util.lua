local meta = FindMetaTable("Player")

net.Receive("MuR.EntityPlayerColor", function()
	local ent = net.ReadEntity()
	local col = net.ReadVector()

	if IsValid(ent) and isvector(col) then
		function ent:GetPlayerColor()
			return col
		end
	end
end)

hook.Add("Think", "MuR_Execute", function()
	RunConsoleCommand("r_decals", 9999)
end)

-----Finish Screen-----
local logoicon = Material("murdered/logo.png", "noclamp")
local killedicon = Material("murdered/result/en/killed.png")
local losedicon = Material("murdered/result/en/losed.png")
local arrestedicon = Material("murdered/result/en/arrested.png")
local aliveicon = Material("murdered/result/en/alive.png")
local zombieicon = Material("murdered/result/en/infected.png")
if MuR.CurrentLanguage == "ru" then
	logoicon = Material("murdered/logo.png", "noclamp")
	killedicon = Material("murdered/result/ru/killed.png")
	losedicon = Material("murdered/result/ru/losed.png")
	arrestedicon = Material("murdered/result/ru/arrested.png")
	aliveicon = Material("murdered/result/ru/alive.png")
	zombieicon = Material("murdered/result/ru/infected.png")
end

local bd_bg = Color(10, 0, 0, 250)
local bd_grid = Color(100, 10, 10, 75)
local bd_primary = Color(200, 20, 20)
local bd_hover = Color(255, 50, 50)
local bd_panel_bg = Color(30, 10, 10, 180)
local bd_panel_border = Color(180, 20, 20, 200)

local function CreateFinishPanel(type, isvote)
	local text, plytext = "", ""

	if type == "innocent" then
		text = MuR.Language["innocentswin"]
	elseif type == "traitor" then
		text = MuR.Language["traitorwin"]
	end

	if LocalPlayer():GetNW2Float('DeathStatus') == 0 then
		plytext = MuR.Language["yousurvived"]
		surface.PlaySound("murdered/theme/win_theme.wav")
	elseif LocalPlayer():GetNW2Float('DeathStatus') == 3 then
		plytext = MuR.Language["youjailed"]
		surface.PlaySound("murdered/theme/lose_theme.wav")
	else
		plytext = MuR.Language["youdied"]
		surface.PlaySound("murdered/theme/lose_theme.wav")
	end

	hook.Add("Think", "ClickerFixMenu", function()
		gui.EnableScreenClicker(input.IsKeyDown(KEY_LALT))
	end)
	MuR.DrawHUD = false

	local dp = vgui.Create("DFrame")
	dp:SetPos(0, 0)
	dp:SetSize(ScrW(), ScrH())
	dp:SetTitle("")
	dp:ShowCloseButton(false)
	dp:SetDraggable(false)
    dp:SetAlpha(0)
    dp:AlphaTo(255, 1.5, 0)

	dp:AlphaTo(0, 2, 15, function()
		if IsValid(dp) then dp:Remove() end
		MuR.DrawHUD = true
		hook.Remove("Think", "ClickerFixMenu")
		gui.EnableScreenClicker(false)
	end)

    local textAnimStart = CurTime()
    local glitch_active = false
    local glitch_end_time, glitch_next_time = 0, CurTime() + math.Rand(3, 5)

    local function DrawShadowedText(txt, font, x, y, color, xalign, yalign)
        draw.SimpleText(txt, font, x + 2, y + 2, Color(0, 0, 0, 180), xalign, yalign)
        draw.SimpleText(txt, font, x, y, color, xalign, yalign)
    end
    
    local function DrawPlayerText(txt, font, x, y, color, xalign, yalign)
        draw.SimpleText(txt, font, x + 3, y + 3, Color(0, 0, 0, 255), xalign, yalign)
        draw.SimpleText(txt, font, x, y, color, xalign, yalign)
    end

    local voteButton, scrollPanel

	dp.Paint = function(self, w, h)
        if not glitch_active and CurTime() > glitch_next_time then
            glitch_active = true
            glitch_end_time = CurTime() + math.Rand(0.15, 0.4)
            glitch_next_time = CurTime() + math.Rand(2, 5)
        elseif CurTime() > glitch_end_time then
            glitch_active = false
        end

        local smooth_shake_x = math.sin(RealTime() * 2) * 2
        local smooth_shake_y = math.cos(RealTime() * 2) * 2
        
        local glitch_shake_x = glitch_active and math.Rand(-2, 2) or 0
        local glitch_shake_y = glitch_active and math.Rand(-2, 2) or 0

        local total_shake_x = smooth_shake_x + glitch_shake_x
        local total_shake_y = smooth_shake_y + glitch_shake_y

        if IsValid(scrollPanel) then scrollPanel:SetPos(We(50) + total_shake_x, He(250) + total_shake_y) end
        if IsValid(voteButton) then voteButton:SetPos(ScrW() / 2 + We(220) + total_shake_x, ScrH() - He(170) + total_shake_y) end

        draw.RoundedBox(0, total_shake_x - 10, total_shake_y - 10, w + 20, h + 20, bd_bg)
        local gridSize = 50
        surface.SetDrawColor(bd_grid)
        for i = 0, w / gridSize do surface.DrawRect(i * gridSize - (RealTime() * 15) % gridSize + total_shake_x, total_shake_y, 1, h) end
        for i = 0, h / gridSize do surface.DrawRect(total_shake_x, i * gridSize - (RealTime() * 15) % gridSize + total_shake_y, w, 1) end

        surface.SetDrawColor(255, 255, 255, 150)
        surface.SetMaterial(logoicon)
        surface.DrawTexturedRect(ScrW() / 2 - We(100) + total_shake_x, ScrH() / 2 - He(200) + total_shake_y, We(1542*0.5), He(824*0.5))

        surface.SetDrawColor(bd_primary)
        surface.DrawRect(We(50) + total_shake_x, He(170) + total_shake_y, We(500), 2)
        surface.DrawRect(We(598) + total_shake_x, total_shake_y, 2, h)

        DrawShadowedText(MuR.Language["roundended"], "MuR_Font6", We(50) + total_shake_x, He(50) + total_shake_y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        DrawShadowedText(MuR.Language["peoplelist"], "MuR_Font2", We(50) + total_shake_x, He(210) + total_shake_y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        DrawShadowedText(plytext, "MuR_Font3", ScrW() / 2 + We(300) + total_shake_x, ScrH() / 2 - He(250) + total_shake_y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        DrawShadowedText(MuR.Language["holdalt"], "MuR_Font1", ScrW() / 2 + We(300) + total_shake_x, ScrH() - He(20) + total_shake_y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

        local timePassed = CurTime() - textAnimStart
        local charsToShow = math.min(string.len(text), math.floor(timePassed * 10))
        local partialText = utf8.sub(text, 1, charsToShow)
        if glitch_active then
            draw.SimpleText(partialText, "MuR_Font2", We(50) + total_shake_x + math.Rand(-5,5), He(100) + total_shake_y, Color(255,0,0,100), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
        DrawShadowedText(partialText, "MuR_Font2", We(50) + total_shake_x, He(100) + total_shake_y, bd_primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        if isvote then
            DrawShadowedText(MuR.Language["log_vote"], "MuR_Font1", ScrW() / 2 + We(300) + total_shake_x, ScrH() - He(200) + total_shake_y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            DrawShadowedText(MuR.Language["log_vote_info"]..MuR.Data["VoteLog"].."/"..player.GetCount(), "MuR_Font1", ScrW() / 2 + We(300) + total_shake_x, ScrH() - He(180) + total_shake_y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        end
	end

	if isvote then
		voteButton = vgui.Create("DButton", dp)
		voteButton:SetPos(ScrW() / 2 + We(220), ScrH() - He(170))
		voteButton:SetSize(We(160), He(40))
		voteButton:SetText("")
		voteButton.Paint = function(self, w, h)
            local color = self:IsHovered() and bd_hover or bd_primary
			draw.RoundedBox(4, 0, 0, w, h, Color(0,0,0,150))
            surface.SetDrawColor(color)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
			DrawShadowedText(MuR.Language["log_vote_button"], "MuR_Font2", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		voteButton.DoClick = function(self)
			net.Start("MuR.ShowLogScreen")
			net.SendToServer()
			surface.PlaySound("buttons/combine_button1.wav")
			self:Remove()
		end
	end

	scrollPanel = vgui.Create("DScrollPanel", dp)
	scrollPanel:SetSize(We(500), He(850))
	scrollPanel:SetPos(We(60), He(280))
	scrollPanel.Paint = function() end
    local sbar = scrollPanel:GetVBar()
    sbar:SetSize(We(10), sbar:GetSize())
    sbar.Paint = function() end
    sbar.btnUp.Paint = function(s,w,h) draw.RoundedBox(2,0,0,w,h,bd_primary) end
    sbar.btnDown.Paint = function(s,w,h) draw.RoundedBox(2,0,0,w,h,bd_primary) end
    sbar.btnGrip.Paint = function(s,w,h) draw.RoundedBox(2,0,0,w,h,bd_hover) end

	for _, ply in pairs(player.GetAll()) do
		local nwc = ply:GetNW2String("Class")
		local pname = ply:Nick() .. " (" .. ply:GetNWString("Name") .. ")"
		local classname = MuR.Language["civilian"]
		local jcolor = Color(100, 150, 200)

		if nwc == "Killer" then classname = MuR.Language["murderer"]; jcolor = Color(200, 50, 50)
		elseif nwc == "Traitor" then classname = MuR.Language["traitor"]; jcolor = Color(200, 50, 50)
		elseif nwc == "Attacker" then classname = MuR.Language["rioter"]; jcolor = Color(200, 50, 50)
		elseif nwc == "Terrorist" or nwc == "Terrorist2" then classname = MuR.Language["terrorist"]; jcolor = Color(200, 50, 50)
		elseif nwc == "Maniac" then classname = MuR.Language["maniac"]; jcolor = Color(200, 50, 50)
		elseif nwc == "Shooter" then classname = MuR.Language["shooter"]; jcolor = Color(200, 50, 50)
		elseif nwc == "Zombie" then classname = MuR.Language["zombie"]; jcolor = Color(200, 50, 50)
		elseif nwc == "Hunter" or nwc == "Defender" then classname = MuR.Language["defender"]; jcolor = Color(50, 75, 175)
		elseif nwc == "Medic" then classname = MuR.Language["medic"]; jcolor = Color(50, 120, 50)
		elseif nwc == "Builder" then classname = MuR.Language["builder"]; jcolor = Color(50, 120, 50)
		elseif nwc == "Soldier" then classname = MuR.Language["soldier"]; jcolor = Color(250, 150, 0)
		elseif nwc == "Officer" then classname = MuR.Language["officer"]; jcolor = Color(75, 100, 200)
		elseif nwc == "FBI" then classname = MuR.Language["fbiagent"]; jcolor = Color(75, 100, 200)
		elseif nwc == "Riot" then classname = MuR.Language["riotpolice"]; jcolor = Color(75, 100, 200)
		elseif nwc == "SWAT" or nwc == "ArmoredOfficer" then classname = MuR.Language["swat"]; jcolor = Color(75, 100, 200)
		elseif nwc == "Criminal" then classname = MuR.Language["criminal"]; jcolor = Color(255, 120, 60)
		elseif nwc == "HeadHunter" then classname = MuR.Language["headhunter"]; jcolor = Color(255, 120, 60)
		elseif nwc == "Witness" then classname = MuR.Language["witness"]; jcolor = Color(50, 120, 50)
		elseif nwc == "Security" then classname = MuR.Language["security"]; jcolor = Color(25, 25, 255)
		elseif nwc == "GangRed" then classname = MuR.Language["gangred"]; jcolor = Color(200, 50, 50)
		elseif nwc == "GangGreen" then classname = MuR.Language["ganggreen"]; jcolor = Color(50, 200, 50)
		end

		local playerPanel = vgui.Create("DPanel", scrollPanel)
		playerPanel:SetSize(We(480), He(64))
		playerPanel:Dock(TOP)
		playerPanel:DockMargin(0, 0, 10, 5)
		playerPanel.Paint = function(self, w, h)  
			draw.RoundedBox(4, 0, 0, w, h, Color(0,0,0,50))
            surface.SetDrawColor(bd_panel_border)
            surface.DrawOutlinedRect(0, 0, w, h)
		end
		playerPanel.PaintOver = function(self, w, h)
			local icon
			if IsValid(ply) then
                local status = ply:GetNW2Float('DeathStatus')
                local class = ply:GetNW2String('Class')
                if class == 'Zombie' then icon = zombieicon
                elseif status == 0 and ply:Alive() or status == 4 then icon = aliveicon
                elseif status == 2 then icon = killedicon
                elseif status == 3 then icon = arrestedicon
                else icon = losedicon end
            else
                icon = losedicon
            end
            if icon then
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(icon)
                surface.DrawTexturedRect(0, 0, w, h)
            end
		end
		
		local avatar = vgui.Create("AvatarImage", playerPanel)
		avatar:SetSize(He(48), He(48))
		avatar:SetPos(We(8), He(8))
		avatar:SetPlayer(ply, 64)

		local name = vgui.Create("DLabel", playerPanel)
		name:SetText("")
		name:SetPos(He(48) + We(16), He(16))
		name:SetSize(We(380), He(24))
        name.Paint = function(s,w,h) 
			DrawPlayerText(pname, "MuR_FontDef", 0, 0, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) 
		end

		local class = vgui.Create("DLabel", playerPanel)
		class:SetText("")
		class:SetPos(He(48) + We(16), He(32))
		class:SetSize(We(380), He(16))
        class.Paint = function(s,w,h) 
			DrawPlayerText(classname, "MuR_FontDef", 0, 0, jcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) 
		end

		local b = vgui.Create("DButton", avatar)
		b:SetPos(0, 0)
		b:SetSize(He(48), He(48))
		b:SetText("")
		b.id = ply:SteamID64() or ""
		b.Paint = function() end
		b.DoClick = function(self)
			if self.id ~= "" then
				gui.OpenURL("https://steamcommunity.com/profiles/" .. self.id)
			end
		end
	end
end

net.Receive("MuR.FinalScreen", function()
	local str = net.ReadString()
	local vote = net.ReadBool()
	CreateFinishPanel(str, vote)
end)

-----ViewPunch Remake-----
local PUNCH_DAMPING = 9
local PUNCH_SPRING_CONSTANT = 65
local vp_is_calc = false
local vp_punch_angle = Angle()
local vp_punch_angle_velocity = Angle()
local vp_punch_angle_last = vp_punch_angle

hook.Add("Think", "mur_viewpunch_decay", function()
	if not vp_punch_angle:IsZero() or not vp_punch_angle_velocity:IsZero() then
		vp_punch_angle = vp_punch_angle + vp_punch_angle_velocity * FrameTime()
		local damping = 1 - (PUNCH_DAMPING * FrameTime())

		if damping < 0 then
			damping = 0
		end

		vp_punch_angle_velocity = vp_punch_angle_velocity * damping
		local spring_force_magnitude = math.Clamp(PUNCH_SPRING_CONSTANT * FrameTime(), 0, 0.2 / FrameTime())
		vp_punch_angle_velocity = vp_punch_angle_velocity - vp_punch_angle * spring_force_magnitude
		local x, y, z = vp_punch_angle:Unpack()
		vp_punch_angle = Angle(math.Clamp(x, -89, 89), math.Clamp(y, -179, 179), math.Clamp(z, -89, 89))
	else
		vp_punch_angle = Angle()
		vp_punch_angle_velocity = Angle()
	end
end)

hook.Add("Think", "mur_viewpunch_apply", function()
	if vp_punch_angle:IsZero() and vp_punch_angle_velocity:IsZero() then return end
	if LocalPlayer():InVehicle() then return end
	LocalPlayer():SetEyeAngles(LocalPlayer():EyeAngles() + vp_punch_angle - vp_punch_angle_last)
	vp_punch_angle_last = vp_punch_angle
end)

local function SetViewPunchAngles(angle)
	if not angle then return end
	vp_punch_angle = angle
end

local function SetViewPunchVelocity(angle)
	if not angle then return end
	vp_punch_angle_velocity = angle * 20
end

local function Viewpunch(angle)
	if not angle then return end
	vp_punch_angle_velocity = vp_punch_angle_velocity + angle * 20
end

function meta:ViewPunchClient(angle)
	--if not IsFirstTimePredicted() then return end
	Viewpunch(angle)
end

net.Receive("MuR.ViewPunch", function()
	local ang = net.ReadAngle()
	Viewpunch(ang)
end)

net.Receive("MuR.SetHull", function()
	local tab = net.ReadTable()
	if !IsValid(LocalPlayer()) then return end
	LocalPlayer():SetHull(tab[1], tab[2])
	LocalPlayer():SetHullDuck(tab[3], tab[4])
end)

-------------------------

local function CreateCharacterVoicePanel()
	local frame = vgui.Create("DFrame")
	frame:SetSize(We(300), He(300))
	frame:Center()
	frame:SetTitle(MuR.Language["dialogue_menu"])
	frame:MakePopup()
	frame.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
	end

	local scrollPanel = vgui.Create("DScrollPanel", frame)
	scrollPanel:Dock(FILL)

	if LocalPlayer():IsRolePolice() then
		for i = 101, 106 do
			local text = MuR.Language["dialogue_menu"..i]
			local button = scrollPanel:Add("DButton")
			button:SetText(text)
			button:Dock(TOP)
			button:DockMargin(2, 5, 2, 0)
			button.DoClick = function()
				net.Start("MuR.VoiceLines")
				net.WriteFloat(i)
				net.SendToServer()
				frame:Remove()
			end
		end
	else
		for i = 1, 14 do
			local text = MuR.Language["dialogue_menu"..i]
			local button = scrollPanel:Add("DButton")
			button:SetText(text)
			button:Dock(TOP)
			button:DockMargin(2, 5, 2, 0)
			button.DoClick = function()
				net.Start("MuR.VoiceLines")
				net.WriteFloat(i)
				net.SendToServer()
				frame:Remove()
			end
		end
	end
end
concommand.Add("mur_voicepanel", CreateCharacterVoicePanel)