local meta = FindMetaTable("Player")
util.AddNetworkString("MuR.SendDataToClient")
util.AddNetworkString("MuR.PlaySoundOnClient")
util.AddNetworkString("MuR.ChatAdd")
util.AddNetworkString("MuR.Announce")
util.AddNetworkString("MuR.Message")
util.AddNetworkString("MuR.Message2")
util.AddNetworkString("MuR.Countdown")
util.AddNetworkString("MuR.FinalScreen")
util.AddNetworkString("MuR.ViewPunch")
util.AddNetworkString("MuR.PainImpulse")
util.AddNetworkString("MuR.StartScreen")
util.AddNetworkString("MuR.VoiceLines")
util.AddNetworkString("MuR.ShowLogScreen")
util.AddNetworkString("MuR.CalcView")
util.AddNetworkString("MuR.BodySearch")
util.AddNetworkString("MuR.SetHull")
util.AddNetworkString("MuR.WeaponryEffect")
util.AddNetworkString("MuR.BloodDamageSound")
util.AddNetworkString("MuR.Storm.Start")
util.AddNetworkString("MuR.Storm.End")
util.AddNetworkString("MuR.Storm.Thunder")
util.AddNetworkString("MuR.Storm.WindDirection")

MuR.guiltSession = {}
file.CreateDir("bloodshed/guilt/")

timer.Simple(1, function()
	if MuR.EnableDebug then
		MuR.GameStarted = true 
		MuR.Gamemode = 5
	end
end)

local WeaponCategories = {
	["Bloodshed - Shotguns"] = "Primary",
	["Bloodshed - Sniper Rifles"] = "Primary",
	["Bloodshed - Marksmans"] = "Primary",
	["Bloodshed - Submachine Guns"] = "Primary",
	["Bloodshed - Machine Guns"] = "Primary",
	["Bloodshed - Rifles"] = "Primary",
	["Bloodshed - Sidearms"] = "Secondary",
	["Bloodshed - Melee"] = "Melee"
}

function MuR:GenerateWeaponsTable()
	local weaponsTable = {
		["Primary"] = {},
		["Secondary"] = {},
		["Melee"] = {}
	}
	
	for id, weaponData in pairs(weapons.GetList()) do
		local category = weaponData.Category
		local weaponType = WeaponCategories[category]
		local className = weaponData.ClassName
		if string.find(className, "maniac") or string.find(className, "chainsaw") then continue end
		if weaponType then
			local ammoType = ""
			local ammoCount = 0
			
			if weaponData.Primary then
				ammoType = weaponData.Primary.Ammo or ""
				ammoCount = weaponData.Primary.ClipSize or 0
			end
			
			table.insert(weaponsTable[weaponType], {
				class = className,
				ammo = ammoType,
				count = ammoCount
			})
		end
	end
	
	return weaponsTable
end

local function GetRandomPlayer(exclude)
    local players = {}
    for _, ply in ipairs(player.GetAll()) do
        if ply:Alive() and ply ~= exclude then
            table.insert(players, ply)
        end
    end
    return #players > 0 and players[math.random(#players)] or nil
end

function meta:GiveWeapon(class, cantdrop)
	timer.Simple(0.01, function()
		local ent = ents.Create(class)
		if not IsValid(ent) or not IsValid(self) then return end
		ent:SetPos(self:GetPos())
		ent.GiveToPlayer = self
		ent.CantDrop = cantdrop

		if ent.IsTFAWeapon then
			ent.Primary.DefaultClip = ent.Primary.ClipSize
		end

		ent:Spawn()

		if ent.ClipSize then
			ent:SetClip1(ent.ClipSize)
			ent:SetClip2(0)
		end

		if IsValid(ent) then
			self:PickupWeapon(ent)
			ent.GiveToPlayer = nil
		end
	end)
end

function meta:NewHull()
	local tab = {Vector(-10, -10, 0), Vector(10, 10, 72), Vector(-10, -10, 0), Vector(10, 10, 38)}
	self:SetHull(tab[1], tab[2])
	self:SetHullDuck(tab[3], tab[4])
	net.Start("MuR.SetHull")
	net.WriteTable(tab)
	net.Send(self)
end

function meta:RandomSkin()
	local skinCount = self:SkinCount()
	local randomSkin = math.random(0, skinCount - 1)
	self:SetSkin(randomSkin)

	for i = 0, self:GetNumBodyGroups() - 1 do
		local bodyGroupCount = self:GetBodygroupCount(i)
		local randomBodyGroup = math.random(0, bodyGroupCount - 1)
		self:SetBodygroup(i, randomBodyGroup)
	end
end

local function isValidNameString(name)
    if not name then return false end
    if utf8.len(name) > 25 then return false end
    
	local havespace = false
    for p, c in utf8.codes(name) do
        local isLetter = (c >= 65 and c <= 90) or
                       (c >= 97 and c <= 122) or
                       (c >= 1040 and c <= 1103) or
                       c == 1025 or c == 1105 or
                       c == 32
        
        if not isLetter or havespace and c == 32 then
            return false
        end
		if c == 32 then
			havespace = true
		end
    end
    
    return true
end

function meta:SetNewName(force)
	if self.Male then
		local name = force or self:GetInfo("blsd_character_name_male", "")
		local isValidName = isValidNameString(name)
		if name != "" and isValidName then
			self:SetNWString("Name", name)
		else
			self:SetNWString("Name", table.Random(MuR.MaleNames))
		end
	else
		local name = force or self:GetInfo("blsd_character_name_female", "")
		local isValidName = isValidNameString(name)
		if name != "" and isValidName then
			self:SetNWString("Name", name)
		else
			self:SetNWString("Name", table.Random(MuR.FemaleNames))
		end
	end
end

function meta:AddMoney(num)
	self:SetNW2Float("Money", self:GetNW2Float("Money") + num)
end

function meta:ChangeGuilt(mult)
	if MuR.Ending or GetConVar("mur_disableguilt"):GetBool() or MuR.EnableDebug then return end
	
	local currentMode = MuR.Mode(MuR.Gamemode)
	if currentMode and currentMode.no_guilt then return end
	
	local guilt = self:GetNW2Float("Guilt", 0)
	local plus = 10 * mult

	self:SetNW2Float("Guilt", math.Clamp(guilt + plus, 0, 100))

	local id64, id = self:SteamID64(), self:SteamID()
	local guilt = self:GetNW2Float("Guilt")

	if guilt >= 100 then
		timer.Simple(0.1, function()
			if !IsValid(self) then return end
			RunConsoleCommand("ulx", "banid", ""..id.."", "1440", "Guilt reached 100 in Bloodshed Gamemode")
			self:SetNW2Float("Guilt", 0)
			file.Write("bloodshed/guilt/"..id64..".txt", "0")
		end)
	else
		file.Write("bloodshed/guilt/"..id64..".txt", self:GetNW2Float("Guilt", 0))
	end
end

hook.Add("PlayerInitialSpawn", "MuR.Connect", function(ply)
	timer.Simple(1, function()
		if !IsValid(ply) then return end
		local id = ply:SteamID64()
		local f = file.Read("bloodshed/guilt/"..id..".txt", "DATA")
		if isstring(f) then
			ply:SetNW2Float("Guilt", tonumber(f))
		end
	end)
end)

function meta:ChangeHunger(num, ent)
	self:SetNW2Float("Hunger", math.Clamp(self:GetNW2Float("Hunger") + num, 0, 100))
	self:SetNW2Float("Stamina", math.Clamp(self:GetNW2Float("Stamina") + num / 2, 0, 100))
end

function meta:IsAtBack(enemy)
	if not IsValid(enemy) then return end
	local enemyForward = enemy:GetForward()
	local enemyToPlayer = self:GetPos() - enemy:GetPos()
	local angle = enemyForward:Angle():Forward():Dot(enemyToPlayer:GetNormalized())
	local degrees = math.deg(math.acos(angle))

	return degrees > 100
end

function meta:ViewPunch(angle)
	net.Start("MuR.ViewPunch")
	net.WriteAngle(angle)
	net.Send(self)
end

function meta:ResetButtons()
	self:ConCommand("-attack")
	self:ConCommand("-attack2")
	self:ConCommand("-moveright")
	self:ConCommand("-moveleft")
	self:ConCommand("-back")
	self:ConCommand("-forward")
	self:ConCommand("-speed")
	self:ConCommand("-duck")
