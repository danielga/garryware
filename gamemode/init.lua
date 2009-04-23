
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "admin.lua" )
AddCSLuaFile( "cl_postprocess.lua" )
AddCSLuaFile( "vgui_ridiculous.lua" )
AddCSLuaFile( "vgui_transitscreen.lua" )
AddCSLuaFile( "vgui_clock.lua" )
AddCSLuaFile( "vgui_clockgame.lua" )
AddCSLuaFile( "vgui_waitscreen.lua" )
AddCSLuaFile( "skin.lua" )
AddCSLuaFile( "tables.lua" )

include( "shared.lua" )
include( "admin.lua" )
include( "tables.lua" )
include( "ply_extension.lua" )

include( "init_effects.lua" )
include( "init_entitygathering.lua" )

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

resource.AddFile("materials/sprites/ware_bullseye.vmt")
resource.AddFile("materials/sprites/ware_bullseye.vtf")
resource.AddFile("materials/sprites/ware_clock.vmt")
resource.AddFile("materials/sprites/ware_clock.vtf")
resource.AddFile("materials/sprites/ware_trotter.vmt")
resource.AddFile("materials/sprites/ware_trotter.vtf")
resource.AddFile("materials/sprites/ware_bubble.vmt")
resource.AddFile("materials/sprites/ware_bubble.vtf")
resource.AddFile("materials/sprites/ware_lock.vmt")
resource.AddFile("materials/sprites/ware_lock.vtf")

--MAP
resource.AddFile("materials/ware/detail.vtf")
resource.AddFile("materials/ware/ware_crate.vmt")
resource.AddFile("materials/ware/ware_crate.vtf")
resource.AddFile("materials/ware/ware_crate2.vmt")
resource.AddFile("materials/ware/ware_crate2.vtf")
resource.AddFile("materials/ware/ware_floorred.vmt")
resource.AddFile("materials/ware/ware_floor.vtf")
resource.AddFile("materials/ware/ware_wallorange.vmt")
resource.AddFile("materials/ware/ware_wallwhite.vtf")

--DEBUG
CreateConVar( "ware_debug", 0, {FCVAR_ARCHIVE} )
CreateConVar( "ware_debugname", "", {FCVAR_ARCHIVE} )


--Initialization functions
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


--Bin functions
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

--Minigame essentials
function GM:PickRandomGame()
	local minigame
	self.WareHaveStarted = true
	
	--Standard initialization
	for k,v in pairs(player.GetAll()) do 
		v:SetNWInt("ware_hasdestiny", 0 )
		v:StripWeapons() -- TEST
	end
	
	--Ware is picked up now
	if GetConVar("ware_debug"):GetInt() > 0 then
		name = GetConVar("ware_debugname"):GetString()
	else
		name = ware_mod.GetRandomGameName()
	end
	
	minigame = ware_mod.Get(name)
	
	--Ware is initialized
	if minigame and minigame.Initialize and minigame.StartAction then
		self.WareID = name
		minigame:Initialize()
	else
		self:SetWareWindupAndLength(3,0)
		self:DrawPlayersTextAndInitialStatus("Error with minigame \""..name.."\".",0)
	end
	self.NextgameEnd = CurTime() + self.Windup + self.WareLen
	
	--Send info about ware
	local rp = RecipientFilter()
	rp:AddAllPlayers()
	umsg.Start("NextGameTimes", rp)
		umsg.Float( CurTime() + self.Windup )
		umsg.Float( self.NextgameEnd )
		umsg.Float( self.Windup )
		umsg.Float( self.WareLen )
	umsg.End()
	--print("---"..CurTime() + self.Windup.."---"..self.NextgameEnd.."---"..self.Windup.."---"..self.WareLen)
end
	
function GM:EndGame()
	if self.WareHaveStarted == true then
		--Destroy all
		if self.ActionPhase == true then
			GAMEMODE:UnhookTriggers(self.WareID)
			self.ActionPhase = false
		end
		local minigame = ware_mod.Get(self.WareID)
		if minigame and minigame.EndAction then minigame:EndAction() end
		self:RemoveEnts()
		self.GamePool = {}

		--Do stuff to player
		for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
			local achieved = v:GetNWInt("ware_achieved")
			local destiny  = v:GetNWInt("ware_hasdestiny")
			
			if (destiny == 0) then
				if achieved >= 1 then
					v:WarePlayerDestinyWin( )
				else
					v:WarePlayerDestinyLose( )
				end
			end
			
			--Reinit player
			v:StripWeapons()
			v:RemoveAllAmmo( )
			v:Give("weapon_physcannon")
			
			--Tell players if they won
			local rp = RecipientFilter()
			rp:AddPlayer( v )
			umsg.Start("EventEndgameSet", rp)
				umsg.Long(achieved)
			umsg.End()
			
			--Clear decals
			v:ConCommand("r_cleardecals")
		end
		for k,v in pairs(team.GetPlayers(TEAM_SPECTATOR)) do
			--Do generic stuff to specs
			local rp = RecipientFilter()
			rp:AddPlayer( v )
			umsg.Start("EventEndgameSet", rp)
				umsg.Long(0)
			umsg.End()
			v:ConCommand("r_cleardecals")
		end
	end
	
	self.NextgameStart = CurTime() + 2.7
	SendUserMessage( "Transit" )
	
	--Reinit
	self.WareHaveStarted = false
	self.WareID = ""
