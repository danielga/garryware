
function EFFECT:Init( data )

	self.Pos = data:GetOrigin( ) 
	
	local emitter = ParticleEmitter( self.Pos )
	
	for i=1,50 do
		local particle = emitter:Add( "effects/yellowflare", self.Pos + VectorRand() * 5)
		particle:SetColor( 255, 255, 0 )
		
		particle:SetStartSize( math.Rand(20,30) )
		particle:SetEndSize( 0 )
		
		particle:SetStartAlpha( 250 )
		particle:SetEndAlpha( 0 )
		
		particle:SetDieTime( 2.7 )
		
		--particle:SetVelocity( VectorRand() * 20 + Vector(0, 0, (math.random(0,1)*2-1)*math.random(20,100)) )
		particle:SetVelocity( VectorRand() * math.random(10,20) )
		particle:SetRoll( (math.random(0,1)*2-1)*math.random(20,40) )
		
		particle:SetStartLength( 64 )
		particle:SetEndLength( 48 )
		
		particle:SetBounce( 0.8 )
		particle:SetCollide( true )
	end
	
	emitter:Finish( )
	
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render( )

end
