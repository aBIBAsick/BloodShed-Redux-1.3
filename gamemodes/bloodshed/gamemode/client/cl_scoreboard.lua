local scoreboard = nil

local THEME = {
    background = Color(15, 15, 20, 250),
    accent = Color(180, 40, 40),
    panel = Color(25, 25, 30, 255),
    text = Color(255, 255, 255),
    textDark = Color(200, 200, 200),
    success = Color(40, 180, 120),
    danger = Color(220, 50, 50)
}

local function CreateScoreboard()
    if IsValid(scoreboard) then return end
    
    scoreboard = vgui.Create("DPanel")
    scoreboard:SetSize(We(580), He(700))
    scoreboard:Center()
    scoreboard:AlphaTo(0, 0)
    scoreboard:AlphaTo(255, 0.2)
    scoreboard:MakePopup()
    scoreboard:SetKeyboardInputEnabled(false)

    scoreboard.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, THEME.background)
        draw.RoundedBox(8, 0, 0, w, He(80), THEME.panel)
        surface.SetDrawColor(THEME.accent)
        surface.DrawRect(0, He(80), w, He(2))
    end

    local title = vgui.Create("DLabel", scoreboard)
    title:SetText(MuR.Language["plylist"] or "Player List")
    title:SetFont("MuR_Font3")
    title:SetTextColor(THEME.text)
    title:SetPos(We(30), He(20))
    title:SizeToContents()

    local gamemode = vgui.Create("DLabel", scoreboard)
    local gamemodeText = (MuR.Language["startscreen_gamemode"] or "Gamemode: ") .. "None"
    if MuR.GamemodeCount and MuR.GamemodeCount > 0 then
        gamemodeText = (MuR.Language["startscreen_gamemode"] or "Gamemode: ") .. (MuR.Language["gamename"..MuR.GamemodeCount] or "Unknown")
    end
    if MuR.EnableDebug then
        gamemodeText = (MuR.Language["startscreen_gamemode"] or "Gamemode: ") .. "Sandbox"
    end
    gamemode:SetText(gamemodeText)
    gamemode:SetFont("MuR_Font1")
    gamemode:SetTextColor(THEME.textDark)
    gamemode:SetPos(We(30), He(45))
    gamemode:SizeToContents()

    local playerCount = vgui.Create("DLabel", scoreboard)
    playerCount:SetText("Bloodshed: Redux")
    playerCount:SetFont("MuR_Font3")
    playerCount:SetTextColor(THEME.accent)
    playerCount:SetPos(scoreboard:GetWide() - We(250), He(25))
	playerCount:SetContentAlignment(6)
    playerCount:SizeToContents()

    local scrollPanel = vgui.Create("DScrollPanel", scoreboard)
    scrollPanel:SetPos(We(10), He(90))
    scrollPanel:SetSize(We(580), He(600))
    
    local sbar = scrollPanel:GetVBar()
    sbar:SetWide(We(8))
    function sbar:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(THEME.panel.r, THEME.panel.g, THEME.panel.b, 100))
    end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, THEME.accent)
    end

    local playerList = vgui.Create("DListLayout", scrollPanel)
    playerList:SetSize(We(560), He(600))
    playerList:DockMargin(We(5), He(5), We(5), He(5))

    local players = player.GetAll()
    table.sort(players, function(a, b)
        return a:Ping() < b:Ping()
    end)

    for _, ply in ipairs(players) do
        local playerPanel = vgui.Create("DPanel")
        playerPanel:SetHeight(He(70))
        playerPanel:DockMargin(0, 0, 0, He(5))

        playerPanel.Paint = function(self, w, h)
            if ply == LocalPlayer() then
				draw.RoundedBox(8, 0, 0, w, h, Color(THEME.accent.r/4, THEME.accent.g/4, THEME.accent.b/4))

                surface.SetDrawColor(THEME.accent.r, THEME.accent.g, THEME.accent.b, 100)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
                
                surface.SetDrawColor(THEME.accent)
                surface.DrawRect(0, 0, We(3), h)
			else
				draw.RoundedBox(8, 0, 0, w, h, THEME.panel)
            end
        end

        local avatarImage = vgui.Create("AvatarImage", playerPanel)
        avatarImage:SetPos(We(10), He(10))
        avatarImage:SetSize(We(50), He(50))
        avatarImage:SetPlayer(ply, 64)
        
        local avatarButton = vgui.Create("DButton", avatarImage)
        avatarButton:SetPos(0, 0)
        avatarButton:SetSize(We(50), He(50))
        avatarButton:SetText("")
        avatarButton.id = ply:SteamID64() or ""

        avatarButton.DoClick = function(self)
            gui.OpenURL("https://steamcommunity.com/profiles/" .. self.id)
        end

        avatarButton.Paint = function() end

        local nameLabel = vgui.Create("DLabel", playerPanel)
        nameLabel:SetText(ply:Nick())
        nameLabel:SetPos(We(70), He(12))
        nameLabel:SetSize(We(300), He(25))
        nameLabel:SetFont("MuR_Font3")
        nameLabel:SetTextColor(THEME.text)

        local guiltLabel = vgui.Create("DLabel", playerPanel)
        guiltLabel:SetText((MuR.Language["guilt:"] or "Guilt: ") .. ply:GetNW2Float('Guilt', 0) .. "%")
        guiltLabel:SetPos(We(70), He(35))
        guiltLabel:SetSize(We(200), He(20))
        guiltLabel:SetFont("MuR_Font1")
        guiltLabel:SetTextColor(THEME.textDark)

        local ping = ply:Ping()
        local pingColor = THEME.success
        if ping >= 200 then
            pingColor = THEME.danger
		elseif ping >= 100 then
            pingColor = Color(255, 200, 0)
        end

        local pingLabel = vgui.Create("DLabel", playerPanel)
        pingLabel:SetText(ping .. " ms")
        pingLabel:SetPos(We(480), He(25))
        pingLabel:SetSize(We(60), He(20))
        pingLabel:SetFont("MuR_Font1")
        pingLabel:SetTextColor(pingColor)
        pingLabel:SetContentAlignment(5)

        if ply ~= LocalPlayer() then
            local muteButton = vgui.Create("DButton", playerPanel)
            muteButton:SetPos(We(420), He(23))
            muteButton:SetSize(We(24), He(24))
            muteButton:SetText("")

            muteButton.Paint = function(self, w, h)
                if IsValid(ply) then
                    local isMuted = ply:IsMuted()
                    local iconColor = isMuted and THEME.danger or THEME.textDark
                    
                    if self:IsHovered() then
                        draw.RoundedBox(4, 0, 0, w, h, Color(THEME.accent.r, THEME.accent.g, THEME.accent.b, 50))
                    end
                    
                    local muteIcon = isMuted and "icon16/sound_mute.png" or "icon16/sound.png"
                    surface.SetDrawColor(iconColor)
                    surface.SetMaterial(Material(muteIcon))
                    surface.DrawTexturedRect(0, 0, w, h)
                end
            end

            muteButton.DoClick = function()
                ply:SetMuted(not ply:IsMuted())
                surface.PlaySound("murdered/vgui/ui_click.wav")
            end
        end

        playerList:Add(playerPanel)
    end
end

hook.Add("ScoreboardShow", "ShowScoreboard", function()
    CreateScoreboard()
    return true
end)

hook.Add("ScoreboardHide", "HideScoreboard", function()
    if IsValid(scoreboard) then
        scoreboard:AlphaTo(0, 0.2, 0, function()
            scoreboard:Remove()
        end)
    end
end)