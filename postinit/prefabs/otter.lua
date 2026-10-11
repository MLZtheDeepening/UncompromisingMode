local env = env
GLOBAL.setfenv(1, GLOBAL)
-----------------------------------------------------------------
SetSharedLootTable("otter",
{
    { "meat",            1.00 },
    { "messagebottle",   0.05 },
})	

--[[env.AddPrefabPostInit("otter", function(inst)
    if not TheWorld.ismastersim then return end
end)]]