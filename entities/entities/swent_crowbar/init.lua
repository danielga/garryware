AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/weapons/w_crowbar.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	
	local phys = self:GetPhysicsObject()
	phys:EnableDrag(true)
	phys:SetMass(80)
	phys:SetMaterial("crowbar")
	phys:AddAngleVelocity(Vector(math.random(-600,600),math.random(-600,600),math.random(-600,600))) 
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	
	if (CLIENT) then return end
	GAMEMODE:AppendEntToBin(self)
	
	return
end

function ENT:Use(activator,caller)
end

function ENT:OnTakeDamage( dmginfo )
	self:TakePhysicsDamage( dmginfo )
end

function ENT:PhysicsCollide( data, physobj )
	if (data.Speed > 50 and data.DeltaTime > 0.2 ) then
		self:EmitSound("Weapon_Crowbar.Melee_HitWorld", data.Speed/2)
	end
	if (data.Speed > 512 and IsValid(data.HitEntity)) then
		if (data.HitEntity:IsPlayer() or data.HitEntity:IsNPC()) then
		   self:EmitSound("weapons/hitbod1.wav", data.Speed*1.5)
		end
	end
end 

function ENT:Think()
end
