AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = {
	"models/murdered/npc/police/male_01.mdl", 
	"models/murdered/npc/police/male_03.mdl", 
	"models/murdered/npc/police/male_04.mdl", 
	"models/murdered/npc/police/male_05.mdl", 
	"models/murdered/npc/police/male_06.mdl", 
	"models/murdered/npc/police/male_07.mdl", 
	"models/murdered/npc/police/male_08.mdl", 
	"models/murdered/npc/police/male_09.mdl"
}
ENT.StartHealth = 100

ENT.AnimTbl_MeleeAttack = {"pushplayer", "swing", "thrust"}
ENT.VJ_NPC_Class = {"CLASS_BLOODSHED_CIVILIAN"}

ENT.AnimTbl_DoorSeq = "adoorkick"
ENT.DoorKickSetBack = true

ENT.SoundTbl_Death = "BloodshedNPC_HumanDeath"
ENT.SoundTbl_FootStep = "BloodshedNPC_HumanFootstep"
ENT.SoundTbl_AllyDeath = {}
ENT.SoundTbl_CombatIdle = {}
ENT.SoundTbl_Alert = {}
ENT.SoundTbl_PoliceSurrender = {}
ENT.SoundTbl_PoliceNoSurrender = {}

-----------------------------------------------------------------------------

function ENT:CustomOnInitialize()
    local skinCount = self:SkinCount()
	local randomSkin = math.random(0, skinCount - 1)
	self:SetSkin(randomSkin)

	for i = 0, self:GetNumBodyGroups() - 1 do
		local bodyGroupCount = self:GetBodygroupCount(i)
		local randomBodyGroup = math.random(0, bodyGroupCount - 1)
		self:SetBodygroup(i, randomBodyGroup)
	end

	self.IsPolice = true
	self:SetupVoice()
end

function ENT:SetupVoice()
	local id = math.random(1,10)
	self:SetupVoiceTable(id, "murdered/npc/voice"..id, "alert", self.SoundTbl_PoliceSurrender)
	self:SetupVoiceTable(id, "murdered/npc/voice"..id, "combat", self.SoundTbl_PoliceNoSurrender)
	self:SetupVoiceTable(id, "murdered/npc/voice"..id, "mandown", self.SoundTbl_AllyDeath)
end

function ENT:SetupVoiceTable(id, folder, names, tab)
	local files = file.Find("sound/"..folder.."/"..names.."*", "GAME")
	for _, v in pairs(files) do
		table.insert(tab, folder.."/"..v)
	end
end

function ENT:OnThink()
	self:DoorLogicBust()
	self:VoiceLogic()
	self:TaserLogic()
end

function ENT:SetCooldown(name, time)
	if not name or not time then return end
	self:SetNWFloat(name, CurTime()+time)
end

function ENT:GetCooldown(name)
	if not name then return end
	return math.max(self:GetNWFloat(name)-CurTime(), 0)
end

-----------------------------------------------------------------------------

function ENT:TaserLogic()
	local en = self:GetEnemy()
	if IsValid(en) and en:IsPlayer() then
		local can = en:GetNWFloat("ArrestState") == 1 and (en:GetMoveType() == MOVETYPE_LADDER and math.abs(en:GetPos().z-self:GetPos().z) > 72 and math.random(1,10) == 1 or self:GetCooldown("taseruse") == 0)
		if can then
			self:SetCooldown("taseruse", math.Rand(30,60))
			self:UseTaser()
		end
	else
		self:SetCooldown("taseruse", math.Rand(30,60))
	end
end

