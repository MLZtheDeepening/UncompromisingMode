local env = env
GLOBAL.setfenv(1, GLOBAL)
-----------------------------------------------------------------
SetSharedLootTable('batty',
{
    {'batwing',    0.15},
    {'guano',      0.15},
    {'monstersmallmeat',0.10},
})

local _OnSave
local function OnSave(inst, data, ...)
    data.um_guano_rain_temporary = inst.um_guano_rain_temporary
    return _OnSave and _OnSave(inst, data, ...)
end

local _OnLoad
local function OnLoad(inst, data, ...)
    if data and data.um_guano_rain_temporary then
        inst.um_guano_rain_temporary = true
    end
    return _OnLoad and _OnLoad(inst, data, ...)
end

env.AddPrefabPostInit("bat", function(inst)
	if not TheWorld.ismastersim then
		return
	end

	if inst.components.lootdropper then
		inst.components.lootdropper:SetChanceLootTable('batty')
	end

    if not _OnSave then
        _OnSave = inst.OnSave
    end
    inst.OnSave = OnSave
    if not _OnLoad then
        _OnLoad = inst.OnLoad
    end
    inst.OnLoad = OnLoad
end)