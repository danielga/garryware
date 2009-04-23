local function GetRandomPositions(num, group)
	local entposcopy = table.Copy(GAMEMODE:GetEnts(group))
	num = math.Clamp(num,0,#entposcopy)
	local result = {}
	
	for i=1,num do
		local p = table.remove(entposcopy, math.random(1,#entposcopy))
		table.insert(result, p:GetPos())
	end
	
	return result
end

local function GetRandomPositionsAvoidBox(num, group, test, vec1, vec2)
	local entposcopy = table.Copy(GAMEMODE:GetEnts(group))
	num = math.Clamp(num,0,#entposcopy)
	local result = {}
	local invalid = {}
	local failsafe = false
	
	for i=1,num do
		local ok
		repeat
			local p = table.remove(entposcopy, math.random(1,#entposcopy))
			ok = true
			
			if not failsafe then
				for _,v in pairs(ents.FindInBox(p:GetPos()+vec1, p:GetPos()+vec2)) do
					if test(v) then
						ok = false
						break
					end
				end
			end
			
			if ok then
				table.insert(result, p:GetPos())
			else
				table.insert(invalid, p:GetPos())
			end
			
			if #entposcopy==0 then
				-- No more entities available, enable failsafe mode, and pick invalid entities
				entposcopy = invalid
				failsafe = true
			end
		until ok
	end
	
	return result
end

---------------------------------------------------------------------------------

registerMinigame("pickupthatcan",
-- INIT
function(self, args)
	GAMEMODE:SetWareWindupAndLength(3,5)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Pick up that can !",0)
	
	local numberSpawns = math.Clamp(team.NumPlayers(TEAM_UNASSIGNED),1,table.Count(GAMEMODE:GetEnts(ENTS_INAIR)))
	
	-- HAXX
	-- GravGunOnPickedUp hook is broken, so we'll use this tricky workaround
	local lua_run = ents.Create("lua_run")
	--lua_run:SetKeyValue('Code','CALLER:SetNWEntity("CanOwner",ACTIVATOR)')
	lua_run:SetKeyValue('Code','CALLER.CanOwner=ACTIVATOR')
	lua_run:SetKeyValue('targetname','luarun')
	lua_run:Spawn()
	
	for _,pos in ipairs(GetRandomPositions(numberSpawns, ENTS_INAIR)) do
		local prop = ents.Create("prop_physics")
		prop:SetModel("models/props_junk/popcan01a.mdl")
		prop:SetSkin(math.random(0,2))
		prop:PhysicsInit(SOLID_VPHYSICS)
		prop:SetMoveType(MOVETYPE_VPHYSICS)
		prop:SetSolid(SOLID_VPHYSICS)
		prop:SetPos(pos)
		prop:SetAngles(Angle(math.random(-180,180),math.random(-180,180),math.random(-180,180)))
		prop:Spawn()
		
		prop:Fire("AddOutput", "OnPhysGunPickup luarun,RunCode")
		util.SpriteTrail(prop,0,Color(255,255,255,255),false,16,0,6,1/8,"trails/smoke.vmt")
		
		GAMEMODE:AppendEntToBin(prop)
		GAMEMODE:MakeAppearEffect(pos)
	end
	
	for _,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "weapon_physcannon" )
	end
end,
-- ACT START
function(self, args)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Put it in the trashcan ! ",0)
	
	local pos = GetRandomPositionsAvoidBox(1, ENTS_ONCRATE, function(v) return v:IsPlayer() end, Vector(-64,-64,64), Vector(64,64,64))[1]
	local trash = ents.Create("prop_physics")
	trash:SetModel("models/props_trainstation/trashcan_indoor001b.mdl")
	trash:PhysicsInit(SOLID_VPHYSICS)
	trash:SetSolid(SOLID_VPHYSICS)
	
	trash:SetPos(pos)
	trash:Spawn()
	
	local land = ents.Create("gmod_landmarkonremove")
	land:SetPos(pos)
	land:Spawn()
	
	local obbmins = trash:OBBMins()
	pos = pos - Vector(0,0,obbmins.z)
	trash:SetPos(pos)
	trash:SetMoveType(MOVETYPE_NONE)
	
	GAMEMODE:AppendEntToBin(land)
	GAMEMODE:AppendEntToBin(trash)
	GAMEMODE:MakeAppearEffect(pos)
	
	GAMEMODE.GamePool.Trashcan = trash
end,
-- ACT END
function(self, args)
	GAMEMODE.GamePool.Trashcan = nil
	GAMEMODE.GamePool.NextTrashThink = nil
	for _,v in pairs(ents.FindByClass("lua_run")) do
		v:Remove()
	end
end)

--[[registerTrigger("pickupthatcan","GravGunOnPickedUp",function(pl,ent)
	if ent:GetModel()=="models/props_junk/popcan01a.mdl" then
		Msg("lol\n")
		ent:SetNWEntity("CanOwner",pl)
	end
end)]]

registerTrigger("pickupthatcan","Think",function()
	if GAMEMODE.GamePool.Trashcan then
		if not GAMEMODE.GamePool.NextTrashThink or CurTime()>GAMEMODE.GamePool.NextTrashThink then
			local bmin,bmax = GAMEMODE.GamePool.Trashcan:WorldSpaceAABB()
			for _,v in pairs(ents.FindInBox(bmin+Vector(12,12,14),bmax-Vector(12,12,10))) do
				if v:GetModel()=="models/props_junk/popcan01a.mdl" then
					local Owner = v.CanOwner
					if Owner and Owner:IsPlayer() then
						GAMEMODE:MakeAppearEffect(v:GetPos())
						v:Remove()
					
						Owner:StripWeapons()
						GAMEMODE:WarePlayerDestinyWin(Owner)
					end
				end
			end
			GAMEMODE.GamePool.NextTrashThink = CurTime()+0.1
		end
	end
end)

---------------------------------------------------------------------------------

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

registerMinigame("memorycrates",
-- INIT
function(self, args)
	local numberSpawns = 5
	local delay = 4
	
	GAMEMODE:SetWareWindupAndLength(numberSpawns+delay,numberSpawns)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Watch carefully !",0)
	
	GAMEMODE.GamePool.Crates = {}
	
	for i,pos in ipairs(GetRandomPositions(numberSpawns, ENTS_ONCRATE)) do
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
end,
-- ACT START
function(self, args)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Repeat ! ",0)
	
	GAMEMODE.GamePool.PlayerCurrentCrate = {}
	
	for _,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give("gmdm_pistol")
		v:GiveAmmo(12, "Pistol", true)
		GAMEMODE.GamePool.PlayerCurrentCrate[v] = 1
	end
end,
-- ACT END
function(self, args)
	GAMEMODE.GamePool.Crates = nil
	GAMEMODE.GamePool.Sequence = nil
	GAMEMODE.GamePool.PlayerCurrentCrate = nil
end)

registerTrigger("memorycrates","EntityTakeDamage",function(ent,inf,att,amount,info)
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
end)

---------------------------------------------------------------------------------

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

registerMinigame("meloncrates",
-- INIT
function(self, args)
	local maxcount = table.Count(GAMEMODE:GetEnts(ENTS_ONCRATE))
	
	local numberMelonSpawns = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*0.5),1,maxcount)
	local numberFakeSpawns = math.Clamp(team.NumPlayers(TEAM_UNASSIGNED)+1,4,maxcount-numberMelonSpawns)
	
	local delay = 2
	
	GAMEMODE:SetWareWindupAndLength(delay+1,6)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Watch the crates...",0)
	
	for i,pos in ipairs(GetRandomPositions(numberMelonSpawns+numberFakeSpawns, ENTS_ONCRATE)) do
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
end,
-- ACT START
function(self, args)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Break a melon ! ",0)
	
	for _,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give("weapon_crowbar")
	end
end,
-- ACT END
function(self, args)
	
end)

registerTrigger("meloncrates","PropBreak",function(pl,prop)
	if not pl:IsPlayer() then return end
	
	if prop:GetModel()=="models/props_junk/watermelon01.mdl" then
		GAMEMODE:WarePlayerDestinyWin(pl)
		pl:StripWeapons()
	elseif prop.Contents then
		prop.Contents:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		prop.Contents:GetPhysicsObject():EnableMotion(true)
		prop.Contents:GetPhysicsObject():Wake()
	end
end)

---------------------------------------------------------------------------------

function RespawnSawblade(ent)
	if not ent or not ent:IsValid() or not ent.OriginalPos then return end
	
	local saw = ents.Create ("prop_physics")
	saw:SetModel("models/props_junk/sawblade001a.mdl")
	saw:SetPos(ent.OriginalPos)
	saw:SetAngles(Angle(0,0,0))
	saw:Spawn()
	
	GAMEMODE:AppendEntToBin(saw)
	GAMEMODE:MakeAppearEffect(saw:GetPos())
end

registerMinigame("buildtothetop",
-- INIT
function(self, args)
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
end,
-- ACT START
function(self, args)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Get on the red platform !",0)
	
	local numberSpawns = math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*0.75)
	
	for i,pos in ipairs(GetRandomPositions(numberSpawns, ENTS_INAIR)) do
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
end,
-- ACT END
function(self, args)
	
end)

registerTrigger("buildtothetop","Think",function()
	for _,v in pairs(ents.FindByClass("player")) do
		local ent = v:GetGroundEntity()
		if ent and ent:IsValid() and ent:GetModel()=="models/props_lab/blastdoor001b.mdl" then
			GAMEMODE:WarePlayerDestinyWin(v)
		end
	end
end)

registerTrigger("buildtothetop","GravGunPunt",function(pl,ent)
	if not pl:IsPlayer() then return end
	
	if ent:GetPhysicsObject() and ent:GetPhysicsObject():IsValid() then
		ent:GetPhysicsObject():EnableMotion(false)
		timer.Simple(4,RespawnSawblade,ent)
	end
end)

---------------------------------------------------------------------------------
