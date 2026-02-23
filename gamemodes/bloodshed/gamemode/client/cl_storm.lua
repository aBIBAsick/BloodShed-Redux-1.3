local StormActive = false
local WindDirection = Vector(0, 0, 0)
local RainActiveAt = 0
local ThunderFlashUntil = 0
local LastStrikeAt = 0
local LastStrikePos = vector_origin
local LastStrikeRadius = 0
local NextAmbientUpdate = 0
local RainLoop
local WindLoop

net.Receive("MuR.Storm.Start", function()
	StormActive = true
	RainActiveAt = CurTime() + 30
end)

net.Receive("MuR.Storm.End", function()
	StormActive = false
	ThunderFlashUntil = 0
	if RainLoop then RainLoop:Stop() RainLoop = nil end
	if WindLoop then WindLoop:Stop() WindLoop = nil end
end)

net.Receive("MuR.Storm.WindDirection", function()
	WindDirection = net.ReadVector()
end)

net.Receive("MuR.Storm.Thunder", function()
	if not StormActive then return end
	local p = LocalPlayer()
	if not IsValid(p) then return end
	util.ScreenShake(p:GetPos(), math.random(4, 10), 0.3, math.random(1, 2), 8000)
	ThunderFlashUntil = CurTime() + 0.25 + math.Rand(0.0, 0.25)
	local hasPayload = net.ReadBool()
	if hasPayload then
		LastStrikePos = net.ReadVector()
		LastStrikeRadius = net.ReadUInt(12)
		LastStrikeAt = CurTime()
	end
end)

hook.Add("SetupWorldFog", "StormFog", function()
	if not StormActive then return end
	render.FogMode(MATERIAL_FOG_LINEAR)
	render.FogStart(0)
	render.FogEnd(260)
	render.FogMaxDensity(0.98)
	render.FogColor(5, 5, 10)
	return true
end)

hook.Add("SetupSkyboxFog", "StormSkyboxFog", function()
	if not StormActive then return end
	render.FogMode(MATERIAL_FOG_LINEAR)
	render.FogStart(0)
	render.FogEnd(260)
	render.FogMaxDensity(0.98)
	render.FogColor(5, 5, 10)
	return true
end)

hook.Add("PostDrawSkyBox", "StormDarkSky", function()
	if not StormActive then return end
	render.OverrideColorWriteEnable(true, true)
	render.SetColorMaterial()
	local a = 255
	if ThunderFlashUntil > CurTime() then a = 80 end
	render.DrawQuadEasy(Vector(0, 0, 0), Vector(0, 0, -1), 32000, 32000, Color(5, 5, 8, a), 0)
	render.OverrideColorWriteEnable(false)
end)

local rainMat = Material("effects/tool_tracer")
local dustMat = Material("sprites/glow04_noz")
local smokeMat = Material("particle/particle_smokegrenade")

