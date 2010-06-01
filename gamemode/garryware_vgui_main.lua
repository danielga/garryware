PANEL.Base = "DPanel"

function PANEL:Init()
	self:SetSkin( G_GWI_SKIN )
	self:SetPaintBackground( true )
	self:SetVisible( false )
	
	surface.CreateFont("Trebuchet MS", 36, 0   , 0, false, "dhigwfont_num_nb" )
	surface.CreateFont("Trebuchet MS", 26, 0   , 0, false, "dhigwfont_nummedium_nb" )
	surface.CreateFont("Trebuchet MS", 20, 0   , 0, false, "dhigwfont_numsmall_nb" )
	surface.CreateFont("Trebuchet MS", 36, 0   , 0, false, "dhigwfont_textlarge_nb" )
	surface.CreateFont("Trebuchet MS", 24, 0   , 0, false, "dhigwfont_textmedium_nb" )
	surface.CreateFont("Trebuchet MS", 16, 400 , 0, false, "dhigwfont_textsmall_nb" )
	surface.CreateFont("Trebuchet MS", 24, 400 , 0, false, "dhigwfont_textmediumbold_nb" )
	
	/*self.dVDiv = vgui.Create("DVerticalDivider", self)
	self.dVDiv:SetDragging( false )
	
	self.dTitle = vgui.Create("DImage", self)
	self.dTitle:SetImage("VGUI/ware/garryware_two_logo_alone")
	self.dTitle:SetKeepAspect( true )*/
	
	self.dCentric = vgui.Create("DPanel", self)
	self.dCentric:SetPaintBackground( false )
	self.dCentric:SetZPos( 9001 )
	self.dCentricWin = vgui.Create("DImage", self.dCentric)
	self.dCentricWin:SetImage("VGUI/ware/ui_scoreboard_winarrow")
	self.dCentricFail = vgui.Create("DImage", self.dCentric)
	self.dCentricFail:SetImage("VGUI/ware/ui_scoreboard_failarrow")
	self.dCentricText = vgui.Create("DLabel", self.dCentric)
	self.dCentricText:SetText("x")
	self.dCentricText:SetFont( "dhigwfont_num_nb" )
	self.dCentricText:SetColor( color_white )
	
	self.dWinBox = vgui.Create("DPanel", self)
	self.dWinBox:SetPaintBackground( false )
	self.dWinImage = vgui.Create("DImage", self.dWinBox)
	self.dWinImage:SetImage("VGUI/ware/ui_scoreboard_winner")
	self.dWinText = vgui.Create("DLabel", self.dWinImage)
	self.dWinText:SetText("Winners")
	self.dWinText:SetFont( "dhigwfont_textmedium_nb" )
	self.dWinText:SetColor( color_white )
	
	self.dFailBox = vgui.Create("DPanel", self)
	self.dFailBox:SetPaintBackground( false )
	self.dFailImage = vgui.Create("DImage", self.dFailBox)
	self.dFailImage:SetImage("VGUI/ware/ui_scoreboard_failure")
	self.dFailText = vgui.Create("DLabel", self.dFailImage)
	self.dFailText:SetText("Failures")
	self.dFailText:SetFont( "dhigwfont_textmedium_nb" )
	self.dFailText:SetColor( color_white )
	
	self.iLastWinFailRatio = 0.5
	self.iDrawKeep = 0.4
	
	self.bLastIsWin = false
	self.bLastIsLocked = false
end

function PANEL:PerformLayout()
	local width  = ScrW() * 0.7
	local height = (width * 0.5) / 512 * 64
	
	self:SetSize( width, height )
	self:SetPos( (ScrW() - width) * 0.5, ScrH() * 0.02 )

	--NOTE : CONVERT THE CENTRIC TO ITS OWN PANEL!
	self.dCentric:SetWide( self:GetWide() * 0.5 * 0.25 )
	self.dCentric:SetTall( self:GetTall() )
	self.dCentric:CenterHorizontal( )
	self.dCentric:CenterVertical( )
	self.dCentricWin:SetWide( self.dCentric:GetWide() )
	self.dCentricWin:SetTall( self.dCentric:GetTall() )
	self.dCentricFail:SetWide( self.dCentric:GetWide() )
	self.dCentricFail:SetTall( self.dCentric:GetTall() )
	self.dCentricText:SizeToContents( )
	self.dCentricText:CenterHorizontal( )
	self.dCentricText:CenterVertical( )
	
	
	self.dWinBox:SetWide( self:GetWide() * 0.5 )
	self.dWinBox:SetTall( self:GetTall() )
	self.dWinBox:AlignLeft( )
	self.dWinBox:CenterVertical( )
	self.dWinImage:SetWide( self.dWinBox:GetWide() )
	self.dWinImage:SetTall( self.dWinBox:GetTall() )
	self.dWinImage:AlignLeft( )
	self.dWinImage:CenterVertical( )
	self.dWinText:SizeToContents( )
	self.dWinText:AlignLeft( 16 )
	self.dWinText:CenterVertical( )
	
	self.dFailBox:SetWide( self:GetWide() * 0.5 )
	self.dFailBox:SetTall( self:GetTall() )
	self.dFailBox:AlignRight()
	self.dFailBox:CenterVertical( )
	self.dFailImage:SetWide( self.dFailBox:GetWide() )
	self.dFailImage:SetTall( self.dFailBox:GetTall() )
	self.dFailImage:AlignRight( )
	self.dFailImage:CenterVertical( )
	self.dFailText:SizeToContents( )
	self.dFailText:AlignRight( 16 )
	self.dFailText:CenterVertical( )
	
end

function PANEL:Think()
	if not ValidEntity( LocalPlayer() ) or not LocalPlayer().GetAchieved then return end
	
	do --ScoreboardTopShift
		local tCount = team.GetPlayers( TEAM_HUMANS )
		local iCount = 0
		for k,ply in pairs( team.GetPlayers( TEAM_HUMANS ) ) do
			if not ply:GetAchieved() then
				iCount = iCount + 1
			end
		end
		local iWinFailRatio = iCount / #tCount
		
		if iWinFailRatio ~= self.iLastWinFailRatio then
			local displacement = (0.5 - self.iDrawKeep * 0.5) + iWinFailRatio * self.iDrawKeep
			self.dWinImage:MoveTo( displacement * self.dWinImage:GetWide(), 0, 0.3, 0, 2)
			self.dFailImage:MoveTo( (1 - displacement) * -self.dFailImage:GetWide(), 0, 0.3, 0, 2)
			self.iLastWinFailRatio = iWinFailRatio
			
		end
	end
	
	do --Centric
		local bIsWin = LocalPlayer():GetAchieved()
		if bIsWin ~= self.bLastIsWin then
			if bIsWin then
				self.dCentricWin:SetVisible( true )
				self.dCentricFail:SetVisible( false )
				
			else
				self.dCentricFail:SetVisible( true )
				self.dCentricWin:SetVisible( false )
			
			end
			self.bLastIsWin = bIsWin
			
		end
		
		self.dCentricText:SetText( LocalPlayer():GetCombo() )
		
	end
	
end

function PANEL:Show()
	if self:IsVisible() then return end
	
	self:SetVisible( true )

end

function PANEL:Hide()
	if not self:IsVisible() then return end
	
	self:SetVisible( false )

end

--function PANEL:Paint()
--	print(" whoops shit" )
--end

Derma_Hook( PANEL, "Paint", "Paint", "GWMain" )