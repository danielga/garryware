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

PrecacheSequence = 0

AmbientMusic = {}
AmbientMusicIsOn = false

local function ModelList( m )
	local numberOfModels = m:ReadLong()
	local currentModelCount = #GAMEMODE.ModelPrecacheTable
	local model = ""
	
	for i=1,numberOfModels do
		table.insert( GAMEMODE.ModelPrecacheTable, m:ReadString() )
	end
	
	PrecacheSequence = (PrecacheSequence or 0) + 1
	
	print( "Precaching sequence #".. PrecacheSequence .."." )
	for k=(currentModelCount + 1),(currentModelCount + numberOfModels) do
		model = GAMEMODE.ModelPrecacheTable[ k ]
		print( "Precaching model " .. k .. " : " .. model )
		util.PrecacheModel( model )
	end
end
usermessage.Hook( "ModelList", ModelList )

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



local function CreateAmbientMusic()
	for k,path in pairs(GAMEMODE.WASND.THL_AmbientMusic) do
		AmbientMusic[k] = CreateSound(LocalPlayer(), path)
	end
end
hook.Add( "InitPostEntity" , "CreateAmbientMusic" , CreateAmbientMusic )

local function EnableMusic()
	if AmbientMusicIsOn then
		AmbientMusic[1]:Stop()
		AmbientMusic[1]:Play()
		AmbientMusic[1]:ChangeVolume( 0.3 )
	end
end

local function DisableMusic()
	if not AmbientMusicIsOn then
		AmbientMusic[1]:ChangeVolume( 0.1 )
		//AmbientMusic[1]:Stop()
	end
end

local function PlayEnding()
	LocalPlayer():EmitSound( GAMEMODE.WASND.GlobalWareningEnding , 60 )
	AmbientMusicIsOn = true
	AmbientMusic[1]:Stop( )
	timer.Simple( 7.24, EnableMusic )
end

local function NextGameTimes( m )
	NextwarmupEnd = m:ReadFloat()
	NextgameEnd   = m:ReadFloat()
	WarmupLen     = m:ReadFloat()
	WareLen       = m:ReadFloat()
	local ShouldKeepAnnounce = m:ReadBool() or false
	if not ShouldKeepAnnounce then TickAnnounce = 5 end
	
	if (NextwarmupEnd != 0) then
		LocalPlayer():EmitSound( GAMEMODE.WASND.GlobalWareningNew , 60 )
		AmbientMusicIsOn = true
		timer.Simple( 2.67, EnableMusic )
	end
end
usermessage.Hook( "NextGameTimes", NextGameTimes )

local function EventEndgameTrigger( m )
	local achieved = m:ReadBool()
	
	AmbientMusicIsOn = false
	timer.Simple( 0.5, DisableMusic )
	
	if (achieved) then
		LocalPlayer():EmitSound( GAMEMODE.WASND.GlobalWareningWin , 60 )
	else
		LocalPlayer():EmitSound( GAMEMODE.WASND.GlobalWareningLose , 60 )
	end
end
usermessage.Hook( "EventEndgameTrigger", EventEndgameTrigger )

local function BestStreakEverBreached( m )
	GAMEMODE:SetBestStreak( m:ReadLong() )
end
usermessage.Hook( "BestStreakEverBreached", BestStreakEverBreached )

local function EventEveryoneState( m )
	local achieved = m:ReadBool()

	if (achieved) then
		LocalPlayer():EmitSound( GAMEMODE.WASND.EveryoneWon )
	else
		LocalPlayer():EmitSound( GAMEMODE.WASND.EveryoneLost )
	end
end
usermessage.Hook( "EventEveryoneState", EventEveryoneState )

local function PlayerTeleported( m )
	LocalPlayer():EmitSound( GAMEMODE.WASND.GlobalWareningTeleport , 60 )
	LocalPlayer():EmitSound( table.Random(GAMEMODE.WASND.TBL_Teleport) , 40 )
	// LocalPlayer():EmitSound( GAMEMODE.WASND.GlobalWareningReport )
end
usermessage.Hook( "PlayerTeleported", PlayerTeleported )




local function EntityTextChangeColor( m )
	local target = m:ReadEntity()
	local r,g,b,a = m:ReadChar() + 128, m:ReadChar() + 128, m:ReadChar() + 128, m:ReadChar() + 128
	
	if ValidEntity(target) then
		target:SetEntityColor(r,g,b,a)
	else
		timer.Simple( 0, function(target,r,g,b,a) if ValidEntity(target) then target:SetEntityColor(r,g,b,a) end end )
	end
end
usermessage.Hook( "EntityTextChangeColor", EntityTextChangeColor )


/*----------------------------------
VGUI Includes
------------------------------------*/

local vgui_transit = vgui.RegisterFile( "vgui_transitscreen.lua" )
local vgui_wait = vgui.RegisterFile( "vgui_waitscreen.lua" )
local vgui_clock = vgui.RegisterFile( "vgui_clock.lua" )
local vgui_clockgame = vgui.RegisterFile( "vgui_clockgame.lua" )
local TransitVGUI = vgui.CreateFromTable( vgui_transit )
local WaitVGUI = vgui.CreateFromTable( vgui_wait )
local ClockVGUI = vgui.CreateFromTable( vgui_clock )
local ClockGameVGUI = vgui.CreateFromTable( vgui_clockgame )


local function Transit( m )
	TransitVGUI:Show()
	
	timer.Simple( 2.7, function() TransitVGUI:Hide() end )
end
usermessage.Hook( "Transit", Transit )

function WaitShow( m ) --used in ServerJoinInfo
	WaitVGUI:Show()
end
usermessage.Hook( "WaitShow", WaitShow )

local function WaitHide( m )
	WaitVGUI:Hide()
end
usermessage.Hook( "WaitHide", WaitHide )

local function EndOfGamemode( m )
	ClockVGUI:Hide()
	ClockGameVGUI:Hide()
	
	timer.Simple( 2.26, PlayEnding )
end
usermessage.Hook( "EndOfGamemode", EndOfGamemode )


local function HitConfirmation( m )
	LocalPlayer():EmitSound( GAMEMODE.WASND.Confirmation )
end
usermessage.Hook( "HitConfirmation", HitConfirmation )