hook.Add("PostDrawTranslucentRenderables", "StormEffects", function()
	if not StormActive then return end
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	if CurTime() < RainActiveAt then return end
	local pos = ply:GetPos()
	local eye = ply:EyePos()
	local sky = util.TraceLine({start = pos, endpos = pos + Vector(0, 0, 2000), filter = ply, mask = MASK_SOLID_BRUSHONLY})
	local outside = sky.HitSky or sky.Fraction > 0.6
	if not outside then return end
	local wind = WindDirection:GetNormalized()
	local t = CurTime()
	for i = 1, 60 do
		local off = Vector(math.sin(t * 2 + i) * 220, math.cos(t * 1.6 + i) * 220, math.random(80, 420))
		local s = eye + off
		local e = s + wind * 120 + Vector(0, 0, -260)
		render.SetMaterial(rainMat)
		render.DrawBeam(s, e, 1.5, 0, 1, Color(170, 170, 220, 120))
	end
	for i = 1, 24 do
		local p = eye + Vector(math.sin(t + i * 0.5) * 320, math.cos(t * 0.9 + i * 0.3) * 320, math.random(0, 220))
		local e = p + wind * 90 + Vector(math.sin(t * 3 + i) * 18, math.cos(t * 2.5 + i) * 18, -math.random(10, 44))
		render.SetMaterial(dustMat)
		render.DrawSprite(e, 5, 5, Color(90, 70, 50, 160))
	end

	local tornado = game.GetWorld():GetNW2Bool("MuR_TornadoActive", false)
	if tornado then
		local c = game.GetWorld():GetNW2Vector("MuR_TornadoCenter", Vector(0,0,0))
		local d2 = ply:GetPos():DistToSqr(c)
		if d2 < (1200*1200) then
			for i = 1, 14 do
				local ang = (t * 40 + i * (360/14)) % 360
				local r = 300 + math.sin(t + i) * 40
				local pos2 = c + Vector(math.cos(math.rad(ang)) * r, math.sin(math.rad(ang)) * r, 40 + math.random(0,80))
				local dir2 = (WindDirection:GetNormalized() * 0.3 + VectorRand() * 0.7):GetNormalized()
				local len = 60 + math.random(0,30)
				local a1 = pos2
				local a2 = pos2 + dir2 * len + Vector(0,0,math.random(20,60))
				render.SetMaterial(smokeMat)
				render.DrawBeam(a1, a2, 18, 0, 1, Color(120, 110, 100, 80))
			end
		end
	end

	if LastStrikeAt > 0 and CurTime() - LastStrikeAt < 0.35 then
		local d = DynamicLight(LocalPlayer():EntIndex() + 902)
		if d then
			d.pos = LastStrikePos
			d.r = 180
			d.g = 200
			d.b = 255
			d.brightness = 8
			d.Decay = 2000
			d.Size = LastStrikeRadius
			d.DieTime = CurTime() + 0.15
		end
		render.SetMaterial(dustMat)
		render.DrawSprite(LastStrikePos + Vector(0,0,16), 64, 64, Color(200, 220, 255, 180))
	end
end)

local function UpdateAmbient()
	if not StormActive then return end
	if CurTime() < RainActiveAt then return end
	if CurTime() < NextAmbientUpdate then return end
	NextAmbientUpdate = CurTime() + 0.4
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local p = ply:GetPos()
	local sky = util.TraceLine({start = p, endpos = p + Vector(0, 0, 2000), filter = ply, mask = MASK_SOLID_BRUSHONLY})
	local outside = sky.HitSky or sky.Fraction > 0.8
	local nearWin = 0
	for i = 1, 8 do
		local a = (i - 1) * (360 / 8)
		local dir = Vector(math.cos(math.rad(a)), math.sin(math.rad(a)), 0)
		local t = util.TraceLine({start = p + Vector(0, 0, 40), endpos = p + dir * 2000, filter = ply, mask = MASK_SOLID})
		if t.Hit and t.HitTexture then
			local n = string.lower(t.HitTexture)
			if string.find(n, "glass") or string.find(n, "window") then nearWin = nearWin + 1 end
		elseif t.HitSky then nearWin = nearWin + 1 end
	end
	local wind = WindDirection:Length()
	local windVol = math.Clamp(wind / 160, 0.2, 1)
	local rainVol = outside and 0.7 or math.min(0.15 * nearWin, 0.5)
	local moanVol = outside and 0 or (nearWin > 0 and 0.35 or 0.15)
	if not RainLoop then RainLoop = CreateSound(ply, "ambient/weather/rumble_rain.wav") end
	if not WindLoop then WindLoop = CreateSound(ply, "ambient/wind/wind_hit2.wav") end
	if RainLoop then RainLoop:PlayEx(rainVol, 90) end
	if WindLoop then WindLoop:PlayEx(windVol + moanVol, 95) end
end

hook.Add("Think", "StormAmbientThink", UpdateAmbient)
