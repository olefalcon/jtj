-- Ability #1 Focus
chase_focus = class({})
LinkLuaModifier("modifier_chase_focus_debuff", "abilities/hero_chase", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chase_focus_buff", "abilities/hero_chase", LUA_MODIFIER_MOTION_NONE)
chase_focus.focus_target = nil


function chase_focus:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end

function chase_focus:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local target = self:GetCursorTarget()
	caster:AddNewModifier(caster, ability, "modifier_chase_focus_buff", { duration = self:GetSpecialValueFor("duration")})
	target:AddNewModifier(caster, ability, "modifier_chase_focus_debuff", { duration = self:GetSpecialValueFor("duration")})
	chase_focus.focus_target = target
end
modifier_chase_focus_buff = class({})

function modifier_chase_focus_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_MISS_PERCENTAGE
	}
	return funcs
end

function modifier_chase_focus_buff:CheckState()
	local state = {
		[MODIFIER_STATE_CANNOT_MISS] = true
	}
	return state
end

function modifier_chase_focus_buff:GetModifierAttackRangeBonus()
	local caster = self:GetCaster()
	local ability = caster:GetAbilityByIndex(0)
	if caster:HasTalent("special_bonus_unique_chase_1") then
		return ability:GetSpecialValueFor("bonus_attack_range") + caster:FindTalentValue("special_bonus_unique_chase_1")
	end
	return ability:GetSpecialValueFor("bonus_attack_range")
end

function modifier_chase_focus_buff:GetModifierMiss_Percentage()
	local caster = self:GetCaster()
	local ability = caster:GetAbilityByIndex(0)
	return ability:GetSpecialValueFor("miss_penalty")
end

function modifier_chase_focus_buff:OnAttackStart(params)
	if params.target ~= chase_focus.focus_target then
		local caster = self:GetParent()
		caster:RemoveModifierByName("modifier_chase_focus_buff")
	end
end

modifier_chase_focus_debuff = class({})

function modifier_chase_focus_debuff:IsDebuff()
	return true
end

function modifier_chase_focus_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
	}
	return funcs
end

function modifier_chase_focus_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = false
	}
	return state
end

function modifier_chase_focus_debuff:GetModifierProvidesFOWVision()
	return 1
end

--Ability #2 Under the Radar
chase_under_the_radar = class({})
LinkLuaModifier("modifier_chase_under_the_radar", "abilities/hero_chase", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chase_under_the_radar_debuff", "abilities/hero_chase", LUA_MODIFIER_MOTION_NONE)

function chase_under_the_radar:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_chase_under_the_radar", { duration = self:GetSpecialValueFor("duration")})
	if caster:HasTalent("special_bonus_unique_chase_3") then
		caster:Purge(false, true, true, false, false)
	end
end

modifier_chase_under_the_radar = class({})

function modifier_chase_under_the_radar:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
	return funcs
end

function modifier_chase_under_the_radar:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = true
	}
	return state
end

function modifier_chase_under_the_radar:GetModifierInvisibilityLevel()
	return 0.45
end

function modifier_chase_under_the_radar:OnAttack(params)
		local caster = self:GetParent()
		local target = params.target
	if params.attacker == caster then
		target:AddNewModifier(caster, self:GetAbility(), "modifier_chase_under_the_radar_debuff", { duration = self:GetAbility():GetSpecialValueFor("debuff_duration")})
		caster:RemoveModifierByName("modifier_chase_under_the_radar")
	end
end

function modifier_chase_under_the_radar:OnAbilityExecuted(params)
	local caster = self:GetParent()
	if params.unit == caster then
		caster:RemoveModifierByName("modifier_chase_under_the_radar")
	end
end

modifier_chase_under_the_radar_debuff = class({})

function modifier_chase_under_the_radar_debuff:IsDebuff()
	return true
end

function modifier_chase_under_the_radar_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_chase_under_the_radar_debuff:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()
	return ability:GetSpecialValueFor("debuff_slow")
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
--Ability #3 Family Time
chase_family_time = class({})
LinkLuaModifier("modifier_chase_family_time_search", "abilities/hero_chase", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chase_family_time", "abilities/hero_chase", LUA_MODIFIER_MOTION_NONE)

function chase_family_time:OnUpgrade()
	local caster = self:GetCaster()
	if self:GetLevel() == 1 then
		caster:AddNewModifier(caster, self, "modifier_chase_family_time_search", {})
	end
end

function chase_family_time:OnOwnerSpawned()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_chase_family_time_search", {})
end

modifier_chase_family_time_search = class({})

function modifier_chase_family_time_search:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_UNIT_MOVED
	}
	return funcs
end

function modifier_chase_family_time_search:GetAttributes()
	local attrs = {
		MODIFIER_ATTRIBUTE_PERMANENT
	}
	return attrs
end

