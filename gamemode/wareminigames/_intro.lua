WARE.Author = ""

function WARE:IsPlayable()
	return false
end

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(4, 6)
	
	GAMEMODE:SetPlayersInitialStatus( true )
	GAMEMODE:DrawInstructions( "A new GarryWare game starts!" )
	
	self.Entground = GAMEMODE:GetEnts(ENTS_CROSS)
	umsg.Start("SpecialFlourish")
		umsg.Char( math.random(1, #GAMEMODE.WASND.TBL_GlobalWareningEnding ) )
	umsg.End()
	
	for k,ply in pairs(team.GetPlayers(TEAM_HUMANS)) do
		ply:SetAchievedSpecialInteger( -1 )
		ply:SetLockedSpecialInteger( 1 )
	end
end

local function spawnModel( iModel , modelCount , delay )
	local pos = GAMEMODE:GetRandomPositions(1, ENTS_INAIR)[1]
	
	local ent = ents.Create ("prop_physics_override")
	ent:SetModel ( GAMEMODE.ModelPrecacheTable[iModel] )
	ent:SetPos( pos )
	ent:SetAngles( VectorRand():Angle() )
	ent:Spawn()
	ent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	local physObj = ent:GetPhysicsObject()
	if physObj:IsValid() then
		physObj:ApplyForceCenter( VectorRand() * math.random( 256, 468 ) * physObj:GetMass() )
	end
	
	GAMEMODE:MakeAppearEffect( ent:GetPos() )
	GAMEMODE:AppendEntToBin( ent )
	
	if (iModel < modelCount) then
		timer.Simple( delay, spawnModel , iModel + 1 , modelCount , delay )
	end
end

function WARE:StartAction()
	GAMEMODE:DrawInstructions( "Rules are easy : Do what it tells you to do!" )
	local modelCount = #GAMEMODE.ModelPrecacheTable
	
	if modelCount > 0 then
		local delay = 4.0 / modelCount
		spawnModel( 1 , modelCount, delay )
	end
	
	for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		v:Give( "weapon_physcannon" )
	end
end

function WARE:EndAction()
	GAMEMODE:DrawInstructions( "Game begins now ! Have fun!" )

end

function WARE:Think()	

end