end

function meta:MakeRandomSound(iscough)
	if self.RandomPlayerSound > CurTime() then return end
	self.RandomPlayerSound = CurTime() + math.random(60, 300)
	local rnd, snd = math.random(1, 20), ""
	if iscough then
		rnd = 2
	end

	if rnd <= 10 then
		if self.Male then
			snd = "murdered/player/cough_m.wav"
		else
			snd = "murdered/player/cough_f.wav"
		end

		for i = 1, 2 do
			timer.Simple(i / 2 - 0.5, function()
				if not IsValid(self) then return end
				self:ViewPunch(Angle(4, 0, 0))
			end)
		end
	else
		if self.Male then
			snd = "murdered/player/sneeze_m.wav"
		else
			snd = "murdered/player/sneeze_f.wav"
		end

		timer.Simple(1, function()
			if not IsValid(self) then return end
			self:ViewPunch(Angle(8, 0, 0))
		end)
	end

	self:EmitSound(snd, 60, self.PitchVoice or 100)
end

function MuR:SendDataToClient(string, value, delay)
	if delay then
		timer.Simple(delay, function()
			net.Start("MuR.SendDataToClient")
			net.WriteString(string)

			net.WriteTable({value})

			net.Broadcast()
		end)
	else
		net.Start("MuR.SendDataToClient")
		net.WriteString(string)

		net.WriteTable({value})

		net.Broadcast()
	end
end

function MuR:ShowFinalScreen(type, allowvote)
	for _, ply in ipairs(MuR:GetAlivePlayers()) do
		if type == "traitor" and ply:IsKiller() then
			ply:AddMoney(250)
		end

		if type == "innocent" and not ply:IsKiller() then
			ply:AddMoney(50)
		end
	end

	net.Start("MuR.FinalScreen")
	net.WriteString(type)
	net.WriteBool(allowvote)
	net.Broadcast()
end

function MuR:PlaySoundOnClient(string, ply)
	net.Start("MuR.PlaySoundOnClient")
	net.WriteString(string)
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

function MuR:GiveAnnounce(type, ply)
	net.Start("MuR.Announce")
	net.WriteString(type)
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

function MuR:GiveMessage(type, ply)
	net.Start("MuR.Message")
	net.WriteString(type)
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

function MuR:GiveMessage2(type, ply)
	net.Start("MuR.Message2")
	net.WriteString(type)
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

function MuR:GiveCountdown(time, ply)
	net.Start("MuR.Countdown")
	net.WriteFloat(time)
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

hook.Add("PlayerInitialSpawn", "MuR.InitSpawn", function(ply)
	ply.SpawnDataSpeed = {100, 280, 190}
	ply:SetNW2Float("Guilt", 0)
	ply.SpectateMode = 6
	ply.SpectateIndex = 1
	ply:Spectate(ply.SpectateMode)
	ply.ViewOffsetZ = 64
end)

