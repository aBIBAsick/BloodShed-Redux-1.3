MuR = MuR or {}
MuR.Organs = {}

function MuR.AddOrgan(name, bone, mins, maxs, color, bleed)
	table.insert(MuR.Organs, {
		name = name,
		bone = bone,
		mins = mins,
		maxs = maxs,
		color = color or Color(255, 255, 255),
		bleed = bleed or 0
	})
end

function MuR.GetOrgan(name)
    for _, o in ipairs(MuR.Organs) do
        if o.name == name then return o end
    end
    return nil
end

MuR.AddOrgan("Brain", "ValveBiped.Bip01_Head1", Vector(2, -3, -2), Vector(6, 1, 2), Color(255, 0, 0), 0)
MuR.AddOrgan("Neck", "ValveBiped.Bip01_Neck1", Vector(1, -4, -2), Vector(3, 1, 2), Color(240, 120, 0), 4)
MuR.AddOrgan("Heart", "ValveBiped.Bip01_Spine2", Vector(2, 2, -1.5), Vector(6, 6, 1.5), Color(230, 140, 40), 2)
MuR.AddOrgan("Right Lung", "ValveBiped.Bip01_Spine2", Vector(8, 4, -5), Vector(0, 0, -2), Color(100, 100, 250), 2)
MuR.AddOrgan("Left Lung", "ValveBiped.Bip01_Spine2", Vector(8, 4, 5), Vector(0, 0, 2), Color(100, 100, 250), 2)
MuR.AddOrgan("Abdomen", "ValveBiped.Bip01_Spine", Vector(-3, 0, -4), Vector(4, 4, 4), Color(250, 200, 100), 1)

MuR.AddOrgan("Right Wrist Artery", "ValveBiped.Bip01_R_Hand", Vector(-1, -2, -1), Vector(1, 1, 1), Color(200, 20, 20), 3)
MuR.AddOrgan("Left Wrist Artery", "ValveBiped.Bip01_L_Hand", Vector(-1, -2, -1), Vector(1, 1, 1), Color(200, 20, 20), 3)
MuR.AddOrgan("Right Arm Artery", "ValveBiped.Bip01_R_Forearm", Vector(-1, -1, 0), Vector(1, 1, 2), Color(200, 20, 20), 4)
MuR.AddOrgan("Left Arm Artery", "ValveBiped.Bip01_L_Forearm", Vector(-1, -1, -2), Vector(1, 1, 0), Color(200, 20, 20), 4)
MuR.AddOrgan("Right Leg Artery", "ValveBiped.Bip01_R_Calf", Vector(-1, -1, 0), Vector(1, 1, 2), Color(200, 20, 20), 4)
MuR.AddOrgan("Left Leg Artery", "ValveBiped.Bip01_L_Calf", Vector(-1, -1, -2), Vector(1, 1, 0), Color(200, 20, 20), 4)

MuR.AddOrgan("Spine", "ValveBiped.Bip01_Spine1", Vector(0, -4, -6), Vector(2, 4, 6), Color(200, 200, 200), 0)
MuR.AddOrgan("Liver", "ValveBiped.Bip01_Spine", Vector(4, 2, -6), Vector(8, 6, -3), Color(100, 50, 0), 3)
MuR.AddOrgan("Left Eye", "ValveBiped.Bip01_Head1", Vector(3.5, -4.5, 0.5), Vector(4, -4, 1.8), Color(230, 255, 0), 1)
MuR.AddOrgan("Right Eye", "ValveBiped.Bip01_Head1", Vector(3.5, -4.5, -0.5), Vector(4, -4, -1.8), Color(230, 255, 0), 1)