WARE.Author = "Hurricaaane (Ha3)"
WARE.Room = "empty"

WARE.Models = {
"models/vehicles/prisoner_pod_inner.mdl",
"models/combine_helicopter/helicopter_bomb01.mdl"
}
 
function WARE:GetModelList()
	return self.Models
end

function WARE:IsPlayable()
	if team.NumPlayers(TEAM_HUMANS) >= 2 then
		return true
	end
	return false
end

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(6,6)
	
	GAMEMODE:SetPlayersInitialStatus( false )
	GAMEMODE:DrawInstructions( "Stay near a pod!" )
	
	for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		v:Give( "sware_rocketpush" )
	end
	
	local ratio = 0.4
	local minimum = 1
	local num = math.Clamp(math.ceil( team.NumPlayers(TEAM_HUMANS) * ratio) , minimum, 64)
	local locations = GAMEMODE:GetRandomLocationsAvoidBox(num, {"dark_ground", "light_ground"},  function(v) return v:IsPlayer() end, Vector(-30,-30,0), Vector(30,30,128))
	
	self.Pods = {}
	
	for k,v in pairs(locations) do
		local pod = ents.Create ("prop_vehicle_prisoner_pod")
		pod:SetModel( self.Models[1] )
		pod:SetAngles( Angle(0,math.random(0,360),0) )
		pod:SetPos( v:GetPos() + Vector(0,0,32) )
		//pod:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		pod:Spawn()
		
		pod:Fire("Lock", "", 0)
		pod:Fire("Open", "", 5.7)
		
		local dynaba = ents.Create ("prop_dynamic_override")
		dynaba:SetModel( self.Models[2] )
		dynaba:SetPos( pod:GetPos() + pod:GetAngles():Up() * 86 + pod:GetAngles():Forward() * 9 )
		dynaba:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		dynaba:Spawn()
		dynaba:SetParent(pod)
		GAMEMODE:AppendEntToBin(dynaba)
		
		constraint.Ballsocket( pod, GetWorldEntity(), 0, 0, pod:GetPos() + pod:GetAngles():Up() * 86 + pod:GetAngles():Forward() * 9, 0, 0, 0 )

		local physObj = pod:GetPhysicsObject()
		if physObj:IsValid() then
			physObj:ApplyForceCenter(VectorRand() * physObj:GetMass() * 32)
		end
		
		GAMEMODE:AppendEntToBin(pod)
		GAMEMODE:MakeAppearEffect(pod:GetPos())
		
		table.insert(self.Pods, pod)
	end
end

function WARE:StartAction()
	GAMEMODE:DrawInstructions( "Get in a pod!" )
	
	for k,pod in pairs(self.Pods) do
		pod:Fire("Unlock", "", 0)
	end
end

function WARE:EndAction()
	timer.Simple(0, function()
		for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do
			v:StripWeapons()
			v:RemoveAllAmmo( )
			v:Give("weapon_physcannon")
		end
	end)
end

function WARE:PlayerEnteredVehicle( ply, vehEnt, role )
	ply:ApplyWin()
	vehEnt:Fire("Close", "", 0)
	vehEnt:Fire("Lock", "", 0)
end

function WARE:CanPlayerEnterVehicle( ply, vehEnt, role )
	if GAMEMODE:PhaseIsPrelude() then return false end
	return true
end

function WARE:CanExitVehicle()
	return false
end

