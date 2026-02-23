if !SERVER then return end

local ENT = FindMetaTable("Entity")
local blood_particles = {
    [BLOOD_COLOR_RED] = ZGM3_INSANE_BLOOD_EFFECTS && "blood_stream_goop_large" or "blood_impact_red_01_goop",
    [BLOOD_COLOR_ANTLION] = "blood_impact_yellow_01",
    [BLOOD_COLOR_ANTLION_WORKER] = "blood_impact_yellow_01",
    [BLOOD_COLOR_GREEN] = "blood_impact_yellow_01",
    [BLOOD_COLOR_ZOMBIE] = "blood_impact_yellow_01",
    [BLOOD_COLOR_YELLOW] = "blood_impact_yellow_01",
    [BLOOD_COLOR_ZGM3SYNTH] = "blood_impact_synth_01",
}
local blood_decals = {
    [BLOOD_COLOR_RED] = "Blood",
    [BLOOD_COLOR_ANTLION] = "YellowBlood",
    [BLOOD_COLOR_ANTLION_WORKER] = "YellowBlood",
    [BLOOD_COLOR_GREEN] = "YellowBlood",
    [BLOOD_COLOR_ZOMBIE] = "YellowBlood",
    [BLOOD_COLOR_YELLOW] = "YellowBlood",
}
local bleed_timer_name = "ZippyGore3_LimbBleedEffectTimer"

local ZGM3_GUTS_MODEL = "models/gore/fatalityguts.mdl"
local ZGM3_GUTS_WELD_FORCE = 5000
local ZGM3_GUTS_WELD_BONE_PARENT = "ValveBiped.Bip01_Pelvis"
local ZGM3_GUTS_WELD_BONE_CHILD = "ValveBiped.Bip01_Spine4"
local ZGM3_GUTS_PARENT_PHYS = 1
local ZGM3_GUTS_CHILD_PHYS = 20
local ZGM3_BONE_SPINE2 = "ValveBiped.Bip01_Spine2"
local ZGM3_BONE_PELVIS = "ValveBiped.Bip01_Pelvis"
local ZGM3_GUTS_PARENT_ANG_OFFSET = Angle(0,0,0)
local ZGM3_GUTS_CHILD_ANG_OFFSET = Angle(0,-90,0)

local function ZGM3_AddLocalAngle(baseAng, offset)
    if not offset or (offset.p==0 and offset.y==0 and offset.r==0) then return baseAng end
    local a = Angle(baseAng.p, baseAng.y, baseAng.r)
    if offset.r ~= 0 then a:RotateAroundAxis(a:Forward(), offset.r) end
    if offset.p ~= 0 then a:RotateAroundAxis(a:Right(), offset.p) end
    if offset.y ~= 0 then a:RotateAroundAxis(a:Up(), offset.y) end
    return a
end

function ENT:ZippyGoreMod3_BleedEffect( phys_bone )
    if !ZGM3_CVARS["zippygore3_bleed_effect"] then return end

    local timer_name_real = bleed_timer_name..self:EntIndex().."_Bone: "..phys_bone
    local delayMult = self.ZippyGoreMod3_BloodColor==BLOOD_COLOR_ZGM3SYNTH && 3 or 1
    timer.Create(timer_name_real, math.Rand(0.1, 0.4)*delayMult, math.random(12, 16)/delayMult, function()
        local effect_pos = IsValid(self) && self:GetBonePosition( self:TranslatePhysBoneToBone(phys_bone) )
        if !IsValid(self) or !effect_pos then timer.Remove(timer_name_real) return end

        local particleName = blood_particles[self.ZippyGoreMod3_BloodColor]

        particleName = self:GetNW2String("DynamicBloodSplatter_CustomBlood_Particle", false) or particleName
        if !particleName then timer.Remove(timer_name_real) return end


        ParticleEffect(particleName, effect_pos, AngleRand())
        local effectdata = EffectData()
		effectdata:SetOrigin( effect_pos )
		effectdata:SetNormal( VectorRand(-1,1) )
		effectdata:SetMagnitude( 1 )
		effectdata:SetRadius(20)
		effectdata:SetEntity( self )
		util.Effect("mur_blood_splatter_effect", effectdata, true, true )


        local decal = self:GetNW2String("DynamicBloodSplatter_CustomBlood_Decal", false) or blood_decals[self.ZippyGoreMod3_BloodColor]
        if decal && timer.RepsLeft(timer_name_real) == 0 then
            local tr = util.TraceLine({
                start = effect_pos + Vector(0,0,10),
                endpos = effect_pos - Vector(0,0,50),
                filter = self,
            })
            util.Decal(decal, tr.HitPos, tr.HitPos-tr.HitNormal*10, self)
        end

    end)
