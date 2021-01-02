AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
	-- Use the helibomb model just for the shadow (because it's about the same size)
	self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
end

-- No strings anymore, use integers instead
/*
function ENT:SetEntityText(text)
	self:SetNWString("text",text)
end
*/

function ENT:SetEntityInteger( num )
	self:SetDTInt(0, tonumber(num) )
end