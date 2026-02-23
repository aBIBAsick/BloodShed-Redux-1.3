AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Trap"
ENT.Author = "Author"
ENT.Category = "Traps"
ENT.Spawnable = false
ENT.AdminSpawnable = false

if CLIENT then
    function ENT:Draw()
        self:SetRenderMode(RENDERMODE_TRANSALPHA)
        if self:GetIsOpen() then
            self:SetColor(Color(255, 255, 255, 75))
            self:DrawModel()
        else
            self:SetColor(Color(255, 255, 255, 255))
            self:DrawModel()
        end
    end
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "IsOpen")
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/murdered/traps/trap.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:SetIsOpen(true)
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
        
        self.NextTrigger = 0
    end
end

function ENT:CheckVis(pos, ent)
    local p1, p2 = self:WorldSpaceCenter()+self:GetUp()*4, pos + Vector(0,0,2)
    local tr = util.TraceLine({
        startpos = p1,
        endpos = p2,
        filter = {self, ent},
        mask = MASK_SOLID,
        ignoreworld = true,
    })
    return !tr.Hit
end

function ENT:Think()
    if SERVER and self:GetIsOpen() then
        for _, ply in pairs(ents.FindInSphere(self:WorldSpaceCenter(), 24)) do
            if ply:IsPlayer() and (ply:Team() ~= 1 or ply:IsRolePolice()) and ply:Alive() then
                local bid, pos = self:GetClosestLegBone(ply)
                if self:CheckVis(pos, ply) then
                    self:TriggerTrap(ply)
                end
                break
            end
        end
    end
    self:NextThink(CurTime()+0.05)
    return true
end

function ENT:GetClosestLegBone(ply)
    if not IsValid(ply) then return (math.random(0,1) == 1 and "ValveBiped.Bip01_R_Foot" or "ValveBiped.Bip01_L_Foot") end
    if ply:IsPlayer() and IsValid(ply:GetRD()) then
        ply = ply:GetRD()
    end
    
    local trapPos = self:GetPos()
    local legBones = {
        "ValveBiped.Bip01_L_Foot",
        "ValveBiped.Bip01_L_Calf",
        "ValveBiped.Bip01_L_Thigh",
        "ValveBiped.Bip01_R_Foot",
        "ValveBiped.Bip01_R_Calf",
        "ValveBiped.Bip01_R_Thigh",
        "ValveBiped.Bip01_L_Upperarm",
        "ValveBiped.Bip01_L_Forearm",
        "ValveBiped.Bip01_L_Hand",
        "ValveBiped.Bip01_R_Upperarm",
        "ValveBiped.Bip01_R_Forearm",
        "ValveBiped.Bip01_R_Hand",
        "ValveBiped.Bip01_Head1"
    }
    
    local closestBone = nil
    local closestDist = math.huge
    
    for _, boneName in ipairs(legBones) do
        local boneID = ply:LookupBone(boneName)
        if boneID then
            local bonePos = ply:GetBonePosition(boneID)
            if bonePos then
                local dist = trapPos:DistToSqr(bonePos)
                if dist < closestDist then
                    closestDist = dist
                    closestBone = boneName
                end
            end
        end
    end
    
    local bone = closestBone or (math.random(0,1) == 1 and "ValveBiped.Bip01_R_Foot" or "ValveBiped.Bip01_L_Foot")
    return bone, ply:GetBonePosition(ply:LookupBone(bone))
end

function ENT:TriggerTrap(ply)
    if not IsValid(ply) then return end
    
    local rg = ply:GetRD()
    if IsValid(rg) then
        local bone = self:GetClosestLegBone(rg)
        ply.DeathBlowBone = {bone, true}
        ply:BreakRagdollBone()
    else
        local rag = ply:StartRagdolling()
        if IsValid(rag) then
            local bone = self:GetClosestLegBone(rag)
            ply.DeathBlowBone = {bone, true}
        else
            ply:TakeDamage(50, self:GetOwner(), self)
        end
    end
    
    self:SetModel("models/murdered/traps/trap_close.mdl")
    self:SetIsOpen(false)
    
    self:EmitSound("physics/metal/metal_box_impact_hard" .. math.random(1, 3) .. ".wav", 60)
end

function ENT:Use(activator, caller)
    if not IsValid(caller) or not caller:IsPlayer() then return end
    
    self:EmitSound("physics/metal/metal_box_impact_soft" .. math.random(1, 3) .. ".wav", 60)
    if self:GetIsOpen() then
        self:SetModel("models/murdered/traps/trap_close.mdl")
        self:SetIsOpen(false)
    else
        if caller:Team() == 1 then
            caller:GiveWeapon("mur_beartrap")
        end
        self:Remove()
    end
end