-- Network Profiler - показывает сетевую нагрузку в реальном времени
-- Включить: mur_netprofiler 1
-- Выключить: mur_netprofiler 0

local netStats = {}
local totalBytes = 0
local lastReset = CurTime()
local RESET_INTERVAL = 5

local enabled = CreateClientConVar("mur_netprofiler", "0", false, false, "Enable network profiler overlay")

-- Хук на все входящие net сообщения
local oldNetReceive = net.Receive
function net.Receive(name, callback)
    oldNetReceive(name, function(len, ply)
        if enabled:GetBool() then
            local bytes = len / 8
            netStats[name] = netStats[name] or {count = 0, bytes = 0, lastBytes = 0}
            netStats[name].count = netStats[name].count + 1
            netStats[name].bytes = netStats[name].bytes + bytes
            netStats[name].lastTime = CurTime()
            totalBytes = totalBytes + bytes
        end
        callback(len, ply)
    end)
end

-- Отслеживание исходящих (от клиента к серверу)
local oldNetStart = net.Start
local currentMessage = nil
function net.Start(name, unreliable)
    currentMessage = name
    return oldNetStart(name, unreliable)
end

local oldSendToServer = net.SendToServer
function net.SendToServer()
    if enabled:GetBool() and currentMessage then
        local name = "[OUT] " .. currentMessage
        netStats[name] = netStats[name] or {count = 0, bytes = 0, lastBytes = 0}
        netStats[name].count = netStats[name].count + 1
        netStats[name].bytes = netStats[name].bytes + net.BytesWritten()
        netStats[name].lastTime = CurTime()
    end
    currentMessage = nil
    return oldSendToServer()
end

-- NW2 переменные (приблизительная оценка)
local nw2Stats = {}
hook.Add("EntityNetworkedVarChanged", "MuR_NetProfiler_NW2", function(ent, name, old, new)
    if not enabled:GetBool() then return end
    local key = "[NW2] " .. name
    nw2Stats[key] = nw2Stats[key] or {count = 0, lastTime = 0}
    nw2Stats[key].count = nw2Stats[key].count + 1
    nw2Stats[key].lastTime = CurTime()
end)

-- Рендер оверлея
hook.Add("HUDPaint", "MuR_NetProfiler", function()
    if not enabled:GetBool() then return end
    
    -- Сброс статистики каждые N секунд
    if CurTime() - lastReset > RESET_INTERVAL then
        for k, v in pairs(netStats) do
            v.lastBytes = v.bytes
            v.bytes = 0
            v.count = 0
        end
        for k, v in pairs(nw2Stats) do
            v.count = 0
        end
        totalBytes = 0
        lastReset = CurTime()
    end
    
    -- Сортировка по байтам
    local sorted = {}
    for name, data in pairs(netStats) do
        table.insert(sorted, {name = name, bytes = data.bytes, count = data.count, bps = data.bytes / RESET_INTERVAL})
    end
    table.sort(sorted, function(a, b) return a.bytes > b.bytes end)
    
    -- Сортировка NW2
    local sortedNW2 = {}
    for name, data in pairs(nw2Stats) do
        table.insert(sortedNW2, {name = name, count = data.count, cps = data.count / RESET_INTERVAL})
    end
    table.sort(sortedNW2, function(a, b) return a.count > b.count end)
    
    local x, y = 10, 100
    local lineHeight = 18
    
    -- Заголовок
    draw.RoundedBox(8, x - 5, y - 25, 500, 30, Color(0, 0, 0, 200))
    draw.SimpleText("🌐 NETWORK PROFILER (last " .. RESET_INTERVAL .. "s)", "DermaDefaultBold", x, y - 20, Color(255, 200, 0))
    draw.SimpleText("Total: " .. string.NiceSize(totalBytes) .. " (" .. math.Round(totalBytes / RESET_INTERVAL, 1) .. " B/s)", "DermaDefault", x + 250, y - 20, Color(200, 200, 200))
    
    y = y + 15
    
    -- Net сообщения
    draw.RoundedBox(8, x - 5, y - 5, 500, math.min(#sorted, 15) * lineHeight + 25, Color(0, 0, 0, 180))
    draw.SimpleText("NET MESSAGES:", "DermaDefaultBold", x, y, Color(100, 200, 255))
    y = y + lineHeight
    
    for i = 1, math.min(#sorted, 15) do
        local data = sorted[i]
        local col = data.bytes > 1000 and Color(255, 100, 100) or 
                    data.bytes > 200 and Color(255, 200, 100) or 
                    Color(100, 255, 100)
        
        local text = string.format("%-35s %6s  %4d msgs  %5.0f B/s", 
            string.sub(data.name, 1, 35), 
            string.NiceSize(data.bytes), 
            data.count,
            data.bps)
        draw.SimpleText(text, "DermaDefault", x, y, col)
        y = y + lineHeight
    end
    
    y = y + 10
    
    -- NW2 переменные
    if #sortedNW2 > 0 then
        draw.RoundedBox(8, x - 5, y - 5, 500, math.min(#sortedNW2, 10) * lineHeight + 25, Color(0, 0, 0, 180))
        draw.SimpleText("NW2 VARIABLES (updates):", "DermaDefaultBold", x, y, Color(200, 100, 255))
        y = y + lineHeight
        
        for i = 1, math.min(#sortedNW2, 10) do
            local data = sortedNW2[i]
            local col = data.cps > 20 and Color(255, 100, 100) or 
                        data.cps > 5 and Color(255, 200, 100) or 
                        Color(100, 255, 100)
            
            local text = string.format("%-35s %4d updates  %5.1f/s", 
                string.sub(data.name, 1, 35), 
                data.count,
                data.cps)
            draw.SimpleText(text, "DermaDefault", x, y, col)
            y = y + lineHeight
        end
    end
end)

print("[MuR] Network Profiler loaded. Use 'mur_netprofiler 1' to enable.")
