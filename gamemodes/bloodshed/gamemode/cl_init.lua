MuR = MuR or {}

function MuR.server()
end

function MuR.shared(path)
    include(path)
end

function MuR.client(path)
    include(path)
end

MuR.shared("shared.lua")

CreateConVar("cl_drawspawneffect", 0)

local hiddenErrorModels = {}

hook.Add("Think", "MuR_HideErrorModels", function()
	for _, ent in ents.Iterator() do
		if IsValid(ent) and not ent:IsPlayer() and not ent:IsNPC() then
			local mdl = ent:GetModel()
			local idx = ent:EntIndex()

			if mdl == "models/error.mdl" then
				local data = hiddenErrorModels[idx]

				if not data then
					hiddenErrorModels[idx] = {
						ent = ent,
						time = CurTime()
					}
				elseif not data.hidden and CurTime() - data.time > 1 then
					ent:SetNoDraw(true)
					data.hidden = true
				end
			else
				local data = hiddenErrorModels[idx]
				if data and data.hidden and ent:GetNoDraw() then
					ent:SetNoDraw(false)
				end
				hiddenErrorModels[idx] = nil
			end
		end
	end

	for idx, data in pairs(hiddenErrorModels) do
		if not IsValid(data.ent) then
			hiddenErrorModels[idx] = nil
		end
	end
end)