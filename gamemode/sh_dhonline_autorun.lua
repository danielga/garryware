////////////////////////////////////////////////
// -- Depth HUD : Inline                      //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Shared call file                           /
////////////////////////////////////////////////

if DHONLINE_DEBUG == nil then
	DHONLINE_DEBUG = false
end

DHONLINE_HOOK_HUDPAINT      = false
DHONLINE_HOOK_HUDSHOULDDRAW = false
DHONLINE_DEFAULTTHEME = "garryware"

DHONLINE_NAME = "DepthHUD Inline for Gamemodes"
DHONLINE_THEMEDIR = "dhi_garryware/"

-- SERVER INCLUSION FOR VERY SPECIAL CASES. DO NOT USE UNLESS AWARE OF ITS MAIN USES.

-- You can OMIT adding those files to your gamemode if running as a strap :
-- Official data/ folder.
-- Official materials/ folder.
-- Official resource/ folder.
-- Lua file : control_presets.lua
-- Lua file : preset_editor.lua
-- Lua file : DhCheckPos.lua
-- Lua file : cl_dhonline_cvar_custom.lua
-- Lua file : cl_dhonline_elementpanel.lua
-- Lua file : cl_dhonline_version.lua
-- Official themes.
-- All those cited directory and files DON'T NEED to be added in your gamemode.


-- Don't turn DHONLINE_SPECIAL_SENDSTATICTOCLIENTS to true, unless
-- you have reconfigured the theme directory,
-- and also the default theme,
-- and batch-replaced all match-case "dhonline" to a custom var name in all lua files,
-- and also  replaced all match-case "DHONLINE" to a custom capital letters var name in all lua files,
-- and MORE IMPORTANTLY, replace all "dhonline" from >> Lua Filenames <<, including this one.

-- If you are including as part of a gamemode, set DHONLINE_SPECIAL_ISGAMEMODE_STRAP to true.

DHONLINE_SPECIAL_SENDSTATICTOCLIENTS = true
DHONLINE_SPECIAL_ISGAMEMODE_STRAP = true

if (CLIENT) then
	if (dhonline and dhonline.Unmount) then dhonline.Unmount() end

	dhonline = {}

	include("cl_dhonline_base.lua")
	
	if not DHONLINE_SPECIAL_SENDSTATICTOCLIENTS then
		-- Load regular DepthHUD Inline for clients.
		include("cl_dhonline_version.lua")
		include("cl_dhonline_elementpanel.lua")
		include("cl_dhonline_cvar_custom.lua")
		
	else
		-- Load special serverside DepthHUD Inline.
		include("cl_dhonline_cvar_static.lua")
	end

	dhonline.Mount()
	
elseif (DHONLINE_SPECIAL_SENDSTATICTOCLIENTS) then -- SERVER, don't send to clients default.

	AddCSLuaFile("sh_dhonline_autorun.lua")
	AddCSLuaFile("garbage_module.lua")
	AddCSLuaFile("cl_dhonline_base.lua")
	AddCSLuaFile("cl_dhonline_element.lua")
	AddCSLuaFile("cl_dhonline_theme.lua")
	AddCSLuaFile("cl_dhonline_cvar_static.lua")
	
	local mainPath = DHONLINE_THEMEDIR
	if DHONLINE_SPECIAL_ISGAMEMODE_STRAP then
		mainPath = string.Replace(GM.Folder, "gamemodes/", "") .. "/gamemode/" .. mainPath
	end
	for _,fileName in pairs(file.FindInLua(mainPath .. "*_theme.lua")) do
		AddCSLuaFile(mainPath .. fileName)
		AddCSLuaFile(mainPath .. string.Replace(fileName, "_theme.lua", "_element.lua"))
		Msg("Server " .. DHONLINE_NAME .. " > Sending theme " .. string.Replace(fileName, "_theme.lua", "") .. "\n")
		local themePath = mainPath .. string.Replace(fileName, "_theme.lua", "/")
		for _,elementFile in pairs(file.FindInLua(themePath .."/*.lua")) do
			AddCSLuaFile(themePath .. elementFile)
			if (DHONLINE_DEBUG) then Msg("Server " .. DHONLINE_NAME .. " > Sending " .. themePath .. elementFile .. "\n") end
		end
	end
	
end