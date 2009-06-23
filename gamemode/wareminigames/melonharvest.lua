WARE.Author = "Kilburn"
WARE.Room = "empty"

local ColorEmpty = Color(50,50,50,255)
local ColorFull = Color(0,255,0,255)

//Temporary disable
function WARE:IsPlayable()
	return false
end

local function RemoveCartVictory(cart)
	if cart and cart:IsValid() then
		GAMEMODE:MakeDisappearEffect(cart:GetPos())
		GAMEMODE:MakeLandmarkEffect(cart:GetPos())
		cart:Remove()
	end
end

local function EntityCaught(trigger,ent)
	local cart = trigger:GetParent()
	
	if cart:IsValid() and cart.Owner and ent:GetModel()=="models/props_junk/watermelon01.mdl" then
		ent:Remove()
		GAMEMODE:MakeAppearEffect(ent:GetPos())
		cart.NumMelons = cart.NumMelons + 1
		
		cart.Text:SetEntityText(tostring(cart.NumMelons))
		local r = cart.NumMelons / GAMEMODE.Minigame.NumHarvest
		
		umsg.Start("EntityTextChangeColor")
			umsg.Entity(cart.Text)
			umsg.Long(Lerp(r, ColorEmpty.r, ColorFull.r))
			umsg.Long(Lerp(r, ColorEmpty.g, ColorFull.g))
			umsg.Long(Lerp(r, ColorEmpty.b, ColorFull.b))
			umsg.Long(Lerp(r, ColorEmpty.a, ColorFull.a))
		umsg.End()
		
		cart.Owner:SendLua("LocalPlayer():EmitSound( \"" .. GAMEMODE.WinOther .. "\" )")
		
		if cart.NumMelons>=GAMEMODE.Minigame.NumHarvest then
			cart:SetColor(255,255,255,255)
			cart.Owner:WarePlayerDestinyWin()
			cart.Owner:StripWeapons()
			trigger:Remove()
			cart:Fire("DisablePhyscannonPickup", "", 0.01)
			timer.Simple(1, RemoveCartVictory, cart)
		end
	end
end

function WARE:OnPropGrabbed(pl, prop)
	if prop.NumMelons and not prop.Owner then
		prop.Owner = pl
		prop.Trigger:Enable()
		prop:SetColor(255,255,255,100)
	end
end

function WARE:OnPropDropped(pl, prop)
	if prop.NumMelons and prop.Owner==pl then
		prop.Owner = nil
		prop.Trigger:Disable()
		prop:SetColor(255,255,255,255)
	end
end

function WARE:Initialize()
	local entlist = GAMEMODE:GetEnts({"light_ground","dark_ground"})
	local numPlayers = team.NumPlayers(TEAM_HUMANS)
	local numberSpawns = math.Clamp(numPlayers,1,table.Count(entlist))
	
	self.NumHarvest = math.random(2,4)
	local acttime = 4.5 * self.NumHarvest
	self.NumMelonSpawns = math.ceil(numPlayers*0.2)
	self.DelayBetweenMelons = 0.3 * (1.5 + self.NumMelonSpawns - (numPlayers*0.2))
	self.AirLocations = GAMEMODE:GetEnts({"light_inair","dark_inair"})
	
	GAMEMODE:SetWareWindupAndLength(3,acttime)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Grab a laundry cart...",0)
	
	-- HAXX
	-- GravGunOnPickedUp hook is broken, so we'll use this tricky workaround
	local lua_run1 = ents.Create("lua_run")
	lua_run1:SetKeyValue('Code', 'GAMEMODE.Minigame:OnPropGrabbed(ACTIVATOR, CALLER)')
	lua_run1:SetKeyValue('targetname','luarun1')
	lua_run1:Spawn()
	
	local lua_run2 = ents.Create("lua_run")
	lua_run2:SetKeyValue('Code', 'GAMEMODE.Minigame:OnPropDropped(ACTIVATOR, CALLER)')
	lua_run2:SetKeyValue('targetname','luarun2')
	lua_run2:Spawn()
	
	for _,pos in ipairs(GAMEMODE:GetRandomPositions(numberSpawns, entlist)) do
		local cart = ents.Create("prop_physics")
		cart:SetModel("models/props_wasteland/laundry_cart001.mdl")
		cart:PhysicsInit(SOLID_VPHYSICS)
		cart:SetMoveType(MOVETYPE_VPHYSICS)
		cart:SetSolid(SOLID_VPHYSICS)
		cart:SetPos(pos+Vector(0,0,100))
		cart:SetAngles(Angle(0,math.random(-180,180),0))
		cart:Spawn()
		
		cart:Fire("AddOutput", "OnPhysGunOnlyPickup luarun1,RunCode")
		cart:Fire("AddOutput", "OnPhysGunDrop luarun2,RunCode")
		cart:Fire("AddOutput", "OnPhysCannonDetach luarun2,RunCode")
		
		cart.NumMelons = 0
		
		local trigger = ents.Create("ware_trigger")
		trigger:SetPos(cart:GetPos())
		trigger:SetAngles(cart:GetAngles())
		trigger:Spawn()
		trigger:SetParent(cart)
		trigger:Setup(Vector(-35,-15,-10), Vector(35,15,20), EntityCaught, {"models/props_junk/watermelon01.mdl"}, true)
		cart.Trigger = trigger
		
		trigger:Disable()
		
		GAMEMODE:AppendEntToBin(cart)
		GAMEMODE:MakeAppearEffect(pos+Vector(0,0,100))
	end
	
	for _,v in pairs(team.GetPlayers(TEAM_HUMANS)) do
		v:Give( "weapon_physcannon" )
	end