function GM:PlayerSpawn(ply)
	if not ply.ForceSpawn then
		if not MuR.GameStarted or !MuR.EnableDebug and MuR.GameStarted and MuR.TimeCount + 12 < CurTime() then
			ply:SetModel(table.Random(MuR.PlayerModels["Civilian_Male"]))
			ply:KillSilent()
			return
		end
		if MuR.EnableDebug then 
			ply:SetNW2String("Class", "Civilian") 
			timer.Simple(0.1, function()
				if !IsValid(ply) then return end
				ply:Freeze(false)
			end)
		end
	else
		ply.ForceSpawn = false
	end

	local vars = {
		IsSurrenderBefore = false,
		MindController = nil,
		CurrentEyeAngle = ply:EyeAngles(),
		DamageTargetGuilt = 0,
		VoiceDelay = 0,
		TakeDamageTime = 0,
		UnInnocentTime = 0,
		HungerDelay = CurTime() + 5,
		PitchVoice = math.Clamp(ply:GetInfoNum("blsd_character_pitch", 100), 86, 114),
		RandomPlayerSound = CurTime() + math.random(30, 180),
		BleedTime = 0,
		SpectateMode = 6,
		SpectateIndex = 1,
		LastBleedBone = "",
	}
	
	for k, v in pairs(vars) do ply[k] = v end

	player_manager.OnPlayerSpawn(ply, transiton)
	player_manager.RunClass(ply, "Spawn")

	ply:ConCommand("soundfade 0 0")
	ply:Freeze(false)
	ply:SetNoTarget(false)
	ply:SetNotSolid(false)
	ply:SetAvoidPlayers(true)
	ply:SetCustomCollisionCheck(true)
	ply:SetSVAnimation("")
	ply:StripWeapons()
	ply:StripAmmo()
	ply:SetSlowWalkSpeed(60)
	ply:SetWalkSpeed(100)
	ply:SetRunSpeed(280)
	ply:SetLadderClimbSpeed(60)
	ply:NewHull()
	ply:UnSpectate()
	
	timer.Simple(0.5, function()
		if IsValid(ply) then
			ply:UpdateBloodMovementSpeed()
		end
	end)
	
	local nwf = {
		Stability = 100,
		ArrestState = 0,
		Stamina = 100,
		BleedLevel = 0,
		Hunger = 90,
		DeathStatus = 0
	}
	
	for k, v in pairs(nwf) do ply:SetNW2Float(k, v) end
	
	local nwb = {
		LegBroken = false,
		HardBleed = false,
		GeroinUsed = false,
		Poison = false,
		Bredogen = false
	}
	
	for k, v in pairs(nwb) do ply:SetNW2Bool(k, v) end
	
	ply:SetNW2Entity("CurrentTarget", NULL)
	
	ply:SetBloodColor(BLOOD_COLOR_RED)
	ply:SetColor(Color(255,255,255))
	ply:SetMaterial("")
	ply:SetEyeAngles(Angle(ply:EyeAngles().x, ply:EyeAngles().y, 0))
	ply:SetPlayerColor(ColorRand():ToVector())
	ply:SetViewOffsetDucked(Vector(0, 0, 35))
	ply:SetJumpPower(190)

	local pos = MuR:GetRandomPos(false, nil, nil, nil, true)
	if not isvector(pos) then
		pos = MuR:GetRandomPos(true, nil, nil, nil, true)
	end
	if isvector(pos) then
		ply:SetPos(pos)
	else
		local currentPos = ply:GetPos()
		local offset = VectorRand() * 16
		offset.z = 0
		ply:SetPos(currentPos + offset)
		timer.Simple(0.1, function()
			if IsValid(ply) then
				ply:AllowFlashlight(true)
			end
		end)
	end
	
	local class = ply:GetNW2String("Class", "")
	if class == "" then
		ply:SetNW2String("Class", "Innocent")
		class = "Innocent"
	end
	
	ply.Male = not tobool(ply:GetInfoNum("blsd_character_female", 0))
	if ply.Male then 
		ply:SetModel(table.Random(MuR.PlayerModels["Civilian_Male"]))
	else
		ply:SetModel(table.Random(MuR.PlayerModels["Civilian_Female"]))
	end
	
	ply:AllowFlashlight(false)
	ply:GiveWeapon("mur_hands", true)
	ply:SetTeam(2)
	ply:SetHealth(100)
	ply:SetMaxHealth(100)
	
	if class == "Killer" then
		ply:GiveWeapon("tfa_bs_combk", true)
		ply:GiveWeapon("mur_poisoncanister", true)
		ply:GiveWeapon("mur_cyanide", true)
		ply:GiveWeapon("mur_disguise", true)
		ply:GiveWeapon("mur_scanner", true)
		ply:GiveWeapon("mur_break_tool", true)
		ply:GiveWeapon(math.random(1, 2) == 1 and "mur_loot_heroin" or "mur_loot_adrenaline")
		ply:AllowFlashlight(true)
		ply:SetTeam(1)
		ply:SetHealth(300)
		ply:SetMaxHealth(300)
	elseif class == "Attacker" then
		ply:SetModel(table.Random(MuR.PlayerModels["Anarchist"]))
		ply.Male = true
		ply:GiveWeapon(table.Random(MuR.WeaponsTable["Melee"]).class)
		ply:GiveWeapon("mur_loot_ducttape")
		ply:AllowFlashlight(true)
		ply:SetTeam(1)
		ply:SetNW2Float("ArrestState", 1)
	elseif class == "Traitor" then
		if MuR.Gamemode ~= 7 then
			ply:GiveWeapon("tfa_bs_glock_t")
			ply:GiveAmmo(34, "Pistol", true)
		else
			ply:GiveWeapon("tfa_bs_cobra")
			ply:GiveAmmo(18, "357", true)
		end
		
		ply:GiveWeapon(math.random(1, 2) == 1 and "mur_loot_heroin" or "mur_loot_adrenaline")
		ply:GiveWeapon(math.random(1, 2) == 1 and "mur_f1" or "mur_m67")
		
		local weapons = {"mur_poisoncanister", "mur_cyanide", "mur_disguise", "mur_scanner", 
						"mur_ied", "mur_break_tool", "tfa_bs_combk"}
		for _, wep in pairs(weapons) do ply:GiveWeapon(wep, true) end
		
		ply:AllowFlashlight(true)
		ply:SetTeam(1)
	elseif class == "FBI" then
		ply:GiveWeapon("tfa_bs_p320")
		ply:GiveWeapon("mur_radio")
		ply:GiveWeapon("mur_handcuffs", true)
		ply:GiveWeapon("mur_loot_bandage")
		ply:GiveWeapon("mur_disguise", true)
		ply:AllowFlashlight(true)
		ply:GiveAmmo(45, "Pistol", true)
		ply:SetArmor(10)
		ply:SetTeam(3)
		ply:SetModel(table.Random(MuR.PlayerModels["Civilian_Male"]))
		ply.Male = true
	elseif class == "Officer" then
		ply:GiveWeapon("tfa_bs_glock")
		ply:GiveWeapon("mur_radio")
		
		if math.random(1,10) == 1 then
			ply:GiveWeapon("tfa_bs_m590")
			ply:GiveAmmo(24, "Buckshot", true)
		elseif math.random(1,5) == 1 or MuR.Gamemode == 2 then
			ply:GiveWeapon("tfa_bs_badger")
			ply:GiveAmmo(75, "SMG1", true)
		end
		
		local weapons = {"mur_taser", "mur_pepperspray", "mur_handcuffs", "mur_baterringram", 
						"mur_doorlooker", "tfa_bs_baton", "mur_loot_bandage"}
		for _, wep in pairs(weapons) do ply:GiveWeapon(wep, _ == 3 or _ == 4) end
		
		ply:AllowFlashlight(true)
		ply:GiveAmmo(51, "Pistol", true)
		ply:GiveAmmo(3, "GaussEnergy", true)
		ply:SetArmor(20)
		ply:SetModel(table.Random(MuR.PlayerModels["Police"]))
		ply.Male = true
		ply:SetTeam(3)
	elseif class == "ArmoredOfficer" then
		if math.random(1,6) == 1 then
			ply:GiveWeapon("tfa_bs_m1014")
			ply:GiveAmmo(35, "Buckshot", true)
		elseif math.random(1,4) == 1 then
			ply:GiveWeapon("tfa_bs_acr")
			ply:GiveAmmo(120, "SMG1", true)
		else
			ply:GiveWeapon("tfa_bs_m4a1")
			ply:GiveAmmo(120, "SMG1", true)
		end
		
		ply:GiveWeapon("tfa_bs_glock")
		ply:GiveWeapon("mur_radio")
		
		local weapons = {"mur_taser", "mur_handcuffs", "mur_baterringram", "mur_doorlooker", 
						"tfa_bs_baton", "mur_loot_bandage", "mur_flashbang"}
		for _, wep in pairs(weapons) do ply:GiveWeapon(wep, _ == 2 or _ == 3) end
		
		ply:AllowFlashlight(true)
		ply:GiveAmmo(51, "Pistol", true)
		ply:GiveAmmo(2, "GaussEnergy", true)
		ply:SetArmor(50)
		ply:SetModel(table.Random(MuR.PlayerModels["SWAT"]))
		ply.Male = true
		ply:SetTeam(3)
		
		if MuR.Gamemode == 13 then
			ply:SetTeam(2)
			timer.Simple(0.01, function()
				if IsValid(ply) and MuR.PoliceState != 6 then ply:KillSilent() end
				ply.SpectateMode = 0
			end)
		elseif MuR.Gamemode == 14 then
			ply:SetTeam(2)
			ply:SetNoTarget(true)
			ply:GiveWeapon("mur_loot_medkit")
			ply:GiveWeapon("mur_loot_adrenaline")
			ply:SetWalkSpeed(65)
			ply:SetRunSpeed(130)
			timer.Simple(20, function()
				if !IsValid(ply) or !ply:Alive() then return end
				ply:SetNoTarget(false)
			end)
		end
	elseif class == "Riot" then
		local weapons = {"mur_taser", "mur_handcuffs", "mur_pepperspray", "mur_baterringram", "tfa_bs_baton", "mur_flashbang", "mur_radio"}
		for _, wep in pairs(weapons) do ply:GiveWeapon(wep, _ == 2 or _ == 4) end
		
		ply:AllowFlashlight(true)
		ply:SetModel(table.Random(MuR.PlayerModels["Riot"]))
		ply.Male = true
	elseif class == "Maniac" then
		ply:SetModel(table.Random(MuR.PlayerModels["Maniac"]))
		
		local weapons = {"tfa_bs_fireaxe_maniac", "tfa_bs_chainsaw", "mur_gasoline", 
						"mur_loot_ducttape", "mur_scanner", "mur_beartrap"}
		for _, wep in pairs(weapons) do ply:GiveWeapon(wep, true) end
		
		ply:AllowFlashlight(true)
		ply:SetTeam(1)
		ply:SetArmor(100)
		ply:SetWalkSpeed(180)
		ply:SetRunSpeed(300)
		ply:SetNW2Float("ArrestState", 1)
		ply.Male = true
	elseif class == "Shooter" then
		ply:SetArmor(100)
		ply:AllowFlashlight(true)
		ply:SetModel(table.Random(MuR.PlayerModels["Shooter"]))
		
		local pri, sec = table.Random(MuR.WeaponsTable["Primary"]), table.Random(MuR.WeaponsTable["Secondary"])
		ply:GiveWeapon(pri.class)
		ply:GiveAmmo(pri.count * 4, pri.ammo, true)
		ply:GiveWeapon(sec.class)
		ply:GiveAmmo(sec.count * 2, sec.ammo, true)
		ply:GiveWeapon("tfa_bs_combk")
		ply:GiveWeapon(math.random(0,1) == 1 and "mur_m67" or "mur_f1")
		ply:GiveWeapon("mur_scanner", true)
		
		ply:SetWalkSpeed(80)
		ply:SetRunSpeed(240)
		ply:SetTeam(1)
		ply:SetNW2Float("ArrestState", 1)
		ply.Male = true
		
		timer.Simple(2, function()
			if IsValid(ply) and ply:Alive() then ply:PlayVoiceLine("shooter_intro", true) end
		end)
	elseif class == "Terrorist" then
		ply:SetArmor(100)
		ply:AllowFlashlight(true)
		ply:SetModel(table.Random(MuR.PlayerModels["Terrorist"]))
		
		local sec, mel = table.Random(MuR.WeaponsTable["Primary"]), table.Random(MuR.WeaponsTable["Melee"])
		local weapons = {"tfa_bs_rpg7", "mur_ied", "mur_m67", "mur_f1"}
		for _, wep in pairs(weapons) do ply:GiveWeapon(wep, _ <= 3) end
		
		ply:GiveAmmo(4, "RPG_Round", true)
		ply:GiveWeapon(sec.class)
		ply:GiveAmmo(sec.count * 6, sec.ammo, true)
		ply:GiveWeapon(mel.class)
		ply:GiveWeapon("mur_scanner", true)

		ply:SetWalkSpeed(80)
		ply:SetRunSpeed(240)
		ply:SetTeam(1)
		ply:SetNW2Float("ArrestState", 2)
		ply.Male = true
	elseif class == "Hunter" then
		local pri = table.Random(MuR.WeaponData["DefenderWeapons"])
		ply:GiveWeapon(pri.class)
		ply:GiveAmmo(pri.count * 2, pri.ammo, true)
	elseif class == "Defender" then
		ply:GiveWeapon(MuR.Gamemode ~= 7 and "tfa_bs_walther" or "tfa_bs_cobra")
	elseif class == "Zombie" then
		timer.Simple(0.01, function()
			if IsValid(ply) then ply:StripWeapon("mur_hands") end
		end)

		ply:SetModel(table.Random(MuR.PlayerModels["Zombie"]))
		ply:GiveWeapon("mur_zombie", true)
		ply:SetTeam(1)
		ply:SetRunSpeed(260)
		ply:SetWalkSpeed(160)
		ply:SetJumpPower(320)
	elseif class == "Medic" then
		local weapons = {"mur_loot_medkit", "mur_loot_adrenaline", "mur_loot_bandage", "tfa_bs_compactk"}
		for _, wep in pairs(weapons) do ply:GiveWeapon(wep) end
		
		ply:SetModel(table.Random(MuR.PlayerModels[ply.Male and "Medic_Male" or "Medic_Female"]))
	elseif class == "Builder" then
		local weapons = {"mur_loot_hammer", "mur_loot_ducttape", "tfa_bs_crowbar"}
		for _, wep in pairs(weapons) do ply:GiveWeapon(wep) end
		
		ply:SetModel(table.Random(MuR.PlayerModels["Builder"]))
		ply.Male = true
	elseif class == "Criminal" then
		ply:SetNW2Float("ArrestState", 1)
		ply:GiveWeapon("tfa_bs_knife")
		
		if MuR.Gamemode == 13 then
			ply:SetNW2Float("ArrestState", 2)
			ply:SetTeam(1)
			local pri = table.Random(MuR.WeaponsTable["Secondary"])
			ply:GiveWeapon(pri.class)
			ply:GiveAmmo(pri.count * 6, pri.ammo, true)
		else
			ply:GiveWeapon("tfa_bs_izh43sw")
		end
	elseif class == "HeadHunter" then
		ply:GiveWeapon("tfa_bs_cleaver")
		
		timer.Simple(2, function() 
			if IsValid(ply) and ply:Alive() then
				local rnd = GetRandomPlayer(ply)
				if IsValid(rnd) then ply:SetNW2Entity("CurrentTarget", rnd) end
			end
		end)
	elseif class == "Witness" then
		ply:GiveWeapon("mur_roledetector")
	elseif class == "Security" then
		ply:GiveWeapon("mur_taser")
		ply:GiveWeapon("tfa_bs_baton")
		ply:GiveWeapon("mur_radio")
		ply:GiveAmmo(3, "GaussEnergy", true)
		ply:SetModel(table.Random(MuR.PlayerModels["Security"]))
		ply.Male = true
	elseif class == "SecurityForces" then
		ply:GiveWeapon("mur_taser")
		ply:GiveWeapon("tfa_bs_baton")
		ply:GiveWeapon("mur_radio")
		ply:GiveWeapon("mur_pepperspray")
		ply:GiveWeapon("tfa_bs_m9")
		ply:GiveAmmo(4, "GaussEnergy", true)
		ply:GiveAmmo(30, "Pistol", true)
		ply:SetModel(table.Random(MuR.PlayerModels["SecurityForces"]))
		ply.Male = true
	elseif class == "Soldier" then
		if MuR.Gamemode == 15 and MuR.ExperimentWeapon then
			ply:GiveWeapon(MuR.ExperimentWeapon.class)
			ply:GiveAmmo(MuR.ExperimentWeapon.count * 3, MuR.ExperimentWeapon.ammo, true)
			ply:SetWalkSpeed(240)
			ply:SetRunSpeed(400)
			ply:SetJumpPower(360)
			ply:GiveWeapon("mur_loot_adrenaline")
		else
			local pri, sec = table.Random(MuR.WeaponsTable["Primary"]), table.Random(MuR.WeaponsTable["Secondary"])
			ply:GiveWeapon(pri.class)
			ply:GiveAmmo(pri.count * 6, pri.ammo, true)
			ply:GiveWeapon(sec.class)
			ply:GiveAmmo(sec.count * 4, sec.ammo, true)
			ply:GiveWeapon(math.random(1, 2) == 1 and "mur_f1" or "mur_m67")
			ply:GiveWeapon("mur_loot_medkit")
		end
		ply:GiveWeapon("tfa_bs_combk")
		ply:AllowFlashlight(true)
		ply:SetModel(table.Random(MuR.PlayerModels["Terrorist"]))
		ply:GiveWeapon("mur_loot_bandage")
		ply:GiveWeapon("mur_radio")
	elseif class == "SWAT" then
		local pri, sec = table.Random(MuR.WeaponsTable["Primary"]), table.Random(MuR.WeaponsTable["Secondary"])
		ply:SetModel(table.Random(MuR.PlayerModels["Police_TDM"]))
		ply:GiveWeapon(pri.class)
		ply:GiveAmmo(pri.count * 6, pri.ammo, true)
		ply:GiveWeapon(sec.class)
		ply:GiveAmmo(sec.count * 4, sec.ammo, true)
		ply:GiveWeapon("tfa_bs_combk")
		ply:AllowFlashlight(true)
		ply:GiveWeapon(math.random(1, 2) == 1 and "mur_f1" or "mur_m67")
		ply:GiveWeapon("mur_loot_bandage")
		ply:SetTeam(2)
		ply.Male = true
		ply:GiveWeapon("mur_radio")
	elseif class == "Terrorist2" then
		local pri, sec, mel = table.Random(MuR.WeaponsTable["Primary"]), table.Random(MuR.WeaponsTable["Secondary"]), table.Random(MuR.WeaponsTable["Melee"])
		ply:SetModel(table.Random(MuR.PlayerModels["Terrorist_TDM"]))
		ply:GiveWeapon(pri.class)
		ply:GiveAmmo(pri.count * 6, pri.ammo, true)
		ply:GiveWeapon(sec.class)
		ply:GiveAmmo(sec.count * 4, sec.ammo, true)
		ply:GiveWeapon(mel.class)
		ply:AllowFlashlight(true)
		ply:GiveWeapon(math.random(1, 2) == 1 and "mur_f1" or "mur_m67")
		ply:GiveWeapon("mur_loot_bandage")
		ply:SetTeam(1)
		ply.Male = true
		ply:GiveWeapon("mur_radio")
	elseif class == "GangGreen" then
		ply:SetModel(table.Random(MuR.PlayerModels["GangGreen"]))
		ply.Male = true
		local sec = table.Random(MuR.WeaponsTable["Secondary"])
		ply:GiveWeapon(sec.class)
		ply:GiveAmmo(sec.count * 5, sec.ammo, true)
		ply:GiveWeapon(table.Random(MuR.WeaponsTable["Melee"]).class)
		ply:AllowFlashlight(true)
		ply:SetTeam(2)
		ply:SetNW2Float("ArrestState", 1)
	elseif class == "GangRed" then
		ply:SetModel(table.Random(MuR.PlayerModels["GangRed"]))
		ply.Male = true
		local sec = table.Random(MuR.WeaponsTable["Secondary"])
		ply:GiveWeapon(sec.class)
		ply:GiveAmmo(sec.count * 5, sec.ammo, true)
		ply:GiveWeapon(table.Random(MuR.WeaponsTable["Melee"]).class)
		ply:AllowFlashlight(true)
		ply:SetTeam(1)
		ply:SetNW2Float("ArrestState", 1)
	end
	
	if MuR.EnableDebug then
		ply:GiveWeapon("weapon_physgun")
		ply:GiveWeapon("gmod_tool")
	end

	ply.SpawnDataSpeed = {ply:GetWalkSpeed(), ply:GetRunSpeed(), ply:GetJumpPower()}
	ply:SetNewName()
	ply:SetupHands()
	ply:RandomSkin()
