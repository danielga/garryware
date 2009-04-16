
GM.NewWareSound =  	Sound("ware/game_new.mp3")
GM.LoseWareSound = 	Sound("ware/game_lose.mp3")
GM.WinWareSound =  	Sound("ware/game_win.mp3")

GM.Left1 = 	Sound("ware/announcer_begins_1sec.mp3")
GM.Left2 = 	Sound("ware/announcer_begins_2sec.mp3")
GM.Left3 = 	Sound("ware/announcer_begins_3sec.mp3")
GM.Left4 = 	Sound("ware/announcer_begins_4sec.mp3")
GM.Left5 = 	Sound("ware/announcer_begins_5sec.mp3")

GM.WinTriggerSounds = {
Sound("ware/crit_hit1.wav"),
Sound("ware/crit_hit2.wav"),
Sound("ware/crit_hit3.wav"),
Sound("ware/crit_hit4.wav"),
Sound("ware/crit_hit5.wav")}

GM.WinOther = Sound("ware/crit_hit_other.wav")
GM.LoseOther = Sound("buttons/combine_button3.wav")

GM.LoseTriggerSounds = {
Sound("buttons/button8.wav"),
Sound("buttons/button8.wav")}

GM.WareEnts = {}
GM.EntsOnCrate = {}
GM.EntsOverCrate = {}
GM.EntsInSky = {}
GM.EntsCross = {}

ENTS_ONCRATE = 1
ENTS_OVERCRATE = 2
ENTS_INSKY = 3
ENTS_CROSS = 4

/*
for k,v in pairs(GM.Corpses) do
	util.PrecacheModel(v)
end
*/