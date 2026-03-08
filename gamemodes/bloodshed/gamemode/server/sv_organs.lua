local function pointInBounds(localPos, mins, maxs)
	return localPos.x >= math.min(mins.x, maxs.x) and localPos.x <= math.max(mins.x, maxs.x)
		and localPos.y >= math.min(mins.y, maxs.y) and localPos.y <= math.max(mins.y, maxs.y)
		and localPos.z >= math.min(mins.z, maxs.z) and localPos.z <= math.max(mins.z, maxs.z)
end

local function boxVolume(mins, maxs)
	return math.abs((maxs.x - mins.x) * (maxs.y - mins.y) * (maxs.z - mins.z))
end

local emptyHitboxes = {}

util.AddNetworkString("MuR.DebugOrganRay")

local function canUseOrganDebug(ply)
	return IsValid(ply) and ply:IsPlayer() and ply:IsAdmin()
end

function MuR.ResolveZoneTransform(ent, zone, box)
	local boneId = ent:LookupBone(box.bone or zone.bone)
	if not boneId then return end

	local bonePos, boneAng = ent:GetBonePosition(boneId)
	if not bonePos then return end

	return LocalToWorld(box.offset or vector_origin, box.angle or angle_zero, bonePos, boneAng)
end

MuR.ResolveHitboxTransform = MuR.ResolveZoneTransform

function MuR.GetDamageRay(target, owner, dmginfo, hitPos)
	local attacker = dmginfo:GetAttacker()

	if IsValid(attacker) and attacker ~= target and attacker ~= owner then
		local startPos

		if attacker.GetShootPos then
			startPos = attacker:GetShootPos()
		end

		if (not startPos or startPos == vector_origin) and attacker.WorldSpaceCenter then
			startPos = attacker:WorldSpaceCenter()
		end

		if startPos and startPos ~= vector_origin then
			local delta = hitPos - startPos
			if not delta:IsZero() then
				return startPos, delta + delta:GetNormalized() * 6
			end
		end
	end

	local force = dmginfo:GetDamageForce()
	if force:IsZero() then return end

	local dir = force:GetNormalized()
	return hitPos - dir * 36, dir * 48
end

function MuR.TraceBodyZones(target, zones, hitPos, dmginfo, owner)
	if not IsValid(target) or not istable(zones) or hitPos == vector_origin then return end

	local traceStart, rayDelta = MuR.GetDamageRay(target, owner, dmginfo, hitPos)
	local traceLengthSqr = rayDelta and math.max(rayDelta:LengthSqr(), 0.000001) or nil

	local bestContainedZone
	local rayHits = {}

	for _, zone in ipairs(zones) do
		for _, box in ipairs(zone.hitboxes or emptyHitboxes) do
			local boxPos, boxAng = MuR.ResolveZoneTransform(target, zone, box)
			if not boxPos then continue end

			local volume = boxVolume(box.mins, box.maxs)
			local localHitPos = WorldToLocal(hitPos, angle_zero, boxPos, boxAng)
			if pointInBounds(localHitPos, box.mins, box.maxs) then
				if not bestContainedZone or volume < bestContainedZone.volume then
					bestContainedZone = {
						name = zone.name,
						data = zone,
						hitbox = box,
						volume = volume
					}
				end
			end

			if traceStart and rayDelta then
				local intersectPos, _, frac = util.IntersectRayWithOBB(traceStart, rayDelta, boxPos, boxAng, box.mins, box.maxs)
				if intersectPos then
					rayHits[#rayHits + 1] = {
						name = zone.name,
						data = zone,
						hitbox = box,
						volume = volume,
						frac = frac or (traceStart:DistToSqr(intersectPos) / traceLengthSqr)
					}
				end
			end
		end
	end

	if #rayHits > 0 then
		table.sort(rayHits, function(a, b)
			if a.frac == b.frac then
				return a.volume < b.volume
			end

			return a.frac < b.frac
		end)

		return rayHits[1]
	end

	return bestContainedZone
end

MuR.TraceHitboxEntries = MuR.TraceBodyZones

hook.Add("EntityTakeDamage", "MuR_OrganSystem", function(target, dmginfo)
	if not target:IsPlayer() and not target:IsRagdoll() then return end
	if target:IsPlayer() and target:GetNW2String("Class") == "Entity" then return end

	local hitPos = dmginfo:GetDamagePosition()
	if hitPos == vector_origin then return end

	local owner = target:IsRagdoll() and target.Owner or target
	local hitZone = MuR.TraceBodyZones(target, MuR.Organs, hitPos, dmginfo, owner)
	if not hitZone then return end

	hook.Run("MuR.HandleCustomHitgroup", target, owner, hitZone.name, dmginfo)
end)

hook.Add("EntityFireBullets", "MuR.DebugOrganRays", function(attacker, bulletData)
	if not IsValid(attacker) then return end
	if not bulletData or not isvector(bulletData.Src) then return end

	local originalCallback = bulletData.Callback
	local shotStart = bulletData.Src

	bulletData.Callback = function(shooter, tr, dmginfo)
		if IsValid(shooter) and tr and tr.HitPos then
			local debugViewers = {}
			for _, ply in ipairs(player.GetAll()) do
				if canUseOrganDebug(ply) then
					debugViewers[#debugViewers + 1] = ply
				end
			end

			if #debugViewers > 0 then
				net.Start("MuR.DebugOrganRay")
				net.WriteEntity(shooter)
				net.WriteVector(shotStart)
				net.WriteVector(tr.HitPos)
				net.WriteBool(IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsRagdoll()))
				net.Send(debugViewers)
			end
		end

		if originalCallback then
			return originalCallback(shooter, tr, dmginfo)
		end
	end
end)
