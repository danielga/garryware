local function GetRandomPositions(num, group)
	local entposcopy = table.Copy(GAMEMODE:GetEnts(group))
	local result = {}
	
	for i=1,num do
		local p = table.remove(entposcopy, math.random(1,#entposcopy))
		table.insert(result, p:GetPos())
	end
	
	return result
end

---------------------------------------------------------------------------------

registerMinigame("pickupthatcan",
-- INIT
function(self, args)
	GAMEMODE:SetWareWindupAndLength(5,5)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Pick up that can !",0)
	
	local numberSpawns = math.Clamp(team.NumPlayers(TEAM_UNASSIGNED),1,table.Count(GAMEMODE:GetEnts(ENTS_INAIR)))
	
	-- HAXX
	-- GravGunOnPickedUp hook is broken, so we'll use this tricky workaround
	local lua_run = ents.Create("lua_run")
	lua_run:SetKeyValue('Code','CALLER:SetNWEntity("CanOwner",ACTIVATOR)')
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
		prop:Spawn()
		
		prop:Fire("AddOutput", "OnPhysGunPickup luarun,RunCode")
		util.SpriteTrail(prop,0,Color(255,255,255,255),false,16,0,8,1/8,"trails/smoke.vmt")
		
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
	
	local pos = GetRandomPositions(1, ENTS_ONCRATE)[1]
	local trash = ents.Create("prop_physics")
	trash:SetModel("models/props_trainstation/trashcan_indoor001b.mdl")
	trash:SetKeyValue("physdamagescale", 1000)
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
	
	local min,max = trash:WorldSpaceAABB()
	print(tostring(max-min))
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
			for _,v in pairs(ents.FindInBox(bmin+Vector(10,10,10),bmax-Vector(10,10,10))) do
				if v:GetModel()=="models/props_junk/popcan01a.mdl" then
					local Owner = v:GetNWEntity("CanOwner")
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
