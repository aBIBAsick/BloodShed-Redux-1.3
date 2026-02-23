MuR = MuR or {}
MuR.SubstanceEffects = MuR.SubstanceEffects or {}
MuR.SubstanceEffects.Active = MuR.SubstanceEffects.Active or {}
MuR.SubstanceEffects.Models = MuR.SubstanceEffects.Models or {}
MuR.SubstanceEffects.Sounds = MuR.SubstanceEffects.Sounds or {}

local sin = math.sin
local cos = math.cos
local rand = math.Rand
local CurTime = CurTime
local ScrW, ScrH = ScrW, ScrH
local surface = surface
local LocalPlayer = LocalPlayer
local EyePos = EyePos
local EyeAngles = EyeAngles

net.Receive("MuR.SubstanceVisualClear", function()
	MuR.SubstanceEffects.Active = {}
	for _, ent in pairs(MuR.SubstanceEffects.Models) do SafeRemoveEntity(ent) end
	for _, snd in pairs(MuR.SubstanceEffects.Sounds) do if snd then snd:Stop() end end
	MuR.SubstanceEffects.Models = {}
	MuR.SubstanceEffects.Sounds = {}
end)

net.Receive("MuR.SubstanceVisual", function()
	local sub = net.ReadString()
	local duration = net.ReadFloat()
	local intensity = net.ReadFloat()

	MuR.SubstanceEffects.Active[sub] = {endTime = CurTime() + duration, intensity = intensity}

	if sub == "lsd" then
		local snd = CreateSound(LocalPlayer(), "ambient/levels/citadel/portal_open3.wav")
		snd:PlayEx(0.5, 100)
		snd:ChangePitch(70 + math.random(-20,40), 0)
		MuR.SubstanceEffects.Sounds.lsd = snd

		timer.Create("MuR.LSD.Models", 2.5, math.floor(duration / 2.5), function()
			if not MuR.SubstanceEffects.Active.lsd then return end
			local models = {
				"models/props_junk/gnome.mdl",
				"models/props_c17/doll01.mdl",
				"models/props_lab/huladoll.mdl",
				"models/props/de_tides/vending_turtle.mdl",
				"models/props_c17/TrapPropeller_Engine.mdl"
			}
			local ent = ClientsideModel(table.Random(models), RENDERGROUP_BOTH)
			ent:SetPos(EyePos() + EyeAngles():Forward() * rand(60, 350) + VectorRand() * 150)
			ent:SetAngles(AngleRand())
			ent:Spawn()
			ent:SetRenderMode(RENDERMODE_TRANSALPHA)
			ent:SetColor(Color(255,255,255,180))
			table.insert(MuR.SubstanceEffects.Models, ent)
			timer.Simple(rand(10,25), function() if IsValid(ent) then ent:Remove() end end)
		end)
	end

	if sub == "heroin" then
		local snd = CreateSound(LocalPlayer(), "ambient/atmosphere/underground.wav")
		snd:PlayEx(0.3, 60)
		snd:ChangeVolume(0.6, duration)
		MuR.SubstanceEffects.Sounds.heroin = snd
	end

	if sub == "ketamine" then
		local snd = CreateSound(LocalPlayer(), "ambient/atmosphere/hole_hit3.wav")
		snd:PlayEx(0.4, 80)
		snd:ChangePitch(60, duration)
		MuR.SubstanceEffects.Sounds.ketamine = snd
	end

	if sub == "sarin" or sub == "chlorine" or sub == "phosgene" or sub == "mustard_gas" then
		local snd = CreateSound(LocalPlayer(), "ambient/wind/wind_moan1.wav")
		snd:PlayEx(0.3, 90)
		MuR.SubstanceEffects.Sounds[sub] = snd
	end

	if sub == "mercury" then
		local snd = CreateSound(LocalPlayer(), "ambient/atmosphere/city_rumble_loop1.wav")
		snd:PlayEx(0.5, 50)
		MuR.SubstanceEffects.Sounds.mercury = snd
	end

	if sub == "chloroform" or sub == "midazolam" or sub == "ghb" then
		local snd = CreateSound(LocalPlayer(), "ambient/water/underwater.wav")
		snd:PlayEx(0.6, 80)
		MuR.SubstanceEffects.Sounds[sub] = snd
	end

	if sub == "ammonia" then
		local snd = CreateSound(LocalPlayer(), "ambient/gas/steam_loop1.wav")
		snd:PlayEx(0.4, 120)
		MuR.SubstanceEffects.Sounds.ammonia = snd
	end

	if sub == "nitroglycerin" then
		local snd = CreateSound(LocalPlayer(), "player/heartbeat1.wav")
		snd:PlayEx(1.0, 100)
		MuR.SubstanceEffects.Sounds.nitroglycerin = snd
	end
end)

