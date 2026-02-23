hook.Add("EntityTakeDamage", "MuR_OrganSystem", function(target, dmginfo)
	if not target:IsPlayer() and not target:IsRagdoll() then return end
	if target:IsPlayer() and target:GetNW2String("Class") == "Entity" then return end

	local pos = dmginfo:GetDamagePosition()
	if pos == vector_origin then return end

	local dir = dmginfo:GetDamageForce():GetNormalized()
	local startPos = pos
	local rayDelta = dir * 32

	for _, organ in ipairs(MuR.Organs) do
		local boneId = target:LookupBone(organ.bone)
		if not boneId then continue end

		local bonePos, boneAng = target:GetBonePosition(boneId)
		if not bonePos then continue end

		local hitPos = util.IntersectRayWithOBB(startPos, rayDelta, bonePos, boneAng, organ.mins, organ.maxs)
		if hitPos then
            local owner = target:IsRagdoll() and target.Owner or target
			hook.Run("MuR.HandleCustomHitgroup", target, owner, organ.name, dmginfo)
			break
		end
	end
end)
