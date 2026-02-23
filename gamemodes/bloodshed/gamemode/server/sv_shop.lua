local meta = FindMetaTable("Player")
util.AddNetworkString("MuR.UseShop")

net.Receive("MuR.UseShop", function(len, ply)
	local str = net.ReadString()
	local id = net.ReadFloat()
	ply:BuyItem(str, id)
end)

function meta:BuyItem(cat, id)
	if self:GetNW2Float("Guilt") >= 50 then
		MuR:GiveAnnounce("money_cancel", self)
		return
	end
	
	local tab = MuR.Shop[cat]
	if not istable(tab) or not tab[id] then return end
	if cat == "Soldier" and self:GetNW2String("Class") != "Soldier" or cat == "Killer" and not self:IsKiller() and self:GetNW2String("Class") != "Criminal" then return end
	if self:GetNW2String("Class") == "Maniac" then return end
	if !self:IsKiller() and tab.traitor then return end

	local item = tab[id]
	if self:GetNW2Float("Money") < item.price then return end
	if self.ItemBuyDelay and self.ItemBuyDelay > CurTime() then return end

	self.ItemBuyDelay = CurTime()+1
	self:SetNW2Float("Money", self:GetNW2Float("Money") - item.price)
	item.func(self)
end