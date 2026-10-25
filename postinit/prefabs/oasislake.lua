local env = env
GLOBAL.setfenv(1, GLOBAL)
-----------------------------------------------------------------

--[[env.AddPrefabPostInit("oasislake", function(inst)
	if not TheWorld.ismastersim then return end
end)]]