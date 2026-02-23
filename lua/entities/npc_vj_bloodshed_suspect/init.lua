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
    "vo/npc/male01/gotone.wav","vo/npc/male01/yeah02.wav","vo/npc/male01/likethat.wav","vo/npc/male01/notthemanithought01.wav","vo/npc/male01/notthemanithought02.wav","vo/npc/male01/yougotit02.wav"
}
ENT.SoundTbl_IdleVox = {
    "vo/npc/male01/question02.wav","vo/npc/male01/question05.wav"
}
ENT.SoundTbl_Grenade = {
    "vo/npc/male01/overthere01.wav","vo/npc/male01/overthere02.wav","vo/npc/male01/upthere01.wav","vo/npc/male01/upthere02.wav","vo/npc/male01/takecover02.wav"
}
ENT.StartHealth = 50
ENT.VJ_NPC_Class = {"CLASS_BLOODSHED_SUSPECT"}
ENT.TakeOnSightBeforeShoot = false
ENT.CanGetReactions = true
ENT.CantUseLean = false
ENT.ChaseEnemyAlways = false
ENT.ChaseEnemyWhenGoodSituation = true
ENT.CallForHelp = false
ENT.SightDistance = 2000
ENT.SightAngle = 150 
ENT.DeathAllyResponse = false
ENT.HearingDistance = 3000
ENT.BecomeEnemyToPlayer = true

ENT.CanFlinch = true
ENT.FlinchChance = 1
ENT.FlinchCooldown = false
ENT.AnimTbl_Flinch = {"vjges_flinch_phys_01", "vjges_flinch_phys_02"}

local TYPE_AGGRESSIVE  = "Aggressive"
local TYPE_CAUTIOUS    = "Cautious"
local TYPE_TACTICAL    = "Tactical"
local TYPE_COWARD      = "Coward"

local MORALE_HIGH      = 3
local MORALE_NORMAL    = 2
local MORALE_LOW       = 1
local MORALE_BROKEN    = 0

function ENT:CustomOnInitialize()
    local rand = math.random(1,100)
    if rand <= 15 then
        self.Personality = TYPE_AGGRESSIVE
    elseif rand <= 50 then
        self.Personality = TYPE_CAUTIOUS
    elseif rand <= 80 then
        self.Personality = TYPE_TACTICAL
    else
        self.Personality = TYPE_COWARD
    end

    self.UnsurrenderTime = CurTime()
    self.NextSuicideCheck = CurTime()
    self.SuicideAttempts = 0
    self.MaxSuicideAttempts = 3
    self.LastSuicideThought = 0
    self.LastSawEnemyTime = 0

    self.FakeSurrenderFactors = {
        player_looked_away_time = 0,
        player_distance_time = 0,
        player_has_nongun = false,
        last_player_attention = CurTime()
    }

    self.Morale = MORALE_NORMAL
    self.MoraleFactors = {
        allies_nearby = 0,
        enemies_nearby = 0,
        health_status = 1,
        witnessed_deaths = 0,
        time_in_combat = 0,
        suppression_level = 0
    }

    self.TacticalData = {
        last_cover_time = 0,
        last_flank_time = 0,
        last_suppress_time = 0,
        preferred_range = math.random(300, 800),
        accuracy_modifier = 1,
        reaction_time = 0.5
    }

    self:SetupPersonalityTraits()

    local skinCount = self:SkinCount()
    local randomSkin = math.random(0, skinCount - 1)
    self:SetSkin(randomSkin)
    self:SetSquad(tostring(math.random(1,50)))
    
    self.Surrendering = false
    self.NextLeanTime = CurTime()
    self.SearchCoverTime = CurTime()
    self.Weapon_Accuracy = math.Rand(0.5, 2)
    self.SuspectNPC = true
    self.CombatStartTime = 0
    self.LastSuppressionTime = 0
    self.NextLookAroundTime = CurTime()
    self.LookDirection = 0
    self.IsLookingAround = false
    self.NextSoundReactionTime = CurTime()
    self.LastHeardSoundPos = nil
    self.LastHeardSoundTime = 0
    self.SoundAlertLevel = 0

    for i = 0, self:GetNumBodyGroups() - 1 do
        local bodyGroupCount = self:GetBodygroupCount(i)
        local randomBodyGroup = math.random(0, bodyGroupCount - 1)
        self:SetBodygroup(i, randomBodyGroup)
    end

    self.SuppressionLevel = 0
    self.MaxSuppressionLevel = 100

    self.CanSetTraps = not self.DisableWandering and math.random(1, 3) == 1
    self.TrapsCount = 0
    self.MaxTraps = math.random(2, 4)
    self.NextTrapTime = CurTime() + math.random(5, 15)
    self.LastTrapPosition = Vector(0,0,0)

    self.HasGrenades = math.random(1, 4) == 1
    self.GrenadesCount = self.HasGrenades and math.random(1, 3) or 0
    self.NextGrenadeTime = CurTime()
    self.LastGrenadeTime = 0

    self.CanSetRetreatTraps = math.random(1, 3) == 1
    self.CanSetFloorTraps = not self.DisableWandering and math.random(1, 3) == 1
    self.FloorTrapsCount = 0
    self.MaxFloorTraps = math.random(1, 3)
    self.NextFloorTrapTime = CurTime() + math.random(10, 30)
    self.IsRetreating = false
    self.LastRetreatTime = 0
    
    self:SetupSoundSensitivity()

    self.Hotspots = {}
    self.NextPreplan = CurTime() + math.Rand(2,6)
    self.DidPreplan = false
    self.NextSpacingCheck = CurTime() + math.Rand(0.5,1.5)
    self.NextHotEnemy = CurTime() + 1
    self.NextUnplannedTime = CurTime() + math.Rand(3,6)
    self.LastIdleCheckPos = self:GetPos()
    self.LastIdleCheckTime = CurTime()
    self.NextIdleHideCheck = CurTime() + math.Rand(1,2)
    self.CautiousPatrol = math.random(1,100) <= 70
    self.NextVoxDamage = 0
    self.NextVoxContact = 0
    self.NextVoxFear = 0
    self.NextVoxSurrender = 0
    self.NextVoxKill = 0
    self.NextVoxIdle = CurTime() + math.Rand(30,60)
    self.NextVoxGrenade = 0
end

function ENT:StartTacticalRetreat(enemy)
    if not IsValid(enemy) then return end
    
    self.IsRetreating = true
    self.LastRetreatTime = CurTime()
    
    local retreatPos = self:FindRetreatRoute(enemy)
    if retreatPos then
        self:SetLastPosition(retreatPos)
        self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH", function(x)
            x.CanShootWhenMoving = true
            x.TurnData = {Type = VJ.FACE_ENEMY}
            x.RunCode_OnFinish = function()
                self:OnRetreatPositionReached()
            end
        end)
        
        timer.Simple(1, function()
            if IsValid(self) then
                self:TryCloseDoorBehind()
            end
        end)
        
        if self.CanSetRetreatTraps and math.random(1, 100) <= 60 then
            timer.Simple(math.Rand(1, 3), function()
                if IsValid(self) and self.IsRetreating then
                    self:SetRetreatTrap()
                end
            end)
        end
    end
end

function ENT:FindRetreatRoute(enemy)
    local myPos = self:GetPos()
    local enemyPos = enemy:GetPos()
    local retreatDir = (myPos - enemyPos):GetNormalized()
    
    local bestPos = nil
    local bestScore = -math.huge
    
    for i = 1, 12 do
        local angle = (i - 1) * 30 - 180
        local testDir = retreatDir:Angle()
        testDir:RotateAroundAxis(testDir:Up(), angle)
        
        for dist = 200, 600, 100 do
            local testPos = myPos + testDir:Forward() * dist
            
            local tr = util.TraceLine({
                start = myPos + Vector(0,0,32),
                endpos = testPos + Vector(0,0,32),
                filter = self,
                mask = MASK_NPCSOLID
            })
            
            if not tr.Hit and self:InNav(testPos) and testPos:Distance(myPos) > 180 then
                local score = self:EvaluateRetreatPosition(testPos, enemyPos)
                if score > bestScore then
                    bestScore = score
                    bestPos = testPos
                end
            end
        end
    end
    local nodes = self:GetNearbyNodes(900, 24)
    for _, np in ipairs(nodes) do
        local dir = (np - myPos):GetNormalized()
        if dir:Dot(retreatDir) > 0.2 and np:Distance(myPos) > 220 then
            local s = self:EvaluateRetreatPosition(np, enemyPos)
            if s > bestScore then bestScore = s bestPos = np end
        end
    end
    
    return bestPos
end

function ENT:EvaluateRetreatPosition(pos, enemyPos)
    local score = 0
    if not self:InNav(pos) then return -math.huge end
    
    local distance = pos:Distance(enemyPos)
    score = score + (distance * 0.12)
    
    local tr = util.TraceLine({
        start = pos + Vector(0,0,32),
        endpos = enemyPos + Vector(0,0,32),
        mask = MASK_SHOT
    })
    
    if tr.Hit then
        score = score + 70
    end
    
    local cornerScore = self:EvaluateCornerPosition(pos)
    score = score + cornerScore
    
    local nearbyDoors = ents.FindInSphere(pos, 150)
    for _, ent in pairs(nearbyDoors) do
        if IsValid(ent) and (ent:GetClass():find("door") or ent:GetClass():find("func_door")) then
            score = score + 35
        end
    end
    local allies = 0
    for _, a in pairs(ents.FindInSphere(pos, 250)) do
        if a ~= self and a.GetClass and a:GetClass() == self:GetClass() then allies = allies + 1 end
    end
    if allies >= 2 then score = score - 40 elseif allies == 1 then score = score - 10 end
    if pos:Distance(self:GetPos()) < 180 then score = score - 50 end
    if self:DoesLineBlockPath(self:GetPos(), pos) then score = score + 25 end
    
    return score
end

function ENT:TryCloseDoorBehind()
    local nearbyDoors = ents.FindInSphere(self:GetPos(), 100)
    
    for _, door in pairs(nearbyDoors) do
        if IsValid(door) and (door:GetClass():find("door") or door:GetClass():find("func_door")) then
            if door:GetInternalVariable("m_eDoorState") != 0 then
                door:Fire("Close", "", 0)
                if math.random(1,100) <= 35 then
                    door:Fire("Lock", "", 0)
                end
                break
            end
        end
    end
end

function ENT:SetRetreatTrap()
    local myPos = self:GetPos()
    local trapType = math.random(1, 2)
    
    if trapType == 1 then
        self:SetDoorwayTrap()
    else
        self:SetFloorTrapAtRetreat()
    end
end

function ENT:SetDoorwayTrap()
    local nearbyDoors = ents.FindInSphere(self:GetPos(), 200)
    
    for _, door in pairs(nearbyDoors) do
        if IsValid(door) and (door:GetClass():find("door") or door:GetClass():find("func_door")) then
            local doorPos = door:GetPos()
            local doorAngles = door:GetAngles()
            
            local trapPos = doorPos + doorAngles:Forward() * 80
            
            local tr = util.TraceLine({
                start = trapPos + Vector(0,0,50),
                endpos = trapPos - Vector(0,0,50),
                mask = MASK_SHOT
            })
            
            if tr.Hit then
                self:CreateQuickTrap(tr.HitPos + tr.HitNormal * 2, tr.Entity)
                return
            end
        end
    end
    
    local trapPos = self:GetPos() - self:GetForward() * 150
    local tr = util.TraceLine({
        start = trapPos + Vector(0,0,50),
        endpos = trapPos - Vector(0,0,50),
        mask = MASK_SHOT
    })
    
    if tr.Hit then
        self:CreateQuickTrap(tr.HitPos + tr.HitNormal * 2, tr.Entity)
    end
end

function ENT:CreateQuickTrap(pos, surface)
    local stakeData = self:FindGroundPosition(pos)
    if not stakeData then return end
    
    local grenadeData = self:FindQuickGrenadePosition(stakeData.pos)
    if not grenadeData then return end
    
    local trapGrenade = ents.Create("murwep_grenade")
    trapGrenade:SetPos(stakeData.pos)
    
    trapGrenade.PlayerOwner = self
    trapGrenade.OwnerTrap = self
    trapGrenade.F1 = tobool(math.random(0,1))
    trapGrenade.LimitDistance = stakeData.pos:Distance(grenadeData.pos) + 50
    
    trapGrenade:Spawn()
    
    if IsValid(stakeData.surface) and stakeData.surface != game.GetWorld() then
        trapGrenade:SetParent(stakeData.surface)
    end
    
    local anchor = ents.Create("prop_physics")
    anchor:SetModel("models/hunter/plates/plate.mdl")
    anchor:SetPos(grenadeData.pos)
    anchor:SetNotSolid(true)
    anchor:SetNoDraw(true)
    anchor:Spawn()
    anchor:GetPhysicsObject():EnableMotion(false)
    
    if IsValid(grenadeData.surface) and grenadeData.surface != game.GetWorld() then
        anchor:SetParent(grenadeData.surface)
    end
    
    trapGrenade.StakeEnt = anchor
    
    local distance = stakeData.pos:Distance(grenadeData.pos)
    local rope = constraint.Rope(trapGrenade, anchor, 0, 0, Vector(0, 0, 3), Vector(0, 0, 0), distance, 0, 0, 0.3, "cable/cable", false)
    trapGrenade.StakeConst = rope
end

function ENT:FindQuickGrenadePosition(stakePos)
    local directions = {
        Vector(1, 0, 0), Vector(-1, 0, 0),
        Vector(0, 1, 0), Vector(0, -1, 0)
    }
    
    for _, dir in pairs(directions) do
        for dist = 90, 180, 30 do
            local testPos = stakePos + dir * dist
            testPos.z = stakePos.z 
            
            
            local floorTr = util.TraceLine({
                start = testPos + Vector(0, 0, 20),
                endpos = testPos - Vector(0, 0, 50),
                mask = MASK_SHOT
            })
            
            if floorTr.Hit and floorTr.HitNormal.z > 0.8 then
                local floorPos = floorTr.HitPos + floorTr.HitNormal * 5
                
                if self:IsPositionClear(floorPos, 15) then
                    
                    if self:IsRopePathClear(stakePos, floorPos) and self:DoesLineBlockPath(stakePos, floorPos) then
                        return {
                            pos = floorPos,
                            surface = floorTr.Entity
                        }
                    end
                end
            end
        end
    end
    
    return nil
end
function ENT:FindQuickTrapConnection(startPos)
    local directions = {
        Vector(1, 0, 0), Vector(-1, 0, 0),
        Vector(0, 1, 0), Vector(0, -1, 0),
        Vector(0.7, 0.7, 0), Vector(-0.7, 0.7, 0),
        Vector(0.7, -0.7, 0), Vector(-0.7, -0.7, 0)
    }
    
    local bestConnection = nil
    local bestScore = 0
    
    for _, dir in pairs(directions) do
        for dist = 80, 200, 20 do
            local testPos = startPos + dir * dist
            
            local connectionCheck = self:ValidateRealisticConnection(startPos, testPos, dist)
            
            if connectionCheck.valid then
                local score = 10 + (dist / 10) 
                
                if self:DoesLineBlockPath(startPos, connectionCheck.finalPos) then
                    score = score + 20
                end
                
                if score > bestScore then
                    bestScore = score
                    bestConnection = connectionCheck
                end
            end
        end
    end
    
    return bestConnection
end

function ENT:OnRetreatPositionReached()
    self.IsRetreating = false
    
    local hidePos = self:FindHidingSpot()
    if hidePos then
        self:SetLastPosition(hidePos)
        self:SCHEDULE_GOTO_POSITION("TASK_WALK_PATH")
        self.TakeOnSightBeforeShoot = true
    end
end

function ENT:FindHidingSpot()
    local myPos = self:GetPos()
    local bestPos = nil
    local bestScore = 0
    
    for i = 1, 16 do
        local angle = i * 22.5
        local rad = math.rad(angle)
        local testPos = myPos + Vector(math.cos(rad) * 100, math.sin(rad) * 100, 0)
        
        local score = self:EvaluateHidingSpot(testPos)
        if score > bestScore then
            bestScore = score
            bestPos = testPos
        end
    end
    
    return bestScore > 30 and bestPos or nil
end

function ENT:EvaluateHidingSpot(pos)
    local score = 0
    
    local coverCount = 0
    for i = 0, 7 do
        local angle = i * 45
        local rad = math.rad(angle)
        local dir = Vector(math.cos(rad), math.sin(rad), 0)
        
        local tr = util.TraceLine({
            start = pos + Vector(0,0,32),
            endpos = pos + Vector(0,0,32) + dir * 80,
            mask = MASK_SHOT
        })
        
        if tr.Hit then
            coverCount = coverCount + 1
        end
    end
    
    score = score + (coverCount * 8)
    
    if coverCount >= 5 then
        score = score + 20
    end
    
    return score
end

function ENT:TrySetFloorTrap()
    if not self.CanSetFloorTraps or self.FloorTrapsCount >= self.MaxFloorTraps then return end
    if CurTime() < self.NextFloorTrapTime or IsValid(self:GetEnemy()) then return end
    
    local trapPos = self:FindFloorTrapPosition()
    if trapPos then
        self:SetFloorTrap(trapPos)
        self.FloorTrapsCount = self.FloorTrapsCount + 1
        self.NextFloorTrapTime = CurTime() + math.random(20, 60)
    end
end

function ENT:FindFloorTrapPosition()
    local myPos = self:GetPos()
    local bestPos = nil
    local bestScore = 0
    
    
    local doorPathPositions = self:FindDoorPathPositions()
    for _, pos in pairs(doorPathPositions) do
        local score = 95 + math.random(1, 15)
        if score > bestScore then
            bestScore = score
            bestPos = pos
        end
    end
    
    
    if bestScore < 90 then
        local corridorCenterPositions = self:FindCorridorCenterPositions()
        for _, pos in pairs(corridorCenterPositions) do
            local score = 85 + math.random(1, 10)
            if score > bestScore then
                bestScore = score
                bestPos = pos
            end
        end
    end
    
    
    if bestScore < 80 then
        local intersectionPositions = self:FindMainIntersectionPositions()
        for _, pos in pairs(intersectionPositions) do
            local score = 75 + math.random(1, 8)
            if score > bestScore then
                bestScore = score
                bestPos = pos
            end
        end
    end
    
    return bestScore > 70 and bestPos or nil
end

function ENT:FindDoorPathPositions()
    local positions = {}
    local myPos = self:GetPos()
    
    local nearbyDoors = ents.FindInSphere(myPos, 700)
    
    for _, door in pairs(nearbyDoors) do
        if IsValid(door) and (door:GetClass():find("door") or door:GetClass():find("func_door")) then
            local doorPos = door:GetPos()
            local doorAngles = door:GetAngles()
            local doorForward = doorAngles:Forward()
            
            
            local pathPositions = {
                doorPos + doorForward * 80,   
                doorPos - doorForward * 80,   
                doorPos + doorForward * 120,  
                doorPos - doorForward * 120,
            }
            
            for _, pos in pairs(pathPositions) do
                if self:IsMainWalkingPath(pos) then
                    table.insert(positions, pos)
                end
            end
        end
    end
    
    return positions
