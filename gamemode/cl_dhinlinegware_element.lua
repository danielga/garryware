////////////////////////////////////////////////
// -- Depth HUD : Inline                        //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// The Element Module, to register easily     //
////////////////////////////////////////////////

module( "dhinlinegware", package.seeall )

local Elements = {}
local Elements_names = {}



local ELEMENT = {}

function ELEMENT:GetMyGridPos()
	return self.DefaultGridPosX, self.DefaultGridPosY
end

function ELEMENT:GetMySizes()
	local xGeneric, yGeneric = dhinlinegware_GetGenericBoxSizes()
	local xSize, ySize = self.SizeX, self.SizeY
	if ySize then
		if (ySize < 0) then
			ySize = yGeneric * (-ySize)
		elseif (xSize == 0) then
			ySize = yGeneric
		end
	else
		ySize = yGeneric
	end
	if xSize then
		if (xSize < 0) then
			xSize = xGeneric * (-xSize)
		elseif (xSize == 0) then
			xSize = ySize or yGeneric
		end
	else
		xSize = xGeneric
	end
	if xSize < ySize then
		xSize = ySize
	end
	
	
	return xSize, ySize
end

function ELEMENT:GetMySmootherFullName( stringSuffix )
	return self._rawname .. "_" .. stringSuffix
end

function ELEMENT:CreateSmoother(stringSuffix, numInit, numRate)
	dhinlinegware_CreateSmoother( self:GetMySmootherFullName( stringSuffix ), numInit, numRate)
end

function ELEMENT:ChangeSmootherTarget(stringSuffix, numTarget)
	dhinlinegware_ChangeSmootherTarget( self:GetMySmootherFullName( stringSuffix ), numTarget )
end

function ELEMENT:ChangeSmootherRate(stringSuffix, numRate)
	dhinlinegware_ChangeSmootherRate( self:GetMySmootherFullName( stringSuffix ), numRate )
end

function ELEMENT:GetSmootherCurrent(stringSuffix)
	return dhinlinegware_GetSmootherCurrent( self:GetMySmootherFullName( stringSuffix ) )
end




function ELEMENT:DrawGWTextBox(extraBorder, text, backColor, borderColor, textColor, mainFontChoice)
	local xGrid, yGrid = self:GetMyGridPos()
	local xRel , yRel  = dhinlinegware_GetRelPosFromGrid( xGrid, yGrid )
	
	local width, height = self:GetMySizes()
	
	dhinline_DrawGWTextBox(xRel, yRel, width, height, extraBorder, text, backColor, borderColor, textColor, mainFontChoice)
end

function ELEMENT:DrawGWDoubleSidedBox(border, textLeft, textRight, backLeftColor, backRightColor, borderColor, textLeftColor, textRightColor, mainFontChoice)
	local xGrid, yGrid = self:GetMyGridPos()
	local xRel , yRel  = dhinlinegware_GetRelPosFromGrid( xGrid, yGrid )
	
	local width, height = self:GetMySizes()

	dhinline_DrawGWDoubleSidedBox(xRel, yRel, width, height, border, textLeft, textRight, backLeftColor, backRightColor, borderColor, textLeftColor, textRightColor, mainFontChoice)
end

function ELEMENT:DrawGWRelativeTextBox(xRelOffset, yRelOffset, boxWidth, boxHeight, extraBorder, text, backColor, borderColor, textColor, mainFontChoice)
	local xGrid, yGrid = self:GetMyGridPos()
	local xRel , yRel  = dhinlinegware_GetRelPosFromGrid( xGrid, yGrid )
	
	local width, height = self:GetMySizes()
	
	dhinline_DrawGWRelativeTextBox(xRel, yRel, width, height, xRelOffset, yRelOffset, boxWidth, boxHeight, extraBorder, text, backColor, borderColor, textColor, mainFontChoice)
end


function ELEMENT:DrawGWPreProgrammedRidiculousBox(iFromFirst, ply, textColor, winColor, failColor, mysteryColor, goldColor, goldColorBrighter, neutralColor, confirmedColor)
	local xGrid, yGrid = self:GetMyGridPos()
	local xRel , yRel  = dhinlinegware_GetRelPosFromGrid( xGrid, yGrid )
	
	local width, height = self:GetMySizes()

	dhinline_DrawGWPreProgrammedRidiculousBox(xRel, yRel, width, height, iFromFirst, ply, textColor, winColor, failColor, mysteryColor, goldColor, goldColorBrighter, neutralColor, confirmedColor)
end





