
hook.Add("SetupMove", "MuR_Move", function(ply, mv, cmd)
	local hunger = ply:GetNW2Float("Hunger")
	local stam = ply:GetNW2Float("Stamina")

	if ply:GetNW2Bool("Mode18Staminup") then
		ply:SetNW2Float("Stamina", 100)
		stam = 100
		if ply:IsSprinting() and ply:GetVelocity():Length() > 60 then
			ply.RunMult = math.min(ply.RunMult + FrameTime() * 250, ply:GetRunSpeed() * 1.2)
			mv:SetMaxSpeed(ply:GetWalkSpeed() + ply.RunMult)
			mv:SetMaxClientSpeed(ply:GetWalkSpeed() + ply.RunMult)
		elseif ply:GetVelocity():Length() < 60 then
			ply.RunMult = 0
		else
			ply.RunMult = 0
		end
		return
	end

	if not ply:GetNW2Bool("GeroinUsed") then
		if ply:IsSprinting() and ply:GetVelocity():Length() > 60 then
			ply:SetNW2Float("Stamina", math.Clamp(stam - FrameTime() / 0.2, 0, 100))

			ply.RunMult = math.min(ply.RunMult + FrameTime() * 180, ply:GetRunSpeed())
			mv:SetMaxSpeed(ply:GetWalkSpeed() + ply.RunMult)
			mv:SetMaxClientSpeed(ply:GetWalkSpeed() + ply.RunMult)
		elseif ply:GetVelocity():Length() < 60 then
			ply:SetNW2Float("Stamina", math.Clamp(stam + FrameTime() / 0.18, 0, 100))
			ply.RunMult = 0
		else
			ply:SetNW2Float("Stamina", math.Clamp(stam + FrameTime() / 0.18, 0, 100))
			ply.RunMult = 0
		end

		if stam <= 0 then
			ply.RunMult = 0
		end

		if stam < 10 then
			mv:SetMaxSpeed(ply:GetWalkSpeed() + ply.RunMult / 4)
			mv:SetMaxClientSpeed(ply:GetWalkSpeed() + ply.RunMult / 4)
		elseif stam < 40 then
			mv:SetMaxSpeed(ply:GetWalkSpeed() + ply.RunMult / 2)
			mv:SetMaxClientSpeed(ply:GetWalkSpeed() + ply.RunMult / 2)
		end

        if SERVER then
            local jp = ply.SpawnDataSpeed[3]
            if stam < 10 then
                ply:SetJumpPower(jp*0.6)
            elseif stam < 40 then
                ply:SetJumpPower(jp*0.8)
            else
                ply:SetJumpPower(jp)
            end   
            if ply:GetNW2Bool("LegBroken") then
                ply:SetJumpPower(jp*0.5)
            end
        end

		if stam <= 0 and (ply:WaterLevel() == 3 or IsValid(ply:GetRD()) and ply:GetRD():WaterLevel() == 3) then
			if ply.TakeDamageTime and ply.TakeDamageTime < CurTime() then
				ply.TakeDamageTime = CurTime() + 1
				ply:TakeDamage(5)
				ply:EmitSound("player/pl_drown" .. math.random(1, 3) .. ".wav", 40)
			end
		elseif stam > 0 and (ply:WaterLevel() == 3 or IsValid(ply:GetRD()) and ply:GetRD():WaterLevel() == 3) then
			ply:SetNW2Float("Stamina", math.Clamp(stam - FrameTime() / 0.1, 0, 100))
		end

		local hasAdrenaline = ply:GetNW2Float("AdrenalineEnd", 0) > CurTime()
		if (hunger < 20 or ply:GetNW2Bool("LegBroken")) and not hasAdrenaline then
			mv:SetMaxSpeed(ply:GetWalkSpeed() / 2)
			mv:SetMaxClientSpeed(ply:GetWalkSpeed() / 2)
		elseif ply:GetNW2Float("BleedLevel") >= 3 then
			mv:SetMaxSpeed(ply:GetWalkSpeed() / 1.5)
			mv:SetMaxClientSpeed(ply:GetWalkSpeed() / 1.5)
		elseif hunger < 50 or ply:GetNW2Float("BleedLevel") == 2 or ply:GetNW2Float("Guilt") >= 40 then
			mv:SetMaxSpeed(ply:GetWalkSpeed())
			mv:SetMaxClientSpeed(ply:GetWalkSpeed())
		end

		if ply:GetNW2Float("peppereffect") > CurTime() then
			mv:SetMaxClientSpeed(40)
		end
	end
end)