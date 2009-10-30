////////////////////////////////////////////////
// -- Depth HUD : Inline                      //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Main autorun file, with drawing functions  //
////////////////////////////////////////////////
//  About making elements, read _empty._lua   //
////////////////////////////////////////////////

surface.CreateFont("Trebuchet MS", 36, 0   , 0, 0, "dhigwfont_num" )
surface.CreateFont("Trebuchet MS", 26, 0   , 0, 0, "dhigwfont_nummedium" )
surface.CreateFont("Trebuchet MS", 20, 0   , 0, 0, "dhigwfont_numsmall" )
surface.CreateFont("Trebuchet MS", 36, 0   , 0, 0, "dhigwfont_textlarge" )
surface.CreateFont("Trebuchet MS", 24, 0   , 0, 0, "dhigwfont_textmedium" )
surface.CreateFont("Trebuchet MS", 16, 400 , 0, 0, "dhigwfont_textsmall" )
surface.CreateFont("Trebuchet MS", 24, 400 , 0, 0, "dhigwfont_textmediumbold" )

surface.CreateFont("Trebuchet MS", 36, 0   , 0, false, "dhigwfont_num_nb" )
surface.CreateFont("Trebuchet MS", 26, 0   , 0, false, "dhigwfont_nummedium_nb" )
surface.CreateFont("Trebuchet MS", 20, 0   , 0, false, "dhigwfont_numsmall_nb" )
surface.CreateFont("Trebuchet MS", 36, 0   , 0, false, "dhigwfont_textlarge_nb" )
surface.CreateFont("Trebuchet MS", 24, 0   , 0, false, "dhigwfont_textmedium_nb" )
surface.CreateFont("Trebuchet MS", 16, 400 , 0, false, "dhigwfont_textsmall_nb" )
surface.CreateFont("Trebuchet MS", 24, 400 , 0, false, "dhigwfont_textmediumbold_nb" )

dhinlinegware_styledefs = {}
function dhinlinegware_CreateStyleVar( sRawVarName, sValue, bDumpValOne, bDumpValTwo )
	dhinlinegware_styledefs[sRawVarName] = sValue
end
function dhinlinegware_GetStyleVar( sRawVarName )
	return tonumber(dhinlinegware_styledefs[sRawVarName])
end


dhinlinegware_CreateStyleVar("dhinlinegware_enable", "1", true, false)
dhinlinegware_CreateStyleVar("dhinlinegware_disabledefault", "1", true, false)
dhinlinegware_CreateStyleVar("dhinlinegware_ui_blendfonts", "0", true, false)
dhinlinegware_CreateStyleVar("dhinlinegware_ui_spacing", "0.3", true, false)
dhinlinegware_CreateStyleVar("dhinlinegware_ui_hudlag_mul", "0", true, false)
dhinlinegware_CreateStyleVar("dhinlinegware_ui_hudlag_retab", "0.2", true, false)
dhinlinegware_CreateStyleVar("dhinlinegware_ui_dynamicbackground", "0", true, false)
dhinlinegware_CreateStyleVar("dhinlinegware_ui_drawglow", "0", true, false)

dhinlinegware_CreateStyleVar("dhinlinegware_col_base_r", "255", true, false)
dhinlinegware_CreateStyleVar("dhinlinegware_col_base_g", "220", true, false)
dhinlinegware_CreateStyleVar("dhinlinegware_col_base_b", "0", true, false)
dhinlinegware_CreateStyleVar("dhinlinegware_col_base_a", "192", true, false)

dhinlinegware_CreateStyleVar("dhinlinegware_col_back_r", "0", true, false)
dhinlinegware_CreateStyleVar("dhinlinegware_col_back_g", "0", true, false)
dhinlinegware_CreateStyleVar("dhinlinegware_col_back_b", "0", true, false)
dhinlinegware_CreateStyleVar("dhinlinegware_col_back_a", "92", true, false)

include("cl_dhinlinegware_element.lua")
include("garbage_module.lua")

dhinlinegware_dat = {}

dhinlinegware_dat.DEBUG = false

