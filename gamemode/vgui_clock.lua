
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
	
	self.StartAngle = 15
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
	local achieved = 0
	local hasdestiny = 0
	if LocalPlayer():IsValid() then
		achieved = LocalPlayer():GetNWInt("ware_achieved",0)
		hasdestiny = LocalPlayer():GetNWInt("ware_hasdestiny",0)
	end
	
	surface.SetTexture( self.ClockTexID )
	if (CurTime() < NextgameStart) then
		surface.SetDrawColor( 255,255,255,255 )
	elseif (CurTime() < NextwarmupEnd) then
		surface.SetDrawColor( 255,245,165,255 )
	elseif (achieved > 0 && hasdestiny == 0) then
		surface.SetDrawColor( 215,225,250,255 )
	elseif (achieved > 0 && hasdestiny == 1) then
		surface.SetDrawColor( 166,195,250,255 )
	elseif (achieved <= 0 && hasdestiny == 0) then
		surface.SetDrawColor( 250,215,215,255 )
	elseif (achieved <= 0 && hasdestiny == 1) then
		surface.SetDrawColor( 250,165,165,255 )
	else
		surface.SetDrawColor( 0,255,0,255 )
	end
	surface.DrawTexturedRectRotated( ScrW()*0.05, ScrH() - ScrH()*0.05 , 256, 256, 0 + self.StartAngle )
	
	surface.SetTexture( self.TrotterTexID )
	surface.SetDrawColor( 255,255,255,255 )
	
	if (CurTime() < NextgameStart) then
		surface.DrawTexturedRectRotated( ScrW()*0.05, ScrH() - ScrH()*0.05 , 256, 256, 360*(60-(CurTime()-NextgameStart))/60 + 90 + self.StartAngle )
	elseif (CurTime() < NextwarmupEnd) then
		surface.DrawTexturedRectRotated( ScrW()*0.05, ScrH() - ScrH()*0.05 , 256, 256, 360*(WarmupLen-(CurTime()-NextwarmupEnd))/WarmupLen + 90 + self.StartAngle )
	elseif (CurTime() < NextgameEnd) then
		surface.DrawTexturedRectRotated( ScrW()*0.05, ScrH() - ScrH()*0.05 , 256, 256, 360*(GameLen-(CurTime()-NextgameEnd))/GameLen + 90 + self.StartAngle )
	else
		surface.DrawTexturedRectRotated( ScrW()*0.05, ScrH() - ScrH()*0.05 , 256, 256, 360*0 + 90 + self.StartAngle )
	end
end
