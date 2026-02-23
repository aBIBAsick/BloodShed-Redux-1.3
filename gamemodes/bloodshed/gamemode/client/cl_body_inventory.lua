local function GetWeaponInfo(class)
    local swep = weapons.Get(class)
    local icon = file.Exists("materials/entities/" .. class .. ".png", "GAME") and "entities/" .. class .. ".png" or "entities/question.png"
    if string.find(class, "_food_") then
        icon = "entities/food.png"
    end
    if swep then
        return swep.PrintName or class, icon
    elseif MuR.CustomLootEntityIcons[class] then
        return MuR.CustomLootEntityIcons[class][1], MuR.CustomLootEntityIcons[class][2]
    else
        return class, icon
    end
end

local SEARCH_THEME = {
    background = Color(40, 40, 50, 240),
    accent = Color(255, 100, 100),
    panel = Color(60, 60, 70, 255),
    panelHover = Color(80, 80, 90, 255),
    text = Color(255, 255, 255),
    textDark = Color(180, 180, 180),
    success = Color(100, 255, 100),
    danger = Color(255, 100, 100),
    searching = Color(120, 120, 130, 255)
}

local searchedItems = {}

local function CreateTimingMinigame(callback, failCallback, frame)
    local minigameFrame = vgui.Create("DFrame")
    minigameFrame:SetSize(We(500), He(200))
    minigameFrame:Center()
    minigameFrame:SetTitle("")
    minigameFrame:SetDraggable(false)
    minigameFrame:MakePopup()
    minigameFrame:ShowCloseButton(false)
    minigameFrame:SetKeyboardInputEnabled(true)
    minigameFrame:AlphaTo(0, 0)
    minigameFrame:AlphaTo(255, 0.2)
    frame:AlphaTo(0, 0.2)

    local barWidth = We(400)
    local barHeight = He(20)
    local targetZone = We(60)
    local targetPos = barWidth / 2 - targetZone / 2
    
    local sliderPos = We(math.random(1,649))
    local sliderSpeed = We(650)
    local direction = math.random(0,1) == 0 and -1 or 1
    local gameActive = true
    
    minigameFrame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, SEARCH_THEME.background)
        draw.RoundedBox(8, We(10), He(10), w - We(20), He(60), SEARCH_THEME.panel)
        
        local barX = (w - barWidth) / 2
        local barY = He(100)
        
        draw.RoundedBox(4, barX, barY, barWidth, barHeight, Color(30, 30, 30, 255))
        
        draw.RoundedBox(4, barX + targetPos, barY, targetZone, barHeight, SEARCH_THEME.success)
        
        if gameActive then
            draw.RoundedBox(4, barX + sliderPos, barY - He(5), We(10), barHeight + He(10), SEARCH_THEME.accent)
        end
    end
    
    local title = vgui.Create("DLabel", minigameFrame)
    title:SetText(MuR.Language["search_newhud_tt"])
    title:SetFont("MuR_Font3")
    title:SetTextColor(SEARCH_THEME.text)
    title:SetPos(We(20), He(20))
    title:SizeToContents()
    
    local instruction = vgui.Create("DLabel", minigameFrame)
    instruction:SetText(MuR.Language["search_newhud_space"])
    instruction:SetFont("MuR_FontDef")
    instruction:SetTextColor(SEARCH_THEME.textDark)
    instruction:SetPos(We(20), He(52))
    instruction:SizeToContents()
    
    local function UpdateSlider()
        if not gameActive then return end
        
        sliderPos = sliderPos + sliderSpeed * FrameTime() * direction
        
        if sliderPos <= 0 then
            sliderPos = 0
            direction = 1
        elseif sliderPos >= barWidth - We(10) then
            sliderPos = barWidth - We(10)
            direction = -1
        end
    end
    
    local function CheckHit()
        if not gameActive then return end
        
        local sliderCenter = sliderPos + We(5)
        local targetStart = targetPos
        local targetEnd = targetPos + targetZone
        
        if sliderCenter >= targetStart and sliderCenter <= targetEnd then
            gameActive = false
            instruction:SetText(MuR.Language["search_newhud_perfect"])
            instruction:SetTextColor(SEARCH_THEME.success)
            surface.PlaySound("buttons/button9.wav")
            
            timer.Simple(0.5, function()
                if IsValid(minigameFrame) then
                    minigameFrame:Remove()
                    if IsValid(frame) then frame:AlphaTo(255, 0.2) end
                    callback()
                end
            end)
        else
            gameActive = false
            instruction:SetText(MuR.Language["search_newhud_missed"])
            instruction:SetTextColor(SEARCH_THEME.danger)
            surface.PlaySound("buttons/button10.wav")
            
            timer.Simple(0.5, function()
                if IsValid(minigameFrame) then
                    minigameFrame:Remove()
                    if IsValid(frame) then frame:AlphaTo(255, 0.2) end
                    failCallback()
                end
            end)
        end
    end
    
    minigameFrame.OnKeyCodePressed = function(self, key)
        if key == KEY_SPACE then
            CheckHit()
        end
    end
    
    minigameFrame.Think = UpdateSlider
