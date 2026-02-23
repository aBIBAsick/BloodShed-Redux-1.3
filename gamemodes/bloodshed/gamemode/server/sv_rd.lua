local ent = FindMetaTable("Entity")
local pl = FindMetaTable("Player")

local function calc_health(hp, max_hp)
    local hp_ratio = hp / max_hp

    if hp_ratio >= 0.4 then
        return 1
	elseif hp_ratio <= 0.1 then
		return 3
    else
        return 1 + (1 - hp_ratio / 0.4) * 2
    end
end

local function TransferBones(base, ragdoll)
	if not IsValid(base) or not IsValid(ragdoll) then return end

	for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
		local bone = ragdoll:GetPhysicsObjectNum(i)

		if IsValid(bone) then
			local pos, ang = base:GetBonePosition(ragdoll:TranslatePhysBoneToBone(i))

			if pos then
				bone:SetPos(pos)
			end

			if ang then
				bone:SetAngles(ang)
			end
		end
	end
end

local function VelocityOnAllBones(ragdoll, vel)
	if not IsValid(ragdoll) then return end

	for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
		local bone = ragdoll:GetPhysicsObjectNum(i)

		if IsValid(bone) then
			local name = string.lower(ragdoll:GetBoneName(ragdoll:TranslatePhysBoneToBone(i)))
			local arms = string.find(name, "arm")
			local hands = string.find(name, "hand")
			local head = string.find(name, "head")
			if arms then
				bone:SetMass(4)
			elseif hands then
				bone:SetMass(25)
			elseif head then
				bone:SetMass(50)
			else
				bone:SetMass(40)
			end
			bone:SetVelocity(vel)
		end
	end
end

local function GetCorrectTypeOfBone(name)
	local type = "other"

	local bonetab = {
		["head"] = {
			["ValveBiped.Bip01_Head1"] = true,
			["ValveBiped.Bip01_Neck1"] = true,
		},
		["torso"] = {
			["ValveBiped.Bip01_Pelvis"] = true,
			["ValveBiped.Bip01_Spine"] = true,
			["ValveBiped.Bip01_Spine1"] = true,
			["ValveBiped.Bip01_Spine2"] = true,
			["ValveBiped.Bip01_Spine4"] = true,
		},
		["r_leg"] = {
			["ValveBiped.Bip01_R_Thigh"] = true,
			["ValveBiped.Bip01_R_Calf"] = true,
			["ValveBiped.Bip01_R_Foot"] = true,
			["ValveBiped.Bip01_R_Toe0"] = true,
		},
		["l_leg"] = {
			["ValveBiped.Bip01_L_Thigh"] = true,
			["ValveBiped.Bip01_L_Calf"] = true,
			["ValveBiped.Bip01_L_Foot"] = true,
			["ValveBiped.Bip01_L_Toe0"] = true,
		},
		["r_hand"] = {
			["ValveBiped.Bip01_R_Clavicle"] = true,
			["ValveBiped.Bip01_R_UpperArm"] = true,
			["ValveBiped.Bip01_R_Forearm"] = true,
			["ValveBiped.Bip01_R_Hand"] = true,
		},
		["l_hand"] = {
			["ValveBiped.Bip01_L_Clavicle"] = true,
			["ValveBiped.Bip01_L_UpperArm"] = true,
			["ValveBiped.Bip01_L_Forearm"] = true,
			["ValveBiped.Bip01_L_Hand"] = true,
		},
	}

	for k, v in pairs(bonetab) do
		if v[name] then
			type = k
		end
	end

	return type
end

-------------------PLAYER FUNCTIONS----------------------------

local ItemType = {
	["mur_loot_bandage"] = "Bandage",
	["mur_loot_medkit"] = "Medkit",
	["mur_f1"] = "F1",
	["mur_m67"] = "M67",
}

function pl:GiveRagdollWeapon(ent, awep)
	if not IsValid(awep) or not IsValid(ent) then return end
	if IsValid(ent.Weapon) then
		if awep == ent.Weapon.Weapon and self:IsBot() then return end
		ent.Weapon:Remove()
	end
	timer.Simple(0.001, function()
		if not IsValid(ent) or not IsValid(awep) then return end
		if not awep.RagdollType and MuR.WeaponToRagdoll[awep:GetClass()] then
			awep.RagdollType = MuR.WeaponToRagdoll[awep:GetClass()]
		elseif not awep.RagdollType and !MuR.WeaponToRagdoll[awep:GetClass()] then
			awep.RagdollType = awep:GetClass()
		end
		if awep.Melee == true then
			local wep = ents.Create("murwep_ragdoll_melee")
			wep.Owner = ent

			if IsValid(awep) and awep.RagdollType then
				wep.Weapon = awep
				wep.type = awep.RagdollType
			end

			wep:SetPos(self:GetPos())
			wep:Spawn()
			ent.Weapon = wep
			self:SetNW2Entity("RD_Weapon", wep)
		elseif ItemType[awep:GetClass()] then
			local wep = ents.Create("murwep_ragdoll_item")
			wep.Owner = ent

			if IsValid(awep) then
				wep.Weapon = awep
				wep.type = ItemType[awep:GetClass()]
			end

			wep:SetPos(self:GetPos())
			wep:Spawn()
			ent.Weapon = wep
			self:SetNW2Entity("RD_Weapon", wep)
		else
			local wep = ents.Create("murwep_ragdoll_weapon")
			wep.Owner = ent

			if IsValid(awep) and awep:GetMaxClip1() > 0 and awep.IsTFAWeapon and awep.RagdollType then
				wep.Weapon = awep
				wep.type = awep.RagdollType
			end

			wep:SetPos(self:GetPos())
			wep:Spawn()
			ent.Weapon = wep
			self:SetNW2Entity("RD_Weapon", wep)
		end
	end)
end	

