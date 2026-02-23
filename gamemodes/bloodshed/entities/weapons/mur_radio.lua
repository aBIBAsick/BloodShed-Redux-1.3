if SERVER then
    AddCSLuaFile()
else
    SWEP.PrintName = "Radio"
    SWEP.Slot = 4
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
end

SWEP.DrawWeaponInfoBox = false
SWEP.ViewModel = "models/murdered/weapons/v_dp4800.mdl"
SWEP.WorldModel = "models/murdered/weapons/w_dp4800.mdl"
SWEP.ViewModelFOV = 60
SWEP.UseHands = true
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "Bloodshed - Civilian"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

local MAX_CHANNELS = 999
local POLICE_CHANNEL = 1024
local RADIO_RANGE = 8000
local BATTERY_DRAIN = 0.1
local TEMPERATURE_NORMAL = 35
local TEMPERATURE_MAX = 55
local INTERFERENCE_RANGE = 1000
local TEMPERATURE_INCREASE = 0.05

RADIO_PLAYERS = RADIO_PLAYERS or {}
RADIO_CHANNELS = RADIO_CHANNELS or {}
RADIO_PLAYER_SETTINGS = RADIO_PLAYER_SETTINGS or {}

RADIO_INTERFERENCE_SOURCES = RADIO_INTERFERENCE_SOURCES or {}
RADIO_CHAT_HISTORY = RADIO_CHAT_HISTORY or {}

local function GetPlayerRadioSettings(ply)
    if not IsValid(ply) then return nil end
    
    if not RADIO_PLAYER_SETTINGS[ply] then
        RADIO_PLAYER_SETTINGS[ply] = {
            showHUD = true,
            autoShutdown = true,
            enableChat = true
        }
    end
    
    return RADIO_PLAYER_SETTINGS[ply]
end

local radioSounds = {
    on = ")murdered/radio/on.mp3",
    off = ")murdered/radio/off.mp3",
    switch = "murdered/radio/switch.mp3",
    static = "murdered/radio/static.wav",
    beep = "murdered/radio/message.mp3",
    click = "murdered/vgui/ui_click.wav",
    repair = "murdered/other/ducttape.mp3",
    cool = "murdered/other/taser_reload.mp3",
    error = "murdered/vgui/ui_return.wav"
}

local function InitRadioData(radio)
    if not IsValid(radio) then return end
    radio.RadioData = {
        on = false,
        channel = 1,
        battery = 100,
        signal = 0,
        lastUse = CurTime(),
        temperature = TEMPERATURE_NORMAL,
        signalQuality = 100,
        interference = 0,
        needsRepair = false,
        lastRepairTime = 0,
        lastStatusUpdate = 0,
        serialNumber = "RD-" .. math.random(1000, 9999) .. "-" .. math.random(100, 999)
    }
end

local function GetRadioData(radio)
    if not IsValid(radio) then return nil end
    if not radio.RadioData then
        InitRadioData(radio)
    else
        local data = radio.RadioData
        if not data.lastStatusUpdate then data.lastStatusUpdate = 0 end
        if not data.serialNumber then 
            data.serialNumber = "RD-" .. math.random(1000, 9999) .. "-" .. math.random(100, 999)
        end
    end
    return radio.RadioData
end

local function CalculateInterference(ply)
    if not IsValid(ply) then return 0 end
    
    local interference = 0
    local plyPos = ply:GetPos()
    
    for source, data in pairs(RADIO_INTERFERENCE_SOURCES) do
        if IsValid(source) then
            local dist = plyPos:Distance(source:GetPos())
            if dist < INTERFERENCE_RANGE then
                interference = interference + (data.strength * (1 - dist / INTERFERENCE_RANGE))
            end
        else
            RADIO_INTERFERENCE_SOURCES[source] = nil
        end
    end
    
    local weather = game.GetWorld():GetNWFloat("WeatherIntensity", 0)
    interference = interference + (weather * 20)
    
    local radioCount = 0
    for _, p in ipairs(player.GetAll()) do
        if IsValid(p) and p ~= ply then
            local pWep = p:GetActiveWeapon()
            if IsValid(pWep) and pWep:GetClass() == "mur_radio" then
                local pData = GetRadioData(pWep)
                if pData and pData.on and plyPos:Distance(p:GetPos()) < 500 then
                    radioCount = radioCount + 1
                end
            end
        end
    end
    interference = interference + (radioCount * 5)
    
    return math.min(100, interference)
end

local function CalculateSignalQuality(ply, data)
    if not IsValid(ply) or not data then return 0 end
    
    local baseQuality = 100
    
    baseQuality = baseQuality - data.interference
    
    if data.temperature > 45 then
        baseQuality = baseQuality - ((data.temperature - 45) * 5)
    end
    
    if data.needsRepair then
        baseQuality = baseQuality - 40
    end
    
    if data.battery < 20 then
        baseQuality = baseQuality - (20 - data.battery)
    end
    
    return math.max(0, math.min(100, baseQuality))
end

function SWEP:Initialize()
    self:SetHoldType("slam")
    self:SetNWBool("RadioOn", false)
    self:SetNWInt("RadioChannel", 1)
    self:SetNWFloat("RadioBattery", 100)
    self:SetNWFloat("RadioSignal", 0)
    
    if SERVER then
        InitRadioData(self)
        local data = GetRadioData(self)
        if data then
            self:SetNWString("RadioSerial", data.serialNumber)
        end
    end
    
    if CLIENT then
        self.RadioGUI = nil
        self.LastBlink = CurTime()
        self.BlinkState = true
        self.SignalAnimation = 0
    end
end

function SWEP:Deploy()
    if SERVER then
        local data = GetRadioData(self)
        if data then
            self:SetNWBool("RadioOn", data.on)
            self:SetNWInt("RadioChannel", data.channel)
            self:SetNWFloat("RadioBattery", data.battery)
            self:SetNWFloat("RadioTemperature", data.temperature)
            self:SetNWFloat("RadioInterference", data.interference)
            self:SetNWFloat("RadioQuality", data.signalQuality)
            self:SetNWBool("RadioNeedsRepair", data.needsRepair)
        end
    end
    
    return true
end

function SWEP:Holster() 
    if CLIENT and IsValid(self.RadioGUI) then
        self.RadioGUI:Remove()
        self.RadioGUI = nil
    end
    
    return true
end

function SWEP:OnRemove()
    if SERVER then
        local ply = self:GetOwner()
        if IsValid(ply) and RADIO_PLAYERS[ply] then
            RADIO_PLAYERS[ply] = nil
        end
    end
    
    if CLIENT and IsValid(self.RadioGUI) then
        self.RadioGUI:Remove()
        self.RadioGUI = nil
    end
end

function SWEP:Think()
    if SERVER then
        local ply = self:GetOwner()
        if IsValid(ply) then
            local data = GetRadioData(self)
            local playerSettings = GetPlayerRadioSettings(ply)
            if data then
                if data.on and (data.battery or 0) > 0 then
                    data.battery = math.max(0, (data.battery or 100) - BATTERY_DRAIN * FrameTime())
                    self:SetNWFloat("RadioBattery", data.battery)
                    
                    local oldTemp = data.temperature
                    data.temperature = data.temperature + (TEMPERATURE_INCREASE * FrameTime())
                    
                    if data.temperature > TEMPERATURE_MAX then
                        data.temperature = TEMPERATURE_MAX
                        if math.random() < 0.001 then
                            data.needsRepair = true
                            self:SetNWBool("RadioNeedsRepair", true)
                        end
                    end
                    
                    if data.battery <= 0 and playerSettings.autoShutdown then
                        data.on = false
                        self:SetNWBool("RadioOn", false)
                    end
                else
                    data.temperature = math.max(TEMPERATURE_NORMAL, data.temperature - (0.2 * FrameTime()))
                end
                
                if CurTime() - data.lastStatusUpdate >= 10 then
                    data.interference = CalculateInterference(ply)
                    data.signalQuality = CalculateSignalQuality(ply, data)
                    data.lastStatusUpdate = CurTime()
                end
                
                local signal = math.random(80, 100)
                if data.needsRepair then
                    signal = signal * 0.4
                end
                if data.temperature > 45 then
                    signal = signal * 0.7
                end
                
                data.signal = signal
                self:SetNWFloat("RadioSignal", signal)
                self:SetNWFloat("RadioTemperature", data.temperature)
                self:SetNWFloat("RadioInterference", data.interference)
                self:SetNWFloat("RadioQuality", data.signalQuality)
                
                if ply.IsRolePolice and ply:IsRolePolice() and data.channel ~= POLICE_CHANNEL then
                    data.channel = POLICE_CHANNEL
                    self:SetNWInt("RadioChannel", POLICE_CHANNEL)
                end
            end
        end
    end
    
    if CLIENT then
        self.SignalAnimation = math.sin(CurTime() * 3) * 10
    end
