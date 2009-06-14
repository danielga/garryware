WARE.Author = "Hurricaaane (Ha3)"

function WARE:Initialize()
	self.Plugs = {}
	GAMEMODE:SetWareWindupAndLength(0,12)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Find a battery and plug it !",0)
	
	-- HAXX
	-- GravGunOnPickedUp hook is broken, so we'll use this tricky workaround
	local lua_run = ents.Create("lua_run")
	--lua_run:SetKeyValue('Code','CALLER:SetNWEntity("CanOwner",ACTIVATOR)')
	lua_run:SetKeyValue('Code','CALLER.BatteryOwner=ACTIVATOR')
	lua_run:SetKeyValue('targetname','luarun')
	lua_run:Spawn()
	
	local ratio = 1
	local minimum = 2
	local num = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*ratio),minimum,64)
	local entposcopy = GAMEMODE:GetRandomLocations(num, ENTS_OVERCRATE)
	local cratelist = {}
	for k,v in pairs(entposcopy) do
		local ent = ents.Create ("prop_physics");
		ent:SetModel("models/Items/item_item_crate.mdl")
		ent:SetPos(v:GetPos() + Vector(0,0,16));
		ent:Spawn();
		
		table.insert(cratelist,ent)
		
		local phys = ent:GetPhysicsObject()
		phys:Wake()
		phys:ApplyForceCenter(VectorRand() * 256);
		
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
	
	local ratio2 = 0.5
	local minimum2 = 1
	local num2 = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*ratio2),minimum2,num)
	local entcontains = GAMEMODE:GetRandomLocations(num2, cratelist)
	for k,v in pairs(entcontains) do
		v:SetNWInt("contains",1)
		--v:SetColor(255,0,0,255)
	end
	
	local ratio3 = 0.5
	local minimum3 = 1
	local num3 = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*ratio3),minimum3,64)
	local entposcopy3 = GAMEMODE:GetRandomLocations(num3, ENTS_ONCRATE)
	for k,v in pairs(entposcopy3) do
		local ent = ents.Create ("prop_physics");
		ent:SetModel("models/props_lab/tpplugholder_single.mdl")
		ent:PhysicsInit(SOLID_VPHYSICS)
		ent:SetSolid(SOLID_VPHYSICS)
		
		local side = math.random(1,4)
		local xloc = 0
		local yloc = 0
		if side == 1 then xloc = 1 end
		if side == 2 then yloc = 1 end
		if side == 3 then xloc = -1 end
		if side == 4 then yloc = -1 end
		ent:SetPos( v:GetPos() + Vector(32*xloc,32*yloc,-32) )
		ent:SetAngles(Angle(0,(side-1)*90,0))
		ent:SetPos( ent:GetPos() + ent:GetRight()*13 + Vector(0,0,-5) )
		
		ent:SetMoveType(MOVETYPE_NONE)
		ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		ent:Spawn();
		ent:GetPhysicsObject():EnableMotion(false)
		
		ent:SetNWInt("isoccupied", 0)
		table.insert(self.Plugs,ent)
		
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
		
		
		local camera = ents.Create ("npc_combine_camera");
		camera:SetAngles(Angle(0,math.random(0,360),180))
		camera:SetPos( v:GetPos() )
		camera:SetKeyValue("spawnflags",208)
		camera:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		camera:Spawn()
		
		ent:SetNWEntity("camera",camera)
		
		GAMEMODE:AppendEntToBin(camera)
		GAMEMODE:MakeAppearEffect(camera:GetPos())
	end
	
	for _,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "weapon_physcannon" )
	end
	return
end

function WARE:StartAction()
	return
end

function WARE:EndAction()
	for _,v in pairs(ents.FindByClass("lua_run")) do
		v:Remove()
	end
	for _,v in pairs(ents.FindByClass("prop_physics")) do
		if v:GetModel() == "models/props_lab/tpplugholder_single.mdl" && v:GetNWInt("isoccupied",0) == 0 then
			GAMEMODE:MakeLandmarkEffect(v:GetPos())
		end
	end
end

function WARE:PropBreak(pl,prop)	
	if prop:GetNWInt("contains",0) > 0 then
		local ent = ents.Create ("prop_physics");
		ent:SetModel("models/Items/car_battery01.mdl")
		ent:SetPos(prop:GetPos());
		ent:Spawn();
		
		ent:Fire("AddOutput", "OnPhysGunPickup luarun,RunCode")
		
		local ent2 = ents.Create ("prop_physics");
		ent2:SetModel("models/props_lab/tpplug.mdl")
		ent2:SetPos(ent:GetPos() + ent:GetForward()*-8);
		ent2:Spawn();
		ent2:SetParent(ent)

		local phys = ent:GetPhysicsObject()
		phys:Wake()
		phys:AddAngleVelocity(Angle(math.random(200,300),math.random(200,300),math.random(200,300)))
		phys:ApplyForceCenter(VectorRand() * 64);
		
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
		
		local trail_entity = util.SpriteTrail( ent,  //Entity
												0,  //iAttachmentID
												Color( 255, 255, 255, 92 ),  //Color
												false, // bAdditive
												0.9, //fStartWidth
												1.5, //fEndWidth
												1.2, //fLifetime
												1 / ((0.7+1.2) * 0.5), //fTextureRes
												"trails/physbeam.vmt" ) //strTexture
	end
end

function WARE:Think()
	if self.Plugs then
		if not self.NextPlugThink or CurTime() > self.NextPlugThink then
		
			for l,w in pairs(self.Plugs) do
			
				for _,v in pairs(ents.FindInSphere(w:GetPos(),24)) do
					if v:GetModel() == "models/items/car_battery01.mdl" && w:GetNWInt("isoccupied",0) == 0 then
						local Owner = v.BatteryOwner
						if Owner and Owner:IsPlayer() then
							GAMEMODE:MakeAppearEffect(v:GetPos())
							w:SetNWInt("isoccupied",1)
							v:SetPos(w:GetPos() + w:GetForward()*13 + w:GetRight()*-13 + Vector(0,0,10))
							v:SetAngles(w:GetAngles())
							v:GetPhysicsObject():EnableMotion(false)
							
							w:EmitSound("npc/roller/mine/combine_mine_deploy1.wav")
						
							local spark = ents.Create("env_spark")
							spark:SetPos(v:GetPos())
							spark:SetKeyValue("MaxDelay",2)
							spark:SetKeyValue("Magnitude",4)
							spark:SetKeyValue("TrailLength",2)
							spark:Spawn()
							spark:SetParent(v)
							spark:Fire("SparkOnce")
						
							Owner:StripWeapons()
							
							local camera = w:GetNWEntity("camera")
							camera:Fire("Enable")
							
							
							Owner:WarePlayerDestinyWin( )
						end
					end
				end
				
			end
			
			self.NextPlugThink = CurTime()+0.1
		end
	end
end