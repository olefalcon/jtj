kaydon_eat_rich = class({})

function kaydon_eat_rich:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	--Stun Target
	target:AddNewModifier(caster, self, "modifier_stunned", {})
end

function kaydon_eat_rich:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	--Remove Stun
	target:RemoveModifierByNameAndCaster("modifier_stunned", caster)

	if not bInterrupted then
		--Handle damage based on target's current gold
		local goldDamageMult = self:GetSpecialValueFor("gold_damage")
		if caster:HasTalent("special_bonus_unique_kaydon_2") then
			goldDamageMult = goldDamageMult + caster:FindTalentValue("special_bonus_unique_kaydon_2")
		end
		local damage = target:GetGold() * goldDamageMult
		local damageType = self:GetAbilityDamageType()
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = damageType
		}
		ApplyDamage( damageTable )
	end
end

kaydon_citizens = class({})
LinkLuaModifier("modifier_kaydon_citizens", "abilities/hero_kaydon", LUA_MODIFIER_MOTION_NONE)

function kaydon_citizens:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("buff_duration")

	local allies = FindUnitsInRadius(
		caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
	)
	for _,ally in pairs(allies) do
		ally:AddNewModifier(caster, self, "modifier_kaydon_citizens", {duration=duration})
	end
end

modifier_kaydon_citizens = class({})

function modifier_kaydon_citizens:IsDebuff() return false end
function modifier_kaydon_citizens:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end
function modifier_kaydon_citizens:GetModifierMoveSpeedBonus_Percentage()
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_kaydon_1") then
		return self:GetAbility():GetSpecialValueFor("move_bonus") + caster:FindTalentValue("special_bonus_unique_kaydon_1")
	end
	return self:GetAbility():GetSpecialValueFor("move_bonus")
end
function modifier_kaydon_citizens:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("armor_bonus")
end
kaydon_healthcare = class({})
LinkLuaModifier("modifier_kaydon_healthcare", "abilities/hero_kaydon", LUA_MODIFIER_MOTION_NONE)

function kaydon_healthcare:OnUpgrade()
	local caster = self:GetCaster()
	if caster:IsAlive() then
		local heroes = HeroList:GetAllHeroes()
		for _,hero in pairs(heroes) do
			if hero:GetTeam() == caster:GetTeam() then
				hero:AddNewModifier(caster, self, "modifier_kaydon_healthcare", {})
			end
		end
	end
end

function kaydon_healthcare:OnOwnerSpawned()
	local caster = self:GetCaster()
	local heroes = HeroList:GetAllHeroes()
	for _,hero in pairs(heroes) do
		if hero:GetTeam() == caster:GetTeam() then
			hero:AddNewModifier(caster, self, "modifier_kaydon_healthcare", {})
		end
	end
end

function kaydon_healthcare:OnOwnerDied()
	local heroes = HeroList:GetAllHeroes()
	for _,hero in pairs(heroes) do
		if hero:GetTeam() == caster:GetTeam() then
			hero:RemoveModifierByName("modifier_kaydon_healthcare")
		end
	end
end

modifier_kaydon_healthcare = class({})

function modifier_kaydon_healthcare:IsPurgable() return false end
function modifier_kaydon_healthcare:RemoveOnDeath() return false end
function modifier_kaydon_healthcare:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
	return funcs
end

function modifier_kaydon_healthcare:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("health_regen")
end

kaydon_final_step = class({})

function kaydon_final_step:GetAbilityDamageType()
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_kaydon_4") then
		return DAMAGE_TYPE_PURE
	else
		return DAMAGE_TYPE_MAGICAL
	end
end

function kaydon_final_step:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local dirVector = (target - caster:GetAbsOrigin())
	local dir = dirVector/dirVector:Length()
	local endLoc = caster:GetAbsOrigin() + dir * self:GetSpecialValueFor("dash_distance")
	local width = self:GetSpecialValueFor("dash_width")
	local enemies = FindUnitsInLine(
		caster:GetTeam(),
		caster:GetAbsOrigin(),
		endLoc,
		nil,
		width,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	)
	local iPtclID = ParticleManager:CreateParticle('particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step.vpcf', PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(iPtclID, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(iPtclID, 1, endLoc)
	FindClearSpaceForUnit(caster, endLoc, true)
	local goldStacks = 0
	local damage = self:GetAbilityDamage()
	local damageType = self:GetAbilityDamageType()
	for _,enemy in pairs(enemies) do
		local damageTable = {
			victim = enemy,
			attacker = caster,
			damage = damage,
			damage_type = damageType
		}
		ApplyDamage(damageTable)
		if not enemy:IsAlive() then
			goldStacks = goldStacks + 1
		end
	end
	local bonusGold = self:GetSpecialValueFor("bonus_gold")
	if caster:HasTalent("special_bonus_unique_kaydon_3") then
		bonusGold = bonusGold + caster:FindTalentValue("special_bonus_unique_kaydon_3")
	end
	while goldStacks>0 do
		heroes = HeroList:GetAllHeroes()
		for _,hero in pairs(heroes) do
			if hero:GetTeam() == caster:GetTeam() then
				hero:ModifyGold(bonusGold, false, 0)
			end
		end
		goldStacks = goldStacks-1
	end
	local iPtclID = ParticleManager:CreateParticle('particles/units/heroes/hero_void_spirit/void_spirit_attack_travel_strike_blur.vpcf', PATTACH_ABSORIGIN, hCaster)
	ParticleManager:SetParticleControl(iPtclID, 0, caster:GetAbsOrigin())
end
