
local We = We or function(x) return x * (ScrW() / 1920) end
local He = He or function(x) return x * (ScrH() / 1080) end

local MENU_THEME = {
    background = Color(20, 20, 30, 180),
    accent = Color(180, 60, 60),
    panel = Color(40, 40, 50, 160),
    panelHover = Color(60, 60, 75, 180),
    text = Color(255, 255, 255),
    textDark = Color(160, 160, 170),
    success = Color(80, 200, 80),
    warning = Color(220, 180, 50),
    danger = Color(200, 60, 60),
    progressBg = Color(30, 30, 40, 200),
    progressFill = Color(180, 60, 60),
    cancelBtn = Color(100, 40, 40, 200),
    cancelBtnHover = Color(140, 50, 50, 220)
}

MuR.RagdollMenuOpen = nil
MuR.RagdollActionInProgress = false
MuR.RagdollWoundsData = nil

local function CreateProgressBar(duration, title, onComplete, onCancel)
    if IsValid(MuR.ProgressFrame) then MuR.ProgressFrame:Remove() end

    local startTime = CurTime()
    local endTime = startTime + duration
    local cancelled = false

    local function CancelAction()
        if cancelled then return end
        cancelled = true
        if IsValid(MuR.ProgressFrame) then MuR.ProgressFrame:Remove() end
        MuR.RagdollActionInProgress = false
        if onCancel then onCancel() end
        surface.PlaySound("buttons/button10.wav")

        net.Start("MuR.RagdollActionCancel")
        net.SendToServer()
    end

    local frame = vgui.Create("DFrame")
    MuR.ProgressFrame = frame
    frame:SetSize(We(400), He(140))
    frame:SetPos(We(1400), He(350))
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:MakePopup()
    frame:ShowCloseButton(false)

    frame.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, MENU_THEME.background)

        draw.SimpleText(title, "MuR_Font3", w/2, He(18), MENU_THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        local barX, barY, barW, barH = We(20), He(45), w - We(40), He(25)
        draw.RoundedBox(6, barX, barY, barW, barH, MENU_THEME.progressBg)

        local progress = math.Clamp((CurTime() - startTime) / duration, 0, 1)
        draw.RoundedBox(6, barX, barY, barW * progress, barH, MENU_THEME.progressFill)

        draw.SimpleText(math.Round(progress * 100) .. "%", "MuR_Font2", w/2, barY + barH/2, MENU_THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        draw.SimpleText(MuR.Language["ragdoll_menu_cancel_hint"] or "[ESC] Cancel", "MuR_FontDef", w/2, He(120), MENU_THEME.textDark, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local cancelBtn = vgui.Create("DButton", frame)
    cancelBtn:SetPos(We(100), He(85))
    cancelBtn:SetSize(We(200), He(28))
    cancelBtn:SetText("")
    cancelBtn.Paint = function(self, w, h)
        local bgColor = self:IsHovered() and MENU_THEME.cancelBtnHover or MENU_THEME.cancelBtn
        draw.RoundedBox(6, 0, 0, w, h, bgColor)
        draw.SimpleText(MuR.Language["ragdoll_menu_cancel"] or "Cancel", "MuR_Font2", w/2, h/2, MENU_THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    cancelBtn.DoClick = CancelAction

    frame.Think = function(self)
        if CurTime() >= endTime then
            self:Remove()
            MuR.RagdollActionInProgress = false
            if onComplete then onComplete() end
        end

        local ply = LocalPlayer()
        if ply:GetVelocity():Length() > 50 then
            CancelAction()
        end
    end

    frame.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE or key == KEY_E then
            CancelAction()
        end
    end

    MuR.RagdollActionInProgress = true
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
        draw.RoundedBox(12, 0, 0, w, He(60), MENU_THEME.panel)
        surface.SetDrawColor(MENU_THEME.accent)
        surface.DrawRect(0, He(60), w, He(3))
    end

    frame.OnKeyCodePressed = function(self, key)
        if key == KEY_E or key == KEY_ESCAPE then
            self:Remove()
        end
    end

    local title = vgui.Create("DLabel", frame)
    title:SetText(MuR.Language["ragdoll_menu_wounds_result"] or "Wound Examination Results")
    title:SetFont("MuR_Font3")
    title:SetTextColor(MENU_THEME.text)
    title:SetPos(We(20), He(10))
    title:SizeToContents()

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
                displayText = MuR.Language[wound.locKey] or wound.locKey
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
        noWounds:SetText(MuR.Language["ragdoll_menu_no_wounds"] or "No visible wounds detected")
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
        draw.RoundedBox(12, 0, 0, w, He(50), MENU_THEME.panel)
        surface.SetDrawColor(MENU_THEME.accent)
        surface.DrawRect(0, He(50), w, He(3))
    end

    menu.OnKeyCodePressed = function(self, key)
        if key == KEY_E or key == KEY_ESCAPE then
            self:AlphaTo(0, 0.15, 0, function()
                self:Remove()
            end)
        end
    end

    local title = vgui.Create("DLabel", menu)
    title:SetText(MuR.Language["ragdoll_menu_title"] or "Actions")
    title:SetFont("MuR_Font3")
    title:SetTextColor(MENU_THEME.text)
    title:SetPos(We(20), He(10))
    title:SizeToContents()

    local buttonData = {
        {
            text = MuR.Language["ragdoll_menu_pulse"] or "Check Pulse",
            icon = "icon16/heart.png",
            action = function()
                menu:Remove()
                net.Start("MuR.RagdollAction")
                net.WriteEntity(ragdoll)
                net.WriteString("pulse")
                net.SendToServer()

                CreateProgressBar(2, MuR.Language["ragdoll_menu_checking_pulse"] or "Checking pulse...", function()

                end)
            end
        },
        {
            text = MuR.Language["ragdoll_menu_wounds"] or "Examine Wounds",
            icon = "icon16/zoom.png",
            action = function()
                menu:Remove()
                net.Start("MuR.RagdollAction")
                net.WriteEntity(ragdoll)
                net.WriteString("wounds")
                net.SendToServer()

                CreateProgressBar(5, MuR.Language["ragdoll_menu_examining_wounds"] or "Examining wounds...", function()

                end)
            end
        },
        {
            text = MuR.Language["ragdoll_menu_search"] or "Search Inventory",
            icon = "icon16/folder_explore.png",
            action = function()
                menu:Remove()
                net.Start("MuR.RagdollAction")
                net.WriteEntity(ragdoll)
                net.WriteString("search")
                net.SendToServer()

                CreateProgressBar(2, MuR.Language["ragdoll_menu_searching"] or "Searching...", function()

                end)
            end
        },
        {
            text = MuR.Language["ragdoll_menu_close"] or "Close",
            icon = nil,
            isClose = true,
            action = function()
                menu:AlphaTo(0, 0.15, 0, function()
                    menu:Remove()
                end)
            end
        }
    }

    local yPos = He(65)
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
        text = MuR.Language["ragdoll_pulse_dead"] or "No pulse... They're dead."
        color = MENU_THEME.danger
    elseif status == 1 then
        text = MuR.Language["ragdoll_pulse_unconscious"] or "Weak pulse... They're unconscious but alive."
        color = MENU_THEME.warning
    else
        text = MuR.Language["ragdoll_pulse_alive"] or "Strong pulse... They're alive!"
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
        notification.AddLegacy(MuR.Language[reason] or reason, NOTIFY_ERROR, 3)
        surface.PlaySound("buttons/button10.wav")
    end

end)

net.Receive("MuR.RagdollBeingChecked", function()
    local action = net.ReadString()
    local checker = net.ReadEntity()

    local text
    if action == "pulse" then
        text = MuR.Language["ragdoll_being_pulsed"] or "Someone is checking your pulse..."
    elseif action == "wounds" then
        text = MuR.Language["ragdoll_being_examined"] or "Someone is examining your wounds..."
    elseif action == "search" then
        text = MuR.Language["ragdoll_being_searched"] or "Someone is searching you..."
    end

    if text then
        notification.AddLegacy(text, NOTIFY_HINT, 3)
    end
end)
