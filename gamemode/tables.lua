GM.WASND = {}
GM.WADAT = {}
GM.WADAT.EndFlourishTime = 2.50
--GM.WADAT.StartFlourishTime = 0 or 2.56
GM.WADAT.StartFlourishLength = 2.50
GM.WADAT.TransitFlourishTime = 1.3
GM.WADAT.EndingFlourishDelayAfterStart = 2.20
GM.WADAT.EndingFlourishDelayAfterEnd = 2.0
GM.WADAT.EndingFlourishTime = 1.3

GM.WASND.THL_AmbientMusic = {
Sound("ware/exp_loop_1.wav")
}

GM.WASND.TBL_GlobalWareningNew    = {
Sound("ware/exp_game_new_1.mp3"),
Sound("ware/exp_game_new_2.mp3"),
Sound("ware/exp_game_new_3.mp3"),
Sound("ware/exp_game_new_4.mp3"),
Sound("ware/exp_game_new_5.mp3")
}

GM.WASND.TBL_GlobalWareningWin    = {
Sound("ware/exp_game_win_1.mp3"),
Sound("ware/exp_game_win_2.mp3"),
Sound("ware/exp_game_win_3.mp3")
}

GM.WASND.TBL_GlobalWareningLose   = {
Sound("ware/exp_game_lose_1.mp3"),
Sound("ware/exp_game_lose_2.mp3"),
Sound("ware/exp_game_lose_3.mp3")
}

GM.WASND.GlobalWareningReport = Sound("ware/game_report.mp3")

--[[
GM.WASND.TBL_GlobalWareningReport = {
Sound("ware/game_report.mp3")
}
]]--

GM.WASND.TBL_GlobalWareningTeleport = {
Sound("ware/exp_game_transit_1.mp3"),
Sound("ware/exp_game_transit_2.mp3")
}
GM.WASND.TBL_GlobalWareningPrologue   = {
Sound("ware/game_ending.mp3")
}
GM.WASND.TBL_GlobalWareningEnding   = {
Sound("ware/game_ending.mp3")
}


GM.WASND.TimeLeft = {}
GM.WASND.TimeLeft[1] = Sound("ware/countdown_sec1.mp3")
GM.WASND.TimeLeft[2] = Sound("ware/countdown_sec2.mp3")
GM.WASND.TimeLeft[3] = Sound("ware/countdown_sec3.mp3")
GM.WASND.TimeLeft[4] = Sound("ware/countdown_sec4.mp3")
GM.WASND.TimeLeft[5] = Sound("ware/countdown_sec5.mp3")

GM.WASND.TBL_LocalWon = {
Sound("ware/local_won1.wav"),
Sound("ware/local_won2.wav"),
Sound("ware/local_won3.wav"),
Sound("ware/local_won2.wav"),
Sound("ware/local_won3.wav")}
// Repeating 2 and 3 for more chances of playing

GM.WASND.TBL_LocalLose = {
Sound("ware/local_lose2.wav"),
Sound("ware/local_lose3.wav"),
Sound("ware/local_lose4.wav")}

GM.WASND.Confirmation  = Sound("ware/other_won1.wav")
GM.WASND.OtherWin  = Sound("ware/other_won1.wav")
GM.WASND.OtherLose = Sound("ware/other_lose1.wav")

GM.WASND.EveryoneWon  = Sound("ware/everyone_won2.wav")
GM.WASND.EveryoneLost = Sound("ware/everyone_lose2.wav")

GM.WASND.TBL_Teleport = {
Sound("ambient/machines/teleport1.wav"),
Sound("ambient/machines/teleport3.wav"),
Sound("ambient/machines/teleport4.wav")}

GM.WACOLS = {}
GM.WACOLS["unknown"]  = Color(255,255,255,255)
GM.WACOLS["topic"]    = Color(220,210,92,255)
GM.WACOLS["link"]     = Color(255,255,255,255)
GM.WACOLS["info"]     = Color(170,255,170,255)
GM.WACOLS["dom_outline"] = Color(0,0,0,255)
GM.WACOLS["dom_text"]    = Color(255,255,255,255)

GM.WareEnts = {}

GM.ColorTable = {
	{ "black"		, Color(0,0,0,255) 		, "twirl"	 },
	{ "grey"		, Color(138,138,138,255)	, "cross" 	 },
	{ "white"		, Color(255,255,255,255)	, "triangle" },
	{ "red"			, Color(220,0,0,255)		, "square"   },
	{ "green"		, Color(0,220,0,255)		, "circle"	 },
	{ "blue"		, Color(64,64,255,255)		, "star" 	 },
	{ "pink"		, Color(255,0,255,255)		, "flower"	 }
}

ENTS_ONCRATE = "oncrate"
ENTS_OVERCRATE = "overcrate"
ENTS_INAIR = "inair"
ENTS_CROSS = "cross"
