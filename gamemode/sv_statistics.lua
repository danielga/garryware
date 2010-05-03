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
	local UID = ply:UniqueID()
	
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
	
	local sMinigameName = self.Minigame.Name
	local iTokens = 0
	-- TOKEN_GW_STATS : Why do we use a function ?
	-- That's because tokens can vary with the different phases
	-- of a same minigame, or a minigame can use different tokens
	-- in real time.
	if self.Minigame.GetTokens then
		iTokens = self:StatsRawTableToBitwise( self.Minigame:GetTokens() or nil )
	end
	
	local minigamename = self.Minigame.Name
	local data = { sMinigameName, iWare, iPhase, WonLostUIDS, iTokens }
	
	table.insert( stats.PlayTable, data )
	
end