hook.Add("RenderScreenspaceEffects", "MuR.SubstanceEffects", function()
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:Alive() then return end

	local t = CurTime()

	for sub, data in pairs(MuR.SubstanceEffects.Active) do
		if data.endTime < t then
			MuR.SubstanceEffects.Active[sub] = nil
			continue
		end

		local intensity = data.intensity

		if sub == "meth" then
			local pulse = sin(t * 8) * 0.5 + 0.5
			DrawColorModify({
				["$pp_colour_addr"] = pulse * 0.3,
				["$pp_colour_addg"] = pulse * 0.2,
				["$pp_colour_brightness"] = pulse * 0.2,
				["$pp_colour_contrast"] = 1.6 + pulse * 0.6,
				["$pp_colour_colour"] = 1.5
			})
			DrawSharpen(5 + pulse * 8, 1.2)
			ply:ViewPunch(Angle(sin(t*20)*0.8, sin(t*18)*0.6, 0))

		elseif sub == "cocaine" then
			local pulse = sin(t * 12) * 0.5 + 0.5
			DrawColorModify({
				["$pp_colour_addr"] = 0.1 + pulse * 0.2,
				["$pp_colour_addg"] = pulse * 0.15,
				["$pp_colour_addb"] = pulse * 0.1,
				["$pp_colour_brightness"] = 0.2 + pulse * 0.2,
				["$pp_colour_contrast"] = 1.7 + pulse * 0.5,
				["$pp_colour_colour"] = 1.7
			})
			DrawSharpen(6, 0.8)

		elseif sub == "lsd" then
			local wave = sin(t * 0.8)
			DrawColorModify({
				["$pp_colour_addr"] = sin(t * 3) * 0.8,
				["$pp_colour_addg"] = sin(t * 3.5) * 0.8,
				["$pp_colour_addb"] = sin(t * 4) * 0.8,
				["$pp_colour_colour"] = 2 + wave * 1.5,
				["$pp_colour_contrast"] = 1.8 + sin(t * 1.5) * 0.7,
				["$pp_colour_brightness"] = sin(t * 0.7) * 0.3
			})
			DrawMotionBlur(0.4, 0.95, 0.03)
			DrawBloom(1, wave * 8, 15, 15, 3, wave * 2, 1,1,1)

			ply:ViewPunch(Angle(sin(t*3)*4, cos(t*2.7)*4, sin(t*4)*3))

			for i = 1, 35 do
				local x = ScrW() * 0.5 + sin(t * 1.5 + i*0.3) * ScrW() * 0.9
				local y = ScrH() * 0.5 + cos(t * 1.4 + i*0.4) * ScrH() * 0.9
				local size = 60 + sin(t * 5 + i) * 120
				surface.SetDrawColor(HSVToColor((t*50 + i*30) % 360, 1, 1))
				surface.DrawRect(x - size/2, y - size/2, size, size)
			end

		elseif sub == "heroin" then
			local fade = sin(t * 0.5) * 0.5 + 0.5
			DrawColorModify({
				["$pp_colour_brightness"] = -0.4 - fade * 0.3,
				["$pp_colour_contrast"] = 0.5 + fade * 0.2,
				["$pp_colour_colour"] = 0.4 + fade * 0.2
			})
			DrawMotionBlur(0.6 + fade * 0.5, 0.6, 0.03)
			ply:ViewPunch(Angle(sin(t*math.Rand(1,3))*2, 0, sin(t*0.6)*2))

		elseif sub == "ketamine" then
			local wave = sin(t * 0.5)
			DrawColorModify({
				["$pp_colour_addr"] = 0,
				["$pp_colour_addg"] = 0,
				["$pp_colour_addb"] = 0.1,
				["$pp_colour_brightness"] = -0.1,
				["$pp_colour_contrast"] = 0.8,
				["$pp_colour_colour"] = 0.3,
				["$pp_colour_mulr"] = 0,
				["$pp_colour_mulg"] = 0,
				["$pp_colour_mulb"] = 0
			})
			DrawMotionBlur(0.1, 0.8, 0.05)
			DrawToyTown(2, ScrH() * 0.5)
			ply:ViewPunch(Angle(sin(t*1.5)*2, cos(t*1.2)*2, 0))

		elseif sub == "chlorine" or sub == "phosgene" or sub == "mustard_gas" then
			DrawColorModify({
				["$pp_colour_addr"] = 0,
				["$pp_colour_addg"] = 0.1 + sin(t * 2) * 0.05,
				["$pp_colour_addb"] = 0,
				["$pp_colour_brightness"] = -0.05,
				["$pp_colour_contrast"] = 1,
				["$pp_colour_colour"] = 1,
				["$pp_colour_mulr"] = 0,
				["$pp_colour_mulg"] = 0.5,
				["$pp_colour_mulb"] = 0
			})
			DrawMotionBlur(0.1, 0.5, 0.01)

		elseif sub == "sarin" then
			DrawColorModify({
				["$pp_colour_addr"] = 0,
				["$pp_colour_addg"] = 0,
				["$pp_colour_addb"] = 0,
				["$pp_colour_brightness"] = -0.1,
				["$pp_colour_contrast"] = 2.0 + sin(t * 10) * 0.5,
				["$pp_colour_colour"] = 0.5,
			})
			DrawSharpen(2, 0.5)
			ply:ViewPunch(Angle(rand(-0.5, 0.5), rand(-0.5, 0.5), 0))

		elseif sub == "cyanide" then
			DrawColorModify({
				["$pp_colour_addr"] = 0,
				["$pp_colour_addg"] = 0,
				["$pp_colour_addb"] = 0.2,
				["$pp_colour_brightness"] = -0.2,
				["$pp_colour_contrast"] = 1.2,
				["$pp_colour_colour"] = 0.8,
			})
			DrawToyTown(1, ScrH() * 0.8)

		elseif sub == "mercury" or sub == "lead" then
			DrawColorModify({
				["$pp_colour_addr"] = 0,
				["$pp_colour_addg"] = 0,
				["$pp_colour_addb"] = 0,
				["$pp_colour_brightness"] = 0,
				["$pp_colour_contrast"] = 1,
				["$pp_colour_colour"] = 0.2,
			})
			DrawSharpen(1, 0.5)

		elseif sub == "chloroform" or sub == "midazolam" or sub == "ghb" then
			local blink = sin(t * 1)
			DrawColorModify({
				["$pp_colour_addr"] = 0,
				["$pp_colour_addg"] = 0,
				["$pp_colour_addb"] = 0,
				["$pp_colour_brightness"] = -0.3 - (blink > 0.8 and 0.5 or 0),
				["$pp_colour_contrast"] = 0.8,
				["$pp_colour_colour"] = 0.5,
			})
			DrawMotionBlur(0.2, 0.9, 0.05)

		elseif sub == "ammonia" then
			DrawMotionBlur(0.1, 0.9, 0.05)
			DrawColorModify({
				["$pp_colour_addr"] = 0,
				["$pp_colour_addg"] = 0,
				["$pp_colour_addb"] = 0.1,
				["$pp_colour_brightness"] = 0.1,
				["$pp_colour_contrast"] = 0.8,
				["$pp_colour_colour"] = 0.5,
			})

		elseif sub == "arsenic" or sub == "strychnine" or sub == "ricin" then
			local sick = sin(t * 2) * 0.5 + 0.5
			DrawColorModify({
				["$pp_colour_addr"] = 0,
				["$pp_colour_addg"] = 0.05 * sick,
				["$pp_colour_addb"] = 0,
				["$pp_colour_brightness"] = -0.05,
				["$pp_colour_contrast"] = 1,
				["$pp_colour_colour"] = 0.6,
			})
			ply:ViewPunch(Angle(sin(t)*0.2, cos(t)*0.2, 0))

		elseif sub == "nitroglycerin" then
			local beat = sin(t * 15)
			if beat > 0.8 then
				DrawColorModify({
					["$pp_colour_addr"] = 0.2,
					["$pp_colour_addg"] = 0,
					["$pp_colour_addb"] = 0,
					["$pp_colour_brightness"] = -0.1,
					["$pp_colour_contrast"] = 1.2,
					["$pp_colour_colour"] = 1,
				})
			end

		elseif sub == "white_phosphorus" or sub == "thermite" then
			DrawColorModify({
				["$pp_colour_addr"] = 0.2,
				["$pp_colour_addg"] = 0.1,
				["$pp_colour_addb"] = 0,
				["$pp_colour_brightness"] = 0,
				["$pp_colour_contrast"] = 1.2,
				["$pp_colour_colour"] = 1,
			})
			DrawBloom(0.5, 1, 5, 5, 2, 1, 1, 1, 1)
		end
	end

	local blind = ply:GetNW2Int("Blindness", 0)
    if blind > 0 then
        local alpha = (blind == 1) and 200 or 255
        surface.SetDrawColor(0, 0, 0, alpha)
        surface.DrawRect(0, 0, ScrW(), ScrH())
    end

    local toxin = ply:GetNW2Float("ToxinLevel", 0)
    if toxin > 2 then
        local tab = {
            ["$pp_colour_addr"] = 0,
			["$pp_colour_addg"] = 0.1 * (toxin/10),
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = -0.05 * (toxin/5),
			["$pp_colour_contrast"] = 1 - (0.1 * (toxin/10)),
			["$pp_colour_colour"] = 1 - (0.5 * (toxin/10)),
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
        }
        DrawColorModify(tab)
        DrawMotionBlur(0.1, 0.5 * (toxin/10), 0.01)
    end
end)

hook.Add("Think", "MuR.SubstanceEffects.RandomMovements", function()
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:Alive() then return end
	if MuR.SubstanceEffects.Active.meth then
		ply:SetEyeAngles(ply:EyeAngles() + Angle(rand(-1.5,1.5), rand(-1.5,1.5), 0) * MuR.SubstanceEffects.Active.meth.intensity)
	end
	if MuR.SubstanceEffects.Active.lsd then
		ply:SetEyeAngles(ply:EyeAngles() + Angle(rand(-6,6), rand(-6,6), rand(-3,3)) * MuR.SubstanceEffects.Active.lsd.intensity)
	end
	if MuR.SubstanceEffects.Active.ketamine then
		ply:SetEyeAngles(ply:EyeAngles() + Angle(rand(-2,2), rand(-2,2), rand(-1,1)) * MuR.SubstanceEffects.Active.ketamine.intensity)
	end
end)