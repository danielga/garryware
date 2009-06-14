WARE.Author = "Hurricaaane (Ha3)"

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(0.7,6)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Work as a team !",0)
	
	local ratio = 0.7
	local minimum = 2
	self.Num = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*ratio),minimum,64)
	self.Broke = 0
	
	return
end

function WARE:StartAction()
	local entposcopy = GAMEMODE:GetRandomLocationsAvoidBox(self.Num, ENTS_ONCRATE, function(v) return v:IsPlayer() end, Vector(-30,-30,0), Vector(30,30,64))
	for k,v in pairs(entposcopy) do
		local ent = ents.Create ("prop_physics");
		ent:SetModel ("models/props_junk/wood_crate001a.mdl");
		ent:SetPos(v:GetPos()+Vector(0,0,32));
		ent:SetAngles(Angle(0,math.Rand(0,360),0) );
		ent:Spawn(); 
		ent:SetNWEntity("parpoint",v)
		ent:SetHealth(15)
		
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "weapon_crowbar" )
	end
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Break all crates !",0)
	return
end

function WARE:EndAction()
	if (self.Broke < self.Num) then
		for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
			v:WarePlayerDestinyLose()
		end
	end
end

function WARE:PropBreak(killer, prop)
	if killer:IsPlayer() then
		killer:SetAchievedNoDestiny( 1 )
	end
	self.Broke = self.Broke + 1
	
	if (self.Broke == self.Num) then
		for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
			v:WareApplyDestiny()
		end
	end
end

