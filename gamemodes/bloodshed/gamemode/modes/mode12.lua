MuR.RegisterMode(12, {
	name = "Terrorists vs SWAT", 
	chance = 20, 
	need_players = 4, 
	disables = true,
	no_default_roles = true,
	win_condition = "specops",
	custom_spawning = true,
	no_guilt = true, 
	timer = 300, 
	countdown_on_start = true,
	kteam = "Terrorist2",
	dteam = "SWAT",
	OnModeStarted = function(mode)
		if SERVER then
			SetGlobalFloat("MuR.Mode12.BuyTimeEnd", CurTime() + 45)

			for _, ply in player.Iterator() do
				local budget = math.Round(math.random(3000, 5000) / 10) * 10
				ply:SetNW2Int("MuR.Mode12.Money", budget)
			end
		end
	end
})

local ITEM_PRICES = {

	["tfa_bs_glock"] = 300, 
	["tfa_bs_usp"] = 475,
	["tfa_bs_p320"] = 450,
	["tfa_bs_walther"] = 400,
	["tfa_bs_deagle"] = 600,
	["tfa_bs_m9"] = 400, 
	["tfa_bs_cobra"] = 650,
	["tfa_bs_mateba"] = 650,
	["tfa_bs_colt"] = 350, 
	["tfa_bs_ruger"] = 525,
	["tfa_bs_pm"] = 200,

	["tfa_bs_mp5a5"] = 1200, 
	["tfa_bs_ump"] = 1250, 
	["tfa_bs_vector"] = 1650,
	["tfa_bs_uzi"] = 1100, 
	["tfa_bs_mac11"] = 1050, 
	["tfa_bs_mp7"] = 1450,

	["tfa_bs_nova"] = 2200, 
	["tfa_bs_m1014"] = 2500,
	["tfa_bs_izh43"] = 1200, 
	["tfa_bs_izh43sw"] = 1000, 
	["tfa_bs_m590"] = 1600,
	["tfa_bs_spas"] = 2300, 
	["tfa_bs_m500"] = 2300,
	["tfa_bs_m37"] = 2000,
	["tfa_bs_ks23"] = 2750,

	["tfa_bs_akm"] = 3200, 
	["tfa_bs_hk416"] = 3100, 
	["tfa_bs_val"] = 3200,
	["tfa_bs_ak74"] = 2800, 
	["tfa_bs_l1a1"] = 3400, 
	["tfa_bs_aug"] = 2900,
	["tfa_bs_m4a1"] = 3000, 
	["tfa_bs_mk17"] = 3600,
	["tfa_bs_m16"] = 2750,
	["tfa_bs_draco"] = 2750,
	["tfa_bs_ak12"] = 3000,
	["tfa_bs_aks74u"] = 2750,
	["tfa_bs_badger"] = 2700,
	["tfa_bs_acr"] = 3000,
	["tfa_bs_sg552"] = 2800,
	["tfa_bs_aug"] = 2950,

	["tfa_bs_sks"] = 3600, 
	["tfa_bs_sr25"] = 4500,

	["tfa_bs_m24"] = 4400, 
	["tfa_bs_svd"] = 4550,
	["tfa_bs_kar98"] = 3800, 
	["tfa_bs_mosin"] = 3750,
	["tfa_bs_m82"] = 4900,

	["tfa_bs_m249"] = 4500, 
	["tfa_bs_pkm"] = 4750, 
	["tfa_bs_rpk"] = 4400,

	["mur_f1"] = 750,
	["mur_m67"] = 750,
	["mur_beartrap"] = 500,
	["tfa_bs_police_shield"] = 1500,
	["mur_flashbang"] = 750,
	["mur_doorlooker"] = 250
}

local BLOCKED_WEAPONS = {
	["tfa_bs_colt_nz"] = true,
	["tfa_bs_glock_t"] = true,
	["tfa_bs_vp9"] = true
}

local OTHERS_ITEMS = {
	["Terrorist2"] = {
		{class = "mur_f1", name = "F1 Grenade"},
		{class = "mur_m67", name = "M67 Grenade"},
		{class = "mur_beartrap", name = "Bear Trap"}
	},
	["SWAT"] = {
		{class = "tfa_bs_police_shield", name = "Ballistic Shield"},
		{class = "mur_flashbang", name = "Flashbang"},
		{class = "mur_doorlooker", name = "Surveillance Device"}
	}
}

