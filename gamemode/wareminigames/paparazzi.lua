WARE.Author = "Hurricaaane (Ha3)"

function WARE:IsPlayable()
	return #team.GetPlayers(TEAM_UNASSIGNED) >=2
end

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(1,3.5)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Prepare to look up !",0)
	
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		local angles = v:EyeAngles()
		v:SetEyeAngles( Angle( 0,angles.y,0 ) )
	end
	
	timer.Create("WARETIMERslowlookup", 0, 0, self.SlowLookUp, self)
	return
end

function WARE:SlowLookUp()
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		local angles = v:EyeAngles()
		v:SetEyeAngles( Angle( angles.p + 1, angles.y, 0 ) )
	end
end

function WARE:StartAction()
    timer.Destroy("WARETIMERslowlookup")
	GAMEMODE:DrawPlayersTextAndInitialStatus("Photograph an untagged player !",0)
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "ware_camera" )
		v:SetNWBool("tagged",false)
	end
	return
end

function WARE:EndAction()
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:SetMaterial("")
		v:SetColor(255,255,255,255)
	end
end
