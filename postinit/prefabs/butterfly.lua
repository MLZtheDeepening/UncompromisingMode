local env = env
GLOBAL.setfenv(1, GLOBAL)

if TUNING.DSTU.BUTTERFLYWINGS_NERF == "petals" then
    local function MakeButtery(inst)
        SpawnPrefab("um_buttery_fly").Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst:Remove()
    end

    local function RollForButtery(inst)
        if inst.buttery and inst.buttery >= 98 then
            MakeButtery(inst)
        end
    end

    local butterflies = {["butterfly"] = {"petals"}, ["um_buttery_fly"] = {"petals", "petals"}, ["moonbutterfly"] = {"moon_tree_blossom"}}
    for prefab, petaltable in pairs(butterflies) do
        env.AddPrefabPostInit(prefab, function(inst)
            if not TheWorld.ismastersim then return end

            inst.um_petaldroptable = petaltable

            local lootdropper = inst.components.lootdropper
            if lootdropper then
                local _LootSetupFn = lootdropper.lootsetupfn
                lootdropper:SetLootSetupFn(function(_lootdropper, ...)
                    local _inst = _lootdropper.inst
                    if not _inst.um_wasmurdered then
                        _lootdropper:SetChanceLootTable(nil) -- Moon Moth sets a chance loot table that needs to be cleared here.
                        _lootdropper:SetLoot(_inst.um_petaldroptable or {"petals"})
                    end
                    return _LootSetupFn and _LootSetupFn(_lootdropper, ...)
                end)
            end

            if prefab == "butterfly" then
                if lootdropper then lootdropper:SetLoot({"butterflywings"}) end

                local _OnSave = inst.OnSave
                inst.OnSave = function(_inst, data, ...)
                    if _inst.buttery then data.buttery = _inst.buttery end
                    return _OnSave and _OnSave(_inst, data, ...)
                end
                local _OnLoad = inst.OnLoad
                inst.OnLoad = function(_inst, data, ...)
                    _inst.buttery = data and data.buttery or math.random(1, 100)
                    RollForButtery(_inst)
                    return _OnLoad and _OnLoad(_inst, data, ...)
                end
            end
        end)
    end

    local function ReEnableButterfly(inst)
        if inst.spawned_butterfly then inst.spawned_butterfly = nil end
    end
    
    local flower_types = {"flower", "flower_evil", "um_buttercup"}
    for i,v in ipairs(flower_types) do
        env.AddPrefabPostInit(v, function(inst)
            if not TheWorld.ismastersim then return end
            inst:WatchWorldState("isday", ReEnableButterfly)
        end)
    end

    local FLOWER_TAGS = {"flower"}
    local function GetSpawnPoint(player)
        local rad = 25
        local mindistance = 36
        local x, y, z = player.Transform:GetWorldPosition()
        local flowers = TheSim:FindEntities(x, y, z, rad, FLOWER_TAGS)

        for i, v in ipairs(flowers) do
            while v ~= nil and player:GetDistanceSqToInst(v) <= mindistance or (v ~= nil and v.spawned_butterfly) do
                table.remove(flowers, i)
                v = flowers[i]
            end
        end

        local chosen_flower
        if next(flowers) then
            chosen_flower = flowers[math.random(1, #flowers)]
            chosen_flower.spawned_butterfly = true
        end
        return chosen_flower
    end

    local UMUpvalueHacker = require("tools/um_upvaluehacker")
    env.AddComponentPostInit("butterflyspawner", function(self)
        local _GetSpawnPoint = UMUpvalueHacker.TryGetUpvalue(self.OnPostInit, "ToggleUpdate", "ScheduleSpawn", "SpawnButterflyForPlayer", "GetSpawnPoint")
        if _GetSpawnPoint then UMUpvalueHacker.SetUpvalue(self.OnPostInit, GetSpawnPoint, "ToggleUpdate", "ScheduleSpawn", "SpawnButterflyForPlayer", "GetSpawnPoint") end
    end)
end