dhinlinegware_dat.ui_backcolor = Color(0, 0, 0, 92)
dhinlinegware_dat.ui_basecolor = Color(255, 220, 0, 192)
dhinlinegware_dat.ui_basecolor_lesser = Color(255, 220, 0, 92)
dhinlinegware_dat.ui_drawglow = 0
dhinlinegware_dat.ui_glowrelsize = 5.0
dhinlinegware_dat.ui_glowalpharel = 1.0
dhinlinegware_dat.ui_blendfonts = 1
dhinlinegware_dat.ui_hudlag = {}
dhinlinegware_dat.ui_hudlag.x = 0
dhinlinegware_dat.ui_hudlag.y = 0
dhinlinegware_dat.ui_hudlag.mul = 2
dhinlinegware_dat.ui_hudlag.retab = 0.2
dhinlinegware_dat.ui_edgeSpacingRel = 0.015
//dhinlinegware_dat.ui_rectHeight = 44
//dhinlinegware_dat.ui_rectLen     = math.floor(dhinlinegware_dat.ui_rectHeight * 2.2)
dhinlinegware_dat.ui_rectHeight = ScrH()
dhinlinegware_dat.ui_rectLen    = ScrW()
dhinlinegware_dat.ui_innerSquareProportions = 0.7

dhinlinegware_dat.STOR_Smoothers = {}
dhinlinegware_dat.STOR_TempVars  = {}
dhinlinegware_dat.STOR_HUDPATCH_Volatile  = {}

dhinlinegware_dat.STOR_DynamicBackCalc = Color(0, 255, 255, 255)
dhinlinegware_dat.STOR_BackCalc    = Color(0,255,255,255)
dhinlinegware_dat.STOR_BlendCalc    = Color(0,255,255,255)
dhinlinegware_dat.STOR_TextColorCalc  = Color(0,255,255,255)
dhinlinegware_dat.STOR_TextSmallColCalc   = Color(0,255,255,255)

dhinlinegware_dat.STOR_ElementNamesTable = {}

dhinlinegware_dat.tex_glow       = surface.GetTextureID("sprites/light_glow02_add")

local PARAM_GRID_DIVIDE  = 16
local PARAM_HUDLAG_LastAng = EyeAngles()
local PARAM_HUDLAG_BOX    = 1
local PARAM_HUDLAG_INBOX  = 1.5
local PARAM_HUDLAG_TEXT   = 1.25
local PARAM_BLINK_PERIOD  = 0.5



///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
//// INITIALIZATION FUNCTIONS .

local function dhinlinegware_InitializeElements()
	for k,name in pairs( dhinlinegware_dat.STOR_ElementNamesTable ) do
		local ELEMENT = dhinlinegware.Get(name)
		if (ELEMENT and ELEMENT.Initialize) then
			ELEMENT:Initialize( )
		end
	end
end
	
local function dhinlinegware_LoadAllElements()
	dhinlinegware.RemoveAll()

	local path = string.Replace(GAMEMODE.Folder, "gamemodes/", "") .. "/gamemode/dhinlinegware_element/"
	for _,file in pairs(file.FindInLua(path.."*.lua")) do
		ELEMENT = {}
		
		include(path..file)
		
		local keyword = string.Replace(file, ".lua", "")
		dhinlinegware.Register(keyword, ELEMENT)
	end
	
	dhinlinegware_dat.STOR_ElementNamesTable = dhinlinegware.GetNamesTable()
	table.sort(dhinlinegware_dat.STOR_ElementNamesTable,function(a,b) return a < b end)
	
	print("GWare Inline registered : ")
	for k,name in pairs( dhinlinegware_dat.STOR_ElementNamesTable ) do
		Msg("["..name.."] ")
	end
	Msg("\n")
	
	dhinlinegware_InitializeElements()
	dhinlinegware_InitializeMisc()
	
	hook.Remove("HUDPaint","dhinlinegwareHUDPaint")
	hook.Add("HUDPaint","dhinlinegwareHUDPaint",dhinlinegwareHUDPaint)
end
concommand.Add("dhinlinegware_reloadelements",dhinlinegware_LoadAllElements)
	
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
//// INTERNAL CALC .

local function dhinlinegware_CalcCenter( xRel , yRel , width, height )
	local xCalc,yCalc = 0,0
	
	xDist = dhinlinegware_dat.ui_edgeSpacingRel*ScrW() + width*0.5
	xCalc = xRel*ScrW() + (xRel*(-2) + 1)*xDist
	
	yDist = dhinlinegware_dat.ui_edgeSpacingRel*ScrW() + height*0.5 //ScrW here is not a mistake
	yCalc = yRel*ScrH() + (yRel*(-2) + 1)*yDist
	
	return xCalc, yCalc
