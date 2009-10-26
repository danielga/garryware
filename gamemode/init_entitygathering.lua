--Entity gathering included in init.lua
function GM:GetEnts( group )
	return self.CurrentEnvironment:GetEnts(group)
end

function GM:GetRandomLocations(num, group)
	return self.CurrentEnvironment:GetRandomLocations(num, group)
end

function GM:GetRandomPositions(num, group)
	return self.CurrentEnvironment:GetRandomPositions(num, group)
end

function GM:GetRandomLocationsAvoidBox(num, group, test, vec1, vec2)
	return self.CurrentEnvironment:GetRandomLocationsAvoidBox(num, group, test, vec1, vec2)
end

function GM:GetRandomPositionsAvoidBox(num, group, test, vec1, vec2)
	return self.CurrentEnvironment:GetRandomPositionsAvoidBox(num, group, test, vec1, vec2)
end