end

local function CreateWeaponPanel(weaponTable, body)
    local bodyID = body:EntIndex()
    if not searchedItems[bodyID] then
        searchedItems[bodyID] = {}
    end
    
    local columns = math.min(math.ceil(math.sqrt(#weaponTable)), 5)
    local buttonSize = We(120)
    local spacing = We(15)
    local panelWidth = math.max(columns * (buttonSize + spacing) + spacing, We(500))
    local rows = math.ceil(#weaponTable / columns)
    local panelHeight = math.max(He(120) + rows * (buttonSize + He(40)) + spacing, He(400))

    local frame = vgui.Create("DFrame")
    frame:SetSize(panelWidth, panelHeight)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:SetBackgroundBlur(true)
    frame:ShowCloseButton(false)
    frame:AlphaTo(0, 0)
    frame:AlphaTo(255, 0.3)
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, SEARCH_THEME.background)
        draw.RoundedBox(12, 0, 0, w, He(80), SEARCH_THEME.panel)
        surface.SetDrawColor(SEARCH_THEME.accent)
        surface.DrawRect(0, He(80), w, He(3))
    end
    
    frame.OnKeyCodePressed = function(self, key)
        if key == KEY_E or key == KEY_ESCAPE then
            frame:AlphaTo(0, 0.2, 0, function()
                self:Remove()
            end)
        end
    end

    local title = vgui.Create("DLabel", frame)
    title:SetText(MuR.Language["gui_searchmenu"])
    title:SetFont("MuR_Font3")
    title:SetTextColor(SEARCH_THEME.text)
    title:SetPos(We(25), He(10))
    title:SizeToContents()

    local subtitle = vgui.Create("DLabel", frame)
    subtitle:SetText(MuR.Language["search_newhud_close"])
    subtitle:SetFont("MuR_FontDef")
    subtitle:SetTextColor(SEARCH_THEME.textDark)
    subtitle:SetPos(We(25), He(40))
    subtitle:SizeToContents()

    local itemCount = vgui.Create("DLabel", frame)
    itemCount:SetText(#weaponTable .. MuR.Language["search_newhud_found"])
    itemCount:SetFont("MuR_Font1")
    itemCount:SetTextColor(SEARCH_THEME.accent)
    itemCount:SetPos(We(25), He(55))
    itemCount:SizeToContents()

    if #weaponTable == 0 then
        local noItemsLabel = vgui.Create("DLabel", frame)
        noItemsLabel:SetText("0"..MuR.Language["search_newhud_found"])
        noItemsLabel:SetFont("MuR_Font3")
        noItemsLabel:SetTextColor(SEARCH_THEME.textDark)
        noItemsLabel:SetPos(We(25), frame:GetTall()/2)
        noItemsLabel:SizeToContents()
        return
    end

    local scrollPanel = vgui.Create("DScrollPanel", frame)
    scrollPanel:SetPos(We(15), He(95))
    scrollPanel:SetSize(panelWidth - We(30), panelHeight - He(110))
    
    local sbar = scrollPanel:GetVBar()
    sbar:SetWide(We(8))
    function sbar:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(SEARCH_THEME.panel.r, SEARCH_THEME.panel.g, SEARCH_THEME.panel.b, 100))
    end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, SEARCH_THEME.accent)
    end

    local grid = vgui.Create("DIconLayout", scrollPanel)
    grid:SetSize(scrollPanel:GetWide() - We(10), scrollPanel:GetTall())
    grid:SetSpaceX(spacing)
    grid:SetSpaceY(He(15))
    grid:SetBorder(spacing)

    for i, class in ipairs(weaponTable) do
        local name, icon = GetWeaponInfo(class)
        
        local weaponButton = grid:Add("DButton")
        weaponButton:SetSize(buttonSize, buttonSize + He(35))
        weaponButton:SetText("")
        weaponButton:SetEnabled(true)
        weaponButton.classwep = class
        weaponButton.isSearched = searchedItems[bodyID][class] or false
        
        function weaponButton:Paint(w, h)
            local bgColor = SEARCH_THEME.panel
            local borderColor = Color(0, 0, 0, 0)
            
            if LocalPlayer():HasWeapon(class) then
                bgColor = Color(SEARCH_THEME.danger.r, SEARCH_THEME.danger.g, SEARCH_THEME.danger.b, 100)
                borderColor = SEARCH_THEME.danger
            elseif self:IsHovered() then
                bgColor = SEARCH_THEME.panelHover
                borderColor = SEARCH_THEME.accent
            end
            
            draw.RoundedBox(8, 0, 0, w, h, bgColor)
            if borderColor.a > 0 then
                surface.SetDrawColor(borderColor)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            end
        end

        local weaponIcon = vgui.Create("DImage", weaponButton)
        weaponIcon:SetSize(We(80), He(80))
        weaponIcon:SetPos((buttonSize - We(80)) / 2, He(10))

        local nameLabel = vgui.Create("DLabel", weaponButton)
        nameLabel:SetPos(0, buttonSize - He(20))
        nameLabel:SetSize(buttonSize, He(20))
        nameLabel:SetFont("MuR_Font1")
        nameLabel:SetContentAlignment(5)

        if weaponButton.isSearched then
            weaponIcon:SetImage(icon)
            nameLabel:SetText(name)
            nameLabel:SetTextColor(SEARCH_THEME.text)
            
            if LocalPlayer():HasWeapon(class) then
                nameLabel:SetTextColor(SEARCH_THEME.danger)
            end
            
            weaponButton.DoClick = function()
                if LocalPlayer():HasWeapon(class) then
                    surface.PlaySound("buttons/button10.wav")
                    return
                end
                
                surface.PlaySound("buttons/button14.wav")
                weaponButton:AlphaTo(0, 0.2, 0, function()
                    if IsValid(weaponButton) then
                        weaponButton:Remove()
                        grid:InvalidateLayout(true)
                    end
                end)
                
                net.Start("MuR.BodySearch")
                net.WriteEntity(body)
                net.WriteString(class)
                net.SendToServer()
            end
        else
            weaponIcon:SetImage("entities/search.png")
            nameLabel:SetText(MuR.Language["search_newhud_click"])
            nameLabel:SetTextColor(SEARCH_THEME.textDark)
            
            weaponButton.DoClick = function()
                if LocalPlayer():HasWeapon(class) then
                    surface.PlaySound("buttons/button10.wav")
                    return
                end
                
                weaponButton:SetEnabled(false)
                nameLabel:SetText("")
                
                CreateTimingMinigame(function()
                    if IsValid(weaponButton) and IsValid(frame) then
                        weaponIcon:SetImage(icon)
                        nameLabel:SetText(name)
                        nameLabel:SetTextColor(SEARCH_THEME.text)
                        surface.PlaySound("buttons/button9.wav")
                        
                        searchedItems[bodyID][class] = true
                        weaponButton.isSearched = true
                        
                        if LocalPlayer():HasWeapon(class) then
                            nameLabel:SetTextColor(SEARCH_THEME.danger)
                        end
                        
                        weaponButton:SetEnabled(true)
                        weaponButton.DoClick = function()
                            if LocalPlayer():HasWeapon(class) then
                                surface.PlaySound("buttons/button10.wav")
                                return
                            end
                            
                            surface.PlaySound("buttons/button14.wav")
                            weaponButton:AlphaTo(0, 0.2, 0, function()
                                if IsValid(weaponButton) then
                                    weaponButton:Remove()
                                    grid:InvalidateLayout(true)
                                end
                            end)
                            
                            net.Start("MuR.BodySearch")
                            net.WriteEntity(body)
                            net.WriteString(class)
                            net.SendToServer()
                        end
                    end
                end, function()
                    if IsValid(weaponButton) then
                        weaponButton:SetEnabled(true)
                        nameLabel:SetText(MuR.Language["search_newhud_click"])
                    end
                end, frame)
            end
        end
    end
end

net.Receive("MuR.BodySearch", function()
    local tab = net.ReadTable()
    local ent = net.ReadEntity()
    CreateWeaponPanel(tab, ent)
end)