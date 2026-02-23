AddCSLuaFile()
SWEP.Base = "mur_weapon_base"
SWEP.PrintName = "Police Taser"
SWEP.Slot = 1
SWEP.DisableSuicide = true
SWEP.ViewModelFOV = 80
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/murdered/weapons/c_taser.mdl"
SWEP.WorldModel = "models/murdered/weapons/w_taser.mdl"
SWEP.SwayScale = 0.6
SWEP.BobScale = 0.7
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "GaussEnergy"
SWEP.IronsightPos = Vector(-2, -3, 0)
SWEP.IronsightFOV = 60
SWEP.RunPos = Vector(0, 4, -8)
SWEP.RunAng = Angle(-50, 0, -4)
SWEP.WorldModelPosition = Vector(3.5, -1.5, -2)
SWEP.WorldModelAngle = Angle(0, 270, 90)
SWEP.HoldType = "revolver"
SWEP.AimHoldType = "revolver"
SWEP.RunHoldType = "normal"
SWEP.HitDistance = 250
SWEP.Category = "Bloodshed - Police"
SWEP.Spawnable = true

SWEP.TPIKForce = true

function CreateBlueTaserEffect(startPos, endPos, duration)
    local effect = EffectData()
    effect:SetStart(startPos)
    effect:SetOrigin(endPos)
    effect:SetScale(1)
    effect:SetMagnitude(duration)
    effect:SetFlags(0)
    util.Effect("ToolTracer", effect)
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	local ow = self:GetOwner()

	if CLIENT and IsFirstTimePredicted() then
		local angle = Angle(-self.Primary.Throw, 0, 0)
		self:GetOwner():ViewPunchClient(angle)
		local sp = ow:GetBonePosition(ow:LookupBone("ValveBiped.Bip01_R_Hand"))
		local ep = ow:GetShootPos() + ow:GetAimVector() * self.HitDistance
		CreateBlueTaserEffect(sp, ep, 5)
	end

	local vm = ow:GetViewModel()
	local seq = vm:SelectWeightedSequence(ACT_VM_PRIMARYATTACK)
	vm:SendViewModelMatchingSequence(seq)

	if SERVER then
		ow:EmitSound(")murdered/other/taser_shoot.mp3", 60)

		local sp = ow:GetShootPos()
		local ep = ow:GetShootPos() + ow:GetAimVector() * self.HitDistance
		local tr = util.TraceHull({
			start = sp,
			endpos = ep,
			filter = ow,
			mask = MASK_SHOT_HULL,
			mins = Vector(-10,-10,-10),
			maxs = Vector(10,10,10),
		})
		local tr2 = util.TraceLine({
			start = sp,
			endpos = ep,
			filter = ow,
			mask = MASK_SHOT_HULL,
		})
		if !tr.Hit or !tr.Entity:IsPlayer() and !tr.Entity.isRDRag then
			tr = tr2
		end

		local i = 0
		local tar = tr.Entity
		if IsValid(tar) and tar.isRDRag then
			tar = tar.Owner
		end

		if IsValid(tar) and tar:IsPlayer() then
			local ind = tar:EntIndex()
			tar:StartRagdolling()
			tar:EmitSound(")murdered/other/taser.mp3", 60)

			timer.Create("Tasered" .. ind, 0.01, 350, function()
				i = i + 1

				if not IsValid(tar) or not tar:Alive() then
					timer.Remove("Tasered" .. ind)

					return
				end

				if IsValid(tar:GetRD()) then
					tar:GetRD():StruggleBone()
					tar.IsRagStanding = false

					local light = EffectData()
					light:SetOrigin(tar:GetRD():WorldSpaceCenter())
					light:SetMagnitude(1)
					light:SetEntity(tar:GetRD())
					util.Effect("TeslaHitboxes", light)
				else
					local light = EffectData()
					light:SetOrigin(tar:WorldSpaceCenter())
					light:SetMagnitude(1)
					light:SetEntity(tar)
					util.Effect("TeslaHitboxes", light)
				end
				local rnd = tar:EyeAngles() + AngleRand(-10, 10)
				rnd.z = 0
				tar:SetEyeAngles(rnd)
			end)
		elseif IsValid(tar) and tar.SuspectNPC then
			tar:FullSurrender()
			tar:EmitSound(")murdered/other/taser.mp3", 60)
			local ind = tar:EntIndex()

			timer.Create("Tasered" .. ind, 0.01, 350, function()
				i = i + 1

				if not IsValid(tar) then
					timer.Remove("Tasered" .. ind)

					return
				end

				local light = EffectData()
				light:SetOrigin(tar:WorldSpaceCenter())
				light:SetMagnitude(1)
				light:SetEntity(tar)
				util.Effect("TeslaHitboxes", light)
			end)
		end

		self:TakePrimaryAmmo(1)
		self:SetNextPrimaryFire(CurTime() + 2)
	end
end