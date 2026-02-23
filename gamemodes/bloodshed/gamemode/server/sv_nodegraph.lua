MuR.AI_Nodes = MuR.AI_Nodes or {}
util.AddNetworkString("MuR.NoNodes")
local found_ai_nodes = false
local M = {}
local SIZEOF_INT = 4
local SIZEOF_SHORT = 2
local AINET_VERSION_NUMBER = 37

local function toUShort(b)
	local i = {string.byte(b, 1, SIZEOF_SHORT)}

	return i[1] + i[2] * 256
end

local function toInt(b)
	local i = {string.byte(b, 1, SIZEOF_INT)}

	i = i[1] + i[2] * 256 + i[3] * 65536 + i[4] * 16777216
	if i > 2147483647 then return i - 4294967296 end

	return i
end

local function ReadInt(f)
	return toInt(f:Read(SIZEOF_INT))
end

local function ReadUShort(f)
	return toUShort(f:Read(SIZEOF_SHORT))
end

timer.Create("TryFindAINodes", 3, 0, function()
	if player.GetCount() == 0 then return end

	if istable(VJ_Nodegraph.Data) and #VJ_Nodegraph.Data.Nodes > 0 then 
		local tab = VJ_Nodegraph.Data.Nodes
		local filtered = {}
		for i = 1, #tab do
			if tab[i].type == 2 then
				table.insert(filtered, tab[i])
			end
		end
		MuR.AI_Nodes = filtered
		timer.Remove("TryFindAINodes")
		return
	end 

end)

