AddCSLuaFile()

SWEP.Base = "mur_med_base"
SWEP.PrintName = "Surgical Kit"
SWEP.Slot = 5

SWEP.WorldModel = "models/murdered/medicine/w_meds_surgicalkit.mdl"
SWEP.ViewModel = "models/murdered/medicine/v_meds_surgicalkit.mdl"
SWEP.BandageSound = "murdered/medicals/medkit.wav"

SWEP.WorldModelPosition = Vector(3, -8, 0)
SWEP.WorldModelAngle =  Angle(-90, 0, -90)

SWEP.ViewModelPos = Vector(0, -1, -3)
SWEP.ViewModelAng = Angle(-5, -8, 10)
SWEP.ViewModelFOV = 65

SWEP.HoldType = "slam"

SWEP.TPIKForce = true
SWEP.TPIKPos = Vector(18, -4, 3)

SWEP.HealTimeSelf = 15
SWEP.HealTimeTarget = 15

SWEP.SoundTable = {
    [1] = "murdered/medicals/medkit.wav"
}

SWEP.AnimTable = {
    idle = "idle",
    use_self = "use",
    use_mate = "use",
    holster = "idle",
    draw = "idle"
}

function SWEP:CanHeal(target)
    local internalBleed = target:GetNW2Float("InternalBleedEnd", 0) > CurTime()
    local pneumo = target:GetNW2Bool("Pneumothorax")
    local toxin = target:GetNW2Float("ToxinLevel", 0) > 0
    local hardBleed = target:GetNW2Bool("HardBleed")
    local spine = target:GetNW2Bool("SpineBroken")
    
    if not internalBleed and not pneumo and not toxin and not hardBleed and not spine then 
        return false 
    end
    return true
end

function SWEP:FinishHeal(target, isSelf)
    if not IsValid(target) or not target:Alive() then return end
    
    target:SetNW2Float("InternalBleedEnd", 0)
    target:SetNW2Bool("Pneumothorax", false)
    target:SetNW2Float("ToxinLevel", 0)
    target:SetNW2Bool("RibFracture", false)
    target:SetNW2Bool("SpineBroken", false)
    target:SetNW2Bool("HardBleed", false)
    
    -- Clear blood visual effects
    if target.ClearBloodEffects then
        target:ClearBloodEffects()
    end
    
    local msg = isSelf and "surgical_success" or "surgical_success_target"
    MuR:GiveMessage(msg, self:GetOwner())
    if not isSelf then MuR:GiveMessage("surgical_success", target) end
    
    self:Remove()
end

SWEP.Category = "Bloodshed - Civilian"
SWEP.Spawnable = true
