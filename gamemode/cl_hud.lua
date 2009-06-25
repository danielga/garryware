
surface.CreateFont( "coolvetica", 48, 400, true, false, "WAREIns" ) 
surface.CreateFont( "Verdana", 16, 400, true, false, "WAREScore" ) 

/*----------------------------------
HUD Centermsg
------------------------------------*/

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

/*----------------------------------
HUD Dominations
------------------------------------*/

local DominationMat = Material("SGM/playercircle")

function GM:PrintDominations( )
	for k,ply in pairs(team.GetPlayers(TEAM_HUMANS)) do
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



/*----------------------------------
HUD Particles
------------------------------------*/

HUDParticleThinkTime = CurTime()
HUDParticles = {}

function HUDThinkAboutParticles()
	if CurTime() - HUDParticleThinkTime > 0.05 then
		for k,sprite in pairs(HUDParticles) do
			if sprite:IsValid() == false then
				table.remove(HUDParticles,k)
			else
				local sx,sy = sprite:GetPos()
				sprite.Velocity.y = sprite.Velocity.y + sprite.grav
				sprite:MoveTo(sx + (sprite.Velocity.x*0.1)*sprite.resist, sy + (sprite.Velocity.y*0.1)*sprite.resist, 0.0001/FrameTime(),0)
			end
		end
	end
end

function HUDMakeParticles(materialpath,number,duration,posx,posy,sizemin,sizemax,sizeendmin,sizeendmax,dir_angle,diffusemin,diffusemax,distancemin,distancemax,color,colorend,gravity,resist)
	local sprite
	local randang
	local distance
	local sizeto
	local materialdec = Material(materialpath)
	for i=1,number do
		sprite = CreateSprite( materialdec )
		sprite:SetTerm( duration )
		sprite:SetPos( posx, posy )
		
		size = math.random(sizemin,sizemax)
		sprite:SetSize( size, size )
		sprite:SetColor( color )
		
		randang = math.rad( dir_angle + math.random(diffusemin,diffusemax) )
		distance = math.random(distancemin,distancemax)
		sprite.Velocity = Vector(math.cos(randang)*distance,math.sin(randang)*distance,0)
		sprite:MoveTo(posx + sprite.Velocity.x*0.1, posy + sprite.Velocity.y*0.1, 0.0001/FrameTime(),0)
		
		sizeto = math.random(sizeendmin,sizeendmax)
		sprite:SizeTo( sizeto, sizeto, duration, 0 )
		sprite:ColorTo( colorend, duration, 0 )
		
		sprite.grav = gravity
		sprite.resist = resist
		
		sprite:SetZPos(-128)
		
		table.insert(HUDParticles,sprite)
	end
end

/*
local function RemoteMakeParticles( m )
	local data = m:GetDecodedData()
	HUDMakeParticles(data.materialpath,data.number,data.duration,data.posx_rel*ScrW(),data.posy*ScrH(),data.sizemin,data.sizemax,data.sizeendmin,data.sizeendmax,data.dir_angle,data.diffusemin,data.diffusemax,data.distancemin,data.distancemax,data.color,data.colorend,data.gravity,data.resist)
end
datastream.Hook( "RemoteMakeParticles", RemoteMakeParticles )
*/

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

/*----------------------------------
HUD Paint
------------------------------------*/

function GM:HUDPaint()
	self.BaseClass:HUDPaint();
	
	self:PrintCenterMessage();
	self:PrintDominations();
	self:PrintCommonParticles();
	HUDThinkAboutParticles()
end



/*----------------------------------
HUD Overrides
------------------------------------*/

function HideThings( name )
	if (name == "CHudHealth" or name == "CHudBattery" or name == "CHudWeaponSelection") then
		return false
	end
end
hook.Add( "HUDShouldDraw", "HideThings", HideThings )

function GM:HUDWeaponPickedUp( wep )
	return false
end




/*----------------------------------
VGUI Overrides
------------------------------------*/


function GM:AddScoreboardWon( ScoreBoard )

	local f = function( ply ) return ply:Frags() end
	ScoreBoard:AddColumn( "Won", 50, f, 0.5, nil, 6, 6 )

end

function GM:AddScoreboardFailed( ScoreBoard )

	local f = function( ply ) return ply:Deaths() end
	ScoreBoard:AddColumn( "Failed", 50, f, 0.5, nil, 6, 6 )

end

