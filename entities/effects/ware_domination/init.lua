
function EFFECT:Init( data )

	self.Pos = data:GetOrigin( ) 
	
	local emitter = ParticleEmitter( self.Pos )
	
	for i=1,70 do
		local particle = emitter:Add( "effects/blueflare1", self.Pos + VectorRand() * 5)
		particle:SetColor(255,255,0)
		particle:SetStartSize( math.Rand(5,10) )
		particle:SetEndSize( 0 )
		particle:SetStartAlpha( 250 )
		particle:SetEndAlpha( 0 )
		particle:SetDieTime( math.Rand(2,3) )
		particle:SetVelocity( VectorRand() * 100 + Vector(0,0,50) )
		
		particle:SetBounce(0.8)
		particle:SetGravity( Vector( 0, 0, -200 ) )
		particle:SetCollide(true)
		

		particle:SetStartLength( 0.2 )
		particle:SetEndLength( 0.2 )
		particle:SetVelocityScale( true )
	end
	
	local particle = emitter:Add( "effects/blueflare1", self.Pos)
	particle:SetColor(255,255,0)
	particle:SetStartSize( 100 )
	particle:SetEndSize( 0 )
	particle:SetStartAlpha( 250 )
	particle:SetEndAlpha( 0 )
	particle:SetDieTime( 2 )
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
