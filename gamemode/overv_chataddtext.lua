/*-----------------------
	Serverside chat.AddText by Overv
	Use this script in anything you like to,
	but do mention the thread or my name.
	
	Ha3 - There you go : http://www.facepunch.com/showthread.php?t=768062
	
	chat.AddText([ Player ply,] Colour colour, string text, Colour colour, string text, ... )
	Returns: nil
	In Object: None
	Part of Library: chat
	Available On: Server
-----------------------*/

if SERVER then
	chat = { }
	function chat.AddText( ... )
		if ( type( arg[1] ) == "Player" ) then ply = arg[1] end
		
		umsg.Start( "AddText", ply )
			umsg.Short( #arg )
			for _, v in pairs( arg ) do
				if ( type( v ) == "string" ) then
					umsg.String( v )
				elseif ( type ( v ) == "table" ) then
					//fucking short
					umsg.Char( v.r - 128 )
					umsg.Char( v.g - 128 )
					umsg.Char( v.b - 128 )
				end
			end
		umsg.End( )
	end
else
	usermessage.Hook( "AddText", function( um )
		local argc = um:ReadShort( )
		local args = { }
		for i = 1, argc / 2, 1 do
			table.insert( args, Color( um:ReadChar( ) + 128, um:ReadChar( ) + 128, um:ReadChar( ) + 128, 255 ) )
			table.insert( args, um:ReadString( ) )
		end
		
		chat.AddText( unpack( args ) )
	end )
end