function pl:CreateAdvancedRagdoll(withoutvel)
	if IsValid(self:GetRD()) then return self:GetRD() end
	local vel = self:GetVelocity()
	if withoutvel then vel = Vector(0,0,0) end
	local ent = ents.Create("prop_ragdoll")
	ent:TransferModelData(self)
	ent:SetNW2Vector("RagColor", self:GetPlayerColor())
	ent:SetBloodColor(BLOOD_COLOR_RED)
	ent:Spawn()
	ent:CopyWoundsFrom(self)
	ent.Inventory = {}
	ent.DelayBetweenStruggle = 0
	ent.Moans = 0
	ent.Male = self.Male
	ent.DelayBetweenMoans = 0
	ent.IsDead = false
	ent.isRDRag = true
	ent.Owner = self
	ent.OwnerDead = self
	ent.MaxBlood = 40
	ent.PlyColor = self:GetPlayerColor()
	ent:SetNWString("Name", self:GetNWString("Name"))
	ent:MakePlayerColor(ent.PlyColor)
	ent:ZippyGoreMod3_BecomeGibbableRagdoll(BLOOD_COLOR_RED)
	ent.delta = CurTime()
	ent:SetFlexScale(0.5)
	ent:GetPhysicsObject():Sleep()
	ent:GetPhysicsObject():SetMass(20)
	ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	ent:AddEFlags(EFL_DONTBLOCKLOS)
	ent:AddEFlags(256)
	ent.CanStanding = self:OnGround()

	self.Bullseye = ents.Create("obj_vj_bullseye")
	self.Bullseye:SetModel("models/hunter/plates/plate.mdl")
	self.Bullseye:SetNoDraw(true)
	self.Bullseye:SetPos(ent:WorldSpaceCenter())
	self.Bullseye:SetMaxHealth(999999)
	self.Bullseye:SetHealth(999999)
	self.Bullseye:Spawn()
	self.Bullseye:Activate()
	self.Bullseye:SetMoveType(MOVETYPE_NONE)
	self.Bullseye:SetNotSolid(true)
	self.Bullseye:SetOwner(self)

	timer.Simple(0.2, function()
		if !IsValid(ent) or !IsValid(self) then return end
		net.Start("MuR.CalcView")
		net.WriteEntity(ent)
		net.Send(self)
	end)
	local function PhysCallback(ent, data)
		if data.Speed > 400 and data.HitEntity:IsPlayer() and IsValid(ent.Owner) and data.HitEntity:GetMoveType() ~= MOVETYPE_NOCLIP then
			data.HitEntity:StartRagdolling()
		end
	end
	ent:AddCallback("PhysicsCollide", PhysCallback)

	TransferBones(self, ent)
	VelocityOnAllBones(ent, vel)
	local awep = self:GetActiveWeapon()

	self:SetNW2Entity("RD_Weapon", NULL)
	self:SetNW2Entity("RD_Ent", ent)
	self:SetNW2Entity("RD_EntCam", ent)
	self:SetFOV(0)
	self:GiveRagdollWeapon(ent, self:GetActiveWeapon())

	timer.Simple(0.01, function()
		if !IsValid(self) or !self.DeathBlowHead or !IsValid(ent) then return end
		self.DeathBlowHead = false

		local h = ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_Head1"))
		if isnumber(h) and h > 0 then
			ent:ZippyGoreMod3_BreakPhysBone(h, {damage = 100, forceVec = Vector(0,0,0), dismember = tobool(self.DeathBlowHeadCut)})
		end
		self.DeathBlowHeadCut = false
	end)
	timer.Simple(0.01, function()
		if !IsValid(self) or !self.DeathBlowSpine or !IsValid(ent) then return end
		self.DeathBlowSpine = false 
		local h = ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_Spine2"))
		if isnumber(h) and h > 0 then
			ent:ZippyGoreMod3_BreakPhysBone(h, {damage = 100, forceVec = Vector(0,0,0), dismember = true})
		end
	end)
	timer.Simple(0.01, function()
		if !IsValid(self) or !IsValid(ent) then return end
		self:BreakRagdollBone()
	end)

	return ent
end

function pl:BreakRagdollBone()
	if !IsValid(self:GetRD()) then return end
	local ent = self:GetRD()
	local tab = self.DeathBlowBone 
	if istable(tab) then
		local h = ent:TranslateBoneToPhysBone(ent:LookupBone(tab[1]))
		if isnumber(h) and h > 0 then
			ent:ZippyGoreMod3_BreakPhysBone(h, {damage = 100, forceVec = Vector(0,0,0), dismember = tobool(tab[2])})
		end
		self.DeathBlowBone = nil
	end
end

function pl:IsWepRagReloading()
	local rag = self:GetRD()
	if !IsValid(rag) then return false end
	local wep = rag.Weapon
	if !IsValid(wep) then return false end
	if !wep.IsReloading then return false end
	return wep:IsReloading()
end

function pl:StartRagdolling(moans, dam, gibs)
	if self:IsExecuting() or self:GetNW2String("Class") == "Zombie" or self:GetNW2String("Class") == "Maniac" or self:GetNW2Bool("GeroinUsed") or self:GetNW2Bool("GeroinUsed") or timer.Exists("MindControl_" .. self:EntIndex()) then return end
	moans = moans or 0
	dam = dam or 0
	local ent = self:CreateAdvancedRagdoll()
	self:Flashlight(false)
	self.IsRagStanding = self:OnGround()

	if IsValid(ent) then
		ent.Moans = 0
		self:TimeGetUpChange(3 + dam / 2, true)

		if gibs then
			ent:ZippyGoreMod3_DamageRagdoll(gibs)
		end
	end

	return ent
end

function pl:UnconnectRagdoll(died)
	local rag = self:GetRD()

	if IsValid(rag) then
		local isbleeding = rag.Owner and (rag.Owner:GetNW2Float("BleedLevel", 0) > 1 or rag.Owner:GetNW2Bool("HardBleed", false)) or false
		rag.IsDead = true
		rag.Owner = nil
		self:StopRagdolling(true)
		rag:GrabHand(false, false)
		rag:GrabHand(false, true)
		if isbleeding then
			MuR:AddSmearingBlood(rag)
		end

		if died then
			timer.Create("RagdollStruggle"..rag:EntIndex(), math.Rand(0.2,0.6), math.random(16,64), function()
				if !IsValid(rag) then return end
				rag:StruggleBone()
			end)
		end
	end
end

function pl:StopRagdolling(keeprag, playanim)
	local rag = self:GetRD()
	if !IsValid(rag) then return end
	self:SetNW2Entity("RD_Ent", NULL)
	self:SetNoDraw(false)
	self:SetNotSolid(false)
	self:DrawShadow(true)
	self:SetNoTarget(false)
	local npos = self:GetPos()
	if rag:LookupBone("ValveBiped.Bip01_Pelvis") then
		local _, opos = MuR:CheckHeight(rag, MuR:BoneData(rag, "ValveBiped.Bip01_Pelvis"))
		npos = isvector(opos) and opos or npos
	end
	self:SetPos(npos)
	if IsValid(self.Bullseye) then
		self.Bullseye:Remove()
	end

	if playanim then
		self:Freeze(true)
		self:SelectWeapon("mur_hands")
		local time = self:SetSVAnimation("mur_getup" .. math.random(1, 3), true)

		timer.Simple(time, function()
			if not IsValid(self) then return end
			self:Freeze(false)
		end)
	else
		self:Freeze(false)
		self:SetSVAnimation("")
	end

	if not keeprag and IsValid(rag) then
		rag:Remove()
	else
		timer.Simple(0.01, function()
			if IsValid(rag) and IsValid(self) and isstring(self.LastVoiceLine) then
				rag:StopSound(self.LastVoiceLine)
			end
		end)
	end
	if self:GetNW2String("Class") == "Zombie" then
		SafeRemoveEntityDelayed(rag, 15)
	end
