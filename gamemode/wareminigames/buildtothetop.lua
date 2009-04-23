local function RespawnSawblade(ent)
	if not ent or not ent:IsValid() or not ent.OriginalPos then return end
	
	local saw = ents.Create ("prop_physics")
	saw:SetModel("models/props_junk/sawblade001a.mdl")
	saw:SetPos(ent.OriginalPos)
	saw:SetAngles(Angle(0,0,0))
	saw:Spawn()
	
	GAMEMODE:AppendEntToBin(saw)
	GAMEMODE:MakeAppearEffect(saw:GetPos())
end

-----------------------------------------------------------------------------------

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(2,14)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Punt a sawblade to freeze it",0)
	
	for k,v in pairs(GAMEMODE:GetEnts(ENTS_ONCRATE)) do
		local saw = ents.Create ("prop_physics")
		saw:SetModel("models/props_junk/sawblade001a.mdl")
		saw:SetPos(v:GetPos()+Vector(0,0,100))
		saw:SetAngles(Angle(0,0,0))
		saw:Spawn()
		
		saw.OriginalPos = v:GetPos()+Vector(0,0,100)
		
		GAMEMODE:AppendEntToBin(saw)
		GAMEMODE:MakeAppearEffect(saw:GetPos())
	end
	
	for _,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give("weapon_physcannon")
	end
end

function WARE:StartAction()
	GAMEMODE:DrawPlayersTextAndInitialStatus("Get on the red platform !",0)
	
	local numberSpawns = math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*0.75)
	
	for i,pos in ipairs(GAMEMODE:GetRandomPositions(numberSpawns, ENTS_INAIR)) do
		local platform = ents.Create("prop_physics")
		platform:SetModel("models/props_lab/blastdoor001b.mdl")
		platform:SetPos(pos+Vector(0,0,-140))
		platform:SetAngles(Angle(90,0,0))
		platform:Spawn()
		platform:SetColor(255,0,0,255)
		platform:GetPhysicsObject():EnableMotion(false)
		
		GAMEMODE:AppendEntToBin(platform)
		GAMEMODE:MakeAppearEffect(platform:GetPos())
	end
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

function WARE:GravGunPunt(pl,ent)
	if not pl:IsPlayer() then return end
	
	if ent:GetPhysicsObject() and ent:GetPhysicsObject():IsValid() then
		ent:GetPhysicsObject():EnableMotion(false)
		timer.Simple(4,RespawnSawblade,ent)
	end
end
