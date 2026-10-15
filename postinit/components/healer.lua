local env = env
GLOBAL.setfenv(1, GLOBAL)

-- This postinit exists to support the Walter Veterans Skull Curse -- not anymore, yoink.
env.AddComponentPostInit("healer", function(self)
	local _Heal = self.Heal
	function self:Heal(target, doer, ...)
		--[[if target.walter_vetcurse and target.components.debuffable then
			for i, v in pairs(target.components.debuffable.debuffs) do
				if v and v.inst.prefab == "healthregenbuff_vetcurse_walter_curse" then
					v.inst:Remove()
				end
			end
		end]]
        local delta = target.um_wormwood_vetcurse and not target:HasTag("ignores_healthregen") and target.components.health
            and self.health * (doer.components.efficientuser and doer.components.efficientuser:GetMultiplier(ACTIONS.HEAL) or 1)
        if delta and delta > 3 then
            if self.canhealfn then
                local valid, reason = self.canhealfn(self.inst, target, doer)

                if not valid then
                    return false, reason
                end
            end

            target:AddDebuff("healthregenbuff_vetcurse_"..self.inst.prefab, "healthregenbuff_vetcurse", {duration = delta * .1})

            if self.onhealfn then
                self.onhealfn(self.inst, target, doer)
            end

            if self.inst.components.stackable and self.inst.components.stackable:IsStack() then
                self.inst.components.stackable:Get():Remove()
            else
                self.inst:Remove()
            end
            return true
        end
		return _Heal(self, target, doer, ...)
	end
end)