end

function ENT:IsMainWalkingPath(pos)
    
    
    
    local openDirections = 0
    local directions = {
        Vector(1, 0, 0), Vector(-1, 0, 0),
        Vector(0, 1, 0), Vector(0, -1, 0)
    }
    
    for _, dir in pairs(directions) do
        local tr = util.TraceLine({
            start = pos + Vector(0,0,32),
            endpos = pos + Vector(0,0,32) + dir * 120,
            mask = MASK_NPCSOLID
        })
        
        if not tr.Hit then
            openDirections = openDirections + 1
        end
    end
    
    
    if openDirections < 2 then
        return false
    end
    
    
    local minDistanceToWall = math.huge
    for _, dir in pairs(directions) do
        local wallDist = self:GetWallDistance(pos, dir)
        minDistanceToWall = math.min(minDistanceToWall, wallDist)
    end
    
    
    if minDistanceToWall < 60 then
        return false
    end
    
    
    local wallCount = 0
    for _, dir in pairs(directions) do
        local wallDist = self:GetWallDistance(pos, dir)
        if wallDist < 100 then
            wallCount = wallCount + 1
        end
    end
    
    
    if wallCount > 2 then
        return false
    end
    
    return true
end

function ENT:FindCorridorCenterPositions()
    local positions = {}
    local myPos = self:GetPos()
    
    for angle = 0, 360, 25 do
        for dist = 300, 700, 100 do
            local rad = math.rad(angle)
            local testPos = myPos + Vector(math.cos(rad) * dist, math.sin(rad) * dist, 0)
            
            if self:IsCorridorCenter(testPos) then
                table.insert(positions, testPos)
            end
        end
    end
    
    return positions
end

function ENT:IsCorridorCenter(pos)
    local directions = {
        {Vector(1, 0, 0), Vector(-1, 0, 0)},
        {Vector(0, 1, 0), Vector(0, -1, 0)}
    }
    
    for _, dirPair in pairs(directions) do
        local dist1 = self:GetWallDistance(pos, dirPair[1])
        local dist2 = self:GetWallDistance(pos, dirPair[2])
        local totalWidth = dist1 + dist2
        
        
        if totalWidth > 120 and totalWidth < 280 then
            
            local centerOffset = math.abs(dist1 - dist2)
            if centerOffset < totalWidth * 0.3 then  
                
                
                local perpDir1 = Vector(-dirPair[1].y, dirPair[1].x, 0)
                local perpDir2 = Vector(dirPair[1].y, -dirPair[1].x, 0)
                
                local length1 = self:GetCorridorLength(pos, perpDir1)
                local length2 = self:GetCorridorLength(pos, perpDir2)
                
                if length1 > 150 and length2 > 150 then
                    return true
                end
            end
        end
    end
    
    return false
end

function ENT:FindMainIntersectionPositions()
    local positions = {}
    local myPos = self:GetPos()
    
    for angle = 0, 360, 30 do
        for dist = 250, 600, 100 do
            local rad = math.rad(angle)
            local testPos = myPos + Vector(math.cos(rad) * dist, math.sin(rad) * dist, 0)
            
            if self:IsMainIntersection(testPos) then
                table.insert(positions, testPos)
            end
        end
    end
    
    return positions
end

function ENT:IsMainIntersection(pos)
    
    local directions = {
        Vector(1, 0, 0), Vector(-1, 0, 0),
        Vector(0, 1, 0), Vector(0, -1, 0)
    }
    
    local pathDirections = 0
    local pathLengths = {}
    
    for _, dir in pairs(directions) do
        
        local pathLength = 0
        for dist = 100, 400, 50 do
            local testPos = pos + dir * dist
            if self:IsMainWalkingPath(testPos) then
                pathLength = dist
            else
                break
            end
        end
        
        if pathLength > 150 then
            pathDirections = pathDirections + 1
            table.insert(pathLengths, pathLength)
        end
    end
    
    
    return pathDirections >= 3
end

function ENT:FindDoorFloorTrapPositions()
    local positions = {}
    local myPos = self:GetPos()
    
    
    local nearbyDoors = ents.FindInSphere(myPos, 900)
    
    for _, door in pairs(nearbyDoors) do
        if IsValid(door) and (door:GetClass():find("door") or door:GetClass():find("func_door")) then
            local doorPos = door:GetPos()
            local doorAngles = door:GetAngles()
            local doorForward = doorAngles:Forward()
            local doorRight = doorAngles:Right()
            
            
            local doorTrapPositions = {
                
                {pos = doorPos + doorForward * 50, type = "entrance", priority = 10},
                {pos = doorPos - doorForward * 50, type = "exit", priority = 10},
                
                
                {pos = doorPos + doorForward * 80 + doorRight * 30, type = "side", priority = 8},
                {pos = doorPos + doorForward * 80 - doorRight * 30, type = "side", priority = 8},
                {pos = doorPos - doorForward * 80 + doorRight * 30, type = "side", priority = 8},
                {pos = doorPos - doorForward * 80 - doorRight * 30, type = "side", priority = 8},
                
                
                {pos = doorPos, type = "threshold", priority = 12},
                
                
                {pos = doorPos + doorRight * 120, type = "ambush", priority = 9},
                {pos = doorPos - doorRight * 120, type = "ambush", priority = 9}
            }
            
            for _, trapData in pairs(doorTrapPositions) do
                
                if self:IsValidFloorTrapPosition(trapData.pos, door) then
                    trapData.door = door
                    table.insert(positions, trapData)
                end
            end
        end
    end
    
    return positions
end

function ENT:FindCorridorFloorTrapPositions()
    local positions = {}
    local myPos = self:GetPos()
    
    
    for i = 1, 32 do
        local angle = i * 11.25
        local rad = math.rad(angle)
        
        for dist = 250, 800, 75 do
            local testPos = myPos + Vector(math.cos(rad) * dist, math.sin(rad) * dist, 0)
            
            local corridorData = self:AnalyzeCorridorPosition(testPos)
            if corridorData.isCorridor then
                table.insert(positions, {
                    pos = testPos,
                    type = "corridor",
                    width = corridorData.width,
                    length = corridorData.length,
                    priority = 10 + math.min(corridorData.length / 50, 5)
                })
            end
        end
    end
    
    return positions
end

function ENT:AnalyzeCorridorPosition(pos)
    local directions = {
        {dir = Vector(1, 0, 0), opposite = Vector(-1, 0, 0)},
        {dir = Vector(0, 1, 0), opposite = Vector(0, -1, 0)}
    }
    
    local bestCorridor = {isCorridor = false, width = 0, length = 0}
    
    for _, dirPair in pairs(directions) do
        local wallDist1 = self:GetDistanceToWall(pos, dirPair.dir)
        local wallDist2 = self:GetDistanceToWall(pos, dirPair.opposite)
        local corridorWidth = wallDist1 + wallDist2
        
        
        if corridorWidth > 80 and corridorWidth < 350 then
            
            local perpDir1 = Vector(-dirPair.dir.y, dirPair.dir.x, 0)
            local perpDir2 = Vector(dirPair.dir.y, -dirPair.dir.x, 0)
            
            local length1 = self:GetCorridorLength(pos, perpDir1, corridorWidth)
            local length2 = self:GetCorridorLength(pos, perpDir2, corridorWidth)
            local totalLength = length1 + length2
            
            if totalLength > 200 then
                bestCorridor = {
                    isCorridor = true,
                    width = corridorWidth,
                    length = totalLength
                }
            end
        end
    end
    
    return bestCorridor
end

function ENT:GetDistanceToWall(pos, direction)
    local tr = util.TraceLine({
        start = pos + Vector(0,0,32),
        endpos = pos + Vector(0,0,32) + direction * 200,
        mask = MASK_SHOT
    })
    
    return tr.Hit and (tr.Fraction * 200) or 200
end

function ENT:GetCorridorLength(pos, direction, maxWidth)
    local length = 0
    
    for dist = 50, 500, 50 do
        local testPos = pos + direction * dist
        local testWidth = self:GetDistanceToWall(testPos, Vector(1,0,0)) + self:GetDistanceToWall(testPos, Vector(-1,0,0))
        local testWidth2 = self:GetDistanceToWall(testPos, Vector(0,1,0)) + self:GetDistanceToWall(testPos, Vector(0,-1,0))
        local minWidth = math.min(testWidth, testWidth2)
        
        if math.abs(minWidth - maxWidth) < 100 then
            length = dist
        else
            break
        end
    end
    
    return length
end

function ENT:FindCornerFloorTrapPositions()
    local positions = {}
    local myPos = self:GetPos()
    
    
    for i = 1, 24 do
        local angle = i * 15
        local rad = math.rad(angle)
        
        for dist = 200, 600, 100 do
            local testPos = myPos + Vector(math.cos(rad) * dist, math.sin(rad) * dist, 0)
            
            local cornerData = self:AnalyzeCornerPosition(testPos)
            if cornerData.isCorner then
                table.insert(positions, {
                    pos = testPos,
                    type = "corner",
                    cornerType = cornerData.type,
                    priority = cornerData.priority
                })
            end
        end
    end
    
    return positions
end

function ENT:AnalyzeCornerPosition(pos)
    local directions = {
        Vector(1, 0, 0), Vector(-1, 0, 0),
        Vector(0, 1, 0), Vector(0, -1, 0),
        Vector(0.7, 0.7, 0), Vector(-0.7, 0.7, 0),
        Vector(0.7, -0.7, 0), Vector(-0.7, -0.7, 0)
    }
    
    local wallCount = 0
    local openCount = 0
    local wallDirections = {}
    
    for _, dir in pairs(directions) do
        local tr = util.TraceLine({
            start = pos + Vector(0,0,32),
            endpos = pos + Vector(0,0,32) + dir * 100,
            mask = MASK_SHOT
        })
        
        if tr.Hit and tr.Fraction < 0.7 then
            wallCount = wallCount + 1
            table.insert(wallDirections, dir)
        else
            openCount = openCount + 1
        end
    end
    
    local cornerData = {isCorner = false, type = "none", priority = 0}
    
    
    if wallCount >= 3 and openCount >= 2 then
        cornerData = {isCorner = true, type = "inner", priority = 12}
    
    elseif wallCount >= 1 and wallCount <= 2 and openCount >= 5 then
        cornerData = {isCorner = true, type = "outer", priority = 8}
    
    elseif wallCount == 4 and openCount == 4 then
        cornerData = {isCorner = true, type = "turn", priority = 10}
    end
    
    return cornerData
end

function ENT:FindHiddenFloorTrapPositions()
    local positions = {}
    local myPos = self:GetPos()
    
    
    local nearbyObjects = ents.FindInSphere(myPos, 700)
    
    for _, obj in pairs(nearbyObjects) do
        if IsValid(obj) and (obj:GetClass() == "prop_physics" or obj:GetClass() == "prop_static") then
            local objBounds = obj:OBBMaxs() - obj:OBBMins()
            
            
            if objBounds:Length() > 60 then
                local objPos = obj:GetPos()
                local hiddenPositions = self:GetHiddenPositionsAroundObject(obj)
                
                for _, hiddenPos in pairs(hiddenPositions) do
                    if self:IsValidFloorTrapPosition(hiddenPos) then
                        table.insert(positions, {
                            pos = hiddenPos,
                            type = "hidden",
                            object = obj,
                            priority = 9
                        })
                    end
                end
            end
        end
    end
    
    return positions
end

function ENT:GetHiddenPositionsAroundObject(obj)
    local positions = {}
    local objPos = obj:GetPos()
    local objBounds = obj:OBBMaxs() - obj:OBBMins()
    local objAngles = obj:GetAngles()
    
    
    local hiddenSpots = {
        objPos + objAngles:Forward() * (objBounds.x/2 + 60),
        objPos - objAngles:Forward() * (objBounds.x/2 + 60),
        objPos + objAngles:Right() * (objBounds.y/2 + 60),
        objPos - objAngles:Right() * (objBounds.y/2 + 60),
        
        objPos + objAngles:Forward() * (objBounds.x/2 + 40) + objAngles:Right() * (objBounds.y/2 + 40),
        objPos + objAngles:Forward() * (objBounds.x/2 + 40) - objAngles:Right() * (objBounds.y/2 + 40),
        objPos - objAngles:Forward() * (objBounds.x/2 + 40) + objAngles:Right() * (objBounds.y/2 + 40),
        objPos - objAngles:Forward() * (objBounds.x/2 + 40) - objAngles:Right() * (objBounds.y/2 + 40)
    }
    
    for _, spot in pairs(hiddenSpots) do
        
        if self:IsPositionHiddenFromDirection(spot, obj) then
            table.insert(positions, spot)
        end
    end
    
    return positions
end

function ENT:IsPositionHiddenFromDirection(pos, blockingObj)
    local hiddenFromCount = 0
    local testDirections = {
        Vector(1, 0, 0), Vector(-1, 0, 0),
        Vector(0, 1, 0), Vector(0, -1, 0)
    }
    
    for _, dir in pairs(testDirections) do
        local tr = util.TraceLine({
            start = pos + dir * 150,
            endpos = pos,
            filter = blockingObj,
            mask = MASK_SHOT
        })
        
        if tr.Hit and tr.Entity == blockingObj then
            hiddenFromCount = hiddenFromCount + 1
        end
    end
    
    return hiddenFromCount >= 1
end

function ENT:FindIntersectionFloorTrapPositions()
    local positions = {}
    local myPos = self:GetPos()
    
    
    for i = 1, 20 do
        local angle = i * 18
        local rad = math.rad(angle)
        
        for dist = 300, 700, 100 do
            local testPos = myPos + Vector(math.cos(rad) * dist, math.sin(rad) * dist, 0)
            
            if self:IsPathIntersection(testPos) then
                local intersectionData = self:AnalyzeIntersection(testPos)
                table.insert(positions, {
                    pos = testPos,
                    type = "intersection",
                    pathCount = intersectionData.pathCount,
                    priority = 8 + intersectionData.pathCount
                })
            end
        end
    end
    
    return positions
end

function ENT:AnalyzeIntersection(pos)
    local directions = {
        Vector(1, 0, 0), Vector(-1, 0, 0),
        Vector(0, 1, 0), Vector(0, -1, 0),
        Vector(0.7, 0.7, 0), Vector(-0.7, 0.7, 0),
        Vector(0.7, -0.7, 0), Vector(-0.7, -0.7, 0)
    }
    
    local openPaths = 0
    
    for _, dir in pairs(directions) do
        local tr = util.TraceLine({
            start = pos + Vector(0,0,32),
            endpos = pos + Vector(0,0,32) + dir * 200,
            mask = MASK_NPCSOLID
        })
        
        if not tr.Hit then
            openPaths = openPaths + 1
        end
    end
    
    return {pathCount = openPaths}
end

function ENT:IsValidFloorTrapPosition(pos, relatedEnt)
    
    local tr = util.TraceLine({
        start = self:GetPos() + Vector(0,0,32),
        endpos = pos + Vector(0,0,32),
        filter = {self, relatedEnt},
        mask = MASK_NPCSOLID
    })
    
    if tr.Hit then return false end
    
    
    local floorTr = util.TraceLine({
        start = pos + Vector(0,0,50),
        endpos = pos - Vector(0,0,100),
        mask = MASK_SHOT
    })
    
    if not floorTr.Hit or floorTr.HitNormal.z < 0.7 then return false end
    
    
    local nearbyTraps = ents.FindInSphere(pos, 150)
    for _, ent in pairs(nearbyTraps) do
        if IsValid(ent) and (ent:GetClass() == "trap_entity" or ent:GetClass() == "murwep_grenade") then
            return false
        end
    end
    
    return true
end

function ENT:EvaluateAdvancedFloorTrapPosition(pos, positionType)
    local score = 0
    local posData = pos
    
    
    if type(pos) == "table" and pos.pos then
        posData = pos.pos
        
        
        if pos.priority then
            score = score + pos.priority * 5
        end
    else
        posData = pos
    end
    
    
    if positionType == "door" then
        score = score + 70  
        
        if type(pos) == "table" then
            
            if pos.type == "threshold" then
                score = score + 25  
            elseif pos.type == "entrance" or pos.type == "exit" then
                score = score + 20  
            elseif pos.type == "ambush" then
                score = score + 15  
            end
        end
        
    elseif positionType == "corridor" then
        score = score + 60  
        
        if type(pos) == "table" then
            
            if pos.width and pos.width < 200 then
                score = score + (200 - pos.width) / 10
            end
            
            
            if pos.length then
                score = score + math.min(pos.length / 20, 25)
            end
        end
        
    elseif positionType == "corner" then
        score = score + 50  
        
        if type(pos) == "table" and pos.cornerType then
            if pos.cornerType == "inner" then
                score = score + 20  
            elseif pos.cornerType == "turn" then
                score = score + 15  
            end
        end
        
    elseif positionType == "hidden" then
        score = score + 45  
        
        if type(pos) == "table" and pos.object then
            
            local objBounds = pos.object:OBBMaxs() - pos.object:OBBMins()
            score = score + math.min(objBounds:Length() / 15, 20)
        end
        
    elseif positionType == "intersection" then
        score = score + 40  
        
        if type(pos) == "table" and pos.pathCount then
            score = score + (pos.pathCount * 5)  
        end
        
    else 
        score = score + 15  
    end
    
    
    local trafficScore = self:EstimateTrafficAtPosition(posData)
    score = score + trafficScore
    
    
    if self:IsPositionIndoors(posData) then
        score = score + 25
    end
    
    
    local concealmentScore = self:EvaluateTrapConcealment(posData)
    score = score + concealmentScore
    
    
    local nearbyAllies = ents.FindInSphere(posData, 300)
    for _, ally in pairs(nearbyAllies) do
        if ally != self and ally:GetClass() == self:GetClass() then
            score = score - 15
        end
    end
    
    
    local tacticalScore = self:EvaluateTacticalAdvantage(posData)
    score = score + tacticalScore
    
    return score
end

function ENT:EstimateTrafficAtPosition(pos)
    local trafficScore = 0
    
    
    local openDirections = 0
    local directions = {
        Vector(1, 0, 0), Vector(-1, 0, 0),
        Vector(0, 1, 0), Vector(0, -1, 0)
    }
    
    for _, dir in pairs(directions) do
        local tr = util.TraceLine({
            start = pos + Vector(0,0,32),
            endpos = pos + Vector(0,0,32) + dir * 150,
            mask = MASK_NPCSOLID
        })
        
        if not tr.Hit then
            openDirections = openDirections + 1
        end
    end
    
    trafficScore = trafficScore + (openDirections * 8)
    
    
    local nearbyDoors = ents.FindInSphere(pos, 200)
    for _, door in pairs(nearbyDoors) do
        if IsValid(door) and door:GetClass():find("door") then
            local distance = pos:Distance(door:GetPos())
            trafficScore = trafficScore + math.max(0, 15 - distance/10)
        end
    end
    
    return trafficScore
end

