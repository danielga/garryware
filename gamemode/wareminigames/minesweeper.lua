WARE.Author = "Kilburn"
WARE.Room = "empty"

function WARE:IsPlayable()
	return false
end

local Colors = {
	{0,0,255},
	{0,255,0},
	{255,0,0},
	{0,0,100},
	{100,0,0},
	{0,100,100},
	{100,100,0},
	{20,20,20},
}

--[[ MAP STRUCTURE
(should probably make this into a module, may be useful for other minigames)

grid.W = width of the grid
grid.H = height of the grid

    -1 0 1 2 3 4 ...
-1 { _ _ X X X X ... }
 0 { _ _ x x x x ... }
 1 { Y y C C C C ... }
 2 { Y y C C C C ... }
 3 { Y y C C C C ... }
 . ...

C = Props
X = number of props inserted into that column (used for calculating the average X of this column)
x = average X of this column
Y = number of props inserted into that row
y = average Y of this row
]]

-- Maximum error margin for including props in the grid
local Tolerancy = 10

local function CreateGrid()
	return {[-1]={}, [0]={}, W=0,H=0}
end

local function InsertRow(grid, y)
	local t = {[-1]=0, [0]=0}
	for i=1,grid.W do t[i]=NULL end
	
	table.insert(grid, y, t)
	grid.H = grid.H + 1
end

local function InsertColumn(grid, x)
	table.insert(grid[-1], x, 0)
	table.insert(grid[0], x, 0)
	for i=1,grid.H do
		table.insert(grid[i], x, NULL)
	end
	grid.W = grid.W + 1
end

local function AddItem(grid, x, y, prop)
	local pos = prop:GetPos()
	
	grid[0][x] = (grid[-1][x] * grid[0][x] + pos.x) / (grid[-1][x] + 1)
	grid[-1][x] = grid[-1][x] + 1
	
	grid[y][0] = (grid[y][-1] * grid[y][0] + pos.y) / (grid[y][-1] + 1)
	grid[y][-1] = grid[y][-1] + 1
	
	grid[y][x] = prop
	grid[prop] = {x=x,y=y}
end

local function GetInGrid(grid, x, y)
	if x<1 or y<1 or x>grid.W or y>grid.H then return NULL end
	return grid[y][x]
end

-- Inserting props into the grid with this function will map them so you can know which prop is under which one in the grid, etc...

local function InsertInGrid(grid, prop)
	local pos = prop:GetPos()
	local x, y = pos.x, pos.y
	local a, b = 1, 1
	
	-- Finding/inserting row
	
	if grid.H==0 then
		InsertRow(grid, 1, y)
	else
		for j=1,grid.H do
			local cy = grid[j][0]
			if y<cy+Tolerancy and y>cy-Tolerancy then
				b = j
				break
			elseif y<cy-Tolerancy then
				b = j
				InsertRow(grid, j, y)
				break
			elseif y>cy+Tolerancy and not grid[j+1] then
				b = j+1
				InsertRow(grid, j+1, y)
			end
		end
	end
	
	-- Finding/inserting column
	
	if grid.W==0 then
		InsertColumn(grid, 1, x)
	else
		for i=1,grid.W do
			local cx = grid[0][i]
			if x<cx+Tolerancy and x>cx-Tolerancy then
				a = i
				break
			elseif x<cx-Tolerancy then
				a = i
				InsertColumn(grid, i, x)
				break
			elseif x>cx+Tolerancy and not grid[b][i+1] then
				a = i+1
				InsertColumn(grid, i+1, x)
			end
		end
	end
	
	AddItem(grid, a, b, prop)
end

local function Uncover(p)
	if not p:IsValid() then return end
	
	local num = p.Neighbours
	
	if num>0 then
		local textent = ents.Create("ware_text")
		textent:SetPos(p:GetPos())
		textent:Spawn()
		
		GAMEMODE:AppendEntToBin(textent)
		GAMEMODE:MakeAppearEffect(p:GetPos())
		
		textent:SetEntityText(tostring(num))
		
		local c = Colors[num] or Colors[8]
		
		timer.Simple(0.1, function(t)
			umsg.Start("EntityTextChangeColor")
				umsg.Entity(t)
				umsg.Long(c[1])
				umsg.Long(c[2])
				umsg.Long(c[3])
				umsg.Long(255)
			umsg.End()
		end, textent)
	end
end

local function Floodfill(grid, x, y)
	local removed = 0
	local Q = {}
	table.insert(Q, {x,y})
	while Q[1] do
		local n = Q[1]
		local p = GetInGrid(grid, n[1], n[2])
		local num
		
		if p:IsValid() then
			num = p.Neighbours
			Uncover(p)
			p:Remove()
			removed = removed + 1
		end
		
		table.remove(Q, 1)
		
		if num==0 then
			for i=n[1]-1,n[1]+1 do
				for j=n[2]-1,n[2]+1 do
					if i~=n[1] or j~=n[2] then
						local q = GetInGrid(grid, i, j)
						if q:IsValid() then
							if q.Neighbours==0 then
								table.insert(Q, {i,j})
							else
								Uncover(q)
							end
							q:Remove()
							removed = removed + 1
						end
					end
				end
			end
		end
	end
	return removed
