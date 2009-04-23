function WARE:Initialize()
	self:SetWareWindupAndLength(3,5)
	self:DrawPlayersTextAndInitialStatus("Pick up that can !",0)
	
	local numberSpawns = math.Clamp(team.NumPlayers(TEAM_UNASSIGNED),1,table.Count(self:GetEnts(ENTS_INAIR)))
	
	-- HAXX
	-- GravGunOnPickedUp hook is broken, so we'll use this tricky workaround
	local lua_run = ents.Create("lua_run")
	--lua_run:SetKeyValue('Code','CALLER:SetNWEntity("CanOwner",ACTIVATOR)')
	lua_run:SetKeyValue('Code','CALLER.CanOwner=ACTIVATOR')
	lua_run:SetKeyValue('targetname','luarun')
	lua_run:Spawn()
	
	for _,pos in ipairs(self:GetRandomPositions(numberSpawns, ENTS_INAIR)) do
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
		
		self:AppendEntToBin(prop)
		self:MakeAppearEffect(pos)
	end
	
	for _,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give( "weapon_physcannon" )
	end
end

function WARE:StartAction()
	self:DrawPlayersTextAndInitialStatus("Put it in the trashcan ! ",0)
	
	local pos = self:GetRandomPositionsAvoidBox(1, ENTS_ONCRATE, function(v) return v:IsPlayer() end, Vector(-64,-64,64), Vector(64,64,64))[1]
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
	
	self:AppendEntToBin(land)
	self:AppendEntToBin(trash)
	self:MakeAppearEffect(pos)
	
	self.GamePool.Trashcan = trash
end

function WARE:EndAction()
	for _,v in pairs(ents.FindByClass("lua_run")) do
		v:Remove()
	end
end

function WARE:Think()
	if self.GamePool.Trashcan then
		if not self.GamePool.NextTrashThink or CurTime()>self.GamePool.NextTrashThink then
			local bmin,bmax = self.GamePool.Trashcan:WorldSpaceAABB()
			for _,v in pairs(ents.FindInBox(bmin+Vector(12,12,14),bmax-Vector(12,12,10))) do
				if v:GetModel()=="models/props_junk/popcan01a.mdl" then
					local Owner = v.CanOwner
					if Owner and Owner:IsPlayer() then
						self:MakeAppearEffect(v:GetPos())
						v:Remove()
					
						Owner:StripWeapons()
						self:WarePlayerDestinyWin(Owner)
					end
				end
			end
			self.GamePool.NextTrashThink = CurTime()+0.1
		end
	end
end
