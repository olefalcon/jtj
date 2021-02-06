--Elemental Archer
--Agility Hero

--ICE ABILITIES
--1 - Frost Arrows Autocast slow
--2 - Dash Stun
--3 - Ice Spear Line Target Stun

ea_ice_arrows = class({})
LinkLuaModifier("modifier_ea_ice_arrows", "abilities/hero_elemental_archer", LUA_MODIFIER_MOTION_NONE)

function ea_ice_arrows:GetIntrinsicModifierName()
	return "modifier_ea_ice_arrows"
end

modifier_ea_ice_arrows = class({})

function modifier_ea_ice_arrows:OnCreated()
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()		

	-- Ability specials
	self.procChance = ability:GetSpecialValueFor("stun_chance")
	self.stunDuration = ability:GetSpecialValueFor("stun_duration")
end

function modifier_ea_ice_arrows:DeclareFunctions()
	local decFunc = {MODIFIER_EVENT_ON_ATTACK_LANDED}

	return decFunc
end

function modifier_ea_ice_arrows:OnAttackLanded(params)
	if RollPercentage(self.procChance) and ability:IsCooldownReady() then
		params.unit:AddNewModifier(self.caster, self.ability, "modifier_stunned", { duration = self.stunDuration})
		self.ability:StartCooldown( self.ability:GetCooldown(self.ability:GetLevel() ))
	end
end

ea_fire_arrows = class({})
LinkLuaModifier("modifier_ea_fire_arrows", "abilities/hero_elemental_archer", LUA_MODIFIER_MOTION_NONE)

function ea_ice_arrows:GetIntrinsicModifierName()
	return "modifier_ea_fire_arrows"
end

modifier_ea_fire_arrows = class({})

function modifier_ea_fire_arrows:OnCreated()
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()		

	-- Ability specials
	self.procChance = ability:GetSpecialValueFor("proc_chance")
	self.burn_duration = ability:GetSpecialValueFor("burn_duration")
end

function modifier_ea_fire_arrows:DeclareFunctions()
	local decFunc = {MODIFIER_EVENT_ON_ATTACK_LANDED}

	return decFunc
end

function modifier_ea_fire_arrows:OnAttackLanded(params)
	if RollPercentage(self.procChance) and ability:IsCooldownReady() then
		params.unit:AddNewModifier(self.caster, self.ability, "modifier_ea_fire_arrows_debuff", { duration = self.stunDuration})
		self.ability:StartCooldown( self.ability:GetCooldown(self.ability:GetLevel() ))
	end
end

modifier_ea_fire_arrows_debuff = class({})

function modifier_ea_fire_arrows_debuff:OnCreated()
	self.ability = self:GetAbility()
	self.caster = ability:GetCaster()
	self.slow = ability:GetSpecialValueFor("slow")
	self.burn_tick = ability:GetSpecialValueFor("burn_tick")
	self.burn_damage = ability:GetSpecialValueFor("burn_damage")
	
	self:StartIntervalThink(burn_tick)
end

function modifier_ea_fire_arrows_debuff:OnIntervalThink()
	local target = self:GetParent()
	local damage = self.burn_damage
	local damageType = DAMAGE_TYPE_MAGICAL
	local damageTable = {
		victim = target,
		attacker = self.caster,
		damage = damage,
		damage_type = damageType
	}
	ApplyDamage(damageTable)
end

function modifier_ea_fire_arrows_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_ea_fire_arrows_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

ea_storm_arrows = class({})
LinkLuaModifier("modifier_ea_storm_arrows", "abilities/hero_elemental_archer", LUA_MODIFIER_MOTION_NONE)

function ea_ice_arrows:GetIntrinsicModifierName()
	return "modifier_ea_storm_arrows"
end

modifier_ea_storm_arrows = class({})

