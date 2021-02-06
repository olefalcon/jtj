-- CJ the Siege Wagon
-- Strength Character

--Ability #1 EAT UP
cj_eat_up = class({})
LinkLuaModifier("modifier_cj_eat_up", "abilities/hero_cj", LUA_MODIFIER_MOTION_NONE)
function cj_eat_up:OnSpellStart()
	local caster = self:GetCaster();

	caster:AddNewModifier(caster, self, "modifier_cj_eat_up", { duration = self:GetSpecialValueFor("duration")});
end

modifier_cj_eat_up = class({})

function modifier_cj_eat_up:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
	}
	return funcs
end

function modifier_cj_eat_up:GetModifierBonusStats_Strength(params)
	return self:GetAbility():GetSpecialValueFor("strength_bonus")
end

function modifier_cj_eat_up:GetModifierConstantHealthRegen(params)
	return self:GetAbility():GetSpecialValueFor("hp_regen")
end

--Ability #2 HAM SANDWICH
cj_ham_sandwich = class({})
LinkLuaModifier("modifier_cj_ham_sandwich", "abilities/hero_cj", LUA_MODIFIER_MOTION_NONE)
cj_ham_sandwich.damageTaken = 0;
cj_ham_sandwich.lastAttacker = 0;

function cj_ham_sandwich:GetCastRange()
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_cj_3") then
		return self:GetSpecialValueFor("cast_range") + caster:FindTalentValue("special_bonus_unique_cj_3")
	else
		return self:GetSpecialValueFor("cast_range")
	end
end

function cj_ham_sandwich:OnSpellStart()
	cj_ham_sandwich.damageTaken = 0;
	local caster = self:GetCaster();
	local target = self:GetCursorTarget();

	target:AddNewModifier(caster, self, "modifier_cj_ham_sandwich", { duration = self:GetSpecialValueFor("damage_delay") })
end

modifier_cj_ham_sandwich = class({})

function modifier_cj_ham_sandwich:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function modifier_cj_ham_sandwich:GetModifierIncomingDamage_Percentage(params)
	return -100
end

function modifier_cj_ham_sandwich:OnTakeDamage(params)
	if params.unit == caster then
		cj_ham_sandwich.damageTaken = cj_ham_sandwich.damageTaken + params.original_damage;
		cj_ham_sandwich.lastAttacker = params.attacker;
	end
end

function modifier_cj_ham_sandwich:OnDestroy()
	local caster = self:GetAbility():GetCaster()
	local target = self:GetParent()

	if caster:HasTalent("special_bonus_unique_cj_1") then
		print("talent")
		cj_ham_sandwich.damageTaken = cj_ham_sandwich.damageTaken * 0.8
	end

	if cj_ham_sandwich.damageTaken > target:GetHealth() then
		target:SetHealth(1)
	else
		target:SetHealth(target:GetHealth() - cj_ham_sandwich.damageTaken);
	end
end




--Ability #3 I Got This
cj_i_got_this = class({})
LinkLuaModifier("modifier_cj_i_got_this", "abilities/hero_cj", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cj_i_got_this_bonus", "abilities/hero_cj", LUA_MODIFIER_MOTION_NONE)


function cj_i_got_this:GetIntrinsicModifierName()
	return "modifier_cj_i_got_this"
end

modifier_cj_i_got_this = class({})


function modifier_cj_i_got_this:IsHidden()
	return true
end

function modifier_cj_i_got_this:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_UNIT_MOVED
	}
	return funcs
end


function modifier_cj_i_got_this:OnUnitMoved( params )

		local caster = self:GetParent()
		if params.unit == caster then

		local ability = self:GetAbility()
			
			local radius = ability:GetSpecialValueFor("ally_search_radius")
			
			units = FindUnitsInRadius(
					caster:GetTeamNumber(),
			        caster:GetAbsOrigin(),
			        nil,
			        radius,
			        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			        DOTA_UNIT_TARGET_HERO,
			        DOTA_UNIT_TARGET_FLAG_NO_INVIS,
			        FIND_ANY_ORDER,
			        false
			)

			local caster_is_alone = true

		    for _,unit in pairs(units) do
		    	if unit:GetTeam() == caster:GetTeam() and unit ~= caster then
		    		caster_is_alone = false
		    	end
		    end

		    if caster_is_alone and not caster:HasModifier("modifier_cj_i_got_this_bonus") then
		    	caster:AddNewModifier(caster, ability, "modifier_cj_i_got_this_bonus", {})
		    elseif not caster_is_alone and caster:HasModifier("modifier_cj_i_got_this_bonus") then
		    	caster:RemoveModifierByName("modifier_cj_i_got_this_bonus")
		    end
		end
