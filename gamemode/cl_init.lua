include( 'shared.lua' )
include( 'cl_postprocess.lua' )
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

LastSelfDomThink = 0
LastRemainingThink = 0

local DominationMat = Material("SGM/playercircle")

/*
MusCursor = 1
MusGame = { {"........a4..a4..........a4..a4..","weapons/wrench_hit_build_fail.wav"} ,
			{"a4..b4..........b4c5d5..........","weapons/wrench_hit_build_success1.wav"} }
MusInterval = 0.12
MusRealTime = 0
*/

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

function GM:PrintDominations( )
	for k,ply in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do
		if /*ply != LocalPlayer() &&*/ ply:GetNWBool("dominating",false) == true then
			surface.SetMaterial( DominationMat )
		
			local pos = ply:GetPos() + Vector(0,0,96)
			local lcolor = render.GetLightColor( ply:GetPos() ) * 2
			lcolor.x = 255 * mathx.Clamp( lcolor.x, 0, 1 )
			lcolor.y = 255 * mathx.Clamp( lcolor.y, 0, 1 )
			lcolor.z = 0 * mathx.Clamp( lcolor.z, 0, 1 )
			local pos_toscreen = pos:ToScreen()
			
			surface.SetDrawColor( lcolor.x, lcolor.y, lcolor.z, 255 )
			surface.DrawTexturedRectRotated(pos_toscreen.x, pos_toscreen.y - 2, 52, 52, 0)
			
			draw.SimpleTextOutlined( tostring(ply:GetNWInt("combo",0)), "WAREIns", pos_toscreen.x, pos_toscreen.y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 0, 0, 0, 255 ) );
		end
	end
end

function GM:PrintCommonParticles( )
	if LocalPlayer():GetNWBool("dominating",false) == true then
		if RealTime() - LastSelfDomThink > 0.2 then
			HUDMakeParticles("effects/yellowflare",2,0.5,ScrW()*0.5,ScrH()*0.02,15,25,25,35,90,-55,55,32,48,Color(255,255,255,255),Color(255,255,0,0),0,0.8)
			HUDMakeParticles("effects/yellowflare",1,0.3,ScrW()*0.5,ScrH()*0.02,5 ,10,10,20,90,-55,55,48,64,Color(255,255,255,255),Color(255,255,255,0),0,0.8)
			LastSelfDomThink = RealTime()
		end
	end
	/*
	if TimeWhenGameEnds - CurTime() < 60 then
		if RealTime() - LastRemainingThink > 0.5 then
			HUDMakeParticles("effects/yellowflare",1,0.35,ScrW()*0.98,ScrH()*0.98,16,16,512,512,0,0,360,0,1,Color(255,0,0,255),Color(255,0,0,0),0,0)
			LastRemainingThink = RealTime()
		end
	end
	*/
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
	
	if (TickAnnounce > 0 && CurTime() < NextgameEnd ) then
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
	
	--"Make your own music" module
	/*
	local Pitch = 0
	local NoPitch
	local Note = "."
	local OctaveSt, Octave
	local Pnum = 0
	local Offset = 0
	if (NextgameStart < CurTime() && CurTime() < NextgameEnd && (RealTime() - MusRealTime) > MusInterval) then
		if MusCursor > MusGame[1][1]:len() then MusCursor = 1 end
		
		
		for Index,Patch in pairs(MusGame) do
			NoPitch = false
			local Note = Patch[1]:sub(MusCursor,MusCursor)
			if (Note != ".") then
				OctaveSt = Patch[1]:sub(MusCursor+1,MusCursor+1)
			end
			if (OctaveSt == "0") then Octave = 0 end
			if (OctaveSt == "1") then Octave = 1 end
			if (OctaveSt == "2") then Octave = 2 end
			if (OctaveSt == "3") then Octave = 3 end
			if (OctaveSt == "4") then Octave = 4 end
			if (OctaveSt == "5") then Octave = 5 end
			if (OctaveSt == "6") then Octave = 6 end
			if (OctaveSt == "7") then Octave = 7 end
			if (OctaveSt == "8") then Octave = 8 end
			if (OctaveSt == "9") then Octave = 9 end
			
			if (Note == "c") then Pnum = -9+(12*(Octave-4))
			elseif (Note == "d") then Pnum = -7+(12*(Octave-4))
			elseif (Note == "e") then Pnum = -5+(12*(Octave-4))
			elseif (Note == "f") then Pnum = -4+(12*(Octave-4))
			elseif (Note == "g") then Pnum = -2+(12*(Octave-4))
			elseif (Note == "a") then Pnum = 0+(12*(Octave-4))
			elseif (Note == "b") then Pnum = 2+(12*(Octave-4))
			
			elseif (Note == "C") then Pnum = -9+(12*(Octave-4))+1
			elseif (Note == "D") then Pnum = -7+(12*(Octave-4))+1
			elseif (Note == "F") then Pnum = -4+(12*(Octave-4))+1
			elseif (Note == "G") then Pnum = -2+(12*(Octave-4))+1
			elseif (Note == "A") then Pnum = 0+(12*(Octave-4))+1
			else NoPitch = true Pnum = 0 end

			if (NoPitch == true) then
				Pitch = 0
			else
				Highness = Pnum + Offset
				Pitch = 2^(Highness/12)
			end
			Pitch = Pitch * 100
			LocalPlayer():EmitSound(Patch[2],100,Pitch)
		end
			
		MusCursor = MusCursor + 2
		MusRealTime = RealTime()
	end
	*/
end


function GM:HUDPaint()
	self.BaseClass:HUDPaint();
	
	self:PrintCenterMessage();
	self:PrintDominations();
	self:PrintCommonParticles();
	HUDThinkAboutParticles()
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



function GM:AddScoreboardWins( ScoreBoard )

	local f = function( ply ) return ply:Frags() end
	ScoreBoard:AddColumn( "Wins", 50, f, 0.5, nil, 6, 6 )

end

function GM:AddScoreboardFails( ScoreBoard )

	local f = function( ply ) return ply:Deaths() end
	ScoreBoard:AddColumn( "Failures", 50, f, 0.5, nil, 6, 6 )

end

function GM:CreateScoreboard( ScoreBoard )

	ScoreBoard:SetAsBullshitTeam( TEAM_SPECTATOR )
	ScoreBoard:SetAsBullshitTeam( TEAM_CONNECTING )
	
	if ( GAMEMODE.TeamBased ) then
		ScoreBoard:SetAsBullshitTeam( TEAM_UNASSIGNED )
		ScoreBoard:SetHorizontal( true )
	end

	ScoreBoard:SetSkin( "SimpleSkin" )

	self:AddScoreboardAvatar( ScoreBoard )		
	self:AddScoreboardSpacer( ScoreBoard, 8 )	
	self:AddScoreboardName( ScoreBoard )			
	self:AddScoreboardWins( ScoreBoard )		
	self:AddScoreboardFails( ScoreBoard )		
	self:AddScoreboardPing( ScoreBoard )		
		
	// Here we sort by these columns (and descending), in this order. You can define up to 4
	ScoreBoard:SetSortColumns( { 4, true, 5, false, 3, false } )

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
	if (NextwarmupEnd != 0) then
		LocalPlayer():EmitSound( GAMEMODE.NewWareSound , 40 )
	else
		
	end
	MusCursor = 0
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
	
	target:SetEntityColor(r,g,b,a)
end
usermessage.Hook( "EntityTextChangeColor", EntityTextChangeColor )
