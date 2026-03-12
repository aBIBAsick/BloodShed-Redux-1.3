
local We = We or function(x) return x * (ScrW() / 1920) end
local He = He or function(x) return x * (ScrH() / 1080) end

local MENU_THEME = {
    background = Color(15, 15, 20, 245),
    header = Color(25, 25, 30, 255),
    accent = Color(180, 40, 40),
    panel = Color(25, 25, 30, 245),
    panelHover = Color(35, 35, 42, 255),
    text = Color(255, 255, 255),
    textDark = Color(200, 200, 200),
    success = Color(40, 180, 120),
    warning = Color(220, 180, 50),
    danger = Color(220, 50, 50),
    cancelBtn = Color(15, 15, 20, 245),
    cancelBtnHover = Color(220, 50, 50, 255)
}

MuR.RagdollMenuOpen = nil
MuR.RagdollActionInProgress = false
MuR.RagdollWoundsData = nil

local function L(key)
    local value = MuR.Language[key]
    if value then
        return value
    end

    if MuR.LoadLanguage and MuR.CurrentLanguage then
        MuR.LoadLanguage(MuR.CurrentLanguage)
        value = MuR.Language[key]
        if value then
            return value
        end
    end

    return key
end

local function CreateWoundsDisplay(woundsData)
    if IsValid(MuR.WoundsFrame) then MuR.WoundsFrame:Remove() end

    local frame = vgui.Create("DFrame")
    MuR.WoundsFrame = frame
    frame:SetSize(We(450), He(400))
    frame:SetPos(We(1400), He(350))
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:ShowCloseButton(false)

    frame.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, MENU_THEME.background)
        draw.RoundedBox(12, 0, 0, w, He(60), MENU_THEME.header)
        surface.SetDrawColor(MENU_THEME.accent)
        surface.DrawRect(0, He(60), w, He(2))
    end

    frame.OnKeyCodePressed = function(self, key)
        if key == KEY_E or key == KEY_ESCAPE then
            self:Remove()
        end
    end

    local title = vgui.Create("DLabel", frame)
    title:SetText(L("ragdoll_menu_wounds_result"))
    title:SetFont("MuR_Font3")
    title:SetTextColor(MENU_THEME.text)
    title:SetPos(We(20), He(10))
    title:SizeToContents()

    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetPos(frame:GetWide() - We(42), He(14))
    closeBtn:SetSize(We(28), He(28))
    closeBtn:SetText("")
    function closeBtn:Paint(w, h)
        local color = self:IsHovered() and MENU_THEME.danger or MENU_THEME.panel
        local textColor = self:IsHovered() and MENU_THEME.text or MENU_THEME.textDark
        draw.RoundedBox(4, 0, 0, w, h, color)
        draw.SimpleText("✕", "MuR_Font3", w / 2, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        frame:Remove()
    end

    local hint = vgui.Create("DLabel", frame)
    hint:SetText(MuR.Language["search_newhud_close"])
    hint:SetFont("MuR_FontDef")
    hint:SetTextColor(MENU_THEME.textDark)
    hint:SetPos(We(20), He(38))
    hint:SizeToContents()

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(We(15), He(75))
    scroll:SetSize(We(420), He(310))

    local sbar = scroll:GetVBar()
    sbar:SetWide(We(6))
    function sbar:Paint(w, h) draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 40, 100)) end
    function sbar.btnGrip:Paint(w, h) draw.RoundedBox(4, 0, 0, w, h, MENU_THEME.accent) end

    local yPos = 0

    if woundsData and #woundsData > 0 then
        for _, wound in ipairs(woundsData) do
            local woundPanel = vgui.Create("DPanel", scroll)
            woundPanel:SetPos(0, yPos)
            woundPanel:SetSize(We(400), He(50))

            local woundColor = MENU_THEME.success
            if wound.severity == 2 then
                woundColor = MENU_THEME.warning
            elseif wound.severity >= 3 then
                woundColor = MENU_THEME.danger
            end

            woundPanel.Paint = function(self, w, h)
                draw.RoundedBox(8, 0, 0, w, h, MENU_THEME.panel)
                surface.SetDrawColor(woundColor)
                surface.DrawRect(0, 0, We(4), h)
            end

            local displayText = wound.text
            if wound.locKey then
                displayText = L(wound.locKey)
            end

            local woundText = vgui.Create("DLabel", woundPanel)
            woundText:SetText(displayText)
            woundText:SetFont("MuR_Font2")
            woundText:SetTextColor(MENU_THEME.text)
            woundText:SetPos(We(15), He(5))
            woundText:SetSize(We(380), He(40))
            woundText:SetWrap(true)

            yPos = yPos + He(55)
        end
    else
        local noWounds = vgui.Create("DLabel", scroll)
        noWounds:SetText(L("ragdoll_menu_no_wounds"))
        noWounds:SetFont("MuR_Font2")
        noWounds:SetTextColor(MENU_THEME.success)
        noWounds:SetPos(We(15), He(20))
        noWounds:SizeToContents()
    end
