--Ability #1 Ramadan Breath
anwar_breath = class({})

function anwar_breath:OnSpellStart()
	local caster = self:GetCaster()
	local direction = CalculateDirection( self:GetCursorPosition(), caster)
	
	local velocity = self:GetSpecialValueFor("speed")
	local distance = self:GetSpecialValueFor("range")
	local width = 50
	local endWidth = 200
	self:FireLinearProjectile("particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf", velocity * direction, distance, width, {width_end = endWidth})
	
	EmitSoundOn("Hero_DragonKnight.BreathFire", caster)
end

function anwar_breath:OnProjectileHit(target, position)
	local caster = self:GetCaster()
	if target and not target:IsMagicImmune() and not target:IsInvulnerable() then
		local damage = self:GetSpecialValueFor("damage")
		local damageType = DAMAGE_TYPE_MAGICAL
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = damageType
		}
		ApplyDamage(damageTable)
	end
end

--Ability #2 Meaty Roll
anwar_roll = class({})
function anwar_roll:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    if self:GetCursorTarget() then
    	point = self:GetCursorTarget():GetAbsOrigin()
    end

    EmitSoundOn("Hero_EarthSpirit.RollingBoulder.Cast", caster)
    local velocity = self:GetSpecialValueFor("speed")
    local distance = (point - caster:GetAbsOrigin()):Length2D()
    local width = 100
    local endWidth = 100
    local direction = CalculateDirection(point, caster:GetAbsOrigin())
	self:FireLinearProjectile("particles/units/heroes/hero_earth_spirit/espirit_spawn.vpcf", velocity * direction, distance, width, {width_end = endWidth})
end



function anwar_roll:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget ~= nil then

		if hTarget:GetTeam() ~= caster:GetTeam() then
            EmitSoundOn("Hero_EarthSpirit.RollingBoulder.Target", hTarget)
				hTarget:AddNewModifier(caster, self, "modifier_stunned", { duration = self:GetSpecialValueFor("stun_duration")})
			--self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage"), {}, 0)
		end
	end
	ProjectileManager:ProjectileDodge( caster )
	caster:SetAbsOrigin(vLocation)
	FindClearSpaceForUnit(caster, vLocation, true)

end

--Ability #3 Prayers
anwar_prayers = class({})
LinkLuaModifier("modifier_anwar_prayers", "abilities/hero_anwar", LUA_MODIFIER_MOTION_NONE)

function anwar_prayers:GetIntrinsicModifierName()
	return "modifier_anwar_prayers"
end

modifier_anwar_prayers = class({})

function modifier_anwar_prayers:OnCreated()
	self:SetStackCount(0)
end
function modifier_anwar_prayers:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
	return funcs
end
function modifier_anwar_prayers:GetAttributes()
	local attrs = {
		MODIFIER_ATTRIBUTE_PERMANENT
	}
	return attrs
end
function modifier_anwar_prayers:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("attribute_bonus") * self:GetStackCount()
end
function modifier_anwar_prayers:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("attribute_bonus") * self:GetStackCount()
end
function modifier_anwar_prayers:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("attribute_bonus") * self:GetStackCount()
end


--Ability #4 Allah Akbar
anwar_allah_akbar = class({})
LinkLuaModifier("modifier_anwar_allah_akbar", "abilities/hero_anwar", LUA_MODIFIER_MOTION_NONE)
anwar_allah_akbar.target = ""

function anwar_allah_akbar:OnSpellStart()
	local caster = self:GetCaster()
	anwar_allah_akbar.target = self:GetCursorTarget()
	print(dump(anwar_allah_akbar.target))

	caster:AddNewModifier(caster, self, "modifier_anwar_allah_akbar", {})
end

modifier_anwar_allah_akbar = class({})

function modifier_anwar_allah_akbar:OnCreated()
	self.dir = CalculateDirection(anwar_allah_akbar.target, self:GetParent():GetAbsOrigin())
	self.distance = CalculateDistance(anwar_allah_akbar.target, self:GetParent():GetAbsOrigin())

	self:StartMotionController()
end

function modifier_anwar_allah_akbar:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
	}
	return funcs
end

function modifier_anwar_allah_akbar:CheckState()
	local state = {
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_STUNNED] = true
	}
	return state
end

function modifier_anwar_allah_akbar:GetModifierMoveSpeed_Absolute()
	return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_anwar_allah_akbar:DoControlledMotion()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local radius = 400
	if self.distance > 0 then
		self.dir = CalculateDirection(anwar_allah_akbar.target, self:GetParent():GetAbsOrigin())
		self.distance = CalculateDistance(anwar_allah_akbar.target, self:GetParent():GetAbsOrigin())
		local speed = self:GetAbility():GetSpecialValueFor("movespeed")
		speed = self:GetParent():GetIdealSpeed() * FrameTime()
		self.distance = self.distance - speed
		GridNav:DestroyTreesAroundPoint(parent:GetAbsOrigin(), radius, true)

		parent:SetAbsOrigin(GetGroundPosition(parent:GetAbsOrigin(), parent) + self.dir*speed)

	else
		local enemies = FindUnitsInRadius(
			parent:GetTeamNumber(),
	        parent:GetAbsOrigin(),
	        nil,
	        radius,
	        DOTA_UNIT_TARGET_TEAM_ENEMY,
	        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	        DOTA_UNIT_TARGET_FLAG_NONE,
	        FIND_ANY_ORDER,
	        false
		)
		print(#enemies)

		for _,enemy in pairs(enemies) do

			local damage = self:GetAbility():GetSpecialValueFor("damage")
			local damageType = DAMAGE_TYPE_MAGICAL
			local damageTable = {
				victim = enemy,
				attacker = parent,
				damage = damage,
				damage_type = damageType
			}
			print("DAMAGE PLS JESUS")
			ApplyDamage(damageTable)
			if not enemy:IsAlive() then
				caster:SetModifierStackCount("modifier_anwar_prayers", caster, GetModifierStackCount("modifier_anwar_prayers", caster) + 1)
			end
		end
		local damage = self:GetAbility():GetSpecialValueFor("damage") * 2
		local damageType = DAMAGE_TYPE_MAGICAL
		local damageTable = {
			victim = parent,
			attacker = parent,
			damage = damage,
			damage_type = damageType
		}
		print("DAMAGE PLS JESUS")
		ApplyDamage(damageTable)

		self:StopMotionController(true)
		self:Destroy()
	end
end