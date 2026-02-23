MuR = MuR or {}
MuR.Drug = MuR.Drug or {}

local plyMeta = FindMetaTable("Player")
MuR.Drug.Active = MuR.Drug.Active or {}
MuR.Drug.Tolerance = MuR.Drug.Tolerance or {}
MuR.Drug.BaseStats = MuR.Drug.BaseStats or {}

util.AddNetworkString("MuR.SubstanceVisual")
util.AddNetworkString("MuR.SubstanceVisualClear")

local config = {
	tolerance_build = 0.18,
	tolerance_max = 0.75,
	tolerance_decay = 0.06,
	tolerance_interval = 3600
}

local function playCough(ply)
	if not IsValid(ply) then return end
	timer.Create("MuR.Cough." .. ply:EntIndex(), 1, math.random(4, 6), function()
		if not IsValid(ply) or !ply:Alive() then return end
		ply:EmitSound("ambient/voices/cough" .. math.random(1, 4) .. ".wav", 70, math.random(90, 110))
		ply:ViewPunch(Angle(math.random(2, 5), 0, 0))
	end)
end

local function getSpeedData(ply)
	return istable(ply.SpawnDataSpeed) and ply.SpawnDataSpeed or {120, 200, 110}
end

local substances = {
	meth = {
		name = "Methamphetamine",
		cat = "stimulant",
		dur = 240,
		vis = true,
		effects = {speed = 1.2, jump = 1.15},
		random = {damage = 0.05, twitch = 0.15, heart_attack = 0.005, nausea = 0.02},
		overdose_risk = 0.4
	},
	cocaine = {
		name = "Cocaine",
		cat = "stimulant",
		dur = 180,
		vis = true,
		effects = {speed = 1.1, health_regen = 0.8},
		random = {twitch = 0.08, heart_attack = 0.01, nausea = 0.03},
		overdose_risk = 0.5
	},
	ephedrine = {
		name = "Ephedrine",
		cat = "stimulant",
		dur = 200,
		effects = {speed = 1.05, health_regen = 0.2},
		random = {twitch = 0.02, nausea = 0.01}
	},
	lsd = {
		name = "LSD",
		cat = "hallucinogen",
		dur = 450,
		vis = true,
		random = {stumble = 0.05, hallucination = 0.2, convulsion = 0.01}
	},
	heroin = {
		name = "Heroin",
		cat = "depressant",
		dur = 350,
		vis = true,
		effects = {speed = 0.65, pain = 0.3, health_regen = -0.2},
		random = {collapse = 0.04, unconscious = 0.04, nausea = 0.1, breathing_issue = 0.08},
		withdrawal = {dur = 300, speed = 0.5, health_regen = -1.5}
	},
	cyanide = {
		name = "Cyanide",
		cat = "poison",
		dur = 45,
		vis = true,
		damage = 15,
		interval = 1.0,
		random = {breathing_issue = 0.2, unconscious = 0.1, convulsion = 0.1},
		on_start = function(ply)
			ply:EmitSound("vo/npc/male01/moan0" .. math.random(1, 5) .. ".wav")
			ply:ViewPunch(Angle(10, 0, 0))
		end
	},
	phosgene = {
		name = "Phosgene",
		cat = "poison",
		dur = 70,
		vis = true,
		damage = 6,
		interval = 1.8,
		random = {breathing_issue = 0.15, nausea = 0.1, cough = 0.25},
		on_start = function(ply) playCough(ply) end
	},
	chlorine = {
		name = "Chlorine",
		cat = "poison",
		dur = 60,
		vis = true,
		damage = 7,
		interval = 1.5,
		random = {breathing_issue = 0.18, nausea = 0.12, cough = 0.3, blindness = 0.05},
		on_start = function(ply) playCough(ply) end
	},
	sodium_azide = {
		name = "Sodium Azide",
		cat = "poison",
		dur = 40,
		damage = 8,
		interval = 1.0,
		random = {convulsion = 0.1, heart_attack = 0.05, headache = 0.2}
	},
	mustard_gas = {
		name = "Mustard Gas",
		cat = "poison",
		dur = 80,
		vis = true,
		damage = 5,
		interval = 2.0,
		random = {breathing_issue = 0.1, nausea = 0.1, skin_irritation = 0.2, cough = 0.2},
		on_start = function(ply) playCough(ply) end
	},
	ammonia = {
		name = "Ammonia",
		cat = "poison",
		dur = 35,
		vis = true,
		damage = 5,
		interval = 1.2,
		random = {breathing_issue = 0.2, blindness = 0.1, cough = 0.3},
		on_start = function(ply) playCough(ply) end
	},
	sarin = {
		name = "Sarin",
		cat = "nerve_agent",
		dur = 65,
		vis = true,
		damage = 6,
		interval = 0.8,
		move = 0.4,
		random = {unconscious = 0.1, convulsion = 0.15, breathing_issue = 0.2, blindness = 0.1, spasm = 0.2},
		on_start = function(ply)
			ply:ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 100), 0.5, 0)
			ply:EmitSound("ambient/voices/gasp1.wav")
		end
	},
	arsenic = {
		name = "Arsenic",
		cat = "poison",
		dur = 140,
		vis = true,
		damage = 3,
		interval = 2.5,
		random = {nausea = 0.15, stomach_pain = 0.15, weakness = 0.1}
	},
	barium = {
		name = "Barium",
		cat = "poison",
		dur = 100,
		damage = 4,
		interval = 2.0,
		random = {weakness = 0.25, breathing_issue = 0.1, convulsion = 0.05}
	},
	chloroform = {
		name = "Chloroform",
		cat = "sedative",
		dur = 70,
		vis = true,
		random = {unconscious = 0.5, stumble = 0.3, sleepiness = 0.5}
	},
	strychnine = {
		name = "Strychnine",
		cat = "poison",
		dur = 90,
		vis = true,
		damage = 5,
		interval = 1.5,
		random = {convulsion = 0.25, spasm = 0.2, pain = 0.1}
	},
	ricin = {
		name = "Ricin",
		cat = "poison",
		dur = 350,
		vis = true,
		damage = 2,
		interval = 4.0,
		random = {nausea = 0.1, fever = 0.1, collapse = 0.02}
	},
	midazolam = {
		name = "Midazolam",
		cat = "sedative",
		dur = 140,
		vis = true,
		random = {unconscious = 0.25, stumble = 0.35, sleepiness = 0.5}
	},
	ketamine = {
		name = "Ketamine",
		cat = "dissociative",
		dur = 120,
		vis = true,
		random = {hallucination = 0.15, stumble = 0.3, unconscious = 0.08}
	},
	ghb = {
		name = "GHB",
		cat = "sedative",
		dur = 100,
		vis = true,
		random = {unconscious = 0.3, stumble = 0.25}
	},
	lead = {
		name = "Lead",
		cat = "heavy_metal",
		dur = 700,
		vis = true,
		damage = 1,
		interval = 8.0,
		random = {weakness = 0.1, confusion = 0.1, stomach_pain = 0.05}
	},
	mercury = {
		name = "Mercury",
		cat = "heavy_metal",
		dur = 600,
		vis = true,
		damage = 1.5,
		interval = 6.0,
		random = {twitch = 0.15, confusion = 0.1, madness = 0.05}
	},
	picric_acid = {
		name = "Picric Acid",
		cat = "poison",
		dur = 45,
		damage = 6,
		interval = 1.5,
		random = {skin_irritation = 0.25, nausea = 0.15}
	},
	oxalic_acid = {
		name = "Oxalic Acid",
		cat = "poison",
		dur = 55,
		damage = 5,
		interval = 2.0,
		random = {kidney_pain = 0.15, weakness = 0.1}
	},
	nitroglycerin = {
		name = "Nitroglycerin",
		cat = "explosive_med",
		dur = 40,
		vis = true,
		effects = {speed = 0.85},
		random = {heart_attack = 0.08, headache = 0.4}
	},
	thermite = {
		name = "Thermite",
		cat = "burn",
		dur = 12,
		vis = true,
		damage = 25,
		interval = 1.0,
		random = {fire = 1.0}
	},
	white_phosphorus = {
		name = "White Phosphorus",
		cat = "burn",
		dur = 18,
		vis = true,
		damage = 18,
		interval = 1.0,
		random = {fire = 1.0, smoke = 0.6, skin_irritation = 0.5}
	},
	flash_powder = {
		name = "Flash Powder",
		cat = "irritant",
		dur = 12,
		random = {blindness = 1.0, confusion = 0.6}
	},
	acid = {
		name = "Acid",
		cat = "corrosive",
		dur = 25,
		damage = 10,
		interval = 1.0,
		random = {skin_irritation = 1.0}
	}
}

