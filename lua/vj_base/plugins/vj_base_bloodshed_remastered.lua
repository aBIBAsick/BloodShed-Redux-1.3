/*--------------------------------------------------
	*** Copyright (c) 2012-2025 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
VJ.AddPlugin("Bloodshed SNPCs", "NPC")

local spawnCategory = "VJ Base - Bloodshed" -- Category, you can also set a category individually by replacing the spawnCategory with a string value
local spawnCategoryZombies = "VJ Base - Bloodshed: Dark Aether" -- Category, you can also set a category individually by replacing the spawnCategory with a string value

VJ.AddNPC_HUMAN("Police Officer", "npc_vj_bloodshed_police", {"weapon_vj_bloodshed_glock", "weapon_vj_bloodshed_r870"}, spawnCategory) -- Adds a NPC to the spawnmenu but with a list of default weapons it spawns with
VJ.AddNPC_HUMAN("SWAT", "npc_vj_bloodshed_swat", {"weapon_vj_bloodshed_m4a1", "weapon_vj_bloodshed_r870"}, spawnCategory) -- Adds a NPC to the spawnmenu but with a list of default weapons it spawns with
VJ.AddNPC_HUMAN("Suspect", "npc_vj_bloodshed_suspect", {"weapon_vj_bloodshed_sus_secondary", "weapon_vj_bloodshed_sus_primary"}, spawnCategory) -- Adds a NPC to the spawnmenu but with a list of default weapons it spawns with
VJ.AddNPC("Zombie", "npc_vj_bloodshed_zombie", spawnCategory) -- Adds a NPC to the spawnmenu but with a list of default weapons it spawns with
VJ.AddNPC("PTICHKI", "npc_vj_bloodshed_ptichki", spawnCategory)

VJ.AddNPC("Mangler", "npc_vj_bloodshed_nz_mangler", spawnCategoryZombies) 
VJ.AddNPC("Vermin", "npc_vj_bloodshed_nz_vermin", spawnCategoryZombies) 
VJ.AddNPC("Amalgam", "npc_vj_bloodshed_nz_amalgam", spawnCategoryZombies) 
VJ.AddNPC("Shock Mimic", "npc_vj_bloodshed_nz_mimic", spawnCategoryZombies) 

VJ.AddNPCWeapon("Bloodshed - Glock 17", "weapon_vj_bloodshed_glock", spawnCategory) -- Adds a weapon to the NPC weapon list
VJ.AddNPCWeapon("Bloodshed - Remington 870", "weapon_vj_bloodshed_r870", spawnCategory) -- Adds a weapon to the NPC weapon list
VJ.AddNPCWeapon("Bloodshed - M4A1", "weapon_vj_bloodshed_m4a1", spawnCategory) -- Adds a weapon to the NPC weapon list
VJ.AddNPCWeapon("Bloodshed - Suspect Secondary", "weapon_vj_bloodshed_sus_secondary", spawnCategory) -- Adds a weapon to the NPC weapon list
VJ.AddNPCWeapon("Bloodshed - Suspect Primary", "weapon_vj_bloodshed_sus_primary", spawnCategory) -- Adds a weapon to the NPC weapon list
VJ.AddNPCWeapon("Bloodshed - Suspect Melee", "weapon_vj_bloodshed_sus_melee", spawnCategory) -- Adds a weapon to the NPC weapon list

---------------------------------------------------------

local tab1 = {}
local tab2 = {}

for i=1,104 do
	tab1[#tab1+1] = ")murdered/player/deathmale/bullet/death_bullet"..i..".ogg"
end
for i=1,6 do
	tab2[#tab2+1] = "npc/combine_soldier/gear"..i..".wav"
end

sound.Add({
	name = "BloodshedNPC_HumanDeath",
	level = 60,
	pitch = {90,110},
	sound = tab1,
})
sound.Add({
	name = "BloodshedNPC_HumanFootstep",
	level = 60,
	pitch = {90,110},
	sound = tab2,
	volume = 0.6,
})