function modifier_ea_storm_arrows:OnCreated()
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()		

	-- Ability specials
	self.procChance = ability:GetSpecialValueFor("stun_chance")
	self.stunDuration = ability:GetSpecialValueFor("stun_duration")
end

function modifier_ea_storm_arrows:DeclareFunctions()
	local decFunc = {MODIFIER_EVENT_ON_ATTACK_LANDED}

	return decFunc
end

function modifier_ea_storm_arrows:OnAttackLanded(params)
	if RollPercentage(self.procChance) and ability:IsCooldownReady() then
		params.unit:AddNewModifier(self.caster, self.ability, "modifier_stunned", { duration = self.stunDuration})
		self.ability:StartCooldown( self.ability:GetCooldown(self.ability:GetLevel() ))
	end
end


ea_ice_dash = class({})
LinkLuaModifier("modifier_ea_ice_dash", "abilities/hero_elemental_archer", LUA_MODIFIER_MOTION_NONE)

function ea_ice_dash:OnUpgrade()
	local caster = self:GetCaster()
	local attune = caster:FindAbilityByName("ea_attune")
	if attune:GetLevel() == 0 then
		attune:SetLevel(1)
	end
end

function ea_ice_dash:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("DOTA_Item.ForceStaff.Activate", caster)
	caster:AddNewModifier(self:GetCaster(), self, "modifier_ea_ice_dash", {duration = self:GetSpecialValueFor("duration")})
end

modifier_ea_ice_dash = class({})

function modifier_ea_ice_dash:IsDebuff() return false end
function modifier_ea_ice_dash:IsHidden() return true end
function modifier_ea_ice_dash:IsPurgable() return false end
function modifier_ea_ice_dash:IsStunDebuff() return false end
function modifier_ea_ice_dash:IsMotionController()  return true end
function modifier_ea_ice_dash:GetMotionControllerPriority()  return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end
function modifier_ea_ice_dash:IgnoreTenacity()	return true end

function modifier_ea_ice_dash:OnCreated()
	if not IsServer() then return end
	local caster = self:GetParent()
	local particle_name = "particles/items_fx/force_staff.vpcf"
	self.affectedEnemies = {}
	self.pfx = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self:GetParent():StartGesture(ACT_DOTA_FLAIL)
	self:StartIntervalThink(FrameTime())
	self.angle = CalculateDirection(self:GetAbility():GetCursorPosition(), caster:GetAbsOrigin())
	self.distance = self:GetAbility():GetCastRange(Vector(0,0,0), nil) / ( self:GetDuration() / FrameTime())
end

function modifier_ea_ice_dash:OnDestroy()
	if not IsServer() then return end
	local caster = self:GetParent()
	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)
	self:GetParent():FadeGesture(ACT_DOTA_FLAIL)
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
	caster:Hold()
end

