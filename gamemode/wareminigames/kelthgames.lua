-- CLIMB ON THE BOXES MINIGAME

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

-- TOUCH SKY MINIGAME

registerMinigame("touchsky",function(self, args)
	--Start of INIT
	GAMEMODE:SetWareWindupAndLength(2,6)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Stay on the ground ! ",1)
	local entover = GAMEMODE:GetEnts(ENTS_OVERCRATE)
	local entsky = GAMEMODE:GetEnts(ENTS_INAIR)
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


-- CATCH A BALL MINIGAME

registerMinigame("catchball",function(self, args)
	--Start of INIT
	GAMEMODE:SetWareWindupAndLength(2,6)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Catch a ball !",0)
	return
	
end,function(self, args)
	--Start of ACT
	local entposcopy = table.Copy(GAMEMODE:GetEnts(ENTS_ONCRATE)) --Copying the table, and the removing elements from it
	local numberSpawns = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*0.5),1,table.Count(entposcopy))
	
	for i = 0, numberSpawns - 1 do
		table.sort(entposcopy,function(a,b) return a:EntIndex() < b:EntIndex() end) --Making sure the table doesnt have holes
		local iselect = math.random(1,table.Count(entposcopy))
		local v = entposcopy[iselect]
		
		local ent = ents.Create ("ware_catchball");
		ent:SetPos(v:GetPos());
		ent:Spawn();
		
		local phys = ent:GetPhysicsObject()
		phys:ApplyForceCenter (VectorRand() * 1024);
		
		table.remove( entposcopy, iselect )
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
	
	
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "weapon_physcannon" )
	end
	
	return
end,function(self, args)
	-- End of ACT

end)

function WAREcatchballGravGunOnPickedUp( pl, ent )
	if GAMEMODE:GetWareID() == "catchball" then
	GAMEMODE:WarePlayerDestinyWin( pl )
	end
end

hook.Add( "GravGunOnPickedUp", "WAREcatchballGravGunOnPickedUp", WAREcatchballGravGunOnPickedUp );  



