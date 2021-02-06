-- Ability #1 Instagram Comment
jalen_comment = class({})
LinkLuaModifier("modifier_jalen_comment", "abilities/hero_jalen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jalen_comment_evasion", "abilities/hero_jalen", LUA_MODIFIER_MOTION_NONE)
function jalen_comment:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),
			caster:GetAbsOrigin(),
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false
		)

	for _,enemy in pairs(enemies) do

		local damage = self:GetSpecialValueFor("damage")
		local damageType = DAMAGE_TYPE_MAGICAL
		local damageTable = {
			victim = enemy,
			attacker = caster,
			damage = damage,
			damage_type = damageType
		}
		ApplyDamage(damageTable)
		enemy:Interrupt()
		enemy:AddNewModifier(caster, self, "modifier_jalen_comment", { duration = self:GetSpecialValueFor("duration")})

	end
	caster:AddNewModifier(caster, self, "modifier_jalen_comment_evasion", { duration = self:GetSpecialValueFor("duration")})
end

modifier_jalen_comment = class({})

function modifier_jalen_comment:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true
	}
	return state
end

function modifier_jalen_comment:OnCreated()
	local caster = self:GetAbility():GetCaster()
	local target = self:GetParent()

	-- Clear the force attack target
	target:SetForceAttackTarget(nil)

	-- Give the attack order if the caster is alive
	-- otherwise forces the target to sit and do nothing
	if caster:IsAlive() then
		local order = 
		{
			UnitIndex = target:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = caster:entindex()
		}

		ExecuteOrderFromTable(order)
	else
		target:Stop()
	end

	-- Set the force attack target to be the caster
	target:SetForceAttackTarget(caster)

end

function modifier_jalen_comment:OnDestroy()
	local target = self:GetParent()
	target:SetForceAttackTarget(nil)
end

modifier_jalen_comment_evasion = class({})

function modifier_jalen_comment_evasion:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EVASION_CONSTANT
	}
	return funcs
end

function modifier_jalen_comment_evasion:GetModifierEvasion_Constant()
	return self:GetAbility():GetSpecialValueFor("evasion")
end
-- Ability #2 Mcdonalds
jalen_mcdonalds = class({})
jalen_mcdonalds.nfx = ""
LinkLuaModifier("modifier_jalen_mcdonalds", "abilities/hero_jalen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jalen_mcdonalds_thinker", "abilities/hero_jalen", LUA_MODIFIER_MOTION_NONE)

function jalen_mcdonalds:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function jalen_mcdonalds:OnSpellStart()

	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")

	CreateModifierThinker(caster, self, "modifier_jalen_mcdonalds_thinker", { duration = self:GetSpecialValueFor("area_duration")}, target, caster:GetTeamNumber(), false)

	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		target,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _,enemy in pairs(enemies) do

		local damage = self:GetSpecialValueFor("damage")
		local damageType = DAMAGE_TYPE_MAGICAL
		local damageTable = {
			victim = enemy,
			attacker = caster,
			damage = damage,
			damage_type = damageType
		}

		ApplyDamage(damageTable)
		local duration = self:GetSpecialValueFor("debuff_duration")
		if caster:HasTalent("special_bonus_unique_jalen_1") then
			duration = duration + caster:FindTalentValue("special_bonus_unique_jalen_1")
		end
		enemy:AddNewModifier(caster, self, "modifier_jalen_mcdonalds", { duration = duration})

	end
	--caster:EmitSound("Hero_Alchemist.UnstableConcoction.Throw")

end

modifier_jalen_mcdonalds_thinker = class({})

function modifier_jalen_mcdonalds_thinker:OnCreated()
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	local caster = self:GetParent()
	local nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_viper/viper_nethertoxin.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControl(nFX, 0, (Vector(0, 0, 0)))
	ParticleManager:SetParticleControl(nFX, 1, (Vector(radius, 1, 1)))
	ParticleManager:SetParticleControl(nFX, 15, (Vector(25, 150, 25)))
	ParticleManager:SetParticleControl(nFX, 16, (Vector(0, 0, 0)))
	self:AddParticle(nFX, false, false, 0, false, false)
end

modifier_jalen_mcdonalds = class({})

function modifier_jalen_mcdonalds:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_jalen_mcdonalds:GetModifierMoveSpeedBonus_Percentage()
	return  -1 * self:GetAbility():GetSpecialValueFor("slow")
end


-- Ability #3 Broke
jalen_broke = class({})
LinkLuaModifier("modifier_jalen_broke", "abilities/hero_jalen", LUA_MODIFIER_MOTION_NONE)

function jalen_broke:GetIntrinsicModifierName()
	return "modifier_jalen_broke"
end

modifier_jalen_broke = class({})


function modifier_jalen_broke:OnOwnerDied()
	local caster = self:GetParent()
	local currentGold = caster:GetGold()
	caster:ResetTotalEarnedGold()
	local brokeFactor = self:GetAbility():GetSpecialValueFor("broke_factor")
	local brokeGold = math.floor(currentGold * brokeFactor * 0.01)
	caster:SpendGold(brokeGold, true, 0)
	caster:ModifyGold(brokeGold, false, 0)
end



-- Ability #4 Sweatshirt
jalen_sweatshirt = class({})
LinkLuaModifier("modifier_jalen_sweatshirt", "abilities/hero_jalen", LUA_MODIFIER_MOTION_NONE)
function jalen_sweatshirt:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_jalen_sweatshirt", { duration = self:GetSpecialValueFor("duration")})
end


modifier_jalen_sweatshirt = class({})

function modifier_jalen_sweatshirt:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_jalen_sweatshirt:GetModifierMoveSpeedBonus_Percentage()
	local caster = self:GetParent()
	if caster:HasTalent("special_bonus_unique_jalen_2") then
		return caster:FindTalentValue("special_bonus_unique_jalen_2")
	end
	return self:GetAbility():GetSpecialValueFor("movement_speed")
end

function modifier_jalen_sweatshirt:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attack_speed")
end