end

function GM:PlayerDeathSound(ply)
	return true
end

hook.Add("OnNPCKilled", "MuR.NPCLogic", function(ent, att)
	local allow = MuR.PoliceState > 0 and ent.IsPolice
	if ent.IsPolice then
		MuR.VoteLogDeadPolice = MuR.VoteLogDeadPolice + 1
	end
	if allow then
		timer.Simple(0.01, MuR.CheckPoliceReinforcment)
	end
end)

function GM:PlayerDeath(ply, inf, att)
	if IsValid(att.MindController) then
		att = att.MindController
	end

	ply:ConCommand("soundfade 100 5")
	ply:ScreenFade(SCREENFADE.OUT, color_black, 0.1, 4.9)
	ply:Freeze(true)
	ply:SetNW2Bool("Poison", false)
	ply:SetNW2Bool("Bredogen", false)
	timer.Simple(0.1, function()
		if !IsValid(ply) then return end
		if isstring(ply.LastVoiceLine) then
			ply:StopSound(ply.LastVoiceLine)
		end
	end)

	if att.IsPolice or (att:GetNW2String("Class") == "Officer" or att:GetNW2String("Class") == "ArmoredOfficer" or att:GetNW2String("Class") == "Riot") then
		ply:SetNW2Float("DeathStatus", 2)
	else
		ply:SetNW2Float("DeathStatus", 1)
	end

	MuR:CheckPoliceReinforcment()

	timer.Simple(0.01, function()
		if !IsValid(ply) then return end
		local att2 = ply.LastAttacker
		if IsValid(att2) and att2:IsPlayer() then
			if att2:GetNW2String("Class") == "HeadHunter" and IsValid(att2:GetNW2Entity("CurrentTarget")) and att2:GetNW2Entity("CurrentTarget") == ply then
				MuR:GiveAnnounce("headhunter_kill", att2)
				MuR:GiveAnnounce("headhunter_killed", ply)
				att2:AddMoney(500)
			elseif att2:GetNW2String("Class") != "Soldier" and ply:Team() == 2 and att2:Team() == 2 and MuR.Gamemode ~= 11 and MuR.Gamemode ~= 12 and ply ~= att2 then
				if ply.UnInnocentTime < CurTime() then
					att2:ChangeGuilt(4)
					MuR:GiveAnnounce("innocent_kill", att2)
				else
					MuR:GiveAnnounce("innocent_att_kill", att2)
				end
			end
			if att2:IsKiller() and not ply:IsKiller() then
				att2:SetNW2Float("Stability", math.Clamp(att2:GetNW2Float("Stability")+75, 0, 100)) 
			end
			ply.LastAttacker = nil
		end
	end)

	if att:IsPlayer() and ply:IsKiller() and not att:IsKiller() then
		att:AddMoney(50)
	end

	if att:IsPlayer() and ply:GetNW2Float("ArrestState") ~= 2 and att:IsRolePolice() and ply ~= att and !ply:IsKiller() then
		if ply:GetNW2Float("ArrestState") == 1 then
			att:ChangeGuilt(1)
		else
			att:ChangeGuilt(2)
		end
		MuR:GiveAnnounce("officer_killer", att)
	end

	if MuR.Gamemode == 6 and ply:GetNW2String("Class") ~= "Zombie" then
		MuR:GiveAnnounce("you_zombie", ply)
		ply:SetNW2String("Class", "Zombie")
	end

	if att:IsPlayer() and MuR.Gamemode == 5 then
		att:AddMoney(50)
	end

	timer.Simple(5, function()
		if not IsValid(ply) then return end
		ply:SetNW2Entity("RD_EntCam", ply)
		ply:Freeze(false)

		if MuR.EnableDebug or ply:GetNW2String("Class") == "Zombie" then
			ply:ScreenFade(SCREENFADE.IN, color_black, 1, 0)
			ply.ForceSpawn = true
			ply:Spawn()
		end
	end)
