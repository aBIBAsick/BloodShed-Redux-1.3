local showHitboxes = false

hook.Add("PostDrawOpaqueRenderables", "MuR_DrawOrgans", function()
	if not showHitboxes then return end

	for _, ent in ents.Iterator() do
		if not ent:IsPlayer() and not ent:IsRagdoll() then continue end
		if ent:IsPlayer() and not ent:Alive() then continue end
		if ent == LocalPlayer() and not LocalPlayer():ShouldDrawLocalPlayer() then continue end

		for _, organ in ipairs(MuR.Organs) do
			local boneId = ent:LookupBone(organ.bone)
			if not boneId then continue end

			local bonePos, boneAng = ent:GetBonePosition(boneId)
			if not bonePos then continue end

			local color = organ.color

			local isDamaged = false
			if organ.name == "Spine" and ent:GetNW2Bool("SpineBroken") then isDamaged = true end
			if (organ.name == "Right Lung" or organ.name == "Left Lung") and ent:GetNW2Bool("Pneumothorax") then isDamaged = true end
			if organ.name == "Liver" and ent:GetNW2Float("ToxinLevel") > 0 then isDamaged = true end
			if (organ.name == "Right Eye" or organ.name == "Left Eye") and ent:GetNW2Int("Blindness") > 0 then isDamaged = true end

			if isDamaged then color = Color(0, 0, 0) end

			cam.Start3D()
				render.DrawWireframeBox(bonePos, boneAng, organ.mins, organ.maxs, color, false)
			cam.End3D()
		end
	end
end)
