////////////////////////////////////////////////
// -- Depth HUD : Inline                      //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// The Element Module, to register easily     //
////////////////////////////////////////////////

module( "dhonline_element", package.seeall )

local ELEMENT = {}
//ELEMENT.Theme = dhonline_theme.GetThemeObject(ELEMENT._mytheme)

function ELEMENT:GetRawName( name )
	return self._rawname
end

function ELEMENT:GetDisplayName( name )
	return self.Name
end

function ELEMENT:GetMyGridPos()
	local sCvarPrefix = "dhonline_element_" .. self.Theme:GetRawName() .. "_" .. self:GetRawName()
	return dhonline.GetVar(sCvarPrefix .. "_x"), dhonline.GetVar(sCvarPrefix .. "_y")
end

function ELEMENT:GetMySizes()
	local xGeneric, yGeneric = self.Theme:GetGenericBoxSizes()
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
	/*if xSize < ySize then
		xSize = ySize
	end*/
	
	
	return xSize, ySize
end

function ELEMENT:GetMySmootherFullName( sSuffix )
	return self:GetRawName() .. "_" .. sSuffix
end

function ELEMENT:CreateSmoother(sSuffix, numInit, numRate)
	dhonline.CreateSmoother( self:GetMySmootherFullName( sSuffix ), numInit, numRate)
end

function ELEMENT:ChangeSmootherTarget(sSuffix, numTarget)
	dhonline.ChangeSmootherTarget( self:GetMySmootherFullName( sSuffix ), numTarget )
end

function ELEMENT:ChangeSmootherCurrent(sSuffix, numCurrent)
	dhonline.ChangeSmootherCurrent( self:GetMySmootherFullName( sSuffix ), numCurrent )
end

function ELEMENT:ChangeSmootherRate(sSuffix, numRate)
	dhonline.ChangeSmootherRate( self:GetMySmootherFullName( sSuffix ), numRate )
end

function ELEMENT:GetSmootherCurrent(sSuffix)
	return dhonline.GetSmootherCurrent( self:GetMySmootherFullName( sSuffix ) )
end

function ELEMENT:ConvertGridData()
	local xGrid, yGrid = self:GetMyGridPos()
	local xRel , yRel  = dhonline.GetRelPosFromGrid( xGrid, yGrid )
	local width, height = self:GetMySizes()
	
	return xRel, yRel, width, height
end



local dhi_element_meta = {__index=ELEMENT}

function Initialize( sName, dElement )
	dElement._rawname = sName
	dElement.Name = dElement.Name or sName
	
	local sCvarPrefix = "dhonline_element_" .. dElement._mytheme .. "_" .. sName
	
	dhonline.CreateVar(sCvarPrefix, ( not (dElement.DefaultOff or false ) ) and "1" or "0", true, false)
	dhonline.CreateVar(sCvarPrefix .. "_x", dElement.DefaultGridPosX or 0, true, false)
	dhonline.CreateVar(sCvarPrefix .. "_y", dElement.DefaultGridPosY or 0, true, false)

	setmetatable(dElement, dhi_element_meta)
	
	if dElement.CoreInitialize then dElement:CoreInitialize() end
	if dElement.Initialize then dElement:Initialize() end
end
