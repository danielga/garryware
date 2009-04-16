
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "admin.lua" )
AddCSLuaFile( "cl_postprocess.lua" )
AddCSLuaFile( "vgui_ridiculous.lua" )
AddCSLuaFile( "vgui_transitscreen.lua" )
AddCSLuaFile( "skin.lua" )

include( "shared.lua" )
include( "admin.lua" )
include( "tables.lua" )
include( "ply_extension.lua" )

resource.AddFile("sound/ware/crit_hit1.wav")
resource.AddFile("sound/ware/crit_hit2.wav")
resource.AddFile("sound/ware/crit_hit3.wav")
resource.AddFile("sound/ware/crit_hit4.wav")
resource.AddFile("sound/ware/crit_hit5.wav")

resource.AddFile("sound/ware/crit_hit_other.wav")

resource.AddFile("sound/ware/announcer_begins_1sec.mp3")
resource.AddFile("sound/ware/announcer_begins_2sec.mp3")
resource.AddFile("sound/ware/announcer_begins_3sec.mp3")
resource.AddFile("sound/ware/announcer_begins_4sec.mp3")
resource.AddFile("sound/ware/announcer_begins_5sec.mp3")

resource.AddFile("sound/ware/game_new.mp3")
resource.AddFile("sound/ware/game_lose.mp3")
resource.AddFile("sound/ware/game_win.mp3")

local minigames = {}
local minigames_Names = {}

CreateConVar( "ware_debug", 0, {FCVAR_ARCHIVE} )
CreateConVar( "ware_debugname", "", {FCVAR_ARCHIVE} )

function GM:SetWareWindupAndLength(windup , len)
	self.Windup  = windup
	self.WareLen = len
end

function GM:DrawPlayersTextAndInitialStatus(text , initialAchievedInt)
	for k,v in pairs(player.GetAll()) do 
		v:PrintMessage(HUD_PRINTCENTER , text)
		v:SetNWInt("ware_achieved", initialAchievedInt )
	end
end

function GM:SetWareID(name)
	self.WareID = name
end

function GM:GetWareID()
	return self.WareID
end

function GM:MakeAppearEffect( pos )
	local ed = EffectData()
	ed:SetOrigin( pos )
	util.Effect("ware_appear", ed, true, true)
end

function GM:MakeDisappearEffect( pos )
	local ed = EffectData()
	ed:SetOrigin( pos )
	util.Effect("ware_disappear", ed, true, true)
end

function GM:MakeLankmarkEffect( pos )
	local ed = EffectData()
	ed:SetOrigin( pos )
	util.Effect("ware_landmark", ed, true, true)
end

function GM:AppendEntToBin( ent )
	table.insert(GAMEMODE.WareEnts,ent)
end

function GM:RemoveEnts()
	for k,v in pairs(GAMEMODE.WareEnts) do
		if (ValidEntity(v)) then
			GAMEMODE:MakeDisappearEffect(v:GetPos())
			v:Remove()
		end
	end
end

function GM:PickRandomGame()
	self.WareHaveStarted = true
	self.TickAnnounce = 5
	
	for k,v in pairs(player.GetAll()) do 
		v:SetNWInt("ware_hasdestiny", 0 )
		v:SendLua( "LocalPlayer():EmitSound( \"" .. GAMEMODE.NewWareSound .. "\" );" );
	end
	
	table.sort(minigames_Names,function(a,b) return a[2] < b[2] end)
	local name = minigames_Names[1][1]
	
	if (GetConVar("ware_debug"):GetInt() > 0) then name = GetConVar("ware_debugname"):GetString() end --debugging
	
	if (minigames[name] != nil && minigames[name][1] != nil && minigames[name][2] != nil) then
		minigames[name][1]()
		timer.Simple(self.Windup,GAMEMODE.SetWareID,GAMEMODE,name)
		timer.Simple(self.Windup,minigames[name][2])
	else
		GAMEMODE:SetWareWindupAndLength(3,0)
		GAMEMODE:DrawPlayersTextAndInitialStatus("Error with minigame \""..name.."\".",0)
	end
	self.NextgameEnd = CurTime() + self.Windup + self.WareLen
end

function GM:GetEnts( group )
  if     group == ENTS_ONCRATE then
	return GAMEMODE.EntsOnCrate
	
  elseif group == ENTS_OVERCRATE then
	return GAMEMODE.EntsOverCrate
	
  elseif group == ENTS_INAIR then
	return GAMEMODE.EntsInAir
	
  elseif group == ENTS_CROSS then
	return GAMEMODE.EntsCross
	
  else
	return {}
  end
end
	