if SERVER then
	util.AddNetworkString("MuR.Mode12.Buy")
	util.AddNetworkString("MuR.Mode12.BuyAmmo")

	net.Receive("MuR.Mode12.Buy", function(len, ply)
		if MuR.Gamemode != 12 then return end
		if CurTime() > GetGlobalFloat("MuR.Mode12.BuyTimeEnd", 0) then 
			ply:ChatPrint("[Bloodshed] Buy time is over!")
			return 
		end
		if not ply:Alive() then return end

		local class = net.ReadString()

		if BLOCKED_WEAPONS[class] then return end

		local price = 0
		local found = false

		if ITEM_PRICES[class] then
			price = ITEM_PRICES[class]
			found = true
		end

		if found then
			local teamName = ply:GetNW2String("Class")

			local isRestrictedItem = false
			local myTeamHasItem = false

			for tName, items in pairs(OTHERS_ITEMS) do
				for _, item in ipairs(items) do
					if item.class == class then
						isRestrictedItem = true
						if tName == teamName then
							myTeamHasItem = true
						end
					end
				end
			end

			if isRestrictedItem and not myTeamHasItem then
				found = false
			end
		end

		if not found then return end

		local money = ply:GetNW2Int("MuR.Mode12.Money", 0)
		if money >= price then
			ply:SetNW2Int("MuR.Mode12.Money", money - price)
			ply:GiveWeapon(class)
			MuR:PlaySoundOnClient("items/ammo_pickup.wav", ply)
		else
			MuR:GiveAnnounce(MuR.Language and MuR.Language["mode12_not_enough_money"] or "Not enough money!", ply)
		end
	end)

	net.Receive("MuR.Mode12.BuyAmmo", function(len, ply)
		if MuR.Gamemode != 12 then return end
		if CurTime() > GetGlobalFloat("MuR.Mode12.BuyTimeEnd", 0) then return end
		if not ply:Alive() then return end

		local class = net.ReadString()
		local wep = ply:GetWeapon(class)
		if not IsValid(wep) then return end

		local money = ply:GetNW2Int("MuR.Mode12.Money", 0)
		if money < 50 then
			MuR:GiveAnnounce(MuR.Language and MuR.Language["mode12_not_enough_money"] or "Not enough money!", ply)
			return
		end

		local ammoType = wep:GetPrimaryAmmoType()
		if ammoType == -1 then return end

		local clipSize = wep:GetMaxClip1()
		if clipSize <= 0 then clipSize = 30 end

		ply:SetNW2Int("MuR.Mode12.Money", money - 50)
		ply:GiveAmmo(clipSize, ammoType, true)
		MuR:PlaySoundOnClient("items/ammo_pickup.wav", ply)
	end)

	hook.Add("ShowSpare1", "MuR.Mode12.OpenMenu", function(ply)
		if MuR.Gamemode == 12 and CurTime() < GetGlobalFloat("MuR.Mode12.BuyTimeEnd", 0) then
			ply:ConCommand("mur_mode12_buymenu")
			return false
		end
	end)
end

