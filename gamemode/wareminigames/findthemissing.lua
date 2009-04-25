WARE.Author = "Hurricaaane (Ha3)"

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(5,6)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Watch the props...",0)
	
	local ratio = 0.8
	local minimum = 4
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
end

function WARE:StartAction()
	self.MissingEnts = {}
	local ratio = 0.25
	local minimum = 1
	local num = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*ratio),minimum,64)
	local entws = GAMEMODE:GetRandomLocations(num,ents.FindByModel("models/props_c17/furniturewashingmachine001a.mdl"))
	
	for k,v in pairs(entws) do
		table.insert(self.MissingEnts,v:GetNWEntity("parpoint"))
		v:Remove()
		local land = ents.Create ("gmod_landmarkonremove");
		land:SetPos(v:GetPos());
		land:Spawn();
		GAMEMODE:AppendEntToBin(land)
	end
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Stand on a missing prop !",0)
	return
end

function WARE:EndAction()

end

function WARE:Think( )
	for k,v in pairs(self.MissingEnts) do
		local missentpos = v:GetPos()
		local box = ents.FindInBox(missentpos+Vector(-30,-30,0),missentpos+Vector(30,30,64))
		for _,target in pairs(box) do
			if target:IsPlayer() then
				target:WarePlayerDestinyWin( )
			end
		end
	end
end