function GM:EndGame()
	if (self.WareHaveStarted == false) then return end
	self.WareHaveStarted = false
	
	if (minigames[self.WareID] != nil && minigames[self.WareID][3] != nil) then minigames[self.WareID][3]() end
	self:RemoveEnts()
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		local achieved = v:GetNWInt("ware_achieved")
		local destiny = v:GetNWInt("ware_hasdestiny")
		
		if (destiny == 0) then
			if achieved >= 1 then
				self:WarePlayerDestinyWin( v )
			else
				self:WarePlayerDestinyLose( v )
			end
		end
		
		v:StripWeapons()
		v:RemoveAllAmmo( )
		//v:Give("weapon_hands")
		
		if achieved >= 1 then
			v:SendLua( "LocalPlayer():EmitSound( \"" .. GAMEMODE.WinWareSound .. "\" );" );
		else
			v:SendLua( "LocalPlayer():EmitSound( \"" .. GAMEMODE.LoseWareSound .. "\" );" );
		end
	end
	
	minigames_Names[1][2] = math.ceil(minigames_Names[1][2]) + math.random(0,95)*0.01
	self.NextgameStart = CurTime() + 2.7
	SendUserMessage( "Transit" )
	
	self.WareID = ""
end

function GM:WarePlayerDestinyWin( player )
	if player:Team() != TEAM_UNASSIGNED       then return end
	if player:GetNWInt("ware_hasdestiny") > 0 then return end
	
	player:SetNWInt("ware_achieved", 1 )
	player:SetNWInt("ware_hasdestiny", 1 )
	player:PrintMessage(HUD_PRINTCENTER , "Success !")
	player:SendLua( "LocalPlayer():EmitSound( \"" .. table.Random(GAMEMODE.WinTriggerSounds) .. "\" );" );
	player:EmitSound(GAMEMODE.WinOther)
	
	player:AddFrags( 1 )
	
	local ed = EffectData()
	ed:SetOrigin( player:GetPos() )
	util.Effect("ware_good", ed, true, true)
end

function GM:WarePlayerDestinyLose( player )
	if player:Team() != TEAM_UNASSIGNED then return end
	if player:GetNWInt("ware_hasdestiny") > 0 then return end
	
	player:SetNWInt("ware_achieved", 0 )
	player:SetNWInt("ware_hasdestiny", 1 )
	player:PrintMessage(HUD_PRINTCENTER , "Fail !")
	player:SendLua( "LocalPlayer():EmitSound( \"" .. table.Random(GAMEMODE.LoseTriggerSounds) .. "\" );" );
	player:EmitSound(GAMEMODE.LoseOther)
	
	player:AddDeaths( 1 )
	
	local ed = EffectData()
	ed:SetOrigin( player:GetPos() )
	util.Effect("ware_bad", ed, true, true)
end

function registerMinigame(name, funcInit, funcAct, funcDestroy)
	if (funcDestroy == nil) then
		minigames[name] = { funcInit, funcAct }
	else
		minigames[name] = { funcInit, funcAct , funcDestroy }
	end
	table.insert(minigames_Names,{name , math.random(0,95)*0.01})
	print("Minigame \""..name.."\" added ! ")
end

/*
I can't get to make this function
function registerTrigger(name, hookName, func)
	hook.Add( hookName, "WARE"..name..hookName,
	function(self,args)
		if GAMEMODE:GetWareID() == name then
			
		end
	); 
end
*/

IncludeMinigames()
	
function GM:SetNextGameStartsIn( delay )
	self.NextgameStart = CurTime() + delay
	SendUserMessage( "GameStartTime" , nil, self.NextgameStart )
end	

function GM:Think()

	self.BaseClass:Think()
	
	if (self.GamesArePlaying == true && self.WareHaveStarted == false) then
		if (CurTime() > self.NextgameStart) then
			SendUserMessage( "WaitHide" )
			GAMEMODE:PickRandomGame()
		end
	elseif (self.GamesArePlaying == true && self.WareHaveStarted == true) then
		if (CurTime() > (self.NextgameEnd - (self.WareLen/6)*self.TickAnnounce )) then
			for k,v in pairs(player.GetAll()) do 
				if     self.TickAnnounce == 5 then v:SendLua( "LocalPlayer():EmitSound( \"" .. GAMEMODE.Left5 .. "\" );" );
				elseif self.TickAnnounce == 4 then v:SendLua( "LocalPlayer():EmitSound( \"" .. GAMEMODE.Left4 .. "\" );" );
				elseif self.TickAnnounce == 3 then v:SendLua( "LocalPlayer():EmitSound( \"" .. GAMEMODE.Left3 .. "\" );" );
				elseif self.TickAnnounce == 2 then v:SendLua( "LocalPlayer():EmitSound( \"" .. GAMEMODE.Left2 .. "\" );" );
				elseif self.TickAnnounce == 1 then v:SendLua( "LocalPlayer():EmitSound( \"" .. GAMEMODE.Left1 .. "\" );" );
				end
			end
			self.TickAnnounce = self.TickAnnounce - 1
		end
		if (CurTime() > self.NextgameEnd) then
			GAMEMODE:EndGame()
		end
	end
	
	if team.NumPlayers(TEAM_UNASSIGNED) > 0 && self.GamesArePlaying == false then
	
		self.GamesArePlaying = true
		self.WareHaveStarted = false
		
		self:SetNextGameStartsIn( 15 )
		SendUserMessage( "WaitShow" )
		
	elseif team.NumPlayers(TEAM_UNASSIGNED) == 0 && self.GamesArePlaying == true then
		self.GamesArePlaying = false
		GAMEMODE:EndGame()
	end
	
end