if CLIENT then
	local BLOCKED_WEAPONS_CL = {
		["tfa_bs_colt_nz"] = true,
		["tfa_bs_glock_t"] = true,
		["tfa_bs_vp9"] = true
	}

	local function We(x) return x / 1920 * ScrW() end
	local function He(y) return y / 1080 * ScrH() end

	hook.Add("HUDPaint", "MuR.Mode12.HUD", function()
		if MuR.GamemodeCount == 12 and CurTime() < GetGlobalFloat("MuR.Mode12.BuyTimeEnd", 0) then
			local timeLeft = math.ceil(math.max(0, GetGlobalFloat("MuR.Mode12.BuyTimeEnd", 0) - CurTime()))
			local text = string.format(MuR.Language["mode12_hud_buy"] or "F3 TO BUY - %s SECONDS LEFT", timeLeft)
			draw.SimpleText(text, "MuR_Font2", ScrW() / 2, ScrH() / 2 + He(200), Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end)

	local NO_AMMO_ITEMS = {
		["mur_f1"] = true,
		["mur_m67"] = true,
		["mur_beartrap"] = true,
		["mur_flashbang"] = true,
		["tfa_bs_police_shield"] = true,
		["mur_doorlooker"] = true
	}

	concommand.Add("mur_mode12_buymenu", function()
		if MuR.GamemodeCount != 12 then return end
		if CurTime() > GetGlobalFloat("MuR.Mode12.BuyTimeEnd", 0) then 
			chat.AddText(Color(255, 50, 50), MuR.Language["mode12_buy_time_over"] or "[Bloodshed] Buy time is over!")
			return 
		end

		local frame = vgui.Create("DFrame")
		frame:SetSize(We(1000), He(700))
		frame:Center()
		frame:SetTitle("")
		frame:MakePopup()
		frame:ShowCloseButton(false)
		frame.Paint = function(self, w, h)

			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) 

			surface.SetDrawColor(200, 0, 0)
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.DrawOutlinedRect(1, 1, w-2, h-2)
		end

		local sidebar = vgui.Create("DPanel", frame)
		sidebar:SetPos(0, 0)
		sidebar:SetSize(We(250), frame:GetTall())
		sidebar.Paint = function(self, w, h)
			surface.SetDrawColor(200, 0, 0)
			surface.DrawLine(w-1, 0, w-1, h)
		end

		local moneyLabel = vgui.Create("DLabel", sidebar)
		local currentMoney = LocalPlayer():GetNW2Int("MuR.Mode12.Money", 0)
		moneyLabel:SetText("$" .. currentMoney)
		moneyLabel:SetFont("DermaLarge")
		moneyLabel:SetTextColor(Color(0, 255, 0))
		moneyLabel:SetPos(We(10), frame:GetTall() - He(50))
		moneyLabel:SizeToContents()
		moneyLabel.Think = function(s)
			local newMoney = LocalPlayer():GetNW2Int("MuR.Mode12.Money", 0)
			if s.lastMoney != newMoney then
				s.lastMoney = newMoney
				s:SetText("$" .. newMoney)
				s:SizeToContents()
			end
		end

		local content = vgui.Create("DScrollPanel", frame)
		content:SetPos(We(260), 40)
		content:SetSize(frame:GetWide() - We(270), frame:GetTall() - 50)

		local grid = vgui.Create("DIconLayout", content)
		grid:SetSpaceX(10)
		grid:SetSpaceY(10)
		grid:Dock(FILL)

		local closeBtn = vgui.Create("DButton", frame)
		closeBtn:SetText("X")
		closeBtn:SetFont("DermaDefaultBold")
		closeBtn:SetTextColor(Color(255, 255, 255))
		closeBtn:SetSize(20, 30)
		closeBtn:SetPos(frame:GetWide() - 25, 5)
		closeBtn.Paint = function(self, w, h)
			if self:IsHovered() then
				draw.RoundedBox(0, 0, 0, w, h, Color(200, 0, 0, 255))
			else
				draw.RoundedBox(0, 0, 0, w, h, Color(150, 0, 0, 200))
			end
		end
		closeBtn.DoClick = function()
			frame:Close()
		end

		local shopItems = {}

		local function CleanCategory(cat)
			return cat:gsub("Bloodshed %- ", "")
		end

		local ignoredInMainLoop = {}
		for _, teamItems in pairs(OTHERS_ITEMS) do
			for _, item in ipairs(teamItems) do
				ignoredInMainLoop[item.class] = true
			end
		end

		for _, wep in pairs(weapons.GetList()) do
			if ITEM_PRICES[wep.ClassName] and wep.Category and wep.Category != "Others" then
				if not blocked_weapons_cl and not BLOCKED_WEAPONS_CL[wep.ClassName] and not ignoredInMainLoop[wep.ClassName] then
					local catName = CleanCategory(wep.Category)
					shopItems[catName] = shopItems[catName] or {}
					table.insert(shopItems[catName], {
						class = wep.ClassName,
						name = wep.PrintName or wep.ClassName,
						price = ITEM_PRICES[wep.ClassName],
						model = wep.WorldModel,
						ammo = wep.Primary and wep.Primary.Ammo
					})
				end
			end
		end

		local myTeam = LocalPlayer():GetNW2String("Class")
		if OTHERS_ITEMS[myTeam] then
			local catName = "Equipment" 
			shopItems[catName] = shopItems[catName] or {}
			for _, item in ipairs(OTHERS_ITEMS[myTeam]) do
				if not BLOCKED_WEAPONS_CL[item.class] then

					local wep = weapons.GetStored(item.class)
					local model = (wep and wep.WorldModel) or "models/error.mdl"

					if item.class == "mur_f1" then model = "models/simpnades/w_f1.mdl" end
					if item.class == "mur_m67" then model = "models/simpnades/w_m67.mdl" end
					if item.class == "mur_flashbang" then model = "models/simpnades/w_m84.mdl" end

					table.insert(shopItems[catName], {
						class = item.class,
						name = item.name,
						price = ITEM_PRICES[item.class] or 1000,
						model = model,
						ammo = nil 
					})
				end
			end
		end

		local categoryOrder = {
			"Sidearms", "SubMachine Guns", "Shotguns", "Rifles", "Machine Guns",
			"Marksmans", "Snipers", "Sniper Rifles", "Explosive", "Equipment"
		}

		for cat, _ in pairs(shopItems) do
			if not table.HasValue(categoryOrder, cat) then
				table.insert(categoryOrder, cat)
			end
		end

		local function RebuildGrid(category)
			grid:Clear()
			content:GetVBar():SetScroll(0)

			local items = shopItems[category] or {}
			for _, item in ipairs(items) do
				local card = grid:Add("DPanel")
				card:SetSize(230, 150)
				card.Paint = function(self, w, h)
					draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 100))
					surface.SetDrawColor(200, 0, 0)
					surface.DrawOutlinedRect(0, 0, w, h)
				end

				local nameLabel = vgui.Create("DLabel", card)
				nameLabel:SetText(item.name)
				nameLabel:SetFont("DermaDefaultBold")
				nameLabel:SetTextColor(Color(255, 255, 255))
				nameLabel:SetPos(5, 5)
				nameLabel:SetSize(220, 15) 

				local priceLabel = vgui.Create("DLabel", card)
				priceLabel:SetText("$" .. item.price)
				priceLabel:SetFont("DermaDefaultBold")
				priceLabel:SetTextColor(Color(0, 255, 0))
				surface.SetFont("DermaDefaultBold")
				local tw, th = surface.GetTextSize("$" .. item.price)
				priceLabel:SetPos(230 - tw - 5, 5)
				priceLabel:SetSize(tw, th)

				local modelPanel = vgui.Create("DModelPanel", card)
				modelPanel:SetSize(200, 100)
				modelPanel:SetPos(15, 25)
				modelPanel:SetModel(item.model or "models/error.mdl")
				modelPanel:SetFOV(35)
				modelPanel:SetCamPos(Vector(50, 50, 50))
				modelPanel:SetLookAt(Vector(0, 0, 0))

				function modelPanel:LayoutEntity(Entity)
					Entity:SetAngles(Angle(0, RealTime() * 30 % 360, 0))
				end

				local buyBtn = vgui.Create("DButton", card)
				buyBtn:SetText("Buy")
				buyBtn:SetSize(50, 20)
				buyBtn:SetPos(230 - 55, 150 - 25)
				buyBtn.Paint = function(self, w, h)
					draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 200))
					surface.SetDrawColor(200, 0, 0)
					surface.DrawOutlinedRect(0, 0, w, h)
					if self:IsHovered() then
						 draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 20))
					end
				end
				buyBtn:SetTextColor(Color(255, 255, 255))
				buyBtn.DoClick = function()
					net.Start("MuR.Mode12.Buy")
					net.WriteString(item.class)
					net.SendToServer()
					surface.PlaySound("ui/buttonclick.wav")
				end

				local hasAmmo = item.ammo and item.ammo ~= "none"
				if hasAmmo and not NO_AMMO_ITEMS[item.class] then
					local ammoBtn = vgui.Create("DButton", card)
					ammoBtn:SetText("Buy ammo")
					ammoBtn:SetSize(70, 20)
					ammoBtn:SetPos(230 - 55 - 75, 150 - 25)
					ammoBtn.Paint = function(self, w, h)
						draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 200))
						surface.SetDrawColor(200, 0, 0)
						surface.DrawOutlinedRect(0, 0, w, h)
						if self:IsHovered() then
							 draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 20))
						end
					end
					ammoBtn:SetTextColor(Color(255, 255, 255))
					ammoBtn.DoClick = function()
						net.Start("MuR.Mode12.BuyAmmo")
						net.WriteString(item.class)
						net.SendToServer()
						surface.PlaySound("ui/buttonclick.wav")
					end
				end
			end
		end

		local y = 10
		for _, cat in ipairs(categoryOrder) do
			if shopItems[cat] and #shopItems[cat] > 0 then
				local btn = vgui.Create("DButton", sidebar)
				btn:SetText(cat)
				btn:SetPos(We(10), y)
				btn:SetSize(We(230), 40)
				btn:SetFont("DermaLarge")
				btn:SetTextColor(Color(255, 255, 255))
				btn.Paint = function(self, w, h)
					draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 150))
					surface.SetDrawColor(200, 0, 0)
					surface.DrawOutlinedRect(0, 0, w, h)
					if self:IsHovered() then
						draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 10))
					end
				end
				btn.DoClick = function()
					RebuildGrid(cat)
				end
				y = y + 50
			end
		end

		for _, cat in ipairs(categoryOrder) do
			if shopItems[cat] and #shopItems[cat] > 0 then
				RebuildGrid(cat)
				break
			end
		end
	end)
end
