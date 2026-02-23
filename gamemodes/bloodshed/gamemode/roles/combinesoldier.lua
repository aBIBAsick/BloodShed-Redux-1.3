local ROLE = {}

ROLE.name = "CombineSoldier"
ROLE.team = 1
ROLE.flashlight = true
ROLE.models = {"models/player/combine_soldier_prisonguard.mdl", "models/player/combine_soldier.mdl", "models/player/combine_super_soldier.mdl"}
ROLE.male = true

ROLE.langName = "combinesoldier"
ROLE.color = Color(50, 150, 255)
ROLE.desc = "combinesoldier_desc"

ROLE.onSpawn = function(ply)
    ply:SetPlayerColor(Color(35,35,165):ToVector())

    if math.random(1,4) == 1 then
        ply:GiveWeapon("tfa_bs_spas")
        ply:GiveAmmo(24, "Buckshot", true)
    elseif math.random(1,4) == 1 then
        ply:GiveWeapon("tfa_bs_ar2")
        ply:GiveAmmo(120, "AR2", true)
    else
        ply:GiveWeapon("tfa_bs_mp7")
        ply:GiveAmmo(120, "Pistol", true)
    end
    ply:GiveWeapon("tfa_bs_usp")
    ply:GiveAmmo(36, "Pistol", true)
    ply:GiveWeapon("tfa_bs_baton")
    ply:GiveWeapon("mur_loot_bandage")
    ply:GiveWeapon("mur_loot_medkit")
    ply:GiveWeapon("mur_baterringram")
    ply:SetArmor(50)
    ply:SetWalkSpeed(70)
    ply:SetRunSpeed(180)
end

MuR:RegisterRole(ROLE)