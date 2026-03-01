local meta = FindMetaTable("Player")
util.AddNetworkString("MuR.SendDataToClient")
util.AddNetworkString("MuR.PlaySoundOnClient")
util.AddNetworkString("MuR.ChatAdd")
util.AddNetworkString("MuR.Announce")
util.AddNetworkString("MuR.Message")
util.AddNetworkString("MuR.Message2")
util.AddNetworkString("MuR.Countdown")
util.AddNetworkString("MuR.Notify")
util.AddNetworkString("MuR.FinalScreen")
util.AddNetworkString("MuR.ViewPunch")
util.AddNetworkString("MuR.PainImpulse")
util.AddNetworkString("MuR.StartScreen")
util.AddNetworkString("MuR.VoiceLines")
util.AddNetworkString("MuR.ShowLogScreen")
util.AddNetworkString("MuR.CalcView")
util.AddNetworkString("MuR.BodySearch")
util.AddNetworkString("MuR.RemoveItemFromSearch")
util.AddNetworkString("MuR.SetHull")
util.AddNetworkString("MuR.WeaponryEffect")
util.AddNetworkString("MuR.BloodDamageSound")
util.AddNetworkString("MuR.Storm.Start")
util.AddNetworkString("MuR.Storm.End")
util.AddNetworkString("MuR.Storm.Thunder")
util.AddNetworkString("MuR.Storm.WindDirection")
util.AddNetworkString("MuR.CraftingMessage")
util.AddNetworkString("MuR.ZombieDeathAnim")
util.AddNetworkString("MuR.ExecuteString")
util.AddNetworkString("MuR.ResetPain")
util.AddNetworkString("MuR.TripwireMinigame")
util.AddNetworkString("MuR.TripwireResult")

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
		if weaponData.IsTraitorGun then continue end
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
    for _, ply in player.Iterator() do
        if ply:Alive() and ply ~= exclude then
            table.insert(players, ply)
        end
    end
    return #players > 0 and players[math.random(#players)] or nil
end

function meta:PlayNZDeathAnim(pos, class)
	pos = pos or self:GetPos()
	class = class or ""

	for _, ent in ipairs(ents.FindInSphere(pos, 200)) do
		if ent:IsNPC() then
			local cl = ent:GetClass()
			if MuR.DeathAnimClasses[cl] then
				class = cl
				break
			end
		end
	end

	net.Start("MuR.ZombieDeathAnim")
	net.WriteVector(pos)
	net.WriteString(class)
	net.Send(self)
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
	if self.RandomSkinDisabled then return end

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

net.Receive("MuR.TripwireResult", function(_, ply)
	local ent = net.ReadEntity()
	local success = net.ReadBool()
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if not IsValid(ent) or ent:GetClass() ~= "murwep_grenade" then return end
	if ent.Activated or not IsValid(ent.OwnerTrap) then return end
	if not ent.DisarmInProgress or ent.DisarmPlayer ~= ply then return end
	if ply:GetPos():DistToSqr(ent:GetPos()) > (140 * 140) then
		ent.DisarmInProgress = false
		ent.DisarmPlayer = nil
		return
	end

	ent.DisarmInProgress = false
	ent.DisarmPlayer = nil

	if not success then
		MuR:GiveMessage2("tripwire_fail", ply)
		ent:ActivateGrenade()
		return
	end

	if IsValid(ent.StakeConst) then
		ent.StakeConst:Remove()
	end
	constraint.RemoveAll(ent)

	if IsValid(ent.StakeEnt) then
		ent.StakeEnt:Remove()
	end

	local grenadeClass = ent.F1 and "mur_f1" or "mur_m67"
	ply:GiveWeapon(grenadeClass)

	SafeRemoveEntity(ent)
end)

