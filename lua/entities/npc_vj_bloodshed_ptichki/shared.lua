ENT.Base 			= "npc_vj_creature_base"
ENT.Type 			= "ai"
ENT.PrintName 		= "PTICHKI"
ENT.Author 			= "Hari"
ENT.Category		= "VJ Base - Bloodshed"
ENT.AdminOnly       =  true

if SERVER then return end

function ENT:Think()
    local dlight = DynamicLight(self:EntIndex())
	if dlight then
		dlight.pos = self:EyePos()
		dlight.r = 200
		dlight.g = 20
		dlight.b = 20
		dlight.brightness = 4
		dlight.decay = 512
		dlight.size = 256
		dlight.dietime = CurTime() + 1
	end
end