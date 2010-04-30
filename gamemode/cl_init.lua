////////////////////////////////////////////////
-- -- GarryWare Two                           --
-- by Hurricaaane (Ha3)                       --
--  and Kilburn_                              --
-- http://www.youtube.com/user/Hurricaaane    --
//--------------------------------------------//
-- Clientside Initialization                  --
////////////////////////////////////////////////

include( 'shared.lua' )
include( 'cl_hud.lua' )
include( 'cl_postprocess.lua' )
include( 'cl_usermsg.lua' )
include( 'skin.lua' )
include( "tables.lua" )
include( "sh_chataddtext.lua" )

include("sh_dhonline_autorun.lua")


include( 'cl_splashscreen.lua' )
include( 'vgui/vgui_scoreboard.lua' )

function WARE_SortTable( plyA, plyB )
	if ( not(plyA) or not(plyB) ) then return false end
	if ( not(ValidEntity(plyA)) or not(ValidEntity(plyB)) ) then return false end
	
	if ( plyA:GetLocked() == plyB:GetLocked() ) then
		if ( plyA:Frags() == plyB:Frags() ) then
			if ( plyA:GetBestCombo() == plyB:GetBestCombo() ) then
				if ( plyA:Deaths() == plyB:Deaths() ) then
					return plyA:UserID() > plyB:UserID()
				else
					--Intentionnal : A player with more fails and same wins played more.
					return plyA:Deaths() > plyB:Deaths()
				end
			else
				return plyA:GetBestCombo() > plyB:GetBestCombo()
			end
		else
			return plyA:Frags() > plyB:Frags()
		end
	else
		return ((plyA:GetAchieved() or false) and (plyA:GetLocked() and not plyB:GetLocked())
		       or not(plyA:GetAchieved() or false) and (not plyA:GetLocked() and plyB:GetLocked())) or false
	end
end

function GM:CreateAmbientMusic()
	for k,path in pairs(GAMEMODE.WASND.THL_AmbientMusic) do
		AmbientMusic[k] = CreateSound(LocalPlayer(), path)
	end
end

function GM:InitPostEntity()
	self.BaseClass:InitPostEntity()
	
	self:CreateAmbientMusic()
end

function GM:Think()
	self.BaseClass:Think()
	
	-- Announcer ticks.
	if (TickAnnounce > 0 and CurTime() < NextgameEnd ) then
		if (CurTime() > (NextgameEnd - (WareLen / 6) * TickAnnounce )) then
			if GAMEMODE.WASND.BITBL_TimeLeft[CurrentAnnouncer] and GAMEMODE.WASND.BITBL_TimeLeft[CurrentAnnouncer][TickAnnounce] then
				LocalPlayer():EmitSound( GAMEMODE.WASND.BITBL_TimeLeft[CurrentAnnouncer][TickAnnounce], 100, GAMEMODE:GetSpeedPercent() )
			end
			TickAnnounce = TickAnnounce - 1
		end
	end
end


--print( "GAMEMODE : " .. tostring(gmod.GetGamemode and gmod.GetGamemode().Name or "<ERROR>") )
