if SERVER then return end

net.Receive("ZGM3_SyncBoneScale", function()
	local ent = net.ReadEntity()
	local bone = net.ReadUInt(16)
	local scale = net.ReadVector()

	if not IsValid(ent) then return end

	if scale.x == -1 and scale.y == -1 and scale.z == -1 then
		scale = Vector(0,0,0)
	end

	ent:ManipulateBoneScale(bone, scale)
end)