end

modifier_cj_i_got_this_bonus = class({})


function modifier_cj_i_got_this_bonus:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE
	}
	return funcs
end

function modifier_cj_i_got_this_bonus:GetModifierBaseAttack_BonusDamage()
	local caster = self:GetParent()
	local ability = caster:GetAbilityByIndex(2)
	local damage = ability:GetSpecialValueFor("bonus_damage")

	if caster:HasTalent("special_bonus_unique_cj_2") then
		return damage + caster:FindTalentValue("special_bonus_unique_cj_2")
	else
		return damage
	end
end



--Ability #4 Unstoppable Rage
cj_unstoppable_rage = class({})
LinkLuaModifier("modifier_cj_unstoppable_rage", "abilities/hero_cj", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cj_unstoppable_rage_stacks", "abilities/hero_cj", LUA_MODIFIER_MOTION_NONE)

function cj_unstoppable_rage:GetCooldown(iLevel)
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_cj_4") then
		return self.BaseClass.GetCooldown(self, iLevel) - caster:FindTalentValue("special_bonus_unique_cj_4")
	else
		return self.BaseClass.GetCooldown(self, iLevel)
	end
end

function cj_unstoppable_rage:OnUpgrade()
	local caster = self:GetCaster()
	if self:GetLevel() == 1 then
		caster:AddNewModifier(caster, self, "modifier_cj_unstoppable_rage_stacks", {})
	end
end

function cj_unstoppable_rage:OnOwnerSpawned()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_cj_unstoppable_rage_stacks", {})
end



modifier_cj_unstoppable_rage_stacks = class({})

function modifier_cj_unstoppable_rage_stacks:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

function modifier_cj_unstoppable_rage_stacks:GetAttributes()
	local attrs = {
		MODIFIER_ATTRIBUTE_MULTIPLE,
		MODIFIER_ATTRIBUTE_PERMANENT
	}
	return attrs
end


function modifier_cj_unstoppable_rage_stacks:OnTakeDamage(params)

	local caster = self:GetParent()
	local modifier = "modifier_cj_unstoppable_rage_stacks"
	local ability = self:GetAbility()

	if params.unit == caster and params.attacker:IsHero() then

		local current_stack = caster:GetModifierStackCount( modifier, caster )
		local required_stacks = ability:GetSpecialValueFor("required_stacks")
		if caster:HasTalent("special_bonus_unique_cj_5") then
			required_stacks = required_stacks - caster:FindTalentValue("special_bonus_unique_cj_5")
		end
		if not current_stack then
			current_stack = 0;
		elseif current_stack <  required_stacks then
			caster:SetModifierStackCount( modifier, caster, current_stack + 1 )
		end
		print(caster:GetModifierStackCount(modifier, caster))
		print(dump(params))

	end

end


function cj_unstoppable_rage:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local required_stacks = self:GetSpecialValueFor("required_stacks")
	if caster:HasTalent("special_bonus_unique_cj_5") then
			required_stacks = required_stacks - caster:FindTalentValue("special_bonus_unique_cj_5")
		end
	local current_stack = caster:GetModifierStackCount("modifier_cj_unstoppable_rage_stacks", caster)


	if caster:GetModifierStackCount("modifier_cj_unstoppable_rage_stacks", caster) < required_stacks then
		ability:RefundManaCost()
		ability:EndCooldown()
	else
		caster:SetModifierStackCount("modifier_cj_unstoppable_rage_stacks", caster, 0)
		caster:AddNewModifier(caster, self, "modifier_cj_unstoppable_rage", { duration = self:GetSpecialValueFor("duration")})
		EmitSoundOn("Hero_Alchemist.ChemicalRage.Cast", caster)
	end
end

modifier_cj_unstoppable_rage = class({})

function modifier_cj_unstoppable_rage:OnCreated()
	local gFX = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_spell_gods_strength_ambient.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(gFX, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_head", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(gFX, false, false, 0, false, false)
end

function modifier_cj_unstoppable_rage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
	}
	return funcs
end

function modifier_cj_unstoppable_rage:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("incoming_damage_reduction")
end

function modifier_cj_unstoppable_rage:GetModifierTotalDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("outgoing_damage_amplification")
end

