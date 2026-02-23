AddCSLuaFile()

ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true

if SERVER then
    function ENT:Initialize()
        self:DrawShadow(false)
        self:SetNotSolid(true)
    end

    function ENT:UpdateTransmitState()     
        return TRANSMIT_ALWAYS
    end
else
    function ENT:Draw() 
    end
end

function ENT:Think()
    self:NextThink(CurTime())
    return true
end