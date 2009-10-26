include( "ply_extension.lua" )

GM.Name 	= "GarryWare Two"
GM.Author 	= "Hurricaaane (Ha3) and Kilburn"
GM.Email 	= ""
GM.Website 	= ""

DeriveGamemode( "fretta" )
IncludePlayerClasses()

GM.Help		= 
[[Rules :
- Do what she says
- Have fun, this is not a game where you have to kill everyone still alive
By : Hurricaaane and Kilburn

Credits goes to Valve for the Meet the Sniper flourish, DasMatze for the sound mix.
Original sound effects from Valve 'Team Fortress 2' game.
Special thanks to : Kilburn (for minigame registering improvement), BlackOps (for improvements)]]

GM.TeamBased = true
GM.AllowAutoTeam = true
GM.AllowSpectating = true
GM.SelectClass = false

GM.SecondsBetweenTeamSwitches = 3
GM.GameLength = 8.0 + 47.0/60.0
GM.NotEnoughTimeCap = 20

GM.NoPlayerSuicide = false
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
GM.RoundLength = 5.0*60.0			// Round length, in seconds 
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
GM.SelectColor = true

GM.BestStreakEver = 3
GM.NumberOfWaresPlayed = -1


GM.ModelPrecacheTable = {}

TEAM_HUMANS = 1

function GM:CreateTeams()
	
	team.SetUp( TEAM_HUMANS, "Players", Color( 235, 177, 20 ), true )
	team.SetSpawnPoint( TEAM_HUMANS, "info_player_start" )
	team.SetClass( TEAM_HUMANS, { "Default" } )
	
	team.SetUp( TEAM_SPECTATOR, "Spectators", Color( 200, 200, 200 ), true )
	team.SetSpawnPoint( TEAM_SPECTATOR, "info_player_start" )
	team.SetClass( TEAM_SPECTATOR, { "Spectator" } )

end

function GM:GetBaseColorPtr( sColorname )
	if (GAMEMODE.WACOLS[sColorname] == nil) then return GAMEMODE.WACOLS["unknown"] end
	
	return GAMEMODE.WACOLS[sColorname]
end

function GM:GetBestStreak()
	return GAMEMODE.BestStreakEver
end

function GM:SetBestStreak( newVal )
	if (newVal <= GAMEMODE.BestStreakEver) then return end
	GAMEMODE.BestStreakEver = newVal
end

function GM:PrintInfoMessage( sTopic, sLink, sInfo )
	chat.AddText( GAMEMODE:GetBaseColorPtr("topic"), sTopic, GAMEMODE:GetBaseColorPtr("link"), sLink, GAMEMODE:GetBaseColorPtr("info"), sInfo )
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
	str = "Added wares ("..#names..") : "
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

function RemoveUnplayableMinigames()
	local names = ware_mod.GetNamesTable()
	local removed = {}
	
	for _,v in pairs(ware_mod.GetNamesTable()) do
		if not ware_env.HasEnvironment(ware_mod.Get(v).Room) then
			table.insert(removed,v)
			ware_mod.Remove(v)
		end
	end
	
	print("__________\n")
	str = "Removed wares ("..#removed..") : "
	for k,v in pairs(removed) do
		str = str.."\""..v.."\" "
	end
	print(str)
	print("__________\n")
end
