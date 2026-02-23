wOS.DynaBase:RegisterSource({
    Name = "Bloodshed: Redux - Kick Animations",
    Type = WOS_DYNABASE.EXTENSION,

    Shared = "models/murdered/kick_anim_m.mdl",
    Female = "models/murdered/kick_anim_f.mdl",
    Male   = "models/murdered/kick_anim_m.mdl"
})

hook.Add("PreLoadAnimations", "wOS.DynaBase.MountBloodshedKick", function(gender)
    if gender == WOS_DYNABASE.SHARED then
        IncludeModel("models/murdered/kick_anim_m.mdl")
    elseif gender == WOS_DYNABASE.FEMALE then
        IncludeModel("models/murdered/kick_anim_f.mdl")
    elseif gender == WOS_DYNABASE.MALE then
        IncludeModel("models/murdered/kick_anim_m.mdl")
    end
end)
