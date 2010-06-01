PANEL.Base = "DPanel"

function PANEL:Init()
	self:SetSkin( G_GWI_SKIN )
	self:SetPaintBackground( true )
	self:SetVisible( false )
	
	/*self.dVDiv = vgui.Create("DVerticalDivider", self)
	self.dVDiv:SetDragging( false )
	
	self.dTitle = vgui.Create("DImage", self)
	self.dTitle:SetImage("VGUI/ware/garryware_two_logo_alone")
	self.dTitle:SetKeepAspect( true )*/
	
	
	self.dWinBox = vgui.Create("DPanel", self)
	self.dWinBox:SetPaintBackground( false )
	self.dFailBox = vgui.Create("DPanel", self)
	self.dFailBox:SetPaintBackground( false )
	
	self.dWinImage = vgui.Create("DImage", self.dWinBox)
	self.dWinImage:SetImage("VGUI/ware/ui_scoreboard_winner")
	
	self.dFailImage = vgui.Create("DImage", self.dFailBox)
	self.dFailImage:SetImage("VGUI/ware/ui_scoreboard_failure")
	
	self.dWinText = vgui.Create("Label", self.dWinImage)
	self.dWinText:SetText("Winners")
	
	self.dFailText = vgui.Create("Label", self.dFailImage)
	self.dFailText:SetText("Failures")
	
	self.iLastWinFailRatio = 0.5
	self.iDrawKeep = 0.4
end

function PANEL:PerformLayout()
	local width  = ScrW() * 0.7
	local height = ScrH() * 0.5
	
	self:SetSize( width, height )
	self:SetPos( (ScrW() - width) * 0.5, 0 )
	/*
	self.dTitle:SetWide( self:GetWide() )
	self.dTitle:SetTall( self:GetTall() * 0.3 )
	self.dTitle:CenterHorizontal()
	self.dTitle:AlignTop()*/

	self.dWinBox:SetWide( self:GetWide() * 0.5 )
	self.dWinBox:SetTall( self.dWinBox:GetWide() / 512 * 64 )
	self.dWinBox:AlignLeft( )
	self.dWinBox:AlignTop( 16 )
	
	self.dFailBox:SetWide( self:GetWide() * 0.5 )
	self.dFailBox:SetTall( self.dFailBox:GetWide() / 512 * 64 )
	self.dFailBox:AlignRight()
	self.dFailBox:AlignTop( 16 )
	
	self.dWinImage:SetWide( self.dWinBox:GetWide() )
	self.dWinImage:SetTall( self.dWinBox:GetTall() )
	self.dWinImage:AlignLeft( )
	self.dWinImage:CenterVertical( )
	
	self.dFailImage:SetWide( self.dFailBox:GetWide() )
	self.dFailImage:SetTall( self.dFailBox:GetTall() )
	self.dFailImage:AlignRight( )
	self.dFailImage:CenterVertical( )
	
	self.dWinText:SizeToContents( )
	self.dWinText:AlignLeft( 16 )
	self.dWinText:CenterVertical( )
	
	self.dFailText:SizeToContents( )
	self.dFailText:AlignRight( 16 )
	self.dFailText:CenterVertical( )
	
end

function PANEL:Think()
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
		self.dWinImage:MoveTo( displacement * self.dWinImage:GetWide(), 0, 0.2, 0, 1)
		self.dFailImage:MoveTo( (1 - displacement) * -self.dFailImage:GetWide(), 0, 0.2, 0, 1)
		self.iLastWinFailRatio = iWinFailRatio
		
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