end

local function CreateRagdollMenu(ragdoll)
    if IsValid(MuR.RagdollMenuOpen) then MuR.RagdollMenuOpen:Remove() end
    if MuR.RagdollActionInProgress then return end

    local ply = LocalPlayer()

    local menu = vgui.Create("DFrame")
    MuR.RagdollMenuOpen = menu
    menu:SetSize(We(320), He(300))
    menu:SetPos(We(1400), He(350))
    menu:SetTitle("")
    menu:SetDraggable(false)
    menu:MakePopup()
    menu:ShowCloseButton(false)
    menu:AlphaTo(0, 0)
    menu:AlphaTo(255, 0.2)

    menu.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, MENU_THEME.background)
        draw.RoundedBox(12, 0, 0, w, He(60), MENU_THEME.header)
        surface.SetDrawColor(MENU_THEME.accent)
        surface.DrawRect(0, He(60), w, He(2))
    end

    menu.OnKeyCodePressed = function(self, key)
        if key == KEY_E or key == KEY_ESCAPE then
            self:AlphaTo(0, 0.15, 0, function()
                self:Remove()
            end)
        end
    end

    local title = vgui.Create("DLabel", menu)
    title:SetText(L("ragdoll_menu_title"))
    title:SetFont("MuR_Font3")
    title:SetTextColor(MENU_THEME.text)
    title:SetPos(We(20), He(10))
    title:SizeToContents()

    local closeBtn = vgui.Create("DButton", menu)
    closeBtn:SetPos(menu:GetWide() - We(42), He(14))
    closeBtn:SetSize(We(28), He(28))
    closeBtn:SetText("")
    function closeBtn:Paint(w, h)
        local color = self:IsHovered() and MENU_THEME.danger or MENU_THEME.panel
        local textColor = self:IsHovered() and MENU_THEME.text or MENU_THEME.textDark
        draw.RoundedBox(4, 0, 0, w, h, color)
        draw.SimpleText("✕", "MuR_Font3", w / 2, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        menu:AlphaTo(0, 0.15, 0, function()
            menu:Remove()
        end)
    end

    local buttonData = {
        {
            text = L("ragdoll_menu_pulse"),
            icon = "icon16/heart.png",
            action = function()
                menu:Remove()
                net.Start("MuR.RagdollAction")
                net.WriteEntity(ragdoll)
                net.WriteString("pulse")
                net.SendToServer()
            end
        },
        {
            text = L("ragdoll_menu_wounds"),
            icon = "icon16/zoom.png",
            action = function()
                menu:Remove()
                net.Start("MuR.RagdollAction")
                net.WriteEntity(ragdoll)
                net.WriteString("wounds")
                net.SendToServer()
            end
        },
        {
            text = L("ragdoll_menu_search"),
            icon = "icon16/folder_explore.png",
            action = function()
                menu:Remove()
                net.Start("MuR.RagdollAction")
                net.WriteEntity(ragdoll)
                net.WriteString("search")
                net.SendToServer()
            end
        },
        {
            text = L("ragdoll_menu_close"),
            icon = nil,
            isClose = true,
            action = function()
                menu:AlphaTo(0, 0.15, 0, function()
                    menu:Remove()
                end)
            end
        }
    }

    local yPos = He(75)
    for i, data in ipairs(buttonData) do
        local btn = vgui.Create("DButton", menu)
        btn:SetPos(We(15), yPos)
        btn:SetSize(We(290), He(50))
        btn:SetText("")

        btn.Paint = function(self, w, h)
            local bgColor = MENU_THEME.panel
            if self:IsHovered() then
                bgColor = MENU_THEME.panelHover
            end

            if data.isClose then
                bgColor = self:IsHovered() and MENU_THEME.cancelBtnHover or MENU_THEME.cancelBtn
            end

            draw.RoundedBox(8, 0, 0, w, h, bgColor)

            if self:IsHovered() and not data.isClose then
                surface.SetDrawColor(MENU_THEME.accent)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            end
        end

        if data.icon then
            local icon = vgui.Create("DImage", btn)
            icon:SetPos(We(12), He(17))
            icon:SetSize(We(16), He(16))
            icon:SetImage(data.icon)
        end

        local label = vgui.Create("DLabel", btn)
        label:SetText(data.text)
        label:SetFont("MuR_Font2")
        label:SetTextColor(MENU_THEME.text)
        label:SetPos(data.icon and We(40) or We(15), He(15))
        if data.isClose then
            label:SetContentAlignment(5) 
            label:SetPos(0, He(15))
            label:SetSize(We(290), He(20))
        else
            label:SizeToContents()
        end

        btn.DoClick = function()
            surface.PlaySound("buttons/button14.wav")
            data.action()
        end

        yPos = yPos + He(55)
    end
end

net.Receive("MuR.RagdollMenu", function()
    local ragdoll = net.ReadEntity()
    if not IsValid(ragdoll) then return end
    CreateRagdollMenu(ragdoll)
end)

net.Receive("MuR.RagdollPulseResult", function()
    local status = net.ReadUInt(2) 

    if IsValid(MuR.ProgressFrame) then
        MuR.ProgressFrame:Remove()
    end
    MuR.RagdollActionInProgress = false

    local text, color
    if status == 0 then
        text = L("ragdoll_pulse_dead")
        color = MENU_THEME.danger
    elseif status == 1 then
        text = L("ragdoll_pulse_unconscious")
        color = MENU_THEME.warning
    else
        text = L("ragdoll_pulse_alive")
        color = MENU_THEME.success
    end
end)

net.Receive("MuR.RagdollWoundsResult", function()
    local woundsData = net.ReadTable()

    if IsValid(MuR.ProgressFrame) then
        MuR.ProgressFrame:Remove()
    end
    MuR.RagdollActionInProgress = false

    CreateWoundsDisplay(woundsData)
    surface.PlaySound("buttons/button9.wav")
end)

net.Receive("MuR.RagdollSearchResult", function()
    local canSearch = net.ReadBool()
    local reason = net.ReadString()

    if IsValid(MuR.ProgressFrame) then
        MuR.ProgressFrame:Remove()
    end
    MuR.RagdollActionInProgress = false

    if not canSearch then
        notification.AddLegacy(L(reason), NOTIFY_ERROR, 3)
        surface.PlaySound("buttons/button10.wav")
    end

end)

net.Receive("MuR.RagdollBeingChecked", function()
    local action = net.ReadString()
    local checker = net.ReadEntity()

    local text
    if action == "pulse" then
        text = L("ragdoll_being_pulsed")
    elseif action == "wounds" then
        text = L("ragdoll_being_examined")
    elseif action == "search" then
        text = L("ragdoll_being_searched")
    end

    if text then
        notification.AddLegacy(text, NOTIFY_HINT, 3)
    end
end)