timer.Create("MuR.ToleranceDecay", config.tolerance_interval, 0, function()
	for steamid, data in pairs(MuR.Drug.Tolerance) do
		for id, tol in pairs(data) do
			data[id] = math.max(0, tol - config.tolerance_decay)
			if data[id] <= 0.01 then data[id] = nil end
		end
	end
end)

local function saveBase(ply)
	if not IsValid(ply) then return end
	MuR.Drug.BaseStats[ply] = {
		walk = getSpeedData(ply)[1],
		run = getSpeedData(ply)[2],
		jump = getSpeedData(ply)[3]
	}
end

hook.Add("PlayerInitialSpawn", "MuR.Drug.SaveBase", saveBase)
hook.Add("PlayerSpawn", "MuR.Drug.SaveBase", saveBase)

function MuR.Drug:GetTolerance(ply, id)
	if not IsValid(ply) then return 0 end
	local steam = ply:SteamID64()
	MuR.Drug.Tolerance[steam] = MuR.Drug.Tolerance[steam] or {}
	return math.Clamp(MuR.Drug.Tolerance[steam][id] or 0, 0, config.tolerance_max)
end

function MuR.Drug:AddTolerance(ply, id)
	if not IsValid(ply) then return end
	local steam = ply:SteamID64()
	MuR.Drug.Tolerance[steam] = MuR.Drug.Tolerance[steam] or {}
	local old = MuR.Drug.Tolerance[steam][id] or 0
	MuR.Drug.Tolerance[steam][id] = math.min(old + config.tolerance_build, config.tolerance_max)
