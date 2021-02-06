--Ability #1 Instant Comedy
zac_comedy = class({})

function zac_comedy:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local heal = self:GetSpecialValueFor("heal")
	local allies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NO_INVIS,
		FIND_ANY_ORDER,
		false
	)

	for _,ally in pairs(allies) do
		ally:EmitSound("DOTA_Item.Mekansm.Target")
		ParticleManager:CreateParticle("particles/items2_fx/mekanism_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally)
		ally:Heal(heal, caster)
	end
end

--Ability #2 Link
zac_link = class({})
LinkLuaModifier("modifier_zac_link", "abilities/hero_zac", LUA_MODIFIER_MOTION_NONE)
function zac_link:OnSpellStart()
	local caster = self:GetCaster()
	local range = self:GetSpecialValueFor("range")
	local target = self:GetCursorTarget()
	local duratoin = self:GetSpecialValueFor("duration")
	target:AddNewModifier(caster, self, "modifier_zac_link", { duration = duration })
end

modifier_zac_link = class({})

function modifier_zac_link:OnCreated()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	self.beamFX = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_tether.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(self.beamFX, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.beamFX, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
	self:AddParticle(self.beamFX, false, false, 0, false, false)
	self:StartIntervalThink(1)
end

function modifier_zac_link:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local range = self:GetAbility():GetSpecialValueFor("range")
	if not caster:IsAlive() then
		self:Destroy()
	end
	if CalculateDistance(caster, parent) > range then
		self:Destroy()
	end
end

function modifier_zac_link:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
	return funcs
end

function modifier_zac_link:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("health_regen")
end

zac_comeback_king = class({})

function zac_comeback_king:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local damage = self:GetAbilityDamage()
	local stunDuration = self:GetSpecialValueFor("stun_duration")
	local damageType = self:GetAbilityDamageType()
	local levelDifference = target:GetLevel() - caster:GetLevel()
	print(levelDifference)
	if levelDifference > 0 then
		damage = damage * levelDifference
		stunDuration = stunDuration * levelDifference
	end
	target:AddNewModifier(caster, self, "modifier_stunned", { duration = stunDuration})
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = damageType
	}
	ApplyDamage(damageTable)
end

--Ability #4 Hunnies
zac_hunnies = class({})

function zac_hunnies:OnSpellStart()
	local caster = self:GetCaster()
	local hunnie1 = CreateUnitByName("npc_dota_creature_hunnies", caster:GetAbsOrigin(), true, caster, nil, caster:GetTeamNumber())
	hunnie1:SetControllableByPlayer(caster:GetPlayerID(), true)
	hunnie1:FindAbilityByName("zac_affection"):SetLevel(self:GetLevel())
	hunnie1:AddNewModifier(caster, self, "modifier_kill", { duration = self:GetSpecialValueFor("duration")})
	local hunnie2 = CreateUnitByName("npc_dota_creature_hunnies", caster:GetAbsOrigin(), true, caster, nil, caster:GetTeamNumber())
	hunnie2:SetControllableByPlayer(caster:GetPlayerID(), true)
	hunnie2:FindAbilityByName("zac_affection"):SetLevel(self:GetLevel())
	hunnie2:AddNewModifier(caster, self, "modifier_kill", { duration = self:GetSpecialValueFor("duration")})
	local hunnie3 = CreateUnitByName("npc_dota_creature_hunnies", caster:GetAbsOrigin(), true, caster, nil, caster:GetTeamNumber())
	hunnie3:SetControllableByPlayer(caster:GetPlayerID(), true)
	hunnie3:FindAbilityByName("zac_affection"):SetLevel(self:GetLevel())
	hunnie3:AddNewModifier(caster, self, "modifier_kill", { duration = self:GetSpecialValueFor("duration")})
end

--Hunnies Ability #1 Affection
zac_affection = class({})
LinkLuaModifier("modifier_zac_affection", "abilities/hero_zac", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zac_affection_handler", "abilities/hero_zac", LUA_MODIFIER_MOTION_NONE)

function zac_affection:GetIntrinsicModifierName()
	return "modifier_zac_affection_handler"
end

modifier_zac_affection_handler = class({})
function modifier_zac_affection_handler:IsHidden() return true end
function modifier_zac_affection_handler:OnCreated()
	self:StartIntervalThink(1)
end

function modifier_zac_affection_handler:OnIntervalThink()
	local caster = self:GetCaster()
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	local allies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _,ally in pairs(allies) do
		ally:AddNewModifier(caster, self:GetAbility(), "modifier_zac_affection", { duration = 1 })
	end
end

modifier_zac_affection = class({})

function modifier_zac_affection:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
	return funcs
end

function modifier_zac_affection:GetAttributes()
	local attrs = {
		MODIFIER_ATTRIBUTE_MULTIPLE
	}
	return attrs
end

function modifier_zac_affection:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("health_regen")
end