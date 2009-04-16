// CLIMB ON THE BOXES MINIGAME

registerMinigame("climb",function(self, args)
	--Start of INIT
	GAMEMODE:SetWareWindupAndLength(1.5,3)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Climb on the boxes!",0)
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

// TOUCH SKY MINIGAME

registerMinigame("touchsky",function(self, args)
	--Start of INIT
	GAMEMODE:SetWareWindupAndLength(2,6)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Stay on the ground ! ",1)
	local entover = table.Copy(GAMEMODE:GetEnts(ENTS_OVERCRATE))
	local entsky = table.Copy(GAMEMODE:GetEnts(ENTS_INAIR))
	GAMEMODE.GamePool.zsky = (entover[1]:GetPos().z + entsky[1]:GetPos().z)/2
	return
	
end,function(self, args)
	--Start of ACT
	GAMEMODE:DrawPlayersTextAndInitialStatus("Don't touch the sky ! ",1)
	
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "ware_velocitygun" )
	end
	for k,v in pairs(player.GetAll()) do 
		v:SetGravity(-0.1)
	end
	return
end,function(self, args)
	-- End of ACT
	for k,v in pairs(player.GetAll()) do 
		v:SetGravity(1)
	end
end)
function WAREtouchskyThink( )
	if GAMEMODE:GetWareID() == "touchsky" then
	
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		if v:GetPos().z > GAMEMODE.GamePool.zsky then
			GAMEMODE:WarePlayerDestinyLose( v )
		end
	end
	end
end

hook.Add( "Think", "WAREtouchskyThink", WAREtouchskyThink );  

