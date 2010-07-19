/*
ELEMENT.Name = "3"
ELEMENT.DefaultOff = false
ELEMENT.DefaultGridPosX = 8
ELEMENT.DefaultGridPosY = 12
ELEMENT.SizeX = 88
ELEMENT.SizeY = 44

ELEMENT.BorderColorSet = Color(255,255,255,220)
ELEMENT.BackColor   = Color(128,170,128,192)
ELEMENT.TextColor   = Color(255,255,255,255)
ELEMENT.BackColorCus   = Color(0,0,0,0)
ELEMENT.TextColorCus   = Color(0,0,0,0)
ELEMENT.BackColorSet   = ELEMENT.BackColor
ELEMENT.TextColorSet   = ELEMENT.TextColor

ELEMENT.BorderColorCalc = Color(0,0,0,0)
ELEMENT.BackColorCalc   = Color(0,0,0,0)
ELEMENT.TextColorCalc   = Color(0,0,0,0)

ELEMENT.UseCustomBG = false
ELEMENT.UseCustomFG = false

DHI_REF_InstructionElement = ELEMENT

ELEMENT.UpdateTime     = 0.0
ELEMENT.RemainDuration = 0.0


ELEMENT.Text = ""


function ELEMENT:Initialize( )
	self:CreateSmoother("width", 100, 0.7)
end

function ELEMENT:DrawFunction( )
	if (self.RemainDuration <= 0) or ((CurTime() - self.UpdateTime) > self.RemainDuration) then return end

	local baseRatioFadeOut = 1 - ((CurTime() - self.UpdateTime) / self.RemainDuration)
	
	GC_ColorCopy( self.BorderColorCalc , self.BorderColorSet )
	GC_ColorCopy( self.BackColorCalc , self.BackColorSet )
	GC_ColorCopy( self.TextColorCalc , self.TextColorSet )
	
	local borderRatioFadeOut = 1 - ((1 - baseRatioFadeOut) ^ 5)
	local backRatioFadeOut   = 1 - ((1 - baseRatioFadeOut) ^ 4)
	local textRatioFadeOut   = 1 - ((1 - baseRatioFadeOut) ^ 3)
	
	GC_ColorRatio( self.BorderColorCalc , 1, 1, 1, borderRatioFadeOut )
	GC_ColorRatio( self.BackColorCalc , 1, 1, 1, backRatioFadeOut )
	GC_ColorRatio( self.TextColorCalc , 1, 1, 1, textRatioFadeOut )
	
	local extraBorder = 4.0
	
	self.SizeX = self:GetSmootherCurrent("width")
	
	self:DrawGWTextBox(
	extraBorder
	, self.Text
	, self.BackColorCalc
	, self.BorderColorCalc
	, self.TextColorCalc
	, 2
	)
end

function DHI_ReceiveInstructions( usrmsg )
	DHI_REF_InstructionElement.UpdateTime = CurTime()
	DHI_REF_InstructionElement.RemainDuration = 5.0
	DHI_REF_InstructionElement.Text         = usrmsg:ReadString()
	DHI_REF_InstructionElement.UseCustomBG  = usrmsg:ReadBool()
	if (DHI_REF_InstructionElement.UseCustomBG) then
		DHI_REF_InstructionElement.UseCustomFG = usrmsg:ReadBool()
		
		GC_ColorReplace( DHI_REF_InstructionElement.BackColorCus , usrmsg:ReadChar() + 128, usrmsg:ReadChar() + 128, usrmsg:ReadChar() + 128, usrmsg:ReadChar() + 128)
		DHI_REF_InstructionElement.BackColorSet = DHI_REF_InstructionElement.BackColorCus
		
		if (DHI_REF_InstructionElement.UseCustomFG) then
			GC_ColorReplace( DHI_REF_InstructionElement.TextColorCus , usrmsg:ReadChar() + 128, usrmsg:ReadChar() + 128, usrmsg:ReadChar() + 128, usrmsg:ReadChar() + 128)
			DHI_REF_InstructionElement.TextColorSet = DHI_REF_InstructionElement.TextColorCus
			
		else
			DHI_REF_InstructionElement.TextColorSet = DHI_REF_InstructionElement.TextColor
			
		end
	
	else
		DHI_REF_InstructionElement.BackColorSet = DHI_REF_InstructionElement.BackColor
		DHI_REF_InstructionElement.TextColorSet = DHI_REF_InstructionElement.TextColor
	
	end
		
		
	
	
	surface.SetFont( DHI_REF_InstructionElement.Theme:GetAppropriateFont(DHI_REF_InstructionElement.Text, 2) )
	local wB, hB = surface.GetTextSize( DHI_REF_InstructionElement.Text )
	
	DHI_REF_InstructionElement:ChangeSmootherTarget("width", 44 + wB)
end
usermessage.Hook( "gw_instructions", DHI_ReceiveInstructions )
*/
