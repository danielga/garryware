GM.WASND = {}

GM.WASND.GlobalWareningNew    = Sound("ware/game_new_two.mp3")
GM.WASND.GlobalWareningWin    = Sound("ware/game_win_two.mp3")
GM.WASND.GlobalWareningLose   = Sound("ware/game_lose_two.mp3")
GM.WASND.GlobalWareningReport = Sound("ware/game_report.mp3")
GM.WASND.GlobalWareningTeleport = Sound("ware/game_teleport.mp3")
GM.WASND.GlobalWareningEnding   = Sound("ware/game_ending.mp3")


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
//Repeating 2 and 3 for more chances of playing

GM.WASND.TBL_LocalLose = {
Sound("ware/local_lose2.wav"),
Sound("ware/local_lose3.wav"),
Sound("ware/local_lose4.wav")}

GM.WASND.Confirmation  = Sound("ware/other_won1.wav")
GM.WASND.OtherWin  = Sound("ware/other_won1.wav")
GM.WASND.OtherLose = Sound("ware/other_lose1.wav")

GM.WASND.EveryoneWon  = Sound("ware/everyone_won1.wav")
GM.WASND.EveryoneLost = Sound("ware/everyone_lose1.wav")

GM.WASND.THL_AmbientMusic = {
Sound("ware/amb_playmus_1.wav")
}

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

ENTS_ONCRATE = "oncrate"
ENTS_OVERCRATE = "overcrate"
ENTS_INAIR = "inair"
ENTS_CROSS = "cross"
