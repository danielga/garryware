registerMinigame("calc",function(self, args)
	--Start of INIT
	GAMEMODE:SetWareWindupAndLength(0,8)
	
	local a = math.random(10,99)
	local b = math.random(10,99)
	GAMEMODE.GamePool.WareSolution = a + b
	GAMEMODE:DrawPlayersTextAndInitialStatus("Calculate and say : "..a.." + "..b.." = ?",0)
	return
	
end,function(self, args)
	--Start of ACT
	return
end,function(self, args)
	for k,v in pairs(player.GetAll()) do 
		v:ChatPrint( "Answer was "..GAMEMODE.GamePool.WareSolution.." !" )  
	end
end)
registerTrigger("calc","PlayerSay",function(ply, text, say)
	if text == tostring(GAMEMODE.GamePool.WareSolution) then
		GAMEMODE:WarePlayerDestinyWin( ply )
		for k,v in pairs(player.GetAll()) do 
			v:ChatPrint( ply:GetName() .. " has found the correct answer !" )  
		end
		return false
	else
		GAMEMODE:WarePlayerDestinyLose( ply )
	end
end)




registerMinigame("chair",function(self, args)
	--Start of INIT
	GAMEMODE:SetWareWindupAndLength(0.7,6)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Break 1 chair !",0)
	return
	
end,function(self, args)
	--Start of ACT
	local entposcopy = table.Copy(GAMEMODE:GetEnts(ENTS_ONCRATE)) --Copying the table, and the removing elements from it
	local numberSpawns = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*0.5),1,table.Count(entposcopy))
	
	for i = 0, numberSpawns - 1 do
		//table.sort(entposcopy,function(a,b) return a:EntIndex() < b:EntIndex() end) --Making sure the table doesnt have holes
		local iselect = math.random(1,table.Count(entposcopy))
		local v = entposcopy[iselect]
		
		local ent = ents.Create ("prop_physics");
		ent:SetModel ("models/props_c17/FurnitureChair001a.mdl");
		ent:SetPos(v:GetPos()+Vector(0,0,24));
		ent:SetAngles(Angle(0,math.Rand(0,360),0) );
		ent:Spawn(); 
		
		table.remove( entposcopy, iselect )
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
	local rand = math.random(1,2)
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		if rand == 1 then
			v:Give( "gmdm_pistol" )
			v:GiveAmmo( 12, "Pistol", true )	
		elseif rand == 2 then
			v:Give( "weapon_crowbar" )
		end
	end
	return
end)
registerTrigger("chair","PropBreak",function( killer, prop )
	if killer:IsPlayer() then
		GAMEMODE:WarePlayerDestinyWin( killer )
	end
end)  




registerMinigame("dontmove",function(self, args)
	--Start of INIT
	GAMEMODE:SetWareWindupAndLength(3.5,2)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Don't move !",1)
	return
	
end,function(self, args)
	--Start of ACT
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "ware_weap_crowbar" )
	end
	return
end)
registerTrigger("dontmove","Think",function( )
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		if (v:GetVelocity():Length() > 16) then GAMEMODE:WarePlayerDestinyLose( v ) end
	end
end)




registerMinigame("weirdo",function(self, args)
	--Start of INIT
	GAMEMODE:SetWareWindupAndLength(0.7,6)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Punt the big crate !",0)
	return
	
end,function(self, args)
	--Start of ACT
	
	for k,v in pairs(GAMEMODE:GetEnts(ENTS_ONCRATE)) do
		local ent = ents.Create ("prop_physics");
		ent:SetModel ("models/props_junk/wood_crate001a.mdl");
		ent:SetPos(v:GetPos()+Vector(0,0,64));
		ent:SetAngles(Angle(0,math.Rand(0,360),0) );
		ent:Spawn(); 
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
	local entw = table.Random(ents.FindByClass("prop_physics"))
	local entw2 = ents.Create ("prop_physics");
	entw2:SetModel ("models/props_junk/wood_crate002a.mdl");
	entw2:SetPos(entw:GetPos()+Vector(0,0,64));
	entw2:SetAngles(Angle(0,math.Rand(0,360),0) );
	entw2:SetNWInt("isweirdo",1)
	entw:Remove()
	entw2:Spawn(); 
	GAMEMODE:AppendEntToBin(entw2)
	entw2:SetHealth(100000)
	
	local land = ents.Create ("gmod_landmarkonremove");
	land:SetPos(entw2:GetPos());
	land:SetParent(entw2);
	land:Spawn(); 
	GAMEMODE:AppendEntToBin(land)
	
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "weapon_physcannon" )
	end
	return
end)
registerTrigger("weirdo","GravGunPunt",function( ply, target )
	if target:GetNWInt("isweirdo",0) == 1 then
		GAMEMODE:WarePlayerDestinyWin( ply )
	else
		GAMEMODE:WarePlayerDestinyLose( ply )
	end
end)




