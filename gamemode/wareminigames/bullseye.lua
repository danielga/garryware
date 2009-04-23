WARE.Author = "Hurricaaane (Ha3)"

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(1.5,8)
	
	GAMEMODE.GamePool.TimesToHit = math.random(2,5)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Hit the bullseye exactly "..GAMEMODE.GamePool.TimesToHit.." times !",1)
	
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "gmdm_pistol" )
		v:GiveAmmo( 12, "Pistol", true )	
		v:SetNWInt("timeshit",0)
	end
	
	return
end

function WARE:StartAction()
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
end

function WARE:EndAction()

end

function WARE:Think( )
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		local timeshit = v:GetNWInt("timeshit",0)
		if timeshit == GAMEMODE.GamePool.TimesToHit then
			v:SetAchievedNoDestiny( 1 )
		elseif timeshit > GAMEMODE.GamePool.TimesToHit then
			v:WarePlayerDestinyLose( )
		else
			v:SetAchievedNoDestiny( 0 )
		end
	end
end