function meta:ChangeGuilt(mult)
	if MuR.Ending or GetConVar("mur_disableguilt"):GetBool() or MuR.EnableDebug then return end

	local currentMode = MuR.Mode(MuR.Gamemode)
	if currentMode and currentMode.no_guilt then return end

	local guilt = self:GetNW2Float("Guilt", 0)
	local plus = 10 * mult

	self:SetNW2Float("Guilt", math.Clamp(guilt + plus, 0, 100))

	local id, guilt = self:SteamID64(), self:GetNW2Float("Guilt")

	if guilt >= 100 then
		self:SetNW2Float("Guilt", 0)
		timer.Simple(0.1, function()
			if !IsValid(self) then return end
			self:Ban(30, true)
		end)
	end

	file.Write("bloodshed/guilt/"..id..".txt", self:GetNW2Float("Guilt", 0))
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
	local hunger = math.Clamp(self:GetNW2Float("Hunger") + num, 0, 100)
	local stamina = math.Clamp(self:GetNW2Float("Stamina") + num / 2, 0, 100)
	local health = math.Clamp(self:Health() + num / 10, 0, self:GetMaxHealth())

	self:SetNW2Float("Hunger", hunger)
	self:SetNW2Float("Stamina", stamina)
	self:SetHealth(health)
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

	if IsValid(ply) and ply:IsPlayer() then
		ply.MessageCooldowns = ply.MessageCooldowns or {}

		if ply.MessageCooldowns[type] and CurTime() < ply.MessageCooldowns[type] then 
			return 
		end
		ply.MessageCooldowns[type] = CurTime() + 3

        if ply.GlobalMessageCooldown and CurTime() < ply.GlobalMessageCooldown then
            return
        end
        ply.GlobalMessageCooldown = CurTime() + 0.5

		if not ply:Alive() then
			local dtime = ply.DeathTime or 0
			if CurTime() - dtime > 1 then return end
		end

		if ply:GetNW2Bool("IsUnconscious", false) then
			local utime = ply.UnconsciousStart or 0
			if CurTime() - utime > 1 then return end
		end
	end

	net.Start("MuR.Message2")
	net.WriteString(type)
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

