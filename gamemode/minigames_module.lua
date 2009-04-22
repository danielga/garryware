
module( "ware_minigame", package.seeall )

local Minigames = {}



function Register( name, minigame )
	Minigames[name] = minigame
end

function GetRandomGame( )
	--return Minigames[ name ]
end

function PickGame( name )
	return Minigames[ name ]
end