end


function ENT:ZippyGoreMod3_ForcePhysBonePos()
    for phys_bone, parent_physbone in pairs(self.ZippyGoreMod3_GibbedPhysBoneParents) do
        local gibbed_physobj = self:GetPhysicsObjectNum(phys_bone)
        local parent_physobj = self:GetPhysicsObjectNum(parent_physbone)
        gibbed_physobj:SetPos( parent_physobj:GetPos() )
        gibbed_physobj:SetAngles( parent_physobj:GetAngles() )
        
    end
end


hook.Add("Think", "ZippyGore3_ForcePhysbonePositions_Think", function()
    for _,rag in ipairs( ZGM3_RAGDOLLS ) do
        if rag.ZippyGoreMod3_GibbedPhysBoneParents then rag:ZippyGoreMod3_ForcePhysBonePos() end
    end
end)


function ENT:ZippyGoreMod3_CreateLimbRagdoll( SeveredPhysBone, damageData )
    
    local limb_ragdoll = ents.Create("prop_ragdoll")
    limb_ragdoll:SetPos(self:GetPos())
    limb_ragdoll:SetAngles(self:GetAngles())
    limb_ragdoll:SetModel(self:GetModel())
    limb_ragdoll:TransferModelData(self)
    limb_ragdoll:DrawShadow(false)
    limb_ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    limb_ragdoll:Spawn()
    limb_ragdoll:CopyWoundsFrom(self)
    if isvector(self.PlyColor) then
        limb_ragdoll:SetNW2Vector("RagColor", self.PlyColor)
	    limb_ragdoll:MakePlayerColor(self.PlyColor)
    end
    limb_ragdoll:ZippyGoreMod3_BecomeGibbableRagdoll( self.ZippyGoreMod3_BloodColor )
    limb_ragdoll:ZippyGoreMod3_BleedEffect( SeveredPhysBone )
    limb_ragdoll.ZippyGoreMod3_GibbedPhysBones = {}
    
    limb_ragdoll.ZippyGoreMod3_Ragdoll = false
    if ZGM3_INSANE_BLOOD_EFFECTS && self.ZippyGoreMod3_BloodColor==BLOOD_COLOR_RED then limb_ragdoll:RealisticBlood_Setup() end

    local severedBone = limb_ragdoll:TranslatePhysBoneToBone(SeveredPhysBone)

    
    for i = 0, limb_ragdoll:GetPhysicsObjectCount()-1 do
        local phys_obj = limb_ragdoll:GetPhysicsObjectNum(i)
        phys_obj:SetPos( self:GetPhysicsObjectNum(i):GetPos() )
        phys_obj:SetAngles( self:GetPhysicsObjectNum(i):GetAngles() )
    end

    
    local child_bones = {}
    local function get_all_child_bones_recursive( bone )
        for _, v in ipairs(limb_ragdoll:GetChildBones(bone)) do
            if !self.ZippyGoreMod3_GibbedPhysBones[ self:TranslateBoneToPhysBone(v) ] then
                child_bones[v] = true
                get_all_child_bones_recursive(v)
            end
        end
    end
    get_all_child_bones_recursive( severedBone )

    
    local parent_bones = {}
    local function get_all_parent_bones_recursive( bone )
        local parent_bone = limb_ragdoll:GetBoneParent(bone)
        parent_bones[parent_bone] = true
        if parent_bone != 0 then
            get_all_parent_bones_recursive(parent_bone)
        end
    end
    get_all_parent_bones_recursive( severedBone )

    
    local function remove_bone( bone )
        limb_ragdoll:ManipulateBoneScale(bone, Vector(0, 0, 0))
        limb_ragdoll:ManipulateBonePosition(bone, Vector(0, 0, 0)/0) -- Thanks Rama (only works on certain graphics cards!)

        local phys_bone = limb_ragdoll:TranslateBoneToPhysBone( bone )

        if !limb_ragdoll.ZippyGoreMod3_GibbedPhysBones[ phys_bone ] then
            local phys_bone_bone_translated = limb_ragdoll:TranslatePhysBoneToBone(phys_bone)
            if !child_bones[phys_bone_bone_translated] && phys_bone_bone_translated != severedBone then
                
                local phys_obj = limb_ragdoll:GetPhysicsObjectNum( phys_bone )
                phys_obj:EnableCollisions(false)
                phys_obj:SetMass(0.1)
                
                if !limb_ragdoll.ZippyGoreMod3_GibbedPhysBoneParents then limb_ragdoll.ZippyGoreMod3_GibbedPhysBoneParents = {} end
                if !parent_bones[phys_bone_bone_translated] then
                    limb_ragdoll.ZippyGoreMod3_GibbedPhysBoneParents[ phys_bone ] = 0
                    limb_ragdoll:RemoveInternalConstraint(phys_bone)
                end
            end
            limb_ragdoll.ZippyGoreMod3_GibbedPhysBones[ phys_bone ] = true
        end
    end
    for i = 0, limb_ragdoll:GetBoneCount()-1 do
        if i != severedBone && !child_bones[i] then remove_bone( i ) end
    end

    
    for parent_bone in pairs(parent_bones) do
        local parent_physbone = limb_ragdoll:TranslateBoneToPhysBone(parent_bone)
        limb_ragdoll.ZippyGoreMod3_GibbedPhysBoneParents[ parent_physbone ] = SeveredPhysBone
    end
    
    limb_ragdoll:RemoveInternalConstraint(SeveredPhysBone)

    
    gibbed_physobj = limb_ragdoll:GetPhysicsObjectNum(SeveredPhysBone)
    gibbed_physobj:SetVelocity( damageData.ForceVec:GetNormalized()*damageData.Damage )
    self.ZGM3_LastCreatedLimbRagdoll = limb_ragdoll
    return limb_ragdoll
