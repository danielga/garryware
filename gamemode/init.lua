
AddCSLuaFile( "shared.lua" )

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_postprocess.lua" )
AddCSLuaFile( "cl_usermsg.lua" )

AddCSLuaFile( "vgui_ridiculous.lua" )
AddCSLuaFile( "vgui_transitscreen.lua" )
AddCSLuaFile( "vgui_clock.lua" )
AddCSLuaFile( "vgui_clockgame.lua" )
AddCSLuaFile( "vgui_waitscreen.lua" )
AddCSLuaFile( "skin.lua" )
AddCSLuaFile( "tables.lua" )
AddCSLuaFile( "ply_extension.lua" )

include( "shared.lua" )
include( "admin.lua" )
include( "tables.lua" )
--include( "ply_extension.lua" )

include( "init_effects.lua" )
include( "init_entitygathering.lua" )

include( "minigames_module.lua" )
include( "environment_module.lua" )
include( "entitymap_module.lua" )

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

function GM:CheckAllPlayersStatus()
	if #team.GetPlayers(TEAM_HUMANS) < 2 then return end
	
	local playertable = team.GetPlayers(TEAM_HUMANS)
	
	--Has everyone validated their status ?
	local i = 1
	while ( (i <= #playertable) and (playertable[i]:GetNWInt("ware_hasdestiny",0) == 1) ) do
		i = i + 1
	end
	if (i <= #playertable) then /*print("destiny isnt at 1")*/ return false end
	
	--Do everyone have the same status ?
	local probable = playertable[1]:GetNWInt("ware_achieved",0)
	i = 2
	while ( (i <= #playertable) and (playertable[i]:GetNWInt("ware_achieved",0) == probable) ) do
		i = i + 1
	end
	if (i <= #playertable) then /*print("achieved isnt the same")*/ return false end
	
	
	local rp = RecipientFilter()
	rp:AddAllPlayers( )
	umsg.Start("EventEveryoneState", rp)
		umsg.Long(probable)
	umsg.End()
	
	local message = ""
	if (probable > 0) then
		message = "Everyone won !"
	else
		message = "Everyone failed !"
	end
	
	for k,v in pairs(player.GetAll()) do
		v:PrintMessage( HUD_PRINTCENTER , message )
	end
	
	return true
end

/*
function GM:StreamParticlesToClient(tableClients,materialpath,number,duration,data)
	datastream.StreamToClients(
		tableClients,
		"RemoteMakeParticles",
		{
			["materialpath"] = materialpath,
			["number"] = number,
			["duration"] = duration,
			["posx_rel"] = data[1],
			["posy_rel"] = data[2],
			["sizemin"] = data[3],
			["sizemax"] = data[4],
			["sizeendmin"] = data[5],
			["sizeendmax"] = data[6],
			["dir_angle"] = data[7],
			["diffusemin"] = data[8],
			["diffusemax"] = data[9],
			["distancemin"] = data[10],
			["distancemax"] = data[11],
			["color"] = data[12],
			["colorend"] = data[13],
			["gravity"] = data[14],
			["resist"] = data[15]
		}
	);
end
*/

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

function GM:RespawnAllPlayers()
	if not self.CurrentEnvironment then return end
	
	local rp = RecipientFilter()
	
	local spawns = {}
	-- Priority goes to active players, so they don't spawn in each other
	for _,v in pairs(team.GetPlayers(TEAM_HUMANS)) do
		if v:GetEnvironment()~=self.CurrentEnvironment then
			if #spawns==0 then
				spawns = table.Copy(self.CurrentEnvironment.PlayerSpawns)
			end
		
			GAMEMODE:MakeDisappearEffect(v:GetPos())
			local loc = table.remove(spawns, math.random(1,#spawns))
			
			--v:SetPos(loc:GetPos())
			--v:SetAngles(loc:GetAngles())
			v.ForcedSpawn = loc
			v:Spawn()
			
			GAMEMODE:MakeAppearEffect(loc:GetPos())
			GAMEMODE:MakeLandmarkEffect(loc:GetPos())
			
			rp:AddPlayer(v)
			--Msg("Teleported player \""..v:GetName().."\"\n")
		end
	end
	
	for _,v in pairs(team.GetPlayers(TEAM_SPECTATOR)) do
		if v:GetEnvironment()~=self.CurrentEnvironment then
			if #spawns==0 then
				spawns = table.Copy(self.CurrentEnvironment.PlayerSpawns)
			end
		
			local loc = table.remove(spawns, math.random(1,#spawns))
			
			--v:SetPos(loc:GetPos())
			--v:SetAngles(loc:GetAngles())
			v.ForcedSpawn = loc
			v:Spawn()
			
			rp:AddPlayer(v)
			--Msg("Teleported player \""..v:GetName().."\"\n")
		end
	end
	
	SendUserMessage("PlayerTeleported", rp)
end

--Minigame essentials
function GM:PickRandomGame()
	self.WareHaveStarted = true
	
	--Standard initialization
	for k,v in pairs(player.GetAll()) do 
		v:SetNWInt("ware_hasdestiny", 0 )
		v:StripWeapons() -- TEST
	end
	
	self.Minigame = ware_mod.CreateInstance(self.NextGameName)
	
	--Ware is initialized
	if self.Minigame and self.Minigame.Initialize and self.Minigame.StartAction then
		--self.WareID = name
		self.Minigame:Initialize()
	else
		self.Minigame = ware_mod.CreateInstance("_empty")
		self:SetWareWindupAndLength(0,3)
		self:DrawPlayersTextAndInitialStatus("Error with minigame \""..self.NextGameName.."\".",0)
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

function GM:SetNextGameEnd(time)
	if not self.WareHaveStarted or not self.ActionPhase then return end
	
	local t = CurTime()
	
	-- prevent dividing by zero
	if t-time~=0 and t-self.NextgameEnd~=0 then
		self.WareLen = self.WareLen * (t - time) / (t - self.NextgameEnd)
	end
	
	self.NextgameEnd = time
	
	local rp = RecipientFilter()
	rp:AddAllPlayers()
	umsg.Start("NextGameTimes", rp)
		umsg.Float( 0 )
		umsg.Float( self.NextgameEnd )
		umsg.Float( self.Windup )
		umsg.Float( self.WareLen )
		umsg.Bool( true )
	umsg.End()
end

function GM:EndGame()
	if self.WareHaveStarted == true then
		--Destroy all
		if self.ActionPhase == true then
			GAMEMODE:UnhookTriggers()
			self.ActionPhase = false
		end
		if self.Minigame and self.Minigame.EndAction then self.Minigame:EndAction() end
		self:RemoveEnts()
		--self.GamePool = {}

		--Do stuff to player
		for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
			local achieved = v:WareApplyDestiny()
			
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
	--self.WareID = ""
	
	--Ware is picked up now
	self:PickRandomGameName()
end

function GM:PickRandomGameName(first)
	local env
	if GetConVar("ware_debug"):GetInt() > 0 then
		self.NextGameName = GetConVar("ware_debugname"):GetString()
		env = ware_env.FindEnvironment(ware_mod.Get(self.NextGameName).Room) or self.CurrentEnvironment
	else
		self.NextGameName, env = ware_mod.GetRandomGameName()
	end
	
	if env~=self.CurrentEnvironment then
		self.CurrentEnvironment = env
		if not first then
			self.NextgameStart = self.NextgameStart + 1
			self.NextPlayerRespawn = CurTime() + 2.7
		else
			self.NextPlayerRespawn = CurTime() + 1
		end
	end
end

function GM:HookTriggers()
	local hooks = self.Minigame.Hooks
	if not hooks then return end
	
	for hookname,callback in pairs(hooks) do
		--hook.Add(hookname, "WARE"..name..hookname,function(...) local state = callback(unpack(arg)) print(state) return state end)
		hook.Add(hookname, "WARE"..self.Minigame.Name..hookname,callback)
	end
end

function GM:UnhookTriggers()
	local hooks = self.Minigame.Hooks
	if not hooks then return end
	
	for hookname,_ in pairs(hooks) do
		hook.Remove(hookname, "WARE"..self.Minigame.Name..hookname)
	end
end

--Include NAO !!!
IncludeMinigames()

--DEBUG
CreateConVar( "ware_debug", 0, {FCVAR_ARCHIVE} )
CreateConVar( "ware_debugname", "", {FCVAR_ARCHIVE} )

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
			
			if self.NextPlayerRespawn and CurTime() > self.NextPlayerRespawn then
				GAMEMODE:RespawnAllPlayers()
				self.NextPlayerRespawn = nil
			end
		
		--Starts the action
		else
			if CurTime() > (self.NextgameStart + self.Windup) && self.ActionPhase == false then
				if self.Minigame then
					self:HookTriggers()
					if self.Minigame.StartAction then
						self.Minigame:StartAction()
					end
				end
				
				self.ActionPhase = true
			end
			
			if (CurTime() > self.NextgameEnd) then
				GAMEMODE:EndGame()
			end
		end
		
		
		
		--Ends a current game
		if team.NumPlayers(TEAM_HUMANS) == 0 && self.GamesArePlaying == true then
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
		elseif self.FirstTimePickGame and CurTime()>self.FirstTimePickGame then
			-- Game has just started, pick the first game
			self:PickRandomGameName()
			self.FirstTimePickGame = nil
		end
	
	else
		--Starts a new game
		if team.NumPlayers(TEAM_HUMANS) > 0 && self.GameHasEnded == false && self.GamesArePlaying == false then
			self.GamesArePlaying = true
			self.WareHaveStarted = false
			self.ActionPhase = false
			
			if (GetConVar("ware_debug"):GetInt() > 0) then
				self:SetNextGameStartsIn( 4 )
				self.FirstTimePickGame = 1.3
			else
				self:SetNextGameStartsIn( 22 )
				self.FirstTimePickGame = 19.3
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
	
	--Find combos before ending the game and after saying the game has ended
	for _,ply in pairs(team.GetPlayers(TEAM_HUMANS)) do
		local combo = ply:GetNWInt("combo",0)
		if (ply:GetNWBool("dominating",false) == true) then			
			for k,v in pairs(player.GetAll()) do 
				v:ChatPrint( ply:GetName() .. "'s combo streak reached "..combo.." wins in a row !" )
			end
		end
	end
	
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
	umsg.Start("BestStreakEverBreached", rp)
		umsg.Long( self.BestStreakEver )
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
	self.BaseClass:PlayerInitialSpawn( ply, id )


	--Give him info about wether the game has begun and when the game ends
	local didnotbegin = false
	if self.NextgameStart > CurTime() then
		didnotbegin = true
	end
	
	local rp = RecipientFilter()
	rp:AddPlayer( ply )
	umsg.Start("ServerJoinInfo", rp)
		umsg.Float( self.TimeWhenGameEnds )
		umsg.Bool( didnotbegin )
	umsg.End()
	umsg.Start("BestStreakEverBreached", rp)
		umsg.Long( self.BestStreakEver )
	umsg.End()
	ply:SetNWInt("combo",0)
	ply:SetNWBool("dominating",false)
	
	--Msg("Player "..ply:GetName().." has just spawned\n")
	--[[
	if self.CurrentEnvironment and #self.CurrentEnvironment.PlayerSpawns>0 then
		local loc = self.CurrentEnvironment.PlayerSpawns[math.random(1,#self.CurrentEnvironment.PlayerSpawns)]
		ply:SetPos(loc:GetPos())
		ply:SetAngles(loc:GetAngles())
	end]]
end

function GM:PlayerSpawn(ply)
	self.BaseClass:PlayerSpawn(ply)
	
	if not self.CurrentEnvironment or #self.CurrentEnvironment.PlayerSpawns==0 then return end
	
	--Msg("Respawning player "..ply:GetName().." in environment "..self.CurrentEnvironment.ID.."\n")
	
	--[[
	local loc = self.CurrentEnvironment.PlayerSpawns[math.random(1,#self.CurrentEnvironment.PlayerSpawns)]
	
	ply:SetPos(loc:GetPos())
	ply:SetAngles(loc:GetAngles())]]
end

function GM:PlayerSelectSpawn(ply)
	if ply.ForcedSpawn then
		local spawn = ply.ForcedSpawn
		ply.ForcedSpawn = nil
		return spawn
	end
	
	local spawns
	
	if self.CurrentEnvironment then
		spawns = self.CurrentEnvironment.PlayerSpawns
	end
	
	if not spawns or #spawns==0 then
		spawns = ents.FindByClass("info_player_start")
	end
	
	return spawns[math.random(1,#spawns)]
end

function GM:InitPostEntity( )
	self.BaseClass:InitPostEntity()
	
	RemoveUnplayableMinigames()

	self.GamesArePlaying = false
	self.WareHaveStarted = false
	self.ActionPhase = false
	self.GameHasEnded = false
	
	self.NextgameStart = CurTime() + 8
	self.NexttimeAdvert = CurTime() + 32
	
	self.TimeWhenGameEnds = CurTime() + self.GameLength
	
	for _,v in pairs(ents.FindByClass("func_wareroom")) do
		ware_env.Create(v)
	end
	
	-- No environment found, create the default one
	if #ware_env.GetTable() then
		ware_env.Create()
	end
	
	-- Start with a generic environment
	self.CurrentEnvironment = ware_env.FindEnvironment("generic")
end

function LoseDestinyOnPlayerDeath( victim, weapon, killer )
	victim:WarePlayerDestinyLose()
end
hook.Add( "PlayerDeath", "LoseDestinyOnPlayerDeath", LoseDestinyOnPlayerDeath );