function ENT:UseTaser()
	if self.UsingTaser then return end
	local w = self:GetActiveWeapon()
	if !IsValid(w) then return end
	w:SetNoDraw(true)

	local taser = ents.Create("base_anim")
	taser:SetModel("models/murdered/weapons/w_taser.mdl")
	taser:Spawn()
	local att = self:LookupAttachment("anim_attachment_rh")
	local tab = self:GetAttachment(att)
	taser:SetPos(tab.Pos)
	taser:SetAngles(tab.Ang)
	taser:SetParent(self, att)
	taser:SetLocalAngles(Angle(270,90,0))
	taser:SetLocalPos(Vector(2,0,2))
	self:DeleteOnRemove(taser)
	self.UsingTaser = true
	self:PlayAnim("vjseq_drawpistol", true, false, true, 0, {OnFinish = function()
		self:PlayAnim("vjseq_drawpistol", true, false)
		self.UsingTaser = false
		w:SetNoDraw(false)
		SafeRemoveEntity(taser)

		local ent = self:GetEnemy()
		if !IsValid(ent) then return end
		if VJ.GetNearestDistance(self, ent) < 400 and self:Visible(ent) then
			self:EmitSound(")murdered/other/taser.wav", 70)
			self:SetCooldown("chaseenemy", 2)
			local effect = EffectData()
			effect:SetStart(self:GetAttachment(att).Pos)
			effect:SetOrigin(ent:WorldSpaceCenter())
			effect:SetScale(1)
			effect:SetMagnitude(5)
			effect:SetFlags(0)
			util.Effect("ToolTracer", effect)
			if ent:IsPlayer() then
				ent:StartRagdolling()
				ent:TimeGetUpChange(9, true)
				timer.Create("Tasered"..ent:EntIndex(), 0.05, 50, function()
					if !IsValid(ent) or !ent:Alive() then return end
					ent:SetEyeAngles(ent:EyeAngles()+Angle(math.Rand(-2,2),math.Rand(-2,2),0))
					ent:ViewPunch(AngleRand(-2,2))
					if math.random(1,5) == 1 then
						ent:EmitSound("ambient/energy/spark"..math.random(1,6)..".wav", 50)
	
						local ef = EffectData()
						ef:SetEntity(ent)
						ef:SetMagnitude(1)
						util.Effect("TeslaHitboxes", ef)
					end
					if IsValid(ent:GetRD()) then
						ent:GetRD():StruggleBone()
						ent.IsRagStanding = false
					end
				end)
			else
				ent:TakeDamage(50, self)
			end
		end
	end})
end

function ENT:AcceptInput(key, activator, caller, data)
	local funcCustom = self.OnInput; if funcCustom then funcCustom(self, key, activator, caller, data) end
	if key == "Use" then
		timer.Simple(0.1, function()
			if IsValid(self) && self.FollowPlayer && activator:IsRolePolice() && !activator:KeyDown(IN_ATTACK) && !activator:KeyDownLast(IN_ATTACK) && !activator:KeyPressed(IN_ATTACK) && !activator:KeyReleased(IN_ATTACK) && !activator:KeyDown(IN_ATTACK2) && !activator:KeyDownLast(IN_ATTACK2) && !activator:KeyPressed(IN_ATTACK2) && !activator:KeyReleased(IN_ATTACK2) && !activator:KeyDown(IN_RELOAD) && !activator:KeyDownLast(IN_RELOAD) && !activator:KeyPressed(IN_RELOAD) && !activator:KeyReleased(IN_RELOAD) then
				self:Follow(activator, true)
			end
		end)
	elseif key == "StartScripting" then
		self:SetState(VJ_STATE_FREEZE)
	elseif key == "StopScripting" then
		self:SetState(VJ_STATE_NONE)
	elseif key == "break" then
		local dmginfo = DamageInfo()
		dmginfo:SetDamage(self:Health())
		dmginfo:SetDamageType(DMG_ALWAYSGIB)
		dmginfo:SetAttacker(activator)
		dmginfo:SetInflictor(activator)
		self:TakeDamageInfo(dmginfo)
		return true
	end
	return false
end

function ENT:VoiceLogic()
	local en = self:GetEnemy()
	if IsValid(en) and en:IsPlayer() and en:GetNWFloat("ArrestState") == 2 then
		self.SoundTbl_Alert = self.SoundTbl_PoliceNoSurrender
		self.SoundTbl_CombatIdle = self.SoundTbl_PoliceNoSurrender
	else
		self.SoundTbl_Alert = self.SoundTbl_PoliceSurrender
		self.SoundTbl_CombatIdle = self.SoundTbl_PoliceSurrender
	end
end

