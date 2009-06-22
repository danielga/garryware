WARE.Author = "Hurricaaane (Ha3)"

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(0.7,7.5)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Punt the big crate !",0)
	return
end

function WARE:StartAction()
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
	
	for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		v:Give( "weapon_physcannon" )
	end
	return
end

function WARE:EndAction()

end

function WARE:GravGunPunt( ply, target )
	if target:GetNWInt("isweirdo",0) == 1 then
		ply:WarePlayerDestinyWin( )
	else
		ply:WarePlayerDestinyLose( )
	end
end
