local Settings = {
    Character = {},
    Settings = {},
    Admin = {}
}

local THEME = {
    background = Color(15, 15, 20, 250),
    accent = Color(180, 40, 40),
    panel = Color(25, 25, 30, 255),
    text = Color(255, 255, 255),
    textDark = Color(200, 200, 200),
    success = Color(40, 180, 120),
    danger = Color(220, 50, 50)
}

function AddSetting(category, settingType, name, convar, min, max, options)
    table.insert(Settings[category], {
        type = settingType,
        name = name,
        convar = convar,
        min = min,
        max = max,
        options = options
    })
end

local function CreateControl(parent, setting)
    local panel = vgui.Create("DPanel", parent)
    panel:SetTall(He(60))
    panel:Dock(TOP)
    panel:DockMargin(We(10), He(5), We(10), He(5))

    function panel:Paint(w, h)
        draw.RoundedBox(8, 0, 0, w, h, THEME.panel)
    end

    local label = vgui.Create("DLabel", panel)
    label:SetText(setting.name)
    label:SetTextColor(THEME.text)
    label:SetFont("MuR_Font1")
    label:Dock(LEFT)
    label:DockMargin(We(20), 0, 0, 0)
    label:SetWidth(We(500))

    if setting.type == "checkbox" then
        local checkbox = vgui.Create("DCheckBox", panel)
        checkbox:Dock(RIGHT)
        checkbox:DockMargin(0, He(20), We(20), He(20))
        checkbox:SetConVar(setting.convar)
        checkbox:SetValue(GetConVar(setting.convar):GetBool())

        function checkbox:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, THEME.background)

            if self:GetChecked() then
                draw.RoundedBox(4, 2, 2, w-4, h-4, THEME.accent)
            end
        end

    elseif setting.type == "slider" then
        local slider = vgui.Create("DNumSlider", panel)
        slider:Dock(RIGHT)
        slider:SetWide(We(300))
        slider:DockMargin(0, 0, We(10), 0)
        slider:SetMin(setting.min or 0)
        slider:SetMax(setting.max or 100)
        slider:SetDecimals(0)
        slider:SetConVar(setting.convar)
        slider:SetValue(GetConVar(setting.convar):GetFloat())

        slider.Label:SetTextColor(THEME.textDark)
        slider.Label:SetFont("MuR_Font1")

        function slider.Slider:Paint(w, h)
            draw.RoundedBox(4, 0, h/2-2, w, 4, THEME.background)
            draw.RoundedBox(4, 0, h/2-2, self:GetSlideX(), 4, THEME.accent)
        end

        function slider.Slider.Knob:Paint(w, h)
            draw.RoundedBox(w/2, 0, 0, w, h, THEME.accent)
        end

    elseif setting.type == "textentry" then
        local textentry = vgui.Create("DTextEntry", panel)
        textentry:Dock(RIGHT)
        textentry:SetWidth(We(200))
        textentry:DockMargin(0, He(15), We(20), He(15))
        textentry:SetConVar(setting.convar)
        textentry:SetValue(GetConVar(setting.convar):GetString())
        textentry:SetFont("MuR_Font1")
        textentry:SetTextColor(THEME.text)

        function textentry:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, THEME.background)
            self:DrawTextEntryText(THEME.text, THEME.accent, THEME.text)
        end

    elseif setting.type == "combobox" then
        local combobox = vgui.Create("DComboBox", panel)
        combobox:Dock(RIGHT)
        combobox:SetWidth(We(200))
        combobox:DockMargin(0, He(15), We(20), He(15))
        combobox:SetFont("MuR_Font1")
        combobox:SetTextColor(THEME.text)

        function combobox:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, THEME.background)
        end

        if setting.options then
            for value, text in pairs(setting.options) do
                combobox:AddChoice(text, value)
            end
        end

        local currentValue = GetConVar(setting.convar):GetString()
        for k, v in pairs(setting.options) do
            if k == currentValue then
                combobox:SetValue(v)
                break
            end
        end

        function combobox:OnSelect(index, text, data)
            RunConsoleCommand(setting.convar, data)
        end
    end

    return panel
end

