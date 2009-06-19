WARE.Author = "Hurricaaane (Ha3)"
WARE.Room = "empty"

local possiblenpcs = { "npc_manhack" , "npc_rollermine" }

function WARE:Initialize()
	self.Choice = possiblenpcs[math.random(1,2)]
	GAMEMODE:DrawPlayersTextAndInitialStatus("Flee !",1)
	GAMEMODE:SetWareWindupAndLength(2,8)
	
	return
end

function WARE:StartAction()
	local ratio = 0.7
	local minimum = 3
	local num = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*ratio),minimum,64)
	local entposcopy = GAMEMODE:GetRandomLocations(num, {"dark_inair","light_inair"})
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
