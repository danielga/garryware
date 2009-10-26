ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.Size            = 24

function ENT:IsUsable()
	return self.Entity:GetNWBool( "usable", false )
end