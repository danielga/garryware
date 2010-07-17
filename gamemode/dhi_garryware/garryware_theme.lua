THEME.Name = "GarryWare Theme"


THEME.GenericBoxHeight = ScrH()
THEME.GenericBoxWidth  = ScrW()

THEME.GlowTexture       = surface.GetTextureID("sprites/light_glow02_add")

THEME.BaseColor = Color(0,0,0,0)
THEME.BackColor = Color(0,0,0,0)
THEME.ErrorColor = Color(0,0,0,0)

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

function THEME:GetColorReference( sColorLitteral )
	if     sColorLitteral == "basecolor" then return self.BaseColor
	elseif sColorLitteral == "backcolor" then return self.BackColor
	elseif sColorLitteral == "badcolor" then return self.BadColor end
	
	print(">-- Classic Theme ERROR : Requested color ".. sColorLitteral .. " that doesn't exist!")
	
	return self.ErrorColor
end

function THEME:Load()

	self:AddParameter("basecolor", { Type = "color", Defaults = {"255","255","128","255"} } )
	self:AddParameter("backcolor", { Type = "color", Defaults = {"255","255","128","255"} } )
	
	dhonline.PrimeColorFromTable( self.BaseColor, self:GetParameterSettings("basecolor") )
	dhonline.PrimeColorFromTable( self.BackColor, self:GetParameterSettings("backcolor") )
	
	dhonline.SetVar("dhonline_core_ui_spacing", 0.3)

	surface.CreateFont("Trebuchet MS", 24, 0   , 0, false, "garryware_mediumtext" )
	
end

function THEME:Unload()
end

function THEME:GetAppropriateFont(text, desiredChoice)
	local font = ""
	desiredChoice = desiredChoice or 2
	if (desiredChoice == -1) then
		if type(text) == "number" then
			font = "dhigwfont_nummedium"
		else
			font = "dhigwfont_textmediumbold"
		end
	elseif (desiredChoice >= 2) then
		if type(text) == "number" then
			font = "dhigwfont_num"
		else
			font = "dhigwfont_textlarge"
		end

	elseif (desiredChoice == 1) then 
		if type(text) == "number" then
			font = "dhigwfont_nummedium"
		else
			font = "dhigwfont_textmedium"
		end
	else
		if type(text) == "number" then
			font = "dhigwfont_numsmall"
		else
			font = "dhigwfont_textsmall"
		end
	end
	return font .. "_nb"
end

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

function THEME:Draw_RAW_GetAppropriateBoxRound( myRound )
	local boxRound = 0
	local boxBigSizeCalc = (myRound/44)
	if boxBigSizeCalc <= 0.75 and boxBigSizeCalc > 0.5 then
		boxRound = 6
	elseif boxBigSizeCalc <= 0.5 and boxBigSizeCalc > 0.25 then
		boxRound = 4
	elseif boxBigSizeCalc <= 0.25 then
		boxRound = 0
	else
		boxRound = 8
	end
	
	return boxRound
end

function THEME:Draw_RAW_GWBox(xAbs, yAbs, width, height, extraBorder, backColor, borderColor)

	backColor = backColor or self:GetColorReference("backcolor")
	borderColor = borderColor or self:GetColorReference("basecolor")
	
	local widthBR, heightBR = width, height
	
	extraBorder = math.floor(extraBorder or 0)
	
	width  = width  - extraBorder*2
	height = height - extraBorder*2
	
	local minBoxCalc = 0
	minBoxCalc = math.min(widthBR, heightBR)
	local extBR = self:Draw_RAW_GetAppropriateBoxRound( minBoxCalc )
	
	minBoxCalc = math.min(width, height)
	local inBR = self:Draw_RAW_GetAppropriateBoxRound( minBoxCalc )
	
	draw.RoundedBox(extBR, xAbs - widthBR*0.5, yAbs - heightBR*0.5, widthBR, heightBR, borderColor)
	draw.RoundedBox(extBR, xAbs - width*0.5, yAbs - height*0.5, width, height, backColor)

end

function THEME:Draw_RAW_GWText(xAbs, yAbs, text, textColor, mainFontChoice, optHalign, optValign)
	if (text == nil) or (text == "") then return end

	textColor = textColor or self:GetColorReference("basecolor")

	local font = self:GetAppropriateFont(text, mainFontChoice)
	
	draw.SimpleText(text, font, xAbs, yAbs, textColor, optHalign or 1, optValign or 1 )
end

function THEME:DrawGWTextBox(xRel, yRel, width, height, extraBorder, text, backColor, borderColor, textColor, mainFontChoice)
	local xCenter,yCenter = dhonline.CalcCenter( xRel , yRel , width , height )
	
	self:Draw_RAW_GWBox(xCenter, yCenter, width, height, extraBorder, backColor, borderColor)
	self:Draw_RAW_GWText(xCenter, yCenter, text, textColor, mainFontChoice)
end

function THEME:DrawGWRelativeTextBox(xRel, yRel, width, height, xRelOffset, yRelOffset, boxWidth, boxHeight, extraBorder, text, backColor, borderColor, textColor, mainFontChoice)
	local xCenter,yCenter = dhonline.CalcCenter( xRel , yRel , width , height )
	
	local xCenterNew,yCenterNew = xCenter + width * xRelOffset * 0.5, yCenter + height * yRelOffset * 0.5
	
	self:Draw_RAW_GWBox(xCenterNew, yCenterNew, boxWidth, boxHeight, extraBorder, backColor, borderColor)
	self:Draw_RAW_GWText(xCenterNew, yCenterNew, text, textColor, mainFontChoice)
