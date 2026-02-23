AddCSLuaFile()

SWEP.Base = "mur_loot_base"
SWEP.PrintName = "Medical Base"
SWEP.Slot = 5
SWEP.Spawnable = false

SWEP.HealTimeSelf = 2
SWEP.HealTimeTarget = 2

SWEP.AnimTable = {
    idle = ACT_VM_IDLE,
    use_self = ACT_VM_PRIMARYATTACK,
    use_mate = ACT_VM_SECONDARYATTACK,
    holster = ACT_VM_HOLSTER,
    draw = ACT_VM_DRAW
}

SWEP.SoundTable = {} -- [time] = "sound_path"

SWEP.HealDist = 72

-- Phrases for HUD
SWEP.PhraseSelf = "loot_medic_left"
SWEP.PhraseTarget = "loot_medic_right"

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "HealState") -- 0: None, 1: Self, 2: Target
    self:NetworkVar("Float", 0, "HealStart")
end

function SWEP:CustomInit()
    self:SetHealState(0)
    self:SetHealStart(0)
    self.PlayedSounds = {}
end


function SWEP:PlayAnimation(anim)
    if not anim then return end
    if isnumber(anim) then
        self:SendWeaponAnim(anim)
    elseif isstring(anim) then
        local vm = self:GetOwner():GetViewModel()
        if IsValid(vm) then
            local seq = vm:LookupSequence(anim)
            if seq != -1 then
                self:SendWeaponAnim(vm:GetSequenceActivity(seq))
            end
        end
    end
end

function SWEP:Deploy()
    self:PlayAnimation(self.AnimTable.draw or ACT_VM_DRAW)
    self:SetHoldType(self.HoldType or "slam")
    self:StopHeal()
    return true
end

function SWEP:Holster()
    self:StopHeal()
    return true
end

function SWEP:PrimaryAttack()
    -- Logic handled in Think
    self:SetNextPrimaryFire(CurTime() + 0.1)
end

function SWEP:SecondaryAttack()
    -- Logic handled in Think
    self:SetNextSecondaryFire(CurTime() + 0.1)
end

function SWEP:StopHeal()
    if self:GetHealState() != 0 then
        self:SetHealState(0)
        self:SetHealStart(0)
        self:PlayAnimation(self.AnimTable.idle or ACT_VM_IDLE)
        self.PlayedSounds = {}
    end
end

function SWEP:StartHeal(state)
    local owner = self:GetOwner()
    
    -- Don't restart if already healing in the same state
    if self:GetHealState() == state then return end
    
    if state == 2 then
        -- Validate target
        local tr = util.TraceLine({
            start = owner:GetShootPos(),
            endpos = owner:GetShootPos() + owner:GetAimVector() * self.HealDist,
            filter = owner,
            mask = MASK_SHOT_HULL
        })
        local tar = tr.Entity
        if tar.isRDRag and IsValid(tar.Owner) then tar = tar.Owner end
        
        if not IsValid(tar) or not tar:IsPlayer() then return end
        if self.CanHeal and not self:CanHeal(tar) then return end
    else
        if self.CanHeal and not self:CanHeal(owner) then return end
    end

    self:SetHealState(state)
    self:SetHealStart(CurTime())
    self.PlayedSounds = {}

    local anim = (state == 1) and self.AnimTable.use_self or self.AnimTable.use_mate
    self:PlayAnimation(anim)
    
    -- Play initial sound if at 0
    self:CheckSounds(0)
end

function SWEP:CheckSounds(elapsed)
    if not self.SoundTable then return end
    if CLIENT then return end
    
    for time, snd in pairs(self.SoundTable) do
        local t = tonumber(time)
        if t and elapsed >= t and not self.PlayedSounds[time] then
            self:GetOwner():EmitSound("<"..snd, 60, math.random(90,110))
            self.PlayedSounds[time] = true
        end
    end
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local state = self:GetHealState()
    local startTime = self:GetHealStart()
    local curTime = CurTime()

    if state == 0 then
        if owner:KeyDown(IN_ATTACK) then
            self:StartHeal(1)
        elseif owner:KeyDown(IN_ATTACK2) then
            self:StartHeal(2)
        end
    else
        local isSelf = (state == 1)
        local key = isSelf and IN_ATTACK or IN_ATTACK2
        local duration = isSelf and self.HealTimeSelf or self.HealTimeTarget
        
        -- Validate Target continuously if healing target
        if not isSelf then
            local tr = util.TraceLine({
                start = owner:GetShootPos(),
                endpos = owner:GetShootPos() + owner:GetAimVector() * self.HealDist,
                filter = owner,
                mask = MASK_SHOT_HULL
            })
            local tar = tr.Entity
            if tar.isRDRag and IsValid(tar.Owner) then tar = tar.Owner end
            if not IsValid(tar) or not tar:IsPlayer() then
                self:StopHeal()
                return
            end
            self.CurrentTarget = tar
        else
            self.CurrentTarget = owner
        end

        if not owner:KeyDown(key) then
            self:StopHeal()
            return
        end

        local elapsed = curTime - startTime
        self:CheckSounds(elapsed)

        if elapsed >= duration then
            if SERVER then
                self:FinishHeal(self.CurrentTarget, isSelf)
            end
            self:StopHeal()
            -- Play completion animation or remove weapon if it's one-time use
            -- Assuming these items are consumables, they often remove themselves.
            -- Children should handle removal in FinishHeal or we do it here if generic.
            -- Existing items self:Remove(). Let's let FinishHeal handle logic.
        end
    end
end

function SWEP:FinishHeal(target, isSelf)
    -- Override in child
end

if CLIENT then
    function SWEP:DrawHUD()
        local owner = self:GetOwner()
        local state = self:GetHealState()

        -- Draw Instructions when idle
        if state == 0 then
            draw.SimpleText(MuR.Language[self.PhraseSelf] or self.PhraseSelf, "MuR_Font1", ScrW()/2, ScrH()-He(100), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(MuR.Language[self.PhraseTarget] or self.PhraseTarget, "MuR_Font1", ScrW()/2, ScrH()-He(85), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            -- Draw Progress Bar
            local startTime = self:GetHealStart()
            local duration = (state == 1) and self.HealTimeSelf or self.HealTimeTarget
            local elapsed = CurTime() - startTime
            local progress = math.Clamp(elapsed / duration, 0, 1)

            local w, h = We(300), He(20)
            local x, y = ScrW()/2 - w/2, ScrH() - He(200)

            draw.RoundedBox(4, x, y, w, h, Color(0, 0, 0, 150))
            draw.RoundedBox(4, x, y, w * progress, h, Color(175, 0, 0))
        end
    end
end