function modifier_ea_ice_dash:OnIntervalThink()
	-- Remove force if conflicting
	local caster = self:GetCaster()
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		100,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NO_INVIS,
		FIND_ANY_ORDER,
		false
	)
	for _,enemy in pairs(enemies) do
		local wasAffected = false
		for _aenemy in pairs(self.affectedEnemies) do
			if aenemy == enemy then
				wasAffected = true
			end
		end
		if wasAffected == false then
			enemy:AddNewModifier(caster, self, "modifier_stunned", { duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
			table.insert(self.affectedEnemies, enemy)
		end
	end

	self:HorizontalMotion(self:GetParent(), FrameTime())
end

function modifier_ea_ice_dash:HorizontalMotion(unit, time)
	if not IsServer() then return end
	local pos = unit:GetAbsOrigin()
	GridNav:DestroyTreesAroundPoint(pos, 80, false)
	local pos_p = self.angle * self.distance
	local next_pos = GetGroundPosition(pos + pos_p,unit)
	unit:SetAbsOrigin(next_pos)
end

--FIRE DASH
ea_fire_dash = class({})
ea_fire_dash_info = {}
LinkLuaModifier("modifier_ea_fire_dash", "abilities/hero_elemental_archer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ea_fire_dash_debuff", "abilities/hero_elemental_archer", LUA_MODIFIER_MOTION_NONE)
function ea_fire_dash:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("DOTA_Item.ForceStaff.Activate", caster)
	ea_fire_dash_info = {
		caster = self:GetCaster(),
		damage = self:GetSpecialValueFor("damage_per_tick"),
		damageType = self:GetAbilityDamageType(),
		slow = self:GetSpecialValueFor("slow")
	}
	caster:AddNewModifier(self:GetCaster(), self, "modifier_ea_fire_dash", {duration = self:GetSpecialValueFor("duration")})
end

modifier_ea_fire_dash = class({})

function modifier_ea_fire_dash:IsDebuff() return false end
function modifier_ea_fire_dash:IsHidden() return true end
function modifier_ea_fire_dash:IsPurgable() return false end
function modifier_ea_fire_dash:IsStunDebuff() return false end
function modifier_ea_fire_dash:IsMotionController()  return true end
function modifier_ea_fire_dash:GetMotionControllerPriority()  return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end
function modifier_ea_fire_dash:IgnoreTenacity()	return true end

function modifier_ea_fire_dash:OnCreated()
	if not IsServer() then return end
	local caster = self:GetParent()
	local particle_name = "particles/items_fx/force_staff.vpcf"
	self.affectedEnemies = {}
	self.pfx = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self:GetParent():StartGesture(ACT_DOTA_FLAIL)
	self:StartIntervalThink(FrameTime())
	self.angle = CalculateDirection(self:GetAbility():GetCursorPosition(), caster:GetAbsOrigin())
	self.distance = self:GetAbility():GetCastRange(Vector(0,0,0), nil) / ( self:GetDuration() / FrameTime())
end

function modifier_ea_fire_dash:OnDestroy()
	local caster = self:GetParent()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)
	self:GetParent():FadeGesture(ACT_DOTA_FLAIL)
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
	caster:Hold()
end

function modifier_ea_fire_dash:OnIntervalThink()
	-- Remove force if conflicting
	local caster = self:GetCaster()
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		100,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NO_INVIS,
		FIND_ANY_ORDER,
		false
	)
	for _,enemy in pairs(enemies) do
		local wasAffected = false
		for _aenemy in pairs(self.affectedEnemies) do
			if aenemy == enemy then
				wasAffected = true
			end
		end
		if wasAffected == false then
			enemy:AddNewModifier(caster, self, "modifier_ea_fire_dash_debuff", { duration = self:GetAbility():GetSpecialValueFor("debuff_duration")})
			table.insert(self.affectedEnemies, enemy)
		end
	end

	self:HorizontalMotion(self:GetParent(), FrameTime())
end

function modifier_ea_fire_dash:HorizontalMotion(unit, time)
	if not IsServer() then return end
	local pos = unit:GetAbsOrigin()
	GridNav:DestroyTreesAroundPoint(pos, 80, false)
	local pos_p = self.angle * self.distance
	local next_pos = GetGroundPosition(pos + pos_p,unit)
	unit:SetAbsOrigin(next_pos)
end

modifier_ea_fire_dash_debuff = class({})

function modifier_ea_fire_dash_debuff:OnCreated()
	self:StartIntervalThink(0.25)
end

function modifier_ea_fire_dash_debuff:OnIntervalThink()
	ability = ea_fire_dash_info
	local target = self:GetParent()
	local caster = ability.caster
	local damage = ability.damage
	local damageType = ability.damageType
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = damageType
	}
	print(dump(damageTable))
	ApplyDamage(damageTable)
end

function modifier_ea_fire_dash_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_ea_fire_dash_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -1 * ea_fire_dash_info.slow
end

