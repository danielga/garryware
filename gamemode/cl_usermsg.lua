/*
User Messages
*/

NextgameStart = 0
NextwarmupEnd = 0
NextgameEnd = 0
WarmupLen = 0
WareLen = 0
TimeWhenGameEnds = 0
TickAnnounce = 0
UpcomingInfo = ""

LastSelfDomThink = 0
LastRemainingThink = 0


local function GameStartTime( m )
	NextgameStart = m:ReadLong()
end
usermessage.Hook( "GameStartTime", GameStartTime )

local function ServerJoinInfo( m )
	local didnotbegin = false

	TimeWhenGameEnds = m:ReadFloat()
	didnotbegin = m:ReadBool()
	
	if didnotbegin == true then
		WaitShow()
	end
	print("Game ends on time : "..TimeWhenGameEnds)
end
usermessage.Hook( "ServerJoinInfo", ServerJoinInfo )

local function NextGameTimes( m )
	NextwarmupEnd = m:ReadFloat()
	NextgameEnd = m:ReadFloat()
	WarmupLen = m:ReadFloat()
	WareLen = m:ReadFloat()
	local ShouldReinitAnnounce = m:ReadBool() or false
	if (ShouldReinitAnnounce) then TickAnnounce = 5 end
	--TickAnnounce = 5
	if (NextwarmupEnd != 0) then
		LocalPlayer():EmitSound( GAMEMODE.NewWareSound , 40 )
	else
		
	end
	MusCursor = 0
	//print("---"..NextwarmupEnd.."---"..NextgameEnd.."---"..WarmupLen.."---"..WareLen)
end
usermessage.Hook( "NextGameTimes", NextGameTimes )

local function BestStreakEverBreached( m )
	GAMEMODE.BestStreakEver = m:ReadLong()
end
usermessage.Hook( "BestStreakEverBreached", BestStreakEverBreached )



local function EventDestinySet( m )
	local Destiny = m:ReadLong()
	if (Destiny > 0) then
		LocalPlayer():EmitSound( table.Random(GAMEMODE.WinTriggerSounds) )
		HUDMakeParticles("effects/yellowflare",35,2,ScrW()*0,ScrH(),20,20,50,70,-45,-60,60,64,256,Color(128,255,128,255),Color(0,255,0,0),5,1)
		HUDMakeParticles("effects/yellowflare",5,2,ScrW()*0,ScrH(),10,10,20,30,-45,-60,60,256,512,Color(255,255,255,255),Color(255,255,255,0),10,1)
		HUDMakeParticles("gui/silkicons/check_on.vmt",5,2,ScrW()*0,ScrH(),16,16,32,32,-45,-60,60,64,128,Color(255,255,255,255),Color(255,255,255,0),0,0.2)
	else
		LocalPlayer():EmitSound( table.Random(GAMEMODE.LoseTriggerSounds) )
		HUDMakeParticles("effects/yellowflare",35,2,ScrW()*0,ScrH(),20,20,50,70,-45,-60,60,64,256,Color(255,128,128,255),Color(255,0,0,0),5,1)
		HUDMakeParticles("effects/yellowflare",5,2,ScrW()*0,ScrH(),10,10,20,30,-45,-60,60,256,512,Color(255,255,255,255),Color(255,255,255,0),10,1)
		HUDMakeParticles("gui/silkicons/check_off.vmt",5,2,ScrW()*0,ScrH(),16,16,32,32,-45,-60,60,64,128,Color(255,255,255,255),Color(255,255,255,0),0,0.2)
	end
end
usermessage.Hook( "EventDestinySet", EventDestinySet )

local function EventEndgameSet( m )
	local Destiny = m:ReadLong()
	if (Destiny > 0) then
		LocalPlayer():EmitSound( GAMEMODE.WinWareSound , 40 )
	else
		LocalPlayer():EmitSound( GAMEMODE.LoseWareSound , 40 )
	end
end
usermessage.Hook( "EventEndgameSet", EventEndgameSet )





local function PlayerTeleported( m )
	LocalPlayer():EmitSound( table.Random(GAMEMODE.TeleportSounds) , 40 )
end
usermessage.Hook( "PlayerTeleported", PlayerTeleported )





local function EntityTextChangeColor( m )
	local target = m:ReadEntity()
	local r = m:ReadLong()
	local g = m:ReadLong()
	local b = m:ReadLong()
	local a = m:ReadLong()
	
	if ValidEntity(target) then
		target:SetEntityColor(r,g,b,a)
	else
		timer.Simple( 0, function(target,r,g,b,a) if ValidEntity(target) then target:SetEntityColor(r,g,b,a) end end )
	end
end
usermessage.Hook( "EntityTextChangeColor", EntityTextChangeColor )
