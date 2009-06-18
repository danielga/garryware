WARE.Author = "Hurricaaane (Ha3)"

-----------------------------------------------------------------------------------

function WARE:Initialize()
	local numberSpawns = 5
	
	GAMEMODE:SetWareWindupAndLength(numberSpawns*0.4,numberSpawns*1.5)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Shoot in the right order !",0)
	
	self.Crates = {}
	
	local previousnumber = 0
	for i,pos in ipairs(GAMEMODE:GetRandomPositions(numberSpawns, ENTS_ONCRATE)) do
		local prop = ents.Create("prop_physics")
		prop:SetModel("models/props_junk/wood_crate001a.mdl")
		prop:PhysicsInit(SOLID_VPHYSICS)
		prop:SetSolid(SOLID_VPHYSICS)
		prop:SetPos(pos+Vector(0,0,64))
		prop:Spawn()
		
		prop:SetColor(255, 255, 255, 100)
		prop:SetHealth(100000)
		prop:SetMoveType(MOVETYPE_NONE)
		prop:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		prop.CrateID = i
		
		self.Crates[i] = prop
		
		local textent = ents.Create("ware_text")
		previousnumber = previousnumber + math.random(1,35)
		textent:SetPos(pos+Vector(0,0,64))
		textent:Spawn()
		textent:SetEntityText(tostring(previousnumber))
		
		prop.AssociatedText = textent
		
		GAMEMODE:AppendEntToBin(prop)
		GAMEMODE:AppendEntToBin(textent)
		GAMEMODE:MakeAppearEffect(pos)
	end
	
	/*
	local sequence = {}
	for i=1,numberSpawns do sequence[i]=i end
	
	self.Sequence = {}
	for i=1,numberSpawns do
		self.Sequence[i] = table.remove(sequence, math.random(1,#sequence))
		timer.Simple(delay+i-1, self.PlayCrate, self, self.Sequence[i])
	end
	*/
end

function WARE:StartAction()
	local croissant = math.random(0,1)
	if (croissant == 1) then
		self.Sequence = {1, 2, 3, 4, 5}
		GAMEMODE:DrawPlayersTextAndInitialStatus("In the ascendant order ! (1 , 2 , 3...)",0)
	else
		self.Sequence = {5, 4, 3, 2, 1}
		GAMEMODE:DrawPlayersTextAndInitialStatus("In the descendant order ! (3 , 2 , 1...)",0)
	end
	
	self.PlayerCurrentCrate = {}
	
	for _,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give("gmdm_pistol")
		v:GiveAmmo(12, "Pistol", true)
		self.PlayerCurrentCrate[v] = 1
	end
end

function WARE:EndAction()
	
end

function WARE:EntityTakeDamage(ent,inf,att,amount,info)
	local pool = self
	
	if not att:IsPlayer() or not info:IsBulletDamage() then return end
	if not pool.PlayerCurrentCrate[att] then return end
	if not pool.Crates or not ent.CrateID then return end
	
	GAMEMODE:MakeAppearEffect(ent:GetPos())
	
	if pool.Sequence[pool.PlayerCurrentCrate[att]] == ent.CrateID then
		pool.PlayerCurrentCrate[att] = pool.PlayerCurrentCrate[att] + 1
		att:SendLua( "LocalPlayer():EmitSound( \"" .. GAMEMODE.WinOther .. "\" );" );
		
		local rp = RecipientFilter()
		rp:AddPlayer( att )
		umsg.Start("EntityTextChangeColor", rp)
			umsg.Entity( ent.AssociatedText )
			umsg.Long( 255 )
			umsg.Long( 0 )
			umsg.Long( 0 )
			umsg.Long( 255 )
		umsg.End()
		
		if not pool.Sequence[pool.PlayerCurrentCrate[att]] then
			att:WarePlayerDestinyWin( )
			att:StripWeapons()
		end
	else
		att:WarePlayerDestinyLose( )
		att:StripWeapons()
	end
end