end

function THEME:DrawGWDoubleSidedBox(xRel, yRel, width, height, border, textLeft, textRight, backLeftColor, backRightColor, borderColor, textLeftColor, textRightColor, mainFontChoice)
	local xCenter,yCenter = dhonline.CalcCenter( xRel , yRel , width , height )
	
	local minBoxCalc = 0
	local widthBR, heightBR = width, height
	
	width  = width  - border*2
	height = height - border*2
	minBoxCalc = math.min(width, height)
	minBoxCalc = math.min(widthBR, heightBR)
	
	local extBR = self:Draw_RAW_GetAppropriateBoxRound( minBoxCalc )
	local inBR = self:Draw_RAW_GetAppropriateBoxRound( minBoxCalc )
	
	draw.RoundedBox(extBR, xCenter - widthBR*0.5, yCenter - heightBR*0.5, widthBR, heightBR, borderColor)
	
	draw.RoundedBox(extBR, xCenter - widthBR*0.5 + border, yCenter - heightBR*0.5 + border, width*0.5, height, backLeftColor)
	draw.RoundedBox(extBR, xCenter + border*0.5, yCenter - heightBR*0.5 + border, width*0.5, height, backRightColor)

	self:Draw_RAW_GWText(xCenter - widthBR*0.25, yCenter, textLeft, textLeftColor, mainFontChoice)
	self:Draw_RAW_GWText(xCenter + widthBR*0.25, yCenter, textRight, textRightColor, mainFontChoice)
end

function THEME:DrawGWPreProgrammedRidiculousBox(xRel, yRel, width, height, iFromFirst, ply, textColor, winColor, failColor, mysteryColor, goldColor, goldColorBrighter, neutralColor, confirmedColor)

	if (not ValidEntity(ply) or not ply:IsPlayer()) then return end

	local xCenter, yCenter = dhonline.CalcCenter( xRel , yRel , width , height )
	local yCenterNew = yCenter + 30 + (height * 1.05) * (iFromFirst - 1) -- 30 is the magic number for the Ridiculous title height
	local xTextCenter = xCenter - width * 0.50 + 8
	
	local statusColor = nil
	local borderColor = nil
	
	local text = ply:GetName()
	
	if (ply:GetAchieved() == nil) then
		statusColor = mysteryColor
	elseif (ply:GetAchieved()) then
		statusColor = winColor
	else
		statusColor = failColor
	end
	
	local extraBorder = 2.0
	if ply:GetLocked() then
		extraBorder = 4.0
		borderColor = confirmedColor
	else
		extraBorder = 3.0 + math.sin( math.rad(RealTime()*360) ) * 2.0
		borderColor = neutralColor
	end
	
	self:Draw_RAW_GWBox(xCenter, yCenterNew, width, height, extraBorder, statusColor, borderColor)
	self:Draw_RAW_GWText(xTextCenter, yCenterNew, text, textColor, 0, 0)
	
	-- Scores
	local boxSideLen = height * 1.0
	
	if true then
		local xCenterBox = xCenter + width * (0.5) - boxSideLen * 0.5 - 4
		local borderSize = 2.0
		
		self:Draw_RAW_GWBox(xCenterBox, yCenterNew, boxSideLen, boxSideLen, borderSize, failColor, confirmedColor)
		self:Draw_RAW_GWText(xCenterBox, yCenterNew, ply:Deaths(), textColor, 0)
	end
	
	if true then
		local xCenterBox = xCenter + width * (0.5) - boxSideLen * (0.5 + 1) - 4
		local borderSize = 2.0
		
		self:Draw_RAW_GWBox(xCenterBox, yCenterNew, boxSideLen, boxSideLen, borderSize, winColor, confirmedColor)
		self:Draw_RAW_GWText(xCenterBox, yCenterNew, ply:Frags(), textColor, 0)
	end
	
	if true then
		local xCenterBox = xCenter + width * (0.5) - boxSideLen * (0.5 + 2) - 8
		local borderSize = 2.0
		local combo        = ply:GetCombo()
		local bestCombo    = ply:GetBestCombo()
		local serverStreak = GAMEMODE:GetBestStreak()
		local extraGoldRatio = ((RealTime() * 2.0) % 1)
		
		if (bestCombo == serverStreak) or ((combo >= 3) and (combo == bestCombo)) then
			local plusBorderSize = 2.0
			if (combo == bestCombo) then
				plusBorderSize = plusBorderSize + extraGoldRatio * 4.0
			end
			if (bestCombo == serverStreak) then
				plusBorderSize = plusBorderSize + 2.0
			end
			self:Draw_RAW_GWBox(xCenterBox, yCenterNew, boxSideLen + plusBorderSize, boxSideLen + plusBorderSize, 0.0, goldColorBrighter, nil)
		end
		
		self:Draw_RAW_GWBox(xCenterBox, yCenterNew, boxSideLen, boxSideLen, 2.0, goldColor, confirmedColor)
		self:Draw_RAW_GWText(xCenterBox, yCenterNew, ply:GetBestCombo(), textColor, 0)
	end
	
	
end

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

function THEME:Think( )
end

function THEME:PaintMisc( )
end
