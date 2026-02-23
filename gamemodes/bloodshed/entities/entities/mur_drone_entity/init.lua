AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("MuR_DroneCam")
util.AddNetworkString("MuR_DroneLost")

function ENT:Initialize()
    self:SetModel("models/murdered/weapons/drone_ex.mdl")
    self:ResetSequence("idle")
    self:SetHealth(self.HealthCount)
    self:SetGravity(0)
    self.Velo = {x = 0, y = 0, z = 0}
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self.MultSpeed = 200
    self.MaxSpeed = 250
    self.BoostSpeed = 1000
    -- realism tuning
    self.MaxPitch = 18       -- deg
    self.MaxRoll = 22        -- deg
    self.LinearDrag = 0.04   -- per second drag
    self.GrenadeDelay = CurTime()+5
    self.TakeDamageWall = 0
    self.DeltaTime = 0
    self:SetNW2Float('RemoveTime', CurTime()+self.BatteryCount)
    -- rotor loop (server-side 3D sound) with pitch/volume controlled in Think
    if CreateSound then
        self.RotorSound = CreateSound(self, "ambient/machines/spin_loop.wav")
        if self.RotorSound then
            self.RotorSound:PlayEx(0.25, 85)
        end
    else
        self:EmitSound("ambient/machines/spin_loop.wav", 55, 130, 0.2, CHAN_BODY)
    end
    timer.Simple(0.1, function()
        local ply = self:GetCreator()
        if !IsValid(ply) then return end
        ply.ControlDrone = self
        net.Start("MuR_DroneCam")
        net.WriteEntity(self)
        net.Send(ply)
    end)
end

function ENT:OnRemove()
    if self.RotorSound then
        self.RotorSound:Stop()
    end
    self:StopSound("ambient/machines/spin_loop.wav")
end

