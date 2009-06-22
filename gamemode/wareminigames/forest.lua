WARE.Author = "Kilburn"
WARE.Room = "forest"

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(0.7,6)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Find a chair !",0)
	return
end

function WARE:StartAction()

	local ratio = 0.5
	local minimum = 1
	local num = math.Clamp(math.ceil(team.NumPlayers(TEAM_HUMANS)*ratio),minimum,64)
	local entposcopy = GAMEMODE:GetRandomLocations(num, "ground")
	for k,v in pairs(entposcopy) do
		local ent = ents.Create ("prop_physics")
		ent:SetModel ("models/props_c17/FurnitureChair001a.mdl")
		ent:SetPos(v:GetPos()+Vector(0,0,24))
		ent:SetAngles(Angle(0,math.Rand(0,360),0) )
		ent:Spawn()

		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
	local rand = math.random(1,2)
	for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		if rand == 1 then
			v:Give( "gmdm_pistol" )
			v:GiveAmmo( 12, "Pistol", true )	
		elseif rand == 2 then
			v:Give( "weapon_crowbar" )
		end
	end
	return
end

function WARE:EndAction()

end

function WARE:PropBreak(killer, prop)
	if killer:IsPlayer() then
		killer:WarePlayerDestinyWin( )
	end
end
