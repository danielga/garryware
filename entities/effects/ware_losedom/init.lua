
function EFFECT:Init( data )

	self.Pos = data:GetOrigin( ) 
	
	local emitter = ParticleEmitter( self.Pos )
	
	for i=1,70 do
		local particle = emitter:Add( "effects/blueflare1", self.Pos + Vector(0,0,96) + VectorRand() * 5)
		particle:SetColor(255,0,0)
		particle:SetStartSize( math.Rand(5,10) )
		particle:SetEndSize( 0 )
		particle:SetStartAlpha( 250 )
		particle:SetEndAlpha( 0 )
		particle:SetDieTime( math.Rand(2,3) )
		particle:SetVelocity( VectorRand() * 256 )
		
		particle:SetBounce(0.8)
		particle:SetGravity( Vector( 0, 0, -250 ) )
		particle:SetCollide(true)
		

		particle:SetStartLength( 0.1 )
		particle:SetEndLength( 0.1 )
		particle:SetVelocityScale( true )
	end
	
	local particle = emitter:Add( "SGM/playercircle", self.Pos + Vector(0,0,96))
	particle:SetColor(255,255,0)
	particle:SetStartSize( 8 )
	particle:SetEndSize( 2 )
	particle:SetStartAlpha( 250 )
	particle:SetEndAlpha( 0 )
	particle:SetDieTime( math.Rand(2,3) )
	particle:SetVelocity( Vector(0,0,-48) + VectorRand()*32 )
	
	particle:SetBounce(0.8)
	particle:SetGravity( Vector( 0, 0, -120 ) )
	particle:SetCollide(true)
	
	emitter:Finish( )
	
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render( )

end