function ENT:ArrestLogic(ply)
    if ply:IsPlayer() and ply:GetNWFloat("ArrestState") == 1 then
        if string.find(ply:GetSVAnim(), "sequence_ron_comply_start_0") or IsValid(ply:GetRD()) then
			self.Weapon_RetreatDistance = 50
		else
			self.Weapon_RetreatDistance = 200
		end
		if !(!self:Visible(ply) and VJ.GetNearestDistance(self, ply) > 300 or VJ.GetNearestDistance(self, ply) > 600 or string.find(ply:GetSVAnim(), "sequence_ron_comply_start_0") or IsValid(ply:GetRD())) then
			self:SetCooldown("chaseenemy", math.Rand(2,8))
		end
        if self:GetCooldown("chaseenemy") == 0 then
            self:VJ_TASK_CHASE_ENEMY()
            self:SetCooldown("chaseenemy", math.Rand(2,8))
        end
		self.ConstantlyFaceEnemy = true
        return false
    else
        self.Weapon_RetreatDistance = 125
    end
    return true
end

function ENT:OnWeaponCanFire() 
    local ply = self:GetEnemy()
	if IsValid(ply) then
    	return self:ArrestLogic(ply)
	end
end

function ENT:CustomOnMeleeAttack_AfterChecks(ent)
	if ent:IsPlayer() and ent:GetNWFloat("ArrestState") == 1 then
		if isfunction(ent.Surrender) and ent:Alive() then
			local id = math.random(1,6) 
			local anim = "sequence_ron_arrest_start_player_0"..id
			local _, dur = ent:LookupSequence(anim)

			ent:SetEyeAngles(self:GetAngles())
			ent:Surrender(true, true, id, dur)
			self:EmitSound(")murdered/other/arrest_body.mp3", 60)
			if IsValid(ent:GetRD()) then
				ent:SetPos(self:GetPos())
			else
				self:SetPos(ent:GetPos())
			end
			self:PlayAnim("vjseq_"..anim, true, false)
			return true
		end
	end
end

-----------------------------------------------------------------------------

function ENT:GetSeqName()
	return self:GetSequenceName(self:GetSequence()) or "none"
end

function ENT:DoorLogicBust()
	if not self.doorbusting then
		local tr = util.TraceLine( {
			start = self:GetPos()+Vector(0,0,32),
			endpos = self:GetPos()+Vector(0,0,32)+self:GetAngles():Forward()*40,
			filter = function( ent ) 
				if ent:GetClass() == "prop_door_rotating" or ent:GetClass() == "func_door_rotating" then 
					return true 
				end 
			end
		} )
		local tr2 = util.TraceLine( {
			start = self:GetPos()+Vector(0,0,32),
			endpos = self:GetPos()+Vector(0,0,32)+self:GetAngles():Forward()*64
		} )
		if tr.Hit and not tr2.HitWorld and tr.Entity then
			if ( tr.Entity:GetClass() == "prop_door_rotating" or tr.Entity:GetClass() == "func_door_rotating" ) and tr.Entity:GetInternalVariable( "m_bLocked" ) and not tr.Entity:GetInternalVariable( "m_eDoorState" ) ~= 0 then
				self.doorbusting = true
				self:DoorKickUnlock(tr.Entity, tr.Fraction)
			end
		end
	end
end

function ENT:DoorKickUnlock(door, frac)
	self:PlayAnim(self.AnimTbl_DoorSeq, true, 1.1)
	if self.DoorKickSetBack then
		self:SetPos(self:GetPos()-self:GetForward()*(24*frac))
	end
	if IsValid(self) then
		if IsValid(door) then
			timer.Simple(0.75, function()
				if !IsValid(self) or !IsValid(door) then return end
				local dmg = DamageInfo()
				dmg:SetAttacker(self)
				dmg:SetDamage(math.random(200,300))
				dmg:SetDamageForce(self:GetForward()*100000)
				dmg:SetDamageType(DMG_CRUSH)
				dmg:SetDamagePosition(self:WorldSpaceCenter())
				door:TakeDamageInfo(dmg)
			end)
		end
		timer.Simple(1.2, function()
			if !IsValid(self) then return end
			if self.DoorKickSetBack then
				self:SetPos(self:GetPos()+self:GetForward()*(24*frac))
			end
			self.doorbusting = false
		end)
	end
end