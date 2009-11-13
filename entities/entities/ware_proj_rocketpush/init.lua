AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/Weapons/W_missile_launch.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.Entity:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	
	local phys = self.Entity:GetPhysicsObject()
	phys:EnableDrag(true)
	phys:SetMass(80)
	phys:SetMaterial("crowbar")
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	if (CLIENT) then return end
	GAMEMODE:AppendEntToBin(self.Entity)
	
	return
end

function ENT:Use(activator,caller)
end

function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )
end

function ENT:PhysicsCollide( data, physobj )
	self.Entity:EmitSound("ambient/levels/labs/electric_explosion1.wav")
	
	local effectdata = EffectData( )
		effectdata:SetOrigin( self.Entity:GetPos( ) + data.HitNormal * 16 )
		effectdata:SetNormal( (self.Entity:GetPos() - data.HitPos):Normalize() )
	util.Effect( "waveexplo", effectdata, true, true )

	for i,target in ipairs(ents.FindInSphere( self.Entity:GetPos(), 64 )) do
		if(target!=self.Entity) then
			if(target:IsPlayer()) then
				target:SetVelocity(target:GetVelocity()*(-1) + (target:GetPos() + Vector(0,0,32) - self.Entity:GetPos()):Normalize() * 500)
			end
		end
	end
	self.Entity:Remove()
end 

function ENT:Think()
end
