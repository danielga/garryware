ELEMENT.Name = "5"
ELEMENT.DefaultOff = false
ELEMENT.DefaultGridPosX = 8
ELEMENT.DefaultGridPosY = 0
ELEMENT.SizeX = 50
ELEMENT.SizeY = 50

ELEMENT.LockedColor    = Color(255,255,255,220)
ELEMENT.UnstableColor  = Color(192,0,0,192)
ELEMENT.WinColor  = Color(128,128,255,192)
ELEMENT.LoseColor = Color(255,64,64,192)
ELEMENT.MysteryColor  = Color(128,255,255,192)
ELEMENT.HoldColor     = Color(192,192,192,192)
ELEMENT.TextColor = Color(255,255,255,255)

ELEMENT.GoldColor = Color(255,255,128,255)
ELEMENT.GoldColorBack = Color(235,177,20,255)

ELEMENT.GoldColorCalc = Color(255,255,128,255)

ELEMENT.extraBorder = 4.0
ELEMENT.extraLocked = 8.0
ELEMENT.extraBorderVariance = 2.0
ELEMENT.extraGoldSizeExpand = 24.0
ELEMENT.extraGoldTimePeriod = 2.0


function ELEMENT:Initialize( )
	self:CreateSmoother("border", self.extraBorder, 0.3)
	self:CreateSmoother("backcolor"  , Color(0,0,0,0), 0.1)
	self:CreateSmoother("bordercolor", Color(0,0,0,0), 0.1)
end

function ELEMENT:DrawFunction( )
	local backColorRef   = nil
	local borderColorRef = nil
	local extraBorder    = 0
	local extraSize      = 0
	
	if LocalPlayer():GetAchieved() == nil then
		backColorRef = (not LocalPlayer():IsOnHold() and self.MysteryColor) or self.HoldColor
	elseif LocalPlayer():GetAchieved() then
		backColorRef = self.WinColor
	else
		backColorRef = self.LoseColor
	end
	if LocalPlayer():GetLocked() then
		borderColorRef = self.LockedColor
		extraBorder = self.extraLocked
		self:ChangeSmootherRate("bordercolor", 0.3)
	else
		borderColorRef = self.UnstableColor
		extraSize = math.sin( math.rad(RealTime()*360) ) * self.extraBorderVariance
		extraBorder = self.extraBorder + extraSize
		self:ChangeSmootherRate("bordercolor", 0.1)
	end
	
	self:ChangeSmootherTarget("border", extraBorder)
	self:ChangeSmootherTarget("backcolor", backColorRef)
	self:ChangeSmootherTarget("bordercolor", borderColorRef)
	local curExtraBorder = self:GetSmootherCurrent("border")
	local curBackColorRef = self:GetSmootherCurrent("backcolor")
	local curBorderColorRef = self:GetSmootherCurrent("bordercolor")
	
	local comboNum = LocalPlayer():GetCombo()
	if (comboNum >= 3) then
		local extraGoldRatio = 0.5
		if (comboNum == GAMEMODE:GetBestStreak()) then
			extraGoldRatio = ((RealTime() * self.extraGoldTimePeriod) % 1)
		end
		local extraGoldSize = self.SizeX + extraGoldRatio * self.extraGoldSizeExpand
		
		GC_ColorCopy( self.GoldColorCalc , self.GoldColor )
		GC_ColorRatio( self.GoldColorCalc , 1, 1, 1, 1 - extraGoldRatio * 0.5 )
	
		self:DrawGWRelativeTextBox(
		  0.0
		, 0.0
		, extraGoldSize
		, extraGoldSize
		, 0
		, ""
		, self.GoldColorCalc
		, nil
		, nil
		, 1
		)
	end
	
	local text = comboNum
	self:DrawGWTextBox(
	curExtraBorder
	, text
	, curBackColorRef
	, curBorderColorRef
	, self.TextColor
	, 2
	)
	
	local textBis = "Best : " .. LocalPlayer():GetBestCombo()
	self:DrawGWRelativeTextBox(
	-3
	, -0.7
	, 72
	, 20
	, 2
	, textBis
	, self.WinColor
	, self.LockedColor
	, self.TextColor
	, 0
	)
	
	local textTer = "Server : " .. GAMEMODE:GetBestStreak()
	self:DrawGWRelativeTextBox(
	3
	, -0.7
	, 72
	, 20
	, 2
	, textTer
	, self.GoldColorBack
	, self.LockedColor
	, self.TextColor
	, 0
	)
end

