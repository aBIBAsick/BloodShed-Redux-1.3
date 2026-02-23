local heartBeatSound = nil
local breathingSound = nil
local lastBleedLevel = 0
local lastHardBleed = false
local nextGroan = 0

local function StopBloodSounds()
	if heartBeatSound then
		heartBeatSound:Stop()
		heartBeatSound = nil
	end
	if breathingSound then
		breathingSound:Stop()
		breathingSound = nil
	end
end

local function UpdateBloodSounds()
	if not LocalPlayer():Alive() then
		StopBloodSounds()
		return
	end

	local ply = LocalPlayer()
	local bleedLevel = ply:GetNW2Float("BleedLevel")
	local hardBleed = ply:GetNW2Bool("HardBleed")

	if bleedLevel != lastBleedLevel or hardBleed != lastHardBleed then
		StopBloodSounds()
		lastBleedLevel = bleedLevel
		lastHardBleed = hardBleed
	end

	if hardBleed or bleedLevel >= 2 then
		if not heartBeatSound then
			heartBeatSound = CreateSound(ply, "player/heartbeat1.wav")
		end

		if not heartBeatSound:IsPlaying() then
			local pitch = 100
			local volume = 0.5

			if hardBleed then
				pitch = 130 + math.sin(CurTime() * 4) * 10
				volume = 0.8 + math.sin(CurTime() * 6) * 0.2
			elseif bleedLevel >= 3 then
				pitch = 120 + math.sin(CurTime() * 3) * 8
				volume = 0.6 + math.sin(CurTime() * 4) * 0.15
			elseif bleedLevel == 2 then
				pitch = 110 + math.sin(CurTime() * 2) * 5
				volume = 0.4 + math.sin(CurTime() * 3) * 0.1
			end

			heartBeatSound:SetSoundLevel(0)
			heartBeatSound:ChangePitch(pitch)
			heartBeatSound:ChangeVolume(volume)
			heartBeatSound:Play()
		end
	else
		if heartBeatSound then
			heartBeatSound:FadeOut(2)
			heartBeatSound = nil
		end
	end

	if hardBleed or bleedLevel >= 3 then
		if not breathingSound then
			breathingSound = CreateSound(ply, "player/pl_drown1.wav")
		end

		if not breathingSound:IsPlaying() then
			local pitch = 80
			local volume = 0.3

			if hardBleed then
				pitch = 70 + math.sin(CurTime() * 2) * 10
				volume = 0.5 + math.sin(CurTime() * 3) * 0.15
			elseif bleedLevel >= 3 then
				pitch = 75 + math.sin(CurTime()) * 8
				volume = 0.4 + math.sin(CurTime() * 2) * 0.1
			end

			breathingSound:SetSoundLevel(0)
			breathingSound:ChangePitch(pitch)
			breathingSound:ChangeVolume(volume)
			breathingSound:Play()
		end

		if CurTime() > nextGroan then
			ply:EmitSound("vo/npc/male01/pain0" .. math.random(1,9) .. ".wav", 35, math.random(85, 95))
			nextGroan = CurTime() + math.random(10, 25)
		end
	else
		if breathingSound then
			breathingSound:FadeOut(3)
			breathingSound = nil
		end
	end
end

timer.Create("MuR.BloodSounds", 1, 0, UpdateBloodSounds)

hook.Add("PlayerDeath", "MuR.StopBloodSounds", function(victim)
	if victim == LocalPlayer() then
		StopBloodSounds()
	end
end)

hook.Add("ShutDown", "MuR.StopBloodSounds", StopBloodSounds)

net.Receive("MuR.BloodDamageSound", function()
	local soundType = net.ReadString()

	if soundType == "heartbeat_spike" then
		LocalPlayer():EmitSound("player/heartbeat1.wav", 75, math.random(140, 160), 0.8)
	elseif soundType == "blood_loss" then
		LocalPlayer():EmitSound("player/pl_pain5.wav", 60, math.random(80, 100), 0.5)
	elseif soundType == "weak_pulse" then
		LocalPlayer():EmitSound("player/heartbeat1.wav", 50, math.random(60, 80), 0.3)
	end
end)
