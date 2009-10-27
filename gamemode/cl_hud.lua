
surface.CreateFont( "coolvetica", 48, 400, true, false, "WAREIns" ) 
surface.CreateFont( "coolvetica", 36, 400, true, false, "WAREDom" )
surface.CreateFont( "Verdana", 16, 400, true, false, "WAREScore" ) 

/*----------------------------------
HUD Dominations
------------------------------------*/

local DominationMat = Material("sprites/ware_clock_two")
local LightColor = nil
local PosToScreen = nil
local NewWorldPos = Vector(0,0,0)

function GM:PrintDominations( )
	for k,ply in pairs(team.GetPlayers(TEAM_HUMANS)) do
		if ply:GetCombo() >= 3 then
			surface.SetMaterial( DominationMat )
		
			GC_VectorCopy(NewWorldPos, ply:GetPos())
			NewWorldPos.z = NewWorldPos.z + 96
			
			LightColor = render.GetLightColor( ply:GetPos() ) * 2
			LightColor.x = 235 * mathx.Clamp( LightColor.x, 0, 1 )
			LightColor.y = 177 * mathx.Clamp( LightColor.y, 0, 1 )
			LightColor.z = 20  * mathx.Clamp( LightColor.z, 0, 1 )
			PosToScreen = NewWorldPos:ToScreen()
			
			surface.SetDrawColor( LightColor.x, LightColor.y, LightColor.z, 255 )
			surface.DrawTexturedRectRotated( PosToScreen.x, PosToScreen.y - 2, 52, 52, 0 )
			
			draw.SimpleTextOutlined( tostring(ply:GetCombo()), "WAREDom", PosToScreen.x, PosToScreen.y, GAMEMODE:GetBaseColorPtr( "dom_text" ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, GAMEMODE:GetBaseColorPtr( "dom_outline" ) )
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
	return
end

/*----------------------------------
HUD Paint
------------------------------------*/

function GM:HUDPaint()
	self.BaseClass:HUDPaint();
	
	self:PrintDominations();
	//self:PrintCommonParticles();
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

	ScoreBoard:SetSkin( "ware" )

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

function GM:UpdateHUD_Dead( whatever )
	return false
end


/*---------------------------------------------------------
   Name: gamemode:HUDDrawTargetID( )
   Desc: Draw the target id (the name of the player you're currently looking at)
---------------------------------------------------------*/
function GM:HUDDrawTargetID()

	local tr = utilx.GetPlayerTrace( LocalPlayer(), LocalPlayer():GetCursorAimVector() )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	if (!trace.HitNonWorld) then return end
	
	local text = "ERROR"
	local font = "TargetID"
	
	if (trace.Entity:IsPlayer()) then
		text = trace.Entity:Nick()
	else
		return
	end
	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	
	local MouseX, MouseY = gui.MousePos()
	
	if ( MouseX == 0 && MouseY == 0 ) then
	
		MouseX = ScrW() / 2
		MouseY = ScrH() / 2
	
	end
	
	local x = MouseX
	local y = MouseY
	
	x = x - w / 2
	y = y + 30
	
	// The fonts internal drop shadow looks lousy with AA on
	draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,120) )
	draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,50) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )
	
	y = y + h + 5
	
	local text = trace.Entity:Frags() .. "W / " .. trace.Entity:Deaths() .. "F / " .. trace.Entity:GetBestCombo() .. "BC"
	local font = "TargetIDSmall"
	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	local x =  MouseX  - w / 2
	
	draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,120) )
	draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,50) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )

end




