
PANEL.Base = "DPanel"

/*---------------------------------------------------------
   Name: gamemode:Init
---------------------------------------------------------*/
function PANEL:Init()

	local h = ScrH() * 0.2
	
	self:SetPaintBackground( false )

	self.BottomPanel = VGUIRect( 0, ScrH(), ScrW(), h )
	self.BottomPanel:SetColor( color_black )
	self.BottomPanel:SetParent( self )
	
	self:SetVisible( false )
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self:SetSize( ScrW(), ScrH() )
	self:SetPos( 0, 0 )
end

function PANEL:Show()

	local h = ScrH() * 0.07
	
	self.BottomPanel:SetPos( 0, ScrH() )
	self.BottomPanel:MoveTo( 0, ScrH()-h, 1 )
	
	self:InvalidateLayout()
	self:SetVisible( true )

end

function PANEL:Hide()
	local h = ScrH() * 0.07

	self.BottomPanel:MoveTo( 0, ScrH(), 1 )
	
	timer.Simple( 1, function() self:SetVisible( false ) end )
end

