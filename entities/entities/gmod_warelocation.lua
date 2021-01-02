AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"

function ENT:Initialize()
	self:PhysicsInitBox(Vector(-1,-1,-1), Vector(1,1,1))
	self:SetCollisionBounds(Vector(-1,-1,-1), Vector(1,1,1))
	self:SetNoDraw(true)
	self:SetMoveType(MOVETYPE_NONE)
end