end

local function dhinlinegware_CalcHudLag( )
	dhinlinegware_dat.ui_hudlag.la = PARAM_HUDLAG_LastAng
	dhinlinegware_dat.ui_hudlag.ca = EyeAngles()
	
	local targetX = math.AngleDifference(dhinlinegware_dat.ui_hudlag.ca.y , dhinlinegware_dat.ui_hudlag.la.y)*dhinlinegware_dat.ui_hudlag.mul
	local targetY = -math.AngleDifference(dhinlinegware_dat.ui_hudlag.ca.p , dhinlinegware_dat.ui_hudlag.la.p)*dhinlinegware_dat.ui_hudlag.mul
	
	//print(x,y)
	
	dhinlinegware_dat.ui_hudlag.x = dhinlinegware_dat.ui_hudlag.x + (targetX - dhinlinegware_dat.ui_hudlag.x) * math.Clamp(dhinlinegware_dat.ui_hudlag.retab * 0.5 * FrameTime() * 50 , 0 , 1 )
	dhinlinegware_dat.ui_hudlag.y = dhinlinegware_dat.ui_hudlag.y + (targetY - dhinlinegware_dat.ui_hudlag.y) * math.Clamp(dhinlinegware_dat.ui_hudlag.retab * 0.5 * FrameTime() * 50 , 0 , 1 )
	
	PARAM_HUDLAG_LastAng = EyeAngles()
end

function dhinlinegware_GetGridDivideMax()
	return PARAM_GRID_DIVIDE
end

function dhinlinegware_GetGenericBoxSizes()
	return dhinlinegware_dat.ui_rectLen, dhinlinegware_dat.ui_rectHeight
end

function dhinlinegware_GetRelPosFromGrid( xGrid, yGrid )
	local max = dhinlinegware_GetGridDivideMax()
	local xRel, yRel = (xGrid / max), (yGrid / max)
	
	return xRel, yRel
end

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
//// USEFUL FUNCTIONS FOR USER .

function dhinlinegware_GetStyleData( stringPredefName )
	if     stringPredefName == "color_base"        then return dhinlinegware_dat.ui_basecolor
	elseif stringPredefName == "color_base_lesser" then return dhinlinegware_dat.ui_basecolor_lesser
	elseif stringPredefName == "color_back"        then return dhinlinegware_dat.ui_backcolor
	else return nil end
end

