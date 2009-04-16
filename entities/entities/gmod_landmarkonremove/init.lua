ENT.Type = "point"

function ENT:OnRemove( )
	GAMEMODE:MakeLankmarkEffect(self:GetPos())
end
