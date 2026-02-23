if SERVER then
	CreateConVar("blsd_ror_npccountscale", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "NPC count scale multiplier for Ready or Not mode", 0.1, 5)
end

MuR.Mode14 = MuR.Mode14 or {}

function MuR:Mode14Report(ply, ent)
    if not IsValid(ply) or not IsValid(ent) then return end
    if MuR.Gamemode != 14 and not ent:GetNW2Bool("RoN_ForcedReport") then return end
    if ent:GetNW2Bool("RoN_Reported") then return end
    if ent:GetNW2Bool("MuR.IsLivingRagdoll") then return end

    local type = ent:GetNW2String("RoN_Type", "suspect")
    if IsValid(ent.OwnerDead) and ent.OwnerDead:IsPlayer() then
        type = "swat"
    end

    local isSecured = ent:GetClass() == "bloodshed_anim_model" or ent:GetClass() == "prop_dynamic"
    ent:SetNW2Bool("RoN_Reported", true)

    local plyVoice = ""
    if isSecured then
        if type == "suspect" then
            plyVoice = "ror_police_reportarrestedsuspect"
        else
            plyVoice = "ror_police_reportcivilianarrested"
        end
    else
        if type == "suspect" then
            plyVoice = "ror_police_deadsus"
        elseif type == "civilian" or type == "hostage" then
            plyVoice = "ror_police_deadciv"
        elseif type == "swat" then
            plyVoice = "ror_police_deadswat"
        end
    end

    if plyVoice != "" then
        ply:PlayVoiceLine(plyVoice)
    end

    timer.Simple(3.5, function()
        if not IsValid(ply) then return end
        local sounds = {
            "npc/overwatch/radiovoice/apply.wav",
            "npc/overwatch/radiovoice/riot404.wav",
            "npc/overwatch/radiovoice/subject.wav",
            "npc/overwatch/radiovoice/respond.wav",
            "npc/overwatch/radiovoice/reporton.wav",
            "npc/overwatch/radiovoice/reportplease.wav"
        }
        ply:EmitSound(table.Random(sounds), 70, 100)
    end)

    local money = 0
    local msg = ""

    if isSecured then
        if type == "civilian" or type == "hostage" then
            money = 10
            msg = "mode14_civilian_secured"
        else
            money = 25
            msg = "mode14_suspect_arrested"
        end
    else
        if type == "civilian" then
            money = -25
            msg = "mode14_deceased_civilian"
        elseif type == "hostage" then
            money = -50
            msg = "mode14_deceased_hostage"
        elseif type == "suspect" then
            if ent.SurrenderedDeath then
                money = -10
                msg = "mode14_deceased_surrendering_suspect"
            else
                money = 5
                msg = "mode14_deceased_suspect"
            end
        elseif type == "swat" then
            msg = "mode14_downed_officer"
        end
    end

    net.Start("MuR.Mode14Notification")
    net.WriteString(msg)
    net.WriteInt(money, 16)
    net.Send(ply)

    if type == "swat" and not isSecured then
        if ply.NextDeadSwatSound and CurTime() < ply.NextDeadSwatSound then return end
        ply:PlayVoiceLine("ror_police_deadswat")
        ply.NextDeadSwatSound = CurTime() + 5
    end
end

local function GetNPCCountScale()
	local cvar = GetConVar("blsd_ror_npccountscale")
	return cvar and cvar:GetFloat() or 1
end

local function CalculateNPCCount(playerCount)
	local scale = GetNPCCountScale()
	local base = math.Clamp(playerCount * math.Rand(2.5, 4), 6, 32)
	return math.floor(base * scale)
end

local function CalculateMaxActiveNPCs(playerCount)
	local scale = GetNPCCountScale()
	local base = math.Clamp(playerCount * 2, 4, 16)
	return math.floor(base * scale)
end

local function GetMaxPlayersOnMap()
	return 5
end

