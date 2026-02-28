AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {
    "models/murdered/pm/citizen/male_01.mdl",
    "models/murdered/pm/citizen/male_02.mdl",
    "models/murdered/pm/citizen/male_03.mdl",
    "models/murdered/pm/citizen/male_04.mdl",
    "models/murdered/pm/citizen/male_05.mdl",
    "models/murdered/pm/citizen/male_06.mdl",
    "models/murdered/pm/citizen/male_07.mdl",
    "models/murdered/pm/citizen/male_08.mdl",
    "models/murdered/pm/citizen/male_09.mdl",
    "models/murdered/pm/citizen/male_10.mdl",
    "models/murdered/pm/citizen/male_11.mdl",
}

ENT.UsePlayerModelMovement = true
ENT.AnimTbl_MeleeAttack = {"vjseq_seq_baton_swing", "vjges_range_melee_shove_1hand", "vjges_range_melee_shove_2hand"}
ENT.NextMeleeAttackTime = VJ.SET(2,4)
ENT.MeleeAttackDamage = 20

ENT.SoundTbl_FootStep = {"player/footsteps/concrete1.wav", "player/footsteps/concrete2.wav", "player/footsteps/concrete3.wav", "player/footsteps/concrete4.wav"}
ENT.SoundTbl_Damage = {
    "vo/npc/male01/pain01.wav","vo/npc/male01/pain02.wav","vo/npc/male01/pain03.wav","vo/npc/male01/pain04.wav","vo/npc/male01/pain05.wav","vo/npc/male01/pain06.wav","vo/npc/male01/pain07.wav","vo/npc/male01/pain08.wav","vo/npc/male01/pain09.wav"
}
ENT.SoundTbl_Contact = {
    "vo/npc/male01/watchout.wav","vo/npc/male01/overhere01.wav","vo/npc/male01/headsup01.wav", "vo/npc/male01/cps01.wav", "vo/npc/male01/cps02.wav", "vo/npc/male01/gethellout.wav", "vo/npc/male01/getdown02.wav", "vo/npc/male01/civilprotection01.wav", "vo/npc/male01/civilprotection02.wav", "vo/npc/male01/headsup02.wav"
}
ENT.SoundTbl_Fear = {
    "vo/npc/male01/ohno.wav","vo/npc/male01/help01.wav","vo/npc/male01/runforyourlife01.wav","vo/npc/male01/runforyourlife02.wav","vo/npc/male01/runforyourlife03.wav"
}
ENT.SoundTbl_Surrender = {
    "vo/npc/male01/goodgod.wav","vo/npc/male01/ohno.wav","vo/npc/male01/pleaseno.wav","vo/npc/male01/gordead_ans01.wav","vo/npc/male01/gordead_ans04.wav","vo/npc/male01/gordead_ans03.wav","vo/npc/male01/onyourside.wav","vo/npc/male01/gordead_ans19.wav","vo/npc/male01/gordead_ans15.wav","vo/npc/male01/gordead_ans12.wav","vo/npc/male01/gordead_ans11.wav","vo/npc/male01/gordead_ans10.wav","vo/npc/male01/gordead_ans06.wav","vo/npc/male01/gordead_ans05.wav"
}
ENT.SoundTbl_Kill = {
    "vo/npc/male01/gotone.wav","vo/npc/male01/yeah02.wav","vo/npc/male01/likethat.wav"
}
ENT.SoundTbl_IdleVox = {
    "vo/npc/male01/question02.wav","vo/npc/male01/question05.wav"
}
ENT.SoundTbl_Grenade = {
    "vo/npc/male01/overthere01.wav","vo/npc/male01/overthere02.wav","vo/npc/male01/takecover02.wav"
}

ENT.CallForHelp = false
ENT.DeathAllyResponse = false
ENT.StartHealth = 50
ENT.VJ_NPC_Class = {"CLASS_BLOODSHED_SUSPECT"}
ENT.SightDistance = 2000
ENT.SightAngle = 150 
ENT.HearingDistance = 3000
ENT.BecomeEnemyToPlayer = true

ENT.Bleeds = true
ENT.BloodColor = VJ.BLOOD_COLOR_RED

ENT.CanFlinch = true
ENT.FlinchChance = 1
ENT.FlinchCooldown = false
ENT.AnimTbl_Flinch = {"vjges_flinch_phys_01", "vjges_flinch_phys_02"}

local TYPE_SUSPECT = "Suspect"
local TYPE_CIVILIAN = "Civilian"
local TYPE_HOSTAGE = "Hostage"

local PERSONALITY_AGGRESSIVE = "Aggressive"
local PERSONALITY_CAUTIOUS = "Cautious"
local PERSONALITY_COWARD = "Coward"

local MORALE_HIGH = 3
local MORALE_NORMAL = 2
local MORALE_LOW = 1
local MORALE_BROKEN = 0

local AWARENESS_UNAWARE = 0
local AWARENESS_SUSPICIOUS = 1
local AWARENESS_ALERTED = 2
local AWARENESS_COMBAT = 3

local STANCE_PASSIVE = 0
local STANCE_DEFENSIVE = 1
local STANCE_AGGRESSIVE = 2
local STANCE_AMBUSH = 3

local ROLE_LEADER = "leader"
local ROLE_POINTMAN = "pointman"
local ROLE_SUPPORT = "support"
local ROLE_SNIPER = "sniper"
local ROLE_FOLLOWER = "follower"

local WOUND_NONE = 0
local WOUND_LIGHT = 1
local WOUND_MODERATE = 2
local WOUND_SEVERE = 3
local WOUND_CRITICAL = 4

local WOUND_LOCATION_HEAD = "head"
local WOUND_LOCATION_TORSO = "torso"
local WOUND_LOCATION_ARM = "arm"
local WOUND_LOCATION_LEG = "leg"

function ENT:CustomOnInitialize()
    self:InitializeNPCType()
    self:InitializePersonality()
    self:InitializeMorale()
    self:InitializeCombatVars()
    self:InitializeSurrenderVars()
    self:InitializeTrapVars()
    self:InitializeAppearance()
    self:InitializeTimers()
    self:InitializeRoNSystems()
    self:InitializeWoundSystem()
    self:InitializeMemorySystem()
    self:InitializeSquadSystem()
    self:InitializeSoundSystem()
    self:InitializeEnvironmentSystem()
    
    if self.DisableWandering then
        timer.Simple(0.1, function()
            if IsValid(self) then
                self:CheckAmbushBehavior()
            end
        end)
    end
end

function ENT:InitializeRoNSystems()
    self.Awareness = AWARENESS_UNAWARE
    self.AwarenessState = AWARENESS_UNAWARE
    self.AwarenessLevel = 0
    self.AwarenessDecayTime = CurTime()
    self.LastKnownEnemyPos = nil
    self.LastKnownEnemyTime = 0
    self.SuspiciousPositions = {}
    
    self.CombatStance = STANCE_PASSIVE
    self.IsHoldingAngle = false
    self.HoldAnglePos = nil
    self.HoldAngleDir = nil
    self.HoldAngleTimeout = 0
    
    self.IsBlindFiring = false
    self.BlindFireTarget = nil
    self.BlindFireEndTime = 0
    
    self.CanWallbang = self.IsSuspect and math.random(1, 3) == 1
    self.LastWallbangTime = 0
    
    self.IsUsingHostageShield = false
    self.HostageShield = nil
    
    self.HeardSounds = {}
    self.LastHeardSoundTime = 0
    self.InvestigatingSound = false
    
    self.TeamRole = nil
    self.SquadLeader = nil
    self.SquadMembers = {}
    self.SquadID = nil
    self.SquadFormation = "loose"
    self.LastSquadUpdate = 0
    self.SquadCommunicationRange = 800
    self.IsSquadLeader = false
    self.SquadOrders = nil
    self.LastOrderTime = 0
    
    self.DoorMemory = {}
    self.RoomCleared = {}
    self.BlockedDoors = {}
    self.WaitingForEnemy = false
    self.AmbushPosition = nil
    
    self.LastPeekTime = 0
    self.PeekDirection = 0
    self.IsPeeking = false
    
    self.ReactionDelay = 0
    self.QueuedAction = nil
    
    self.CoverPosition = nil
    self.LastCoverChangeTime = 0
    
    self.PreFireWarning = self.Personality ~= PERSONALITY_AGGRESSIVE and math.random(1, 3) == 1
end

function ENT:InitializeNPCType()
    local rand = math.random(1, 100)
    
    if rand <= 25 then
        self.NPCType = TYPE_CIVILIAN
        self.IsCivilian = true
        self.IsHostage = false
        self.IsSuspect = false
        self:SetupCivilian()
    elseif rand <= 35 then
        self.NPCType = TYPE_HOSTAGE
        self.IsCivilian = false
        self.IsHostage = true
        self.IsSuspect = false
        self:SetupHostage()
    else
        self.NPCType = TYPE_SUSPECT
        self.IsCivilian = false
        self.IsHostage = false
        self.IsSuspect = true
        self:SetupSuspect()
    end
    
    self.SuspectNPC = self.IsSuspect
end

function ENT:SetupCivilian()
    self.VJ_NPC_Class = {"CLASS_BLOODSHED_CIVILIAN"}
    self.BecomeEnemyToPlayer = false
    self.DisableWandering = false
    self.StartHealth = 40
    self:SetHealth(40)
    self:SetMaxHealth(40)
    
    self.CanAttack = false
    self.DisableMeleeAttack = true
    self.DisableWeaponFiringGesture = true
    self.NoWeapon = true
    
    self.CivilianPenaltyMoney = 100
    self.CivilianPenaltyGuilt = math.random(10, 25)
    
    self.Surrendering = false
    self.PermanentSurrender = false
    self.FleeOnDanger = true
    self.FleeDistance = 1500
    
    self.IsHiddenSuspect = math.random(1, 3) == 1
    if self.IsHiddenSuspect then
        self.HiddenWeapon = math.random(1, 3) == 1 and "weapon_vj_bloodshed_sus_secondary" or "weapon_vj_bloodshed_sus_melee"
        self.HasRevealed = false
    end
    
    self.SoundTbl_Surrender = {
        "vo/npc/male01/illstayhere01.wav",
        "vo/npc/male01/help01.wav",
        "vo/npc/male01/imstickinghere01.wav",
        "vo/npc/male01/no02.wav",
        "vo/npc/male01/ohno.wav",
        "vo/npc/male01/pleaseno.wav",
        "vo/npc/male01/imhurt01.wav",
        "vo/npc/male01/imhurt02.wav"
    }
end

function ENT:SetupHostage()
    self.VJ_NPC_Class = {"CLASS_BLOODSHED_HOSTAGE"}
    self.BecomeEnemyToPlayer = false
    self.DisableWandering = true
    self.StartHealth = 35
    self:SetHealth(35)
    self:SetMaxHealth(35)
    
    self.CanAttack = false
    self.DisableMeleeAttack = true
    self.DisableWeaponFiringGesture = true
    self.NoWeapon = true
    
    self.HostageRescueReward = math.random(300, 800)
    self.HostageDeathPenalty = math.random(1000, 3000)
    self.HostageDeathGuilt = math.random(15, 35)
    
    self.Surrendering = true
    self.PermanentSurrender = true
    self.SurrenderAnimStarted = false
    
    self.CanBeRescued = true
    self.IsRescued = false
end

function ENT:SetupSuspect()
    self.VJ_NPC_Class = {"CLASS_BLOODSHED_SUSPECT"}
    self.BecomeEnemyToPlayer = true
    
    local wanderRoll = math.random(1, 100)
    self.DisableWandering = wanderRoll > 60
    
    self.CanAttack = true
    self.DisableMeleeAttack = false
    self.NoWeapon = false
end

function ENT:InitializePersonality()
    if self.IsCivilian or self.IsHostage then
        self.Personality = PERSONALITY_COWARD
        return
    end
    
    local rand = math.random(1, 100)
    if rand <= 20 then
        self.Personality = PERSONALITY_AGGRESSIVE
    elseif rand <= 60 then
        self.Personality = PERSONALITY_CAUTIOUS
    else
        self.Personality = PERSONALITY_COWARD
    end
    
    self:ApplyPersonalityTraits()
end

function ENT:ApplyPersonalityTraits()
    if self.Personality == PERSONALITY_AGGRESSIVE then
        self.BaseSurrenderChance = 15
        self.FakeSurrenderChance = 40
        self.ChaseEnemyAlways = math.random(1, 3) == 1
        self.ChaseEnemyWhenGoodSituation = true
        self.TakeOnSightBeforeShoot = false
        self.ReactionTime = 0.3
        self.AccuracyMod = 1.2
        
    elseif self.Personality == PERSONALITY_CAUTIOUS then
        self.BaseSurrenderChance = 35
        self.FakeSurrenderChance = 20
        self.ChaseEnemyAlways = false
        self.ChaseEnemyWhenGoodSituation = true
        self.TakeOnSightBeforeShoot = math.random(1, 2) == 1
        self.ReactionTime = 0.6
        self.AccuracyMod = 1.0
        
    else
        self.BaseSurrenderChance = 60
        self.FakeSurrenderChance = 8
        self.ChaseEnemyAlways = false
        self.ChaseEnemyWhenGoodSituation = false
        self.TakeOnSightBeforeShoot = true
        self.ReactionTime = 0.9
        self.AccuracyMod = 0.7
    end
end

function ENT:InitializeMorale()
    self.MoraleFactors = {
        allies_nearby = 0,
        enemies_nearby = 0,
        health_ratio = 1,
        witnessed_deaths = 0,
        suppression = 0
    }
    
    if self.IsCivilian or self.IsHostage then
        self.Morale = MORALE_BROKEN
        return
    end
    
    if self.Personality == PERSONALITY_AGGRESSIVE then
        self.Morale = MORALE_HIGH
    elseif self.Personality == PERSONALITY_COWARD then
        self.Morale = MORALE_LOW
    else
        self.Morale = MORALE_NORMAL
    end
end

function ENT:InitializeCombatVars()
    self.SuppressionLevel = 0
    self.MaxSuppression = 100
    self.LastSuppressionTime = 0
    
    self.Weapon_Accuracy = self.AccuracyMod or 1
    self.CombatStartTime = 0
    self.LastSawEnemyTime = 0
    
    self.IsRetreating = false
    self.LastRetreatTime = 0
    self.IsPanicking = false
    
    self.HasGrenades = self.IsSuspect and math.random(1, 5) == 1
    self.GrenadesCount = self.HasGrenades and math.random(1, 2) or 0
    self.NextGrenadeTime = CurTime() + math.random(10, 30)
    self.NextThrowGrenadeT = CurTime() + math.random(10, 30)
end

function ENT:InitializeSurrenderVars()
    self.Surrendering = self.IsHostage or false
    self.SurrenderAnimStarted = false
    self.SurrenderStartTime = 0
    self.UnsurrenderTime = CurTime()
    
    self.FakeSurrendering = false
    self.FakeSurrenderWindow = 0
    
    self.LastWeapon = nil
end

function ENT:InitializeWoundSystem()
    self.Wounds = {
        [WOUND_LOCATION_HEAD] = WOUND_NONE,
        [WOUND_LOCATION_TORSO] = WOUND_NONE,
        [WOUND_LOCATION_ARM] = WOUND_NONE,
        [WOUND_LOCATION_LEG] = WOUND_NONE
    }
    self.TotalWoundSeverity = 0
    self.IsLimping = false
    self.IsBleeding = false
    self.BleedRate = 0
    self.LastBleedTime = 0
    self.NextBleedDamageTime = 0
    self.CanHealSelf = self.IsSuspect and math.random(1, 4) == 1
    self.HealingKitCount = self.CanHealSelf and 1 or 0
    self.IsHealing = false
    self.HealingEndTime = 0
    self.PainLevel = 0
    self.MaxPain = 100
end

function ENT:InitializeMemorySystem()
    self.PlayerMemory = {}
    self.ThreatMemory = {}
    self.CoverMemory = {}
    self.DangerZones = {}
    self.SuccessfulTactics = {}
    self.FailedTactics = {}
    self.LastSeenPlayers = {}
    self.PlayerThreatLevel = {}
    self.EncounterCount = 0
    self.AdaptationLevel = 0
end

function ENT:InitializeSquadSystem()
    self.SquadTactics = {
        crossfire = false,
        pindown = false,
        flank = false,
        retreat = false
    }
    self.AssignedCoverSector = nil
    self.SupportingAlly = nil
    self.NeedingSupport = false
    self.LastCalloutTime = 0
    self.Callouts = {}
end

function ENT:InitializeSoundSystem()
    self.SoundMemory = {}
    self.LastSoundAnalysis = 0
    self.IdentifiedWeaponSounds = {}
    self.FootstepPatterns = {}
    self.VoiceCallouts = {}
    self.LastCallout = 0
    self.SoundAlertLevel = 0
    self.EchoLocatedPositions = {}
end

function ENT:InitializeEnvironmentSystem()
    self.KnownDoors = {}
    self.BarricadedDoors = {}
    self.BrokenWindows = {}
    self.UsableProps = {}
    self.KnownLadders = {}
    self.KnownVents = {}
    self.EnvironmentScanned = false
    self.LastEnvironmentScan = 0
    self.CanBarricade = self.IsSuspect and self.Personality == PERSONALITY_CAUTIOUS
    self.BarricadeCount = 0
    self.MaxBarricades = 2
end
function ENT:InitializeTrapVars()
    if not self.IsSuspect then
        self.CanSetTraps = false
        return
    end
    
    self.CanSetTraps = (self.Personality == PERSONALITY_CAUTIOUS or self.Personality == PERSONALITY_AGGRESSIVE) and math.random(1, 100) <= 70
    self.TrapsPlaced = 0
    self.MaxTraps = 5
    self.NextTrapTime = CurTime() + math.random(10, 30)
    self.LastTrapPos = nil
    self.TrapMemory = {}
    self.EnemyPathMemory = {}
    self.HighTrafficAreas = {}
    self.CachedNearbyEnts = {}
    self.NextCacheUpdate = 0
end

function ENT:InitializeAppearance()
    local skinCount = self:SkinCount()
    self:SetSkin(math.random(0, skinCount - 1))
    self:SetSquad(tostring(math.random(1, 32)))
    
    for i = 0, self:GetNumBodyGroups() - 1 do
        local count = self:GetBodygroupCount(i)
        self:SetBodygroup(i, math.random(0, count - 1))
    end
end

function ENT:InitializeTimers()
    self.NextMoraleUpdate = CurTime() + 1
    self.NextLeanTime = CurTime()
    self.NextLookTime = CurTime()
    self.NextIdleVox = CurTime() + math.random(30, 60)
    self.NextVoxCooldowns = {}
    self.NextAwarenessUpdate = CurTime()
    self.NextTacticalDecision = CurTime()
    self.NextSoundCheck = CurTime()
end

function ENT:UpdateAwareness()
    if CurTime() < self.NextAwarenessUpdate then return end
    self.NextAwarenessUpdate = CurTime() + 0.3
    
    local enemy = self:GetEnemy()
    
    -- Fast detection if player has flashlight on or is running
    if IsValid(enemy) and enemy:IsPlayer() then
        local dist = self:GetPos():Distance(enemy:GetPos())
        local isFlashlight = enemy:FlashlightIsOn()
        local speed = enemy:GetVelocity():Length()
        
        if isFlashlight and self:Visible(enemy) and dist < 2000 then
             -- Instantly alert if flashlight shines on me or near me
             if self.Awareness < AWARENESS_ALERTED then
                 self.Awareness = AWARENESS_ALERTED
             end
             -- Force combat if close
             if dist < 800 then
                 self.Awareness = AWARENESS_COMBAT
             end
        end
        
        -- Running makes you easier to spot even if not directly looked at (peripheral vision)
        if speed > 200 and dist < 1000 and self:Visible(enemy) then
             if self.Awareness < AWARENESS_ALERTED then
                 self.Awareness = AWARENESS_ALERTED
             end
        end
    end
    
    if IsValid(enemy) and self:Visible(enemy) then
        self.Awareness = AWARENESS_COMBAT
        self.LastKnownEnemyPos = enemy:GetPos()
        self.LastKnownEnemyTime = CurTime()
        self.AwarenessDecayTime = CurTime() + 10
        return
    end
    
    if self.LastKnownEnemyPos and CurTime() - self.LastKnownEnemyTime < 5 then
        self.Awareness = AWARENESS_ALERTED
        return
    end
    
    if #self.SuspiciousPositions > 0 or self.InvestigatingSound then
        self.Awareness = AWARENESS_SUSPICIOUS
        return
    end
    
    if CurTime() > self.AwarenessDecayTime then
        if self.Awareness > AWARENESS_UNAWARE then
            self.Awareness = self.Awareness - 1
            self.AwarenessDecayTime = CurTime() + 8
        end
    end