end

-------------------------ENTITY FUNCTIONS------------------------------
function ent:TransferModelData(from)
	local ent1Model = from:GetModel()
	local ent1Skin = from:GetSkin()
	local ent1BodyGroups = from:GetNumBodyGroups()
	self:SetModel(ent1Model)
	self:SetSkin(ent1Skin)

	for i = 0, ent1BodyGroups - 1 do
		self:SetBodygroup(i, from:GetBodygroup(i))
	end
end

function ent:StruggleBone()
	local vel1 = VectorRand(-100, 100)
	local vel2 = VectorRand(-25, 25)

	for i = 0, self:GetPhysicsObjectCount() - 1 do
		local bone = self:GetPhysicsObjectNum(i)

		if IsValid(bone) then
			if math.random(1, 10) == 1 then
				bone:SetVelocity(vel1)
				bone:ApplyTorqueCenter(vel2)
			end
		end
	end
end

function ent:GiveWeaponsFromPly()
	local ply = self.Owner
	if IsValid(ply) then
		self.Inventory = {}
		for _, wep in pairs(ply:GetWeapons()) do
			local cls = wep:GetClass()
			if wep.CantDrop == true then continue end
			ply:DropWeapon(wep)
			wep:SetPos(wep:GetPos() + VectorRand(-12, 12))
			wep:SetNoDraw(true)
			wep:SetNotSolid(true)
			local phys = wep:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableMotion(false)
			end
			timer.Simple(0.1, function()
				if (!IsValid(wep) or wep:IsWeapon()) and IsValid(self) then
					local wep = ents.Create(cls)
					wep:SetPos(Vector(0,0,9999))
					wep:SetNoDraw(true)
					wep:SetNotSolid(true)
					wep:Spawn()
					local phys = wep:GetPhysicsObject()
					if IsValid(phys) then
						phys:EnableMotion(false)
					end
					table.insert(self.Inventory, wep)
				end
			end)
		end
	end
end

function ent:RollBone(inputState)
	if IsValid(self.Owner) then
		local ang = self.Owner:EyeAngles()
		local aimvector = ang:Forward()
		local viewForward = ang:Forward()
		local viewRight = ang:Right()
		local viewUp = ang:Up()
		local viewRightFlat = viewForward:Cross(Vector(0, 0, 1))
		local viewForwardYawOnly = (viewForward * Vector(1, 1, 0)):GetNormalized()
		local hasMoveInput = inputState[IN_FORWARD] or inputState[IN_BACK] or inputState[IN_MOVERIGHT] or inputState[IN_MOVELEFT]
		local moveValues = Vector((inputState[IN_MOVERIGHT] and 1 or 0) - (inputState[IN_MOVELEFT] and 1 or 0), (inputState[IN_FORWARD] and 1 or 0) - (inputState[IN_BACK] and 1 or 0), 0)
		local moveInput2d = ((moveValues.y * viewForwardYawOnly) + (moveValues.x * viewRightFlat)):GetNormalized()
		local torque = Vector(moveInput2d.y, moveInput2d.x, 0) * 120
		local bone1 = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_Spine")))
		local bone2 = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_Spine1")))
		local bone3 = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_Spine2")))
		local bone4 = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_Spine4")))
		local bone5 = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_Pelvis")))
		local bone6 = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_L_Calf")))
		local bone7 = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_R_Calf")))
		local bone8 = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_Head1")))
		local bonelf = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_L_Foot")))
		local bonerf = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_R_Foot")))
		local moves = calc_health(self.Owner:Health(), self.Owner:GetMaxHealth())

		if (IsValid(self.RightHandGrab) or IsValid(self.LeftHandGrab)) and self.Owner:KeyDown(IN_FORWARD) then
			bone3:ApplyForceCenter(torque)
			bone4:ApplyForceCenter(torque)
			bone8:ApplyForceCenter(torque)
		else
			bone1:ApplyTorqueCenter(torque)
			bone2:ApplyTorqueCenter(torque)
			bone3:ApplyTorqueCenter(torque)
			bone4:ApplyTorqueCenter(torque)
			bone5:ApplyTorqueCenter(torque)
			bone6:ApplyTorqueCenter(torque)
			bone7:ApplyTorqueCenter(torque)
		end
	end
end

function ent:JumpOutGrab()
	if self.GrabOverTime and self.GrabOverTime > CurTime() then return end
	local aimvector = self.Owner:GetAimVector()
	if self.Owner:GetNW2Float("Stamina") > 30 and self.Owner:Health() > 10 then
		local torque = aimvector * 3000

		if self.Owner.IsRagStanding then
			torque = aimvector * 6000
		end

		if IsValid(constraint.GetAllConstrainedEntities(game.GetWorld())[self]) then
			torque = aimvector * 12000
		end

		self.GrabOverTime = CurTime()+1
		self:GrabHand(false, false)
		self:GrabHand(false, true)
		self.Owner:SetNW2Float("Stamina", math.Clamp(self.Owner:GetNW2Float("Stamina") - 30, 0, 100))

		timer.Simple(0.1, function()
			if not IsValid(self) then return end

			for i = 0, self:GetPhysicsObjectCount() - 1 do
				local phys = self:GetPhysicsObjectNum(i)
				phys:ApplyForceCenter(torque)
			end
		end)
	end
end

