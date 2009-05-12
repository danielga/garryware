include('shared.lua')

function ENT:Initialize()
	if (CLIENT) then
		self.Entity:SetRenderBoundsWS(self.Entity:GetPos() + Vector(-128,-128,0),self.Entity:GetPos() + Vector(128,128,0))
	end
end

local Circle = Material("sprites/sent_ball")

function ENT:Draw()
	local vectcolor = self:GetNWVector("dcolor",Vector(255 , 255 , 255))
	local color = Color(vectcolor.x,vectcolor.y,vectcolor.z,255)
	--local color = Color(255,255,255,255)
	local size = self:GetNWInt("zsize",64)
	
	local center = self:LocalToWorld(self:OBBCenter())
	local trace = {}
	trace.start 	= center 
	trace.endpos 	= trace.start + Vector(0,0,-300)
	trace.filter 	= self
	local tr = util.TraceLine( trace )
		
	if not tr.HitWorld then
		tr.HitPos = self:GetPos()
	end
	
	render.SetMaterial( Circle )
	--render.DrawQuadEasy( self:GetPos(), self:GetAngles():Up(), size, size, color )
	render.DrawQuadEasy( self:GetPos(), self:GetUp(), size, size, color )
end