end

function WARE:StartAction()
	GAMEMODE:DrawPlayersTextAndInitialStatus("Catch "..self.NumHarvest.." melons ! ",0)
	self.NextMelonSpawn = 0
	self.NextMelonCleanup = 0
	
	for _,v in pairs(ents.FindByModel("models/props_wasteland/laundry_cart001.mdl")) do
		local textent = ents.Create("ware_text")
		textent:SetPos(v:GetPos())
		textent:Spawn()
		textent:SetParent(v)
		textent:SetEntityText(tostring(v.NumMelons))
		
		v.Text = textent
	end
	
	timer.Simple(0.1, function()
		for _,t in pairs(ents.FindByClass("ware_text")) do
			umsg.Start("EntityTextChangeColor")
				umsg.Entity(t)
				umsg.Long(ColorEmpty.r)
				umsg.Long(ColorEmpty.g)
				umsg.Long(ColorEmpty.b)
				umsg.Long(ColorEmpty.a)
			umsg.End()
		end
	end)
	
end

function WARE:EndAction()
	for _,v in pairs(ents.FindByClass("lua_run")) do
		v:Remove()
	end
end

function WARE:Think()
	if not self.NextMelonSpawn then return end
	
	if CurTime()>self.NextMelonSpawn then
		for _,pos in pairs(GAMEMODE:GetRandomPositions(self.NumMelonSpawns, self.AirLocations)) do
			local melon = ents.Create("prop_physics")
			melon:SetModel("models/props_junk/watermelon01.mdl")
			melon:PhysicsInit(SOLID_VPHYSICS)
			melon:SetMoveType(MOVETYPE_VPHYSICS)
			melon:SetSolid(SOLID_VPHYSICS)
			melon:SetPos(pos)
			melon:SetAngles(Angle(math.random(-180,180),math.random(-180,180),math.random(-180,180)))
			melon:Spawn()
			
			-- Can't pick them up!
			melon:Fire("DisablePhyscannonPickup", "", 0.01)
			
			melon:GetPhysicsObject():SetDamping(5,melon:GetPhysicsObject():GetRotDamping())
			melon:GetPhysicsObject():ApplyForceCenter(Vector(math.random(-5000,5000),math.random(-5000,5000),math.random(-1000,0)))
			
			GAMEMODE:AppendEntToBin(melon)
			GAMEMODE:MakeAppearEffect(pos)
		end
		self.NextMelonSpawn = CurTime() + self.DelayBetweenMelons
	end
	
	if CurTime()>self.NextMelonCleanup then
		for _,v in pairs(ents.FindByModel("models/props_junk/watermelon01.mdl")) do
			if math.abs(v:GetPhysicsObject():GetVelocity().x)<0.1 and
			   math.abs(v:GetPhysicsObject():GetVelocity().y)<0.1 and
			   math.abs(v:GetPhysicsObject():GetVelocity().z)<0.1 then
				GAMEMODE:MakeDisappearEffect(v:GetPos())
				v:Remove()
			end
		end
		self.NextMelonCleanup = CurTime() + 3
	end
end
