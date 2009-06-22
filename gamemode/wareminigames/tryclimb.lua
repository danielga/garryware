WARE.Author = "Kelth"

function WARE:Initialize()
	--Start of INIT
	GAMEMODE:SetWareWindupAndLength(0.5,6)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Try to climb on the boxes !",0)
	return
end

function WARE:StartAction()
	for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		v:SetEyeAngles( Angle( 0,0,180 ) )
	end
	return
end

function WARE:EndAction()
	for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		v:SetEyeAngles( Angle( 0,0,0 ) )
	end
	return
end

function WARE:Think( )
	for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		v:SetAchievedNoDestiny(0)
		
	end
	local entposcopy = 	table.Copy(GAMEMODE:GetEnts(ENTS_ONCRATE))
	for _,block in pairs(entposcopy) do
		local box = ents.FindInBox(block:GetPos()+Vector(-30,-30,0),block:GetPos()+Vector(30,30,64))
		for _,target in pairs(box) do
			if target:IsPlayer() then
				target:SetAchievedNoDestiny(1)
			end
		end
	end
end