function ent:PullHand(type, power)
	if IsValid(self.Owner) then
		local isGrabbed = IsValid(self.LeftHandGrab) or IsValid(self.RightHandGrab)
		
		if not isGrabbed and MuR:CheckHeight(self, MuR:BoneData(self, "ValveBiped.Bip01_Pelvis")) > 200 and self:GetVelocity():Length() > 200 then return end
		
		local eang = self.Owner:EyeAngles()
		local aimvector = eang:Forward()

		local isClimbingUp = IsValid(self.LeftHandGrab) and IsValid(self.RightHandGrab) and 
							type == "all" and eang.p > 30
		
		if isClimbingUp then
			local upForce = self.Owner:GetForward()*200+Vector(0, 0, 1000)
			local bone_spine = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_Spine")))
			local bone_spine1 = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_Spine1")))
			local bone_spine2 = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_Spine2")))
			local bone_spine4 = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_Spine4")))
			local bone_pelvis = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_Pelvis")))
			
			if IsValid(bone_spine) then bone_spine:ApplyForceCenter(upForce) end
			if IsValid(bone_spine1) then bone_spine1:ApplyForceCenter(upForce) end
			if IsValid(bone_spine2) then bone_spine2:ApplyForceCenter(upForce * 1.2) end
			if IsValid(bone_spine4) then bone_spine4:ApplyForceCenter(upForce * 1.5) end
			if IsValid(bone_pelvis) then bone_pelvis:ApplyForceCenter(upForce * 0.8) end
			
			local bone_l_thigh = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_L_Thigh")))
			local bone_r_thigh = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_R_Thigh")))
			if IsValid(bone_l_thigh) then bone_l_thigh:ApplyForceCenter(upForce * 0.3) end
			if IsValid(bone_r_thigh) then bone_r_thigh:ApplyForceCenter(upForce * 0.3) end
			
			return
		end
		
		local torque = aimvector * power
		local bonerh1 = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_R_Hand")))
		local bonerh2 = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_R_Forearm")))
		local bonelh1 = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_L_Hand")))
		local bonelh2 = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_L_Forearm")))
		local boneh = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_Head1")))
		local moves = calc_health(self.Owner:Health(), self.Owner:GetMaxHealth())
		local isgrab = IsValid(constraint.GetAllConstrainedEntities(game.GetWorld())[self])
		self.Owner.using_twohand = false

		if type == "right" then
			local p = {}
			local havewep = IsValid(self.Weapon)
			if havewep then
				p.secondstoarrive = 0.00000001
				p.pos = boneh:GetPos() + aimvector * 24 + eang:Up()*4 + eang:Right()*4
				p.angle = eang
				p.angle.z = 180
				if self.Owner:IsWepRagReloading() then
					p.pos = boneh:GetPos() + aimvector * 8 - eang:Right()*4
				end
				p.maxangular = 1000
				p.maxangulardamp = 500
				p.maxspeeddamp = 70
				p.maxspeed = 90
				if self.Weapon:GetClass() == "murwep_ragdoll_melee" then
					p.maxspeeddamp = 150
					p.maxspeed = 300
					p.pos = boneh:GetPos() + aimvector * 24 + eang:Up()*4 - eang:Right()*4
				end
				p.teleportdistance = 0
				p.deltatime = CurTime() - self.delta
				if p.angle:IsEqualTol(bonerh1:GetAngles(), 25) then
					bonerh1:SetAngles(LerpAngle(1, bonerh1:GetAngles(), p.angle))
				else
					bonerh1:SetAngles(LerpAngle(0.5, bonerh1:GetAngles(), p.angle))
				end
			else
				p.secondstoarrive = moves * 0.1
				p.pos = boneh:GetPos() + aimvector * (isgrab and 96 or 32) + eang:Right()*0
				p.angle = eang
				p.angle.z = 90
				p.maxangular = 670
				p.maxangulardamp = 600
				p.maxspeeddamp = 100
				p.maxspeed = 150
				p.teleportdistance = 0
				p.deltatime = CurTime() - self.delta
			end
			bonerh1:Wake()
			bonerh1:ComputeShadowControl(p)
		elseif type == "left" then
			local p = {}
			p.secondstoarrive = moves * 0.1
			p.pos = boneh:GetPos() + aimvector * (isgrab and 96 or 32)
			p.angle = eang
			p.angle.z = 90
			p.maxangular = 670
			p.maxangulardamp = 600
			p.maxspeeddamp = 100
			p.maxspeed = 150
			p.teleportdistance = 0
			p.deltatime = CurTime() - self.delta

			bonelh1:Wake()
			bonelh1:ComputeShadowControl(p)
		elseif type == "all" then
			if IsValid(self.Weapon) and self.Weapon.data.twohand then
				local p = {}
				p.secondstoarrive = 0.00000001
				p.pos = boneh:GetPos() + aimvector * 26 + eang:Up() * 4
				p.angle = eang
				p.angle.z = 0
				p.maxangular = 1000
				p.maxangulardamp = 500
				p.maxspeeddamp = 70
				p.maxspeed = 90
				p.teleportdistance = 0
				p.deltatime = CurTime() - self.delta

				if self.Weapon:GetClass() == "murwep_ragdoll_melee" then
					p.maxspeeddamp = 120
					p.maxspeed = 200
				else
					if self.Owner:IsWepRagReloading() then
						p.pos = boneh:GetPos() + aimvector * 8 - eang:Right()*2 - eang:Up() * 12
					else
						local angz = p.angle
						angz.z = 0
						if p.angle:IsEqualTol(bonerh1:GetAngles(), 100) then
							bonerh1:SetAngles(LerpAngle(1, bonerh1:GetAngles(), angz))
						end
					end
				end

				bonelh1:Wake()
				bonelh1:ComputeShadowControl(p)

				p.pos = boneh:GetPos() + aimvector * 17 + eang:Up() * 4 + eang:Right()*4
				p.angle = eang
				p.angle.z = 180
				
				if p.angle:IsEqualTol(bonerh1:GetAngles(), 10) then
					bonerh1:SetAngles(LerpAngle(1, bonerh1:GetAngles(), p.angle))
				end

				bonerh1:Wake()
				bonerh1:ComputeShadowControl(p)
				self.Owner.using_twohand = true
			elseif IsValid(self.Weapon) and !self.Weapon.data.twohand then
				local p = {}
				p.secondstoarrive = moves * 0.4
				p.pos = boneh:GetPos()  + eang:Forward()*(isgrab and 25 or 20) - eang:Right()*15
				p.angle = eang
				p.angle.z = 90
				p.maxangular = 670
				p.maxangulardamp = 600
				p.maxspeeddamp = 100
				p.maxspeed = 150
				p.teleportdistance = 0
				p.deltatime = CurTime() - self.delta

				bonelh1:Wake()
				bonelh1:ComputeShadowControl(p)

				p.pos = boneh:GetPos()  + eang:Forward()*(isgrab and 25 or 20) + eang:Right()*0
				p.secondstoarrive = moves * 0.4
				p.pos = boneh:GetPos() + eang:Forward()*30 + eang:Right()*5
				p.angle = eang
				p.angle:RotateAroundAxis(eang:Right(), 180)
				p.maxangular = 670
				p.maxangulardamp = 600
				p.maxspeeddamp = 100
				p.maxspeed = 150
				p.teleportdistance = 0
				p.deltatime = CurTime() - self.delta
				bonerh1:Wake()
				bonerh1:ComputeShadowControl(p)
			else
				local p = {}
				p.secondstoarrive = moves * 0.2
				p.pos = boneh:GetPos() + aimvector * (isgrab and 65 or 30) - eang:Right()*8
				p.angle = eang + Angle(0, 0, 90)
				p.maxangular = 670
				p.maxangulardamp = 600
				p.maxspeeddamp = 100
				p.maxspeed = 150
				p.teleportdistance = 0
				p.deltatime = CurTime() - self.delta

				bonelh1:Wake()
				bonelh1:ComputeShadowControl(p)
				p.pos = boneh:GetPos() + aimvector * (isgrab and 65 or 30) + eang:Right()*8
				bonerh1:Wake()
				bonerh1:ComputeShadowControl(p)
			end
		end
	end
