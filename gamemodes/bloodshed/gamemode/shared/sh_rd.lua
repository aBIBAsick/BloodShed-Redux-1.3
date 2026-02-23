local pl = FindMetaTable("Player")

if SERVER then
	function pl:SetSVAnimation(anim, autostop)
		self:SetNW2String('SVAnim', anim)
		self:SetNW2Float('SVAnimDelay', select(2, self:LookupSequence(anim)))
		self:SetNW2Float('SVAnimStartTime', CurTime())
		self:SetCycle(0)

		if autostop and anim ~= "" then
			local delay = select(2, self:LookupSequence(anim))

			timer.Simple(delay, function()
				if not IsValid(self) then return end
				local anim2 = self:GetNW2String('SVAnim')

				if anim == anim2 then
					self:SetSVAnimation("")
				end
			end)
		end

		return select(2, self:LookupSequence(anim))
	end

	hook.Add("PlayerDeath", "SVanimFix", function(ply)
		ply:SetSVAnimation("")
	end)
end

function pl:GetRD()
	return self:GetNW2Entity("RD_Ent")
end

function pl:CanGetUp()
	local rag = self:GetRD()
	local _, opos = MuR:CheckHeight(rag, MuR:BoneData(rag, "ValveBiped.Bip01_Pelvis"))
	local tr = util.TraceHull({

		start = opos,
		endpos = opos + Vector(0,0,4),
		filter = function(ent)
			if ent:GetClass() == "prop_ragdoll" or ent == self or ent:GetClass() == "murwep_ragdoll_weapon" or ent:GetClass() == "murwep_ragdoll_melee" then
				return false
			else
				return true
			end
		end,
		mins = self:OBBMins(),
		maxs = self:OBBMaxs(),
		mask = MASK_SHOT_HULL,
	})

	return not tr.Hit
end

function pl:GetSVAnimation()
	return self:GetNW2String('SVAnim')
end

function pl:TimeGetUpChange(time, isset)
	local rag = self:GetRD()

	if IsValid(rag) then
		if isset then
			local times = math.Clamp(CurTime() + time, CurTime(), CurTime()+45)
			if time > 500 then
				times = time
			end
			self:SetNW2Float('RD_GetUpTime', times)
		else
			local times = math.Clamp(self:GetNW2Float('RD_GetUpTime') + time, CurTime(), CurTime()+45)
			if time > 500 then
				times = time
			end
			self:SetNW2Float('RD_GetUpTime', times)
		end
	end
end

function pl:TimeGetUp(check)
	if check then
		return self:GetNW2Float('RD_GetUpTime') < CurTime()
	else
		return self:GetNW2Float('RD_GetUpTime')
	end
end

function MuR:BoneData(ent, bone)
	if !IsValid(ent) or !isstring(bone) then return Vector(0,0,0), Angle(0,0,0) end
	local boneid = ent:LookupBone(bone)
	local pos, ang = ent:GetBonePosition(boneid)

	return pos, ang
end

function MuR:CheckHeight(ent, pos)
	local tr = util.TraceLine({
		start = pos,
		endpos = pos - Vector(0, 0, 999999),
		filter = function(tar)
			if IsValid(ent.Weapon) and tar == ent.Weapon or ent == tar then
				return false 
			else
				return true
			end	
		end,
		mask = MASK_PLAYERSOLID,
	})

	return (pos - tr.HitPos):Length(), tr.HitPos
end

hook.Add("CalcMainActivity", "!TDMAnims", function(ply, vel)
	local str = ply:GetNW2String('SVAnim')
	local num = ply:GetNW2Float('SVAnimDelay')
	local st = ply:GetNW2Float('SVAnimStartTime')

	if str ~= "" then
		ply:SetCycle((CurTime() - st) / num)

		return -1, ply:LookupSequence(str)
	end
end)