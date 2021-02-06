--Ability #1 Smoke Cloud
johnny_smoke = class({})
LinkLuaModifier("modifier_johnny_smoke", "abilities/hero_johnny", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_johnny_smoke_thinker", "abilities/hero_johnny", LUA_MODIFIER_MOTION_NONE)

function johnny_smoke:OnSpellStart()
	local caster = self:GetCaster()
	local location = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")

	CreateModifierThinker(caster, self, "modifier_johnny_smoke_thinker", { duration = self:GetSpecialValueFor("area_duration")}, location, caster:GetTeamNumber(), false)

	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		location,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _,enemy in pairs(enemies) do

		enemy:AddNewModifier(caster, self, "modifier_johnny_smoke", { duration = self:GetSpecialValueFor("debuff_duration")})

	end
end

modifier_johnny_smoke = class({})

function modifier_johnny_smoke:OnCreated()
	self.tick = self:GetAbility():GetSpecialValueFor("tick")
	self:StartIntervalThink(self.tick)
end

function modifier_johnny_smoke:OnIntervalThink()
	local target = self:GetParent()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local damage = ability:GetAbilityDamage()
	local damageType = ability:GetAbilityDamageType()
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = damageType
	}

	ApplyDamage(damageTable)
end

modifier_johnny_smoke_thinker = class({})

function modifier_johnny_smoke_thinker:OnCreated(table)
    EmitSoundOn("Hero_Riki.Smoke_Screen", self:GetParent())

    local radius = self:GetAbility():GetSpecialValueFor("radius")
    self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_smokebomb.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(self.nfx, 0, self:GetAbility():GetCursorPosition())
    ParticleManager:SetParticleControl(self.nfx, 1, Vector(radius, 0, radius))
    self:AddParticle(self.nfx, false, false, 0, false, false)
    self:StartIntervalThink(1.0)
end

function modifier_johnny_smoke_thinker:OnIntervalThink()
	local caster = self:GetCaster()
	local location = self:GetAbility():GetCursorPosition()
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		location,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _,enemy in pairs(enemies) do

		enemy:AddNewModifier(caster, self, "modifier_johnny_smoke", { duration = self:GetSpecialValueFor("debuff_duration")})

	end
end

--Ability #2 AR-15
johnny_ar = class({})
LinkLuaModifier("modifier_johnny_ar", "abilities/hero_johnny", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_johnny_ar_clip", "abilities/hero_johnny", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_johnny_ar_ammo", "abilities/hero_johnny", LUA_MODIFIER_MOTION_NONE)

function johnny_ar:OnUpgrade()
	local caster = self:GetCaster()
	if self:GetLevel() == 1 then
		caster:FindAbilityByName("johnny_buy_ammo"):UpgradeAbility(true)
		caster:FindAbilityByName("johnny_reload"):UpgradeAbility(true)
		caster:AddNewModifier(caster, self, "modifier_johnny_ar_ammo", {})
		caster:AddNewModifier(caster, self, "modifier_johnny_ar_clip", {})
	end
end

function johnny_ar:OnToggle()
	local caster = self:GetCaster()
	if self:GetToggleState() then
		caster:AddNewModifier(caster, self, "modifier_johnny_ar", {})
	else
		caster:RemoveModifierByName("modifier_johnny_ar")
	end
end


modifier_johnny_ar_clip = class({})

function modifier_johnny_ar_clip:OnCreated()
	local ability = self:GetAbility()
	self:SetStackCount(ability:GetSpecialValueFor("clip_ammo"))
end

function modifier_johnny_ar_clip:RemoveOnDeath() return false end
function modifier_johnny_ar_clip:IsPurgable() return false end

modifier_johnny_ar_ammo = class({})

function modifier_johnny_ar_ammo:OnCreated()
	local ability = self:GetAbility()
	self:SetStackCount(ability:GetSpecialValueFor("max_ammo"))
end

function modifier_johnny_ar_ammo:RemoveOnDeath() return false end
function modifier_johnny_ar_ammo:IsPurgable() return false end

modifier_johnny_ar = class({})

function modifier_johnny_ar:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_START
	}
	return funcs
end

function modifier_johnny_ar:OnAttackStart(params)
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local modifier = caster:FindModifierByName("modifier_johnny_ar_clip")
	if modifier:GetStackCount() == 0 and params.attacker == caster then
		caster:Interrupt()
		ability:ToggleAbility()
		ability:SetActivated(false)
	end
end

function modifier_johnny_ar:OnAttack(params)
	local caster = self:GetCaster()
	local modifier = caster:FindModifierByName("modifier_johnny_ar_clip")
	if params.attacker == caster then
		modifier:DecrementStackCount()
	end
end

function modifier_johnny_ar:GetModifierBaseAttackTimeConstant()
	return self:GetAbility():GetSpecialValueFor("bat")
