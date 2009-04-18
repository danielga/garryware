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
registerTrigger("climb","Think",function()  
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
registerTrigger("touchsky","Think",function()  
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		if v:GetPos().z > GAMEMODE.GamePool.zsky then
			GAMEMODE:WarePlayerDestinyLose( v )
		end
	end
end)


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
end,function(self, args)
	-- End of ACT

end)

registerTrigger("catchball","GravGunOnPickedUp",function(pl, ent)  
	GAMEMODE:WarePlayerDestinyWin( pl )
end)

-- CROUCH MINIGAME

--Useful function to spawn a crouchball
/*
function WARESpawnCrouchBall(pos)
	local ent = ents.Create ("ware_crouchball");
	ent:SetPos(pos);
	ent:Spawn();
	GAMEMODE:AppendEntToBin(ent)
	GAMEMODE:MakeAppearEffect(ent:GetPos())
	local crouch = math.random(0,4)
	
	if crouch >= 3 then 
		ent:SetColor(math.random(100,255),math.random(100,255),0,255)
		ent:SetNWBool("crouch", false)
	else
		ent:SetColor(0,0,255,255)
		ent:SetNWBool("crouch", true)
	end
	mess=GAMEMODE.GamePool.Fake[math.random(1,table.Count(GAMEMODE.GamePool.Fake))]
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:PrintMessage( HUD_PRINTCENTER, mess )
	end
	
	
	return
end

registerMinigame("crouch",function(self, args)
	--Start of INIT
	GAMEMODE.GamePool.NbBall = math.random(4,8)
	GAMEMODE.GamePool.Fake = {"To crouch or no to crouch ?","I think you should crouch...","Crouch !","Look ! It's a blue one !","You may have to crouch next time.","Don't crouch this time !"}
	GAMEMODE:SetWareWindupAndLength( 4, GAMEMODE.GamePool.NbBall/2 + 2 )
	GAMEMODE:DrawPlayersTextAndInitialStatus("Crouch only when a blue ball hit the ground !",1)
	return
	
end,function(self, args)
	--Start of ACT
	local entposcopy = table.Copy(GAMEMODE:GetEnts(ENTS_INAIR)) --Copying the table, and the removing elements from it

	local posCenter = Vector(0,0,0)
	for k,v in pairs(entposcopy) do
		posCenter = posCenter + v:GetPos()	
		table.remove( entposcopy, k )
	end
	posCenter = posCenter/table.Count(entposcopy)
	
	for i = 0, GAMEMODE.GamePool.NbBall do
		timer.Simple(i/2,WARESpawnCrouchBall,posCenter)
	end
	
	
	return
end,function(self, args)
	-- End of ACT

end)
*/

