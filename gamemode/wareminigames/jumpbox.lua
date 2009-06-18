WARE.Author = "xandar"

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(2,5)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Don't stop jumping from box to box !",1)
	self.Entground = GAMEMODE:GetEnts(ENTS_CROSS)
	return
end

function WARE:StartAction()
	self.PlayerLastBlock = {}
	self.PlayerLastTime = {}
	
	self.PlayerList = team.GetPlayers(TEAM_UNASSIGNED)
	
	for _,v in pairs(self.PlayerList) do
		self.PlayerLastBlock[v] = nil
		self.PlayerLastTime[v] = CurTime()
	end
end

function WARE:EndAction()

end

function WARE:Think()	
	for k,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do		
		if v:GetPos().z-self.Entground[1]:GetPos().z <= 5 then 
			v:WarePlayerDestinyLose()
		end
	end 
	
	local entposcopy = 	table.Copy(GAMEMODE:GetEnts(ENTS_ONCRATE))
	for _,block in pairs(entposcopy) do
		local box = ents.FindInBox(block:GetPos()+Vector(-30,-30,0),block:GetPos()+Vector(30,30,64))
		for _,target in pairs(box) do
			if target:IsPlayer() then
				if (self.PlayerLastBlock[target] != block) then
					self.PlayerLastBlock[target] = block
					self.PlayerLastTime[target] = CurTime()
				end
			end
		end
	end
	
	for k,v in pairs(self.PlayerList) do
		if v:IsValid() then
			if (CurTime() > (self.PlayerLastTime[v] + 1.75)) then
				v:WarePlayerDestinyLose()
			end
		end
	end
end