end

function modifier_johnny_ar:GetModifierBaseDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("damage_reduction")
end

--Ability #3 Buy Ammo
johnny_buy_ammo = class({})

function johnny_buy_ammo:OnSpellStart()
	local caster = self:GetCaster()
	local modifier = caster:FindModifierByName("modifier_johnny_ar_ammo")
	local maxammo = caster:FindAbilityByName("johnny_ar"):GetSpecialValueFor("max_ammo")
	local ammo = self:GetSpecialValueFor("ammo")
	local currentStacks = modifier:GetStackCount()
	modifier:SetStackCount( ammo + currentStacks)
	if modifier:GetStackCount() > maxammo then
		modifier:SetStackCount(maxammo)
	end
end

--Ability #4 Reload

johnny_reload = class({})

function johnny_reload:OnChannelFinish(bInterrupted)
	if not bInterrupted then
		local caster = self:GetCaster()
		local ability = caster:FindAbilityByName("johnny_ar")
		local clip = caster:FindModifierByName("modifier_johnny_ar_clip")
		local ammo = caster:FindModifierByName("modifier_johnny_ar_ammo")
		local clipSize = ability:GetSpecialValueFor("clip_ammo")
		local ammoNeeded = clipSize - clip:GetStackCount()
		if ammo:GetStackCount() > ammoNeeded then
			clip:SetStackCount(clipSize)
			ammo:SetStackCount(ammo:GetStackCount() - ammoNeeded)
		else
			clip:SetStackCount(clip:GetStackCount() + ammo:GetStackCount())
			ammo:SetStackCount(0)
		end
		if not ability:IsActivated() then
			ability:SetActivated(true)
		end
	end
end

--Ability #5 Snap Map
johnny_snap_map = class({})
LinkLuaModifier("modifier_johnny_snap_map", "abilities/hero_johnny", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_johnny_snap_map_discover", "abilities/hero_johnny", LUA_MODIFIER_MOTION_NONE)

function johnny_snap_map:GetIntrinsicModifierName()
	return "modifier_johnny_snap_map"
end

modifier_johnny_snap_map = class({})

function modifier_johnny_snap_map:OnCreated()
	self:StartIntervalThink(1.0)
end

function modifier_johnny_snap_map:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if ability:IsCooldownReady() then
		local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(), 
			caster:GetAbsOrigin(), 
			nil, 
			FIND_UNITS_EVERYWHERE, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO, 
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 
			FIND_ANY_ORDER, 
			false
		)
		if #enemies > 0 then

			local richestHero = nil
			for _,enemy in pairs(enemies) do
				if richestHero == nil then 
					richestHero = enemy
				else if enemy:GetGold() > richestHero:GetGold() and enemy:IsRealHero() then
					richestHero = enemy
				end
			end
			
		end
		richestHero:AddNewModifier(caster, ability, "modifier_johnny_snap_map_discover", { duration = ability:GetSpecialValueFor("duration")})
		end
		ability:StartCooldown(ability:GetCooldown(caster:GetLevel()))
	end
end

modifier_johnny_snap_map_discover = class({})

function modifier_johnny_snap_map_discover:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
	}
	return funcs
end

function modifier_johnny_snap_map_discover:GetModifierProvidesFOWVision()
	return 1
end

--Ability Ultimate: Not Invited
johnny_not_invited = class({})
LinkLuaModifier("modifier_johnny_not_invited", "abilities/hero_johnny", LUA_MODIFIER_MOTION_NONE)

function johnny_not_invited:OnSpellStart()
	local caster = self:GetCaster()
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(), 
		caster:GetAbsOrigin(), 
		nil, 
		FIND_UNITS_EVERYWHERE, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO, 
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 
		FIND_ANY_ORDER, 
		false
	)
	if #enemies > 0 then

		local richestHero = nil
		for _,enemy in pairs(enemies) do
			if richestHero == nil then 
				richestHero = enemy
			else if enemy:GetGold() > richestHero:GetGold() and enemy:IsRealHero() then
				richestHero = enemy
			end
		end
		caster:SetAbsOrigin(richestHero:GetAbsOrigin())
		FindClearSpaceForUnit(caster, richestHero:GetAbsOrigin(), true)
		caster:AddNewModifier(caster, self, "modifier_johnny_not_invited", { duration = self:GetSpecialValueFor("duration")})
	end
	end
end

modifier_johnny_not_invited = class({})

function modifier_johnny_not_invited:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_HERO_KILLED
	}
	return funcs
end

function modifier_johnny_not_invited:OnHeroKilled(params)
	local caster = self:GetParent()
	if params.attacker == caster then
		local bonusGold = self:GetAbility():GetSpecialValueFor("bonus_gold")
		caster:ModifyGold(bonusGold, true, 0)
		self:Destroy()
	end
end