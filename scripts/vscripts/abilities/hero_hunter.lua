--Ability #1 Marine Punch
hunter_marine_punch = class({})

function hunter_marine_punch:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end


function hunter_marine_punch:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local damage = self:GetAbilityDamage()
	local stunDuration = self:GetSpecialValueFor("stun_duration")
	if caster:HasTalent("special_bonus_unique_hunter_2") then
		stunDuration = stunDuration + caster:FindTalentValue("special_bonus_unique_hunter_2")
	end
	local damageType = self:GetAbilityDamageType()

	local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = damageType
	}

	ApplyDamage(damageTable)

	target:AddNewModifier(caster, self, "modifier_stunned", { duration = stunDuration })
	caster:EmitSound("Hero_Tusk.Walrus_Punch.Hit")
end

--Ability #2 Payday
hunter_payday = class({})
LinkLuaModifier("modifier_hunter_payday", "abilities/hero_hunter", LUA_MODIFIER_MOTION_NONE)


function hunter_payday:OnUpgrade()
	if self:GetLevel() == 1 then
		local caster = self:GetCaster()
		caster:AddNewModifier(caster, self, "modifier_hunter_payday", { })
	end
end

function hunter_payday:OnOwnerSpawned()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_hunter_payday", { })
end

modifier_hunter_payday = class({})

function modifier_hunter_payday:IsPurgable()
	return false
end

function modifier_hunter_payday:OnCreated()
	self:StartIntervalThink(1)
end

function modifier_hunter_payday:OnIntervalThink()
	local caster = self:GetParent()
	local ability = self:GetAbility()
	if ability:IsCooldownReady() then
		local goldBonus = ability:GetSpecialValueFor("gold_interest")
		if caster:HasTalent("special_bonus_unique_hunter_1") then
			goldBonus = goldBonus + caster:FindTalentValue("special_bonus_unique_hunter_1")
		end
		local currentGold = caster:GetGold()
		local goldGiven = math.floor(currentGold * goldBonus * 0.01)
		caster:ModifyGold(goldGiven, true, 0)
		ability:StartCooldown( ability:GetCooldown( ability:GetLevel() ) )
	end

end

--Ability #3 Retardation
hunter_retardation = class({})
LinkLuaModifier("modifier_hunter_retardation", "abilities/hero_hunter", LUA_MODIFIER_MOTION_NONE)



function hunter_retardation:OnUpgrade()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_hunter_retardation", {})
end

function hunter_retardation:OnOwnerSpawned()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_hunter_retardation", {})
end

modifier_hunter_retardation = class({})

function modifier_hunter_retardation:IsPurgable()
	return false
end

function modifier_hunter_retardation:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EVASION_CONSTANT
	}
	return funcs
end

function modifier_hunter_retardation:GetModifierEvasion_Constant()
	local caster = self:GetParent()
	local ability = caster:GetAbilityByIndex(2)
	return ability:GetSpecialValueFor("evasion")
end
--Ability #4 Motorcross Star
hunter_motocross = class({})
LinkLuaModifier("modifier_hunter_motocross", "abilities/hero_hunter", LUA_MODIFIER_MOTION_NONE)

function hunter_motocross:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	if caster:HasTalent("special_bonus_unique_hunter_3") then
		duration = duration + caster:FindTalentValue("special_bonus_unique_hunter_3")
	end
	caster:AddNewModifier(caster, self, "modifier_hunter_motocross", { duration = duration})
	print(self:GetAbilityIndex())
end

modifier_hunter_motocross = class({})

modifier_hunter_motocross.fx = ""

function modifier_hunter_motocross:OnCreated()
	local caster = self:GetCaster()
	--modifier_hunter_motocross.fx = ParticleManager:CreateParticle("particles/items_fx/black_king_bar_avatar.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	--SetParticleControl(modifier_hunter_motocross.fx, 0, caster:GetAbsOrigin())
end

function modifier_hunter_motocross:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
	}
	return funcs
end

function modifier_hunter_motocross:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true
	}
	return state
end

function modifier_hunter_motocross:GetModifierMoveSpeed_Absolute()
	return self:GetAbility():GetSpecialValueFor("movement_speed")
end

function modifier_hunter_motocross:GetModifierPercentageCooldown()
	return self:GetAbility():GetSpecialValueFor("cooldown_reduction")
end

function modifier_hunter_motocross:OnDestroy()
	local caster = self:GetParent()
	local payday = caster:GetAbilityByIndex(1)
	payday:EndCooldown()
	--ParticleManager:DestroyParticle(modifier_hunter_motocross.fx, true)
	--ParticleManager:ReleaseParticleIndex(modifier_hunter_motocross.fx)
end

--Ability #5 Backflip
hunter_backflip = class({})


function hunter_backflip:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local damageType = DAMAGE_TYPE_MAGICAL

	local dust = ParticleManager:CreateParticle(dust_particle, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(dust, 0, caster:GetAbsOrigin())

	enemies = FindUnitsInRadius(
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

		local damageTable = {
			victim = enemy,
			attacker = caster,
			damage = damage,
			damage_type = damageType
		}

	end
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