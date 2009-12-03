ELEMENT.Name = "1"
ELEMENT.DefaultOff = false
ELEMENT.DefaultGridPosX = 8
ELEMENT.DefaultGridPosY = 10
ELEMENT.SizeX = 88
ELEMENT.SizeY = 44

ELEMENT.BorderColorSet = Color(255,255,255,220)
ELEMENT.BackWinColorSet    = Color(128,128,255,192)
ELEMENT.BackLoseColorSet   = Color(255,64,64,192)
ELEMENT.BackColorSet    = ELEMENT.BackWinColorSet
ELEMENT.TextColorSet   = Color(255,255,255,255)

ELEMENT.BorderColorCalc = Color(0,0,0,0)
ELEMENT.BackColorCalc   = Color(0,0,0,0)
ELEMENT.TextColorCalc   = Color(0,0,0,0)

DHI_REF_StatusElement = ELEMENT

ELEMENT.UpdateTime     = 0.0
ELEMENT.RemainDuration = 0.0


ELEMENT.Text = ""


function ELEMENT:Initialize( )
	self:CreateSmoother("width", 100, 0.7)
end

function ELEMENT:DrawFunction( )
	if (self.RemainDuration <= 0) or ((RealTime() - self.UpdateTime) > self.RemainDuration) then return end

	local baseRatioFadeOut = 1 - ((RealTime() - self.UpdateTime) / self.RemainDuration)
	
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

DHI_WinParticles = {
	{"effects/yellowflare",35,2,ScrW()*0,ScrH(),20,20,50,70,-45,-60,60,64,256,Color(128,255,128,255),Color(0,255,0,0),5,1},
	{"effects/yellowflare",5,2,ScrW()*0,ScrH(),10,10,20,30,-45,-60,60,256,512,Color(255,255,255,255),Color(255,255,255,0),10,1},
	{"gui/silkicons/check_on.vmt",5,2,ScrW()*0,ScrH(),16,16,32,32,-45,-60,60,64,128,Color(255,255,255,255),Color(255,255,255,0),0,0.2}
}
DHI_FailParticles = {
	{"effects/yellowflare",35,2,ScrW()*0,ScrH(),20,20,50,70,-45,-60,60,64,256,Color(128,255,128,255),Color(0,255,0,0),5,1},
	{"effects/yellowflare",35,2,ScrW()*0,ScrH(),20,20,50,70,-45,-60,60,64,256,Color(255,128,128,255),Color(255,0,0,0),5,1},
	{"gui/silkicons/check_off.vmt",5,2,ScrW()*0,ScrH(),16,16,32,32,-45,-60,60,64,128,Color(255,255,255,255),Color(255,255,255,0),0,0.2}
}

function DHI_MakeParticlesFromTable( myTablePtr )
	for k,particle in pairs(myTablePtr) do
		GAMEMODE:OnScreenParticlesMake(particle)
	end
end

function DHI_ReceiveStatuses( usrmsg )
	DHI_REF_StatusElement.UpdateTime = RealTime()
	DHI_REF_StatusElement.RemainDuration = 3.0
	local yourStatus = usrmsg:ReadBool() or false
	local isServerGlobal = usrmsg:ReadBool() or false
	if not(isServerGlobal) then
		DHI_REF_StatusElement.Text = ((yourStatus and "Success !") or "Fail !")
		if yourStatus then
			LocalPlayer():EmitSound( table.Random(GAMEMODE.WASND.TBL_LocalWon) )
		
			DHI_MakeParticlesFromTable( DHI_WinParticles )
			
		else
			LocalPlayer():EmitSound( table.Random(GAMEMODE.WASND.TBL_LocalLose) )
		
			DHI_MakeParticlesFromTable( DHI_FailParticles )
			
		end
		
	else
		DHI_REF_StatusElement.Text = ((yourStatus and "Everyone won !") or "Everyone failed !")
	end
	DHI_REF_StatusElement.BackColorSet = (yourStatus and DHI_REF_StatusElement.BackWinColorSet) or DHI_REF_StatusElement.BackLoseColorSet
	
	surface.SetFont( DHI_REF_StatusElement.Theme:GetAppropriateFont(DHI_REF_StatusElement.Text, 2) )
	local wB, hB = surface.GetTextSize( DHI_REF_StatusElement.Text )
	
	DHI_REF_StatusElement:ChangeSmootherTarget("width", 44 + wB)
end
usermessage.Hook( "gw_yourstatus", DHI_ReceiveStatuses )

