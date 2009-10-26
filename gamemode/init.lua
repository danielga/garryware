
AddCSLuaFile( "shared.lua" )

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_postprocess.lua" )
AddCSLuaFile( "cl_usermsg.lua" )

AddCSLuaFile( "vgui_transitscreen.lua" )
AddCSLuaFile( "vgui_clock.lua" )
AddCSLuaFile( "vgui_clockgame.lua" )
AddCSLuaFile( "vgui_waitscreen.lua" )
AddCSLuaFile( "skin.lua" )
AddCSLuaFile( "tables.lua" )
AddCSLuaFile( "ply_extension.lua" )
AddCSLuaFile( "garbage_module.lua" )
AddCSLuaFile( "overv_chataddtext.lua" )

include( "shared.lua" )
include( "tables.lua" )

include( "init_effects.lua" )
include( "init_entitygathering.lua" )
include( "overv_chataddtext.lua" )

include( "minigames_module.lua" )
include( "environment_module.lua" )
include( "entitymap_module.lua" )

for k,stringOrTable in pairs(GM.WASND) do
	if type(stringOrTable) == "string" then
		resource.AddFile("sound/" .. stringOrTable)
		
	elseif type(stringOrTable) == "table" then
		for l,sString in pairs(stringOrTable) do
			resource.AddFile("sound/" .. sString)
		end
		
	end
end


AddCSLuaFile( "cl_dhinlinegware_base.lua" )
AddCSLuaFile( "cl_dhinlinegware_element.lua" )

local hudPath = string.Replace(GM.Folder, "gamemodes/", "") .. "/gamemode/dhinlinegware_element/"
for _,file in pairs(file.FindInLua(hudPath .. "*.lua")) do
	AddCSLuaFile(hudPath .. file)
	//print("ADDED TO CLIENT : "..hudPath .. file)
end

resource.AddFile("materials/sprites/ware_bullseye.vmt")
resource.AddFile("materials/sprites/ware_bullseye.vtf")
resource.AddFile("materials/sprites/ware_clock_two.vmt")
resource.AddFile("materials/sprites/ware_clock_two.vtf")
resource.AddFile("materials/sprites/ware_trotter.vmt")
resource.AddFile("materials/sprites/ware_trotter.vtf")

--MAP
resource.AddFile("materials/ware/detail.vtf")
resource.AddFile("materials/ware/ware_crate.vmt")
resource.AddFile("materials/ware/ware_crate.vtf")
resource.AddFile("materials/ware/ware_crate2.vmt")
resource.AddFile("materials/ware/ware_crate2.vtf")
resource.AddFile("materials/ware/ware_floor.vtf")
resource.AddFile("materials/ware/ware_floorred.vmt")
resource.AddFile("materials/ware/ware_wallorange.vmt")
resource.AddFile("materials/ware/ware_wallwhite.vtf")


--Initialization functions
function GM:SetWareWindupAndLength(windup , len)
	self.Windup  = windup
	self.WareLen = len
end

function GM:DrawInstructions( sInstructions , optColorPointer , optTextColorPointer )
	local rp = RecipientFilter();
	rp:AddAllPlayers( );
			
	umsg.Start( "gw_instructions", rp );
	umsg.String( sInstructions );
	// If there is no color, no chars about the color are passed.
	umsg.Bool( optColorPointer != nil )
	if (optColorPointer != nil) then
		// If there is a background color, a bool stating about the presence
		// of a text color must be passed, even if there is no text color !
		umsg.Bool( optTextColorPointer != nil )

		umsg.Char( optColorPointer.r - 128 )
		umsg.Char( optColorPointer.g - 128 )
		umsg.Char( optColorPointer.b - 128 )
		umsg.Char( optColorPointer.a - 128 )
		
		if (optTextColorPointer != nil) then
			umsg.Char( optTextColorPointer.r - 128 )
			umsg.Char( optTextColorPointer.g - 128 )
			umsg.Char( optTextColorPointer.b - 128 )
			umsg.Char( optTextColorPointer.a - 128 )
		end
	end
	umsg.End();
