MuR.Roles = MuR.Roles or {}
function MuR.RegisterRole(name, def)
	MuR.Roles[name] = def or {}
end
function MuR.GetRole(name)
	return MuR.Roles[name] or {}
end
