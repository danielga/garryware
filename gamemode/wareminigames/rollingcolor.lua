WARE.Author = "Kilburn"

local CrateColours = {
	{1,0,0,"red"},
	{0,1,0,"green"},
	{0,0,1,"blue"},
	{1,1,0,"yellow"},
	{1,0,1,"purple"},
	{1,1,1,"white"},
	{0,0,0,"black"},
}

local function NextCrateColour()
	for _,prop in pairs(ents.FindByModel("models/props_c17/furniturewashingmachine001a.mdl")) do
		if prop.CurrentColour and not prop.Stop then
			prop.CurrentColour = prop.CurrentColour + 1
			if not CrateColours[prop.CurrentColour] then prop.CurrentColour = 1 end
			local col = CrateColours[prop.CurrentColour]
			prop:SetColor(col[1]*255, col[2]*255, col[3]*255, 255)
		end
	end
end

local function RemoveCrate(prop)
	GAMEMODE:MakeAppearEffect(prop:GetPos())
	prop:Remove()
end

local function ResumeCrate(prop)
	prop.Stop = nil
end

-----------------------------------------------------------------------------------

function WARE:Initialize()
	local ratio = 0.7
	local minimum = 3
	local maxcount = table.Count(GAMEMODE:GetEnts(ENTS_OVERCRATE))
	local numberSpawns = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*ratio),minimum,maxcount)
	
	GAMEMODE.GamePool.TargetColour = math.random(1,#CrateColours)
	
	GAMEMODE:SetWareWindupAndLength(1,6)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Shoot the "..CrateColours[GAMEMODE.GamePool.TargetColour][4].." one !",0)
	
	for i,pos in ipairs(GAMEMODE:GetRandomPositions(numberSpawns, ENTS_OVERCRATE)) do
		local c = math.random(1,#CrateColours)
		local col = CrateColours[c]
		local prop = ents.Create("prop_physics")
		prop:SetModel("models/props_c17/furniturewashingmachine001a.mdl")
		prop:PhysicsInit(SOLID_VPHYSICS)
		prop:SetSolid(SOLID_VPHYSICS)
		prop:SetPos(pos)
		prop:SetAngles(Angle(0,math.Rand(0,360),0))
		prop:Spawn()
		
		prop.CurrentColour = c
		prop:SetColor(col[1]*255, col[2]*255, col[3]*255, 255)
		prop:SetMoveType(MOVETYPE_NONE)
		
		GAMEMODE:AppendEntToBin(prop)
		GAMEMODE:MakeAppearEffect(pos)
	end
end

function WARE:StartAction()
	for _,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give("gmdm_pistol")
		v:GiveAmmo(12, "Pistol", true)
	end
	
	NextCrateColour()
	timer.Create("WARETIMERrollingcolor", 0.3, 0, NextCrateColour)
end

function WARE:EndAction()
	timer.Destroy("WARETIMERrollingcolor")
end

function WARE:EntityTakeDamage(ent,inf,att,amount,info)
	local pool = GAMEMODE.GamePool
	
	if not att:IsPlayer() or not info:IsBulletDamage() then return end
	if not ent.CurrentColour then return end
	
	if GAMEMODE.GamePool.TargetColour == ent.CurrentColour then
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
