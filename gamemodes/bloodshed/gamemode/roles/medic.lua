local ROLE = {}

ROLE.name = "Medic"
ROLE.team = 2
ROLE.flashlight = false
ROLE.models = {
    male = {"models/murdered/pm/medic_01.mdl", "models/murdered/pm/medic_02.mdl", "models/murdered/pm/medic_03.mdl", "models/murdered/pm/medic_04.mdl", "models/murdered/pm/medic_05.mdl", "models/murdered/pm/medic_06.mdl", "models/murdered/pm/medic_07.mdl"},
    female = {"models/murdered/pm/medic_01_f.mdl", "models/murdered/pm/medic_02_f.mdl", "models/murdered/pm/medic_03_f.mdl", "models/murdered/pm/medic_04_f.mdl", "models/murdered/pm/medic_05_f.mdl", "models/murdered/pm/medic_06_f.mdl"}
}

ROLE.langName = "medic"
ROLE.color = Color(50, 120, 50)
ROLE.desc = "medic_desc"

ROLE.onSpawn = function(ply)
    local weapons = {"mur_loot_medkit", "mur_loot_adrenaline", "mur_loot_bandage", "mur_loot_surgicalkit", "mur_loot_tourniquet", "mur_antidote", "mur_chemistry_basic"}
    for _, wep in pairs(weapons) do ply:GiveWeapon(wep) end
end

MuR:RegisterRole(ROLE)