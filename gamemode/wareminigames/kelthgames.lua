-- CLIMB ON THE BOXES MINIGAME

registerMinigame("climb",
function(self, args)
	--Start of INIT
	GAMEMODE:SetWareWindupAndLength(1.5,3)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Climb on the boxes!",0)
	return
	
end,
function(self, args)
	--Start of ACT
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "ware_weap_crowbar" )
	end
	return
end)
registerTrigger("climb","Think",
function()  
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
end)

-- TOUCH SKY MINIGAME

registerMinigame("touchsky",
function(self, args)
	--Start of INIT
	GAMEMODE:SetWareWindupAndLength(2,6)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Stay on the ground ! ",1)
	local entover = GAMEMODE:GetEnts(ENTS_OVERCRATE)
	local entsky = GAMEMODE:GetEnts(ENTS_INAIR)
	GAMEMODE.GamePool.zsky = (entover[1]:GetPos().z + entsky[1]:GetPos().z)/2
	return
	
end,
function(self, args)
	--Start of ACT
	GAMEMODE:DrawPlayersTextAndInitialStatus("Don't touch the sky ! ",1)
	
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "ware_velocitygun" )
	end
	for k,v in pairs(player.GetAll()) do 
		v:SetGroundEntity( NULL )
		v:SetGravity(-0.1)
	end
	return
end,
function(self, args)
	-- End of ACT
	for k,v in pairs(player.GetAll()) do 
		v:SetGravity(1)
	end
end)
registerTrigger("touchsky","Think",
function()  
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		if v:GetPos().z > GAMEMODE.GamePool.zsky then
			GAMEMODE:WarePlayerDestinyLose( v )
		end
	end
end)


-- CATCH A BALL MINIGAME

registerMinigame("catchball",
function(self, args)
	--Start of INIT
	GAMEMODE:SetWareWindupAndLength(2,6)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Catch a ball !",0)
	return
	
end,
function(self, args)
	--Start of ACT
	local entposcopy = table.Copy(GAMEMODE:GetEnts(ENTS_ONCRATE)) --Copying the table, and the removing elements from it
	local numberSpawns = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*0.5),1,table.Count(entposcopy))
	
	for i = 0, numberSpawns - 1 do
		// table.sort(entposcopy,function(a,b) return a:EntIndex() < b:EntIndex() end) --Making sure the table doesnt have holes
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
end,
function(self, args)
	-- End of ACT

end)

registerTrigger("catchball","GravGunOnPickedUp",
function(pl, ent)  
	if ent:GetClass() == "ware_catchball" && ent:GetNWBool( "usable" ) == true then
		GAMEMODE:WarePlayerDestinyWin( pl )
		ent:SetUnusable()
	end
end)

-- TRY TO CLIMB ON THE BOXES MINIGAME

registerMinigame("tryclimb",
function(self, args)
	--Start of INIT
	GAMEMODE:SetWareWindupAndLength(2,6)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Try to climb on the boxes !",0)
	return
	
end,
function(self, args)
	--Start of ACT
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:SetEyeAngles( Angle( 0,0,180 ) )
	end
	
	return
end,
function(self, args)
	-- End of Act
	for k,v in pairs(player.GetAll()) do 
		v:SetEyeAngles( Angle(0,0,0))
	end
end)
registerTrigger("tryclimb","Think",
function() 
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
end)