function ENT:EvaluateTrapConcealment(pos)
    local concealmentScore = 0
    
    local lightLevel = VectorRand(0,1)
    local avgLight = (lightLevel.x + lightLevel.y + lightLevel.z) / 3
    concealmentScore = concealmentScore + math.max(0, 15 - avgLight * 30)
    
    local tr = util.TraceLine({
        start = pos + Vector(0,0,10),
        endpos = pos - Vector(0,0,50),
        mask = MASK_SHOT
    })
    
    if tr.Hit then
        local material = tr.MatType
        if material == MAT_DIRT or material == MAT_GRASS then
            concealmentScore = concealmentScore + 10  
        elseif material == MAT_CONCRETE or material == MAT_TILE then
            concealmentScore = concealmentScore + 5   
        end
    end
    
    
    local nearbyObjects = ents.FindInSphere(pos, 100)
    local smallObjectsCount = 0
    
    for _, obj in pairs(nearbyObjects) do
        if IsValid(obj) and obj:GetClass() == "prop_physics" then
            local bounds = obj:OBBMaxs() - obj:OBBMins()
            if bounds:Length() < 50 then  
                smallObjectsCount = smallObjectsCount + 1
            end
        end
    end
    
    concealmentScore = concealmentScore + math.min(smallObjectsCount * 3, 12)
    
    return concealmentScore
end

function ENT:EvaluateTacticalAdvantage(pos)
    local tacticalScore = 0
    
    
    local nearbyCovers = 0
    local coverPositions = {}
    
    for i = 0, 7 do
        local angle = i * 45
        local rad = math.rad(angle)
        local dir = Vector(math.cos(rad), math.sin(rad), 0)
        
        for dist = 100, 300, 50 do
            local coverPos = pos + dir * dist
            local coverTr = util.TraceLine({
                start = coverPos + Vector(0,0,32),
                endpos = pos + Vector(0,0,32),
                mask = MASK_SHOT
            })
            
            if coverTr.Hit then
                nearbyCovers = nearbyCovers + 1
                table.insert(coverPositions, coverPos)
                break
            end
        end
    end
    
    tacticalScore = tacticalScore + math.min(nearbyCovers * 3, 20)
    
    
    local hasGoodOverwatch = false
    for _, coverPos in pairs(coverPositions) do
        local overwatchTr = util.TraceLine({
            start = coverPos + Vector(0,0,64),
            endpos = pos + Vector(0,0,16),
            mask = MASK_SHOT
        })
        
        if not overwatchTr.Hit then
            hasGoodOverwatch = true
            break
        end
    end
    
    if hasGoodOverwatch then
        tacticalScore = tacticalScore + 15
    end
    
    return tacticalScore
end

function ENT:SetFloorTrap(pos)
    local posData = pos
    local relatedEntity = nil
    local trapType = "standard"
    
    
    if type(pos) == "table" then
        posData = pos.pos
        relatedEntity = pos.door or pos.object
        trapType = pos.type or "standard"
    end
    
    local tr = util.TraceLine({
        start = posData + Vector(0, 0, 50),
        endpos = posData - Vector(0, 0, 100),
        mask = MASK_SHOT
    })
    
    if not tr.Hit then return end
    
    local trapPos = tr.HitPos
    
    
    local trap = ents.Create("trap_entity")
    trap:SetPos(trapPos)
    trap:SetAngles(tr.HitNormal:Angle() + Angle(90,0,0))
    trap:SetOwner(self)
    
    if trapType == "door" then
        trap:SetSkin(1)  
    elseif trapType == "hidden" then
        trap:SetColor(Color(100, 80, 60, 255))  
        trap:SetMaterial("models/props_wasteland/rockgranite03b")
    end
    
    trap:Spawn()
    
    
    if IsValid(relatedEntity) and relatedEntity != game.GetWorld() then
        constraint.Weld(trap, relatedEntity, 0, 0, 0, true, false)
    else
        constraint.Weld(trap, tr.Entity, 0, tr.PhysicsBone, 0, true, false)
    end
    
    
    if trapType == "hidden" then
        self:EmitSound("weapons/slam/buttonclick.wav", 35, math.random(80, 90))  
    else
        self:EmitSound("weapons/slam/buttonclick.wav", 50, math.random(90, 110))
    end
    
    
    if trapType == "hidden" or trapType == "door" then
        
        self:AddCamouflageAroundTrap(trapPos)
    end
end

function ENT:GetCorridorDirection(pos)
    
    local directions = {
        Vector(1, 0, 0), Vector(0, 1, 0)
    }
    
    for _, dir in pairs(directions) do
        local dist1 = self:GetDistanceToWall(pos, dir)
        local dist2 = self:GetDistanceToWall(pos, -dir)
        local width = dist1 + dist2
        
        if width < 300 then  
            return dir:Angle()
        end
    end
    
    return nil
end

