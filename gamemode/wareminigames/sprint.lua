WARE.Author = "Frostyfrog"
WARE.MaxSpeed = 320

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(2.5,5)
	
	GAMEMODE:SetPlayersInitialStatus( true )
	GAMEMODE:DrawInstructions( "Don't stop sprinting!" )
end

function WARE:StartAction()
	
end

function WARE:EndAction()
	for _,v in pairs(player.GetAll()) do
		v:SetColor(255, 255, 255, 255)
		if v:GetRagdollEntity() then
			v:GetRagdollEntity():Remove()
			
		end
		
	end
end

function WARE:Think( )
	for k,ply in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		if not ply:GetLocked() and ( ply:GetVelocity():Length() < (self.MaxSpeed * 0.8) ) then
			ply:ApplyLose( )
			
			ply:SetColor(255, 255, 255, 64)
			ply:CreateRagdoll()
			local ragdollent = ply:GetRagdollEntity()
			if ValidEntity(ragdoll) then
				local ragphys = ragdoll:GetPhysicsObjectNum( 0 )
				ragphys:ApplyForceCenter( Vector(0, 0, 10000) )
			end
			
		end
	end
end