end


local stumpTbl = {
    ["ValveBiped.Bip01_Head1"] = { mdl = "models/mosi/fnv/props/character/headcap.mdl", ang_offset=Angle(0, 84, 442), pos_offset=Vector(6, 0, 0) },
    ["ValveBiped.Bip01_Spine2"] = { mdl = "models/mosi/fnv/props/gore/goretorsob01.mdl", ang_offset=Angle(0, 84, 442), pos_offset=Vector(11, 0, 0), scale=0.7 },
    ["ValveBiped.Bip01_R_UpperArm"] = { mdl="models/mosi/fnv/props/character/legcap02.mdl", ang_offset=Angle(77, 373, 0), pos_offset=Vector(5, -2, 0) },
    ["ValveBiped.Bip01_L_UpperArm"] = { mdl="models/mosi/fnv/props/character/legcap02.mdl", ang_offset=Angle(77, 373, 0), pos_offset=Vector(5, 2, 0) },
    ["ValveBiped.Bip01_R_Forearm"] = { mdl="models/mosi/fnv/props/character/armcap.mdl", ang_offset=Angle(77, 373, 0), pos_offset=Vector(4, 0, 0) },
    ["ValveBiped.Bip01_L_Forearm"] = { mdl="models/mosi/fnv/props/character/armcap.mdl", ang_offset=Angle(77, 373, 0), pos_offset=Vector(4, 0, 0) },
    ["ValveBiped.Bip01_R_Hand"] = { mdl="models/mosi/fnv/props/character/armcap.mdl", ang_offset=Angle(77, 373, 0), pos_offset=Vector(4, 0, 0), scale=0.7 },
    ["ValveBiped.Bip01_L_Hand"] = { mdl="models/mosi/fnv/props/character/armcap.mdl", ang_offset=Angle(77, 373, 0), pos_offset=Vector(4, 0, 0), scale=0.7 },
    ["ValveBiped.Bip01_R_Foot"] = { mdl="models/mosi/fnv/props/character/armcap.mdl", ang_offset=Angle(77, 373, 0), pos_offset=Vector(6, 0, 0), scale=1.2 },
    ["ValveBiped.Bip01_L_Foot"] = { mdl="models/mosi/fnv/props/character/armcap.mdl", ang_offset=Angle(77, 373, 0), pos_offset=Vector(6, 0, 0), scale=1.2 },
    ["ValveBiped.Bip01_R_Calf"] = { mdl="models/mosi/fnv/props/character/legcap02.mdl", ang_offset=Angle(77, 373, 0), pos_offset=Vector(7, 0, 0) },
    ["ValveBiped.Bip01_L_Calf"] = { mdl="models/mosi/fnv/props/character/legcap02.mdl", ang_offset=Angle(77, 373, 0), pos_offset=Vector(7, 0, 0) },
    ["ValveBiped.Bip01_R_Thigh"] = { mdl="models/mosi/fnv/props/character/legcap01.mdl", ang_offset=Angle(77, 373, 0), pos_offset=Vector(5, -2, 0) },
    ["ValveBiped.Bip01_L_Thigh"] = { mdl="models/mosi/fnv/props/character/legcap01.mdl", ang_offset=Angle(77, 373, 0), pos_offset=Vector(5, 2, 0) },
}
local stumpcvar = ZGM3_CVARS["zippygore3_stumps"]
function ENT:ZippyGoreMod3_GetStumpModel( gibbed_bone )
    local bone_name = self:GetBoneName(gibbed_bone)
    local tbl = stumpTbl[bone_name]

    if !tbl then
        return
    end

    return tbl.mdl, tbl.ang_offset, tbl.pos_offset, tbl.scale or 1
