--ware_mod.AddCSFile( "wareminigames/clientside/cl_hlss.lua" )

function WARE:IsPlayable()
	local doit = false
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		doit = v:IsSpeaking( ) or doit
	end
	return doit
end

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(1.5,2)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Don't use HLSS !",1)
	return
end

function WARE:StartAction()
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "ware_hlss" )
	end
	return
end

function WARE:EndAction()

end

local function WareHLSS(player, commandName, args)
	player:WarePlayerDestinyLose( )
end
concommand.Add("ware_hlss",WareHLSS)