function dhinlinegware_StringNiceNameTransform( stringInput )
	local stringParts = string.Explode("_",stringInput)
	local stringOutput = ""
	for k,part in pairs(stringParts) do
		local len = string.len(part)
		if (len == 1) then
			stringOutput = stringOutput .. string.upper(part)
		elseif (len > 1) then
			stringOutput = stringOutput .. string.Left(string.upper(part),1) .. string.Right(part,len-1)
		end
		if (k != #stringParts) then stringOutput = stringOutput .. " " end
	end
	return stringOutput
end

function dhinlinegware_GetAppropriateFont(text, desiredChoice)
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
	if (dhinlinegware_dat.ui_blendfonts <= 0) then
		font = font .. "_nb"
	end
	return font
end

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
//// DRAWING FUNCTIONS. DO NOT USE IN YOUR ELEMENTS.
//// READ cl_dhinlinegware_element.lua FOR DRAWING FUNCTIONS
//// AND _empty._lua .

function dhinlinegware_DrawSprite(sprite, x, y, width, height, angle, r, g, b, a)
	local spriteid = 0
	if ( type(sprite) == "string" ) then
		spriteid = surface.GetTextureID(sprite)
	else
		spriteid = sprite
	end
	
	surface.SetTexture(spriteid)
	surface.SetDrawColor(r, g, b, a)
	surface.DrawTexturedRectRotated(x, y, width, height, angle)
end

//The font changes if the text is a number or not.
//If it is a number, it will take the best version of the font, that is the HL2 one.
//If not, it will take a similar, lesser quality version, that allows alphabetical characters.

function dhinlinegware_Draw_RAW_GetAppropriateBoxRound( myRound )
	local boxRound = 0
	local boxBigSizeCalc = (myRound/44)
	if boxBigSizeCalc <= 0.75 && boxBigSizeCalc > 0.5 then
		boxRound = 6
	elseif boxBigSizeCalc <= 0.5 && boxBigSizeCalc > 0.25 then
		boxRound = 4
	elseif boxBigSizeCalc <= 0.25 then
		boxRound = 0
	else
		boxRound = 8
	end
	
	return boxRound
end

function dhinlinegware_Draw_RAW_GWBox(xAbs, yAbs, width, height, extraBorder, backColor, borderColor)

	backColor = backColor or dhinlinegware_dat.ui_backcolor
	borderColor = borderColor or dhinlinegware_dat.ui_basecolor
	
	xAbs = xAbs + dhinlinegware_dat.ui_hudlag.x*PARAM_HUDLAG_INBOX
	yAbs = yAbs + dhinlinegware_dat.ui_hudlag.y*PARAM_HUDLAG_INBOX
	
	local widthBR, heightBR = width, height
	
	extraBorder = math.floor(extraBorder or 0)
	
	width  = width  - extraBorder*2
	height = height - extraBorder*2
	
	local minBoxCalc = 0
	minBoxCalc = math.min(widthBR, heightBR)
	local extBR = dhinlinegware_Draw_RAW_GetAppropriateBoxRound( minBoxCalc )
	
	minBoxCalc = math.min(width, height)
	local inBR = dhinlinegware_Draw_RAW_GetAppropriateBoxRound( minBoxCalc )
	
	draw.RoundedBox(extBR, xAbs - widthBR*0.5, yAbs - heightBR*0.5, widthBR, heightBR, borderColor)
	draw.RoundedBox(extBR, xAbs - width*0.5, yAbs - height*0.5, width, height, backColor)

end

function dhinlinegware_Draw_RAW_GWText(xAbs, yAbs, text, textColor, mainFontChoice, optHalign, optValign)
	if (text == nil) or (text == "") then return end

	textColor = textColor or dhinlinegware_dat.ui_basecolor

	local font = dhinlinegware_GetAppropriateFont(text, mainFontChoice)
	
	xAbs = dhinlinegware_dat.ui_hudlag.x*PARAM_HUDLAG_TEXT + xAbs
	yAbs = dhinlinegware_dat.ui_hudlag.y*PARAM_HUDLAG_TEXT + yAbs
	
	draw.SimpleText(text, font, xAbs, yAbs, textColor, optHalign or 1, optValign or 1 )
end

function dhinline_DrawGWTextBox(xRel, yRel, width, height, extraBorder, text, backColor, borderColor, textColor, mainFontChoice)
	local xCenter,yCenter = dhinlinegware_CalcCenter( xRel , yRel , width , height )
	
	dhinlinegware_Draw_RAW_GWBox(xCenter, yCenter, width, height, extraBorder, backColor, borderColor)
	dhinlinegware_Draw_RAW_GWText(xCenter, yCenter, text, textColor, mainFontChoice)
end

function dhinline_DrawGWRelativeTextBox(xRel, yRel, width, height, xRelOffset, yRelOffset, boxWidth, boxHeight, extraBorder, text, backColor, borderColor, textColor, mainFontChoice)
	local xCenter,yCenter = dhinlinegware_CalcCenter( xRel , yRel , width , height )
	
	local xCenterNew,yCenterNew = xCenter + width * xRelOffset * 0.5, yCenter + height * yRelOffset * 0.5
	
	dhinlinegware_Draw_RAW_GWBox(xCenterNew, yCenterNew, boxWidth, boxHeight, extraBorder, backColor, borderColor)
	dhinlinegware_Draw_RAW_GWText(xCenterNew, yCenterNew, text, textColor, mainFontChoice)
end

function dhinline_DrawGWDoubleSidedBox(xRel, yRel, width, height, border, textLeft, textRight, backLeftColor, backRightColor, borderColor, textLeftColor, textRightColor, mainFontChoice)
	local xCenter,yCenter = dhinlinegware_CalcCenter( xRel , yRel , width , height )
	
	local minBoxCalc = 0
	local widthBR, heightBR = width, height
	
	width  = width  - border*2
	height = height - border*2
	minBoxCalc = math.min(width, height)
	minBoxCalc = math.min(widthBR, heightBR)
	
	local extBR = dhinlinegware_Draw_RAW_GetAppropriateBoxRound( minBoxCalc )
	local inBR = dhinlinegware_Draw_RAW_GetAppropriateBoxRound( minBoxCalc )
	
	draw.RoundedBox(extBR, xCenter - widthBR*0.5, yCenter - heightBR*0.5, widthBR, heightBR, borderColor)
	
	draw.RoundedBox(extBR, xCenter - widthBR*0.5 + border, yCenter - heightBR*0.5 + border, width*0.5, height, backLeftColor)
	draw.RoundedBox(extBR, xCenter + border*0.5, yCenter - heightBR*0.5 + border, width*0.5, height, backRightColor)

	dhinlinegware_Draw_RAW_GWText(xCenter - widthBR*0.25, yCenter, textLeft, textLeftColor, mainFontChoice)
	dhinlinegware_Draw_RAW_GWText(xCenter + widthBR*0.25, yCenter, textRight, textRightColor, mainFontChoice)
end

function dhinline_DrawGWPreProgrammedRidiculousBox(xRel, yRel, width, height, iFromFirst, ply, textColor, winColor, failColor, mysteryColor, goldColor, goldColorBrighter, neutralColor, confirmedColor)

	if (not ValidEntity(ply) or not ply:IsPlayer()) then return end

	local xCenter, yCenter = dhinlinegware_CalcCenter( xRel , yRel , width , height )
	local yCenterNew = yCenter + (height * 1.05) * (iFromFirst - 1)
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
	
	dhinlinegware_Draw_RAW_GWBox(xCenter, yCenterNew, width, height, extraBorder, statusColor, borderColor)
	dhinlinegware_Draw_RAW_GWText(xTextCenter, yCenterNew, text, textColor, 0, 0)
	
	// Scores
	local boxSideLen = height * 1.0
	
	if true then
		local xCenterBox = xCenter + width * (0.5) - boxSideLen * 0.5 - 4
		local borderSize = 2.0
		
		dhinlinegware_Draw_RAW_GWBox(xCenterBox, yCenterNew, boxSideLen, boxSideLen, borderSize, failColor, confirmedColor)
		dhinlinegware_Draw_RAW_GWText(xCenterBox, yCenterNew, ply:Deaths(), textColor, 0)
	end
	
	if true then
		local xCenterBox = xCenter + width * (0.5) - boxSideLen * (0.5 + 1) - 4
		local borderSize = 2.0
		
		dhinlinegware_Draw_RAW_GWBox(xCenterBox, yCenterNew, boxSideLen, boxSideLen, borderSize, winColor, confirmedColor)
		dhinlinegware_Draw_RAW_GWText(xCenterBox, yCenterNew, ply:Frags(), textColor, 0)
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
			dhinlinegware_Draw_RAW_GWBox(xCenterBox, yCenterNew, boxSideLen + plusBorderSize, boxSideLen + plusBorderSize, 0.0, goldColorBrighter, nil)
		end
		
		dhinlinegware_Draw_RAW_GWBox(xCenterBox, yCenterNew, boxSideLen, boxSideLen, 2.0, goldColor, confirmedColor)
		dhinlinegware_Draw_RAW_GWText(xCenterBox, yCenterNew, ply:GetBestCombo(), textColor, 0)
	end
	
	
end


///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
//// VOLATILE ACCUMULATION FUNCTIONS. DO NOT USE IN YOUR ELEMENTS.
//// READ cl_dhinlinegware_element.lua FOR VOLATILE FUNCTIONS.

function dhinlinegware_GetVolatileStorage(name)
	if (dhinlinegware_dat.STOR_HUDPATCH_Volatile[name] == nil) then
		return nil
	end
	return dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][10] or nil
