WARE.Author = "Kilburn"

local CrateColours = {
	{"black" , Color(0  ,0  ,0  ,255)},
	{"grey"  , Color(128,128,128,255)},
	{"white" , Color(255,255,255,255)},
	{"red"   , Color(255,0  ,0  ,255)},
	{"green" , Color(0  ,255,0  ,255)},
	{"blue"  , Color(0  ,0  ,255,255)},
	{"yellow", Color(255,255,0  ,255)},
	{"pink"  , Color(255,0  ,255,255)},
}


function WARE:NextCrateColour()
	for _,prop in pairs(ents.FindByModel("models/props_c17/furniturewashingmachine001a.mdl")) do
		if prop.CurrentColour and not prop.Stop then
			prop.CurrentColour = prop.CurrentColour + 1
			if not self.Sequence[prop.CurrentColour] then prop.CurrentColour = 1 end
			local col = self.Sequence[prop.CurrentColour]
			prop:SetColor(col[2].r, col[2].g, col[2].b, col[2].a)
		end
	end
end

local function RemoveCrate(prop)
	if prop and prop:IsValid() then
		GAMEMODE:MakeAppearEffect(prop:GetPos())
		prop:Remove()
	end
end

local function ResumeCrate(prop)
	if prop and prop:IsValid() then
		prop.Stop = nil
	end
end

-----------------------------------------------------------------------------------

function WARE:Initialize()
	local ratio = 0.5
	local minimum = 4
	local maxcount = table.Count(GAMEMODE:GetEnts(ENTS_OVERCRATE))
	local numberSpawns = math.Clamp(math.ceil(team.NumPlayers(TEAM_HUMANS)*ratio),minimum,maxcount)
	
	-- Randomize the colour sequence so players have to memorize it every time this minigame plays
	local seqcopy = table.Copy(CrateColours)
	self.Sequence = {}
	for i=1,#CrateColours do
		table.insert(self.Sequence, table.remove(seqcopy,math.random(1,#seqcopy)))
	end
	
	local Sequence = self.Sequence
	
	self.TargetColour = math.random(1,#Sequence)
	
	GAMEMODE:SetWareWindupAndLength(0.7,7)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Shoot the "..Sequence[self.TargetColour][1].." one !",0)
	
	for i,pos in ipairs(GAMEMODE:GetRandomPositions(numberSpawns, ENTS_OVERCRATE)) do
		local c = math.random(1,#Sequence)
		local col = Sequence[c]
		local prop = ents.Create("prop_physics")
		prop:SetModel("models/props_c17/furniturewashingmachine001a.mdl")
		prop:PhysicsInit(SOLID_VPHYSICS)
		prop:SetSolid(SOLID_VPHYSICS)
		prop:SetPos(pos)
		prop:SetAngles(Angle(0,math.Rand(0,360),0))
		prop:Spawn()
		
		prop.CurrentColour = c
		prop:SetColor(col[2].r, col[2].g, col[2].b, col[2].a)
		prop:SetMoveType(MOVETYPE_NONE)
		
		GAMEMODE:AppendEntToBin(prop)
		GAMEMODE:MakeAppearEffect(pos)
	end
end

function WARE:StartAction()
	for _,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		v:Give("gmdm_pistol")
		v:GiveAmmo(12, "Pistol", true)
	end
	
	self:NextCrateColour()
	timer.Create("WARETIMERrollingcolor", 0.7, 0, self.NextCrateColour, self)
end

function WARE:EndAction()
	timer.Destroy("WARETIMERrollingcolor")
end

function WARE:EntityTakeDamage(ent,inf,att,amount,info)
	local pool = self
	
	if not att:IsPlayer() or not info:IsBulletDamage() then return end
	if not ent.CurrentColour then return end
	
	if self.TargetColour == ent.CurrentColour then
		if not ent.Stop then
			ent.Stop = true
			timer.Simple(1, RemoveCrate, ent)
		end
		att:WarePlayerDestinyWin()
		att:StripWeapons()
	else
		if not ent.Stop then
			ent.Stop = true
			timer.Simple(1, ResumeCrate, ent)
		end
		att:WarePlayerDestinyLose()
		att:StripWeapons()
	end
end
