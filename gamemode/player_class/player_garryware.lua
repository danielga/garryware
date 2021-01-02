////////////////////////////////////////////////
// // GarryWare Gold                          //
// by Hurricaaane (Ha3)                       //
//  and Kilburn_                              //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Default      Class                         //
////////////////////////////////////////////////

AddCSLuaFile()
DEFINE_BASECLASS("player_default")

local CLASS = {}

CLASS.DisplayName			= "GarryWare"
CLASS.CrouchedWalkSpeed	    = 0.5
CLASS.DuckSpeed			    = 0.2
CLASS.StartHealth			= 100
CLASS.MaxHealth			    = 100
CLASS.DrawTeamRing			= true
CLASS.CanUseFlashlight		= true

function CLASS:Loadout(pl)
end

player_manager.RegisterClass("player_garryware", CLASS, "player_default")
