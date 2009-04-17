
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	// Use the helibomb model just for the shadow (because it's about the same size)
	self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	
	// Don't use the model's physics - create a sphere instead
	self.Entity:PhysicsInitSphere( self.Size, "metal_bouncy" )
	
	// Wake the physics object up. It's time to have fun!
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity( false )
	end
	
	// Set collision bounds exactly
	self.Entity:SetCollisionBounds( Vector( -self.Size, -self.Size, -self.Size), Vector( self.Size,self.Size, self.Size ) )
end

/*---------------------------------------------------------
   Name: PhysicsCollide
---------------------------------------------------------*/
function ENT:PhysicsCollide( data, physobj )
	
	// Play sound on bounce
	if (data.Speed > 80 && data.DeltaTime > 0.2 ) then
		self.Entity:EmitSound( "Rubber.BulletImpact" )
	end
	
	
	// Bounce like a crazy bitch
	local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )
	local NewVelocity = physobj:GetVelocity()
	NewVelocity:Normalize()
	
	LastSpeed = math.max( NewVelocity:Length(), LastSpeed )
	
	local TargetVelocity = NewVelocity * LastSpeed * 0.85
	
	physobj:SetVelocity( TargetVelocity )
	
end


/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )

	// React physically when shot/getting blown
	dmginfo:SetDamageForce(dmginfo:GetDamageForce()*0.05)
	self.Entity:TakePhysicsDamage( dmginfo )
	
	local ply = dmginfo:GetAttacker( )
	if ply:IsValid() && ply:IsPlayer() then
		local times = ply:GetNWInt("timeshit")
		ply:SetNWInt("timeshit",times + 1)
		ply:SendLua( "LocalPlayer():EmitSound( \"" .. GAMEMODE.WinOther .. "\" );" );
	end
end