end

function GM:HookTriggers( name )
	local hooks = ware_mod.GetHooks(name)
	if not hooks then return end
	
	for hookname,callback in pairs(hooks) do
		hook.Add(hookname, "WARE"..name..hookname, callback)
	end
end

function GM:UnhookTriggers( name )
	local hooks = ware_mod.GetHooks(name)
	if not hooks then return end
	
	for hookname,_ in pairs(hooks) do
		hook.Remove(hookname, "WARE"..name..hookname)
	end
end

--Include NAO !!!
IncludeMinigames()
	
--Thinking and overrides
function GM:SetNextGameStartsIn( delay )
	self.NextgameStart = CurTime() + delay
	SendUserMessage( "GameStartTime" , nil, self.NextgameStart )
end	

function GM:Think()
	self.BaseClass:Think()
	
	if (self.GamesArePlaying == true) then
		--Starts a new ware
		if (self.WareHaveStarted == false) then
			if (CurTime() > self.NextgameStart) then
				GAMEMODE:PickRandomGame()
				SendUserMessage("WaitHide")
			end
		
		--Starts the action
		else
			if CurTime() > (self.NextgameStart + self.Windup) && self.ActionPhase == false then
				local minigame = ware_mod.Get(self.WareID)
				
				self:HookTriggers(self.WareID)
				if minigame.StartAction then
					minigame:StartAction()
				end
				
				self.ActionPhase = true
			end
			
			if (CurTime() > self.NextgameEnd) then
				GAMEMODE:EndGame()
			end
		end
		
		
		
		--Ends a current game
		if team.NumPlayers(TEAM_UNASSIGNED) == 0 && self.GamesArePlaying == true then
			self.GamesArePlaying = false
			GAMEMODE:EndGame()
			
			--Send info about ware
			local rp = RecipientFilter()
			rp:AddAllPlayers()
			umsg.Start("NextGameTimes", rp)
				umsg.Float( 0 )
				umsg.Float( 0 )
				umsg.Float( 0 )
				umsg.Float( 0 )
			umsg.End()
		end
	
	else
		--Starts a new game
		if team.NumPlayers(TEAM_UNASSIGNED) > 0 && self.GameHasEnded == false && self.GamesArePlaying == false then
			self.GamesArePlaying = true
			self.WareHaveStarted = false
			self.ActionPhase = false
			
			if (GetConVar("ware_debug"):GetInt() > 0) then
				self:SetNextGameStartsIn( 4 )
			else
				self:SetNextGameStartsIn( 22 )
			end
			SendUserMessage( "WaitShow" )
		end
	end
	
	--Adverts
	if (self.NexttimeAdvert - CurTime()) < 0 then
		for k,v in pairs(player.GetAll()) do 
			v:ChatPrint( "This gamemode is called Garry Ware, keep track of it on http://www.facepunch.com/showthread.php?p=14682019" ) 
			v:ChatPrint( "You can also code your own minigames ! Get documented on the Facepunch thread !" ) 
		end
		self.NexttimeAdvert = CurTime() + math.random(60*3,60*5)
	end
end

function GM:EndTheGameForOnce()
	if self.GameHasEnded == true then return end
	self.GamesArePlaying = false
	self.GameHasEnded = true
	GAMEMODE:EndGame()
	
	--Send info about VGUI
	SendUserMessage( "EndOfGamemode_HideVGUI" )
	
	--Send info about ware
	local rp = RecipientFilter()
	rp:AddAllPlayers()
	umsg.Start("NextGameTimes", rp)
		umsg.Float( 0 )
		umsg.Float( 0 )
		umsg.Float( 0 )
		umsg.Float( 0 )
	umsg.End()
end

function GM:EndOfGame( bGamemodeVote )
	self:EndTheGameForOnce()
	
	self.BaseClass:EndOfGame( bGamemodeVote );
end

function GM:StartGamemodeVote()
	self:EndTheGameForOnce()
	
	self.BaseClass:StartGamemodeVote();
end

function GM:PlayerInitialSpawn( ply, id )
	--Give him info about wether the game has begun and when the game ends
	local didnotbegin = false
	if self.NextgameStart < CurTime() then
		didnotbegin = true
	end
	
	local rp = RecipientFilter()
	rp:AddPlayer( ply )
	umsg.Start("ServerJoinInfo", rp)
		umsg.Float( self.TimeWhenGameEnds )
		umsg.Bool( didnotbegin )
	umsg.End()
	
	self.BaseClass:PlayerInitialSpawn( ply, id )
end 
