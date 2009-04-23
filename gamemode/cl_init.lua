include( 'shared.lua' )
include( 'cl_postprocess.lua' )
include( 'admin.lua' )
include( 'skin.lua' )
include( "tables.lua" )

surface.CreateFont( "coolvetica", 48, 400, true, false, "WAREIns" ) 
surface.CreateFont( "Verdana", 16, 400, false, false, "WAREScore" ) 

Sound("ware/game_new.mp3")
Sound("ware/game_lose.mp3")
Sound("ware/game_win.mp3")

Sound("ware/announcer_begins_1sec.mp3")
Sound("ware/announcer_begins_2sec.mp3")
Sound("ware/announcer_begins_3sec.mp3")
Sound("ware/announcer_begins_4sec.mp3")
Sound("ware/announcer_begins_5sec.mp3")

Sound("ware/crit_hit1.wav")
Sound("ware/crit_hit2.wav")
Sound("ware/crit_hit3.wav")
Sound("ware/crit_hit4.wav")
Sound("ware/crit_hit5.wav")

Sound("ware/crit_hit_other.wav")

local iKeepTime = 4;
local fLastMessage = 0;
local fAlpha = 0;
local szMessage = "";

NextgameStart = 0
NextwarmupEnd = 0
NextgameEnd = 0
WarmupLen = 0
WareLen = 0
TimeWhenGameEnds = 0
TickAnnounce = 0
UpcomingInfo = ""

function GM:PrintCenterMessage( )
	if( fLastMessage + iKeepTime < CurTime() and fAlpha > 0) then
		fAlpha = fAlpha - (FrameTime()*200)
	end
	
	local timeDif = CurTime() - fLastMessage;
	
	if( fAlpha > 0 ) then
		local gB = math.Clamp( timeDif * 400, 192, 255 );
		draw.SimpleTextOutlined( szMessage, "WAREIns", ScrW()/2, ScrH()*0.62, Color( gB, gB, 255, math.Clamp( fAlpha, 0, 255 ) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, math.Clamp( ((fAlpha/255)^2)*255, 0, 255 ) ) );
	end
end

function GM:AddCenterMessage( message )
	fLastMessage = CurTime();
	szMessage = message;
	fAlpha = 255;
end

function ReceiveCenterMessage( usrmsg )
	fLastMessage = CurTime();
	szMessage = usrmsg:ReadString();	
	fAlpha = 255;
end
usermessage.Hook( "gmdm_printcenter", ReceiveCenterMessage );

function GM:GetMotionBlurValues( x, y, fwd, spin )

	if( ValidEntity( LocalPlayer() ) and ( !LocalPlayer():IsOnGround() or LocalPlayer():KeyDown( IN_SPEED ) )) then
		fwd = fwd * 5
	end
	
	return x, y, fwd, spin
	
end

function GM:Think()
	self.BaseClass:Think()
	
	if (TickAnnounce > 0 && extwarmupEnd != 0 ) then
		if (CurTime() > (NextgameEnd - (WareLen/6)*TickAnnounce )) then
			if     TickAnnounce == 5 then LocalPlayer():EmitSound( GAMEMODE.Left5 )
			elseif TickAnnounce == 4 then LocalPlayer():EmitSound( GAMEMODE.Left4 )
			elseif TickAnnounce == 3 then LocalPlayer():EmitSound( GAMEMODE.Left3 )
			elseif TickAnnounce == 2 then LocalPlayer():EmitSound( GAMEMODE.Left2 )
			elseif TickAnnounce == 1 then LocalPlayer():EmitSound( GAMEMODE.Left1 )
			end
			TickAnnounce = TickAnnounce - 1
		end
	end
end

function GM:HUDPaint()
	self:PrintCenterMessage();
	
	self.BaseClass:HUDPaint();
end


function GM:HUDThink()
end

function HideThings( name )
	if (name == "CHudHealth" or name == "CHudBattery" or name == "CHudWeaponSelection") then
		return false
	end
end
hook.Add( "HUDShouldDraw", "HideThings", HideThings )

function GM:HUDWeaponPickedUp( wep )
	return false
end

local vgui_ridiculous = vgui.RegisterFile( "vgui_ridiculous.lua" )
local vgui_transit = vgui.RegisterFile( "vgui_transitscreen.lua" )
local vgui_wait = vgui.RegisterFile( "vgui_waitscreen.lua" )
local vgui_clock = vgui.RegisterFile( "vgui_clock.lua" )
local vgui_clockgame = vgui.RegisterFile( "vgui_clockgame.lua" )
local RidiculousVGUI = vgui.CreateFromTable( vgui_ridiculous ) 
local TransitVGUI = vgui.CreateFromTable( vgui_transit )
local WaitVGUI = vgui.CreateFromTable( vgui_wait )
local ClockVGUI = vgui.CreateFromTable( vgui_clock )
local ClockGameVGUI = vgui.CreateFromTable( vgui_clockgame )

local function Transit( m )
	TransitVGUI:Show()
	
	timer.Simple( 2.7, function() TransitVGUI:Hide() end )
end
usermessage.Hook( "Transit", Transit )

local function WaitShow( m )
	WaitVGUI:Show()
end
usermessage.Hook( "WaitShow", WaitShow )

local function WaitHide( m )
	WaitVGUI:Hide()
end
usermessage.Hook( "WaitHide", WaitHide )

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
	TickAnnounce = 5
	if NextwarmupEnd != 0 then LocalPlayer():EmitSound( GAMEMODE.NewWareSound , 40 ) end
	//print("---"..NextwarmupEnd.."---"..NextgameEnd.."---"..WarmupLen.."---"..WareLen)
end
usermessage.Hook( "NextGameTimes", NextGameTimes )

local function EndOfGamemode_HideVGUI( m )
	RidiculousVGUI:Hide()
	ClockVGUI:Hide()
	ClockGameVGUI:Hide()
end
usermessage.Hook( "EndOfGamemode_HideVGUI", EndOfGamemode_HideVGUI )

local function EventDestinySet( m )
	local Destiny = m:ReadLong()
	if (Destiny > 0) then
		LocalPlayer():EmitSound( table.Random(GAMEMODE.WinTriggerSounds) )
	else
		LocalPlayer():EmitSound( table.Random(GAMEMODE.LoseTriggerSounds) )
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
