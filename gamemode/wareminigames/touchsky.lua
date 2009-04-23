WARE.Author = "Kelth"

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(2,6)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Stay on the ground ! ",1)
	local entover = GAMEMODE:GetEnts(ENTS_OVERCRATE)
	local entsky = GAMEMODE:GetEnts(ENTS_INAIR)
	GAMEMODE.GamePool.zsky = (entover[1]:GetPos().z + entsky[1]:GetPos().z)/2
	return
end

function WARE:StartAction()
	GAMEMODE:DrawPlayersTextAndInitialStatus("Don't touch the sky ! ",1)
	
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "ware_velocitygun" )
	end
	for k,v in pairs(player.GetAll()) do 
		v:SetGroundEntity( NULL )
		v:SetGravity(-0.1)
	end
	return
end

function WARE:EndAction()
	for k,v in pairs(player.GetAll()) do 
		v:SetGravity(1)
	end
end

function WARE:Think( )
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		if v:GetPos().z > GAMEMODE.GamePool.zsky then
			v:WarePlayerDestinyLose( )
		end
	end
end
