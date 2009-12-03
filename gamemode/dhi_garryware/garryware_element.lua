function ELEMENT:DrawGWTextBox(extraBorder, text, backColor, borderColor, textColor, mainFontChoice)
	local xRel, yRel, width, height = self:ConvertGridData()
	
	self.Theme:DrawGWTextBox(xRel, yRel, width, height, extraBorder, text, backColor, borderColor, textColor, mainFontChoice)
end

function ELEMENT:DrawGWDoubleSidedBox(border, textLeft, textRight, backLeftColor, backRightColor, borderColor, textLeftColor, textRightColor, mainFontChoice)
	local xRel, yRel, width, height = self:ConvertGridData()

	self.Theme:DrawGWDoubleSidedBox(xRel, yRel, width, height, border, textLeft, textRight, backLeftColor, backRightColor, borderColor, textLeftColor, textRightColor, mainFontChoice)
end

function ELEMENT:DrawGWRelativeTextBox(xRelOffset, yRelOffset, boxWidth, boxHeight, extraBorder, text, backColor, borderColor, textColor, mainFontChoice)
	local xRel, yRel, width, height = self:ConvertGridData()
	
	self.Theme:DrawGWRelativeTextBox(xRel, yRel, width, height, xRelOffset, yRelOffset, boxWidth, boxHeight, extraBorder, text, backColor, borderColor, textColor, mainFontChoice)
end


function ELEMENT:DrawGWPreProgrammedRidiculousBox(iFromFirst, ply, textColor, winColor, failColor, mysteryColor, goldColor, goldColorBrighter, neutralColor, confirmedColor)
	local xRel, yRel, width, height = self:ConvertGridData()

	self.Theme:DrawGWPreProgrammedRidiculousBox(xRel, yRel, width, height, iFromFirst, ply, textColor, winColor, failColor, mysteryColor, goldColor, goldColorBrighter, neutralColor, confirmedColor)
end