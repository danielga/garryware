WARE.Author = "Frostyfrog"

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(2,5)
	
	GAMEMODE.GamePool.MaxSpeed = 320
	GAMEMODE:DrawPlayersTextAndInitialStatus("Don't stop sprinting !",1)
end

function WARE:StartAction()
	
end

function WARE:EndAction()

end

function WARE:Think( )
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		if (v:GetVelocity():Length() < GAMEMODE.GamePool.MaxSpeed*0.8) then
			v:WarePlayerDestinyLose( )
		end
	end
end