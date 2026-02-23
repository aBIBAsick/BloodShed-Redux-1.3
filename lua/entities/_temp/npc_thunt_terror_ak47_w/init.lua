AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/player/arctic.mdl","models/player/2055_teror.mdl","models/player/north_connexion.mdl","models/player/terror_grunt.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want 
ENT.StartHealth = 80 --GetConVarNumber("vj_mili_pzgrenadier_h")
ENT.HullType = HULL_HUMAN
ENT.AnimationPlaybackRate = 1.0
ENT.UsePlayerModelMovement = false

---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_TERRORIST"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Red" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.BloodDecalUseGMod = true

ENT.CallForHelp = true -- Does the SNPC call for help?
ENT.CallForHelpDistance = 400 -- -- How far away the SNPC's call for help goes | Counted in World Units
ENT.NextCallForHelpTime = math.random(25,45) -- Time until it calls for help again
ENT.HasCallForHelpAnimation = true -- if true, it will play the call for help animation
ENT.AnimTbl_CallForHelp = {"vjges_gesture_signal_group"} -- Call For Help Animations
ENT.CallForHelpAnimationDelay = 1 -- It will wait certain amount of time before playing the animation
ENT.CallForHelpStopAnimations = true
ENT.SightDistance = 2000
ENT.AllowMovementJumping = false

ENT.Still = false
ENT.CanGasMask = true
ENT.CanLean = true
ENT.NextLeanTime = 0
ENT.NextSuppressionTime = 0

	-- ====== Flinching Variables ====== --
ENT.CanFlinch = 1 -- 0 = Don't flinch | 1 = Flinch at any damage | 2 = Flinch only from certain damages
ENT.FlinchChance = 1 -- Chance of it flinching from 1 to x | 1 will make it always flinch
	-- To let the base automatically detect the animation duration, set this to false:
ENT.NextMoveAfterFlinchTime = 0.1 -- How much time until it can move, attack, etc.
ENT.NextFlinchTime = 0.2 -- How much time until it can flinch again?
ENT.AnimTbl_Flinch = {"vjges_Flinch Gut", "vjges_Flinch Gut", "vjges_Flinch Gut", "vjges_Flinch Gut", "vjges_Flinch Chest"} -- If it uses normal based animation, use this
ENT.FlinchAnimationDecreaseLengthAmount = 0 -- This will decrease the time it can move, attack, etc. | Use it to fix animation pauses after it finished the flinch animation
ENT.HitGroupFlinching_DefaultWhenNotHit = true -- If it uses hitgroup flinching, should it do the regular flinch if it doesn't hit any of the specified hitgroups?
ENT.HitGroupFlinching_Values = {{HitGroup = {HITGROUP_HEAD}, Animation = {"vjges_Flinch Head"}}, {HitGroup = {HITGROUP_LEFTARM}, Animation = {"vjges_Flinch Left Arm"}}, {HitGroup = {HITGROUP_RIGHTARM}, Animation = {"vjges_Flinch Right Arm"}}, {HitGroup = {HITGROUP_RIGHTLEG}, Animation = {"vjges_Flinch Left Leg"}}, {HitGroup = {HITGROUP_LEFTLEG}, Animation = {"vjges_Flinch Left Leg"}}}

ENT.DeathCorpseCollisionType = COLLISION_GROUP_DEBRIS

ENT.HasItemDropsOnDeath = false -- Should it drop items on death?
ENT.DropWeaponOnDeath = false -- Should it drop its weapon on death?

ENT.MoveRandomlyWhenShooting = true
ENT.HasMeleeAttack = false -- Should the SNPC have a melee attack?

	-- ====== Distance Variables ====== --
ENT.Weapon_FiringDistanceFar = 1500 -- How far away it can shoot
ENT.Weapon_FiringDistanceClose = 50 -- How close until it stops shooting
ENT.HasWeaponBackAway = true -- Should the SNPC back away if the enemy is close?
ENT.WeaponBackAway_Distance = 100 -- When the enemy is this close, the SNPC will back away | 0 = Never back away
ENT.AlertedToIdleTime = VJ_Set(35, 60)
ENT.TimeUntilEnemyLost = 15
ENT.TurningSpeed = 30


ENT.AnimTbl_WeaponAttack = {attack_smg1} -- Animation played when the SNPC does weapon attack
ENT.CanCrouchOnWeaponAttack = true -- Can it crouch while shooting?
ENT.AnimTbl_WeaponAttackFiringGesture = {attack_smg1} -- Firing Gesture animations used when the SNPC is firing the weapon
ENT.DisableWeaponFiringGesture = false -- If set to true, it will disable the weapon firing gestures
ENT.CanCrouchOnWeaponAttackChance = 4

ENT.HasShootWhileMoving = true -- Can it shoot while moving?
ENT.AnimTbl_ShootWhileMovingRun = {ACT_RUN_AIM} -- Animations it will play when shooting while running | NOTE: Weapon may translate the animation that they see fit!
ENT.AnimTbl_ShootWhileMovingWalk = {ACT_RUN_AIM} -- Animations it will play when shooting while walking | NOTE: Weapon may translate the animation that they see fit!
ENT.AnimTbl_IdleStand = {ACT_HL2MP_IDLE_PASSIVE}
ENT.AnimTbl_Walk = {ACT_HL2MP_WALK_PASSIVE}
ENT.AnimTbl_Run = {ACT_RUN_AIM}

	-- ====== Pose Parameter Variables ====== --
ENT.HasPoseParameterLooking = true -- Does it look at its enemy using poseparameters?
ENT.PoseParameterLooking_CanReset = true -- Should it reset its pose parameters if there is no enemies?
ENT.PoseParameterLooking_InvertPitch = false -- Inverts the pitch poseparameters (X)
ENT.PoseParameterLooking_InvertYaw = false -- Inverts the yaw poseparameters (Y)
ENT.PoseParameterLooking_InvertRoll = false -- Inverts the roll poseparameters (Z)
ENT.PoseParameterLooking_TurningSpeed = 25 -- How fast does the parameter turn?
ENT.Weapon_AimTurnDiff = false
ENT.PoseParameterLooking_Names = {pitch={"aim_pitch", "head_pitch"}, yaw={"aim_yaw", "head_yaw"}, roll={}} -- Custom pose parameters to use, can put as many as needed

ENT.CanInvestigate = true -- Can it detect and investigate possible enemy disturbances? | EX: Sounds, movement and flashlight
ENT.InvestigateSoundDistance = 9 -- How far can the NPC hear sounds? | This number is multiplied by the calculated volume of the detectable sound
	-- ====== Reloading Variables ====== --
ENT.AllowWeaponReloading = true -- If false, the SNPC will no longer reload
ENT.DisableWeaponReloadAnimation = false -- if true, it will disable the animation code when reloading
ENT.AnimTbl_WeaponReload = {ACT_RELOAD} -- Animations that play when the SNPC reloads
ENT.WeaponReloadAnimationFaceEnemy = true -- Should it face the enemy while playing the weapon reload animation?
ENT.WeaponReloadAnimationDecreaseLengthAmount = 0 -- This will decrease the time until it starts moving or attack again. Use it to fix animation pauses until it chases the enemy.
ENT.WeaponReloadAnimationDelay = 0 -- It will wait certain amount of time before playing the animation

	-- ====== Move Randomly While Firing Variables ====== --
ENT.MoveRandomlyWhenShooting = false -- Should it move randomly when shooting?
ENT.NextMoveRandomlyWhenShootingTime1 = 2 -- How much time until it can move randomly when shooting? | First number in math.random
ENT.NextMoveRandomlyWhenShootingTime2 = 5 -- How much time until it can move randomly when shooting? | Second number in math.random

	-- ====== Run Away On Unknown Damage Variables ====== --
ENT.RunAwayOnUnknownDamage = true -- Should run away on damage
ENT.NextRunAwayOnDamageTime = 2 -- Until next run after being shot when not alerted

	-- ====== Call For Back On Damage Variables ====== --