end

function SWEP:PrimaryAttack()
    if CLIENT then return end
    
    local ply = self:GetOwner()
    local data = GetRadioData(self)
    local playerSettings = GetPlayerRadioSettings(ply)
    if not data then return end
    
    if not data.battery or data.battery <= 0 then
        return
    end
    
    if data.needsRepair then
        return
    end
    
    local state = not data.on
    data.on = state
    self:SetNWBool("RadioOn", state)
    
    self:SetNextPrimaryFire(CurTime() + 0.5)
    
    local sound = state and radioSounds.on or radioSounds.off
    ply:EmitSound(sound, 60, 100)
end

function SWEP:SecondaryAttack()
    if CLIENT then
        self:OpenRadioGUI()
    end
    self:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:Reload()
    return false
end

if SERVER then
    util.AddNetworkString("RadioChangeChannel")
    util.AddNetworkString("RadioTogglePower")
    util.AddNetworkString("RadioRepair")
    util.AddNetworkString("RadioCool")
    util.AddNetworkString("RadioChatMessage")
    util.AddNetworkString("RadioSyncHistory")
    util.AddNetworkString("RadioUpdateSettings")
    util.AddNetworkString("RadioNoices")

    local function CorruptText(message, qualityReduction)
        if not isstring(message) or not isnumber(qualityReduction) then return message end
        qualityReduction = math.Clamp(qualityReduction, 0, 1)

        local corrupted = {}
        for i = 1, #message do
            local char = message[i]
            if math.random() < qualityReduction then
                local rand = math.random()
                if rand < 0.2 then
                    char = " "
                elseif rand < 0.6 then
                    char = string.char(math.random(33, 126))
                else
                    char = ""
                end
            end
            table.insert(corrupted, char)
        end

        return table.concat(corrupted)
    end
    
    net.Receive("RadioChangeChannel", function(len, ply)
        if not IsValid(ply) then return end
        
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "mur_radio" then return end
        
        local channel = net.ReadInt(16)
        if channel < 0 or channel > MAX_CHANNELS then return end
        
        if ply.IsRolePolice and ply:IsRolePolice() then
            return
        end
        
        local data = GetRadioData(wep)
        local playerSettings = GetPlayerRadioSettings(ply)
        if not data then return end
        
        data.channel = channel
        wep:SetNWInt("RadioChannel", channel)
        
        wep:EmitSound(radioSounds.switch, 70, 100)
    end)

    net.Receive("RadioTogglePower", function(len, ply)
        if not IsValid(ply) then return end
        
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "mur_radio" then return end
        
        local data = GetRadioData(wep)
        local playerSettings = GetPlayerRadioSettings(ply)
        if not data then return end
        
        if not data.battery or data.battery <= 0 then
            wep:EmitSound(radioSounds.error, 60, 100)
            return
        end
        
        if data.needsRepair then
            return
        end
        
        local state = not data.on
        data.on = state
        wep:SetNWBool("RadioOn", state)
        
        local sound = state and radioSounds.on or radioSounds.off
        wep:EmitSound(sound, 70, 100)
    end)

    net.Receive("RadioRepair", function(len, ply)
        if not IsValid(ply) then return end
        
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "mur_radio" then return end
        
        local data = GetRadioData(wep)
        if not data then return end
        
        data.needsRepair = false
        data.temperature = TEMPERATURE_NORMAL
        wep:SetNWBool("RadioNeedsRepair", false)
    end)

    net.Receive("RadioCool", function(len, ply)
        if not IsValid(ply) then return end
        
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "mur_radio" then return end
        
        local data = GetRadioData(wep)
        if not data then return end
        
        data.temperature = TEMPERATURE_NORMAL
        wep:SetNWFloat("RadioTemperature", TEMPERATURE_NORMAL)
    end)

    net.Receive("RadioChatMessage", function(len, ply)
        if not IsValid(ply) then return end
        
        local playerSettings = GetPlayerRadioSettings(ply)
        if not playerSettings.enableChat then return end
        
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "mur_radio" then return end
        
        local data = GetRadioData(wep)
        if not data or not data.on or data.battery <= 0 or data.needsRepair then 
            wep:EmitSound(radioSounds.error, 60, 100)
            return
        end
        
        local message = net.ReadString()
        if string.len(message) == 0 then return end
        
        local talkerData = data
        local talkerPos = ply:GetPos()
        local talkerChannel = talkerData.channel
        local talkerSerial = talkerData.serialNumber or "RD-UNKN"
        
        if not RADIO_CHAT_HISTORY[talkerChannel] then
            RADIO_CHAT_HISTORY[talkerChannel] = {}
        end

        wep:EmitSound(radioSounds.beep, 70, 100)

        table.insert(RADIO_CHAT_HISTORY[talkerChannel], {
            sender = talkerSerial,
            text = message,
            time = os.time(),
            color = Color(150, 200, 255),
            original = true
        })
        
        if #RADIO_CHAT_HISTORY[talkerChannel] > 50 then
            table.remove(RADIO_CHAT_HISTORY[talkerChannel], 1)
        end
        
        for _, listener in ipairs(player.GetAll()) do
            if IsValid(listener) and listener ~= ply then
                local listenerWep = listener:GetActiveWeapon()
                if IsValid(listenerWep) and listenerWep:GetClass() == "mur_radio" then
                    local listenerData = GetRadioData(listenerWep)
                    local listenerSettings = GetPlayerRadioSettings(listener)
                    
                    if listenerData and listenerData.on and 
                       listenerData.channel == talkerData.channel and
                       listenerData.battery > 0 and not listenerData.needsRepair then
                        
                        local dist = talkerPos:Distance(listener:GetPos())
                        if dist <= RADIO_RANGE then
                            local talkerQuality = math.max(0, talkerData.signalQuality or 100)
                            local listenerQuality = math.max(0, listenerData.signalQuality or 100)
                            local overallQuality = math.min(talkerQuality, listenerQuality)
                            
                            local qualityReduction = (100 - overallQuality) / 100
                            
                            if math.Rand(0, 1) > qualityReduction then
                                local corruptedMessage = CorruptText(message, qualityReduction)
                                local corruptedSerial = talkerSerial
                                
                                if qualityReduction > 0.5 then
                                    corruptedSerial = CorruptText(talkerSerial, qualityReduction * 0.4)
                                end
                                
                                local color = Color(100, 255, 150)
                                if qualityReduction > 0.3 then
                                    color = Color(255, 200, 100)
                                end
                                if qualityReduction > 0.6 then
                                    color = Color(255, 100, 100)
                                end
                                
                                listenerWep:EmitSound(radioSounds.beep, 60, 90)
                                
                                net.Start("RadioSyncHistory")
                                net.WriteInt(talkerChannel, 16)
                                net.WriteString(corruptedSerial)
                                net.WriteString(corruptedMessage)
                                net.WriteInt(os.time(), 32)
                                net.WriteColor(color)
                                net.WriteBool(false)
                                net.Send(listener)
                            end
                        end
                    end
                end
            end
        end
        
        net.Start("RadioSyncHistory")
        net.WriteInt(talkerChannel, 16)
        net.WriteString(talkerSerial)
        net.WriteString(message)
        net.WriteInt(os.time(), 32)
        net.WriteColor(Color(150, 200, 255))
        net.WriteBool(true)
        net.Send(ply)
    end)

    hook.Add("PlayerSay", "RadioChat", function(ply, text, team)
        if not IsValid(ply) then return end
        if not string.StartWith(text, "/r ") and not string.StartWith(text, "!r ") then return end
        
        local playerSettings = GetPlayerRadioSettings(ply)
        if not playerSettings.enableChat then return "" end
        
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "mur_radio" then return "" end
        
        local data = GetRadioData(wep)
        if not data or not data.on or data.battery <= 0 or data.needsRepair then 
            wep:EmitSound(radioSounds.error, 60, 100)
            return ""
        end
        
        local message = string.sub(text, 4)
        if string.len(message) == 0 then return "" end
        
        local talkerData = data
        local talkerPos = ply:GetPos()
        local talkerChannel = talkerData.channel
        local talkerSerial = talkerData.serialNumber or "RD-UNKN"
        
        wep:EmitSound(radioSounds.beep, 70, 100)
        
        if not RADIO_CHAT_HISTORY[talkerChannel] then
            RADIO_CHAT_HISTORY[talkerChannel] = {}
        end
        
        table.insert(RADIO_CHAT_HISTORY[talkerChannel], {
            sender = talkerSerial,
            text = message,
            time = os.time(),
            color = Color(150, 200, 255),
            original = true
        })
        
        if #RADIO_CHAT_HISTORY[talkerChannel] > 50 then
            table.remove(RADIO_CHAT_HISTORY[talkerChannel], 1)
        end
        
        for _, listener in ipairs(player.GetAll()) do
            if IsValid(listener) and listener ~= ply then
                local listenerWep = listener:GetActiveWeapon()
                if IsValid(listenerWep) and listenerWep:GetClass() == "mur_radio" then
                    local listenerData = GetRadioData(listenerWep)
                    
                    if listenerData and listenerData.on and 
                       listenerData.channel == talkerData.channel and
                       listenerData.battery > 0 and not listenerData.needsRepair then
                        
                        local dist = talkerPos:Distance(listener:GetPos())
                        if dist <= RADIO_RANGE then
                            local talkerQuality = math.max(0, talkerData.signalQuality or 100)
                            local listenerQuality = math.max(0, listenerData.signalQuality or 100)
                            local overallQuality = math.min(talkerQuality, listenerQuality)
                            
                            local qualityReduction = (100 - overallQuality) / 100
                            
                            if math.Rand(0, 1) > qualityReduction then
                                local corruptedMessage = CorruptText(message, qualityReduction)
                                local corruptedSerial = talkerSerial
                                
                                if qualityReduction > 0.5 then
                                    corruptedSerial = CorruptText(talkerSerial, qualityReduction * 0.4)
                                end
                                
                                local color = Color(100, 255, 150)
                                if qualityReduction > 0.3 then
                                    color = Color(255, 200, 100)
                                end
                                if qualityReduction > 0.6 then
                                    color = Color(255, 100, 100)
                                end
                                
                                listenerWep:EmitSound(radioSounds.beep, 60, 90)
                                
                                net.Start("RadioSyncHistory")
                                net.WriteInt(talkerChannel, 16)
                                net.WriteString(corruptedSerial)
                                net.WriteString(corruptedMessage)
                                net.WriteInt(os.time(), 32)
                                net.WriteColor(color)
                                net.WriteBool(false)
                                net.Send(listener)
                            end
                        end
                    end
                end
            end
        end
        
        net.Start("RadioSyncHistory")
        net.WriteInt(talkerChannel, 16)
        net.WriteString(talkerSerial)
        net.WriteString(message)
        net.WriteInt(os.time(), 32)
        net.WriteColor(Color(150, 200, 255))
        net.WriteBool(true)
        net.Send(ply)
        
        return ""
    end)

    hook.Add("PlayerDisconnected", "RadioCleanup", function(ply)
        if RADIO_PLAYERS[ply] then
            RADIO_PLAYERS[ply] = nil
        end
        if RADIO_PLAYER_SETTINGS[ply] then
            RADIO_PLAYER_SETTINGS[ply] = nil
        end
    end)

    hook.Add("PlayerSpawn", "RadioReset", function(ply)
        if RADIO_PLAYERS[ply] then
            RADIO_PLAYERS[ply] = nil
        end
        
        timer.Simple(1, function()
            if IsValid(ply) and ply.IsRolePolice and ply:IsRolePolice() then
                local wep = ply:GetActiveWeapon()
                if IsValid(wep) and wep:GetClass() == "mur_radio" then
                    local data = GetRadioData(wep)
                    if data then
                        data.channel = POLICE_CHANNEL
                        wep:SetNWInt("RadioChannel", POLICE_CHANNEL)
                    end
                end
            end
        end)
    end)
    
    hook.Add("PlayerCanHearPlayersVoice", "RadioVoiceChat", function(listener, talker)
        if not IsValid(listener) or not IsValid(talker) then return end

        local listenerWep = listener:GetWeapon("mur_radio")
        local talkerWep = talker:GetActiveWeapon()
        
        if IsValid(listenerWep) and IsValid(talkerWep) and talkerWep:GetClass() == "mur_radio" then
            
            local listenerData = GetRadioData(listenerWep)
            local talkerData = GetRadioData(talkerWep)
            
            if listenerData and talkerData and 
               listenerData.on and talkerData.on and 
               listenerData.battery > 0 and talkerData.battery > 0 and
               not listenerData.needsRepair and not talkerData.needsRepair then
                if listenerData.channel == talkerData.channel then
                    local rnd = math.random(0, 99)
                    if rnd >= math.min(listenerWep:GetNWFloat("RadioQuality", 100), talkerWep:GetNWFloat("RadioQuality", 100)) then
                        net.Start("RadioNoices")
                        net.Send(listener)
                        return false, false
                    else
                        return true, false
                    end
                end
            end
        end
    end)