end

function GM:PlayerDeathThink(ply)
	if ply.SpectateMode then
		ply:Spectate(ply.SpectateMode)
		local ent = MuR:GetAlivePlayers()[ply.SpectateIndex]

		if IsValid(ent) and ent:Health() > 0 and (ply:GetObserverMode() == 5 or ply:GetObserverMode() == 4) then
			ply:SpectateEntity(ent)
		else
			ply:SpectateEntity(NULL)
		end
	end

	if ply:EyeAngles().z != 0 then
		local ang = ply:EyeAngles()
		ang.z = 0
		ply:SetEyeAngles(ang)
	end

	if ply:GetNW2String("Class") == "Zombie" or MuR.EnableDebug then return true end
	if MuR.GameStarted then return false end
end

function GM:PlayerSay(ply, text, team)
	if MuR.GameStarted and MuR.TimeCount + 12 < CurTime() and ply:Alive() then
		for k, ply2 in pairs(player.GetAll()) do
			local can = hook.Call("PlayerCanSeePlayersChat", GAMEMODE, text, team, ply2, ply)

			if ply:GetNW2Bool("IsUnconscious", false) then
				return false
			end

			if can then
				net.Start("MuR.ChatAdd")
				net.WriteEntity(ply)
				net.WriteString(text)
				net.Send(ply2)
			end
		end

		return false
	end

	return true
end

function meta:NextSpectateEntity()
	self.SpectateIndex = self.SpectateIndex + 1

	if not IsValid(MuR:GetAlivePlayers()[self.SpectateIndex]) then
		self.SpectateIndex = 1
	end
end

net.Receive("MuR.BodySearch", function(len, ply)
	local ent = net.ReadEntity()
	local cl = net.ReadString()
	local prop = ent:GetClass() != "prop_ragdoll"
	if !ply:Alive() or ply:GetPos():DistToSqr(ent:GetPos()) > 25000 or !istable(ent.Inventory) or ply:HasWeapon(cl) then return end

	local wep = nil
	for k, wp in pairs(ent.Inventory) do
		if IsValid(wp) and wp:GetClass() == cl or isstring(wp) and wp == cl then
			wep = wp
			break
		end
	end
	if !IsValid(wep) and !isstring(wep) or isstring(wep) and not prop then return end
	if isstring(wep) then
		wep = ents.Create(wep)
		wep:Spawn()
	end
	wep:SetNoDraw(false)
	wep:SetNotSolid(false)
	wep:SetPos(ent:GetPos()+Vector(0,0,24))
	local phys = wep:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(true)
		phys:SetVelocity(-phys:GetVelocity() + VectorRand(-50, 50))
	end
	if wep:IsWeapon() then
		ply:PickupWeapon(wep)
	else
		timer.Simple(0.1, function()
			if !IsValid(ply) then return end
			wep:Use(ply)
		end)
	end
	ply:SelectWeapon(cl)
	if prop then
		table.RemoveByValue(ent.Inventory, cl)
	else
		table.RemoveByValue(ent.Inventory, wep)
	end
end)

hook.Add("PlayerButtonDown", "MuR_SButtons", function(ply, but)
	if ply:GetObserverMode() > 0 then
		if (ply:GetObserverMode() == 5 or ply:GetObserverMode() == 4) and but == KEY_SPACE then
			ply:UnSpectate()
			ply.SpectateMode = 6
		elseif ply:GetObserverMode() == 6 and but == KEY_SPACE then
			ply.SpectateMode = 5
		end

		if but == MOUSE_LEFT then
			ply:NextSpectateEntity(true)
		elseif but == MOUSE_RIGHT then
			if ply:GetObserverMode() == 5 then
				ply.SpectateMode = 4
			elseif ply:GetObserverMode() == 4 then
				ply.SpectateMode = 5
			end
		end
	end

	if ply:Alive() and but == KEY_E and (not ply:GetNoDraw() or IsValid(ply:GetRD())) then
		local tr = ply:GetEyeTrace().Entity

		if IsValid(ply:GetRD()) and tr == ply:GetRD() then return end
		if IsValid(tr) and tr:GetClass() == "prop_ragdoll" and tr.isRDRag and tr:GetPos():DistToSqr(ply:GetPos()) < 10000 then
			if IsValid(tr.Owner) then
				MuR:GiveMessage("corpse_alive", ply)
			else
				if IsValid(tr.OwnerDead) and ply:Team() == 2 then
					tr.OwnerDead:SetNW2Float("DeathStatus", 2)
				end

				MuR:GiveMessage("corpse_dead", ply)

				if istable(tr.Inventory) then
					if IsValid(tr.Weapon) then
						tr.Weapon:Remove()
					end

					local tab = {}
					for _, wep in pairs(tr.Inventory) do
						if IsValid(wep) then
							table.insert(tab, wep:GetClass())
						end
					end

					net.Start("MuR.BodySearch")
					net.WriteTable(tab)
					net.WriteEntity(tr)
					net.Send(ply)
				end
			end
		elseif IsValid(tr) and table.HasValue(MuR.LootableProps, tr:GetModel()) and istable(tr.Inventory) and tr:GetPos():DistToSqr(ply:GetPos()) < 10000 then
			net.Start("MuR.BodySearch")
			net.WriteTable(tr.Inventory)
			net.WriteEntity(tr)
			net.Send(ply)
		end
	end

	if ply:Alive() and but == KEY_SPACE and not ply:GetNoDraw() and ply:OnGround() then
		local stam = ply:GetNW2Float("Stamina")
		ply:SetNW2Float("Stamina", math.Clamp(stam - 5, 0, 100))
	end
end)

