WARE.Author = "Kilburn"

local Alarms = {
	"ambient/alarms/alarm_citizen_loop1.wav",
	"ambient/alarms/alarm1.wav",
	"ambient/alarms/city_firebell_loop1.wav",
	"ambient/alarms/siren.wav",
}

function WARE:Initialize()
	local maxcount = table.Count(GAMEMODE:GetEnts(ENTS_ONCRATE))
	
	local numberAlarmSpawns = math.Clamp(math.ceil(team.NumPlayers(TEAM_UNASSIGNED)*0.5),1,maxcount)
	local numberNormalSpawns = math.Clamp(team.NumPlayers(TEAM_UNASSIGNED)+1,4,maxcount-numberAlarmSpawns)
	
	GAMEMODE:SetWareWindupAndLength(3,8)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Listen and get ready...",0)
	
	for i,pos in ipairs(GAMEMODE:GetRandomPositions(numberAlarmSpawns+numberNormalSpawns, ENTS_ONCRATE)) do
		pos = pos + Vector(0,0,100)
		
		local prop = ents.Create("prop_physics")
		prop:SetModel("models/props_junk/wood_crate001a.mdl")
		prop:PhysicsInit(SOLID_VPHYSICS)
		prop:SetSolid(SOLID_VPHYSICS)
		prop:SetPos(pos)
		prop:Spawn()
		
		prop:SetMoveType(MOVETYPE_NONE)
		
		GAMEMODE:AppendEntToBin(prop)
		GAMEMODE:MakeAppearEffect(pos)
		
		if i<=numberAlarmSpawns then
			local speaker = ents.Create("prop_physics")
			speaker:SetModel("models/props_wasteland/speakercluster01a.mdl")
			speaker:PhysicsInit(SOLID_VPHYSICS)
			speaker:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			speaker:SetSolid(SOLID_VPHYSICS)
			speaker:SetPos(prop:GetPos())
			speaker:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
			speaker:Spawn()
			speaker:SetColor(255,255,255,0)
			speaker:GetPhysicsObject():EnableMotion(false)
			
			speaker.AlarmSound = CreateSound(speaker, Sound(Alarms[math.random(1,#Alarms)]))
			prop.Speaker = speaker
			GAMEMODE:AppendEntToBin(speaker)
		end
	end
end

function WARE:StartAction()
	GAMEMODE:DrawPlayersTextAndInitialStatus("Shut it down ! ",0)
	
	for _,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		v:Give("weapon_crowbar")
	end
	
	for _,v in pairs(ents.FindByClass("prop_physics")) do
		if v.AlarmSound then
			v.AlarmSound:Play()
		end
	end
end

function WARE:EndAction()
	for _,v in pairs(ents.FindByClass("prop_physics")) do
		if v.AlarmSound then
			if not v.AlarmPitch then
				GAMEMODE:MakeLankmarkEffect(v:GetPos())
			end
			v.AlarmSound:Stop()
			v.AlarmSound = nil
		end
	end
end

function WARE:Think()
	for _,v in pairs(ents.FindByClass("prop_physics")) do
		if v.AlarmSound and v.AlarmPitch then
			v.AlarmPitch = v.AlarmPitch - 0.7
			v.AlarmSound:ChangePitch(v.AlarmPitch)
			
			if v.AlarmPitch<=1 then
				v.AlarmSound:Stop()
				v.AlarmSound = nil
				v.AlarmPitch = nil
			end
		end
	end
end

function WARE:PropBreak(pl,prop)
	if not pl:IsPlayer() then return end
	
	if prop.Speaker then
		pl:WarePlayerDestinyWin()
		pl:StripWeapons()
		
		prop.Speaker.AlarmPitch = 100
		
		local spark = ents.Create("env_spark")
		spark:SetPos(prop.Speaker:GetPos())
		spark:SetKeyValue("MaxDelay",1)
		spark:SetKeyValue("Magnitude",4)
		spark:SetKeyValue("TrailLength",2)
		spark:Spawn()
		spark:SetParent(prop.Speaker)
		spark:Fire("StartSpark")
		
		prop.Speaker:SetColor(255,255,255,255)
		prop.Speaker:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		prop.Speaker:GetPhysicsObject():EnableMotion(true)
		prop.Speaker:GetPhysicsObject():Wake()
		prop.Speaker:GetPhysicsObject():AddAngleVelocity(Angle(math.random(500,2000),math.random(500,2000),math.random(500,2000)))
		prop.Speaker:GetPhysicsObject():ApplyForceCenter((prop:GetPos()-pl:GetPos()-Vector(0,0,20)):GetNormal() * math.random(10000,20000))
	end
end
