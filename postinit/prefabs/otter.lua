local env = env
GLOBAL.setfenv(1, GLOBAL)
-----------------------------------------------------------------
env.AddSimPostInit(function()
    SetSharedLootTable("otter",
    {
        {"meat", 1},
        {"messagebottle", .05},
    })
end)

--[[env.AddPrefabPostInit("otter", function(inst)
    if not TheWorld.ismastersim then return end
end)]]