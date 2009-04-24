if( SERVER ) then
	AddCSLuaFile( "ply_extension.lua" );
end
include( "ply_extension.lua" );
include( "minigames_module.lua" )

GM.Name 	= "Garry Ware"
GM.Author 	= "Hurricaaane (Ha3)"
GM.Email 	= ""
GM.Website 	= ""

DeriveGamemode( "fretta" )
IncludePlayerClasses()

GM.Help		= "Do what she says\n\nMinigame crafters:\nHurricaaane, Kelth, Kilburn, Frostyfrog, and you?\n\nCredits goes to DasMatze and Valve for the Meet the Sniper flourish. Special thanks to : Kilburn (for minigame registering improvement)"
GM.TeamBased = false
GM.AllowAutoTeam = true
GM.AllowSpectating = true
GM.SelectClass = false
GM.SecondsBetweenTeamSwitches = 3
GM.GameLength = 7.36
GM.NoPlayerSuicide = true
GM.NoPlayerDamage = true
GM.NoPlayerSelfDamage = true
GM.NoPlayerTeamDamage = true
GM.NoPlayerPlayerDamage = true
GM.NoNonPlayerPlayerDamage = true

GM.MaximumDeathLength = 1			// Player will repspawn if death length > this (can be 0 to disable)
GM.MinimumDeathLength = 1			// Player has to be dead for at least this long
GM.ForceJoinBalancedTeams = false	// Players won't be allowed to join a team if it has more players than another team

GM.NoAutomaticSpawning = false		// Players don't spawn automatically when they die, some other system spawns them
GM.RoundBased = false				// Round based, like CS
GM.RoundLength = 5*60				// Round length, in seconds 
GM.RoundEndsWhenOneTeamAlive = false


GM.GamesArePlaying = false
GM.GameHasEnded = false
GM.WareHaveStarted = false
GM.ActionPhase = false
GM.WareID = ""
GM.NextgameStart = 0
GM.NextgameEnd = 0
GM.Windup = 2
GM.WareLen = 100
GM.TickAnnounce = 0

GM.GamePool = {}

function GM:CreateTeams()
	
	team.SetUp( TEAM_UNASSIGNED, "Players", Color( 255, 255, 100 ), true )
	team.SetSpawnPoint( TEAM_UNASSIGNED, "info_player_start" )
	team.SetClass( TEAM_UNASSIGNED, { "Default" } )
	
	team.SetUp( TEAM_SPECTATOR, "Spectators", Color( 200, 200, 200 ), true )
	team.SetSpawnPoint( TEAM_SPECTATOR, "info_player_start" )
	team.SetClass( TEAM_SPECTATOR, { "Spectator" } )

end

function IncludeMinigames()
	local path = string.Replace(GM.Folder, "gamemodes/", "").."/gamemode/wareminigames/"
	local names = {}
	local authors = {}
	local str = ""
	for _,file in pairs(file.FindInLua(path.."*.lua")) do
		WARE = {}
		
		--AddCSLuaFile(path..file)
		include(path..file)
		
		local gamename = string.Replace(file, ".lua", "")
		ware_mod.Register(gamename, WARE)
	end
	
	print("__________\n")
	names = ware_mod.GetNamesTable()
	str = "Added wares : "
	for k,v in pairs(names) do
		str = str.."\""..v.."\" "
	end
	print(str)
	
	authors = ware_mod.GetAuthorTable()
	str = "Author [wares] : "
	for k,v in pairs(authors) do
		str = str.." "..k.." ["..v.." wares]  "
	end
	print(str)
	print("__________\n")
end

