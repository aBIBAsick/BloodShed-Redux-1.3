local shop_select_panel = nil

hook.Add("Think", "MuR_Shop", function()
	if input.IsKeyDown(KEY_F2) and not IsValid(shop_select_panel) then
		RunConsoleCommand("mur_shop")
	end
end)

-------------------------------------------
-------------------------------------------

concommand.Add("mur_shop", function()
    if !LocalPlayer():Alive() then return end
    OpenShop()
end)

local THEME = {
    background = Color(15, 15, 20, 250),
    accent = Color(180, 40, 40),
    panel = Color(25, 25, 30, 255),
    text = Color(255, 255, 255),
    textDark = Color(200, 200, 200),
    success = Color(40, 180, 120),
    danger = Color(220, 50, 50)
}

function OpenShop()
    local shopmenu = vgui.Create("DFrame")
    local frameW, frameH, animTime, animDelay, animEase = We(800), He(400), 0.3, 0, 0.1
    local animating = true
    shopmenu:SetSize(frameW, He(0))
    shopmenu:MakePopup()
    shopmenu:SetTitle("")
    shopmenu:Center()
    shopmenu:ShowCloseButton(false)
    shopmenu:SizeTo(frameW, frameH, animTime, animDelay, animEase, function()
        animating = false
    end)
    shop_select_panel = shopmenu

    shopmenu.Think = function(self)
        if animating then
            shopmenu:Center()
        end
    end

    local blur = Material("pp/blurscreen")
    function BlurBackground(panel, amount)
        if not IsValid(panel) then return end
        local x, y = panel:LocalToScreen(0, 0)
        local scrW, scrH = ScrW(), ScrH()
        
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(blur)
        
        for i = 1, 3 do
            blur:SetFloat("$blur", (i / 3) * (amount or 6))
            blur:Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(-x, -y, scrW, scrH)
        end
    end

    local mainPanel = vgui.Create("DPanel", shopmenu)
    mainPanel:Dock(FILL)
    mainPanel:DockMargin(0, He(60), 0, 0)
    mainPanel.Paint = function() end

    shopmenu.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, THEME.background)
        draw.RoundedBox(8, 0, 0, w, He(60), THEME.panel)
        surface.SetDrawColor(THEME.accent)
        surface.DrawRect(0, He(60), w, He(2))
        draw.SimpleText(MuR.Language["shop"] or "Shop", "MuR_Font3", We(30), He(30), THEME.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        local money = LocalPlayer():GetNW2Float('Money', 0)
        draw.SimpleText("$" .. money, "MuR_Font3", w - We(120), He(30), THEME.accent, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    local closeBtn = vgui.Create("DButton", shopmenu)
    closeBtn:SetSize(We(32), He(32))
    closeBtn:SetPos(frameW - We(42), He(14))
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
        shopmenu:Close()
    end

    local buttonPanel = vgui.Create("DPanel", mainPanel)
    buttonPanel:Dock(FILL)
    buttonPanel.Paint = function() end

    local function CreateButton(parent, text, onBClick, checkFunc)
        local button = vgui.Create("DButton", parent)
        button:Dock(TOP)
        button:DockMargin(We(20), He(10), We(20), 0)
        button:SetTall(He(80))
        button:SetText("")
        
        local hovered = false
        local alpha = 0
        
        button.Think = function(self)
            if not checkFunc or checkFunc() then
                if self:IsHovered() and not hovered then
                    hovered = true
                    alpha = 0
                elseif not self:IsHovered() and hovered then
                    hovered = false
                    alpha = 255
                end
                
                alpha = Lerp(FrameTime() * 8, alpha, hovered and 255 or 0)
            end
        end

        button.Paint = function(self, w, h)
            local isEnabled = not checkFunc or checkFunc()
            local baseAlpha = isEnabled and 255 or 100
            
            draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(THEME.panel, baseAlpha))
            
            if isEnabled and self:IsHovered() then
                surface.SetDrawColor(THEME.accent.r, THEME.accent.g, THEME.accent.b, alpha * 0.1)
                draw.RoundedBox(8, 0, 0, w, h, Color(THEME.accent.r, THEME.accent.g, THEME.accent.b, alpha * 0.1))
                
                surface.SetDrawColor(THEME.accent.r, THEME.accent.g, THEME.accent.b, alpha * 0.8)
                surface.DrawRect(0, 0, We(3), h)
            end
            
            local textColor = isEnabled and Color(255, 255, 255, 255 - alpha * 0.3) or Color(100, 100, 100, 100)
            draw.SimpleText(text, "MuR_Font3", We(80), h/2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            if not isEnabled then
                local roleText = "Unavailable"
                draw.SimpleText(roleText, "MuR_Font3", w - We(30), h/2, Color(100, 100, 100, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end

        button.DoClick = function()
            if not checkFunc or checkFunc() then
                surface.PlaySound("murdered/vgui/ui_click.wav")
                onBClick()
            else
                surface.PlaySound("murdered/vgui/ui_return.wav")
            end
        end

        return button
    end

    CreateButton(buttonPanel, "Civilian Shop", function()
        shopmenu:Close()
        OpenCategoryShop("Civilian")
    end, function()
        return true
    end)

    CreateButton(buttonPanel, "Black Market", function()
        shopmenu:Close()
        OpenCategoryShop("Killer")
    end, function()
        return LocalPlayer():IsKiller() or LocalPlayer():GetNW2String('Class') == "Criminal"
    end)

    CreateButton(buttonPanel, "Military Equipment", function()
        shopmenu:Close()
        OpenCategoryShop("Soldier")
    end, function()
        return LocalPlayer():GetNW2String('Class') == "Soldier"
    end)
end

function OpenCategoryShop(category)
    local shopmenu = vgui.Create("DFrame")
    local frameW, frameH, animTime, animDelay, animEase = We(850), He(570), 0.3, 0, 0.1
    local animating = true
    local counts = 0
    shopmenu:SetSize(frameW, He(0))
    shopmenu:MakePopup()
    shopmenu:SetTitle("")
    shopmenu:Center()
    shopmenu:ShowCloseButton(false)
    shopmenu:SizeTo(frameW, frameH, animTime, animDelay, animEase, function()
        animating = false
    end)
    shop_select_panel = shopmenu

    local mainPanel = vgui.Create("DPanel", shopmenu)
    mainPanel:Dock(FILL)
    mainPanel:DockMargin(0, He(60), 0, 0)
    mainPanel.Paint = function() end

    local scr = vgui.Create("DScrollPanel", shopmenu)
    scr:Dock(FILL)
    scr:DockMargin(We(10), He(70), We(10), He(10))
    
    local sbar = scr:GetVBar()
    sbar:SetWide(We(8))
    function sbar:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(THEME.panel.r, THEME.panel.g, THEME.panel.b, 100))
    end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, THEME.accent)
    end
    
    shopmenu.Think = function(self)
        if animating then
            shopmenu:Center()
        end
    end
    
    shopmenu.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, THEME.background)
        draw.RoundedBox(8, 0, 0, w, He(60), THEME.panel)
        surface.SetDrawColor(THEME.accent)
        surface.DrawRect(0, He(60), w, He(2))
        
        draw.SimpleText(MuR.Language["shop"], "MuR_Font3", We(30), He(30), THEME.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        local money = LocalPlayer():GetNW2Float('Money', 0)
        draw.SimpleText("$" .. money, "MuR_Font3", w - We(120), He(30), THEME.accent, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

        draw.SimpleText(counts..MuR.Language["search_newhud_found"], "MuR_Font2", w/2.05, He(80), THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    local closeBtn = vgui.Create("DButton", shopmenu)
    closeBtn:SetSize(We(32), He(32))
    closeBtn:SetPos(frameW - We(42), He(14))
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
        shopmenu:Close()
    end

    local itemGrid = vgui.Create("DIconLayout", scr)
    itemGrid:Dock(TOP)
    itemGrid:DockMargin(We(10), He(10), We(10), He(10))
    itemGrid:SetSpaceX(We(10))
    itemGrid:SetSpaceY(He(10))

    for k, v in pairs(MuR.Shop[category]) do
        if category == "Killer" and not LocalPlayer():IsKiller() and v.traitor then 
            continue 
        end
        counts = counts + 1
        
        local item = vgui.Create("DButton")
        item:SetSize(We(380), He(140))
        itemGrid:Add(item)
        item:SetText("")
        
        local hovered = false
        local alpha = 0
        
        item.Think = function(self)
            if self:IsHovered() and not hovered then
                hovered = true
                alpha = 0
            elseif not self:IsHovered() and hovered then
                hovered = false
                alpha = 255
            end
            
            alpha = Lerp(FrameTime() * 8, alpha, hovered and 255 or 0)
        end
    
        item.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, THEME.panel)
            
            if self:IsHovered() then
                surface.SetDrawColor(THEME.accent.r, THEME.accent.g, THEME.accent.b, 30)
                draw.RoundedBox(8, 0, 0, w, h, Color(THEME.accent.r, THEME.accent.g, THEME.accent.b, 30))
                
                surface.SetDrawColor(THEME.accent.r, THEME.accent.g, THEME.accent.b, 100)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            end
            
            draw.SimpleText(v.name, "MuR_Font3", We(140), h/2.4, THEME.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            local canBuy = LocalPlayer():GetNW2Float('Money') >= v.price
            local priceColor = canBuy and THEME.success or THEME.danger
            draw.SimpleText("$" .. v.price, "MuR_Font2", We(140), h/1.6, priceColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    
            local itemmaterial = Material(v.icon)
            surface.SetMaterial(itemmaterial)
            surface.SetDrawColor(255, 255, 255)
            surface.DrawTexturedRect(We(50), h/3, We(50), He(50))
        end
    
        item.DoClick = function(self)
            local m = LocalPlayer():GetNW2Float('Money', 0)

            if m >= v.price then
                surface.PlaySound("murdered/vgui/buy.wav")
                timer.Simple(0.1, function()
                    net.Start("MuR.UseShop")
                    net.WriteString(category)
                    net.WriteFloat(k)
                    net.SendToServer()
                end)
            else
                surface.PlaySound("murdered/vgui/ui_return.wav")
            end
        end
    end
end