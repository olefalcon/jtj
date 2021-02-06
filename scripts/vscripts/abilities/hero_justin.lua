--#Ability 1 Grind
justin_grind = class({})
LinkLuaModifier("modifier_justin_grind_attributes", "abilities/hero_justin", LUA_MODIFIER_MOTION_NONE)


function justin_grind:GetCooldown(iLevel)
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_justin_2") then
		return self.BaseClass.GetCooldown(self, iLevel) - caster:FindTalentValue("special_bonus_unique_justin_2")
	end
	
	return self.BaseClass.GetCooldown(self, iLevel)
end

function justin_grind:OnUpgrade()
	local caster = self:GetCaster()
	if self:GetLevel() == 1 then
		caster:AddNewModifier(caster, self, "modifier_justin_grind_attributes", {})
		caster:SetModifierStackCount("modifier_justin_grind_attributes", caster, 0)
	end
end

function justin_grind:OnChannelFinish( interrupt )
	if not interrupt then
		local caster = self:GetCaster()
		local current_stack = caster:GetModifierStackCount("modifier_justin_grind_attributes", caster)
		caster:SetModifierStackCount("modifier_justin_grind_attributes", caster, current_stack + self:GetSpecialValueFor("tuned_attributes"))
	end
end

modifier_justin_grind_attributes = class({})

function modifier_justin_grind_attributes:RemoveOnDeath()
	return false
end

function modifier_justin_grind_attributes:GetAttributes()
	local attrs = {
		MODIFIER_ATTRIBUTE_PERMANENT,
		MODIFIER_ATTRIBUTE_MULTIPLE
	}
	return attrs
end



--#Ability 2 Coca Cola Break
justin_coca_cola = class({})
LinkLuaModifier("modifier_justin_coca_cola", "abilities/hero_justin", LUA_MODIFIER_MOTION_NONE)

function justin_coca_cola:OnSpellStart()

	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_justin_coca_cola", { duration = self:GetSpecialValueFor("duration")})
	self:GetCaster():EmitSound("DOTA_Item.HealingSalve.Activate")

end

modifier_justin_coca_cola = class({})


function modifier_justin_coca_cola:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function modifier_justin_coca_cola:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("health_regen")
end

function modifier_justin_coca_cola:GetModifierConstantManaRegen()
	local caster = self:GetParent()
	if caster:HasTalent("special_bonus_unique_justin_1") then
		return self:GetAbility():GetSpecialValueFor("mana_regen") + caster:FindTalentValue("special_bonus_unique_justin_1")
	else
		return self:GetAbility():GetSpecialValueFor("mana_regen")
	end
end

function modifier_justin_coca_cola:OnTakeDamage(params)
	local caster = self:GetParent()
	if params.unit == caster and params.attacker:IsRealHero() then
		caster:RemoveModifierByName("modifier_justin_coca_cola")
	end
end

--#Ability 3 Always Moving On
justin_always_moving_on = class({})
LinkLuaModifier("modifier_justin_always_moving_on", "abilities/hero_justin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_justin_always_moving_on_bonus", "abilities/hero_justin",LUA_MODIFIER_MOTION_NONE)

local lastTarget = nil

function justin_always_moving_on:OnUpgrade()
	local caster = self:GetCaster()
	if self:GetLevel() == 1 then
		caster:AddNewModifier(caster, self, "modifier_justin_always_moving_on", {})
	end
end

function justin_always_moving_on:OnOwnerSpawned()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_justin_always_moving_on", {})
end
modifier_justin_always_moving_on = class({})

function modifier_justin_always_moving_on:IsPurgable()
	return false
end

function modifier_justin_always_moving_on:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK
	}
	return funcs
end