--Storm Dash
ea_storm_dash = class({})
LinkLuaModifier("modifier_ea_storm_dash", "abilities/hero_elemental_archer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ea_storm_dash_buff", "abilities/hero_elemental_archer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ea_slience", "abilities/hero_elemental_archer", LUA_MODIFIER_MOTION_NONE)

function ea_storm_dash:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("DOTA_Item.ForceStaff.Activate", caster)
	caster:AddNewModifier(self:GetCaster(), self, "modifier_ea_storm_dash", {duration = self:GetSpecialValueFor("duration")})
end

modifier_ea_storm_dash = class({})

function modifier_ea_storm_dash:IsDebuff() return false end
function modifier_ea_storm_dash:IsHidden() return true end
function modifier_ea_storm_dash:IsPurgable() return false end
function modifier_ea_storm_dash:IsStunDebuff() return false end
function modifier_ea_storm_dash:IsMotionController()  return true end
function modifier_ea_storm_dash:GetMotionControllerPriority()  return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end
function modifier_ea_storm_dash:IgnoreTenacity()	return true end

function modifier_ea_storm_dash:OnCreated()
	if not IsServer() then return end
	local caster = self:GetParent()
	local particle_name = "particles/items_fx/force_staff.vpcf"
	self.affectedEnemies = {}
	self.pfx = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self:GetParent():StartGesture(ACT_DOTA_FLAIL)
	self:StartIntervalThink(FrameTime())
	self.angle = CalculateDirection(self:GetAbility():GetCursorPosition(), caster:GetAbsOrigin())
	self.distance = self:GetAbility():GetCastRange(Vector(0,0,0), nil) / ( self:GetDuration() / FrameTime())
end

function modifier_ea_storm_dash:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)
	self:GetParent():FadeGesture(ACT_DOTA_FLAIL)
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self:GetAbility(), "modifier_ea_storm_dash_buff", { duration = self:GetAbility():GetSpecialValueFor("buff_duration")})
	caster:Hold()
end

