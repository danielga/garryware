WARE.Author = "Kelth"

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(0.8,6)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Catch a ball !",0)


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

	return
end

function WARE:StartAction()
	
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "weapon_physcannon" )
	end
	
	return
end

function WARE:EndAction()

end

function WARE:GravGunOnPickedUp( pl, ent )
	if ent:GetClass() == "ware_catchball" && ent:GetNWBool( "usable" ) == true then
		pl:WarePlayerDestinyWin( )
		ent:SetUnusable()
	end
end
