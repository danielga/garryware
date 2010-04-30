WARE.Author = "Hurricaaane (Ha3)"
WARE.Room = "empty"

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(2, math.Rand(1.3, 5.0))

	GAMEMODE:SetPlayersInitialStatus( false )
	GAMEMODE:DrawInstructions( "When clock reaches zero..." )
	
	self.zcap = GAMEMODE:GetRandomLocations(1, "dark_ground")[1]:GetPos().z + 96

	return
end

function WARE:StartAction()
	GAMEMODE:DrawInstructions( "Be high in the air!" )
	
	for _,v in pairs(team.GetPlayers(TEAM_HUMANS)) do
		v:Give( "sware_rocketjump_limited" )
	end
	
	return
end

function WARE:EndAction()

end


function WARE:Think( )
	for _,ply in pairs(team.GetPlayers(TEAM_HUMANS)) do
		ply:SetAchievedNoLock( ply:GetPos().z > self.zcap )
	end
end