function modifier_justin_always_moving_on:GetAttributes()
	local attrs = {
		MODIFIER_ATTRIBUTE_PERMANENT
	}
	return attrs
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function modifier_justin_always_moving_on:OnAttack(params)

	local caster = self:GetParent()
	local ability = self:GetAbility()
	local duration = ability:GetSpecialValueFor("duration")


	if params.attacker == caster then


			print(dump(params))
		if not lastTargets then
			print("1")
			lastTarget = params.target
		end

		local isNewTarget = true

		if lastTarget == params.target then
			isNewTarget = false
		end

		if isNewTarget then
			local modifier = caster:FindModifierByName("modifier_justin_always_moving_on_bonus")
			local current_stack = caster:GetModifierStackCount("modifier_justin_always_moving_on_bonus", caster)
			print("2")
			if not modifier then
				caster:AddNewModifier(caster, ability, "modifier_justin_always_moving_on_bonus", { duration = duration })
				caster:SetModifierStackCount("modifier_justin_always_moving_on_bonus", caster, 1)
				caster:FindModifierByName("modifier_justin_always_moving_on_bonus"):ForceRefresh()
			elseif current_stack < ability:GetSpecialValueFor("max_stacks") then
				caster:SetModifierStackCount("modifier_justin_always_moving_on_bonus", caster, current_stack + 1)
				modifier:ForceRefresh()
				modifier:SetDuration(duration, true)
			else
				modifier:SetDuration(duration, true)
			end
			lastTarget = params.target
		end

	end
end

modifier_justin_always_moving_on_bonus = class({})

function modifier_justin_always_moving_on_bonus:OnDestroy()
	lastTargets = nil
end

function modifier_justin_always_moving_on_bonus:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_justin_always_moving_on_bonus:GetAttributes()
	local attrs = {
		MODIFIER_ATTRIBUTE_MULTIPLE
	}
	return attrs
end


function modifier_justin_always_moving_on_bonus:GetModifierPreAttack_BonusDamage()
	local caster = self:GetParent()
	local ability = caster:GetAbilityByIndex(2)
	if caster:GetModifierStackCount("modifier_justin_always_moving_on_bonus", caster) > 0 then
		return ability:GetSpecialValueFor("bonus_damage") * caster:GetModifierStackCount("modifier_justin_always_moving_on_bonus", caster)
	end
end

function modifier_justin_always_moving_on_bonus:GetModifierMoveSpeedBonus_Constant()
	local caster = self:GetParent()
	local ability = caster:GetAbilityByIndex(2)
	if caster:GetModifierStackCount("modifier_justin_always_moving_on_bonus", caster) > 0 then
		return ability:GetSpecialValueFor("bonus_movespeed") * caster:GetModifierStackCount("modifier_justin_always_moving_on_bonus", caster)
	end
end

--#Ability 4 Not Tuning Down
justin_not_tuning_down = class({})
LinkLuaModifier("modifier_justin_tuned_up", "abilities/hero_justin", LUA_MODIFIER_MOTION_NONE)

function justin_not_tuning_down:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	if caster:HasTalent("special_bonus_unique_justin_3") then
		duration = duration + caster:FindTalentValue("special_bonus_unique_justin_3")
	end
	caster:AddNewModifier(caster, self, "modifier_justin_tuned_up", { duration = duration })
end

modifier_justin_tuned_up = class({})

function modifier_justin_tuned_up:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
	return funcs
end

function modifier_justin_tuned_up:GetModifierBonusStats_Strength()
	local caster = self:GetParent()
	local ability = self:GetAbility()
	local stacks = caster:GetModifierStackCount("modifier_justin_grind_attributes", caster)
	return stacks;
end

function modifier_justin_tuned_up:GetModifierBonusStats_Agility()
	local caster = self:GetParent()
	local ability = self:GetAbility()
	local stacks = caster:GetModifierStackCount("modifier_justin_grind_attributes", caster)
	return stacks;
end

function modifier_justin_tuned_up:GetModifierBonusStats_Intellect()
	local caster = self:GetParent()
	local ability = self:GetAbility()
	local stacks = caster:GetModifierStackCount("modifier_justin_grind_attributes", caster)
	return stacks;
end