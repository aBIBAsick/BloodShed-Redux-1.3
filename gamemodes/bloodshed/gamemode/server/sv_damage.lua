local meta = FindMetaTable("Player")
local meta2 = FindMetaTable("Entity")

function meta2:BloodTrailBone(bone, seconds)
    local body = self:IsPlayer() and IsValid(self:GetRD()) and self:GetRD() or self
    local n = Vector(0.5,math.Rand(-1,1),0)
    local str = self:EntIndex().."BleedingEntBone_"..bone
	self.LastBleedBone = bone
    timer.Create(str, 0.18, math.ceil(seconds*5.555), function()
        if !IsValid(body) or !body:LookupBone(bone) then
            timer.Remove(str)
            return
        end
        local effectdata = EffectData()
		local pos, ang = body:GetBonePosition(body:LookupBone(bone))
		local normal = (n+ang:Up()):GetNormalized()
        effectdata:SetOrigin(pos)
        effectdata:SetNormal(normal)
        effectdata:SetMagnitude(1)
        effectdata:SetRadius(0)
        effectdata:SetFlags(2)
        effectdata:SetEntity(body)
        util.Effect("mur_blood_splatter_effect", effectdata)
    end)
end

function meta2:GetBloodTrails(pattern)
	local tab = {}
	for i=0, self:GetBoneCount()-1 do
		local bone = self:GetBoneName(i)
		if !timer.Exists(self:EntIndex().."BleedingEntBone_"..bone) then continue end
		tab[#tab+1] = bone
		if pattern and string.match(bone, pattern) then return true end
		if pattern == "remove" then
			timer.Remove(self:EntIndex().."BleedingEntBone_"..bone)
		end
	end
	return !pattern and tab or false
end

function meta:ApplyConcussion(dmg, duration, intensity)
	if math.random(1, 100) > 30 then return end
	duration = duration or 2
	intensity = intensity or 1
	if self:GetNW2Float("ConcussionEnd", 0) > CurTime() then
		local left = self:GetNW2Float("ConcussionEnd") - CurTime()
		duration = duration + left * 0.4
		intensity = math.min(intensity + self:GetNW2Float("ConcussionIntensity", 0) * 0.5, 2)
	end
	self:SetNW2Float("ConcussionEnd", CurTime() + duration)
	self:SetNW2Float("ConcussionIntensity", intensity)
	MuR:GiveMessage2("concussion_hit", self)
end

function meta:ApplyInternalBleed(duration, rate)
	duration = duration or 12
	rate = rate or 3
	if self:GetNW2Float("InternalBleedEnd", 0) > CurTime() then
		self:SetNW2Float("InternalBleedEnd", math.max(self:GetNW2Float("InternalBleedEnd"), CurTime() + duration * 0.5))
		return
	end
	self:SetNW2Float("InternalBleedEnd", CurTime() + duration)
	local name = "MuR_InternalBleed_" .. self:EntIndex()
	timer.Create(name, rate, 0, function()
		if not IsValid(self) then timer.Remove(name) return end
		if CurTime() > self:GetNW2Float("InternalBleedEnd") then timer.Remove(name) return end
		if self:Alive() then
			self:DamagePlayerSystem("blood")
			if math.random(1,3) == 1 then self:DamagePlayerSystem("blood") end
		else
			timer.Remove(name)
		end
	end)
	MuR:GiveMessage2("internal_hit", self)
end

function meta:TriggerArtery(source)
	source = source or "Generic"

	local arteryKey = source
	if source == "Heart" then
		arteryKey = "Heart"
	elseif source == "Neck" or source == "Carotid Artery" then
		arteryKey = "Neck"
	elseif isstring(source) and string.find(source, "Brachial", 1, true) then
		arteryKey = "Arm"
	elseif isstring(source) and string.find(source, "Femoral", 1, true) then
		arteryKey = "Leg"
	elseif source ~= "Generic" then
		arteryKey = "Generic"
	end

	self:SetNW2Bool("Artery_" .. arteryKey, true)

	if not self:GetNW2Bool("HardBleed") then
		self:SetNW2Bool("HardBleed", true)
		MuR:GiveMessage2("artery_hit", self)
	end
end

function meta:CheckShock()
	local previous = self:GetNW2Int("ShockLevel", 0)
	local current = self:RefreshShockLevel()
	if current >= 2 and previous < 2 then
		self:ApplyConcussion(nil, 2.5, 1.2)
	end
end

function meta:ApplyCoordinationLoss(duration, severity)
	duration = duration or 8
	severity = severity or 1
	if self:GetNW2Float("CoordinationEnd", 0) > CurTime() then
		local left = self:GetNW2Float("CoordinationEnd") - CurTime()
		duration = duration + left * 0.3
		severity = math.min(severity + self:GetNW2Float("CoordinationSeverity", 0) * 0.4, 2)
	end
	self:SetNW2Float("CoordinationEnd", CurTime() + duration)
	self:SetNW2Float("CoordinationSeverity", severity)
	MuR:GiveMessage2("coordination_loss", self)
end

function meta:ApplyUnconsciousness(duration)
	duration = duration or 4
	if self:GetNW2Float("UnconsciousEnd", 0) > CurTime() then
		self:SetNW2Float("UnconsciousEnd", math.max(self:GetNW2Float("UnconsciousEnd"), CurTime() + duration * 0.7))
		return
	end
	if self:GetNW2Float("AdrenalineEnd", 0) > CurTime() then return end
	self:SetNW2Bool("IsUnconscious", true)
	self:SetNW2Float("UnconsciousEnd", CurTime() + duration)
	self.UnconsciousStart = CurTime()
	self.IsRagStanding = false

	if isstring(self.LastVoiceLine) then
		if IsValid(self:GetRD()) then
			self:GetRD():StopSound(self.LastVoiceLine)
		end
		self:StopSound(self.LastVoiceLine)
		self.LastVoiceLine = nil
	end

	if not IsValid(self:GetRD()) then
		self:StartRagdolling(0, 0)
	end

	MuR:GiveMessage2("unconscious_state", self)
	timer.Simple(duration, function()
		if IsValid(self) then
			self:WakeUpFromUnconsciousness()
		end
	end)
end

function meta:WakeUpFromUnconsciousness()
	self:SetNW2Bool("IsUnconscious", false)
	self:SetNW2Float("UnconsciousEnd", 0)
	self:SetNW2Int("ConsciousLevel", math.max(self:GetNW2Int("ConsciousLevel", 0), 1))
	self.VoiceDelay = 0

	MuR:GiveMessage2("wake_up", self)
	MuR:PlaySoundOnClient("gasp/focus_gasp_0" .. math.random(1, 6) .. ".wav", self)
end

function meta:ResetCriticalOrgans()
	self.CriticalOrganStates = {}
	self.OrganDamageStages = {}
	self.ShockPassoutAt = nil

	local keys = {"brain", "neck", "heart", "carotid", "brachial", "femoral", "liver", "lungs"}
	for _, key in ipairs(keys) do
		self:SetNW2Int("OrganDamage_" .. key, 0)
	end

	local arteryKeys = {
		"Artery_Neck", "Artery_Heart", "Artery_Arm", "Artery_Leg", "Artery_Generic",
		"Artery_neck", "Artery_heart", "Artery_arm", "Artery_leg"
	}
	for _, key in ipairs(arteryKeys) do
		self:SetNW2Bool(key, false)
	end

	self:SetNW2Int("ShockLevel", 0)
	self:SetNW2Int("ConsciousLevel", 0)
end

function meta:SetOrganDamageStage(key, stage)
	stage = math.max(stage or 0, 0)
	self.OrganDamageStages = self.OrganDamageStages or {}

	local current = self.OrganDamageStages[key] or 0
	if stage > current then
		self.OrganDamageStages[key] = stage
		self:SetNW2Int("OrganDamage_" .. key, stage)
	end

	return self.OrganDamageStages[key] or 0
end

function meta:GetOrganDamageStage(key)
	self.OrganDamageStages = self.OrganDamageStages or {}
	return self.OrganDamageStages[key] or 0
end

function meta:ApplyCriticalOrganState(key, data)
	if self:IsRoleWithoutOrgans() then return end

	local now = CurTime()
	local states = self.CriticalOrganStates or {}
	local state = states[key] or {
		key = key,
		startedAt = now
	}

	if data.deathIn then
		local deathAt = now + data.deathIn
		state.deathAt = state.deathAt and math.min(state.deathAt, deathAt) or deathAt
	end

	if data.passoutIn ~= nil then
		local passoutAt = now + data.passoutIn
		state.passoutAt = state.passoutAt and math.min(state.passoutAt, passoutAt) or passoutAt
	end

	state.interval = data.interval or state.interval or 1
	state.nextTick = math.min(state.nextTick or now, now)
	state.damageType = data.damageType or state.damageType or DMG_DIRECT
	state.severity = math.max(state.severity or 0, data.severity or 1)
	state.unconsciousFor = math.max(state.unconsciousFor or 0, data.unconsciousFor or 0)
	state.injuryStage = math.max(state.injuryStage or 0, data.injuryStage or 1)
	state.shockWeight = math.max(state.shockWeight or 0, data.shockWeight or 0.8)

	if IsValid(data.attacker) then state.attacker = data.attacker end
	if IsValid(data.inflictor) then state.inflictor = data.inflictor end

	states[key] = state
	self.CriticalOrganStates = states
	self:SetOrganDamageStage(key, state.injuryStage)

	return state
end

function meta:RefreshShockLevel()
	if not self:Alive() then return 0 end

	local hpFrac = self:Health() / math.max(self:GetMaxHealth(), 1)
	local bleedLevel = self:GetNW2Float("BleedLevel", 0)
	local toxin = self:GetNW2Float("ToxinLevel", 0)
	local load = 0

	if hpFrac < 0.85 then
		load = load + (0.85 - hpFrac) * 3.8
	end

	if self:GetNW2Bool("HardBleed") then
		load = load + 2.2
	elseif bleedLevel > 0 then
		load = load + bleedLevel * 0.7
	end

	if self:GetNW2Float("InternalBleedEnd", 0) > CurTime() then
		load = load + 1.15
	end
	if self:GetNW2Bool("Pneumothorax") then
		load = load + 1.05
	end
	if self:GetNW2Bool("PelvisFracture") then
		load = load + 0.65
	end
	if self:GetNW2Bool("RibFracture") then
		load = load + 0.45
	end
	if self:GetNW2Bool("SpineBroken") then
		load = load + 1.2
	end
	if toxin > 0 then
		load = load + math.min(toxin / 3.5, 1.4)
	end

	local states = self.CriticalOrganStates or {}
	for _, state in pairs(states) do
		load = load + (state.shockWeight or 0.8) * math.max(state.injuryStage or 1, 1) * 0.55
	end

	local stage = 0
	if load >= 5.4 then
		stage = 3
	elseif load >= 3.6 then
		stage = 2
	elseif load >= 1.9 then
		stage = 1
	end

	local lastStage = self:GetNW2Int("ShockLevel", 0)
	self:SetNW2Int("ShockLevel", stage)
	self:SetNW2Bool("ShockState", stage >= 2)

	if stage >= 2 and stage > lastStage then
		MuR:GiveMessage2("shock_state", self)
	end

	return stage
end

function meta:RefreshConsciousLevel()
	if not self:Alive() then return 0 end
	if self:GetNW2Bool("IsUnconscious", false) then
		self:SetNW2Int("ConsciousLevel", 3)
		return 3
	end

	local hpFrac = self:Health() / math.max(self:GetMaxHealth(), 1)
	local shockStage = self:GetNW2Int("ShockLevel", 0)
	local consciousnessLoad = shockStage * 1.15
	local concussionEnd = self:GetNW2Float("ConcussionEnd", 0)

	if hpFrac < 0.55 then
		consciousnessLoad = consciousnessLoad + (0.55 - hpFrac) * 4
	end

	if self:GetNW2Bool("HardBleed") then
		consciousnessLoad = consciousnessLoad + 1.15
	else
		consciousnessLoad = consciousnessLoad + self:GetNW2Float("BleedLevel", 0) * 0.35
	end

	if concussionEnd > CurTime() then
		consciousnessLoad = consciousnessLoad + 0.8 + self:GetNW2Float("ConcussionIntensity", 0) * 0.45
	end

	if self:GetNW2Float("Stamina", 100) <= 20 then
		consciousnessLoad = consciousnessLoad + 0.7
	end

	consciousnessLoad = consciousnessLoad + math.min(self:GetNW2Float("ToxinLevel", 0) / 5, 1.2)
	consciousnessLoad = consciousnessLoad + self:GetOrganDamageStage("brain") * 1.35
	consciousnessLoad = consciousnessLoad + self:GetOrganDamageStage("carotid") * 0.9
	consciousnessLoad = consciousnessLoad + self:GetOrganDamageStage("heart") * 0.55
	consciousnessLoad = consciousnessLoad + math.max(self:GetOrganDamageStage("lungs") - 1, 0) * 0.65

	local stage = 0
	if consciousnessLoad >= 4.6 then
		stage = 2
	elseif consciousnessLoad >= 2.3 then
		stage = 1
	end

	self:SetNW2Int("ConsciousLevel", stage)
	return stage
end

function meta:DieFromCriticalOrgan(state)
	if not self:Alive() then return end

	local attacker = IsValid(state and state.attacker) and state.attacker or game.GetWorld()
	local inflictor = IsValid(state and state.inflictor) and state.inflictor or attacker
	local dmg = DamageInfo()
	dmg:SetAttacker(attacker)
	dmg:SetInflictor(inflictor)
	dmg:SetDamageType(state and state.damageType or DMG_DIRECT)
	dmg:SetDamage(math.max(self:Health() + 25, 50))
	dmg:SetDamagePosition(self:WorldSpaceCenter())
	self:TakeDamageInfo(dmg)

	if self:Alive() then
		self:Kill()
	end
end

local function shortenTimeline(base, dmg, minValue, scale)
	return math.Clamp(base - dmg * scale, minValue, base)
end

local function processCriticalOrgans(ply)
	if not ply:Alive() then return end

	local states = ply.CriticalOrganStates
	if not states then return end

	local now = CurTime()
	for key, state in pairs(states) do
		if now < (state.nextTick or 0) then continue end
		state.nextTick = now + (state.interval or 1)

		if key == "brain" then
			local stage = math.max(state.injuryStage or 1, 1)
			ply:SetNW2Float("Stamina", math.max(ply:GetNW2Float("Stamina", 100) - (4 + stage * 3), 0))
			ply:ApplyCoordinationLoss(3 + stage, 0.7 + stage * 0.2)

			if state.passoutAt and now >= state.passoutAt and not state.passoutApplied then
				state.passoutApplied = true
				ply:ApplyUnconsciousness(math.max(state.unconsciousFor or 18, 8))
			end

			if state.deathAt and now >= state.deathAt then
				ply:DieFromCriticalOrgan(state)
				return
			end
		elseif key == "neck" then
			local stage = math.max(state.injuryStage or 1, 1)
			ply:SetNW2Float("Stamina", math.max(ply:GetNW2Float("Stamina", 100) - (3 + stage * 2), 0))
			ply:ApplyCoordinationLoss(2 + stage, 0.35 + stage * 0.2)
			if math.random() < (0.05 + stage * 0.05) then
				ply:ApplyConcussion(nil, 2, 0.5)
			end

			if state.passoutAt and now >= state.passoutAt and not state.passoutApplied then
				state.passoutApplied = true
				ply:ApplyUnconsciousness(math.max(state.unconsciousFor or 12, 6))
			end

			if state.deathAt and now >= state.deathAt then
				ply:DieFromCriticalOrgan(state)
				return
			end
		elseif key == "heart" then
			local stage = math.max(state.injuryStage or 1, 1)
			if stage >= 2 then
				ply:SetNW2Bool("HardBleed", true)
			end
			if stage >= 2 or math.random() < 0.45 then
				ply:DamagePlayerSystem("blood")
			end
			ply:SetNW2Float("Stamina", 0)
			ply:ApplyCoordinationLoss(2 + stage, 0.45 + stage * 0.2)

			if state.passoutAt and now >= state.passoutAt and not state.passoutApplied then
				state.passoutApplied = true
				ply:ApplyUnconsciousness(math.max(state.unconsciousFor or 14, 8))
			end

			if state.deathAt and now >= state.deathAt then
				ply:DieFromCriticalOrgan(state)
				return
			end
		elseif key == "carotid" then
			local stage = math.max(state.injuryStage or 2, 2)
			ply:SetNW2Bool("HardBleed", true)
			ply:DamagePlayerSystem("blood")
			if stage >= 3 or math.random() < 0.45 then
				ply:DamagePlayerSystem("blood")
			end
			ply:SetNW2Float("Stamina", math.max(ply:GetNW2Float("Stamina", 100) - (10 + stage * 4), 0))

			if state.passoutAt and now >= state.passoutAt and not state.passoutApplied then
				state.passoutApplied = true
				ply:ApplyUnconsciousness(math.max(state.unconsciousFor or 16, 8))
			end

			if state.deathAt and now >= state.deathAt then
				ply:DieFromCriticalOrgan(state)
				return
			end
		elseif key == "brachial" then
			local stage = math.max(state.injuryStage or 1, 1)
			if stage >= 2 or math.random() < 0.55 then
				ply:DamagePlayerSystem("blood")
			end
			ply:SetNW2Float("Stamina", math.max(ply:GetNW2Float("Stamina", 100) - (3 + stage * 2), 0))

			if state.passoutAt and now >= state.passoutAt and not state.passoutApplied then
				state.passoutApplied = true
				ply:ApplyUnconsciousness(math.max(state.unconsciousFor or 10, 6))
			end

			if state.deathAt and now >= state.deathAt then
				ply:DieFromCriticalOrgan(state)
				return
			end
		elseif key == "femoral" then
			local stage = math.max(state.injuryStage or 2, 2)
			ply:SetNW2Bool("HardBleed", true)
			ply:DamagePlayerSystem("blood")
			if stage >= 3 or math.random() < 0.35 then
				ply:DamagePlayerSystem("blood")
			end
			ply:SetNW2Float("Stamina", math.max(ply:GetNW2Float("Stamina", 100) - (8 + stage * 2), 0))

			if state.passoutAt and now >= state.passoutAt and not state.passoutApplied then
				state.passoutApplied = true
				ply:ApplyUnconsciousness(math.max(state.unconsciousFor or 14, 8))
			end

			if state.deathAt and now >= state.deathAt then
				ply:DieFromCriticalOrgan(state)
				return
			end
		elseif key == "liver" then
			local stage = math.max(state.injuryStage or 1, 1)
			if math.random() < (0.2 + stage * 0.18) then
				ply:DamagePlayerSystem("blood")
			end
			ply:SetNW2Float("ToxinLevel", math.min(ply:GetNW2Float("ToxinLevel", 0) + (0.08 + stage * 0.08), 10))
			ply:ApplyCoordinationLoss(1 + stage, 0.2 + stage * 0.12)

			if state.passoutAt and now >= state.passoutAt and not state.passoutApplied then
				state.passoutApplied = true
				ply:ApplyUnconsciousness(math.max(state.unconsciousFor or 16, 8))
			end

			if state.deathAt and now >= state.deathAt then
				ply:DieFromCriticalOrgan(state)
				return
			end
		elseif key == "lungs" then
			local hits = state.hits or 1
			local stage = math.max(state.injuryStage or hits, 1)
			ply:SetNW2Bool("Pneumothorax", true)
			ply:SetNW2Float("Stamina", math.max(ply:GetNW2Float("Stamina", 100) - (2 + hits * 2 + stage * 2), 0))

			if stage >= 2 or hits >= 2 then
				if math.random() < (0.15 + stage * 0.15) then
					ply:DamagePlayerSystem("blood")
				end
				ply:ApplyCoordinationLoss(2 + stage, 0.3 + stage * 0.15)
			end

			if state.passoutAt and now >= state.passoutAt and not state.passoutApplied then
				state.passoutApplied = true
				ply:ApplyUnconsciousness(math.max(state.unconsciousFor or 12, 8))
			end

			if state.deathAt and now >= state.deathAt then
				ply:DieFromCriticalOrgan(state)
				return
			end
		end
	end
end

local function processBodyState(ply)
	if not ply:Alive() then return end
	if (ply.NextBodyStateTick or 0) > CurTime() then return end
	ply.NextBodyStateTick = CurTime() + 1

	local shockStage = ply:RefreshShockLevel()
	local consciousStage = ply:RefreshConsciousLevel()

	if shockStage == 1 then
		ply:SetNW2Float("Stamina", math.max(ply:GetNW2Float("Stamina", 100) - 2, 0))
		if math.random() < 0.25 then
			ply:ApplyCoordinationLoss(1.5, 0.18)
		end
	elseif shockStage == 2 then
		ply:SetNW2Float("Stamina", math.max(ply:GetNW2Float("Stamina", 100) - 4, 0))
		ply:ApplyCoordinationLoss(2.5, 0.32)
	elseif shockStage >= 3 then
		ply:SetNW2Float("Stamina", math.max(ply:GetNW2Float("Stamina", 100) - 7, 0))
		ply:ApplyCoordinationLoss(4, 0.55)

		if not ply:GetNW2Bool("IsUnconscious", false) then
			ply.ShockPassoutAt = ply.ShockPassoutAt or (CurTime() + math.Rand(10, 20))
			if CurTime() >= ply.ShockPassoutAt then
				ply:ApplyUnconsciousness(math.Rand(6, 12))
				ply.ShockPassoutAt = CurTime() + math.Rand(18, 30)
			end
		end
	else
		ply.ShockPassoutAt = nil
	end

	if consciousStage == 1 then
		if math.random() < 0.2 then
			ply:ApplyCoordinationLoss(1.5, 0.2)
		end
	elseif consciousStage >= 2 and not ply:GetNW2Bool("IsUnconscious", false) then
		ply:ApplyCoordinationLoss(2.5, 0.35)
		if math.random() < 0.18 then
			ply:ApplyConcussion(nil, 1.3, 0.45)
		end
	end
end

function meta:CheckForceProneOnly()
	local hp = self:Health()
	local maxhp = self:GetMaxHealth()
	local hpFrac = hp / maxhp
	local forceProneOnly = false
	if self:GetNW2Bool("HardBleed") and hpFrac <= 0.4 then
		forceProneOnly = true
	elseif self:GetNW2Bool("PelvisFracture") then
		forceProneOnly = true
	elseif self:GetNW2Float("BleedLevel") >= 3 and hpFrac <= 0.3 then
		forceProneOnly = true
	elseif self:GetNW2Bool("LegBroken") and hpFrac <= 0.25 then
		forceProneOnly = true
	elseif self:GetNW2Bool("RibFracture") and hpFrac <= 0.2 then
		forceProneOnly = true
	elseif CurTime() < self:GetNW2Float("UnconsciousEnd", 0) then
		forceProneOnly = true
	elseif self:GetNW2Bool("SpineBroken") then
		forceProneOnly = true
	end
	self:SetNW2Bool("ForceProneOnly", forceProneOnly)
end

function meta:MakeBloodEffect(bone, delay, times)
	if not bone then return end
	if not delay then delay = 0 end
	if not times then times = 1 end
	local tar = self
	if IsValid(self:GetRD()) then
		tar = self:GetRD()
	end
	local name = bone .. "Hit" .. self:EntIndex()
	timer.Create(name, delay, times, function()
		if !IsValid(tar) or tar:IsPlayer() and !tar:Alive() then
			timer.Remove(name)
			return 
		end
		local pos = MuR:BoneData(tar, bone)
		if math.random(1,3) == 1 then
			local effectdata = EffectData()
			effectdata:SetOrigin(pos)
			effectdata:SetNormal(VectorRand(-1,1))
			effectdata:SetMagnitude(1)
			effectdata:SetRadius(math.random(8,32))
			effectdata:SetEntity(self)
			util.Effect("mur_blood_splatter_effect", effectdata, true, true )
		end
		if math.random(1,4) == 1 then
			MuR:CreateBloodPool(tar, tar:LookupBone(bone), 1)
			tar:EmitSound("murdered/player/drip_" .. math.random(1, 5) .. ".wav", 40, math.random(80, 120))
		end
	end)
end

function meta:ClearBloodEffects()
	local tar = self
	if IsValid(self:GetRD()) then
		tar = self:GetRD()
	end

	for i = 0, tar:GetBoneCount() - 1 do
		local boneName = tar:GetBoneName(i)
		if boneName then
			local timerName = boneName .. "Hit" .. self:EntIndex()
			if timer.Exists(timerName) then
				timer.Remove(timerName)
			end
		end
	end

	if tar.GetBloodTrails then
		tar:GetBloodTrails("remove")
	end
end

function meta:DamagePlayerSystem(type, heal, dmgInfo)
	if heal then
		if type == "bone" then
			self:SetNW2Bool("LegBroken", false)
		elseif type == "blood" then
			self:SetNW2Float("BleedLevel", math.max(self:GetNW2Float("BleedLevel") - 1, 0))
		elseif type == "hard_blood" then
			self:SetNW2Bool("HardBleed", false)
		end
	else
		if self:IsRoleWithoutOrgans() then return end
		if type == "bone" and not self:GetNW2Bool("LegBroken") then
			self:SetNW2Bool("LegBroken", true)
			self:EmitSound("murdered/player/legbreak.wav", 60, math.random(80, 120))
		elseif type == "blood" then
			local damageAmount = dmgInfo and dmgInfo:GetDamage() or 10
			local bleedIncrease = 0.6

			if damageAmount >= 50 then
				bleedIncrease = 1.2
			elseif damageAmount >= 30 then
				bleedIncrease = 0.9
			end

			if dmgInfo then
				local damageType = dmgInfo:GetDamageType()
				if bit.band(damageType, DMG_SLASH) ~= 0 or bit.band(damageType, DMG_BULLET) ~= 0 then
					bleedIncrease = bleedIncrease * 1.2
				elseif bit.band(damageType, DMG_CLUB) ~= 0 then
					bleedIncrease = bleedIncrease * 0.5
				elseif bit.band(damageType, DMG_BLAST) ~= 0 then
					bleedIncrease = bleedIncrease * 1.2
				end
			end

			local armorReduction = 0
			if dmgInfo and self.GetArmorDamageReductionByHitgroup then
				local bone = self:GetNearestBoneFromPos(dmgInfo:GetDamagePosition(), dmgInfo:GetDamageForce())
				local hitgroup = HITGROUP_GENERIC
				if bone then
					local boneToHitgroup = {
						["ValveBiped.Bip01_Head1"] = HITGROUP_HEAD,
						["ValveBiped.Bip01_Neck1"] = HITGROUP_HEAD,
						["ValveBiped.Bip01_Spine"] = HITGROUP_STOMACH,
						["ValveBiped.Bip01_Spine1"] = HITGROUP_CHEST,
						["ValveBiped.Bip01_Spine2"] = HITGROUP_CHEST,
						["ValveBiped.Bip01_Spine4"] = HITGROUP_CHEST,
					}
					hitgroup = boneToHitgroup[bone] or HITGROUP_GENERIC
				end
				armorReduction, _ = self:GetArmorDamageReductionByHitgroup(hitgroup, dmgInfo)
			end
			bleedIncrease = bleedIncrease * (1 - (armorReduction * 0.5))

			local newLevel = self:GetNW2Float("BleedLevel") + bleedIncrease
			self:SetNW2Float("BleedLevel", math.min(newLevel, 3))

			if newLevel >= 4 then
				self:SetNW2Bool("HardBleed", true)
			end
		elseif type == "hard_blood" then
			self:SetNW2Bool("HardBleed", true)
		end
	end

	timer.Simple(0.1, function()
		if IsValid(self) then
			self:UpdateBloodMovementSpeed()
			self:CheckForceProneOnly()
			self:CheckRandomUnconsciousness()
		end
	end)
end

function meta:UpdateBloodMovementSpeed()
	if not self:Alive() then return end

	local bleedLevel = self:GetNW2Float("BleedLevel")
	local hardBleed = self:GetNW2Bool("HardBleed")
	local legBroken = self:GetNW2Bool("LegBroken")
	local footFracture = self:GetNW2Bool("FootFracture")
	local pelvisFracture = self:GetNW2Bool("PelvisFracture")
	local ribFracture = self:GetNW2Bool("RibFracture")

	local baseSlowWalk = 60
	local baseWalk = self.SpawnDataSpeed[1] 
	local baseRun = self.SpawnDataSpeed[2]

	local speedMultiplier = 1

	if hardBleed then
		speedMultiplier = 0.4
	elseif bleedLevel >= 3 then
		speedMultiplier = 0.6
	elseif bleedLevel == 2 then
		speedMultiplier = 0.75
	elseif bleedLevel == 1 then
		speedMultiplier = 0.9
	end

	if legBroken then
		speedMultiplier = speedMultiplier * 0.5
	end

	if footFracture then
		speedMultiplier = speedMultiplier * 0.75
	end

	if pelvisFracture then
		speedMultiplier = speedMultiplier * 0.35
	end

	if ribFracture then
		speedMultiplier = speedMultiplier * 0.9
	end

	self:SetSlowWalkSpeed(baseSlowWalk * speedMultiplier)
	self:SetWalkSpeed(baseWalk * speedMultiplier)
	self:SetRunSpeed(baseRun * speedMultiplier)
end

function meta:CheckRandomUnconsciousness()
	if not self:Alive() then return end
	if self:GetNW2Bool("IsUnconscious", false) then return end

	local hp = self:Health()
	local maxhp = self:GetMaxHealth()
	local hpFrac = hp / maxhp
	local bleedLevel = self:GetNW2Float("BleedLevel")
	local hardBleed = self:GetNW2Bool("HardBleed")
	local shockStage = self:GetNW2Int("ShockLevel", 0)
	local consciousStage = self:GetNW2Int("ConsciousLevel", 0)

	local unconsciousChance = 0

	if hpFrac <= 0.15 then
		unconsciousChance = unconsciousChance + 0.008
	elseif hpFrac <= 0.25 then
		unconsciousChance = unconsciousChance + 0.004
	elseif hpFrac <= 0.35 then
		unconsciousChance = unconsciousChance + 0.002
	end

	if hardBleed then
		unconsciousChance = unconsciousChance + 0.006
	elseif bleedLevel >= 3 then
		unconsciousChance = unconsciousChance + 0.004
	elseif bleedLevel >= 2 then
		unconsciousChance = unconsciousChance + 0.002
	end

	if shockStage >= 2 then
		unconsciousChance = unconsciousChance + 0.003 * shockStage
	end

	if consciousStage == 1 then
		unconsciousChance = unconsciousChance + 0.0015
	elseif consciousStage >= 2 then
		unconsciousChance = unconsciousChance + 0.004
	end

	if unconsciousChance > 0 and math.random() < unconsciousChance then
		local duration = math.random(2, 5) + (1 - hpFrac) * 3
		self:ApplyUnconsciousness(duration)
		MuR:GiveMessage2("random_unconscious", self)
	end
end

hook.Add("EntityTakeDamage", "MuR_DamageSystem", function(ent, dmg)
	local att = dmg:GetAttacker()

	if ent.Owner then
		ent = ent.Owner
	end

	if ent:IsPlayer() and !ent:IsRoleWithoutOrgans() then
		local force = dmg:GetDamageForce()
		if force:IsZero() and att:IsPlayer() then
			force = att:GetAimVector()*100
		end
		local bone1 = ent:GetNearestBoneFromPos(dmg:GetDamagePosition(), force)
		if IsValid(ent:GetRD()) then
			bone1 = ent:GetRD():GetNearestBoneFromPos(dmg:GetDamagePosition(), force)
		end

		local buldmg = dmg:IsBulletDamage()
		local dm = dmg:GetDamage()
		local kndmg = dmg:GetDamageType() == DMG_SLASH

		if (buldmg or kndmg) and (bone1 == "ValveBiped.Bip01_Spine" or bone1 == "ValveBiped.Bip01_Spine2") then
			local base = dmg:GetDamage()
			if base >= 20 then
				if not ent:GetNW2Bool("RibFracture") then
					ent:SetNW2Bool("RibFracture", true)
					MuR:GiveMessage2("rib_hit", ent)
				end
			end
		end

		if (bone1 == "ValveBiped.Bip01_L_Calf" or bone1 == "ValveBiped.Bip01_R_Calf") and math.random(1, 2) == 1 and dm > 10 then
			MuR:GiveMessage2("leg_hit", ent)
			ent:DamagePlayerSystem("bone")
		end

		if dmg:GetDamageType()==DMG_CLUB and (bone1 == "ValveBiped.Bip01_Head1" or bone1=="ValveBiped.Bip01_Neck1") then
			ent:ApplyConcussion(dmg, 2, 1)
			if dm >= 50 then
				ent:ApplyUnconsciousness(4 + dm/4)
			end
		end

		if dmg:GetDamageType()==DMG_CLUB and bone1 ~= "ValveBiped.Bip01_Head1" and bone1 ~= "ValveBiped.Bip01_Neck1" and dm>25 then
			ent:ApplyConcussion(dmg, 1.2, 0.6)
			ent:ApplyCoordinationLoss(6, 0.8)
		end

		if dmg:GetDamageType()==DMG_BLAST and (bone1 == "ValveBiped.Bip01_Head1" or bone1=="ValveBiped.Bip01_Neck1") then
			if ent:GetNW2Float("TinnitusEnd",0) < CurTime() then
				ent:SetNW2Float("TinnitusEnd", CurTime()+6)
				MuR:GiveMessage2("tinnitus_hit", ent)
			end
			ent:ApplyCoordinationLoss(10, 1.2)
			if dm >= 40 then
				ent:ApplyUnconsciousness(5 + dm/25)
			end
		end

		if dmg:GetDamageType()==DMG_FALL and dm >= 25 then
			ent:ApplyCoordinationLoss(4, 0.6)
			if dm >= 50 then
				ent:ApplyUnconsciousness(3)
			end
		end

		ent:CheckShock()
	end
end)

hook.Add("EntityTakeDamage", "MuR.RagdollDamage", function(ent, dmg)
	local dt = dmg:GetDamageType()
	local att = dmg:GetAttacker()
	if IsValid(att.MindController) then
		att = att.MindController
	end

	if ent.isRDRag then
		ent:GiveDamageOnRag(dmg)
	end

	if ent:IsPlayer() and IsValid(ent:GetRD()) then
		ent:TimeGetUpChange(dmg:GetDamage() / 8)
	end

	if ent:IsPlayer() and ent:Alive() then
		local dm = dmg:GetDamage()

		if dm >= 5 and ent:Armor() <= 0 then
			local maxhp = ent:GetMaxHealth()
			local frac = dm / maxhp
			local severity = frac
			if ent:GetNW2Bool("HardBleed") then severity = severity + 0.08 end
			local bl = ent:GetNW2Float("BleedLevel")
			if bl >= 3 then severity = severity + 0.05 elseif bl == 2 then severity = severity + 0.02 end
			if ent:GetNW2Bool("LegBroken") then severity = severity + 0.03 end
			local dtsev = dmg:GetDamageType()
			if bit.band(dtsev, DMG_CLUB) ~= 0 then severity = severity + 0.05 end
			if bit.band(dtsev, DMG_BLAST) ~= 0 then severity = severity + 0.1 end
			local hp = ent:Health()
			if hp <= maxhp * 0.35 then severity = severity + 0.05 end
			if hp <= maxhp * 0.2 then severity = severity + 0.08 end
			if CurTime() < ent:GetNW2Float("ConcussionEnd",0) then severity = severity + 0.05 end
			if CurTime() < ent:GetNW2Float("CoordinationEnd",0) then severity = severity + 0.03 end
			if CurTime() < ent:GetNW2Float("UnconsciousEnd",0) then severity = severity + 0.1 end
			if severity >= 1.2 then
				if MuR.Gamemode == 18 and ent:Health() > 30 then

				else
					ent:StartRagdolling(dm / 25, dm / 5, dmg)
				end
			end
		end

		if dm > 1 then
			if dt == DMG_CLUB or att:IsWorld() or string.match(att:GetClass(), "prop_") then
				ent:PlayVoiceLine("death_blunt")
			else
				ent:PlayVoiceLine("death_default")
			end
		end
	end
end)

hook.Add("PlayerPostThink", "MuR.UnconsciousCheck", function(ply)
	if ply:GetNW2Bool("IsUnconscious", false) then
		if not ply:Alive() then
			ply:SetNW2Bool("IsUnconscious", false)
			ply:SetNW2Float("UnconsciousEnd", 0)
		else
			ply.IsRagStanding = false
		end
	elseif ply:Alive() and (ply:Health() <= ply:GetMaxHealth() * 0.4 or ply:GetNW2Bool("HardBleed") or ply:GetNW2Float("BleedLevel") >= 2) then
		if not ply.NextUnconsciousCheck or ply.NextUnconsciousCheck <= CurTime() then
			ply:CheckRandomUnconsciousness()
			ply.NextUnconsciousCheck = CurTime() + 0.2
		end
	end
end)

hook.Add("PlayerCanHearPlayersVoice", "MuR.UnconsciousVoice", function(listener, talker)
	if talker:GetNW2Bool("IsUnconscious", false) then
		return false
	end
end)

hook.Add("PlayerDeath", "MuR.ClearUnconsciousState", function(victim)
	victim:SetNW2Bool("IsUnconscious", false)
	victim:SetNW2Float("UnconsciousEnd", 0)
	victim:SetNW2Float("ConcussionEnd", 0)
	victim:SetNW2Float("CoordinationEnd", 0)
	victim:SetNW2Int("ShockLevel", 0)
	victim:SetNW2Int("ConsciousLevel", 0)
end)

hook.Add("MuR.HandleCustomHitgroup", "MuR_OrganDamage", function(victim, owner, organ, dmginfo)
	if not IsValid(victim) or not IsValid(owner) or not owner:IsPlayer() or (not victim:IsPlayer() and not victim:IsRagdoll()) then return end

	local ply = victim:IsPlayer() and victim or (victim:IsRagdoll() and victim.Owner)
	if IsValid(ply) and MuR.Gamemode == 21 and ply:GetNW2String("Class") == "Tony" then return end

	if dmginfo:IsBulletDamage() or dmginfo:GetDamageType() == DMG_SLASH then
		local armorReduction = 0
		if ply and ply.GetArmorDamageReductionByHitgroup then
			local bone = victim:IsPlayer() and victim:GetNearestBoneFromPos(dmginfo:GetDamagePosition(), dmginfo:GetDamageForce()) or victim:GetNearestBoneFromPos(dmginfo:GetDamagePosition(), dmginfo:GetDamageForce())
			local hitgroup = HITGROUP_GENERIC
			local boneToHitgroup = {
				["ValveBiped.Bip01_Head1"] = HITGROUP_HEAD,
				["ValveBiped.Bip01_Neck1"] = HITGROUP_HEAD,
				["ValveBiped.Bip01_Spine"] = HITGROUP_STOMACH,
				["ValveBiped.Bip01_Spine1"] = HITGROUP_CHEST,
				["ValveBiped.Bip01_Spine2"] = HITGROUP_CHEST,
				["ValveBiped.Bip01_Spine4"] = HITGROUP_CHEST,
			}
			hitgroup = boneToHitgroup[bone] or HITGROUP_GENERIC
			armorReduction, _ = ply:GetArmorDamageReductionByHitgroup(hitgroup, dmginfo)
		end

		if armorReduction >= 0.8 then
			return
		elseif armorReduction > 0 and armorReduction < 0.5 then
			if math.random() > (1 - armorReduction * 2) then
				return
			end
		end
		if organ == "Brain" then
			local brainStage = dmginfo:GetDamage() >= 34 and 3 or (dmginfo:GetDamage() >= 18 and 2 or 1)
			MuR:GiveMessage2("brain_hit", owner)
			dmginfo:ScaleDamage(1.4 + brainStage * 0.35)
			owner:ApplyConcussion(dmginfo, 5 + brainStage * 3, 0.8 + brainStage * 0.35)
			local state = owner:ApplyCriticalOrganState("brain", {
				attacker = dmginfo:GetAttacker(),
				inflictor = dmginfo:GetInflictor(),
				damageType = DMG_DIRECT,
				deathIn = brainStage >= 2 and shortenTimeline(55 - brainStage * 8, dmginfo:GetDamage(), 18 - brainStage * 2, 0.18 + brainStage * 0.03) or nil,
				passoutIn = brainStage >= 2 and 0 or shortenTimeline(16, dmginfo:GetDamage(), 6, 0.08),
				unconsciousFor = 10 + brainStage * 6,
				interval = 1.5,
				injuryStage = brainStage,
				shockWeight = 1.2
			})
			if state and brainStage >= 2 then
				owner:ApplyUnconsciousness(10 + brainStage * 6)
			end

		elseif organ == "Neck" then
			local neckStage = dmginfo:GetDamage() >= 26 and 3 or (dmginfo:GetDamage() >= 14 and 2 or 1)
			MuR:GiveMessage2("neck_hit", owner)
			dmginfo:ScaleDamage(1.05 + neckStage * 0.12)
			owner:ApplyConcussion(dmginfo, 2 + neckStage * 2, 0.5 + neckStage * 0.2)
			owner:ApplyCoordinationLoss(3 + neckStage * 2, 0.3 + neckStage * 0.2)
			local state = owner:ApplyCriticalOrganState("neck", {
				attacker = dmginfo:GetAttacker(),
				inflictor = dmginfo:GetInflictor(),
				damageType = DMG_DIRECT,
				deathIn = neckStage >= 2 and shortenTimeline(95 - neckStage * 10, dmginfo:GetDamage(), 34 - neckStage * 3, 0.12 + neckStage * 0.02) or nil,
				passoutIn = neckStage >= 2 and shortenTimeline(45 - neckStage * 4, dmginfo:GetDamage(), 14 - neckStage * 2, 0.08 + neckStage * 0.02) or nil,
				unconsciousFor = 8 + neckStage * 3,
				interval = 2.5,
				injuryStage = neckStage,
				shockWeight = 0.7
			})
			if victim.MakeBloodEffect then victim:MakeBloodEffect("ValveBiped.Bip01_Neck1", 0.1, 4) end
			if state and state.passoutAt and state.passoutAt <= CurTime() + 0.1 then
				owner:ApplyUnconsciousness(12)
			end

		elseif organ == "Heart" then
			local heartStage = dmginfo:GetDamage() >= 30 and 3 or (dmginfo:GetDamage() >= 16 and 2 or 1)
			MuR:GiveMessage2("heart_hit", owner)
			if heartStage >= 2 then
				MuR:GiveMessage2("artery_heart_hit", owner)
				owner:TriggerArtery("Heart")
			end
			dmginfo:ScaleDamage(1.1 + heartStage * 0.1)
			owner:ApplyCriticalOrganState("heart", {
				attacker = dmginfo:GetAttacker(),
				inflictor = dmginfo:GetInflictor(),
				damageType = DMG_DIRECT,
				deathIn = heartStage >= 2 and shortenTimeline(42 - heartStage * 8, dmginfo:GetDamage(), 14 - heartStage, 0.08 + heartStage * 0.02) or nil,
				passoutIn = heartStage >= 2 and shortenTimeline(18 - heartStage * 2, dmginfo:GetDamage(), 5, 0.04 + heartStage * 0.02) or nil,
				unconsciousFor = 8 + heartStage * 4,
				interval = 2,
				injuryStage = heartStage,
				shockWeight = 1.35
			})
			if victim.MakeBloodEffect then victim:MakeBloodEffect("ValveBiped.Bip01_Spine4", 0.1, 10) end
			if heartStage >= 2 then
				owner:EmitSound("murdered/player/heartbeat_stop.wav", 60, 100)
			end

		elseif organ == "Right Lung" or organ == "Left Lung" then
			local lungStage = dmginfo:GetDamage() >= 22 and 2 or 1
			MuR:GiveMessage2("lung_hit", owner)
			owner:ApplyInternalBleed(10 + lungStage * 6, 5 - lungStage)
			owner:ApplyCoordinationLoss(8 + lungStage * 4, 0.55 + lungStage * 0.2)
			owner:SetNW2Bool("Pneumothorax", true)
			local state = owner:ApplyCriticalOrganState("lungs", {
				attacker = dmginfo:GetAttacker(),
				inflictor = dmginfo:GetInflictor(),
				damageType = DMG_DIRECT,
				interval = 1,
				injuryStage = lungStage,
				shockWeight = 0.9
			})
			if state then
				local sideKey = organ == "Right Lung" and "rightHit" or "leftHit"
				if not state[sideKey] then
					state[sideKey] = true
					state.hits = (state.hits or 0) + 1
				end

				state.injuryStage = math.max(state.injuryStage or 1, lungStage, state.hits or 1)
				owner:SetOrganDamageStage("lungs", state.injuryStage)

				if (state.hits or 1) >= 2 then
					local totalStage = math.max(state.injuryStage or 2, dmginfo:GetDamage() >= 26 and 3 or 2)
					local now = CurTime()
					local deathAt = totalStage >= 3 and (now + shortenTimeline(60, dmginfo:GetDamage(), 22, 0.12)) or nil
					local passoutAt = now + shortenTimeline(42 - totalStage * 6, dmginfo:GetDamage(), 12 - totalStage, 0.06 + totalStage * 0.02)
					if deathAt then
						state.deathAt = state.deathAt and math.min(state.deathAt, deathAt) or deathAt
					end
					state.passoutAt = state.passoutAt and math.min(state.passoutAt, passoutAt) or passoutAt
					state.unconsciousFor = math.max(state.unconsciousFor or 0, 10 + totalStage * 2)
					state.injuryStage = totalStage
					owner:SetOrganDamageStage("lungs", totalStage)
				end
			end
			if math.random(1, 2) == 1 then
				owner:EmitSound("murdered/player/gasp_0" .. math.random(1, 3) .. ".wav", 60, 100)
			end

		elseif organ == "Spine" then
			MuR:GiveMessage2("spine_hit", owner)
			dmginfo:ScaleDamage(1.5)
			owner:SetNW2Bool("SpineBroken", true)
			owner:StartRagdolling(0, dmginfo:GetDamage())
			owner:ApplyCoordinationLoss(20, 1.8)
			owner:EmitSound("murdered/player/bone_break.wav", 60, 100)

		elseif organ == "Liver" then
			local liverStage = dmginfo:GetDamage() >= 30 and 3 or (dmginfo:GetDamage() >= 15 and 2 or 1)
			MuR:GiveMessage2("liver_hit", owner)
			owner:ApplyInternalBleed(8 + liverStage * 6, math.max(2, 6 - liverStage))
			owner:ApplyCriticalOrganState("liver", {
				attacker = dmginfo:GetAttacker(),
				inflictor = dmginfo:GetInflictor(),
				damageType = DMG_DIRECT,
				deathIn = liverStage >= 2 and shortenTimeline(180 - liverStage * 25, dmginfo:GetDamage(), 60 - liverStage * 5, 0.25 + liverStage * 0.05) or nil,
				passoutIn = liverStage >= 2 and shortenTimeline(110 - liverStage * 15, dmginfo:GetDamage(), 28, 0.1 + liverStage * 0.03) or nil,
				unconsciousFor = 10 + liverStage * 3,
				interval = 4,
				injuryStage = liverStage,
				shockWeight = 0.75
			})

		elseif string.find(organ, "Artery") then
			MuR:GiveMessage2("artery_hit", owner)
			owner:TriggerArtery(organ)

			if organ == "Carotid Artery" then
				MuR:GiveMessage2("artery_neck_hit", owner)
				owner:ApplyCriticalOrganState("carotid", {
					attacker = dmginfo:GetAttacker(),
					inflictor = dmginfo:GetInflictor(),
					damageType = DMG_DIRECT,
					deathIn = shortenTimeline(28, dmginfo:GetDamage(), 12, 0.09),
					passoutIn = shortenTimeline(14, dmginfo:GetDamage(), 5, 0.05),
					unconsciousFor = 18,
					interval = 1.5,
					injuryStage = dmginfo:GetDamage() >= 20 and 3 or 2,
					shockWeight = 1.5
				})
				if victim.MakeBloodEffect then victim:MakeBloodEffect("ValveBiped.Bip01_Neck1", 0.1, 8) end
				owner:EmitSound("murdered/player/throat_cut.wav", 60, 100)
			elseif string.find(organ, "Brachial") then
				MuR:GiveMessage2("artery_arm_hit", owner)
				if owner:GetNW2Int("HP_LegRight") == 0 or owner:GetNW2Int("HP_LegLeft") == 0 or owner:GetNW2Int("HP_HandRight") == 0 or owner:GetNW2Int("HP_HandLeft") == 0 then
					MuR:GiveMessage2("dismember_agony", owner)
				end
				if IsValid(owner:GetActiveWeapon()) and not owner:GetActiveWeapon().NeverDrop then
					owner:DropWeapon(owner:GetActiveWeapon())
				end
				owner:ApplyCriticalOrganState("brachial", {
					attacker = dmginfo:GetAttacker(),
					inflictor = dmginfo:GetInflictor(),
					damageType = DMG_DIRECT,
					deathIn = shortenTimeline(130, dmginfo:GetDamage(), 55, 0.2),
					passoutIn = shortenTimeline(70, dmginfo:GetDamage(), 24, 0.1),
					unconsciousFor = 10,
					interval = 3,
					injuryStage = dmginfo:GetDamage() >= 22 and 2 or 1,
					shockWeight = 0.7
				})
				if string.find(organ, "Right") then
					if victim.MakeBloodEffect then victim:MakeBloodEffect("ValveBiped.Bip01_R_UpperArm", 0.1, 6) end
				else
					if victim.MakeBloodEffect then victim:MakeBloodEffect("ValveBiped.Bip01_L_UpperArm", 0.1, 6) end
				end
			elseif string.find(organ, "Femoral") then
				MuR:GiveMessage2("artery_leg_hit", owner)
				owner:DamagePlayerSystem("bone")
				owner:ApplyCriticalOrganState("femoral", {
					attacker = dmginfo:GetAttacker(),
					inflictor = dmginfo:GetInflictor(),
					damageType = DMG_DIRECT,
					deathIn = shortenTimeline(55, dmginfo:GetDamage(), 22, 0.14),
					passoutIn = shortenTimeline(28, dmginfo:GetDamage(), 10, 0.08),
					unconsciousFor = 16,
					interval = 2,
					injuryStage = dmginfo:GetDamage() >= 24 and 3 or 2,
					shockWeight = 1.2
				})
				if string.find(organ, "Right") then
					if victim.MakeBloodEffect then victim:MakeBloodEffect("ValveBiped.Bip01_R_Thigh", 0.1, 7) end
				else
					if victim.MakeBloodEffect then victim:MakeBloodEffect("ValveBiped.Bip01_L_Thigh", 0.1, 7) end
				end
			end
		end

		local organData = MuR.GetOrgan(organ)
		if organData and organData.bleed and organData.bleed > 0 then
			local boneName = organData.bone
			local seconds = math.Clamp(organData.bleed * 6, 2, 30)
			local times = math.max(1, organData.bleed * 2)

			if victim:IsRagdoll() then
				victim._MuR_BledOrgans = victim._MuR_BledOrgans or {}
				if not victim._MuR_BledOrgans[organ] then
					victim._MuR_BledOrgans[organ] = true
					if victim.BloodTrailBone then victim:BloodTrailBone(boneName, seconds) end
					local pos = MuR:BoneData(victim, boneName)
					if pos then
						local eff = EffectData()
						eff:SetOrigin(pos)
						eff:SetMagnitude(organData.bleed)
						eff:SetEntity(victim)
						util.Effect("mur_organ_bleed", eff)
					end
				end
			else
				local plyVictim = victim:IsPlayer() and victim or (victim:IsRagdoll() and victim.Owner)
				if IsValid(plyVictim) then
					local newLevel = plyVictim:GetNW2Float("BleedLevel") + organData.bleed
					plyVictim:SetNW2Float("BleedLevel", math.min(newLevel, 3))
					if newLevel >= 4 then plyVictim:SetNW2Bool("HardBleed", true) end
					if plyVictim.BloodTrailBone then plyVictim:BloodTrailBone(boneName, seconds) end
					plyVictim:MakeBloodEffect(boneName, 0.1, times)
				end
			end
		end

	elseif dmginfo:GetDamageType() == DMG_CLUB and organ == "Brain" and dmginfo:GetDamage() >= 40 then
		if owner:IsPlayer() then
			owner:ApplyCriticalOrganState("brain", {
				attacker = dmginfo:GetAttacker(),
				inflictor = dmginfo:GetInflictor(),
				damageType = DMG_CLUB,
				deathIn = shortenTimeline(50, dmginfo:GetDamage(), 18, 0.18),
				passoutIn = 0,
				unconsciousFor = 18,
				interval = 1.5
			})
			owner:ApplyUnconsciousness(18)
		end
	end
end)

hook.Add("PlayerPostThink", "MuR.OrganEffects", function(ply)
	if not ply:Alive() then return end

	processCriticalOrgans(ply)
	processBodyState(ply)

	if ply:GetNW2Bool("Pneumothorax") then
		if ply:GetNW2Float("Stamina", 100) > 20 then
			ply:SetNW2Float("Stamina", math.max(ply:GetNW2Float("Stamina") - FrameTime() * 10, 20))
		end

		if math.random() < 0.005 then
			ply:EmitSound("murdered/player/gasp_0" .. math.random(1, 3) .. ".wav", 50, 90)
		end
	end

	local toxin = ply:GetNW2Float("ToxinLevel", 0)
	if toxin > 0 then
		if toxin > 3 and math.random() < 0.001 then
			ply:ApplyUnconsciousness(2)
		end
	end
end)

hook.Add("PlayerDeath", "MuR.ClearCriticalOrgans", function(victim)
	victim:ResetCriticalOrgans()
end)
