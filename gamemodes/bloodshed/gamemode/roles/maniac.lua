local ROLE = {}

ROLE.name = "Maniac"
ROLE.team = 1
ROLE.flashlight = true
ROLE.models = {"models/murdered/pm/jason_v.mdl"}
ROLE.male = true
ROLE.killer = "active"

ROLE.langName = "maniac"
ROLE.color = Color(150, 10, 10)
ROLE.desc = "maniac_desc"

ROLE.onSpawn = function(ply)
    local weapons = {"tfa_bs_fireaxe_maniac", "tfa_bs_chainsaw", "mur_gasoline", 
                    "mur_loot_ducttape", "mur_scanner", "mur_beartrap"}
    for _, wep in pairs(weapons) do ply:GiveWeapon(wep, true) end

    ply:SetArmor(100)
    ply:SetWalkSpeed(180)
    ply:SetRunSpeed(300)
    ply:SetNW2Float("ArrestState", 1)
end

MuR:RegisterRole(ROLE)