local function SpawnSuspectNPC(pos)
	if not isvector(pos) then return nil end

	local tab = MuR.PoliceClasses["suspect"]
	if not istable(tab) then return nil end

	local class = tab.npcs[math.random(1, #tab.npcs)]
	local wclass = tab.weps[math.random(1, #tab.weps)]

	local ent = ents.Create(class)
	if not IsValid(ent) then return nil end

	ent:SetPos(pos)
	ent:Spawn()
	ent:Give(wclass)

	return ent
end

MuR.RegisterMode(14, {
	name = "Ready or Not", 
	chance = 20, 
	need_players = 1, 
	disables = true,
	no_default_roles = true,
	win_condition = "raid",
	custom_spawning = true,
	npc_team_count = true,
	custom_spawning_func = "Mode14SpawnPlayers",
	no_npc_police_spawn = true,
	armored_officer_raid_logic = true,
	no_guilt = true, 
	no_friendly_fire = true,
	timer = 900,
	kteam = "ArmoredOfficer",
	dteam = "ArmoredOfficer",
	iteam = "ArmoredOfficer",
	OnModeStarted = function(mode)
		if SERVER then
			util.AddNetworkString("MuR.Mode14Reset")
			util.AddNetworkString("MuR.Mode14Data")
			util.AddNetworkString("MuR.Mode14Objectives")
			util.AddNetworkString("MuR.Mode14Report")
			util.AddNetworkString("MuR.Mode14Notification")
			net.Start("MuR.Mode14Reset")
			net.Broadcast()

			local playerCount = math.min(player.GetCount(), 5)

			MuR.Mode14 = {
				NPCToSpawn = CalculateNPCCount(playerCount),
				NPCSpawned = 0,
				MaxActiveNPCs = CalculateMaxActiveNPCs(playerCount),
				SpawnDelay = 0,
				SpawnInterval = math.Clamp(3 - playerCount * 0.2, 0.8, 3),
				ActivePlayers = {},
				ReinforcementQueue = {},
				MaxPlayersOnMap = GetMaxPlayersOnMap(),
				KilledNPCs = 0,
				TotalNPCs = CalculateNPCCount(playerCount),
				CiviliansRescued = 0,
				TotalCivilians = 0,
				ObjectiveSuspectsComplete = false,
				ObjectiveCiviliansComplete = false,
			}

			timer.Simple(2, function()
				if MuR.Gamemode != 14 or not MuR.Mode14 then return end
				local civCount = 0
			for _, npc in ipairs(ents.FindByClass("npc_vj_bloodshed_suspect")) do
					if npc.IsCivilian or npc.IsHostage then
						civCount = civCount + 1
					end
				end
				MuR.Mode14.TotalCivilians = civCount
				MuR:SendMode14Objectives()
			end)

			hook.Add("OnNPCKilled", "MuR.Mode14.NPCKilled", function(npc, attacker, inflictor)
				if MuR.Gamemode != 14 then return end

				if npc:GetClass() == "npc_vj_bloodshed_suspect" or npc.IsSuspect then
					MuR.Mode14.KilledNPCs = MuR.Mode14.KilledNPCs + 1

					if MuR.Mode14.KilledNPCs >= MuR.Mode14.TotalNPCs and not MuR.Mode14.ObjectiveSuspectsComplete then
						MuR.Mode14.ObjectiveSuspectsComplete = true
						MuR:SendMode14Objectives()
					end
				end

				if (npc.IsCivilian or npc.IsHostage) and not npc.IsRescued then
					if MuR.Mode14.TotalCivilians > 0 then
						MuR.Mode14.TotalCivilians = MuR.Mode14.TotalCivilians - 1
						MuR:SendMode14Objectives()
					end
				end

				if not IsValid(attacker) or not attacker:IsPlayer() then return end

				local isSuspect = npc.IsSuspect
				if isSuspect == nil then isSuspect = IsValid(npc:GetActiveWeapon()) end

                local type = "suspect"
                if npc.IsHostage then type = "hostage" elseif npc.IsCivilian then type = "civilian" end

                local isSurrendering = npc:GetNW2Float("ArrestState") == 1 or string.find(npc:GetSVAnim(), "sequence_ron_comply_start")

                local money = 0
                if type == "civilian" then money = -25 elseif type == "hostage" then money = -50 
                elseif isSurrendering then money = -10
                else money = 5 end

                attacker:AddMoney(money)
			end)

			hook.Add("KeyPress", "MuR.Mode14.KeyPress", function(ply, key)
				if MuR.Gamemode != 14 then return end
				if key == IN_USE then
					local tr = util.TraceLine({
						start = ply:GetShootPos(),
						endpos = ply:GetShootPos() + ply:GetAimVector() * 96,
						filter = ply
					})
					local ent = tr.Entity
                    local isValidTarget = IsValid(ent) and (ent:GetClass() == "prop_ragdoll" and ent:LookupBone("ValveBiped.Bip01_Head1"))
					if isValidTarget and tr.HitPos:DistToSqr(ply:GetShootPos()) < 14400 then
                        MuR:Mode14Report(ply, ent)
					end
				end
			end)

            hook.Add("CreateEntityRagdoll", "MuR.Mode14.TagRagdoll", function(ent, rag)
                if MuR.Gamemode != 14 then return end
                local type = "suspect"
                if ent:IsPlayer() then
                    type = "swat"
                elseif ent.IsHostage then
                    type = "hostage"
                elseif ent.IsCivilian then
                    type = "civilian"
                end

                rag:SetNW2String("RoN_Type", type)
				rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
                if string.find(ent:GetSequenceName(ent:GetSequence()), "sequence_ron_comply_start") then
                    rag.SurrenderedDeath = true
                end
            end)

            hook.Add("OnNPCKilled", "MuR.Mode14.ArrestReward", function(ent, att)
                if MuR.Gamemode != 14 then return end
                if ent:GetNW2Float("DeathStatus") == 3 then
                    if IsValid(att) and att:IsPlayer() then
                        local money = 25
                        if ent.IsCivilian or ent.IsHostage then
                            money = 10
                        end
                        att:AddMoney(money)
                    end
                end
            end)

			hook.Add("PlayerDeath", "MuR.Mode14.PlayerDeath", function(victim, inflictor, attacker)
				if MuR.Gamemode != 14 then return end
				if not MuR.Mode14 then return end

				MuR.Mode14.ActivePlayers[victim:SteamID64()] = nil

				if #MuR.Mode14.ReinforcementQueue > 0 then
					local nextPly = table.remove(MuR.Mode14.ReinforcementQueue, 1)
					if IsValid(nextPly) and not nextPly:Alive() then
						timer.Simple(3, function()
							if not IsValid(nextPly) or MuR.Gamemode != 14 then return end
							if not MuR.Mode14 then return end

							nextPly.ForceSpawn = true
							nextPly:SetNW2String("Class", "ArmoredOfficer")
							nextPly:Spawn()
							nextPly:ScreenFade(SCREENFADE.IN, color_black, 1, 0)

							local pos = MuR:GetRandomPos(false)
							if isvector(pos) then
								timer.Simple(0.1, function()
									if IsValid(nextPly) and nextPly:Alive() then
										nextPly:SetPos(pos)
									end
								end)
							end

							MuR.Mode14.ActivePlayers[nextPly:SteamID64()] = true
							MuR:GiveAnnounce("reinforcement_arrived", nextPly)
						end)
					end
				end
			end)
		end
	end,
	OnModeThink = function(mode)
		if not SERVER then return end
		if not MuR.Mode14 then return end
		if MuR.Ending then return end

		local activeNPCs = 0
		for _ in ipairs(ents.FindByClass("npc_vj_bloodshed_suspect")) do activeNPCs = activeNPCs + 1 end

		if activeNPCs < MuR.Mode14.MaxActiveNPCs and MuR.Mode14.NPCSpawned < MuR.Mode14.NPCToSpawn and MuR.Mode14.SpawnDelay < CurTime() then
			local pos = MuR:GetRandomPos(true)
			if not isvector(pos) then
				pos = MuR:GetRandomPos(false)
			end

			if isvector(pos) then
				local npc = SpawnSuspectNPC(pos)
				if IsValid(npc) then
					MuR.Mode14.NPCSpawned = MuR.Mode14.NPCSpawned + 1
					MuR.Mode14.SpawnDelay = CurTime() + MuR.Mode14.SpawnInterval
				end
			end
		end

		if not MuR.Mode14.NextObjectivesUpdate or CurTime() >= MuR.Mode14.NextObjectivesUpdate then
			MuR:SendMode14Objectives()
			MuR.Mode14.NextObjectivesUpdate = CurTime() + 1
		end

		MuR:SendMode14Data()
	end,
	OnModeEnded = function(mode)
		if SERVER then
			hook.Remove("OnNPCKilled", "MuR.Mode14.NPCKilled")
			hook.Remove("KeyPress", "MuR.Mode14.KeyPress")
			hook.Remove("PlayerDeath", "MuR.Mode14.PlayerDeath")
			hook.Remove("CreateEntityRagdoll", "MuR.Mode14.TagRagdoll")
			hook.Remove("OnNPCKilled", "MuR.Mode14.ArrestReward")
			MuR.Mode14 = nil
		end
		if CLIENT then
			hook.Remove("HUDPaint", "MuR.Mode14HUD")
			hook.Remove("HUDPaint", "MuR.Mode14ReportPrompt")
			hook.Remove("HUDPaint", "MuR.Mode14Compass")
            notifications = {}
            promptAlpha = 0
		end
	end
})

if SERVER then
	function MuR:SendMode14Data()
		if not MuR.Mode14 then return end

		net.Start("MuR.Mode14Data")
		net.WriteInt(MuR.Mode14.KilledNPCs, 16)
		net.WriteInt(MuR.Mode14.TotalNPCs, 16)
		net.WriteInt(#MuR.Mode14.ReinforcementQueue, 8)
		net.Broadcast()
	end

	function MuR:SendMode14Objectives()
		if not MuR.Mode14 then return end

		local suspectsAlive = 0
		local civiliansAlive = 0

		for _, npc in ipairs(ents.FindByClass("npc_vj_bloodshed_suspect")) do
			if IsValid(npc) then
				if npc.IsCivilian or npc.IsHostage then
					civiliansAlive = civiliansAlive + 1
				else
					suspectsAlive = suspectsAlive + 1
				end
			end
		end

		for _, npc in ipairs(ents.GetAll()) do
			if not IsValid(npc) or not npc:IsNPC() then continue end
			if npc:GetClass() == "npc_vj_bloodshed_suspect" then continue end
			if npc.IsCivilian or npc.IsHostage then
				civiliansAlive = civiliansAlive + 1
			end
		end

		local suspectsComplete = suspectsAlive == 0 and MuR.Mode14.NPCSpawned >= MuR.Mode14.NPCToSpawn
		local civiliansComplete = civiliansAlive == 0

		net.Start("MuR.Mode14Objectives")
		net.WriteBool(suspectsComplete)
		net.WriteBool(civiliansComplete)
		net.WriteInt(civiliansAlive, 8)
		net.Broadcast()
	end

	function MuR:Mode14SpawnPlayers()
		if MuR.Gamemode != 14 then return end
		if not MuR.Mode14 then return end

		local allPlayers = player.GetAll()
		table.Shuffle(allPlayers)

		local spawnPos = MuR:GetRandomPos(false)
		local spawned = 0

		for _, ply in ipairs(allPlayers) do
			if spawned < MuR.Mode14.MaxPlayersOnMap then
				ply:SetNW2String("Class", "ArmoredOfficer")
				ply:Spawn()
				ply:Freeze(true)
				ply:GodEnable()

				if isvector(spawnPos) then
					timer.Simple(1, function()
						if IsValid(ply) and ply:Alive() then
							ply:SetPos(spawnPos)
						end
					end)
				end

				timer.Simple(12, function()
					if IsValid(ply) then
						ply:Freeze(false)
						ply:GodDisable()
					end
				end)

				MuR.Mode14.ActivePlayers[ply:SteamID64()] = true
				spawned = spawned + 1
			else
				table.insert(MuR.Mode14.ReinforcementQueue, ply)
				ply:SetNW2String("Class", "ArmoredOfficer")
				ply:SetTeam(2)
				ply:Freeze(false)
				MuR:GiveAnnounce("waiting_reinforcement", ply)
			end
		end
	end
end

if CLIENT then
	local function We(x) return x / 1920 * ScrW() end
	local function He(y) return y / 1080 * ScrH() end

	local THEME = {
		bg = Color(0, 0, 0, 180),
		bgDark = Color(0, 0, 0, 220),
		accent = Color(30, 144, 255),
		accentDim = Color(30, 144, 255, 100),
		text = Color(255, 255, 255),
		textDim = Color(180, 180, 180),
		health = Color(50, 205, 50),
		healthLow = Color(255, 80, 80),
		armor = Color(100, 149, 237),
		warning = Color(255, 200, 50),
		danger = Color(255, 50, 50),
		grid = Color(30, 144, 255, 30)
	}

	local compassDirs = {"N", "NE", "E", "SE", "S", "SW", "W", "NW"}
	local compassMat = Material("vgui/gradient-l")

	surface.CreateFont("RoN_Font_Small", {font = "VK Sans Display DemiBold", extended = true, size = He(14), weight = 500, antialias = true})
	surface.CreateFont("RoN_Font_Medium", {font = "VK Sans Display DemiBold", extended = true, size = He(18), weight = 500, antialias = true})
	surface.CreateFont("RoN_Font_Large", {font = "VK Sans Display DemiBold", extended = true, size = He(24), weight = 700, antialias = true})
	surface.CreateFont("RoN_Font_Compass", {font = "VK Sans Display DemiBold", extended = true, size = He(16), weight = 600, antialias = true})
	surface.CreateFont("RoN_Font_Big", {font = "VK Sans Display DemiBold", extended = true, size = He(32), weight = 700, antialias = true})

	local function DrawCompass(x, y, width)
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		local ang = ply:EyeAngles().y
		local height = He(28)

		local centerX = x
		local pixelsPerDegree = width / 90

		render.SetScissorRect(x - width/2 + 2, y, x + width/2 - 2, y + height, true)

		for deg = -180, 180, 15 do
			local offset = (deg + ang) % 360
			if offset > 180 then offset = offset - 360 end

			local drawX = centerX - offset * pixelsPerDegree

			if drawX > x - width/2 and drawX < x + width/2 then
				local dirIndex = math.floor(((deg + 180) % 360) / 45) + 1
				local isCardinal = deg % 90 == 0
				local isMajor = deg % 45 == 0

				if isCardinal then
					local dir = compassDirs[dirIndex] or ""
					draw.SimpleText(dir, "RoN_Font_Compass", drawX, y + height/2, THEME.accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				elseif isMajor then
					surface.SetDrawColor(THEME.textDim)
					surface.DrawRect(drawX - 1, y + He(8), 2, He(12))
				else
					surface.SetDrawColor(THEME.grid)
					surface.DrawRect(drawX, y + He(10), 1, He(8))
				end
			end
		end

		render.SetScissorRect(0, 0, 0, 0, false)

		surface.SetDrawColor(THEME.accent)
		local triSize = He(6)
		draw.NoTexture()
		surface.DrawPoly({
			{x = centerX, y = y + 2},
			{x = centerX - triSize, y = y - triSize},
			{x = centerX + triSize, y = y - triSize}
		})
	end

	local function DrawHealthArmor(x, y)
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		local health = ply:Health()
		local maxHealth = ply:GetMaxHealth()

		local barWidth = We(180)
		local barHeight = He(30)

		local healthColor = health > 30 and THEME.health or THEME.healthLow

		surface.SetDrawColor(healthColor)
		local points = {}
		local step = 2
		local speed = health < 30 and 2.0 or 0.8
		local time = CurTime() * speed

		for i = 0, barWidth, step do
			local normalizedX = i / barWidth
			local phase = (normalizedX * 2 + time) % 1.0
			local y_val = 0

			if phase > 0.4 and phase < 0.6 then
				local p = (phase - 0.4) / 0.2
				if p < 0.2 then
					y_val = math.sin(p / 0.2 * math.pi) * He(3)
				elseif p < 0.3 then
					y_val = 0
				elseif p < 0.4 then
					y_val = -He(3) * math.sin((p-0.3)/0.1 * math.pi)
				elseif p < 0.6 then
					y_val = He(15) * math.sin((p-0.4)/0.2 * math.pi)
					if p > 0.5 then y_val = -y_val * 0.5 end
				elseif p < 0.7 then
					y_val = -He(5) * (1 - (p-0.6)/0.1)
				elseif p < 1.0 then
					y_val = math.sin((p-0.7)/0.3 * math.pi) * He(4)
				end
			end

			if health < 30 then
				y_val = y_val + math.sin(i * 0.5 + CurTime() * 20) * He(1)
			end

			table.insert(points, {x = x + He(4) + i, y = y + He(4) + barHeight/2 - y_val})
		end

		for i=1, #points-1 do
			surface.DrawLine(points[i].x, points[i].y, points[i+1].x, points[i+1].y)
		end

		local healthPercent = math.Clamp(health / maxHealth, 0, 1)
		local baseBPM = 60 + (1 - healthPercent) * 80
		local variance = 5 + (1 - healthPercent) * 10
		local bpm = baseBPM + math.sin(CurTime() * (2 - healthPercent)) * variance

		local bpmColor
		if healthPercent > 0.7 then
			bpmColor = Color(
				Lerp((healthPercent - 0.7) / 0.3, 150, 50),
				Lerp((healthPercent - 0.7) / 0.3, 200, 205),
				50
			)
		elseif healthPercent > 0.3 then
			bpmColor = Color(
				Lerp((healthPercent - 0.3) / 0.4, 255, 150),
				Lerp((healthPercent - 0.3) / 0.4, 150, 200),
				50
			)
		else
			bpmColor = Color(
				255,
				Lerp(healthPercent / 0.3, 80, 150),
				Lerp(healthPercent / 0.3, 80, 50)
			)
		end

		draw.SimpleText("BPM " .. math.Round(bpm), "RoN_Font_Small", x + barWidth + He(8), y + He(4) + barHeight/2, bpmColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local function DrawTeammates(x, y)
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		local teammates = {}
		for _, p in player.Iterator() do
			if p ~= ply and p:Alive() and p:Team() == ply:Team() then
				table.insert(teammates, p)
			end
		end

		if #teammates == 0 then return end

		local entryHeight = He(24)
		local width = We(180)

		draw.SimpleText(MuR.Language["mode14_squad"], "RoN_Font_Small", x + We(8), y + He(10), THEME.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		surface.SetDrawColor(THEME.accent)
		surface.DrawRect(x + He(4), y + He(18), width - He(8), 1)

		for i, mate in ipairs(teammates) do
			local yPos = y + He(24) + (i-1) * entryHeight
			local hp = mate:Health()
			local maxHp = mate:GetMaxHealth()
			local hpPercent = math.Clamp(hp / maxHp, 0, 1)

			local hpColor = hp > 30 and THEME.health or THEME.healthLow

			surface.SetDrawColor(Color(hpColor.r, hpColor.g, hpColor.b, 30))
			surface.DrawRect(x + He(4), yPos + He(2), (width - He(8)) * hpPercent, entryHeight - He(4))

			local mateHealthPercent = math.Clamp(hp / maxHp, 0, 1)
			local mateBaseBPM = 60 + (1 - mateHealthPercent) * 80
			local mateVariance = 5 + (1 - mateHealthPercent) * 10
			local mateBPM = mateBaseBPM + math.sin(CurTime() * (2 - mateHealthPercent)) * mateVariance

			local name = string.sub(mate:Nick(), 1, 12)
			draw.SimpleText(name, "RoN_Font_Small", x + He(8), yPos + entryHeight/2, THEME.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(math.Round(mateBPM) .. " BPM", "RoN_Font_Small", x + width - He(8), yPos + entryHeight/2, hpColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end
	end

	local function DrawMissionTimer(x, y)
		if not MuR.Data["TimerActive"] then return end

		local timeLeft = MuR.Data["TimerLeft"] or 0
		local mins = math.floor(timeLeft / 60)
		local secs = math.floor(timeLeft % 60)
		local timeStr = string.format("%02d:%02d", mins, secs)

		local boxHeight = He(36)

		local timeColor = THEME.text
		if timeLeft < 60 then
			local flash = math.abs(math.sin(CurTime() * 4))
			timeColor = Color(255, 255 * flash, 255 * flash)
		end

		draw.SimpleText(timeStr, "RoN_Font_Large", x, y + boxHeight/2, timeColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local function DrawWeaponInfo(x, y)
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		local wep = ply:GetActiveWeapon()
		if not IsValid(wep) then return end

		local name = wep:GetPrintName()
		if not name or name == "" then return end

		name = string.upper(name)

		draw.SimpleText(name, "RoN_Font_Small", x, y, THEME.textDim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	end

	local function DrawScanlines()
		surface.SetDrawColor(0, 0, 0, 15)
		for i = 0, ScrH(), 4 do
			surface.DrawRect(0, i, ScrW(), 1)
		end
	end

	MuR.Mode14Client = MuR.Mode14Client or {
		KilledNPCs = 0,
		TotalNPCs = 0,
		ReinforcementQueue = 0,
		ObjectiveSuspectsComplete = false,
		ObjectiveCiviliansComplete = false,
		ObjectiveSuspectsCompleteTime = 0,
		ObjectiveCiviliansCompleteTime = 0,
	}

	net.Receive("MuR.Mode14Reset", function()
		MuR.Mode14Client = {
			KilledNPCs = 0,
			TotalNPCs = 0,
			ReinforcementQueue = 0,
			ObjectiveSuspectsComplete = false,
			ObjectiveCiviliansComplete = false,
			ObjectiveSuspectsCompleteTime = 0,
			ObjectiveCiviliansCompleteTime = 0,
		}
	end)

	net.Receive("MuR.Mode14Data", function()
		MuR.Mode14Client.KilledNPCs = net.ReadInt(16)
		MuR.Mode14Client.TotalNPCs = net.ReadInt(16)
		MuR.Mode14Client.ReinforcementQueue = net.ReadInt(8)
	end)

	net.Receive("MuR.Mode14Objectives", function()
		local prevSuspects = MuR.Mode14Client.ObjectiveSuspectsComplete
		local prevCivilians = MuR.Mode14Client.ObjectiveCiviliansComplete

		local newSuspectsComplete = net.ReadBool()
		local newCiviliansComplete = net.ReadBool()
		local civiliansRemaining = net.ReadInt(8)

		if newSuspectsComplete and not prevSuspects then
			MuR.Mode14Client.ObjectiveSuspectsCompleteTime = CurTime()
		end

		if newCiviliansComplete and not prevCivilians then
			MuR.Mode14Client.ObjectiveCiviliansCompleteTime = CurTime()
		end

		MuR.Mode14Client.ObjectiveSuspectsComplete = newSuspectsComplete
		MuR.Mode14Client.ObjectiveCiviliansComplete = newCiviliansComplete
		MuR.Mode14Client.CiviliansRemaining = civiliansRemaining
	end)

    local notifications = {}
    net.Receive("MuR.Mode14Notification", function()
        local msg = net.ReadString()
        local money = net.ReadInt(16)
        table.insert(notifications, {
            msg = MuR.Language[msg] or msg, 
            money = money, 
            time = CurTime() + 4,
            fade = 0,
            yOff = He(20)
        })
    end)

    local radioIcon = Material("murdered/ror_report.png", "smooth")
    local promptAlpha = 0
    hook.Add("HUDPaint", "MuR.Mode14ReportPrompt", function()
        if MuR.GamemodeCount != 14 or not LocalPlayer():Alive() then 
            promptAlpha = 0
            return 
        end

        local tr = LocalPlayer():GetEyeTrace()
        local ent = tr.Entity
        local canReport = IsValid(ent) and (ent:GetClass() == "prop_ragdoll" and ent:LookupBone("ValveBiped.Bip01_Head1")) and tr.HitPos:DistToSqr(LocalPlayer():GetShootPos()) < 10000

        if canReport and not ent:GetNW2Bool("RoN_Reported") and not ent:GetNW2Bool("MuR.IsLivingRagdoll") then
            promptAlpha = Lerp(FrameTime() * 10, promptAlpha, 1)
        else
            promptAlpha = Lerp(FrameTime() * 10, promptAlpha, 0)
        end

        if promptAlpha > 0.01 then
            local x, y = ScrW() / 2, ScrH() / 2 + He(150)
            local alpha = promptAlpha * 255

            surface.SetMaterial(radioIcon)
            surface.SetDrawColor(255, 255, 255, alpha * 0.8)
            surface.DrawTexturedRect(x - We(24), y - He(65), We(48), He(48))

            local promptText = MuR.Language["mode14_report_body"]
            local parsed = markup.Parse(string.format("<font=RoN_Font_Medium><colour=255,0,0, %d>%s [</colour><colour=255,255,255, %d>E</colour><colour=255,0,0, %d>]</colour></font>", alpha, promptText, alpha, alpha))
            parsed:Draw(x, y, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, alpha)
        end

        local centerX = ScrW() / 2
        local startY = ScrH() / 2 + He(160)

        for i, v in ipairs(notifications) do
            local isExpired = v.time < CurTime()
            v.fade = Lerp(FrameTime() * 8, v.fade, isExpired and 0 or 1)
            v.yOff = Lerp(FrameTime() * 8, v.yOff, (i - 1) * He(25))

            if isExpired and v.fade < 0.01 then
                table.remove(notifications, i)
                continue
            end

            local alpha = v.fade * 255
            local moneyText = v.money > 0 and "+" .. v.money .. "$" or v.money .. "$"
            if v.money == 0 then moneyText = "" end

            local colorMoney = "255,255,255"
            local parsed = markup.Parse(string.format("<font=RoN_Font_Medium><colour=%s, %d>%s </colour><colour=255,0,0, %d>%s</colour></font>", colorMoney, alpha, moneyText, alpha, v.msg))
            parsed:Draw(centerX, startY + v.yOff, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, alpha)
        end
    end)

	local function DrawObjectives(x, y)
		local objAlpha = 200
		local gx, gy = x, y
		local ga = objAlpha

		local title = MuR.Language["mode14_objectives_title"] or "OBJECTIVES"
		draw.SimpleText(title, "MuR_Font3", gx, gy, Color(255, 255, 255, ga), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

		surface.SetDrawColor(255, 255, 255, ga * 0.6)
		surface.DrawRect(gx, gy + He(32), We(160), 2)

		local taskY = gy + He(40)

		local obj1Complete = MuR.Mode14Client.ObjectiveSuspectsComplete
		local obj1Text = "• " .. (MuR.Language["mode14_objective_suspects"] or "Objective")
		local obj1Alpha = obj1Complete and ga * 0.5 or ga
		local obj1W, obj1H = draw.SimpleText(obj1Text, "MuR_Font2", gx + We(5), taskY, Color(255, 255, 255, obj1Alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		if obj1Complete then
			surface.SetDrawColor(255, 255, 255, obj1Alpha * 0.8)
			surface.DrawRect(gx + We(5), taskY + math.floor(obj1H * 0.55), obj1W, 2)
		end

		taskY = taskY + He(25)

		local obj2Complete = MuR.Mode14Client.ObjectiveCiviliansComplete
		local obj2Text = "• " .. (MuR.Language["mode14_objective_civilians"] or "Objective")
		local obj2Alpha = obj2Complete and ga * 0.5 or ga
		local obj2W, obj2H = draw.SimpleText(obj2Text, "MuR_Font2", gx + We(5), taskY, Color(255, 255, 255, obj2Alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		if obj2Complete then
			surface.SetDrawColor(255, 255, 255, obj2Alpha * 0.8)
			surface.DrawRect(gx + We(5), taskY + math.floor(obj2H * 0.55), obj2W, 2)
		end
	end

	local function DrawReinforcementStatus(x, y)
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		if ply:Alive() then return end

		local queuePos = MuR.Mode14Client.ReinforcementQueue or 0

		if queuePos > 0 then
			local boxWidth = We(300)
			local boxHeight = He(60)
			local drawX, drawY = ScrW()/2 - boxWidth/2, He(150)

			draw.RoundedBox(4, drawX, drawY, boxWidth, boxHeight, THEME.bg)
			draw.SimpleText(MuR.Language["mode14_waiting_deployment"], "RoN_Font_Medium", drawX + boxWidth/2, drawY + He(15), THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText(MuR.Language["mode14_queue_position"] .. queuePos, "RoN_Font_Small", drawX + boxWidth/2, drawY + He(35), THEME.accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end
	end

	hook.Add("HUDPaint", "MuR.Mode14HUD", function()
		if MuR.GamemodeCount != 14 then return end

		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		DrawScanlines()

		if ply:Alive() then
			DrawCompass(ScrW()/2, He(10), We(400))
			DrawHealthArmor(We(20), ScrH() - He(60))
			DrawTeammates(We(20), He(150))
			DrawMissionTimer(ScrW()/2, He(50))
			DrawObjectives(We(20), He(10))
		else
			DrawReinforcementStatus()
		end
	end)
end