end

local function checkOverdose(ply)
	if not IsValid(ply) then return end
	local active = MuR.Drug.Active[ply] or {}
	local count = table.Count(active)
	local tol_high = false
	local stim = false
	local dep = false

	for id,_ in pairs(active) do
		local sub = substances[id]
		if sub and MuR.Drug:GetTolerance(ply, id) > 0.7 then tol_high = true end
		if sub.cat == "stimulant" then stim = true end
		if sub.cat == "depressant" then dep = true end
	end

	if count >= 3 or (tol_high and stim and dep) then
		ply:SetNW2Bool("IsUnconscious", true)
		ply:StartRagdolling(0, 60)
		ply:TakeDamage(40, ply, ply)
		timer.Simple(20, function()
			if IsValid(ply) and ply:GetRD() then
				ply:SetNW2Bool("IsUnconscious", false)
			end
		end)
	end
end

function MuR.Drug:Apply(ply, id, intensity)
	intensity = intensity or 1
	if not IsValid(ply) or not substances[id] then return end

	local sub = substances[id]
	if sub.cat == "poison" or sub.cat == "nerve_agent" or sub.cat == "irritant" then
		local gasProtection = ply.GetGasProtectionLevel and ply:GetGasProtectionLevel() or 0
		if gasProtection >= 1.0 then
			return 
		elseif gasProtection > 0 then
			intensity = intensity * (1 - gasProtection) 
		end
	end

	local tol = self:GetTolerance(ply, id)
	local eff = intensity * (1 - tol)
	if eff < 0.1 then 
		return 
	end

	self:AddTolerance(ply, id)
	MuR.Drug.Active[ply] = MuR.Drug.Active[ply] or {}

	local isNew = MuR.Drug.Active[ply][id] == nil
	MuR.Drug.Active[ply][id] = {endTime = CurTime() + substances[id].dur * eff, intensity = eff}

	if isNew and substances[id].on_start then
		substances[id].on_start(ply)
	end

	if substances[id].vis then
		net.Start("MuR.SubstanceVisual")
			net.WriteString(id)
			net.WriteFloat(substances[id].dur * eff)
			net.WriteFloat(eff)
		net.Send(ply)
	end

	local base = MuR.Drug.BaseStats[ply] or {walk = getSpeedData(ply)[1], run = getSpeedData(ply)[2], jump = getSpeedData(ply)[3]}
	if substances[id].effects then
		if substances[id].effects.speed then
			ply:SetWalkSpeed(base.walk * substances[id].effects.speed)
			ply:SetRunSpeed(base.run * substances[id].effects.speed)
		end
		if substances[id].effects.jump then 
			ply:SetJumpPower(base.jump * substances[id].effects.jump) 
		end
	end

	timer.Create("MuR.Drug.Tick." .. ply:EntIndex() .. "." .. id, substances[id].interval or 1, substances[id].dur * eff, function()
		if not IsValid(ply) or not ply:Alive() then return end
		local sub = substances[id]
		if sub.random then
			if sub.random.damage and math.random() < sub.random.damage then ply:TakeDamage(4 * eff, ply, ply) end
			if sub.random.heart_attack and math.random() < sub.random.heart_attack then
				ply:TakeDamage(15 * eff, ply, ply)
				ply:ViewPunch(Angle(10, 0, 0))
				ply:SetNW2Bool("IsUnconscious", true)
				ply:StartRagdolling(0, 10)
				timer.Simple(5, function() if IsValid(ply) then ply:SetNW2Bool("IsUnconscious", false) end end)
			end
			if sub.random.nausea and math.random() < sub.random.nausea then
				ply:TakeDamage(2 * eff, ply, ply)
				ply:ViewPunch(AngleRand() * 2)
				ply:EmitSound("npc/zombie/zombie_pain" .. math.random(1, 6) .. ".wav", 60, 100)
			end
			if sub.random.convulsion and math.random() < sub.random.convulsion then
				ply:StartRagdolling(0, 8)
				ply:ViewPunch(AngleRand() * 3)
			end
			if sub.random.breathing_issue and math.random() < sub.random.breathing_issue then
				ply:SetWalkSpeed(ply:GetWalkSpeed() * 0.8)
				ply:SetRunSpeed(ply:GetRunSpeed() * 0.8)
				ply:TakeDamage(3 * eff, ply, ply)
				ply:EmitSound("npc/zombie/zombie_voice_idle" .. math.random(1, 10) .. ".wav", 60, 120)
			end
			if sub.random.hallucination and math.random() < sub.random.hallucination then
				ply:ViewPunch(AngleRand() * 4)
				ply:StartRagdolling(0, 2)
			end
			if sub.random.collapse and math.random() < sub.random.collapse then
				ply:StartRagdolling(0, 20)
			end
			if sub.random.unconscious and math.random() < sub.random.unconscious then
				ply:SetNW2Bool("IsUnconscious", true)
				ply:StartRagdolling(0, 40)
				timer.Simple(12, function() if IsValid(ply) then ply:SetNW2Bool("IsUnconscious", false) end end)
			end
			if sub.random.stumble and math.random() < sub.random.stumble then
				ply:StartRagdolling(0, 3)
			end
			if sub.random.blindness and math.random() < sub.random.blindness then
				ply:ScreenFade(SCREENFADE.IN, color_white, 1, 0.5)
			end
			if sub.random.confusion and math.random() < sub.random.confusion then
				ply:ViewPunch(AngleRand() * 10)
			end
			if sub.random.weakness and math.random() < sub.random.weakness then
				ply:SetWalkSpeed(ply:GetWalkSpeed() * 0.7)
				ply:SetRunSpeed(ply:GetRunSpeed() * 0.7)
			end
			if sub.random.spasm and math.random() < sub.random.spasm then
				ply:ViewPunch(Angle(math.random(-10, 10), math.random(-10, 10), 0))
			end
			if sub.random.skin_irritation and math.random() < sub.random.skin_irritation then
				ply:TakeDamage(1 * eff, ply, ply)
			end
			if sub.random.fire and math.random() < sub.random.fire then
				ply:Ignite(2)
			end
			if sub.random.smoke and math.random() < sub.random.smoke then
				local ed = EffectData()
				ed:SetOrigin(ply:GetPos())
				util.Effect("Smoke", ed)
			end
			if sub.random.kidney_pain and math.random() < sub.random.kidney_pain then
				ply:TakeDamage(5 * eff, ply, ply)
				ply:EmitSound("vo/npc/male01/pain0" .. math.random(1, 9) .. ".wav")
			end
			if sub.random.stomach_pain and math.random() < sub.random.stomach_pain then
				ply:TakeDamage(3 * eff, ply, ply)
				ply:ViewPunch(Angle(5, 0, 0))
			end
			if sub.random.fever and math.random() < sub.random.fever then
				ply:ScreenFade(SCREENFADE.IN, Color(255, 100, 100, 50), 1, 0)
			end
			if sub.random.sleepiness and math.random() < sub.random.sleepiness then
				ply:ScreenFade(SCREENFADE.IN, color_black, 2, 1)
			end
			if sub.random.headache and math.random() < sub.random.headache then
				ply:ViewPunch(Angle(math.random(-2, 2), math.random(-2, 2), 0))
			end
			if sub.random.cough and math.random() < sub.random.cough then
				playCough(ply)
			end
			if sub.random.madness and math.random() < sub.random.madness then
				ply:EmitSound("npc/zombie/zombie_voice_idle" .. math.random(1, 14) .. ".wav", 60, 120)
				ply:ViewPunch(AngleRand() * 5)
			end
		end
		if sub.damage then
			ply:TakeDamage(sub.damage * eff, ply, ply)
		end
	end)

	checkOverdose(ply)

	timer.Simple(substances[id].dur * eff, function()
		if IsValid(ply) then self:Remove(ply, id) end
	end)
