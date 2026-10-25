local env = env
GLOBAL.setfenv(1, GLOBAL)
-----------------------------------------------------------------

-- Lightning FX

local FX_OFFSETS = { -- NOTES(JBK): Similar offsets done for reskin_tool the y position positive goes down.
    DEFAULT = {0, 0, 0},
    ["spear_wathgrithr_lightning_lunar"]    = {0,  20, 0},
    ["spear_wathgrithr_lightning_valkyrie"] = {0,   0, 0},
    ["spear_wathgrithr_lightning_wrestle"]  = {0, -20, 0},
    ["spear_wathgrithr_lightning_northern"] = {0, -10, 0},
}

local function LightningCharged_SetFxOwner(inst, owner)
    if inst._fxowner ~= nil and inst._fxowner.components.colouradder ~= nil then
        inst._fxowner.components.colouradder:DetachChild(inst.fx)
    end

    inst._fxowner = owner

    local offset = FX_OFFSETS.DEFAULT
    if owner ~= nil then
        inst.fx.entity:SetParent(owner.entity)

        inst.fx.Follower:FollowSymbol(owner.GUID, "swap_object", offset[1]-20, offset[2], offset[3], true)
        inst.fx.components.highlightchild:SetOwner(owner)

        if owner.components.colouradder ~= nil then
            owner.components.colouradder:AttachChild(inst.fx)
        end
    else
        inst.fx:Remove()
        inst.fx = nil
        local frame = math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1

        inst.AnimState:SetFrame(frame)
        inst.fx = SpawnPrefab("spear_wathgrithr_lightning_fx")
        inst.fx.AnimState:SetFrame(frame)        
        
        inst.fx.entity:SetParent(inst.entity)

        -- For floating.
        --inst.fx.Follower:FollowSymbol(inst.GUID, "swap_staff", offset[1], offset[2], offset[3], true)
        inst.fx.components.highlightchild:SetOwner(inst)
    end
end

local function PushIdleLoop(inst)
    inst.AnimState:PushAnimation("idle_loop")
end

local function LightningCharged_OnStopFloating(inst)
    inst.fx.AnimState:SetFrame(0)
    inst:DoTaskInTime(0, PushIdleLoop) --#V2C: #HACK restore the looping anim, timing issues.
end

local CHARGE_SOUND_LOOP_NAME = "soundloop"

local function LightningCharged_OnEntityWake(inst)
    if inst:IsInLimbo() or inst:IsAsleep() then
        return
    end

    if not inst.SoundEmitter:PlayingSound(CHARGE_SOUND_LOOP_NAME) then
        inst.SoundEmitter:PlaySound("meta3/wigfrid/spear_wathrithr_lightning_charged", CHARGE_SOUND_LOOP_NAME)
    end
end

local function LightningCharged_OnEntitySleep(inst)
    inst.SoundEmitter:KillSound(CHARGE_SOUND_LOOP_NAME)
end

local function LightningSpearPostInitFn_Charged(inst)
    inst:AddTag("um_empowered")
    inst.um_empowered = true
    inst.SetFxOwner = LightningCharged_SetFxOwner
    inst.OnStopFloating = LightningCharged_OnStopFloating

    local frame = math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1

    inst.AnimState:SetFrame(frame)
    inst.fx = SpawnPrefab("spear_wathgrithr_lightning_fx")
    inst.fx.AnimState:SetFrame(frame)

    inst:ListenForEvent("floater_stopfloating", inst.OnStopFloating)

    inst:SetFxOwner(nil)
    --inst.fx.Transform:SetPosition(inst.Transform:GetWorldPosition())


    inst.OnEntityWake  = LightningCharged_OnEntityWake
    inst.OnEntitySleep = LightningCharged_OnEntitySleep

    inst:ListenForEvent("exitlimbo", inst.OnEntityWake)
    inst:ListenForEvent("enterlimbo", inst.OnEntitySleep)
end

---------------------------
local function GetMousePosition(inst)
    if inst.WINDSTAFF_CASTER and inst.WINDSTAFF_CASTER.tornadopointx then
        return Vector3(inst.WINDSTAFF_CASTER.tornadopointx,inst.WINDSTAFF_CASTER.tornadopointy,inst.WINDSTAFF_CASTER.tornadopointz)
    end
