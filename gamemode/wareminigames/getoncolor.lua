WARE.Author = "Hurricaaane (Ha3)"

WARE.PossibleColors = {
{ "black" , Color(0,0,0,255) },
{ "grey" , Color(138,138,138,255), Color(255,255,255,255) },
{ "white" , Color(255,255,255,255), Color(0,0,0,255) },
{ "red" , Color(220,0,0,255) },
{ "green" , Color(0,220,0,255) },
{ "blue" , Color(64,64,255,255) },
{ "pink" , Color(255,0,255,255) }
}
 
WARE.Props = {}

WARE.TheProp = nil
WARE.CircleRadius = 64

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(0.7,5)
	
	self.Props = {}
	
	local spawnedcolors = {}
	local magicCopy = {}
	for k=1,#self.PossibleColors do
		magicCopy[k] = k
	end
	
	local ratio = 0.5
	local minimum = 3
	local num = math.Clamp(math.ceil(team.NumPlayers(TEAM_HUMANS) * ratio), minimum, #self.PossibleColors)
	local entposcopy = GAMEMODE:GetRandomLocations(num, ENTS_CROSS)
	
	for k,v in pairs(entposcopy) do
		local chosenColor = math.random(1, #magicCopy)
		local colorID = table.remove( magicCopy , chosenColor )
		table.insert(spawnedcolors, colorID)
		
		local ent = ents.Create("ware_ringzone")
		ent:SetPos(v:GetPos() + Vector(0,0,8) )
		ent:SetAngles( Angle(0,0,0) )
		ent:Spawn()
		ent:Activate()
		
		GAMEMODE:AppendEntToBin(ent)
		
		table.insert( self.Props , ent )
		
		ent.ColorID = colorID
		
		ent:SetZSize(self.CircleRadius * 2.0)
		ent:SetZColor(self.PossibleColors[colorID][2])

		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
	
	local selected = table.Random(spawnedcolors)
	self.SelectedColorID = selected
	
	for k,prop in pairs( self.Props ) do
		if prop.ColorID == self.SelectedColorID then
			self.TheProp = prop
			break
		end
	end
	
	GAMEMODE:SetPlayersInitialStatus( false )
	GAMEMODE:DrawInstructions( "Get on the ".. self.PossibleColors[selected][1] .." circle !" , self.PossibleColors[selected][2] or nil, self.PossibleColors[selected][3] or nil )
	
end

function WARE:StartAction()
	for _,ply in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		ply:Give("ware_weap_crowbar")
	end
	
end

function WARE:EndAction()
	if ValidEntity( self.TheProp ) then
		GAMEMODE:MakeLandmarkEffect( self.TheProp:GetPos() )
	end
end
		

function WARE:Think( )
	for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		v:SetAchievedNoLock( false )
	end
	
	for _,target in pairs( ents.FindInSphere(self.TheProp:GetPos() , self.CircleRadius) ) do
		if target:IsPlayer() and target:IsWarePlayer() then
			target:SetAchievedNoLock( true )
		end
	end
end