function ENT:Think()
    local ply = self:GetCreator()
    if !IsValid(ply) then
        self:Remove() 
    else
        local phys = self:GetPhysicsObject()
        local mu = self.MultSpeed
        local ms = self.MaxSpeed
        local deltatime = self.DeltaTime
        local vel = phys:GetVelocity()
        local pos = self:GetPos()
        local ang = ply:EyeAngles().y
        local sang = Angle(0,ang,0)
        ply:SetActiveWeapon(nil)
        local trace = { start = self:GetPos(), endpos = self:GetPos(), filter = self }
        local tr = util.TraceEntity( trace, self )
        if self:GetNW2Bool('Boost') then 
            -- accelerate along drone forward, not player pitch; add slight upforce to avoid nose-dive
            local fwd = self:GetForward()
            phys:SetVelocityInstantaneous(fwd * self.Velo.x + Vector(0,0,10))
            -- in boost we still apply gentle banking based on current lateral speed
        else
            if tr.Hit then
                phys:SetVelocityInstantaneous((self:GetForward()*self.Velo.x+self:GetRight()*self.Velo.y+self:GetUp()*self.Velo.z)/2+Vector(0,0,10))
                if self.TakeDamageWall < CurTime() then
                    self:TakeDamage(1)
                    self.TakeDamageWall = CurTime()+0.2
                end
            else
                phys:SetVelocityInstantaneous(self:GetForward()*self.Velo.x+self:GetRight()*self.Velo.y+self:GetUp()*self.Velo.z+Vector(0,0,10))
            end
        end

        -- compute tilt from velocity for realism (bank to strafe, pitch to move forward/back)
        local ratioX = math.Clamp(self.Velo.x / ms, -1, 1)
        local ratioY = math.Clamp(self.Velo.y / ms, -1, 1)
    local targetPitch = ratioX * self.MaxPitch
        local targetRoll  =  ratioY * self.MaxRoll
        sang = Angle(targetPitch, ang, targetRoll)

        local b = {}
        b.secondstoarrive = 1
        b.pos = self:GetPos()
        b.angle = sang
        b.maxangular = 120
        b.maxangulardamp = 50
        b.maxspeed = 1000
        b.maxspeeddamp = 150
        b.dampfactor = 0.4
        b.teleportdistance = 0
        b.deltatime = CurTime()-self.DeltaTime
        phys:ComputeShadowControl(b)

        local tick = FrameTime()
        if ply:KeyDown(IN_FORWARD) or self:GetNW2Bool('Boost') then
            if self:GetNW2Bool('Boost') then
                self.Velo.x = math.Clamp(self.Velo.x+tick*mu*2, -ms, self.BoostSpeed)
            else
                self.Velo.x = math.Clamp(self.Velo.x+tick*mu, -ms, ms)
            end
        elseif ply:KeyDown(IN_BACK) then
            self.Velo.x = math.Clamp(self.Velo.x-tick*mu, -ms, ms)
        end
        if ply:KeyDown(IN_MOVELEFT) then
            self.Velo.y = math.Clamp(self.Velo.y-tick*mu, -ms, ms)
        elseif ply:KeyDown(IN_MOVERIGHT) then
            self.Velo.y = math.Clamp(self.Velo.y+tick*mu, -ms, ms)
        end
        if ply:KeyDown(IN_DUCK) then
            self.Velo.z = math.Clamp(self.Velo.z-tick*mu, -ms, ms)
        elseif ply:KeyDown(IN_SPEED) then
            self.Velo.z = math.Clamp(self.Velo.z+tick*mu, -ms, ms)
        end
        -- apply continuous aerodynamic drag
        local drag = 1 - math.Clamp(self.LinearDrag * tick, 0, 0.2)
        self.Velo.x = self.Velo.x * drag
        self.Velo.y = self.Velo.y * drag
        self.Velo.z = self.Velo.z * (0.98 * drag) -- slightly stronger vertical damping to help hover
        if not ply:KeyDown(IN_FORWARD) and not ply:KeyDown(IN_BACK) and not self:GetNW2Bool('Boost') then
            if self.Velo.x > 5 or self.Velo.x < -5 then
                if self.Velo.x > 0 then
                    self.Velo.x = math.Clamp(self.Velo.x-tick*mu, -ms, ms)
                elseif self.Velo.x < 0 then
                    self.Velo.x = math.Clamp(self.Velo.x+tick*mu, -ms, ms)
                end
            else
                self.Velo.x = 0
            end
        end
        if not ply:KeyDown(IN_SPEED) and not ply:KeyDown(IN_DUCK) then
            if self.Velo.z > 5 or self.Velo.z < -5 then
                if self.Velo.z > 0 then
                    self.Velo.z = math.Clamp(self.Velo.z-tick*mu, -ms, ms)
                elseif self.Velo.z < 0 then
                    self.Velo.z = math.Clamp(self.Velo.z+tick*mu, -ms, ms)
                end
            else
                self.Velo.z = 0
            end
        end
        if not ply:KeyDown(IN_MOVELEFT) and not ply:KeyDown(IN_MOVERIGHT) then
            if self.Velo.y > 5 or self.Velo.y < -5 then
                if self.Velo.y > 0 then
                    self.Velo.y = math.Clamp(self.Velo.y-tick*mu, -ms, ms)
                elseif self.Velo.y < 0 then
                    self.Velo.y = math.Clamp(self.Velo.y+tick*mu, -ms, ms)
                end
            else
                self.Velo.y = 0
            end
        end
        self:SetNW2Bool('Boost', ply:KeyDown(IN_ATTACK))
        self:SetNW2Bool('Light', ply:KeyDown(IN_ATTACK2))
        -- rotor sound feedback (pitch ~ throttle/speed, volume ~ load)
        if self.RotorSound then
            local spd = phys:GetVelocity():Length()
            local load = math.Clamp((math.abs(self.Velo.x) + math.abs(self.Velo.y) + math.abs(self.Velo.z)) / (self.BoostSpeed*0.6), 0, 1)
            local timeLeft = math.max(self:GetNW2Float('RemoveTime') - CurTime(), 0)
            local battFrac = math.Clamp(timeLeft / self.BatteryCount, 0, 1)
            local basePitch = 85 + 35*load + math.Clamp(spd*0.02, 0, 30)
            local baseVol = 0.18 + 0.32*load
            -- slight sag on low battery
            basePitch = basePitch * (0.9 + 0.1*battFrac)
            self.RotorSound:ChangePitch(math.Clamp(basePitch, 60, 170), 0.1)
            self.RotorSound:ChangeVolume(math.Clamp(baseVol, 0.05, 0.6), 0.1)
        end
        if self:Health() <= 0 then
            net.Start("MuR_DroneLost")
            net.Send(ply)
            self:Explode()
        end
        if self:GetNW2Float('RemoveTime') < CurTime() or !ply:Alive() or ply:GetSVAnim() != "" then
            net.Start("MuR_DroneLost")
            net.Send(ply)
            self:Remove()
        elseif (ply:KeyDown(IN_RELOAD) and ply:GetPos():DistToSqr(self:GetPos()) < 50000) then
            ply:GiveWeapon("mur_drone")
            ply:SelectWeapon("mur_drone")
            self:Remove()
        end
        self.DeltaTime = CurTime()
        self:NextThink(CurTime())
        return true
    end
end

function ENT:PhysicsCollide(col)
    if self.Velo.x > self.MaxSpeed and self:GetNW2Bool('Boost') then
        self:TakeDamage(self:Health())
    end
end

function ENT:Explode()
    local explosion = ents.Create("env_explosion")
    explosion:SetPos(self:GetPos())
    explosion:Spawn()
    explosion:SetKeyValue("iMagnitude", "200")
    explosion:Fire("Explode", 0, 0)
    self:Remove()
end

function ENT:OnTakeDamage(dmgt)
    local dmg = dmgt:GetDamage()
    local att = dmgt:GetAttacker()
    self:SetHealth(self:Health()-dmg)
    if IsValid(self:GetCreator()) then
        self:GetCreator():ViewPunch(AngleRand(-1,1))
    self:EmitSound("physics/metal/metal_box_impact_bullet"..math.random(1,3)..".wav", 80, 100)
    end
end

hook.Add("SetupPlayerVisibility", "GpincDroneCam", function(ply, viewEntity)
    local drone = ply.ControlDrone
    if IsValid(drone) then
        AddOriginToPVS(drone:GetPos())
    end
end)