registerMinigame("findthemissing",function(self, args)
	--Start of INIT
	GAMEMODE:SetWareWindupAndLength(5,5)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Watch the props...",0)
	
	local entposcopy = 	table.Copy(GAMEMODE:GetEnts(ENTS_ONCRATE)) --Copy the ents to remove entries
	local numberSpawns = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*0.6),3,table.Count(entposcopy))
	for i = 1, numberSpawns do
		//table.sort(entposcopy,function(a,b) return a:EntIndex() < b:EntIndex() end) --Making sure the table doesnt have holes
		local iselect = math.random(1,table.Count(entposcopy))
		local v = entposcopy[iselect]
		
		local ent = ents.Create ("prop_physics");
		ent:SetModel ("models/props_c17/FurnitureWashingmachine001a.mdl");
		ent:SetPos(v:GetPos()+Vector(0,0,32));
		ent:SetAngles(Angle(0,math.Rand(0,360),0) );
		ent:Spawn(); 
		ent:SetNWEntity("parpoint",v)
		
		table.remove( entposcopy, iselect )
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
	return
	
end,function(self, args)
	--Start of ACT
	local entw = table.Random(ents.FindByClass("prop_physics"))
	GAMEMODE.GamePool.MissingEnt = entw:GetNWEntity("parpoint")
	entw:Remove()
	
	local land = ents.Create ("gmod_landmarkonremove");
	land:SetPos(GAMEMODE.GamePool.MissingEnt:GetPos());
	land:Spawn(); 
	GAMEMODE:AppendEntToBin(land)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Stand on the missing prop !",0)
	return
end)
registerTrigger("findthemissing","Think",function( )
	local sphere = ents.FindInSphere(GAMEMODE.GamePool.MissingEnt:GetPos(),32)
	for _,target in pairs(sphere) do
		if target:IsPlayer() then
			GAMEMODE:WarePlayerDestinyWin( target )
		end
	end
end)



registerMinigame("avoidball",function(self, args)
	--Start of INIT
	GAMEMODE:SetWareWindupAndLength(1.5,8)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Avoid the balls !",1)
	
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "weapon_physcannon" )
	end
	
	return
	
end,function(self, args)
	--Start of ACT
	local entposcopy = 	table.Copy(GAMEMODE:GetEnts(ENTS_INAIR)) --Copy the ents to remove entries
	local numberSpawns = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*3),3,table.Count(entposcopy))
	for i = 1, numberSpawns do
		//table.sort(entposcopy,function(a,b) return a:EntIndex() < b:EntIndex() end) --Making sure the table doesnt have holes
		local iselect = math.random(1,table.Count(entposcopy))
		local v = entposcopy[iselect]
		
		local ent = ents.Create ("ware_avoidball");
		ent:SetPos(v:GetPos());
		ent:Spawn();
		
		local phys = ent:GetPhysicsObject()
		phys:ApplyForceCenter (VectorRand() * 512);
		
		table.remove( entposcopy, iselect )
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
	return
end)


registerMinigame("bullseye",function(self, args)
	--Start of INIT
	GAMEMODE:SetWareWindupAndLength(1.5,8)
	
	GAMEMODE.GamePool.TimesToHit = math.random(2,5)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Hit the bullseye exactly "..GAMEMODE.GamePool.TimesToHit.." times !",1)
	
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "gmdm_pistol" )
		v:GiveAmmo( 12, "Pistol", true )	
		v:SetNWInt("timeshit",0)
	end
	
	return
	
end,function(self, args)
	--Start of ACT
	local entposcopy = 	table.Copy(GAMEMODE:GetEnts(ENTS_OVERCRATE)) --Copy the ents to remove entries
	local numberSpawns = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*0.3),1,table.Count(entposcopy))
	for i = 1, numberSpawns do
		//table.sort(entposcopy,function(a,b) return a:EntIndex() < b:EntIndex() end) --Making sure the table doesnt have holes
		local iselect = math.random(1,table.Count(entposcopy))
		local v = entposcopy[iselect]
		
		local ent = ents.Create ("ware_bullseye");
		ent:SetPos(v:GetPos());
		ent:Spawn();
		
		local phys = ent:GetPhysicsObject()
		phys:ApplyForceCenter (VectorRand() * 16);
		
		table.remove( entposcopy, iselect )
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
	return
end)
registerTrigger("bullseye","Think",function( )
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		local timeshit = v:GetNWInt("timeshit",0)
		if timeshit == GAMEMODE.GamePool.TimesToHit then
			v:SetAchievedNoDestiny( 1 )
		elseif timeshit > GAMEMODE.GamePool.TimesToHit then
			GAMEMODE:WarePlayerDestinyLose(v)
		else
			v:SetAchievedNoDestiny( 0 )
		end
	end
end)