end

function ent:FireHand(reload)
	if IsValid(self.Owner) then
		local recoil = self.Weapon.Weapon.IronRecoilMultiplier
		if not recoil then
			recoil = 1
		end
		local torque = self.Weapon:GetUp() * (500 * recoil)
		local bone1 = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_R_Hand")))
		local bone2 = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_R_Forearm")))

		if self.Weapon.data.twohand then
			bone1 = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_L_Hand")))
			bone2 = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_L_Forearm")))
		end

		if reload then
			local bones = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_Spine4")))
			torque = (bones:GetPos() - bone1:GetPos()):GetNormalized() * 3000
		end

		bone1:ApplyForceCenter(torque)
		bone2:ApplyForceCenter(torque)
	end
end

function ent:TryStanding(inputState)
	if self.CanStanding and self.Owner.IsRagStanding and self.Owner.CanStandInRag and not self.Owner:GetNW2Bool("ForceProneOnly", false) then
		self.CustomHeightHead = 76
		if self.Owner:KeyDown(IN_DUCK) then
			self.CustomHeightHead = 40
		end

		local bone_spine4 = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_Spine4")))
		local bone_spine = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_Spine")))
		local bone_pelvis = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_Pelvis")))
		local cantmove = false
		
		local pos1 = MuR:BoneData(self, "ValveBiped.Bip01_Spine4")
		local tr = util.TraceLine({
			start = pos1,
			endpos = pos1 - Vector(0, 0, 999999),
			filter = function(ent) 
				if ent:GetClass() == "murwep_ragdoll_weapon" or ent == self then
					return 
				end
			end,
		})
		
		local groundPos = tr.HitPos
		local stepPhase = CurTime() * 2
		local isRightStep = math.floor(stepPhase) % 2 == 0
		
		local bone_l_foot = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_L_Foot")))
		local bone_r_foot = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_R_Foot")))
		local bone_l_calf = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_L_Calf")))
		local bone_r_calf = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_R_Calf")))
		
		local bone_forward = isRightStep and bone_r_foot or bone_l_foot
		local bone_back = isRightStep and bone_l_foot or bone_r_foot
		local calf_forward = isRightStep and bone_r_calf or bone_l_calf
		local calf_back = isRightStep and bone_l_calf or bone_r_calf

		local rightInput = 0
		local forwardInput = 0
		local mult = 1
		if cantmove then
			mult = 0
		end
		if mult == 0 then return end
		
		local isMoving = false
		
		if inputState[IN_FORWARD] then
			forwardInput = 32 * mult
			isMoving = true
		elseif inputState[IN_BACK] then
			forwardInput = -32 * mult
			isMoving = true
		end

		if inputState[IN_MOVERIGHT] then
			rightInput = 16 * mult
			isMoving = true
		elseif inputState[IN_MOVELEFT] then
			rightInput = -16 * mult
			isMoving = true
		end

		local moveDir = self.Owner:GetForward() * forwardInput + self.Owner:GetRight() * rightInput
		
		if isMoving then
			local stepHeight = math.sin(stepPhase * math.pi) * 8 + 4
			
			local p = {}
			p.secondstoarrive = 0.4
			p.pos = groundPos + self.Owner:GetForward() * forwardInput + self.Owner:GetRight() * rightInput + Vector(0, 0, stepHeight * mult)
			p.angle = bone_forward:GetAngles()
			p.maxangular = 670
			p.maxangulardamp = 100
			p.maxspeed = 600
			p.maxspeeddamp = 50
			p.teleportdistance = 0
			p.deltatime = CurTime() - self.delta

			bone_forward:Wake()
			bone_forward:ComputeShadowControl(p)
			
			p.pos = groundPos - self.Owner:GetForward() * forwardInput - self.Owner:GetRight() * rightInput + Vector(0, 0, 4 * mult)
			
			bone_back:Wake()
			bone_back:ComputeShadowControl(p)
			
			local calfLift = math.sin(stepPhase * math.pi * 2) * 15
			if calfLift > 0 then
				local cp = {}
				cp.secondstoarrive = 0.2
				cp.pos = calf_forward:GetPos() + Vector(0, 0, calfLift)
				cp.angle = calf_forward:GetAngles()
				cp.maxangular = 300
				cp.maxangulardamp = 60
				cp.maxspeed = 300
				cp.maxspeeddamp = 30
				cp.teleportdistance = 0
				cp.deltatime = CurTime() - self.delta
				
				calf_forward:Wake()
				calf_forward:ComputeShadowControl(cp)
			end
		else
			local idleOffset = math.sin(CurTime() * 1.5) * 0.5
			
			local p = {}
			p.secondstoarrive = 0.5
			p.pos = groundPos + self.Owner:GetRight() * 8 + Vector(0, 0, 4 * mult + idleOffset)
			p.angle = bone_r_foot:GetAngles()
			p.maxangular = 670
			p.maxangulardamp = 100
			p.maxspeed = 600
			p.maxspeeddamp = 50
			p.teleportdistance = 0
			p.deltatime = CurTime() - self.delta
			
			bone_r_foot:Wake()
			bone_r_foot:ComputeShadowControl(p)
			
			p.pos = groundPos - self.Owner:GetRight() * 8 + Vector(0, 0, 4 * mult - idleOffset)
			
			bone_l_foot:Wake()
			bone_l_foot:ComputeShadowControl(p)
		end

		local p = {}
		p.secondstoarrive = self.Owner:KeyDown(IN_DUCK) and 0.4 or 0.25
		p.pos = bone_spine4:GetPos() + self.Owner:GetForward() * forwardInput + self.Owner:GetRight() * rightInput
		p.angle = bone_spine4:GetAngles()
		p.maxangular = 670
		p.maxangulardamp = 100
		p.maxspeed = 600
		p.maxspeeddamp = 50
		p.teleportdistance = 0
		p.deltatime = CurTime() - self.delta

		bone_spine4:Wake()
		bone_spine4:ComputeShadowControl(p)
	end
end

