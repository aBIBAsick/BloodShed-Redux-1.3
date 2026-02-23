MuR.Modes = MuR.Modes or {}

function MuR.RegisterMode(id, def)
	MuR.Modes[id] = def or {}
	if MuR.RebuildGamemodeChances then
		MuR:RebuildGamemodeChances()
	end
end

function MuR.Mode(id)
	return MuR.Modes[id] or {}
end

function MuR:RebuildGamemodeChances()
	local t = {}
	for id, def in pairs(MuR.Modes) do
		if def.enabled ~= false then
			t[id] = {chance = def.chance or 0, need_players = def.need_players or 1}
		end
	end
	MuR.GamemodeChances = t
end