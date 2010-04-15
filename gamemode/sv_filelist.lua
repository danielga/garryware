////////////////////////////////////////////////
// -- GarryWare Two                           //
// by Hurricaaane (Ha3)                       //
//  and Kilburn_                              //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Files sent to players                      //
////////////////////////////////////////////////

AddCSLuaFile( "shared.lua" )

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_postprocess.lua" )
AddCSLuaFile( "cl_usermsg.lua" )

AddCSLuaFile( "skin.lua" )
AddCSLuaFile( "tables.lua" )
AddCSLuaFile( "ply_extension.lua" )
AddCSLuaFile( "garbage_module.lua" )
AddCSLuaFile( "sh_chataddtext.lua" )

// Fretta VGUI replacements :
AddCSLuaFile( "cl_splashscreen.lua" )
AddCSLuaFile( "vgui/vgui_scoreboard.lua" )

AddCSLuaFile( "vgui_transitscreen.lua" )
AddCSLuaFile( "vgui_clock.lua" )
AddCSLuaFile( "vgui_clockgame.lua" )
AddCSLuaFile( "vgui_waitscreen.lua" )

-- Sound Resources
for k,stringOrTable in pairs(GM.WASND) do
	if type(stringOrTable) == "string" then
		resource.AddFile("sound/" .. stringOrTable)
		
	elseif type(stringOrTable) == "table" then
	    if type(stringOrTable[1]) == "string" then --If not, it's a bireferenced table
			for l,sString in pairs(stringOrTable) do
				resource.AddFile("sound/" .. sString)
			end
		end
		
	end
end

-- Gamemode Resources
resource.AddFile("materials/refract_ring.vmt")
resource.AddFile("materials/refract_ring.vtf")
resource.AddFile("materials/ware/interface/ware_clock_two.vmt")
resource.AddFile("materials/ware/interface/ware_clock_two.vtf") -- This has NOLOD
resource.AddFile("materials/ware/interface/ware_trotter.vmt")
resource.AddFile("materials/ware/interface/ware_trotter.vtf")
resource.AddFile("materials/ware/stickers/ware_clock_two.vmt")
resource.AddFile("materials/ware/stickers/ware_clock_two.vtf") -- This has LOD
resource.AddFile("materials/vgui/ware/garryware_two_logo.vmt")
resource.AddFile("materials/vgui/ware/garryware_two_logo.vtf")
resource.AddFile("materials/vgui/ware/garryware_two_logo_alone.vmt")
resource.AddFile("materials/vgui/ware/garryware_two_logo_alone.vtf")

-- Nonc Files
resource.AddFile("materials/ware/nonc/ware_bullseye.vmt")
resource.AddFile("materials/ware/nonc/ware_bullseye.vtf")
resource.AddFile("materials/ware/nonc/ware_facepunch.vmt")
resource.AddFile("materials/ware/nonc/ware_facepunch.vtf")
resource.AddFile("materials/ware/nonc/ware_file.vmt")
resource.AddFile("materials/ware/nonc/ware_file.vtf")
resource.AddFile("materials/ware/nonc/ware_mail.vmt")
resource.AddFile("materials/ware/nonc/ware_mail.vtf")
resource.AddFile("materials/ware/nonc/ware_zip.vmt")
resource.AddFile("materials/ware/nonc/ware_zip.vtf")

-- Map-related Resources
resource.AddFile("materials/ware/detail.vtf")
resource.AddFile("materials/ware/ware_crate.vmt")
resource.AddFile("materials/ware/ware_crate.vtf")
resource.AddFile("materials/ware/ware_crate2.vmt")
resource.AddFile("materials/ware/ware_crate2.vtf")
resource.AddFile("materials/ware/ware_floor.vtf")
resource.AddFile("materials/ware/ware_floorred.vmt")
resource.AddFile("materials/ware/ware_wallorange.vmt")
resource.AddFile("materials/ware/ware_wallwhite.vtf")

////////////////////////////////////////////////
////////////////////////////////////////////////