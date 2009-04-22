include('shared.lua')

local Circle = Material("effects/select_ring")

function ENT:Initialize()
end

function ENT:Draw()
	print("allo")

	local vectcolor = self:GetNWVector("dcolor",Vector(255 , 255 , 255))
	local color = Color(vectcolor.x,vectcolor.y,vectcolor.z,255)
	local size = self:GetNWInt("size",64)
	
	render.SetMaterial( Circle )
	render.DrawQuadEasy( self:GetPos(), self:GetAngles():Up(), size, size, color )
end
