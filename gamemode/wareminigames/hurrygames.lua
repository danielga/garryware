registerMinigame("calc",
--INIT
function(self, args)
	GAMEMODE:SetWareWindupAndLength(0,8)
	
	local a = math.random(10,99)
	local b = math.random(10,99)
	GAMEMODE.GamePool.WareSolution = a + b
	GAMEMODE:DrawPlayersTextAndInitialStatus("Calculate and say : "..a.." + "..b.." = ?",0)
	return
	
end,
--ACT START
function(self, args)
	return
end,
--ACT END
function(self, args)
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




registerMinigame("chair",
--INIT
function(self, args)
	GAMEMODE:SetWareWindupAndLength(0.7,6)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Break 1 chair !",0)
	return
	
end,
--Start of ACT
function(self, args)
	local ratio = 0.5
	local minimum = 1
	local num = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*ratio),minimum,64)
	local entposcopy = GAMEMODE:GetRandomLocations(num, ENTS_ONCRATE)
	for k,v in pairs(entposcopy) do
		local ent = ents.Create ("prop_physics");
		ent:SetModel ("models/props_c17/FurnitureChair001a.mdl");
		ent:SetPos(v:GetPos()+Vector(0,0,24));
		ent:SetAngles(Angle(0,math.Rand(0,360),0) );
		ent:Spawn(); 

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




registerMinigame("dontmove",
--Start of INIT
function(self, args)
	GAMEMODE:SetWareWindupAndLength(3.5,2)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Don't move !",1)
	return
end,
--Start of ACT
function(self, args)
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




registerMinigame("weirdo",
--Start of INIT
function(self, args)
	GAMEMODE:SetWareWindupAndLength(0.7,6)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Punt the big crate !",0)
	return
end,
--Start of ACT
function(self, args)
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




registerMinigame("findthemissing",
--Start of INIT
function(self, args)
	GAMEMODE:SetWareWindupAndLength(5,5)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Watch the props...",0)
	
	local ratio = 0.8
	local minimum = 3
	local num = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*ratio),minimum,64)
	local entposcopy = GAMEMODE:GetRandomLocationsAvoidBox(num, ENTS_ONCRATE, function(v) return v:IsPlayer() end, Vector(-30,-30,0), Vector(30,30,64))
	for k,v in pairs(entposcopy) do
		local ent = ents.Create ("prop_physics");
		ent:SetModel ("models/props_c17/FurnitureWashingmachine001a.mdl");
		ent:SetPos(v:GetPos()+Vector(0,0,32));
		ent:SetAngles(Angle(0,math.Rand(0,360),0) );
		ent:Spawn(); 
		ent:SetNWEntity("parpoint",v)
		
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
	return
	
end,
--Start of ACT
function(self, args)
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
	local missentpos = GAMEMODE.GamePool.MissingEnt:GetPos()
	local box = ents.FindInBox(missentpos+Vector(-30,-30,0),missentpos+Vector(30,30,64))
	for _,target in pairs(box) do
		if target:IsPlayer() then
			GAMEMODE:WarePlayerDestinyWin( target )
		end
	end
end)



registerMinigame("avoidball",
--Start of INIT
function(self, args)
	GAMEMODE:SetWareWindupAndLength(1.5,8)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Avoid the balls !",1)
	
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "weapon_physcannon" )
	end
	
	return
	
end,
--Start of ACT
function(self, args)
	local ratio = 1.5
	local minimum = 3
	local num = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*ratio),minimum,64)
	local entposcopy = GAMEMODE:GetRandomLocations(num, ENTS_INAIR)
	for k,v in pairs(entposcopy) do
		local ent = ents.Create ("ware_avoidball");
		ent:SetPos(v:GetPos());
		ent:Spawn();
		
		local phys = ent:GetPhysicsObject()
		phys:ApplyForceCenter (VectorRand() * 512);
		
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
	return
end)


registerMinigame("bullseye",
--Start of INIT
function(self, args)
	GAMEMODE:SetWareWindupAndLength(1.5,8)
	
	GAMEMODE.GamePool.TimesToHit = math.random(2,5)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Hit the bullseye exactly "..GAMEMODE.GamePool.TimesToHit.." times !",1)
	
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "gmdm_pistol" )
		v:GiveAmmo( 12, "Pistol", true )	
		v:SetNWInt("timeshit",0)
	end
	
	return
	
end,
--Start of ACT
function(self, args)
	local ratio = 0.3
	local minimum = 1
	local num = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*ratio),minimum,64)
	local entposcopy = GAMEMODE:GetRandomLocations(num, ENTS_INAIR)
	for k,v in pairs(entposcopy) do
		local ent = ents.Create ("ware_bullseye");
		ent:SetPos(v:GetPos());
		ent:Spawn();
		
		local phys = ent:GetPhysicsObject()
		phys:ApplyForceCenter (VectorRand() * 16);
		
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


registerMinigame("paparazzi",
--Start of INIT
function(self, args)
	GAMEMODE:SetWareWindupAndLength(2.5,3.5)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Don't get photograph'd !",1)
	return
end,
--Start of ACT
function(self, args)
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "ware_camera" )
	end
	return
end)
