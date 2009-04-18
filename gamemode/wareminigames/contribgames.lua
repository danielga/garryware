-----------------------
---- By Frostyfrog ----
-----------------------
registerMinigame("sprint",
--Start of INIT
function(self, args)
	GAMEMODE:SetWareWindupAndLength(2,5)
	
	/*
	local players = team.GetPlayers(TEAM_UNASSIGNED)
	local class = players[1]:GetPlayerClass()
	GAMEMODE.GamePool.MaxSpeed = class.RunSpeed
	*/
	
	GAMEMODE.GamePool.MaxSpeed = 320
	GAMEMODE:DrawPlayersTextAndInitialStatus("Don't stop sprinting !",1)
end,
--Start of ACT
function(self, args)
end)
registerTrigger("sprint","Think",function( )
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		if (v:GetVelocity():Length() < GAMEMODE.GamePool.MaxSpeed*0.8) then
			GAMEMODE:WarePlayerDestinyLose( v )
		end
	end
end)