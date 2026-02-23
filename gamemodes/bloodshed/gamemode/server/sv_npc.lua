local meta = FindMetaTable("Player")

function meta:Surrender(force, moment, id, dur)
	if timer.Exists("MindControl_" .. self:EntIndex()) or self:GetNW2Bool("GeroinUsed") or self:IsRolePolice() or string.match(self:GetSVAnim(), "sequence_ron_arrest_start_npc_") or self:IsExecuting() then return end

	if moment then
		timer.Simple(30, function()
			if not IsValid(ent) then return end
			ent:SetRenderFX(kRenderFxFadeSlow)

			timer.Simple(4, function()
				if not IsValid(ent) then return end
				ent:Remove()
			end)
		end)

		self:StopRagdolling()
		self:SetSVAnimation("sequence_ron_arrest_start_npc_0" .. id)
		self:Freeze(true)
		self:SetNW2Float("ArrestState", 0)
		self:SetNW2Float("DeathStatus", 3)
		self:SetNotSolid(true)
		self:SetNoTarget(true)
		timer.Simple(dur, function()
			if not IsValid(self) or !self:Alive() then return end
			local ent = ents.Create("bloodshed_anim_model")
			ent:TransferModelData(self)
            ent:SetNW2String("RoN_Type", self.IsHostage and "hostage" or self.IsCivilian and "civilian" or "suspect")
			ent:SetPos(self:GetPos() + self:GetForward() * 16)
			ent:SetAngles(Angle(0, self:EyeAngles().y, 0))
			ent:Spawn()
			ent:DropToFloor()
			ent:SetAnim("sequence_ron_arrest_wiggleloop")
			ent:SetRenderMode(RENDERMODE_TRANSALPHA)
			ent:MakePlayerColor(self:GetPlayerColor())
			ent:SetFlexScale(0.5)

			self:StopRagdolling()
			self:KillSilent()
			self:SetSVAnimation("")
			self:Freeze(false)
			MuR:GiveAnnounce("arrested", self)

			self:SetNW2Float("Guilt", math.Clamp(self:GetNW2Float("Guilt", 0) - 10, 0, 100))

			if IsValid(copmodel) then
				copmodel:Remove()
			end
		end)
	else
		self:ResetButtons()
		if self:GetSVAnim() ~= "" then
			if self.IsSurrenderBefore then
				self:SetNW2Float("ArrestState", 2)
			end
			self.IsSurrenderBefore = false
			self:SetSVAnimation("sequence_ron_comply_exit_0" .. math.random(1,3), true)
		else
			self.IsSurrenderBefore = self:GetNW2Float("ArrestState") == 2
			if self.IsSurrenderBefore then
				self:SetNW2Float("ArrestState", 1)
			end
			self:SetSVAnimation("sequence_ron_comply_start_0" .. math.random(1,4))
		end
	end
end

function MuR:SpawnNPC(type, pos)
	local tab = MuR.PoliceClasses[type]
	if not istable(tab) then return end

	if type != "zombie" and type != "suspect" then
		local class, wclass = tab.npcs[math.random(1, #tab.npcs)], tab.weps[math.random(1, #tab.weps)]
		local ent = ents.Create(class)
		ent.IsPolice = true
		ent:SetPos(pos)
		ent:Spawn()
		ent:Give(wclass)

		timer.Simple(2, function()
			if not IsValid(ent) then return end
			local pos = MuR:GetRandomPos(tobool(math.random(0,7)))
			if isvector(pos) then
				ent:SetLastPosition(pos)
				ent:SetSchedule(SCHED_FORCED_GO_RUN)
			end
		end)
	elseif type == "suspect" then
		local class, wclass = tab.npcs[math.random(1, #tab.npcs)], tab.weps[math.random(1, #tab.weps)]
		local ent = ents.Create(class)
		ent:SetPos(pos)
		ent:Spawn()
		ent:Give(wclass)
	else
		local class = tab[math.random(1, #tab)]
		local ent = ents.Create(class)
		ent:SetPos(pos)
		ent:Spawn()
	end
end

function MuR:CheckOtherForces()
	if !MuR.HeliArrived then
		local tab = MuR.HeliSettings
		local time = MuR.PoliceArriveTime-CurTime()-math.random(tab[1], tab[2])
		timer.Create("MuR_SpecialForcesHeli", time, 1, function()
			local rnd = MuR.PoliceState == 1 and tab[3] or MuR.PoliceState == 5 and 100 or tab[4]
			if math.random(1,100) <= rnd then
				local pos = MuR:GetRandomPos(false)
				if isvector(pos) then
					MuR:PlayDispatch("heli")
					local heli = ents.Create("bloodshed_police_heli")
					heli:SetPos(pos+Vector(0,0,400))
					heli:Spawn()
					MuR.HeliArrived = true
				end
			end
		end)
	end

	if !MuR.SniperArrived then
		local tab = MuR.SniperSettings
		local time = MuR.PoliceArriveTime-CurTime()-math.random(tab[1], tab[2])
		timer.Create("MuR_SpecialForcesSniper", time, 1, function()
			local rnd = MuR.PoliceState == 1 and tab[3] or MuR.PoliceState == 5 and 100 or tab[4]
			if math.random(1,100) <= rnd then
				MuR:PlayDispatch("sniper")
				MuR.SniperArrived = true
			end
		end)
	end
end

function MuR:CheckPoliceReinforcment()
	local pa = MuR:CountPlayerPolice()
	pa = pa + MuR:CountNPCPolice()
	local mode = MuR.Mode(MuR.Gamemode)
	if (MuR.PoliceState == 2 or MuR.PoliceState == 4) and pa <= 2 or (MuR.PoliceState < 5 and mode.armored_officer_heist_logic) then
		MuR:SetPoliceTime(75)
		MuR.PoliceState = 5
		MuR:PlayDispatch("raidstart")
		MuR:CheckOtherForces()
	end
	if MuR.PoliceState == 6 and pa <= 2 and not mode.armored_officer_heist_logic then
		timer.Simple(3, function()
			if MuR.PoliceState ~= 6 then return end
			MuR:SpawnPlayerPolice(true)
		end)
	end
end

local function PushApart(npc1, npc2)
	local pos1 = npc1:GetPos()
	local pos2 = npc2:GetPos()
	if pos1:DistToSqr(pos2) > 10000 then return end
	local dir = (pos1 - pos2):GetNormalized()
	local pushForce = 25
	local npc1allow = not npc1:IsPlayer()
	local npc2allow = not npc2:IsPlayer()

	if npc1allow then
		npc1:SetVelocity(dir * pushForce)
	end
	if npc2allow then
		npc2:SetVelocity(-dir * pushForce)
	end
end

hook.Add("EntityTakeDamage", "MuR_NoCollisionNPCs", function(ent, dmg)
	local att = dmg:GetAttacker()
	local allow1 = ent:IsNPC() and ent.IsPolice or ent:IsPlayer() and ent:IsRolePolice()
	local allow2 = att:IsNPC() and att.IsPolice or att:IsPlayer() and att:IsRolePolice()
	if allow1 and allow2 and ent != att then
		return true
	end
end)