function ENT:AddCamouflageAroundTrap(pos)
    
    local camoObjects = {
        "models/props_junk/garbage_newspaper001a.mdl",
        "models/props_junk/garbage_bag001a.mdl",
        "models/props_c17/oildrum001_explosive.mdl"
    }
    
    for i = 1, math.random(1, 2) do
        local camoModel = camoObjects[math.random(1, #camoObjects)]
        local camoPos = pos + Vector(math.random(-30, 30), math.random(-30, 30), 5)
        
        local camo = ents.Create("prop_physics")
        camo:SetModel(camoModel)
        camo:SetPos(camoPos)
        camo:SetAngles(Angle(0, math.random(0, 360), 0))
        camo:Spawn()
        camo:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        
        
        camo:SetColor(Color(255, 255, 255, 180))
        camo:SetModelScale(0.7, 0)
        
        
        timer.Simple(math.random(300, 600), function()
            if IsValid(camo) then
                camo:Remove()
            end
        end)
    end
end

function ENT:SetFloorTrapAtRetreat()
    local myPos = self:GetPos()
    local trapPos = myPos - self:GetForward() * 100
    
    local tr = util.TraceLine({
        start = trapPos + Vector(0, 0, 50),
        endpos = trapPos - Vector(0, 0, 100),
        mask = MASK_SHOT
    })
    
    if tr.Hit then
        local trap = ents.Create("trap_entity")
        trap:SetPos(tr.HitPos)
        trap:SetAngles(tr.HitNormal:Angle() + Angle(90, 0, 0))
        trap:SetOwner(self)
        trap:Spawn()
        
        constraint.Weld(trap, tr.Entity, 0, tr.PhysicsBone, 0, true, false)
        
        self.LastTrapPosition = tr.HitPos
    end
end

function ENT:TrySetTrap()
    if not self.CanSetTraps or self.TrapsCount >= self.MaxTraps then return end
    if CurTime() < self.NextTrapTime or IsValid(self:GetEnemy()) then return end
    
    if self.DisableWandering or self.Surrendering then return end
    
    local myPos = self:GetPos()
    
    if self.LastTrapPosition and isvector(self.LastTrapPosition) and self.LastTrapPosition:Distance(myPos) < 200 then 
        return 
    end
    
    local trapPos = self:FindTrapPosition()
    if trapPos then
        self:SetTrap(trapPos)
        self.TrapsCount = self.TrapsCount + 1
        self.LastTrapPosition = trapPos
        self.NextTrapTime = CurTime() + math.random(60, 180)
    end
end

function ENT:FindTrapPosition()
    local myPos = self:GetPos()
    local bestPos = nil
    local bestScore = 0
    
    
    local doorPositions = self:FindDoorwayPositions()
    for _, pos in pairs(doorPositions) do
        local score = 100 + math.random(1, 20) 
        if score > bestScore then
            bestScore = score
            bestPos = pos
        end
    end
    
    
    if bestScore < 90 then
        local passagePositions = self:FindNarrowPassagePositions()
        for _, pos in pairs(passagePositions) do
            local score = 80 + math.random(1, 15)
            if score > bestScore then
                bestScore = score
                bestPos = pos
            end
        end
    end
    
    
    if bestScore < 70 then
        local corridorPositions = self:FindActiveCorridorPositions()
        for _, pos in pairs(corridorPositions) do
            local score = 70 + math.random(1, 10)
            if score > bestScore then
                bestScore = score
                bestPos = pos
            end
        end
    end
    
    return bestScore > 60 and bestPos or nil
end

function ENT:FindDoorwayPositions()
    local positions = {}
    local myPos = self:GetPos()
    
    local nearbyDoors = ents.FindInSphere(myPos, 600)
    
    for _, door in pairs(nearbyDoors) do
        if IsValid(door) and (door:GetClass():find("door") or door:GetClass():find("func_door")) then
            local doorPos = door:GetPos()
            local doorAngles = door:GetAngles()
            local doorForward = doorAngles:Forward()
            
            
            local doorwayPositions = {
                doorPos,  
                doorPos + doorForward * 20,   
                doorPos - doorForward * 20,   
            }
            
            for _, pos in pairs(doorwayPositions) do
                
                if self:IsActualDoorway(pos, door) then
                    table.insert(positions, pos)
                end
            end
        end
    end
    
    return positions
end

function ENT:IsActualDoorway(pos, door)
    
    local doorPos = door:GetPos()
    local doorAngles = door:GetAngles()
    local doorRight = doorAngles:Right()
    
    
    local leftWall = util.TraceLine({
        start = pos + Vector(0,0,32),
        endpos = pos + Vector(0,0,32) + doorRight * 60,
        mask = MASK_SHOT
    })
    
    local rightWall = util.TraceLine({
        start = pos + Vector(0,0,32),
        endpos = pos + Vector(0,0,32) - doorRight * 60,
        mask = MASK_SHOT
    })
    
    
    return leftWall.Hit and rightWall.Hit and leftWall.Fraction < 0.8 and rightWall.Fraction < 0.8
end

function ENT:FindNarrowPassagePositions()
    local positions = {}
    local myPos = self:GetPos()
    
    
    for angle = 0, 360, 15 do
        for dist = 200, 500, 50 do
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
    
    local directions = {
        {Vector(1, 0, 0), Vector(-1, 0, 0)},  
        {Vector(0, 1, 0), Vector(0, -1, 0)}   
    }
    
    for _, dirPair in pairs(directions) do
        local dist1 = self:GetWallDistance(pos, dirPair[1])
        local dist2 = self:GetWallDistance(pos, dirPair[2])
        local totalWidth = dist1 + dist2
        
        
        if totalWidth > 80 and totalWidth < 250 then
            
            local perpDist1 = self:GetWallDistance(pos, dirPair[1]:Angle():Right())
            local perpDist2 = self:GetWallDistance(pos, -dirPair[1]:Angle():Right())
            
            if perpDist1 > 100 or perpDist2 > 100 then
                return true
            end
        end
    end
    
    return false
end

function ENT:GetWallDistance(pos, direction)
    local tr = util.TraceLine({
        start = pos + Vector(0,0,32),
        endpos = pos + Vector(0,0,32) + direction * 200,
        mask = MASK_SHOT
    })
    
    return tr.Hit and (tr.Fraction * 200) or 200
end

function ENT:FindActiveCorridorPositions()
    local positions = {}
    local myPos = self:GetPos()
    
    
    for angle = 0, 360, 20 do
        for dist = 250, 600, 75 do
            local rad = math.rad(angle)
            local testPos = myPos + Vector(math.cos(rad) * dist, math.sin(rad) * dist, 0)
            
            if self:IsActiveCorridor(testPos) then
                table.insert(positions, testPos)
            end
        end
    end
    
    return positions
end

function ENT:IsActiveCorridor(pos)
    local directions = {
        {Vector(1, 0, 0), Vector(-1, 0, 0)},
        {Vector(0, 1, 0), Vector(0, -1, 0)}
    }
    
    for _, dirPair in pairs(directions) do
        local dist1 = self:GetWallDistance(pos, dirPair[1])
        local dist2 = self:GetWallDistance(pos, dirPair[2])
        local width = dist1 + dist2
        
        
        if width > 100 and width < 300 then
            
            local perpDir1 = Vector(-dirPair[1].y, dirPair[1].x, 0)
            local perpDir2 = Vector(dirPair[1].y, -dirPair[1].x, 0)
            
            local length1 = self:GetCorridorLength(pos, perpDir1)
            local length2 = self:GetCorridorLength(pos, perpDir2)
            local totalLength = length1 + length2
            
            
            if totalLength > 300 then
                return true
            end
        end
    end
    
    return false
end

function ENT:IsIndoors()
    local tr = util.TraceLine({
        start = self:GetPos() + Vector(0, 0, 32),
        endpos = self:GetPos() + Vector(0, 0, 500),
        mask = MASK_SHOT
    })
    
    return tr.Hit and tr.Fraction < 0.8
end

function ENT:IsPositionIndoors(pos)
    local tr = util.TraceLine({
        start = pos + Vector(0, 0, 32),
        endpos = pos + Vector(0, 0, 500),
        mask = MASK_SHOT
    })
    
    return tr.Hit and tr.Fraction < 0.8
end

function ENT:FindDoorTrapPositions()
    local positions = {}
    local myPos = self:GetPos()
    
    local nearbyDoors = ents.FindInSphere(myPos, 800)
    
    for _, door in pairs(nearbyDoors) do
        if IsValid(door) and (door:GetClass():find("door") or door:GetClass():find("func_door")) then
            local doorPos = door:GetPos()
            local doorAngles = door:GetAngles()
            local doorForward = doorAngles:Forward()
            local doorRight = doorAngles:Right()
            
            local doorPositions = {
                doorPos + doorForward * 100,
                doorPos - doorForward * 100,
                doorPos + doorRight * 80,
                doorPos - doorRight * 80,
                doorPos + doorForward * 60 + doorRight * 60,
                doorPos + doorForward * 60 - doorRight * 60,
                doorPos - doorForward * 60 + doorRight * 60,
                doorPos - doorForward * 60 - doorRight * 60
            }
            
            for _, pos in pairs(doorPositions) do
                
                local tr = util.TraceLine({
                    start = myPos + Vector(0,0,32),
                    endpos = pos + Vector(0,0,32),
                    filter = {self, door},
                    mask = MASK_NPCSOLID
                })
                
                if not tr.Hit then
                    
                    local floorTr = util.TraceLine({
                        start = pos + Vector(0,0,50),
                        endpos = pos - Vector(0,0,100),
                        mask = MASK_SHOT
                    })
                    
                    if floorTr.Hit and floorTr.HitNormal.z > 0.7 then
                        table.insert(positions, {pos = floorTr.HitPos + floorTr.HitNormal * 2, door = door})
                    end
                end
            end
        end
    end
    
    return positions
end

function ENT:FindCorridorTrapPositions()
    local positions = {}
    local myPos = self:GetPos()
    
    
    for i = 1, 24 do
        local angle = i * 15
        local rad = math.rad(angle)
        
        for dist = 200, 600, 50 do
            local testPos = myPos + Vector(math.cos(rad) * dist, math.sin(rad) * dist, 0)
            
            
            if self:IsCorridorPosition(testPos) then
                local floorTr = util.TraceLine({
                    start = testPos + Vector(0,0,50),
                    endpos = testPos - Vector(0,0,100),
                    mask = MASK_SHOT
                })
                
                if floorTr.Hit and floorTr.HitNormal.z > 0.7 then
                    table.insert(positions, floorTr.HitPos + floorTr.HitNormal * 2)
                end
            end
        end
    end
    
    return positions
end

function ENT:IsCorridorPosition(pos)
    local wallCount = 0
    local openCount = 0
    
    local directions = {
        Vector(1, 0, 0), Vector(-1, 0, 0),
        Vector(0, 1, 0), Vector(0, -1, 0)
    }
    
    for _, dir in pairs(directions) do
        local tr = util.TraceLine({
            start = pos + Vector(0,0,32),
            endpos = pos + Vector(0,0,32) + dir * 120,
            mask = MASK_SHOT
        })
        
        if tr.Hit and tr.Fraction < 0.6 then
            wallCount = wallCount + 1
        else
            openCount = openCount + 1
        end
    end
    
    
    return wallCount >= 2 and openCount >= 2
end

function ENT:FindPropTrapPositions()
    local positions = {}
    local myPos = self:GetPos()
    
    
    local nearbyProps = ents.FindInSphere(myPos, 700)
    
    for _, prop in pairs(nearbyProps) do
        if IsValid(prop) and (prop:GetClass() == "prop_physics" or prop:GetClass() == "prop_static") then
            local propBounds = prop:OBBMaxs() - prop:OBBMins()
            
            
            if propBounds:Length() > 80 then
                local propPos = prop:GetPos()
                local propAngles = prop:GetAngles()
                
                
                local hiddenPositions = {
                    propPos + propAngles:Forward() * (propBounds.x/2 + 40),
                    propPos - propAngles:Forward() * (propBounds.x/2 + 40),
                    propPos + propAngles:Right() * (propBounds.y/2 + 40),
                    propPos - propAngles:Right() * (propBounds.y/2 + 40)
                }
                
                for _, pos in pairs(hiddenPositions) do
                    
                    if self:IsPositionHiddenByProp(pos, prop) then
                        local floorTr = util.TraceLine({
                            start = pos + Vector(0,0,50),
                            endpos = pos - Vector(0,0,100),
                            mask = MASK_SHOT
                        })
                        
                        if floorTr.Hit and floorTr.HitNormal.z > 0.7 then
                            table.insert(positions, {pos = floorTr.HitPos + floorTr.HitNormal * 2, prop = prop})
                        end
                    end
                end
            end
        end
    end
    
    return positions
end

function ENT:IsPositionHiddenByProp(pos, prop)
    
    local directions = {
        Vector(1, 0, 0), Vector(-1, 0, 0),
        Vector(0, 1, 0), Vector(0, -1, 0)
    }
    
    local hiddenFromDirections = 0
    
    for _, dir in pairs(directions) do
        local tr = util.TraceLine({
            start = pos + Vector(0,0,32),
            endpos = pos + Vector(0,0,32) + dir * 200,
            filter = {self, prop},
            mask = MASK_SHOT
        })
        
        
        if IsValid(tr.Entity) and tr.Entity == prop then
            hiddenFromDirections = hiddenFromDirections + 1
        end
    end
    
    return hiddenFromDirections >= 1
end

function ENT:EvaluateAdvancedTrapPosition(pos, positionType)
    local score = 0
    local posData = pos
    
    
    if type(pos) == "table" and pos.pos then
        posData = pos.pos
    else
        posData = pos
    end
    
    
    if positionType == "door" then
        score = score + 60  
        
        
        if self:IsCorridorPosition(posData) then
            score = score + 30
        end
        
    elseif positionType == "corridor" then
        score = score + 45  
        
        
        local corridorLength = self:GetCorridorLength(posData)
        score = score + math.min(corridorLength / 10, 20)
        
    elseif positionType == "prop" then
        score = score + 40  
        
        
        if type(pos) == "table" and pos.prop then
            local propBounds = pos.prop:OBBMaxs() - pos.prop:OBBMins()
            score = score + math.min(propBounds:Length() / 20, 15)
        end
        
    else 
        score = score + 10  
    end
    
    
    local coverCount = 0
    local viewDirections = 0
    
    for i = 0, 7 do
        local angle = i * 45
        local rad = math.rad(angle)
        local dir = Vector(math.cos(rad), math.sin(rad), 0)
        
        local tr = util.TraceLine({
            start = posData + Vector(0,0,32),
            endpos = posData + Vector(0,0,32) + dir * 150,
            mask = MASK_SHOT
        })
        
        if tr.Hit then
            coverCount = coverCount + 1
        else
            viewDirections = viewDirections + 1
        end
    end
    
    
    if coverCount >= 3 and viewDirections >= 2 then
        score = score + 25
    end
    
    
    if self:IsIndoors() and self:IsPositionIndoors(posData) then
        score = score + 20  
    end
    
    
    local nearbyTraps = ents.FindInSphere(posData, 200)
    for _, ent in pairs(nearbyTraps) do
        if IsValid(ent) and (ent:GetClass() == "murwep_grenade" or ent:GetClass() == "trap_entity") then
            score = score - 30
        end
    end
    
    
    if self:IsPathIntersection(posData) then
        score = score + 20
    end
    score = score + self:GetHotspotScore(posData) * 0.5
    
    return score
end

function ENT:GetCorridorLength(pos)
    
    local directions = {
        Vector(1, 0, 0), Vector(-1, 0, 0),
        Vector(0, 1, 0), Vector(0, -1, 0)
    }
    
    local maxLength = 0
    
    for _, dir in pairs(directions) do
        local length = 0
        for dist = 50, 500, 50 do
            local testPos = pos + dir * dist
            if self:IsCorridorPosition(testPos) then
                length = dist
            else
                break
            end
        end
        maxLength = math.max(maxLength, length)
    end
    
    return maxLength
end

function ENT:IsPathIntersection(pos)
    
    local openDirections = 0
    
    local directions = {
        Vector(1, 0, 0), Vector(-1, 0, 0),
        Vector(0, 1, 0), Vector(0, -1, 0)
    }
    
    for _, dir in pairs(directions) do
        local tr = util.TraceLine({
            start = pos + Vector(0,0,32),
            endpos = pos + Vector(0,0,32) + dir * 200,
            mask = MASK_NPCSOLID
        })
        
        if not tr.Hit then
            openDirections = openDirections + 1
        end
    end
    
    return openDirections >= 3  
end

function ENT:SetTrap(pos)
    local posData = pos
    
    if type(pos) == "table" then
        posData = pos.pos
    end
    
    local stakeData = self:FindGroundPosition(posData)
    if not stakeData then return end
    
    local grenadeData = self:FindGrenadePosition(stakeData.pos)
    if not grenadeData then return end
    
    if not self:ValidateTrapSetup(stakeData.pos, grenadeData.pos) then return end
    
    local stake = ents.Create("prop_physics")
    stake:SetModel("models/props_c17/TrapPropeller_Lever.mdl")
    stake:SetPos(stakeData.pos)
    stake:SetAngles(Angle(0, 0, 90))
    stake:Spawn()
    stake:GetPhysicsObject():EnableMotion(false)
    stake:SetNotSolid(true)
    
    if IsValid(stakeData.surface) and stakeData.surface != game.GetWorld() then
        stake:SetParent(stakeData.surface)
    end
    
    local trapGrenade = ents.Create("murwep_grenade")
    trapGrenade:SetPos(grenadeData.pos)
    
    trapGrenade.PlayerOwner = self
    trapGrenade.OwnerTrap = self
    trapGrenade.StakeEnt = stake
    trapGrenade.F1 = tobool(math.random(0,1))
    trapGrenade.LimitDistance = stakeData.pos:Distance(grenadeData.pos) + 50
    
    trapGrenade:Spawn()
    
    if IsValid(grenadeData.surface) and grenadeData.surface != game.GetWorld() then
        trapGrenade:SetParent(grenadeData.surface)
    end
    
    local distance = stakeData.pos:Distance(grenadeData.pos)
    local rope = constraint.Rope(
        trapGrenade, stake, 
        0, 0, 
        Vector(0, 0, 5), Vector(0, 0, 5), 
        distance, 0, 0, 0.3, "cable/cable", false
    )
    trapGrenade.StakeConst = rope
    
    self:EmitSound("weapons/slam/buttonclick.wav", 45, math.random(90, 110))
end

function ENT:FindGroundPosition(centerPos)
    
    local testPositions = {
        centerPos,
        centerPos + Vector(30, 0, 0),
        centerPos + Vector(-30, 0, 0),
        centerPos + Vector(0, 30, 0),
        centerPos + Vector(0, -30, 0),
        centerPos + Vector(20, 20, 0),
        centerPos + Vector(-20, 20, 0),
        centerPos + Vector(20, -20, 0),
        centerPos + Vector(-20, -20, 0)
    }
    
    for _, testPos in pairs(testPositions) do
        
        local tr = util.TraceLine({
            start = testPos + Vector(0, 0, 50),
            endpos = testPos - Vector(0, 0, 100),
            mask = MASK_SHOT
        })
        
        if tr.Hit and tr.HitNormal.z > 0.8 then 
            local floorPos = tr.HitPos + tr.HitNormal * 5 
            
            
            if self:IsPositionClear(floorPos, 20) then
                return {
                    pos = floorPos,
                    surface = tr.Entity
                }
            end
        end
    end
    
    return nil
end

function ENT:FindGrenadePosition(stakePos)
    
    local stakeHeight = stakePos.z
    local bestPos = nil
    local bestScore = 0
    
    
    local directions = {
        Vector(1, 0, 0), Vector(-1, 0, 0),
        Vector(0, 1, 0), Vector(0, -1, 0),
        Vector(0.7, 0.7, 0), Vector(-0.7, 0.7, 0),
        Vector(0.7, -0.7, 0), Vector(-0.7, -0.7, 0)
    }
    
    for _, dir in pairs(directions) do
        for dist = 100, 250, 25 do
            local testPos = stakePos + dir * dist
            testPos.z = stakeHeight
            
            
            if not self:HasDirectLineOfSight(stakePos, testPos) then
                continue 
            end
            
            
            local floorTr = util.TraceLine({
                start = testPos + Vector(0, 0, 20),
                endpos = testPos - Vector(0, 0, 50),
                mask = MASK_SHOT
            })
            
            if floorTr.Hit and floorTr.HitNormal.z > 0.8 then
                local floorPos = floorTr.HitPos + floorTr.HitNormal * 5
                
                
                if not self:HasDirectLineOfSight(stakePos, floorPos) then
                    continue
                end
                
                
                if self:IsPositionClear(floorPos, 15) then
                    
                    if self:IsRopePathClear(stakePos, floorPos) then
                        
                        local score = self:ScoreGrenadePosition(stakePos, floorPos, dist)
                        if score > bestScore then
                            bestScore = score
                            bestPos = {
                                pos = floorPos,
                                surface = floorTr.Entity
                            }
                        end
                    end
                end
            end
        end
    end
    
    return bestPos
end

function ENT:HasDirectLineOfSight(startPos, endPos)
    
    local heights = {5, 10, 15} 
    
    for _, height in pairs(heights) do
        local checkStart = startPos + Vector(0, 0, height)
        local checkEnd = endPos + Vector(0, 0, height)
        
        local tr = util.TraceLine({
            start = checkStart,
            endpos = checkEnd,
            mask = MASK_SHOT
        })
        
        
        if tr.Hit and tr.Fraction < 0.95 then
            return false
        end
    end
    
    
    local hullTr = util.TraceHull({
        start = startPos + Vector(0, 0, 10),
        endpos = endPos + Vector(0, 0, 10),
        mins = Vector(-2, -2, -2),
        maxs = Vector(2, 2, 2),
        mask = MASK_SHOT
    })
    
    if hullTr.Hit and hullTr.Fraction < 0.95 then
        return false
    end
    
    return true
end

function ENT:IsPositionClear(pos, radius)
    
    local directions = {
        Vector(1, 0, 0), Vector(-1, 0, 0),
        Vector(0, 1, 0), Vector(0, -1, 0)
    }
    
    for _, dir in pairs(directions) do
        local tr = util.TraceLine({
            start = pos + Vector(0, 0, 10),
            endpos = pos + Vector(0, 0, 10) + dir * radius,
            mask = MASK_SHOT
        })
        
        if tr.Hit and tr.Fraction < 0.8 then
            return false 
        end
    end
    
    return true
end

function ENT:ScoreGrenadePosition(stakePos, grenadePos, distance)
    local score = 10
    
    
    local optimalDistance = 150
    local distancePenalty = math.abs(distance - optimalDistance) / 10
    score = score + math.max(0, 20 - distancePenalty)
    
    
    if self:DoesLineBlockPath(stakePos, grenadePos) then
        score = score + 30
    end
    
    
    local heightDiff = math.abs(stakePos.z - grenadePos.z)
    if heightDiff < 10 then
        score = score + 20
    end
    
    return score
end

function ENT:ValidateTrapSetup(stakePos, grenadePos)
    
    
    
    local distance = stakePos:Distance(grenadePos)
    if distance < 30 or distance > 300 then
        return false
    end
    
    
    local heightDiff = math.abs(stakePos.z - grenadePos.z)
    if heightDiff > 20 then
        return false
    end
    
    
    if not self:HasDirectLineOfSight(stakePos, grenadePos) then
        return false
    end
    
    
    if not self:VerifyNoWallsBetween(stakePos, grenadePos) then
        return false
    end
    
    
    if not self:IsRopePathClear(stakePos, grenadePos) then
        return false
    end
    
    
    if not self:DoesLineBlockPath(stakePos, grenadePos) then
        return false
    end
    
    return true
end

function ENT:VerifyNoWallsBetween(startPos, endPos)
    
    local steps = 10 
    
    for i = 1, steps - 1 do
        local t = i / steps
        local checkPos = LerpVector(t, startPos, endPos)
        
        
        local directions = {
            Vector(0, 0, 10),
            Vector(10, 0, 0), Vector(-10, 0, 0),
            Vector(0, 10, 0), Vector(0, -10, 0)
        }
        
        for _, dir in pairs(directions) do
            local tr = util.TraceLine({
                start = checkPos,
                endpos = checkPos + dir,
                mask = MASK_SHOT
            })
            
            if tr.Hit and tr.Fraction < 0.3 then
                
                if math.abs(tr.HitNormal.z) < 0.3 then 
                    return false
                end
            end
        end
    end
    
    return true
end

function ENT:IsRopePathClear(startPos, endPos)
    
    local ropeHeight = 10
    local checkStart = startPos + Vector(0, 0, ropeHeight)
    local checkEnd = endPos + Vector(0, 0, ropeHeight)
    
    
    local distance = startPos:Distance(endPos)
    local checkPoints = math.max(5, math.floor(distance / 25)) 
    
    for i = 0, checkPoints do
        local t = i / checkPoints
        local checkPos = LerpVector(t, checkStart, checkEnd)
        
        
        if not self:IsRopePointClear(checkPos, startPos, endPos) then
            return false
        end
        
        
        local wallCheck = util.TraceLine({
            start = checkPos,
            endpos = checkPos + Vector(0, 0, 1), 
            mask = MASK_SHOT
        })
        
        if wallCheck.Hit and wallCheck.StartSolid then
            return false 
        end
    end
    
    return true
end

function ENT:IsRopePointClear(checkPos, ropeStart, ropeEnd)
    
    local radius = 15 
    
    
    local directions = {
        Vector(0, 0, 10),   
        Vector(0, 0, -10),  
        Vector(5, 0, 0),    
        Vector(-5, 0, 0),   
        Vector(0, 5, 0),    
        Vector(0, -5, 0)    
    }
    
    for _, dir in pairs(directions) do
        local tr = util.TraceLine({
            start = checkPos,
            endpos = checkPos + dir,
            mask = MASK_SHOT
        })
        
        if tr.Hit and tr.Fraction < 0.8 then
            
            if math.abs(tr.HitNormal.z) < 0.9 then 
                return false
            end
        end
    end
    
    
    local nearbyEnts = ents.FindInSphere(checkPos, radius)
    for _, ent in pairs(nearbyEnts) do
        if self:IsObstructingEntity(ent) then
            return false
        end
    end
    
    
    local ropeDir = (ropeEnd - ropeStart):GetNormalized()
    local perpDir = Vector(-ropeDir.y, ropeDir.x, 0):GetNormalized()
    
    
    for _, side in pairs({perpDir, -perpDir}) do
        local tr = util.TraceLine({
            start = checkPos + side * 20,
            endpos = checkPos - side * 20,
            mask = MASK_SHOT
        })
        
        if tr.Hit and tr.Fraction < 0.5 then
            
            return false
        end
    end
    
    return true
end

function ENT:IsObstructingEntity(ent)
    if not IsValid(ent) then return false end
    
    local entClass = ent:GetClass()
    
    
    local ignoredClasses = {
        "player",
        "npc_vj_bloodshed_suspect",
        "npc_citizen",
        "weapon_",
        "item_",
        "env_",
        "info_",
        "light",
        "func_illusionary"
    }
    
    for _, ignored in pairs(ignoredClasses) do
        if string.find(entClass, ignored) then
            return false
        end
    end
    
    
    local obstructingClasses = {
        "prop_physics",
        "prop_static", 
        "func_door",
        "func_wall",
        "func_breakable",
        "prop_door_rotating"
    }
    
    for _, obstructing in pairs(obstructingClasses) do
        if string.find(entClass, obstructing) then
            
            local entBounds = ent:OBBMaxs() - ent:OBBMins()
            if entBounds:Length() > 30 then 
                return true
            end
        end
    end
    
    return false
end

function ENT:ScoreTrapConnection(stakePos, grenadePos, distance, connectionData)
    local score = 10
    
    
    local optimalDistance = 150
    local distancePenalty = math.abs(distance - optimalDistance) / 10
    score = score + math.max(0, 20 - distancePenalty)
    
    
    if self:DoesLineBlockPath(stakePos, grenadePos) then
        score = score + 30
    end
    
    
    local heightDiff = math.abs(stakePos.z - grenadePos.z)
    if heightDiff < 20 then
        score = score + 15
    end
    
    
    if self:IsConnectionHidden(stakePos, grenadePos) then
        score = score + 20
    end
    
    
    local visibility = self:GetConnectionVisibility(stakePos, grenadePos)
    if visibility > 0.7 then
        score = score - 10
    end
    
    return score
end

function ENT:GetConnectionVisibility(pos1, pos2)
    local midPoint = (pos1 + pos2) / 2
    local visibleAngles = 0
    local totalAngles = 8
    
    for i = 0, totalAngles - 1 do
        local angle = i * (360 / totalAngles)
        local rad = math.rad(angle)
        local viewDir = Vector(math.cos(rad), math.sin(rad), 0)
        
        local tr = util.TraceLine({
            start = midPoint + viewDir * 300,
            endpos = midPoint,
            mask = MASK_SHOT
        })
        
        if not tr.Hit or tr.Fraction > 0.8 then
            visibleAngles = visibleAngles + 1
        end
    end
    
    return visibleAngles / totalAngles
end

function ENT:FindBestTrapConnection(stakePos, relatedEntity)
    local bestConnection = nil
    local bestScore = 0
    
    
    local searchAngles = {}
    
    if IsValid(relatedEntity) and relatedEntity:GetClass():find("door") then
        
        local doorAngles = relatedEntity:GetAngles()
        local doorRight = doorAngles:Right()
        table.insert(searchAngles, doorRight:Angle().y)
        table.insert(searchAngles, (doorRight * -1):Angle().y)
    else
        
        for i = 0, 7 do
            table.insert(searchAngles, i * 45)
        end
    end
    
    for _, angle in pairs(searchAngles) do
        for dist = 80, 250, 20 do
            local rad = math.rad(angle)
            local checkDir = Vector(math.cos(rad), math.sin(rad), 0)
            local checkPos = stakePos + checkDir * dist
            
            local tr = util.TraceLine({
                start = stakePos + Vector(0, 0, 32),
                endpos = checkPos + Vector(0, 0, 32),
                mask = MASK_SHOT
            })
            
            if tr.Hit and dist > 60 then
                local score = 10 + (dist / 10)  
                
                
                if self:DoesLineBlockPath(stakePos, tr.HitPos) then
                    score = score + 30
                end
                
                
                if self:IsConnectionHidden(stakePos, tr.HitPos) then
                    score = score + 20
                end
                
                if score > bestScore then
                    bestScore = score
                    bestConnection = {
                        pos = tr.HitPos + tr.HitNormal * 2,
                        distance = dist,
                        attachTo = tr.Entity ~= game.GetWorld() and tr.Entity or nil
                    }
                end
            end
        end
    end
    
    return bestConnection
end

function ENT:DoesLineBlockPath(startPos, endPos)
    
    local midPoint = (startPos + endPos) / 2
    
    
    local lineDir = (endPos - startPos):GetNormalized()
    local perpDir = Vector(-lineDir.y, lineDir.x, 0)
    
    local tr1 = util.TraceLine({
        start = midPoint + Vector(0,0,32),
        endpos = midPoint + Vector(0,0,32) + perpDir * 100,
        mask = MASK_NPCSOLID
    })
    
    local tr2 = util.TraceLine({
        start = midPoint + Vector(0,0,32),
        endpos = midPoint + Vector(0,0,32) - perpDir * 100,
        mask = MASK_NPCSOLID
    })
    
    return not tr1.Hit or not tr2.Hit  
end

function ENT:IsConnectionHidden(startPos, endPos)
    
    local midPoint = (startPos + endPos) / 2
    local hiddenAngles = 0
    
    for i = 0, 3 do
        local angle = i * 90
        local rad = math.rad(angle)
        local viewDir = Vector(math.cos(rad), math.sin(rad), 0)
        
        local tr = util.TraceLine({
            start = midPoint + viewDir * 200,
            endpos = midPoint,
            mask = MASK_SHOT
        })
        
        if tr.Hit and tr.Fraction < 0.8 then
            hiddenAngles = hiddenAngles + 1
        end
    end
    
    return hiddenAngles >= 2  
end

function ENT:SetupSoundSensitivity()
    if self.Personality == TYPE_AGGRESSIVE then
        self.SoundReactionDistance = 1500
        self.SoundReactionChance = 0.7
    elseif self.Personality == TYPE_CAUTIOUS then
        self.SoundReactionDistance = 2500
        self.SoundReactionChance = 0.9
    elseif self.Personality == TYPE_TACTICAL then
        self.SoundReactionDistance = 2000
        self.SoundReactionChance = 0.8
    else
        self.SoundReactionDistance = 3000
        self.SoundReactionChance = 1.0
    end
end

function ENT:AddHotspot(pos, weight)
    if not self.Hotspots then self.Hotspots = {} end
    table.insert(self.Hotspots, {pos = pos, w = weight or 1, t = CurTime()})
    if #self.Hotspots > 30 then table.remove(self.Hotspots, 1) end
end

function ENT:DecayHotspots()
    if not self.Hotspots then return end
    local now = CurTime()
    local kept = {}
    for _, h in ipairs(self.Hotspots) do
        local dt = now - (h.t or now)
        h.w = (h.w or 1) * math.exp(-dt / 20)
        h.t = now
        if h.w > 0.2 then table.insert(kept, h) end
    end
    self.Hotspots = kept
end

function ENT:GetHotspotScore(pos)
    if not self.Hotspots then return 0 end
    local s = 0
    for _, h in ipairs(self.Hotspots) do
        local d = pos:Distance(h.pos)
        if d < 800 then s = s + (h.w or 1) * (1 - d / 800) * 50 end
    end
    return s
end

function ENT:InNav(pos)
    local trh = util.TraceHull({start = pos + Vector(0,0,2), endpos = pos + Vector(0,0,2), mins = Vector(-16,-16,0), maxs = Vector(16,16,72), mask = MASK_SHOT_HULL})
    if trh.Hit then return false end
    local tr = util.TraceLine({start = self:GetPos() + Vector(0,0,32), endpos = pos + Vector(0,0,32), filter = self, mask = MASK_NPCSOLID})
    return not tr.Hit
end

function ENT:GetNearbyNodes(radius, limit)
    local res = {}
    local center = self:GetPos()
    local tab = MuR and MuR.AI_Nodes or {}
    for i = 1, #tab do
        local p = tab[i]
        if center:DistToSqr(p) <= (radius or 600)^2 then
            local trh = util.TraceHull({start = p + Vector(0,0,2), endpos = p + Vector(0,0,2), mins = Vector(-16,-16,0), maxs = Vector(16,16,72), mask = MASK_SHOT_HULL})
            if not trh.Hit then table.insert(res, p) end
        end
        if limit and #res >= limit then break end
    end
    return res
end

function ENT:PreplanSetup()
    if self.DidPreplan then return end
    self.DidPreplan = true
    local candidates = {}
    local function add(list, t)
        for _, p in pairs(list or {}) do
            local pd = p.pos or p
            local sc = self:EvaluateAdvancedFloorTrapPosition(p, t) + self:GetHotspotScore(pd) * 0.3
            table.insert(candidates, {pos = p, score = sc, type = t})
        end
    end
    add(self:FindDoorFloorTrapPositions(), "door")
    add(self:FindCorridorFloorTrapPositions(), "corridor")
    add(self:FindCornerFloorTrapPositions(), "corner")
    add(self:FindHiddenFloorTrapPositions(), "hidden")
    add(self:FindIntersectionFloorTrapPositions(), "intersection")
    table.sort(candidates, function(a, b) return a.score > b.score end)
    local best = candidates[1]
    if best and best.score > 80 then
        self:SetFloorTrap(best.pos)
    end
    local ambush = self:FindHiddenPosition() or self:FindAdvanceCoverPosition(nil)
    if ambush then
        self:SetLastPosition(ambush)
        self:SCHEDULE_GOTO_POSITION("TASK_WALK_PATH", function(x) x.CanShootWhenMoving = false end)
    end
end

function ENT:MaintainSpacing()
    if self.NextSpacingCheck and CurTime() < self.NextSpacingCheck then return end
    self.NextSpacingCheck = CurTime() + math.Rand(0.8, 1.6)
    local nearby = ents.FindInSphere(self:GetPos(), 36)
    local cnt = 0
    local push = Vector(0, 0, 0)
    for _, a in pairs(nearby) do
        if a ~= self and a.GetClass and a:GetClass() == self:GetClass() then
            cnt = cnt + 1
            push = push + (self:GetPos() - a:GetPos())
        end
    end
    if cnt > 0 then
        push.z = 0
        if push:Length() > 0 then
            push = push:GetNormalized() * 64
            local target = self:GetPos() + push
            local tr = util.TraceLine({start = self:GetPos() + Vector(0,0,32), endpos = target + Vector(0,0,32), filter = self, mask = MASK_NPCSOLID})
            if not tr.Hit then
                self:SetLastPosition(target)
                self:SCHEDULE_GOTO_POSITION("TASK_WALK_PATH")
            end
        end
    end
end

function ENT:OnHearSound(data)
    if not data or not IsValid(data.Entity) or data.Entity == self then return end
    if CurTime() < self.NextSoundReactionTime then return end
    
    local soundPos = data.Pos
    local soundEnt = data.Entity
    local distance = self:GetPos():Distance(soundPos)
    
    if distance > self.SoundReactionDistance then return end
    
    local reactionChance = self.SoundReactionChance
    local soundType = "unknown"
    
    if soundEnt:IsPlayer() then
        if data.SoundLevel and data.SoundLevel > 100 then
            soundType = "gunshot"
            reactionChance = reactionChance + 0.3
        elseif data.SoundLevel and data.SoundLevel > 70 then
            soundType = "shout"
            reactionChance = reactionChance + 0.1
        else
            soundType = "movement"
        end
    elseif soundEnt:IsNPC() and soundEnt:GetClass() == self:GetClass() then
        soundType = "ally"
        reactionChance = reactionChance + 0.2
    end
    
    local distanceModifier = 1 - (distance / self.SoundReactionDistance)
    reactionChance = reactionChance * distanceModifier
    
    if self.Personality == TYPE_COWARD and soundType == "gunshot" then
        reactionChance = reactionChance + 0.4
    end
    
    if math.random() <= reactionChance then
        self:ReactToSound(soundPos, soundEnt, soundType, distance)
        self.NextSoundReactionTime = CurTime() + math.Rand(1, 3)
    end
end

function ENT:ReactToSound(soundPos, soundEnt, soundType, distance)
    self.LastHeardSoundPos = soundPos
    self.LastHeardSoundTime = CurTime()
    self:AddHotspot(soundPos, soundType == "gunshot" and 3 or 1)
    
    if soundType == "gunshot" then
        self.SoundAlertLevel = math.min(self.SoundAlertLevel + 50, 100)
        self:AddSuppression(15)
        
        if IsValid(ent) then self:AddHotspot(ent:GetPos(), 2) end
        if soundEnt:IsPlayer() and not IsValid(self:GetEnemy()) then
            self:UpdateEnemyMemory(soundEnt, soundPos)
            self:ForceSetEnemy(soundEnt)
        end
        
        self:CallNearAllyReaction("gunshotheard")
        
    elseif soundType == "shout" then
        self.SoundAlertLevel = math.min(self.SoundAlertLevel + 25, 100)
        
        if soundEnt:IsPlayer() and not IsValid(self:GetEnemy()) then
            self:UpdateEnemyMemory(soundEnt, soundPos)
        end
        if soundEnt:IsPlayer() then
            local d = self:GetPos():Distance(soundPos)
            local base = 0
            if self.Personality == TYPE_COWARD then base = 60 elseif self.Personality == TYPE_CAUTIOUS then base = 35 elseif self.Personality == TYPE_TACTICAL then base = 25 else base = 15 end
            if self.Morale == MORALE_BROKEN then base = base + 30 elseif self.Morale == MORALE_LOW then base = base + 15 end
            base = base + math.Clamp((800 - d) / 8, 0, 40)
            if math.random(1,100) <= math.min(95, base) then
                self:TrySurrender(false, soundEnt)
            end
        end
        
    elseif soundType == "movement" then
        self.SoundAlertLevel = math.min(self.SoundAlertLevel + 10, 100)
        
    elseif soundType == "ally" then
        if not IsValid(self:GetEnemy()) and soundEnt.LastHeardSoundPos then
            self:InvestigatePosition(soundEnt.LastHeardSoundPos)
        end
    end
    
    if not IsValid(self:GetEnemy()) and self.SoundAlertLevel > 30 then
        self:InvestigatePosition(soundPos)
    end
end

function ENT:InvestigatePosition(pos)
    if not pos then return end
    
    local investigatePos = pos + Vector(math.random(-100, 100), math.random(-100, 100), 0)
    self:AddHotspot(investigatePos, 1)
    self:SetLastPosition(investigatePos)
    self:SCHEDULE_GOTO_POSITION("TASK_WALK_PATH", function(x)
        x.CanShootWhenMoving = true
        x.ConstantlyFaceEnemy = false
    end)
    
    self.IsLookingAround = true
    self.NextLookAroundTime = CurTime() + 0.5
end

function ENT:LookAroundBehavior()
    if IsValid(self:GetEnemy()) then
        self.IsLookingAround = false
        return
    end

    if not self.DisableWandering then
        self.IsLookingAround = false
        return
    end
    
    if CurTime() < self.NextLookAroundTime then return end
    
    if not self.IsLookingAround and self.SoundAlertLevel > 20 then
        self.IsLookingAround = true
    end
    
    if self.IsLookingAround then
        self.NextLookAroundTime = CurTime() + math.Rand(1, 2)
        self.LookDirection = self.LookDirection + math.random(-90, 90)
        
        local lookAngle = Angle(0, self.LookDirection, 0)
        local lookPos = self:GetPos() + lookAngle:Forward() * 500
        
        self:SetAngles(lookAngle)
        
        if self.SoundAlertLevel > 0 then
            self.SoundAlertLevel = math.max(0, self.SoundAlertLevel - 2)
        end
        
        if self.SoundAlertLevel <= 10 then
            self.IsLookingAround = false
        end
    end
end

function ENT:SetupPersonalityTraits()
    if self.Personality == TYPE_AGGRESSIVE then
        self.InvestigateSoundMultiplier = 2
        self.TakeOnSightBeforeShoot = false
        self.DisableWandering = math.random(1,5) > 4
        self.ChaseEnemyAlways = math.random(1,3) == 1
        self.ChaseEnemyWhenGoodSituation = true
        self.TacticalData.reaction_time = 0.3
        self.TacticalData.accuracy_modifier = 1.2
        self.Morale = MORALE_HIGH
        
    elseif self.Personality == TYPE_CAUTIOUS then
        self.InvestigateSoundMultiplier = 0.5
        self.TakeOnSightBeforeShoot = math.random(1,2) == 1
        self.DisableWandering = math.random(1,4) > 3
        self.ChaseEnemyAlways = false
        self.ChaseEnemyWhenGoodSituation = math.random(1,3) == 1
        self.TacticalData.reaction_time = 0.7
        self.TacticalData.accuracy_modifier = 0.9
        
    elseif self.Personality == TYPE_TACTICAL then
        self.InvestigateSoundMultiplier = 1
        self.TakeOnSightBeforeShoot = math.random(1,3) == 1
        self.DisableWandering = math.random(1,6) > 5
        self.ChaseEnemyAlways = false
        self.ChaseEnemyWhenGoodSituation = true
        self.TacticalData.reaction_time = 0.5
        self.TacticalData.accuracy_modifier = 1.1
        self.TacticalData.preferred_range = math.random(400, 600)
        
    elseif self.Personality == TYPE_COWARD then
        self.InvestigateSoundMultiplier = 0.2
        self.TakeOnSightBeforeShoot = true
        self.DisableWandering = math.random(1,3) > 1
        self.ChaseEnemyAlways = false
        self.ChaseEnemyWhenGoodSituation = false
        self.TacticalData.reaction_time = 1.0
        self.TacticalData.accuracy_modifier = 0.6
        self.Morale = MORALE_LOW
    end

    if self.DisableWandering then
        timer.Simple(math.Rand(0.5, 2), function()
            if IsValid(self) and not IsValid(self:GetEnemy()) then
                self:FindAndTakeStrategicPosition()
            end
        end)
    end
end

function ENT:UpdateMorale()
    local oldMorale = self.Morale
    
    self.MoraleFactors.allies_nearby = 0
    self.MoraleFactors.enemies_nearby = 0
    
    for _, ent in pairs(ents.FindInSphere(self:GetPos(), 1000)) do
        if ent != self and ent:GetClass() == self:GetClass() and ent:Health() > 0 then
            if self:Visible(ent) then
                self.MoraleFactors.allies_nearby = self.MoraleFactors.allies_nearby + 1
            end
        elseif ent:IsPlayer() and ent:Alive() and self:Visible(ent) then
            self.MoraleFactors.enemies_nearby = self.MoraleFactors.enemies_nearby + 1
        end
    end
    
    self.MoraleFactors.health_status = self:Health() / self:GetMaxHealth()
    
    if IsValid(self:GetEnemy()) then
        if self.CombatStartTime == 0 then
            self.CombatStartTime = CurTime()
        end
        self.MoraleFactors.time_in_combat = CurTime() - self.CombatStartTime
    else
        self.CombatStartTime = 0
        self.MoraleFactors.time_in_combat = 0
    end
    
    local moraleScore = 2
    
    moraleScore = moraleScore + (self.MoraleFactors.allies_nearby * 0.3)
    moraleScore = moraleScore + (self.MoraleFactors.health_status * 0.5)
    
    moraleScore = moraleScore - (self.MoraleFactors.enemies_nearby * 0.3)
    moraleScore = moraleScore - (self.MoraleFactors.witnessed_deaths * 0.2)
    moraleScore = moraleScore - (self.MoraleFactors.time_in_combat / 60) * 0.3
    moraleScore = moraleScore - (self.SuppressionLevel / self.MaxSuppressionLevel) * 1.5
    
    if self.Personality == TYPE_AGGRESSIVE then
        moraleScore = moraleScore + 1
    elseif self.Personality == TYPE_COWARD then
        moraleScore = moraleScore - 0.5
    end
    
    if moraleScore >= 2.5 then
        self.Morale = MORALE_HIGH
    elseif moraleScore >= 1.5 then
        self.Morale = MORALE_NORMAL
    elseif moraleScore >= 0.5 then
        self.Morale = MORALE_LOW
    else
        self.Morale = MORALE_BROKEN
    end
    
    if oldMorale != self.Morale then
        self:OnMoraleChanged(oldMorale, self.Morale)
    end
end

function ENT:ShouldStartRetreat()
    if CurTime() - self.LastRetreatTime < 30 then return false end
    
    local retreatChance = 0
    
    if self:Health() < self:GetMaxHealth() * 0.4 then
        retreatChance = retreatChance + 40
    end
    
    if self.Morale == MORALE_LOW then
        retreatChance = retreatChance + 30
    elseif self.Morale == MORALE_BROKEN then
        retreatChance = retreatChance + 60
    end
    
    if self.MoraleFactors.enemies_nearby > self.MoraleFactors.allies_nearby + 1 then
        retreatChance = retreatChance + 25
    end
    
    if self.Personality == TYPE_COWARD then
        retreatChance = retreatChance + 20
    elseif self.Personality == TYPE_CAUTIOUS then
        retreatChance = retreatChance + 10
    end
    
    return math.random(1, 100) <= retreatChance
end

function ENT:OnMoraleChanged(oldMorale, newMorale)
    if newMorale == MORALE_BROKEN and not self.Surrendering then
        if math.random(1,10) <= 8 then
            self:TrySurrender(true)
        else
            self:Panic()
        end
    elseif newMorale == MORALE_LOW and oldMorale > MORALE_LOW then
        self.TakeOnSightBeforeShoot = true
    end
end

function ENT:FindAndTakeStrategicPosition()
    local myPos = self:GetPos()
    local bestPos = nil
    local bestScore = -math.huge
    
    
    if self.DisableWandering then
        bestPos = self:FindHiddenPosition()
        if bestPos then
            self:SetLastPosition(bestPos)
            self:SCHEDULE_GOTO_POSITION("TASK_WALK_PATH", function(x)
                x.CanShootWhenMoving = false
            end)
            return
        end
    end
    
    
    for i = 1, 16 do
        local angle = (i - 1) * 22.5
        for dist = 200, 800, 100 do
            local rad = math.rad(angle)
            local testPos = myPos + Vector(math.cos(rad) * dist, math.sin(rad) * dist, 0)
            
            local tr = util.TraceLine({
                start = myPos + Vector(0,0,32),
                endpos = testPos + Vector(0,0,32),
                filter = self,
                mask = MASK_NPCSOLID
            })
            
            if not tr.Hit then
                local score = self:EvaluateStrategicPosition(testPos)
                if score > bestScore then
                    bestScore = score
                    bestPos = testPos
                end
            end
        end
    end
    
    if bestPos and bestScore > 20 then
        self:SetLastPosition(bestPos)
        self:SCHEDULE_GOTO_POSITION("TASK_WALK_PATH", function(x)
            x.CanShootWhenMoving = false
        end)
    end
end

function ENT:FindHiddenPosition()
    local myPos = self:GetPos()
    local candidates = {}
    
    
    local nearbyProps = ents.FindInSphere(myPos, 1000)
    for _, prop in pairs(nearbyProps) do
        if IsValid(prop) and (prop:GetClass() == "prop_physics" or prop:GetClass():find("door")) then
            local propPos = prop:GetPos()
            local propBounds = prop:OBBMaxs() - prop:OBBMins()
            
            
            if propBounds:Length() > 80 then
                local hidePositions = self:GetHidePositionsAroundProp(prop)
                for _, pos in pairs(hidePositions) do
                    table.insert(candidates, {pos = pos, score = self:EvaluateHiddenPosition(pos, prop), type = "prop"})
                end
            end
        end
    end
    
    
    local wallCorners = self:FindWallCorners(myPos, 800)
    for _, corner in pairs(wallCorners) do
        table.insert(candidates, {pos = corner, score = self:EvaluateHiddenPosition(corner, nil), type = "corner"})
    end
    
    
    table.sort(candidates, function(a, b) return a.score > b.score end)
    
    
    if #candidates > 0 and candidates[1].score > 50 then
        return candidates[1].pos
    end
    
    return nil
end

function ENT:GetHidePositionsAroundProp(prop)
    local propPos = prop:GetPos()
    local propAngles = prop:GetAngles()
    local positions = {}
    
    
    local mins, maxs = prop:OBBMins(), prop:OBBMaxs()
    local propForward = propAngles:Forward()
    local propRight = propAngles:Right()
    
    
    local offsets = {
        propForward * (maxs.x + 40),      
        -propForward * (mins.x + 40),     
        propRight * (maxs.y + 40),        
        -propRight * (mins.y + 40),       
    }
    
    for _, offset in pairs(offsets) do
        local testPos = propPos + offset
        
        
        local tr = util.TraceLine({
            start = self:GetPos() + Vector(0,0,32),
            endpos = testPos + Vector(0,0,32),
            filter = {self, prop},
            mask = MASK_NPCSOLID
        })
        
        if not tr.Hit then
            table.insert(positions, testPos)
        end
    end
    
    return positions
end

function ENT:FindWallCorners(center, radius)
    local corners = {}
    
    
    for angle = 0, 360, 30 do
        local rad = math.rad(angle)
        local dir = Vector(math.cos(rad), math.sin(rad), 0)
        
        local tr1 = util.TraceLine({
            start = center + Vector(0,0,32),
            endpos = center + Vector(0,0,32) + dir * radius,
            mask = MASK_SHOT
        })
        
        if tr1.Hit then
            
            local perpDir = Vector(-dir.y, dir.x, 0)
            
            local tr2 = util.TraceLine({
                start = tr1.HitPos + perpDir * 20,
                endpos = tr1.HitPos + perpDir * 100,
                mask = MASK_SHOT
            })
            
            local tr3 = util.TraceLine({
                start = tr1.HitPos - perpDir * 20,
                endpos = tr1.HitPos - perpDir * 100,
                mask = MASK_SHOT
            })
            
            
            if tr2.Hit and not tr3.Hit then
                table.insert(corners, tr1.HitPos - perpDir * 50)
            elseif not tr2.Hit and tr3.Hit then
                table.insert(corners, tr1.HitPos + perpDir * 50)
            end
        end
    end
    
    return corners
end

function ENT:EvaluateHiddenPosition(pos, prop)
    local score = 0
    
    
    local coverDirections = 0
    local viewDirections = 0
    
    for i = 0, 7 do
        local angle = i * 45
        local rad = math.rad(angle)
        local dir = Vector(math.cos(rad), math.sin(rad), 0)
        
        local tr = util.TraceLine({
            start = pos + Vector(0,0,32),
            endpos = pos + Vector(0,0,32) + dir * 150,
            filter = {self, prop},
            mask = MASK_SHOT
        })
        
        if tr.Hit then
            coverDirections = coverDirections + 1
        else
            viewDirections = viewDirections + 1
        end
    end
    
    
    score = score + (coverDirections * 15)
    
    
    if viewDirections >= 2 then
        score = score + 20
    end
    
    
    if prop then
        score = score + 30
    end
    
    
    local hiddenFromPlayers = 0
    local testPoints = {
        pos + Vector(200, 0, 0),
        pos + Vector(-200, 0, 0),
        pos + Vector(0, 200, 0),
        pos + Vector(0, -200, 0),
        pos + Vector(150, 150, 0),
        pos + Vector(-150, 150, 0),
        pos + Vector(150, -150, 0),
        pos + Vector(-150, -150, 0)
    }
    
    for _, point in pairs(testPoints) do
        local tr = util.TraceLine({
            start = point + Vector(0,0,64),
            endpos = pos + Vector(0,0,32),
            mask = MASK_SHOT
        })
        
        if tr.Hit then
            hiddenFromPlayers = hiddenFromPlayers + 1
        end
    end
    
    score = score + (hiddenFromPlayers * 8)
    
    return score
end

function ENT:EvaluateStrategicPosition(pos)
    local score = 0
    if not self:InNav(pos) then return -math.huge end
    
    local heightDiff = pos.z - self:GetPos().z
    if heightDiff > 32 then
        score = score + 30
    end
    
    local coverCount = 0
    local directions = {
        Vector(1, 0, 0), Vector(-1, 0, 0),
        Vector(0, 1, 0), Vector(0, -1, 0),
        Vector(0.7, 0.7, 0), Vector(-0.7, 0.7, 0),
        Vector(0.7, -0.7, 0), Vector(-0.7, -0.7, 0)
    }
    
    for _, dir in pairs(directions) do
        local tr = util.TraceLine({
            start = pos + Vector(0, 0, 32),
            endpos = pos + Vector(0, 0, 32) + dir * 100,
            mask = MASK_SHOT
        })
        
        if tr.Hit then
            coverCount = coverCount + 1
        end
    end
    
    score = score + (coverCount * 5)
    
    local nearbyProps = ents.FindInSphere(pos, 150)
    for _, ent in pairs(nearbyProps) do
        if IsValid(ent) and (ent:GetClass() == "prop_physics" or ent:GetClass():find("door")) then
            local bounds = ent:OBBMaxs() - ent:OBBMins()
            if bounds:Length() > 60 then
                score = score + 15
            end
        end
    end
    
    local viewCount = 0
    for i = 0, 7 do
        local angle = i * 45
        local rad = math.rad(angle)
        local viewDir = Vector(math.cos(rad), math.sin(rad), 0)
        
        local tr = util.TraceLine({
            start = pos + Vector(0, 0, 64),
            endpos = pos + Vector(0, 0, 64) + viewDir * 500,
            mask = MASK_SHOT
        })
        
        if not tr.Hit or tr.Fraction > 0.8 then
            viewCount = viewCount + 1
        end
    end
    
    score = score + (viewCount * 3)
    score = score + self:GetHotspotScore(pos) * 0.4
    local allies = 0
    for _, a in pairs(ents.FindInSphere(pos, 128)) do
        if a ~= self and a.GetClass and a:GetClass() == self:GetClass() then allies = allies + 1 end
    end
    if allies >= 2 then score = score - 40 elseif allies == 1 then score = score - 10 end
    
    return score
end

function ENT:AddSuppression(amount)
    self.SuppressionLevel = math.Clamp(self.SuppressionLevel + amount, 0, self.MaxSuppressionLevel)
    self.LastSuppressionTime = CurTime()
    
    if self.SuppressionLevel > 50 then
        self.Weapon_Accuracy = self.TacticalData.accuracy_modifier * 0.5
        self.AnimTbl_WeaponAttack = ACT_HL2MP_IDLE_SCARED
    end
    
    if self.SuppressionLevel >= self.MaxSuppressionLevel then
        self:ForceDuck()
    end
end

function ENT:ReduceSuppression()
    if CurTime() - self.LastSuppressionTime > 3 then
        self.SuppressionLevel = math.max(0, self.SuppressionLevel - 5)
        if self.SuppressionLevel < 30 then
            self.Weapon_Accuracy = self.TacticalData.accuracy_modifier
            self.AnimTbl_WeaponAttack = ACT_RANGE_ATTACK1
        end
    end
end

function ENT:TacticalThink()
    local enemy = self:GetEnemy()
    if not IsValid(enemy) then return end
    
    local dist = self:GetPos():Distance(enemy:GetPos())
    local visible = self:Visible(enemy)
    
    if self.Morale >= MORALE_NORMAL and self.Personality == TYPE_TACTICAL then
        if dist > self.TacticalData.preferred_range * 1.5 then
            self:TacticalAdvance(enemy)
        elseif dist < self.TacticalData.preferred_range * 0.5 then
            self:TacticalRetreat(enemy)
        else
            if math.random(1,10) <= 3 then
                self:AttemptFlank(enemy)
            end
        end
    end
    
    if self.MoraleFactors.allies_nearby > 0 and visible and math.random(1,20) == 1 then
        self:SuppressingFire(enemy)
    end
end

function ENT:TacticalAdvance(enemy)
    local coverPos = self:FindAdvanceCoverPosition(enemy)
    if coverPos then
        self:SetLastPosition(coverPos)
        self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH", function(x) 
            x.CanShootWhenMoving = true 
            x.TurnData = {Type = VJ.FACE_ENEMY} 
        end)
    end
end

function ENT:TacticalRetreat(enemy)
    local coverPos = self:FindRetreatCoverPosition(enemy)
    if coverPos then
        self:SetLastPosition(coverPos)
        self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH", function(x) 
            x.CanShootWhenMoving = true 
            x.TurnData = {Type = VJ.FACE_ENEMY} 
        end)
    end
