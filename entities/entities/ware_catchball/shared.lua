ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.Size            = 24

function ENT:IsUsable()
	return self:GetDTBool(0) or false
end