function ent:GetUpToStandPos()
	if IsValid(self.Owner) then
		local boneh = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_Head1")))
		local bone_spine = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_Spine")))
		local bonel = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_L_Calf")))
		local boner = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_R_Calf")))
		
		local pos1 = MuR:BoneData(self, "ValveBiped.Bip01_Head1")
		local tr = util.TraceLine({
			start = pos1,
			endpos = pos1 - Vector(0, 0, 999999),
			mask = MASK_PLAYERSOLID,
			filter = function(e) 
				if IsValid(self.Weapon) and e == self.Weapon or e == self then 
					return false 
				else
					return true
				end 
			end,
		})
		
		local pos2 = tr.HitPos
		local p = {}
		
		local isUsingE = self.Owner:KeyDown(IN_USE)
		
		local ang
		if isUsingE then
			if not self.FixedAngle then
				self.FixedAngle = Angle(self.Owner:EyeAngles())
				self.FixedAngle:RotateAroundAxis(self.FixedAngle:Forward(), 90)
				self.FixedAngle:RotateAroundAxis(self.FixedAngle:Up(), 90)
			end
			
			local currentEyeAng = self.Owner:EyeAngles()
			local angleDiff = math.abs(math.AngleDifference(currentEyeAng.y, self.FixedAngle.y))
			
			ang = self.FixedAngle
		else
			self.FixedAngle = nil
			ang = self.Owner:EyeAngles()
			ang:RotateAroundAxis(ang:Forward(), 90)
			ang:RotateAroundAxis(ang:Up(), 90)
		end
		
		p.secondstoarrive = 0.0001
		p.pos = pos2 + Vector(0, 0, 16)
		local hg = self.CustomHeightHead
		if hg then
			p.pos = pos2 + Vector(0, 0, hg)
			self.CustomHeightHead = nil
		end
		
		if IsValid(constraint.GetAllConstrainedEntities(game.GetWorld())[self]) then
			p.pos = boneh:GetPos() + Vector(0, 0, 4)
		end
		
		if self.Owner.using_twohand then
			p.pos = p.pos - self.Owner:EyeAngles():Forward() * 1
		end
		
		p.angle = ang
		p.maxangular = 1200
		p.maxangulardamp = 1000
		p.maxspeed = 80
		p.maxspeeddamp = 50
		p.teleportdistance = 0
		p.deltatime = CurTime() - self.delta

		if p.angle:IsEqualTol(boneh:GetAngles(), 20) then
			boneh:SetAngles(LerpAngle(0.5, boneh:GetAngles(), p.angle))
		else
			boneh:SetAngles(LerpAngle(0.1, boneh:GetAngles(), p.angle))
		end

		boneh:Wake()
		boneh:ComputeShadowControl(p)
	end
end

local function FindClosestEntity(pos, filter, allowWorld, directionBias, ent)
	local radius = 6
	if not filter then
		filter = function(e)
			if IsValid(ent.Weapon) and e == ent.Weapon or e == ent then 
				return false 
			else
				return true
			end 
		end
	end

	local trace = {
		start = pos + directionBias * radius / 2,
		endpos = pos + directionBias * radius / 2,
		mins = Vector(-radius / 2, -radius / 2, -radius / 2),
		maxs = Vector(radius / 2, radius / 2, radius / 2),
		filter = filter,
		mask = MASK_SHOT,
		ignoreworld = not allowWorld
	}

	local res = util.TraceHull(trace)
	if not res or not res.Hit or not res.Entity then return end

	return res.Entity, res.PhysicsBone, res.Entity:GetPhysicsObjectNum(res.PhysicsBone)
end

function ent:GrabHand(bool, isright)
	if isright then
		if bool and not IsValid(self.RightHandGrab) then
			local limbBone = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_R_Hand")))
			local prop, physObjId, physObj = FindClosestEntity(limbBone:GetPos(), nil, true, limbBone:GetVelocity():GetNormalized(), self)
			if not prop or ((not IsValid(prop) or not IsValid(physObj)) and not prop:IsWorld()) then return false end
			local weld = constraint.Weld(self, prop, self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_R_Hand")), physObjId, 10000, false, false)
			self.RightHandGrab = weld
			self:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 7) .. ".wav", 50, 110, 0.5)
		elseif not bool and IsValid(self.RightHandGrab) then
			self.RightHandGrab:Remove()
			self:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 7) .. ".wav", 50, 70, 0.5)
		end
	else
		if bool and not IsValid(self.LeftHandGrab) then
			local limbBone = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_L_Hand")))
			local prop, physObjId, physObj = FindClosestEntity(limbBone:GetPos(), nil, true, limbBone:GetVelocity():GetNormalized(), self)
			if not prop or ((not IsValid(prop) or not IsValid(physObj)) and not prop:IsWorld()) then return false end
			local weld = constraint.Weld(self, prop, self:TranslateBoneToPhysBone(self:LookupBone("ValveBiped.Bip01_L_Hand")), physObjId, 10000, false, false)
			self.LeftHandGrab = weld
			self:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 7) .. ".wav", 50, 110)
		elseif not bool and IsValid(self.LeftHandGrab) then
			self.LeftHandGrab:Remove()
			self:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 7) .. ".wav", 50, 70)
		end
	end
end

function ent:GiveDamageOnRag(dmg)
	local att = dmg:GetAttacker()
	local dm = dmg:GetDamage()
	local pos = dmg:GetDamagePosition()
	local dt = dmg:GetDamageType()
	local dir = dmg:GetDamageForce()
	local bonename = self:GetNearestBoneFromPos(pos, dir)
	local bonetype = GetCorrectTypeOfBone(bonename)
	if att == self or att:IsPlayer() and !IsValid(att:GetRD()) and dt == 1 or att:GetClass() == "prop_ragdoll" and att == self or string.match(att:GetClass(), "murwep_ragdoll_") and dm < 50 or dt == 1 and dm <= 10 then
		dm = 0
	end

	if dt == DMG_BURN or dt == DMG_DIRECT then
		dm = dm * 5	
	end

	if dmg:IsExplosionDamage() then
		dm = dmg:GetDamage() * 2
	elseif string.match(att:GetClass(), "prop_") and dt == DMG_CRUSH then
		dm = dmg:GetDamage() * 0.1

		if dm < 10 then
			dm = 0
		end
	elseif att:IsWorld() and dt == DMG_CRUSH and dir:Length() < 4000 then
		dm = dmg:GetDamage() * 0.2
	end

	if bonetype == "r_hand" or bonetype == "l_hand" then
		dm = dm * 0.4
	elseif bonetype == "r_leg" or bonetype == "l_leg" then
		dm = dm * 0.6
	elseif bonetype == "torso" then
		dm = dm * 1
	elseif bonetype == "head" then
		if dmg:IsBulletDamage() then
			dm = dm * 4
		else
			dm = dm * 2
		end
	end

	if dm > 5 and self.MaxBlood > 0 then
		self.MaxBlood = self.MaxBlood - 1
		MuR:CreateBloodPool(self, self:LookupBone(bonename), 1, 0)
	end

	local ply = self.Owner
	if IsValid(ply) and ply:Alive() and dm > 0 then
		local is_limb = bonename and (string.find(bonename, "_L_") or string.find(bonename, "_R_"))
		
		local player_damage = is_limb and (dm / 8) or dm
		local timeget_damage = is_limb and (dm / 8 / 5) or (dm / 5)
		
		self:TakeImpact(dm, bonename, dir)
		dmg:SetDamage(player_damage)
		ply:TakeDamageInfo(dmg)
		ply:TimeGetUpChange(timeget_damage)
	end
