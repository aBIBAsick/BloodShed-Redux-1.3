MuR.RegisterMode(3, {
	name = "Maniac",
	chance = 40,
	need_players = 2,
	disable_loot = true,
	dispatch = "maniac",
	police_call_mult = 0.5,
	call_police_on_think = true,
	killer_spawn_far = true,
	kteam = "Maniac",
	dteam = "Innocent",
	iteam = "Innocent",
	roles = {
		{class = "Medic", odds = 3, min_players = 5},
		{class = "Builder", odds = 3, min_players = 5},
		{class = "HeadHunter", odds = 4, min_players = 6},
		{class = "Criminal", odds = 5, min_players = 6},
		{class = "Security", odds = 3, min_players = 6},
		{class = "Witness", odds = 3, min_players = 6},
		{class = "Officer", odds = 8, min_players = 7},
		{class = "FBI", odds = 8, min_players = 7}
	}
})
