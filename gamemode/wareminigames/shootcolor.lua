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

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(0.7,4)
	
	local matchtemp = table.Copy(matchcolors)
	local spawnedcolors = {}
	
	local ratio = 0.5
	local minimum = 4
	local num = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*ratio),minimum,#matchcolors)
	local entposcopy = GAMEMODE:GetRandomLocations(num, ENTS_OVERCRATE)
	for k,v in pairs(entposcopy) do
		local cookie = math.random(1,#matchtemp)
		local color = table.remove(matchtemp,cookie)
		table.insert(spawnedcolors,color)
		
		local ent = ents.Create("prop_physics");
		ent:SetModel("models/props_c17/FurnitureWashingmachine001a.mdl")
		ent:SetPos(v:GetPos())
		ent:SetAngles(Angle(0,math.Rand(0,360),0) );
		ent:Spawn();
		
		ent:SetMaterial("debug/debugwhite")
		ent:GetPhysicsObject():EnableMotion(false)
		GAMEMODE:AppendEntToBin(ent)
		
		ent:SetNWString("selcolor",color[1])
		ent:SetColor(color[2].r, color[2].g, color[2].b, color[2].a)

		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
	
	local selected = table.Random(spawnedcolors)[1]
	GAMEMODE.GamePool.SelectedColor = selected
	
	for k,v in pairs(ents.FindByClass("prop_physics")) do
		if v:GetNWString("color","") == GAMEMODE.GamePool.SelectedColor then
			local land = ents.Create ("gmod_landmarkonremove");
			land:SetPos(v:GetPos());
			land:Spawn();
			GAMEMODE:AppendEntToBin(land)
		end
	end
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Shoot the "..selected.." one !",0)
	return
end

function WARE:StartAction()
	for _,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give("gmdm_pistol")
		v:GiveAmmo(12, "Pistol", true)
	end
	return
end

function WARE:EndAction()

end

function WARE:EntityTakeDamage( ent, inf, att, amount, info )
	local pool = GAMEMODE.GamePool
	
	if att:IsPlayer() == false or info:IsBulletDamage() == false then return end
	if ent:GetNWString("selcolor","") == "" then return end
	
	--print("Someone shot the "..ent:GetNWString("selcolor","").." one...")
	if ent:GetNWString("selcolor","") == GAMEMODE.GamePool.SelectedColor then
		att:WarePlayerDestinyWin( )
		att:StripWeapons()
	else
		att:WarePlayerDestinyLose( )
		att:StripWeapons()
	end
end
