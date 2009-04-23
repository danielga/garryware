WARE.Author = "Hurricaaane (Ha3)"

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(3.5,2)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Don't move !",1)
	return
end

function WARE:StartAction()
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "ware_weap_crowbar" )
	end
	return
end

function WARE:EndAction()

end

function WARE:Think( )
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		if (v:GetVelocity():Length() > 16) then v:WarePlayerDestinyLose( ) end
	end
end