function modifier_chase_family_time_search:OnUnitMoved( params )
	local caster = self:GetParent()
	local ability = self:GetAbility()
	local radius = self:GetAbility():GetSpecialValueFor("ally_search_radius")
	if params.unit:GetTeam() == caster:GetTeam() and params.unit:IsRealHero() then

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

		local allies = 0

	    for _,unit in pairs(units) do
	    	if unit:GetTeam() == caster:GetTeam() and unit ~= caster then
	    		allies = allies + 1
	    		if unit:HasModifier("modifier_chase_family_time") then
				unit:SetModifierStackCount("modifier_chase_family_time", caster, allies)
			else
				unit:AddNewModifier(caster, ability, "modifier_chase_family_time", {})
				unit:SetModifierStackCount("modifier_chase_family_time", caster, allies)
			end
	    	end
	    end


		if allies > 0 then
			if caster:HasModifier("modifier_chase_family_time") then
				caster:SetModifierStackCount("modifier_chase_family_time", caster, allies)
			else
				caster:AddNewModifier(caster, ability, "modifier_chase_family_time", {})
				caster:SetModifierStackCount("modifier_chase_family_time", caster, allies)
			end
		elseif caster:HasModifier("modifier_chase_family_time") then
			caster:RemoveModifierByName("modifier_chase_family_time")
		end
	end

end


modifier_chase_family_time = class({})

function modifier_chase_family_time:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
	return funcs
end

function modifier_chase_family_time:GetAttributes()
	local attrs = {
		MODIFIER_ATTRIBUTE_MULTIPLE
	}
	return attrs
end

function modifier_chase_family_time:GetModifierConstantHealthRegen()
	local ability = self:GetAbility()
	return ability:GetSpecialValueFor("health_regen_per_ally") * self:GetStackCount()
end

--Ability #4 Oi

chase_oi = class({})
chase_oi.attack_interval = 0
chase_oi.channel_interval = 0
function chase_oi:OnSpellStart()
	chase_oi.attack_interval = self:GetSpecialValueFor("attack_interval")
	chase_oi.channel_interval = 0

	local caster = self:GetCaster()
		local radius = self:GetSpecialValueFor("radius")
		
		enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),
			caster:GetAbsOrigin(),
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
			FIND_ANY_ORDER,
			false
		)
		local i = RandomInt(1, table.getn(enemies))

		if table.getn(enemies) > 0 then

			local target = enemies[i]

			local bullet_speed = self:GetSpecialValueFor("projectile_speed")

			-- Create the fake, visible projectile
			oi_fake_projectile = {
				Target = target,
				Source = caster,
				Ability = self,	
				EffectName = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_projectile.vpcf",
				bReplaceExisting = false,
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO,
				iMoveSpeed = bullet_speed,
				bProvidesVision = false,
				bDodgeable = true,
			}
			ProjectileManager:CreateTrackingProjectile(oi_fake_projectile)
			caster:EmitSound("Hero_Alchemist.UnstableConcoction.Throw")
			chase_oi.channel_interval = chase_oi.channel_interval - chase_oi.attack_interval
		end
end

function chase_oi:OnChannelThink( interval ) 
	chase_oi.channel_interval = chase_oi.channel_interval + interval
	if chase_oi.channel_interval > chase_oi.attack_interval then

		print("think")
		local caster = self:GetCaster()
		local radius = self:GetSpecialValueFor("radius")
		
		enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),
			caster:GetAbsOrigin(),
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE,
			FIND_ANY_ORDER,
			false
		)
		local i = RandomInt(1, table.getn(enemies))
		if table.getn(enemies) > 0 then

			local target = enemies[i]

			local bullet_speed = self:GetSpecialValueFor("projectile_speed")

			-- Create the fake, visible projectile
			oi_fake_projectile = {
				Target = target,
				Source = caster,
				Ability = self,	
				EffectName = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_projectile.vpcf",
				bReplaceExisting = false,
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO,
				iMoveSpeed = bullet_speed,
				bProvidesVision = false,
				bDodgeable = true,
			}
			ProjectileManager:CreateTrackingProjectile(oi_fake_projectile)
			caster:EmitSound("Hero_Alchemist.UnstableConcoction.Throw")
		end
		chase_oi.channel_interval = chase_oi.channel_interval - chase_oi.attack_interval
	end

end

function chase_oi:OnProjectileHit(target)
	print(dump(target))
	print("hit")
		local caster = self:GetCaster()
		local baseDamage = caster:GetBaseDamageMax()
		local crit = self:GetSpecialValueFor("attack_crit")
		if caster:HasTalent("special_bonus_unique_chase_2") then
			crit = crit + caster:FindTalentValue("special_bonus_unique_chase_2")
		end
		local damageMult = crit * 0.01
		local damageType = DAMAGE_TYPE_PHYSICAL


		local damage = damageMult * baseDamage
		print(damage)

		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = damageType
		}
		ApplyDamage( damageTable )
end