function modifier_ea_storm_dash:OnIntervalThink()
	-- Remove force if conflicting
	local caster = self:GetCaster()
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		100,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NO_INVIS,
		FIND_ANY_ORDER,
		false
	)
	for _,enemy in pairs(enemies) do
		local wasAffected = false
		for _aenemy in pairs(self.affectedEnemies) do
			if aenemy == enemy then
				wasAffected = true
			end
		end
		if wasAffected == false then
			enemy:AddNewModifier(caster, self, "modifier_ea_slience", { duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
			table.insert(self.affectedEnemies, enemy)
		end
	end

	self:HorizontalMotion(self:GetParent(), FrameTime())
end

function modifier_ea_storm_dash:HorizontalMotion(unit, time)
	if not IsServer() then return end
	local pos = unit:GetAbsOrigin()
	GridNav:DestroyTreesAroundPoint(pos, 80, false)
	local pos_p = self.angle * self.distance
	local next_pos = GetGroundPosition(pos + pos_p,unit)
	unit:SetAbsOrigin(next_pos)
end

modifier_ea_storm_dash_buff = class({})

function modifier_ea_storm_dash_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_ea_storm_dash_buff:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attack_speed")
end

modifier_ea_slience = class({})

function modifier_ea_slience:OnCreated()
	local nFX = ParticleManager:CreateParticle("particles/generic_gameplay/generic_silenced.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
	self:AddParticle(nfx, false, false, 0, false, false)
end

function modifier_ea_slience:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true
	}
	return state
end
--ICE ABILITY 3 ICE SPEAR
ea_ice_spear = class({})

function ea_ice_spear:OnUpgrade()
	local caster = self:GetCaster()
	local attune = caster:FindAbilityByName("ea_attune")
	if attune:GetLevel() == 0 then
		attune:SetLevel(1)
	end
end

function ea_ice_spear:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local direction = CalculateDirection(point, caster:GetAbsOrigin())
	local speed = self:GetSpecialValueFor("speed")
	local width = self:GetSpecialValueFor("width")
	self:FireLinearProjectile("particles/econ/items/mirana/mirana_crescent_arrow/mirana_spell_crescent_arrow.vpcf", direction*speed, self:GetCastRange(Vector(), nil), width, {}, false, false, 0)
end

function ea_ice_spear:OnProjectileHit(target, location)
	local caster = self:GetCaster()
	if target ~= nil then
		local stunDuration = self:GetSpecialValueFor("stun_duration")
		--projectile hit a target
		local damage = self:GetAbilityDamage()
		local damageType = self:GetAbilityDamageType()
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = damageType
		}
		target:AddNewModifier(caster, self, "modifier_stunned", { duration = stunDuration})
		ApplyDamage(damageTable)
	end
end

ea_fire_barrage = class({})
LinkLuaModifier("modifier_ea_fire_barrage", "abilities/hero_elemental_archer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ea_fire_barrage_thinker", "abilities/hero_elemental_archer", LUA_MODIFIER_MOTION_NONE)
function ea_fire_barrage:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local direction = CalculateDirection(point, caster:GetAbsOrigin())
	local distance = CalculateDistance(point, caster:GetAbsOrigin())
	local speed = self:GetSpecialValueFor("speed")
	local width = self:GetSpecialValueFor("width")
	self:FireLinearProjectile("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_launch.vpcf", direction*speed, distance, width, {}, false, false, 0)
end

function ea_fire_barrage:OnProjectileHit(target, location)
	local caster = self:GetCaster()
	if target == nil then
		--projectile lands at destination not when hitting unit
		local radius = self:GetSpecialValueFor("radius")
		local slowDuration = self:GetSpecialValueFor("slow_duration")
		local areaDuration = self:GetSpecialValueFor("area_duration")
		local damage = self:GetAbilityDamage()
		local damageType = self:GetAbilityDamageType()
		CreateModifierThinker(caster, self, "modifier_ea_fire_barrage_thinker", { duration = areaDuration }, location, caster:GetTeamNumber(), false)
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
			local damageTable = {
				victim = enemy,
				attacker = caster,
				damage = damage,
				damage_type = damageType
			}
			ApplyDamage(damageTable)
			enemy:AddNewModifier(caster, self, "modifier_ea_fire_barrage", { duration = slowDuration})
		end
	end
end

modifier_ea_fire_barrage = class({})

function modifier_ea_fire_barrage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_ea_fire_barrage:GetModifierMoveSpeedBonus_Percentage()
	return -1 * self:GetAbility():GetSpecialValueFor("slow")
end

modifier_ea_fire_barrage_thinker = class({})

function modifier_ea_fire_barrage_thinker:OnCreated()
	local caster = self:GetParent()
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_calldown_marker.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControl(nfx, 0, Vector(0,0,0))
	ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, -radius))
	ParticleManager:ReleaseParticleIndex(nfx)
	self:AddParticle(nfx, false, false, 0, false, false)
end

ea_cosmic_arrow = class({})

function ea_cosmic_arrow:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local direction = CalculateDirection(point, caster:GetAbsOrigin())
	local distance = CalculateDistance(point, caster:GetAbsOrigin())
	local speed = self:GetSpecialValueFor("speed")
	local width = self:GetSpecialValueFor("width")
	self:FireLinearProjectile("particles/units/heroes/hero_puck/puck_illusory_orb.vpcf", direction*speed, distance, width, {}, false, false, 0)
end

function ea_cosmic_arrow:OnProjectileHit(target, location)
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	local radius = self:GetSpecialValueFor("radius")
	local manaBurn = self:GetSpecialValueFor("mana_burn")

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(nfx, 0, location)
				ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, radius))
				ParticleManager:SetParticleControl(nfx, 2, location)
				ParticleManager:ReleaseParticleIndex(nfx)

	local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),
			location,
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false
		)
	for _,enemy in pairs(enemies) do
			FindClearSpaceForUnit(enemy, location, true)
			enemy:ReduceMana(manaBurn)
	end

	GridNav:DestroyTreesAroundPoint(location, radius, false)
