WARE.Author = "Hurricaaane (Ha3)"

local matchcolors = {
{ "black" , Color(0,0,0,255) },
{ "grey" , Color(128,128,128,255) },
{ "white" , Color(255,255,255,255) },
{ "red" , Color(255,0,0,255) },
{ "green" , Color(0,255,0,255) },
{ "blue" , Color(0,0,255,255) },
{ "yellow" , Color(255,255,0,255) },
{ "pink" , Color(255,0,255,255) },
}

WARE.CircleRadius = 64

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(0.7,5)
	
	local matchtemp = table.Copy(matchcolors)
	local spawnedcolors = {}
	
	local ratio = 0.6
	local minimum = 3
	local num = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*ratio),minimum,#matchcolors)
	local entposcopy = GAMEMODE:GetRandomLocations(num, ENTS_CROSS)
	for k,v in pairs(entposcopy) do
		local cookie = math.random(1,#matchtemp)
		local color = table.remove(matchtemp,cookie)
		table.insert(spawnedcolors,color)
		
		local ent = ents.Create("ware_ringzone");
		ent:SetPos(v:GetPos() + Vector(0,0,8) )
		ent:SetAngles(Angle(0,0,0));
		ent:Spawn();
		ent:Activate()
		
		ent:SetZSize(self.CircleRadius*2)
		GAMEMODE:AppendEntToBin(ent)
		
		ent:SetNWString("selcolor",color[1])
		ent:SetZColor(color[2])

		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
	
	local selected = table.Random(spawnedcolors)[1]
	GAMEMODE.GamePool.SelectedColor = selected
	
	for k,v in pairs(ents.FindByClass("ware_ringzone")) do
		if v:GetNWString("selcolor","") == GAMEMODE.GamePool.SelectedColor then
			local land = ents.Create ("gmod_landmarkonremove");
			land:SetPos(v:GetPos());
			land:Spawn();
			GAMEMODE:AppendEntToBin(land)
		end
	end
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Get on the "..selected.." circle !",0)
	return
end

function WARE:StartAction()
	for _,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do
		v:Give( "ware_weap_crowbar" )
	end
	return
end

function WARE:EndAction()

end

function WARE:Think( )
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:SetAchievedNoDestiny(0)
	end
	for k,v in pairs(ents.FindByClass("ware_ringzone")) do
		if v:GetNWString("selcolor","") == GAMEMODE.GamePool.SelectedColor then
			local missentpos = v:GetPos()
			local sphere = ents.FindInSphere(missentpos,self.CircleRadius)
			for _,target in pairs(sphere) do
				if target:IsPlayer() then
					target:SetAchievedNoDestiny(1)
				end
			end
		end
	end
end
