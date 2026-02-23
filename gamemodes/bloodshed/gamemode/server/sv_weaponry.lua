local function CallEffects(ply)
    local rnd = math.random(1,18)
    net.Start("MuR.WeaponryEffect")
    net.WriteInt(rnd, 32)
    net.Send(ply)
end

hook.Add("PlayerPostThink", "MuR.TraitorThinking", function(ply)
    if ply:GetNW2Bool("Bredogen") and (not ply.PoisonVoiceTime or ply.PoisonVoiceTime < CurTime()) then
        ply.PoisonVoiceTime = CurTime() + math.Rand(15,45)
        CallEffects(ply)
    end
end)

concommand.Add("_takedamagebredogen", function(ply, cmd, args)
    local dmg = tonumber(args[1])
    if isnumber(dmg) and ply:GetNW2Bool("Bredogen") and ply:Alive() then
        timer.Simple(0.05, function()
            if !IsValid(ply) then return end
            ply:TakeDamage(dmg)
        end)
    end
end)