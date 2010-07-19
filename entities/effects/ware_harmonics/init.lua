EFFECT.Mat = Material( "effects/yellowflare" )
EFFECT.Color = Color( 119, 199, 255, 128 )
EFFECT.NumPins = 10
EFFECT.CirclePrecision = 24
EFFECT.Thickness = 2

EFFECT.AngleDump = Angle(0,0,0)

function EFFECT:Init( data )
	self.Origin  = data:GetOrigin()
	self.Extrema = data:GetStart()
	self.Radius = data:GetRadius()
	self.Speed = data:GetMagnitude()
	local angleFake = data:GetAngle()
	
	self.Color = Color( angleFake.p, angleFake.y, angleFake.r )
	self.BaseAlpha = color.a
	
	self.Distance = (self.Origin - self.Extrema):Length()
	
	self.Entity:SetRenderBoundsWS( self.Origin + Vector(1,1,1) * self.Radius * -1.5, self.Origin + Vector(1,1,1) * self.Radius * 1.5 )
	
	self.VD = {}
	for i = 1, 3 do
		table.insert(self.VD, 0 )
		table.insert(self.VD, ((math.random(0, 1) == 1) and 1 or -1) * math.Rand(0.7,3) )
	end
	
	self.BaseCircle = {}
	for d = 0, 359, (360 / self.CirclePrecision) do
		table.insert( self.BaseCircle, Vector( math.cos( math.rad(d) ) * self.Distance, math.sin( math.rad(d) ) * self.Distance, 0) )
	end
	
	self.SubSequents = {}
	for i=1,self.NumPins do
		self.SubSequents[i] = {}
		for k=1,self.CirclePrecision do
			table.insert( self.SubSequents[i], Vector(0,0,0) )
		end
	end
	
end

function EFFECT:Think( )
	return true
	
end

function EFFECT:CalculateAngle( iPhasis , angleToModify )
	angleToModify.p = iPhasis * self.VD[2]
	angleToModify.y = iPhasis * self.VD[4]
	angleToModify.r = iPhasis * self.VD[6]
end

function EFFECT:Render( )
	local phasis = math.floor(CurTime() * self.Speed)
	
	render.SetMaterial( self.Mat )
	for i = 1, self.NumPins do
		local delta = (self.NumPins - i + 1) / self.NumPins
		
		if phasis ~= self.LastPhasis then
			self:CalculateAngle( phasis - i , self.AngleDump )
			for k,_ in pairs( self.SubSequents[i] ) do
				self.SubSequents[i][k].x = self.BaseCircle[k].x
				self.SubSequents[i][k].y = self.BaseCircle[k].y
				self.SubSequents[i][k].z = 0
					
				-- Rotate modiffies the original vector
				self.SubSequents[i][k]:Rotate( self.AngleDump )
				self.SubSequents[i][k] = self.SubSequents[i+1][k] + self.Origin
				
			end
		end
		
		for k,_ in pairs( self.SubSequents[i] ) do
			self.Color.a = self.BaseAlpha * delta
			render.DrawBeam( self.SubSequents[i+1][k], 		
							 self.SubSequents[i+1][(k % self.CirclePrecision) + 1],
							 self.Thickness,					
							 0.5,					
							 0.5,				
							 self.Color )
		end
		
	end
	
end
