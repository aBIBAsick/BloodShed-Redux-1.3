if !SERVER then return end

local ENT = FindMetaTable("Entity")

local DRAG_TRAIL_ENABLED = true
local DRAG_VELOCITY_THRESHOLD = 50
local DRAG_DECAL_INTERVAL = 0.15
local DRAG_MAX_DECALS = 30
local DRAG_GROUND_CHECK_DIST = 20

local blood_decals = {
    "Blood",
    "Blood",
    "Blood",
}

local smear_decals = {
    "Blood",
}

function ENT:ZippyGoreMod3_StartDragTrail()
    if not DRAG_TRAIL_ENABLED then return end
    if self.ZGM3_DragTrailActive then return end
    if not self.ZippyGoreMod3_Ragdoll then return end
    if self.ZippyGoreMod3_BloodColor and self.ZippyGoreMod3_BloodColor ~= BLOOD_COLOR_RED then return end

    self.ZGM3_DragTrailActive = true
    self.ZGM3_DragDecalCount = 0
    self.ZGM3_LastDragPos = nil
    self.ZGM3_LastDragTime = 0

    local timerName = "ZGM3_DragTrail_" .. self:EntIndex()
    timer.Create(timerName, 0.05, 0, function()
        if not IsValid(self) then
            timer.Remove(timerName)
            return
        end

        if not self.ZGM3_DragTrailActive then
            timer.Remove(timerName)
            return
        end

        if self.ZGM3_DragDecalCount >= DRAG_MAX_DECALS then
            self.ZGM3_DragTrailActive = false
            timer.Remove(timerName)
            return
        end

        local pelvisPhys = self:GetPhysicsObjectNum(0)
        if not IsValid(pelvisPhys) then return end

        local vel = pelvisPhys:GetVelocity()
        local speed = vel:Length2D()

        if speed < DRAG_VELOCITY_THRESHOLD then return end

        local pos = pelvisPhys:GetPos()

        if self.ZGM3_LastDragPos and (pos - self.ZGM3_LastDragPos):Length() < 15 then
            return
        end

        if CurTime() - self.ZGM3_LastDragTime < DRAG_DECAL_INTERVAL then
            return
        end

        local tr = util.TraceLine({
            start = pos,
            endpos = pos - Vector(0, 0, DRAG_GROUND_CHECK_DIST),
            filter = self,
            mask = MASK_SOLID_BRUSHONLY
        })

        if not tr.Hit then return end

        local decal = speed > 150 and table.Random(smear_decals) or table.Random(blood_decals)
        util.Decal(decal, tr.HitPos + tr.HitNormal * 1, tr.HitPos - tr.HitNormal * 5, self)

        self.ZGM3_DragDecalCount = self.ZGM3_DragDecalCount + 1
        self.ZGM3_LastDragPos = pos
        self.ZGM3_LastDragTime = CurTime()
    end)

    self:CallOnRemove("ZGM3_StopDragTrail", function()
        timer.Remove(timerName)
    end)
end

function ENT:ZippyGoreMod3_StopDragTrail()
    self.ZGM3_DragTrailActive = false
    timer.Remove("ZGM3_DragTrail_" .. self:EntIndex())
end

hook.Add("PhysgunPickup", "ZGM3_DragTrail_PhysgunPickup", function(ply, ent)
    if ent.ZippyGoreMod3_Ragdoll and ent.ZippyGoreMod3_StartDragTrail then
        ent:ZippyGoreMod3_StartDragTrail()
    end
end)

hook.Add("PhysgunDrop", "ZGM3_DragTrail_PhysgunDrop", function(ply, ent)
    if ent.ZGM3_DragTrailActive then
        timer.Simple(2, function()
            if IsValid(ent) and ent.ZippyGoreMod3_StopDragTrail then
                ent:ZippyGoreMod3_StopDragTrail()
            end
        end)
    end
end)
