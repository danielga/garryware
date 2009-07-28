WARE.Author = "Hurricaaane (Ha3)"
WARE.Room = "none"

WARE.OccurencesPerCycle = 2

///////////////////////////////////////////////////////////////////////////
//DISABLED THIS WARE BECAUSE IT HAS BECOME TECHNICALLY IMPOSSIBLE TO LOSE//
//DISABLED THIS WARE BECAUSE IT HAS BECOME TECHNICALLY IMPOSSIBLE TO LOSE//
//DISABLED THIS WARE BECAUSE IT HAS BECOME TECHNICALLY IMPOSSIBLE TO LOSE//
//DISABLED THIS WARE BECAUSE IT HAS BECOME TECHNICALLY IMPOSSIBLE TO LOSE//
//DISABLED THIS WARE BECAUSE IT HAS BECOME TECHNICALLY IMPOSSIBLE TO LOSE//
//DISABLED THIS WARE BECAUSE IT HAS BECOME TECHNICALLY IMPOSSIBLE TO LOSE//
//DISABLED THIS WARE BECAUSE IT HAS BECOME TECHNICALLY IMPOSSIBLE TO LOSE//
///////////////////////////////////////////////////////////////////////////

function WARE:IsPlayable()
	return false
end

function WARE:IsPlayable()
	local doit = false
	if #team.GetPlayers(TEAM_HUMANS) >= 14 then
		doit = true
	end
	return doit
end

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(1.5,2)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Don't use HLSS !",1)
	return
end

function WARE:StartAction()
	for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		v:Give( "ware_hlss" )
	end
	return
end

function WARE:EndAction()

end

local function WareHLSS(player, commandName, args)
	if (GAMEMODE.Minigame.Name == "hlss") then
		player:WarePlayerDestinyLose( )
	end
end
concommand.Add("cware_hlss",WareHLSS)
