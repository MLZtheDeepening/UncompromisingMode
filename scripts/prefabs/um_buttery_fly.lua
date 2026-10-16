require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/um_buttery_fly.zip"),
}

local prefabs =
{
    "butter",
    "um_buttercup",
}

local brain = require "brains/butterflybrain"

local function OnDropped(inst)
    inst.sg:GoToState("idle")
    if inst.butterflyspawner then
        inst.butterflyspawner:StartTracking(inst)
    end
    if inst.components.workable then
        inst.components.workable:SetWorkLeft(1)
    end
    if inst.components.stackable then
        while inst.components.stackable:StackSize() > 1 do
            local item = inst.components.stackable:Get()
            if item then
                if item.components.inventoryitem then
                    item.components.inventoryitem:OnDropped()
                end
                item.Physics:Teleport(inst.Transform:GetWorldPosition())
            end
        end
    end
end

local function OnPickedUp(inst)
    if inst.butterflyspawner then
        inst.butterflyspawner:StopTracking(inst)
    end
end

local function OnWorked(inst, worker)
    if worker.components.inventory then
        if inst.butterflyspawner then
            inst.butterflyspawner:StopTracking(inst)
        end
        worker.components.inventory:GiveItem(inst, nil, inst:GetPosition())
        worker.SoundEmitter:PlaySound("dontstarve/common/butterfly_trap")
    end
end

local function OnDeploy(inst, pt, deployer)
    local flower = SpawnPrefab("um_buttercup")
    if flower then
        flower.Transform:SetPosition(pt:Get())
        inst.components.stackable:Get():Remove()
        AwardPlayerAchievement("growfrombutterfly", deployer)
        TheWorld:PushEvent("CHEVO_growfrombutterfly", {target = flower, doer = deployer})
        if deployer and deployer.SoundEmitter then
            deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
        end
    end
end

local function OnMutate(inst, transformed_inst)
	if transformed_inst then
		transformed_inst.sg:GoToState("idle")
	end
end

local function fn()
    local inst = CreateEntity()

    --Core components
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local shadow = inst.entity:AddDynamicShadow()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    --Initialize physics
    MakeTinyFlyingCharacterPhysics(inst, 1, .5)

    inst:AddTag("butterfly")
    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")
    inst:AddTag("insect")
    inst:AddTag("smallcreature")
    inst:AddTag("cattoyairborne")
    inst:AddTag("wildfireprotected")
    inst:AddTag("deployedplant")
    inst:AddTag("noember")
    inst:AddTag("plantcreature")

    --pollinator (from pollinator component) added to pristine state for optimization
    inst:AddTag("pollinator")

    trans:SetTwoFaced()

    anim:SetBuild("um_buttery_fly")
    anim:SetBank("butterfly")
    anim:PlayAnimation("idle")
    anim:SetRayTestOnBB(true)

    shadow:SetSize(.8, .5)

    MakeInventoryFloatable(inst)

    MakeFeedableSmallLivestockPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    ---------------------
    local locomotor = inst:AddComponent("locomotor")
    locomotor:EnableGroundSpeedMultiplier(false)
    locomotor:SetTriggersCreep(false)

    inst:SetStateGraph("SGbutterfly")
    inst.sg.mem.burn_on_electrocute = true

    ---------------------
    inst:AddComponent("stackable")
    local inventoryitem = inst:AddComponent("inventoryitem")
    inventoryitem.canbepickedup = false
    inventoryitem.canbepickedupalive = true
    inventoryitem.nobounce = true
    inventoryitem.pushlandedevents = false

    ------------------
    inst:AddComponent("pollinator")

    ------------------
    local health = inst:AddComponent("health")
    health:SetMaxHealth(1)

    ------------------
    local combat = inst:AddComponent("combat")
    combat.hiteffectsymbol = "butterfly_body"

    ------------------
    inst:AddComponent("knownlocations")

    local burnable = MakeSmallBurnableCharacter(inst, "butterfly_body")
    MakeTinyFreezableCharacter(inst, "butterfly_body")
    burnable:SetBurnTime(6 * TUNING.PLANTMOB_BURNTIME_MULT)
    health.fire_damage_scale = TUNING.PLANTMOB_FIRE_DAMAGE_SCALE

    ------------------
    local inspectable = inst:AddComponent("inspectable")
	inspectable.nameoverride = "BUTTERFLY"

    ------------------
    local lootdropper = inst:AddComponent("lootdropper")
    lootdropper:AddRandomLoot("butter", 1)
    lootdropper.numrandomloot = 1

    ------------------
    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.NET)
    workable:SetWorkLeft(1)
    workable:SetOnFinishCallback(OnWorked)

    ------------------
    inst:AddComponent("tradable")

    ------------------
    local deployable = inst:AddComponent("deployable")
    deployable.ondeploy = OnDeploy
    deployable:SetDeployMode(DEPLOYMODE.PLANT)
    deployable:SetDeploySpacing(DEPLOYSPACING.LESS)

    MakeHauntablePanicAndIgnite(inst)

    inst:SetBrain(brain)

    inst.butterflyspawner = TheWorld.components.butterflyspawner
    if inst.butterflyspawner then
        inventoryitem:SetOnPutInInventoryFn(inst.butterflyspawner.StopTrackingFn)
        inst:ListenForEvent("onremove", inst.butterflyspawner.StopTrackingFn)
        inst.butterflyspawner:StartTracking(inst)
    end

    MakeFeedableSmallLivestock(inst, TUNING.BUTTERFLY_PERISH_TIME, OnPickedUp, OnDropped)

    local halloweenmoonmutable = inst:AddComponent("halloweenmoonmutable")
    halloweenmoonmutable:SetPrefabMutated("moonbutterfly")
    halloweenmoonmutable:SetOnMutateFn(OnMutate)
    halloweenmoonmutable.push_attacked_on_new_inst = false

    return inst
end

return Prefab("um_buttery_fly", fn, assets, prefabs),
    MakePlacer("um_buttery_fly_placer", "um_buttercup", "um_buttercup", "idle")