end

function MuR.Drug:Remove(ply, id)
	if not IsValid(ply) or not MuR.Drug.Active[ply] or not MuR.Drug.Active[ply][id] then return end

	MuR.Drug.Active[ply][id] = nil
	local timerName = "MuR.Drug.Tick." .. ply:EntIndex() .. "." .. id
	if timer.Exists(timerName) then
		timer.Remove(timerName)
	end

	if table.Count(MuR.Drug.Active[ply] or {}) == 0 then
		local base = MuR.Drug.BaseStats[ply]
		if base then
			ply:SetWalkSpeed(base.walk)
			ply:SetRunSpeed(base.run)
			ply:SetJumpPower(base.jump)
		end
		MuR.Drug.Active[ply] = nil
	end
end

local function removeAllDrugTimers(ply)
	if not IsValid(ply) then return end

	for id, _ in pairs(substances) do
		local timerName = "MuR.Drug.Tick." .. ply:EntIndex() .. "." .. id
		if timer.Exists(timerName) then
			timer.Remove(timerName)
		end
	end
end

local function fullReset(ply)
	if not IsValid(ply) then return end

	MuR.Drug.Active[ply] = nil
	removeAllDrugTimers(ply)

	local base = MuR.Drug.BaseStats[ply]
	if base then
		ply:SetWalkSpeed(base.walk)
		ply:SetRunSpeed(base.run)
		ply:SetJumpPower(base.jump)
	end

	net.Start("MuR.SubstanceVisualClear")
	net.Send(ply)
