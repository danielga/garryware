AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Weapons/W_missile_launch.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	
	local phys = self:GetPhysicsObject()
	phys:EnableDrag(true)
	phys:SetMass(80)
	phys:SetMaterial("crowbar")
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
	self:EmitSound("ambient/levels/labs/electric_explosion1.wav")
	
	local effectdata = EffectData( )
		effectdata:SetOrigin( self:GetPos( ) + data.HitNormal * 16 )
		local vec = self:GetPos() - data.HitPos
		vec:Normalize()
		effectdata:SetNormal( vec )
	util.Effect( "waveexplo", effectdata, true, true )
	
	--Old fucking hard rocketjump code by Hurricaaane
	/*for _,ent in pairs(ents.FindInSphere(self:GetPos(),64)) do
		if ent:IsPlayer() == true then
			ent:SetGroundEntity( NULL )
			local vec = ent:GetPos() - self:GetPos()
			vec:Normalize()
			ent:SetVelocity(ent:GetVelocity() + vec * 350)
		end
	end*/

	--New code from BlackOps
	for i,v in ipairs(ents.FindInSphere( self:GetPos(), 60 )) do
		if(v ~= self) then
			if(v:IsPlayer()) then
				if(v == self:GetOwner()) then
					v:SetVelocity(v:GetAimVector() * -500, 0)
				end
			end
		end
	end
	self:Remove()
end 

function ENT:Think()
end
