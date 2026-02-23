if !ZippyGoreMod3_BasicGib_Models then ZippyGoreMod3_BasicGib_Models = { "models/props_junk/watermelon01_chunk02a.mdl", "models/props_junk/watermelon01_chunk02b.mdl" } end
if !ZippyGoreMod3_BasicGib_Scale then ZippyGoreMod3_BasicGib_Scale = {0.5, 1} end
if ZippyGoreMod3_BasicGib_UseFleshMaterial != false then ZippyGoreMod3_BasicGib_UseFleshMaterial = true end

if !ZippyGoreMod3_CustomGibs then
    -- Use default gibs when no custom ones are available:
    ZippyGoreMod3_CustomGibs = {
        ["ValveBiped.Bip01_Head1"] = {
            gibs = {
                {
                    model = "models/Gibs/HGIBS.mdl",
                    scale = 1,
                },
                {
                    model = "models/Gibs/HGIBS_spine.mdl",
                    scale = 0.5,
                },
            },
        },
        ["ValveBiped.Bip01_Spine2"] = {
            gibs = {
                {
                    model = "models/Gibs/HGIBS_spine.mdl",
                    scale = 1.25,
                },
                {
                    model = "models/Gibs/HGIBS_rib.mdl",
                    random_angle = true,
                    random_pos = true,
                    scale = {0.5, 0.75},
                    count = {2, 4},
                },
            },

            basic_gib_mult = 0.5,
        },
        ["ValveBiped.Bip01_Pelvis"] = {
            gibs = {
                {
                    model = "models/Gibs/HGIBS_spine.mdl",
                    scale = {0.85, 1.15},
                },
                {
                    model = "models/gibs/antlion_gib_medium_1.mdl",
                    random_angle = true,
                    random_pos = true,
                    use_flesh_material = true,
                    scale = {0.8, 1.2},
                    count = {3, 5},
                },
            },

            basic_gib_mult = 0.35,
        },
    }
end











-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- BASIC GIBS --
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- The "basic" gibs are gibs that can spawn from any ragdoll bone:

-- Here is an example that turns the gibs into giant bathtubs:
-- (VERY IMPORTANT: REMOVE THE "local" WHEN YOU USE THESE IN YOUR FILE!!)
ZippyGoreMod3_BasicGib_Models = { "models/mosi/fnv/props/gore/meatbit01.mdl" } -- Put as many models as you like.
ZippyGoreMod3_BasicGib_Scale = {1, 4} -- Minimum and maximum model scale for the basic gibs. Both values have to be included.
ZippyGoreMod3_BasicGib_UseFleshMaterial = false -- Apply a flesh material to the models, set to false if you want the models to have their default materials.

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- BONE SPECIFIC GIBS --
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Here you can change what gibs should spawn from specific bones

-- [*name of bone that should have these gibs, for example "ValveBiped.Bip01_Head1"*] = {
--     gibs = {
--         {
--             model = *gib model name*,
--             scale = {*minimum model scale*, *maximum model scale*},
--             random_angle = *true = spawn with random angle, otherwise it will have the same angle as the bone*,
--             random_pos = *true = spawn at a random position around the bone, otherwise it will spawn on the bone*,
--             count = {*minimum amount of this gib*, *maximum amount of this gib*},
--             use_flesh_material = *true = spawn with a flesh material*,
--         },
--     },

--     basic_gib_mult = *multiply the amount of "basic" gibs spawned when this bone is gibbed*.
-- },

