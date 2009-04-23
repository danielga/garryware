local CrateColours = {
	{1,0,0},
	{0,1,0},
	{0,0,1},
	{1,1,0},
	{1,0,1},
	{0,1,1},
}

local CratePitches = {
	262,
	294,
	330,
	349,
	392,
	440,
}

local function ResetCrate(i)
	if not GAMEMODE.GamePool.Crates then return end
	
	local prop = GAMEMODE.GamePool.Crates[i]
	if not(prop and prop:IsValid()) then return end
	
	local col = CrateColours[i]
	
	prop:SetColor(col[1]*100, col[2]*100, col[3]*100, 100)
end

local function PlayCrate(i)
	if not GAMEMODE.GamePool.Crates then return end
	
	local prop = GAMEMODE.GamePool.Crates[i]
	if not(prop and prop:IsValid()) then return end
	
	local col = CrateColours[i]
	
	prop:SetColor(col[1]*255, col[2]*255, col[3]*255, 255)
	prop:SetHealth(100000)
	prop:EmitSound("buttons/button17.wav", 100, CratePitches[i]/3)
	
	timer.Simple(0.5, ResetCrate, i)
end

-----------------------------------------------------------------------------------

function WARE:Initialize()
	local numberSpawns = 5
	local delay = 4
	
	GAMEMODE:SetWareWindupAndLength(numberSpawns+delay,numberSpawns)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Watch carefully !",0)
	
	GAMEMODE.GamePool.Crates = {}
	
	for i,pos in ipairs(GAMEMODE:GetRandomPositions(numberSpawns, ENTS_ONCRATE)) do
		local col = CrateColours[i]
		local prop = ents.Create("prop_physics")
		prop:SetModel("models/props_junk/wood_crate001a.mdl")
		prop:PhysicsInit(SOLID_VPHYSICS)
		prop:SetSolid(SOLID_VPHYSICS)
		prop:SetPos(pos+Vector(0,0,64))
		prop:Spawn()
		
		prop:SetColor(col[1]*100, col[2]*100, col[3]*100, 100)
		prop:SetHealth(100000)
		prop:SetMoveType(MOVETYPE_NONE)
		prop:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		prop.CrateID = i
		
		GAMEMODE.GamePool.Crates[i] = prop
		
		GAMEMODE:AppendEntToBin(prop)
		GAMEMODE:MakeAppearEffect(pos)
	end
	
	local sequence = {}
	for i=1,numberSpawns do sequence[i]=i end
	
	GAMEMODE.GamePool.Sequence = {}
	for i=1,numberSpawns do
		GAMEMODE.GamePool.Sequence[i] = table.remove(sequence, math.random(1,#sequence))
		timer.Simple(delay+i-1, PlayCrate, GAMEMODE.GamePool.Sequence[i])
	end
end

function WARE:StartAction()
	GAMEMODE:DrawPlayersTextAndInitialStatus("Repeat ! ",0)
	
	GAMEMODE.GamePool.PlayerCurrentCrate = {}
	
	for _,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give("gmdm_pistol")
		v:GiveAmmo(12, "Pistol", true)
		GAMEMODE.GamePool.PlayerCurrentCrate[v] = 1
	end
end

function WARE:EndAction()
	
end

function WARE:EntityTakeDamage(ent,inf,att,amount,info)
	local pool = GAMEMODE.GamePool
	
	if not att:IsPlayer() or not info:IsBulletDamage() then return end
	if not pool.PlayerCurrentCrate[att] then return end
	if not pool.Crates or not ent.CrateID then return end
	
	PlayCrate(ent.CrateID)
	
	if pool.Sequence[pool.PlayerCurrentCrate[att]] == ent.CrateID then
		pool.PlayerCurrentCrate[att] = pool.PlayerCurrentCrate[att] + 1
		if not pool.Sequence[pool.PlayerCurrentCrate[att]] then
			GAMEMODE:WarePlayerDestinyWin(att)
			att:StripWeapons()
		end
	else
		GAMEMODE:WarePlayerDestinyLose(att)
		att:StripWeapons()
	end
end
