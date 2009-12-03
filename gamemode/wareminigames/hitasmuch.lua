WARE.Author = "Hurricaaane (Ha3)"

WARE.EndingColor = Color(0,0,0,255)

function WARE:IsPlayable()
	if team.NumPlayers(TEAM_HUMANS) >= 2 then
		return true
	end
	
	return false
end

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(1.5, 8)
	
	self.MostTimesHit = 2
	
	GAMEMODE:SetPlayersInitialStatus( false )
	GAMEMODE:DrawInstructions( "Hit the bullseye most times !" )
	
	for k,ply in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		ply:Give( "sware_pistol" )
		ply:GiveAmmo( 12, "Pistol", true )	
		ply.BULLSEYE_Hit = 0
	end
	
end

function WARE:StartAction()
	local ratio = 0.3
	local minimum = 1
	local num = math.Clamp(math.ceil(team.NumPlayers(TEAM_HUMANS) * ratio), minimum, 64)
	local entposcopy = GAMEMODE:GetRandomPositions(num, ENTS_INAIR)
	
	for k,pos in pairs(entposcopy) do
		local ent = ents.Create("ware_bullseye")
		ent:SetPos(pos)
		ent:Spawn()
		
		local phys = ent:GetPhysicsObject()
		phys:ApplyForceCenter(VectorRand() * 16)
		
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
	
end

function WARE:EndAction()
	if (self.MostTimesHit > 2) then
		GAMEMODE:DrawInstructions( "It was hit ".. self.MostTimesHit .." times !", self.EndingColor )
		
	else
		GAMEMODE:DrawInstructions( "No one hit it enough !", self.EndingColor )
		
	end
end

function WARE:Think( )
	for k,ply in pairs(team.GetPlayers(TEAM_HUMANS)) do 
	
		if ply.BULLSEYE_Hit > self.MostTimesHit then
			self.MostTimesHit = ply.BULLSEYE_Hit
		end
		
	end

	for k,ply in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		local timesHit = ply.BULLSEYE_Hit
		
		if (self.MostTimesHit > 2) and (timesHit == self.MostTimesHit) then
			ply:SetAchievedNoLock( true )
			
		else
			ply:SetAchievedNoLock( false )
		end
	end
	
end