end

function dhinlinegware_UpdateVolatile(name, xRel, yRel, width, height, xRelOffset, yRelOffset, text, textColor, lagMultiplier, fontChoice, duration, fadePower, storage)
	dhinlinegware_dat.STOR_HUDPATCH_Volatile[name] = {}
	dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][1] = xRel
	dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][2] = yRel
	dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][3] = text
	dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][4] = textColor
	dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][5] = lagMultiplier
	dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][6] = duration
	dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][7] = fadePower
	dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][8] = fontChoice
	dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][9] = RealTime()
	dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][10] = storage
	dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][11] = width
	dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][12] = height
	dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][13] = xRelOffset
	dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][14] = yRelOffset
end

local function dhinlinegware_DrawVolatiles()
	for name,subtable in pairs(dhinlinegware_dat.STOR_HUDPATCH_Volatile) do	
		if (subtable[1] != nil) then
			local timeSpawned = dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][9]
			local duration    = dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][6]
			
			if ((RealTime() - timeSpawned) > duration) then
				dhinlinegware_dat.STOR_HUDPATCH_Volatile[name] = {nil}
			else
				local stayedUpRel = (RealTime() - timeSpawned) / duration
				
				local xRel = dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][1]
				local yRel = dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][2]
				local text = dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][3]
				local lagMultiplier = dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][5]
				local fadePower = dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][7]
				local fontChoice = dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][8]
				local width = dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][11]
				local height = dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][12]
				local xRelOffset = dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][13]
				local yRelOffset = dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][14]
				
				local textColor = Color(dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][4].r, dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][4].g, dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][4].b, dhinlinegware_dat.STOR_HUDPATCH_Volatile[name][4].a)
				textColor.a = textColor.a * (1 - (stayedUpRel^fadePower))
				
				dhinlinegware_DrawVolatile(xRel, yRel, width, height, xRelOffset, yRelOffset, text, textColor, lagMultiplier, fontChoice)
			end
		end
		
	end