function MuR:Notify(target, text, level)
	if text == nil then return end
	if type(text) != "string" then
		text = tostring(text or "")
	end
	text = string.Trim(text)
	if text == "" then return end
	level = math.Clamp(tonumber(level) or 0, 0, 3)

	local recipients
	if istable(target) then
		recipients = {}
		for _, ply in ipairs(target) do
			if IsValid(ply) and ply:IsPlayer() then
				table.insert(recipients, ply)
			end
		end
		if #recipients == 0 then return end
	elseif IsValid(target) and target:IsPlayer() then
		recipients = target
	end

	net.Start("MuR.Notify")
	net.WriteString(text)
	net.WriteUInt(level, 3)

	if recipients then
		net.Send(recipients)
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
			local role = MuR:GetRole("Civilian")
			if role and role.models then
				local isMale = not tobool(ply:GetInfoNum("blsd_character_female", 0))
				local mdl
				if isfunction(role.models) then
					mdl = role.models(ply)
				elseif istable(role.models) then
					if role.models.male and role.models.female then
						mdl = table.Random(isMale and role.models.male or role.models.female)
					else
						mdl = table.Random(role.models)
					end
				end
				if isstring(mdl) then
					ply:SetModel(mdl)
				end
			end
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
		LastAlivePosition = nil,
		RandomSkinDisabled = false,
		peppertimevoice = 0,
		NextUnconsciousCheck = 0
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

	for i = 0, ply:GetNumBodyGroups() - 1 do
		ply:SetBodygroup(i, 0)
	end

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
		DeathStatus = 0,
		ToxinLevel = 0,
		Blindness = 0,
		ConcussionEnd = 0,
		InternalBleedEnd = 0,
		CoordinationEnd = 0,
		AdrenalineEnd = 0
	}

	for k, v in pairs(nwf) do ply:SetNW2Float(k, v) end

	local nwb = {
		LegBroken = false,
		HardBleed = false,
		GeroinUsed = false,
		Poison = false,
		Bredogen = false,
		FlashlightIsOn = false,
		ShockState = false,
		IsUnconscious = false,
		Pneumothorax = false,
		SpineBroken = false,
		ForceProneOnly = false
	}

	for k, v in pairs(nwb) do ply:SetNW2Bool(k, v) end

	ply:SetNW2Entity("CurrentTarget", NULL)

	ply:SetBloodColor(BLOOD_COLOR_RED)
	ply:SetColor(Color(255,255,255))
	ply:SetMaterial("")
	ply:SetEyeAngles(Angle(ply:EyeAngles().x, ply:EyeAngles().y, 0))
	ply:SetPlayerColor(ColorRand():ToVector())
	ply:SetViewOffset(Vector(0, 0, 64))
	ply:SetViewOffsetDucked(Vector(0, 0, 36))
	ply:SetJumpPower(190)

	local pos = MuR:GetRandomPos()
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
    local innocentRole = MuR:GetRole("Innocent")
    if innocentRole and innocentRole.models then
        local mdl
        if isfunction(innocentRole.models) then
            mdl = innocentRole.models(ply)
        elseif istable(innocentRole.models) then
            if innocentRole.models.male and innocentRole.models.female then
                mdl = table.Random(ply.Male and innocentRole.models.male or innocentRole.models.female)
            else
                mdl = table.Random(innocentRole.models)
            end
        end
        if isstring(mdl) then
            ply:SetModel(mdl)
        end
    end

	ply:AllowFlashlight(false)
	ply:GiveWeapon("mur_hands", true)
	ply:SetTeam(2)
	ply:SetHealth(100)
	ply:SetMaxHealth(100)

    local roleData = MuR:GetRole(class)
    if roleData then
        if roleData.male != nil then
            ply.Male = roleData.male
        end

        if roleData.models then
            if isfunction(roleData.models) then
                ply:SetModel(roleData.models(ply))
            elseif istable(roleData.models) then
                if roleData.models.male and roleData.models.female then
                    ply:SetModel(table.Random(ply.Male and roleData.models.male or roleData.models.female))
                else
                    ply:SetModel(table.Random(roleData.models))
                end
            end
        end

        if roleData.flashlight != nil then
            ply:AllowFlashlight(roleData.flashlight)
        end

        if roleData.team then
            ply:SetTeam(roleData.team)
        end

        if roleData.health then
            ply:SetHealth(roleData.health)
            ply:SetMaxHealth(roleData.health)
        end

        if roleData.onSpawn then
            local skipOnSpawn = MuR.Gamemode == 23 and class == "PrisonGuard" and MuR.Mode23 and not MuR.Mode23.GuardsSpawned
            if not skipOnSpawn then
                roleData.onSpawn(ply)
            end
        end
    end

	if MuR.EnableDebug then
		ply:GiveWeapon("weapon_physgun")
		ply:GiveWeapon("gmod_tool")
	end

	ply.SpawnDataSpeed = {ply:GetWalkSpeed(), ply:GetRunSpeed(), ply:GetJumpPower()}
	ply:SetNewName()
	ply:SetupHands()
	ply:RandomSkin()
	net.Start("MuR.ResetPain")
	net.Send(ply)
end

function GM:PlayerDeathSound(ply)
	return true
end

function MuR:ExecuteString(type)
	if type == "decals" then
		type = [[RunConsoleCommand("r_decals", "9000000") RunConsoleCommand("mp_decals", "9000000")]]
	end
	net.Start("MuR.ExecuteString")
	net.WriteString(type)
	net.Broadcast()
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

