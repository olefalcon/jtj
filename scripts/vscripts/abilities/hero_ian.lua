--Ability #1 Tennis Swing
ian_tennis = class({})

function ian_tennis:GetCooldown(iLevel)
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_ian_1") then
		return self.BaseClass.GetCooldown(self, iLevel) - caster:FindTalentValue("special_bonus_unique_ian_1")
	else
		return self.BaseClass.GetCooldown(self, iLevel)
	end
end

function ian_tennis:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local damage = self:GetSpecialValueFor("damage")
	local damageType = DAMAGE_TYPE_MAGICAL
	local stunDuration = self:GetSpecialValueFor("stun_duration")

	target:AddNewModifier(caster, self, "modifier_stunned", { duration = stunDuration})

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = damageType
	}
	ApplyDamage(damageTable)
end

--Ability #2 Customer Service
ian_customer_service = class({})
LinkLuaModifier("modifier_ian_customer_service", "abilities/hero_ian", LUA_MODIFIER_MOTION_NONE)

function ian_customer_service:GetCastRange(vLocation, hTarget)
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_ian_2") then
		return 10000
	else
		return self.BaseClass.GetCastRange(self, Vector(0,0,0), nil)
	end
end

function ian_customer_service:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local healDuration = self:GetSpecialValueFor("heal_duration")

	target:AddNewModifier(caster, self, "modifier_ian_customer_service", { duration = healDuration})
end

modifier_ian_customer_service = class({})

function modifier_ian_customer_service:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
	return funcs
end

function modifier_ian_customer_service:GetModifierConstantHealthRegen()
	local totalHeal = self:GetAbility():GetSpecialValueFor("total_heal")
	local healDuration = self:GetAbility():GetSpecialValueFor("heal_duration")
	return (totalHeal / healDuration)
end
--Ability #3 2skinny productions
ian_2skinny = class({})

function ian_2skinny:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local bullet_speed = self:GetSpecialValueFor("speed")
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NO_INVIS,
		FIND_ANY_ORDER,
		false
	)

	for _,enemy in pairs(enemies) do
		info = {
			Target = enemy,
			Source = caster,
			Ability = self,	
			EffectName = "particles/units/heroes/hero_queenofpain/queen_scream_of_pain.vpcf",
			bReplaceExisting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			iMoveSpeed = bullet_speed,
			bProvidesVision = false,
			bDodgeable = true,
		}
		ProjectileManager:CreateTrackingProjectile(info)
	end
end

function ian_2skinny:OnProjectileHit(hTarget)
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage")

	if caster:HasTalent("special_bonus_unique_ian_4") then
		damage = damage + caster:FindTalentValue("special_bonus_unique_ian_4")
	end
	local damageType = DAMAGE_TYPE_MAGICAL
	local damageTable = {
		victim = hTarget,
		attacker = caster,
		damage = damage,
		damage_type = damageType
	}
	ApplyDamage(damageTable)
end
--Ability #4 Wifi Restrictions
ian_wifi = class({})
LinkLuaModifier("modifier_ian_wifi", "abilities/hero_ian", LUA_MODIFIER_MOTION_NONE)

function ian_wifi:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local banishDuration = self:GetSpecialValueFor("banish_duration")

	caster:AddNewModifier(caster, self, "modifier_ian_wifi", { duration = banishDuration})
	target:AddNewModifier(caster, self, "modifier_ian_wifi", { duration = banishDuration})
end

modifier_ian_wifi = class({})

function modifier_ian_wifi:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true
	}
	return state
end

function modifier_ian_wifi:GetEffectName()
	return "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_prison.vpcf"
end