ELEMENT.Name = "8"
ELEMENT.DefaultOff = false
ELEMENT.DefaultGridPosX = 16 - 5
ELEMENT.DefaultGridPosY = 0.5
ELEMENT.SizeX = -0.25
ELEMENT.SizeY = 20

ELEMENT.LockedColor    = Color(255,255,255,220)
ELEMENT.UnstableColor  = Color(192,0,0,192)

ELEMENT.WinColor  = Color(128,128,255,192)
ELEMENT.LoseColor = Color(255,64,64,192)
ELEMENT.MysteryColor  = Color(128,255,255,192)
ELEMENT.HoldColor     = Color(192,192,192,192)

ELEMENT.GoldColor = Color(255,255,128,190)
ELEMENT.GoldColorBack = Color(235,177,20,255)

ELEMENT.TextColor = Color(255,255,255,255)

ELEMENT.PlayerTable = {}

ELEMENT.TableRefreshDelay = 0.1
ELEMENT.TableRefreshTime  = CurTime()

function ELEMENT:Initialize( )

end

function ELEMENT:DrawFunction( )
	if ((CurTime() - self.TableRefreshTime) > self.TableRefreshDelay) then
		self.PlayerTable = {}
		
		for k,ply in pairs(team.GetPlayers(TEAM_HUMANS)) do
			if (ply:GetAchieved() or false) == false then
				table.insert( self.PlayerTable , ply )
			end
		end
		
		self.TableRefreshTime = CurTime()
	end

	local k = 1
	while k <= #self.PlayerTable do
		if not (self.PlayerTable[k] and ValidEntity(self.PlayerTable[k])) then
			table.remove(self.PlayerTable, k)
		else
			k = k + 1
		end
	end
	
	if #self.PlayerTable > 1 then
		table.sort( self.PlayerTable , WARE_SortTable )
	end
	
	for k,ply in pairs(self.PlayerTable) do
		self:DrawGWPreProgrammedRidiculousBox(k, ply, self.TextColor, self.WinColor, self.LoseColor, (not ply:IsOnHold() and self.MysteryColor) or self.HoldColor, self.GoldColorBack, self.GoldColor, self.UnstableColor, self.LockedColor)
		
		if (k >= 5) then break end // Horror museum
	end
end