hook.Add("PlayerCanHearPlayersVoice", "MuR.Voice", function(listener, talker)
	if MuR.GameStarted and MuR.TimeCount + 12 > CurTime() or MuR.Ending then return true end
	
	if MuR.PoliceState == 5 then
		local listenerIsPolice = (listener:GetNW2String("Class") == "Officer" or listener:GetNW2String("Class") == "ArmoredOfficer" or listener:GetNW2String("Class") == "SWAT")
		local talkerIsPolice = (talker:GetNW2String("Class") == "Officer" or talker:GetNW2String("Class") == "ArmoredOfficer" or talker:GetNW2String("Class") == "SWAT")
		local talkerIsCriminal = (talker:GetNW2String("Class") == "Criminal")
		
		if listenerIsPolice and talkerIsCriminal then
			return false
		end
	end
	
	if listener:GetPos():DistToSqr(talker:GetPos()) > 250000 and talker:Alive() or not listener:IsLineOfSightClear(talker) and talker:Alive() or not talker:Alive() and listener:Alive() then return false end
	if !talker:Alive() and !listener:Alive() then return true end
	return true, true
end)

hook.Add("PlayerCanSeePlayersChat", "MuR.Voice", function(text, team, listener, talker)
	if MuR.GameStarted and MuR.TimeCount + 12 > CurTime() or MuR.Ending then return true end
	
	if MuR.PoliceState == 5 then
		local listenerIsPolice = (listener:GetNW2String("Class") == "Officer" or listener:GetNW2String("Class") == "ArmoredOfficer" or listener:GetNW2String("Class") == "SWAT")
		local talkerIsPolice = (talker:GetNW2String("Class") == "Officer" or talker:GetNW2String("Class") == "ArmoredOfficer" or talker:GetNW2String("Class") == "SWAT")
		local talkerIsCriminal = (talker:GetNW2String("Class") == "Criminal")
		
		if listenerIsPolice and talkerIsCriminal then
			return false
		end
	end
	
	if listener:GetPos():DistToSqr(talker:GetPos()) > 250000 and talker:Alive() or not listener:IsLineOfSightClear(talker) and talker:Alive() or not talker:Alive() and listener:Alive() then return false end
end)

hook.Add("OnEntityCreated", "MuR_Remover", function(ent)
	if (MuR.Gamemode == 2 or MuR.Gamemode == 3) and (ent.Melee or ent.IsTFAWeapon) and not ent.CantDrop then end
end)

hook.Add("Think", "MuR_LogicPlayer", function()
	local tab = player.GetAll()

	for i = 1, #tab do
		local ent = tab[i]
		if not ent:Alive() then continue end
		


		if ent:HaveStability() and not ent:GetNW2Bool("GeroinUsed", false) then
			ent:SetNW2Float("Stability", math.Clamp(ent:GetNW2Float("Stability")-FrameTime()/5, 0, 100)) 
			if ent:GetNW2Float("Stability") <= 0 then
				ent:ConCommand("kill")
				if math.random(1,5) == 1 then
					ent:TakeDamage(1)
				end
			end
		end

		if ent:Alive() and ent:GetSVAnim() == "" and !IsValid(ent:GetRD()) then
			local num = 64
			local eyes = ent:LookupAttachment("eyes")
			if eyes > 0 then
				local att = ent:GetAttachment(eyes)
				local dif = math.sqrt(att.Pos:DistToSqr(ent:GetPos()))
				num = math.Clamp(dif, 8, 96)
			end
			ent:SetViewOffset(Vector(0, 0, ent.ViewOffsetZ))
			ent:SetViewOffsetDucked(Vector(0, 0, 36))
			ent.ViewOffsetZ = Lerp(FrameTime()/0.1, ent.ViewOffsetZ, num)
		else
			ent:SetViewOffset(Vector(0, 0, 64))
			ent:SetViewOffsetDucked(Vector(0, 0, 36))
			ent.ViewOffsetZ = 64
			if string.find(ent:GetSVAnim(), "sequence_ron_comply_start_0") then
				ent:SetActiveWeapon(nil)
			end
		end

		local tr = ent:GetEyeTrace().Entity
		local wep = ent:GetActiveWeapon()

		if IsValid(wep) and wep:GetMaxClip1() > 0 and ent:GetNW2Float("Guilt") >= 70 and MuR.Gamemode ~= 5 then
			ent:DropWeapon(wep)
		end

		if ent:GetNW2Float("ArrestState") > 0 and ent:IsRolePolice() then
			ent:SetNW2Float("ArrestState", 0)
		end

		if ent:GetNW2Float("ArrestState") > 0 then
			ent.VJ_NPC_Class = {"CLASS_BLOODSHED_WANTED"}
		else
			ent.VJ_NPC_Class = {"CLASS_BLOODSHED_CIVILIAN"}
		end

		if ent:GetNW2String("Class") == "Zombie" then
			ent:SelectWeapon("mur_zombie")
			ent.VJ_NPC_Class = {"CLASS_BLOODSHED_ZOMBIE"}
		end

		local lvl = ent:GetNW2Float("BleedLevel")
		local hbl = ent:GetNW2Bool("HardBleed")
		local moving = ent:GetVelocity():Length() > 50
		local running = ent:GetVelocity():Length() > 150
		
		if hbl and ent.BleedTime < CurTime() then
			local bleedDelay = moving and math.Rand(0.2, 0.4) or math.Rand(0.3, 0.6)
			if running then bleedDelay = bleedDelay * 0.8 end
			ent.BleedTime = CurTime() + bleedDelay
			MuR:CreateBloodPool(ent, 0, 1)
			local damage = running and 2.5 or moving and 2 or 1.5
			ent:TakeDamage(damage)
			ent:EmitSound("murdered/player/drip_" .. math.random(1, 5) .. ".wav", 50, math.random(70, 110))
			
			if math.random(1, 12) == 1 then
				ent:ViewPunch(Angle(math.random(-1, 1), math.random(-1, 1), 0))
			end
			
			if math.random(1, 10) == 1 then
				net.Start("MuR.BloodDamageSound")
				net.WriteString("heartbeat_spike")
				net.Send(ent)
			end
		end

		if lvl == 1 and ent.BleedTime < CurTime() then
			local bleedDelay = moving and math.Rand(1.2, 2) or math.Rand(2, 3)
			ent.BleedTime = CurTime() + bleedDelay
			MuR:CreateBloodPool(ent, 0, 1)
			ent:TakeDamage(moving and 0.8 or 0.5)
			ent:EmitSound("murdered/player/drip_" .. math.random(1, 5) .. ".wav", 40, math.random(80, 120))
		elseif lvl == 2 and ent.BleedTime < CurTime() then
			local bleedDelay = moving and math.Rand(0.6, 1) or math.Rand(1, 1.5)
			if running then bleedDelay = bleedDelay * 0.9 end
			ent.BleedTime = CurTime() + bleedDelay
			MuR:CreateBloodPool(ent, 0, 1)
			local damage = running and 1.5 or moving and 1 or 0.8
			ent:TakeDamage(damage)
			ent:EmitSound("murdered/player/drip_" .. math.random(1, 5) .. ".wav", 45, math.random(75, 115))
		elseif lvl >= 3 and ent.BleedTime < CurTime() then
			local bleedDelay = moving and math.Rand(0.3, 0.6) or math.Rand(0.5, 1)
			if running then bleedDelay = bleedDelay * 0.7 end
			ent.BleedTime = CurTime() + bleedDelay
			MuR:CreateBloodPool(ent, 0, math.random(1, 2))
			local damage = running and 2 or moving and 1.5 or 1.2
			ent:TakeDamage(damage)
			ent:EmitSound("murdered/player/drip_" .. math.random(1, 5) .. ".wav", 50, math.random(70, 110))
			
			if math.random(1, 18) == 1 then
				ent:ViewPunch(Angle(math.random(-1, 1), math.random(-1, 1), 0))
			end
			
			if math.random(1, 15) == 1 then
				net.Start("MuR.BloodDamageSound")
				net.WriteString("blood_loss")
				net.Send(ent)
			end
		end
		
		if not ent.BloodRegenTime then ent.BloodRegenTime = CurTime() + 30 end

		ent:SetNW2Bool("Surrender", ent:GetNW2Float("ArrestState") == 1 and (MuR:VisibleByNPCs(ent:WorldSpaceCenter()) or MuR.PoliceState == 2 or MuR.PoliceState == 4 or MuR.Gamemode == 11) and ent:Alive() and ent:GetSVAnimation() == "")
		ent:MakeRandomSound()

		if ent:GetNW2Float("peppereffect") > CurTime() and ent.peppertimevoice < CurTime() then
			ent.peppertimevoice = CurTime() + 2
			ent:ViewPunch(AngleRand(-10, 10))

			if ent.Male then
				ent:EmitSound("murdered/player/cough_m.wav", 60, math.random(80, 110))
			else
				ent:EmitSound("murdered/player/cough_f.wav", 60, math.random(80, 110))
			end
		end

		if ent:GetNW2Bool("Poison") and (not ent.PoisonVoiceTime or ent.PoisonVoiceTime < CurTime()) then
			ent.PoisonVoiceTime = CurTime() + 3
			local dm = DamageInfo()
			dm:SetDamage(10)
			dm:SetDamageType(DMG_NERVEGAS)
			dm:SetAttacker(ent)
			ent:TakeDamageInfo(dm)
			ent:EmitSound("ambient/voices/citizen_beaten" .. math.random(3, 4) .. ".wav", 60, math.random(90, 110))
			ent:ViewPunch(AngleRand(-5, 5))
		end

		if ent.HungerDelay < CurTime() and not MuR:DisablesGamemode() then
			ent.HungerDelay = CurTime() + 5
			ent:SetNW2Float("Hunger", math.Clamp(ent:GetNW2Float("Hunger") - 1, 0, 100))
		end

		local rag = ent:GetRD()
		if !IsValid(rag) then
			rag = ent
		end
		if IsValid(rag) then
			local vel = rag:GetVelocity():Length()
			local height = MuR:CheckHeight(rag, rag:WorldSpaceCenter())
			if not rag:OnGround() and (vel > 1000 or height > 300 and vel > 300) and ent:GetMoveType() ~= MOVETYPE_NOCLIP then
				ent:PlayVoiceLine("death_fly")
				if rag:IsPlayer() then
					rag:StartRagdolling()
					rag:TimeGetUpChange(10, true)
				end
			end
		end
	end
end)

