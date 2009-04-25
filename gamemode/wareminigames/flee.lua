WARE.Author = "Hurricaaane (Ha3)"

local possiblenpcs = { "npc_manhack" , "npc_rollermine" }

function WARE:Initialize()
	self.Choice = possiblenpcs[math.random(1,2)]
	if self.Choice == "npc_rollermine" then
		GAMEMODE:DrawPlayersTextAndInitialStatus("Don't be on the boxes !",1)
		GAMEMODE:SetWareWindupAndLength(3,8)
	else
		GAMEMODE:DrawPlayersTextAndInitialStatus("Flee !",1)
		GAMEMODE:SetWareWindupAndLength(1,8)
	end
	
	return
end

function WARE:StartAction()
	if self.Choice == "npc_rollermine" then
		GAMEMODE:DrawPlayersTextAndInitialStatus("Flee !",1)
	end

	local ratio = 0.4
	local minimum = 3
	local num = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*ratio),minimum,64)
	local entposcopy = GAMEMODE:GetRandomLocations(num, ENTS_INAIR)
	for k,v in pairs(entposcopy) do
		local ent = ents.Create (self.Choice);
		ent:SetPos(v:GetPos());
		ent:Spawn();
		
		local phys = ent:GetPhysicsObject()
		phys:ApplyForceCenter (VectorRand() * 16);
		
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
	return
end

function WARE:EndAction()

end

function WARE:EntityTakeDamage( ent, inflictor, attacker, amount)
	if ent:IsPlayer() && attacker:IsNPC( ) then
		ent:WarePlayerDestinyLose( )
	end
end

function WARE:Think( )
	if self.Choice == "npc_rollermine" then
		local entposcopy = 	table.Copy(GAMEMODE:GetEnts(ENTS_ONCRATE))
		for _,block in pairs(entposcopy) do
			local box = ents.FindInBox(block:GetPos()+Vector(-30,-30,0),block:GetPos()+Vector(30,30,64))
			for _,target in pairs(box) do
				if target:IsPlayer() then
					target:WarePlayerDestinyLose( )
				end
			end
		end
	end
end
