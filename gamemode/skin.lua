local SKIN = {}

function SKIN:PaintListViewLine( panel )
	local colorL
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
	surface.DrawRect( 0, 0, panel:GetWide(), panel:GetTall() )
end

function SKIN:SchemeListViewLabel( panel )
	panel:SetFont( "WAREScore" )
	panel:SetColor(Color(255,255,255,255))
end
function SKIN:SchemeListViewColumn( panel )
	panel.Header:SetFont( "WAREScore" )
	panel.Header:SetColor(Color(255,255,255,255))
end

derma.DefineSkin( "ware", "", SKIN )