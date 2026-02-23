local ARMOR_UI_THEME = {
    background = Color(30, 30, 40, 245),
    header = Color(45, 45, 55, 255),
    accent = Color(200, 0, 0),
    panel = Color(50, 50, 60, 255),
    panelHover = Color(65, 65, 75, 255),
    text = Color(255, 255, 255),
    textDark = Color(180, 180, 180),
    success = Color(100, 200, 100),
    danger = Color(255, 100, 100),
    empty = Color(80, 80, 90, 255)
}

local bodypartOrder = {"head", "face", "body"}
local bodypartNames = {
    head = MuR.Language["armor_slot_head"] or "Голова",
    face = MuR.Language["armor_slot_face"] or "Лицо",
    body = MuR.Language["armor_slot_body"] or "Тело"
}

local function CreateArmorSlot(parent, bodypart, x, y, width, height)
    local slot = vgui.Create("DButton", parent)
    slot:SetPos(x, y)
    slot:SetSize(width, height)
    slot:SetText("")
    slot.bodypart = bodypart

    function slot:UpdateArmor()
        local ply = LocalPlayer()
        local armorId = ply:GetNW2String("MuR_Armor_" .. bodypart, "")
        self.armorId = armorId
        self.isActive = ply:GetNW2Bool("MuR_Armor_Active_" .. bodypart, false)
        self.item = armorId ~= "" and MuR.Armor.GetItem(armorId) or nil
    end

    slot:UpdateArmor()

    function slot:Paint(w, h)
        local bgColor = self.item and ARMOR_UI_THEME.panel or ARMOR_UI_THEME.empty
        if self:IsHovered() and self.item then
            bgColor = ARMOR_UI_THEME.panelHover
        end
        draw.RoundedBox(8, 0, 0, w, h, bgColor)
        if self:IsHovered() and self.item then
            surface.SetDrawColor(ARMOR_UI_THEME.accent)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
        end
        draw.SimpleText(bodypartNames[bodypart] or bodypart, "MuR_Font1", 10, 5, ARMOR_UI_THEME.textDark)
        if self.item then
            local itemName = MuR.Language["armor_item_" .. self.armorId] or self.armorId
            local nameColor = self.isActive and ARMOR_UI_THEME.text or ARMOR_UI_THEME.textDark
            draw.SimpleText(itemName, "MuR_Font3", w/2, h/2 - 10, nameColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            local statusText = self.isActive and (MuR.Language["armor_active"] or "Активна") or (MuR.Language["armor_inactive"] or "В сумке")
            local statusColor = self.isActive and ARMOR_UI_THEME.success or ARMOR_UI_THEME.danger
            draw.SimpleText(statusText, "MuR_Font1", w/2, h/2 + 5, statusColor, TEXT_ALIGN_CENTER)
            draw.SimpleText(MuR.Language["armor_options"] or "ЛКМ - Опции", "MuR_Font1", w/2, h - 20, ARMOR_UI_THEME.textDark, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText(MuR.Language["armor_empty"] or "Пусто", "MuR_Font2", w/2, h/2, ARMOR_UI_THEME.textDark, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    function slot:DoClick()
        if not self.item then return end
        local menu = DermaMenu()
        local toggleText = self.isActive and (MuR.Language["armor_take"] or "Снять") or (MuR.Language["armor_put_on"] or "Одеть")
        local toggleIcon = self.isActive and "icon16/arrow_undo.png" or "icon16/tick.png"
        menu:AddOption(toggleText, function()
            net.Start("MuR_ArmorPickup")
            net.WriteString("toggle_active")
            net.WriteString(bodypart)
            net.WriteBool(not self.isActive)
            net.SendToServer()
            timer.Simple(0.1, function()
                if IsValid(self) then self:UpdateArmor() end
            end)
        end):SetIcon(toggleIcon)
        menu:AddOption(MuR.Language["armor_drop"] or "Выбросить", function()
            net.Start("MuR_ArmorPickup")
            net.WriteString("unequip")
            net.WriteString(bodypart)
            net.SendToServer()
            if self.isActive and self.item and self.item.unequip_sound then
                surface.PlaySound(self.item.unequip_sound)
            end
            timer.Simple(0.1, function()
                if IsValid(self) then self:UpdateArmor() end
            end)
        end):SetIcon("icon16/arrow_out.png")
        local descLabel = MuR.Language["armor_desc_" .. self.armorId] or "..."
        local info = menu:AddSubMenu(MuR.Language["armor_desc"] or "Описание")
        info:AddOption(descLabel, function() end):SetIcon("icon16/information.png")
        menu:Open()
    end
    return slot
end

local function OpenArmorPanel()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    local frameW, frameH = We(450), He(400)
    local frame = vgui.Create("DFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, ARMOR_UI_THEME.background)
        draw.RoundedBox(12, 0, 0, w, He(60), ARMOR_UI_THEME.header)
        surface.SetDrawColor(ARMOR_UI_THEME.accent)
        surface.DrawRect(0, He(60), w, 2)
    end
    frame.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE or key == KEY_Q then
            self:Remove()
        end
    end
    local title = vgui.Create("DLabel", frame)
    title:SetText(MuR.Language["armor_title"] or "Броня")
    title:SetFont("MuR_Font4")
    title:SetTextColor(ARMOR_UI_THEME.text)
    title:SetPos(We(20), He(15))
    title:SizeToContents()
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetPos(frameW - We(40), He(15))
    closeBtn:SetSize(We(25), He(25))
    closeBtn:SetText("✕")
    closeBtn:SetFont("MuR_Font3")
    closeBtn:SetTextColor(ARMOR_UI_THEME.text)
    closeBtn.Paint = function(self, w, h)
        if self:IsHovered() then
            draw.RoundedBox(4, 0, 0, w, h, ARMOR_UI_THEME.danger)
        end
    end
    closeBtn.DoClick = function()
        frame:Remove()
    end
    local slotWidth = frameW - We(40)
    local slotHeight = He(90)
    local startY = He(80)
    local spacing = He(10)
    local slots = {}
    for i, bodypart in ipairs(bodypartOrder) do
        local y = startY + (i - 1) * (slotHeight + spacing)
        slots[bodypart] = CreateArmorSlot(frame, bodypart, We(20), y, slotWidth, slotHeight)
    end
    timer.Create("MuR_ArmorUIUpdate", 0.5, 0, function()
        if not IsValid(frame) then
            timer.Remove("MuR_ArmorUIUpdate")
            return
        end
        for bodypart, slot in pairs(slots) do
            if IsValid(slot) then
                slot:UpdateArmor()
            end
        end
    end)
end

concommand.Add("mur_armor_panel", function()
    OpenArmorPanel()
end)

MuR.OpenArmorPanel = OpenArmorPanel
