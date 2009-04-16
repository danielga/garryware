include( 'shared.lua' )
include( 'cl_postprocess.lua' )
include( 'admin.lua' )
include( 'skin.lua' )

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

function GM:HUDPaint()
	self:PrintCenterMessage();
	
	self.BaseClass:HUDPaint();
end


function GM:HUDThink()
end

function HideThings( name )
	if (name == "CHudHealth" or name == "CHudBattery") then
		return false
	end
end
hook.Add( "HUDShouldDraw", "HideThings", HideThings ) 

local vgui_ridiculous = vgui.RegisterFile( "vgui_ridiculous.lua" )
local vgui_transit = vgui.RegisterFile( "vgui_transitscreen.lua" )
local vgui_wait = vgui.RegisterFile( "vgui_waitscreen.lua" )
local RidiculousVGUI = vgui.CreateFromTable( vgui_ridiculous ) 
local TransitVGUI = vgui.CreateFromTable( vgui_transit )
local WaitVGUI = vgui.CreateFromTable( vgui_wait )

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
