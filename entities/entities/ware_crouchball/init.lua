
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
	end
	// Set collision bounds exactly
	self.Entity:SetCollisionBounds( Vector( -self.Size, -self.Size, -self.Size), Vector( self.Size,self.Size, self.Size ) )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WORLD )
	
end

/*---------------------------------------------------------
   Name: PhysicsCollide
---------------------------------------------------------*/
function ENT:PhysicsCollide( data, physobj )
	
	// Play sound on bounce
	if (data.Speed > 80 && data.DeltaTime > 0.2 ) then
		self.Entity:EmitSound( "Rubber.BulletImpact" )
	end
	
	if data.HitEntity:IsWorld() then
		if self.Entity:GetNWBool("crouch") then
			for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do
				if v:Crouching() == false then
					GAMEMODE:WarePlayerDestinyLose( v )
				end
			end	
		else
			for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do
				if v:Crouching() == true then
					GAMEMODE:WarePlayerDestinyLose( v )
				end
			end
		end
		self.Entity:Remove()
	end
	
end
