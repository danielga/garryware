function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(1.5,8)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Avoid the balls !",1)
	
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "weapon_physcannon" )
	end
	
	return
end

function WARE:StartAction()
	local ratio = 1.1
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
end

function WARE:EndAction()

end
