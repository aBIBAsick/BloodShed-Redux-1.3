MuR.RegisterMode(21, {
	name = "Hotline Miami",
	chance = 10,
	need_players = 2,
	custom_spawning = true,
	kteam = "Tony",
	dteam = "Mafia",
	iteam = "Mafia",
	disables_police = true,
    no_guilt = true,
    disables = true,
    disable_loot = true,
    timer = 360,

	spawn_type = "tdm",
	win_condition = "tdm",
	kteam_count = 1,
	tdm_end_logic = true,
	win_screen_team1 = "tony",
	win_screen_team2 = "mafia",

	OnModeStarted = function(mode)
		if SERVER then
			MuR.Mode21 = {}
		end
	end,

	OnModeThink = function(mode)
		if SERVER then
			for _, ply in player.Iterator() do
				if ply:GetNW2String("Class") == "Tony" then
					ply:SetNW2Float("Stamina", 100)
					ply.BleedTime = 0
				end
			end
		end
	end,

	OnModeEnded = function(mode)
		if SERVER then
			MuR.Mode21 = nil
		end
	end
})

if CLIENT then
	hook.Add("HUDPaint", "MuR_Mode21_HUD", function()
		if MuR.GamemodeCount == 21 and LocalPlayer():GetNW2String("Class") == "Tony" then
			for _, ply in player.Iterator() do
				if ply != LocalPlayer() and ply:Alive() and ply:GetPos():DistToSqr(LocalPlayer():GetPos()) <= 1000000 then
					local pos = ply:GetPos() + Vector(0,0,40)
					local scr = pos:ToScreen()
					if scr.visible then
						local hp = math.Clamp(ply:Health(), 0, 100)
						local col = Color(255 * (1 - hp/100), 255 * (hp/100), 0)

						surface.SetDrawColor(col)
						local s = 16
						surface.DrawOutlinedRect(scr.x - s/2, scr.y - s/2, s, s)
					end
				end
			end
		end
	end)
end
