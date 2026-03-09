local snds = {
    "clunkysteps/csgot_01.ogg",
    "clunkysteps/csgot_02.ogg",
    "clunkysteps/csgot_03.ogg",
    "clunkysteps/csgot_04.ogg",
    "clunkysteps/csgot_05.ogg",
    "clunkysteps/csgot_06.ogg",
    "clunkysteps/csgot_07.ogg",
    "clunkysteps/csgot_08.ogg",
    "clunkysteps/csgot_09.ogg",
    "clunkysteps/csgot_10.ogg",
    "clunkysteps/csgot_11.ogg",
    "clunkysteps/csgot_12.ogg"
}

local ducksnd = snds[1]

function MuR.HasVest(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end

    local id = ply:GetNW2String("MuR_Armor_body", "")
    if id == "" then return false end
    if not ply:GetNW2Bool("MuR_Armor_Active_body", false) then return false end

    local get = MuR and MuR.Armor and MuR.Armor.GetItem
    local item = get and get(id)
    return item ~= nil and item.bodypart == "body"
end

local function playvest(ply, ent, snd, vol)
    if not MuR.HasVest(ply) then return false end

    ent = IsValid(ent) and ent or ply
    if not IsValid(ent) then return false end

    snd = snd or table.Random(snds)
    vol = math.Clamp(vol or 0.35, 0.2, 0.45)

    local pitch = snd == ducksnd and math.random(98, 102) or math.random(95, 105)
    ent:EmitSound(snd, 65, pitch, vol, CHAN_BODY)

    return true
end

function MuR.VestStep(ply, ent, vol)
    return playvest(ply, ent, nil, vol)
end

function MuR.VestDuck(ply, ent, vol)
    return playvest(ply, ent, ducksnd, vol or 0.4)
end

if SERVER then
    for _, snd in ipairs(snds) do
        resource.AddSingleFile("sound/" .. snd)
    end

    hook.Add("PlayerFootstep", "MuR_VestSteps", function(ply, pos, foot, soundName, volume, filter)
        MuR.VestStep(ply, ply, (volume or 1) * 0.35)
    end)

    hook.Add("SetupMove", "MuR_VestDuck", function(ply, mv)
        if not IsValid(ply) or not ply:Alive() or IsValid(ply:GetRD()) or ply:InVehicle() then
            ply.vestDuck = false
            return
        end

        local ducking = mv:KeyDown(IN_DUCK) and ply:OnGround()
        if ducking and not ply.vestDuck then
            MuR.VestDuck(ply, ply)
        end

        ply.vestDuck = ducking
    end)
end
