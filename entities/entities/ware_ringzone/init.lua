
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	
	self:SetTrigger( true )
	self:DrawShadow( false )
	
	self:SetNWVector("color", Vector(255 , 255 , 255))
	self:SetNWInt("size", 64)
end

function ENT:SetZColor( color )
	self:SetNWVector("dcolor", Vector(color.r , color.g , color.b))
end

function ENT:SetZSize( inches )
	self:SetNWInt("zsize", inches)
end

function ENT:Think()
end 
