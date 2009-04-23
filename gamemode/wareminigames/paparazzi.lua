function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(2.5,3.5)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Don't get photograph'd !",1)
	return
end

function WARE:StartAction()
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "ware_camera" )
	end
	return
end

function WARE:EndAction()

end