function ELEMENT:DrawGenericInfobox(text, smallText, rate, boxIsAtRight, falseColor, trueColor, minSize, maxSize, blinkBelowRate, blinkSize, mainFontChoice, useStaticTextColor, opt_textColor, opt_smallTextColor)

	local xGrid, yGrid = self:GetMyGridPos()
	local xRel , yRel  = dhinlinegware_GetRelPosFromGrid( xGrid, yGrid )
	
	local width, height = self:GetMySizes()
	
	dhinlinegware_DrawGenericInfobox(xRel, yRel, width, height, text, smallText, rate, boxIsAtRight, falseColor, trueColor, minSize, maxSize, blinkBelowRate, blinkSize, mainFontChoice, useStaticTextColor, opt_textColor, opt_smallTextColor)
end


function ELEMENT:DrawGenericContentbox(text, smallText, textColor, textColorSmall, fontChoice)

	local xGrid, yGrid = self:GetMyGridPos()
	local xRel, yRel  = dhinlinegware_GetRelPosFromGrid( xGrid, yGrid )
	
	local width, height = self:GetMySizes()
	
	dhinlinegware_DrawGenericContentbox(xRel, yRel, width, height, text, smallText, textColor, textColorSmall, fontChoice)
end

function ELEMENT:DrawGenericText(text, smallText, textColor, textColorSmall, fontChoice, lagMultiplier, insideBoxXEquirel, insideBoxYEquirel)
	local xGrid, yGrid = self:GetMyGridPos()
	local xRel, yRel  = dhinlinegware_GetRelPosFromGrid( xGrid, yGrid )
	
	local width, height = self:GetMySizes()
	
	dhinlinegware_DrawGenericText(xRel, yRel, width, height, text, smallText, textColor, textColorSmall, fontChoice, lagMultiplier, insideBoxXEquirel, insideBoxYEquirel)
end

function ELEMENT:UpdateVolatile(name, xRelOffset, yRelOffset, text, textColor, lagMultiplier, fontChoice, duration, fadePower, storage)
	local xGrid, yGrid = self:GetMyGridPos()
	local xRel , yRel  = dhinlinegware_GetRelPosFromGrid( xGrid, yGrid )
	
	local width, height = self:GetMySizes()
	
	dhinlinegware_UpdateVolatile(name, xRel, yRel, width, height, xRelOffset, yRelOffset, text, textColor, lagMultiplier, fontChoice, duration, fadePower, storage)
end



local element_meta = {__index=ELEMENT}

function Register(name, element)
	if string.find( name , " " ) then return end
	
	element._rawname = name
	element.Name = element.Name or name
	setmetatable(element, element_meta)
	
	Elements[name] = element
	table.insert(Elements_names, name)
	
	/*
	element.DefaultGridPosX = element.DefaultGridPosX or 0
	element.DefaultGridPosY = element.DefaultGridPosY or 0
	element.DefaultOff      = element.DefaultOff or false
	*/
	
	dhinlinegware_CreateStyleVar("dhinlinegware_element_" .. name, ( not (dhinlinegware.Get(name).DefaultOff or false ) ) and "1" or "0", true, false)
	dhinlinegware_CreateStyleVar("dhinlinegware_element_" .. name .. "_x", element.DefaultGridPosX or 0, true, false)
	dhinlinegware_CreateStyleVar("dhinlinegware_element_" .. name .. "_y", element.DefaultGridPosY or 0, true, false)
end

function RemoveAll()
	Elements = {}
	Elements_names = {}
	
	dhinlinegware_DeleteAllSmoothers()
	dhinlinegware_DeleteAllVolatiles()
end

function Get(name)
	if Elements[name] == nil then return nil end
	return Elements[name] or nil
end

function GetNamesTable()
	return table.Copy(Elements_names)
end

function GetConVarTable()
	local ConVars = {}
	for k,name in pairs(Elements_names) do
		table.insert(ConVars, "dhinlinegware_element_" .. name)
		table.insert(ConVars, "dhinlinegware_element_" .. name .. "_x")
		table.insert(ConVars, "dhinlinegware_element_" .. name .. "_y")
	end
	return ConVars
end

function GetAllDefaultsTable()
	local Defaults = {}
	for k,name in pairs(Elements_names) do
		Defaults["dhinlinegware_element_" .. name]         = ( not (dhinlinegware.Get(name).DefaultOff or false ) ) and "1" or "0"
		Defaults["dhinlinegware_element_" .. name .. "_x"] = dhinlinegware.Get(name).DefaultGridPosX
		Defaults["dhinlinegware_element_" .. name .. "_y"] = dhinlinegware.Get(name).DefaultGridPosY
	end
	return Defaults
end
