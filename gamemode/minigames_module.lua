
module( "ware_mod", package.seeall )

local Minigames = {}
local Minigames_names = {}
local Minigames_sequence = {}
local Minigames_CSFiles = {}

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
			minigame.Hooks[name] = function(...) return func(minigame,unpack(arg)) end
		end
	end
	
	setmetatable(minigame, ware_mod_meta)
	Minigames[name] = minigame
	
	table.insert(Minigames_names, name)
end

function RandomizeGameSequence()
	Minigames_sequence = {}
	local gamenamecopy = ware_mod.GetNamesTable()
	local occurListDisc = {}
	local occur
	
	for i=1,#gamenamecopy do
		local name = table.remove(gamenamecopy, math.random(1,#gamenamecopy))
		table.insert(Minigames_sequence,name)
		
		occur = ware_mod.Get(name).OccurencesPerCycle or 1
		occurListDisc[name] = (occurListDisc[name] or 0) + 1
		if occur - occurListDisc[name] > 0 then
			table.insert(gamenamecopy,name)
		end
	end
end

function GetRandomGameName()
	local name, minigame
	repeat
		if #Minigames_sequence == 0 then -- All games have been played, start a new cycle
			ware_mod.RandomizeGameSequence()
		end
		name = table.remove(Minigames_sequence,1)
		minigame = ware_mod.Get(name)
	until minigame.IsPlayable == nil or minigame:IsPlayable()
	return name
end

function Get(name)
	return Minigames[name]
end

function GetHooks(name)
	if Minigames[name] == nil then return nil end
	return Minigames[name].Hooks or nil
end

function GetNamesTable()
	return table.Copy(Minigames_names)
end

function GetAuthorTable()
	local authtable = {}
	for k,v in pairs(Minigames) do
		authtable[v.Author or "Unknown"] = (authtable[v.Author or "Unknown"] or 0) + 1
	end
	return table.Copy(authtable)
end
