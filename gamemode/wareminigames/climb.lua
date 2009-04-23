WARE.Author = "Kelth"

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(1.5,3)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Climb on the boxes !",0)
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