end

hook.Add("PlayerDeath", "MuR.Drug.Reset", fullReset)
hook.Add("PlayerSpawn", "MuR.Drug.Reset", fullReset)
hook.Add("PlayerDisconnected", "MuR.Drug.Reset", fullReset)

MuR.SubstanceSystem = MuR.SubstanceSystem or {}

function MuR.SubstanceSystem:ApplySubstance(ply, substanceID, intensity)
	MuR.Drug:Apply(ply, substanceID, intensity or 1)
end

function MuR.SubstanceSystem:ApplyPoisonFromCloud(ply, substanceID, ow, intensity)
	MuR.Drug:Apply(ply, substanceID, intensity or 1)
end

function MuR.SubstanceSystem:RemoveSubstance(ply, substanceID)
	MuR.Drug:Remove(ply, substanceID)
end

function MuR.SubstanceSystem:HasSubstance(ply, substanceID)
	return MuR.Drug.Active[ply] and MuR.Drug.Active[ply][substanceID] ~= nil
end

function MuR.SubstanceSystem:CurePoison(ply)
	for id, sub in pairs(substances) do
		if sub.cat == "poison" or sub.cat == "nerve_agent" or sub.cat == "heavy_metal" then
			MuR.Drug:Remove(ply, id)
		end
	end
end

function MuR.SubstanceSystem:Detoxify(ply)
	for id,_ in pairs(substances) do
		MuR.Drug:Remove(ply, id)
	end
end

function MuR.SubstanceSystem:GetSubstance(id)
	return substances[id]
end