end


local stump_adjust = CreateConVar("zgm3_stump_adjust", 0, FCVAR_NONE, "Do not enable this.")
local dev = GetConVar("developer")
local up_world = Vector(0, 0, 1)
function ENT:ZippyGoreMod3_BreakPhysBone( phys_bone_idx, data )
    local gibbed_bone = self:TranslatePhysBoneToBone(phys_bone_idx)
    local EnhancedSplatter = DynSplatterFullyInitialized and false


    self:DrawShadow(false)


    local function gib_bone_recursive( bone, dismember, MakeLimbRag )
        self:ManipulateBoneScale(bone, Vector(0,0,0))

    
        local timer_name_real = bleed_timer_name..self:EntIndex().."_Bone: "..phys_bone_idx
        if timer.Exists(timer_name_real) then
            timer.Remove(timer_name_real)
        end

        local phys_bone = self:TranslateBoneToPhysBone( bone )
        if phys_bone != -1 then
            if !self.ZippyGoreMod3_GibbedPhysBones then self.ZippyGoreMod3_GibbedPhysBones = {} end
            if !self.ZippyGoreMod3_GibbedPhysBones[ phys_bone ] then
                local phys_obj = self:GetPhysicsObjectNum( phys_bone )
                if phys_obj then
                    
                    phys_obj:EnableCollisions(false)

                    
                    if !self.ZippyGoreMod3_GibbedPhysBoneParents then self.ZippyGoreMod3_GibbedPhysBoneParents = {} end
                    
                    if phys_bone != 0 then
                        self.ZippyGoreMod3_GibbedPhysBoneParents[ phys_bone ] = self:TranslateBoneToPhysBone(self:GetBoneParent( bone ))
                        self:RemoveInternalConstraint(phys_bone)
                    end

                    
                    local damageData = {
                        Damage = data.damage,
                        ForceVec = data.forceVec,
                    }
                    if dismember then
                        if MakeLimbRag && phys_bone != 0 then
                            self:ZippyGoreMod3_CreateLimbRagdoll( phys_bone, damageData )
                        elseif phys_bone == 0 then
                            self:ZippyGoreMod3_CreateGibs( phys_bone, damageData )
                        end
                    else
                        self:ZippyGoreMod3_CreateGibs( phys_bone, damageData )
                    end

                    MuR:CreateBloodPool(self, self:TranslatePhysBoneToBone(phys_bone), 3, 0)
					timer.Remove("RagdollStruggle"..self:EntIndex())
					if IsValid(self.Owner) and self.isRDRag and self.Owner:IsPlayer() then
						self.Owner:TimeGetUpChange(99999, true)
						self.Owner:DamagePlayerSystem("hard_blood")
						self.Gibbed = true
						if self:GetBoneName(bone) == "ValveBiped.Bip01_Head1" then
							if isstring(self.Owner.LastVoiceLine) then
								self.Owner:StopSound(self.Owner.LastVoiceLine)
							end
							self.Owner:Kill()
						end
					end
                    

                    
                    local physObjPos = phys_obj:GetPos()
                    local aabb_min, aabb_max = phys_obj:GetAABB()

                    local effect_pos_data = { blood_color=self.ZippyGoreMod3_BloodColor, pos_min = physObjPos + aabb_min, pos_max = physObjPos + aabb_max, ent=self }
                    local effectdata = EffectData()
                    effectdata:SetFlags( effect_pos_data.blood_color or -1 )
                    effectdata:SetOrigin( effect_pos_data.pos_min )
                    effectdata:SetStart( effect_pos_data.pos_max )
                    effectdata:SetEntity(effect_pos_data.ent)
                    util.Effect("zippygore3_ongib", effectdata, true, true)
                    

                    
                    if bone == 0 then
                        self:EmitSound("ZippyGore3OnRootBoneGib")
                    else
                        self:EmitSound("ZippyGore3OnGib")
                    end
                    

                    self.ZippyGoreMod3_GibbedPhysBones[ phys_bone ] = true
                end
            end

            
            if self.ZGM3_OnBreakRemoveStumpTbl && self.ZGM3_OnBreakRemoveStumpTbl[bone] then
                self.ZGM3_OnBreakRemoveStumpTbl[bone]()
            end

            for _, v in ipairs(self:GetChildBones(bone)) do
                gib_bone_recursive(v, dismember, phys_bone==0)
            end
        end
    end



    
    gib_bone_recursive( gibbed_bone, data.dismember, true )


    if phys_bone_idx == 0 then
        
        self:Remove()
    elseif blood_particles[self.ZippyGoreMod3_BloodColor] then

        
        self:ZippyGoreMod3_BleedEffect( phys_bone_idx )

        local boneName = self:GetBoneName(gibbed_bone)
        if boneName == ZGM3_BONE_PELVIS and not self.ZGM3_Spine2Gibbed then
            if not self.ZGM3_GutsSpawned then
                local guts = ents.Create("prop_ragdoll")
                if IsValid(guts) then
                    guts:SetModel(ZGM3_GUTS_MODEL)
                    guts:SetPos(self:GetBonePosition(1))
                    guts:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
                    local pelvisBone = self:LookupBone(ZGM3_BONE_PELVIS)
                    if pelvisBone then
                        local m = self:GetBoneMatrix(pelvisBone)
                        if m then guts:SetAngles(ZGM3_AddLocalAngle(m:GetAngles(), ZGM3_GUTS_PARENT_ANG_OFFSET)) else guts:SetAngles(ZGM3_AddLocalAngle(self:GetAngles(), ZGM3_GUTS_PARENT_ANG_OFFSET)) end
                    else
                        guts:SetAngles(ZGM3_AddLocalAngle(self:GetAngles(), ZGM3_GUTS_PARENT_ANG_OFFSET))
                    end
                    guts:Spawn()
                    guts:GetPhysicsObjectNum(20):SetVelocity(data.forceVec or Vector())
                    self.ZGM3_GutsSpawned = true
                end
            end
        elseif boneName == ZGM3_BONE_SPINE2 then
            self.ZGM3_Spine2Gibbed = true
            local guts = ents.Create("prop_ragdoll")
            if IsValid(guts) then
                guts:SetModel(ZGM3_GUTS_MODEL)
                guts:SetPos(self:GetBonePosition(1))
                guts:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
                local s2idx = self:LookupBone(ZGM3_BONE_SPINE2)
                if s2idx then
                    local m = self:GetBoneMatrix(s2idx)
                    if m then guts:SetAngles(ZGM3_AddLocalAngle(m:GetAngles(), ZGM3_GUTS_PARENT_ANG_OFFSET)) else guts:SetAngles(ZGM3_AddLocalAngle(self:GetAngles(), ZGM3_GUTS_PARENT_ANG_OFFSET)) end
                else
                    guts:SetAngles(ZGM3_AddLocalAngle(self:GetAngles(), ZGM3_GUTS_PARENT_ANG_OFFSET))
                end
                guts:Spawn()
                guts:GetPhysicsObjectNum(20):SetVelocity(data.forceVec or Vector())
                local created = self.ZGM3_LastCreatedLimbRagdoll
                local function getPhysByBone(ent, boneStr)
                    if !IsValid(ent) then return nil end
                    local b = ent:LookupBone(boneStr)
                    if !b then return nil end
                    local pb = ent:TranslateBoneToPhysBone(b)
                    if pb < 0 then return nil end
                    return ent:GetPhysicsObjectNum(pb), pb
                end
                local pSelf, idxSelf = getPhysByBone(self, ZGM3_GUTS_WELD_BONE_PARENT)
                local pLimb, idxLimb = getPhysByBone(created, ZGM3_GUTS_WELD_BONE_CHILD)
                local pGuts1 = guts:GetPhysicsObjectNum(0)
                local gParentPhys = guts:GetPhysicsObjectNum(ZGM3_GUTS_PARENT_PHYS)
                local gChildPhys = guts:GetPhysicsObjectNum(ZGM3_GUTS_CHILD_PHYS)
                local function alignPhysToBone(hostEnt, boneName, physObj, angOffset)
                    if not (IsValid(hostEnt) and IsValid(physObj)) then return end
                    local b = hostEnt:LookupBone(boneName)
                    if not b then return end
                    local m = hostEnt:GetBoneMatrix(b)
                    if not m then return end
                    physObj:SetPos(m:GetTranslation())
                    physObj:SetAngles(ZGM3_AddLocalAngle(m:GetAngles(), angOffset or angle_zero))
                    physObj:Wake()
                end
                alignPhysToBone(self, ZGM3_GUTS_WELD_BONE_PARENT, gParentPhys, ZGM3_GUTS_PARENT_ANG_OFFSET)
                if IsValid(created) then alignPhysToBone(created, ZGM3_GUTS_WELD_BONE_CHILD, gChildPhys, ZGM3_GUTS_CHILD_ANG_OFFSET) end
                local weldCount = 0
                local lastConstraint
                if IsValid(pSelf) and IsValid(pGuts1) then
                    lastConstraint = constraint.Weld(self, guts, idxSelf or 0, ZGM3_GUTS_PARENT_PHYS, ZGM3_GUTS_WELD_FORCE, false, false)
                    if lastConstraint then weldCount = weldCount + 1 end
                end
                if IsValid(pLimb) and IsValid(pGuts1) then
                    local c2 = constraint.Weld(created, guts, idxLimb or 0, ZGM3_GUTS_CHILD_PHYS, ZGM3_GUTS_WELD_FORCE, false, false)
                    if c2 then weldCount = weldCount + 1 end
                end
                if weldCount == 0 and IsValid(pSelf) and IsValid(pGuts1) then
                    lastConstraint = constraint.Weld(self, guts, idxSelf or 0, ZGM3_GUTS_PARENT_PHYS, ZGM3_GUTS_WELD_FORCE, false, false)
                    if lastConstraint then weldCount = 1 end
                elseif weldCount == 0 and IsValid(pLimb) and IsValid(pGuts1) then
                    lastConstraint = constraint.Weld(created, guts, idxLimb or 0, ZGM3_GUTS_CHILD_PHYS, ZGM3_GUTS_WELD_FORCE, false, false)
                    if lastConstraint then weldCount = 1 end
                end
                guts.ZGM3_GutsWelds = weldCount
                self.ZGM3_GutsSpawned = true
            end
        end

        
        local mdl, ang_offset, pos_offset, scale = self:ZippyGoreMod3_GetStumpModel(gibbed_bone)
        if mdl then
            local phys = self:GetPhysicsObjectNum(phys_bone_idx)
            local parent_bone = self:GetBoneParent(gibbed_bone)
            local parent_phys = self:GetPhysicsObjectNum( self:TranslateBoneToPhysBone(parent_bone) )
            local phys_pos = phys:GetPos()
            local parent_phys_pos = parent_phys:GetPos()
            
            
            local forward = (parent_phys_pos - phys_pos):GetNormalized()
            
            

            local right = forward:Cross(up_world):GetNormalized()
            
            
            local up = right:Cross(forward):GetNormalized()
            
            
            debugoverlay.Line(phys_pos, phys_pos + forward * 100, 2, Color(0, 255, 0)) -- Forward is green
            debugoverlay.Line(phys_pos, phys_pos + up * 100, 2, Color(0, 0, 255))     -- Up is blue
            debugoverlay.Line(phys_pos, phys_pos + right * 100, 2, Color(255, 0, 0))  -- Right is red
            

            local stump = ents.Create("base_gmodentity")
            stump:SetParent(self)
            stump:SetModel(mdl)
            stump:FollowBone(self, parent_bone)
            stump:SetPos( phys_pos + (forward*pos_offset.x) + (right*pos_offset.y) + (up*pos_offset.z) )
            stump:SetAngles(  self:GetAngles() + (!stump_adjust:GetBool() && ang_offset or angle_zero) )
            if scale != 1 then stump:SetModelScale(scale, 0) end
            stump:Spawn()


            self.ZGM3_OnBreakRemoveStumpTbl = self.ZGM3_OnBreakRemoveStumpTbl or {}
            self.ZGM3_OnBreakRemoveStumpTbl[parent_bone] = function()
                SafeRemoveEntity(stump)
            end


            
            if stump_adjust:GetBool() && dev:GetBool() then

                stump.ZGM3_DevAngOffset = Angle()
                hook.Add("Tick", stump, function()
                    if !IsValid(stump) then
                        hook.Remove("Tick", stump)
                        return 
                    end

                    local ply = Entity(1)

                    if IsValid(ply) && ply:IsPlayer() then

                        local did_adjust = false

                        if ply:KeyDown(IN_FORWARD) then
                            stump.ZGM3_DevAngOffset = stump.ZGM3_DevAngOffset+Angle(1, 0, 0)
                            did_adjust = true
                        elseif ply:KeyDown(IN_MOVERIGHT) then
                            stump.ZGM3_DevAngOffset = stump.ZGM3_DevAngOffset+Angle(0, 1, 0)
                            did_adjust = true
                        elseif ply:KeyDown(IN_JUMP) then
                            stump.ZGM3_DevAngOffset = stump.ZGM3_DevAngOffset+Angle(0, 0, 1)
                            did_adjust = true
                        elseif ply:KeyDown(IN_BACK) then
                            stump.ZGM3_DevAngOffset = stump.ZGM3_DevAngOffset+Angle(-1, 0, 0)
                            did_adjust = true
                        elseif ply:KeyDown(IN_MOVELEFT) then
                            stump.ZGM3_DevAngOffset = stump.ZGM3_DevAngOffset+Angle(0, -1, 0)
                            did_adjust = true
                        elseif ply:KeyDown(IN_SPEED) then
                            stump.ZGM3_DevAngOffset = stump.ZGM3_DevAngOffset+Angle(0, 0, -1)
                            did_adjust = true
                        end

                        if did_adjust then
                            stump:SetAngles(stump.ZGM3_DevAngOffset)
                            PrintMessage(HUD_PRINTTALK, tostring(stump.ZGM3_DevAngOffset))
                            ply:SetPos(stump:GetPos())
                        end

                    end

                end)
            end
        end

    end

    
    if ZGM3_CVARS["zippygore3_print_gibbed_bone"] then
        PrintMessage(HUD_PRINTCENTER, self:GetBoneName( gibbed_bone ) )
        PrintMessage(HUD_PRINTTALK, self:GetBoneName( gibbed_bone ) )
    end
end