end

if CLIENT then
    hook.Add("PlayerDeath", "RadioGUIClose", function(victim, inflictor, attacker)
        if IsValid(victim) and victim == LocalPlayer() then
            local wep = victim:GetActiveWeapon()
            if IsValid(wep) and wep:GetClass() == "mur_radio" and IsValid(wep.RadioGUI) then
                wep.RadioGUI:Remove()
                wep.RadioGUI = nil
            end
        end
    end)
    
    local activeStaticSounds = {}
    local ownStaticSound = nil
    hook.Add("PlayerStartVoice", "RadioStartVoice", function(ply)
        if ply != LocalPlayer() then
            local wep = ply:GetActiveWeapon()
            if IsValid(wep) and wep:GetClass() == "mur_radio" and wep:GetNWBool("RadioOn", false) then
                surface.PlaySound("murdered/radio/start.mp3")
                
                if ownStaticSound then
                    ownStaticSound:Stop()
                end
                
                ownStaticSound = CreateSound(ply, radioSounds.static)
                ownStaticSound:SetSoundLevel(0)
                ownStaticSound:PlayEx(1, 100)
            end
        end
    end)
    
    hook.Add("PlayerEndVoice", "RadioEndVoice", function(ply)
        if ply != LocalPlayer() then
            local wep = ply:GetActiveWeapon()
            timer.Simple(0.1, function()
                if IsValid(wep) and wep:GetClass() == "mur_radio" and wep:GetNWBool("RadioOn", false) then
                    surface.PlaySound("murdered/radio/end"..math.random(1,3)..".mp3")
                end
                if ownStaticSound then
                    ownStaticSound:Stop()
                    ownStaticSound = nil
                end
            end)
        end
    end)
