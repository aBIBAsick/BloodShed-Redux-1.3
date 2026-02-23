local function create_materials( mat_names )
	local mats = {}

	for _, v in ipairs(mat_names) do
		local imat = Material(v)
		table.insert(mats, imat)
	end

	return mats
end

local blood_materials = create_materials({
	"decals/blood1",
	"decals/blood2",
	"decals/blood3",
	"decals/blood4",
	"decals/blood5",
	"decals/blood6",
})

local blood_drop_sounds = {
	")enh_blood_splatter_drips/drip_1.wav",
	")enh_blood_splatter_drips/drip_2.wav",
	")enh_blood_splatter_drips/drip_3.wav",
	")enh_blood_splatter_drips/drip_4.wav",
	")enh_blood_splatter_drips/drip_5.wav",
}

function EFFECT:Init( data )
	self.Entity = data:GetEntity()
	self.Bone = data:GetAttachment()
	self.Intensity = data:GetMagnitude() or 1
	self.Emitter = ParticleEmitter(self.Entity:GetPos(), false)
	self.Emitter3D = ParticleEmitter(self.Entity:GetPos(), true)
	self.NextEmit = CurTime()
	self.StartTime = CurTime()
	self.DieTime = CurTime() + math.Rand(4, 8)
	self.PulsePhase = math.Rand(0, math.pi * 2)
	self.PulseRate = math.Rand(1.0, 1.4)
	self.BaseVelocity = VectorRand(-20, 20)
	self.BaseVelocity.z = math.Rand(30, 80)
end

function EFFECT:Think()
	if self.DieTime < CurTime() or !IsValid(self.Entity) then
		self.Emitter:Finish()
		return false
	end

	if self.NextEmit > CurTime() then return true end

	local bonePos = self.Entity:GetBonePosition(self.Bone)
	if not bonePos then return true end

	local elapsed = CurTime() - self.StartTime
	local lifeProgress = 1 - (elapsed / (self.DieTime - self.StartTime))
	
	local pulse = 0.4 + 0.6 * math.abs(math.sin(CurTime() * self.PulseRate * math.pi + self.PulsePhase))
	local intensityMult = pulse * lifeProgress * self.Intensity
	
	local isPeak = pulse > 0.8
	local particleCount = isPeak and math.random(3, 6) or math.random(1, 2)
	
	for i = 1, particleCount do
		local sizeMult = 2 * intensityMult
		local length = math.Rand(15, 50) * intensityMult
		
		local vel = Vector(self.BaseVelocity.x, self.BaseVelocity.y, self.BaseVelocity.z)
		vel = vel + VectorRand(-30, 30)
		vel = vel * (0.5 + pulse * 1.5) * intensityMult
		
		if isPeak and math.random(1, 3) == 1 then
			vel = vel * 1.8
			vel.z = vel.z + math.Rand(40, 80)
		end
		
		local particle = self.Emitter:Add(table.Random(blood_materials), bonePos + VectorRand(-2, 2))
		particle:SetDieTime(math.Rand(1.2, 2.0))
		particle:SetStartSize(math.Rand(1.5, 3.5) * sizeMult)
		particle:SetEndSize(0)
		particle:SetStartLength(length * 0.3)
		particle:SetEndLength(length)
		particle:SetGravity(Vector(0, 0, -600))
		particle:SetVelocity(vel)
		particle:SetCollide(true)
		particle:SetBounce(0.2)
		particle:SetAirResistance(50)
		
		if i == 1 then
			particle:SetCollideCallback(function(_, collidepos, normal)
				if math.random(1, 3) == 1 then
					util.DecalEx(
						table.Random(blood_materials),
						Entity(0),
						collidepos,
						normal,
						Color(255, 255, 255),
						math.Rand(0.3, 0.8),
						math.Rand(0.3, 0.8)
					)
				end
				if math.random(1, 4) == 1 then
					sound.Play(table.Random(blood_drop_sounds), collidepos, 55, math.random(90, 115), 0.5)
				end
			end)
		end
	end

	local baseDelay = isPeak and 0.04 or 0.12
	self.NextEmit = CurTime() + baseDelay * (1 / math.max(intensityMult, 0.3))
	
	return true
end

function EFFECT:Render()
end