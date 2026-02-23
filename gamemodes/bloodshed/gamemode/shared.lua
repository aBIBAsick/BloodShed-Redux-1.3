--[[
WARNING: CC BY-NC 4.0

This gamemod is distributed under the terms of CC BY-NC 4.0
(https://creativecommons.org/licenses/by-nc/4.0/deed.en) with ADDITIONAL TERMS:

- It is prohibited to change or delete the GM.Author and GM.License fields.
- Before publishing, distributing or significantly modifying, you MUST
notify the original author (hari_devs - discord_tag or profile link).
- Any use outside the terms of this license is prohibited.

Note: additional terms go beyond the "pure" CC BY-NC 4.0.
By using this gamemode, you accept both the terms of CC BY-NC 4.0 and the additional terms listed above.
If you do not agree, do not use the material or obtain separate written permission from the author.
]]--

DeriveGamemode("sandbox")

GM.License = "https://creativecommons.org/licenses/by-nc/4.0/deed.en"
GM.Author = "https://steamcommunity.com/id/harionplayz/"
GM.Name = "Bloodshed: Redux"

MuR = MuR or {}

MuR.EnableDebug = false

MuR.shared("shared/sh_cvars.lua")
MuR.shared("shared/sh_rd.lua")
MuR.shared("shared/sh_woundfix.lua")
MuR.shared("shared/sh_policedispatch.lua")
MuR.shared("shared/sh_convars.lua")
MuR.shared("shared/sh_sniper.lua")
MuR.shared("shared/sh_modes.lua")
MuR.shared("shared/sh_roles.lua")
MuR.shared("shared/sh_tpik.lua")
MuR.shared("shared/sh_lib.lua")
MuR.shared("shared/sh_bloodsmearing.lua")
MuR.shared("shared/sh_move.lua")

local function LoadDir(dir)
	local files, dirs = file.Find( dir .. "*", "LUA" )
	for _, f in ipairs(files or {}) do
		local path = "modes/"..f
		AddCSLuaFile(path)
		include(path)
	end
end
LoadDir("bloodshed/gamemode/modes/")
MuR:RebuildGamemodeChances()

MuR.server("lang/sv_init.lua")
MuR.server("server/sv_functions.lua")
MuR.server("server/sv_rounds.lua")
MuR.server("server/sv_rd.lua")
MuR.server("server/sv_npc.lua")
MuR.server("server/sv_nodegraph.lua")
MuR.server("server/sv_commands.lua")
MuR.server("server/sv_util.lua")
MuR.server("server/sv_shop.lua")
MuR.server("server/sv_damage.lua")
MuR.server("server/sv_deathlist.lua")
MuR.server("server/sv_deathragdoll.lua")
MuR.server("server/sv_weaponry.lua")
MuR.server("server/sv_executions.lua")
MuR.server("server/sv_sandbox.lua")
MuR.server("server/sv_newfunctions.lua")

MuR.shared("zippy_gore/zippygoremod3.lua")
MuR.shared("zippy_blood/zippy_dynamic_blood_splatter.lua")

MuR.client("lang/cl_init.lua")
MuR.client("client/cl_execcam.lua")
MuR.client("client/cl_hud.lua")
MuR.client("client/cl_rd.lua")
MuR.client("client/cl_chat.lua")
MuR.client("client/cl_util.lua")
MuR.client("client/cl_scoreboard.lua")
MuR.client("client/cl_body.lua")
MuR.client("client/cl_q_menu.lua")
MuR.client("client/cl_shop.lua")
MuR.client("client/cl_pain.lua")
MuR.client("client/cl_deathlist.lua")
MuR.client("client/cl_body_inventory.lua")
MuR.client("client/cl_addhud.lua")
MuR.client("client/cl_settings.lua")
MuR.client("client/cl_animcreator.lua")
MuR.client("client/cl_sandbox.lua")
MuR.client("client/cl_rormusic.lua")
MuR.client("client/cl_presence.lua")
MuR.client("client/cl_policeraidcam.lua")
MuR.client("client/cl_storm.lua")

MuR.shared("extensions/sh_tfa_lean.lua")
MuR.shared("extensions/sh_better_flashlight.lua")
MuR.shared("extensions/sh_suppresion.lua")
MuR.shared("extensions/sh_litewounds.lua")
MuR.server("extensions/sv_litewounds.lua")
MuR.client("extensions/cl_chands.lua")
MuR.client("extensions/cl_autoicon.lua")
MuR.client("extensions/cl_litewounds.lua")

MuR.Language = MuR.Language or {}

MuR.PlayerModels = {
	["Civilian_Male"] = {"models/murdered/pm/citizen/male_01.mdl", "models/murdered/pm/citizen/male_02.mdl", "models/murdered/pm/citizen/male_03.mdl", "models/murdered/pm/citizen/male_04.mdl", "models/murdered/pm/citizen/male_05.mdl", "models/murdered/pm/citizen/male_06.mdl", "models/murdered/pm/citizen/male_07.mdl", "models/murdered/pm/citizen/male_08.mdl", "models/murdered/pm/citizen/male_09.mdl", "models/murdered/pm/citizen/male_10.mdl", "models/murdered/pm/citizen/male_11.mdl"},
	["Civilian_Female"] = {"models/murdered/pm/citizen/female_01.mdl", "models/murdered/pm/citizen/female_02.mdl", "models/murdered/pm/citizen/female_03.mdl", "models/murdered/pm/citizen/female_04.mdl", "models/murdered/pm/citizen/female_06.mdl", "models/murdered/pm/citizen/female_07.mdl"},
	["Medic_Male"] = {"models/murdered/pm/medic_01.mdl", "models/murdered/pm/medic_02.mdl", "models/murdered/pm/medic_03.mdl", "models/murdered/pm/medic_04.mdl", "models/murdered/pm/medic_05.mdl", "models/murdered/pm/medic_06.mdl", "models/murdered/pm/medic_07.mdl"},
	["Medic_Female"] = {"models/murdered/pm/medic_01_f.mdl", "models/murdered/pm/medic_02_f.mdl", "models/murdered/pm/medic_03_f.mdl", "models/murdered/pm/medic_04_f.mdl", "models/murdered/pm/medic_05_f.mdl", "models/murdered/pm/medic_06_f.mdl"},
	["Builder"] = {"models/murdered/pm/odessa.mdl",},
	["Maniac"] = {"models/murdered/pm/jason_v.mdl",},
	["Terrorist"] = {"models/murdered/pm/t_grunts.mdl",},
	["Shooter"] = {"models/murdered/pm/hatred_mh.mdl",},
	["Anarchist"] = {"models/murdered/pm/t_grunts.mdl",},
	["Police"] = {"models/murdered/pm/police/male_01.mdl", "models/murdered/pm/police/male_03.mdl", "models/murdered/pm/police/male_04.mdl", "models/murdered/pm/police/male_05.mdl", "models/murdered/pm/police/male_06.mdl", "models/murdered/pm/police/male_07.mdl", "models/murdered/pm/police/male_08.mdl", "models/murdered/pm/police/male_09.mdl"},
	["SWAT"] = {"models/murdered/pm/swat/male_01.mdl", "models/murdered/pm/swat/male_02.mdl", "models/murdered/pm/swat/male_03.mdl", "models/murdered/pm/swat/male_04.mdl", "models/murdered/pm/swat/male_05.mdl", "models/murdered/pm/swat/male_06.mdl", "models/murdered/pm/swat/male_07.mdl", "models/murdered/pm/swat/male_08.mdl", "models/murdered/pm/swat/male_09.mdl"},
	["Riot"] = {"models/murdered/pm/swat/male_01.mdl", "models/murdered/pm/swat/male_02.mdl", "models/murdered/pm/swat/male_03.mdl", "models/murdered/pm/swat/male_04.mdl", "models/murdered/pm/swat/male_05.mdl", "models/murdered/pm/swat/male_06.mdl", "models/murdered/pm/swat/male_07.mdl", "models/murdered/pm/swat/male_08.mdl", "models/murdered/pm/swat/male_09.mdl"},
	["Terrorist_TDM"] = {"models/murdered/pm/t_phoenix.mdl", "models/murdered/pm/t_leet.mdl", "models/murdered/pm/t_guerilla.mdl", "models/murdered/pm/t_arctic.mdl"},
	["Police_TDM"] = {"models/murdered/pm/ct_spetsnaz.mdl"},
	["Zombie"] = {"models/murdered/pm/zombie/zombie_male_01.mdl", "models/murdered/pm/zombie/zombie_male_02.mdl", "models/murdered/pm/zombie/zombie_male_03.mdl", "models/murdered/pm/zombie/zombie_male_04.mdl", "models/murdered/pm/zombie/zombie_male_05.mdl", "models/murdered/pm/zombie/zombie_male_06.mdl", "models/murdered/pm/zombie/zombie_male_07.mdl", "models/murdered/pm/zombie/zombie_male_08.mdl", "models/murdered/pm/zombie/zombie_male_09.mdl"},
	["Security"] = {"models/murdered/pm/guard/guard_01.mdl", "models/murdered/pm/guard/guard_02.mdl", "models/murdered/pm/guard/guard_03.mdl", "models/murdered/pm/guard/guard_04.mdl", "models/murdered/pm/guard/guard_05.mdl", "models/murdered/pm/guard/guard_06.mdl", "models/murdered/pm/guard/guard_07.mdl", "models/murdered/pm/guard/guard_08.mdl", "models/murdered/pm/guard/guard_09.mdl"},
	["SecurityForces"] = {"models/murdered/pm/sf/guard_01.mdl", "models/murdered/pm/sf/guard_02.mdl", "models/murdered/pm/sf/guard_03.mdl", "models/murdered/pm/sf/guard_04.mdl", "models/murdered/pm/sf/guard_05.mdl", "models/murdered/pm/sf/guard_06.mdl", "models/murdered/pm/sf/guard_07.mdl", "models/murdered/pm/sf/guard_08.mdl", "models/murdered/pm/sf/guard_09.mdl"},
	["GangGreen"] = {"models/murdered/pm/gangs/gang_groove_chem.mdl", "models/murdered/pm/gangs/gang_1.mdl", "models/murdered/pm/gangs/gang_2.mdl"},
	["GangRed"] = {"models/murdered/pm/gangs/gang_ballas_chem.mdl", "models/murdered/pm/gangs/gang_ballas_1.mdl", "models/murdered/pm/gangs/gang_ballas_2.mdl"}
}

local ftab = {"mur_food_apple", "mur_food_banana", "mur_food_beer1", "mur_food_beer2", "mur_food_burger", "mur_food_chickenwrap", "mur_food_colabig", "mur_food_colasmall", "mur_food_doritos", "mur_food_hotdog", "mur_food_icecream", "mur_food_lays", "mur_food_monster", "mur_food_mtndewcan", "mur_food_pepsican", "mur_food_redbull", "mur_food_sandwich"}

MuR.GamemodeChances = MuR.GamemodeChances or {}

MuR.Shop = {
	["Civilian"] = {
		{
			name = "Food",
			icon = "entities/food.png",
			price = 5,
			func = function(ply)
				ply:GiveWeapon(table.Random(ftab))
			end,
		},
		{
			name = "Flashlight",
			icon = "entities/flashlight.png",
			price = 10,
			func = function(ply)
				ply:AllowFlashlight(true)
			end,
		},
		{
			name = "Bandage",
			icon = "entities/mur_loot_bandage.png",
			price = 25,
			func = function(ply)
				ply:GiveWeapon("mur_loot_bandage")
			end,
		},
		{
			name = "Adrenaline",
			icon = "entities/mur_loot_adrenaline.png",
			price = 50,
			func = function(ply)
				ply:GiveWeapon("mur_loot_adrenaline")
			end,
		},
		{
			name = "Duct Tape",
			icon = "entities/mur_loot_ducttape.png",
			price = 50,
			func = function(ply)
				ply:GiveWeapon("mur_loot_ducttape")
			end,
		},
		{
			name = "First Aid Kit",
			icon = "entities/mur_loot_medkit.png",
			price = 75,
			func = function(ply)
				ply:GiveWeapon("mur_loot_medkit")
			end,
		},
		{
			name = "Hammer",
			icon = "entities/mur_loot_hammer.png",
			price = 100,
			func = function(ply)
				ply:GiveWeapon("mur_loot_hammer")
			end,
		},
		{
			name = "Compact Knife",
			icon = "entities/tfa_bs_compactk.png",
			price = 125,
			func = function(ply)
				ply:GiveWeapon("tfa_bs_compactk")
			end,
		},
		{
			name = "Phone",
			icon = "entities/mur_loot_phone.png",
			price = 150,
			func = function(ply)
				ply:GiveWeapon("mur_loot_phone")
			end,
		},
		{
			name = "Pepper Spray",
			icon = "entities/mur_pepperspray.png",
			price = 250,
			func = function(ply)
				ply:GiveWeapon("mur_pepperspray")
			end,
		},
	},
	["Killer"] = {
		{
			name = "Ammo",
			icon = "entities/am_bullets.png",
			price = 25,
			func = function(ply)
				local wep = ply:GetActiveWeapon()

				if IsValid(wep) and wep:GetMaxClip1() > 0 then
					ply:GiveAmmo(wep:GetMaxClip1(), wep:GetPrimaryAmmoType(), true)
				end
			end,
		},
		{
			name = "Midazolam",
			icon = "entities/mur_tranq.png",
			price = 25,
			func = function(ply)
				ply:GiveWeapon("mur_tranq")
			end,
		},
		{
			name = "Surveillance Probe",
			icon = "entities/mur_doorlooker.png",
			price = 50,
			traitor = true,
			func = function(ply)
				ply:GiveWeapon("mur_doorlooker")
			end,
		},
		{
			name = "Phencyclidine",
			icon = "entities/mur_loot_heroin.png",
			price = 50,
			traitor = true,
			func = function(ply)
				ply:GiveWeapon("mur_bredogen")
			end,
		},
		{
			name = "Tetrodotoxin",
			icon = "entities/mur_poisoncanister.png",
			price = 75,
			traitor = true,
			func = function(ply)
				ply:GiveWeapon("mur_poisoncanister")
			end,
		},
		{
			name = "Hydrogen Cyanide",
			icon = "entities/mur_cyanide.png",
			price = 75,
			traitor = true,
			func = function(ply)
				ply:GiveWeapon("mur_cyanide")
			end,
		},
		{
			name = "Hydrofluoric Acid",
			icon = "entities/mur_acid.png",
			price = 75,
			traitor = false,
			func = function(ply)
				ply:GiveWeapon("mur_acid")
			end,
		},
		{
			name = "Bear Trap",
			icon = "entities/mur_beartrap.png",
			price = 100,
			traitor = false,
			func = function(ply)
				ply:GiveWeapon("mur_beartrap")
			end,
		},
		{
			name = "Taser",
			icon = "entities/mur_taser.png",
			price = 100,
			func = function(ply)
				ply:GiveWeapon("mur_taser")
				ply:GiveAmmo(3, "GaussEnergy", true)
			end,
		},
		{
			name = "Heroin",
			icon = "entities/mur_loot_heroin.png",
			price = 100,
			func = function(ply)
				ply:GiveWeapon("mur_loot_heroin")
			end,
		},
		{
			name = "Gasoline",
			icon = "entities/mur_gasoline.png",
			price = 125,
			func = function(ply)
				ply:GiveWeapon("mur_gasoline")
			end,
		},
		{
			name = "F1 Grenade",
			icon = "entities/mur_f1.png",
			price = 150,
			func = function(ply)
				ply:GiveWeapon("mur_f1")
			end,
		},
		{
			name = "M67 Grenade",
			icon = "entities/mur_m67.png",
			price = 150,
			func = function(ply)
				ply:GiveWeapon("mur_m67")
			end,
		},
		{
			name = "Light Weapon",
			icon = "entities/tfa_bs_glock.png",
			price = 200,
			func = function(ply)
				ply:GiveWeapon(table.Random(MuR.WeaponTable["Secondary"]).class)
			end,
		},
		{
			name = "IED",
			icon = "entities/mur_ied.png",
			price = 225,
			traitor = true,
			func = function(ply)
				ply:GiveWeapon("mur_ied")
			end,
		},
		{
			name = "FPV Drone",
			icon = "entities/mur_drone.png",
			price = 250,
			traitor = true,
			func = function(ply)
				ply:GiveWeapon("mur_drone")
			end,
		},
		{
			name = "Mind Controller",
			icon = "entities/mur_loot_heroin.png",
			price = 300,
			traitor = true,
			func = function(ply)
				ply:GiveWeapon("mur_mind_controller")
			end,
		},
		{
			name = "Heavy Weapon",
			icon = "entities/tfa_bs_akm.png",
			price = 500,
			func = function(ply)
				ply:GiveWeapon(table.Random(MuR.WeaponTable["Primary"]).class)
			end,
		},
		{
			name = "Wall-Piercing C4",
			icon = "entities/mur_c4.png",
			price = 750,
			traitor = true,
			func = function(ply)
				ply:GiveWeapon("mur_c4")
			end,
		},
	},
	["Soldier"] = {
		{
			name = "Ammo",
			icon = "entities/am_bullets.png",
			price = 25,
			func = function(ply)
				local wep = ply:GetActiveWeapon()

				if IsValid(wep) and wep:GetMaxClip1() > 0 then
					ply:GiveAmmo(wep:GetMaxClip1(), wep:GetPrimaryAmmoType(), true)
				end
			end,
		},
		{
			name = "F1 Grenade",
			icon = "entities/mur_f1.png",
			price = 50,
			func = function(ply)
				ply:GiveWeapon("mur_f1")
			end,
		},
		{
			name = "M67 Grenade",
			icon = "entities/mur_m67.png",
			price = 50,
			func = function(ply)
				ply:GiveWeapon("mur_m67")
			end,
		},
		{
			name = "Flashbang",
			icon = "entities/mur_flashbang.png",
			price = 50,
			func = function(ply)
				ply:GiveWeapon("mur_flashbang")
			end,
		},
		{
			name = "Light Weapon",
			icon = "entities/tfa_bs_glock.png",
			price = 75,
			func = function(ply)
				ply:GiveWeapon(table.Random(MuR.WeaponTable["Secondary"]).class)
			end,
		},
		{
			name = "IED",
			icon = "entities/mur_ied.png",
			price = 75,
			func = function(ply)
				ply:GiveWeapon("mur_ied")
			end,
		},
		{
			name = "FPV Drone",
			icon = "entities/mur_drone.png",
			price = 150,
			func = function(ply)
				ply:GiveWeapon("mur_drone")
			end,
		},
		{
			name = "Heavy Weapon",
			icon = "entities/tfa_bs_akm.png",
			price = 250,
			func = function(ply)
				ply:GiveWeapon(table.Random(MuR.WeaponTable["Primary"]).class)
			end,
		},
		{
			name = "RPG-7",
			icon = "entities/tfa_bs_rpg7.png",
			price = 500,
			func = function(ply)
				ply:GiveWeapon("tfa_bs_rpg7")
			end,
		}
	}
}

MuR.PoliceClasses = {
	["patrol"] = {
		npcs = {"npc_vj_bloodshed_police"},
		weps = {"weapon_vj_bloodshed_glock"},
	},
	["swat"] = {
		npcs = {"npc_vj_bloodshed_swat"},
		weps = {"weapon_vj_bloodshed_m4a1"},
	},
	["security"] = {
		npcs = {"npc_vj_bloodshed_police"},
		weps = {"weapon_vj_bloodshed_glock"},
		underroof = false,
	},
	["suspect"] = {
		npcs = {"npc_vj_bloodshed_suspect"},
		weps = {"weapon_vj_bloodshed_sus_primary", "weapon_vj_bloodshed_sus_primary", "weapon_vj_bloodshed_sus_melee", "weapon_vj_bloodshed_sus_secondary", "weapon_vj_bloodshed_sus_secondary", "weapon_vj_bloodshed_sus_secondary", "weapon_vj_bloodshed_sus_secondary", "weapon_vj_bloodshed_sus_secondary"},
		underroof = true,
	},
	["zombie"] = {"npc_vj_bloodshed_zombie"},
	max_npcs = 16,
	delay_spawn = 2,
	security_spawn = 0,
	no_npc_police = false,
	no_player_police = false,
}

MuR.MaxLootNumber = 100

MuR.Loot = {
	---WEAPONS---
	{
		class = "mur_pepperspray",
		chance = 12
	},
	{
		class = "tfa_bs_compactk",
		chance = 15
	},
	{
		class = "tfa_bs_wrench",
		chance = 15
	},
	{
		class = "tfa_bs_crowbar",
		chance = 15
	},
	{
		class = "tfa_bs_pipe",
		chance = 12
	},
	{
		class = "tfa_bs_knife",
		chance = 14
	},
	{
		class = "tfa_bs_hatchet",
		chance = 12
	},
	{
		class = "tfa_bs_machete",
		chance = 10
	},
	{
		class = "tfa_bs_spade",
		chance = 10
	},
	{
		class = "tfa_bs_cleaver",
		chance = 14
	},
	{
		class = "tfa_bs_bat",
		chance = 12
	},
	{
		class = "tfa_bs_fireaxe",
		chance = 8
	},
	{
		class = "tfa_bs_pickaxe",
		chance = 12
	},
	{
		class = "tfa_bs_fubar",
		chance = 10
	},
	{
		class = "tfa_bs_sledge",
		chance = 6
	},
	{
		class = "tfa_bs_pm",
		chance = 4
	},
	{
		class = "tfa_bs_colt",
		chance = 4
	},
	{
		class = "tfa_bs_m9",
		chance = 3
	},
	{
		class = "tfa_bs_glock",
		chance = 3
	},
	{
		class = "tfa_bs_usp",
		chance = 3
	},
	{
		class = "tfa_bs_walther",
		chance = 3
	},
	{
		class = "tfa_bs_p320",
		chance = 3
	},
	{
		class = "tfa_bs_mateba",
		chance = 2
	},
	{
		class = "tfa_bs_cobra",
		chance = 2
	},
	{
		class = "tfa_bs_deagle",
		chance = 1
	},
	---OTHERS---
	{
		class = "mur_loot_money",
		chance = 50
	},
	{
		class = "mur_loot_ammo",
		chance = 30
	},
	{
		class = "mur_loot_flashlight",
		chance = 25
	},
	{
		class = "mur_loot_bandage",
		chance = 25
	},
	{
		class = "mur_loot_ducttape",
		chance = 20
	},
	{
		class = "mur_loot_adrenaline",
		chance = 10
	},
	{
		class = "mur_loot_heroin",
		chance = 10
	},
	{
		class = "mur_loot_medkit",
		chance = 5
	},
	{
		class = "mur_loot_hammer",
		chance = 5
	},
	{
		class = "mur_loot_phone",
		chance = 5
	},
	{
		class = "mur_gasoline",
		chance = 5
	},
}

for k, v in ipairs(ftab) do
	table.insert(MuR.Loot, {
		class = v,
		chance = 50
	})
end

MuR.MaleNames =  {"Andrew", "Max", "James", "David", "Daniel", "Michael", "Matthew", "Robert", "John", "William", "Thomas", "Richard", "Mark", "Charles", "Christopher", "Paul", "Steven", "George", "Edward", "Peter", "Anthony", "Simon", "Adam", "Luke", "Benjamin", "Samuel", "Alexander", "Henry", "Joseph", "Ryan", "Liam", "Harry", "Jack", "Oliver", "Noah", "Leo", "Oscar", "Ethan", "Jacob", "Lucas", "Joshua", "Logan", "Mason", "Isaac", "Dylan", "Finley", "Archie", "Theo", "Alfie", "Charlie"}
MuR.FemaleNames = {"Emma", "Olivia", "Sophia", "Isabella", "Ava", "Emily", "Abigail", "Mia", "Chloe", "Ella", "Amelia", "Grace", "Lily", "Hannah", "Zoe", "Anna", "Charlotte", "Lucy", "Evelyn", "Ruby", "Eva", "Alice", "Molly", "Isla", "Lola", "Eleanor", "Harper", "Scarlett", "Layla", "Ellie", "Mila", "Ivy", "Isabelle", "Rosie", "Freya", "Poppy", "Daisy", "Evie", "Sofia", "Willow", "Phoebe", "Esme", "Sienna", "Maya", "Luna", "Holly", "Lily", "Imogen", "Erin", "Bella"}

MuR.CustomLootEntityIcons = {
	["mur_loot_money"] = {"Money", "entities/money.png"},
	["mur_loot_flashlight"] = {"Flashlight", "entities/flashlight.png"},
	["mur_loot_ammo"] = {"Ammo", "entities/am_bullets.png"},
}

MuR.LootableProps = {
	"models/props_junk/wood_crate001a.mdl",
	"models/props_junk/wood_crate001a_damaged.mdl",
	"models/props_junk/wood_crate002a.mdl",
	"models/props_junk/cardboard_box001a.mdl",
	"models/props_junk/cardboard_box001b.mdl",
	"models/props_junk/cardboard_box002a.mdl",
	"models/props_junk/cardboard_box002b.mdl",
	"models/props_junk/cardboard_box003a.mdl",
	"models/props_junk/cardboard_box003b.mdl",
	"models/props_junk/trashdumpster01a.mdl",
	"models/props_junk/trashbin01a.mdl",
	"models/props_borealis/bluebarrel001.mdl",
	"models/props_c17/oildrum001.mdl",
	"models/props_c17/furniturecupboard001a.mdl",
	"models/props_c17/furnituredrawer001a.mdl",
	"models/props_c17/furnituredrawer002a.mdl",
	"models/props_c17/furnituredrawer003a.mdl",
	"models/props_c17/furnituredresser001a.mdl",
	"models/props_interiors/furniture_desk01a.mdl",
	"models/props_c17/furniturestove001a.mdl",
	"models/props_c17/gravestone_coffinpiece001a.mdl",
	"models/props_c17/gravestone_coffinpiece002a.mdl",
	"models/props_c17/lockers001a.mdl",
	"models/props_wasteland/kitchen_fridge001a.mdl",
	"models/props_interiors/vendingmachinesoda01a.mdl",
	"models/props_junk/plasticbucket001a.mdl",
	"models/props_wasteland/cargo_container01.mdl",
	"models/props_lab/filecabinet02.mdl",
	"models/props_wasteland/controlroom_filecabinet001a.mdl",
	"models/props_wasteland/controlroom_filecabinet002a.mdl",
	"models/props_wasteland/controlroom_storagecloset001a.mdl",
	"models/props_wasteland/controlroom_storagecloset001b.mdl",
	"models/props_combine/breendesk.mdl",
	"models/props_wasteland/kitchen_counter001c.mdl",
	"models/props_wasteland/kitchen_stove001a.mdl",
	"models/props_wasteland/kitchen_stove002a.mdl",
	"models/props_wasteland/laundry_dryer001.mdl",
	"models/props_wasteland/laundry_dryer002.mdl",
	"models/props_wasteland/laundry_washer001a.mdl",
	"models/props_c17/furniturewashingmachine001a.mdl",
	"models/props_c17/furnituretoilet001a.mdl",
	"models/props_c17/cashregister01a.mdl",
	"models/props_c17/briefcase001a.mdl",
	"models/props_c17/suitcase001a.mdl",
	"models/props_c17/suitcase_passenger_physics.mdl",
	"models/props_junk/garbage128_composite001a.mdl",
	"models/props_junk/garbage128_composite001b.mdl",
	"models/props_junk/garbage256_composite001a.mdl",
	"models/props_junk/garbage256_composite001b.mdl",
	"models/props_lab/partsbin01.mdl",
	"models/props_phx/oildrum001.mdl",
	"models/props_phx/facepunch_barrel.mdl",
	"models/props_interiors/furniture_cabinetdrawer02a.mdl",
	"models/props_interiors/furniture_cabinetdrawer01a.mdl",
	"models/props_wasteland/prison_toilet01.mdl",
	"models/props_c17/furniturefridge001a.mdl",
	"models/props_junk/wood_crate001a_damagedmax.mdl",
	"models/props_lab/dogobject_wood_crate001a_damagedmax.mdl",
	"models/props_lab/powerbox01a.mdl",
	"models/combine_dropship_container.mdl",
	"models/props_combine/headcrabcannister01a.mdl",
	"models/props_combine/headcrabcannister01b.mdl",
	"models/items/ammocrate_rockets.mdl",
	"models/items/ammocrate_smg1.mdl",
	"models/items/ammocrate_ar2.mdl",
	"models/items/ammocrate_grenade.mdl",
	"models/items/item_item_crate.mdl",
	"models/props_trainstation/train003.mdl",
	"models/props_trainstation/train001.mdl",
	"models/props_vehicles/trailer001a.mdl",
	"models/props_lab/scrapyarddumpster_static.mdl",
	"models/props_trainstation/train_outro_car01.mdl",
	"models/items/item_beacon_crate.mdl",
	"models/items/ammocrate_smg2.mdl",
	"models/items/ammocrate_pistol.mdl",
	"models/items/ammocrate_buckshot.mdl",
	"models/props_forest/footlocker01_closed.mdl",
	"models/props_forest/refrigerator01.mdl",
	"models/props_forest/stove01.mdl",
	"models/props_outland/haybale.mdl",
	"models/props_silo/signalbox_01.mdl",
	"models/props_trainstation/boxcar.mdl",
	"models/props_trainstation/boxcar2.mdl",
	"models/props_trainstation/boxcar2_damaged1.mdl",
	"models/props_trainstation/boxcar2a.mdl",
	"models/props_trainstation/diesel.mdl",
	"models/props_trainstation/train_boxcar.mdl",
	"models/props_trainstation/train_boxcar_damaged.mdl",
	"models/props_trainstation/train_engine.mdl",
	"models/vehicle/helicopter.mdl",
	"models/lostcoast/props_wasteland/boat_drydock01a.mdl",
	"models/lostcoast/props_wasteland/boat_fishing01a.mdl",
	"models/props_crates/static_crate_40.mdl",
	"models/props_crates/static_crate_48.mdl",
	"models/props_crates/static_crate_64.mdl",
	"models/props_crates/supply_crate01.mdl",
	"models/props_crates/supply_crate02.mdl",
	"models/props_crates/supply_crate03.mdl",
	"models/props_crates/tnt_dump.mdl",
	"models/props_fortifications/fueldrum.mdl",
	"models/props_furniture/bookcase_large.mdl",
	"models/props_furniture/cabinet_large.mdl",
	"models/props_furniture/cupboard1.mdl",
	"models/props_furniture/desk1.mdl",
	"models/props_furniture/drawer1.mdl",
	"models/props_furniture/drawer2.mdl",
	"models/props_furniture/drawer3.mdl",
	"models/props_furniture/drawer4.mdl",
	"models/props_furniture/dresser1.mdl",
	"models/props_furniture/kitchen_cabinet1.mdl",
	"models/props_furniture/kitchen_countertop1.mdl",
	"models/props_furniture/kitchen_oven1.mdl",
	"models/props_furniture/nightstand_large.mdl",
	"models/props_furniture/nightstand_small.mdl",
	"models/props_misc/claypot01.mdl",
	"models/props_misc/claypot02.mdl",
	"models/props_misc/grainbasket01b.mdl",
	"models/props_normandy/haybale.mdl",
	"models/props_misc/well-1.mdl",
	"models/props_2fort/locker001.mdl",
	"models/props_2fort/miningcrate001.mdl",
	"models/props_2fort/miningcrate002.mdl",
	"models/props_2fort/oildrum.mdl",
	"models/props_2fort/wastebasket01.mdl",
	"models/props_badlands/barrel01.mdl",
	"models/props_badlands/barrel02.mdl",
	"models/props_badlands/barrel03.mdl",
	"models/props_badlands/barrel_flatbed01.mdl",
	"models/props_farm/box_cluster01.mdl",
	"models/props_farm/box_cluster02.mdl",
	"models/props_farm/wooden_barrel.mdl",
	"models/props_forest/kitchen_stove.mdl",
	"models/props_hydro/barrel_crate.mdl",
	"models/props_hydro/barrel_crate_half.mdl",
	"models/props_hydro/keg_large.mdl",
	"models/props_hydro/water_barrel.mdl",
	"models/props_hydro/water_barrel_cluster.mdl",
	"models/props_hydro/water_barrel_cluster2.mdl",
	"models/props_hydro/water_barrel_cluster3.mdl",
	"models/props_hydro/water_barrel_large.mdl",
	"models/props_lakeside/wood_crate_01.mdl",
	"models/props_manor/cardboard_box_set_01.mdl",
	"models/props_manor/cardboard_box_set_02.mdl",
	"models/props_medieval/medieval_resupply.mdl",
	"models/props_vehicles/train_flatcar_container.mdl",
	"models/props_swamp/landrover.mdl",
	"models/props_mvm/oildrum.mdl",
	"models/props/cs_assault/box_stack1.mdl",
	"models/props/cs_assault/box_stack2.mdl",
	"models/props/cs_assault/dryer_box.mdl",
	"models/props/cs_assault/dryer_box2.mdl",
	"models/props/cs_assault/moneypallet.mdl",
	"models/props/cs_assault/moneypallet02.mdl",
	"models/props/cs_assault/moneypallet02a.mdl",
	"models/props/cs_assault/moneypallet02b.mdl",
	"models/props/cs_assault/moneypallet02c.mdl",
	"models/props/cs_assault/moneypallet02d.mdl",
	"models/props/cs_assault/moneypallet02e.mdl",
	"models/props/cs_assault/moneypallet03.mdl",
	"models/props/cs_assault/moneypallet03a.mdl",
	"models/props/cs_assault/moneypallet03b.mdl",
	"models/props/cs_assault/moneypallet03c.mdl",
	"models/props/cs_assault/moneypallet03d.mdl",
	"models/props/cs_assault/moneypallet03e.mdl",
	"models/props/cs_assault/moneypalleta.mdl",
	"models/props/cs_assault/moneypalletb.mdl",
	"models/props/cs_assault/moneypalletc.mdl",
	"models/props/cs_assault/moneypalletd.mdl",
	"models/props/cs_assault/moneypallete.mdl",
	"models/props/cs_assault/moneypallet_washerdryer.mdl",
	"models/props/cs_assault/washer_box.mdl",
	"models/props/cs_assault/washer_box2.mdl",
	"models/props/cs_militia/boxes_frontroom.mdl",
	"models/props/cs_militia/boxes_garage.mdl",
	"models/props/cs_militia/boxes_garage_lower.mdl",
	"models/props/cs_militia/crate_extralargemill.mdl",
	"models/props/cs_militia/crate_extrasmallmill.mdl",
	"models/props/cs_militia/crate_stackmill.mdl",
	"models/props/cs_militia/dryer.mdl",
	"models/props/cs_militia/food_stack.mdl",
	"models/props/cs_militia/footlocker01_closed.mdl",
	"models/props/cs_militia/microwave01.mdl",
	"models/props/cs_militia/paintbucket01.mdl",
	"models/props/cs_militia/refrigerator01.mdl",
	"models/props/cs_militia/roof_vent.mdl",
	"models/props/cs_militia/stove01.mdl",
	"models/props/cs_office/cardboard_box01.mdl",
	"models/props/cs_office/cardboard_box03.mdl",
	"models/props/cs_office/crates_indoor.mdl",
	"models/props/cs_office/crates_outdoor.mdl",
	"models/props/cs_office/file_cabinet1.mdl",
	"models/props/cs_office/file_cabinet1_group.mdl",
	"models/props/cs_office/file_cabinet2.mdl",
	"models/props/cs_office/file_cabinet3.mdl",
	"models/props/cs_office/microwave.mdl",
	"models/props/cs_office/paperbox_pile_01.mdl",
	"models/props/cs_office/shelves_metal1.mdl",
	"models/props/cs_office/shelves_metal2.mdl",
	"models/props/cs_office/shelves_metal3.mdl",
	"models/props/cs_office/trash_can.mdl",
	"models/props/cs_office/vending_machine.mdl",
	"models/props/de_nuke/crate_extralarge.mdl",
	"models/props/de_nuke/crate_extrasmall.mdl",
	"models/props/de_nuke/crate_large.mdl",
	"models/props/de_nuke/crate_small.mdl",
	"models/props/de_nuke/file_cabinet1_group.mdl",
	"models/props/de_nuke/nuclearcontainerboxclosed.mdl",
	"models/props_downtown/side_table.mdl",
	"models/props_equipment/cargo_container01.mdl",
	"models/props_interiors/dresser_short.mdl",
	"models/props_interiors/desk_metal.mdl",
	"models/props_interiors/file_cabinet1_group.mdl",
	"models/props_interiors/refrigerator03.mdl",
	"models/props_interiors/stove02.mdl",
	"models/props_interiors/stove03_industrial.mdl",
	"models/props_interiors/stove04_industrial.mdl",
	"models/props_street/trashbin01.mdl",
	"models/props_unique/airport/luggage1.mdl",
	"models/props_unique/airport/luggage2.mdl",
	"models/props_unique/airport/luggage3.mdl",
	"models/props_unique/airport/luggage4.mdl",
	"models/props_unique/airport/luggage_pile1.mdl",
	"models/props_urban/ashtray_stand001.mdl",
	"models/props_urban/pontoon_drum001.mdl",
	"models/props_urban/highway_barrel001.mdl",
	"models/props_vehicles/train_box_euro.mdl",
	"models/props_vehicles/train_box.mdl",
	"models/props_urban/oil_drum001.mdl",
	"models/props_urban/garbage_can001.mdl",
	"models/props_urban/garbage_can002.mdl",
	"models/props_vehicles/semi_trailer_freestanding.mdl",
	"models/props_vehicles/airport_baggage_cart2.mdl",
	"models/props_vehicles/semi_trailer.mdl",
	"models/props_vehicles/airport_catering_truck.mdl",
	"models/props_c17/furnituredrawer001b.mdl",
	"models/props_c17/furnituredrawer001c.mdl",
	"models/props_c17/lockers001a_single.mdl",
	"models/props_c17/lockers001b_single.mdl",
	"models/props_interiors/furniture_drawer01a.mdl",
	"models/props_interiors/furniture_drawer01b.mdl",
	"models/props_junk/wood_crate001a_half.mdl",
	"models/props_junk/wood_crate001b.mdl",
	"models/props_junk/wood_crate002a_half.mdl",
	"models/props_junk/wood_crate003a.mdl",
	"models/props_lab/filedesk01a.mdl"
}

MuR.WeaponData = {
	["DefenderWeapons"] = {
		{
			class = "tfa_bs_m37",
			ammo = "Buckshot",
			count = 25,
		},
		{
			class = "tfa_bs_mosin",
			ammo = "357",
			count = 5,
		},
		{
			class = "tfa_bs_kar98",
			ammo = "357",
			count = 6,
		},
		{
			class = "tfa_bs_izh43",
			ammo = "Buckshot",
			count = 12,
		},
	}
}

MuR.ExperimentWeapons = {
	{
		class = "weapon_physcannon",
		ammo = "",
		count = 0,
	},
	{
		class = "weapon_physgun",
		ammo = "",
		count = 0,
	},
}

MuR.WeaponToRagdoll = {}

MuR.RagdollGunData = {
    ["Glock"] = {
        model = "models/weapons/w_pist_p228.mdl",
        offsetpos = Vector(-1,3,-2),
        offsetang = Angle(0,0,180),
        twohand = false,
        automatic = false,
    },
    ["Seven"] = {
        model = "models/weapons/w_pist_fiveseven.mdl",
        offsetpos = Vector(-1,3,-2),
        offsetang = Angle(0,0,180),
        twohand = false,
        automatic = false,
    },
    ["Deagle"] = {
        model = "models/weapons/w_357.mdl",
        offsetpos = Vector(-1,3,2),
        offsetang = Angle(0,0,180),
        twohand = false,
        automatic = false,
    },
    ["P228"] = {
        model = "models/weapons/w_pist_p228.mdl",
        offsetpos = Vector(-1,3,-2),
        offsetang = Angle(0,0,180),
        twohand = false,
        automatic = false,
    },
    ["USP"] = {
        model = "models/weapons/w_pist_usp.mdl",
        offsetpos = Vector(-1,3,-2),
        offsetang = Angle(0,0,180),
        twohand = false,
        automatic = false,
    },
    ["Elite"] = {
        model = "models/weapons/w_pist_elite_single.mdl",
        offsetpos = Vector(-1,3,-2),
        offsetang = Angle(0,0,180),
        twohand = false,
        automatic = false,
    },
    ["USPs"] = {
        model = "models/weapons/w_pist_usp_silencer.mdl",
        offsetpos = Vector(-1,3,-2),
        offsetang = Angle(0,0,180),
        twohand = false,
        automatic = false,
    },
    ["MAC"] = {
        model = "models/weapons/w_smg_mac10.mdl",
        offsetpos = Vector(-1,3,-2),
        offsetang = Angle(0,0,180),
        twohand = false,
        automatic = true,
    },


    ["AK47"] = {
        model = "models/weapons/w_rif_ak47.mdl",
        offsetpos = Vector(-1,12,-3),
        offsetang = Angle(0,0,180),
        twohand = true,
        automatic = true,
    },
    ["M4A1"] = {
        model = "models/weapons/w_rif_m4a1.mdl",
        offsetpos = Vector(-1,12,-3),
        offsetang = Angle(0,0,180),
        twohand = true,
        automatic = true,
    },
    ["MP5"] = {
        model = "models/weapons/w_smg_mp5.mdl",
        offsetpos = Vector(-1,7,-3),
        offsetang = Angle(0,0,180),
        twohand = true,
        automatic = true,
    },
    ["M3"] = {
        model = "models/weapons/w_shot_m3super90.mdl",
        offsetpos = Vector(-1,12,-3),
        offsetang = Angle(0,0,180),
        twohand = true,
        automatic = false,
        extradelay = 0.7,
    },
    ["AWP"] = {
        model = "models/weapons/w_snip_awp.mdl",
        offsetpos = Vector(-1,12,-3),
        offsetang = Angle(0,0,180),
        twohand = true,
        automatic = false,
        extradelay = 1.4,
    },
    ["Scout"] = {
        model = "models/weapons/w_snip_scout.mdl",
        offsetpos = Vector(-1,12,-3),
        offsetang = Angle(0,0,180),
        twohand = true,
        automatic = false,
    },

    ------------------

    -- [[ PISTOLS ]]

	["tfa_bs_m9"] = {model = "models/sidearms/w_m9.mdl", offsetpos = Vector(-1.5,5,1.5), offsetang = Angle(180,180,0), twohand = false, automatic = false},
	["tfa_bs_colt"] = {model = "models/sidearms/w_1911.mdl", offsetpos = Vector(-1.5,5,1.5), offsetang = Angle(180,180,0), twohand = false, automatic = false},
    ["tfa_bs_glock"] = {model = "models/sidearms/w_glock.mdl", offsetpos = Vector(5,1,3), offsetang = Angle(180,90,20), twohand = false, automatic = false},
	["tfa_bs_glock_t"] = {model = "models/sidearms/w_glock_t.mdl", offsetpos = Vector(5,1,3), offsetang = Angle(180,90,20), twohand = false, automatic = false},
	["tfa_bs_usp"] = {model = "models/sidearms/w_usp_match.mdl", offsetpos = Vector(-1.5,5,2), offsetang = Angle(180,180,0), twohand = false, automatic = false},
	["tfa_bs_deagle"] = {model = "models/sidearms/w_deagle.mdl", offsetpos = Vector(-1.5,5,1.5), offsetang = Angle(180,180,0), twohand = false, automatic = false},
	["tfa_bs_cobra"] = {model = "models/sidearms/w_thanez_cobra.mdl", offsetpos = Vector(-1.5,5,0), offsetang = Angle(180,180,0), twohand = false, automatic = false},
	["tfa_bs_pm"] = {model = "models/sidearms/w_pm.mdl", offsetpos = Vector(-1.5,5,2), offsetang = Angle(180,180,0), twohand = false, automatic = false},
	["tfa_bs_mateba"] = {model = "models/sidearms/w_mateba.mdl", offsetpos = Vector(-1.5,5,2), offsetang = Angle(180,180,0), twohand = false, automatic = false},
	["tfa_bs_p320"] = {model = "models/sidearms/w_p320.mdl", offsetpos = Vector(-1.5,5,2), offsetang = Angle(180,180,0), twohand = false, automatic = false},
	["tfa_bs_walther"] = {model = "models/sidearms/w_ins2_pist_p99.mdl", offsetpos = Vector(-1.5,5,2), offsetang = Angle(180,180,0), twohand = false, automatic = false},

	-- [[ SNIPER RIFLES ]]

	["tfa_bs_mosin"] = {model = "models/snipers/w_ins2_mosin.mdl", offsetpos = Vector(-5.5,-2,6), offsetang = Angle(180,180,0), twohand = true, automatic = false},
	["tfa_bs_svd"] = {model = "models/marksman/w_nam_svd.mdl", offsetpos = Vector(-2.5,5,2), offsetang = Angle(180,180,0), twohand = true, automatic = false},
	["tfa_bs_m82"] = {model = "models/snipers/w_inss_m82.mdl", offsetpos = Vector(-2.5,5,0), offsetang = Angle(180,180,0), twohand = true, automatic = false},
	["tfa_bs_m24"] = {model = "models/snipers/w_m24.mdl", offsetpos = Vector(-2,8,1), offsetang = Angle(180,180,0), twohand = true, automatic = false},
	["tfa_bs_kar98"] = {model = "models/snipers/w_k98.mdl", offsetpos = Vector(-2,6,1), offsetang = Angle(180,180,0), twohand = true, automatic = false},

        -- [[ MARKSMAN RIFLES ]]

	["tfa_bs_sks"] = {model = "models/marksman/w_sks.mdl", offsetpos = Vector(-3,8,0), offsetang = Angle(180,180,0), twohand = true, automatic = false},
	["tfa_bs_sr25"] = {model = "models/marksman/w_sr25_gleb.mdl", offsetpos = Vector(-2.5,5,2), offsetang = Angle(180,180,0), twohand = true, automatic = false},

        -- [[ SHOTGUNS ]]

	["tfa_bs_spas"] = {model = "models/shotguns/w_spas12_bri.mdl", offsetpos = Vector(-2,7,4), offsetang = Angle(180,180,0), twohand = true, automatic = false},
	["tfa_bs_m500"] = {model = "models/shotguns/w_m500.mdl", offsetpos = Vector(-1.8,6,3), offsetang = Angle(180,180,0), twohand = true, automatic = false},
	["tfa_bs_m590"] = {model = "models/shotguns/w_m590.mdl", offsetpos = Vector(-2,7,2), offsetang = Angle(180,180,0), twohand = true, automatic = false},
	["tfa_bs_nova"] = {model = "models/shotguns/w_nova.mdl", offsetpos = Vector(-1,-1,0), offsetang = Angle(180,180,0), twohand = true, automatic = false},
	["tfa_bs_m1014"] = {model = "models/shotguns/w_m1014.mdl", offsetpos = Vector(-2,7,4), offsetang = Angle(180,180,0), twohand = true, automatic = false},
	["tfa_bs_izh43"] = {model = "models/shotguns/w_doublebarrel_new.mdl", offsetpos = Vector(-2,3,1.8), offsetang = Angle(180,180,0), twohand = true, automatic = false},
	["tfa_bs_izh43sw"] = {model = "models/shotguns/w_izh43_sawnoff.mdl", offsetpos = Vector(-1,1,0.5), offsetang = Angle(180,180,0), twohand = false, automatic = false},
	["tfa_bs_ks23"] = {model = "models/shotguns/w_coldwar_ks23.mdl", offsetpos = Vector(-2,1,0), offsetang = Angle(180,180,0), twohand = true, automatic = false},
	["tfa_bs_m37"] = {model = "models/shotguns/w_tfa_ithaca m37.mdl", offsetpos = Vector(-4,-5,5), offsetang = Angle(0,270,0), twohand = true, automatic = false},

        -- [[ RIFLES ]]

	["tfa_bs_ak74"] = {model = "models/rifles/w_ak74.mdl", offsetpos = Vector(-2.5,5,3), offsetang = Angle(180,180,0), twohand = true, automatic = true},
	["tfa_bs_akm"] = {model = "models/rifles/w_akm.mdl", offsetpos = Vector(-2.5,5,2), offsetang = Angle(180,180,0), twohand = true, automatic = true},
	["tfa_bs_aks74u"] = {model = "models/rifles/w_aks74u.mdl", offsetpos = Vector(-2,5,2), offsetang = Angle(180,180,0), twohand = true, automatic = true},
	["tfa_bs_aug"] = {model = "models/rifles/w_aug.mdl", offsetpos = Vector(-2.5,5,2), offsetang = Angle(180,180,0), twohand = true, automatic = true},
	["tfa_bs_badger"] = {model = "models/rifles/w_inss_q_honeybadger.mdl", offsetpos = Vector(-2.5,5,2), offsetang = Angle(180,180,0), twohand = true, automatic = true},
	["tfa_bs_g3"] = {model = "models/rifles/g3a3/w_fal.mdl", offsetpos = Vector(-2.5,5,2), offsetang = Angle(180,180,0), twohand = true, automatic = true},
	["tfa_bs_hk416"] = {model = "models/rifles/w_hk416.mdl", offsetpos = Vector(-2,6,2), offsetang = Angle(180,180,0), twohand = true, automatic = true},
	["tfa_bs_m4a1"] = {model = "models/rifles/m4a1/w_m4a1.mdl", offsetpos = Vector(-2,6,2), offsetang = Angle(180,180,0), twohand = true, automatic = true},
	["tfa_bs_l1a1"] = {model = "models/rifles/l1a1/w_l1a1.mdl", offsetpos = Vector(-2.5,5,2), offsetang = Angle(180,180,0), twohand = true, automatic = true},
	["tfa_bs_val"] = {model = "models/rifles/w_asval.mdl", offsetpos = Vector(-1,12,2), offsetang = Angle(180,180,0), twohand = true, automatic = true},
	["tfa_bs_acr"] = {model = "models/rifles/w_acr.mdl", offsetpos = Vector(-2.5,5,2), offsetang = Angle(180,180,0), twohand = true, automatic = true},
	["tfa_bs_draco"] = {model = "models/rifles/w_draco.mdl", offsetpos = Vector(-2,6,1), offsetang = Angle(0,0,180), twohand = true, automatic = true},
	["tfa_bs_ak12"] = {model = "models/rifles/w_ak12.mdl", offsetpos = Vector(-2,8,1), offsetang = Angle(0,0,180), twohand = true, automatic = true},
	["tfa_bs_m16"] = {model = "models/rifles/w_doi_m16a1.mdl", offsetpos = Vector(-4,-4,6), offsetang = Angle(0,0,180), twohand = true, automatic = true},
	["tfa_bs_sg552"] = {model = "models/rifles/w_sg55x.mdl", offsetpos = Vector(2,-16,1), offsetang = Angle(0,180,180), twohand = true, automatic = true},

        -- [[ MACHINE GUNS ]]

	["tfa_bs_m249"] = {model = "models/machine/w_m249.mdl", offsetpos = Vector(-2,5,2), offsetang = Angle(180,180,0), twohand = true, automatic = true},
	["tfa_bs_pkm"] = {model = "models/machine/w_pkm.mdl", offsetpos = Vector(-7,-1,2), offsetang = Angle(180,270,0), twohand = true, automatic = true},
	["tfa_bs_rpk"] = {model = "models/machine/w_rpk.mdl", offsetpos = Vector(-2.5,5,2), offsetang = Angle(180,180,0), twohand = true, automatic = true},

	    -- [[ SUBMACHINE GUNS ]]

	["tfa_bs_ump"] = {model = "models/submachine/w_ump45.mdl", offsetpos = Vector(-2,5,2), offsetang = Angle(180,180,0), twohand = true, automatic = true},
	["tfa_bs_uzi"] = {model = "models/submachine/w_uzi.mdl", offsetpos = Vector(-2,5,2), offsetang = Angle(180,180,0), twohand = false, automatic = true},
	["tfa_bs_vector"] = {model = "models/submachine/w_t2_vector.mdl", offsetpos = Vector(-2,5,2), offsetang = Angle(180,180,0), twohand = true, automatic = true},
	["tfa_bs_mp5a5"] = {model = "models/submachine/w_inss2_mp5a5.mdl", offsetpos = Vector(-3,7,2), offsetang = Angle(180,180,0), twohand = true, automatic = true},
	["tfa_bs_mp7"] = {model = "models/submachine/w_mp7.mdl", offsetpos = Vector(-2,5,2), offsetang = Angle(180,180,0), twohand = true, automatic = true},
	["tfa_bs_mac11"] = {model = "models/submachine/w_mac11.mdl", offsetpos = Vector(2,-2,1), offsetang = Angle(180,0,0), twohand = false, automatic = true},

	    -- [[ OTHERS ]]

	["tfa_bs_annabelle"] = {model = "models/hl/w_annabelle.mdl", offsetpos = Vector(1,-16,1), offsetang = Angle(180,0,0), twohand = true, automatic = false},
	["tfa_bs_ar2"] = {model = "models/hl/w_iiopnirifle.mdl", offsetpos = Vector(3,-16,1), offsetang = Angle(180,0,0), twohand = true, automatic = true},

        -- [[ END ]]
}

-------------------------------------------------------------------------

game.AddDecal("mur_ducttape", "decals/mur_ducttape")