WARE.Author = "Hurricaaane (Ha3)"
WARE.Room = "empty"

WARE.Models = {
"models/breen.mdl",
"models/props_lab/monitor02.mdl"
 }
WARE.DrHax = nil
WARE.HaxSounds = {
"vo/npc/male01/thehacks01.wav",
"vo/npc/male01/hacks01.wav"
	}

function WARE:GetModelList()
	return self.Models
end

function WARE:IsPlayable()
	return false
end

function WARE:Initialize()	
	GAMEMODE:SetWareWindupAndLength(4, 8)
	
	GAMEMODE:SetPlayersInitialStatus( true )
	GAMEMODE:DrawInstructions( "Hide from Dr. Hax !" )
	
	-- HAXX
	-- Lets add a lua mod when he sees someone.
	local lua_run = ents.Create("lua_run")
	--lua_run:SetKeyValue('Code','CALLER:SetNWEntity("CanOwner",ACTIVATOR)')
	lua_run:SetKeyValue('Code','WARE_DrHaxSeen(CALLER, ACTIVATOR)')
	lua_run:SetKeyValue('targetname','luarun')
	lua_run:Spawn()
	
	local location = GAMEMODE:GetRandomLocationsAvoidBox(1, {"dark_ground", "light_ground"}, function(v) return v:IsPlayer() end, Vector(-30,-30,0), Vector(30,30,64))[1]
	
	local ent = ents.Create("npc_breen")
	ent:SetPos(location:GetPos())
	ent:Spawn()
	ent:SetHealth(10000000)
	
	self.DrHax = ent
	
	GAMEMODE:AppendEntToBin(ent)
	GAMEMODE:MakeAppearEffect(ent:GetPos())
	
	local bone = ent:LookupBone("ValveBiped.Bip01_Head1")
	if bone then
		local matrix = ent:GetBoneMatrix(bone)
		matrix:Scale( Vector(2,2,2) )
		ent:SetBoneMatrix(bone, matrix)
	end
	
	for k,ply in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		ply:Give("sware_rocketpush")
	end
end

function WARE_DrHaxSeen( drhax, ply )
	if (ply:GetAchieved() == false) then return end
	
	ply:ApplyLose()
	self.DrHax:EmitSound(self.HaxSounds[math.random(1,#self.HaxSounds)])
	
	ply:SetAngles(Angle(0,(self.DrHax:GetPos() - ply:GetPos()):Angle().y,0))
	ply:Freeze( true )
	
	local comp = ents.Create ("prop_physics")
	comp:SetModel( self.Models[2] )
	comp:SetPos(self.DrHax:GetPos() + Vector(0,0,128))
	comp:SetAngles(Angle(0,math.random(0,360),0))
	comp:Spawn()
	
	comp:SetMass(128)
	
	local physobj = comp:GetPhysicsObject()
	if physobj:IsValid() then
		physobj:ApplyForceCenter((ply:GetPos() - comp:GetPos()) * 2 * comp:GetMass())
	end
end

function WARE:StartAction()
	self.DrHax:Fire("AddOutput", "OnFoundPlayer luarun,RunCode")
end

function WARE:EndAction()
	for _,v in pairs(ents.FindByClass("lua_run")) do
		v:Remove()
	end
	
	for k,ply in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		ply:Freeze( false )
	end
end