ENT.CallForBackUpOnDamage = true -- Should the SNPC call for help when damaged? (Only happens if the SNPC hasn't seen a enemy)
ENT.CallForBackUpOnDamageDistance = 250 -- How far away the SNPC's call for help goes | Counted in World Units
ENT.CallForBackUpOnDamageLimit = 2 -- How many people should it call? | 0 = Unlimited
ENT.CallForBackUpOnDamageAnimation = {"vjges_gesture_signal_group"} -- Animation used if the SNPC does the CallForBackUpOnDamage function
	-- To let the base automatically detect the animation duration, set this to false:
ENT.CallForBackUpOnDamageAnimationTime = true -- How much time until it can use activities
ENT.NextCallForBackUpOnDamageTime = VJ_Set(9, 11) -- Next time it use the CallForBackUpOnDamage function
ENT.DisableCallForBackUpOnDamageAnimation = true -- Disables the animation when the CallForBackUpOnDamage function is called

	-- ====== Wait For Enemy To Come Out Variables ====== --
ENT.WaitForEnemyToComeOut = true -- Should it wait for the enemy to come out from hiding?
ENT.WaitForEnemyToComeOutTime = VJ_Set(3, 20) -- How much time should it wait until it starts chasing the enemy?
ENT.WaitForEnemyToComeOutDistance = 200 -- If it's this close to the enemy, it won't do it
ENT.HasLostWeaponSightAnimation = false -- Set to true if you would like the SNPC to play a different animation when it has lost sight of the enemy and can't fire at it

ENT.FootStepTimeRun = 0.2 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 0.5 -- Next foot step sound when it is walking
ENT.WeaponSpread = 2

ENT.LastSeenEnemyTimeUntilReset = 20
ENT.HasDeathAnimation = true 
ENT.AnimTbl_Death = {"death2"}
ENT.DeathAnimationTime = 0.9
ENT.DeathAnimationChance = 8
ENT.DeathAnimationDecreaseLengthAmount = 0.1

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Grenade Attack Variables ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ENT.HasGrenadeAttack = false -- Should the SNPC have a grenade attack?
ENT.GrenadeAttackEntity = "arccw_thr_go_flash" -- The entity that the SNPC throws | Half Life 2 Grenade: "npc_grenade_frag"
ENT.GrenadeAttackModel = {"models/weapons/w_eq_flashbang_thrown.mdl"} -- Picks a random model from this table to override the model of the grenade
ENT.GrenadeAttackAttachment = "anim_attachment_LH" -- The attachment that the grenade will spawn at | false = Custom position
	-- ====== Animation Variables ====== --
ENT.AnimTbl_GrenadeAttack = {"vjges_Attack_Grenade"} -- Grenade Attack Animations
ENT.GrenadeAttackAnimationDelay = 0 -- It will wait certain amount of time before playing the animation
ENT.GrenadeAttackAnimationFaceEnemy = true -- Should it face the enemy while playing the grenade attack animation?
	-- ====== Distance & Chance Variables ====== --
ENT.NextThrowGrenadeTime = VJ_Set(5, 10) -- Time until it can throw a grenade again
ENT.ThrowGrenadeChance = 1 -- Chance that it will throw the grenade | Set to 1 to throw all the time
ENT.GrenadeAttackThrowDistance = 1500 -- How far it can throw grenades
ENT.GrenadeAttackThrowDistanceClose = 400 -- How close until it stops throwing grenades
	-- ====== Timer Variables ====== --
ENT.TimeUntilGrenadeIsReleased = 0.72 -- Time until the grenade is released
ENT.GrenadeAttackAnimationStopAttacks = true -- Should it stop attacks for a certain amount of time?
	-- To let the base automatically detect the attack duration, set this to false:
ENT.GrenadeAttackAnimationStopAttacksTime = false -- How long should it stop attacks?
ENT.GrenadeAttackFussTime = 3 -- Time until the grenade explodes

	-- ====== Move Or Hide On Damage Variables ====== --
ENT.MoveOrHideOnDamageByEnemy = true -- Should the SNPC move or hide when being damaged by an enemy?
ENT.MoveOrHideOnDamageByEnemy_OnlyMove = false -- Should it only move and not hide?
ENT.MoveOrHideOnDamageByEnemy_HideTime = VJ_Set(2, 6) -- How long should it hide?
ENT.NextMoveOrHideOnDamageByEnemy1 = 2 -- How much time until it moves or hides on damage by enemy? | The first # in math.random
ENT.NextMoveOrHideOnDamageByEnemy2 = 5.5 -- How much time until it moves or hides on damage by enemy? | The second # in math.random
ENT.PlayerFriendly = false
	-- ====== Constantly Face Enemy Variables ====== --
ENT.ConstantlyFaceEnemy = true -- Should it face the enemy constantly?
ENT.ConstantlyFaceEnemy_IfVisible = true -- Should it only face the enemy if it's visible?
ENT.ConstantlyFaceEnemy_IfAttacking = true -- Should it face the enemy when attacking?
ENT.ConstantlyFaceEnemy_Postures = "Both" -- "Both" = Moving or standing | "Moving" = Only when moving | "Standing" = Only when standing
ENT.ConstantlyFaceEnemyDistance = 1000 -- How close does it have to be until it starts to face the enemy?


	-- ====== Ally Reaction On Death Variables ====== --
	-- Default: Creature base uses BringFriends and Human base uses AlertFriends
	-- BringFriendsOnDeath takes priority over AlertFriendsOnDeath!
ENT.BringFriendsOnDeath = true -- Should the SNPC's friends come to its position before it dies?
ENT.BringFriendsOnDeathDistance = 500 -- How far away does the signal go? | Counted in World Units
ENT.BringFriendsOnDeathLimit = 3 -- How many people should it call? | 0 = Unlimited
ENT.AlertFriendsOnDeath = true -- Should the SNPCs allies get alerted when it dies? | Its allies will also need to have this variable set to true!
ENT.AlertFriendsOnDeathDistance = 500 -- How far away does the signal go? | Counted in World Units
ENT.AlertFriendsOnDeathLimit = 3 -- How many people should it alert?
ENT.AnimTbl_AlertFriendsOnDeath = {ACT_RANGE_ATTACK1} -- Animations it plays when an ally dies that also has AlertFriendsOnDeath set to true

	-- ====== Idle dialogue Sound Variables ====== --
	-- When an allied SNPC or a allied player is in range, the SNPC will play a different sound table. If the ally is a VJ SNPC and has dialogue answer sounds, it will respond to this SNPC
ENT.HasIdleDialogueSounds = true -- If set to false, it won't play the idle dialogue sounds
ENT.HasIdleDialogueAnswerSounds = true -- If set to false, it won't play the idle dialogue answer sounds
ENT.IdleDialogueDistance = 500 -- How close should the ally be for the SNPC to talk to the ally?
ENT.IdleDialogueCanTurn = false -- If set to false, it won't turn when a dialogue occurs
	-- ================ Sounds ================ --
--==Sound Variables==--
ENT.HasSounds = true
ENT.HasFootStepSound = true 
ENT.CombatIdleSoundPitch1 = 100
ENT.CombatIdleSoundPitch2 = 100
ENT.DeathSoundPitch1 = 100
ENT.DeathSoundPitch2 = 100
ENT.CallForHelpSoundPitch1 = 100
ENT.CallForHelpSoundPitch2 = 100
ENT.OnGrenadeSightSoundPitch1 = 100
ENT.OnGrenadeSightSoundPitch2 = 100
ENT.PainSoundPitch1 = 100
ENT.PainSoundPitch2 = 100
ENT.OnReceiveOrderSoundPitch1 = 100
ENT.OnReceiveOrderSoundPitch2 = 100
ENT.CombatIdleSoundLevel = 85
ENT.DeathSoundLevel = 85
ENT.CallForHelpSoundLevel = 85
ENT.OnGrenadeSightSoundLevel = 85
ENT.PainSoundLevel = 85
ENT.OnReceiveOrderSoundLevel = 85
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play

ENT.SoundTbl_Idle = {"vo/terror1/idle1.wav","vo/terror1/idle2.wav","vo/terror1/idle3.wav","vo/terror1/idle4.wav",
"vo/terror1/idle5.wav","vo/terror1/idle6.wav","vo/terror1/idle7.wav","vo/terror1/idle8.wav","vo/terror1/idle9.wav",
"vo/terror1/idle10.wav","vo/terror1/idle11.wav","vo/terror1/idle12.wav","vo/terror1/idle13.wav","vo/terror1/idle14.wav",
"vo/terror1/idle15.wav","vo/terror1/idle16.wav","vo/terror1/idle17.wav","vo/terror1/idle18.wav","vo/terror1/idle19.wav",
"vo/terror1/idle20.wav","vo/terror1/idle21.wav","vo/terror1/idle22.wav","vo/terror1/idle23.wav","vo/terror1/idle24.wav",
"vo/terror1/idle25.wav","vo/terror1/idle26.wav","vo/terror1/idle27.wav","vo/terror1/idle28.wav","vo/terror1/idle29.wav",
"vo/terror1/idle30.wav","vo/terror1/idle31.wav"}
ENT.SoundTbl_IdleDialogue = {"soldier/idlequestion/idlequestion1.wav","soldier/idlequestion/idlequestion10.wav","soldier/idlequestion/idlequestion11.wav",
"soldier/idlequestion/idlequestion12.wav","soldier/idlequestion/idlequestion14.wav","soldier/idlequestion/idlequestion15.wav","soldier/idlequestion/idlequestion17.wav",
"soldier/idlequestion/idlequestion18.wav","soldier/idlequestion/idlequestion2.wav","soldier/idlequestion/idlequestion28.wav","soldier/idlequestion/idlequestion3.wav"}
ENT.SoundTbl_IdleDialogueAnswer = {"soldier/affirmative/affirmative10.wav","soldier/affirmative/affirmative11.wav","soldier/affirmative/affirmative12.wav",
"soldier/affirmative/affirmative13.wav","soldier/affirmative/affirmative15.wav","soldier/affirmative/affirmative16.wav","soldier/affirmative/affirmative17.wav",
"soldier/affirmative/affirmative18.wav","soldier/affirmative/affirmative19.wav"}
ENT.SoundTbl_CombatIdle = {"soldier/moving/moving19.wav","soldier/moving/moving20.wav","soldier/moving/moving21.wav","soldier/moving/moving22.wav",
"soldier/moving/moving24.wav","soldier/moving/moving25.wav","soldier/moving/moving26.wav","soldier/moving/moving27.wav","soldier/moving/moving28.wav",
"soldier/moving/moving3.wav","soldier/moving/moving30.wav","soldier/moving/moving31.wav","soldier/moving/moving34.wav","soldier/moving/moving36.wav",
"soldier/moving/moving37.wav","soldier/moving/moving39.wav","soldier/moving/moving49.wav","soldier/moving/moving5.wav","soldier/moving/moving50.wav",
"soldier/moving/moving51.wav","soldier/moving/moving52.wav","soldier/moving/moving56.wav","soldier/moving/moving7.wav","soldier/pursuit/pursuit28.wav"}
ENT.SoundTbl_Investigate = {"soldier/soundheard/soundheard13.wav","soldier/soundheard/soundheard14.wav","soldier/soundheard/soundheard15.wav","soldier/soundheard/soundheard16.wav",
"soldier/soundheard/soundheard17.wav","soldier/soundheard/soundheard18.wav","soldier/soundheard/soundheard21.wav","soldier/soundheard/soundheard22.wav",
"soldier/soundheard/soundheard23.wav","soldier/soundheard/soundheard24.wav","soldier/soundheard/soundheard25.wav","soldier/soundheard/soundheard26.wav",
"soldier/spottedflashlight/spottedflashlight5.wav","soldier/spottedflashlight/spottedflashlight6.wav","soldier/spottedflashlight/spottedflashlight7.wav",
"soldier/spottedflashlight/spottedflashlight8.wav","soldier/spottedflashlight/spottedflashlight4.wav"}
ENT.SoundTbl_LostEnemy = {"soldier/lostshort/lostshort20.wav","soldier/lostshort/lostshort21.wav","soldier/lostshort/lostshort22.wav","soldier/lostshort/lostshort23.wav",
"soldier/lostshort/lostshort24.wav","soldier/lostshort/lostshort25.wav","soldier/lostshort/lostshort26.wav","soldier/lostshort/lostshort27.wav","soldier/lostshort/lostshort28.wav",
"soldier/lostshort/lostshort29.wav","soldier/lostshort/lostshort30.wav","soldier/lostshort/lostshort31.wav","soldier/lostshort/lostshort32.wav","soldier/lostshort/lostshort33.wav",
"soldier/lostshort/lostshort50.wav","soldier/lostshort/lostshort51.wav","soldier/lostlong/lostlong1.wav","soldier/lostlong/lostlong10.wav","soldier/lostlong/lostlong11.wav",
"soldier/lostlong/lostlong12.wav","soldier/lostlong/lostlong13.wav","soldier/lostlong/lostlong14.wav","soldier/lostlong/lostlong15.wav","soldier/lostlong/lostlong16.wav",
"soldier/lostlong/lostlong17.wav","soldier/lostlong/lostlong2.wav","soldier/lostlong/lostlong33.wav","soldier/lostlong/lostlong34.wav","soldier/lostlong/lostlong35.wav",
"soldier/lostlong/lostlong36.wav","soldier/lostlong/lostlong37.wav","soldier/lostlong/lostlong38.wav","soldier/lostlong/lostlong39.wav","soldier/lostlong/lostlong4.wav",
"soldier/lostlong/lostlong40.wav","soldier/lostlong/lostlong41.wav","soldier/lostlong/lostlong42.wav","soldier/lostlong/lostlong43.wav","soldier/lostlong/lostlong44.wav",
"soldier/lostlong/lostlong45.wav"}
ENT.SoundTbl_Alert = {"soldier/contact/contact1.wav","soldier/contact/contact11.wav","soldier/contact/contact12.wav","soldier/contact/contact13.wav","soldier/contact/contact14.wav",
"soldier/contact/contact15.wav","soldier/contact/contact16.wav","soldier/contact/contact17.wav","soldier/contact/contact18.wav","soldier/contact/contact19.wav","soldier/contact/contact2.wav",
"soldier/contact/contact20.wav","soldier/contact/contact24.wav","soldier/contact/contact26.wav","soldier/contact/contact27.wav","soldier/contact/contact28.wav","soldier/contact/contact3.wav",
"soldier/contact/contact30.wav","soldier/contact/contact32.wav","soldier/contact/contact5.wav","soldier/firstencounter/firstencounter1.wav","soldier/firstencounter/firstencounter10.wav",
"soldier/firstencounter/firstencounter11.wav","soldier/firstencounter/firstencounter12.wav","soldier/firstencounter/firstencounter13.wav","soldier/firstencounter/firstencounter14.wav",
"soldier/firstencounter/firstencounter2.wav","soldier/firstencounter/firstencounter3.wav","soldier/firstencounter/firstencounter4.wav","soldier/firstencounter/firstencounter5.wav",
"soldier/firstencounter/firstencounter6.wav","soldier/firstencounter/firstencounter7.wav","soldier/firstencounter/firstencounter8.wav","soldier/firstencounter/firstencounter9.wav"}
ENT.SoundTbl_CallForHelp = {"soldier/lostfound/lostfound51.wav","soldier/lastmanstanding/lastmanstanding1.wav","soldier/lastmanstanding/lastmanstanding11.wav","soldier/lastmanstanding/lastmanstanding14.wav",
"soldier/lastmanstanding/lastmanstanding15.wav","soldier/lastmanstanding/lastmanstanding16.wav","soldier/lastmanstanding/lastmanstanding17.wav","soldier/lastmanstanding/lastmanstanding18.wav",
"soldier/lastmanstanding/lastmanstanding2.wav","soldier/lastmanstanding/lastmanstanding26.wav","soldier/lastmanstanding/lastmanstanding6.wav","soldier/lastmanstanding/lastmanstanding7.wav",
"soldier/lastmanstanding/lastmanstanding8.wav","soldier/lastmanstanding/lastmanstanding9.wav","soldier/wounded/wounded11.wav","soldier/wounded/wounded13.wav","soldier/wounded/wounded19.wav"}
ENT.SoundTbl_Suppressing = {"soldier/engaging/engaging11.wav","soldier/engaging/engaging13.wav","soldier/engaging/engaging15.wav","soldier/engaging/engaging21.wav","soldier/engaging/engaging23.wav",
"soldier/engaging/engaging28.wav","soldier/engaging/engaging3.wav","soldier/engaging/engaging30.wav","soldier/engaging/engaging31.wav","soldier/engaging/engaging5.wav"}
ENT.SoundTbl_WeaponReload = {}
ENT.SoundTbl_GrenadeAttack = {"soldier/throwinggrenade/throwinggrenade1.wav","soldier/throwinggrenade/throwinggrenade10.wav","soldier/throwinggrenade/throwinggrenade11.wav",
"soldier/throwinggrenade/throwinggrenade12.wav","soldier/throwinggrenade/throwinggrenade13.wav","soldier/throwinggrenade/throwinggrenade14.wav","soldier/throwinggrenade/throwinggrenade15.wav",
"soldier/throwinggrenade/throwinggrenade16.wav","soldier/throwinggrenade/throwinggrenade2.wav","soldier/throwinggrenade/throwinggrenade3.wav","soldier/throwinggrenade/throwinggrenade4.wav",
"soldier/throwinggrenade/throwinggrenade5.wav","soldier/throwinggrenade/throwinggrenade6.wav","soldier/throwinggrenade/throwinggrenade7.wav","soldier/throwinggrenade/throwinggrenade8.wav",
"soldier/throwinggrenade/throwinggrenade9.wav"}
ENT.SoundTbl_OnGrenadeSight = {"soldier/grenade/grenade1.wav","soldier/grenade/grenade10.wav","soldier/grenade/grenade11.wav","soldier/grenade/grenade12.wav","soldier/grenade/grenade2.wav",
"soldier/grenade/grenade21.wav","soldier/grenade/grenade24.wav","soldier/grenade/grenade3.wav","soldier/grenade/grenade4.wav","soldier/grenade/grenade5.wav","soldier/grenade/grenade6.wav",
"soldier/grenade/grenade7.wav","soldier/grenade/grenade8.wav","soldier/grenade/grenade9.wav"}
ENT.SoundTbl_OnKilledEnemy = {"soldier/playerdead/playerdead1.wav","soldier/playerdead/playerdead10.wav","soldier/playerdead/playerdead11.wav","soldier/playerdead/playerdead12.wav",
"soldier/playerdead/playerdead13.wav","soldier/playerdead/playerdead14.wav","soldier/playerdead/playerdead15.wav","soldier/playerdead/playerdead16.wav","soldier/playerdead/playerdead17.wav",
"soldier/playerdead/playerdead18.wav","soldier/playerdead/playerdead2.wav","soldier/playerdead/playerdead3.wav","soldier/playerdead/playerdead4.wav","soldier/playerdead/playerdead5.wav",
"soldier/playerdead/playerdead6.wav","soldier/playerdead/playerdead7.wav","soldier/playerdead/playerdead8.wav","soldier/playerdead/playerdead9.wav","soldier/enemydown/enemydown1.wav",
"soldier/enemydown/enemydown10.wav","soldier/enemydown/enemydown11.wav","soldier/enemydown/enemydown13.wav","soldier/enemydown/enemydown14.wav","soldier/enemydown/enemydown15.wav",
"soldier/enemydown/enemydown16.wav","soldier/enemydown/enemydown17.wav"}
ENT.SoundTbl_AllyDeath = {"soldier/mandown/mandown26.wav","soldier/mandown/mandown27.wav","soldier/mandown/mandown28.wav","soldier/mandown/mandown29.wav","soldier/mandown/mandown30.wav",
"soldier/mandown/mandown31.wav","soldier/mandown/mandown32.wav","soldier/mandown/mandown33.wav","soldier/mandown/mandown34.wav","soldier/mandown/mandown35.wav","soldier/mandown/mandown36.wav",
"soldier/mandown/mandown37.wav","soldier/mandown/mandown38.wav","soldier/mandown/mandown39.wav","soldier/mandown/mandown40.wav","soldier/mandown/mandown41.wav","soldier/mandown/mandown42.wav",
"soldier/mandown/mandown43.wav","soldier/mandown/mandown44.wav","soldier/mandown/mandown45.wav","soldier/mandown/mandown46.wav","soldier/mandown/mandown47.wav","soldier/mandown/mandown48.wav",
"soldier/mandown/mandown49.wav","soldier/mandown/mandown50.wav","soldier/mandown/mandown51.wav"}
ENT.SoundTbl_Pain = {"soldier/pain/pain1.wav","soldier/pain/pain10.wav","soldier/pain/pain11.wav","soldier/pain/pain12.wav","soldier/pain/pain13.wav","soldier/pain/pain14.wav",
"soldier/pain/pain15.wav","soldier/pain/pain18.wav","soldier/pain/pain2.wav","soldier/pain/pain20.wav","soldier/pain/pain21.wav","soldier/pain/pain22.wav","soldier/pain/pain23.wav",
"soldier/pain/pain24.wav","soldier/pain/pain25.wav","soldier/pain/pain26.wav","soldier/pain/pain27.wav","soldier/pain/pain28.wav","soldier/pain/pain29.wav","soldier/pain/pain3.wav",
"soldier/pain/pain30.wav","soldier/pain/pain31.wav","soldier/pain/pain32.wav","soldier/pain/pain33.wav","soldier/pain/pain36.wav","soldier/pain/pain37.wav","soldier/pain/pain38.wav",
"soldier/pain/pain4.wav","soldier/pain/pain8.wav","soldier/pain/pain9.wav"}
ENT.SoundTbl_Death = {"soldier/death/death30.wav","soldier/death/death31.wav","soldier/death/death32.wav","soldier/death/death33.wav","soldier/death/death34.wav","soldier/death/death4.wav",
"soldier/death/death5.wav","soldier/death/death6.wav","soldier/death/death7.wav","soldier/death/death8.wav","soldier/death/death9.wav","soldier/death/death19.wav","soldier/death/death24.wav",
"soldier/death/death25.wav","soldier/death/death26.wav","soldier/death/death27.wav"}
ENT.SoundTbl_SoundTrack = {}
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.SoundTbl_BeforeMeleeAttack = {""}
ENT.WeaponUseEnemyEyePos = true
ENT.AnimTbl_TakingCover = {ACT_COVER_LOW} 
ENT.AnimTbl_MoveToCover = {ACT_RUN_CROUCH}
ENT.AnimTbl_WeaponReloadBehindCover = {ACT_RELOAD_LOW}
ENT.CanDetectGrenades = true
ENT.SightAngle = 90
ENT.AllowPrintingInChat = false

ENT.CanCrouchOnWeaponAttackChance = 8

ENT.WaitForEnemyToComeOutTime1 = 6 -- How much time should it wait until it starts chasing the enemy? | First number in math.random
ENT.WaitForEnemyToComeOutTime2 = 20 -- How much time should it wait until it starts chasing the enemy? | Second number in math.random

ENT.SoundTrackPlaybackRate = 1

ENT.HasBreathSound = false
ENT.NextSoundTime_Breath = VJ_Set(6, 16)
ENT.BreathSoundLevel = 80
ENT.IdleAlwaysWander = false
ENT.SoundTbl_Breath = {"vo/npc/male01/moan01.wav","vo/npc/male01/moan02.wav","vo/npc/male01/moan03.wav","vo/npc/male01/moan04.wav","vo/npc/male01/moan05.wav","vo/npc/male01/imhurt01.wav","vo/npc/male01/imhurt02.wav"}

ENT.WaitForEnemyToComeOutTime1 = 6 -- How much time should it wait until it starts chasing the enemy? | First number in math.random
ENT.WaitForEnemyToComeOutTime2 = 20 -- How much time should it wait until it starts chasing the enemy? | Second number in math.random

		-- Set the idle movement interval and entity list
		ENT.NextIdleMoveTime = 5 -- Time interval between idle movements (in seconds)
		ENT.IdleMoveEntities = {} -- List of entities to move towards
		
		ENT.JuggFollowT = 5
		ENT.Human_TurretPlacing = false
		ENT.Human_NextTurretCheckT = 1

		ENT.WanderDistance = 2000 -- The distance the NPC will wander when idle
		ENT.WanderRadius = 2000 -- The radius around the NPC's initial position to select a new wander position
		ENT.WanderStartTime = 0 -- The time when the wander started

		ENT.RetreatDistance = 1500 -- The distance the NPC will retreat
		ENT.RetreatDelay = 3 -- The delay in seconds before the NPC can retreat again
		ENT.NextRetreatTime = CurTime() 
		
		ENT.FlankDistance = 1000 -- The distance the NPC will retreat
		ENT.FlankDelay = math.random(10,30) -- The delay in seconds before the NPC can retreat again
		ENT.NextFlankTime = CurTime() 


-- PROFILES --
function ENT:CustomOnPreInitialize()
--	if self.CanGasMask == true then
	
--	end
	
local voice = math.random(1,9)
if voice == 1 then

end
if voice == 2 then
self.SoundTbl_Idle = {"vo/terror2/nz_facility_wunderfizz_1.wav","vo/terror2/nz_perk_deadshot_1.wav","vo/terror2/nz_perk_generic_2.wav","vo/terror2/nz_power_on_1.wav",
"vo/terror2/nz_powerup_generic_2.wav","vo/terror2/nz_powerup_generic_3.wav","vo/terror2/nz_revive_revived_1.wav","vo/terror2/nz_revive_revived_11.wav",
"vo/terror2/nz_revive_revived_2.wav","vo/terror2/nz_revive_revived_4.wav","vo/terror2/nz_revive_reviving_3.wav","vo/terror2/nz_revive_reviving_8.wav","vo/terror2/nz_revive_reviving_9.wav",
"vo/terror2/nz_round_prepare_1.wav","vo/terror2/nz_round_prepare_2.wav","vo/terror2/nz_round_prepare_4.wav","vo/terror2/nz_round_prepare_5.wav"}
self.SoundTbl_IdleDialogue = {"vo/terror2/nz_facility_randombox_2.wav","vo/terror2/nz_perk_generic_1.wav","vo/terror2/nz_revive_revived_8.wav","vo/terror2/nz_revive_reviving_6.wav",
"vo/terror2/nz_round_prepare_3.wav","vo/terror2/nz_round_special_1.wav"}
self.SoundTbl_IdleDialogueAnswer = {"vo/terror2/nz_round_preparereply_10.wav","vo/terror2/nz_round_preparereply_2.wav","vo/terror2/nz_round_preparereply_3.wav","vo/terror2/nz_round_preparereply_4.wav",
"vo/terror2/nz_round_preparereply_5.wav","vo/terror2/nz_round_preparereply_6.wav","vo/terror2/nz_round_preparereply_7.wav","vo/terror2/nz_round_preparereply_8.wav",
"vo/terror2/nz_round_preparereply_9.wav"}
self.SoundTbl_CombatIdle = {"vo/terror2/nz_powerup_generic_1.wav","vo/terror2/nz_revive_downed_6.wav","vo/terror2/nz_revive_reviving_1.wav","vo/terror2/nz_revive_reviving_10.wav",
"vo/terror2/nz_revive_reviving_11.wav","vo/terror2/nz_revive_reviving_2.wav","vo/terror2/nz_revive_reviving_4.wav","vo/terror2/nz_revive_reviving_5.wav","vo/terror2/nz_round_preparereply_1.wav"}
self.SoundTbl_Investigate = {"vo/terror2/nz_round_special_1.wav","vo/terror2/nz_revive_reviving_1.wav","vo/terror2/nz_facility_randombox_3.wav","vo/terror2/nz_facility_packapunch_2.wav"}
self.SoundTbl_LostEnemy = {""}
self.SoundTbl_Alert = {"vo/terror2/nz_revive_revived_1.wav","vo/terror2/nz_round_special_3.wav"}
self.SoundTbl_CallForHelp = {"vo/terror2/nz_revive_downed_1.wav","vo/terror2/nz_revive_downed_2.wav","vo/terror2/nz_revive_downed_3.wav","vo/terror2/nz_revive_downed_4.wav",
"vo/terror2/nz_revive_downed_5.wav","vo/terror2/nz_revive_downed_7.wav","vo/terror2/nz_revive_downed_8.wav"}
self.SoundTbl_Suppressing = {"vo/terror2/nz_facility_packapunch_3.wav","vo/terror2/nz_facility_randombox_1.wav","vo/terror2/bash_3.wav","vo/terror2/bash_6.wav"}
self.SoundTbl_WeaponReload = {"vo/terror2/reload_1.wav","vo/terror2/reload_10.wav","vo/terror2/reload_11.wav","vo/terror2/reload_2.wav","vo/terror2/reload_3.wav",
"vo/terror2/reload_4.wav","vo/terror2/reload_5.wav","vo/terror2/reload_6.wav","vo/terror2/reload_7.wav","vo/terror2/reload_8.wav","vo/terror2/reload_9.wav"}
self.SoundTbl_GrenadeAttack = {""}
self.SoundTbl_OnGrenadeSight = {""}
self.SoundTbl_OnKilledEnemy = {"vo/terror2/nz_revive_revived_7.wav"}
self.SoundTbl_AllyDeath = {"vo/terror2/nz_revive_dead_2.wav","vo/terror2/nz_revive_dead_3.wav","vo/terror2/nz_revive_dead_4.wav","vo/terror2/nz_revive_dead_6.wav",
"vo/terror2/nz_revive_dead_7.wav","vo/terror2/nz_revive_dead_8.wav","vo/terror2/nz_revive_reviving_7.wav","vo/terror2/nz_round_special_2.wav"}
self.SoundTbl_Pain = {"vo/terror2/hurt_1.wav","vo/terror2/hurt_2.wav","vo/terror2/hurt_3.wav","vo/terror2/hurt_4.wav","vo/terror2/hurt_5.wav","vo/terror2/hurt_6.wav","vo/terror2/hurt_7.wav","vo/terror2/hurt_8.wav","vo/terror2/hurt_9.wav"}
self.SoundTbl_Death = {"vo/terror2/death_2.wav","vo/terror2/death_3.wav","vo/terror2/death_4.wav","vo/terror2/death_5.wav"}
self.SoundTbl_Breath = {"vo/terror2/crithealth_1.wav","vo/terror2/crithealth_2.wav","vo/terror2/crithealth_3.wav","vo/terror2/crithealth_4.wav","vo/terror2/crithealth_5.wav","vo/terror2/crithit_1.wav"}
end
if voice == 3 then
self.SoundTbl_Idle = {"vo/terror3/coachgoingtodie08.wav","vo/terror3/coachsorry02.wav","vo/terror3/coachsorry06.wav","vo/terror3/coachspawn01.wav","vo/terror3/coachspawn02.wav",
"vo/terror3/coachspawn03.wav","vo/terror3/coachspawn04.wav"}
self.SoundTbl_IdleDialogue = {"vo/terror3/coachgoingtodie12.wav","vo/terror3/coachgoingtodie02.wav"}
self.SoundTbl_IdleDialogueAnswer = {"vo/terror3/coachellisinterrupt01.wav","vo/terror3/coachellisinterrupt03.wav","vo/terror3/coachellisinterrupt04.wav",
"vo/terror3/coachellisinterrupt05.wav","vo/terror3/coachno02.wav","vo/terror3/coachno03.wav","vo/terror3/coachno07.wav","vo/terror3/coachno10.wav","vo/terror3/coachno12.wav",
"vo/terror3/coachyes01.wav","vo/terror3/coachyes02.wav","vo/terror3/coachyes03.wav","vo/terror3/coachyes04.wav","vo/terror3/coachyes05.wav","vo/terror3/coachywelcome01.wav"}
self.SoundTbl_CombatIdle = {"vo/terror3/coachmoveon01.wav","vo/terror3/coachmoveon02.wav","vo/terror3/coachmoveon04.wav","vo/terror3/coachmoveon06.wav"}
self.SoundTbl_Investigate = {"vo/terror3/coachlook01.wav","vo/terror3/coachlook04.wav","vo/terror3/coachlook02.wav"}
self.SoundTbl_LostEnemy = {""}
self.SoundTbl_Alert = {"vo/terror3/coachenemyspotted01.wav","vo/terror3/coachenemyspotted02.wav","vo/terror3/coachenemyspotted03.wav",
"vo/terror3/coachenemyspotted04.wav","vo/terror3/coachenemyspotted05.wav","vo/terror3/coachenemyspotted06.wav","vo/terror3/coachhelp05.wav"}
self.SoundTbl_CallForHelp = {"vo/terror3/coachhelp01.wav","vo/terror3/coachhelp02.wav","vo/terror3/coachhelp03.wav","vo/terror3/coachhelp04.wav","vo/terror3/coachhelp05.wav",
"vo/terror3/coachhelp06.wav"}
self.SoundTbl_Suppressing = {""}
self.SoundTbl_WeaponReload = {"vo/terror3/coachreloading01.wav","vo/terror3/coachreloading02.wav","vo/terror3/coachreloading03.wav","vo/terror3/coachreloading04.wav","vo/terror3/coachreloading05.wav",
"vo/terror3/coachreloading06.wav","vo/terror3/coachreloading07.wav"}
self.SoundTbl_GrenadeAttack = {""}
self.SoundTbl_OnGrenadeSight = {""}
self.SoundTbl_OnKilledEnemy = {"vo/terror3/coachkillconfirmation01.wav","vo/terror3/coachkillconfirmation03.wav","vo/terror3/coachkillconfirmation06.wav"}
self.SoundTbl_AllyDeath = {"vo/terror3/coachgoingtodie02.wav","vo/terror3/coachgoingtodie01.wav","vo/terror3/coachsorry01.wav","vo/terror3/coachsorry02.wav",
"vo/terror3/coachswears01.wav","vo/terror3/coachswears02.wav","vo/terror3/coachswears03.wav","vo/terror3/coachswears04.wav","vo/terror3/coachswears05.wav",
"vo/terror3/coachswears06.wav","vo/terror3/coachswears07.wav","vo/terror3/coachswears08.wav"}
self.SoundTbl_Pain = {"vo/terror3/coachhurt01.wav","vo/terror3/coachhurt02.wav","vo/terror3/coachhurt03.wav","vo/terror3/coachhurt04.wav","vo/terror3/coachhurt05.wav",
"vo/terror3/coachhurt06.wav","vo/terror3/coachhurtcritical01.wav"}
self.SoundTbl_Death = {"vo/terror3/coachhurtcritical02.wav","vo/terror3/coachhurtcritical03.wav","vo/terror3/coachhurtcritical04.wav","vo/terror3/coachhurtcritical05.wav",
"vo/terror3/coachhurtcritical06.wav","vo/terror3/coachhurtcritical07.wav"}
self.SoundTbl_Breath = {"vo/terror3/coachgoingtodie01.wav","vo/terror3/coachgoingtodie02.wav","vo/terror3/coachgoingtodie03.wav","vo/terror3/coachgoingtodie04.wav",
"vo/terror3/coachgoingtodie05.wav","vo/terror3/coachgoingtodie06.wav","vo/terror3/coachgoingtodie07.wav","vo/terror3/coachgoingtodie09.wav","vo/terror3/coachgoingtodie10.wav",
"vo/terror3/coachgoingtodie11.wav","vo/terror3/coachgoingtodie12.wav","vo/terror3/coachgoingtodie13.wav","vo/terror3/coachgoingtodie14.wav","vo/terror3/coachgoingtodie15.wav"}
end
if voice == 4 then
self.SoundTbl_Idle = {"vo/terror4/domchatter_dontmindifido_medium03.ogg","vo/terror4/domchatter_icoulddothatalldaylong_loud01.ogg",
"vo/terror4/domchatter_icoulddothatallnightlong_loud01.ogg","vo/terror4/domchatter_illtakethis_medium01.ogg","vo/terror4/domchatter_iminthezone_loud01.ogg",
"vo/terror4/domchatter_iminthezone_loud02.ogg","vo/terror4/domchatter_juicy_loud01.ogg"}
self.SoundTbl_IdleDialogue = {"vo/terror4/domchatter_supbitches_loud01.ogg"}
self.SoundTbl_IdleDialogueAnswer = {""}
self.SoundTbl_CombatIdle = {"vo/terror4/domchatter_attacking_loud01.ogg","vo/terror4/domchatter_atttackmytarget_loud01.ogg","vo/terror4/domchatter_bringit_loud01.ogg",
"vo/terror4/domchatter_bringit_loud02.ogg","vo/terror4/domchatter_diealready_loud01.ogg","vo/terror4/domchatter_diealready_loud02.ogg","vo/terror4/domchatter_eatshitanddie_loud01.ogg",
"vo/terror4/domchatter_eatshitanddie_loud02.ogg","vo/terror4/domchatter_howmuchcantheytake_loud01.ogg","vo/terror4/domchatter_howmuchcantheytake_loud02.ogg",
"vo/terror4/domchatter_justdiewillya_loud01.ogg","vo/terror4/domchatter_justdiewillya_loud02.ogg","vo/terror4/domchatter_letsdothis_medium01.ogg",
"vo/terror4/domchatter_letsdothis_medium02.ogg","vo/terror4/domchatter_letsdothis_medium03.ogg","vo/terror4/domchatter_letsgo_loud01.ogg",
"vo/terror4/domchatter_letsgo_loud02.ogg","vo/terror4/domchatter_letsgo_loud03.ogg"}
self.SoundTbl_Investigate = {"vo/terror4/domchatter_didyouseethat_medium01.ogg","vo/terror4/domchatter_didyouseethat_medium02.ogg",
"vo/terror4/domchatter_didyouseethat_soft01.ogg","vo/terror4/domchatter_isawsomething_medium01.ogg","vo/terror4/domchatter_isawsomething_soft01.ogg",
"vo/terror4/domchatter_isawsomething_soft02.ogg"}
self.SoundTbl_LostEnemy = {""}
self.SoundTbl_Alert = {"vo/terror4/domchatter_contact_loud01.oggq","vo/terror4/domchatter_contact_loud02.ogg","vo/terror4/domchatter_enemyreinforcements_loud01.ogg",
"vo/terror4/domchatter_enemyspotted_loud01.ogg","vo/terror4/domchatter_engaging_loud01.ogg","vo/terror4/domchatter_engaging_loud02.ogg",
"vo/terror4/domchatter_getdown_loud01.ogg","vo/terror4/domchatter_getdown_loud02.ogg","vo/terror4/domchatter_hostiles_loud01.ogg",
"vo/terror4/domchatter_hostiles_loud03.ogg"}
self.SoundTbl_CallForHelp = {""}
self.SoundTbl_Suppressing = {"vo/terror4/domchatter_aintsotough_loud01.ogg","vo/terror4/domchatter_aintsotough_loud03.ogg",
"vo/terror4/domchatter_aintsotoughnowareya_medium01.ogg","vo/terror4/domchatter_aintsotoughnowareya_medium03.ogg"}
self.SoundTbl_WeaponReload = {"vo/terror4/domchatter_imout_loud01.ogg","vo/terror4/domchatter_imout_loud02.ogg","vo/terror4/domchatter_imout_medium01.ogg",
"vo/terror4/domchatter_imoutofammo_loud01.ogg","vo/terror4/domchatter_imoutofammo_medium01.ogg","vo/terror4/domchatter_ineedammo_loud01.ogg"}
self.SoundTbl_GrenadeAttack = {""}
self.SoundTbl_OnGrenadeSight = {""}
self.SoundTbl_OnKilledEnemy = {"vo/terror4/domchatter_andstaydown_medium01.ogg","vo/terror4/domchatter_hellyeah_loud01.ogg"}
self.SoundTbl_AllyDeath = {"vo/terror4/domchatter_areyoukiddingme_loud01.ogg","vo/terror4/domchatter_areyoukiddingme_loud02.ogg","vo/terror4/domchatter_areyoukiddingme_loud03.ogg",
"vo/terror4/domchatter_couldbeworse_loud01.ogg","vo/terror4/domchatter_couldbeworse_loud02.ogg","vo/terror4/domchatter_dammit_loud01.ogg",
"vo/terror4/domchatter_damntheyretough_loud01.ogg","vo/terror4/domchatter_damntheyretough_loud02.ogg","vo/terror4/domchatter_shit_loud01.ogg"}
self.SoundTbl_Pain = {"vo/terror4/dompainmedium01.ogg","vo/terror4/dompainmedium02.ogg","vo/terror4/dompainmedium03.ogg","vo/terror4/dompainmedium04.ogg",
"vo/terror4/dompainmedium05.ogg","vo/terror4/dompainmedium06.ogg"}
self.SoundTbl_Death = {"vo/terror4/domdeath01.ogg","vo/terror4/domdeath02.ogg","vo/terror4/domdeath03.ogg","vo/terror4/domdeath04.ogg","vo/terror4/domdeath05.ogg",
"vo/terror4/dompainhuge01.ogg","vo/terror4/dompainhuge02.ogg","vo/terror4/dompainhuge03.ogg","vo/terror4/dompainhuge04.ogg"}
self.SoundTbl_Breath = {"vo/terror4/dombreathneardeath01.ogg","vo/terror4/dombreathneardeath02.ogg","vo/terror4/dombreathneardeath03.ogg"}
end
if voice == 5 then
self.SoundTbl_Idle = {"vo/terror5/marcuschatter_bloodgutsdayonthejob_soft01.ogg","vo/terror5/marcuschatter_dontmindifido_medium01.ogg","vo/terror5/marcuschatter_dontmindifido_medium02.ogg","vo/terror5/marcuschatter_goodtogo_medium01.ogg",
"vo/terror5/marcuschatter_hey_medium01.ogg","vo/terror5/marcuschatter_illtakethat_medium03.ogg"}
self.SoundTbl_IdleDialogueAnswer = {""}
self.SoundTbl_IdleDialogue = {""}
self.SoundTbl_CombatIdle = {"vo/terror5/marcuschatter_bringit_loud01.ogg","vo/terror5/marcuschatter_destroyit_loud02.ogg",
"vo/terror5/marcuschatter_diealready_loud01.ogg","vo/terror5/marcuschatter_enemyreinforcements_loud01.ogg","vo/terror5/marcuschatter_engage_loud01.ogg",
"vo/terror5/marcuschatter_eyesontarget_loud01.ogg","vo/terror5/marcuschatter_fuckyou_medium01.ogg","vo/terror5/marcuschatter_getdown_loud02.ogg",
"vo/terror5/marcuschatter_letsdothis_medium02.ogg"}
self.SoundTbl_Investigate = {""}
self.SoundTbl_LostEnemy = {""}
self.SoundTbl_Alert = {"vo/terror5/marcuschatter_attack_loud01.ogg","vo/terror5/marcuschatter_locknload_loud01.ogg","vo/terror5/marcuschatter_letsdothis_medium02.ogg",
"vo/terror5/marcuschatter_takecover_loud01.ogg","vo/terror5/marcuschatter_takecover_loud02.ogg"}
self.SoundTbl_CallForHelp = {"vo/terror5/marcuschatter_formup_loud01.ogg"}
self.SoundTbl_Suppressing = {""}
self.SoundTbl_GrenadeAttack = {""}
self.SoundTbl_OnGrenadeSight = {""}
self.SoundTbl_OnKilledEnemy = {"vo/terror5/marcuschatter_goodnight_loud01.ogg","vo/terror5/marcuschatter_gotem_medium01.ogg","vo/terror5/marcuschatter_gotone_medium01.ogg",
"vo/terror5/marcuschatter_nice_loud01.ogg","vo/terror5/marcuschatter_next_loud01.ogg"}
self.SoundTbl_AllyDeath = {"vo/terror5/marcuschatter_areyoukiddingme_loud02.ogg","vo/terror5/marcuschatter_careful_loud02.ogg","vo/terror5/marcuschatter_damntheyretough_loud01.ogg",
"vo/terror5/marcuschatter_frustrationgroan_medium03.ogg","vo/terror5/marcuschatter_frustrationgroan_medium04.ogg","vo/terror5/marcuschatter_frustrationgroan_soft03.ogg",
"vo/terror5/marcuschatter_great_medium01.ogg","vo/terror5/marcuschatter_howmuchcantheytake_loud01.ogg","vo/terror5/marcuschatter_justdiewillya_loud01.ogg",
"vo/terror5/marcuschatter_nowimpissed_loud01.ogg"}
self.SoundTbl_Pain = {"vo/terror5/marcuspainlarge01.ogg","vo/terror5/marcuspainlarge02.ogg","vo/terror5/marcuspainlarge03.ogg","vo/terror5/marcuspainlarge04.ogg","vo/terror5/marcuspainlarge05.ogg",
"vo/terror5/marcuspainlarge06.ogg","vo/terror5/marcuspainmedium01.ogg","vo/terror5/marcuspainmedium02.ogg","vo/terror5/marcuspainmedium03.ogg","vo/terror5/marcuspainmedium04.ogg","vo/terror5/marcuspainmedium05.ogg",
"vo/terror5/marcuspainsmall01.ogg","vo/terror5/marcuspainsmall02.ogg","vo/terror5/marcuspainsmall03.ogg"}
self.SoundTbl_Death = {"vo/terror5/marcuspainhuge01.ogg","vo/terror5/marcuspainhuge02.ogg","vo/terror5/marcuspainhuge03.ogg","vo/terror5/marcuspainhuge04.ogg"}
self.SoundTbl_Breath = {"vo/terror5/marcusbreathneardeath01.ogg","vo/terror5/marcusbreathneardeath02.ogg","vo/terror5/marcusbreathneardeath03.ogg",
"vo/terror5/marcusbreathneardeath04.ogg","vo/terror5/marcusbreathneardeath06.ogg","vo/terror5/marcusbreathneardeath07.ogg","vo/terror5/marcuschatter_comegetme_medium01.ogg",
"vo/terror5/marcuschatter_needahand_medium01.ogg"}
end
if voice == 6 then
self.SoundTbl_Idle = {"vo/terror6/guschatter_alittletimeout_medium01.ogg","vo/terror6/guschatter_andimspent_loud01.ogg","vo/terror6/guschatter_backinthegame_medium01.ogg","vo/terror6/guschatter_busstopsonyou_medium02.ogg",
"vo/terror6/guschatter_doitagain_loud01.ogg","vo/terror6/guschatter_doitagain_loud02.ogg","vo/terror6/guschatter_dontmindifido_soft01.ogg","vo/terror6/guschatter_dontmindifido_soft02.ogg"}
self.SoundTbl_IdleDialogueAnswer = {"vo/terror6/guschatter_allright_loud01.ogg","vo/terror6/guschatter_allright_medium01.ogg","vo/terror6/guschatter_bustmybuns_medium02.ogg",
"vo/terror6/guschatter_dontfusswiththebus_loud01.ogg","vo/terror6/guschatter_dontfusswiththebus_loud03.ogg","vo/terror6/guschatter_dontmakemeshoot_medium01.ogg"}
self.SoundTbl_CombatIdle = {"vo/terror6/guschatter_360degreeturn_medium01.ogg","vo/terror6/guschatter_aintenoughfreakstostopme_loud01.ogg","vo/terror6/guschatter_aintenoughfreakstostopme_loud02.ogg",
"vo/terror6/guschatter_attack_loud02.ogg","vo/terror6/guschatter_attack_loud03.ogg","vo/terror6/guschatter_attacking_medium01.ogg","vo/terror6/guschatter_bigfatkillmesign_loud01.ogg",
"vo/terror6/guschatter_bigfatkillmesign_loud02.ogg","vo/terror6/guschatter_blockingmyshot_medium01.ogg","vo/terror6/guschatter_blockingmyshot_medium03.ogg","vo/terror6/guschatter_bringit_medium01.ogg",
"vo/terror6/guschatter_bringit_medium02.ogg","vo/terror6/guschatter_diginbaby_medium01.ogg","vo/terror6/guschatter_dontneednocrosshairs_loud02.ogg","vo/terror6/guschatter_dontstandinfrontsteamroller_medium01.ogg",
"vo/terror6/guschatter_dontstandinfrontsteamroller_medium02.ogg","vo/terror6/guschatter_engaging_medium01.ogg","vo/terror6/guschatter_enoughforallyall_loud01.ogg","vo/terror6/guschatter_enoughforallyall_loud02.ogg",
"vo/terror6/guschatter_flankem_loud01.ogg","vo/terror6/guschatter_flankem_loud02.ogg","vo/terror6/guschatter_followme_loud01.ogg","vo/terror6/guschatter_followme_loud02.ogg","vo/terror6/guschatter_fulloffensiveteams_medium02.ogg",
"vo/terror6/guschatter_fulloffensiveteams_medium03.ogg"}
self.SoundTbl_Investigate = {"vo/terror6/guschatter_diginbaby_medium01.ogg","vo/terror6/guschatter_thisisbadrealbad_loud03.ogg","vo/terror6/guschatter_thisiswrong_soft01.ogg",
"vo/terror6/guschatter_thisiswrong_soft02.ogg","vo/terror6/guschatter_thisiswrong_soft03.ogg","vo/terror6/guschatter_thisplacejustaintright_soft01.ogg",
"vo/terror6/guschatter_thisplacejustaintright_soft02.ogg","vo/terror6/guschatter_thisplacejustaintright_soft03.ogg","vo/terror6/guschatter_whatwasthat_loud01.ogg","vo/terror6/guschatter_whatwasthat_medium02.ogg"}
self.SoundTbl_IdleDialogue = {"vo/terror6/guschatter_busissmoothride_medium01.ogg","vo/terror6/guschatter_busissmoothride_medium02.ogg","vo/terror6/guschatter_busstopsonyou_medium01.ogg",
"vo/terror6/guschatter_bustmybuns_medium01.ogg","vo/terror6/guschatter_thisisbadrealbad_loud01.ogg"}
self.SoundTbl_LostEnemy = {"vo/terror6/guschatter_theyrecomingaround_loud01.ogg","vo/terror6/guschatter_theyreflanking_loud01.ogg","vo/terror6/guschatter_thisisbadrealbad_loud01.ogg",
"vo/terror6/guschatter_thisisbadrealbad_loud01.ogg","vo/terror6/guschatter_thisisbadrealbad_loud02.ogg"}
self.SoundTbl_Alert = {"vo/terror6/guschatter_attack_loud01.ogg","vo/terror6/guschatter_attack_loud02.ogg","vo/terror6/guschatter_attack_loud03.ogg","vo/terror6/guschatter_attackmytarget_loud01.ogg",
"vo/terror6/guschatter_enemyspotted_loud01.ogg","vo/terror6/guschatter_enemyspotted_loud02.ogg","vo/terror6/guschatter_enemyspotted_medium01.ogg","vo/terror6/guschatter_enemyspotted_medium02.ogg",
"vo/terror6/guschatter_engage_loud01.ogg","vo/terror6/guschatter_engage_loud02.ogg","vo/terror6/guschatter_timetogetmessy_medium02.ogg"}
self.SoundTbl_CallForHelp = {""}
self.SoundTbl_Suppressing = {"vo/terror6/guschatter_aintsotoughnow_loud01.ogg","vo/terror6/guschatter_aintsotoughnow_loud02.ogg","vo/terror6/guschatter_aintsotoughnow_loud03.ogg","vo/terror6/guschatter_boom_loud03.ogg",
"vo/terror6/guschatter_boombaby_loud01.ogg","vo/terror6/guschatter_boombaby_loud02.ogg","vo/terror6/guschatter_diealready_loud01.ogg","vo/terror6/guschatter_dontneednocrosshairs_loud01.ogg",
"vo/terror6/guschatter_dontneednocrosshairs_loud03.ogg"}
self.SoundTbl_GrenadeAttack = {""}
self.SoundTbl_OnGrenadeSight = {""}
self.SoundTbl_OnKilledEnemy = {"vo/terror6/guschatter_aintsotoughnow_loud03.ogg","vo/terror6/guschatter_alldone_loud01.ogg","vo/terror6/guschatter_almosthadusthattime_soft02.ogg",
"vo/terror6/guschatter_anddead_loud01.ogg","vo/terror6/guschatter_andstaydown_medium02.ogg","vo/terror6/guschatter_eatdirt_loud05.ogg"}
self.SoundTbl_AllyDeath = {"vo/terror6/guschatter_awdamn_medium01.ogg","vo/terror6/guschatter_awdamn_medium02.ogg","vo/terror6/guschatter_awdamn_medium03.ogg","vo/terror6/guschatter_disappointed_medium01.ogg",
"vo/terror6/guschatter_disappointed_medium02.ogg","vo/terror6/guschatter_disappointed_medium03.ogg","vo/terror6/guschatter_eatlead_loud03.ogg","vo/terror6/guschatter_eatthat_loud01.ogg",
"vo/terror6/guschatter_eatthat_loud03.ogg","vo/terror6/guschatter_fraidthisonesgone_medium01.ogg","vo/terror6/guschatter_fraidthisonesgone_medium02.ogg","vo/terror6/guschatter_tiptoethroughthecorpses_soft01.ogg",
"vo/terror6/guschatter_tiptoethroughthecorpses_soft02.ogg","vo/terror6/guschatter_toocloseforcomfort_loud01.ogg","vo/terror6/guschatter_toocloseforcomfort_loud03.ogg",
"vo/terror6/guschatter_youneedglasses_loud01.ogg","vo/terror6/guschatter_yow_loud01.ogg","vo/terror6/guschatter_yowza_loud01.ogg"}
self.SoundTbl_Pain = {"vo/terror6/guspainlarge01.ogg","vo/terror6/guspainlarge02.ogg","vo/terror6/guspainlarge03.ogg","vo/terror6/guspainlarge04.ogg","vo/terror6/guspainlarge05.ogg",
"vo/terror6/guspainmedium01.ogg","vo/terror6/guspainmedium02.ogg","vo/terror6/guspainmedium03.ogg","vo/terror6/guspainmedium04.ogg","vo/terror6/guspainmedium05.ogg"}
self.SoundTbl_Death = {"vo/terror6/guspainhuge01.ogg","vo/terror6/guspainhuge02.ogg","vo/terror6/guspainhuge03.ogg","vo/terror6/guspainhuge04.ogg","vo/terror6/guspainhuge05.ogg"}
self.SoundTbl_Breath = {"vo/terror6/guschatter_almosthadmethattime_soft01.ogg"}
end
if voice == 7 then
self.SoundTbl_Idle = {"vo/terror7/vgeneric04.mp3","vo/terror7/vgeneric05.mp3","vo/terror7/vgeneric06.mp3","vo/terror7/vgeneric07.mp3","vo/terror7/vlookhere01.mp3","vo/terror7/vspawn03.mp3",
"vo/terror7/vspawn04.mp3","vo/terror7/vspawn05.mp3"}
self.SoundTbl_IdleDialogue = {"vo/terror7/vgeneric01.mp3","vo/terror7/vgeneric02.mp3","vo/terror7/vlookhere02.mp3","vo/terror7/vlookhere03.mp3","vo/terror7/vlookhere04.mp3"}
self.SoundTbl_IdleDialogueAnswer = {"vo/terror7/vgeneric03.mp3","vo/terror7/vgeneric08.mp3","vo/terror7/vkillconfirmation01.mp3","vo/terror7/vno03.mp3","vo/terror7/vno01.mp3",
"vo/terror7/vno04.mp3","vo/terror7/vno05.mp3","vo/terror7/vno08.mp3","vo/terror7/vno09.mp3","vo/terror7/vtaunt09.mp3","vo/terror7/vyes01.mp3","vo/terror7/vyes02.mp3","vo/terror7/vyes03.mp3",
"vo/terror7/vyes05.mp3","vo/terror7/vyes06.mp3"}
self.SoundTbl_CombatIdle = {"vo/terror7/vmoveon01.mp3","vo/terror7/vmoveon02.mp3","vo/terror7/vmoveon03.mp3","vo/terror7/vmoveon04.mp3","vo/terror7/vmoveon05.mp3","vo/terror7/vmoveon06.mp3",
"vo/terror7/vmoveon07.mp3","vo/terror7/vmoveon08.mp3","vo/terror7/vtaunt01.mp3"}
self.SoundTbl_Investigate = {"vo/terror7/vlook01.mp3","vo/terror7/vlook02.mp3","vo/terror7/vlook03.mp3","vo/terror7/vmoveon07.mp3"}
self.SoundTbl_LostEnemy = {"vo/terror7/vspawn06.mp3"}
self.SoundTbl_Alert = {"vo/terror7/venemyspotted1.mp3","vo/terror7/venemyspotted2.mp3","vo/terror7/venemyspotted3.mp3"}
self.SoundTbl_CallForHelp = {"vo/terror7/vhelp01.mp3","vo/terror7/vhelp02.mp3","vo/terror7/vhelp03.mp3","vo/terror7/vhelp04.mp3","vo/terror7/vhelp05.mp3","vo/terror7/vhelp06.mp3",
"vo/terror7/vhelp07.mp3","vo/terror7/vhelp08.mp3","vo/terror7/vhelp09.mp3"}
self.SoundTbl_Suppressing = {""}
self.SoundTbl_GrenadeAttack = {""}
self.SoundTbl_OnGrenadeSight = {""}
self.SoundTbl_OnKilledEnemy = {"vo/terror7/vkillconfirmation03.mp3","vo/terror7/vkillconfirmation04.mp3","vo/terror7/vkillconfirmation05.mp3","vo/terror7/vkillconfirmation06.mp3"}
self.SoundTbl_AllyDeath = {"vo/terror7/vspawn01.mp3","vo/terror7/vspawn02.mp3","vo/terror7/vswears01.mp3","vo/terror7/vswears02.mp3","vo/terror7/vswears03.mp3",
"vo/terror7/vswears04.mp3","vo/terror7/vswears05.mp3","vo/terror7/vswears06.mp3","vo/terror7/vswears07.mp3","vo/terror7/vswears08.mp3","vo/terror7/vswears09.mp3","vo/terror7/vswears10.mp3",
"vo/terror7/vswears11.mp3","vo/terror7/vswears12.mp3"}
self.SoundTbl_Pain = {"vo/terror7/vhurt01.mp3","vo/terror7/vhurt02.mp3","vo/terror7/vhurt03.mp3","vo/terror7/vhurt04.mp3","vo/terror7/vhurt05.mp3","vo/terror7/vhurt06.mp3"}
self.SoundTbl_Death = {"vo/terror7/vdeath01.mp3","vo/terror7/vdeath02.mp3","vo/terror7/vdeath03.mp3","vo/terror7/vdeath04.mp3","vo/terror7/vdeath05.mp3","vo/terror7/vhurtcritical01.mp3",
"vo/terror7/vhurtcritical02.mp3","vo/terror7/vhurtcritical03.mp3","vo/terror7/vhurtcritical04.mp3","vo/terror7/vhurtcritical05.mp3"}
self.SoundTbl_Breath = {"vo/terror7/vgoingtodie01.mp3","vo/terror7/vgoingtodie02.mp3","vo/terror7/vgoingtodie03.mp3","vo/terror7/vgoingtodie04.mp3","vo/terror7/vgoingtodie05.mp3",
"vo/terror7/vgoingtodie06.mp3","vo/terror7/vgoingtodie07.mp3","vo/terror7/vgoingtodie08.mp3","vo/terror7/vgoingtodie09.mp3","vo/terror7/vgoingtodie10.mp3","vo/terror7/vgoingtodie11.mp3"}
end
if voice == 8 then
self.SoundTbl_Idle = {"vo/terror8/noammo1.wav","vo/terror8/purchase1.wav","vo/terror8/purchase13.wav","vo/terror8/purchase4.wav","vo/terror8/purchase6.wav","vo/terror8/purchase8.wav",
"vo/terror8/quote1.wav","vo/terror8/quote3.wav","vo/terror8/quote4.wav","vo/terror8/quote5.wav","vo/terror8/quote7.wav","vo/terror8/quote8.wav"}
self.SoundTbl_IdleDialogue = {"vo/terror8/murdgen3.wav","vo/terror8/murdgen4.wav","vo/terror8/purchase10.wav","vo/terror8/purchase11.wav","vo/terror8/purchase13.wav","vo/terror8/purchase15.wav",
"vo/terror8/purchase16.wav","vo/terror8/quote10.wav","vo/terror8/quote2.wav","vo/terror8/quote6.wav"}
self.SoundTbl_IdleDialogueAnswer = {"vo/terror8/agree1.wav","vo/terror8/agree2.wav","vo/terror8/agree3.wav","vo/terror8/agree5.wav","vo/terror8/disagree1.wav","vo/terror8/disagree2.wav",
"vo/terror8/disagree3.wav","vo/terror8/disagree4.wav","vo/terror8/disagree5.wav","vo/terror8/disagree7.wav","vo/terror8/disagree8.wav","vo/terror8/insult1.wav","vo/terror8/insult11.wav",
"vo/terror8/insult12.wav","vo/terror8/insult13.wav","vo/terror8/insult3.wav","vo/terror8/insult4.wav","vo/terror8/insult5.wav","vo/terror8/insult8.wav","vo/terror8/insult9.wav","vo/terror8/threaten4.wav",
"vo/terror8/threaten8.wav","vo/terror8/threaten9.wav"}
self.SoundTbl_CombatIdle = {"vo/terror8/blindrage11.wav","vo/terror8/blindrage16.wav","vo/terror8/blindrage17.wav","vo/terror8/blindrage6.wav","vo/terror8/insult1.wav","vo/terror8/insult10.wav",
"vo/terror8/insult13.wav","vo/terror8/insult14.wav","vo/terror8/insult15.wav","vo/terror8/insult16.wav","vo/terror8/insult17.wav","vo/terror8/insult18.wav","vo/terror8/insult2.wav","vo/terror8/insult6.wav",
"vo/terror8/insult7.wav","vo/terror8/murdgen11.wav","vo/terror8/murdgen12.wav","vo/terror8/murdgen13.wav","vo/terror8/murdgen17.wav","vo/terror8/murdgen18.wav","vo/terror8/murdgen2.wav","vo/terror8/murdgen5.wav",
"vo/terror8/murdgen6.wav","vo/terror8/murdgen7.wav","vo/terror8/murdgen8.wav","vo/terror8/threaten1.wav","vo/terror8/threaten10.wav","vo/terror8/threaten2.wav","vo/terror8/threaten3.wav"}
self.SoundTbl_Investigate = {"vo/terror8/noammo2.wav","vo/terror8/threaten5.wav","vo/terror8/threaten7.wav"}
self.SoundTbl_LostEnemy = {"vo/terror8/blindrage11.wav","vo/terror8/blindrage12.wav"}
self.SoundTbl_Alert = {"vo/terror8/noammo2.wav","vo/terror8/noammo3.wav","vo/terror8/threaten5.wav","vo/terror8/threaten1.wav","vo/terror8/murdgen5.wav","vo/terror8/murdgen2.wav"}
self.SoundTbl_CallForHelp = {""}
self.SoundTbl_Suppressing = {"vo/terror8/blindrage1.wav","vo/terror8/blindrage10.wav","vo/terror8/blindrage12.wav","vo/terror8/blindrage13.wav","vo/terror8/blindrage14.wav","vo/terror8/blindrage15.wav",
"vo/terror8/blindrage16.wav","vo/terror8/blindrage2.wav","vo/terror8/blindrage3.wav","vo/terror8/blindrage4.wav","vo/terror8/blindrage7.wav","vo/terror8/blindrage8.wav","vo/terror8/blindrage9.wav"}
self.SoundTbl_GrenadeAttack = {""}
self.SoundTbl_OnGrenadeSight = {""}
self.SoundTbl_OnKilledEnemy = {"vo/terror8/murdgen1.wav","vo/terror8/murdgen10.wav","vo/terror8/murdgen11.wav","vo/terror8/murdgen14.wav","vo/terror8/murdgen15.wav","vo/terror8/murdgen16.wav"}
self.SoundTbl_AllyDeath = {"vo/terror8/blindrage5.wav","vo/terror8/blindrage4.wav","vo/terror8/murdgen12.wav","vo/terror8/murdgen13.wav","vo/terror8/murdgen6.wav","vo/terror8/murdgen8.wav",
"vo/terror8/threaten6.wav"}
self.SoundTbl_Pain = {"vo/terror8/crithit1.wav","vo/terror8/crithit2.wav","vo/terror8/death1.wav","vo/terror8/death2.wav","vo/terror8/death3.wav","vo/terror8/death4.wav","vo/terror8/death5.wav"}
self.SoundTbl_Death = {"vo/terror8/crithealth1.wav","vo/terror8/crithealth2.wav","vo/terror8/crithealth3.wav"}
self.SoundTbl_Breath = {"vo/terror8/pain7.wav","vo/terror8/pain3.wav","vo/terror8/pain2.wav","vo/terror8/pain1.wav","vo/terror8/noammo3.wav"}
self.SuppressingSoundChance = 1
end
if voice == 9 then
self.SoundTbl_Idle = {"vo/terror9/chat (1).mp3","vo/terror9/chat (4).mp3","vo/terror9/chat (5).mp3","vo/terror9/chat (6).mp3","vo/terror9/chat (8).mp3","vo/terror9/hi (1).mp3"}
self.SoundTbl_IdleDialogue = {"vo/terror9/chat (7).mp3","vo/terror9/chat (8).mp3","vo/terror9/hi (2).mp3","vo/terror9/playerdamage (1).mp3","vo/terror9/playerdamage (4).mp3",
"vo/terror9/playerdamage (5).mp3","vo/terror9/playerdamage (6).mp3"}
self.SoundTbl_IdleDialogueAnswer = {"vo/terror9/chat (2).mp3","vo/terror9/chat (3).mp3","vo/terror9/playerdamage (2).mp3"}
self.SoundTbl_CombatIdle = {"vo/terror9/alert (5).mp3","vo/terror9/alert (4).mp3","vo/terror9/alert (6).mp3","vo/terror9/alert (7).mp3","vo/terror9/becomehos (1).mp3",
"vo/terror9/becomehos (2).mp3","vo/terror9/becomehos (3).mp3","vo/terror9/becomehos (4).mp3","vo/terror9/becomehos (5).mp3","vo/terror9/combat (1).mp3","vo/terror9/combat (2).mp3",
"vo/terror9/combat (3).mp3","vo/terror9/combat (4).mp3","vo/terror9/combat (5).mp3","vo/terror9/combat (6).mp3","vo/terror9/combat (7).mp3","vo/terror9/combat (8).mp3","vo/terror9/combat (9).mp3",
"vo/terror9/follow (1).mp3","vo/terror9/follow (2).mp3","vo/terror9/follow (3).mp3","vo/terror9/follow (4).mp3","vo/terror9/follow (5).mp3","vo/terror9/kill (1).mp3"}
self.SoundTbl_Investigate = {"vo/terror9/invest (4).mp3","vo/terror9/invest (5).mp3","vo/terror9/invest (6).mp3"}
self.SoundTbl_LostEnemy = {"vo/terror9/invest (1).mp3","vo/terror9/invest (3).mp3","vo/terror9/invest (2).mp3","vo/terror9/losthim (1).mp3","vo/terror9/losthim (2).mp3","vo/terror9/losthim (3).mp3"}
self.SoundTbl_Alert = {"vo/terror9/alert (1).mp3","vo/terror9/alert (2).mp3","vo/terror9/alert (3).mp3","vo/terror9/alert (4).mp3","vo/terror9/alert (5).mp3","vo/terror9/pain (6).mp3"}
self.SoundTbl_CallForHelp = {"vo/terror9/pain (1).mp3","vo/terror9/pain (2).mp3","vo/terror9/pain (3).mp3","vo/terror9/pain (4).mp3","vo/terror9/pain (5).mp3"}
self.SoundTbl_Suppressing = {"vo/terror9/kill (1).mp3","vo/terror9/suppress (1).mp3","vo/terror9/suppress (2).mp3","vo/terror9/suppress (3).mp3","vo/terror9/suppress (4).mp3","vo/terror9/suppress (5).mp3",
"vo/terror9/suppress (6).mp3"}
self.SoundTbl_GrenadeAttack = {""}
self.SoundTbl_OnGrenadeSight = {""}
self.SoundTbl_OnKilledEnemy = {"vo/terror9/follow (5).mp3","vo/terror9/follow (6).mp3","vo/terror9/follow (7).mp3","vo/terror9/kill (2).mp3","vo/terror9/kill (3).mp3"}
self.SoundTbl_AllyDeath = {"vo/terror9/kill (1).mp3","vo/terror9/kill (4).mp3","vo/terror9/mandown (1).mp3","vo/terror9/mandown (2).mp3"}
self.SoundTbl_Pain = {""}
self.SoundTbl_Death = {""}
self.SoundTbl_Breath = {"vo/terror9/pain (5).mp3"}
end
if voice == 10 then
self.SoundTbl_Idle = {""}
self.SoundTbl_IdleDialogue = {""}
self.SoundTbl_IdleDialogueAnswer = {""}
self.SoundTbl_CombatIdle = {""}
self.SoundTbl_LostEnemy = {""}
self.SoundTbl_Alert = {""}
self.SoundTbl_CallForHelp = {""}
self.SoundTbl_Suppressing = {""}
self.SoundTbl_GrenadeAttack = {""}
self.SoundTbl_OnGrenadeSight = {""}
self.SoundTbl_OnKilledEnemy = {""}
self.SoundTbl_AllyDeath = {""}
self.SoundTbl_Pain = {""}
self.SoundTbl_Death = {""}
self.SoundTbl_Breath = {""}
end
if voice == 11 then
self.SoundTbl_Idle = {""}
self.SoundTbl_IdleDialogue = {""}
self.SoundTbl_IdleDialogueAnswer = {""}
self.SoundTbl_CombatIdle = {""}
self.SoundTbl_LostEnemy = {""}
self.SoundTbl_Alert = {""}
self.SoundTbl_CallForHelp = {""}
self.SoundTbl_Suppressing = {""}
self.SoundTbl_GrenadeAttack = {""}
self.SoundTbl_OnGrenadeSight = {""}
self.SoundTbl_OnKilledEnemy = {""}
self.SoundTbl_AllyDeath = {""}
self.SoundTbl_Pain = {""}
self.SoundTbl_Death = {""}
self.SoundTbl_Breath = {""}
end
if voice == 12 then
self.SoundTbl_Idle = {""}
self.SoundTbl_IdleDialogue = {""}
self.SoundTbl_IdleDialogueAnswer = {""}
self.SoundTbl_CombatIdle = {""}
self.SoundTbl_LostEnemy = {""}
self.SoundTbl_Alert = {""}
self.SoundTbl_CallForHelp = {""}
self.SoundTbl_Suppressing = {""}
self.SoundTbl_GrenadeAttack = {""}
self.SoundTbl_OnGrenadeSight = {""}
self.SoundTbl_OnKilledEnemy = {""}
self.SoundTbl_AllyDeath = {""}
self.SoundTbl_Pain = {""}
self.SoundTbl_Death = {""}
self.SoundTbl_Breath = {""}
end


local profile = math.random(1,10)
if profile == 1 then
self.Weapon_FiringDistanceFar = 2000
self.WeaponBackAway_Distance = 50
self.TurningSpeed = 35
self.WaitForEnemyToComeOutTime1 = 8
self.WaitForEnemyToComeOutTime2 = 25
self.WeaponSpread = 1.8
self.InvestigateSoundDistance = 10
self.TimeUntilEnemyLost = 20
print("pro")
end
if profile == 2 then
self.Weapon_FiringDistanceFar = 1000
self.WeaponBackAway_Distance = 300
self.TurningSpeed = 20
self.WaitForEnemyToComeOutTime1 = 2 -- How much time should it wait until it starts chasing the enemy? | First number in math.random
self.WaitForEnemyToComeOutTime2 = 16 -- How much time should it wait until it starts chasing the enemy? | Second number in math.random
self.WeaponSpread = 2.2
self.InvestigateSoundDistance = 7
self.InvestigateSoundChance = 1
self.TimeUntilEnemyLost = 10
self.IdleAlwaysWander = true
self.CanInvestigate = false
self.CallForBackUpOnDamage = false
self.CallForHelp = false
print("noob")
end
if profile == 3 then
self.Weapon_FiringDistanceFar = 1500
self.WeaponBackAway_Distance = 100
self.TurningSpeed = 25
self.WaitForEnemyToComeOutTime1 = 5
self.WaitForEnemyToComeOutTime2 = 10
self.WeaponSpread = 1.8
self.InvestigateSoundDistance = 9
self.InvestigateSoundChance = 3
self.TimeUntilEnemyLost = 10
self.DisableChasingEnemy = true
self.DisableWandering = true
self.CallForHelp = false
self.CallForBackUpOnDamage = false
self.WaitForEnemyToComeOut = false
self.AlertFriendsOnDeath = false
self.Still = true
self.IsGuard = true
print("standing normal")
end
if profile == 4 then
self.Weapon_FiringDistanceFar = 1500
self.WeaponBackAway_Distance = 300
self.TurningSpeed = 25
self.WaitForEnemyToComeOutTime1 = 5
self.WaitForEnemyToComeOutTime2 = 10
self.WeaponSpread = 1.8
self.InvestigateSoundDistance = 9
self.InvestigateSoundChance = 4
self.TimeUntilEnemyLost = 10
self.DisableChasingEnemy = true
self.DisableWandering = true
self.CallForHelp = false
self.CallForBackUpOnDamage = false
self.WaitForEnemyToComeOut = false
self.AlertFriendsOnDeath = false
self.IsGuard = true
self.Still = true
print("standing still")
end
if profile == 5 then
self.Weapon_FiringDistanceFar = 1500
self.WeaponBackAway_Distance = 300
self.TurningSpeed = 25
self.WaitForEnemyToComeOutTime1 = 5
self.WaitForEnemyToComeOutTime2 = 10
self.WeaponSpread = 1.8
self.InvestigateSoundDistance = 9
self.InvestigateSoundChance = 4
self.TimeUntilEnemyLost = 10
self.DisableChasingEnemy = true
self.DisableWandering = true
self.CallForHelp = false
self.CallForBackUpOnDamage = false
self.WaitForEnemyToComeOut = false
self.AlertFriendsOnDeath = false
self.IsGuard = true
self.Still = true
print("standing still")
end
if profile == 6 then
self.Weapon_FiringDistanceFar = 2000
self.WeaponBackAway_Distance = 100
self.TurningSpeed = 30
self.WaitForEnemyToComeOutTime1 = 10
self.WaitForEnemyToComeOutTime2 = 20
self.WeaponSpread = 1.6
self.InvestigateSoundDistance = 10
self.InvestigateSoundChance = 8
self.TimeUntilEnemyLost = 5
self.DisableChasingEnemy = true
self.DisableWandering = true
self.WaitForEnemyToComeOut = false
self.AlertFriendsOnDeath = false
self.IsGuard = true
print("standing smart")
end
if profile == 7 then
self.Weapon_FiringDistanceFar = 600
self.WeaponBackAway_Distance = 50
self.TurningSpeed = 25
self.WaitForEnemyToComeOutTime1 = 2
self.WaitForEnemyToComeOutTime2 = 10
self.WeaponSpread = 2.4
self.InvestigateSoundDistance = 9
self.TimeUntilEnemyLost = 10
self.IdleAlwaysWander = true
print("charging fella")
end
if profile >= 8 then
print("normal")
end
end


function ENT:CustomOnInitialize()
		if self.Still == true then
		self.AnimTbl_Walk = {ACT_IDLE}
		self.AnimTbl_Run = {ACT_IDLE}
		self.HasShootWhileMoving = false
		self.MoveRandomlyWhenShooting = false
		self.WeaponReload_FindCover = false

end
	self.JuggFollowT = CurTime() + 5
	self.NextFlankTime = CurTime() + math.random(5,10)
	--self:SetColor( Color( math.Rand(50,255), math.Rand(100,255), math.Rand(0,100), 255 ) )
	
	timer.Simple(0.01,function() if IsValid(self) && IsValid(self:GetActiveWeapon()) then
	if math.random(1,30) == 1 then
		self.spot = ents.Create( "env_projectedtexture" )
		self.spot:SetParent(self:GetActiveWeapon())
		self.spot:Fire("SetParentAttachmentMaintainOffset","muzzle")
		self.spot:SetPos(self:GetActiveWeapon():GetAttachment(self:GetActiveWeapon():LookupAttachment("muzzle")).Pos)
		self.spot:SetAngles(self:GetActiveWeapon():GetAttachment(self:GetActiveWeapon():LookupAttachment("muzzle")).Ang)
		self.spot:SetKeyValue( "enableshadows", 1 )
		self.spot:SetKeyValue( "shadowquality", 1 )
		self.spot:SetKeyValue( "nearz", 1 )
		self.spot:Input("SpotlightTexture",NULL,NULL,"effects/flashlight001")
		self.spot:Input("FOV",NULL,NULL,70)
		self.spot:SetKeyValue("farz", 700)
		self.spot:SetKeyValue("brightnessscale", 10.00)
		self.spot:SetKeyValue("lightcolor","255 255 230 255")
		self.spot:Spawn()
		local muz = ents.Create("env_sprite")
		muz:SetKeyValue("model","sprites/light_glow01.vmt")
		muz:SetKeyValue("scale","1")
		muz:SetKeyValue("GlowProxySize","0.1") -- Size of the glow to be rendered for visibility testing.
		muz:SetKeyValue("HDRColorScale","1.0")
		muz:SetKeyValue("renderfx","22")
		muz:SetKeyValue("rendermode","3") -- Set the render mode to "3" (Glow)
		muz:SetKeyValue("renderamt","255") -- Transparency
		muz:SetKeyValue("disablereceiveshadows","0") -- Disable receiving shadows
		muz:SetKeyValue("framerate","10.0") -- Rate at which the sprite should animate, if at all.
		muz:SetKeyValue("spawnflags","0")
		muz:SetParent(self:GetActiveWeapon())
		muz:Fire("SetParentAttachmentMaintainOffset","muzzle")
		muz:SetPos(self:GetActiveWeapon():GetAttachment(self:GetActiveWeapon():LookupAttachment("muzzle")).Pos)
		muz:Spawn()
		muz:Activate()
		timer.Simple(0.01,function() if IsValid(self) && IsValid(self:GetActiveWeapon()) then
		end end)
		self:DeleteOnRemove(self.spot)
	end end end)

--	timer.Simple(0.01,function() if IsValid(self) && self.CanGasMask == true then
--	if math.random(1,1) == 1 then
--	local deploypos = self:GetPos() + self:GetForward() * 2 + self:GetRight() * -0+self:GetUp()* 95 
--	local angles = self:GetAngles()
--	self.shield = ents.Create("thunt_gasmask")
--	self.shield:SetPos( deploypos )
--	self.shield:SetParent(self, 1)
--	self.shield:SetAngles(Angle(angles.x + 0, angles.y + -90, angles.z -90))
--	self.shield:SetCollisionGroup(COLLISION_GROUP_WEAPON)
--	self.shield:SetOwner( self )
--	self.shield:Spawn()
--	end
--	end end)
end

function ENT:CustomOnInvestigate(ent) 
self:VJ_TASK_FACE_X("TASK_FACE_TARGET")
timer.Simple(1, function()
	if IsValid(self) then
	self:VJ_TASK_GOTO_LASTPOS("TASK_RUN_PATH", function(x) x:EngTask("TASK_FACE_ENEMY", 0) x.CanShootWhenMoving = true x.ConstantlyFaceEnemy = true end)
	end
end)
if math.random(1,5) == 1 then
self.AnimTbl_Walk = {ACT_WALK}
self.AnimTbl_Run = {ACT_RUN}
self.HasShootWhileMoving = true
self.MoveRandomlyWhenShooting = true
self.WeaponReload_FindCover = true
end
self.SightDistance = 3000
end

function ENT:CustomOnAlert(ent) 
if math.random(1,2) == 1 then
if IsValid(self:GetEnemy()) && self:Visible(self:GetEnemy()) then
self:VJ_ACT_PLAYACTIVITY("idle_all_scared",true,0.5,true,0,{AnimationPlaybackRate=2}, false)
--self:VJ_ACT_PLAYACTIVITY("seq_preskewer",true,1,true,0,{AnimationPlaybackRate=0.1}, false)
end
end
if math.random(1,5) == 1 then
timer.Simple(0.5, function()
	if IsValid(self) then
		self:VJ_TASK_COVER_FROM_ENEMY("TASK_RUN_PATH", function(x) x.CanShootWhenMoving = true x.ConstantlyFaceEnemy = true end)
		self.AnimTbl_Walk = {ACT_RUN}
		self.AnimTbl_Run = {ACT_RUN}
	end
end)
end
self.Human_NextTurretCheckT = CurTime() + math.random(8, 12)

if math.random(1,10) == 1 then
self.IsGuard = false
self.AnimTbl_Walk = {ACT_WALK}
self.AnimTbl_Run = {ACT_RUN}
self.HasShootWhileMoving = true
self.MoveRandomlyWhenShooting = true
self.WeaponReload_FindCover = true
self.Still = false
end
self.SightDistance = 3000
self.SightAngle = 130
self.HasIdleSounds = false
end
	
function ENT:CustomOnTakeDamage_AfterDamage(dmginfo, hitgroup) 
if !IsValid(self:GetEnemy()) then
self:VJ_TASK_COVER_FROM_ORIGIN("TASK_RUN_PATH")
self.FindEnemy_UseSphere = true
self.AnimTbl_Walk = {ACT_RUN}
self.AnimTbl_Run = {ACT_RUN}
timer.Simple(1, function()
	if IsValid(self) then
	self.FindEnemy_UseSphere = false
	end
end)
end
self.IsGuard = false
self.Still = false
self.AnimTbl_Walk = {ACT_WALK}
self.AnimTbl_Run = {ACT_RUN}
self.HasShootWhileMoving = true
self.MoveRandomlyWhenShooting = true
self.WeaponReload_FindCover = true
self.SightDistance = 3000
self.SightAngle = 130
end

function ENT:CustomOnThink_AIEnabled() 

	if ((self.VJ_IsBeingControlled && self.VJ_TheController:KeyDown(IN_DUCK)) or !self.VJ_IsBeingControlled) && IsValid(self:GetEnemy()) && self.Human_NextTurretCheckT < CurTime() && self:Health() >= self:GetMaxHealth() * 0.4 && self.Still == false then
				self.Human_NextTurretCheckT = CurTime() + math.random(8, 32)
				self:VJ_TASK_COVER_FROM_ORIGIN("TASK_RUN_PATH", function(x) x.CanShootWhenMoving = true x.ConstantlyFaceEnemy = true end)
				--self:VJ_TASK_COVER_FROM_ENEMY("TASK_RUN_PATH", function(x) x.CanShootWhenMoving = true x.ConstantlyFaceEnemy = true end)
				self.AnimTbl_Walk = {ACT_WALK_CROUCH}
				self.AnimTbl_Run = {ACT_WALK_CROUCH}
				self.AnimTbl_ShootWhileMovingRun = {ACT_WALK_CROUCH_AIM}
				self.AnimTbl_ShootWhileMovingWalk = {ACT_WALK_CROUCH_AIM}
				self.AnimTbl_IdleStand = {ACT_COVER_LOW}
				timer.Simple(math.random(6, 12), function()
				if IsValid(self) then
				self.AnimTbl_Walk = {ACT_WALK}
				self.AnimTbl_Run = {ACT_RUN}
				self.AnimTbl_ShootWhileMovingRun = {ACT_WALK_AIM}
				self.AnimTbl_ShootWhileMovingWalk = {ACT_WALK_AIM}
				self.AnimTbl_IdleStand = {ACT_IDLE}
				
			end
		end)
	end

		if IsValid(self:GetEnemy()) && self:Health() <= self:GetMaxHealth() * 0.4 and CurTime() > self.NextRetreatTime then -- Retreat when health is below 50% and the retreat delay has passed
				self.AnimTbl_Walk = {ACT_WALK}
				self.AnimTbl_Run = {ACT_RUN}
				self.AnimTbl_ShootWhileMovingRun = {ACT_WALK_AIM}
				self.AnimTbl_ShootWhileMovingWalk = {ACT_WALK_AIM}
				self.AnimTbl_IdleStand = {ACT_IDLE}
				self.WeaponBackAway_Distance = 2000
				self.Weapon_FiringDistanceClose = 300
				self.WaitForEnemyToComeOut = false
				self.DisableChasingEnemy = true
				self.HasBreathSound = true
				self.NextRetreatTime = CurTime() + self.RetreatDelay -- Set the next retreat time
				self.JuggFollowT = 20
				local retreatPos = self:GetPos() - (self:GetForward() * self.RetreatDistance) -- Calculate the retreat position
				local navArea = navmesh.GetNearestNavArea(retreatPos) -- Get the nearest navigation area to the retreat position

					if IsValid(navArea) then
					local retreatNavPos = navArea:GetRandomPoint() -- Get a random point within the navigation area
						if retreatNavPos then
						print("MOVING OUT")
						self:SetLastPosition(retreatNavPos) -- Set the last position of the NPC to the retreat position
						self:VJ_TASK_GOTO_LASTPOS("TASK_RUN_PATH", function(x) x:EngTask("TASK_FACE_ENEMY", 0) x.CanShootWhenMoving = true x.ConstantlyFaceEnemy = true end) -- Instruct the NPC to run to the last position

						end
					end
			else
			if self:Health() >= self:GetMaxHealth() * 0.4 then
			self.WeaponBackAway_Distance = 100
			self.Weapon_FiringDistanceClose = 50
			self.WaitForEnemyToComeOut = true
			self.DisableChasingEnemy = false
			self.HasBreathSound = false
		end
	end
	if !IsValid(self:GetEnemy()) && !self.Alerted && self:Health() <= self:GetMaxHealth() * 0.4 and CurTime() > self.NextRetreatTime then
	self:TaskComplete()
	self:StopMoving()
	self:ClearSchedule()
	self:ClearGoal()
	self:VJ_ACT_PLAYACTIVITY("vjseq_cidle_all")
	self.NextRetreatTime = CurTime() + self.RetreatDelay
	timer.Simple(math.random(3, 8), function()
	if IsValid(self) then
	VJ_EmitSound(self, {"items/smallmedkit1.wav"}, 80, 100)
	self:VJ_ACT_PLAYACTIVITY(ACT_IDLE)
	self:SetHealth(80)
	
	end

end)
end

		if IsValid(self:GetEnemy()) and CurTime() > self.NextFlankTime then -- Retreat when health is below 50% and the retreat delay has passed
					
					self.JuggFollowT = 20
					local retreatPos = self:GetPos() - (self:GetForward() * self.FlankDistance) -- Calculate the retreat position
					local navArea = navmesh.GetNearestNavArea(retreatPos) -- Get the nearest navigation area to the retreat position

						if IsValid(navArea) then
						local retreatNavPos = navArea:GetRandomPoint() -- Get a random point within the navigation area
						if retreatNavPos then
						print("Flanking!!!")
						self:SetLastPosition(retreatNavPos) -- Set the last position of the NPC to the retreat position
						self:VJ_TASK_GOTO_LASTPOS("TASK_RUN_PATH", function(x) x:EngTask("TASK_FACE_ENEMY", 0) end) -- Instruct the NPC to run to the last position
						self.AnimTbl_Walk = {ACT_WALK}
						self.AnimTbl_Run = {ACT_RUN}
						self.AnimTbl_ShootWhileMovingRun = {ACT_WALK_AIM}
						self.AnimTbl_ShootWhileMovingWalk = {ACT_WALK_AIM}
						self.AnimTbl_IdleStand = {ACT_IDLE}


					end
				end
				self.NextFlankTime = CurTime() + self.FlankDelay -- Set the next retreat time
			end
			if self.NextLeanTime < CurTime() && self.CanLean == true then
			self:CustomLean()
			end
			if self.NextSuppressionTime > CurTime() && IsValid(self:GetEnemy()) && !self:Visible(self:GetEnemy()) && (self:GetPos():Distance(self:GetEnemy():GetPos())) > 300 then
			local tracedataAD = {}
			tracedataAD.start = self:GetPos() + Vector(0,0,40)
			tracedataAD.endpos = self:GetEnemy():GetPos() + Vector(0,0,40) + self:GetForward()*200
			tracedataAD.filter = {self:GetEnemy(),self}
			local trAD = util.TraceLine(tracedataAD)
			if !tracedataAD.Hit then
			self:CustomBlindFire()
			end
		end
	if self.NextSuppressionTime < CurTime() && IsValid(self:GetEnemy()) && self:Visible(self:GetEnemy()) then
		
	self.NextSuppressionTime = CurTime() + math.random(2,8)
	
	end
end

function ENT:CustomOnWaitForEnemyToComeOut() 
if math.random(1,4) == 1 then

		local retreatPos = self:GetPos() - (self:GetForward() * self.RetreatDistance) -- Calculate the retreat position
		local navArea = navmesh.GetNearestNavArea(retreatPos) -- Get the nearest navigation area to the retreat position

		if IsValid(navArea) then
			local retreatNavPos = navArea:GetRandomPoint() -- Get a random point within the navigation area
			if retreatNavPos then
			print("MOVING OUT")
				self:SetLastPosition(retreatNavPos) -- Set the last position of the NPC to the retreat position
				self:VJ_TASK_GOTO_LASTPOS("TASK_RUN_PATH") -- Instruct the NPC to run to the last position

				self.NextRetreatTime = CurTime() + self.RetreatDelay -- Set the next retreat time
			end
		end
	end
end

function ENT:CustomOnWeaponReload() 
	self:VJ_TASK_COVER_FROM_ENEMY("TASK_RUN_PATH", function(x) x.CanShootWhenMoving = false x.ConstantlyFaceEnemy = true end)
end

function ENT:CustomOnInitialKilled(dmginfo, hitgroup) 

	local weapon = self:GetActiveWeapon()
	if self:GetActiveWeapon():GetClass() == "vj_thunt_ak47" then
		local ent = ents.Create("arc9_thunt_ar15")
		local pos = self:GetPos() + Vector(0, 0, 30) 
		ent:SetPos(pos)
        ent:Spawn()
	elseif self:GetActiveWeapon():GetClass() == "vj_thunt_m4a1" then
		local ent = ents.Create("arc9_thunt_ar15")
		local pos = self:GetPos() + Vector(0, 0, 30) 
		ent:SetPos(pos)
        ent:Spawn()
	elseif self:GetActiveWeapon():GetClass() == "vj_thunt_famas" then
		local ent = ents.Create("arc9_thunt_ar15")
		local pos = self:GetPos() + Vector(0, 0, 30) 
		ent:SetPos(pos)
        ent:Spawn()
	elseif self:GetActiveWeapon():GetClass() == "vj_thunt_galil" then
		local ent = ents.Create("arc9_thunt_ar15")
		local pos = self:GetPos() + Vector(0, 0, 30) 
		ent:SetPos(pos)
        ent:Spawn()
	end
end

function ENT:CustomOnAllyDeath(ent)
if math.random(1,5) == 1 then
self.IsGuard = false
self.AnimTbl_Walk = {ACT_WALK}
self.AnimTbl_Run = {ACT_RUN}
self.HasShootWhileMoving = true
self.MoveRandomlyWhenShooting = true
self.WeaponReload_FindCover = true 
self.Still = false
end
if math.random(1,3) == 1 then
self:VJ_TASK_COVER_FROM_ENEMY("TASK_RUN_PATH")
end
end

function ENT:CustomOnDoKilledEnemy(ent, attacker, inflictor) 
if math.random(1,3) == 1 && self:Health() <= self:GetMaxHealth() * 0.8 then
self:VJ_TASK_COVER_FROM_ENEMY("TASK_RUN_PATH")
end
end

function ENT:CustomOnCallForHelp(ally) 
self:VJ_TASK_COVER_FROM_ENEMY("TASK_RUN_PATH")
end

function ENT:AngleFix()
	local angles = self:GetAngles()
	self:SetAngles(Angle(0, angles.y, 0))
end



function ENT:State()
	if IsValid(self:GetEnemy()) then
		
		local tracedataAD = {}
		tracedataAD.start = self:GetPos() + Vector(0,0,40)
		tracedataAD.endpos = self:GetEnemy():GetPos() + Vector(0,0,40)
		tracedataAD.filter = {self:GetEnemy(),self}
		local trAD = util.TraceLine(tracedataAD)
		if (self:GetPos():Distance(self:GetEnemy():GetPos())) > 255 && ( trAD.HitWorld ) or ( trAD.Entity != nil and trAD.Entity != NULL && trAD.Entity && ((trAD.Entity:GetClass() == "prop_dynamic" or trAD.Entity:GetClass() == "func_brush" or trAD.Entity:GetClass() == "func_lod" or trAD.Entity:GetClass() == "func_door_rotating" or trAD.Entity:GetClass() == "prop_door_rotating" or trAD.Entity:GetClass() == "prop_physics" or trAD.Entity:GetClass() == "prop_physics_multiplayer") or (trAD.Entity:IsPlayer() or trAD.Entity:IsNPC()))) then
			self.AnimTbl_WeaponAttack = {ACT_RANGE_ATTACK1}
		else
			self.AnimTbl_WeaponAttack = {ACT_RANGE_ATTACK1_LOW}
		end
	else
	end
end

function ENT:CustomLean()
	local wep = self:GetActiveWeapon()
	local hasAmmo = wep:Clip1() > 0
	self.NextLeanTime = CurTime() + 0.25
		if IsValid(self:GetEnemy()) && hasAmmo && self.EnemyData.LastVisibleTime > 5 then
		local tracedataAD = {}
		tracedataAD.start = self:GetPos() + Vector(0,0,40)
		tracedataAD.endpos = self:GetEnemy():GetPos() + Vector(0,0,40)
		tracedataAD.filter = {self:GetEnemy(),self}
		local trAD = util.TraceLine(tracedataAD)
		if ( trAD.HitWorld ) or ( trAD.Entity != nil and trAD.Entity != NULL && trAD.Entity && ((trAD.Entity:GetClass() == "prop_dynamic" or trAD.Entity:GetClass() == "func_brush" or trAD.Entity:GetClass() == "func_lod" or trAD.Entity:GetClass() == "func_door_rotating"  or trAD.Entity:GetClass() == "prop_door_rotating" or trAD.Entity:GetClass() == "prop_physics" or trAD.Entity:GetClass() == "prop_physics_multiplayer") or (trAD.Entity:IsPlayer() or trAD.Entity:IsNPC()))) then
			local tracedataRight = {}
			tracedataRight.start = self:GetPos() + self:GetRight()*18 + self:GetUp()*45 --Vector(15,0,45)
			tracedataRight.endpos = self:GetEnemy():GetPos() + Vector(0,0,40)
			tracedataRight.filter = {self}
			local tracedataLeft = {}
			tracedataLeft.start = self:GetPos() + self:GetRight()*-18 + self:GetUp()*45 --Vector(-15,0,45)
			tracedataLeft.endpos = self:GetEnemy():GetPos() + Vector(0,0,40) --self:GetEnemy():GetUp()*45
			tracedataLeft.filter = tracedataRight.filter
			local trL = util.TraceLine(tracedataLeft)
			local trR = util.TraceLine(tracedataRight)
			if trR.Entity != nil and trR.Entity != NULL && trR.Entity == self:GetEnemy() && trR.Entity:GetClass() == self:GetEnemy():GetClass() then
				if self.CurrentWeaponAnimation == self:TranslateToWeaponAnim(VJ_PICK(self.AnimTbl_WeaponAttackCrouch)) then
					self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_Spine"),Angle(30,15,15))
					self:FaceCertainEntity(self:GetEnemy(),true)
					self:StopMoving()
					self.IsLeaning = true
				elseif self.CurrentWeaponAnimation == self:TranslateToWeaponAnim(VJ_PICK(self.AnimTbl_WeaponAttack)) then
					self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_Spine"),Angle(30,25,15))
					self:FaceCertainEntity(self:GetEnemy(),true)
					self:StopMoving()
					self.IsLeaning = true
				end
			elseif trL.Entity != nil and trL.Entity != NULL && trL.Entity == self:GetEnemy() && trL.Entity:GetClass() == self:GetEnemy():GetClass() then
				if self.CurrentWeaponAnimation == self:TranslateToWeaponAnim(VJ_PICK(self.AnimTbl_WeaponAttackCrouch)) then
					self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_Spine"),Angle(-30,-10,5))
					self:FaceCertainEntity(self:GetEnemy(),true)
					self:StopMoving()
					self.IsLeaning = true
				elseif self.CurrentWeaponAnimation == self:TranslateToWeaponAnim(VJ_PICK(self.AnimTbl_WeaponAttack)) then
					self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_Spine"),Angle(-45,-45,5))
					self:FaceCertainEntity(self:GetEnemy(),true)
					self:StopMoving()
					self.IsLeaning = true
				end
			else
				self.IsLeaning = false
				self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_Spine"),Angle(0,0,0))
			return end
		else
			self.IsLeaning = false
			self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_Spine"),Angle(0,0,0))
		end
	else
		self.IsLeaning = false
		self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_Spine"),Angle(0,0,0))
end
end


function ENT:CustomBlindFire()
	
	local wep = self:GetActiveWeapon()
	local hasAmmo = wep:Clip1() > 0
	
	local owner = wep:GetOwner()
	local ene = owner:GetEnemy()
	if CurTime() > wep.NPC_NextPrimaryFireT then
	if IsValid(self:GetEnemy()) && hasAmmo then
	


bullet = {}
bullet.Num = wep.Primary.NumberOfShots
bullet.Src=wep:GetPos()
bullet.Dir=wep:GetAngles():Forward()
bullet.Spread = Vector(wep.NPC_CustomSpread * 0.3, wep.NPC_CustomSpread * 0.3, 0) -- was / 6
bullet.Tracer = wep.Primary.Tracer
bullet.Force = wep.Primary.Force
bullet.Damage = (wep.Primary.Damage * 0.5) -- was / 2
bullet.AmmoType = wep.Primary.Ammo
wep:SetClip1(wep:Clip1() - wep.Primary.TakeAmmo)
wep:FireBullets(bullet)

self.DoingWeaponAttack = true
	
	wep.NPC_NextPrimaryFireT = CurTime() + wep.NPC_NextPrimaryFire
	local fireSd = VJ_PICK(wep.Primary.Sound)
	sound.Play(fireSd, owner:GetPos(), wep.Primary.SoundLevel, math.random(wep.Primary.SoundPitch.a, wep.Primary.SoundPitch.b), wep.Primary.SoundVolume)
end
end
end



function ENT:CustomOnMoveRandomlyWhenShooting() 
if math.random(1,3) == 1 then
self:VJ_TASK_COVER_FROM_ENEMY("TASK_WALK_PATH", function(x) x.CanShootWhenMoving = true x.ConstantlyFaceEnemy = true end)
end
end

function ENT:SetAnimData(idle,crouch,crouch_move,walk,run,fire,reload,jump)
	if type(idle) == "string" then idle = VJ_SequenceToActivity(self,idle) end
	if type(crouch) == "string" then crouch = VJ_SequenceToActivity(self,crouch) end
	if type(crouch_move) == "string" then crouch_move = VJ_SequenceToActivity(self,crouch_move) end
	if type(walk) == "string" then walk = VJ_SequenceToActivity(self,walk) end
	if type(run) == "string" then run = VJ_SequenceToActivity(self,run) end
	if type(fire) == "string" then fire = VJ_SequenceToActivity(self,fire) end
	if type(reload) == "string" then reload = VJ_SequenceToActivity(self,reload) end
	if type(jump) == "string" then jump = VJ_SequenceToActivity(self,jump) end

	self.WeaponAnimTranslations[ACT_IDLE] 							= idle
	self.WeaponAnimTranslations[ACT_WALK] 							= walk
	self.WeaponAnimTranslations[ACT_RUN] 							= run
	self.WeaponAnimTranslations[ACT_IDLE_ANGRY] 					= idle
	self.WeaponAnimTranslations[ACT_WALK_AIM] 						= walk
	self.WeaponAnimTranslations[ACT_WALK_CROUCH] 					= crouch_move
	self.WeaponAnimTranslations[ACT_WALK_CROUCH_AIM] 				= crouch_move
	self.WeaponAnimTranslations[ACT_RUN_AIM] 						= run
	self.WeaponAnimTranslations[ACT_RUN_CROUCH] 					= crouch_move
	self.WeaponAnimTranslations[ACT_RUN_CROUCH_AIM] 				= crouch_move
	self.WeaponAnimTranslations[ACT_RANGE_ATTACK1] 					= idle
	self.WeaponAnimTranslations[ACT_GESTURE_RANGE_ATTACK1] 			= fire
	self.WeaponAnimTranslations[ACT_RANGE_ATTACK1_LOW] 				= crouch
	self.WeaponAnimTranslations[ACT_RELOAD]							= "vjges_" .. VJ_GetSequenceName(self,reload)
	self.WeaponAnimTranslations[ACT_COVER_LOW] 						= crouch
	self.WeaponAnimTranslations[ACT_RELOAD_LOW] 					= "vjges_" .. VJ_GetSequenceName(self,reload)
	self.WeaponAnimTranslations[ACT_JUMP] 							= jump
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnSetupWeaponHoldTypeAnims(htype)
	self.CurrentHoldType = htype
	local idle = ACT_HL2MP_IDLE
	local walk = ACT_HL2MP_WALK
	local crouch_move = ACT_HL2MP_WALK_CROUCH
	local run = ACT_HL2MP_RUN
	local fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST
	local crouch = ACT_HL2MP_IDLE_CROUCH
	local reload = ACT_HL2MP_GESTURE_RELOAD_PISTOL
	if htype == "ar2" && self:GetActiveWeapon().CS_HType != "mach" then
		idle = ACT_HL2MP_IDLE_AR2
		walk = ACT_HL2MP_WALK_AR2
		crouch_move = ACT_HL2MP_WALK_CROUCH_AR2
		run = ACT_HL2MP_RUN_AR2
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
		crouch = ACT_HL2MP_IDLE_CROUCH_AR2
		reload = ACT_HL2MP_GESTURE_RELOAD_AR2
		jump = ACT_HL2MP_JUMP_AR2
	elseif htype == "smg" && self:GetActiveWeapon().CS_HType != "mac" then
		idle = ACT_HL2MP_IDLE_SMG1
		walk = ACT_HL2MP_WALK_SMG1
		crouch_move = ACT_HL2MP_WALK_CROUCH_SMG1
		run = ACT_HL2MP_RUN_SMG1
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1
		crouch = ACT_HL2MP_IDLE_CROUCH_SMG1
		reload = ACT_HL2MP_GESTURE_RELOAD_SMG1
		jump = ACT_HL2MP_JUMP_SMG1
	elseif htype == "shotgun" then
		idle = ACT_HL2MP_IDLE_SHOTGUN
		walk = ACT_HL2MP_WALK_SHOTGUN
		crouch_move = ACT_HL2MP_WALK_CROUCH_SHOTGUN
		run = ACT_HL2MP_RUN_SHOTGUN
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN
		crouch = ACT_HL2MP_IDLE_CROUCH_SHOTGUN
		reload = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN
		jump = ACT_HL2MP_JUMP_SHOTGUN
	elseif htype == "rpg" then
		idle = ACT_HL2MP_IDLE_RPG
		walk = ACT_HL2MP_WALK_RPG
		crouch_move = ACT_HL2MP_WALK_CROUCH_RPG
		run = ACT_HL2MP_RUN_RPG
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_RPG
		crouch = ACT_HL2MP_IDLE_CROUCH_RPG
		reload = ACT_HL2MP_GESTURE_RELOAD_RPG
		jump = ACT_HL2MP_JUMP_RPG
	elseif htype == "pistol" then
		idle = ACT_HL2MP_IDLE_REVOLVER
		walk = ACT_HL2MP_WALK_REVOLVER
		crouch_move = ACT_HL2MP_WALK_CROUCH_PISTOL
		run = ACT_HL2MP_RUN_REVOLVER
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
		crouch = ACT_HL2MP_IDLE_CROUCH_PISTOL
		reload = ACT_HL2MP_GESTURE_RELOAD_PISTOL
		jump = ACT_HL2MP_JUMP_REVOLVER
	elseif htype == "dual" then
		idle = "idle_dual"
		walk = "walk_dual"
		crouch_move = "cwalk_dual"
		run = "run_dual"
		fire = "range_dual_r"
		crouch = "cidle_dual"
		reload = "reload_dual"
		jump = "jump_dual"
	elseif htype == "revolver" then
		idle = ACT_HL2MP_IDLE_REVOLVER
		walk = ACT_HL2MP_WALK_REVOLVER
		crouch_move = ACT_HL2MP_WALK_CROUCH_REVOLVER
		run = ACT_HL2MP_RUN_REVOLVER
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER
		crouch = ACT_HL2MP_IDLE_CROUCH_REVOLVER
		reload = ACT_HL2MP_GESTURE_RELOAD_REVOLVER
		jump = ACT_HL2MP_JUMP_REVOLVER
	elseif htype == "crossbow" then
		idle = ACT_HL2MP_IDLE_CROSSBOW
		walk = ACT_HL2MP_WALK_CROSSBOW
		crouch_move = ACT_HL2MP_WALK_CROUCH_CROSSBOW
		run = ACT_HL2MP_RUN_CROSSBOW
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW
		crouch = ACT_HL2MP_IDLE_CROUCH_CROSSBOW
		reload = ACT_HL2MP_GESTURE_RELOAD_CROSSBOW
		jump = ACT_HL2MP_JUMP_CROSSBOW
	elseif htype == "knife" then
		idle = ACT_HL2MP_IDLE_KNIFE
		walk = ACT_HL2MP_WALK_KNIFE
		crouch_move = ACT_HL2MP_WALK_CROUCH_KNIFE
		run = ACT_HL2MP_RUN_KNIFE
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
		crouch = ACT_HL2MP_IDLE_CROUCH_KNIFE
		reload = ACT_HL2MP_GESTURE_RELOAD_KNIFE
		jump = ACT_HL2MP_JUMP_KNIFE
	elseif htype == "grenade" then
		idle = ACT_HL2MP_IDLE_GRENADE
		walk = ACT_HL2MP_WALK_GRENADE
		crouch_move = ACT_HL2MP_WALK_CROUCH_GRENADE
		run = ACT_HL2MP_RUN_GRENADE
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE
		crouch = ACT_HL2MP_IDLE_CROUCH_GRENADE
		reload = ACT_HL2MP_GESTURE_RELOAD_GRENADE
		jump = ACT_HL2MP_JUMP_GRENADE
	elseif htype == "melee" then
		idle = ACT_HL2MP_IDLE_MELEE
		walk = ACT_HL2MP_WALK_MELEE
		crouch_move = ACT_HL2MP_WALK_CROUCH_MELEE
		run = ACT_HL2MP_RUN_MELEE
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
		crouch = ACT_HL2MP_IDLE_CROUCH_MELEE
		reload = ACT_HL2MP_GESTURE_RELOAD_MELEE
		jump = ACT_HL2MP_JUMP_MELEE
	elseif htype == "melee_angry" then
		idle = "idle_melee_angry"
		walk = ACT_HL2MP_WALK_MELEE
		crouch_move = ACT_HL2MP_WALK_CROUCH_MELEE
		run = ACT_HL2MP_RUN_MELEE
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
		crouch = ACT_HL2MP_IDLE_CROUCH_MELEE
		reload = ACT_HL2MP_GESTURE_RELOAD_MELEE
		jump = ACT_HL2MP_JUMP_MELEE
	elseif htype == "melee2" then
		idle = ACT_HL2MP_IDLE_MELEE2
		walk = ACT_HL2MP_WALK_MELEE2
		crouch_move = ACT_HL2MP_WALK_CROUCH_MELEE2
		run = ACT_HL2MP_RUN_MELEE2
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2
		crouch = ACT_HL2MP_IDLE_CROUCH_MELEE2
		reload = ACT_HL2MP_GESTURE_RELOAD_MELEE2
		jump = ACT_HL2MP_JUMP_MELEE2
	elseif htype == "physgun" then
		idle = ACT_HL2MP_IDLE_PHYSGUN
		walk = ACT_HL2MP_WALK_PHYSGUN
		crouch_move = ACT_HL2MP_WALK_CROUCH_PHYSGUN
		run = ACT_HL2MP_RUN_PHYSGUN
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_PHYSGUN
		crouch = ACT_HL2MP_IDLE_CROUCH_PHYSGUN
		reload = ACT_HL2MP_GESTURE_RELOAD_PHYSGUN
		jump = ACT_HL2MP_JUMP_PHYSGUN
	elseif htype == "ar2" && self:GetActiveWeapon().CS_HType == "mach" then
		idle = ACT_HL2MP_IDLE_SHOTGUN
		walk = ACT_HL2MP_WALK_SHOTGUN
		crouch_move = ACT_HL2MP_WALK_CROUCH_SHOTGUN
		run = ACT_HL2MP_RUN_SHOTGUN
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
		crouch = ACT_HL2MP_IDLE_CROUCH_SHOTGUN
		reload = ACT_HL2MP_GESTURE_RELOAD_SMG1
		jump = ACT_HL2MP_JUMP_SHOTGUN
	elseif htype == "smg" && self:GetActiveWeapon().CS_HType == "mac" then
		idle = ACT_HL2MP_IDLE_REVOLVER
		walk = ACT_HL2MP_WALK_REVOLVER
		crouch_move = ACT_HL2MP_WALK_CROUCH_REVOLVER
		run = ACT_HL2MP_RUN_REVOLVER
		fire = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
		crouch = ACT_HL2MP_IDLE_CROUCH_REVOLVER
		reload = ACT_HL2MP_GESTURE_RELOAD_REVOLVER
		jump = ACT_HL2MP_JUMP_REVOLVER
	end
	self:SetAnimData(idle,crouch,crouch_move,walk,run,fire,reload,jump)
	return true
end

function ENT:Between(a,b)
	local waypoint = self:GetCurWaypointPos()
	local ang = (waypoint -self:GetPos()):Angle()
	local dif = math.AngleDifference(self:GetAngles().y,ang.y)
	return dif < a && dif > b
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DecideXY()
	local x = 0
	local y = 0
	if self:Between(30,-30) then
		x = 1
		y = 0
	elseif self:Between(70,30) then
		x = 1
		y = 1
	elseif self:Between(120,70) then
		x = 0
		y = 1
	elseif self:Between(150,120) then
		x = -1
		y = 1
	elseif !self:Between(150,-150) then
		x = -1
		y = 0
	elseif self:Between(-110,-150) then
		x = -1
		y = -1
	elseif self:Between(-70,-110) then
		x = 0
		y = -1
	elseif self:Between(-30,-70) then
		x = 1
		y = -1
	end
	
	self:SetPoseParameter("move_x",x)
	self:SetPoseParameter("move_y",y)
end

function ENT:CustomOnThink()
	self:State()
	
	self:DecideXY()
	if self:IsMoving() then
		if !self.DoingWeaponAttack && self:GetPos():Distance(self:GetCurWaypointPos()) > 75 then
			self:FaceCertainPosition(self:GetCurWaypointPos())
		end
	end
--if self:IsOnGround() then
--self:SetLocalVelocity(self:GetMoveVelocity() * -0.1)
--end
end
---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------


--function ENT:GetSightDirection()
--    local att = self:LookupAttachment("eyes") -- Not all models have it, must check for validity
--    return att != 0 && self:GetAttachment(att).Ang:Forward() or self:GetForward()
--end
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/