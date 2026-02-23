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

hook.Add("InitPostEntity", "TryFindAINodes", function()
	timer.Simple(5, function()
		if #MuR.AI_Nodes > 0 then return end
		MuR.EnableDebug = true 
		hook.Add("PlayerInitialSpawn", "BlockGameMuRNodes", function(ply)
			net.Start("MuR.NoNodes")
			net.Send(ply)
		end)
		net.Start("MuR.NoNodes")
		net.Broadcast()
	end)

	if found_ai_nodes then return end
	f = file.Open("maps/graphs/" .. game.GetMap() .. ".ain", "rb", "GAME")
	if not f then return end
	found_ai_nodes = true
	local ainet_ver = ReadInt(f)
	local map_ver = ReadInt(f)

	if ainet_ver ~= AINET_VERSION_NUMBER then
		MsgN("Unknown graph file")

		return
	end

	local numNodes = ReadInt(f)

	if numNodes < 0 then
		MsgN("Graph file has an unexpected amount of nodes")

		return
	end

	for i = 1, numNodes do
		local v = Vector(f:ReadFloat(), f:ReadFloat(), f:ReadFloat())
		local yaw = f:ReadFloat()
		local flOffsets = {}

		for i = 1, NUM_HULLS do
			flOffsets[i] = f:ReadFloat()
		end

		local nodetype = f:ReadByte()
		local nodeinfo = ReadUShort(f)
		local zone = f:ReadShort()

		if nodetype == 4 or nodetype == 3 then
			goto cont
		end

		local node = {
			pos = v,
			yaw = yaw,
			offset = flOffsets,
			type = nodetype,
			info = nodeinfo,
			zone = zone,
			neighbor = {},
			numneighbors = 0,
			link = {},
			numlinks = 0
		}

		table.insert(MuR.AI_Nodes, node.pos)
		::cont::
	end
end)

function MuR:GetRandomPos(underroof, frompos, mindist, maxdist, withoutply)
	local newtab = {}
	local tab = MuR.AI_Nodes

	if #tab > 0 then
		for i = 1, #tab do
			local pos = tab[i]

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

			if not withoutply then
				local visible = false
				local tab = player.GetAll()

				for i = 1, #tab do
					local ply = tab[i]

					if ply:Alive() and (ply:GetPos():DistToSqr(pos) < 50000 or ply:VisibleVec(pos)) then
						visible = true
						break
					end
				end
			end

			if visible then continue end
			table.insert(newtab, pos)
		end
	end

	if #newtab > 0 then
		return newtab[math.random(1, #newtab)]
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
        local pos = MuR.AI_Nodes[i]
        
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