end

function ENT:AttemptFlank(enemy)
    if CurTime() - self.TacticalData.last_flank_time < 10 then return end
    
    local flankPos = self:FindFlankPosition(enemy)
    if flankPos then
        self.TacticalData.last_flank_time = CurTime()
        self:SetLastPosition(flankPos)
        self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH", function(x) 
            x.CanShootWhenMoving = false 
        end)
    end
end

function ENT:SuppressingFire(target)
    if CurTime() - self.TacticalData.last_suppress_time < 5 then return end
    
    self.TacticalData.last_suppress_time = CurTime()
    self:CallNearAllyReaction("suppressing")
    
    timer.Create("SuppressFire"..self:EntIndex(), 0.1, 30, function()
        if not IsValid(self) or not IsValid(self:GetActiveWeapon()) then 
            timer.Remove("SuppressFire"..self:EntIndex())
            return 
        end
        
        local wep = self:GetActiveWeapon()
        if wep:Clip1() > 0 then
        else
            timer.Remove("SuppressFire"..self:EntIndex())
        end
    end)
end

function ENT:PlayVox(tbl, vol, pit)
    if not tbl or #tbl == 0 then return end
    sound.Play(VJ_PICK(tbl), self:GetPos(), vol or 70, pit or math.random(95,105), 1)