end

function ENT:SetAwareness(level)
    local oldAwareness = self.Awareness
    self.Awareness = math.Clamp(level, AWARENESS_UNAWARE, AWARENESS_COMBAT)
    
    if self.Awareness > oldAwareness then
        self.AwarenessDecayTime = CurTime() + 15
        
        if self.Awareness == AWARENESS_COMBAT then
            self:OnEnterCombat()
        elseif self.Awareness == AWARENESS_ALERTED then
            self:OnBecomeAlerted()
        elseif self.Awareness == AWARENESS_SUSPICIOUS then
            self:OnBecomeSuspicious()
        end
    end
end

function ENT:OnEnterCombat()
    self.CombatStartTime = CurTime()
    self:DecideCombatStance()
    self:CallAllyReaction("combat_started")
end

function ENT:OnBecomeAlerted()
    if self:CanPlayVox("contact") then
        self:PlayVox(self.SoundTbl_Contact, 80)
        self:SetVoxCooldown("contact", 10)
    end
    
    self:CallAllyReaction("alert")
end

function ENT:OnBecomeSuspicious()
    if #self.SuspiciousPositions > 0 then
        self:InvestigatePosition(self.SuspiciousPositions[1])
    end
end

function ENT:DecideCombatStance()
    if self.IsCivilian or self.IsHostage then
        self.CombatStance = STANCE_PASSIVE
        return
    end
    
    local healthRatio = self:Health() / self:GetMaxHealth()
    local hasAdvantage = self.MoraleFactors.allies_nearby >= self.MoraleFactors.enemies_nearby
    
    if self.Personality == PERSONALITY_AGGRESSIVE then
        if healthRatio > 0.5 then
            self.CombatStance = STANCE_AGGRESSIVE
        else
            self.CombatStance = STANCE_DEFENSIVE
        end
    elseif self.Personality == PERSONALITY_CAUTIOUS then
        if hasAdvantage and healthRatio > 0.6 then
            self.CombatStance = STANCE_DEFENSIVE
        else
            self.CombatStance = STANCE_AMBUSH
        end
    else
        self.CombatStance = STANCE_DEFENSIVE
    end
    
    if self.DisableWandering and not IsValid(self:GetEnemy()) then
        self.CombatStance = STANCE_AMBUSH
    end
end

function ENT:HearSound(soundPos, soundType, loudness)
    if not self.IsSuspect then return end
    if self.Awareness == AWARENESS_COMBAT then return end
    
    local dist = self:GetPos():Distance(soundPos)
    if dist > self.HearingDistance then return end
    
    local effectiveLoudness = loudness * (1 - dist / self.HearingDistance)
    
    if effectiveLoudness < 0.3 then return end
    
    table.insert(self.SuspiciousPositions, soundPos)
    if #self.SuspiciousPositions > 5 then
        table.remove(self.SuspiciousPositions, 1)
    end
    
    self.LastHeardSoundTime = CurTime()
    
    if soundType == "gunshot" then
        self:SetAwareness(AWARENESS_ALERTED)
        self:AddSuppression(10)
    elseif soundType == "footstep" or soundType == "door" then
        if self.Awareness < AWARENESS_SUSPICIOUS then
            self:SetAwareness(AWARENESS_SUSPICIOUS)
        end
    elseif soundType == "flashbang_pin" then
        self:ReactToFlashbangWarning(soundPos)
    end
end

function ENT:ReactToFlashbangWarning(pos)
    local dist = self:GetPos():Distance(pos)
    local reactionChance = math.Clamp(100 - (dist / 10), 20, 90)
    
    if self.Personality == PERSONALITY_AGGRESSIVE then
        reactionChance = reactionChance * 0.6
    elseif self.Personality == PERSONALITY_CAUTIOUS then
        reactionChance = reactionChance * 1.2
    else
        reactionChance = reactionChance * 1.5
    end
    
    if math.random(1, 100) <= reactionChance then
        local actionRoll = math.random(1, 100)
        
        if actionRoll <= 25 then
            self:CoverEarsAndEyes()
            self:StopMoving()
            self:SetAngles((self:GetPos() - pos):Angle())
        elseif actionRoll <= 50 then
            self:LookAway(pos)
            if math.random(1, 2) == 1 then
                self:CrouchDown()
            end
        elseif actionRoll <= 75 then
            local coverPos = self:FindQuickCover(pos)
            if coverPos then
                self:SetLastPosition(coverPos)
                self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH")
            end
        else
            self:FleeFromPosition(pos, 400)
        end
        
        if self:CanPlayVox("fear") and math.random(1, 3) == 1 then
            self:PlayVox({"vo/npc/male01/watchout.wav", "vo/npc/male01/getdown02.wav"}, 80)
            self:SetVoxCooldown("fear", 5)
        end
    end
end

function ENT:LookAway(fromPos)
    local awayDir = (self:GetPos() - fromPos):GetNormalized()
    local awayAng = awayDir:Angle()
    self:SetAngles(Angle(0, awayAng.y, 0))
end

function ENT:CoverEarsAndEyes()
    if self:LookupSequence("coverhead") ~= -1 then
        self:PlayAnim("vjseq_coverhead", true, 2, false)
    elseif self:LookupSequence("idle_all_cower") ~= -1 then
        self:PlayAnim("idle_all_cower", true, 2, false)
    end
    
    self.IsCoveringHead = true
    self.CoverHeadEndTime = CurTime() + 2
end

function ENT:CrouchDown()
    if self:LookupSequence("crouch_idle_01") ~= -1 then
        self:PlayAnim("vjseq_crouch_idle_01", true, 2, false)
    end
end

function ENT:FleeFromPosition(pos, minDist)
    local fleeDir = (self:GetPos() - pos):GetNormalized()
    local fleePos = self:GetPos() + fleeDir * minDist
    
    local tr = util.TraceLine({
        start = self:GetPos() + Vector(0, 0, 32),
        endpos = fleePos + Vector(0, 0, 32),
        filter = self,
        mask = MASK_NPCSOLID
    })
    
    if tr.Hit then
        fleePos = tr.HitPos - fleeDir * 50
    end
    
    self:SetLastPosition(fleePos)
    self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH")
end

function ENT:FindPhysicsCover(threatPos)
    local myPos = self:GetPos()
    local props = ents.FindInSphere(myPos, 500)
    
    for _, prop in pairs(props) do
        if not IsValid(prop) then continue end
        if prop:GetClass() ~= "prop_physics" then continue end
        
        local mins, maxs = prop:GetCollisionBounds()
        local height = maxs.z - mins.z
        local width = math.max(maxs.x - mins.x, maxs.y - mins.y)
        
        if height < 30 or width < 20 then continue end
        
        local propPos = prop:GetPos()
        local toThreat = (threatPos - propPos):GetNormalized()
        local coverPos = propPos - toThreat * (width + 30)
        
        local tr = util.TraceHull({
            start = coverPos + Vector(0,0,10),
            endpos = coverPos + Vector(0,0,10),
            mins = Vector(-16,-16,0),
            maxs = Vector(16,16,64),
            filter = {self, prop},
            mask = MASK_NPCSOLID
        })
        
        if not tr.Hit then
             local visIdx = 0
             local points = {coverPos + Vector(0,0,30), coverPos + Vector(0,0,60)}
             for _, p in pairs(points) do
                 local visTr = util.TraceLine({start = p, endpos = threatPos + Vector(0,0,50), filter = {self, prop}, mask = MASK_SHOT})
                 if visTr.Hit then
                    visIdx = visIdx + 1
                    if visTr.Entity == prop then visIdx = visIdx + 1 end
                 end
             end
             if visIdx >= 1 then return coverPos end
        end
    end
    return nil
end

function ENT:FindQuickCover(threatPos)
    local myPos = self:GetPos()
    local awayDir = (myPos - threatPos):GetNormalized()
    
    -- PRIORITIZE PHYSICS PROPS (User Request: "Сделать чаще прятки за пропы")
    if math.random(1, 100) <= 70 then -- 70% chance to check props FIRST
        local propCover = self:FindPhysicsCover(threatPos)
        if propCover then return propCover end
    end
    
    for dist = 100, 300, 50 do
        local testPos = myPos + awayDir * dist
        local tr = util.TraceLine({start = myPos + Vector(0, 0, 32), endpos = testPos + Vector(0, 0, 32), filter = self, mask = MASK_NPCSOLID})
        if not tr.Hit then
            local coverTr = util.TraceLine({start = testPos + Vector(0, 0, 32), endpos = threatPos + Vector(0, 0, 32), mask = MASK_SHOT})
            if coverTr.Hit then return testPos end
        end
    end
    
    -- If we didn't check props first (or failed), check them now
    local propCover = self:FindPhysicsCover(threatPos)
    if propCover then return propCover end
    
    return nil
end

function ENT:InvestigatePosition(pos)
    if not pos then return end
    -- User Request: only aggressive investigates, and not always
    if self.Personality ~= PERSONALITY_AGGRESSIVE then return end
    if self.Surrendering or self.IsPanicking or math.random(1, 10) > 3 then return end -- 30% chance to investigate
    self.InvestigatingSound = true
    local approachPos = pos + VectorRand() * 50
    approachPos.z = pos.z
    self:SetLastPosition(approachPos)
    self:SCHEDULE_GOTO_POSITION("TASK_WALK_PATH", function(x)
        x.CanShootWhenMoving = true
        x.RunCode_OnFinish = function()
            self.InvestigatingSound = false
            table.RemoveByValue(self.SuspiciousPositions, pos)
        end
    end)
end

function ENT:TryWallbang(targetPos)
    if not self.CanWallbang then return false end
    if CurTime() - self.LastWallbangTime < 3 then return false end
    if self.Surrendering then return false end
    
    local wep = self:GetActiveWeapon()
    if not IsValid(wep) or wep:Clip1() < 3 then return false end
    
    -- Predictive Wallbang: If enemy is moving, aim slightly ahead
    local enemy = self:GetEnemy()
    local predictedPos = targetPos
    if IsValid(enemy) then
         local vel = enemy:GetVelocity()
         if vel:Length() > 50 then
             predictedPos = targetPos + vel * 0.5 -- Aim 0.5s ahead
         end
    end
    
    local myPos = self:EyePos()
    local tr = util.TraceLine({
        start = myPos,
        endpos = predictedPos,
        filter = self,
        mask = MASK_SHOT
    })
    
    if not tr.Hit then return false end
    
    local hitEnt = tr.Entity
    if not IsValid(hitEnt) then return false end
    
    local canPenetrate = hitEnt:GetClass():find("door") or 
                         hitEnt:GetClass():find("func_breakable") or
                         hitEnt:GetClass() == "prop_physics"
    
    if not canPenetrate then
        local material = tr.MatType
        canPenetrate = material == MAT_WOOD or material == MAT_GLASS or material == MAT_PLASTIC or material == MAT_ALIENFLESH or material == MAT_FLESH
    end
    
    if canPenetrate then
        self:DoWallbang(tr.HitPos, predictedPos) -- Use predicted pos
        return true
    end
    
    return false
end

function ENT:DoWallbang(wallPos, targetPos)
    self.LastWallbangTime = CurTime()
    
    local fireDir = (targetPos - self:EyePos()):GetNormalized()
    local spreadDir = fireDir + VectorRand() * 0.1
    
    self:SetAngles(spreadDir:Angle())
    
    local wep = self:GetActiveWeapon()
    if not IsValid(wep) then return end
    
    local burstCount = math.random(3, 6)
    
    for i = 1, burstCount do
        timer.Simple(i * 0.1, function()
            if IsValid(self) and IsValid(wep) and wep:Clip1() > 0 then
                wep:PrimaryAttack()
            end
        end)
    end
    
    if self:CanPlayVox("contact") then
        self:PlayVox(self.SoundTbl_Contact, 85)
        self:SetVoxCooldown("contact", 5)
    end
end

function ENT:StartHoldingAngle(pos, dir)
    if self.Surrendering or self.IsPanicking then return end
    
    self.IsHoldingAngle = true
    self.HoldAnglePos = pos
    self.HoldAngleDir = dir
    self.HoldAngleTimeout = CurTime() + math.random(10, 30)
    
    self:SetLastPosition(pos)
    self:SCHEDULE_GOTO_POSITION("TASK_WALK_PATH", function(x)
        x.CanShootWhenMoving = false
        x.RunCode_OnFinish = function()
            if IsValid(self) and self.IsHoldingAngle then
                self:SetAngles(dir:Angle())
                self:SetState(VJ_STATE_FREEZE)
            end
        end
    end)
end

function ENT:HoldAngleThink()
    if not self.IsHoldingAngle then return end
    
    if CurTime() > self.HoldAngleTimeout then
        self:StopHoldingAngle()
        return
    end
    
    local enemy = self:GetEnemy()
    if IsValid(enemy) and self:Visible(enemy) then
        self:StopHoldingAngle()
        return
    end
    
    if self.HoldAngleDir then
        self:SetAngles(self.HoldAngleDir:Angle())
    end
end

function ENT:StopHoldingAngle()
    self.IsHoldingAngle = false
    self.HoldAnglePos = nil
    self.HoldAngleDir = nil
    self:SetState(VJ_STATE_NONE)
end

function ENT:HoldPosition(duration)
    duration = duration or 5
    self:StopMoving()
    self.IsHoldingPosition = true
    self.HoldPositionEnd = CurTime() + duration
    
    timer.Simple(duration, function()
        if IsValid(self) then
            self.IsHoldingPosition = false
        end
    end)
end

function ENT:TryBlindFire(targetPos)
    if self.Surrendering or self.IsPanicking then return end
    if self.IsBlindFiring then return end
    
    local wep = self:GetActiveWeapon()
    if not IsValid(wep) or wep:Clip1() < 5 then return end
    
    if self.SuppressionLevel < 40 then return end
    
    self.IsBlindFiring = true
    self.BlindFireTarget = targetPos
    self.BlindFireEndTime = CurTime() + math.random(1, 3)
    
    self:DoBlindFireBurst()
end

function ENT:DoBlindFireBurst()
    if not self.IsBlindFiring then return end
    
    local wep = self:GetActiveWeapon()
    if not IsValid(wep) or wep:Clip1() <= 0 then
        self.IsBlindFiring = false
        return
    end
    
    local fireDir = (self.BlindFireTarget - self:EyePos()):GetNormalized()
    fireDir = fireDir + VectorRand() * 0.3
    
    self:SetAngles(fireDir:Angle())
    
    for i = 1, math.random(2, 4) do
        timer.Simple(i * 0.15, function()
            if IsValid(self) and IsValid(wep) and wep:Clip1() > 0 and self.IsBlindFiring then
                wep:PrimaryAttack()
            end
        end)
    end
end

function ENT:BlindFireThink()
    if not self.IsBlindFiring then return end
    
    if CurTime() > self.BlindFireEndTime then
        self.IsBlindFiring = false
        return
    end
    
    if math.random(1, 100) <= 20 then
        self:DoBlindFireBurst()
    end
end

