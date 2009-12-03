ELEMENT.Name = "7"
ELEMENT.DefaultOff = false
ELEMENT.DefaultGridPosX = 8
ELEMENT.DefaultGridPosY = 0.5
ELEMENT.SizeX = -0.5
ELEMENT.SizeY = 30

ELEMENT.LockedColor    = Color(255,255,255,220)
ELEMENT.UnstableColor  = Color(192,0,0,192)
ELEMENT.WinColor  = Color(128,128,255,192)
ELEMENT.LoseColor = Color(255,64,64,192)
ELEMENT.TextColor = Color(255,255,255,255)
ELEMENT.GoldColor = Color(255,255,128,255)

ELEMENT.BorderColor = ELEMENT.LockedColor

ELEMENT.extraBorder = 8.0
ELEMENT.extraLocked = 16.0
ELEMENT.extraBorderVariance = 3.0


function ELEMENT:Initialize( )

end

function ELEMENT:DrawFunction( )
	
	if (LocalPlayer():GetBestCombo() == GAMEMODE:GetBestStreak()) then
		self.BorderColor = self.GoldColor
	else
		self.BorderColor = self.LockedColor
	end
	
	local winners, failures = 0, 0
	for k, ply in pairs( team.GetPlayers(TEAM_HUMANS) ) do
		winners = winners + (((ply:GetAchieved() or false) and 1) or 0)
	end
	failures = team.NumPlayers(TEAM_HUMANS) - winners
	
	self:DrawGWDoubleSidedBox(
	  2
	, "Winners"
	, "Failures"
	, self.WinColor
	, self.LoseColor
	, self.BorderColor
	, self.TextColor
	, self.TextColor
	, 1
	)
	
	self:DrawGWRelativeTextBox(
	  -1.0
	, 0.0
	, 36
	, 36
	, 4
	, winners
	, self.WinColor
	, self.BorderColor
	, self.TextColor
	, 1
	)
	self:DrawGWRelativeTextBox(
	  1.0
	, 0.0
	, 36
	, 36
	, 4
	, failures
	, self.LoseColor
	, self.BorderColor
	, self.TextColor
	, 1
	)
end

