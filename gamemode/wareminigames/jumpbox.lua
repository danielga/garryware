WARE.Author = "xandar"
WARE.Duration = 5.0

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(3, self.Duration)
	
	GAMEMODE:SetPlayersInitialStatus( true )
	GAMEMODE:DrawInstructions( "Don't stop sprint-jumping from box to box!" )
	
	self.Entground = GAMEMODE:GetEnts(ENTS_CROSS)
end

function WARE:StartAction()
	self.PlayerLastBlock = {}
	self.PlayerLastTime = {}
	
	self.EndTime = CurTime() + self.Duration
	
	self.PlayerList = team.GetPlayers(TEAM_HUMANS)
	
	for _,v in pairs(self.PlayerList) do
		self.PlayerLastBlock[v] = nil
		self.PlayerLastTime[v] = CurTime()
	end
end

function WARE:EndAction()

end

function WARE:Think()	
	for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do		
		if v:GetPos().z-self.Entground[1]:GetPos().z <= 5 then 
			v:ApplyLose()
		end
	end 
	
	local entposcopy = 	table.Copy(GAMEMODE:GetEnts(ENTS_ONCRATE))
	for _,block in pairs(entposcopy) do
		local box = ents.FindInBox(block:GetPos() + Vector(-30,-30,0), block:GetPos() + Vector(30,30,64))
		for _,target in pairs(box) do
			if target:IsPlayer() and target:IsWarePlayer() then
				if (self.PlayerLastBlock[target] != block) then
					self.PlayerLastBlock[target] = block
					self.PlayerLastTime[target] = CurTime()
					if ((CurTime() + 1.75) > self.EndTime) then
						target:ApplyWin()
					end
				end
			end
		end
	end
	
	for k,v in pairs(self.PlayerList) do
		if v:IsValid() then
			if (CurTime() > (self.PlayerLastTime[v] + 1.75)) then
				v:ApplyLose()
			end
		end
	end
end