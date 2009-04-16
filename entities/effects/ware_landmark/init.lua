
function EFFECT:Init( data )

	self.Pos = data:GetOrigin( ) 
	
	local emitter = ParticleEmitter( self.Pos )
	
	for i=1,100 do
		local particle = emitter:Add( "effects/blueflare1", self.Pos + VectorRand() * 5)
		particle:SetColor(0,0,250)
		particle:SetStartSize( math.Rand(10,15) )
		particle:SetEndSize( 0 )
		particle:SetStartAlpha( 250 )
		particle:SetEndAlpha( 0 )
		particle:SetDieTime( 2.7 )
		particle:SetVelocity( VectorRand() * 10 + Vector(0,0,(math.random(0,2)-1)*math.random(20,100)) )
		
		particle:SetBounce(0.8)
		particle:SetGravity( Vector( 0, 0, 0 ) )
		particle:SetCollide(true)
	end
	
	local particle = emitter:Add( "effects/blueflare1", self.Pos)
	particle:SetColor(0,0,250)
	particle:SetStartSize( 20 )
	particle:SetEndSize( 0 )
	particle:SetStartAlpha( 250 )
	particle:SetEndAlpha( 0 )
	particle:SetDieTime( 2.7 )
	particle:SetVelocity( Vector(0,0,0) )
		
	particle:SetBounce(0)
	particle:SetGravity( Vector( 0, 0, 0 ) )
	
	emitter:Finish( )
	
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render( )

end
