WARE.Author = "Hurricaaane (Ha3)"

WARE.Models = {
"models/props_c17/furniturechair001a.mdl",
"models/props_c17/chair_office01a.mdl",
"models/props_c17/chair_stool01a.mdl",
"models/props_wasteland/controlroom_chair001a.mdl"
 }

function WARE:GetModelList()
	return self.Models
end

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(0.7,6)
	
	GAMEMODE:SetPlayersInitialStatus( false )
	GAMEMODE:DrawInstructions( "Break a chair !" )
end

function WARE:StartAction()

	local entsTable = GAMEMODE:GetEnts(ENTS_ONCRATE)
	
	local ratio = 0.5
	local minimum = 1
	local numRealChairs = math.Clamp( math.ceil(team.NumPlayers(TEAM_HUMANS)*ratio) , minimum, 64)
	
	local invNumPropsToSpawn = #entsTable - math.Clamp( math.Clamp( math.ceil(#entsTable * 0.7) , minimum, 64), 1, 3 )
	for k=1,invNumPropsToSpawn do
		table.remove(entsTable, math.random(1, #entsTable) )
	end
	
	for k=1,numRealChairs do
		local myLocation = table.remove(entsTable, math.random(1, #entsTable) )
	
		local ent = ents.Create("prop_physics")
		ent:SetModel( self.Models[1] )
		ent:SetPos( myLocation:GetPos() + Vector(0,0,64) )
		ent:SetAngles( Angle(0, math.Rand(0,360), 0) )
		ent:Spawn()
		ent:SetHealth(15)
		
		ent.ValidDetProp = true
		
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
	
	for k=1,#entsTable do
		local myLocation = table.remove(entsTable, math.random(1, #entsTable) )
	
		local ent = ents.Create("prop_physics")
		ent:SetModel( self.Models[ math.random(2, #self.Models) ] )
		ent:SetPos( myLocation:GetPos() + Vector(0,0,32) )
		ent:SetAngles( Angle(0, math.Rand(0,360), 0) )
		ent:Spawn()
		ent:SetHealth(10000)
		
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
	
	
	
	local useCrowbar = math.random(0,1) > 0
	for k,ply in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		if useCrowbar then
			ply:Give( "gmdm_pistol" )
			ply:GiveAmmo( 12, "Pistol", true )	
		else
			ply:Give( "weapon_crowbar" )
		end
	end
	return
end

function WARE:EndAction()

end

function WARE:PropBreak(killer, prop)
	if not (prop.ValidDetProp) then return end
	
	if killer:IsPlayer() then
		killer:ApplyWin( )
	end
end