local fallspd = 500
hook.Add("OnPlayerHitGround", "MuR_DamageNPCThink", function(ply, onwater, onfloater, speed)
	if speed >= fallspd then
		local fatal = 1000
		local isfatal = fatal > 0 and speed >= fatal
		local dmg = DamageInfo()
		dmg:SetAttacker(game.GetWorld())
		dmg:SetInflictor(game.GetWorld())
		dmg:SetDamage(isfatal and ply:Health() + ply:Armor() or speed / 25)
		dmg:SetDamageType(DMG_FALL)
		ply:TakeDamageInfo(dmg)
		ply:EmitSound("Player.FallDamage", 75, math.random(90, 110), 0.5)
	end
end)

hook.Add("EntityTakeDamage", "MuR_DamageNPCThink", function(ent, dmg)
	local att = dmg:GetAttacker()
	local inf = dmg:GetInflictor()
	if IsValid(att.MindController) then
		att = att.MindController
	end

	if dmg:IsExplosionDamage() and dmg:GetDamage() > 10 and (ent:GetClass() == "prop_door_rotating" or ent:GetClass() == "func_door_rotating") then
		ent:SetHealth(1)
	end

	if att.isRDRag and IsValid(att.Owner) then
		dmg:SetAttacker(att.Owner)
		att = dmg:GetAttacker()
	end

	if dmg:GetDamageType() == DMG_BURN then
		dmg:SetDamage(dmg:GetDamage()*5)
	end

	if att:IsPlayer() then
		local wep = dmg:GetInflictor()
		local df = dmg:GetDamageForce()
		if dmg:IsBulletDamage() then
			dmg:SetDamageForce(df/20)
		end
	end
	
	if ent:IsPlayer() then
		local force = dmg:GetDamageForce()
		if force:IsZero() and (att:IsPlayer() or att:IsNPC()) then
			force = att:GetAimVector()*100
		end
		local bone1 = ent:GetNearestBoneFromPos(dmg:GetDamagePosition(), force)
		if IsValid(ent:GetRD()) then
			bone1 = ent:GetRD():GetNearestBoneFromPos(dmg:GetDamagePosition(), force)
		end

		if att:IsNPC() and dmg:GetDamageType() == 1 then
			dmg:SetDamage(0)
		end

		if !IsValid(ent:GetRD()) then
			if (bone1 == "ValveBiped.Bip01_Head1" or bone1 == "ValveBiped.Bip01_Neck1") and dmg:IsBulletDamage() then
				dmg:SetDamage(dmg:GetDamage()*4)
			elseif dmg:IsExplosionDamage() then
				dmg:SetDamage(dmg:GetDamage()*0.1)
			elseif dmg:IsFallDamage() then
				dmg:SetDamage(dmg:GetDamage()*1)
			end
		end

		if att:IsPlayer() and MuR.Gamemode == 6 and att:Team() == ent:Team() then
			dmg:SetDamage(0)
			return true
		end
	end

	if ent:IsPlayer() and ent:Alive() then
		if !att:IsWorld() or att:IsWorld() and dmg:GetDamage() > 1 then
			ent.LastAttacker = att
		end

		local wep = ent:GetActiveWeapon()

		if IsValid(wep) and wep.GetBlocking and wep:GetBlocking() then
			dmg:ScaleDamage(0.5)
		end

		if dmg:IsFallDamage() and !ent:IsRoleWithoutOrgans() then
			ent:DamagePlayerSystem("bone")
		elseif dmg:IsBulletDamage() and dmg:GetDamage() > 1 and math.random(1, 100) <= 50 or dmg:IsExplosionDamage() and !ent:IsRoleWithoutOrgans() then
			ent:DamagePlayerSystem("blood")
			ent:StartRagdolling(dmg:GetDamage() / 25, dmg:GetDamage() / 5, dmg)
		end

		if att:IsPlayer() then
			local wep2 = att:GetActiveWeapon()

			if att:IsAtBack(ent) and IsValid(wep2) and wep2.Melee then
				ent:StartRagdolling(math.Round(dmg:GetDamage() / 50), math.Round(dmg:GetDamage() / 2), dmginfo)
			end

			att.DamageTargetGuilt = att.DamageTargetGuilt - 1
			att.UnInnocentTime = CurTime() + 15

			if att.DamageTargetGuilt <= 0 and MuR.Gamemode ~= 5 and MuR.Gamemode ~= 6 and att:Team() == 2 then
				att.DamageTargetGuilt = 3
				att:ChangeGuilt(0.1)
			end

			if IsValid(wep2) and wep2.Melee and wep2.BladeWeapon and math.random(1, 2) == 1 then
				ent:DamagePlayerSystem("blood")
			end
		end
	
		net.Start("MuR.PainImpulse")
		net.WriteFloat(dmg:GetDamage())
		net.Send(ent)

		if ent:GetNW2Float("Guilt") >= 90 then
			dmg:ScaleDamage(100)
		end
	end

	if (ent.IsPolice or ent:IsRolePolice()) and att:IsPlayer() then
		if dmg:GetDamage() >= 10 then
			att:SetNW2Float("ArrestState", 2)
		elseif att:GetNW2Float("ArrestState") < 1 then
			att:SetNW2Float("ArrestState", 1)
		end
	end

	if ent:IsPlayer() and att:IsPlayer() and MuR:VisibleByNPCs(att:WorldSpaceCenter()) then
		if att:GetNW2Float("ArrestState") == 0 then
			att:SetNW2Float("ArrestState", 1)
		end

		att:SetNW2Float("ArrestState", 2)
	end

	if ent:IsPlayer() and att:IsPlayer() and att:Team() == 1 and dmg:GetDamage() >= ent:Health() and att:GetNW2Float("ArrestState") == 0 then
		att:SetNW2Float("ArrestState", 1)
	end

	if ent:GetNW2Bool("BreakableThing") and not dmg:IsBulletDamage() then
		local frs = dmg:GetDamageForce()/4
		if dmg:IsExplosionDamage() then
			frs = frs * 20
		end
		local dmg = dmg:GetDamage()
		ent:SetHealth(ent:Health() - dmg)

		if ent:Health() <= 0 and not ent.SpawnedBreaked then
			ent.SpawnedBreaked = true

			if string.match(ent:GetClass(), "prop_door_rotating") then
				local fallingDoor = ents.Create("prop_physics")
				fallingDoor:SetPos(ent:GetPos() + Vector(0, 0, 2))
				fallingDoor:SetAngles(ent:GetAngles())
				fallingDoor:TransferModelData(ent)
				fallingDoor:Spawn()
				fallingDoor:EmitSound(")ambient/materials/door_hit1.wav", 70, math.random(90,110))
				local ef = EffectData()
				ef:SetOrigin(ent:GetPos()+Vector(0,0,16))
				ef:SetNormal(frs:GetNormalized())
				util.Effect("MetalSpark", ef)
				ef:SetOrigin(ent:GetPos()+Vector(0,0,56))
				util.Effect("MetalSpark", ef)
				timer.Simple(0.001, function()
					if !IsValid(fallingDoor) then return end
					fallingDoor:SetNW2Bool("BreakableThing", true)
					fallingDoor:SetMaxHealth(250)
					fallingDoor:SetHealth(250)
					local phys = fallingDoor:GetPhysicsObject()
					if IsValid(phys) then
						phys:SetMass(100)
						phys:ApplyForceCenter(frs)
					end
				end)
			elseif not string.match(ent:GetClass(), "ragdoll") then
				local eff = ents.Create("prop_physics")
				eff:SetModel("models/props_interiors/Furniture_shelf01a.mdl")
				eff:SetPos(ent:WorldSpaceCenter())
				eff:SetAngles(ent:GetAngles())
				eff:Spawn()
				eff:Fire("Break")
			end

			ent:Remove()
		else
			if dmg >= 5 then
				ent:EmitSound("physics/wood/wood_box_impact_hard" .. math.random(1, 6) .. ".wav")
			end
		end
	end

	if dmg:GetDamage() > 1 then
		ent.LastDamageInfo = {dmg:GetDamageType(), dmg:GetDamagePosition(), dmg:IsExplosionDamage(), dmg:GetDamageForce(), dmg:IsBulletDamage(), dmg:IsFallDamage()}
	end

end)