end

function dhinlinegware_DeleteAllVolatiles()
	dhinlinegware_dat.STOR_HUDPATCH_Volatile = {}
end

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
//// SMOOTHING FUNCTIONS. DO NOT USE IN YOUR ELEMENTS.
//// READ cl_dhinlinegware_element.lua FOR SMOOTHING FUNCTIONS.

function dhinlinegware_CreateSmoother(strName, numInit, numRate)
	//{Target, Current, Rate}
	//if dhinlinegware_dat.STOR_Smoothers[strName] then return end
	//numRate = math.Clamp(numRate,0.001,1)
	local numCurrent = nil
	if type(numInit) == "table" then
		numCurrent = table.Copy(numInit)
	else
		numCurrent = numInit
	end
	dhinlinegware_dat.STOR_Smoothers[strName] = {numInit, numCurrent, numRate}
end

function dhinlinegware_ChangeSmootherTarget(strName, numTarget)
	if not dhinlinegware_dat.STOR_Smoothers[strName] then print("dhinlinegware ERROR : ChangeSmootherTarget has requested field " .. strName .." which hasn't been created !") return end
	dhinlinegware_dat.STOR_Smoothers[strName][1] = numTarget
end

function dhinlinegware_ChangeSmootherRate(strName, numRate)
	if not dhinlinegware_dat.STOR_Smoothers[strName] then print("dhinlinegware ERROR : ChangeSmootherRate has requested field " .. strName .." which hasn't been created !") return end
	dhinlinegware_dat.STOR_Smoothers[strName][3] = numRate
end

function dhinlinegware_GetSmootherCurrent(strName)
	if not dhinlinegware_dat.STOR_Smoothers[strName] then print("dhinlinegware ERROR : GetSmootherCurrent has requested field " .. strName .." which hasn't been created !") return nil end
	return dhinlinegware_dat.STOR_Smoothers[strName][2]
end



local function dhinlinegware_RecalcAllSmoothers()
	local previousCurrent = 0
	for name,subtable in pairs(dhinlinegware_dat.STOR_Smoothers) do
		if (type(dhinlinegware_dat.STOR_Smoothers[name][2]) == "table") then
			for subkey,value in pairs(dhinlinegware_dat.STOR_Smoothers[name][2]) do
				previousCurrent = dhinlinegware_dat.STOR_Smoothers[name][2][subkey]
				dhinlinegware_dat.STOR_Smoothers[name][2][subkey] = dhinlinegware_dat.STOR_Smoothers[name][2][subkey] + (dhinlinegware_dat.STOR_Smoothers[name][1][subkey] - dhinlinegware_dat.STOR_Smoothers[name][2][subkey]) * dhinlinegware_dat.STOR_Smoothers[name][3] * FrameTime() * 50
				if (previousCurrent < dhinlinegware_dat.STOR_Smoothers[name][1][subkey]) and (dhinlinegware_dat.STOR_Smoothers[name][2][subkey] > dhinlinegware_dat.STOR_Smoothers[name][1][subkey]) then
					dhinlinegware_dat.STOR_Smoothers[name][2][subkey] = dhinlinegware_dat.STOR_Smoothers[name][1][subkey]
				elseif (previousCurrent > dhinlinegware_dat.STOR_Smoothers[name][1][subkey]) and (dhinlinegware_dat.STOR_Smoothers[name][2][subkey] < dhinlinegware_dat.STOR_Smoothers[name][1][subkey]) then
					dhinlinegware_dat.STOR_Smoothers[name][2][subkey] = dhinlinegware_dat.STOR_Smoothers[name][1][subkey]
				end
			end
		else
			dhinlinegware_dat.STOR_Smoothers[name][2] = dhinlinegware_dat.STOR_Smoothers[name][2] + (dhinlinegware_dat.STOR_Smoothers[name][1] - dhinlinegware_dat.STOR_Smoothers[name][2]) * math.Clamp( dhinlinegware_dat.STOR_Smoothers[name][3] * 0.5 * FrameTime() * 50 , 0 , 1 )
		end
	end