function GM:AddScoreboardStreak( ScoreBoard )

	local f = function( ply )
		local combo = ply:GetNWInt("combo")
		local combomax = ply:GetNWInt("combo_max")
		local sufstring = ""
		if (combo == combomax) then
			sufstring = "Ongoing "
		end
		return sufstring .. combomax
	end
	ScoreBoard:AddColumn( "Best Streak", 80, f, 0.5, nil, 6, 6 )

end

function GM:AddScoreboardAward( ScoreBoard )

	local f = function( ply ) 	
	
		/*local combomax = ply:GetNWInt("combo_max")
		local av = vgui.Create( "DImage" )
			av:SetSize( 16, 16 )
			av:SetVisible( GAMEMODE.BestStreakEver == combomax )
			av:SetImage( "gui/silkicons/star" )
			return av*/
			
		local quastring = ""
		local quartiers = false
		local totalplayed = ply:Frags() + ply:Deaths()
		
		local besstring = ""
		local beststreak = false
		local combomax = ply:GetNWInt("combo_max")
		
		if ( ( totalplayed >= 5 ) and ( ( ply:Frags() / totalplayed ) >= 0.65 ) ) then
			quastring = "Talented 65%"
			quartiers = true
		end
		if ( ( totalplayed >= 5 ) and ( ( ply:Frags() / totalplayed ) >= 0.80 ) ) then
			quastring = "Perfect 80%"
		end
		
		if ( ( totalplayed >= 5 ) and ( ( ply:Frags() / totalplayed ) <= 0.20 ) ) then
			quastring = "Try harder <20%"
			quartiers = true
		end
		if ( ( totalplayed >= 5 ) and ( ( ply:Frags() / totalplayed ) <= 0.15 ) ) then
			quastring = "AFK ? <15%"
		end
		
		if ( GAMEMODE.BestStreakEver == combomax ) then
			besstring = "Best Streak"
			beststreak = true
		end
		
		local qb = ""
		if ( quartiers and beststreak ) then
			qb = " + "
		end
		return "  " .. quastring .. qb .. besstring
	end
	
	ScoreBoard:AddColumn( "Awards", 190, f, 0.5 , nil, 6 , 6 )

end

function GM:CreateScoreboard( ScoreBoard )

	ScoreBoard:SetAsBullshitTeam( TEAM_SPECTATOR )
	ScoreBoard:SetAsBullshitTeam( TEAM_CONNECTING )
	
	if ( GAMEMODE.TeamBased ) then
		ScoreBoard:SetAsBullshitTeam( TEAM_UNASSIGNED )
		ScoreBoard:SetHorizontal( true )
	end

	ScoreBoard:SetSkin( "SimpleSkin" )

	self:AddScoreboardAvatar( ScoreBoard )		 //1
	self:AddScoreboardWantsChange( ScoreBoard )	 //2
	self:AddScoreboardName( ScoreBoard )	     //3
	self:AddScoreboardWon( ScoreBoard )          //4
	self:AddScoreboardFailed( ScoreBoard )       //5
	self:AddScoreboardStreak( ScoreBoard )	     //6
	self:AddScoreboardAward( ScoreBoard )		 //7
	self:AddScoreboardPing( ScoreBoard )     //8
		
	// Here we sort by these columns (and descending), in this order. You can define up to 4
	ScoreBoard:SetSortColumns( { 4, true, 5, false, 3, false } )

end

function GM:PositionScoreboard( ScoreBoard )

	if ( GAMEMODE.TeamBased ) then
		ScoreBoard:SetSize( 780, ScrH() - 50 )
		ScoreBoard:SetPos( (ScrW() - ScoreBoard:GetWide()) * 0.5,  25 )
	else
		ScoreBoard:SetSize( 600, ScrH() - 64 )
		ScoreBoard:SetPos( (ScrW() - ScoreBoard:GetWide()) / 2, 32 )
	end

end

function GM:UpdateHUD_Alive( InRound )
	return false
end




/*----------------------------------
VGUI Includes
------------------------------------*/

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

function WaitShow( m ) --used in ServerJoinInfo
	WaitVGUI:Show()
end
usermessage.Hook( "WaitShow", WaitShow )

local function WaitHide( m )
	WaitVGUI:Hide()
end
usermessage.Hook( "WaitHide", WaitHide )

local function EndOfGamemode_HideVGUI( m )
	RidiculousVGUI:Hide()
	ClockVGUI:Hide()
	ClockGameVGUI:Hide()
end
usermessage.Hook( "EndOfGamemode_HideVGUI", EndOfGamemode_HideVGUI )



