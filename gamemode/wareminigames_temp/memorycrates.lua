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
	
	self:SetWareWindupAndLength(numberSpawns+delay,numberSpawns)
	self:DrawPlayersTextAndInitialStatus("Watch carefully !",0)
	
	self.GamePool.Crates = {}
	
	for i,pos in ipairs(self:GetRandomPositions(numberSpawns, ENTS_ONCRATE)) do
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
		
		self.GamePool.Crates[i] = prop
		
		self:AppendEntToBin(prop)
		self:MakeAppearEffect(pos)
	end
	
	local sequence = {}
	for i=1,numberSpawns do sequence[i]=i end
	
	self.GamePool.Sequence = {}
	for i=1,numberSpawns do
		self.GamePool.Sequence[i] = table.remove(sequence, math.random(1,#sequence))
		timer.Simple(delay+i-1, PlayCrate, self.GamePool.Sequence[i])
	end
end

function WARE:StartAction()
	self:DrawPlayersTextAndInitialStatus("Repeat ! ",0)
	
	self.GamePool.PlayerCurrentCrate = {}
	
	for _,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give("gmdm_pistol")
		v:GiveAmmo(12, "Pistol", true)
		self.GamePool.PlayerCurrentCrate[v] = 1
	end
end

function WARE:EndAction()
	
end

function WARE:EntityTakeDamage(ent,inf,att,amount,info)
	local pool = self.GamePool
	
	if not att:IsPlayer() or not info:IsBulletDamage() then return end
	if not pool.PlayerCurrentCrate[att] then return end
	if not pool.Crates or not ent.CrateID then return end
	
	PlayCrate(ent.CrateID)
	
	if pool.Sequence[pool.PlayerCurrentCrate[att]] == ent.CrateID then
		pool.PlayerCurrentCrate[att] = pool.PlayerCurrentCrate[att] + 1
		if not pool.Sequence[pool.PlayerCurrentCrate[att]] then
			self:WarePlayerDestinyWin(att)
			att:StripWeapons()
		end
	else
		self:WarePlayerDestinyLose(att)
		att:StripWeapons()
	end
end
