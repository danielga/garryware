////////////////////////////////////////////////
// // GarryWare Gold                          //
// by Hurricaaane (Ha3)                       //
//  and Kilburn_                              //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
-- Clientside Initialization                  --
////////////////////////////////////////////////

DEFINE_BASECLASS( "gamemode_base" )

include( 'shared.lua' )

surface.CreateFont("garryware_instructions",	{font = "Trebuchet MS", size = 36, weight = 0   , antialias = true, additive = false})
surface.CreateFont("garryware_largetext",		{font = "Trebuchet MS", size = 36, weight = 0   , antialias = true, additive = false})
surface.CreateFont("garryware_mediumtext",		{font = "Trebuchet MS", size = 24, weight = 0   , antialias = true, additive = false})
surface.CreateFont("garryware_averagetext",		{font = "Trebuchet MS", size = 20, weight = 0   , antialias = true, additive = false})
surface.CreateFont("garryware_smalltext",		{font = "Trebuchet MS", size = 16, weight = 400 , antialias = true, additive = false})

include( 'panel_warelabel.lua' )
include( 'panel_arrow.lua' )
include( 'panel_message.lua' )
include( 'panel_playerlabel.lua' )
include( 'panel_finalplayerlabel.lua' )

include( 'cl_hud.lua' )
include( 'cl_postprocess.lua' )
include( 'cl_usermsg.lua' )
include( 'cl_mapdecoration.lua' )

include( 'skin.lua' )
include( "sh_tables.lua" )
include( "sh_chataddtext.lua" )

include( "cl_version.lua" )
include( "cl_version_search.lua" )

include( 'cl_splashscreen.lua' )
include( 'vgui/vgui_scoreboard.lua' )

include( 'garbage_module.lua' )


function WARE_SortTable( plyA, plyB )
	if ( not(plyA) or not(plyB) ) then return false end
	if ( not(IsValid(plyA)) or not(IsValid(plyB)) ) then return false end
	
	local tokenA = plyA:GetAchieved() and (plyA:GetLocked() and (plyA:IsFirst() and 5 or 4) or 3) or (plyA:GetLocked() and (plyA:IsFirst() and 1 or 0) or 2)
	local tokenB = plyB:GetAchieved() and (plyB:GetLocked() and (plyB:IsFirst() and 5 or 4) or 3) or (plyB:GetLocked() and (plyB:IsFirst() and 1 or 0) or 2)
	
	if ( tokenA == tokenB ) then
		if ( plyA:Frags() == plyB:Frags() ) then
			if ( plyA:GetBestCombo() == plyB:GetBestCombo() ) then
				return plyA:Nick() < plyB:Nick()
			else
				return plyA:GetBestCombo() > plyB:GetBestCombo()
			end
		else
			return plyA:Frags() > plyB:Frags()
		end
	else
		return tokenA > tokenB
		
	end
end

function WARE_SortTableStateBlind( plyA, plyB )
	if ( not(plyA) or not(plyB) ) then return false end
	if ( not(IsValid(plyA)) or not(IsValid(plyB)) ) then return false end
	
	if ( plyA:Frags() == plyB:Frags() ) then
		if ( plyA:GetBestCombo() == plyB:GetBestCombo() ) then
			return plyA:Nick() < plyB:Nick()
		else
			return plyA:GetBestCombo() > plyB:GetBestCombo()
		end
	else
		return plyA:Frags() > plyB:Frags()
	end
end

function GM:CreateAmbientMusic()
	for k,path in pairs(GAMEMODE.WASND.THL_AmbientMusic) do
		gws_AmbientMusic[k] = CreateSound(LocalPlayer(), path)
		gws_AmbientMusic_dat[k] = {}
	end
	
end

function GM:InitPostEntity()
	BaseClass.InitPostEntity( self )
	
	self:CreateAmbientMusic()
end

function GM:Think()
	BaseClass.Think( self )
	
	-- Announcer ticks.
	if (gws_TickAnnounce > 0 and CurTime() < gws_NextgameEnd ) then
		if (CurTime() > (gws_NextgameEnd - (gws_WareLen / 6) * gws_TickAnnounce )) then
			if GAMEMODE.WASND.BITBL_TimeLeft[gws_CurrentAnnouncer] and GAMEMODE.WASND.BITBL_TimeLeft[gws_CurrentAnnouncer][gws_TickAnnounce] then
				LocalPlayer():EmitSound( GAMEMODE.WASND.BITBL_TimeLeft[gws_CurrentAnnouncer][gws_TickAnnounce], 100, GAMEMODE:GetSpeedPercent() )
			end
			gws_TickAnnounce = gws_TickAnnounce - 1
			
			if gws_TickAnnounce == 0 and GAMEMODE.WASND.BITBL_TimeLeft[gws_CurrentAnnouncer][0] then
				timer.Simple((gws_WareLen / 6), function() LocalPlayer():EmitSound(GAMEMODE.WASND.BITBL_TimeLeft[gws_CurrentAnnouncer][0], 100, GAMEMODE:GetSpeedPercent()) end )
			end
		end
	end
end


--print( "GAMEMODE : " .. tostring(gmod.GetGamemode and gmod.GetGamemode().Name or "<ERROR>") )
