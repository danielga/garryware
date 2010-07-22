
-- Call this BEFORE minigame initialization
-- (NOT AFTER THE END OF MINIGAME !!!)
function GAMEMODE:ResetWareAwards( tAwards )
	self.m_ware_winawards  = {}
	self.m_ware_failawards = {}
	
end

function GAMEMODE:SetWinAwards( tAwards )
	self.m_ware_winawards = tAwards
	
end

function GAMEMODE:SetFailAwards( tAwards )
	self.m_ware_failawards = tAwards
	
end


function GAMEMODE:GiveAwards( ply, tAwards )
	for _,id in pairs( tAwards ) do
		ply.m_tokens[id] = (ply.m_tokens[id] or 0) + 1
		
	end
	
end

function GAMEMODE:CalculateBastAwards()
	local bestTokensFound  = {}
	
	for k,ply in pairs( team.GetPlayers(TEAM_HUMANS) ) do
		for id,num in pairs(ply.m_tokens) do
			if not bestTokensFound[id] or num > bestTokensFound[id][1] then
				bestTokensFound[id] = { num, ply }
				
			else
				table.insert( bestTokensFound[id] , ply )
			
			end
		end
		
	end
	
end