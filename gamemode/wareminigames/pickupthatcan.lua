WARE.Author = "Kilburn"

function WARE:Initialize()
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
	
	for _,pos in ipairs(GAMEMODE:GetRandomPositions(numberSpawns, ENTS_INAIR)) do
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
end

function WARE:StartAction()
	GAMEMODE:DrawPlayersTextAndInitialStatus("Put it in the trashcan ! ",0)
	GAMEMODE.GamePool.Trashcans = {}
	local pos = GAMEMODE:GetRandomPositionsAvoidBox(2, ENTS_ONCRATE, function(v) return v:IsPlayer() end, Vector(-64,-64,64), Vector(64,64,64))
	for k,v in pairs(pos) do
		local trash = ents.Create("prop_physics")
		trash:SetModel("models/props_trainstation/trashcan_indoor001b.mdl")
		trash:PhysicsInit(SOLID_VPHYSICS)
		trash:SetSolid(SOLID_VPHYSICS)
		
		trash:SetPos(v)
		trash:Spawn()
		
		local obbmins = trash:OBBMins()
		local newpos = v - Vector(0,0,obbmins.z)
		trash:SetPos(newpos)
		trash:SetMoveType(MOVETYPE_NONE)
		
		local land = ents.Create("gmod_landmarkonremove")
		land:SetPos(newpos)
		land:Spawn()
		GAMEMODE:AppendEntToBin(land)
		GAMEMODE:AppendEntToBin(trash)
		table.insert(GAMEMODE.GamePool.Trashcans,trash)
		
		GAMEMODE:MakeAppearEffect( v )
	end
end

function WARE:EndAction()
	for _,v in pairs(ents.FindByClass("lua_run")) do
		v:Remove()
	end
end

function WARE:Think()
	if GAMEMODE.GamePool.Trashcans then
		if not GAMEMODE.GamePool.NextTrashThink or CurTime()>GAMEMODE.GamePool.NextTrashThink then
		
			for l,w in pairs(GAMEMODE.GamePool.Trashcans) do
			
				local bmin,bmax = w:WorldSpaceAABB()
				for _,v in pairs(ents.FindInBox(bmin+Vector(12,12,14),bmax-Vector(12,12,10))) do
					if v:GetModel()=="models/props_junk/popcan01a.mdl" then
						local Owner = v.CanOwner
						if Owner and Owner:IsPlayer() then
							GAMEMODE:MakeAppearEffect(v:GetPos())
							v:Remove()
						
							Owner:StripWeapons()
							Owner:WarePlayerDestinyWin( )
						end
					end
				end
				
			end
			
			GAMEMODE.GamePool.NextTrashThink = CurTime()+0.1
		end
	end
end
