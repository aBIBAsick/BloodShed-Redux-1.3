local meta = FindMetaTable('Player')
local meta2 = FindMetaTable('Entity')

function meta:IsExecuting()
    return tobool(string.find(self:GetSVAnim(), "executions")) or tobool(string.find(self:GetSVAnim(), "hatred"))
end

function meta2:GetSVAnim()
	if self:IsPlayer() then
		return self:GetNW2String('SVAnim', '')
	else
		return self:GetNW2String('SVAnim', '')
	end
end

function meta2:IsProp()
	return self:GetClass() == "prop_dynamic" or self:GetClass() == "prop_physics" or self:GetClass() == "prop_physics_multiplayer" or self:GetClass() == "prop_physics_override"
end

function meta2:IsRolePolice()
	if self:IsPlayer() then
		return self:GetNW2String('Class') == "Riot" or self:GetNW2String('Class') == "Officer" or self:GetNW2String('Class') == "ArmoredOfficer" or self:GetNW2String('Class') == "FBI"
	else
		return self:GetNW2String('Class') == "Riot" or self:GetNW2String('Class') == "Officer" or self:GetNW2String('Class') == "ArmoredOfficer" or self:GetNW2String('Class') == "FBI"
	end
end

function meta:IsRoleWithoutOrgans()
	return self:GetNW2String('Class') == "Zombie" or self:GetNW2String('Class') == "Maniac"
end

function meta2:HaveStability()
	if self:IsPlayer() then
		return self:GetNW2String('Class') == "Killer" or self:GetNW2String('Class') == "Traitor"
	else
		return self:GetNW2String('Class') == "Killer" or self:GetNW2String('Class') == "Traitor"
	end
end

function meta2:IsKiller()
	return self:GetNW2String('Class') == "Shooter" or self:GetNW2String('Class') == "Terrorist" or self:GetNW2String('Class') == "Maniac" or self:GetNW2String('Class') == "Killer" or self:GetNW2String('Class') == "Traitor"
end

function meta2:IsActiveKiller()
	return self:GetNW2String('Class') == "Shooter" or self:GetNW2String('Class') == "Terrorist" or self:GetNW2String('Class') == "Maniac"
end

function MuR:CheckCollision(pos, ply)
	if !isvector(pos) and IsValid(ply) then
		pos = ply:GetPos()
	end
	local tr = util.TraceHull({
		start = pos,
		endpos = pos,
		filter = function(ent)
			return ent:GetClass() != "prop_ragdoll" and (IsValid(ply) and ent != ply or !IsValid(ply))
		end,
		mins = Vector(-16, -16, 0),
		maxs = Vector(16, 16, 72),
		mask = MASK_PLAYERSOLID,
	})
	return tr.Hit, tr.Entity
end

function MuR:GetAlivePlayers()
	local tab, tab2 = {}, player.GetAll()

	for i = 1, #tab2 do
		if tab2[i]:Alive() then
			tab[#tab + 1] = tab2[i]
		end
	end

	return tab
end

function MuR:VisibleByNPCs(pos)
	local tab = ents.FindByClass("npc_combine_s")

	for i = 1, #tab do
		local ent = tab[i]

		local tr = util.TraceLine({
			start = ent:EyePos(),
			endpos = pos,
			filter = function(ent)
				if ent:IsPlayer() or ent:IsNPC() then
					return false
				else
					return true
				end
			end,
			mask = MASK_SHOT,
		})

		if not tr.Hit and pos:DistToSqr(ent:GetPos()) <= 500 ^ 2 then return true end
	end

	return false
end

function MuR:VisibleByPlayers(ply, ent1)
	local tab = MuR:GetAlivePlayers()

	for i = 1, #tab do
		local ent = tab[i]
		if ent == ply or ent == ent1 then continue end

		local tr = util.TraceLine({
			start = ent:EyePos(),
			endpos = ply:WorldSpaceCenter(),
			filter = function(ent)
				if ent:IsPlayer() or ent:IsNPC() then
					return false
				else
					return true
				end
			end,
			mask = MASK_SHOT,
		})

		if not tr.Hit then return true end
	end

	return false
end

function MuR:DisablesGamemode()
	local def = MuR.Mode and MuR.Mode(MuR.Gamemode) or {}
	if def.disables ~= nil then return def.disables end
	return MuR.Gamemode == 5 or MuR.Gamemode == 6 or MuR.Gamemode == 11 or MuR.Gamemode == 12 or MuR.Gamemode == 13 or MuR.Gamemode == 14 or MuR.Gamemode == 17
end

function MuR:DisableWeaponLoot()
	local def = MuR.Mode and MuR.Mode(MuR.Gamemode) or {}
	if def.disable_loot ~= nil then return def.disable_loot end
	return MuR.Gamemode == 2 or MuR.Gamemode == 3 or MuR.Gamemode == 10
end

function MuR:CountNPCPolice(alive)
	local count = MuR.NPC_To_Spawn
	if alive then
		count = 0
	end
	return count+#ents.FindByClass("npc_vj_bloodshed_*")
end

function MuR:CountPlayerPolice()
	local tab = player.GetAll()
	local alive = 0
	local dead = 0
	for i=1,#tab do
		local ply = tab[i]
		if ply:GetNW2String('Class') == "ArmoredOfficer" or ply:GetNW2String('Class') == 'Officer' then
			if ply:Alive() then
				alive = alive + 1
			else
				dead = dead + 1
			end
		end
	end
	return alive, dead
end

hook.Add("SetupMove", "MuR.AimSpeed", function(ply, mvd, cmd)
	local wep = ply:GetActiveWeapon()

	if IsValid(wep) and wep:GetNW2Bool('Aiming') then
		mvd:SetMaxSpeed(50)
		mvd:SetMaxClientSpeed(50)
	end
	if string.match(ply:GetSVAnim(), "sequence_ron_") then
		mvd:SetMaxSpeed(1)
		mvd:SetMaxClientSpeed(1)
	end
end)

hook.Add("EntityEmitSound", "MuR.BlockPickupSound", function(t)
	if t.SoundName == "items/ammo_pickup.wav" then
		return false
	end
end)

local function FindModelsRecursive(path)
    local models = {}
    local files, folders = file.Find(path .. "/*", "WORKSHOP")
    for _, f in ipairs(files) do
        if string.EndsWith(f, ".mdl") then
            table.insert(models, path .. "/" .. f)
        end
    end
    for _, folder in ipairs(folders) do
        local subModels = FindModelsRecursive(path .. "/" .. folder)
        for _, m in ipairs(subModels) do
            table.insert(models, m)
        end
    end
    return models
end

local precachedModels = 0
local allModels = FindModelsRecursive("models")
for _, mdl in ipairs(allModels) do
    if precachedModels > 4096 then break end
    util.PrecacheModel(mdl)
    precachedModels = precachedModels + 1
end
print("[Bloodshed: Redux] Precached " .. precachedModels .. " models.")