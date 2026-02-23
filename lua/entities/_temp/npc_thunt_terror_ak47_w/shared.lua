ENT.Base 			= "npc_thunt_base"
ENT.Type 			= "ai"
ENT.PrintName 		= "Terrorist"
ENT.Author 			= "DrVrej"
ENT.Contact 		= "http://steamcommunity.com/groups/vrejgaming"
ENT.Purpose 		= "Spawn it and fight with it!"
ENT.Instructions 	= "Click on the spawnicon to spawn it."
ENT.Category		= "Nazi Party"

if (CLIENT) then
local Name = "SW IMP Human Base"
local LangName = "npc_cods_human_base"
language.Add(LangName, Name)
killicon.Add(LangName,"HUD/killicons/default",Color(255,80,0,255))
language.Add("#"..LangName, Name)
killicon.Add("#"..LangName,"HUD/killicons/default",Color(255,80,0,255))
end