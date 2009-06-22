WARE.Author = "Hurricaaane (Ha3)"
WARE.Room = "empty"

local PossibleColours = {
	{"red"   , Color(255,0  ,0  ,255)},
	{"blue"  , Color(0  ,0  ,255,255)},
	{"yellow", Color(255,255,0  ,255)},
}


function WARE:Initialize()
	local numberSpawns = #PossibleColours
	
	GAMEMODE:SetWareWindupAndLength(5,3.5)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Memorize !",0)
	
	self.Crates = {}
	
	for i,pos in ipairs(GAMEMODE:GetRandomPositions(numberSpawns, "dark_over")) do
		local prop = ents.Create("prop_physics")
		prop:SetModel("models/props_junk/wood_crate001a.mdl")
		prop:PhysicsInit(SOLID_VPHYSICS)
		prop:SetSolid(SOLID_VPHYSICS)
		local newpos = pos - Vector(0,0,32)
		prop:SetPos(newpos)
		prop:Spawn()
		
		prop:SetColor(255, 255, 255, 192)
		prop:SetHealth(100000)
		prop:GetPhysicsObject():EnableMotion(false)
		prop:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		prop.CrateID = i
		
		self.Crates[i] = prop
		
		local textent = ents.Create("ware_text")
		textent:SetPos(newpos)
		textent:Spawn()
		textent:SetParent(prop)
		
		prop.AssociatedText = textent
		
		GAMEMODE:AppendEntToBin(prop)
		GAMEMODE:AppendEntToBin(textent)
		GAMEMODE:MakeAppearEffect(newpos)
	end
	
	local colors = {}
	for i=1,#PossibleColours do colors[i]=i end
	
	local previousnumber = 0
	self.RolledColor = {}
	self.RolledNumber = {}
	
	for i=1,numberSpawns do
		local chosencolor = table.remove(colors, math.random(1,#colors))
		self.RolledColor[i] = chosencolor
		
		previousnumber = previousnumber + math.random(1,35)
		self.RolledNumber[i] = previousnumber
		self.Crates[i].AssociatedText:SetEntityText(tostring(previousnumber))
	end
	
	timer.Simple(0.1, self.SendColors, self)
	timer.Simple(3.5, self.ReleaseAllCrates, self)
end

function WARE:SendColors()
	local rp = RecipientFilter()
	rp:AddAllPlayers()
	for i=1,#PossibleColours do
		umsg.Start("EntityTextChangeColor", rp)
			umsg.Entity( (self.Crates[i]).AssociatedText )
			umsg.Long( PossibleColours[self.RolledColor[i]][2].r )
			umsg.Long( PossibleColours[self.RolledColor[i]][2].g )
			umsg.Long( PossibleColours[self.RolledColor[i]][2].b )
			umsg.Long( 255 )
		umsg.End()
	end
end

function WARE:ReleaseAllCrates()
	local rp = RecipientFilter()
	rp:AddAllPlayers()
	for i=1,#PossibleColours do
		local physobj = self.Crates[i]:GetPhysicsObject()
		physobj:EnableMotion(true)
		physobj:ApplyForceCenter(VectorRand()*512*physobj:GetMass())
		umsg.Start("EntityTextChangeColor", rp)
			umsg.Entity( (self.Crates[i]).AssociatedText )
			umsg.Long( 0 )
			umsg.Long( 0 )
			umsg.Long( 0 )
			umsg.Long( 0 )
		umsg.End()
	end
end

function WARE:StartAction()
	local what_property_color = math.random(0,1)
	self.WinnerID = math.random(1,#PossibleColours)
	if (what_property_color == 1) then
		local text = PossibleColours[self.RolledColor[self.WinnerID]][1]
		GAMEMODE:DrawPlayersTextAndInitialStatus("Shoot the ".. text .." one !",0)
	else
		local text = self.RolledNumber[self.WinnerID]
		GAMEMODE:DrawPlayersTextAndInitialStatus("Shoot the "..text.." !",0)
	end
	
	for _,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		v:Give("gmdm_pistol")
		v:GiveAmmo(12, "Pistol", true)
	end
end

function WARE:EndAction()

end

function WARE:EntityTakeDamage(ent,inf,att,amount,info)
	local pool = self
	
	if not att:IsPlayer() or not info:IsBulletDamage() then return end
	if not pool.Crates or not ent.CrateID then return end
	
	GAMEMODE:MakeAppearEffect(ent:GetPos())
	
	local rp = RecipientFilter()
	rp:AddPlayer( att )
	if self.WinnerID  == ent.CrateID then
		att:WarePlayerDestinyWin( )
		att:StripWeapons()
		
		for i=1,#PossibleColours do
			if (i == self.WinnerID) then
				umsg.Start("EntityTextChangeColor", rp)
					umsg.Entity( (pool.Crates[i]).AssociatedText )
					umsg.Long( PossibleColours[pool.RolledColor[i]][2].r )
					umsg.Long( PossibleColours[pool.RolledColor[i]][2].g )
					umsg.Long( PossibleColours[pool.RolledColor[i]][2].b )
					umsg.Long( 255 )
				umsg.End()
			else
				umsg.Start("EntityTextChangeColor", rp)
					umsg.Entity( (pool.Crates[i]).AssociatedText )
					umsg.Long( (PossibleColours[pool.RolledColor[i]][2].r)/2 )
					umsg.Long( (PossibleColours[pool.RolledColor[i]][2].g)/2 )
					umsg.Long( (PossibleColours[pool.RolledColor[i]][2].b)/2 )
					umsg.Long( 255 )
				umsg.End()
			end
		end
	else
		att:WarePlayerDestinyLose( )
		att:StripWeapons()
		
		for i=1,#PossibleColours do
			if (i == self.WinnerID) then
				umsg.Start("EntityTextChangeColor", rp)
					umsg.Entity( (pool.Crates[i]).AssociatedText )
					umsg.Long( PossibleColours[pool.RolledColor[i]][2].r )
					umsg.Long( PossibleColours[pool.RolledColor[i]][2].g )
					umsg.Long( PossibleColours[pool.RolledColor[i]][2].b )
					umsg.Long( 255 )
				umsg.End()
			elseif (i == ent.CrateID) then
				umsg.Start("EntityTextChangeColor", rp)
					umsg.Entity( (pool.Crates[i]).AssociatedText )
					umsg.Long( (PossibleColours[pool.RolledColor[i]][2].r)/2 )
					umsg.Long( (PossibleColours[pool.RolledColor[i]][2].g)/2 )
					umsg.Long( (PossibleColours[pool.RolledColor[i]][2].b)/2 )
					umsg.Long( 192 )
				umsg.End()
			else
				umsg.Start("EntityTextChangeColor", rp)
					umsg.Entity( (pool.Crates[i]).AssociatedText )
					umsg.Long( (PossibleColours[pool.RolledColor[i]][2].r)/2 )
					umsg.Long( (PossibleColours[pool.RolledColor[i]][2].g)/2 )
					umsg.Long( (PossibleColours[pool.RolledColor[i]][2].b)/2 )
					umsg.Long( 255 )
				umsg.End()
			end
		end
	end
end