-- Your table of gibs should look something like this:
-- (VERY IMPORTANT: REMOVE THE "local" IN YOUR FILE!!)
ZippyGoreMod3_CustomGibs = {
    ["ValveBiped.Bip01_Head1"] = {
        -- The head spawns a skull and a small spine piece:
        gibs = {
            {
                model = "models/mosi/fnv/props/gore/gorehead01.mdl",
                scale = 1,
            },
            {
                model = "models/mosi/fnv/props/gore/gorehead04.mdl",
                scale = 1,
            },
			{
                model = "models/mosi/fnv/props/gore/gorehead05.mdl",
                scale = 1,
            },
			{
                model = "models/mosi/fnv/props/gore/gorehead02.mdl",
                scale = 1,
            },
			{
                model = "models/mosi/fnv/props/gore/gorehead06.mdl",
                scale = 1,
            },
			{
                model = "models/mosi/fnv/props/gore/gorehead03.mdl",
                scale = 1,
            },
        },
        basic_gib_mult = 0.1,
    },
    
    ["ValveBiped.Bip01_Spine2"] = {
        -- Chest spawns ribs and a spine peice:
        gibs = {
            {
                model = "models/mosi/fnv/props/gore/goretorso03.mdl",
                scale = 0.9,
            },
            {
                model = "models/mosi/fnv/props/gore/goretorso04.mdl",
                scale = 0.9,
            },
        },

        basic_gib_mult = 0.4,
    },
    -- Upper Arms
    ["ValveBiped.Bip01_L_UpperArm"] = {

        gibs = {
            {
                model = "models/mosi/fnv/props/gore/gorearm01.mdl",
                scale = 1,
            },       
    },
    basic_gib_mult = 0.5,
},
["ValveBiped.Bip01_R_UpperArm"] = {

    gibs = {
        {
            model = "models/mosi/fnv/props/gore/gorearm01.mdl",
            scale = 1,
        },       
},
basic_gib_mult = 0.5,
},
-- Lower Arms
["ValveBiped.Bip01_L_Forearm"] = {

    gibs = {
        {
            model = "models/mosi/fnv/props/gore/gorearm02.mdl",
            scale = 1,
        },
    
},
basic_gib_mult = 0.5,
},

["ValveBiped.Bip01_R_Forearm"] = {

    gibs = {
        {
            model = "models/mosi/fnv/props/gore/gorearm02.mdl",
            scale = 1,
        },
    
},
basic_gib_mult = 0.5,
},
--Spine1
["ValveBiped.Bip01_Spine"] = {
    gibs = {
        {
            model = "models/mosi/fnv/props/gore/goretorso02.mdl",
            scale = 1,
        },           
   
}, 
basic_gib_mult = 0.6,
},
--Upper Legs
["ValveBiped.Bip01_L_Thigh"] = {

    gibs = {
        {
            model = "models/mosi/fnv/props/gore/goreleg03.mdl",
            scale = 1,
        },           
    },
basic_gib_mult = 0.1,
},
["ValveBiped.Bip01_R_Thigh"] = {

    gibs = {
        {
            model = "models/mosi/fnv/props/gore/goreleg03.mdl",
            scale = 1,
        },           
    },
basic_gib_mult = 0.1,
},
--Lower Legs
["ValveBiped.Bip01_L_Calf"] = {

    gibs = {
        {
            model = "models/mosi/fnv/props/gore/goreleg02.mdl",
            scale = 1,
        },           
   
}, 
basic_gib_mult = 0.1,
},
["ValveBiped.Bip01_R_Calf"] = {

    gibs = {
        {
            model = "models/mosi/fnv/props/gore/goreleg02.mdl",
            scale = 1,
        },           
   
}, 
basic_gib_mult = 0.1,
},
--Feet
["ValveBiped.Bip01_L_Foot"] = {

    gibs = {
        {
            model = "models/mosi/fnv/props/gore/goreleg01.mdl",
            scale = 1,
        },           
   
}, 
basic_gib_mult = 0.1,
},
["ValveBiped.Bip01_R_Foot"] = {

    gibs = {
        {
            model = "models/mosi/fnv/props/gore/goreleg01.mdl",
            scale = 1,
        },           
   
}, 
basic_gib_mult = 0.1,
},
--Pelvis
    ["ValveBiped.Bip01_Pelvis"] = {
        -- The gut spawns something that kind of resembles intestines, and also another spine peice:
        gibs = {
            {
                model = "models/mosi/fnv/props/gore/goretorso01.mdl",
                scale = 0.9
            },
            {
                model = "models/mosi/fnv/props/gore/goretorso05.mdl",
                random_angle = true,
                random_pos = true,
                scale = {0.8, 1.2},
                count = {3, 4},
            },
        },

        basic_gib_mult = 0.35,
    },
}