local FACES =
{
    FOUR = 1,
    SIX  = 2,
    TWO  = 3,
    EIGHT = 4,
}

local corpselist = {
    {
        creature = "um_vampirebat",
        bank = "bat",
        build = "bat_vamp_build",
        sg = "SGum_vampirebat",
        firesymbol = "bat_body",
        makeburnablefn = MakeMediumBurnableCorpse,
        faces = FACES.FOUR,
        sanityaura = -TUNING.SANITYAURA_MED,
        use_inventory_physics = true,
        shadowsize = {1.5, .75},
    },
}

local corpseprefabs = require("prefabs/corpses_defs").CORPSE_DEFS
for _, fx in pairs(corpselist) do
    table.insert(corpseprefabs, fx)
end