end

function ENT:FindAdvancedCoverPosition(enemy, advancing)
    if not IsValid(enemy) then
        local myPos = self:GetPos()
        local bestPos = nil
        local bestScore = -math.huge
        
        for i = 0, 7 do
            local angle = i * 45
            for dist = 100, 400, 50 do
                local rad = math.rad(angle)
                local testPos = myPos + Vector(math.cos(rad) * dist, math.sin(rad) * dist, 0)
                local score = self:EvaluateAdvancedCoverPosition(testPos, myPos, false)
                
                if score > bestScore then
                    bestScore = score
                    bestPos = testPos
                end
            end
        end
        
        return bestPos
    end
    
    local enemyPos = enemy:GetPos()
    local myPos = self:GetPos()
    local direction
    
    if advancing then
        direction = (enemyPos - myPos):GetNormalized()
    else
        direction = (myPos - enemyPos):GetNormalized()
    end
    
    local bestPos = nil
    local bestScore = -math.huge
    
    local searchRadius = advancing and 400 or 600
    local angles = {}
    for i = 0, 7 do
        table.insert(angles, i * 45)
    end
    
    for _, angle in pairs(angles) do
        for dist = 100, searchRadius, 50 do
            local offset = direction:Angle()
            offset:RotateAroundAxis(offset:Up(), angle - 180)
            
            local testPos = myPos + offset:Forward() * dist
            local score = self:EvaluateAdvancedCoverPosition(testPos, enemyPos, advancing)
            
            if score > bestScore then
                bestScore = score
                bestPos = testPos
            end
        end
    end
    local nodes = self:GetNearbyNodes(searchRadius, 16)
    for _, np in ipairs(nodes) do
        local s = self:EvaluateAdvancedCoverPosition(np, enemyPos, advancing)
        if s > bestScore then bestScore = s bestPos = np end
    end
    
    return bestPos
end

function ENT:EvaluateAdvancedCoverPosition(pos, enemyPos, advancing)
    local score = 0
    if not self:InNav(pos) then return -math.huge end
    
    local tr = util.TraceLine({
        start = self:GetPos() + Vector(0,0,32),
        endpos = pos + Vector(0,0,32),
        filter = self,
        mask = MASK_NPCSOLID
    })
    
    if tr.Hit then return -math.huge end
    
    local coverTrace = util.TraceLine({
        start = pos + Vector(0,0,32),
        endpos = enemyPos + Vector(0,0,32),
        filter = self,
        mask = MASK_SHOT
    })
    
    if coverTrace.Hit then
        score = score + 100
        
        if IsValid(coverTrace.Entity) and not coverTrace.Entity:IsPlayer() and not coverTrace.Entity:IsNPC() then
            score = score + 50
        end
        
        local normal = coverTrace.HitNormal
        if math.abs(normal.z) < 0.3 then
            score = score + 30
        end
    end
    
    local cornerScore = self:EvaluateCornerPosition(pos)
    score = score + cornerScore
    
    local dist = pos:Distance(enemyPos)
    if advancing then
        score = score - math.abs(dist - self.TacticalData.preferred_range) * 0.1
    else
        score = score + (dist - self.TacticalData.preferred_range) * 0.1
    end
    
    local allyCount = 0
    for _, ally in pairs(ents.FindInSphere(pos, 200)) do
        if ally != self and ally.GetClass and ally:GetClass() == self:GetClass() then
            allyCount = allyCount + 1
        end
    end
    if allyCount == 1 then score = score + 5 elseif allyCount >= 2 then score = score - 35 end
    
    local nearbyProps = ents.FindInSphere(pos, 100)
    for _, prop in pairs(nearbyProps) do
        if IsValid(prop) and prop:GetClass() == "prop_physics" then
            local propBounds = prop:OBBMaxs() - prop:OBBMins()
            if propBounds:Length() > 50 then
                score = score + 25
            end
        end
    end
    
    return score + self:GetHotspotScore(pos) * 0.3
end

function ENT:EvaluateCornerPosition(pos)
    local score = 0
    local traces = {
        {Vector(1, 0, 0), Vector(0, 1, 0)},
        {Vector(-1, 0, 0), Vector(0, 1, 0)},
        {Vector(1, 0, 0), Vector(0, -1, 0)},
        {Vector(-1, 0, 0), Vector(0, -1, 0)}
    }
    
    for _, trace in pairs(traces) do
        local tr1 = util.TraceLine({
            start = pos + Vector(0, 0, 32),
            endpos = pos + Vector(0, 0, 32) + trace[1] * 80,
            mask = MASK_SHOT
        })
        
        local tr2 = util.TraceLine({
            start = pos + Vector(0, 0, 32),
            endpos = pos + Vector(0, 0, 32) + trace[2] * 80,
            mask = MASK_SHOT
        })
        
        if tr1.Hit and tr2.Hit then
            score = score + 40
        elseif tr1.Hit or tr2.Hit then
            score = score + 20
        end
    end
    
    return score
end

function ENT:FindAdvanceCoverPosition(enemy)
    return self:FindAdvancedCoverPosition(enemy, true)
end

function ENT:FindRetreatCoverPosition(enemy)
    return self:FindAdvancedCoverPosition(enemy, false)
end

function ENT:FindFlankPosition(enemy)
    local enemyPos = enemy:GetPos()
    local myPos = self:GetPos()
    local direction = (enemyPos - myPos):GetNormalized()
    local right = direction:Angle():Right()
    
    local positions = {
        myPos + right * 400,
        myPos - right * 400
    }
    
    local bestPos = nil
    local bestScore = -math.huge
    
    for _, pos in pairs(positions) do
        local score = self:EvaluateAdvancedCoverPosition(pos, enemyPos, true)
        if score > bestScore then
            bestScore = score
            bestPos = pos
        end
    end
    
    return bestPos
end

function ENT:EvaluateCoverPosition(pos, enemyPos, advancing)
    return self:EvaluateAdvancedCoverPosition(pos, enemyPos, advancing)
end

function ENT:Panic()
    self.IsPanicking = true
    self.PanicEndTime = CurTime() + math.random(5, 10)
    self.AnimTbl_WeaponAttack = ACT_HL2MP_IDLE_SCARED
    self.DisableChasingEnemy = true
    self.Weapon_Accuracy = self.TacticalData.accuracy_modifier * 0.3
    if CurTime() > (self.NextVoxFear or 0) then
        self:PlayVox(self.SoundTbl_Fear, 75)
        self.NextVoxFear = CurTime() + math.Rand(6,12)
    end
    
    timer.Create("Panic"..self:EntIndex(), 0.5, 0, function()
        if not IsValid(self) or CurTime() > self.PanicEndTime then
            timer.Remove("Panic"..self:EntIndex())
            self.IsPanicking = false
            self.AnimTbl_WeaponAttack = ACT_RANGE_ATTACK1
            self.DisableChasingEnemy = false
            return
        end
        
        local randomPos = self:GetPos() + Vector(math.random(-300,300), math.random(-300,300), 0)
        self:SetLastPosition(randomPos)
        self:VJ_TASK_GOTO_LASTPOS("TASK_RUN_PATH")
    end)
end

function ENT:TrySurrender(force, en)
    if self.Surrendering then return end
    
    local surrenderChance = 0
    local playerCount = #player.GetAll()
    
    if force then
        surrenderChance = 80
    else
        local baseChance = 0
        if self.Personality == TYPE_COWARD then
            baseChance = math.max(15, 40 - (playerCount * 3))
        elseif self.Personality == TYPE_CAUTIOUS then
            baseChance = math.max(8, 20 - (playerCount * 2))
        elseif self.Personality == TYPE_TACTICAL then
            baseChance = math.max(5, 15 - (playerCount * 1.5))
        else
            baseChance = math.max(2, 5 - playerCount)
        end
        
        surrenderChance = baseChance
        
        if self.Morale == MORALE_BROKEN then
            surrenderChance = surrenderChance + math.min(40, 20 + (playerCount * 2))
        elseif self.Morale == MORALE_LOW then
            surrenderChance = surrenderChance + math.min(25, 10 + playerCount)
        end
        
        if self:Health() < self:GetMaxHealth() * 0.3 then
            surrenderChance = surrenderChance + 20
        end
        
        if self.MoraleFactors.allies_nearby == 0 then
            surrenderChance = surrenderChance + math.min(30, 15 + (playerCount * 2))
        end
        
        if self.MoraleFactors.enemies_nearby > 2 then
            surrenderChance = surrenderChance + math.min(20, 10 + playerCount)
        end
    
        local nearbyPlayers = 0
        for _, ply in pairs(player.GetAll()) do
            if ply:Alive() and VJ.GetNearestDistance(self, ply) < 300 and self:Visible(ply) then
                nearbyPlayers = nearbyPlayers + 1
            end
        end
        
        if nearbyPlayers >= 2 then
            surrenderChance = surrenderChance + (nearbyPlayers * 8)
        end
        
        if nearbyPlayers >= 3 then
            surrenderChance = surrenderChance + 25
        end
    end
    
    surrenderChance = math.min(surrenderChance, 85)
    
    if math.random(1,100) <= surrenderChance then
        self.Surrendering = true
        self.SurrenderStartTime = CurTime()
        self.FakeSurrendering = self:DecideFakeSurrender()
        self:CallNearAllyReaction(self.FakeSurrendering and "fakesurrender" or "surrender")
        
        if en and IsValid(en) then
            self:ForceSetEnemy(en)
        end
    end
end

function ENT:DecideFakeSurrender()
    local fakeChance = 10
    local playerCount = #player.GetAll()
    
    if self.Personality == TYPE_AGGRESSIVE then
        fakeChance = math.max(30, 75 - (playerCount * 8))
    elseif self.Personality == TYPE_TACTICAL then
        fakeChance = math.max(15, 40 - (playerCount * 5))
    elseif self.Personality == TYPE_CAUTIOUS then
        fakeChance = math.max(8, 25 - (playerCount * 3))
    else
        fakeChance = math.max(3, 10 - playerCount)
    end
    
    if self.MoraleFactors.allies_nearby > 0 then
        fakeChance = fakeChance + math.min(15, self.MoraleFactors.allies_nearby * 3)
    end
    
    local nearbyPlayers = 0
    for _, ply in pairs(player.GetAll()) do
        if ply:Alive() and VJ.GetNearestDistance(self, ply) < 200 then
            nearbyPlayers = nearbyPlayers + 1
        end
    end
    
    if nearbyPlayers >= 3 then
        fakeChance = math.max(5, fakeChance - 20)
    end
    
    fakeChance = math.min(95, fakeChance + 5)
    return math.random(1,100) <= fakeChance
end

function ENT:UpdateFakeSurrenderFactors()
    if not self.Surrendering then return end
    
    local nearestPlayer = self:GetNearestPolice()
    if not IsValid(nearestPlayer) then return end
    
    local playerPos = nearestPlayer:GetPos()
    local myPos = self:GetPos()
    local distance = playerPos:Distance(myPos)
    
    
    local playerLookDir = nearestPlayer:GetAimVector()
    local playerToMe = (myPos - playerPos):GetNormalized()
    local lookDot = playerLookDir:Dot(playerToMe)
    
    
    local playerLookingAtMe = lookDot > 0.7
    
    if playerLookingAtMe and distance < 300 then
        self.FakeSurrenderFactors.last_player_attention = CurTime()
        self.FakeSurrenderFactors.player_looked_away_time = 0
        self.FakeSurrenderFactors.player_distance_time = 0
    else
        
        if not playerLookingAtMe then
            self.FakeSurrenderFactors.player_looked_away_time = CurTime() - self.FakeSurrenderFactors.last_player_attention
        end
        
        if distance > 300 then
            self.FakeSurrenderFactors.player_distance_time = CurTime() - self.FakeSurrenderFactors.last_player_attention
        end
    end
    
    
    local playerWeapon = nearestPlayer:GetActiveWeapon()
    if IsValid(playerWeapon) then
        local weaponClass = playerWeapon:GetClass()
        self.FakeSurrenderFactors.player_has_nongun = not string.find(weaponClass:lower(), "tfa_bs_")
    end
