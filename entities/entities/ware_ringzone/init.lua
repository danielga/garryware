
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:SetNWVector("color",Vector(255 , 255 , 255))
	self:SetNWInt("size",64)
	
	self.Entity:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableDrag(false)
		phys:EnableCollisions(false)
		phys:SetMass(10)
	end
	
	self.Entity:SetTrigger( true )
	self.Entity:DrawShadow( false )
end

function ENT:SetColor( color )
	self:SetNWVector("dcolor",Vector(color.r , color.g , color.b))
end

function ENT:SetSize( inches )
	self:SetNWInt("size",inches)
end

function ENT:Think() 

end 