function MuR:GetRandomPos(underroof, frompos, mindist, maxdist, withoutply)
	local hidden_nodes = {}
	local visible_nodes = {}
	local tab = MuR.AI_Nodes

	if #tab > 0 then
		for i = 1, #tab do
			local pos = tab[i].pos

			local tr = util.TraceLine({
				start = pos,
				endpos = pos + Vector(0, 0, 9999),
			})

			local tr2 = util.TraceHull({
				start = pos + Vector(0, 0, 2),
				endpos = pos + Vector(0, 0, 2),
				filter = function(ent) return true end,
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 72),
				mask = MASK_SHOT_HULL,
			})

			if underroof != nil then
				if tr.HitSky and underroof or not tr.HitSky and not underroof or tr2.Hit then continue end
			end

			if frompos then
				local dist = frompos:DistToSqr(pos)
				if dist < mindist ^ 2 or dist > maxdist ^ 2 then continue end
			end

			local is_visible = false
			if not withoutply then
				local players = player.GetAll()

				for j = 1, #players do
					local ply = players[j]

					local pos2 = pos + Vector(0, 0, 64)
					if ply:Alive() and (ply:GetPos():DistToSqr(pos) < 100000 or ply:VisibleVec(pos) or ply:VisibleVec(pos2)) then
						is_visible = true
						break
					end
				end
			end

			if is_visible then
				table.insert(visible_nodes, pos)
			else
				table.insert(hidden_nodes, pos)
			end
		end
	end

	if #hidden_nodes > 0 then
		return hidden_nodes[math.random(1, #hidden_nodes)]
	elseif #visible_nodes > 0 then
		return visible_nodes[math.random(1, #visible_nodes)]
	else
		return nil
	end
end

function MuR:FindTwoDistantSpawnLocations(minDistance, maxAttempts)
    minDistance = minDistance or 1500
    maxAttempts = maxAttempts or 100

    if #MuR.AI_Nodes == 0 then
        return nil, nil
    end

    local validNodes = {}

    for i = 1, #MuR.AI_Nodes do
        local pos = MuR.AI_Nodes[i].pos

        local tr = util.TraceLine({
            start = pos,
            endpos = pos + Vector(0, 0, 9999),
        })

        local tr2 = util.TraceHull({
            start = pos + Vector(0, 0, 2),
            endpos = pos + Vector(0, 0, 2),
            filter = function(ent) return true end,
            mins = Vector(-16, -16, 0),
            maxs = Vector(16, 16, 72),
            mask = MASK_SHOT_HULL,
        })

        local visibleToPlayer = false
        local players = player.GetAll()
        for j = 1, #players do
            local ply = players[j]
            if ply:Alive() and (ply:GetPos():DistToSqr(pos) < 50000 or ply:VisibleVec(pos)) then
                visibleToPlayer = true
                break
            end
        end

        if not tr2.Hit and not visibleToPlayer then
            table.insert(validNodes, pos)
        end
    end

    if #validNodes < 2 then
        return nil, nil
    end

    local attempts = 0
    local firstPos, secondPos

    while attempts < maxAttempts do
        attempts = attempts + 1

        local firstIndex = math.random(1, #validNodes)
        firstPos = validNodes[firstIndex]

        local candidateNodes = {}
        for i = 1, #validNodes do
            if i ~= firstIndex then
                local pos = validNodes[i]
                local distSqr = firstPos:DistToSqr(pos)

                if distSqr >= minDistance * minDistance then
                    local tr = util.TraceLine({
                        start = firstPos + Vector(0, 0, 50),
                        endpos = pos + Vector(0, 0, 50),
                        mask = MASK_SOLID_BRUSHONLY
                    })

                    if tr.Hit then
                        table.insert(candidateNodes, pos)
                    end
                end
            end
        end

        if #candidateNodes > 0 then
            secondPos = candidateNodes[math.random(1, #candidateNodes)]
            return firstPos, secondPos
        end
    end

    return nil, nil
end

function MuR:FindPositionInRadius(pos, dist)
	local spawnPositions = {}
	local trace = {}
	trace.start = pos
	trace.mask = MASK_SOLID

	trace.filter = function(ent)
		if ent:IsPlayer() or ent:IsNPC() or string.match(ent:GetClass(), "_door") then
			return false
		else
			return true
		end
	end

	trace.endpos = pos - Vector(0, 0, 1000)
	local result = util.TraceLine(trace)

	if result.Hit then
		local floorPos = result.HitPos
		trace.endpos = floorPos + Vector(0, 0, 1000)
		result = util.TraceLine(trace)

		if result.Hit then
			local ceilingPos = result.HitPos
			local height = math.abs(ceilingPos.z - floorPos.z)

			for i = 0, 360 do
				local offset = Vector(math.random(-dist, dist), math.random(-dist, dist), 0)
				local spawnPos = floorPos + offset + Vector(0, 0, height / 2)
				trace.start = spawnPos
				trace.endpos = spawnPos + Vector(0, 0, 1000)
				result = util.TraceLine(trace)

				if result.Hit then
					trace.start = result.HitPos
					trace.endpos = result.HitPos - Vector(0, 0, 1000)
					result = util.TraceLine(trace)

					if result.Hit and result.HitPos.z - pos.z >= 4 then
						table.insert(spawnPositions, result.HitPos + Vector(0, 0, 8))
					end
				end
			end
		end
	end

	return table.Random(spawnPositions)
end

function MuR:FindNearbySpawnPosition(basePos, maxDistance)
	maxDistance = maxDistance or 500

	if not isvector(basePos) or #MuR.AI_Nodes == 0 then
		return basePos
	end

	local nearbyNodes = {}

	for i = 1, #MuR.AI_Nodes do
		local pos = MuR.AI_Nodes[i].pos
		local distSqr = basePos:DistToSqr(pos)

		if distSqr <= maxDistance * maxDistance then
			local tr2 = util.TraceHull({
				start = pos + Vector(0, 0, 2),
				endpos = pos + Vector(0, 0, 2),
				filter = function(ent) return true end,
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 72),
				mask = MASK_SHOT_HULL,
			})

			if not tr2.Hit then
				local visibleToPlayer = false
				local players = player.GetAll()
				for j = 1, #players do
					local ply = players[j]
					if ply:Alive() and ply:GetPos():DistToSqr(pos) < 40000 then
						visibleToPlayer = true
						break
					end
				end

				if not visibleToPlayer then
					table.insert(nearbyNodes, {pos = pos, dist = distSqr})
				end
			end
		end
	end

	if #nearbyNodes > 0 then
		table.SortByMember(nearbyNodes, "dist", true)
		local selectedIndex = math.random(1, math.min(5, #nearbyNodes))
		return nearbyNodes[selectedIndex].pos
	end

	return basePos
end

function MuR:FindFarthestSpawnFromPlayers()
	if #MuR.AI_Nodes == 0 then
		return nil
	end

	local alivePlayers = {}
	for _, ply in player.Iterator() do
		if ply:Alive() then
			table.insert(alivePlayers, ply)
		end
	end

	if #alivePlayers == 0 then
		return MuR:GetRandomPos()
	end

	local bestPos = nil
	local bestMinDist = 0

	for i = 1, #MuR.AI_Nodes do
		local pos = MuR.AI_Nodes[i].pos

		local tr2 = util.TraceHull({
			start = pos + Vector(0, 0, 2),
			endpos = pos + Vector(0, 0, 2),
			filter = function(ent) return true end,
			mins = Vector(-16, -16, 0),
			maxs = Vector(16, 16, 72),
			mask = MASK_SHOT_HULL,
		})

		if tr2.Hit then continue end

		local minDistToPlayer = math.huge
		local isVisible = false

		for _, ply in ipairs(alivePlayers) do
			local distSqr = ply:GetPos():DistToSqr(pos)
			if distSqr < minDistToPlayer then
				minDistToPlayer = distSqr
			end
			if ply:VisibleVec(pos) or ply:VisibleVec(pos + Vector(0, 0, 64)) then
				isVisible = true
			end
		end

		if not isVisible and minDistToPlayer > bestMinDist then
			bestMinDist = minDistToPlayer
			bestPos = pos
		end
	end

	return bestPos or MuR:GetRandomPos()
end