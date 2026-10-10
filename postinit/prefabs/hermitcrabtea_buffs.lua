local env = env
GLOBAL.setfenv(1, GLOBAL)
local UMUpvalueHacker = require("tools/um_upvaluehacker")
-----------------------------------------------------------------
local hermitcrabtea_defs = require("prefabs/hermitcrabtea_defs")
for _, data in ipairs(hermitcrabtea_defs.buffs) do
    if data.name == "moon_tree_blossom" then
        local _MoonBlossom_OnAttacked = UMUpvalueHacker.TryGetUpvalue(data.onattachedfn, "MoonBlossom_OnAttacked")
        if _MoonBlossom_OnAttacked then
            local SparkLunarOnShadow = UMUpvalueHacker.TryGetUpvalue(_MoonBlossom_OnAttacked, "SparkLunarOnShadow")
            local function AttackShadow(inst, attacker)
                if inst.components.combat:CanTarget(attacker) then
                    if not (attacker.components.health and attacker.components.health:IsDead()) and attacker.sg:HasStateTag("attack") and attacker.sg:HasState("hit") then
                        attacker.sg:GoToState("hit")
                    end
                    attacker.components.combat:GetAttacked(inst, TUNING.DSTU.HERMITCRAB_MOONTREEBLOSSOMTEA_SHADOWCREATURE_DAMAGE)
                end
            end
            local function MoonBlossom_OnAttacked(inst, data)
                local attacker, damage = data and data.attacker, data and data.original_damage
                if attacker and attacker:IsValid() and attacker:HasTag("shadowsubmissive") then
                    if SparkLunarOnShadow then SparkLunarOnShadow(inst, attacker) end
                    AttackShadow(inst, attacker)
                end
            end
            UMUpvalueHacker.SetUpvalue(data.onattachedfn, MoonBlossom_OnAttacked, "MoonBlossom_OnAttacked")
        end
    end
end