hook.Add("EntityRemoved", "MuR.FixDoors", function(ent)
	if string.match(ent:GetClass(), "_door_") then
		for _, ap in ipairs(ents.FindByClass("func_areaportal")) do
			if ap:GetInternalVariable("target") == ent:GetName() then
				ap:Fire("Open")
				ap:SetSaveValue("target", "")
				break
			end
		end
	end
end)

hook.Add("AllowPlayerPickup", "MuR_WeaponsFuck", function(ply, ent)
	if ent:IsWeapon() then
		ply:PickupWeapon(ent)

		if ent:GetMaxClip1() > 0 then
			ply:EmitSound("items/ammocrate_open.wav", 60)
		else
			ply:EmitSound("Flesh.ImpactSoft", 55)
		end

		ply:SelectWeapon(ent:GetClass())
	end
end)

hook.Add("PlayerCanPickupWeapon", "MuR_WeaponsFuck", function(ply, weapon)
	local ent = weapon.GiveToPlayer

	if IsValid(ent) and ply == ent then
		weapon.GiveToPlayer = nil
		return true
	else
		return false
	end
end)

hook.Add("WeaponEquip", "MuR_Fixes", function( weapon, ply )
	if MuR.Gamemode == 3 and weapon.IsTFAWeapon and weapon.Base == "tfa_gun_base" then
		timer.Simple(0, function()
			ply:DropWeapon( weapon )
		end)
	end
end)

hook.Add("PlayerUse", "MuR_DoorUse", function(ply, door)
	if door:GetClass() == "prop_door_rotating" or door:GetClass() == "func_door_rotating" then
		if not door.AntiDoorSpam or CurTime() - door.AntiDoorSpam > 0.5 and ply:GetNW2String("Class") ~= "Zombie" then
			door.AntiDoorSpam = CurTime()
		else
			return false
		end
	end
end)

hook.Add("AllowPlayerPickup", "MuR_DisableUseProp", function(ply, ent) return false end)

function meta:Suicide()
	local wep = self:GetActiveWeapon()
	if timer.Exists("MindControl_" .. self:EntIndex()) or self.Suiciding or not IsValid(wep) or wep:GetMaxClip1() <= 0 and not wep.Melee or wep.DisableSuicide or self:GetSVAnim() != "" then return false end

	local delay, delay2, anim = 0.8, 1, "mur_suicide"

	if wep.IsTFAWeapon and wep.Category == "Bloodshed - Sidearms" then
		delay, delay2, anim = 3.5, 3.65, "mur_suicide_Pistol"
	else
		delay, delay2, anim = 3.5, 3.65, "mur_suicide_rifle"
	end

	if isnumber(wep.Primary.Damage) and wep.Primary.Damage >= 45 then
		self.DeathBlowHead = true
	end

	self:Freeze(true)
	self.Suiciding = true
	self:SetSVAnimation(anim, true)

	timer.Simple(delay, function()
		if not IsValid(self) then return end

		if IsValid(wep) and wep.Primary.Sound and not wep.Melee then
			self:EmitSound(wep.Primary.Sound, 70)
		else
			self:EmitSound("physics/flesh/flesh_bloody_break.wav", 70)
		end

		local ef = EffectData()
		ef:SetOrigin(self:GetBonePosition(self:LookupBone("ValveBiped.Bip01_Head1")))
		ef:SetColor(0)
		util.Effect("BloodImpact", ef)
	end)

	timer.Simple(delay2, function()
		if not IsValid(self) then return end
		self.Suiciding = false
		self:Freeze(false)
		self:SetHealth(1)
		if IsValid(wep) and wep.ShootSound then
			local att = game.GetWorld()
			local dmginfo = DamageInfo()
			
			dmginfo:SetDamage(self:Health()*10 + self:Armor())
			dmginfo:SetAttacker(att)
			dmginfo:SetInflictor(att)
			dmginfo:SetDamageType(DMG_BULLET)
			dmginfo:SetDamageForce(self:GetForward()*-1)
			
			local headPos = self:GetBonePosition(self:LookupBone("ValveBiped.Bip01_Head1"))
			dmginfo:SetDamagePosition(headPos)
			self:TakeDamageInfo(dmginfo)
		else
			self:TakeDamage(self:Health()*10 + self:Armor())
		end
	end)
end

hook.Add("CanPlayerSuicide", "MuR_SuicideAnimation", function(ply)
	if ply:GetNW2String("Class") == "Zombie" then
		return true
	end
	ply:Suicide()
	return false
end)

hook.Add("PlayerUse", "MuR_UseThings", function(ply, ent)
	local tab = ent:GetChildren()
	for _, e in pairs(tab) do
		if IsValid(e) and e:GetClass() == "murwep_ied" and IsValid(e.PlayerOwner) and ply != e.PlayerOwner and not e.UsedAlready then
			e.UsedAlready = true
			e:EmitSound("murdered/weapons/grenade/ied.wav", 60)
			timer.Simple(0.8, function()
				if !IsValid(e) then return end
				e:Explode()
			end)
			break
		end
	end
	if ent.Poison and !ply:IsKiller() then
		ent.Poison = false
		ply.PoisonVoiceTime = CurTime() + math.random(15, 60)
		ply:SetNW2Bool("Poison", true)
	end
end)

hook.Add("EntityEmitSound", "MuR_QuieterRagdollSounds", function(data)
    if (data.Entity:GetClass() == "prop_ragdoll" or data.Entity:IsWorld()) and string.find(data.SoundName, "physics/body/") then
        data.Volume = data.Volume * 1
		data.SoundLevel = 60
        return true
    end
end)

hook.Add("SetupPlayerVisibility", "MuR_PoliceVisibility", function(ply, viewEntity)
	if not IsValid(ply) then return end
	
	if MuR.PoliceState == 5 and (ply:GetNW2String("Class") == "Officer" or ply:GetNW2String("Class") == "ArmoredOfficer" or ply:GetNW2String("Class") == "SWAT") then
		for _, target in pairs(player.GetAll()) do
			if IsValid(target) and target != ply then
				AddOriginToPVS(target:GetPos())
			end
		end
	end
end)

