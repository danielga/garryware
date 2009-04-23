WARE.Author = "Kilburn"

local function ResetFlashCrate(prop)
	if not(prop and prop:IsValid()) then return end
	prop:SetColor(255,255,255,255)
end

local function FlashCrate(prop)
	if not(prop and prop:IsValid()) then return end
	prop:SetColor(255,255,255,50)
	timer.Simple(0.2, ResetFlashCrate, prop)
end

local MelonCratesFakeProps = {
	"models/props_junk/plasticbucket001a.mdl",
	"models/props_junk/metalbucket01a.mdl",
	"models/props_junk/propanecanister001a.mdl",
	"models/props_combine/breenglobe.mdl",
}

-----------------------------------------------------------------------------------

function WARE:Initialize()
	local maxcount = table.Count(GAMEMODE:GetEnts(ENTS_ONCRATE))
	
	local numberMelonSpawns = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*0.5),1,maxcount)
	local numberFakeSpawns = math.Clamp(team.NumPlayers(TEAM_UNASSIGNED)+1,4,maxcount-numberMelonSpawns)
	
	local delay = 2
	
	GAMEMODE:SetWareWindupAndLength(delay+1,6)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Watch the crates...",0)
	
	for i,pos in ipairs(GAMEMODE:GetRandomPositions(numberMelonSpawns+numberFakeSpawns, ENTS_ONCRATE)) do
		pos = pos + Vector(0,0,100)
		
		local prop = ents.Create("prop_physics")
		prop:SetModel("models/props_junk/wood_crate001a.mdl")
		prop:PhysicsInit(SOLID_VPHYSICS)
		prop:SetSolid(SOLID_VPHYSICS)
		prop:SetPos(pos)
		prop:Spawn()
		
		prop:SetMoveType(MOVETYPE_NONE)
		
		GAMEMODE:AppendEntToBin(prop)
		GAMEMODE:MakeAppearEffect(pos)
		
		local model
		
		if i<=numberMelonSpawns then
			model = "models/props_junk/watermelon01.mdl"
		else
			-- model = nil if math.random returns 0, so we have an empty crate
			model = MelonCratesFakeProps[math.random(0,#MelonCratesFakeProps)]
		end
		
		if model then
			local prop2 = ents.Create("prop_physics")
			prop2:SetModel(model)
			prop2:PhysicsInit(SOLID_VPHYSICS)
			prop2:SetSolid(SOLID_VPHYSICS)
			prop2:SetPos(pos)
			prop2:SetAngles(Angle(math.random(-180,180),math.random(-180,180),math.random(-180,180)))
			prop2:Spawn()
			
			prop2:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			prop2:SetMoveType(MOVETYPE_VPHYSICS)
			prop2:GetPhysicsObject():EnableMotion(false)
			GAMEMODE:AppendEntToBin(prop2)
			
			prop.Contents = prop2
		end
		
		timer.Simple(delay, FlashCrate, prop)
	end
end

function WARE:StartAction()
	GAMEMODE:DrawPlayersTextAndInitialStatus("Break a melon ! ",0)
	
	for _,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give("weapon_crowbar")
	end
end

function WARE:EndAction()
	
end

function WARE:PropBreak(pl,prop)
	if not pl:IsPlayer() then return end
	
	if prop:GetModel()=="models/props_junk/watermelon01.mdl" then
		pl:WarePlayerDestinyWin( )
		pl:StripWeapons()
	elseif prop.Contents then
		prop.Contents:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		prop.Contents:GetPhysicsObject():EnableMotion(true)
		prop.Contents:GetPhysicsObject():Wake()
	end
end
