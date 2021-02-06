--Ability #1 Complain
jeff_complain = class({})

function jeff_complain:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local gold = self:GetSpecialValueFor("gold")

	target:Kill(self, caster)
	caster:ModifyGold(gold, true, 0)
end

--Ability #2 Water Bottle Throw
jeff_water_bottle = class({})
LinkLuaModifier("modifier_jeff_water_bottle", "abilities/hero_jeff", LUA_MODIFIER_MOTION_NONE)

function jeff_water_bottle:GetIntrinsicModifierName()
	return "modifier_jeff_water_bottle"
end



function jeff_water_bottle:OnSpellStart()
	local caster = self:GetCaster()
	if caster:FindModifierByName("modifier_jeff_water_bottle"):GetStackCount() == 0 then
		self:EndCooldown()
		self:RefundManaCost()
	else

		local target = self:GetCursorTarget()
		local speed = self:GetSpecialValueFor("speed")
		caster:SetModifierStackCount("modifier_jeff_water_bottle", caster, caster:GetModifierStackCount("modifier_jeff_water_bottle", caster) - 1)
		info = {
			Target = target,
			Source = caster,
			Ability = self,	
			EffectName = "particles/units/heroes/hero_tinker/tinker_missile.vpcf",
			bReplaceExisting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO,
			iMoveSpeed = speed,
			bProvidesVision = false,
			bDodgeable = true,
		}
		ProjectileManager:CreateTrackingProjectile(info)
		caster:EmitSound("Hero_Tinker.Heat-Seeking_Missile")
		
		

	end
end

function jeff_water_bottle:OnProjectileHit(hTarget, vLocation)

	local caster = self:GetCaster()
	local target = hTarget
	local damage = self:GetSpecialValueFor("damage")
	local damageType = DAMAGE_TYPE_MAGICAL

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = damageType
	}
	ApplyDamage(damageTable)

	target:AddNewModifier(caster, self, "modifier_stunned", { duration = self:GetSpecialValueFor("stun_duration")})

end

modifier_jeff_water_bottle = class({})

function modifier_jeff_water_bottle:OnCreated()
	self:SetStackCount(self:GetAbility():GetSpecialValueFor("max_charges"))
	self:StartIntervalThink(1)
	local chargeRestoreTime = self:GetAbility():GetSpecialValueFor("charge_restore_time")
	self.chargeCooldown = chargeRestoreTime
end


function modifier_jeff_water_bottle:OnIntervalThink()
	local caster = self:GetParent()
	local ability = self:GetAbility()
	local maxCharges = self:GetAbility():GetSpecialValueFor("max_charges")
	local chargeRestoreTime = self:GetAbility():GetSpecialValueFor("charge_restore_time")
	if self:GetStackCount() < maxCharges then


		if self.chargeCooldown == 0 then
			self:IncrementStackCount()
			self.chargeCooldown = chargeRestoreTime
		else
			self.chargeCooldown = self.chargeCooldown - 1
			if caster:GetModifierStackCount("modifier_jeff_water_bottle", caster) == 0 then
				ability:StartCooldown(self.chargeCooldown)
			end
		end
	end
end
--Ability #3 Taking Sides
jeff_taking_sides = class({})

function jeff_taking_sides:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local damage = self:GetSpecialValueFor("damage")
	EmitSoundOn("Hero_Antimage.Blink_out", caster)
	caster:SetAbsOrigin(target:GetAbsOrigin())
	FindClearSpaceForUnit(caster, target:GetAbsOrigin(), true)

	if target:GetTeamNumber() == caster:GetTeamNumber() then
		target:Heal(damage, caster)
	else
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

--Ability #4 Infernal Beam
jeff_beam = class({})
LinkLuaModifier("modifier_jeff_beam", "abilities/hero_jeff", LUA_MODIFIER_MOTION_NONE)

function jeff_beam:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	target:AddNewModifier(caster, self, "modifier_jeff_beam", { duration = self:GetChannelTime() })
end

function jeff_beam:OnChannelFinish( interrupt )
	local target = self:GetCursorTarget()
	if target then
		target:FindModifierByName("modifier_jeff_beam"):Destroy()
	end
end

modifier_jeff_beam = class({})

function modifier_jeff_beam:OnCreated()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	self:StartIntervalThink(0.25)
	self.damage = self:GetAbility():GetSpecialValueFor("damage_start")
	self.beamFX = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_life_drain.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(self.beamFX, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.beamFX, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
	self:AddParticle(self.beamFX, false, false, 0, false, false)
end

function modifier_jeff_beam:OnIntervalThink()
	local target = self:GetParent()
	local caster = self:GetCaster()
	if CalculateDistance(target, caster) > self:GetAbility():GetSpecialValueFor("beam_range") then
		self:Destroy()
	else
		local damage = self.damage
		local damageType = DAMAGE_TYPE_MAGICAL
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = damageType
		}
		ApplyDamage(damageTable)
		self.damage = self.damage * self:GetAbility():GetSpecialValueFor("damage_mult_per_tick")
	end
end

function CalculateDistance(ent1, ent2)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local distance = (pos1 - pos2):Length2D()
	return distance
end