end

function ENT:CalculateFakeSurrenderChance()
    local baseChance = 14
    local situation_multiplier = 1
    
    
    if self.Personality == TYPE_AGGRESSIVE then
        baseChance = 75
    elseif self.Personality == TYPE_TACTICAL then
        baseChance = 50
    elseif self.Personality == TYPE_CAUTIOUS then
        baseChance = 30
    else 
        baseChance = 15
    end
    
    
    local factors = self.FakeSurrenderFactors
    
    
    if factors.player_looked_away_time > 2.0 then
        situation_multiplier = situation_multiplier + 0.9
        if factors.player_looked_away_time > 6 then
            situation_multiplier = situation_multiplier + 0.6
        end
    end
    
    
    if factors.player_distance_time > 3.0 then
        situation_multiplier = situation_multiplier + 0.7
        if factors.player_distance_time > 9 then
            situation_multiplier = situation_multiplier + 0.5
        end
    end
    
    
    if factors.player_has_nongun then
        situation_multiplier = situation_multiplier + 0.5
    end
    
    
    if self.Morale == MORALE_HIGH then
        situation_multiplier = situation_multiplier + 0.3
    elseif self.Morale == MORALE_LOW then
        situation_multiplier = situation_multiplier - 0.2
    elseif self.Morale == MORALE_BROKEN then
        situation_multiplier = situation_multiplier - 0.5
    end
    
    
    if self.MoraleFactors.allies_nearby > 0 then
        situation_multiplier = situation_multiplier + (self.MoraleFactors.allies_nearby * 0.2)
    end
    
    
    if self.SurrenderStartTime then
        local timeInSurrender = CurTime() - self.SurrenderStartTime
        if timeInSurrender > 10 then
            situation_multiplier = situation_multiplier + 0.3
        end
        if timeInSurrender > 30 then
            situation_multiplier = situation_multiplier + 0.4
        end
    end
    
    
    situation_multiplier = math.Clamp(situation_multiplier, 0.2, 3.5)
    
    local finalChance = baseChance * situation_multiplier
    return math.min(finalChance, 95)
end

function ENT:SurrenderLogic()
    if self.Surrendering then
        self.VJ_NPC_Class = {"CLASS_BLOODSHED_SUSPECT", "CLASS_BLOODSHED_CIVILIAN"}
        
        if !string.find(self:GetSequenceName(self:GetSequence()), "comply_start") then
            local np = self:GetNearestPolice()
            if IsValid(np) then
                local ang = (np:GetPos() - self:GetPos()):Angle()
                self:SetAngles(Angle(0, ang.y, 0))
            end
            self:SetState(VJ_STATE_FREEZE)
            if CurTime() > (self.NextVoxSurrender or 0) then
                self:PlayVox(self.SoundTbl_Surrender, 75)
                self.NextVoxSurrender = CurTime() + math.Rand(6,12)
            end
            self:PlayAnim("vjseq_sequence_ron_comply_start_0"..math.random(1,4), true, 999999)
            
            if IsValid(self:GetActiveWeapon()) then
                self.LastWeapon = self:GetActiveWeapon()
                self:DropWeapon(self.LastWeapon)
                self.TakeOnSightBeforeShoot = false
            end
        end
        
    if self.FakeSurrendering then
            self:UpdateFakeSurrenderFactors()
            
            local nearCops = self:CountNearbyPolice()
            local shouldFakeAttack = false
            
            if nearCops == 1 and VJ.GetNearestDistance(self, self:GetNearestPolice()) < 150 then
                shouldFakeAttack = true
            elseif nearCops == 0 and self.MoraleFactors.allies_nearby > 0 then
                shouldFakeAttack = true
            end
            
            if not shouldFakeAttack then
                local fakeChance = self:CalculateFakeSurrenderChance()
                
                if not self.NextFakeCheck then
                    self.NextFakeCheck = CurTime() + math.Rand(1.2, 2.2)
                end
                
                if CurTime() > self.NextFakeCheck then
                    self.NextFakeCheck = CurTime() + math.Rand(1.2, 2.2)
                    
                    if math.random(1, 100) <= fakeChance then
                        shouldFakeAttack = true
                    end
                end
            end
            local f = self.FakeSurrenderFactors or {}
            if not shouldFakeAttack then
                if (f.player_looked_away_time and f.player_looked_away_time > 1.2) or (f.player_distance_time and f.player_distance_time > 2.0) or f.player_has_nongun then
                    if math.random(1,100) <= 75 then shouldFakeAttack = true end
                end
            end
            
            if shouldFakeAttack then
                timer.Simple(math.Rand(0.5, 1.5), function()
                    if IsValid(self) and self.Surrendering then
                        self:FakeSurrenderUse()
                    end
                end)
            end
        end
        
        if self.UnsurrenderTime < CurTime() then
            self.Surrendering = false
        elseif self:NearCops(true) then
            self.UnsurrenderTime = CurTime() + math.Rand(4,16)
        end
    else
        self.UnsurrenderTime = CurTime() + math.Rand(4,16)
        self.VJ_NPC_Class = {"CLASS_BLOODSHED_SUSPECT"}
        
        if string.find(self:GetSequenceName(self:GetSequence()), "comply_start") then
            self:SetState(VJ_STATE_NONE)
            self:PlayAnim("vjseq_sequence_ron_comply_exit_0"..math.random(1,3), true, false)
            
            if IsValid(self.LastWeapon) then
                self:Give(self.LastWeapon:GetClass())
                self.LastWeapon:Remove()
            end
        end
    end
end

function ENT:OnLastAllyKilled()
    if self.MoraleFactors.allies_nearby == 0 and self.Personality != TYPE_AGGRESSIVE then
        self.SuicideAttempts = math.min(self.SuicideAttempts + 2, self.MaxSuicideAttempts)
        self.NextSuicideCheck = CurTime() + 2
    end
end

function ENT:CountNearbyPolice()
    local count = 0
    for _, ply in pairs(player.GetAll()) do
        if ply:Alive() and VJ.GetNearestDistance(self, ply) < 400 then
            count = count + 1
        end
    end
    return count
end

function ENT:NearCops(visible)
    for _, ply in pairs(player.GetAll()) do
        if not visible and ply:Alive() and VJ.GetNearestDistance(self, ply) < 100 then
            return true
        elseif visible and ply:Alive() and VJ.GetNearestDistance(self, ply) < 400 and self:Visible(ply) then
            return true
        end
    end
    return false
end

function ENT:StartResetLean()
    self:StartLean(0, 0, 0)
end

function ENT:FindRetreatPosition(enemy)
    if self.SearchCoverTime > CurTime() then return end

    self.SearchCoverTime = CurTime() + math.Rand(4,8)
    local pos = self:FindAdvancedCoverPosition(enemy, false)
    if not pos then
        pos = MuR and MuR:GetRandomPos(nil, self:GetPos(), 200, 600, true) or self:GetPos() + Vector(math.random(-400,400), math.random(-400,400), 0)
    end
    
    if isvector(pos) then
        self:SetLastPosition(pos)
        self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH", function(x) 
            x.CanShootWhenMoving = true 
            x.TurnData = {Type = VJ.FACE_ENEMY} 
        end)
    end
end

function ENT:GetNearestPolice()
    local nearest = nil
    local minDist = math.huge
    
    for _, ply in pairs(player.GetAll()) do
        if ply:Alive() then
            local dist = VJ.GetNearestDistance(self, ply)
            if dist < minDist then
                minDist = dist
                nearest = ply
            end
        end
    end
    
    return nearest
end

function ENT:UpdateLean()
    if not self.LeanStartTime then return end

    local elapsed = CurTime() - self.LeanStartTime
    local t = math.Clamp(elapsed / self.LeanDuration, 0, 1)

    local ang = Angle(
        Lerp(t, self.LeanInitialAngles.p, self.LeanTargetAngles.p),
        Lerp(t, self.LeanInitialAngles.y, self.LeanTargetAngles.y),
        Lerp(t, self.LeanInitialAngles.r, self.LeanTargetAngles.r)
    )

    local bone = self:LookupBone("ValveBiped.Bip01_Spine")
    if bone then
        self:ManipulateBoneAngles(bone, ang)
    end

    if t >= 1 then
        if bone then
            self:ManipulateBoneAngles(bone, self.LeanTargetAngles)
        end
        self.LeanStartTime = nil
        self.IsLeaning = false
    end
end

function ENT:CautionsLogic()
    local ply = self:GetEnemy()
    if not IsValid(ply) or not ply:IsPlayer() then
        self.TakeOnSightBeforeShootAngryTime = CurTime() + math.random(5,30)
        self.TakeCoverIfVisibleTime = CurTime() + math.Rand(2,10)
        return 
    end

    if self.TakeOnSightBeforeShoot then
        self.AnimTbl_WeaponAttack = ACT_HL2MP_IDLE_SCARED
        self.ConstantlyFaceEnemy = true

        if self.TakeCoverIfVisibleTime < CurTime() and self:Visible(ply) then
            local pos = self:FindAdvancedCoverPosition(ply, false)
            if pos then
                self:SetLastPosition(pos)
                self.TakeCoverIfVisibleTime = CurTime() + math.Rand(4,8)
                self:VJ_TASK_GOTO_LASTPOS("TASK_WALK_PATH", function(x)
                    x.CanShootWhenMoving = false
                    x.ConstantlyFaceEnemy = true
                end)
            end
        end

        if not self:Visible(ply) and self.TakeOnSightBeforeShootAngryTime - CurTime() > 5 then
            self.TakeOnSightBeforeShootAngryTime = CurTime() + math.Rand(1,5)
        elseif self.TakeOnSightBeforeShootAngryTime < CurTime() then
            self.TakeOnSightBeforeShoot = false
            self.AnimTbl_WeaponAttack = ACT_RANGE_ATTACK1
        end
        
        if self.Morale <= MORALE_LOW then
            if math.random(1,20) == 1 then
                self:TrySurrender(false, ply)
            end
        end
        
        if self:Health() < self:GetMaxHealth() * 0.3 then
            self:FindRetreatPosition(ply)
        end
    else
        self.AnimTbl_WeaponAttack = ACT_RANGE_ATTACK1
        self.ConstantlyFaceEnemy = false
    end
end

function ENT:FindCoverPosition(enemy)
    return self:FindAdvancedCoverPosition(enemy, false)
end

function ENT:IsSurrounded()
    local enemies = 0
    local directions = {
        Vector(1, 0, 0),
        Vector(-1, 0, 0),
        Vector(0, 1, 0),
        Vector(0, -1, 0)
    }
    
    for _, dir in pairs(directions) do
        local tr = util.TraceLine({
            start = self:GetPos() + Vector(0, 0, 32),
            endpos = self:GetPos() + Vector(0, 0, 32) + dir * 200,
            filter = self
        })
        
        if tr.Entity and tr.Entity:IsPlayer() then
            enemies = enemies + 1
        end
    end
    
    return enemies >= 3
end

function ENT:CheckSuicideConditions()
    if self.AlreadyUsedSuicide or self.Surrendering or not IsValid(self:GetActiveWeapon()) then 
        return false 
    end
    
    if CurTime() < self.NextSuicideCheck then 
        return false 
    end
    
    self.NextSuicideCheck = CurTime() + math.Rand(5, 10)
    
    local suicideChance = 0
    
    if self.Personality == TYPE_COWARD then
        suicideChance = suicideChance + 15
    elseif self.Personality == TYPE_AGGRESSIVE then
        suicideChance = suicideChance + 5
    elseif self.Personality == TYPE_CAUTIOUS then
        suicideChance = suicideChance + 10
    end
    
    if self.Morale == MORALE_BROKEN then
        suicideChance = suicideChance + 30
    elseif self.Morale == MORALE_LOW then
        suicideChance = suicideChance + 15
    end
    
    if self:Health() < self:GetMaxHealth() * 0.2 then
        suicideChance = suicideChance + 20
    elseif self:Health() < self:GetMaxHealth() * 0.4 then
        suicideChance = suicideChance + 10
    end
    
    if self.MoraleFactors.allies_nearby == 0 and self.MoraleFactors.enemies_nearby > 2 then
        suicideChance = suicideChance + 25
    end
    
    if self.MoraleFactors.time_in_combat > 120 then
        suicideChance = suicideChance + 15
    end
    
    if self.MoraleFactors.witnessed_deaths > 2 then
        suicideChance = suicideChance + 20
    end
    
    if self.SuppressionLevel > self.MaxSuppressionLevel * 0.8 then
        suicideChance = suicideChance + 15
    end
    
    if self:IsSurrounded() then
        suicideChance = suicideChance + 30
    end
    
    suicideChance = suicideChance - (self.SuicideAttempts * 20)
    
    return math.random(1, 100) <= suicideChance
end

function ENT:TryThrowGrenade()
    if not self.HasGrenades or self.GrenadesCount <= 0 then return end
    if CurTime() < self.NextGrenadeTime or self.Surrendering then return end
    
    local enemy = self:GetEnemy()
    if not IsValid(enemy) then return end
    
    local shouldThrow = self:EvaluateGrenadeThrow(enemy)
    if shouldThrow then
        self:ThrowGrenade(enemy)
    end
end

function ENT:EvaluateGrenadeThrow(enemy)
    local myPos = self:GetPos()
    local enemyPos = enemy:GetPos()
    local distance = myPos:Distance(enemyPos)
    
    if distance < 150 or distance > 600 then return false end
    
    local throwScore = 0
    
    if not self:Visible(enemy) and CurTime() - self.LastSawEnemyTime < 5 then
        throwScore = throwScore + 40
    end
    
    local nearbyEnemies = 0
    for _, ply in pairs(player.GetAll()) do
        if ply:Alive() and enemyPos:Distance(ply:GetPos()) < 200 then
            nearbyEnemies = nearbyEnemies + 1
        end
    end
    
    if nearbyEnemies >= 2 then
        throwScore = throwScore + 50
    elseif nearbyEnemies == 1 then
        throwScore = throwScore + 20
    end
    
    if self.Personality == TYPE_AGGRESSIVE then
        throwScore = throwScore + 30
    elseif self.Personality == TYPE_TACTICAL then
        throwScore = throwScore + 20
    elseif self.Personality == TYPE_CAUTIOUS then
        throwScore = throwScore + 10
    else
        throwScore = throwScore + 5
    end
    
    if self.Morale == MORALE_HIGH then
        throwScore = throwScore + 20
    elseif self.Morale == MORALE_LOW then
        throwScore = throwScore - 10
    elseif self.Morale == MORALE_BROKEN then
        throwScore = throwScore - 20
    end
    
    if self:Health() < self:GetMaxHealth() * 0.3 then
        throwScore = throwScore + 30
    end
    
    local timeSinceLastGrenade = CurTime() - self.LastGrenadeTime
    if timeSinceLastGrenade > 30 then
        throwScore = throwScore + 15
    end
    
    for _, ally in pairs(ents.FindInSphere(enemyPos, 250)) do
        if ally != self and ally:GetClass() == self:GetClass() then
            throwScore = throwScore - 40
        end
    end
    
    return throwScore > 60
end

function ENT:ThrowGrenade(target)
    if not IsValid(target) then return end
    
    local myPos = self:EyePos()
    local targetPos = target:GetPos() + Vector(0, 0, 32)
    
    local distance = myPos:Distance(targetPos)
    local throwDir = (targetPos - myPos):GetNormalized()
    
    if target:IsPlayer() then
        local targetVel = target:GetVelocity()
        local travelTime = distance / 500
        targetPos = targetPos + targetVel * travelTime
        throwDir = (targetPos - myPos):GetNormalized()
    end
    
    local lift = math.Clamp(distance / 300, 0.01, 0.2)
    throwDir.z = throwDir.z + lift
    throwDir = throwDir:GetNormalized()
    
    local grenade = ents.Create("murwep_grenade")
    grenade:SetPos(myPos + self:GetForward() * 32)
    grenade:Spawn()
    
    local phys = grenade:GetPhysicsObject()
    if IsValid(phys) then
        local throwForce = math.Clamp(distance * 2, 800, 1200)
        phys:SetVelocity(throwDir * throwForce)
        phys:AddAngleVelocity(Vector(math.random(-500, 500), math.random(-500, 500), math.random(-500, 500)))
    end
    
    grenade.PlayerOwner = self
    
    self.GrenadesCount = self.GrenadesCount - 1
    self.LastGrenadeTime = CurTime()
    self.NextGrenadeTime = CurTime() + math.random(15, 30)
    
    self:PlayAnim("idle_grenade", true, 1, false)
    
    self:EmitSound("weapons/slam/throw.wav", 70, math.random(95, 105))
    if CurTime() > (self.NextVoxGrenade or 0) then
        self:PlayVox(self.SoundTbl_Grenade, 70)
        self.NextVoxGrenade = CurTime() + math.Rand(6,12)
    end
    
    self:CallNearAllyReaction("grenadeout")
end

function ENT:OnThink()
    if self.NextPreplan and CurTime() > self.NextPreplan then
        self:PreplanSetup()
        self.NextPreplan = CurTime() + 9999
    end
    self:DecayHotspots()
    self:MaintainSpacing()
    if self.NextMoraleUpdate == nil or CurTime() > self.NextMoraleUpdate then
        self:UpdateMorale()
        self.NextMoraleUpdate = CurTime() + 1
    end
    
    self:ReduceSuppression()
    self:SurrenderLogic()
    self:LookAroundBehavior()
    self:IdleHideThink()
    
    if not self.Surrendering and not self.IsPanicking then
        self:TacticalThink()
    end
    
    if self.Personality == TYPE_CAUTIOUS then
        self:CautionsLogic()
    end
    
    if not self.TakeOnSightBeforeShoot and not self.Surrendering then
        self:CustomLean()
        self:UpdateLean()
        self:EvaluateChaseBehavior()
    end
    
    local en = self:GetEnemy()
    if IsValid(en) and en:IsPlayer() and en:IsFlagSet(FL_NOTARGET) then
        self:ResetEnemy()
        self:SetEnemy(en:GetRD())
    end
    if IsValid(en) then
        if CurTime() > (self.NextHotEnemy or 0) then
            self:AddHotspot(en:GetPos(), 1.5)
            self.NextHotEnemy = CurTime() + 1.25
        end
    end

    if IsValid(self:GetEnemy()) and not self.Surrendering then
        if self:CheckSuicideConditions() then
            if CurTime() - self.LastSuicideThought > 30 then
                self.LastSuicideThought = CurTime()
                self.SuicideAttempts = self.SuicideAttempts + 1
                
                if self.SuicideAttempts >= self.MaxSuicideAttempts then
                    self:Suicide()
                else
                    self:CallNearAllyReaction("suicidethought")
                end
            end
        end
    else
        if self.SuicideAttempts > 0 and CurTime() - self.LastSuicideThought > 60 then
            self.SuicideAttempts = math.max(0, self.SuicideAttempts - 1)
        end
    end

    self:TrySetTrap()
    self:TryThrowGrenade()
    self:TrySetFloorTrap()
    if not IsValid(self:GetEnemy()) and CurTime() > (self.NextVoxIdle or 0) and math.random(1,100) <= 5 then
        self:PlayVox(self.SoundTbl_IdleVox, 60)
        self.NextVoxIdle = CurTime() + math.Rand(40,80)
    end
    
    if IsValid(self:GetEnemy()) and not self.IsRetreating and not self.Surrendering then
        if self:ShouldStartRetreat() then
            self:StartTacticalRetreat(self:GetEnemy())
        end
    end
    self:UnplannedTacticsThink()
