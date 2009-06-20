local SKIN = {}

function SKIN:PaintListView( panel )

	if ( panel.IsWare ) then
		surface.SetDrawColor( 50, 50, 50, 255 )
		surface.DrawRect( 0, 18, panel:GetWide(), panel:GetTall()-18 )
	end
	
end

function SKIN:PaintListViewLine( panel )
	/*local colorL
	if panel.goodness == true then
		if panel.destiny > 0 then
			colorL = Color(64,64,192,192)
		else
			colorL = Color(0,0,0,192)
		end
	else
		if panel.destiny > 0 then
			colorL = Color(192,64,64,192)
		else
			colorL = Color(0,0,0,192)
		end
	end
	surface.SetDrawColor( colorL.r, colorL.g, colorL.b, colorL.a )
	panel:DrawFilledRect()*/
	//surface.DrawRect( 0, panel:GetTall()-2, panel:GetWide(), 2 )
	if panel.goodness == false then
		if panel.destiny > 0 then
			surface.SetDrawColor(192,192,192,255)
			surface.DrawLine(0,panel:GetTall()/2,panel:GetWide(),panel:GetTall()/2)
		end
	end
end

function SKIN:SchemeListViewLabel( panel )
	panel:SetFont( "WAREScore" )
	
	if panel:GetParent().goodness == true then
		if panel:GetParent().destiny > 0 then
			colorL = Color(132,190,255,255)
		else
			colorL = Color(255,255,255,255)
		end
	else
		if panel:GetParent().destiny > 0 then
			colorL = Color(192,192,192,255)
		else
			colorL = Color(255,255,255,255)
		end
	end
	
	panel:SetColor(colorL)
end
function SKIN:SchemeListViewColumn( panel )
	panel.Header:SetFont( "WAREScore" )
	panel.Header:SetColor(Color(255,255,255,255))
end

function SKIN:PaintVScrollBar( panel )
	return false
end
function SKIN:LayoutVScrollBar( panel )
	panel:SetWide(0)
end
function SKIN:PaintScrollBarGrip( panel )
	return false
end

derma.DefineSkin( "ware", "", SKIN )