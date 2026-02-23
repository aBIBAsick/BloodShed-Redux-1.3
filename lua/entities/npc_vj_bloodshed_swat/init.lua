AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = {
	"models/murdered/npc/swat/male_01.mdl", 
	"models/murdered/npc/swat/male_02.mdl", 
	"models/murdered/npc/swat/male_03.mdl", 
	"models/murdered/npc/swat/male_04.mdl", 
	"models/murdered/npc/swat/male_05.mdl", 
	"models/murdered/npc/swat/male_06.mdl", 
	"models/murdered/npc/swat/male_07.mdl", 
	"models/murdered/npc/swat/male_08.mdl", 
	"models/murdered/npc/swat/male_09.mdl"
}
ENT.StartHealth = 125

ENT.AnimTbl_MeleeAttack = {"melee_gunhit"}
ENT.AnimTbl_DoorSeq = "melee_gunhit"
ENT.DoorKickSetBack = false
ENT.HaveTaser = false