end

function ENT:IdleHideThink()
    if CurTime() < (self.NextIdleHideCheck or 0) then return end
    self.NextIdleHideCheck = CurTime() + math.Rand(1.5,3)
    if self.Surrendering or self.IsPanicking then return end
    if IsValid(self:GetEnemy()) then return end
    if not self.DisableWandering and self.SoundAlertLevel < 20 then return end
    local moved = self:GetPos():Distance(self.LastIdleCheckPos or self:GetPos())
    if moved > 6 then
        self.LastIdleCheckPos = self:GetPos()
        self.LastIdleCheckTime = CurTime()
        return
    end
    local stationary = CurTime() - (self.LastIdleCheckTime or CurTime()) > 2
    if not stationary then return end
    local curScore = self:EvaluateHiddenPosition(self:GetPos(), nil)
    if curScore >= 50 then return end
    local hidePos = self:FindHiddenPosition()
    if hidePos and self:InNav(hidePos) and hidePos:Distance(self:GetPos()) > 72 then
        self:SetLastPosition(hidePos)
        self:SCHEDULE_GOTO_POSITION("TASK_WALK_PATH", function(x) x.CanShootWhenMoving = false end)
        self.LastIdleCheckPos = hidePos
        self.LastIdleCheckTime = CurTime()
    end
end

function ENT:UnplannedTacticsThink()
    if CurTime() < (self.NextUnplannedTime or 0) then return end
    self.NextUnplannedTime = CurTime() + math.Rand(4,8)
    if self.Surrendering or self.IsPanicking then return end
    local enemy = self:GetEnemy()
    if IsValid(enemy) then
        local roll = math.random(1,4)
        if roll == 1 then
            local fp = self:FindFlankPosition(enemy)
            if fp and self:InNav(fp) then self:SetLastPosition(fp) self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH") end
        elseif roll == 2 then
            if self.CanSetTraps and math.random(1,2) == 1 then self:SetDoorwayTrap() end
        elseif roll == 3 then
            local dir = (self:GetRight() * (math.random(0,1)==1 and 1 or -1))
            local tp = self:GetPos() + dir * math.random(120,220)
            if self:InNav(tp) then self:SetLastPosition(tp) self:SCHEDULE_GOTO_POSITION("TASK_WALK_PATH") end
        else
            self:TryCloseDoorBehind()
        end
    else
        if self.SoundAlertLevel > 30 then
            local pos = self:FindHiddenPosition() or (MuR and MuR:GetRandomPos(nil, self:GetPos(), 200, 700, true))
            if pos and self:InNav(pos) then self:SetLastPosition(pos) self:SCHEDULE_GOTO_POSITION("TASK_WALK_PATH") end
        end
    end
end

function ENT:CustomOnTakeDamage_BeforeDamage(dmg, hg)
    local att = dmg:GetAttacker()
    
    self:AddSuppression(dmg:GetDamage() * 0.5)
    
    if self.TakeOnSightBeforeShoot and not self.Surrendering then
        if self.Morale <= MORALE_LOW or dmg:GetDamage() > 30 then
            self:TrySurrender(true)
        else
            self.TakeOnSightBeforeShoot = false
        end
    end
    
    if dmg:GetDamage() >= self:Health() then
        for _, ally in pairs(ents.FindInSphere(self:GetPos(), 500)) do
            if ally != self and ally:GetClass() == self:GetClass() and ally:Visible(self) then
                ally.MoraleFactors.witnessed_deaths = ally.MoraleFactors.witnessed_deaths + 1
            end
        end
    end

    if dmg:GetDamage() > self:Health() * 0.8 and not self.Surrendering then
        if self.Personality == TYPE_COWARD or self.Morale == MORALE_BROKEN then
            self.SuicideAttempts = self.MaxSuicideAttempts - 1
            self.NextSuicideCheck = CurTime() + 1
        end
    end
    if CurTime() > (self.NextVoxDamage or 0) then
        self:PlayVox(self.SoundTbl_Damage, 75)
        self.NextVoxDamage = CurTime() + math.Rand(2,4)
    end
end

function ENT:CallNearAllyReaction(type)
    if not isstring(type) then return end
    
    for _, ent in pairs(ents.FindInSphere(self:GetPos(), 512)) do
        if ent != self and ent:GetClass() == self:GetClass() and self:Visible(ent) and ent.CanGetReactions then
            
            if type == "surrender" and not ent.Surrendering then
                local chance = 0
                if ent.Personality == TYPE_COWARD then
                    chance = 70
                elseif ent.Personality == TYPE_CAUTIOUS then
                    chance = 40
                elseif ent.Personality == TYPE_TACTICAL then
                    chance = 20
                else
                    chance = 10
                end
                
                if ent.Morale <= MORALE_LOW then
                    chance = chance + 30
                end
                
                if math.random(1,100) <= chance then
                    ent.Surrendering = true
                    ent.FakeSurrendering = ent:DecideFakeSurrender()
                end
                
            elseif type == "fakesurrender" and not ent.Surrendering then
                if ent.Personality == TYPE_AGGRESSIVE or ent.Personality == TYPE_TACTICAL then
                    if math.random(1,100) <= 30 then
                        ent.Surrendering = true
                        ent.FakeSurrendering = true
                    end
                end
                
            elseif type == "attacksurrender" and ent.Surrendering then
                local chance = 0
                if ent.Personality == TYPE_AGGRESSIVE then
                    chance = 80
                elseif ent.Personality == TYPE_TACTICAL then
                    chance = 60
                elseif ent.Personality == TYPE_CAUTIOUS then
                    chance = 30
                else
                    chance = 10
                end
                
                if math.random(1,100) <= chance then
                    timer.Simple(math.Rand(0.1,1), function()
                        if IsValid(ent) and ent.Surrendering then
                            ent:FakeSurrenderUse()
                        end
                    end)
                end
                
            elseif type == "fullsurrender" and not ent.Surrendering then
                local chance = 0
                if ent.Personality == TYPE_COWARD then
                    chance = 90
                elseif ent.Personality == TYPE_CAUTIOUS then
                    chance = 70
                elseif ent.Personality == TYPE_TACTICAL then
                    chance = 50
                else
                    chance = 30
                end
                
                if ent.Morale == MORALE_BROKEN then
                    chance = 100
                elseif ent.Morale == MORALE_LOW then
                    chance = chance + 20
                end
                
                if math.random(1,100) <= chance then
                    ent.Surrendering = true
                    ent.FakeSurrendering = math.random(1,100) <= 10
                end
                
            elseif type == "alert" then
                local en = self:GetEnemy()
                if IsValid(en) then
                    ent:ForceSetEnemy(en)
                    ent:UpdateEnemyMemory(en, en:GetPos() + Vector(math.random(-128,128), math.random(-128,128), 0))
                    ent:AddSuppression(10)
                end
                
            elseif type == "suppressing" then
                if ent.MoraleFactors.allies_nearby > 0 and not ent.Surrendering then
                    timer.Simple(math.Rand(0.5,1.5), function()
                        if IsValid(ent) and IsValid(ent:GetEnemy()) then
                            ent:SuppressingFire(ent:GetEnemy())
                        end
                    end)
                end
                
            elseif type == "gunshotheard" then
                ent.SoundAlertLevel = math.min(ent.SoundAlertLevel + 30, 100)
                ent:AddSuppression(10)
                
                if not IsValid(ent:GetEnemy()) and self.LastHeardSoundPos then
                    ent:InvestigatePosition(self.LastHeardSoundPos)
                end
                
            elseif type == "suicidethought" then
                for _, ally in pairs(ents.FindInSphere(self:GetPos(), 300)) do
                    if ally != self and ally:GetClass() == self:GetClass() and self:Visible(ally) then
                        ally.MoraleFactors.witnessed_deaths = ally.MoraleFactors.witnessed_deaths + 0.5
                        
                        if ally.Personality == TYPE_COWARD and ally.Morale <= MORALE_LOW then
                            ally.SuicideAttempts = math.min(ally.SuicideAttempts + 1, ally.MaxSuicideAttempts - 1)
                        end
                    end
                end
            elseif type == "grenadeout" then
                if ent.MoraleFactors.allies_nearby > 0 and not ent.Surrendering then
                    local coverPos = ent:FindAdvancedCoverPosition(nil, false)
                    if coverPos then
                        ent:SetLastPosition(coverPos)
                        ent:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH")
                    end
                end
            end
        end
    end
end

function ENT:OnResetEnemy()
    self.CombatStartTime = 0
    
    if self.DisableWandering then
        local pos = self:FindAdvancedCoverPosition(nil, false)
        if not pos then
            pos = MuR and MuR:GetRandomPos(nil, self:GetPos(), 200, 600, true) or self:GetPos() + Vector(math.random(-400,400), math.random(-400,400), 0)
        end
        
        if isvector(pos) then
            self:SetLastPosition(pos)
            self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH", function(x) 
                x.CanShootWhenMoving = true 
                x.TurnData = {Type = VJ.FACE_ENEMY} 
            end)
        end
    end
    
    self.IsLookingAround = true
    self.SoundAlertLevel = math.max(self.SoundAlertLevel, 30)
end

function ENT:EvaluateChaseBehavior()
    if not IsValid(self:GetEnemy()) then return end
    
    local enemy = self:GetEnemy()
    local shouldChase = false
    
    if self.Personality == TYPE_AGGRESSIVE and self.Morale >= MORALE_NORMAL then
        shouldChase = true
        
    elseif self.Personality == TYPE_TACTICAL then
        local healthRatio = self:Health() / self:GetMaxHealth()
        local hasAdvantage = self.MoraleFactors.allies_nearby > self.MoraleFactors.enemies_nearby
        local goodPosition = self:GetPos():Distance(enemy:GetPos()) < self.TacticalData.preferred_range
        
        if healthRatio > 0.6 and (hasAdvantage or goodPosition) then
            shouldChase = true
        end
        
    elseif self.ChaseEnemyWhenGoodSituation then
        local healthRatio = self:Health() / self:GetMaxHealth()
        
        if healthRatio >= 0.5 and self.Morale >= MORALE_NORMAL then
            if self.MoraleFactors.allies_nearby >= 2 or 
               (self.MoraleFactors.allies_nearby > 0 and self.MoraleFactors.enemies_nearby <= 1) then
                shouldChase = true
            end
        end
    end
    
    if self.Morale <= MORALE_LOW then
        shouldChase = false
    end
    
    if shouldChase then
        self.DisableChasingEnemy = false
    else
        self.DisableChasingEnemy = true
        if self:Visible(enemy) then
            self:FindRetreatPosition(enemy)
        end
    end
end

function ENT:OnAlert(ent)
    self:CallNearAllyReaction("alert")
    
    if not self.ExpectedContact then
        self:AddSuppression(20)
    end
    
    self.SoundAlertLevel = math.min(self.SoundAlertLevel + 40, 100)
    self.IsLookingAround = true
    self.LastSawEnemyTime = CurTime()
    if IsValid(ent) then self:AddHotspot(ent:GetPos(), 2) end
    if CurTime() > (self.NextVoxContact or 0) then
        self:PlayVox(self.SoundTbl_Contact, 75)
        self.NextVoxContact = CurTime() + math.Rand(6,12)
    end
end

function ENT:CustomOnEnemyKilled(dmginfo, hitgroup)
    if CurTime() > (self.NextVoxKill or 0) then
        self:PlayVox(self.SoundTbl_Kill, 75)
        self.NextVoxKill = CurTime() + math.Rand(6,12)
    end
end

function ENT:CustomBlindFire()
end

function ENT:SetCooldown(name, time)
    if not name or not time then return end
    self:SetNWFloat(name, CurTime() + time)
end

function ENT:GetCooldown(name)
    if not name then return end
    return math.max(self:GetNWFloat(name) - CurTime(), 0)
end

function ENT:GetSeqName()
    return self:GetSequenceName(self:GetSequence()) or "none"
end

function ENT:FullSurrender()
    self.Surrendering = math.random(1,10) != 1
    self.FakeSurrendering = math.random(1,10) == 1
    self:CallNearAllyReaction(self.FakeSurrendering and "fakesurrender" or "fullsurrender")
end

function ENT:FakeSurrenderUse()
    if not self.Surrendering then return end
    self:CallNearAllyReaction("attacksurrender")
    self.VJ_NPC_Class = {"CLASS_BLOODSHED_SUSPECT"}
    self.Surrendering = false
    self.FakeSurrendering = false
    self.TakeOnSightBeforeShoot = false
    self:SetState(VJ_STATE_NONE)
    self:PlayAnim("vjseq_zombie_slump_rise_02_fast", true, 0.5, true, 0, {PlayBackRate = 2})
    self:SetCycle(0.2)
    if IsValid(self.LastWeapon) then
        self:Give(self.LastWeapon:GetClass())
        self.LastWeapon:Remove()
    end
end

function ENT:Suicide()
    local wep = self:GetActiveWeapon()
    if self:Health() <= 1 or not IsValid(wep) or self.AlreadyUsedSuicide then return end

    local p = wep.Primary
    if not p then return end
    local sd = VJ_PICK(p.Sound)
    local isfaking = math.random(1,5) >= 3

    self:SetEnemy(NULL)
    self:SetState(VJ_STATE_FREEZE)
    self.AlreadyUsedSuicide = true
    self:PlayAnim("mur_suicide", true, 1.2, false, 0, {OnFinish = function(int, anim)
        if isfaking then
            self:SetState(VJ_STATE_NONE)
            if math.random(1,2) == 1 then
                self.Surrendering = true
                self.FakeSurrendering = math.random(1,5) == 1
            end
        else
            sound.Play(sd, self:GetPos(), p.SoundLevel, math.random(p.SoundPitch.a, p.SoundPitch.b), p.SoundVolume)
            wep:PrimaryAttackEffects()
            local ef = EffectData()
            ef:SetOrigin(self:GetBonePosition(self:LookupBone("ValveBiped.Bip01_Head1")))
            util.Effect("BloodImpact", ef)
            self:SetHealth(1)
            self:TakeDamage(10)
        end
    end})
end

function ENT:OnWeaponCanFire() 
    local ply = self:GetEnemy()
    if IsValid(ply) and ply:IsPlayer() and self.TakeOnSightBeforeShoot then
        return false
    end
    return true
end

function ENT:StartLean(pitch, yaw, roll)
    local bone = self:LookupBone("ValveBiped.Bip01_Spine")
    if not bone then return end
    
    local m = self:GetManipulateBoneAngles(bone) or Angle(0,0,0)
    self.LeanDuration = 0.2
    self.LeanInitialAngles = Angle(m.p, m.y, m.r)
    self.LeanTargetAngles = Angle(pitch, yaw, roll)
    self.LeanStartTime = CurTime()
    self.IsLeaning = true
end

function ENT:ResetLean()
    local bone = self:LookupBone("ValveBiped.Bip01_Spine")
    if bone then
        self:ManipulateBoneAngles(bone, Angle(0,0,0))
    end
    self.IsLeaning = false
end

function ENT:ForceDuck()
    if self.IsDucking then return end
    
    self.IsDucking = true
    self:SetCollisionBounds(Vector(-16,-16,0), Vector(16,16,40))
    self:PlayAnim("vjseq_crouch_idle_all_scared", true, 3, false)
    
    timer.Simple(3, function()
        if IsValid(self) then
            self.IsDucking = false
            self:SetCollisionBounds(Vector(-16,-16,0), Vector(16,16,72))
        end
    end)
end

function ENT:CustomLean()
    local enemy = self:GetEnemy()
    if not IsValid(enemy) or CurTime() < self.NextLeanTime or self.CantUseLean or self.IsPanicking then 
        return 
    end
    
    self.NextLeanTime = CurTime() + 0.25
    
    local wep = self:GetActiveWeapon()
    if not IsValid(wep) or wep:Clip1() <= 0 then
        return self:StartResetLean()
    end
    
    local startPos = self:GetBonePosition(2) or self:EyePos()
    local endPos = enemy:GetBonePosition(2) or enemy:EyePos()
    local filter = {enemy, self}
    local tr = util.TraceLine({start = startPos, endpos = endPos, filter = filter})
    
    if not tr.Hit or (tr.Entity and (tr.Entity:IsPlayer() or tr.Entity:IsNPC())) then
        return self:StartResetLean()
    end
    
    local right = self:GetRight() * 30
    local trR = util.TraceLine({start = startPos + right, endpos = endPos, filter = filter})
    local trL = util.TraceLine({start = startPos - right, endpos = endPos, filter = filter})
    
    if trR.Entity == enemy then
        self:StartLean(35, 0, -8)
    elseif trL.Entity == enemy then
        self:StartLean(-35, 0, 8)
    else
        local up = self:GetUp() * 20
        local trU = util.TraceLine({start = startPos - up, endpos = endPos, filter = filter})
        
        if trU.Entity == enemy then
            self:StartLean(-15, 0, 0)
        else
            self:StartResetLean()
        end
    end
end

if engine.ActiveGamemode() == "bloodshed" then
    hook.Add("PlayerButtonDown", "MuR.GoSurrender", function(ply, key)
        if MuR.Gamemode != 14 then return end
        
        if ply:IsRolePolice() and ply:Alive() and key == KEY_G then
            if ply.DelayBeforeNextUseSurrender and ply.DelayBeforeNextUseSurrender > CurTime() then 
                return 
            end
            
            ply.DelayBeforeNextUseSurrender = CurTime() + 3
            ply.VoiceDelay = 0
            ply:PlayVoiceLine("ror_police_surrender", true)
            
            local targets = {}
            for _, ent in pairs(ents.FindInSphere(ply:GetPos(), 1024)) do
                if ent.SuspectNPC and ply:Visible(ent) then
                    table.insert(targets, {
                        ent = ent,
                        dist = VJ.GetNearestDistance(ent, ply)
                    })
                end
            end
            
            table.sort(targets, function(a, b) return a.dist < b.dist end)
            
            for i, target in ipairs(targets) do
                timer.Simple(i * 0.1, function()
                    if IsValid(target.ent) and IsValid(ply) then
                        local ang = (ply:GetPos() - target.ent:GetPos()):Angle()
                        target.ent:SetAngles(Angle(0, ang.y, 0))
                        target.ent:TrySurrender(false, ply)
                        if IsValid(target.ent:GetEnemy()) then return end
                        target.ent:ForceSetEnemy(ply)
                    end
                end)
            end
        end
    end)
end