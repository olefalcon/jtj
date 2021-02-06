--Ability #1 Meme Talk
trevor_meme_talk = class({})
LinkLuaModifier("modifier_trevor_meme_talk", "abilities/hero_trevor", LUA_MODIFIER_MOTION_NONE)

function trevor_meme_talk:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	target:AddNewModifier(caster, self, "modifier_trevor_meme_talk", { duration = self:GetSpecialValueFor("duration")})
end

modifier_trevor_meme_talk = class({})

function modifier_trevor_meme_talk:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true
	}
	return state
end

--Ability #2 Double Pump
trevor_double_pump_one = class({})

function trevor_double_pump_one:OnUpgrade()
	local caster = self:GetCaster()
	local pump2 = caster:FindAbilityByName("trevor_double_pump_two")
	if pump2 and pump2:GetLevel() ~= self:GetLevel() then
		pump2:UpgradeAbility(true)
	end
end

function trevor_double_pump_one:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local distance = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
	local distanceMult = 1 - (distance / self:GetCastRange(Vector(), nil))
	local maxDamage = self:GetSpecialValueFor("max_damage")
	local damage = math.floor(maxDamage * distanceMult)
	local damageType = DAMAGE_TYPE_MAGICAL

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = damageType
	}

	ApplyDamage(damageTable)
end

--Ability #3 Double Pump 2
trevor_double_pump_two = class({})

function trevor_double_pump_two:OnUpgrade()
	local caster = self:GetCaster()
	local pump1 = caster:FindAbilityByName("trevor_double_pump_one")
	if pump1 and pump1:GetLevel() ~= self:GetLevel() then
		pump1:UpgradeAbility(true)
	end
end

function trevor_double_pump_two:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local distance = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
	local distanceMult = 1 - (distance / self:GetCastRange(Vector(), nil))
	local maxDamage = self:GetSpecialValueFor("max_damage")
	local damage = math.floor(maxDamage * distanceMult)
	local damageType = DAMAGE_TYPE_MAGICAL

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = damageType
	}

	ApplyDamage(damageTable)
end

--Ability #4 Youtube Videos
trevor_videos = class({})
LinkLuaModifier("modifier_trevor_videos", "abilities/hero_trevor", LUA_MODIFIER_MOTION_NONE)

function trevor_videos:GetIntrinsicModifierName()
	return "modifier_trevor_videos"
end

modifier_trevor_videos = class({})

function modifier_trevor_videos:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EXP_RATE_BOOST
	}
	return funcs
end

function modifier_trevor_videos:GetModifierPercentageExpRateBoost()
	return self:GetAbility():GetSpecialValueFor("exp_gain")
end

--Ability #6 Fortnite Storm
trevor_storm = class({})
LinkLuaModifier("modifier_trevor_storm", "abilities/hero_trevor", LUA_MODIFIER_MOTION_NONE)

function trevor_storm:OnSpellStart()
	local caster = self:GetCaster()
	local point = Vector(0,0,0)
	local radius = self:GetSpecialValueFor("radius")

	CreateModifierThinker(caster, self, "modifier_trevor_storm", {}, point, caster:GetTeam(), false)


end

modifier_trevor_storm = class({})
modifier_trevor_storm.radius = 0
modifier_trevor_storm.nfx = ""
modifier_trevor_storm.nfx2 = ""
modifier_trevor_storm.nfx3 = ""
modifier_trevor_storm.point = ""

function modifier_trevor_storm:OnCreated(table)
    if IsServer() then
        local caster = self:GetCaster()
        modifier_trevor_storm.point = Vector(0,0,0)
        modifier_trevor_storm.radius = 7000

        modifier_trevor_storm.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere_surface.vpcf", PATTACH_POINT, caster)
                    ParticleManager:SetParticleControl(modifier_trevor_storm.nfx, 0, modifier_trevor_storm.point)
                    ParticleManager:SetParticleControl(modifier_trevor_storm.nfx, 1, Vector(modifier_trevor_storm.radius, modifier_trevor_storm.radius, 2))
        self:AddParticle(modifier_trevor_storm.nfx, false, false, 0, false, false)

        modifier_trevor_storm.nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere_rim.vpcf", PATTACH_POINT, caster)
                    ParticleManager:SetParticleControl(modifier_trevor_storm.nfx2, 0, modifier_trevor_storm.point)
                    ParticleManager:SetParticleControl(modifier_trevor_storm.nfx2, 1, Vector(modifier_trevor_storm.radius, modifier_trevor_storm.radius, 2))
        self:AddParticle(modifier_trevor_storm.nfx2, false, false, 0, false, false)

        modifier_trevor_storm.nfx3 = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere.vpcf", PATTACH_POINT, caster)
                    ParticleManager:SetParticleControl(modifier_trevor_storm.nfx3, 0, modifier_trevor_storm.point)
                    ParticleManager:SetParticleControl(modifier_trevor_storm.nfx3, 1, Vector(modifier_trevor_storm.radius, modifier_trevor_storm.radius, 2))
        self:AddParticle(modifier_trevor_storm.nfx3, false, false, 0, false, false)

        self:StartIntervalThink(0.1)
       -- self:StartMotionController()
		--self:GetAbility():StartDelayedCooldown()
    end
end

function modifier_trevor_storm:OnIntervalThink()
    local caster = self:GetCaster()

    modifier_trevor_storm.radius = modifier_trevor_storm.radius - 25
    if modifier_trevor_storm.radius < 100 then
    	self:Destroy()
    end


    ParticleManager:SetParticleControl(modifier_trevor_storm.nfx, 0, modifier_trevor_storm.point)
    ParticleManager:SetParticleControl(modifier_trevor_storm.nfx, 1, Vector(modifier_trevor_storm.radius, modifier_trevor_storm.radius, 128))


    ParticleManager:SetParticleControl(modifier_trevor_storm.nfx2, 0, modifier_trevor_storm.point)
   	ParticleManager:SetParticleControl(modifier_trevor_storm.nfx2, 1, Vector(modifier_trevor_storm.radius, modifier_trevor_storm.radius, 128))

    ParticleManager:SetParticleControl(modifier_trevor_storm.nfx3, 0, modifier_trevor_storm.point)
    ParticleManager:SetParticleControl(modifier_trevor_storm.nfx3, 1, Vector(modifier_trevor_storm.radius, modifier_trevor_storm.radius, 128))

    enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),
			modifier_trevor_storm.point,
			nil,
			GetWorldMaxX(),
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false
		)

    for _,enemy in pairs(enemies) do

    	local distance = (enemy:GetAbsOrigin() - modifier_trevor_storm.point):Length2D()

	    if distance > modifier_trevor_storm.radius then

			local damage = self:GetAbility():GetSpecialValueFor("damage")
			local damageType = DAMAGE_TYPE_MAGICAL
			local damageTable = {
				victim = enemy,
				attacker = caster,
				damage = damage,
				damage_type = damageType
			}

			ApplyDamage(damageTable)

		end

	end

end