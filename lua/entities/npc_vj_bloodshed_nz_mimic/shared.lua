ENT.Base 			= "npc_vj_creature_base"
ENT.Type 			= "ai"
ENT.PrintName 		= "Shock Mimic"
ENT.Author 			= "Hari"
ENT.Category		= "VJ Base - Bloodshed"

function ENT:Draw()
    self:DrawModel()

    local dlight = DynamicLight( LocalPlayer():EntIndex() )
	if dlight then
        local att = self:GetAttachment(9)
		dlight.pos = att.Pos
		dlight.r = math.random(10, 25)
		dlight.g = math.random(10, 25)
		dlight.b = math.random(200, 255)
		dlight.brightness = 2
		dlight.decay = 1000
		dlight.size = 256
		dlight.dietime = CurTime() + 1
	end
end