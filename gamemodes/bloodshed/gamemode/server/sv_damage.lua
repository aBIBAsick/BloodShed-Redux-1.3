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

function meta:TriggerArtery()
	if not self:GetNW2Bool("HardBleed") then
		self:SetNW2Bool("HardBleed", true)
		MuR:GiveMessage2("artery_hit", self)
	end
end

function meta:CheckShock()
	if self:GetNW2Bool("ShockState") then return end
	if self:Health() <= self:GetMaxHealth() * 0.25 and (self:GetNW2Bool("HardBleed") or self:GetNW2Float("BleedLevel") >= 3) then
		self:SetNW2Bool("ShockState", true)
		MuR:GiveMessage2("shock_state", self)
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
	self:SetNW2Bool("IsUnconscious", true)
	self:SetNW2Float("UnconsciousEnd", CurTime() + duration)
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
	self.VoiceDelay = 0
	
	MuR:GiveMessage2("wake_up", self)
	MuR:PlaySoundOnClient("gasp/focus_gasp_0" .. math.random(1, 6) .. ".wav", self)
end

function meta:CheckForceProneOnly()
	local hp = self:Health()
	local maxhp = self:GetMaxHealth()
	local hpFrac = hp / maxhp
	local forceProneOnly = false
	if self:GetNW2Bool("HardBleed") and hpFrac <= 0.4 then
		forceProneOnly = true
	elseif self:GetNW2Float("BleedLevel") >= 3 and hpFrac <= 0.3 then
		forceProneOnly = true
	elseif self:GetNW2Bool("LegBroken") and hpFrac <= 0.25 then
		forceProneOnly = true
	elseif self:GetNW2Bool("RibFracture") and hpFrac <= 0.2 then
		forceProneOnly = true
	elseif CurTime() < self:GetNW2Float("UnconsciousEnd", 0) then
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
			local bleedIncrease = 1
			
			if damageAmount >= 50 then
				bleedIncrease = 2
			elseif damageAmount >= 30 then
				bleedIncrease = 1.5
			end
			
			if dmgInfo then
				local damageType = dmgInfo:GetDamageType()
				if bit.band(damageType, DMG_SLASH) ~= 0 or bit.band(damageType, DMG_BULLET) ~= 0 then
					bleedIncrease = bleedIncrease * 1.3
				elseif bit.band(damageType, DMG_CLUB) ~= 0 then
					bleedIncrease = bleedIncrease * 0.7
				elseif bit.band(damageType, DMG_BLAST) ~= 0 then
					bleedIncrease = bleedIncrease * 1.5
				end
			end
			
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
	
	if self:GetNW2Bool("ShockState") then
		unconsciousChance = unconsciousChance + 0.003
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

		if buldmg then
			if not (bone1 == "ValveBiped.Bip01_Head1" or bone1 == "ValveBiped.Bip01_Neck1") then
				dmg:ScaleDamage(1/3)
			end
		elseif kndmg or bit.band(dmg:GetDamageType(), DMG_CLUB) ~= 0 then
			dmg:ScaleDamage(0.5)
		end
		dm = dmg:GetDamage()

		if (buldmg and math.random(1,4) == 1 or kndmg) and (bone1 == "ValveBiped.Bip01_Head1" or bone1 == "ValveBiped.Bip01_Neck1") then
			MuR:GiveMessage2("neck_hit", ent)
			ent:DamagePlayerSystem("hard_blood")
			ent:BloodTrailBone("ValveBiped.Bip01_Neck1", 30)
			ent:TriggerArtery()
			if kndmg then ent:ApplyConcussion(dmg, 1.6, 0.9) end
		end

		if (buldmg or kndmg) and (bone1 == "ValveBiped.Bip01_Spine" or bone1 == "ValveBiped.Bip01_Spine2") then
			local base = dmg:GetDamage()
			if base >= 55 then
				MuR:GiveMessage2("heart_hit", ent)
				ent:DamagePlayerSystem("hard_blood")
				ent:MakeBloodEffect("ValveBiped.Bip01_Spine4", 0.4, 30)
				ent:TriggerArtery()
			elseif base >= 35 then
				MuR:GiveMessage2("lung_hit", ent)
				ent:DamagePlayerSystem("hard_blood")
				ent:MakeBloodEffect("ValveBiped.Bip01_Spine4", 0.4, 30)
				if math.random(1,2)==1 then ent:ApplyInternalBleed(10,3) end
			elseif base >= 20 then
				if not ent:GetNW2Bool("RibFracture") then
					ent:SetNW2Bool("RibFracture", true)
					MuR:GiveMessage2("rib_hit", ent)
					if math.random(1,2)==1 then ent:ApplyInternalBleed(8,4) end
				end
			else
				MuR:GiveMessage2("down_hit", ent)
				ent:MakeBloodEffect("ValveBiped.Bip01_Spine2", 0.8, 15)
				ent:DamagePlayerSystem("blood")
				if math.random(1,2)==1 then ent:DamagePlayerSystem("blood") end
			end
			if dmg:GetDamageType()==DMG_BLAST then ent:ApplyInternalBleed(14,2) end
		end

		if (bone1 == "ValveBiped.Bip01_R_Forearm" or bone1 == "ValveBiped.Bip01_L_Forearm") and math.random(1, 2) == 1 and IsValid(ent:GetActiveWeapon()) and not ent:GetActiveWeapon().NeverDrop and dm > 10 then
			MuR:GiveMessage2("arm_hit", ent)
			ent:DropWeapon(ent:GetActiveWeapon())
		end

		if (bone1 == "ValveBiped.Bip01_L_Calf" or bone1 == "ValveBiped.Bip01_R_Calf") and math.random(1, 2) == 1 and dm > 10 then
			MuR:GiveMessage2("leg_hit", ent)
			ent:DamagePlayerSystem("bone")
		end

		if dmg:GetDamageType()==DMG_CLUB and (bone1 == "ValveBiped.Bip01_Head1" or bone1=="ValveBiped.Bip01_Neck1") then
			ent:ApplyConcussion(dmg, 2, 1)
			if dm >= 30 then
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
			if ent:GetNW2Bool("HardBleed") then severity = severity + 0.2 end
			local bl = ent:GetNW2Float("BleedLevel")
			if bl >= 3 then severity = severity + 0.15 elseif bl == 2 then severity = severity + 0.08 end
			if ent:GetNW2Bool("LegBroken") then severity = severity + 0.1 end
			local dtsev = dmg:GetDamageType()
			if bit.band(dtsev, DMG_CLUB) ~= 0 then severity = severity + 0.15 end
			if bit.band(dtsev, DMG_BLAST) ~= 0 then severity = severity + 0.25 end
			local hp = ent:Health()
			if hp <= maxhp * 0.35 then severity = severity + 0.15 end
			if hp <= maxhp * 0.2 then severity = severity + 0.25 end
			if CurTime() < ent:GetNW2Float("ConcussionEnd",0) then severity = severity + 0.15 end
			if CurTime() < ent:GetNW2Float("CoordinationEnd",0) then severity = severity + 0.1 end
			if CurTime() < ent:GetNW2Float("UnconsciousEnd",0) then severity = severity + 0.3 end
			if severity >= 0.6 then
				ent:StartRagdolling(dm / 25, dm / 5, dmg)
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
end)

hook.Add("PlayerSpawn", "MuR.ClearUnconsciousOnSpawn", function(ply)
	ply:SetNW2Bool("IsUnconscious", false)
	ply:SetNW2Float("UnconsciousEnd", 0)
	ply:SetNW2Float("CoordinationEnd", 0)
	ply:SetNW2Float("ConcussionEnd", 0)
	ply:SetNW2Bool("ForceProneOnly", false)
	ply.NextUnconsciousCheck = nil
end)