end

function dhinlinegware_DeleteAllSmoothers()
	dhinlinegware_dat.STOR_Smoothers = {}
end

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
//// OBSELETE SHARED VARS .

/*
function dhinlinegware_ChangeVar(strName, newVar)
	//if not dhinlinegware_dat.STOR_TempVars[strName] then print("dhinlinegware ERROR : ChangeVar has requested field " .. strName .." which hasn't been created !") return end
	dhinlinegware_dat.STOR_TempVars[strName] = newVar
end
function dhinlinegware_GetVar(strName)
	if not dhinlinegware_dat.STOR_TempVars[strName] then print("dhinlinegware ERROR : GetVar has requested field " .. strName .." which hasn't been created !") return nil end
	return dhinlinegware_dat.STOR_TempVars[strName]
end
function dhinlinegware_DeleteAllVars()
	dhinlinegware_dat.STOR_TempVars = {}
end
*/

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
//// DRAWING FUNCTION AND STYLE.

local function dhinlinegware_DrawElements()
	for k,name in pairs( dhinlinegware_dat.STOR_ElementNamesTable ) do
		local ELEMENT = dhinlinegware.Get(name)
		if (ELEMENT and ( dhinlinegware_GetStyleVar( "dhinlinegware_element_" .. name ) > 0 ) and ELEMENT.DrawFunction) then
			local bOkay, strErr = pcall(ELEMENT.DrawFunction, ELEMENT)
			if not bOkay then print(strErr .. " [DHINLINE ERROR]") end
		end
	end
end


/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
//// THE MAIN HOOK - THINK .

function dhinlinegware_InitializeMisc()
	dhinlinegware_CreateSmoother("__dynamicbackground",Color(255,255,255,255),0.05)
end