function ENT:TryUseHostageShield()
    if self.IsUsingHostageShield then return end
    if self.Morale > MORALE_LOW then return end
    if self.Personality == PERSONALITY_COWARD then return end
    
    local nearbyTargets = {}
    
    for _, ent in pairs(ents.FindInSphere(self:GetPos(), 150)) do
        if ent == self then continue end
        
        if ent:GetClass() == self:GetClass() and (ent.IsHostage or ent.IsCivilian) and not ent.IsRescued then
            if not ent.IsBeingUsedAsShield then
                table.insert(nearbyTargets, ent)
            end
        end
    end
    
    if #nearbyTargets == 0 then return end
    
    local target = nearbyTargets[math.random(1, #nearbyTargets)]
    self:GrabHostageShield(target)
end

function ENT:GrabHostageShield(victim)
    if not IsValid(victim) then return end
    if self.IsUsingHostageShield then return end
    if victim:IsPlayer() then return end
    
    self.IsUsingHostageShield = true
    self.HostageShield = victim
    self.HostageShieldGrabTime = CurTime()
    self.HostageShootCooldown = CurTime() + 0.5
    
    victim.IsBeingUsedAsShield = true
    victim.HostageAttackerNPC = self
    
    local victimFwd = victim:GetForward()
    local attackFwd = self:GetForward()
    local dotFacing = victimFwd:Dot(attackFwd)
    
    if dotFacing < -0.5 then
        self.HostageGrabType = "front"
    else
        self.HostageGrabType = "behind"
    end
    
    self:EmitSound("murdered/gore/punch" .. math.random(1, 4) .. ".mp3", 60)
    
    victim:SetState(VJ_STATE_FREEZE)
    victim:StopMoving()
    
    if self.HostageGrabType == "front" then
        victim:PlayAnim("mur_hostage_victim_front", true, false)
    else
        victim:PlayAnim("mur_hostage_victim_behind", true, false)
    end
    
    if self.HostageGrabType == "front" then
        self:PlayAnim("mur_hostage_attacker_front", true, false)
    else
        self:PlayAnim("mur_hostage_attacker_behind", true, false)
    end
    
    self:SetState(VJ_STATE_ONLY_ANIMATION_NOATTACK)
    self:StopMoving()
    
    if self:CanPlayVox("fear") then
        self:PlayVox({"vo/npc/male01/gethellout.wav", "vo/npc/male01/answer16.wav"}, 85)
        self:SetVoxCooldown("fear", 10)
    end
end

function ENT:ReleaseHostageShield(escaped)
    if not self.IsUsingHostageShield then return end
    
    local victim = self.HostageShield
    
    if IsValid(victim) then
        victim.IsBeingUsedAsShield = false
        victim.HostageAttackerNPC = nil
        
        victim:SetState(VJ_STATE_NONE)
        
        if escaped then
            victim:PlayAnim("mur_hostage_victim_escape", true, 1, false)
            
            timer.Simple(1, function()
                if IsValid(victim) then
                    local fleeDir = (victim:GetPos() - self:GetPos()):GetNormalized() * 200
                    local fleePos = victim:GetPos() + fleeDir
                    victim:SetLastPosition(fleePos)
                    victim:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH")
                end
            end)
        end
        
        self:EmitSound("murdered/gore/punch" .. math.random(1, 4) .. ".mp3", 60)
    end
    
    if escaped then
        self:PlayAnim("mur_hostage_attacker_escape", true, 1, false)
    end
    
    self.IsUsingHostageShield = false
    self.HostageShield = nil
    self.HostageGrabType = nil
    
    timer.Simple(escaped and 1 or 0.1, function()
        if IsValid(self) then
            self:SetState(VJ_STATE_NONE)
        end
    end)
end

function ENT:ExecuteHostage()
    if not self.IsUsingHostageShield then return end
    
    local victim = self.HostageShield
    if not IsValid(victim) then
        self:ReleaseHostageShield(false)
        return
    end
    
    self:ReleaseHostageShield(false)
    
    timer.Simple(0.1, function()
        if IsValid(self) and IsValid(victim) then
            victim:TakeDamage(999, self, self)
        end
    end)
end

function ENT:ShootFromHostagePosition()
    if not self.IsUsingHostageShield then return end
    if CurTime() < self.HostageShootCooldown then return end
    
    local wep = self:GetActiveWeapon()
    if not IsValid(wep) or wep:Clip1() <= 0 then return end
    
    local enemy = self:GetEnemy()
    if not IsValid(enemy) then return end
    
    self.HostageShootCooldown = CurTime() + math.random(1, 2)
    
    local fireDir = (enemy:GetPos() + Vector(0, 0, 40) - self:EyePos()):GetNormalized()
    fireDir = fireDir + VectorRand() * 0.15
    self:SetAngles(fireDir:Angle())
    
    wep:PrimaryAttack()
end

function ENT:HostageShieldThink()
    if not self.IsUsingHostageShield then return end
    
    local victim = self.HostageShield
    
    if not IsValid(victim) then
        self:ReleaseHostageShield(false)
        return
    end
    
    if victim:Health() <= 0 then
        self:ReleaseHostageShield(false)
        return
    end
    
    if self:Health() <= 0 or self.Surrendering then
        self:ReleaseHostageShield(true)
        return
    end
    
    local offset
    if self.HostageGrabType == "front" then
        offset = self:GetForward() * 35
    else
        offset = self:GetForward() * 40
    end
    
    victim:SetPos(self:GetPos() + offset)
    victim:SetAngles(self:GetAngles() + Angle(0, 180, 0))
    
    local enemy = self:GetEnemy()
    if IsValid(enemy) then
        local toEnemy = (enemy:GetPos() - self:GetPos()):GetNormalized()
        local ang = toEnemy:Angle()
        self:SetAngles(Angle(0, ang.y, 0))
        
        if math.random(1, 100) <= 30 then
            self:ShootFromHostagePosition()
        end
    end
    
    if CurTime() - self.HostageShieldGrabTime > 30 then
        if math.random(1, 100) <= 20 then
            if self.Personality == PERSONALITY_AGGRESSIVE then
                self:ExecuteHostage()
            else
                self:ReleaseHostageShield(true)
            end
        end
    end
    
    if self:Health() < 20 and self.Personality == PERSONALITY_AGGRESSIVE then
        if math.random(1, 100) <= 10 then
            self:ExecuteHostage()
        end
    end
end

function ENT:PeekCorner(direction)
    if self.IsPeeking then return end
    if CurTime() - self.LastPeekTime < 2 then return end
    
    self.IsPeeking = true
    self.PeekDirection = direction
    self.LastPeekTime = CurTime()
    
    local peekOffset = self:GetRight() * direction * 30
    local originalPos = self:GetPos()
    
    self:DoLean(direction > 0 and 25 or -25, 0, direction > 0 and -5 or 5)
    
    timer.Simple(0.8, function()
        if IsValid(self) then
            self.IsPeeking = false
            self:ResetLean()
        end
    end)
end

function ENT:CustomOnThink_AIEnabled()
    if not self.IsSuspect then return end
    
    if CurTime() > (self.NextSquadUpdate or 0) then
        self:CoordinateWithSquad()
        self.NextSquadUpdate = CurTime() + 2
    end
    
    if self.TeamRole == "leader" and CurTime() > (self.NextTacticalDecision or 0) then
        self:PlanSquadTactics()
        self.NextTacticalDecision = CurTime() + 1
    end
    
    self:CheckAmbushBehavior()
end

function ENT:CoordinateWithSquad()
    if not self.IsSuspect or self.IsCivilian or self.IsHostage then return end
    
    local squadMembers = {}
    local nearby = self:GetCachedNearbyEnts("npc", 800)
    
    for _, ent in pairs(nearby) do
        if IsValid(ent) and ent ~= self and ent:GetClass() == self:GetClass() and ent.IsSuspect and not ent.Dead and not ent.Surrendering then
            table.insert(squadMembers, ent)
        end
    end
    
    self.SquadMembers = squadMembers
    
    if #squadMembers == 0 then
        self.TeamRole = "solo"
        self.SquadLeader = nil
        return
    end
    
    if IsValid(self.SquadLeader) then
        local leader = self.SquadLeader
        if leader.Dead or leader.Surrendering or self:GetPos():Distance(leader:GetPos()) > 1000 then
            self.SquadLeader = nil
        end
    end

    if not IsValid(self.SquadLeader) then
        for _, member in pairs(squadMembers) do
            if member.TeamRole == "leader" then
                self.SquadLeader = member
                break
            end
        end
        
        if not IsValid(self.SquadLeader) then
             -- Simple election: Aggressive personality first, then anyone
            if self.Personality == PERSONALITY_AGGRESSIVE then
                self:AssignSquadLeader(self)
            else
                 -- Wait for someone else to claim or claim if critical
                 if math.random(1, 20) == 1 then
                    self:AssignSquadLeader(self)
                 end
            end
        end
    end
    
    -- Assign role relative to leader if I am not leader
    if IsValid(self.SquadLeader) and self.SquadLeader ~= self then
        self.TeamRole = "follower" -- simplified, leader will assign specific roles
    end
end

function ENT:AssignSquadLeader(ent)
    self.SquadLeader = ent
    self.TeamRole = (ent == self) and "leader" or "follower"
    if ent == self then
        -- I am the captain now
        for _, member in pairs(self.SquadMembers) do
            if IsValid(member) then
                member.SquadLeader = self
                member.TeamRole = "follower"
            end
        end
    end
end

function ENT:PlanSquadTactics()
    if not self.SquadMembers or #self.SquadMembers == 0 then return end
    
    local enemy = self:GetEnemy()
    if not IsValid(enemy) then return end
    
    -- Assign roles dynamically based on situation
    local suppressors = {}
    local flankers = {}
    
    for _, member in pairs(self.SquadMembers) do
        if not IsValid(member) or member == self then continue end
        
        -- Improve role assignment logic
        if member:Visible(enemy) and member:GetPos():Distance(enemy:GetPos()) < 1000 then
            table.insert(suppressors, member)
        else
            table.insert(flankers, member)
        end
    end
    
    -- Orders
    if #suppressors > 0 then
        local suppressor = suppressors[math.random(1, #suppressors)]
        suppressor:ExecuteSquadTactic("suppress", enemy)
    end
    
    if #flankers > 0 then
         for _, flanker in pairs(flankers) do
             if math.random(1, 3) == 1 then -- Don't move everyone at once
                 flanker:ExecuteSquadTactic("flank", enemy)
             end
         end
    end
    
    -- Leader also acts
    if self:Visible(enemy) then
        self:ExecuteSquadTactic("suppress", enemy)
    end
end

function ENT:ExecuteSquadTactic(tactic, target)
    if not IsValid(target) then return end
    
    if tactic == "flank" then
        if self.IsPeeking or self.IsHoldingAngle then return end
        local flankPos = self:GetFlankPosition(target)
        if flankPos then
            self:SetLastPosition(flankPos)
            self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH")
        end
    elseif tactic == "suppress" then
        self:StartSuppressingFire(target:GetPos())
    end
end

function ENT:GetFlankPosition(target)
    if not IsValid(target) then return nil end
    local targetPos = target:GetPos()
    
    -- Try to find a position using nodegraph that is behind or to the side of the enemy
    -- And preferably hidden from the enemy's view UNTIL we get there
    
    if MuR and MuR.GetRandomPos then
         -- Try 3 times to find a good flank spot
         for i=1, 3 do
             local pos = MuR:GetRandomPos(false, targetPos, 500, 1500, true) -- true = visible to player? No wait.
             -- MuR:GetRandomPos(underroof, frompos, mindist, maxdist, withoutply)
             -- We want 'withoutply' to be false if we WANT to be visible?
             -- looking at sv_nodegraph.lua:
             -- if not withoutply then check visibility...
             -- if is_visible then visible_nodes else hidden_nodes
             
             -- We actually want a position that is NOT visible to the player initially if flanking?
             -- Actually, simple flank: just get to the side.
             
            if pos and pos ~= Vector(0,0,0) then
                local toPos = (pos - targetPos):GetNormalized()
                local toMe = (self:GetPos() - targetPos):GetNormalized()
                
                -- IF dot product is negative, it's behind the enemy relative to me?
                -- Or check angle difference.
                -- We want an angle > 45 degrees from current position relative to enemy
                
                local dot = toPos:Dot(toMe)
                if dot < 0.5 then -- At least 60 degrees away
                    return pos
                end
            end
         end
    end

    -- Fallback to geometric calculation if nodes fail
    local myPos = self:GetPos()
    local toEnemy = (targetPos - myPos):GetNormalized()
    local flankDir = toEnemy:Cross(Vector(0, 0, 1))
    
    if math.random(1, 2) == 1 then flankDir = -flankDir end
    
    -- Trace to ensure we don't run into a wall immediately
    local testPos = targetPos + flankDir * 500
    local tr = util.TraceLine({
        start = targetPos + Vector(0,0,50),
        endpos = testPos + Vector(0,0,50),
        mask = MASK_NPCSOLID
    })
    
    return tr.HitPos
end

function ENT:StartSuppressingFire(targetPos)
    if self.Surrendering then return end
    
    local wep = self:GetActiveWeapon()
    if not IsValid(wep) or wep:Clip1() < 10 then return end
    
    local fireDir = (targetPos - self:EyePos()):GetNormalized()
    self:SetAngles(fireDir:Angle())
    
    timer.Create("SuppressFire" .. self:EntIndex(), 0.15, 20, function()
        if not IsValid(self) or not IsValid(wep) or wep:Clip1() <= 0 then
            timer.Remove("SuppressFire" .. self:EntIndex())
            return
        end
        
        local spread = VectorRand() * 0.1
        self:SetAngles((fireDir + spread):Angle())
        wep:PrimaryAttack()
    end)
end

function ENT:FindAmbushPosition()
    -- Try to find a tactically advantageous position (partial cover)
    local myPos = self:GetPos()
    local bestPos = nil
    local bestScore = -1
    
    for i = 1, 10 do
        local randVec = VectorRand() * math.random(200, 800)
        randVec.z = 0
        local testPos = myPos + randVec
        
        -- Drop to floor
        local tr = util.TraceLine({
            start = testPos + Vector(0,0,50),
            endpos = testPos - Vector(0,0,200),
            mask = MASK_NPCSOLID
        })
        
        if tr.Hit then
            testPos = tr.HitPos
            
            -- Analyze position
            -- We want a spot with:
            -- 1. Some cover (objects nearby)
            -- 2. Some visibility (not stuck in a closet)
            
            local blockedCount = 0
            local openCount = 0
            
            for ang = 0, 315, 45 do
                local rad = math.rad(ang)
                local dir = Vector(math.cos(rad), math.sin(rad), 0)
                
                local coverTr = util.TraceLine({
                    start = testPos + Vector(0,0,40),
                    endpos = testPos + dir * 100 + Vector(0,0,40),
                    mask = MASK_SHOT
                })
                
                if coverTr.Hit then
                    blockedCount = blockedCount + 1
                else
                    openCount = openCount + 1
                end
            end
            
            -- Ideal ambush: 3-5 sides blocked (corner/wall), 3-5 sides open
            if blockedCount >= 3 and openCount >= 2 then
                -- Check if we can stand there
                local hullTr = util.TraceHull({
                    start = testPos + Vector(0,0,2),
                    endpos = testPos + Vector(0,0,72),
                    mins = Vector(-16,-16,0),
                    maxs = Vector(16,16,0),
                    mask = MASK_NPCSOLID
                })
                
                if not hullTr.Hit then
                    local score = blockedCount -- Prefer more cover
                    if score > bestScore then
                        bestScore = score
                        bestPos = testPos
                    end
                end
            end
        end
    end
    
    return bestPos
end

function ENT:CheckAmbushBehavior()
    -- Triggered if we are idle/wandering restricted OR lost enemy
    if self.IsHostage or self.IsCivilian then return end
    if self.Surrendering then return end
    if self.MovedToAmbush then return end
    
    local enemy = self:GetEnemy()
    local shouldAmbush = false
    
    if self.DisableWandering then
        shouldAmbush = true
    elseif IsValid(enemy) and not self:Visible(enemy) and not self.ChaseEnemyAlways then
        -- Lost visual and not a chaser
        shouldAmbush = true
    elseif self.Awareness == AWARENESS_ALERTED and not IsValid(enemy) then
         -- Alerted but no target
         shouldAmbush = true
    end
    
    if shouldAmbush then
        local ambushPos = self:FindAmbushPosition()
        if ambushPos then
            self:SetLastPosition(ambushPos)
            self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH")
            self.MovedToAmbush = true
            
            -- Reset flag after a while so we can move again if needed
            timer.Simple(15, function()
                if IsValid(self) then self.MovedToAmbush = false end
            end)
        end
    end
end

function ENT:CheckDoorAmbush()
    if self.CombatStance ~= STANCE_AMBUSH then return end
    if self.IsHoldingAngle then return end
    
    local nearbyDoors = ents.FindInSphere(self:GetPos(), 300)
    
    for _, door in pairs(nearbyDoors) do
        if IsValid(door) and door:GetClass():find("door") then
            local doorPos = door:GetPos()
            local toMe = (self:GetPos() - doorPos):GetNormalized()
            
            local ambushPos = doorPos + toMe * 150
            local ambushDir = -toMe
            
            local tr = util.TraceLine({
                start = ambushPos + Vector(0, 0, 32),
                endpos = doorPos + Vector(0, 0, 32),
                filter = self,
                mask = MASK_SHOT
            })
            
            if not tr.Hit or tr.Entity == door then
                self:StartHoldingAngle(ambushPos, ambushDir)
                
                self.DoorMemory[door:EntIndex()] = {
                    pos = doorPos,
                    watching = true
                }
                
                return
            end
        end
    end
end

function ENT:ReactToDoorOpening(door)
    if not IsValid(door) then return end
    if self.Surrendering then return end
    
    local doorPos = door:GetPos()
    local dist = self:GetPos():Distance(doorPos)
    
    if dist > 400 then return end
    
    self:SetAwareness(AWARENESS_ALERTED)
    
    if self.DoorMemory[door:EntIndex()] and self.DoorMemory[door:EntIndex()].watching then
        if self.Personality == PERSONALITY_AGGRESSIVE then
            local fireDir = (doorPos - self:EyePos()):GetNormalized()
            self:SetAngles(fireDir:Angle())
            
            local wep = self:GetActiveWeapon()
            if IsValid(wep) and wep:Clip1() > 0 then
                timer.Simple(self.ReactionTime or 0.3, function()
                    if IsValid(self) and IsValid(wep) then
                        wep:PrimaryAttack()
                    end
                end)
            end
        end
    else
        self:AddSuspiciousPosition(doorPos)
    end
end

function ENT:AddSuspiciousPosition(pos)
    table.insert(self.SuspiciousPositions, pos)
    if #self.SuspiciousPositions > 5 then
        table.remove(self.SuspiciousPositions, 1)
    end
    
    if self.Awareness < AWARENESS_SUSPICIOUS then
        self:SetAwareness(AWARENESS_SUSPICIOUS)
    end
end

function ENT:PreFireWarningShot()
    if not self.PreFireWarning then return false end
    if self.Awareness == AWARENESS_COMBAT then return false end
    
    local enemy = self:GetEnemy()
    if not IsValid(enemy) or not enemy:IsPlayer() then return false end
    
    if self:CanPlayVox("contact") then
        self:PlayVox(self.SoundTbl_Contact, 90)
        self:SetVoxCooldown("contact", 15)
    end
    
    local wep = self:GetActiveWeapon()
    if IsValid(wep) and wep:Clip1() > 0 then
        local ceilingDir = Vector(0, 0, 1) + VectorRand() * 0.2
        self:SetAngles(ceilingDir:Angle())
        
        timer.Simple(0.3, function()
            if IsValid(self) and IsValid(wep) then
                wep:PrimaryAttack()
            end
        end)
    end
    
    self.PreFireWarning = false
    
    timer.Simple(1.5, function()
        if IsValid(self) and IsValid(enemy) and not self.Surrendering then
            self:SetAwareness(AWARENESS_COMBAT)
        end
    end)
    
    return true
end

function ENT:PlayVox(tbl, vol)
    if not tbl or #tbl == 0 then return end
    local snd = VJ_PICK(tbl)
    if snd then
        sound.Play(snd, self:GetPos(), vol or 70, math.random(95, 105), 1)
    end
end

function ENT:CanPlayVox(voxType)
    local cooldown = self.NextVoxCooldowns[voxType] or 0
    return CurTime() > cooldown
end

function ENT:SetVoxCooldown(voxType, time)
    self.NextVoxCooldowns[voxType] = CurTime() + (time or 5)
end

function ENT:UpdateMorale()
    if self.IsCivilian or self.IsHostage then return end
    if CurTime() < self.NextMoraleUpdate then return end
    
    self.NextMoraleUpdate = CurTime() + 1
    
    local allies = 0
    local enemies = 0
    
    for _, ent in pairs(ents.FindInSphere(self:GetPos(), 800)) do
        if ent ~= self then
            if ent:GetClass() == self:GetClass() and ent:Health() > 0 then
                if ent.IsSuspect and self:Visible(ent) then
                    allies = allies + 1
                end
            elseif ent:IsPlayer() and ent:Alive() then
                if self:Visible(ent) then
                    enemies = enemies + 1
                end
            end
        end
    end
    
    self.MoraleFactors.allies_nearby = allies
    self.MoraleFactors.enemies_nearby = enemies
    self.MoraleFactors.health_ratio = self:Health() / self:GetMaxHealth()
    self.MoraleFactors.suppression = self.SuppressionLevel / self.MaxSuppression
    
    local score = 2
    
    score = score + (allies * 0.5) -- Increased ally bonus
    score = score + (self.MoraleFactors.health_ratio * 0.6)
    
    score = score - (math.min(enemies, 3) * 0.2) -- Reduced enemy penalty
    score = score - (self.MoraleFactors.witnessed_deaths * 0.2) -- Reduced death penalty
    score = score - (self.MoraleFactors.suppression * 0.7) -- Reduced suppression penalty
    
    if self.Personality == PERSONALITY_AGGRESSIVE then
        score = score + 0.8
    elseif self.Personality == PERSONALITY_COWARD then
        score = score - 0.6
    end
    
    local oldMorale = self.Morale
    
    if score >= 2.5 then
        self.Morale = MORALE_HIGH
    elseif score >= 1.5 then
        self.Morale = MORALE_NORMAL
    elseif score >= 0.5 then
        self.Morale = MORALE_LOW
    else
        self.Morale = MORALE_BROKEN
    end
    
    if oldMorale ~= self.Morale then
        self:OnMoraleChanged(oldMorale, self.Morale)
    end
end

function ENT:OnMoraleChanged(oldMorale, newMorale)
    if newMorale == MORALE_BROKEN and not self.Surrendering then
        if math.random(1, 100) <= 70 then
            self:TrySurrender(true)
        else
            self:StartPanic()
        end
    elseif newMorale == MORALE_LOW and oldMorale > MORALE_LOW then
        self.TakeOnSightBeforeShoot = true
    end
end

function ENT:AddSuppression(amount)
    self.SuppressionLevel = math.Clamp(self.SuppressionLevel + amount, 0, self.MaxSuppression)
    self.LastSuppressionTime = CurTime()
    
    if self.SuppressionLevel > 60 then
        self.Weapon_Accuracy = (self.AccuracyMod or 1) * 0.4
    elseif self.SuppressionLevel > 30 then
        self.Weapon_Accuracy = (self.AccuracyMod or 1) * 0.7
    end
    
    if self.SuppressionLevel >= 80 and not self.Surrendering then
        if math.random(1, 100) <= 40 then
            self:TrySurrender(false)
        end
    end
end

function ENT:ReduceSuppression()
    if CurTime() - self.LastSuppressionTime > 2 then
        self.SuppressionLevel = math.max(0, self.SuppressionLevel - 8)
        
        if self.SuppressionLevel < 20 then
            self.Weapon_Accuracy = self.AccuracyMod or 1
        end
    end
end

function ENT:TrySurrender(forced, attacker)
    if self.Surrendering then return end
    if self.IsCivilian then return end
    
    local chance = self.BaseSurrenderChance or 30
    
    if forced then
        chance = chance + 50
    end
    
    if self.Morale == MORALE_BROKEN then
        chance = chance + 40
    elseif self.Morale == MORALE_LOW then
        chance = chance + 20
    end
    
    if self:Health() < self:GetMaxHealth() * 0.3 then
        chance = chance + 30
    elseif self:Health() < self:GetMaxHealth() * 0.5 then
        chance = chance + 15
    end
    
    if self.MoraleFactors.allies_nearby == 0 then
        chance = chance + 25
    end
    
    if self.MoraleFactors.enemies_nearby >= 2 then
        chance = chance + 20
    end
    
    if self.SuppressionLevel > 50 then
        chance = chance + 15
    end
    
    local nearbyPolice = self:CountNearbyPolice(300)
    if nearbyPolice >= 2 then
        chance = chance + 25
    elseif nearbyPolice >= 1 then
        chance = chance + 10
    end
    
    chance = math.min(chance, 95)
    
    if math.random(1, 100) <= chance then
        self:StartSurrender(attacker)
    end
end

function ENT:StartSurrender(attacker)
    self.Surrendering = true
    self.SurrenderAnimStarted = false
    self.SurrenderStartTime = CurTime()
    self.UnsurrenderTime = CurTime() + math.random(8, 20)
    
    self.FakeSurrendering = self:ShouldFakeSurrender()
    
    if self.FakeSurrendering then
        self.FakeSurrenderWindow = CurTime() + math.random(5, 15)
    end
    
    if IsValid(attacker) then
        self:ForceSetEnemy(attacker)
    end
    
    if self.IsCivilian and self.IsHiddenSuspect then
        self:OnCivilianSurrender(attacker)
    end
    
    if not self.IsCallingReaction then
        self.IsCallingReaction = true
        self:CallAllyReaction(self.FakeSurrendering and "fake_surrender" or "surrender")
        self.IsCallingReaction = false
    end
end

function ENT:ShouldFakeSurrender()
    if self.Personality == PERSONALITY_COWARD then
        return math.random(1, 100) <= 10 -- Increased from 5
    end
    
    local chance = (self.FakeSurrenderChance or 15) + 15 -- Increased base chance
    
    if self.MoraleFactors.allies_nearby > 0 then
        chance = chance + 15 -- Increased bonus
    end
    
    if self.Morale == MORALE_BROKEN then
        chance = math.max(10, chance - 15) -- Reduced penalty
    elseif self.Morale == MORALE_LOW then
        chance = math.max(15, chance - 5) -- Reduced penalty
    end
    
    local nearbyPolice = self:CountNearbyPolice(200)
    if nearbyPolice >= 2 then
        chance = math.max(5, chance - 10) -- Reduced penalty
    end
    
    return math.random(1, 100) <= chance
end

function ENT:SurrenderThink()
    if not self.Surrendering then
        self.VJ_NPC_Class = self.IsSuspect and {"CLASS_BLOODSHED_SUSPECT"} or {"CLASS_BLOODSHED_CIVILIAN"}
        return
    end
    
    self.VJ_NPC_Class = {"CLASS_BLOODSHED_SUSPECT", "CLASS_BLOODSHED_CIVILIAN"}
    
    if not self.SurrenderAnimStarted then
        self.SurrenderAnimStarted = true
        
        local nearestPly = self:GetNearestPlayer()
        if IsValid(nearestPly) then
            local ang = (nearestPly:GetPos() - self:GetPos()):Angle()
            self:SetAngles(Angle(0, ang.y, 0))
        end
        
        self:SetState(VJ_STATE_FREEZE)
        
        if self:CanPlayVox("surrender") then
            self:PlayVox(self.SoundTbl_Surrender, 75)
            self:SetVoxCooldown("surrender", 8)
        end
        
        local anim = "sequence_ron_comply_start_0" .. math.random(1, 4)
        if self:LookupSequence(anim) ~= -1 then
            self:PlayAnim("vjseq_" .. anim, true, false)
        else
            if self:LookupSequence("idle_all_scared") ~= -1 then
                self:PlayAnim("idle_all_scared", true, false)
            end
        end
        
        if IsValid(self:GetActiveWeapon()) and not self.NoWeapon then
            self.LastWeapon = self:GetActiveWeapon()
            self:DropWeapon(self.LastWeapon)
        end
    end
    
    if self.FakeSurrendering and not self.PermanentSurrender then
        self:FakeSurrenderThink()
    end
    
    if self.PermanentSurrender then
        self.UnsurrenderTime = CurTime() + 10
        return
    end
    
    if self:IsPoliceNearby(true) then
        self.UnsurrenderTime = CurTime() + math.random(5, 12)
    end
    
    if CurTime() > self.UnsurrenderTime then
        self:EndSurrender()
    end
end

function ENT:FakeSurrenderThink()
    if CurTime() < self.FakeSurrenderWindow then return end
    
    local nearestPly = self:GetNearestPlayer()
    if not IsValid(nearestPly) then return end
    
    local dist = self:GetPos():Distance(nearestPly:GetPos())
    local isLooking = self:IsPlayerLookingAtMe(nearestPly)
    
    local attackChance = 0
    
    if dist < 100 and not isLooking then
        attackChance = 80
    elseif dist < 150 and not isLooking then
        attackChance = 50
    elseif dist > 400 then
        attackChance = 30
    elseif not isLooking then
        attackChance = 20
    end
    
    if self.MoraleFactors.allies_nearby > 0 then
        attackChance = attackChance + 15
    end
    
    local playerWep = nearestPly:GetActiveWeapon()
    if IsValid(playerWep) then
        local clip = playerWep:Clip1()
        local wepClass = playerWep:GetClass()
        local isFirearm = wepClass:find("tfa_") or wepClass:find("weapon_") or wepClass:find("m9k_")
        
        if clip < 1 then
            attackChance = attackChance + 25
        end
        
        if not isFirearm or wepClass:find("knife") or wepClass:find("melee") or wepClass:find("baton") then
            attackChance = attackChance + 20
        end
    else
        attackChance = attackChance + 30
    end
    
    if math.random(1, 100) <= attackChance then
        timer.Simple(math.Rand(0.3, 1.0), function()
            if IsValid(self) and self.Surrendering then
                self:ExecuteFakeSurrender()
            end
        end)
    end
end

function ENT:ExecuteFakeSurrender()
    self:CallAllyReaction("attack_from_surrender")
    
    self.VJ_NPC_Class = {"CLASS_BLOODSHED_SUSPECT"}
    self.Surrendering = false
    self.SurrenderAnimStarted = false
    self.FakeSurrendering = false
    self.TakeOnSightBeforeShoot = false
    
    self:SetState(VJ_STATE_NONE)
    self:PlayAnim("vjseq_zombie_slump_rise_02_fast", true, 0.5, true, 0, {PlayBackRate = 2})
    self:SetCycle(0.2)
    
    local hiddenWeapon = math.random(1, 2) == 1 and "weapon_vj_bloodshed_sus_melee" or "weapon_vj_bloodshed_sus_secondary"
    self:Give(hiddenWeapon)
    
    if IsValid(self.LastWeapon) then
        self.LastWeapon:Remove()
    end
    
    self:EmitSound("weapons/slide_pull.wav", 60, 100)
end

function ENT:EndSurrender()
    if not self.Surrendering then return end
    if self.PermanentSurrender then return end
    
    self.Surrendering = false
    self.SurrenderAnimStarted = false
    self.FakeSurrendering = false
    
    self:SetState(VJ_STATE_NONE)
    
    local exitAnim = "sequence_ron_comply_exit_0" .. math.random(1, 3)
    if self:LookupSequence(exitAnim) ~= -1 then
        self:PlayAnim("vjseq_" .. exitAnim, true, false)
    end
    
    if IsValid(self.LastWeapon) then
        self:Give(self.LastWeapon:GetClass())
        self.LastWeapon:Remove()
    end
end

function ENT:IsPlayerLookingAtMe(ply)
    if not IsValid(ply) then return false end
    
    local plyDir = ply:GetAimVector()
    local toMe = (self:GetPos() - ply:GetPos()):GetNormalized()
    
    return plyDir:Dot(toMe) > 0.7
end

function ENT:CountNearbyPolice(radius)
    local count = 0
    for _, ply in pairs(player.GetAll()) do
        if ply:Alive() and self:GetPos():Distance(ply:GetPos()) < radius then
            count = count + 1
        end
    end
    return count
end

function ENT:IsPoliceNearby(visible)
    for _, ply in pairs(player.GetAll()) do
        if ply:Alive() then
            local dist = self:GetPos():Distance(ply:GetPos())
            if visible then
                if dist < 400 and self:Visible(ply) then
                    return true
                end
            else
                if dist < 150 then
                    return true
                end
            end
        end
    end
    return false
end

function ENT:GetNearestPlayer()
    local nearest = nil
    local minDist = math.huge
    
    for _, ply in pairs(player.GetAll()) do
        if ply:Alive() then
            local dist = self:GetPos():Distance(ply:GetPos())
            if dist < minDist then
                minDist = dist
                nearest = ply
            end
        end
    end
    
    return nearest
end

function ENT:TryPlaceTrap()
    if not self.CanSetTraps then return end
    if self.TrapsPlaced >= self.MaxTraps then return end
    if CurTime() < self.NextTrapTime then return end
    if IsValid(self:GetEnemy()) and self:Visible(self:GetEnemy()) then return end
    if self.Surrendering then return end
    
    self:UpdateEnemyPathMemory()
    
    local trapData = self:FindOptimalTrapPosition()
    if not trapData then return end
    
    if self.LastTrapPos and trapData.pos:Distance(self.LastTrapPos) < 400 then
        return
    end
    
    self:PlaceTrap(trapData.pos, trapData.door, trapData.type)
    self.TrapsPlaced = self.TrapsPlaced + 1
    self.LastTrapPos = trapData.pos
    self.NextTrapTime = CurTime() + math.random(30, 60)
    
    self.TrapMemory[#self.TrapMemory + 1] = {
        pos = trapData.pos,
        time = CurTime(),
        door = trapData.door,
        score = trapData.score
    }
end

function ENT:UpdateEnemyPathMemory()
    local enemy = self:GetEnemy()
    if not IsValid(enemy) then return end
    
    local enemyPos = enemy:GetPos()
    
    if #self.EnemyPathMemory == 0 or self.EnemyPathMemory[#self.EnemyPathMemory].pos:Distance(enemyPos) > 100 then
        table.insert(self.EnemyPathMemory, {
            pos = enemyPos,
            time = CurTime()
        })
        
        if #self.EnemyPathMemory > 20 then
            table.remove(self.EnemyPathMemory, 1)
        end
    end
    
    self:AnalyzeHighTrafficAreas()
end

function ENT:AnalyzeHighTrafficAreas()
    self.HighTrafficAreas = {}
    
    local grid = {}
    local cellSize = 200
    
    for _, pathData in ipairs(self.EnemyPathMemory) do
        local cellX = math.floor(pathData.pos.x / cellSize)
        local cellY = math.floor(pathData.pos.y / cellSize)
        local key = cellX .. "_" .. cellY
        
        grid[key] = (grid[key] or 0) + 1
    end
    
    for key, count in pairs(grid) do
        if count >= 3 then
            local coords = string.Explode("_", key)
            local x = tonumber(coords[1]) * cellSize + cellSize / 2
            local y = tonumber(coords[2]) * cellSize + cellSize / 2
            
            table.insert(self.HighTrafficAreas, {
                pos = Vector(x, y, 0),
                traffic = count
            })
        end
    end
end

function ENT:FindOptimalTrapPosition()
    local candidates = {}
    local myPos = self:GetPos()
    local enemy = self:GetEnemy()
    
    local doors = self:GetCachedNearbyEnts("door", 600)
    
    for _, door in pairs(doors) do
        if IsValid(door) and not door.IsTrapped then
            local doorPos = door:GetPos()
            local dist = myPos:Distance(doorPos)
            
            if dist > 100 and dist < 600 then
                local score = self:EvaluateTrapPosition(doorPos, door)
                
                if score > 30 then
                    table.insert(candidates, {
                        pos = doorPos,
                        door = door,
                        score = score,
                        type = self:DetermineTrapType(doorPos, door)
                    })
                end
            end
        end
    end
    
    if #candidates == 0 then return nil end
    if #candidates == 1 then return candidates[1] end
    
    table.sort(candidates, function(a, b) return a.score > b.score end)
    
    local topCount = math.min(3, #candidates)
    return candidates[math.random(1, topCount)]
end

function ENT:EvaluateTrapPosition(pos, door)
    local score = 0
    local myPos = self:GetPos()
    local dist = myPos:Distance(pos)
    
    if dist > 600 then return 0 end
    if dist < 100 then return 0 end
    
    score = score + (600 - dist) / 10
    
    local enemy = self:GetEnemy()
    if IsValid(enemy) then
        local enemyPos = enemy:GetPos()
        local enemyDist = enemyPos:Distance(pos)
        
        if enemyDist < dist then
            score = score + 40
        end
        
        if enemyDist < 300 then
            score = score + 30
        end
        
        for _, pathData in ipairs(self.EnemyPathMemory) do
            if pathData.pos:Distance(pos) < 250 then
                score = score + 15
            end
        end
        
        local predictedPath = self:PredictEnemyPath()
        if predictedPath then
            local predictDist = predictedPath:Distance(pos)
            if predictDist < 200 then
                score = score + 60
            elseif predictDist < 400 then
                score = score + 30
            end
        end
        
        local enemyVel = enemy:GetVelocity()
        if enemyVel:Length() > 100 then
            local enemyDir = enemyVel:GetNormalized()
            local toTrap = (pos - enemyPos):GetNormalized()
            local alignment = enemyDir:Dot(toTrap)
            
            if alignment > 0.7 then
                score = score + 45
            elseif alignment > 0.3 then
                score = score + 20
            end
        end
    end
    
    for _, area in ipairs(self.HighTrafficAreas) do
        local areaDist = area.pos:Distance(pos)
        if areaDist < 300 then
            score = score + (area.traffic * 10) * (1 - areaDist / 300)
        end
    end
    
    if self:IsChokepointDoor(door) then
        score = score + 50
    end
    
    if self:IsRetreatPath(pos) then
        score = score + 35
    end
    
    if self:HasCoverNearby(pos, 150) then
        score = score + 25
    end
    
    if self:IsNarrowPassage(pos) then
        score = score + 30
    end
    
    if self:IsOpenSpace(pos) then
        score = score + 40
    else
        score = score - 50
    end
    
    if self:IsCorridorCenter(pos) then
        score = score + 50
    end
    
    local connectionScore = self:EvaluateDoorConnections(door)
    score = score + connectionScore
    
    for i = math.max(1, #self.TrapMemory - 5), #self.TrapMemory do
        local trapData = self.TrapMemory[i]
        local trapDist = trapData.pos:Distance(pos)
        if trapDist < 400 then
            score = score - 30
        end
    end
    
    if self.SquadMembers and #self.SquadMembers > 0 then
        for _, ally in pairs(self.SquadMembers) do
            if IsValid(ally) and ally.LastTrapPos and ally.LastTrapPos:Distance(pos) < 300 then
                score = score - 20
            end
        end
    end
    
    return score
end

function ENT:IsChokepointDoor(door)
    if not IsValid(door) then return false end
    
    local doorPos = door:GetPos()
    local nearbyDoors = 0
    
    for _, otherDoor in pairs(ents.FindInSphere(doorPos, 400)) do
        if IsValid(otherDoor) and otherDoor ~= door and otherDoor:GetClass():find("door") then
            nearbyDoors = nearbyDoors + 1
        end
    end
    
    return nearbyDoors <= 1
end

function ENT:IsRetreatPath(pos)
    local myPos = self:GetPos()
    local enemy = self:GetEnemy()
    if not IsValid(enemy) then return false end
    
    local toPos = (pos - myPos):GetNormalized()
    local toEnemy = (enemy:GetPos() - myPos):GetNormalized()
    
    return toPos:Dot(toEnemy) < -0.3
end

function ENT:HasCoverNearby(pos, radius)
    local coverCount = 0
    
    for angle = 0, 270, 90 do
        local rad = math.rad(angle)
        local dir = Vector(math.cos(rad), math.sin(rad), 0)
        
        local tr = util.TraceLine({
            start = pos + Vector(0, 0, 32),
            endpos = pos + Vector(0, 0, 32) + dir * radius,
            mask = MASK_SOLID_BRUSHONLY
        })
        
        if tr.Hit and tr.Fraction < 0.6 then
            coverCount = coverCount + 1
        end
    end
    
    return coverCount >= 2
end

function ENT:IsCorridorCenter(pos)
    local distances = {}
    
    for angle = 0, 270, 90 do
        local rad = math.rad(angle)
        local dir = Vector(math.cos(rad), math.sin(rad), 0)
        
        local tr = util.TraceLine({
            start = pos + Vector(0, 0, 32),
            endpos = pos + Vector(0, 0, 32) + dir * 200,
            mask = MASK_SOLID_BRUSHONLY
        })
        
        if tr.Hit then
            table.insert(distances, tr.Fraction * 200)
        end
    end
    
    if #distances < 2 then return false end
    
    local minDist = math.huge
    local maxDist = 0
    for _, dist in ipairs(distances) do
        minDist = math.min(minDist, dist)
        maxDist = math.max(maxDist, dist)
    end
    
    local variance = maxDist - minDist
    
    return variance < 60 and minDist > 60
end

function ENT:EvaluateDoorConnections(door)
    if not IsValid(door) then return 0 end
    
    local doorPos = door:GetPos()
    local score = 0
    local connections = 0
    
    for angle = 0, 315, 45 do
        local rad = math.rad(angle)
        local dir = Vector(math.cos(rad), math.sin(rad), 0)
        
        local tr = util.TraceLine({
            start = doorPos + Vector(0, 0, 32),
            endpos = doorPos + Vector(0, 0, 32) + dir * 500,
            mask = MASK_SOLID_BRUSHONLY
        })
        
        if not tr.Hit or tr.Fraction > 0.7 then
            connections = connections + 1
        end
    end
    
    if connections >= 2 and connections <= 4 then
        score = score + 20
    end
    
    return score
end

function ENT:GetCachedNearbyEnts(searchType, radius)
    local cacheKey = searchType .. "_" .. radius
    local cache = self.CachedNearbyEnts and self.CachedNearbyEnts[cacheKey]
    if not cache then
        self.CachedNearbyEnts = {}
    end
    
    if cache and CurTime() < cache.expires then
        return cache.ents
    end
    
    local found = {}
    local all = ents.FindInSphere(self:GetPos(), radius)
    
    for _, ent in pairs(all) do
        if searchType == "door" and IsValid(ent) and ent:GetClass():find("door") then
            table.insert(found, ent)
        elseif searchType == "npc" and IsValid(ent) and ent:IsNPC() then
            table.insert(found, ent)
        elseif searchType == "all" then
            table.insert(found, ent)
        end
    end
    
    self.CachedNearbyEnts[cacheKey] = {
        ents = found,
        expires = CurTime() + 1
    }
    
    return found
end

function ENT:DetermineTrapType(pos, door)
    local enemy = self:GetEnemy()
    
    if IsValid(enemy) then
        local enemyDist = enemy:GetPos():Distance(pos)
        
        if enemyDist < 400 then
            return "grenade"
        end
        
        local predictedPath = self:PredictEnemyPath()
        if predictedPath then
            local pathDist = predictedPath:Distance(pos)
            if pathDist < 300 then
                return "grenade"
            end
        end
    end
    
    if self:IsNarrowPassage(pos) then
        return math.random(1, 100) <= 60 and "grenade" or "beartrap"
    end
    
    local nearbyAllies = 0
    for _, ally in pairs(ents.FindInSphere(pos, 300)) do
        if ally ~= self and ally:GetClass() == self:GetClass() and ally.IsSuspect then
            nearbyAllies = nearbyAllies + 1
        end
    end
    
    if nearbyAllies > 0 then
        return "grenade"
    end
    
    return math.random(1, 100) <= 70 and "grenade" or "beartrap"
end

function ENT:PredictEnemyPath()
    if #self.EnemyPathMemory < 3 then return nil end
    
    local recent = {}
    for i = math.max(1, #self.EnemyPathMemory - 5), #self.EnemyPathMemory do
        table.insert(recent, self.EnemyPathMemory[i].pos)
    end
    
    local avgDir = Vector(0, 0, 0)
    for i = 1, #recent - 1 do
        avgDir = avgDir + (recent[i + 1] - recent[i]):GetNormalized()
    end
    avgDir = avgDir / (#recent - 1)
    
    local lastPos = recent[#recent]
    local predictedPos = lastPos + avgDir * 200
    
    return predictedPos
end

function ENT:ShouldCoordinateTrapPlacement()
    if not self.SquadMembers or #self.SquadMembers == 0 then return false end
    
    for _, ally in pairs(self.SquadMembers) do
        if IsValid(ally) and ally.CanSetTraps and ally.TrapsPlaced < ally.MaxTraps then
            return true
        end
    end
    
    return false
end

function ENT:GetAllyTrapPositions()
    local positions = {}
    
    for _, ally in pairs(ents.FindInSphere(self:GetPos(), 1000)) do
        if ally ~= self and ally:GetClass() == self:GetClass() and ally.IsSuspect then
            if ally.LastTrapPos then
                table.insert(positions, ally.LastTrapPos)
            end
            
            if ally.TrapMemory then
                for _, trapData in ipairs(ally.TrapMemory) do
                    table.insert(positions, trapData.pos)
                end
            end
        end
    end
    
    return positions
end

function ENT:FindNearbyDoorways(radius)
    local positions = {}
    local doors = ents.FindInSphere(self:GetPos(), radius)
    
    for _, door in pairs(doors) do
        if IsValid(door) and door:GetClass():find("door") then
            local doorPos = door:GetPos()
            local fwd = door:GetAngles():Forward()
            
            table.insert(positions, doorPos + fwd * 60)
            table.insert(positions, doorPos - fwd * 60)
        end
    end
    
    return positions
end

function ENT:FindNarrowSpots(radius)
    local positions = {}
    local myPos = self:GetPos()
    
    for angle = 0, 360, 45 do
        for dist = 150, radius, 100 do
            local rad = math.rad(angle)
            local testPos = myPos + Vector(math.cos(rad) * dist, math.sin(rad) * dist, 0)
            
            if self:IsNarrowPassage(testPos) then
                table.insert(positions, testPos)
            end
        end
    end
    
    return positions
end

function ENT:IsNarrowPassage(pos)
    local dirs = {
        {Vector(1, 0, 0), Vector(-1, 0, 0)},
        {Vector(0, 1, 0), Vector(0, -1, 0)}
    }
    
    for _, pair in pairs(dirs) do
        local tr1 = util.TraceLine({
            start = pos + Vector(0, 0, 32),
            endpos = pos + Vector(0, 0, 32) + pair[1] * 150,
            mask = MASK_SHOT
        })
        local tr2 = util.TraceLine({
            start = pos + Vector(0, 0, 32),
            endpos = pos + Vector(0, 0, 32) + pair[2] * 150,
            mask = MASK_SHOT
        })
        
        local width = (tr1.Fraction + tr2.Fraction) * 150
        if width > 60 and width < 200 then
            return true
        end
    end
    
    return false
end

function ENT:IsValidTrapSpot(pos)
    local floorTr = util.TraceLine({
        start = pos + Vector(0, 0, 50),
        endpos = pos - Vector(0, 0, 50),
        mask = MASK_SOLID_BRUSHONLY
    })
    
    if not floorTr.Hit or floorTr.HitNormal.z < 0.7 then
        return false
    end
    
    local nearbyTraps = ents.FindInSphere(pos, 150)
    for _, ent in pairs(nearbyTraps) do
        if ent:GetClass() == "trap_entity" or ent:GetClass() == "murwep_grenade" then
            return false
        end
    end
    
    local sphere = ents.FindInSphere(pos, 100)
    for _, ent in pairs(sphere) do
        if IsValid(ent) and (ent:GetClass():find("prop") or ent:IsPlayer() or ent:IsNPC()) then
            return false
        end
    end
    
    if not self:IsOpenSpace(pos) then
        return false
    end
    
    return true
end

function ENT:IsOpenSpace(pos)
    local openDirs = 0
    local closedDirs = 0
    
    for angle = 0, 270, 90 do
        local rad = math.rad(angle)
        local dir = Vector(math.cos(rad), math.sin(rad), 0)
        
        local tr = util.TraceLine({
            start = pos + Vector(0, 0, 32),
            endpos = pos + Vector(0, 0, 32) + dir * 120,
            mask = MASK_SOLID_BRUSHONLY
        })
        
        if not tr.Hit or tr.Fraction > 0.7 then
            openDirs = openDirs + 1
        else
            closedDirs = closedDirs + 1
        end
    end
    
    return openDirs >= 2
end

function ENT:PlaceTrap(pos, door, trapType)
    if not IsValid(door) then return end
    
    local doorPos = door:GetPos()
    local doorAng = door:GetAngles()
    local doorForward = doorAng:Forward()
    
    if trapType == "grenade" then
        self:PlaceTripwireTrap(doorPos + doorForward * 70)
    else
        local floorTr = util.TraceLine({
            start = doorPos + Vector(0, 0, 50),
            endpos = doorPos - Vector(0, 0, 100),
            mask = MASK_SOLID_BRUSHONLY
        })
        
        local floorHeight = floorTr.Hit and floorTr.HitPos.z or doorPos.z
        local trapPos = doorPos + doorForward * 50
        trapPos.z = floorHeight + 5
        
        local trap = ents.Create("trap_entity")
        if not IsValid(trap) then return end
        
        trap:SetPos(trapPos)
        trap:SetAngles(doorAng)
        trap:SetOwner(self)
        trap.AttachedDoor = door
        trap.IsTripwire = false
        trap:Spawn()
        
        door.IsTrapped = true
        door.TrapType = "beartrap"
    end
    
    self:EmitSound("weapons/slam/buttonclick.wav", 40, math.random(90, 110))
end

function ENT:TacticalThink()
    if self.Surrendering or self.IsPanicking then return end
    if self.IsCivilian or self.IsHostage then return end
    
    if self.InvestigatingSound then
        local doors = ents.FindInSphere(self:GetPos(), 150)
        for _, door in pairs(doors) do
            if IsValid(door) and door:GetClass():find("door") then
                local state = door:GetInternalVariable("m_eDoorState")
                if state == 0 then -- Door is closed
                    self.InvestigatingSound = false
                    break
                end
            end
        end
    end
    
    local enemy = self:GetEnemy()
    if not IsValid(enemy) then return end
    
    local dist = self:GetPos():Distance(enemy:GetPos())
    local visible = self:Visible(enemy)
    
    self.LastSawEnemyTime = visible and CurTime() or self.LastSawEnemyTime
    
    if self:ShouldRetreat() then
        self:StartRetreat(enemy)
        return
    end
    
    if self.Personality == PERSONALITY_AGGRESSIVE then
        if dist > 600 and visible then
            self:TacticalAdvance(enemy)
        end
    elseif self.Personality == PERSONALITY_CAUTIOUS then
        if dist < 200 then
            self:TacticalRetreat(enemy)
        elseif dist > 500 and self.MoraleFactors.allies_nearby > 0 then
            self:TacticalAdvance(enemy)
        end
    else
        if dist < 400 then
            self:TacticalRetreat(enemy)
        end
    end
end

function ENT:ShouldRetreat()
    if CurTime() - self.LastRetreatTime < 15 then return false end
    
    local chance = 0
    
    if self:Health() < self:GetMaxHealth() * 0.3 then
        chance = chance + 50
    elseif self:Health() < self:GetMaxHealth() * 0.5 then
        chance = chance + 25
    end
    
    if self.Morale == MORALE_BROKEN then
        chance = chance + 40
    elseif self.Morale == MORALE_LOW then
        chance = chance + 20
    end
    
    if self.MoraleFactors.enemies_nearby > self.MoraleFactors.allies_nearby + 1 then
        chance = chance + 30
    end
    
    if self.Personality == PERSONALITY_COWARD then
        chance = chance + 25
    elseif self.Personality == PERSONALITY_CAUTIOUS then
        chance = chance + 10
    end
    
    return math.random(1, 100) <= chance
end

function ENT:StartRetreat(enemy)
    if not IsValid(enemy) then return end
    
    self.IsRetreating = true
    self.LastRetreatTime = CurTime()
    self.InvestigatingSound = false -- Stop investigating sounds when retreating
    
    local retreatPos = self:FindRetreatPosition(enemy)
    if not retreatPos then return end
    
    self:SetLastPosition(retreatPos)
    self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH", function(x)
        x.CanShootWhenMoving = true
        x.TurnData = {Type = VJ.FACE_ENEMY}
        x.RunCode_OnFinish = function()
            self.IsRetreating = false
        end
    end)
    
    timer.Simple(1.5, function()
        if IsValid(self) then
            self:TryCloseDoor()
        end
    end)
end

function ENT:FindRetreatPosition(enemy)
    local myPos = self:GetPos()
    local enemyPos = enemy:GetPos()
    local retreatDir = (myPos - enemyPos):GetNormalized()
    
    local bestPos = nil
    local bestScore = -math.huge
    
    for i = 1, 8 do
        local angle = (i - 1) * 45 - 180
        local testDir = retreatDir:Angle()
        testDir:RotateAroundAxis(Vector(0, 0, 1), angle)
        
        for dist = 200, 500, 100 do
            local testPos = myPos + testDir:Forward() * dist
            
            local tr = util.TraceLine({
                start = myPos + Vector(0, 0, 32),
                endpos = testPos + Vector(0, 0, 32),
                filter = self,
                mask = MASK_NPCSOLID
            })
            
            if not tr.Hit then
                local score = self:EvaluateRetreatSpot(testPos, enemyPos)
                if score > bestScore then
                    bestScore = score
                    bestPos = testPos
                end
            end
        end
    end
    
    return bestPos
end

function ENT:EvaluateRetreatSpot(pos, enemyPos)
    local score = 0
    
    local dist = pos:Distance(enemyPos)
    score = score + dist * 0.1
    
    local coverTr = util.TraceLine({
        start = pos + Vector(0, 0, 32),
        endpos = enemyPos + Vector(0, 0, 32),
        mask = MASK_SHOT
    })
    
    if coverTr.Hit then
        score = score + 50
    end
    
    local nearbyDoors = ents.FindInSphere(pos, 100)
    for _, ent in pairs(nearbyDoors) do
        if ent:GetClass():find("door") then
            score = score + 30
            break
        end
    end
    
    return score
end

function ENT:TacticalAdvance(enemy)
    local coverPos = self:FindCoverPosition(enemy, true)
    if coverPos then
        self:SetLastPosition(coverPos)
        self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH", function(x)
            x.CanShootWhenMoving = true
            x.TurnData = {Type = VJ.FACE_ENEMY}
        end)
    end
end

function ENT:TacticalRetreat(enemy)
    local coverPos = self:FindCoverPosition(enemy, false)
    if coverPos then
        self:SetLastPosition(coverPos)
        self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH", function(x)
            x.CanShootWhenMoving = true
            x.TurnData = {Type = VJ.FACE_ENEMY}
        end)
    end
end

function ENT:FindCoverPosition(enemy, advancing)
    if not IsValid(enemy) then return nil end
    
    local myPos = self:GetPos()
    local enemyPos = enemy:GetPos()
    local direction = advancing and (enemyPos - myPos):GetNormalized() or (myPos - enemyPos):GetNormalized()
    
    local bestPos = nil
    local bestScore = -math.huge
    
    for i = 0, 7 do
        local angle = i * 45
        for dist = 100, 400, 75 do
            local offset = direction:Angle()
            offset:RotateAroundAxis(Vector(0, 0, 1), angle - 180)
            
            local testPos = myPos + offset:Forward() * dist
            
            local tr = util.TraceLine({
                start = myPos + Vector(0, 0, 32),
                endpos = testPos + Vector(0, 0, 32),
                filter = self,
                mask = MASK_NPCSOLID
            })
            
            if not tr.Hit then
                local score = self:EvaluateCoverSpot(testPos, enemyPos, advancing)
                if score > bestScore then
                    bestScore = score
                    bestPos = testPos
                end
            end
        end
    end
    
    return bestPos
end

function ENT:EvaluateCoverSpot(pos, enemyPos, advancing)
    local score = 0
    
    local coverTr = util.TraceLine({
        start = pos + Vector(0, 0, 32),
        endpos = enemyPos + Vector(0, 0, 32),
        filter = self,
        mask = MASK_SHOT
    })
    
    if coverTr.Hit then
        score = score + 80
    end
    
    local dist = pos:Distance(enemyPos)
    if advancing then
        score = score - dist * 0.05
    else
        score = score + dist * 0.08
    end
    
    local coverCount = 0
    for i = 0, 7 do
        local rad = math.rad(i * 45)
        local dir = Vector(math.cos(rad), math.sin(rad), 0)
        
        local tr = util.TraceLine({
            start = pos + Vector(0, 0, 32),
            endpos = pos + Vector(0, 0, 32) + dir * 80,
            mask = MASK_SHOT
        })
        
        if tr.Hit then
            coverCount = coverCount + 1
        end
    end
    
    score = score + coverCount * 10
    
    return score
end

function ENT:TryCloseDoor()
    local doors = ents.FindInSphere(self:GetPos(), 100)
    
    for _, door in pairs(doors) do
        if IsValid(door) and door:GetClass():find("door") then
            local state = door:GetInternalVariable("m_eDoorState")
            if state and state ~= 0 then
                door:Fire("Close", "", 0)
                
                if math.random(1, 100) <= 30 then
                    door:Fire("Lock", "", 0.5)
                end
                
                break
            end
        end
    end
end

function ENT:StartPanic()
    if self.IsPanicking then return end
    
    self.IsPanicking = true
    self.InvestigatingSound = false -- Stop investigating sounds when panicking
    self.PanicEndTime = CurTime() + math.random(4, 8)
    self.DisableChasingEnemy = true
    self.Weapon_Accuracy = (self.AccuracyMod or 1) * 0.2
    
    if self:CanPlayVox("fear") then
        self:PlayVox(self.SoundTbl_Fear, 80)
        self:SetVoxCooldown("fear", 10)
    end
    
    timer.Create("Panic" .. self:EntIndex(), 0.6, 0, function()
        if not IsValid(self) or CurTime() > self.PanicEndTime then
            timer.Remove("Panic" .. self:EntIndex())
            if IsValid(self) then
                self.IsPanicking = false
                self.DisableChasingEnemy = false
                self.Weapon_Accuracy = self.AccuracyMod or 1
            end
            return
        end
        
        local randomPos = self:GetPos() + Vector(math.random(-250, 250), math.random(-250, 250), 0)
        self:SetLastPosition(randomPos)
        self:VJ_TASK_GOTO_LASTPOS("TASK_RUN_PATH")
    end)
end

function ENT:CivilianThink()
    if not self.IsCivilian then return end
    if self.HasRevealed then return end
    if self.Surrendering then return end
    
    if self.IsHiddenSuspect then
        self:HiddenSuspectThink()
    end
    
    if self.FleeOnDanger then
        local nearestDanger = nil
        local minDist = self.FleeDistance
        
        for _, ply in pairs(player.GetAll()) do
            if ply:Alive() then
                local dist = self:GetPos():Distance(ply:GetPos())
                if dist < minDist then
                    local wep = ply:GetActiveWeapon()
                    if IsValid(wep) and wep:GetClass():find("tfa_bs_") then
                        minDist = dist
                        nearestDanger = ply
                    end
                end
            end
        end
        
        for _, npc in pairs(ents.FindInSphere(self:GetPos(), self.FleeDistance)) do
            if npc:GetClass() == self:GetClass() and npc.IsSuspect then
                if IsValid(npc:GetEnemy()) then
                    local dist = self:GetPos():Distance(npc:GetPos())
                    if dist < minDist then
                        minDist = dist
                        nearestDanger = npc
                    end
                end
            end
        end
        
        if nearestDanger and minDist < 500 then
            self:FleeFromDanger(nearestDanger)
        end
    end
end

function ENT:FleeFromDanger(danger)
    if not IsValid(danger) then return end
    
    local fleeDir = (self:GetPos() - danger:GetPos()):GetNormalized()
    local fleePos = self:GetPos() + fleeDir * math.random(300, 600)
    
    local tr = util.TraceLine({
        start = self:GetPos() + Vector(0, 0, 32),
        endpos = fleePos + Vector(0, 0, 32),
        filter = self,
        mask = MASK_NPCSOLID
    })
    
    if tr.Hit then
        fleePos = tr.HitPos - fleeDir * 50
    end
    
    self:SetLastPosition(fleePos)
    self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH")
    
    if self:CanPlayVox("fear") and math.random(1, 3) == 1 then
        self:PlayVox(self.SoundTbl_Fear, 75)
        self:SetVoxCooldown("fear", 8)
    end
    
    if self.IsHiddenSuspect and not self.HasRevealed then
        if self.BeenSpottedByPlayer and math.random(1, 4) == 1 then
            timer.Simple(math.Rand(0.5, 2), function()
                if IsValid(self) and not self.HasRevealed then
                    self:RevealAsHostile(danger)
                end
            end)
        end
    end
end

function ENT:HiddenSuspectThink()
    if not self.IsHiddenSuspect then return end
    if self.HasRevealed then return end
    
    local nearestPolice = nil
    local minDist = 600
    local wasSpotted = false
    
    for _, ply in pairs(player.GetAll()) do
        if ply:Alive() then
            local dist = self:GetPos():Distance(ply:GetPos())
            if dist < minDist then
                local tr = util.TraceLine({
                    start = ply:EyePos(),
                    endpos = self:EyePos(),
                    filter = {ply, self},
                    mask = MASK_PLAYERSOLID
                })
                
                if not tr.Hit then
                    minDist = dist
                    nearestPolice = ply
                    wasSpotted = true
                    
                    if not self.EverSpottedByPlayer then
                        self.EverSpottedByPlayer = true
                        self.SpottedTime = CurTime()
                    end
                end
            end
        end
    end
    
    if not self.EverSpottedByPlayer then return end
    if not IsValid(nearestPolice) then return end
    
    local isBeingWatched = self:IsPlayerLookingAtMe(nearestPolice)
    local dist = minDist
    local timeSinceSpotted = CurTime() - (self.SpottedTime or CurTime())
    
    local revealChance = 0
    
    if dist < 100 and not isBeingWatched then
        revealChance = 50
    elseif dist < 200 and not isBeingWatched then
        revealChance = 30
    elseif dist < 150 and isBeingWatched then
        revealChance = 20
    elseif timeSinceSpotted > 10 and dist < 300 then
        revealChance = 15
    end
    
    revealChance = revealChance + 10
    if isBeingWatched then
        revealChance = revealChance + 15
    end
    
    local playerWep = nearestPolice:GetActiveWeapon()
    if IsValid(playerWep) then
        local clip = playerWep:Clip1()
        local wepClass = playerWep:GetClass()
        local isFirearm = wepClass:find("tfa_") or wepClass:find("weapon_")
        
        if clip < 1 then
            revealChance = revealChance + 25
        end
        
        if not isFirearm or wepClass:find("knife") or wepClass:find("melee") or wepClass:find("baton") then
            revealChance = revealChance + 20
        end
    else
        revealChance = revealChance + 30
    end
    
    if math.random(1, 100) <= revealChance then
        self:RevealAsHostile(nearestPolice)
    end
end

function ENT:RevealAsHostile(target)
    if self.HasRevealed then return end
    
    self.HasRevealed = true
    self.IsCivilian = false
    self.IsSuspect = true
    self.SuspectNPC = true
    self.NoWeapon = false
    self.CanAttack = true
    self.DisableMeleeAttack = false
    self.BecomeEnemyToPlayer = true
    self.FleeOnDanger = false
    
    self.VJ_NPC_Class = {"CLASS_BLOODSHED_SUSPECT"}
    
    self.CivilianPenaltyMoney = 0
    self.CivilianPenaltyGuilt = 0
    
    self:InitializePersonality()
    self.Personality = PERSONALITY_AGGRESSIVE
    self:ApplyPersonalityTraits()
    self.Morale = MORALE_HIGH
    
    self:Give(self.HiddenWeapon)
    print("Hidden suspect revealed and armed with " .. self.HiddenWeapon)
    
    self:EmitSound("weapons/draw_primary.wav", 60, math.random(95, 105))
    
    if IsValid(target) then
        self:ForceSetEnemy(target)
        self:SetAwareness(AWARENESS_COMBAT)
    end
    
    if self:CanPlayVox("contact") then
        self:PlayVox({"vo/npc/male01/gethellout.wav", "vo/npc/male01/yeah02.wav"}, 80)
        self:SetVoxCooldown("contact", 5)
    end
    
    hook.Run("BloodshedHiddenSuspectRevealed", self, target)
end

function ENT:OnCivilianSurrender(attacker)
    if not self.IsHiddenSuspect then return end
    if self.HasRevealed then return end
    
    if math.random(1, 100) <= 40 then
        timer.Simple(math.Rand(2, 6), function()
            if IsValid(self) and self.Surrendering and not self.HasRevealed then
                self:RevealAsHostile(attacker)
            end
        end)
    end
end

function ENT:HostageThink()
    if not self.IsHostage then return end
    if self.IsRescued then return end
    if self.IsBeingUsedAsShield then return end
    
    if not self.SurrenderAnimStarted then
        self.SurrenderAnimStarted = true
        self:SetState(VJ_STATE_FREEZE)
        
        local anim = "sequence_ron_comply_start_0" .. math.random(1, 4)
        if self:LookupSequence(anim) ~= -1 then
            self:PlayAnim("vjseq_" .. anim, true, false)
        else
            if self:LookupSequence("idle_all_cower") ~= -1 then
                self:PlayAnim("idle_all_cower", true, false)
            end
        end
        
        self.NextWiggleTime = CurTime() + math.random(3, 8)
    end
    
    if CurTime() > (self.NextWiggleTime or 0) then
        self.NextWiggleTime = CurTime() + 0.5
        
        if self:LookupSequence("cidle_all") ~= -1 then
            self:PlayAnim("vjseq_cidle_all", true, 2, false)
        end
    end
end

function ENT:CallAllyReaction(reactionType)
    if not isstring(reactionType) or not IsValid(self) then return end
    if self.IsProcessingReaction then return end
    
    self.IsProcessingReaction = true
    
    for _, ent in pairs(ents.FindInSphere(self:GetPos(), 400)) do
        if not IsValid(ent) or ent == self or ent:GetClass() ~= self:GetClass() then continue end
        if not ent.IsSuspect then continue end
        if not self:Visible(ent) then continue end
            
            if reactionType == "surrender" then
                local chance = 0
                if ent.Personality == PERSONALITY_COWARD then
                    chance = 50
                elseif ent.Personality == PERSONALITY_CAUTIOUS then
                    chance = 25
                else
                    chance = 10
                end
                
                if ent.Morale <= MORALE_LOW then
                    chance = chance + 25
                end
                
                if math.random(1, 100) <= chance then
                    ent:StartSurrender()
                end
                
            elseif reactionType == "fake_surrender" then
                if ent.Personality == PERSONALITY_AGGRESSIVE then
                    if math.random(1, 100) <= 25 then
                        ent.Surrendering = true
                        ent.FakeSurrendering = true
                    end
                end
                
            elseif reactionType == "attack_from_surrender" and ent.Surrendering then
                local chance = 0
                if ent.Personality == PERSONALITY_AGGRESSIVE then
                    chance = 60
                elseif ent.Personality == PERSONALITY_CAUTIOUS then
                    chance = 30
                else
                    chance = 10
                end
                
                if math.random(1, 100) <= chance then
                    timer.Simple(math.Rand(0.2, 0.8), function()
                        if IsValid(ent) and ent.Surrendering then
                            ent:ExecuteFakeSurrender()
                        end
                    end)
                end
                
            elseif reactionType == "alert" then
                local enemy = self:GetEnemy()
                if IsValid(enemy) then
                    ent:ForceSetEnemy(enemy)
                    ent:AddSuppression(15)
                end
            end
    end
    
    self.IsProcessingReaction = false
end

function ENT:TryThrowGrenade()
    if not self.HasGrenades or self.GrenadesCount <= 0 then return end
    if CurTime() < self.NextGrenadeTime then return end
    if self.Surrendering or self.IsPanicking then return end
    
    local enemy = self:GetEnemy()
    if not IsValid(enemy) then return end
    
    local dist = self:GetPos():Distance(enemy:GetPos())
    if dist < 200 or dist > 500 then return end
    
    local throwChance = 0
    
    if not self:Visible(enemy) and CurTime() - self.LastSawEnemyTime < 5 then
        throwChance = throwChance + 40
    end
    
    if self.Personality == PERSONALITY_AGGRESSIVE then
        throwChance = throwChance + 30
    elseif self.Personality == PERSONALITY_CAUTIOUS then
        throwChance = throwChance + 15
    end
    
    if self:Health() < self:GetMaxHealth() * 0.4 then
        throwChance = throwChance + 25
    end
    
    for _, ally in pairs(ents.FindInSphere(enemy:GetPos(), 200)) do
        if ally ~= self and ally:GetClass() == self:GetClass() then
            throwChance = throwChance - 50
            break
        end
    end
    
    if math.random(1, 100) <= throwChance then
        self:ThrowGrenade(enemy)
    end
end

function ENT:ThrowGrenade(target)
    if not IsValid(target) then return end
    
    local myPos = self:EyePos()
    local targetPos = target:GetPos() + Vector(0, 0, 32)
    local dist = myPos:Distance(targetPos)
    
    local throwDir = (targetPos - myPos):GetNormalized()
    throwDir.z = throwDir.z + math.Clamp(dist / 400, 0.05, 0.2)
    throwDir = throwDir:GetNormalized()
    
    local grenade = ents.Create("murwep_grenade")
    if not IsValid(grenade) then return end
    
    grenade:SetPos(myPos + self:GetForward() * 30)
    grenade:Spawn()
    
    local phys = grenade:GetPhysicsObject()
    if IsValid(phys) then
        local force = math.Clamp(dist * 2, 600, 1000)
        phys:SetVelocity(throwDir * force)
        phys:AddAngleVelocity(VectorRand() * 300)
    end
    
    grenade.PlayerOwner = self
    
    self.GrenadesCount = self.GrenadesCount - 1
    self.NextGrenadeTime = CurTime() + math.random(20, 40)
    
    self:EmitSound("weapons/slam/throw.wav", 70, math.random(95, 105))
    
    if self:CanPlayVox("grenade") then
        self:PlayVox(self.SoundTbl_Grenade, 75)
        self:SetVoxCooldown("grenade", 10)
    end
end

function ENT:OnThink()
    self:UpdateMorale()
    self:ReduceSuppression()
    self:UpdateAwareness()
    self:SurrenderThink()
    self:FlashbangRecoveryThink()
    
    if self.IsCivilian then
        self:CivilianThink()
        SafeRemoveEntity(self:GetActiveWeapon())
        return
    end
    
    if self.IsHostage then
        self:HostageThink()
        SafeRemoveEntity(self:GetActiveWeapon())
        return
    end
    
    if self.Surrendering or self.IsPanicking then return end
    
    self:RoNTacticalThink()
    self:HoldAngleThink()
    self:BlindFireThink()
    self:HostageShieldThink()
    
    self:WoundThink()
    self:SquadThink()
    self:MemoryThink()
    self:SoundAnalysisThink()
    self:EnvironmentThink()
    
    if self.CanSetTraps and CurTime() - (self.LastPathUpdate or 0) > 2 then
        self:UpdateEnemyPathMemory()
        self.LastPathUpdate = CurTime()
    end
    
    self:TacticalThink()
    self:TryPlaceTrap()
    self:TryThrowGrenade()
    self:LeanThink()
    
    if not IsValid(self:GetEnemy()) and CurTime() > self.NextIdleVox then
        if math.random(1, 100) <= 5 then
            self:PlayVox(self.SoundTbl_IdleVox, 60)
        end
        self.NextIdleVox = CurTime() + math.random(40, 80)
    end
end

function ENT:FlashbangRecoveryThink()
    if self.IsCoveringHead and CurTime() > (self.CoverHeadEndTime or 0) then
        self.IsCoveringHead = false
    end
    
    if not self.IsFlashbanged then return end
    
    if CurTime() > self.FlashbangRecoveryTime then
        self.IsFlashbanged = false
        self.FlashbangLevel = nil
        self.IsDisoriented = false
        timer.Remove("Disoriented_" .. self:EntIndex())
        timer.Remove("DisShoot_" .. self:EntIndex())
    end
end

function ENT:CheckBlockedDoorAhead()
    local forward = self:GetAngles():Forward()
    local checkPos = self:GetPos() + forward * 100
    
    local doors = ents.FindInSphere(checkPos, 120)
    for _, door in pairs(doors) do
        if IsValid(door) and door:GetClass():find("door") then
            local isOpen = door:GetInternalVariable("m_bLocked") == 0
            if not isOpen then
                local tr = util.TraceLine({
                    start = self:GetPos() + Vector(0, 0, 32),
                    endpos = checkPos + forward * 200,
                    filter = self,
                    mask = MASK_NPCSOLID
                })
                
                if tr.Hit and tr.Entity == door then
                    self.BlockedDoors[door:EntIndex()] = {
                        door = door,
                        pos = door:GetPos(),
                        time = CurTime()
                    }
                    return door
                end
            end
        end
    end
    return nil
end

function ENT:EnterWaitingMode(door)
    if self.WaitingForEnemy then return end
    
    self.WaitingForEnemy = true
    self.CombatStance = STANCE_AMBUSH
    
    local coverPos = self:FindSecureAmbushPosition(door:GetPos())
    if coverPos then
        self.AmbushPosition = coverPos
        self:SetLastPosition(coverPos)
        self:SCHEDULE_GOTO_POSITION("TASK_WALK_PATH", function(x)
            x.CanShootWhenMoving = false
            x.RunCode_OnFinish = function()
                if IsValid(self) then
                    self:StartHoldingAngle(coverPos, (door:GetPos() - coverPos):GetNormalized())
                end
            end
        end)
    end
end

function ENT:FindSecureAmbushPosition(doorPos)
    local myPos = self:GetPos()
    local bestPos = nil
    local bestScore = 0
    
    for angle = 0, 360, 45 do
        for dist = 150, 400, 50 do
            local rad = math.rad(angle)
            local testPos = doorPos + Vector(math.cos(rad) * dist, math.sin(rad) * dist, 0)
            
            local tr = util.TraceLine({
                start = testPos + Vector(0, 0, 50),
                endpos = testPos - Vector(0, 0, 50),
                mask = MASK_SOLID_BRUSHONLY
            })
            
            if tr.Hit then
                testPos = tr.HitPos
                
                local visibleToDoor = util.TraceLine({
                    start = testPos + Vector(0, 0, 64),
                    endpos = doorPos + Vector(0, 0, 32),
                    mask = MASK_SOLID_BRUSHONLY
                })
                
                if not visibleToDoor.Hit then
                    local coverScore = 0
                    
                    for coverAngle = 0, 315, 45 do
                        local coverRad = math.rad(coverAngle)
                        local coverDir = Vector(math.cos(coverRad), math.sin(coverRad), 0)
                        local coverTr = util.TraceLine({
                            start = testPos + Vector(0, 0, 32),
                            endpos = testPos + Vector(0, 0, 32) + coverDir * 80,
                            mask = MASK_SOLID_BRUSHONLY
                        })
                        
                        if coverTr.Hit and coverTr.Fraction < 0.8 then
                            coverScore = coverScore + 1
                        end
                    end
                    
                    if coverScore >= 3 and coverScore > bestScore then
                        bestScore = coverScore
                        bestPos = testPos
                    end
                end
            end
        end
    end
    
    return bestPos
end

function ENT:RoNTacticalThink()
    if CurTime() < self.NextTacticalDecision then return end
    self.NextTacticalDecision = CurTime() + math.Rand(0.5, 1.5)
    
    if self.WaitingForEnemy and not IsValid(self:GetEnemy()) then
        return
    elseif self.WaitingForEnemy and IsValid(self:GetEnemy()) then
        local enemy = self:GetEnemy()
        if self:Visible(enemy) then
            self.WaitingForEnemy = false
            self.AmbushPosition = nil
            self:StopHoldingAngle()
        else
            return
        end
    end
    
    local blockedDoor = self:CheckBlockedDoorAhead()
    if IsValid(blockedDoor) and not IsValid(self:GetEnemy()) then
        self:EnterWaitingMode(blockedDoor)
        return
    end
    
    local enemy = self:GetEnemy()
    
    if self.Awareness == AWARENESS_UNAWARE then
        if self.DisableWandering then
            self:CheckDoorAmbush()
        end
        return
    end
    
    if self.Awareness == AWARENESS_SUSPICIOUS then
        if #self.SuspiciousPositions > 0 and not self.InvestigatingSound then
            self:InvestigatePosition(self.SuspiciousPositions[1])
        end
        return
    end
    
    if self.Awareness == AWARENESS_ALERTED then
        if self.LastKnownEnemyPos then
            if math.random(1, 100) <= 30 then
                self:TryWallbang(self.LastKnownEnemyPos)
            end
        end
        
        self:CoordinateWithSquad()
        return
    end
    
    if self.Awareness == AWARENESS_COMBAT then
        if not IsValid(enemy) then return end
        
        if not self:Visible(enemy) then
            if self.LastKnownEnemyPos then
                if math.random(1, 100) <= 40 then
                    self:TryWallbang(self.LastKnownEnemyPos)
                end
                
                if self.SuppressionLevel > 50 then
                    self:TryBlindFire(self.LastKnownEnemyPos)
                end
            end
        else
            if self.PreFireWarning and self.Awareness < AWARENESS_COMBAT then
                self:PreFireWarningShot()
            end
        end
        
        if self.Morale <= MORALE_LOW and not self.IsUsingHostageShield then
            if math.random(1, 100) <= 15 then
                self:TryUseHostageShield()
            end
        end
        
        if self.TeamRole == "leader" and #self.SquadMembers > 0 then
            if math.random(1, 100) <= 20 then
                local tactics = {"flank", "suppress", "retreat"}
                self:ExecuteSquadTactic(tactics[math.random(1, #tactics)])
            end
        end
        
        if math.random(1, 100) <= 10 then
            local peekDir = math.random(1, 2) == 1 and 1 or -1
            self:PeekCorner(peekDir)
        end
    end
end

function ENT:CustomOnTakeDamage_BeforeDamage(dmg, hitgroup)
    local attacker = dmg:GetAttacker()
    
    self:AddSuppression(dmg:GetDamage() * 0.5)
    self:ProcessWound(dmg, hitgroup)
    self:RememberThreat(attacker, dmg:GetDamage())
    
    if self.TakeOnSightBeforeShoot and not self.Surrendering then
        if self.Morale <= MORALE_LOW or dmg:GetDamage() > 25 then
            self:TrySurrender(true, attacker)
        else
            self.TakeOnSightBeforeShoot = false
        end
    end
    
    if dmg:GetDamage() >= self:Health() then
        for _, ally in pairs(ents.FindInSphere(self:GetPos(), 400)) do
            if ally ~= self and ally:GetClass() == self:GetClass() and ally.IsSuspect then
                if ally:Visible(self) then
                    ally.MoraleFactors.witnessed_deaths = ally.MoraleFactors.witnessed_deaths + 1
                end
            end
        end
    end
    
    if self:CanPlayVox("damage") then
        self:PlayVox(self.SoundTbl_Damage, 75)
        self:SetVoxCooldown("damage", 3)
    end
    
    self:BroadcastToSquad("taking_fire", attacker:GetPos())
end

function ENT:OnAlert(ent)
    self:CallAllyReaction("alert")
    self:AddSuppression(20)
    self.LastSawEnemyTime = CurTime()
    
    if self:CanPlayVox("contact") then
        self:PlayVox(self.SoundTbl_Contact, 80)
        self:SetVoxCooldown("contact", 8)
    end
end

function ENT:OnResetEnemy()
    self.CombatStartTime = 0
    
    if self.DisableWandering and self.IsSuspect then
        local coverPos = self:FindCoverPosition(nil, false)
        if coverPos then
            self:SetLastPosition(coverPos)
            self:SCHEDULE_GOTO_POSITION("TASK_WALK_PATH")
        end
    end
end

function ENT:CustomOnEnemyKilled(dmginfo, hitgroup)
    if self:CanPlayVox("kill") then
        self:PlayVox(self.SoundTbl_Kill, 75)
        self:SetVoxCooldown("kill", 10)
    end
end

function ENT:OnWeaponCanFire()
    if self.TakeOnSightBeforeShoot then
        return false
    end
    return true
end

function ENT:LeanThink()
    if CurTime() < self.NextLeanTime then return end
    if self.IsPanicking then return end
    
    self.NextLeanTime = CurTime() + 0.3
    
    local enemy = self:GetEnemy()
    if not IsValid(enemy) then
        self:ResetLean()
        return
    end
    
    local wep = self:GetActiveWeapon()
    if not IsValid(wep) or wep:Clip1() <= 0 then
        self:ResetLean()
        return
    end
    
    local startPos = self:GetBonePosition(2) or self:EyePos()
    local endPos = enemy:GetBonePosition(2) or enemy:EyePos()
    
    local tr = util.TraceLine({
        start = startPos,
        endpos = endPos,
        filter = {self, enemy}
    })
    
    if not tr.Hit then
        self:ResetLean()
        return
    end
    
    local right = self:GetRight() * 25
    local trR = util.TraceLine({start = startPos + right, endpos = endPos, filter = {self, enemy}})
    local trL = util.TraceLine({start = startPos - right, endpos = endPos, filter = {self, enemy}})
    
    if trR.Entity == enemy then
        self:DoLean(30, 0, -8)
    elseif trL.Entity == enemy then
        self:DoLean(-30, 0, 8)
    else
        self:ResetLean()
    end
end

function ENT:DoLean(pitch, yaw, roll)
    local bone = self:LookupBone("ValveBiped.Bip01_Spine")
    if not bone then return end
    
    self:ManipulateBoneAngles(bone, Angle(pitch, yaw, roll))
end

function ENT:ResetLean()
    local bone = self:LookupBone("ValveBiped.Bip01_Spine")
    if bone then
        self:ManipulateBoneAngles(bone, Angle(0, 0, 0))
    end
end

function ENT:OnFlashbang(duration, intensity, lookingAt)
    duration = duration or 6
    intensity = math.Clamp(intensity or 1, 0, 1)
    lookingAt = lookingAt == nil and true or lookingAt
    
    if not lookingAt then
        intensity = intensity * 0.3
        duration = duration * 0.4
    end
    
    if self.IsCoveringHead then
        intensity = intensity * 0.2
        duration = duration * 0.3
    end
    
    self.FlashbangIntensity = intensity
    self.IsFlashbanged = true
    self.FlashbangEndTime = CurTime() + duration
    self.FlashbangRecoveryTime = CurTime() + duration * 1.5
    
    if intensity > 0.7 then
        self.FlashbangLevel = "FULL_BLIND"
        self:OnFullBlind(duration)
    elseif intensity > 0.4 then
        self.FlashbangLevel = "PARTIAL_BLIND"
        self:OnPartialBlind(duration)
    else
        self.FlashbangLevel = "STUNNED"
        self:OnStunned(duration)
    end
    
    self.Morale = MORALE_BROKEN
    self:AddSuppression(100 * intensity)
    self.Weapon_Accuracy = 0.05 + (0.15 * (1 - intensity))
    
    local baseAccuracy = self.AccuracyMod or 1
    timer.Simple(duration, function()
        if IsValid(self) then
            self.IsFlashbanged = false
            self.Weapon_Accuracy = baseAccuracy * 0.5
        end
    end)
    
    timer.Simple(duration * 1.5, function()
        if IsValid(self) then
            self.Weapon_Accuracy = baseAccuracy
            self.FlashbangLevel = nil
        end
    end)
end

function ENT:OnFullBlind(duration)
    self:StopMoving()
    self:SetState(VJ_STATE_FREEZE)
    
    if self:LookupSequence("idle_all_angry") ~= -1 then
        self:PlayAnim("idle_all_angry", true, duration, false)
    end
    
    if self:CanPlayVox("damage") then
        self:PlayVox(self.SoundTbl_Damage, 90)
        self:SetVoxCooldown("damage", duration)
    end
    
    if math.random(1, 100) <= 85 then
        timer.Simple(duration * 0.2, function()
            if IsValid(self) and self.IsFlashbanged then
                self:TrySurrender(true)
            end
        end)
    else
        self:StartDisorientedBehavior(duration)
    end
    
    timer.Simple(duration * 0.8, function()
        if IsValid(self) then
            self:SetState(VJ_STATE_NONE)
        end
    end)
end

function ENT:OnPartialBlind(duration)
    self:StopMoving()
    
    if self:CanPlayVox("damage") then
        self:PlayVox(self.SoundTbl_Damage, 80)
        self:SetVoxCooldown("damage", duration * 0.8)
    end
    
    if self.Personality == PERSONALITY_COWARD then
        if math.random(1, 100) <= 60 then
            timer.Simple(duration * 0.3, function()
                if IsValid(self) and self.IsFlashbanged then
                    self:TrySurrender(true)
                end
            end)
        else
            self:StartPanic()
        end
    else
        self:StartDisorientedBehavior(duration * 0.6)
        
        if math.random(1, 100) <= 30 then
            self:DisorientedShooting(duration)
        end
    end
end

function ENT:OnStunned(duration)
    if self:CanPlayVox("damage") then
        self:PlayVox(self.SoundTbl_Damage, 70)
        self:SetVoxCooldown("damage", duration * 0.5)
    end
    
    self:AddSuppression(50)
    
    if math.random(1, 100) <= 20 then
        timer.Simple(duration * 0.4, function()
            if IsValid(self) and self.IsFlashbanged then
                self:TrySurrender(false)
            end
        end)
    end
end

function ENT:StartDisorientedBehavior(duration)
    self.IsDisoriented = true
    self.DisorientedEndTime = CurTime() + duration
    
    timer.Create("Disoriented_" .. self:EntIndex(), 0.8, math.floor(duration / 0.8), function()
        if not IsValid(self) or CurTime() > self.DisorientedEndTime then
            timer.Remove("Disoriented_" .. self:EntIndex())
            if IsValid(self) then
                self.IsDisoriented = false
            end
            return
        end
        
        local action = math.random(1, 100)
        
        if action <= 30 then
            local randomAng = Angle(0, math.random(0, 360), 0)
            self:SetAngles(randomAng)
        elseif action <= 50 then
            local randomPos = self:GetPos() + VectorRand() * math.random(100, 200)
            self:SetLastPosition(randomPos)
            self:SCHEDULE_GOTO_POSITION("TASK_WALK_PATH")
        elseif action <= 60 then
            self:StopMoving()
        end
    end)
end

function ENT:DisorientedShooting(duration)
    local wep = self:GetActiveWeapon()
    if not IsValid(wep) or wep:Clip1() < 3 then return end
    
    timer.Create("DisShoot_" .. self:EntIndex(), 0.4, math.floor(duration / 0.4), function()
        if not IsValid(self) or not IsValid(wep) or wep:Clip1() <= 0 then
            timer.Remove("DisShoot_" .. self:EntIndex())
            return
        end
        
        if math.random(1, 100) <= 40 then
            local randomAng = Angle(math.random(-20, 45), math.random(-90, 90), 0)
            self:SetAngles(self:GetAngles() + randomAng)
            wep:PrimaryAttack()
        end
    end)
end

function ENT:FullSurrender()
    self.Surrendering = true
    self.FakeSurrendering = math.random(1, 100) <= 5
    self:CallAllyReaction(self.FakeSurrendering and "fake_surrender" or "surrender")
end

function ENT:OnKilled(dmginfo)
    local attacker = dmginfo:GetAttacker()
    
    if self.IsCivilian and IsValid(attacker) and attacker:IsPlayer() then
        local penalty = self.CivilianPenaltyMoney or 1000
        local guilt = self.CivilianPenaltyGuilt or 15
        
        if attacker.AddMoney then
            attacker:AddMoney(-penalty)
        end
        
        if attacker.AddGuilt then
            attacker:AddGuilt(guilt)
        end
        
        attacker:ChatPrint("[PENALTY] Civilian killed! -$" .. penalty .. " | +" .. guilt .. " guilt")
        
        hook.Run("BloodshedCivilianKilled", attacker, self, penalty, guilt)
    end
    
    if self.IsHostage and IsValid(attacker) and attacker:IsPlayer() then
        local penalty = self.HostageDeathPenalty or 2000
        local guilt = self.HostageDeathGuilt or 25
        
        if attacker.AddMoney then
            attacker:AddMoney(-penalty)
        end
        
        if attacker.AddGuilt then
            attacker:AddGuilt(guilt)
        end
        
        attacker:ChatPrint("[PENALTY] Hostage killed! -$" .. penalty .. " | +" .. guilt .. " guilt")
        
        hook.Run("BloodshedHostageKilled", attacker, self, penalty, guilt)
    end
end

function ENT:RescueHostage(rescuer)
    if not self.IsHostage then return end
    if self.IsRescued then return end
    if not IsValid(rescuer) or not rescuer:IsPlayer() then return end
    if true then return end
    
    self.IsRescued = true
    
    local reward = self.HostageRescueReward or 500
    
    if rescuer.AddMoney then
        rescuer:AddMoney(reward)
    end
    
    rescuer:ChatPrint("[REWARD] Hostage rescued! +$" .. reward)
    
    rescuer:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 0.5, 0)
    
    hook.Run("BloodshedHostageRescued", rescuer, self, reward)
    
    self:Remove()
end

if engine.ActiveGamemode() == "bloodshed" then
    MuR.ActiveSuspects = MuR.ActiveSuspects or {}

    local function TrackSuspect(ent)
        if not IsValid(ent) then return end
        if ent:GetClass() ~= "npc_vj_bloodshed_suspect" then return end
        MuR.ActiveSuspects[ent] = true
    end

    hook.Add("OnEntityCreated", "MuR.TrackSuspects", function(ent)
        timer.Simple(0, function()
            TrackSuspect(ent)
        end)
    end)

    hook.Add("EntityRemoved", "MuR.TrackSuspects", function(ent)
        if MuR.ActiveSuspects then
            MuR.ActiveSuspects[ent] = nil
        end
    end)

    timer.Simple(0, function()
        if not MuR.ActiveSuspects then return end
        for _, ent in ipairs(ents.FindByClass("npc_vj_bloodshed_suspect")) do
            MuR.ActiveSuspects[ent] = true
        end
    end)

    hook.Add("PlayerButtonDown", "MuR.GoSurrender", function(ply, key)
        if MuR.Gamemode ~= 14 then return end
        
        if ply:IsRolePolice() and ply:Alive() and key == KEY_G then
            if ply.DelayBeforeNextUseSurrender and ply.DelayBeforeNextUseSurrender > CurTime() then
                return
            end
            
            ply.DelayBeforeNextUseSurrender = CurTime() + 3
            ply.VoiceDelay = 0
            ply:PlayVoiceLine("ror_police_surrender", true)
            
            local targets = {}
            for _, ent in pairs(ents.FindInSphere(ply:GetPos(), 800)) do
                if ent.SuspectNPC or ent.IsCivilian then
                    if ply:Visible(ent) then
                        table.insert(targets, {
                            ent = ent,
                            dist = ply:GetPos():Distance(ent:GetPos())
                        })
                    end
                end
            end
            
            table.sort(targets, function(a, b) return a.dist < b.dist end)
            
            for i, target in ipairs(targets) do
                timer.Simple(i * 0.1, function()
                    if IsValid(target.ent) and IsValid(ply) then
                        local ang = (ply:GetPos() - target.ent:GetPos()):Angle()
                        target.ent:SetAngles(Angle(0, ang.y, 0))
                        
                        if target.ent.IsCivilian then
                            if not target.ent.Surrendering then
                                target.ent.Surrendering = true
                                target.ent.PermanentSurrender = true
                            end
                        else
                            target.ent:TrySurrender(false, ply)
                        end
                        
                        if not IsValid(target.ent:GetEnemy()) then
                            target.ent:ForceSetEnemy(ply)
                        end
                    end
                end)
            end
        end
    end)
    
    hook.Add("PlayerUse", "MuR.RescueHostage", function(ply, ent)
        if not IsValid(ent) then return end
        if not ent.IsHostage then return end
        if ent.IsRescued then return end
        
        if ply:IsRolePolice() and ply:Alive() then
            local dist = ply:GetPos():Distance(ent:GetPos())
            if dist < 100 then
                ent:RescueHostage(ply)
            end
        end
    end)
    
    hook.Add("EntityEmitSound", "BloodshedSuspectHearSounds", function(data)
        if not data.Entity then return end
        
        local soundName = data.SoundName or ""
        local pos = data.Pos or (IsValid(data.Entity) and data.Entity:GetPos())
        if not pos then return end
        
        local isDoorSound = string.find(soundName, "door") or string.find(soundName, "Door")
        local isBreachSound = string.find(soundName, "breach") or string.find(soundName, "explosion") or string.find(soundName, "break")
        local isFootstep = string.find(soundName, "footstep") or string.find(soundName, "step")
        
        if isDoorSound or isBreachSound or isFootstep then
            local hearRadius = 600
            if isBreachSound then hearRadius = 1200 end
            if isFootstep then hearRadius = 300 end
            local hearRadiusSq = hearRadius * hearRadius
            
            local suspects = MuR.ActiveSuspects
            if suspects then
                for npc in pairs(suspects) do
                    if not IsValid(npc) then
                        suspects[npc] = nil
                        continue
                    end
                    if not npc.SuspectNPC or npc:Health() <= 0 or npc.Surrendering then
                        continue
                    end
                    if npc.NextSoundListen and npc.NextSoundListen > CurTime() then
                        continue
                    end
                    if npc:GetPos():DistToSqr(pos) > hearRadiusSq then
                        continue
                    end

                    npc.NextSoundListen = CurTime() + (isFootstep and 0.2 or 0.1)
                    npc.LastHeardSoundPos = pos
                    npc.LastHeardSoundTime = CurTime()
                        
                    npc.AwarenessState = npc.AwarenessState or AWARENESS_UNAWARE
                    npc.AwarenessLevel = npc.AwarenessLevel or 0
                        
                    if isBreachSound then
                        npc.AwarenessState = AWARENESS_COMBAT
                        npc.AwarenessLevel = 100
                            
                        if npc.Personality == PERSONALITY_AGGRESSIVE then
                            npc:SetMovementActivity(ACT_RUN)
                            npc:SetLastPosition(pos)
                            npc:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH")
                        elseif npc.Personality == PERSONALITY_COWARD then
                            local fleeDir = (npc:GetPos() - pos):GetNormalized() * 500
                            local fleePos = npc:GetPos() + fleeDir
                            npc:SetLastPosition(fleePos)
                            npc:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH")
                        else
                            npc.IsHoldingAngle = true
                            npc.HoldAnglePos = npc:GetPos()
                            npc.HoldAngleTarget = pos
                        end
                    elseif isDoorSound then
                        if npc.AwarenessState < AWARENESS_ALERTED then
                            npc.AwarenessState = AWARENESS_SUSPICIOUS
                            npc.AwarenessLevel = math.max(npc.AwarenessLevel, 50)
                        end
                            
                        npc.DoorWatchPos = pos
                        npc.DoorWatchTime = CurTime() + math.random(3, 8)
                    elseif isFootstep then
                        if npc.AwarenessState == AWARENESS_UNAWARE then
                            npc.AwarenessState = AWARENESS_SUSPICIOUS
                            npc.AwarenessLevel = math.max(npc.AwarenessLevel, 25)
                        end
                    end
                end
            else
                for _, npc in pairs(ents.FindInSphere(pos, hearRadius)) do
                    if npc.SuspectNPC and IsValid(npc) and npc:Health() > 0 and not npc.Surrendering then
                        npc.LastHeardSoundPos = pos
                        npc.LastHeardSoundTime = CurTime()

                        npc.AwarenessState = npc.AwarenessState or AWARENESS_UNAWARE
                        npc.AwarenessLevel = npc.AwarenessLevel or 0

                        if isBreachSound then
                            npc.AwarenessState = AWARENESS_COMBAT
                            npc.AwarenessLevel = 100

                            if npc.Personality == PERSONALITY_AGGRESSIVE then
                                npc:SetMovementActivity(ACT_RUN)
                                npc:SetLastPosition(pos)
                                npc:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH")
                            elseif npc.Personality == PERSONALITY_COWARD then
                                local fleeDir = (npc:GetPos() - pos):GetNormalized() * 500
                                local fleePos = npc:GetPos() + fleeDir
                                npc:SetLastPosition(fleePos)
                                npc:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH")
                            else
                                npc.IsHoldingAngle = true
                                npc.HoldAnglePos = npc:GetPos()
                                npc.HoldAngleTarget = pos
                            end
                        elseif isDoorSound then
                            if npc.AwarenessState < AWARENESS_ALERTED then
                                npc.AwarenessState = AWARENESS_SUSPICIOUS
                                npc.AwarenessLevel = math.max(npc.AwarenessLevel, 50)
                            end

                            npc.DoorWatchPos = pos
                            npc.DoorWatchTime = CurTime() + math.random(3, 8)
                        elseif isFootstep then
                            if npc.AwarenessState == AWARENESS_UNAWARE then
                                npc.AwarenessState = AWARENESS_SUSPICIOUS
                                npc.AwarenessLevel = math.max(npc.AwarenessLevel, 25)
                            end
                        end
                    end
                end
            end
        end
    end)
    
    hook.Add("OnEntityCreated", "BloodshedFlashbangReaction", function(ent)
        timer.Simple(0, function()
            if not IsValid(ent) then return end
            
            local class = ent:GetClass()
            if class == "bloodshed_flashbang" or class == "weapon_flashbang" or string.find(class, "flashbang") then
                local startPos = ent:GetPos()
                
                timer.Simple(0.3, function()
                    if IsValid(ent) then
                        for _, npc in pairs(ents.FindInSphere(ent:GetPos(), 600)) do
                            if npc.SuspectNPC and IsValid(npc) and npc:Health() > 0 and not npc.Surrendering then
                                npc:HearSound(ent:GetPos(), "flashbang_pin", 1.0)
                            end
                        end
                    end
                end)
                
                timer.Simple(1.5, function()
                    local detonatePos = IsValid(ent) and ent:GetPos() or startPos
                    
                    for _, npc in pairs(ents.FindInSphere(detonatePos, 900)) do
                        if npc.SuspectNPC and IsValid(npc) and npc:Health() > 0 then
                            local dist = npc:GetPos():Distance(detonatePos)
                            local maxRange = 900
                            local effectStrength = math.Clamp(1 - (dist / maxRange), 0, 1)
                            
                            if effectStrength < 0.1 then continue end
                            
                            local npcToFlash = (detonatePos - npc:EyePos()):GetNormalized()
                            local npcForward = npc:GetAngles():Forward()
                            local lookDot = npcForward:Dot(npcToFlash)
                            local isLookingAt = lookDot > 0.3
                            
                            local visibleTr = util.TraceLine({
                                start = npc:EyePos(),
                                endpos = detonatePos,
                                filter = npc,
                                mask = MASK_SHOT
                            })
                            
                            local canSeeFlash = not visibleTr.Hit or visibleTr.HitPos:Distance(detonatePos) < 50
                            
                            if not canSeeFlash then
                                effectStrength = effectStrength * 0.3
                                isLookingAt = false
                            end
                            
                            if isLookingAt then
                                effectStrength = effectStrength * 1.5
                            else
                                effectStrength = effectStrength * 0.6
                            end
                            
                            effectStrength = math.Clamp(effectStrength, 0, 1)
                            
                            local duration = 3 + (3 * effectStrength)
                            
                            if npc.OnFlashbang then
                                npc:OnFlashbang(duration, effectStrength, isLookingAt)
                            else
                                npc.IsFlashbanged = true
                                npc.FlashbangEndTime = CurTime() + duration
                                npc.FlashbangStrength = effectStrength
                                npc:StopMoving()
                            end
                            
                            if effectStrength > 0.5 then
                                npc:SetAwareness(AWARENESS_COMBAT)
                            end
                        end
                    end
                end)
            end
        end)
    end)
    
    hook.Add("EntityTakeDamage", "BloodshedNPCHostageDamage", function(target, dmg)
        if not IsValid(target) then return end
        if not target.IsUsingHostageShield then return end
        
        local hostage = target.HostageShield
        if not IsValid(hostage) then return end
        
        local attacker = dmg:GetAttacker()
        if not IsValid(attacker) then return end
        
        if math.random(1, 100) <= 60 then
            local redirectDmg = DamageInfo()
            redirectDmg:SetDamage(dmg:GetDamage() * 0.7)
            redirectDmg:SetAttacker(attacker)
            redirectDmg:SetInflictor(dmg:GetInflictor())
            redirectDmg:SetDamageType(dmg:GetDamageType())
            
            hostage:TakeDamageInfo(redirectDmg)
            dmg:SetDamage(dmg:GetDamage() * 0.3)
        end
    end)
    
end

function ENT:ProcessWound(dmg, hitgroup)
    if not self.Wounds then return end
    
    local damage = dmg:GetDamage()
    local location = WOUND_LOCATION_TORSO
    
    if hitgroup == HITGROUP_HEAD then
        location = WOUND_LOCATION_HEAD
    elseif hitgroup == HITGROUP_LEFTARM or hitgroup == HITGROUP_RIGHTARM then
        location = WOUND_LOCATION_ARM
    elseif hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG then
        location = WOUND_LOCATION_LEG
    end
    
    local severity = WOUND_LIGHT
    if damage > 40 then
        severity = WOUND_CRITICAL
    elseif damage > 25 then
        severity = WOUND_SEVERE
    elseif damage > 15 then
        severity = WOUND_MODERATE
    end
    
    if severity > self.Wounds[location] then
        self.Wounds[location] = severity
    end
    
    self:CalculateTotalWoundEffects()
    self:ApplyWoundEffects(location, severity)
    
    if severity >= WOUND_MODERATE then
        self.IsBleeding = true
        self.BleedRate = self.BleedRate + (severity * 0.5)
        self.NextBleedDamageTime = CurTime() + 3
    end
    
    self.PainLevel = math.min(self.PainLevel + damage * 0.8, self.MaxPain)
end

function ENT:CalculateTotalWoundEffects()
    self.TotalWoundSeverity = 0
    for _, severity in pairs(self.Wounds) do
        self.TotalWoundSeverity = self.TotalWoundSeverity + severity
    end
    
    if self.Wounds[WOUND_LOCATION_LEG] >= WOUND_MODERATE then
        self.IsLimping = true
        self.AnimTbl_Walk = {"walk_all_injured"}
        self:SetMovementActivity(ACT_WALK)
    end
    
    if self.Wounds[WOUND_LOCATION_ARM] >= WOUND_MODERATE then
        self.Weapon_Accuracy = (self.AccuracyMod or 1) * (1 - self.Wounds[WOUND_LOCATION_ARM] * 0.15)
    end
    
    if self.TotalWoundSeverity >= 8 then
        self.Morale = MORALE_BROKEN
    elseif self.TotalWoundSeverity >= 5 then
        self.Morale = math.min(self.Morale, MORALE_LOW)
    end
end

function ENT:ApplyWoundEffects(location, severity)
    if location == WOUND_LOCATION_LEG and severity >= WOUND_SEVERE then
        self:StopMoving()
        if self:LookupSequence("idle_injured") ~= -1 then
            self:PlayAnim("idle_injured", true, 2, false)
        end
        
        if self:CanPlayVox("damage") then
            self:PlayVox(self.SoundTbl_Damage, 85)
        end
    end
    
    if location == WOUND_LOCATION_HEAD and severity >= WOUND_MODERATE then
        self.Weapon_Accuracy = (self.AccuracyMod or 1) * 0.3
        self:AddSuppression(50)
    end
end

function ENT:WoundThink()
    if not self.IsBleeding then return end
    
    if CurTime() > self.NextBleedDamageTime then
        self.NextBleedDamageTime = CurTime() + 2
        
        local bleedDamage = self.BleedRate * 0.5
        self:TakeDamage(bleedDamage, self, self)
        
        local ef = EffectData()
        ef:SetOrigin(self:GetPos() + Vector(0, 0, 20))
        util.Effect("BloodImpact", ef)
        
        self.BleedRate = math.max(0, self.BleedRate - 0.1)
        if self.BleedRate <= 0 then
            self.IsBleeding = false
        end
    end
    
    if self.PainLevel > 50 and not self.IsHealing then
        self:TryHealSelf()
    end
end

function ENT:TryHealSelf()
    if not self.CanHealSelf or self.HealingKitCount <= 0 then return end
    if self.IsHealing or self.Surrendering then return end
    if IsValid(self:GetEnemy()) and self:Visible(self:GetEnemy()) then return end
    
    local coverPos = self:FindCoverPosition(self:GetEnemy(), false)
    if not coverPos then return end
    
    self.IsHealing = true
    self.HealingKitCount = self.HealingKitCount - 1
    
    self:SetLastPosition(coverPos)
    self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH", function(x)
        x.RunCode_OnFinish = function()
            if IsValid(self) then
                self:PerformHealing()
            end
        end
    end)
end

function ENT:PerformHealing()
    self:StopMoving()
    self:SetState(VJ_STATE_ONLY_ANIMATION_NOATTACK)
    
    self:EmitSound("items/medshot4.wav", 60)
    
    timer.Simple(3, function()
        if not IsValid(self) then return end
        
        self.IsBleeding = false
        self.BleedRate = 0
        self.PainLevel = math.max(0, self.PainLevel - 50)
        
        for location, _ in pairs(self.Wounds) do
            if self.Wounds[location] > WOUND_NONE then
                self.Wounds[location] = math.max(WOUND_NONE, self.Wounds[location] - 1)
            end
        end
        
        self:CalculateTotalWoundEffects()
        
        local healAmount = 20
        self:SetHealth(math.min(self:Health() + healAmount, self:GetMaxHealth()))
        
        self.IsHealing = false
        self:SetState(VJ_STATE_NONE)
    end)
end

function ENT:RememberThreat(attacker, damage)
    if not IsValid(attacker) then return end
    if not attacker:IsPlayer() then return end
    
    local steamID = attacker:SteamID()
    
    if not self.PlayerMemory[steamID] then
        self.PlayerMemory[steamID] = {
            totalDamage = 0,
            encounters = 0,
            lastWeapon = nil,
            preferredPositions = {},
            threatLevel = 0
        }
    end
    
    local mem = self.PlayerMemory[steamID]
    mem.totalDamage = mem.totalDamage + damage
    mem.encounters = mem.encounters + 1
    mem.lastPos = attacker:GetPos()
    mem.lastTime = CurTime()
    
    local wep = attacker:GetActiveWeapon()
    if IsValid(wep) then
        mem.lastWeapon = wep:GetClass()
    end
    
    mem.threatLevel = math.Clamp(mem.totalDamage / 50 + mem.encounters * 0.5, 0, 10)
    self.PlayerThreatLevel[steamID] = mem.threatLevel
end

function ENT:MemoryThink()
    if CurTime() - (self.LastMemoryUpdate or 0) < 2 then return end
    self.LastMemoryUpdate = CurTime()
    
    for steamID, mem in pairs(self.PlayerMemory) do
        if mem.lastTime and CurTime() - mem.lastTime > 60 then
            mem.threatLevel = math.max(0, mem.threatLevel - 0.5)
        end
    end
    
    self:AdaptTactics()
end

function ENT:AdaptTactics()
    local highestThreat = nil
    local highestLevel = 0
    
    for steamID, level in pairs(self.PlayerThreatLevel) do
        if level > highestLevel then
            highestLevel = level
            highestThreat = steamID
        end
    end
    
    if highestLevel > 5 then
        self.AdaptationLevel = math.min(self.AdaptationLevel + 1, 10)
        
        if self.AdaptationLevel > 3 then
            self.TakeOnSightBeforeShoot = false
            self.ReactionTime = math.max(0.2, (self.ReactionTime or 0.5) - 0.1)
        end
        
        if self.AdaptationLevel > 5 then
            self.ChaseEnemyAlways = false
            self.CombatStance = STANCE_DEFENSIVE
        end
        
        if self.AdaptationLevel > 7 then
            self:BroadcastToSquad("high_threat", highestThreat)
        end
    end
    
    local mem = highestThreat and self.PlayerMemory[highestThreat]
    if mem and mem.lastWeapon then
        if string.find(mem.lastWeapon, "shotgun") then
            self.PreferredCombatRange = 600
        elseif string.find(mem.lastWeapon, "sniper") or string.find(mem.lastWeapon, "awp") then
            self.PreferredCombatRange = 200
            self.ShouldFlank = true
        end
    end
end

function ENT:RememberCover(pos, wasGood)
    if not pos then return end
    
    local key = math.floor(pos.x/100) .. "_" .. math.floor(pos.y/100)
    
    if not self.CoverMemory[key] then
        self.CoverMemory[key] = {pos = pos, score = 0, uses = 0}
    end
    
    self.CoverMemory[key].uses = self.CoverMemory[key].uses + 1
    self.CoverMemory[key].score = self.CoverMemory[key].score + (wasGood and 10 or -15)
    
    if self.CoverMemory[key].score < -20 then
        self.DangerZones[key] = pos
    end
end

function ENT:SquadThink()
    if not self.IsSuspect then return end
    if CurTime() - self.LastSquadUpdate < 1 then return end
    self.LastSquadUpdate = CurTime()
    
    self:UpdateSquadMembers()
    
    if self.IsSquadLeader then
        self:LeaderThink()
    else
        self:FollowerThink()
    end
end

function ENT:UpdateSquadMembers()
    self.SquadMembers = {}
    
    for _, ent in pairs(ents.FindInSphere(self:GetPos(), self.SquadCommunicationRange)) do
        if ent ~= self and ent:GetClass() == self:GetClass() and ent.IsSuspect then
            if ent:Health() > 0 and not ent.Surrendering then
                table.insert(self.SquadMembers, ent)
            end
        end
    end
    
    if #self.SquadMembers == 0 then
        self.TeamRole = ROLE_FOLLOWER
        self.IsSquadLeader = false
        return
    end
    
    local hasLeader = false
    for _, member in pairs(self.SquadMembers) do
        if member.IsSquadLeader then
            hasLeader = true
            self.SquadLeader = member
            break
        end
    end
    
    if not hasLeader then
        self:TryBecomeLeader()
    end
end

function ENT:TryBecomeLeader()
    local shouldLead = true
    
    for _, member in pairs(self.SquadMembers) do
        if member.Personality == PERSONALITY_AGGRESSIVE and self.Personality ~= PERSONALITY_AGGRESSIVE then
            shouldLead = false
            break
        end
        if member:Health() > self:Health() and member.Personality == self.Personality then
            shouldLead = false
            break
        end
    end
    
    if shouldLead then
        self.IsSquadLeader = true
        self.TeamRole = ROLE_LEADER
        self:AssignSquadRoles()
    end
end

function ENT:AssignSquadRoles()
    if not self.IsSquadLeader then return end
    
    for i, member in ipairs(self.SquadMembers) do
        if member.Personality == PERSONALITY_AGGRESSIVE then
            member.TeamRole = ROLE_POINTMAN
        elseif member.Personality == PERSONALITY_CAUTIOUS then
            if i % 2 == 0 then
                member.TeamRole = ROLE_SNIPER
            else
                member.TeamRole = ROLE_SUPPORT
            end
        else
            member.TeamRole = ROLE_FOLLOWER
        end
        
        member.SquadLeader = self
    end
end

function ENT:LeaderThink()
    local enemy = self:GetEnemy()
    if not IsValid(enemy) then return end
    
    local enemyPos = enemy:GetPos()
    local myPos = self:GetPos()
    
    if #self.SquadMembers >= 2 and not self.SquadTactics.crossfire then
        self:OrderCrossfire(enemyPos)
    end
    
    if self.MoraleFactors.allies_nearby > 0 and self:Visible(enemy) then
        self:OrderPinDown(enemyPos)
    end
    
    if self.Morale <= MORALE_LOW then
        self:OrderRetreat()
    end
end

function ENT:OrderCrossfire(targetPos)
    self.SquadTactics.crossfire = true
    
    local leftFlank = targetPos + (targetPos - self:GetPos()):Cross(Vector(0,0,1)):GetNormalized() * 200
    local rightFlank = targetPos - (targetPos - self:GetPos()):Cross(Vector(0,0,1)):GetNormalized() * 200
    
    local assigned = 0
    for _, member in pairs(self.SquadMembers) do
        if assigned == 0 then
            member:ReceiveOrder("move_to", leftFlank)
            member.AssignedCoverSector = "left"
        elseif assigned == 1 then
            member:ReceiveOrder("move_to", rightFlank)
            member.AssignedCoverSector = "right"
        end
        assigned = assigned + 1
        if assigned >= 2 then break end
    end
end

function ENT:OrderPinDown(targetPos)
    self.SquadTactics.pindown = true
    
    for _, member in pairs(self.SquadMembers) do
        if member.TeamRole == ROLE_SUPPORT or member.TeamRole == ROLE_SNIPER then
            member:ReceiveOrder("suppress", targetPos)
        end
    end
end

function ENT:OrderRetreat()
    self.SquadTactics.retreat = true
    
    local retreatDir = (self:GetPos() - (self:GetEnemy() and self:GetEnemy():GetPos() or self:GetPos())):GetNormalized()
    local retreatPos = self:GetPos() + retreatDir * 500
    
    for _, member in pairs(self.SquadMembers) do
        member:ReceiveOrder("retreat", retreatPos)
    end
    
    self:ReceiveOrder("retreat", retreatPos)
end

function ENT:ReceiveOrder(orderType, data)
    self.SquadOrders = {type = orderType, data = data, time = CurTime()}
    self.LastOrderTime = CurTime()
    
    if orderType == "move_to" and data then
        self:SetLastPosition(data)
        self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH")
    elseif orderType == "suppress" and data then
        self:StartSuppressingFire(data)
    elseif orderType == "retreat" and data then
        self:StartRetreat(self:GetEnemy())
    elseif orderType == "hold" then
        self:HoldPosition(10)
    end
end

function ENT:FollowerThink()
    if not IsValid(self.SquadLeader) then return end
    
    if self.SquadOrders and CurTime() - self.LastOrderTime < 10 then
        return
    end
    
    local leaderDist = self:GetPos():Distance(self.SquadLeader:GetPos())
    if leaderDist > 400 then
        local followPos = self.SquadLeader:GetPos() + VectorRand() * 100
        self:SetLastPosition(followPos)
        self:SCHEDULE_GOTO_POSITION("TASK_WALK_PATH")
    end
end

function ENT:BroadcastToSquad(msgType, data)
    for _, member in pairs(self.SquadMembers) do
        if IsValid(member) then
            member:ReceiveSquadMessage(self, msgType, data)
        end
    end
end

function ENT:ReceiveSquadMessage(sender, msgType, data)
    if msgType == "taking_fire" then
        self:SetAwareness(AWARENESS_ALERTED)
        if data then
            self:AddSuspiciousPosition(data)
        end
    elseif msgType == "enemy_spotted" then
        if data and IsValid(data) then
            self:ForceSetEnemy(data)
        end
    elseif msgType == "need_support" then
        self.SupportingAlly = sender
    elseif msgType == "high_threat" then
        self.AdaptationLevel = math.max(self.AdaptationLevel, 5)
    end
end

function ENT:SoundAnalysisThink()
    if CurTime() - self.LastSoundAnalysis < 0.5 then return end
    self.LastSoundAnalysis = CurTime()
    
    if self.SoundAlertLevel > 0 then
        self.SoundAlertLevel = math.max(0, self.SoundAlertLevel - 1)
    end
    
    self:ProcessSoundMemory()
end

function ENT:ProcessSoundMemory()
    local currentTime = CurTime()
    
    for i = #self.SoundMemory, 1, -1 do
        local sound = self.SoundMemory[i]
        if currentTime - sound.time > 10 then
            table.remove(self.SoundMemory, i)
        end
    end
    
    if #self.SoundMemory >= 3 then
        self:AnalyzeSoundPattern()
    end
end

function ENT:AnalyzeSoundPattern()
    local footstepCount = 0
    local gunfireCount = 0
    local avgPos = Vector(0, 0, 0)
    
    for _, sound in pairs(self.SoundMemory) do
        if sound.type == "footstep" then
            footstepCount = footstepCount + 1
        elseif sound.type == "gunshot" then
            gunfireCount = gunfireCount + 1
        end
        avgPos = avgPos + sound.pos
    end
    
    if #self.SoundMemory > 0 then
        avgPos = avgPos / #self.SoundMemory
    end
    
    if footstepCount >= 3 then
        self.FootstepPatterns[tostring(avgPos)] = {
            pos = avgPos,
            count = footstepCount,
            direction = self:EstimateMovementDirection()
        }
        
        self:SetAwareness(AWARENESS_SUSPICIOUS)
    end
    
    if gunfireCount >= 2 then
        self:SetAwareness(AWARENESS_COMBAT)
        self:AddSuspiciousPosition(avgPos)
    end
end

function ENT:EstimateMovementDirection()
    if #self.SoundMemory < 2 then return Vector(0, 0, 0) end
    
    local first = self.SoundMemory[1].pos
    local last = self.SoundMemory[#self.SoundMemory].pos
    
    return (last - first):GetNormalized()
end

function ENT:IdentifyWeaponBySound(soundName)
    if string.find(soundName, "pistol") or string.find(soundName, "glock") or string.find(soundName, "usp") then
        return "pistol"
    elseif string.find(soundName, "shotgun") or string.find(soundName, "pump") then
        return "shotgun"
    elseif string.find(soundName, "rifle") or string.find(soundName, "ak") or string.find(soundName, "m4") then
        return "rifle"
    elseif string.find(soundName, "smg") or string.find(soundName, "mp5") then
        return "smg"
    end
    return "unknown"
end

function ENT:MakeCallout(calloutType, data)
    if CurTime() - self.LastCallout < 3 then return end
    self.LastCallout = CurTime()
    
    local calloutSounds = {
        enemy_spotted = {"vo/npc/male01/overhere01.wav", "vo/npc/male01/overthere01.wav"},
        reloading = {"vo/npc/male01/waitin03.wav"},
        covering = {"vo/npc/male01/question14.wav"},
        flanking = {"vo/npc/male01/squad_flank01.wav"},
        retreating = {"vo/npc/male01/runforyourlife01.wav"},
        grenade = self.SoundTbl_Grenade
    }
    
    local sounds = calloutSounds[calloutType]
    if sounds then
        self:PlayVox(sounds, 80)
    end
    
    self:BroadcastToSquad(calloutType, data)
end

function ENT:EnvironmentThink()
    if not self.IsSuspect then return end
    if CurTime() - self.LastEnvironmentScan < 2 then return end -- Check more often (User Request)
    self.LastEnvironmentScan = CurTime()
    
    if not self.EnvironmentScanned then
        self:ScanEnvironment()
    end
    
    if self.CanBarricade and self.BarricadeCount < self.MaxBarricades then
        self:TryBarricade()
    end
end

function ENT:ScanEnvironment()
    self.EnvironmentScanned = true
    
    for _, ent in pairs(ents.FindInSphere(self:GetPos(), 500)) do
        local class = ent:GetClass()
        
        if class:find("door") then
            self.KnownDoors[ent:EntIndex()] = {
                ent = ent,
                pos = ent:GetPos(),
                isOpen = false
            }
        elseif class == "func_breakable" or (class == "prop_physics" and ent:Health() > 0) then
            if string.find(ent:GetModel() or "", "window") then
                self.BrokenWindows[ent:EntIndex()] = {
                    ent = ent,
                    pos = ent:GetPos(),
                    broken = false
                }
            end
        elseif class == "prop_physics" then
            local model = ent:GetModel() or ""
            if string.find(model, "furniture") or string.find(model, "desk") or string.find(model, "table") then
                self.UsableProps[ent:EntIndex()] = {
                    ent = ent,
                    pos = ent:GetPos(),
                    canMove = true
                }
            end
        elseif class == "func_ladder" then
            self.KnownLadders[ent:EntIndex()] = {
                ent = ent,
                pos = ent:GetPos()
            }
        end
    end
end

function ENT:TryBarricade()
    if self.Surrendering or self.IsPanicking then return end
    if IsValid(self:GetEnemy()) and self:Visible(self:GetEnemy()) then return end
    
    local bestDoor = nil
    local bestScore = 0
    
    for _, doorData in pairs(self.KnownDoors) do
        if not IsValid(doorData.ent) then continue end
        if self.BarricadedDoors[doorData.ent:EntIndex()] then continue end
        
        local door = doorData.ent
        local dist = self:GetPos():Distance(door:GetPos())
        
        -- User Request: "Close doors more freq" -> Increased range (was 200)
        if dist > 350 then continue end
        
        local score = 100 - dist
        
        local enemy = self:GetEnemy()
        if IsValid(enemy) then
            local enemyDist = enemy:GetPos():Distance(door:GetPos())
            if enemyDist < dist then
                score = score + 50
            end
        end
        
        if score > bestScore then
            bestScore = score
            bestDoor = door
        end
    end
    
    if bestDoor then
        self:BarricadeDoor(bestDoor)
    end
end

function ENT:BarricadeDoor(door)
    if not IsValid(door) then return end
    
    self:SetLastPosition(door:GetPos())
    self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH", function(x)
        x.RunCode_OnFinish = function()
            if IsValid(self) and IsValid(door) then
                door:Fire("Close", "", 0)
                door:Fire("Lock", "", 0.5)
                
                self.BarricadedDoors[door:EntIndex()] = true
                self.BarricadeCount = self.BarricadeCount + 1
                
                self:EmitSound("doors/door_latch3.wav", 60)
                
                local prop = self:FindNearbyMovableProp()
                if IsValid(prop) then
                    self:PushPropAgainstDoor(prop, door)
                end
                
                -- User Request: "closing doors with traps"
                if self.CanSetTraps and self.TrapsPlaced < self.MaxTraps then
                    self:PlaceDoorTrap(door)
                end
            end
        end
    end)
end

function ENT:PlaceDoorTrap(door)
    if not IsValid(door) then return end
    if door.IsTrapped then return end
    
    door.IsTrapped = true
    door.TrappedBy = self
    self.TrapsPlaced = self.TrapsPlaced + 1
    
    self:EmitSound("weapons/c4/c4_plant.wav", 60)
    
    timer.Simple(2, function()
        if not IsValid(door) or not IsValid(self) then return end
        
        if math.random(1, 2) == 1 then
            local trap = ents.Create("trap_entity")
            if IsValid(trap) then
                local forward = door:GetForward()
                local toMe = (self:GetPos() - door:GetPos()):GetNormalized()
                if toMe:Dot(forward) < 0 then forward = -forward end
                
                local pos = door:GetPos() + forward * 40
                
                local tr = util.TraceLine({
                    start = pos + Vector(0,0,30),
                    endpos = pos - Vector(0,0,100),
                    mask = MASK_SOLID_BRUSHONLY
                })
                
                if tr.Hit then
                    trap:SetPos(tr.HitPos)
                    trap:SetAngles(Angle(0, math.random(0, 360), 0))
                    trap:SetOwner(self)
                    trap:Spawn()
                    trap:Activate()
                else
                    SafeRemoveEntity(trap)
                end
            end
        else
            self:PlaceTripwireTrap(door:GetPos() + door:GetForward() * 60)
        end
    end)
end

function ENT:PlaceTripwireTrap(centerPos)
    local floorTr = util.TraceLine({
        start = centerPos + Vector(0, 0, 20),
        endpos = centerPos - Vector(0, 0, 200),
        mask = MASK_SOLID_BRUSHONLY
    })
    local basePos = floorTr.Hit and floorTr.HitPos or centerPos
    local trapHeight = Vector(0, 0, 15) -- Ankle height

    local nearbyProps = ents.FindInSphere(basePos, 50)
    for _, ent in pairs(nearbyProps) do
        if IsValid(ent) and ent:GetClass():find("prop") then
            -- return -- Relaxed
        end
    end
    
    local bestLeft = nil
    local bestRight = nil
    local bestDist = 0
    local bestScore = 0
    
    for angle = 0, 315, 45 do
        local rad = math.rad(angle)
        local dir = Vector(math.cos(rad), math.sin(rad), 0)
        
        local trLeft = util.TraceLine({
            start = basePos + trapHeight,
            endpos = basePos + trapHeight + dir * 300,
            mask = MASK_SOLID_BRUSHONLY
        })
        
        local trRight = util.TraceLine({
            start = basePos + trapHeight,
            endpos = basePos + trapHeight - dir * 300,
            mask = MASK_SOLID_BRUSHONLY
        })
        
        if trLeft.Hit and trRight.Hit then
            local dist = trLeft.HitPos:Distance(trRight.HitPos)
            
            if dist > 50 and dist < 400 then
                local score = 0
                
                if dist > 60 and dist < 150 then -- Doorway size
                    score = score + 60
                elseif dist >= 150 and dist < 300 then
                    score = score + 40
                end
                
                local leftToCenter = (basePos - trLeft.HitPos):Length()
                local rightToCenter = (basePos - trRight.HitPos):Length()
                local centerBalance = math.abs(leftToCenter - rightToCenter)
                
                if centerBalance < 50 then
                    score = score + 30
                end
                
                if score > bestScore or (score == bestScore and dist > bestDist) then
                    bestScore = score
                    bestDist = dist
                    bestLeft = {
                        pos = trLeft.HitPos + trLeft.HitNormal * 3,
                        normal = trLeft.HitNormal,
                        angle = angle
                    }
                    bestRight = {
                        pos = trRight.HitPos + trRight.HitNormal * 3,
                        normal = trRight.HitNormal
                    }
                end
            end
        end
    end
    
    if not bestLeft or not bestRight then return end
    
    local stake = ents.Create("prop_physics")
    stake:SetModel("models/props_c17/TrapPropeller_Lever.mdl")
    stake:SetPos(bestLeft.pos)
    stake:SetAngles(bestLeft.normal:Angle() + Angle(90, 0, 0))
    stake:Spawn()
    local phys = stake:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
    end
    stake:SetCollisionGroup(COLLISION_GROUP_WORLD)
    
    local grenPos = bestRight.pos + (bestLeft.pos - bestRight.pos):GetNormalized() * 15
    grenPos.z = bestRight.pos.z -- Keep it at the same height as the trace
    
    local gren = ents.Create("murwep_grenade")
    gren:SetPos(grenPos)
    gren:SetAngles(Angle(0, bestLeft.angle, 0))
    gren:SetOwner(self)
    gren.PlayerOwner = self
    gren.OwnerTrap = self
    gren.StakeEnt = stake
    gren.StakeLimit = grenPos:Distance(bestLeft.pos) + 30
    gren:Spawn()
    
    local phys = gren:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
    end
    
    constraint.Rope(gren, stake, 0, 0, Vector(0, 0, 0), Vector(0, 0, 0), grenPos:Distance(bestLeft.pos), 100, 0, 1.5, "cable/cable2", false)
    
    gren:CallOnRemove("CleanStake", function()
        if IsValid(stake) then SafeRemoveEntity(stake) end
    end)
end

function ENT:FindNearbyMovableProp()
    for _, propData in pairs(self.UsableProps) do
        if IsValid(propData.ent) and propData.canMove then
            local dist = self:GetPos():Distance(propData.pos)
            if dist < 150 then
                return propData.ent
            end
        end
    end
    return nil
end

function ENT:PushPropAgainstDoor(prop, door)
    if not IsValid(prop) or not IsValid(door) then return end
    
    local phys = prop:GetPhysicsObject()
    if not IsValid(phys) then return end
    
    local pushDir = (door:GetPos() - prop:GetPos()):GetNormalized()
    phys:ApplyForceCenter(pushDir * 500)
    
    self.UsableProps[prop:EntIndex()].canMove = false
end

function ENT:TryBreakWindow(targetPos)
    for _, windowData in pairs(self.BrokenWindows) do
        if not IsValid(windowData.ent) or windowData.broken then continue end
        
        local window = windowData.ent
        local windowPos = window:GetPos()
        
        local toTarget = (targetPos - self:GetPos()):GetNormalized()
        local toWindow = (windowPos - self:GetPos()):GetNormalized()
        
        if toTarget:Dot(toWindow) > 0.7 then
            local dist = self:GetPos():Distance(windowPos)
            if dist < 100 then
                window:TakeDamage(100, self, self)
                windowData.broken = true
                return true
            end
        end
    end
    return false
end

function ENT:TryUseLadder()
    for _, ladderData in pairs(self.KnownLadders) do
        if not IsValid(ladderData.ent) then continue end
        
        local dist = self:GetPos():Distance(ladderData.pos)
        if dist < 100 then
            return true
        end
    end
    return false
end