end


--ABILITY ULTIMATE
ea_attune = class({})
LinkLuaModifier("modifier_ea_attune_ice", "abilities/hero_elemental_archer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ea_attune_storm", "abilities/hero_elemental_archer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ea_attune_fire", "abilities/hero_elemental_archer", LUA_MODIFIER_MOTION_NONE)

function ea_attune:OnUpgrade()
	local caster = self:GetCaster()
	if self:GetLevel() == 1 then
		caster:AddNewModifier(caster, self, "modifier_ea_attune_ice", {})
	end
end

function ea_attune:OnSpellStart()
	local caster = self:GetCaster()
	local ability2level = caster:GetAbilityByIndex(1):GetLevel()
	local ability3level = caster:GetAbilityByIndex(2):GetLevel()
	if caster:HasModifier("modifier_ea_attune_ice") then --Check if currently attuned to ice
		caster:RemoveModifierByName("modifier_ea_attune_ice") --Remove attune ice modifier
		caster:AddNewModifier(caster, self, "modifier_ea_attune_storm", {}) --Add attune storm modifier
		if not caster:FindAbilityByName("ea_storm_dash") then
			caster:AddAbility("ea_storm_dash")
		end
		caster:SwapAbilities("ea_ice_dash", "ea_storm_dash", false, true)
		--Replace 3
		if not caster:FindAbilityByName("ea_cosmic_arrow") then
			caster:AddAbility("ea_cosmic_arrow")
		end
		caster:SwapAbilities("ea_ice_spear", "ea_cosmic_arrow", false, true)
	elseif caster:HasModifier("modifier_ea_attune_storm") then --Check if currently attuned to storm
		caster:RemoveModifierByName("modifier_ea_attune_storm") --Remove attune storm modifier
		caster:AddNewModifier(caster, self, "modifier_ea_attune_fire", {}) --Add attune fire modifier
		if not caster:FindAbilityByName("ea_fire_dash") then
			caster:AddAbility("ea_fire_dash")
		end
		caster:SwapAbilities("ea_storm_dash", "ea_fire_dash", false, true)
		if not caster:FindAbilityByName("ea_fire_barrage") then
			caster:AddAbility("ea_fire_barrage")
		end
		caster:SwapAbilities("ea_cosmic_arrow", "ea_fire_barrage", false, true)
	elseif caster:HasModifier("modifier_ea_attune_fire") then --Check if currently attuned to fire
		caster:RemoveModifierByName("modifier_ea_attune_fire") --Remove attune fire modifier
		caster:AddNewModifier(caster, self, "modifier_ea_attune_ice", {}) --Add attune ice modifier
		caster:SwapAbilities("ea_fire_dash", "ea_ice_dash", false, true)
		caster:SwapAbilities("ea_fire_barrage", "ea_ice_spear", false, true)
	end
	caster:GetAbilityByIndex(2):SetLevel(ability3level)
	caster:GetAbilityByIndex(1):SetLevel(ability2level)
end

modifier_ea_attune_ice = class({})
function modifier_ea_attune_ice:IsPurgable() return false end
function modifier_ea_attune_ice:RemoveOnDeath() return false end
function modifier_ea_attune_ice:GetTexture() return "invoker_quas" end
modifier_ea_attune_storm = class({})
function modifier_ea_attune_storm:IsPurgable() return false end
function modifier_ea_attune_storm:RemoveOnDeath() return false end
function modifier_ea_attune_storm:GetTexture() return "invoker_wex" end
modifier_ea_attune_fire = class({})
function modifier_ea_attune_fire:IsPurgable() return false end
function modifier_ea_attune_fire:RemoveOnDeath() return false end
function modifier_ea_attune_fire:GetTexture() return "invoker_exort" end