end

function ent:TakeImpact(dm, bonename, dir)
	local normal = dir:GetNormalized()*dm*50
	local bone = self:GetPhysicsObjectNum(self:TranslateBoneToPhysBone(self:LookupBone(bonename)))
	local standing = self.Owner.IsRagStanding
	bone:ApplyForceCenter(normal)
	if standing then
		timer.Simple(math.Rand(0.01, 0.3), function()
			if !IsValid(self) or !IsValid(self.Owner) then return end
			self.Owner.IsRagStanding = true
		end)
	end
end

function ent:GetNearestBoneFromPos(pos, dir)
	dir = dir:GetNormalized()
	dir:Mul(1024 * 8)

	local tr = {}
	tr.start = pos
	tr.endpos = pos + dir
	tr.filter = function(ent)
		return ent == self
	end
	tr.ignoreworld = true

	local result = util.TraceLine(tr)
	if result.Entity ~= self then
		tr.endpos = pos - dir

		local result = util.TraceLine(tr)
		local pb = result.PhysicsBone

		if self:TranslatePhysBoneToBone(pb) then
			pb = self:GetBoneName(self:TranslatePhysBoneToBone(pb))
		else
			pb = "ValveBiped.Bip01_Pelvis"
		end
		return pb
	else
		local pb = result.PhysicsBone

		if self:TranslatePhysBoneToBone(pb) then
			pb = self:GetBoneName(self:TranslatePhysBoneToBone(pb))
		else
			pb = "ValveBiped.Bip01_Pelvis"
		end
		return pb
	end
end

function ent:MakeEffects(ply)
	local dmg = ply.LastDamageInfo
	if not dmg then return end
	local type = dmg[1]
	local boneid = self:LookupBone(self:GetNearestBoneFromPos(dmg[2], dmg[4]))
	local eff = 0
	local name = GetCorrectTypeOfBone(boneid)

	if ply:GetNW2Float("BleedLevel") > 1 then
		eff = 2
	end

	if type == DMG_FALL or type == DMG_CLUB or type == DMG_CRUSH then
		eff = -1
	end

	if type == DMG_SLASH or dmg[3] then
		eff = 2
	end

	if eff >= 0 then
		MuR:CreateBloodPool(self, boneid, eff, 1)
	end
end

function ent:CrawlLogic()
	local ply = self.Owner
	if IsValid(ply) then
		if ply.ragcrawl_clickTime == nil then ply.ragcrawl_clickTime = 0 end
		if ply.ragcrawl_clickType == nil then ply.ragcrawl_clickType = "" end
		if ply.ragcrawl_prevLeft == nil then ply.ragcrawl_prevLeft = false end
		if ply.ragcrawl_prevRight == nil then ply.ragcrawl_prevRight = false end

		local makemove = SysTime() - ply.ragcrawl_clickTime <= 0.2
		if not makemove then
			
		end

		if ply:KeyDown(IN_ATTACK) and not ply.ragcrawl_prevLeft then
			ply.ragcrawl_clickTime = SysTime()
			ply.ragcrawl_clickType = "left"
		end

		if ply:KeyDown(IN_ATTACK2) and not ply.ragcrawl_prevRight then
			ply.ragcrawl_clickTime = SysTime()
			ply.ragcrawl_clickType = "right"
		end
	end
end

------------------------HOOKS-----------------------------------

hook.Add("PlayerSwitchWeapon", "MuR_ChangeWeaponInRagdoll", function(ply, oldwep, wep)
	if (MuR.Gamemode == 5 or MuR.Gamemode == 11 or MuR.Gamemode == 12 or MuR.Gamemode == 17) and MuR.TimeCount + 22 > CurTime() or ply:GetNW2String("Class") == "Zombie" and IsValid(wep) and wep:GetClass() != "mur_zombie" then
		return true
	end
	if ply:GetNW2Bool("IsUnconscious", false) then
		return true
	end
	local rag = ply:GetRD()
	if IsValid(rag) then
		ply:GiveRagdollWeapon(rag, wep)
	end
end)

hook.Add("InitPostEntity", "MuR.Init", function()
	function pl:CreateRagdoll()
	end

	function pl:GetRagdollEntity()
		return self:GetRD()
	end
end)

hook.Add("SetupPlayerVisibility", "AddRTCamera", function(ply)
	if IsValid(ply:GetRD()) then
		AddOriginToPVS(ply:GetRD():GetPos()+Vector(0,0,8))
	end
end)

