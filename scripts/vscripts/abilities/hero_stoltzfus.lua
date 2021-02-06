--Ability #1 Intelligence Shots
stoltzfus_insults = class({})

function stoltzfus_insults:OnSpellStart()
	local caster = self:GetCaster()
    local ability = self
    local target = self:GetCursorTarget()
    local particle_projectile = "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_arcane_orb.vpcf"
    local sound_cast = "Hero_ObsidianDestroyer.ArcaneOrb"

    -- Ability specials
    local projectile_speed = ability:GetSpecialValueFor("projectile_speed")
    local vision_radius = ability:GetSpecialValueFor("vision_radius")

    -- Play attack sound
    EmitSoundOn(sound_cast, caster)    

    -- Launch projectile on target
    local info = {
        Target = target,
        Source = caster,
        Ability = ability,
        EffectName = particle_projectile,
        iMoveSpeed = projectile_speed,
        bDodgeable = true, 
        bVisibleToEnemies = true,
        bReplaceExisting = false,
        bProvidesVision = true,        
        iVisionRadius = vision_radius,
        iVisionTeamNumber = caster:GetTeamNumber()      
        }

    ProjectileManager:CreateTrackingProjectile(info)
end

function stoltzfus_insults:OnProjectileHit(hTarget, vLocation)
    -- Ability properties
    local caster = self:GetCaster()
    local ability = self
    local sound_hit = "Hero_ObsidianDestroyer.ArcaneOrb.Impact"
    local intDif = caster:GetIntellect() - hTarget:GetIntellect()
    print(intDif)
    if intDif > 0 then
    	local damage = self:GetAbilityDamage() * intDif
    else
    	local damage = 0
    end
    local damageType = self:GetAbilityDamageType()
    -- Ability specials

    -- If target has Linken Sphere, block effect entirely
    if target:GetTeam() ~= caster:GetTeam() then
        if target:TriggerSpellAbsorb(ability) then
            return nil
        end
    end

    -- Play hit sound
    EmitSoundOn(sound_hit, hTarget)

    -- Perform an attack on the target
    caster:PerformAttack(target, false, true, true, false, false, false, true)
    local damageTable = {
    	victim = hTarget,
    	attacker = caster,
    	damage = damage,
    	damage_type = damageType
    }
    ApplyDamage(damageTable)

end


--Ability #2 Mumble Rap
stoltzfus_rap = class({})
LinkLuaModifier("modifier_stoltzfus_rap_thinker", "abilities/hero_stoltzfus", LUA_MODIFIER_MOTION_NONE)


function stoltzfus_rap:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("stun_duration")
	local areaDuration = self:GetSpecialValueFor("area_duration")
	CreateModifierThinker(caster, self, "modifier_stoltzfus_rap_thinker", { duration = areaDuration}, point, caster:GetTeamNumber(), false)
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		point, 
		nil, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO, 
		DOTA_UNIT_TARGET_FLAG_NONE, 
		FIND_ANY_ORDER, 
		false)

	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self, "modifier_stunned", { duration = duration})
		local damage = self:GetAbilityDamage()
		local damageType = self:GetAbilityDamageType()
		local damageTable = {
			victim = enemy,
			attacker = caster,
			damage = damage,
			damage_type = damageType
		}
		ApplyDamage(damageTable)
	end
end

modifier_stoltzfus_rap_thinker = class({})

function modifier_stoltzfus_rap_thinker:OnCreated()
	local caster = self:GetParent()
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	local aoe_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_maledict_aoe.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControl( aoe_pfx, 0, Vector(0,0,0) )
	ParticleManager:SetParticleControl( aoe_pfx, 1, Vector(radius, radius, radius) )
	self:AddParticle(aoe_pfx, false, false, 0, false, false)
end

--Ability #4 Valedictorian
stoltzfus_valedictorian = class({})
LinkLuaModifier("modifier_stoltzfus_valedictorian", "abilities/hero_stoltzfus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stoltzfus_valedictorian_thinker", "abilities/hero_stoltzfus", LUA_MODIFIER_MOTION_NONE)

function stoltzfus_valedictorian:GetIntrinsicModifierName()
	return "modifier_stoltzfus_valedictorian_thinker"
end

modifier_stoltzfus_valedictorian_thinker = class({})

function modifier_stoltzfus_valedictorian_thinker:OnCreated()
	self:StartIntervalThink(1)
end

function modifier_stoltzfus_valedictorian_thinker:OnIntervalThink()
	local caster = self:GetParent()
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	print(radius)
	local units = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetAbsOrigin(), 
		nil, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_BOTH, 
		DOTA_UNIT_TARGET_HERO, 
		DOTA_UNIT_TARGET_FLAG_NONE, 
		FIND_ANY_ORDER, 
		false
	)
	if caster:HasModifier("modifier_stoltzfus_valedictorian") then
		if #units > 0 then
			caster:RemoveModifierByName("modifier_stoltzfus_valedictorian")
		end
	else
		if #units == 0 then
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_stoltzfus_valedictorian", {})
		end
	end
end

modifier_stoltzfus_valedictorian = class({})

function modifier_stoltzfus_valedictorian:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
	return funcs
end

function modifier_stoltzfus_valedictorian:GetModifierBonusStats_Intellect()
	local int = self:GetAbility():GetSpecialValueFor("bonus_int")
	return int
end