local fxlist = {
    {
        name = "um_ocean_splash",
        bank = "Bubble_fx",
        build = "crab_king_bubble_fx",
        anim = "waterspout",
        sound = "turnoftides/common/together/water/splash/medium",
        fn = function(inst)
            inst.AnimState:SetFinalOffset(1)
        end,
    },
    {
        name = "um_brokentool",
        bank = "broketool",
        build = "broken_tool",
        anim = "used",
        sound = "dontstarve/wilson/use_break",
        nofaced = true,
    },
    {
        name = "wathom_wound_vfx",
        bank = "wathom_wound_vfx",
        build = "wathom_wound_vfx",
        anim = "idle1",
        nofaced = true,
        fn = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(.85)
        end,
    },
    {
        name = "um_deer_fire_burst",
        bank = "deer_fire_burst",
        build = "deer_fire_burst",
        anim = "idle",
        nofaced = true,
        fn = function(inst)
            inst.AnimState:SetLightOverride(1)
            inst.AnimState:SetFinalOffset(1)
        end,
    },
}

local fxprefabs = require("fx")
for _, fx in pairs(fxlist) do
    table.insert(fxprefabs, fx)
end