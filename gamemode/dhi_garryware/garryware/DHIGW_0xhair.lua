/*
ELEMENT.Name = "0"
ELEMENT.DefaultOff = false
ELEMENT.DefaultGridPosX = 8
ELEMENT.DefaultGridPosY = 8
ELEMENT.SizeX = 88
ELEMENT.SizeY = 44

ELEMENT.cBaseSize = 8
ELEMENT.minRate = 1.3
ELEMENT.maxRate = 1.0

function ELEMENT:BiltRectangle( screenx, screeny, width, height, oR, oG, oB, oA)
	surface.SetDrawColor( oR or 255, oG or 220, oB or 0, oA or 255 )
	surface.DrawRect(screenx - width/2, screeny - height/2 , width, height  )
end

function ELEMENT:BiltCrosshair( screenx, screeny, length, thick , oR, oG, oB, oA)
	self:BiltRectangle( screenx, screeny, length, thick , oR, oG, oB, oA)
	if (length ~= thick) then
		self:BiltRectangle( screenx, screeny, thick, length , oR, oG, oB, oA)
	end
end

function ELEMENT:Initialize( )
	self:CreateSmoother("chsize", self.cBaseSize, 0.1)
	self:CreateSmoother("chx", 0.5*ScrW(), 0.5)
	self:CreateSmoother("chy", 0.5*ScrH(), 0.5)
end

function ELEMENT:DrawFunction( )
	if LocalPlayer():InVehicle() then return false end

	self.traceLineData = utilx.GetPlayerTrace( LocalPlayer(), LocalPlayer():GetCursorAimVector() )
	self.traceLineRes = util.TraceLine( self.traceLineData )
	
	local scrpos = self.traceLineRes.HitPos:ToScreen()
	self:ChangeSmootherTarget("chx", scrpos.x)
	self:ChangeSmootherTarget("chy", scrpos.y)
	local scrpos_smoothx = self:GetSmootherCurrent("chx")
	local scrpos_smoothy = self:GetSmootherCurrent("chy")
	
	local distdet = 1 - self.traceLineRes.Fraction
	local size_real = (self.cBaseSize * self.maxRate * distdet) + (self.cBaseSize * self.minRate * (1-distdet))
	self:ChangeSmootherTarget("chsize", size_real)
	
	local size_smooth = math.floor(self:GetSmootherCurrent("chsize"))
	
	self:BiltRectangle(ScrW()*0.5 - size_smooth * 2, ScrH()*0.5, size_smooth, 2)
	self:BiltRectangle(ScrW()*0.5 + size_smooth * 2, ScrH()*0.5, size_smooth, 2)
	self:BiltCrosshair(scrpos_smoothx, scrpos_smoothy, self.cBaseSize, 2)
	
	return true
end
*/
