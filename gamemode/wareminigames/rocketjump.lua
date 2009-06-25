WARE.Author = "Hurricaaane (Ha3)"
WARE.Room = "empty"

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(1,9)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Look up !",0)
	return
end

function WARE:StartAction()
	GAMEMODE:DrawPlayersTextAndInitialStatus("Rocketjump onto a plate !",0)
	
	for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		v:Give( "ware_weap_rocketjump" )
	end
	
	local ratio = 0.3
	local minimum = 1
	local num = math.Clamp(math.ceil(team.NumPlayers(TEAM_HUMANS)*ratio),minimum,64)
	
	local entposcopy = GAMEMODE:GetRandomLocations(num,"dark_inair")
	for k,v in pairs(entposcopy) do
		local platform = ents.Create("prop_physics")
		platform:SetModel("models/props_lab/blastdoor001b.mdl")
		platform:SetPos(v:GetPos() + Vector(0,0,-140))
		platform:SetAngles(Angle(90,0,0))
		platform:Spawn()
		platform:SetColor(255,0,0,255)
		platform:GetPhysicsObject():EnableMotion(false)
		
		GAMEMODE:AppendEntToBin(platform)
		GAMEMODE:MakeAppearEffect(platform:GetPos())
	end
	return
end

function WARE:EndAction()

end

function WARE:Think()
	for _,v in pairs(ents.FindByClass("player")) do
		local ent = v:GetGroundEntity()
		if ent and ent:IsValid() and ent:GetModel()=="models/props_lab/blastdoor001b.mdl" then
			v:WarePlayerDestinyWin( )
		end
	end
end