function meta:DeathEffect(att)
	local pos = self.LastAlivePosition or self:GetPos()
	local isNPC = IsValid(att) and att:IsNPC()
	local playAnim = (MuR.Gamemode == 18) or (MuR.Gamemode == 22 and isNPC)

	if not playAnim then
		self:ConCommand("soundfade 100 5")
		self:ScreenFade(SCREENFADE.OUT, color_black, 0.1, 4.9)
	else
		self:ScreenFade(SCREENFADE.OUT, color_black, 0.1, 1.9)
		timer.Simple(2, function()
			if !IsValid(self) then return end
			self:PlayNZDeathAnim(pos)
		end)
	end
end

function GM:PlayerDeath(ply, inf, att)
	if IsValid(att.MindController) then
		att = att.MindController
	end

	ply:DeathEffect(att)
	ply.DeathTime = CurTime()
	ply:Freeze(true)
	ply:SetNW2Bool("Poison", false)
	ply:SetNW2Bool("Bredogen", false)
	net.Start("MuR.ResetPain")
	net.Send(ply)
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
			elseif att2:GetNW2String("Class") != "Soldier" and (ply:Team() == 2 or ply:Team() == 3) and (att2:Team() == 2 or att2:Team() == 3) and MuR.Gamemode ~= 11 and MuR.Gamemode ~= 12 and ply ~= att2 then
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

	if att:IsPlayer() and ply:GetNW2Float("ArrestState") ~= 2 and att:IsRolePolice() and ply ~= att and !ply:IsKiller() and not (MuR.Gamemode == 23 and ply:GetNW2String("Class") == "Prisoner") then
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

	if ply:IsBot() and ply.KickAfterDeath then
		timer.Simple(1, function() if !IsValid(ply) then return end ply:Kick("Bot kicked after death.") end)
	end
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
		for _, ply2 in player.Iterator() do
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

	if string.len(cl) > 256 then return end
	if !ply:Alive() or !IsValid(ent) or ply:GetPos():DistToSqr(ent:GetPos()) > 25000 or !istable(ent.Inventory) then return end

	if string.StartWith(cl, "mur_armor_") then
		local armorId = string.sub(cl, 11)
		local item = MuR.Armor.GetItem(armorId)
		if item then
			if table.HasValue(ent.Inventory, cl) then
				table.RemoveByValue(ent.Inventory, cl)
				local pickup
				if ent:GetClass() == "prop_ragdoll" then
					pickup = MuR:DropArmorFromRagdoll(ent, item.bodypart)
				else
					pickup = MuR:SpawnArmorPickup(ent:GetPos() + Vector(0, 0, 20), armorId)
				end

				if IsValid(pickup) then
					timer.Simple(0.1, function()
						if IsValid(ply) and IsValid(pickup) then
							pickup:Use(ply, ply)
						end
					end)
				end

				if item.unequip_sound then
					ply:EmitSound(item.unequip_sound, 50, 100)
				end
			end
		end
		return
	end

	if ply:HasWeapon(cl) then return end
	local prop = ent:GetClass() != "prop_ragdoll"

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

	net.Start("MuR.RemoveItemFromSearch")
	net.WriteEntity(ent)
	net.WriteString(cl)
	net.Broadcast()
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

		if IsValid(tr) and table.HasValue(MuR.LootableProps, tr:GetModel()) and istable(tr.Inventory) and tr:GetPos():DistToSqr(ply:GetPos()) < 10000 then
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

	if talker:Alive() and talker:GetNW2String("Class") == "CombineSoldier" and listener:Alive() and listener:GetNW2String("Class") == "CombineSoldier" then return true end

	local listenerWep = listener:GetWeapon("mur_radio")
	local talkerWep = talker:GetActiveWeapon()
	
	if IsValid(listenerWep) and IsValid(talkerWep) and talkerWep:GetClass() == "mur_radio" then
		local listenerOn = listenerWep:GetNWBool("RadioOn", false)
		local talkerOn = talkerWep:GetNWBool("RadioOn", false)
		
		if listenerOn and talkerOn then
			local listenerChannel = listenerWep:GetNWInt("RadioChannel", 1)
			local talkerChannel = talkerWep:GetNWInt("RadioChannel", 1)
			
			if listenerChannel == talkerChannel then
				local dist = listener:GetPos():Distance(talker:GetPos())
				if dist <= 8000 then
					return true, false
				end
			end
		end
	end

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
	for _, ent in player.Iterator() do
		if not ent:Alive() then continue end

		ent.LastAlivePosition = IsValid(ent:GetRD()) and ent:GetRD():GetPos() or ent:GetPos()

		if ent:HaveStability() and not ent:GetNW2Bool("GeroinUsed", false) then
			ent:SetNW2Float("Stability", math.Clamp(ent:GetNW2Float("Stability")-FrameTime()/10, 0, 100)) 
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
			ent.ViewOffsetZ = Lerp(FrameTime()/0.1, ent.ViewOffsetZ, num)
		else
			ent.ViewOffsetZ = 64
			if string.find(ent:GetSVAnim(), "sequence_ron_comply_start_0") then
				ent:SetActiveWeapon(nil)
			end
		end

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
			local damage = running and 1.5 or moving and 1.25 or 1
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
			local damage = running and 1.5 or moving and 1.25 or 1
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
			if MuR.Gamemode != 18 then
				ent:SetNW2Float("Hunger", math.Clamp(ent:GetNW2Float("Hunger") - 1, 0, 100))
			end

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
				dmg:SetDamage(dmg:GetDamage()*2)
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

			if att.DamageTargetGuilt <= 0 and MuR.Gamemode ~= 5 and MuR.Gamemode ~= 6 and (att:Team() == 2 or att:Team() == 3) then
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
		local entAmmoType = ent:GetPrimaryAmmoType()
		local entClip = ent:Clip1()

		if ply:HasWeapon(ent:GetClass()) then
			if entClip > 0 and entAmmoType > 0 then
				ply:GiveAmmo(entClip, entAmmoType, true)
				ent:SetClip1(0)
				ply:EmitSound("items/ammocrate_open.wav", 60)
			end
			return
		end

		if entAmmoType > 0 and entClip > 0 then
			for _, wep in ipairs(ply:GetWeapons()) do
				if wep:GetPrimaryAmmoType() == entAmmoType and wep:GetClass() ~= ent:GetClass() then
					ply:GiveAmmo(entClip, entAmmoType, true)
					ent:SetClip1(0)
					ply:EmitSound("items/ammocrate_open.wav", 60)
					return
				end
			end
		end

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
	if timer.Exists("MindControl_" .. self:EntIndex()) or self.Suiciding or not IsValid(wep) or wep.DisableSuicide or self:GetSVAnim() != "" then return false end

	-- причуда века
	if not wep.Melee then
		local maxclip = wep:GetMaxClip1() or 0
		if maxclip > 0 then
			if wep:Clip1() <= 0 then return false end
		else
			local ammoType = wep:GetPrimaryAmmoType()
			if ammoType and ammoType > 0 then
				if self:GetAmmoCount(ammoType) <= 0 then return false end
			else
				return false
			end
		end
	end

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

	if ent:GetModel() == "models/props/cs_office/fire_extinguisher.mdl" then
		if ply:HasWeapon("mur_extinguisher") then
			return
		end

		ply:GiveWeapon("mur_extinguisher")
		local tname = "MuR_ExtinguisherSelect_" .. ply:EntIndex()
		timer.Create(tname, 0.05, 6, function()
			if not IsValid(ply) then
				timer.Remove(tname)
				return
			end
			if ply:HasWeapon("mur_extinguisher") then
				ply:SelectWeapon("mur_extinguisher")
				timer.Remove(tname)
			end
		end)
		ent:Remove()
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
		for _, target in player.Iterator() do
			if IsValid(target) and target != ply then
				AddOriginToPVS(target:GetPos())
			end
		end
	end
end)
