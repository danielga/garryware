////////////////////////////////////////////////
// // GarryWare Gold                          //
// by Hurricaaane (Ha3)                       //
//  and Kilburn_                              //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Statistics (server)                        //
////////////////////////////////////////////////

include("sh_statistics.lua")
include("cl_version.lua")
local stats = GM.GW_STATS

stats.PlayerTable = {}
stats.PlayTable = {}

function GM:StatsAddPlayer( ply )
	if ValidEntity( ply ) and ply:IsPlayer() then
	local UID = ply:UserID()
	
	if stats.PlayerTable[UID] then return end
	
	stats.PlayerTable[UID] = {}
	local pdat = stats.PlayerTable[iUID]
	
	pdat.Nick    = ply:Nick()
	pdat.SteamID = ply:SteamID()
	
end

-- ALERT : Stats are gathered AFTER THE PreEndGame !
-- That means, if you have 
function GM:StatsUpdateMinigameInfo( )
	local iWare  = self.NumberOfWaresPlayed
	local iPhase = self.WarePhase_Current
	
	local WonLostHoldUIDS = {{},{},{}}
	
	for k,ply in pairs(player.GetAll()) do
		if not ply:IsWarePlayer() or ply:IsOnHold() then
			table.insert( WonLostHoldUIDS[3], ply )
		elseif not play:GetAchieved() then
			table.insert( WonLostHoldUIDS[2], ply )
		else
			table.insert( WonLostHoldUIDS[1], ply )
		end
	end
	
	--local sMinigameName = self.Minigame.Name
	local iTokens = 0
	-- TOKEN_GW_STATS : Why do we use a function ?
	-- That's because tokens can vary with the different phases
	-- of a same minigame, or a minigame can use different tokens
	-- in real time.
	if self.Minigame.GetTokens then
		iTokens = self:StatsRawTableToBitwise( self.Minigame:GetTokens() or nil )
	end
	
	local sMinigameDesc = self.Minigame.Desc
	local data = { sMinigameDesc, iWare, iPhase, WonLostUIDS, iTokens }
	
	table.insert( stats.PlayTable, data )
	
end

-- TOKEN_GW_STATS : SHOULD CALL AFTER REMOVEUNPLAYABLE IN INIT
function StatsPoolMinigameDescriptions()
	local names = ware_mod.GetNamesTable()
	for _,name in pairs( names ) do
		local desc = ware_mod.Get(v).Desc
		
		if desc then
			umsg.PoolString( desc )
		end
	end
	
end

function GM:StatsStream()
	-- HOLY JEEBUS.
	--Send players
	for uid,data in pairs( stats.PlayerTable ) do
		-- TOKEN_GW_STATS : Optimize
		umsg.Start("StatsPlayerData")
			umsg.Char( uid - 128 )
			umsg.String( data.Nick )
		umsg.End()
		
	end
	
	-- AT THE SAME TIME, TRY TO MAKE THE PLAYER CRASH,
	-- DUE TO UNOPTIMIZED CODE IN EDGE CASES.
	--Send minigames
	for i,data in pairs( stats.PlayTable ) do
		umsg.Start("ModelList")
			umsg.Char( i - 128 )
			umsg.String( data[1] )
			umsg.Char( data[2] - 128 )
			umsg.Char( data[3] - 128 )
			umsg.Char( #data[4][1] - 128 )
			umsg.Char( #data[4][2] - 128 )
			umsg.Char( #data[4][3] - 128 )
			for l,tp in pairs( data[4] ) do
				for k,uid in pairs( tp[l] ) do
					-- Remember, there actually could be 32 of these.
					-- I mean, does chat.AddText use more?
					umsg.Char( uid - 128 )
				end
			end
			-- TOKEN_GW_STATS : Send the bitwise thing or try to use Pooled Strings.
			umsg.Short( #data[5] - 128 )
		umsg.End()
	end
	
end