hook.Add("Think", "MuR.RagdollDamage", function()
	for _, ply in pairs(player.GetAll()) do
		local rag = ply:GetRD()

		if IsValid(rag) and ply:Alive() then
			ply.CanStandInRag = ply:Health() >= 30 and !rag.Gibbed and ply:GetNW2Float('RD_GetUpTime')-CurTime() < 20 and !ply:GetNW2Bool("LegBroken") and not ply:GetNW2Bool("IsUnconscious", false)
			ply.CurrentEyeAngle = ply:GetAimVector():Angle()
			ply:SetNoDraw(true)
			ply:SetNotSolid(true)
			ply:DrawShadow(false)
			ply:SetActiveWeapon(nil)
			local pos = rag:GetAttachment(rag:LookupAttachment("eyes")).Pos-Vector(0,0,48)
			ply:SetPos(pos)
			ply:SetVelocity(-ply:GetVelocity())
			ply:SetNW2Entity("RD_EntCam", rag)
			ply:SetSVAnimation("rd_getup1")
			ply:ExitVehicle()
			ply:SetNoTarget(true)
			if IsValid(ply.Bullseye) then
				ply.Bullseye:SetPos(rag:GetBonePosition(rag:LookupBone("ValveBiped.Bip01_Spine2")))
				ply.Bullseye.VJ_NPC_Class = ply.VJ_NPC_Class
			end

			local isbleeding = (ply:GetNW2Float("BleedLevel", 0) > 1 or ply:GetNW2Bool("HardBleed", false)) or false
			if isbleeding then
				MuR:AddSmearingBlood(rag)
			else
				MuR:RemoveSmearingBlood(rag)
			end

			local posh = MuR:BoneData(rag, "ValveBiped.Bip01_Pelvis")
			local isUnconscious = ply:GetNW2Bool("IsUnconscious", false)

			local isfire = IsValid(rag.Weapon) and rag.Weapon:GetClass() == "murwep_ragdoll_weapon"
			if isfire and not isUnconscious then
				if rag.Weapon.data.twohand and ply:KeyDown(IN_ATTACK2) then
					rag:PullHand("all", 120)
				elseif ply:KeyDown(IN_ATTACK2) then
					rag:PullHand("right", 120)
				else
					ply.using_twohand = false
				end
			elseif not isUnconscious then
				rag:CrawlLogic()
				if ply:KeyDown(IN_ATTACK) and ply:KeyDown(IN_ATTACK2) then
					rag:PullHand("all", 120)
				elseif ply:KeyDown(IN_ATTACK) then
					rag:PullHand("left", 120)
				elseif ply:KeyDown(IN_ATTACK2) then
					rag:PullHand("right", 120)
				else
					ply.using_twohand = false
				end
			end

			local wep = rag.Weapon
			if IsValid(wep) and not isUnconscious then
				wep:Shoot(ply:KeyDown(IN_ATTACK))

				if ply:KeyDown(IN_RELOAD) then
					wep:Reload()
				end
			end

			local hpos = MuR:BoneData(rag, "ValveBiped.Bip01_Spine4")
			local isGrabbed = IsValid(rag.LeftHandGrab) or IsValid(rag.RightHandGrab)
			
			if ((not isGrabbed and MuR:CheckHeight(rag, hpos) < 80) or isGrabbed) and ply.IsRagStanding == true and not isUnconscious then
				rag:GetUpToStandPos()
			end

			local tab = {
				[IN_MOVELEFT] = ply:KeyDown(IN_MOVELEFT) and not isUnconscious,
				[IN_MOVERIGHT] = ply:KeyDown(IN_MOVERIGHT) and not isUnconscious,
				[IN_FORWARD] = ply:KeyDown(IN_FORWARD) and not isUnconscious,
				[IN_BACK] = ply:KeyDown(IN_BACK) and not isUnconscious,
			}
			rag:TryStanding(tab)

			if (ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK)) and not isUnconscious then
				rag:RollBone(tab, standing)
			end

			ply.delta = CurTime()
		end
	end

	for _, rag in ipairs(ents.FindByClass("prop_ragdoll")) do
		if rag.isRDRag then
			if not rag.IsDead and rag.Moans > 0 and rag.DelayBetweenMoans < CurTime() then
				rag.Moans = rag.Moans - 1
				rag.DelayBetweenMoans = CurTime() + 6

				if rag.Male then
					rag:EmitSound("vo/npc/male01/moan0" .. math.random(1, 5) .. ".wav", 60)
				else
					rag:EmitSound("vo/npc/female01/moan0" .. math.random(1, 5) .. ".wav", 60)
				end
			end

			if rag.Moans > 0 and not rag.IsDead and rag.DelayBetweenStruggle < CurTime() then
				rag.DelayBetweenStruggle = CurTime() + math.Rand(0.1, 1)
				--rag:StruggleBone()
			end
		end
	end
end)

hook.Add("PlayerSpawn", "MuR.RagdollDamage", function(ply)
	local rag = ply:GetRD()

	if IsValid(rag) then
		rag:Remove()
	end

	ply:SetNW2Entity("RD_EntCam", NULL)
end)

hook.Add("PlayerDeath", "MuR.RagdollDamage", function(ply)
	local rag = ply:GetRD()
	if IsValid(rag) then
		rag:GiveWeaponsFromPly()
		rag:MakeEffects(ply)
		ply:UnconnectRagdoll(true)
		local rag_old = ply:GetRagdollEntity()
		if IsValid(rag_old) then
			rag_old:Remove()
		end
	else
		rag = ply:CreateAdvancedRagdoll(true)
		rag:GiveWeaponsFromPly()
		rag:MakeEffects(ply)
		ply:UnconnectRagdoll(true)
	end
	if ply:IsRolePolice() and IsValid(rag) then
		rag.IsPoliceCorpse = true
		timer.Create("CheckPoliceBody"..rag:EntIndex(), 60, 1, function()
			if !IsValid(rag) then return end
			MuR:CallPolice(0.4)
		end)
	end
end)

hook.Add("KeyPress", "Murdered_Ragdolling", function( ply, key)
	local rag = ply:GetRD()

	if IsValid(rag) and ply:Alive() and not ply:GetNW2Bool("IsUnconscious", false) then
		if key == IN_SPEED then
			rag:GrabHand(not IsValid(rag.LeftHandGrab), false)
		elseif key == IN_WALK then
			rag:GrabHand(not IsValid(rag.RightHandGrab), true)
		elseif key == IN_JUMP then
			rag:JumpOutGrab()
		end
	end
end)

hook.Add("KeyRelease", "Murdered_Ragdolling", function(ply, key)
	local rag = ply:GetRD()

	if IsValid(rag) and ply:Alive() and tobool(ply:GetInfoNum("blsd_ragdoll_hold_grab", 0)) and not ply:GetNW2Bool("IsUnconscious", false) then
		if key == IN_SPEED then
			rag:GrabHand(false, false)
		elseif key == IN_WALK then
			rag:GrabHand(false, true)
		end
	end
end)

hook.Add("PlayerButtonDown", "Murdered_Ragdolling", function(ply, but)
	local rag = ply:GetRD()

	if IsValid(rag) and ply:Alive() then
		if but == KEY_C then
			local pos = MuR:BoneData(rag, "ValveBiped.Bip01_Pelvis")
			
			if ply:TimeGetUp(true) and MuR:CheckHeight(rag, pos) < 72 and ply:CanGetUp() and not rag.Gibbed and not ply:GetNW2Bool("IsUnconscious", false) then
				if MuR:CheckHeight(rag, pos) < 16 then
					ply:StopRagdolling(false, true)
				else
					ply:StopRagdolling(false)
				end
			end
		elseif but == KEY_F then
			if not ply:GetNW2Bool("IsUnconscious", false) then
				if not ply.IsRagStanding then
					ply.IsRagStanding = false
				end
				ply.IsRagStanding = !ply.IsRagStanding
			end
		elseif but == KEY_V then
			if not ply:GetNW2Bool("IsUnconscious", false) then
				rag.CanStanding = !rag.CanStanding
			end
		end
	end
end)

hook.Add("PlayerSwitchFlashlight", "MuR_BlockFlashLight", function(ply, enabled)
	if enabled and IsValid(ply:GetRD()) then return false end
end)