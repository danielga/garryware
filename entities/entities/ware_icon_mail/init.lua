
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

end

function ENT:Think()
end 
