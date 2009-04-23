
module( "ware_mod", package.seeall )

local Minigames = {}
local Minigames_names = {}
local Minigames_sequence = {}

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

local ware_mod_meta = {
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
	
	setmetatable(minigame, ware_mod_meta)
	Minigames[name] = minigame
	
	table.insert(Minigames_names, name)
end

function RandomizeGameSequence()
	Minigames_sequence = {}
	local gamenamecopy = ware_mod.GetNamesTable()
	
	for i=1,#gamenamecopy do
		local name = table.remove(gamenamecopy, math.random(1,#gamenamecopy))
		table.insert(MinigameSequence,name)
	end
end

function GetRandomGame()
	local name, minigame
	repeat
		if #MinigameSequence == 0 then -- All games have been played, start a new cycle
			ware_mod.RandomizeGameSequence()
		end
		name = table.remove(MinigameSequence,1)
		minigame = ware_mod.Get(name)
	until minigame.IsPlayable == nil or minigame:IsPlayable()
	return minigame
end

function Get(name)
	return Minigames[name]
end

function GetHooks(name)
	return Minigames[name].Hooks
end

function GetNamesTable()
	return table.Copy(Minigames_names)
end