function dhinlinegwareHUDPaint(name)
	if dhinlinegware_GetStyleVar("dhinlinegware_enable") <= 0 then return end
	
	dhinlinegware_dat.ui_edgeSpacingRel = dhinlinegware_GetStyleVar("dhinlinegware_ui_spacing") * 0.015
	dhinlinegware_dat.ui_hudlag.mul    = dhinlinegware_GetStyleVar("dhinlinegware_ui_hudlag_mul")
	dhinlinegware_dat.ui_hudlag.retab  = dhinlinegware_GetStyleVar("dhinlinegware_ui_hudlag_retab")
	
	dhinlinegware_dat.ui_drawglow    = dhinlinegware_GetStyleVar("dhinlinegware_ui_drawglow")
	dhinlinegware_dat.ui_blendfonts    = dhinlinegware_GetStyleVar("dhinlinegware_ui_blendfonts")
	
	dhinlinegware_dat.ui_basecolor.r = dhinlinegware_GetStyleVar("dhinlinegware_col_base_r")
	dhinlinegware_dat.ui_basecolor.g = dhinlinegware_GetStyleVar("dhinlinegware_col_base_g")
	dhinlinegware_dat.ui_basecolor.b = dhinlinegware_GetStyleVar("dhinlinegware_col_base_b")
	dhinlinegware_dat.ui_basecolor.a = dhinlinegware_GetStyleVar("dhinlinegware_col_base_a")
	
	dhinlinegware_dat.ui_basecolor_lesser.r = dhinlinegware_dat.ui_basecolor.r
	dhinlinegware_dat.ui_basecolor_lesser.g = dhinlinegware_dat.ui_basecolor.g
	dhinlinegware_dat.ui_basecolor_lesser.b = dhinlinegware_dat.ui_basecolor.b
	dhinlinegware_dat.ui_basecolor_lesser.a = dhinlinegware_dat.ui_basecolor.a*0.5

	dhinlinegware_dat.STOR_DynamicBackCalc.r = dhinlinegware_GetStyleVar("dhinlinegware_col_back_r")
	dhinlinegware_dat.STOR_DynamicBackCalc.g = dhinlinegware_GetStyleVar("dhinlinegware_col_back_g")
	dhinlinegware_dat.STOR_DynamicBackCalc.b = dhinlinegware_GetStyleVar("dhinlinegware_col_back_b")
	dhinlinegware_dat.STOR_DynamicBackCalc.a = dhinlinegware_GetStyleVar("dhinlinegware_col_back_a")
	
	if (dhinlinegware_GetStyleVar("dhinlinegware_ui_dynamicbackground") > 0) then
		local lcolor = render.GetLightColor( EyePos() ) * 2
		lcolor.x = mathx.Clamp( lcolor.x, 0, 1 )
		lcolor.y = mathx.Clamp( lcolor.y, 0, 1 )
		lcolor.z = mathx.Clamp( lcolor.z, 0, 1 )
		
		local lightlevel_darkness = ( 1 - (lcolor.x + lcolor.y + lcolor.z) / 3 ) * 0.3
		
		local reflectcookie = math.cos(math.rad(2*EyeAngles().y+75)) * math.sin(math.rad(EyeAngles().p + 90)) * 0.2 + 0.8
		dhinlinegware_dat.STOR_DynamicBackCalc.r = dhinlinegware_dat.STOR_DynamicBackCalc.r + (255 - dhinlinegware_dat.STOR_DynamicBackCalc.r) * lightlevel_darkness
		dhinlinegware_dat.STOR_DynamicBackCalc.g = dhinlinegware_dat.STOR_DynamicBackCalc.g + (255 - dhinlinegware_dat.STOR_DynamicBackCalc.g) * lightlevel_darkness
		dhinlinegware_dat.STOR_DynamicBackCalc.b = dhinlinegware_dat.STOR_DynamicBackCalc.b + (255 - dhinlinegware_dat.STOR_DynamicBackCalc.b) * lightlevel_darkness
		dhinlinegware_dat.STOR_DynamicBackCalc.a = dhinlinegware_dat.STOR_DynamicBackCalc.a * reflectcookie
		
		//We shouldn't need that due to the pointer
		dhinlinegware_ChangeSmootherTarget("__dynamicbackground", dhinlinegware_dat.STOR_DynamicBackCalc)
		
		dhinlinegware_dat.ui_backcolor = dhinlinegware_GetSmootherCurrent("__dynamicbackground")
	else
		dhinlinegware_dat.ui_backcolor.r = dhinlinegware_dat.STOR_DynamicBackCalc.r
		dhinlinegware_dat.ui_backcolor.g = dhinlinegware_dat.STOR_DynamicBackCalc.g
		dhinlinegware_dat.ui_backcolor.b = dhinlinegware_dat.STOR_DynamicBackCalc.b
		dhinlinegware_dat.ui_backcolor.a = dhinlinegware_dat.STOR_DynamicBackCalc.a
	end

	//Calc all required inline
	dhinlinegware_CalcHudLag()
	dhinlinegware_RecalcAllSmoothers()
	
	//Draw all the elements
	dhinlinegware_DrawElements()
	dhinlinegware_DrawVolatiles()
end
//hook.Add("HUDPaint","dhinlinegwareHUDPaint",dhinlinegwareHUDPaint)

local function dhinlinegwareHideHUD(name)
	if dhinlinegware_GetStyleVar("dhinlinegware_disabledefault") <= 0 then return end
	
	if name == "CHudHealth"        then return false end
	if name == "CHudBattery"       then return false end
	if name == "CHudAmmo"          then return false end
	if name == "CHudSecondaryAmmo" then return false end
end
hook.Add("HUDShouldDraw","dhinlinegwareHideHUD",dhinlinegwareHideHUD)


/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
//// STARTING UP .

hook.Add( "InitPostEntity", "dhinlinegwareLoadAllElements", dhinlinegware_LoadAllElements )

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////