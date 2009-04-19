
PANEL.Base = "DPanel"

/*---------------------------------------------------------
   Name: gamemode:Init
---------------------------------------------------------*/
function PANEL:Init()
	
	self:SetPaintBackground( false )
	
	self.ClockTexPath = "sprites/ware_clock"
	self.ClockTexID   = surface.GetTextureID( self.ClockTexPath )
	
	self.TrotterTexPath = "sprites/ware_trotter"
	self.TrotterTexID   = surface.GetTextureID( self.TrotterTexPath )
	
	//self:SetVisible( true )
	
	self.StartAngle = -15
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self:SetSize( ScrW(), ScrH() )
	self:SetPos( 0, 0 )
	
end

function PANEL:Think()
	self:InvalidateLayout()
end

function PANEL:Hide()
	self:SetVisible( false )
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Paint()	
	surface.SetTexture( self.ClockTexID )
	surface.SetDrawColor( 255,255,255,255 )
	surface.DrawTexturedRectRotated( ScrW()-24, ScrH() - 18 , 64, 64, 0 + self.StartAngle )
	
	surface.SetTexture( self.TrotterTexID )
	surface.SetDrawColor( 255,255,255,255 )
	
	surface.DrawTexturedRectRotated( ScrW()-24, ScrH() - 18 , 64, 64, 360*((GAMEMODE.GameLength*60)-(CurTime()-TimeWhenGameEnds))/(GAMEMODE.GameLength*60) + 90 + self.StartAngle )
end