end

if CLIENT then
    local RADIO_SETTINGS = {
        showHUD = true,
        autoShutdown = true,
        enableChat = true
    }
    
    local activeChatPanels = {}
    
    local function UpdateAllChatPanels(channel)
        for panelID, updateFunc in pairs(activeChatPanels) do
            if isfunction(updateFunc) then
                updateFunc(channel)
            end
        end
    end
    
    net.Receive("RadioSyncHistory", function()
        local channel = net.ReadInt(16)
        local sender = net.ReadString()
        local text = net.ReadString()
        local time = net.ReadInt(32)
        local color = net.ReadColor()
        local isOriginal = net.ReadBool()
        
        if not RADIO_CHAT_HISTORY[channel] then
            RADIO_CHAT_HISTORY[channel] = {}
        end
        
        table.insert(RADIO_CHAT_HISTORY[channel], {
            sender = sender,
            text = text,
            time = time,
            color = color,
            original = isOriginal
        })
        
        if #RADIO_CHAT_HISTORY[channel] > 50 then
            table.remove(RADIO_CHAT_HISTORY[channel], 1)
        end
        
        UpdateAllChatPanels(channel)
    end)

    net.Receive("RadioNoices", function()
        LocalPlayer():EmitSound("murdered/radio/corrupt-0"..math.random(1, 8)..".mp3", 0, math.random(80,120), 1)
    end)

    function SWEP:OpenRadioGUI()
        if IsValid(self.RadioGUI) then
            self.RadioGUI:Remove()
            self.RadioGUI = nil
            return
        end
        
        local frame = vgui.Create("DFrame")
        frame:SetSize(We(700), He(500))
        frame:Center()
        frame:SetTitle("")
        frame:SetDraggable(true)
        frame:ShowCloseButton(false)
        frame:MakePopup()
        
        frame.Paint = function(s, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(25, 25, 25, 250))
            draw.RoundedBox(6, 2, 2, w-4, h-4, Color(35, 35, 35, 200))
            
            draw.SimpleText(MuR.Language["radio_system"], "MuR_Font2", w/2, He(10), Color(220, 60, 60), TEXT_ALIGN_CENTER)
            draw.SimpleText(MuR.Language["radio_system_config"], "MuR_Font1", w/2, He(35), Color(180, 180, 180), TEXT_ALIGN_CENTER)
            
            surface.SetDrawColor(60, 15, 15, 150)
            surface.DrawLine(We(10), He(65), w-We(10), He(65))
        end
        
        
        local closeBtn = vgui.Create("DButton", frame)
        closeBtn:SetPos(We(650), He(10))
        closeBtn:SetSize(We(40), He(30))
        closeBtn:SetText("✕")
        closeBtn:SetTextColor(Color(220, 60, 60))
        closeBtn:SetFont("MuR_Font2")
        closeBtn.Paint = function(s, w, h)
            local col = s:IsHovered() and Color(80, 20, 20, 180) or Color(50, 15, 15, 120)
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        closeBtn.DoClick = function()
            frame:Remove()
        end
        
        frame.OnRemove = function()
            self.RadioGUI = nil
            for panelID, _ in pairs(activeChatPanels) do
                if string.find(panelID, "chatpanel_") then
                    activeChatPanels[panelID] = nil
                end
            end
        end
        
        local sidebar = vgui.Create("DPanel", frame)
        sidebar:SetPos(We(10), He(75))
        sidebar:SetSize(We(180), He(415))
        sidebar.Paint = function(s, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(20, 20, 20, 200))
            draw.RoundedBox(4, 2, 2, w-4, h-4, Color(30, 30, 30, 150))
        end
        
        local mainPanel = vgui.Create("DPanel", frame)
        mainPanel:SetPos(We(200), He(75))
        mainPanel:SetSize(We(490), He(415))
        mainPanel.Paint = function(s, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 40, 180))
        end
        
        local currentTab = "main"
        local tabPanels = {}
        
        local function createTabButton(text, id, yPos)
            local btn = vgui.Create("DButton", sidebar)
            btn:SetPos(We(10), He(yPos))
            btn:SetSize(We(160), He(35))
            btn:SetText("")
            
            btn.Paint = function(s, w, h)
                local isActive = (currentTab == id)
                local baseCol = isActive and Color(80, 20, 20, 200) or Color(45, 45, 45, 150)
                local hoverCol = isActive and Color(100, 30, 30, 220) or Color(60, 60, 60, 180)
                
                local col = s:IsHovered() and hoverCol or baseCol
                draw.RoundedBox(4, 0, 0, w, h, col)
                
                if isActive then
                    draw.RoundedBox(2, 0, 0, 4, h, Color(220, 60, 60))
                end
                
                local textCol = isActive and Color(255, 255, 255) or Color(200, 200, 200)
                draw.SimpleText(text, "MuR_Font2", We(10), h/2, textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
            
            btn.DoClick = function()
                currentTab = id
                for k, panel in pairs(tabPanels) do
                    panel:SetVisible(k == id)
                end
                surface.PlaySound(radioSounds.click)
            end
            
            return btn
        end
        
        createTabButton(MuR.Language["radio_basic"], "main", 20)
        createTabButton(MuR.Language["radio_frequencies"], "channels", 65)
        createTabButton(MuR.Language["radio_diagnostics"], "diagnostics", 110)
        createTabButton(MuR.Language["radio_settings"], "settings", 155)
        
        local function createMainPanel()
            local panel = vgui.Create("DPanel", mainPanel)
            panel:SetPos(0, 0)
            panel:SetSize(We(490), He(415))
            panel.Paint = function() end
            
            local statusBox = vgui.Create("DPanel", panel)
            statusBox:SetPos(We(20), He(20))
            statusBox:SetSize(We(450), He(120))
            statusBox.Paint = function(s, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Color(25, 25, 25, 200))
                
                draw.SimpleText(MuR.Language["radio_system_state"], "MuR_Font2", We(15), He(10), Color(220, 60, 60))
                
                if not IsValid(self) then return end
                
                local battery = math.max(0, self:GetNWFloat("RadioBattery", 100) or 100)
                local signal = math.max(0, (self:GetNWFloat("RadioSignal", 0) or 0))
                local isOn = self:GetNWBool("RadioOn", false) or false
                local channel = math.max(1, self:GetNWInt("RadioChannel", 1) or 1)
                
                local statusText = isOn and MuR.Language["radio_status_on"] or MuR.Language["radio_status_off"]
                local statusCol = isOn and Color(100, 255, 100) or Color(255, 100, 100)
                draw.SimpleText(MuR.Language["radio_status"] .. statusText, "MuR_Font1", We(15), He(35), statusCol)
                
                draw.SimpleText(MuR.Language["radio_frequency"] .. channel .. MuR.Language["radio_mhz"], "MuR_Font1", We(15), He(55), Color(255, 255, 255))
                draw.SimpleText(MuR.Language["radio_signal"] .. math.floor(signal) .. MuR.Language["radio_percent"], "MuR_Font1", We(15), He(75), Color(100, 255, 150))
                
                draw.SimpleText(MuR.Language["radio_battery"], "MuR_Font1", We(250), He(35), Color(200, 200, 200))
                local batW = We(150) * (battery / 100)
                draw.RoundedBox(2, We(250), He(55), We(150), He(15), Color(60, 60, 60))
                local batCol = battery > 20 and Color(100, 255, 100) or Color(255, 100, 100)
                draw.RoundedBox(2, We(250), He(55), batW, He(15), batCol)
                draw.SimpleText(math.floor(battery) .. MuR.Language["radio_percent"], "MuR_Font1", We(325), He(75), batCol)
            end
            
            local powerToggle = vgui.Create("DButton", panel)
            powerToggle:SetPos(We(20), He(160))
            powerToggle:SetSize(We(140), He(45))
            powerToggle:SetText("")
            powerToggle.Paint = function(s, w, h)
                if not IsValid(self) then return end
                
                local isOn = self:GetNWBool("RadioOn", false) or false
                local col = isOn and Color(80, 20, 20, 200) or Color(20, 80, 20, 200)
                if s:IsHovered() then
                    col = Color(col.r + 30, col.g + 30, col.b + 30)
                end
                
                draw.RoundedBox(6, 0, 0, w, h, col)
                draw.SimpleText(isOn and MuR.Language["radio_power_off"] or MuR.Language["radio_power_on"], "MuR_Font2", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            powerToggle.DoClick = function()
                net.Start("RadioTogglePower")
                net.SendToServer()
            end
            
            local infoBox = vgui.Create("DPanel", panel)
            infoBox:SetPos(We(20), He(230))
            infoBox:SetSize(We(450), He(165))
            infoBox.Paint = function(s, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Color(25, 25, 25, 200))
                
                draw.SimpleText(MuR.Language["radio_info"], "MuR_Font2", We(15), He(10), Color(220, 60, 60))
                
                local info = {
                    MuR.Language["radio_range"] .. RADIO_RANGE .. MuR.Language["radio_units"],
                    MuR.Language["radio_channels"] .. MAX_CHANNELS .. MuR.Language["radio_special_channel"],
                    MuR.Language["radio_battery_life"],
                    MuR.Language["radio_encryption"],
                    MuR.Language["radio_frequency_range"] .. MAX_CHANNELS .. MuR.Language["radio_mhz"],
                    "",
                    MuR.Language["radio_controls"],
                    MuR.Language["radio_control_power"],
                    MuR.Language["radio_control_settings"],
                    MuR.Language["radio_control_chat"]
                }
                
                for i, text in ipairs(info) do
                    local col = text:find("•") and Color(150, 200, 255) or Color(200, 200, 200)
                    if text:find("УПРАВЛЕНИЕ") then col = Color(255, 200, 100) end
                    draw.SimpleText(text, "MuR_Font1", We(15), He(25 + (i * 14)), col)
                end
            end
            
            return panel
        end
        
        local function createChannelsPanel()
            local panel = vgui.Create("DPanel", mainPanel)
            panel:SetPos(0, 0)
            panel:SetSize(We(490), He(415))
            panel:SetVisible(false)
            panel.Paint = function() end
            
            local title = vgui.Create("DLabel", panel)
            title:SetPos(We(20), He(15))
            title:SetSize(We(450), He(25))
            title:SetText(MuR.Language["radio_frequency_setup"])
            title:SetTextColor(Color(220, 60, 60))
            title:SetFont("MuR_Font2")
            
            local currentCh = math.max(0, self:GetNWInt("RadioChannel", 1) or 1)
            
            local freqInputBox = vgui.Create("DPanel", panel)
            freqInputBox:SetPos(We(20), He(60))
            freqInputBox:SetSize(We(450), He(100))
            freqInputBox.Paint = function(s, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Color(25, 25, 25, 200))
                draw.SimpleText(MuR.Language["radio_manual_frequency"], "MuR_Font2", We(15), He(10), Color(200, 200, 200))
                draw.SimpleText(MuR.Language["radio_enter_channel"] .. " (0-" .. MAX_CHANNELS .. ")", "MuR_Font1", We(15), He(35), Color(150, 150, 150))
            end
            
            local freqEntry = vgui.Create("DTextEntry", freqInputBox)
            freqEntry:SetPos(We(15), He(60))
            freqEntry:SetSize(We(200), He(25))
            freqEntry:SetText(tostring(currentCh))
            freqEntry:SetNumeric(true)
            freqEntry.Paint = function(s, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40))
                s:DrawTextEntryText(Color(255, 255, 255), Color(100, 200, 255), Color(255, 255, 255))
            end
            
            local setFreqBtn = vgui.Create("DButton", freqInputBox)
            setFreqBtn:SetPos(We(230), He(60))
            setFreqBtn:SetSize(We(100), He(25))
            setFreqBtn:SetText("")
            setFreqBtn.Paint = function(s, w, h)
                local col = s:IsHovered() and Color(80, 20, 20) or Color(60, 15, 15)
                draw.RoundedBox(4, 0, 0, w, h, col)
                draw.SimpleText(MuR.Language["radio_set"], "MuR_Font1", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            setFreqBtn.DoClick = function()
                local channel = tonumber(freqEntry:GetValue())
                if channel and channel >= 0 and channel <= MAX_CHANNELS then
                    net.Start("RadioChangeChannel")
                    net.WriteInt(channel, 16)
                    net.SendToServer()
                    
                    surface.PlaySound(radioSounds.switch)
                    currentCh = channel
                    freqEntry:SetText(tostring(channel))
                else
                    surface.PlaySound(radioSounds.error)
                end
            end
            
            local chatBox = vgui.Create("DPanel", panel)
            chatBox:SetPos(We(20), He(180))
            chatBox:SetSize(We(450), He(215))
            chatBox.Paint = function(s, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Color(25, 25, 25, 200))
                draw.SimpleText(MuR.Language["radio_chat"], "MuR_Font2", We(15), He(10), Color(200, 200, 200))
            end
            
            local chatHistory = vgui.Create("DScrollPanel", chatBox)
            chatHistory:SetPos(We(15), He(35))
            chatHistory:SetSize(We(420), He(125))
            chatHistory.Paint = function(s, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(15, 15, 15, 200))
            end
            
            local function UpdateChatHistory(targetChannel)
                if not IsValid(chatHistory) then return end
                
                local currentChannel = math.max(0, self:GetNWInt("RadioChannel", 1) or 1)
                
                if targetChannel and targetChannel ~= currentChannel then
                    return
                end
                
                chatHistory:Clear()
                
                if RADIO_CHAT_HISTORY[currentChannel] then
                    for i, msg in ipairs(RADIO_CHAT_HISTORY[currentChannel]) do
                        local msgPanel = vgui.Create("DPanel", chatHistory)
                        msgPanel:SetSize(400, 20)
                        msgPanel:Dock(TOP)
                        msgPanel:DockMargin(2, 1, 2, 1)
                        msgPanel.Paint = function(s, w, h)
                            local timeStr = os.date("%H:%M", msg.time)
                            draw.SimpleText("[" .. timeStr .. "] " .. msg.sender .. ": " .. msg.text, "MuR_Font1", 5, h/2, msg.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        end
                    end
                end
                
                timer.Simple(0.01, function()
                    if IsValid(chatHistory) and IsValid(chatHistory:GetVBar()) then
                        chatHistory:GetVBar():AnimateTo(chatHistory:GetVBar().CanvasSize, 0.1, 0, 0.5)
                    end
                end)
            end
            
            UpdateChatHistory()
            
            local panelID = "chatpanel_" .. tostring(chatHistory)
            activeChatPanels[panelID] = UpdateChatHistory
            
            panel.OnRemove = function()
                activeChatPanels[panelID] = nil
            end
            
            local chatEntry = vgui.Create("DTextEntry", chatBox)
            chatEntry:SetPos(We(15), He(170))
            chatEntry:SetSize(We(240), He(25))
            chatEntry:SetPlaceholderText(MuR.Language["radio_enter_message"])
            chatEntry:SetEnabled(RADIO_SETTINGS.enableChat)
            chatEntry.Paint = function(s, w, h)
                local bgCol = RADIO_SETTINGS.enableChat and Color(40, 40, 40) or Color(25, 25, 25)
                draw.RoundedBox(4, 0, 0, w, h, bgCol)
                s:DrawTextEntryText(Color(255, 255, 255), Color(100, 200, 255), Color(255, 255, 255))
                
                if not RADIO_SETTINGS.enableChat then
                    draw.SimpleText(MuR.Language["radio_chat_disabled"], "MuR_Font1", w/2, h/2, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
            
            local sendBtn = vgui.Create("DButton", chatBox)
            sendBtn:SetPos(We(265), He(170))
            sendBtn:SetSize(We(80), He(25))
            sendBtn:SetText("")
            sendBtn.Paint = function(s, w, h)
                local col = Color(40, 25, 25)
                if RADIO_SETTINGS.enableChat then
                    col = s:IsHovered() and Color(80, 20, 20) or Color(60, 15, 15)
                end
                draw.RoundedBox(4, 0, 0, w, h, col)
                
                local textCol = RADIO_SETTINGS.enableChat and Color(255, 255, 255) or Color(120, 120, 120)
                draw.SimpleText(MuR.Language["radio_send"], "MuR_Font1", w/2, h/2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            sendBtn.DoClick = function()
                if not RADIO_SETTINGS.enableChat then return end
                local message = chatEntry:GetValue()
                if string.len(message) > 0 then
                    net.Start("RadioChatMessage")
                    net.WriteString(message)
                    net.SendToServer()
                    chatEntry:SetValue("")
                end
            end
            
            local clearBtn = vgui.Create("DButton", chatBox)
            clearBtn:SetPos(We(355), He(170))
            clearBtn:SetSize(We(80), He(25))
            clearBtn:SetText("")
            clearBtn.Paint = function(s, w, h)
                local col = s:IsHovered() and Color(60, 40, 15) or Color(40, 25, 10)
                draw.RoundedBox(4, 0, 0, w, h, col)
                draw.SimpleText(MuR.Language["radio_clear"], "MuR_Font1", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            clearBtn.DoClick = function()
                local channel = math.max(0, self:GetNWInt("RadioChannel", 1) or 1)
                RADIO_CHAT_HISTORY[channel] = {}
                UpdateChatHistory()
                surface.PlaySound(radioSounds.click)
            end
            
            chatEntry.OnEnter = function()
                if RADIO_SETTINGS.enableChat then
                    sendBtn:DoClick()
                end
            end
            
            return panel
        end
        
        local function createDiagnosticsPanel()
            local panel = vgui.Create("DPanel", mainPanel)
            panel:SetPos(0, 0)
            panel:SetSize(We(490), He(415))
            panel:SetVisible(false)
            panel.Paint = function() end
            
            local title = vgui.Create("DLabel", panel)
            title:SetPos(We(20), He(15))
            title:SetSize(We(450), He(25))
            title:SetText(MuR.Language["radio_system_diag"])
            title:SetTextColor(Color(220, 60, 60))
            title:SetFont("MuR_Font2")
            
            local isTestRunning = false
            local testStartTime = 0
            local testResults = {}
            local isRepairing = false
            local repairStartTime = 0
            local isCooling = false
            local coolingStartTime = 0
            local testCompleted = false
            
            local diagBox = vgui.Create("DPanel", panel)
            diagBox:SetPos(We(20), He(50))
            diagBox:SetSize(We(450), He(220))
            diagBox.Paint = function(s, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Color(25, 25, 25, 200))
                
                if isRepairing then
                    local progress = math.min(1, (CurTime() - repairStartTime) / 3)
                    local barW = (w - We(30)) * progress
                    
                    draw.SimpleText(MuR.Language["radio_repairing_process"], "MuR_Font2", We(15), He(15), Color(255, 200, 100))
                    draw.RoundedBox(4, We(15), He(40), w - We(30), He(20), Color(60, 60, 60))
                    draw.RoundedBox(4, We(15), He(40), barW, He(20), Color(255, 200, 100))
                    draw.SimpleText(math.floor(progress * 100) .. "%", "MuR_Font1", w/2, He(50), Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    
                    if progress >= 1 then
                        isRepairing = false
                        net.Start("RadioRepair")
                        net.SendToServer()
                        surface.PlaySound(radioSounds.switch)
                    end
                elseif isCooling then
                    local progress = math.min(1, (CurTime() - coolingStartTime) / 5)
                    local barW = (w - We(30)) * progress
                    
                    draw.SimpleText(MuR.Language["radio_cooling_process"], "MuR_Font2", We(15), He(15), Color(100, 200, 255))
                    draw.RoundedBox(4, We(15), He(40), w - We(30), He(20), Color(60, 60, 60))
                    draw.RoundedBox(4, We(15), He(40), barW, He(20), Color(100, 200, 255))
                    draw.SimpleText(math.floor(progress * 100) .. "%", "MuR_Font1", w/2, He(50), Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    
                    if progress >= 1 then
                        isCooling = false
                        net.Start("RadioCool")
                        net.SendToServer()
                        surface.PlaySound(radioSounds.cool)
                    end
                elseif isTestRunning then
                    local progress = math.min(1, (CurTime() - testStartTime) / 5)
                    local barW = (w - We(30)) * progress
                    
                    draw.SimpleText(MuR.Language["radio_testing_process"], "MuR_Font2", We(15), He(15), Color(255, 200, 100))
                    draw.RoundedBox(4, We(15), He(40), w - We(30), He(20), Color(60, 60, 60))
                    draw.RoundedBox(4, We(15), He(40), barW, He(20), Color(100, 200, 255))
                    draw.SimpleText(math.floor(progress * 100) .. "%", "MuR_Font1", w/2, He(50), Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    
                    local tests = {
                        MuR.Language["radio_checking_power"],
                        MuR.Language["radio_checking_signal"],
                        MuR.Language["radio_checking_transmitter"],
                        MuR.Language["radio_checking_antenna"],
                        MuR.Language["radio_checking_encryption"],
                        MuR.Language["radio_checking_temperature"]
                    }
                    
                    local currentTestStage = math.min(6, math.floor(progress * 6) + 1)
                    if tests[currentTestStage] then
                        draw.SimpleText(tests[currentTestStage], "MuR_Font1", We(15), He(80), Color(200, 200, 200))
                    end
                    
                    if progress >= 1 and isTestRunning then
                        isTestRunning = false
                        testCompleted = true
                        
                        local battery = 100
                        local signal = 90
                        local isOn = false
                        local temperature = TEMPERATURE_NORMAL
                        local interference = 0
                        local quality = 100
                        local needsRepair = false
                        
                        if IsValid(self) then
                            battery = math.max(0, self:GetNWFloat("RadioBattery", 100) or 100)
                            signal = math.max(0, self:GetNWFloat("RadioSignal", 0) or 0)
                            isOn = self:GetNWBool("RadioOn", false) or false
                            temperature = self:GetNWFloat("RadioTemperature", TEMPERATURE_NORMAL) or TEMPERATURE_NORMAL
                            interference = self:GetNWFloat("RadioInterference", 0) or 0
                            quality = self:GetNWFloat("RadioQuality", 100) or 100
                            needsRepair = self:GetNWBool("RadioNeedsRepair", false) or false
                        end
                        
                        testResults = {
                            {name = MuR.Language["radio_test_power"], status = battery > 20, value = math.floor(battery) .. "%"},
                            {name = MuR.Language["radio_test_signal_quality"], status = quality > 60, value = math.floor(quality) .. "%"},
                            {name = MuR.Language["radio_test_transmitter"], status = not needsRepair, value = needsRepair and MuR.Language["radio_status_malfunction"] or MuR.Language["radio_status_functional"]},
                            {name = MuR.Language["radio_test_interference"], status = interference < 30, value = math.floor(interference) .. "%"},
                            {name = MuR.Language["radio_test_temperature"], status = temperature < 45, value = math.floor(temperature) .. "°C"},
                            {name = MuR.Language["radio_test_overall"], status = quality > 70 and not needsRepair, value = quality > 70 and not needsRepair and MuR.Language["radio_status_normal"] or MuR.Language["radio_status_needs_attention"]},
                        }
                        
                        surface.PlaySound(radioSounds.switch)
                    end
                else
                    if #testResults > 0 then
                        draw.SimpleText(MuR.Language["radio_test_results_title"], "MuR_Font2", We(15), He(15), Color(200, 200, 200))
                        
                        local passedTests = 0
                        for i, test in ipairs(testResults) do
                            local y = He(35 + (i * 25))
                            local statusCol = test.status and Color(100, 255, 100) or Color(255, 100, 100)
                            local statusText = test.status and "✓" or "✗"
                            
                            if test.status then passedTests = passedTests + 1 end
                            
                            draw.SimpleText(test.name, "MuR_Font1", We(15), y, Color(255, 255, 255))
                            draw.SimpleText(test.value, "MuR_Font1", We(250), y, Color(200, 200, 200))
                            draw.SimpleText(statusText, "MuR_Font2", We(400), y, statusCol)
                        end
                        
                        local overallCol = passedTests == #testResults and Color(100, 255, 100) or (passedTests > #testResults/2 and Color(255, 200, 100) or Color(255, 100, 100))
                        local overallStatus = passedTests == #testResults and MuR.Language["radio_status_excellent"] or (passedTests > #testResults/2 and MuR.Language["radio_status_satisfactory"] or MuR.Language["radio_status_needs_attention"])
                        draw.SimpleText(MuR.Language["radio_overall_status"] .. overallStatus, "MuR_FontDef", We(15), He(205), overallCol)
                    else
                        draw.SimpleText(MuR.Language["radio_test_start"], "MuR_Font1", We(15), He(15), Color(150, 150, 150))
                        draw.SimpleText(MuR.Language["radio_test_duration"], "MuR_Font1", We(15), He(40), Color(100, 100, 100))
                        draw.SimpleText(MuR.Language["radio_test_results"], "MuR_Font1", We(15), He(65), Color(100, 100, 100))
                        draw.SimpleText(MuR.Language["radio_test_repair_note"], "MuR_Font1", We(15), He(90), Color(255, 200, 100))
                    end
                end
            end
            
            local buttonY = He(280)
            local testBtn = vgui.Create("DButton", panel)
            testBtn:SetPos(We(20), buttonY)
            testBtn:SetSize(We(100), He(30))
            testBtn:SetText("")
            testBtn.Paint = function(s, w, h)
                local col = s:IsHovered() and Color(60, 60, 60) or Color(40, 40, 40)
                if isTestRunning then col = Color(80, 80, 80) end
                draw.RoundedBox(4, 0, 0, w, h, col)
                
                local text = isTestRunning and MuR.Language["radio_testing"] or MuR.Language["radio_test"]
                draw.SimpleText(text, "MuR_Font1", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            testBtn.DoClick = function()
                if not isTestRunning and not isRepairing and not isCooling then
                    isTestRunning = true
                    testStartTime = CurTime()
                    testResults = {}
                    testCompleted = false
                    surface.PlaySound(radioSounds.beep)
                end
            end
            
            local repairBtn = vgui.Create("DButton", panel)
            repairBtn:SetPos(We(130), buttonY)
            repairBtn:SetSize(We(100), He(30))
            repairBtn:SetText("")
            repairBtn.Paint = function(s, w, h)
                local canRepair = testCompleted and not isTestRunning and not isRepairing and not isCooling
                local col = Color(40, 25, 25)
                if canRepair then
                    col = s:IsHovered() and Color(60, 40, 40) or Color(40, 25, 25)
                else
                    col = Color(25, 15, 15)
                end
                if isRepairing then col = Color(80, 60, 60) end
                draw.RoundedBox(4, 0, 0, w, h, col)
                
                local text = isRepairing and MuR.Language["radio_repairing"] or MuR.Language["radio_repair"]
                local textCol = canRepair and Color(255, 255, 255) or Color(120, 120, 120)
                draw.SimpleText(text, "MuR_Font1", w/2, h/2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            repairBtn.DoClick = function()
                if testCompleted and not isTestRunning and not isRepairing and not isCooling then
                    isRepairing = true
                    repairStartTime = CurTime()
                    surface.PlaySound(radioSounds.repair)
                else
                    surface.PlaySound(radioSounds.error)
                end
            end
            
            local coolBtn = vgui.Create("DButton", panel)
            coolBtn:SetPos(We(240), buttonY)
            coolBtn:SetSize(We(100), He(30))
            coolBtn:SetText("")
            coolBtn.Paint = function(s, w, h)
                local canCool = testCompleted and not isTestRunning and not isRepairing and not isCooling
                local col = Color(25, 25, 40)
                if canCool then
                    col = s:IsHovered() and Color(40, 40, 60) or Color(25, 25, 40)
                else
                    col = Color(15, 15, 25)
                end
                if isCooling then col = Color(60, 60, 80) end
                draw.RoundedBox(4, 0, 0, w, h, col)
                
                local text = isCooling and MuR.Language["radio_cooling"] or MuR.Language["radio_cool"]
                local textCol = canCool and Color(255, 255, 255) or Color(120, 120, 120)
                draw.SimpleText(text, "MuR_Font1", w/2, h/2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            coolBtn.DoClick = function()
                if testCompleted and not isTestRunning and not isRepairing and not isCooling then
                    isCooling = true
                    coolingStartTime = CurTime()
                    surface.PlaySound(radioSounds.cool)
                else
                    surface.PlaySound(radioSounds.error)
                end
            end
            
            local resetBtn = vgui.Create("DButton", panel)
            resetBtn:SetPos(We(350), buttonY)
            resetBtn:SetSize(We(100), He(30))
            resetBtn:SetText("")
            resetBtn.Paint = function(s, w, h)
                local canReset = testCompleted and not isTestRunning and not isRepairing and not isCooling
                local col = Color(40, 25, 25)
                if canReset then
                    col = s:IsHovered() and Color(60, 40, 40) or Color(40, 25, 25)
                else
                    col = Color(25, 15, 15)
                end
                draw.RoundedBox(4, 0, 0, w, h, col)
                
                local textCol = canReset and Color(255, 255, 255) or Color(120, 120, 120)
                draw.SimpleText(MuR.Language["radio_reset"], "MuR_Font1", w/2, h/2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            resetBtn.DoClick = function()
                if testCompleted and not isTestRunning and not isRepairing and not isCooling then
                    testResults = {}
                    testCompleted = false
                    surface.PlaySound(radioSounds.click)
                else
                    surface.PlaySound(radioSounds.error)
                end
            end
            
            local statusPanel = vgui.Create("DPanel", panel)
            statusPanel:SetPos(We(20), He(320))
            statusPanel:SetSize(We(450), He(75))
            statusPanel.Paint = function(s, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Color(25, 25, 25, 200))
                draw.SimpleText(MuR.Language["radio_current_stats"], "MuR_Font2", We(15), He(10), Color(200, 200, 200))
                
                if IsValid(self) then
                    local temp = self:GetNWFloat("RadioTemperature", TEMPERATURE_NORMAL) or TEMPERATURE_NORMAL
                    local interference = self:GetNWFloat("RadioInterference", 0) or 0
                    local quality = self:GetNWFloat("RadioQuality", 100) or 100
                    
                    local tempCol = temp > 45 and Color(255, 100, 100) or Color(100, 255, 100)
                    local intCol = interference > 30 and Color(255, 100, 100) or Color(100, 255, 100)
                    local qualCol = quality > 70 and Color(100, 255, 100) or Color(255, 200, 100)
                    
                    draw.SimpleText(MuR.Language["radio_temperature"] .. math.floor(temp) .. "°C", "MuR_Font1", We(15), He(30), tempCol)
                    draw.SimpleText(MuR.Language["radio_interference"] .. math.floor(interference) .. "%", "MuR_Font1", We(200), He(30), intCol)
                    draw.SimpleText(MuR.Language["radio_signal_quality"] .. math.floor(quality) .. "%", "MuR_Font1", We(15), He(50), qualCol)
                end
            end
            
            return panel
        end
        
        local function createSettingsPanel()
            local panel = vgui.Create("DPanel", mainPanel)
            panel:SetPos(0, 0)
            panel:SetSize(We(490), He(415))
            panel:SetVisible(false)
            panel.Paint = function() end
            
            local title = vgui.Create("DLabel", panel)
            title:SetPos(We(20), He(15))
            title:SetSize(We(450), He(25))
            title:SetText(MuR.Language["radio_settings_title"])
            title:SetTextColor(Color(220, 60, 60))
            title:SetFont("MuR_Font2")
            
            local settingsBox = vgui.Create("DPanel", panel)
            settingsBox:SetPos(We(20), He(50))
            settingsBox:SetSize(We(450), He(250))
            settingsBox.Paint = function(s, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Color(25, 25, 25, 200))
                draw.SimpleText(MuR.Language["radio_config"], "MuR_Font2", We(15), He(15), Color(200, 200, 200))
            end
            
            local hudToggle = vgui.Create("DButton", settingsBox)
            hudToggle:SetPos(We(15), He(50))
            hudToggle:SetSize(We(420), He(30))
            hudToggle:SetText("")
            hudToggle.Paint = function(s, w, h)
                local col = s:IsHovered() and Color(50, 50, 50) or Color(35, 35, 35)
                draw.RoundedBox(4, 0, 0, w, h, col)
                
                draw.SimpleText(MuR.Language["radio_hud_display"], "MuR_Font1", We(10), h/2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                local statusText = RADIO_SETTINGS.showHUD and MuR.Language["radio_on"] or MuR.Language["radio_off"]
                local statusCol = RADIO_SETTINGS.showHUD and Color(100, 255, 100) or Color(255, 100, 100)
                draw.SimpleText(statusText, "MuR_Font1", w - We(10), h/2, statusCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
            hudToggle.DoClick = function()
                RADIO_SETTINGS.showHUD = not RADIO_SETTINGS.showHUD
                surface.PlaySound(radioSounds.click)
            end
            
            local autoToggle = vgui.Create("DButton", settingsBox)
            autoToggle:SetPos(We(15), He(90))
            autoToggle:SetSize(We(420), He(30))
            autoToggle:SetText("")
            autoToggle.Paint = function(s, w, h)
                local col = s:IsHovered() and Color(50, 50, 50) or Color(35, 35, 35)
                draw.RoundedBox(4, 0, 0, w, h, col)
                
                draw.SimpleText(MuR.Language["radio_auto_shutdown"], "MuR_Font1", We(10), h/2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                local statusText = RADIO_SETTINGS.autoShutdown and MuR.Language["radio_on"] or MuR.Language["radio_off"]
                local statusCol = RADIO_SETTINGS.autoShutdown and Color(100, 255, 100) or Color(255, 100, 100)
                draw.SimpleText(statusText, "MuR_Font1", w - We(10), h/2, statusCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
            autoToggle.DoClick = function()
                RADIO_SETTINGS.autoShutdown = not RADIO_SETTINGS.autoShutdown
                surface.PlaySound(radioSounds.click)
            end
            
            local chatToggle = vgui.Create("DButton", settingsBox)
            chatToggle:SetPos(We(15), He(130))
            chatToggle:SetSize(We(420), He(30))
            chatToggle:SetText("")
            chatToggle.Paint = function(s, w, h)
                local col = s:IsHovered() and Color(50, 50, 50) or Color(35, 35, 35)
                draw.RoundedBox(4, 0, 0, w, h, col)
                
                draw.SimpleText(MuR.Language["radio_chat_enable"], "MuR_Font1", We(10), h/2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                local statusText = RADIO_SETTINGS.enableChat and MuR.Language["radio_on"] or MuR.Language["radio_off"]
                local statusCol = RADIO_SETTINGS.enableChat and Color(100, 255, 100) or Color(255, 100, 100)
                draw.SimpleText(statusText, "MuR_Font1", w - We(10), h/2, statusCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
            chatToggle.DoClick = function()
                RADIO_SETTINGS.enableChat = not RADIO_SETTINGS.enableChat
                surface.PlaySound(radioSounds.click)
                self:OpenRadioGUI()
                timer.Simple(0.1, function()
                    if !IsValid(self) then return end
                    self:OpenRadioGUI()
                end)
            end
            
            local infoPanel = vgui.Create("DPanel", panel)
            infoPanel:SetPos(We(20), He(320))
            infoPanel:SetSize(We(450), He(75))
            infoPanel.Paint = function(s, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Color(25, 25, 25, 200))
                
                local serialNumber = IsValid(self) and self:GetNWString("RadioSerial", "") or ""
                if serialNumber == "" then
                    serialNumber = "RD-" .. math.random(1000, 9999) .. "-" .. math.random(100, 999)
                end
                
                local info = {
                    MuR.Language["radio_version"],
                    MuR.Language["radio_serial"] .. serialNumber,
                    MuR.Language["radio_date"]
                }
                
                for i, setting in ipairs(info) do
                    draw.SimpleText(setting, "MuR_Font1", We(15), He(-5 + (i * 18)), Color(150, 200, 255))
                end
            end
            
            return panel
        end
        
        tabPanels["main"] = createMainPanel()
        tabPanels["channels"] = createChannelsPanel()
        tabPanels["diagnostics"] = createDiagnosticsPanel()
        tabPanels["settings"] = createSettingsPanel()
        
        self.RadioGUI = frame
    end
    
    hook.Add("HUDPaint", "RadioHUD", function()
        if not RADIO_SETTINGS.showHUD then return end
        
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local wep = ply:GetActiveWeapon()
        
        if IsValid(wep) and wep:GetClass() == "mur_radio" then
            local x, y = We(50), ScrH() - He(150)
            local w, h = We(250), He(80)
            
            draw.RoundedBox(8, x-We(5), y-He(5), w+We(10), h+He(10), Color(0, 0, 0, 100))
            draw.RoundedBox(6, x, y, w, h, Color(40, 10, 10, 200))
            
            local isOn = wep:GetNWBool("RadioOn", false) or false
            local channel = math.max(1, wep:GetNWInt("RadioChannel", 1) or 1)
            local battery = math.max(0, wep:GetNWFloat("RadioBattery", 100) or 100)
            
            if not wep.LastBlink then wep.LastBlink = CurTime() end
            if wep.BlinkState == nil then wep.BlinkState = true end
            
            if CurTime() - wep.LastBlink > 0.5 then
                wep.LastBlink = CurTime()
                wep.BlinkState = not wep.BlinkState
            end
            
            local statusCol = Color(255, 100, 100)
            if isOn then
                statusCol = wep.BlinkState and Color(100, 255, 100) or Color(150, 255, 150)
            end
            
            draw.SimpleText(MuR.Language["radio_title"], "MuR_Font2", x + We(10), y + He(8), Color(200, 50, 50))
            draw.SimpleText(MuR.Language["radio_status"] .. (isOn and "ON" or "OFF"), "MuR_Font1", x + We(10), y + He(25), statusCol)
            draw.SimpleText(MuR.Language["radio_frequency"] .. channel .. MuR.Language["radio_mhz"], "MuR_Font1", x + We(10), y + He(40), Color(255, 255, 255))
            
            local batCol = battery > 20 and Color(100, 255, 100) or Color(255, 100, 100)
            draw.SimpleText(MuR.Language["radio_battery_status"] .. math.floor(battery) .. "%", "MuR_Font1", x + We(10), y + He(55), batCol)
        end
    end)
end