end

function GM:SendEntityTextColor( rpfilterOrPlayer, entity, r, g, b, a )
	umsg.Start("EntityTextChangeColor", rpfilterOrPlayer)
		umsg.Entity( entity )
		umsg.Char( r - 128 )
		umsg.Char( g - 128 )
		umsg.Char( b - 128 )
		umsg.Char( a - 128 )
	umsg.End()
end

function GM:SetPlayersInitialStatus(isAchievedNilIfMystery)
	// nil as an achieved status then can only be set globally (start of game).
	// Use it for games where the status is set on Epilogue (not Ending), while
	// the players shouldn't know if they won or not.
	// Example : Watch the props ! / Stand on the missing prop ! (ver.2)
	
	for k,v in pairs(player.GetAll()) do 
		v:SetAchievedSpecialInteger( ((isAchievedNilIfMystery == nil) and -1) or ((isAchievedNilIfMystery) and 1) or 0 )
	end
	
end

function GM:HasEveryoneLocked()
	local playertable = team.GetPlayers(TEAM_HUMANS)

	local i = 1
	while ( (i <= #playertable) and playertable[i]:GetLocked() ) do
		i = i + 1
	end
	if (i <= #playertable) then
		return false
	end
	
	return true
end

function GM:CheckGlobalStatus( endOfGameBypassValidation )
	if team.NumPlayers(TEAM_HUMANS) < 2 then return false end
	
	local playertable = team.GetPlayers(TEAM_HUMANS)
	
	
	// Has everyone validated their status ?
	// (Don't do that if it's the end of the game. Call Check first ONCE, then validate
	// with bypass of the lock if that function returned true.)
	if not(endOfGameBypassValidation) then
		if not GAMEMODE:HasEveryoneLocked() then return false end
	end
	
	
	// Do everyone have the same status ?
	local probableStatus = playertable[1]:GetAchieved()
	i = 2
	while ( (i <= #playertable) and (playertable[i]:GetAchieved() == probableStatus) ) do
		i = i + 1
	end
	if (i <= #playertable) then
		return false
	end
	
	// Note from Ha3 : Omg, check the usermessage types next time. 1 hour waste
	local rp = RecipientFilter()
	rp:AddAllPlayers( )
	umsg.Start("gw_yourstatus", rp)
		umsg.Bool(probableStatus)
		umsg.Bool(true)
	umsg.End()
	
	return true , probableStatus
end

function GM:SendEveryoneEvent( probable )
	local rpAll = RecipientFilter()
	rpAll:AddAllPlayers()
	
	umsg.Start("EventEveryoneState", rpAll)
		umsg.Bool( probable )
	umsg.End()
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
			
			v.ForcedSpawn = loc
			v:Spawn()
			
			GAMEMODE:MakeAppearEffect(loc:GetPos())
			GAMEMODE:MakeLandmarkEffect(loc:GetPos())
			
			rp:AddPlayer(v)
		end
	end
	
	for _,v in pairs(team.GetPlayers(TEAM_SPECTATOR)) do
		if v:GetEnvironment()~=self.CurrentEnvironment then
			if #spawns==0 then
				spawns = table.Copy(self.CurrentEnvironment.PlayerSpawns)
			end
		
			local loc = table.remove(spawns, math.random(1,#spawns))
			
			v.ForcedSpawn = loc
			v:Spawn()
			
			rp:AddPlayer(v)
		end
	end
	
	SendUserMessage("PlayerTeleported", rp)
end

-- Minigame essentials
function GM:PickRandomGame()
	self.WareHaveStarted = true
	
	--Standard initialization
	for k,v in pairs(player.GetAll()) do 
		v:SetLockedSpecialInteger(0)
		v:StripWeapons()
	end
	
	self.Minigame = ware_mod.CreateInstance(self.NextGameName)
	
	--Ware is initialized
	if self.Minigame and self.Minigame.Initialize and self.Minigame.StartAction then
		self.Minigame:Initialize()
		
	else
		self.Minigame = ware_mod.CreateInstance("_empty")
		self:SetWareWindupAndLength(0,3)
		
	GAMEMODE:SetPlayersInitialStatus( false )
	GAMEMODE:DrawInstructions( "Error with minigame \""..self.NextGameName.."\"." )
		
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
end

function GM:SetNextGameEnd(time)
	if not self.WareHaveStarted or not self.ActionPhase then return end
	
	local t = CurTime()
	
	-- Prevent dividing by zero
	if (t - time ~= 0) and (t - self.NextgameEnd ~= 0) then
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

function GM:GetCurrentMinigameName()
	return (self.Minigame and self.Minigame.Name) or ""
end

function GM:EndGame()
	if self.WareHaveStarted == true then
	
		// Destroy all
		if self.ActionPhase == true then
			GAMEMODE:UnhookTriggers()
			self.ActionPhase = false
		end
		if self.Minigame and self.Minigame.EndAction then self.Minigame:EndAction() end
		self:RemoveEnts()

		local everyoneStatusIsSame, probable = GAMEMODE:CheckGlobalStatus( true )
		if (everyoneStatusIsSame and not GAMEMODE:HasEveryoneLocked()) then
			self:SendEveryoneEvent( probable )
		end
		
		--Do stuff to player
		local rpWin = RecipientFilter()
		local rpLose = RecipientFilter()
		for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
			v:ApplyLock( everyoneStatusIsSame )
			
			local bAchieved = v:GetAchieved()
			if (bAchieved) then
				rpWin:AddPlayer(v)
			else
				rpLose:AddPlayer(v)
			end
			
			--Reinit player
			v:StripWeapons()
			v:RemoveAllAmmo( )
			v:Give("weapon_physcannon")
			
			--Clear decals
			v:ConCommand("r_cleardecals")
		end
		
		// Send positive message to the RP list of winners
		umsg.Start("EventEndgameTrigger", rpWin)
			umsg.Bool( true )
		umsg.End()
		
		// Send negative message to the RP list of winners
		umsg.Start("EventEndgameTrigger", rpLose)
			umsg.Bool( false )
		umsg.End()
		
		if (team.NumPlayers(TEAM_SPECTATOR) != 0) then
			local rpSpec = RecipientFilter()
			for k,v in pairs(team.GetPlayers(TEAM_SPECTATOR)) do
				--Do generic stuff to specs
				
				rpSpec:AddPlayer( v )
				v:ConCommand("r_cleardecals")
			end
			umsg.Start("EventEndgameTrigger", rpSpec)
				umsg.Bool( false )
			umsg.End()
		end
	end
	
	self.NextgameStart = CurTime() + 2.8
	SendUserMessage( "Transit" )
	
	// Reinitialize
	self.WareHaveStarted = false
	
	//Enough time to play ?
	if ((self.TimeWhenGameEnds - CurTime()) < self.NotEnoughTimeCap) then
		self:EndOfGame( true )
	else
		--Ware is picked up now
		self:PickRandomGameName()
	end
end

function GM:PickRandomGameName( first )
	local env
	
	if GetConVar("ware_debug"):GetInt() == 1 then
		self.NextGameName = GetConVar("ware_debugname"):GetString()
		env = ware_env.FindEnvironment(ware_mod.Get(self.NextGameName).Room) or self.CurrentEnvironment
	else
		self.NextGameName, env = ware_mod.GetRandomGameName()
	end
	
	if env ~= self.CurrentEnvironment then
		self.CurrentEnvironment = env
		if not first then
			self.NextgameStart = self.NextgameStart + 1.3
			self.NextPlayerRespawn = CurTime() + 2.8
		else
			self.NextPlayerRespawn = CurTime() + 1
		end
	end
end

function GM:PhaseIsPrelude()
	return CurTime() < (self.NextgameStart + self.Windup)
end

function GM:HookTriggers()
	local hooks = self.Minigame.Hooks
	if not hooks then return end
	
	for hookname,callback in pairs(hooks) do
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
	/*
	if (self.NexttimeAdvert - CurTime()) < 0 then
		for k,v in pairs(player.GetAll()) do 
			v:ChatPrint( "This gamemode is called Garry Ware, keep track of it on http://www.facepunch.com/showthread.php?p=14682019" ) 
			v:ChatPrint( "You can also code your own minigames ! Get documented on the Facepunch thread !" ) 
		end
		self.NexttimeAdvert = CurTime() + math.random(60*3,60*5)
	end
	*/
end

function GM:EndTheGameForOnce()
	if self.GameHasEnded == true then return end
	
	self.GamesArePlaying = false
	self.GameHasEnded = true
	
	// Find combos before ending the game and after saying the game has ended
	for _,ply in pairs(team.GetPlayers(TEAM_HUMANS)) do
		ply:PrintComboMessagesAndEffects( ply:GetCombo() )
	end
	
	GAMEMODE:EndGame()
	
	--Send info about VGUI
	SendUserMessage( "EndOfGamemode" )
	
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

function GM:SendModelList( ply )
	if #self.ModelPrecacheTable <= 0 then return end
	
	local messageSplit = 3
	
	local count = #self.ModelPrecacheTable
	local splits = math.ceil(#self.ModelPrecacheTable / messageSplit)
	
	local lastSplit = #self.ModelPrecacheTable % messageSplit
	local model = ""
	
	for i=1,splits do
		local toSend = ((i < splits) and messageSplit) or lastSplit
		
		umsg.Start("ModelList", ply)
			umsg.Long(toSend)
			for k=1,toSend do
				model = self.ModelPrecacheTable[ (i - 1) * messageSplit + k ]
				umsg.String( model )
			end
		umsg.End()
		
	end
end

function GM:PlayerInitialSpawn( ply, id )
	self.BaseClass:PlayerInitialSpawn( ply, id )


	// Give him info about the current status of the game
	local didnotbegin = false
	if (self.NextgameStart > CurTime()) then
		didnotbegin = true
	end
	
	umsg.Start("ServerJoinInfo", ply )
		umsg.Float( self.TimeWhenGameEnds )
		umsg.Bool( didnotbegin )
	umsg.End()
	umsg.Start("BestStreakEverBreached", ply )
		umsg.Long( self.BestStreakEver )
	umsg.End()
	
	GAMEMODE:SendModelList( ply )
	
	ply:SetComboSpecialInteger( 0 )
end

function GM:PlayerSpawn(ply)
	self.BaseClass:PlayerSpawn( ply )
	
	ply:SetAchievedSpecialInteger( -1 )
	ply:SetLockedSpecialInteger( 1 )
	
	// > wat <
	// NOTE from Ha3 : kilburn have written this, and I don't know what it means. Commented it out.
	--if not (self.CurrentEnvironment) or (#self.CurrentEnvironment.PlayerSpawns == 0) then return end
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
	
	self.TimeWhenGameEnds = CurTime() + self.GameLength * 60.0
	
	for _,v in pairs(ents.FindByClass("func_wareroom")) do
		ware_env.Create(v)
	end
	
	-- No environment found, create the default one
	if #ware_env.GetTable() then
		ware_env.Create()
	end
	
	-- Start with a generic environment
	self.CurrentEnvironment = ware_env.FindEnvironment("generic")
	
	-- Create the precache table
	for k,name in pairs(ware_mod.GetNamesTable()) do
		if (ware_mod.Get(name).GetModelList) then
		
			for j,model in pairs(ware_mod.Get(name):GetModelList() or {}) do
				if (type(model) == "string") and (not table.HasValue( self.ModelPrecacheTable , model )) then
					table.insert( self.ModelPrecacheTable , model )
				end
			end
			
		end
		
	end
	
end

/*
// Silent fall damage leg break sound ?
function GM:EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )
	if ent:IsPlayer() and dmginfo:IsFallDamage() then
		dmginfo:ScaleDamage( 0 )
		return false
	end
end
*/

function LoseWareOnPlayerDeath( victim, weapon, killer )
	victim:ApplyLose()
end
hook.Add( "PlayerDeath", "LoseWareOnPlayerDeath", LoseWareOnPlayerDeath );