function OpenSettingsMenu()
    local frame = vgui.Create("DFrame")
    frame:SetSize(We(800), He(600))
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame:Center()
    frame:MakePopup()

    frame:AlphaTo(0, 0, 0)
    frame:AlphaTo(255, 0.2, 0)

    function frame:Paint(w, h)
        draw.RoundedBox(8, 0, 0, w, h, THEME.background)
        draw.RoundedBox(8, 0, 0, w, He(60), THEME.panel)
        surface.SetDrawColor(THEME.accent)
        surface.DrawRect(0, He(60), w, He(2))

        draw.SimpleText(MuR.Language["settings_main"] or "Settings", "MuR_Font3", We(30), He(30), THEME.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetSize(We(32), He(32))
    closeBtn:SetPos(frame:GetWide() - We(42), He(14))
    closeBtn:SetText("")

    closeBtn.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local color = hovered and THEME.danger or THEME.panel
        local symbolColor = hovered and THEME.text or THEME.textDark

        draw.RoundedBox(4, 0, 0, w, h, color)
        draw.SimpleText("✕", "MuR_Font3", w/2, h/2, symbolColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    closeBtn.DoClick = function()
        surface.PlaySound("murdered/vgui/ui_click.wav")
        frame:AlphaTo(0, 0.2, 0, function()
            frame:Remove()
        end)
    end

    local sheet = vgui.Create("DPropertySheet", frame)
    sheet:Dock(FILL)
    sheet:DockMargin(We(10), He(70), We(10), He(10))
    function sheet:Paint(w, h) end

    local characterPanel = vgui.Create("DScrollPanel")
    characterPanel.Paint = function() end

    local characterSbar = characterPanel:GetVBar()
    characterSbar:SetWide(We(8))
    function characterSbar:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(THEME.panel.r, THEME.panel.g, THEME.panel.b, 100))
    end
    function characterSbar.btnGrip:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, THEME.accent)
    end

    local settingsPanel = vgui.Create("DScrollPanel")
    settingsPanel.Paint = function() end

    local settingsSbar = settingsPanel:GetVBar()
    settingsSbar:SetWide(We(8))
    function settingsSbar:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(THEME.panel.r, THEME.panel.g, THEME.panel.b, 100))
    end
    function settingsSbar.btnGrip:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, THEME.accent)
    end

    local characterSheet = sheet:AddSheet(MuR.Language["settings_main_char"], characterPanel, "icon16/user.png")
    local settingsSheet = sheet:AddSheet(MuR.Language["settings_main_set"], settingsPanel, "icon16/cog.png")

    local bindsPanel = vgui.Create("DScrollPanel")
    bindsPanel.Paint = function() end

    local bindsSbar = bindsPanel:GetVBar()
    bindsSbar:SetWide(We(8))
    function bindsSbar:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(THEME.panel.r, THEME.panel.g, THEME.panel.b, 100))
    end
    function bindsSbar.btnGrip:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, THEME.accent)
    end

    local bindsSheet = sheet:AddSheet(MuR.Language["binds_tab_name"], bindsPanel, "icon16/keyboard.png")
    bindsSheet.Tab:SetFont("MuR_Font1")

    local bindsData = {
        {name = "bind_ragdoll", command = "mur_ragdoll"},
        {name = "bind_kick", command = "mur_legkick"},
        {name = "bind_armor", command = "mur_armor_panel"},
        {name = "bind_voice", command = "mur_voicepanel"},
        {name = "bind_drop", command = "mur_wep_drop"},
        {name = "bind_unload", command = "mur_wep_unload"},
        {name = "bind_shout", command = "mur_shout"},
        {name = "bind_hostage_capture", command = "mur_hostage_capture"},
        {name = "bind_hostage_execute", command = "mur_hostage_execute"},
    }

    for _, bind in ipairs(bindsData) do
        local panel = vgui.Create("DPanel", bindsPanel)
        panel:SetTall(He(60))
        panel:Dock(TOP)
        panel:DockMargin(We(10), He(5), We(10), He(5))
        function panel:Paint(w, h)
            draw.RoundedBox(8, 0, 0, w, h, THEME.panel)
        end

        local label = vgui.Create("DLabel", panel)
        local txt = MuR.Language[bind.name] or bind.name
        label:SetText(txt)
        label:SetTextColor(THEME.text)
        label:SetFont("MuR_Font1")
        label:Dock(LEFT)
        label:DockMargin(We(20), 0, 0, 0)
        label:SetWidth(We(500))

        local binder = vgui.Create("DBinder", panel)
        binder:Dock(RIGHT)
        binder:SetWide(We(200))
        binder:DockMargin(0, He(10), We(20), He(10))

        binder:SetValue(MuR:GetBind(bind.command))

        function binder:OnChange(num)
            if num then
                MuR:SetBind(bind.command, num)
            end
        end
    end

    local adminPanel
    local adminSheet
    local adminItems = {}
    if LocalPlayer():IsSuperAdmin() then
        adminPanel = vgui.Create("DScrollPanel")
        adminPanel.Paint = function() end
        local adminSbar = adminPanel:GetVBar()
        adminSbar:SetWide(We(8))
        function adminSbar:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(THEME.panel.r, THEME.panel.g, THEME.panel.b, 100))
        end
        function adminSbar.btnGrip:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, THEME.accent)
        end
        adminSheet = sheet:AddSheet(MuR.Language["settings_main_admin"] or "Admin", adminPanel, "icon16/shield.png")
        adminSheet.Tab:SetFont("MuR_Font1")

        local function addAdminRow(name, rightWidgetBuilder)
            local panel = vgui.Create("DPanel", adminPanel)
            panel:SetTall(He(60))
            panel:Dock(TOP)
            panel:DockMargin(We(10), He(5), We(10), He(5))
            function panel:Paint(w, h)
                draw.RoundedBox(8, 0, 0, w, h, THEME.panel)
            end
            local label = vgui.Create("DLabel", panel)
            label:SetText(name)
            label:SetTextColor(THEME.text)
            label:SetFont("MuR_Font1")
            label:Dock(LEFT)
            label:DockMargin(We(20), 0, 0, 0)
            label:SetWidth(We(500))
            rightWidgetBuilder(panel)
            return panel
        end

        local modeCheckboxes = {}
        local modeIds = {}
        for id, _ in pairs(MuR.Modes or {}) do table.insert(modeIds, id) end
        table.sort(modeIds, function(a,b) return a<b end)

        local restartRow = addAdminRow(MuR.Language["settings_admin_restart"] or "Restart round", function(parent)
            local btn = vgui.Create("DButton", parent)
            btn:Dock(RIGHT)
            btn:SetWide(We(220))
            btn:DockMargin(0, He(10), We(20), He(10))
            btn:SetText("")
            function btn:Paint(w, h)
                local hovered = self:IsHovered()
                local color = hovered and THEME.accent or THEME.background
                draw.RoundedBox(4, 0, 0, w, h, color)
                draw.SimpleText(MuR.Language["settings_admin_select"] or "Select mode", "MuR_Font1", w/2, h/2, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            function btn:DoClick()
                surface.PlaySound("murdered/vgui/ui_click.wav")
                local menu = DermaMenu()
                menu:AddOption(MuR.EnableDebug and "Disable Sandbox" or "Enable Sandbox", function()
                    RunConsoleCommand("mur_sandboxtoggle")
                end):SetIcon("icon16/wand.png")
                menu:AddOption(MuR.Language["settings_admin_random"] or "Random", function()
                    RunConsoleCommand("mur_nextgamemode", "0")
                    RunConsoleCommand("mur_restartround")
                end):SetIcon("icon16/wand.png")
                for _, id in ipairs(modeIds) do
                    local solo = MuR.Modes[id].need_players and MuR.Modes[id].need_players == 1
                    if !solo and player.GetCount() == 1 then continue end
                    local txt = MuR.Language["gamename" .. tostring(id)] or ("Mode " .. tostring(id))
                    menu:AddOption(txt, function()
                        RunConsoleCommand("mur_nextgamemode", tostring(id))
                        RunConsoleCommand("mur_restartround")
                    end):SetIcon("icon16/world.png")
                end
                menu:Open()
            end
        end)
        table.insert(adminItems, restartRow)

        local nextTraitorRow = addAdminRow(MuR.Language["settings_admin_nexttraitor"] or "Next traitor", function(parent)
            local btn = vgui.Create("DButton", parent)
            btn:Dock(RIGHT)
            btn:SetWide(We(220))
            btn:DockMargin(0, He(10), We(20), He(10))
            btn:SetText("")
            function btn:Paint(w, h)
                local hovered = self:IsHovered()
                local color = hovered and THEME.accent or THEME.background
                draw.RoundedBox(4, 0, 0, w, h, color)
                draw.SimpleText(MuR.Language["settings_admin_select_player"] or "Select player", "MuR_Font1", w/2, h/2, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            function btn:DoClick()
                surface.PlaySound("murdered/vgui/ui_click.wav")
                local win = vgui.Create("DFrame")
                win:SetTitle("")
                win:SetSize(We(500), He(220))
                win:Center()
                win:MakePopup()
                function win:Paint(w,h)
                    draw.RoundedBox(8, 0, 0, w, h, THEME.background)
                    draw.RoundedBox(8, 0, 0, w, He(50), THEME.panel)
                    draw.SimpleText(MuR.Language["settings_admin_nexttraitor"] or "Next traitor", "MuR_Font3", We(16), He(25), THEME.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end

                local p1 = vgui.Create("DComboBox", win)
                p1:SetPos(We(16), He(70))
                p1:SetSize(We(468), He(36))
                p1:SetValue((MuR.Language["settings_admin_primary"] or "Primary") .. ": ")
                for _, ply in player.Iterator() do
                    p1:AddChoice(ply:Nick())
                end

                local p2 = vgui.Create("DComboBox", win)
                p2:SetPos(We(16), He(120))
                p2:SetSize(We(468), He(36))
                p2:SetValue((MuR.Language["settings_admin_secondary"] or "Secondary") .. ": ")
                for _, ply in player.Iterator() do
                    p2:AddChoice(ply:Nick())
                end

                local apply = vgui.Create("DButton", win)
                apply:SetPos(We(16), He(170))
                apply:SetSize(We(225), He(36))
                apply:SetText("")
                function apply:Paint(w,h)
                    draw.RoundedBox(4, 0, 0, w, h, THEME.accent)
                    draw.SimpleText(MuR.Language["settings_admin_apply"] or "Apply", "MuR_Font1", w/2, h/2, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                function apply:DoClick()
                    local _, n1 = p1:GetSelected()
                    local _, n2 = p2:GetSelected()
                    if n1 or n2 then
                        if n1 and n2 then
                            RunConsoleCommand("mur_nexttraitor", n1, n2)
                        elseif n1 then
                            RunConsoleCommand("mur_nexttraitor", n1)
                        elseif n2 then
                            RunConsoleCommand("mur_nexttraitor", "", n2)
                        end
                    end
                    win:Close()
                end

                local cancel = vgui.Create("DButton", win)
                cancel:SetPos(We(259), He(170))
                cancel:SetSize(We(225), He(36))
                cancel:SetText("")
                function cancel:Paint(w,h)
                    draw.RoundedBox(4, 0, 0, w, h, THEME.panel)
                    draw.SimpleText(MuR.Language["settings_admin_cancel"] or "Cancel", "MuR_Font1", w/2, h/2, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                function cancel:DoClick()
                    win:Close()
                end
            end
        end)
        table.insert(adminItems, nextTraitorRow)

        local respawnRow = addAdminRow(MuR.Language["settings_admin_respawn"] or "Respawn player", function(parent)
            local btn = vgui.Create("DButton", parent)
            btn:Dock(RIGHT)
            btn:SetWide(We(220))
            btn:DockMargin(0, He(10), We(20), He(10))
            btn:SetText("")
            function btn:Paint(w, h)
                local hovered = self:IsHovered()
                local color = hovered and THEME.accent or THEME.background
                draw.RoundedBox(4, 0, 0, w, h, color)
                draw.SimpleText(MuR.Language["settings_admin_select_player"] or "Select player", "MuR_Font1", w/2, h/2, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            function btn:DoClick()
                surface.PlaySound("murdered/vgui/ui_click.wav")
                local win = vgui.Create("DFrame")
                win:SetTitle("")
                win:SetSize(We(520), He(280))
                win:Center()
                win:MakePopup()
                function win:Paint(w,h)
                    draw.RoundedBox(8, 0, 0, w, h, THEME.background)
                    draw.RoundedBox(8, 0, 0, w, He(50), THEME.panel)
                    draw.SimpleText(MuR.Language["settings_admin_respawn"] or "Respawn player", "MuR_Font3", We(16), He(25), THEME.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end

                local plyBox = vgui.Create("DComboBox", win)
                plyBox:SetPos(We(16), He(70))
                plyBox:SetSize(We(488), He(36))
                plyBox:SetValue(MuR.Language["settings_admin_select_player"] or "Select player")
                for _, ply in player.Iterator() do
                    plyBox:AddChoice(ply:Nick())
                end

                local useCurrent = vgui.Create("DCheckBoxLabel", win)
                useCurrent:SetPos(We(16), He(120))
                useCurrent:SetText(MuR.Language["settings_admin_use_current_role"] or "Use current role")
                useCurrent:SetTextColor(THEME.text)
                useCurrent:SetChecked(true)

                local roleBox = vgui.Create("DComboBox", win)
                roleBox:SetPos(We(16), He(170))
                roleBox:SetSize(We(488), He(36))
                roleBox:SetValue(MuR.Language["settings_admin_choose_role"] or "Choose role")
                roleBox:SetEnabled(false)

                local function fillRoles()
                    local added = {}
                    local function addRole(c)
                        if not isstring(c) or added[c] then return end
                        added[c] = true
                        local map = {
                            Killer = "murderer", Traitor = "traitor", Innocent = "innocent", Defender = "defender",
                            Medic = "medic", Builder = "builder", HeadHunter = "headhunter", Criminal = "criminal",
                            Security = "security", Witness = "witness", Officer = "officer", ArmoredOfficer = "riotpolice",
                            FBI = "fbiagent", Zombie = "zombie", SWAT = "swat", Riot = "riotpolice",
                            Terrorist = "terrorist", Shooter = "shooter", Soldier = "soldier", GangGreen = "ganggreen", GangRed = "gangred",
                            Tony = "tony", Mafia = "mafia"
                        }
                        local key = map[c] or string.lower(c)
                        local label = MuR.Language[key] or c
                        roleBox:AddChoice(label, c)
                    end
                    for id, def in pairs(MuR.Modes or {}) do
                        if isstring(def.kteam) then addRole(def.kteam) end
                        if isstring(def.dteam) then addRole(def.dteam) end
                        if isstring(def.iteam) then addRole(def.iteam) end
                        if istable(def.roles) then
                            for _, r in ipairs(def.roles) do
                                addRole(r.class or r.name)
                            end
                        end
                    end
                end
                fillRoles()

                function useCurrent:OnChange(val)
                    roleBox:SetEnabled(not val)
                end

                local apply = vgui.Create("DButton", win)
                apply:SetPos(We(16), He(220))
                apply:SetSize(We(240), He(36))
                apply:SetText("")
                function apply:Paint(w,h)
                    draw.RoundedBox(4, 0, 0, w, h, THEME.accent)
                    draw.SimpleText(MuR.Language["settings_admin_apply"] or "Apply", "MuR_Font1", w/2, h/2, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                function apply:DoClick()
                    local plname = plyBox:GetSelected()
                    if not plname then return end
                    if useCurrent:GetChecked() then
                        RunConsoleCommand("mur_forcespawn", plname)
                    else
                        local _, class = roleBox:GetSelected()
                        if class then
                            RunConsoleCommand("mur_forcespawn", plname, class)
                        else
                            RunConsoleCommand("mur_forcespawn", plname)
                        end
                    end
                    win:Close()
                end

                local cancel = vgui.Create("DButton", win)
                cancel:SetPos(We(264), He(220))
                cancel:SetSize(We(240), He(36))
                cancel:SetText("")
                function cancel:Paint(w,h)
                    draw.RoundedBox(4, 0, 0, w, h, THEME.panel)
                    draw.SimpleText(MuR.Language["settings_admin_cancel"] or "Cancel", "MuR_Font1", w/2, h/2, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                function cancel:DoClick()
                    win:Close()
                end
            end
        end)
        table.insert(adminItems, respawnRow)

        local manageRow = addAdminRow(MuR.Language["settings_admin_modes"] or "Manage modes", function(parent)
            local btn = vgui.Create("DButton", parent)
            btn:Dock(RIGHT)
            btn:SetWide(We(220))
            btn:DockMargin(0, He(10), We(20), He(10))
            btn:SetText("")
            function btn:Paint(w, h)
                local hovered = self:IsHovered()
                local color = hovered and THEME.accent or THEME.background
                draw.RoundedBox(4, 0, 0, w, h, color)
                draw.SimpleText(MuR.Language["settings_admin_open"] or "Open", "MuR_Font1", w/2, h/2, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            function btn:DoClick()
                surface.PlaySound("murdered/vgui/ui_click.wav")
                local win = vgui.Create("DFrame")
                win:SetTitle("")
                win:SetSize(We(720), He(380))
                win:Center()
                win:MakePopup()
                function win:Paint(w,h)
                    draw.RoundedBox(8, 0, 0, w, h, THEME.background)
                    draw.RoundedBox(8, 0, 0, w, He(50), THEME.panel)
                    draw.SimpleText(MuR.Language["settings_admin_modes"] or "Manage modes", "MuR_Font3", We(16), He(25), THEME.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end

                local left = vgui.Create("DListView", win)
                left:SetPos(We(16), He(66))
                left:SetSize(We(320), He(240))
                left:AddColumn(MuR.Language["settings_admin_enabled"] or "Enabled")

                local mid = vgui.Create("DPanel", win)
                mid:SetPos(We(344), He(66))
                mid:SetSize(We(32), He(240))
                function mid:Paint(w,h) end

                local toRight = vgui.Create("DButton", mid)
                toRight:SetText(">>")
                toRight:SetSize(We(32), He(36))
                toRight:SetPos(0, He(70))
                function toRight:Paint(w,h)
                    draw.RoundedBox(4, 0, 0, w, h, THEME.accent)
                    draw.SimpleText(">>", "MuR_Font1", w/2, h/2, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                local toLeft = vgui.Create("DButton", mid)
                toLeft:SetText("<<")
                toLeft:SetSize(We(32), He(36))
                toLeft:SetPos(0, He(130))
                function toLeft:Paint(w,h)
                    draw.RoundedBox(4, 0, 0, w, h, THEME.panel)
                    draw.SimpleText("<<", "MuR_Font1", w/2, h/2, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                local right = vgui.Create("DListView", win)
                right:SetPos(We(392), He(66))
                right:SetSize(We(312), He(240))
                right:AddColumn(MuR.Language["settings_admin_disabled"] or "Disabled")

                local function syncLists(disabled)
                    left:Clear()
                    right:Clear()
                    local set = {}
                    for k,v in pairs(disabled or {}) do if v then set[tonumber(k)] = true end end
                    for _, id in ipairs(modeIds) do
                        local name = MuR.Language["gamename"..id] or ("Mode "..id)
                        if set[id] then
                            right:AddLine(name).mode_id = id
                        else
                            left:AddLine(name).mode_id = id
                        end
                    end
                end

                local currentDisabled = {}
                local function requestState()
                    net.Start("MuR.ModesStateReq"); net.SendToServer()
                end
                net.Receive("MuR.ModesState", function()
                    currentDisabled = net.ReadTable() or {}
                    syncLists(currentDisabled)
                end)
                requestState()

                function toRight:DoClick()
                    local sel = left:GetSelected()
                    for _, line in ipairs(sel or {}) do
                        if line.mode_id then currentDisabled[line.mode_id] = true end
                    end
                    syncLists(currentDisabled)
                end
                function toLeft:DoClick()
                    local sel = right:GetSelected()
                    for _, line in ipairs(sel or {}) do
                        if line.mode_id then currentDisabled[line.mode_id] = nil end
                    end
                    syncLists(currentDisabled)
                end

                local save = vgui.Create("DButton", win)
                save:SetPos(We(16), He(320))
                save:SetSize(We(340), He(36))
                save:SetText("")
                function save:Paint(w,h)
                    draw.RoundedBox(4, 0, 0, w, h, THEME.accent)
                    draw.SimpleText(MuR.Language["settings_admin_save"] or "Save", "MuR_Font1", w/2, h/2, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                function save:DoClick()
                    local payload = {_asSet = {}}
                    for k,v in pairs(currentDisabled or {}) do if v then payload._asSet[tostring(k)] = true end end
                    net.Start("MuR.ModesStateSave")
                    net.WriteTable(payload)
                    net.SendToServer()
                    surface.PlaySound("buttons/button9.wav")
                end

                local close = vgui.Create("DButton", win)
                close:SetPos(We(364), He(320))
                close:SetSize(We(340), He(36))
                close:SetText("")
                function close:Paint(w,h)
                    draw.RoundedBox(4, 0, 0, w, h, THEME.panel)
                    draw.SimpleText(MuR.Language["settings_admin_close"] or "Close", "MuR_Font1", w/2, h/2, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                function close:DoClick()
                    win:Close()
                end
            end
        end)
        table.insert(adminItems, manageRow)

        do
            net.Start("MuR.ModesStateReq")
            net.SendToServer()
            net.Receive("MuR.ModesState", function()
                local disabled = net.ReadTable() or {}
                for id, cb in pairs(modeCheckboxes) do
                    if IsValid(cb) then
                        cb:SetValue(disabled[id] and 1 or 0)
                    end
                end
            end)
        end
    end

    characterSheet.Tab:SetFont("MuR_Font1")
    settingsSheet.Tab:SetFont("MuR_Font1")

    for _, setting in ipairs(Settings.Character) do
        CreateControl(characterPanel, setting)
    end

    for _, setting in ipairs(Settings.Settings) do
        CreateControl(settingsPanel, setting)
    end

    for k, v in pairs(sheet:GetItems()) do
        if v.Tab then
            function v.Tab:Paint(w, h)
                if self:IsActive() then
                    draw.RoundedBox(4, 0, 0, w, h, THEME.accent)
                else
                    draw.RoundedBox(4, 0, 0, w, h, THEME.panel)
                end
            end

            function v.Tab:UpdateColours()
                if self:IsActive() then
                    self:SetTextColor(THEME.text)
                else
                    self:SetTextColor(THEME.textDark)
                end
            end
        end
    end

    return frame
end

concommand.Add("open_settings", function()
    OpenSettingsMenu()
end)

hook.Add("PlayerBindPress", "OpenSettingsMenuF1", function(ply, bind, pressed)
    if bind == "gm_showhelp" and pressed then
        OpenSettingsMenu()
        return true
    end
end)

AddSetting("Settings", "slider", MuR.Language["settings_settings_view"], "blsd_viewperson", 0, 2)
AddSetting("Settings", "checkbox", MuR.Language["settings_settings_exec"], "blsd_execution_3rd_person")
AddSetting("Settings", "checkbox", MuR.Language["settings_settings_holdrag"], "blsd_ragdoll_hold_grab")

AddSetting("Settings", "checkbox", MuR.Language["settings_settings_hud"], "blsd_nohud")
AddSetting("Settings", "checkbox", MuR.Language["settings_settings_crossrag"], "blsd_crosshair_ragdoll")
AddSetting("Settings", "checkbox", MuR.Language["settings_settings_chands"], "blsd_chands")
AddSetting("Settings", "checkbox", MuR.Language["settings_settings_tpik"], "blsd_tpik")
AddSetting("Settings", "checkbox", MuR.Language["settings_settings_viewbob"], "blsd_viewbob")

AddSetting("Character", "textentry", MuR.Language["settings_character_namem"], "blsd_character_name_male")
AddSetting("Character", "textentry", MuR.Language["settings_character_namef"], "blsd_character_name_female")
AddSetting("Character", "checkbox", MuR.Language["settings_character_female"], "blsd_character_female")
AddSetting("Character", "slider", MuR.Language["settings_character_tone"], "blsd_character_pitch", 86, 114)
AddSetting("Character", "combobox", MuR.Language["settings_character_exec"], "blsd_character_executionstyle", nil, nil, {
    ["default"] = MuR.Language["settings_character_exec1"],
    ["long_gib"] = MuR.Language["settings_character_exec2"],
    ["long_choke"] = MuR.Language["settings_character_exec3"],
    ["default_knife"] = MuR.Language["settings_character_exec4"],
})