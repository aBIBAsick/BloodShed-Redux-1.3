local ROLE = {}

ROLE.name = "Rebel"
ROLE.team = 2
ROLE.flashlight = true
ROLE.models = {"models/player/group03/male_01.mdl", "models/player/group03/male_02.mdl", "models/player/group03/male_03.mdl", "models/player/group03/male_04.mdl", "models/player/group03/male_05.mdl", "models/player/group03/male_06.mdl", "models/player/group03/male_07.mdl", "models/player/group03/male_08.mdl", "models/player/group03/male_09.mdl"}
ROLE.male = true

ROLE.langName = "rebel"
ROLE.color = Color(255, 150, 50)
ROLE.desc = "rebel_desc"

ROLE.onSpawn = function(ply)
    ply:SetPlayerColor(Color(35,165,35):ToVector())

    if math.random(1,4) == 1 then
        ply:GiveWeapon("tfa_bs_spas")
        ply:GiveAmmo(24, "Buckshot", true)
    elseif math.random(1,4) == 1 then
        ply:GiveWeapon("tfa_bs_mosin")
        ply:GiveAmmo(25, "SniperPenetratedRound", true)
    elseif math.random(1,4) == 1 then
        ply:GiveWeapon("tfa_bs_sks")
        ply:GiveAmmo(60, "AR2", true)
    elseif math.random(1,4) == 1 then
        ply:GiveWeapon("tfa_bs_mp7")
        ply:GiveAmmo(120, "Pistol", true)
    else
        ply:GiveWeapon("tfa_bs_annabelle")
        ply:GiveAmmo(32, "357", true)
    end
    if math.random(1,3) == 1 then
        ply:GiveWeapon("tfa_bs_cobra")
        ply:GiveAmmo(24, "357", true)
    else
        ply:GiveWeapon("tfa_bs_usp")
        ply:GiveAmmo(36, "Pistol", true)
    end
    ply:GiveWeapon(table.Random(MuR.WeaponsTable["Melee"]).class)
    ply:GiveWeapon(math.random(1, 2) == 1 and "mur_f1" or "mur_m67")
    ply:GiveWeapon(math.random(1, 2) == 1 and "mur_beartrap" or "mur_loot_ducttape")
    ply:GiveWeapon("mur_loot_bandage")
    ply:SetWalkSpeed(100)
    ply:SetRunSpeed(280)
    ply:SetNW2Float("ArrestState", 1)
end

MuR:RegisterRole(ROLE)