end

-----------------------------------------------------------------------------------------------

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(2,25)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Work as a team, keyword: \"minesweeper\" !",0)
	
	local entlist = GAMEMODE:GetEnts({"light_ground","dark_ground"})
	local maxcount = table.Count(entlist)
	local nummines = math.ceil(math.Clamp(team.NumPlayers(TEAM_UNASSIGNED)*1.25,1,maxcount*0.3))
	
	Msg(maxcount.."\n")
	
	self.Grid = CreateGrid()
	self.Remaining = maxcount
	
	for k,v in pairs(entlist) do
		local pos = v:GetPos()
		pos = pos + Vector(0,0,v:OBBMins().z)
		
		local prop = ents.Create("prop_physics")
		prop:SetModel("models/props_junk/wood_crate001a.mdl")
		prop:PhysicsInit(SOLID_VPHYSICS)
		prop:SetSolid(SOLID_VPHYSICS)
		prop:SetPos(pos)
		prop:Spawn()
		
		prop:SetMoveType(MOVETYPE_NONE)
		prop:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		
		prop.Neighbours = 0
		
		GAMEMODE:AppendEntToBin(prop)
		GAMEMODE:MakeAppearEffect(pos)
		
		InsertInGrid(self.Grid, prop)
	end
	
	Msg(self.Grid.W.." , "..self.Grid.H.."\n")
	for i=1,self.Grid.H do
		for j=1,self.Grid.W do
			local p = GetInGrid(self.Grid, j, i)
			if not p then
				Msg("N ")
			elseif p:IsValid() then
				Msg("O ")
			else
				Msg("X ")
			end
		end
		Msg("\n")
	end
	
	local dbg = (GetConVarNumber("ware_debug")==2)
	
	for i=1,nummines do
		local x,y = math.random(1,self.Grid.W), math.random(1,self.Grid.H)
		local p = GetInGrid(self.Grid, x, y)
		
		if p:IsValid() and not p.Mine then
			p.Mine = true
			if dbg then
				p:SetColor(255,200,200,255)
			end
			p:SetHealth(100000)
			self.Remaining = self.Remaining - 1
			
			for i=x-1,x+1 do
				for j=y-1,y+1 do
					local q = GetInGrid(self.Grid, i, j)
					if q:IsValid() then
						q.Neighbours = q.Neighbours + 1
					end
				end
			end
		end
	end
	
end

function WARE:StartAction()
	GAMEMODE:DrawPlayersTextAndInitialStatus("Break all crates without a mine inside !",0)
	
	for _,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give("weapon_crowbar")
	end
	
	for _,v in pairs(ents.FindByClass("prop_physics")) do
		v:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
	end
end

function WARE:EndAction()
	if self.Remaining>0 then
		for _,p in pairs(ents.FindByClass("prop_physics")) do
			if p.Mine then
				GAMEMODE:MakeLandmarkEffect(p:GetPos())
			end
		end
		
		for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
			v:WarePlayerDestinyLose()
		end
	end
end

function WARE:EntityTakeDamage(ent,inf,att,amount,info)
	if not att:IsPlayer() or amount<10 then return end
	
	if ent.Mine then
		ent:EmitSound("ambient/levels/labs/electric_explosion1.wav")
		
		local effectdata = EffectData( )
			effectdata:SetOrigin(ent:GetPos())
			effectdata:SetNormal(Vector(0,0,1))
		util.Effect("waveexplo", effectdata, true, true)
		
		ent:SetColor(255,0,0,255)
		timer.Simple(3,function(e) if e:IsValid() and e.Mine then e:SetColor(255,255,255,255) end end,ent)
		
		att:WarePlayerDestinyLose( )
		att:StripWeapons()
	end
end

function WARE:PropBreak(killer, prop)
	local pos = self.Grid[prop]
	if not pos then return end
	
	if killer:IsPlayer() then
		killer:SetAchievedNoDestiny(1)
	end
	
	local num = prop.Neighbours
	
	local removed = Floodfill(self.Grid, pos.x, pos.y)
	
	self.Remaining = self.Remaining - removed
	if self.Remaining<=0 then
		for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do
			for _,p in pairs(ents.FindByClass("prop_physics")) do
				if p.Mine then
					p.Mine = false
					p:SetHealth(40)
					p:SetColor(0,255,0,255)
				end
			end
			v:WareApplyDestiny()
		end
	end
end
