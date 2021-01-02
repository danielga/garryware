////////////////////////////////////////////////
// // GarryWare Gold                          //
// by Hurricaaane (Ha3)                       //
//  and Kilburn_                              //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Fretta and Votes overrides                 //
////////////////////////////////////////////////

-- NO MORE FRETTA
-- So, what now? Reset the game after a while?

function GM:EndOfGame( bGamemodeVote )
	if self.GameHasEnded == true then return end
	
	self.GamesArePlaying = false
	self.GameHasEnded = true
	
	-- Find combos before ending the game and after saying the game has ended
	for _,ply in pairs(team.GetPlayers(TEAM_HUMANS)) do
		ply:PrintComboMessagesAndEffects( ply:GetCombo() )
	end
	
	self:EndGame()
	
	--self:DoProcessAllAwards()
	
	--Send info about VGUI
	umsg.Start("SpecialFlourish")
		umsg.Char( 2 )
	umsg.End()
	umsg.Start("EndOfGamemode")
	umsg.End()
	
	--Send info about ware
	--local rp = RecipientFilter()
	--rp:AddAllPlayers()
	umsg.Start("NextGameTimes", nil)
		umsg.Float( 0 )
		umsg.Float( 0 )
		umsg.Float( 0 )
		umsg.Float( 0 )
		umsg.Bool( false )
		umsg.Bool( false )
	umsg.End()
	umsg.Start("BestStreakEverBreached", rp)
		umsg.Long( self.BestStreakEver )
	umsg.End()
	
	if not DEBUG_DISABLE_STATS then
		self:StatsCR_LogSynthesisGLON()
	end

	timer.Simple(self.RestartIntermission, function() RunConsoleCommand("changelevel", game.GetMap()) end)
end