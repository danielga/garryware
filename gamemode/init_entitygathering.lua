--Entity gathering included in init.lua
function GM:GetEnts( group )
	local all_ents = ents.FindByClass("gmod_warelocation")
	local entlist = {}

	for k,v in pairs(all_ents) do
		if v:GetName() == group then
			table.insert(entlist,v)
		end
	end
	return entlist
end

function GM:GetRandomLocations(num, group)
	local entposcopy = {}
	if type(group) == "table" then
		for k,v in pairs(group) do
			if (type(v) == "string") then
				for l,w in pairs(GAMEMODE:GetEnts(group)) do
					table.insert(entposcopy,w)
				end
			else
				table.insert(entposcopy,v)
			end
		end
	else
		entposcopy = table.Copy(GAMEMODE:GetEnts(group))
	end
	local result = {}
	
	local available = math.Clamp(num,1,#entposcopy)
	
	for i=1,available do
		local p = table.remove(entposcopy, math.random(1,#entposcopy))
		table.insert(result, p)
	end
	
	return result
end

function GM:GetRandomPositions(num, group)
	local result = self:GetRandomLocations(num, group)
	for k,v in pairs(result) do
		result[k] = result[k]:GetPos()
	end
	
	return result
end

function GM:GetRandomLocationsAvoidBox(num, group, test, vec1, vec2)
	local entposcopy = table.Copy(GAMEMODE:GetEnts(group))
	num = math.Clamp(num,0,#entposcopy)
	local result = {}
	local invalid = {}
	local failsafe = false
	
	for i=1,num do
		local ok
		repeat
			local p = table.remove(entposcopy, math.random(1,#entposcopy))
			ok = true
			
			if not failsafe then
				for _,v in pairs(ents.FindInBox(p:GetPos()+vec1, p:GetPos()+vec2)) do
					if test(v) then
						ok = false
						break
					end
				end
			end
			
			if ok then
				table.insert(result, p)
			else
				table.insert(invalid, p)
			end
			
			if #entposcopy==0 then
				-- No more entities available, enable failsafe mode, and pick invalid entities
				entposcopy = invalid
				failsafe = true
			end
		until ok
	end
	
	return result
end

function GM:GetRandomPositionsAvoidBox(num, group, test, vec1, vec2)
	local result = self:GetRandomLocationsAvoidBox(num, group, test, vec1, vec2)
	for k,v in pairs(result) do
		result[k] = result[k]:GetPos()
	end
	
	return result
end
