
module( "ware_minigame", package.seeall )

local Minigames = {}
local Minigames_names = {}

local function CopyTable(tbl)
	local res = {}
	for k,v in pairs(tbl) do
		if k~="Hooks" or type(v)~="table" then
			res[k] = v
		else
			res[k] = CopyTable(v)
		end
	end
	return res
end

local ware_minigame_meta = {
	__index = {
		Copy = function(self)
			return CopyTable(self)
		end,
	}
}

local function IsValidHookName(name)
	return name~="Initialize" and name~="StartAction" and name~="EndAction" and name~="IsPlayable"
end

function Register(name, minigame)
	minigame.Hooks = {}
	for name,func in pairs(minigame) do
		if type(func)=="function" and IsValidHookName(name) then
			minigame.Hooks[name] = function(...) func(minigame,unpack(arg)) end
		end
	end
	
	setmetatable(minigame, ware_minigame_meta)
	Minigames[name] = minigame
	
	table.insert(Minigames_names, name)
end

function GetRandomGame()
	return Minigames_names[math.random(1,#Minigames_names)]
end

function Get(name)
	return Minigames[name]
end

function GetHooks(name)
	return Minigames[name].Hooks
end
