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
			prop.AlarmSound = CreateSound(prop, Sound(Alarms[math.random(1,#Alarms)]))
			--prop.AlarmSound:SetSoundLevel(3.9)
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
			GAMEMODE:MakeLankmarkEffect(v:GetPos())
			v.AlarmSound:Stop()
			v.AlarmSound = nil
		end
	end
end

function WARE:PropBreak(pl,prop)
	if not pl:IsPlayer() then return end
	
	if prop.AlarmSound then
		pl:WarePlayerDestinyWin()
		pl:StripWeapons()
		prop.AlarmSound:Stop()
		prop.AlarmSound = nil
		
		local spark = ents.Create("env_spark")
		spark:SetPos(prop:GetPos())
		spark:SetKeyValue("MaxDelay",1)
		spark:SetKeyValue("Magnitude",4)
		spark:SetKeyValue("TrailLength",2)
		spark:Spawn()
		spark:Fire("StartSpark")
		spark:Fire("Kill",0,2)
	end
end
