local EFFECT = {}

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local mag = data:GetMagnitude() or 1
    local ent = data:GetEntity()

    -- Main particle impact
    ParticleEffect("blood_impact_red_01", pos, Angle(0,0,0))

    -- Create dripping stream with emitter
    local emitter = ParticleEmitter(pos)
    if emitter then
        for i = 1, math.Clamp(2 + math.floor(mag), 2, 10) do
            local p = emitter:Add("particle/smokesprites_0001", pos + VectorRand() * 2)
            if p then
                p:SetVelocity(VectorRand():GetNormalized() * (50 + mag * 30) + Vector(0,0,-100))
                p:SetDieTime(0.8 + math.Rand(0, 0.6))
                p:SetStartAlpha(200)
                p:SetEndAlpha(0)
                p:SetStartSize(3 + mag)
                p:SetEndSize(0)
                p:SetGravity(Vector(0,0,-300))
                p:SetAirResistance(50)
                p:SetCollide(true)
                p:SetBounce(0.2)
                p:SetColor(160, 10, 10)
                p:SetCollideCallback(function(_, spos, snorm, entcol)
                    util.Decal("Blood", spos - snorm, spos + snorm)
                end)
            end
        end
        emitter:Finish()
    end

    -- small blood stain decal
    util.Decal("Blood", pos + Vector(0,0,8), pos - Vector(0,0,8))
end

function EFFECT:Think() return false end
function EFFECT:Render() end

effects.Register(EFFECT, "mur_organ_bleed")
