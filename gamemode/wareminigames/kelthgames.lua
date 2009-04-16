registerMinigame("climb",function(self, args)
	--Start of INIT
	GAMEMODE:SetWareWindupAndLength(1.5,3)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Climb on the blocks !",0)
	return
	
end,function(self, args)
	--Start of ACT
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "ware_weap_crowbar" )
	end
	return
end)
function WAREclimbThink( )
	if GAMEMODE:GetWareID() == "climb" then
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:SetAchievedNoDestiny(0)
	end
	local entposcopy = 	table.Copy(GAMEMODE:GetEnts(ENTS_ONCRATE))
	for _,block in pairs(entposcopy) do
		local sphere = ents.FindInSphere(block:GetPos(),32)
		for _,target in pairs(sphere) do
			if target:IsPlayer() then
				target:SetAchievedNoDestiny(1)
			end
		end
	end
	end
end
hook.Add( "Think", "WAREclimbThink", WAREclimbThink );  

registerMinigame("touchsky",function(self, args)
	--Start of INIT
	GAMEMODE:SetWareWindupAndLength(1.5,6)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Don't touch the sky ! ",1)
	return
	
end,function(self, args)
	--Start of ACT
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "ware_velocitygun" )
	end
	return
end)
function WAREtouchskyThink( )
	if GAMEMODE:GetWareID() == "touchsky" then
	local entover = table.Copy(GAMEMODE:GetEnts(ENTS_OVERCRATE))
	local entsky = table.Copy(GAMEMODE:GetEnts(ENTS_OVERCRATE))
	local zsky = (entover[1]:GetPos().z + entsky[1]:GetPos().z)/1.5
	
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		if v:GetPos().z > zsky then
			GAMEMODE:WarePlayerDestinyLose( v )
		end
	end
	end
end
hook.Add( "Think", "WAREtouchskyThink", WAREtouchskyThink );  