end

env.AddPrefabPostInit("tornado", function(inst)
    inst:AddTag("um_tornado_redirector")

    if not TheWorld.ismastersim then return end
end)

local _displaynamefn
local function DisplayNameFn(inst, ...)
    return inst:HasTag("um_empowered") and STRINGS.NAMES.STAFF_TORNADO_LIGHTNING or _displaynamefn and _displaynamefn(inst, ...) or nil
end

local function getspawnlocation(inst, target)
    local x1, y1, z1 = inst.Transform:GetWorldPosition()
    local x2, y2, z2 = target.Transform:GetWorldPosition()
    return x1 + .15 * (x2 - x1), 0, z1 + .15 * (z2 - z1)
end

local function CastSpell(staff, target, pos)
    for i = 1, (staff.um_empowered and 3 or 1) do
        local tornado = SpawnPrefab("tornado", staff.linked_skinname, staff.skin_id)
        tornado.WINDSTAFF_CASTER = staff.components.inventoryitem.owner
        tornado.WINDSTAFF_CASTER_ISPLAYER = tornado.WINDSTAFF_CASTER ~= nil and tornado.WINDSTAFF_CASTER:HasTag("player")
        local x,y,z = getspawnlocation(staff, target)
        tornado.Transform:SetPosition(x,y,z)
        tornado.components.knownlocations:RememberLocation("target", target:GetPosition())

        if tornado.WINDSTAFF_CASTER_ISPLAYER then
            tornado.overridepkname = tornado.WINDSTAFF_CASTER:GetDisplayName()
            tornado.overridepkpet = true
        end

        if staff.um_empowered then
            tornado.Transform:SetPosition(x+math.random(-1,1),0,z+math.random(-1,1))
            tornado:SetDuration(3*TUNING.TORNADO_LIFETIME)
            tornado.Transform:SetScale(0.8,0.8,0.8)
            tornado:DoPeriodicTask(0.5,function(tornado) 
                local pos = GetMousePosition(tornado)
                if pos then
                    tornado.components.knownlocations:RememberLocation("target", pos) 
                end
            end)
        end
    end
    staff.components.finiteuses:Use(1)
end

local _OnEquip
local function OnEquip(inst, owner, ...)
    if inst.fx then
        inst:SetFxOwner(owner)

        if owner.SoundEmitter then
            owner.SoundEmitter:PlaySound("meta3/wigfrid/spear_wathrithr_lightning_charged", CHARGE_SOUND_LOOP_NAME)
        end
    end
    return _OnEquip and _OnEquip(inst, owner, ...)
end

local _OnUnequip
local function OnUnequip(inst, owner, ...)
    if inst.fx then
        inst:SetFxOwner(nil)

        if owner.SoundEmitter then
            owner.SoundEmitter:KillSound(CHARGE_SOUND_LOOP_NAME)
        end
    end
    return _OnUnequip and _OnUnequip(inst, owner, ...)
end

local _OnSave
local function OnSave(inst, data, ...)
    data.um_empowered = inst.um_empowered
    return _OnSave and _OnSave(inst, data, ...)
end

local _OnLoad
local function OnLoad(inst, data, ...)
    if data and data.um_empowered then
        LightningSpearPostInitFn_Charged(inst)
    end
    return _OnLoad and _OnLoad(inst, data, ...)
end

env.AddPrefabPostInit("staff_tornado", function(inst)
    if not _displaynamefn then
        _displaynamefn = inst.displaynamefn
    end
    inst.displaynamefn = DisplayNameFn

    if not TheWorld.ismastersim then return end

    inst.ChargeUp = LightningSpearPostInitFn_Charged

    local spellcaster = inst.components.spellcaster
    if spellcaster then
        spellcaster.canonlyuseonlocomotors = true
        --local _spellfn = spellcaster.spell -- Need to reference the local variable tornado somehow, overriding till possible.
        spellcaster:SetSpellFn(CastSpell)
    end

    local equippable = inst.components.equippable
    if equippable then
        if not _OnEquip then
            _OnEquip = equippable.onequipfn
        end
        equippable:SetOnEquip(OnEquip)
        if not _OnUnequip then
            _OnUnequip = equippable.onunequipfn
        end
        equippable:SetOnUnequip(OnUnequip)
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