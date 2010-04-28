////////////////////////////////////////////////
-- -- Depth HUD : Inline                      --
-- by Hurricaaane (Ha3)                       --
--                                            --
-- http://www.youtube.com/user/Hurricaaane    --
//--------------------------------------------//
-- Main file, with core functions             --
////////////////////////////////////////////////

if not dhonline then dhonline = {} end

include("garbage_module.lua")
include("cl_dhonline_element.lua")
include("cl_dhonline_theme.lua")

dhonline_dat = {}
dhonline_dat.DEBUG = false
dhonline_dat.ui_edgeSpacingRel = 0.01
dhonline_dat.PARAM_GRID_DIVIDE  = 16

dhonline_dat.PANEL_Types = {}
dhonline_dat.PANEL_Constructors = {}
dhonline_dat.PANEL_ConvarSuffixes = {}

dhonline_dat.STOR_Smoothers = {}

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
//// INITIALIZATION FUNCTIONS .

function dhonline.LoadCurrentTheme()
	local sThemeFromConvar = dhonline.GetVar("dhonline_core_theme", true)
	dhonline_theme.SetTheme(sThemeFromConvar)
end

-- DEBUG : TO BE TESTED
function dhonline.DeriveFromTheme( sTheme )
	local path = DHONLINE_THEMEDIR 
	include(path..sTheme.."_theme.lua")
	THEME._derivefrom = sTheme
end

function dhonline.LoadAllThemes()
	dhonline_theme.RemoveAll()

	local path = DHONLINE_THEMEDIR
	if DHONLINE_SPECIAL_ISGAMEMODE_STRAP then
		path = string.Replace(GM.Folder, "gamemodes/", "") .. "/gamemode/" .. path
	end
	for _,file in pairs(file.FindInLua(path.."*_theme.lua")) do
		THEME = {}
		
		include(path..file)
		
		local sKeyword = string.Replace(file, "_theme.lua", "")
		dhonline_theme.Register(sKeyword, THEME)
		
		THEME = nil
	end
	
	local stNames = dhonline_theme.GetNamesTable()
	--table.sort(stNames, function(a,b) return dhonline_element.GetThemeObject(a):GetDisplayName() < dhonline_element.GetThemeObject(b):GetDisplayName() end)
	
	if DHONLINE_DEBUG then
		print(DHONLINE_NAME .. " >> Registered Themes : ")
		for k,name in pairs( stNames ) do
			Msg("["..name.."] ")
		end
		Msg("\n")
	end
	
	dhonline.LoadCurrentTheme()
end

function dhonline.SetTheme( sName )
	if not sName or not table.HasValue( dhonline_theme.GetNamesTable() , sName ) then return end
	
	dhonline.SetVar("dhonline_core_theme", sName )
	dhonline_theme.SetTheme( sName )
end

function dhonline.SetThemeCommand( player, command, stName )
	dhonline.SetTheme( stName[1] )
end

function dhonline.LoadElement( sThemeName, sElementName, opt_ThemeOverride )
	ELEMENT = {}
	local pathBase = DHONLINE_THEMEDIR .. (opt_ThemeOverride or sThemeName) .."_element.lua"
	local pathElem = DHONLINE_THEMEDIR .. (opt_ThemeOverride or sThemeName) .."/"..sElementName..".lua"
	
	ELEMENT._mytheme = sThemeName
	ELEMENT.Theme = dhonline_theme.GetThemeObject(ELEMENT._mytheme)
	
	include( pathBase )
	include( pathElem )
	
	return ELEMENT
end


///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
//// CORE CALC .

function dhonline.CalcCenter( xRel , yRel , width, height )
	local xCalc,yCalc = 0,0
	
	xDist = dhonline_dat.ui_edgeSpacingRel*ScrW() + width*0.5
	xCalc = xRel*ScrW() + (xRel*(-2) + 1)*xDist
	
	yDist = dhonline_dat.ui_edgeSpacingRel*ScrW() + height*0.5 --ScrW here is not a mistake
	yCalc = yRel*ScrH() + (yRel*(-2) + 1)*yDist
	
	return xCalc, yCalc
end

function dhonline.GetGridDivideMax()
	return dhonline_dat.PARAM_GRID_DIVIDE
end

function dhonline.GetRelPosFromGrid( xGrid, yGrid )
	local max = dhonline.GetGridDivideMax()
	local xRel, yRel = (xGrid / max), (yGrid / max)
	
	return xRel, yRel
end

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
//// USEFUL FUNCTIONS FOR USER .

function dhonline.StringNiceNameTransform( stringInput )
	local stringParts = string.Explode("_",stringInput)
	local stringOutput = ""
	for k,part in pairs(stringParts) do
		local len = string.len(part)
		if (len == 1) then
			stringOutput = stringOutput .. string.upper(part)
		elseif (len > 1) then
			stringOutput = stringOutput .. string.Left(string.upper(part),1) .. string.Right(part,len-1)
		end
		if (k ~= #stringParts) then stringOutput = stringOutput .. " " end
	end
	return stringOutput
end


function dhonline.PrimeColorFromTable( cColor, tHyb )
	cColor.r = tHyb[1]
	cColor.g = tHyb[2]
	cColor.b = tHyb[3]
	cColor.a = tHyb[4]
end

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
//// DRAWING FUNCTIONS. DO NOT USE IN YOUR ELEMENTS.
//// READ cl_dhonline_element.lua FOR DRAWING FUNCTIONS
//// AND _empty._lua .

function dhonline.DrawSprite(sprite, x, y, width, height, angle, r, g, b, a)
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

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
//// SMOOTHING FUNCTIONS. DO NOT USE IN YOUR ELEMENTS.
//// READ cl_dhonline_element.lua FOR SMOOTHING FUNCTIONS.

/*
function dhonline.CreateSmoother(strName, numInit, numRate)
	local numCurrent = nil
	if type(numInit) == "table" then
		numCurrent = table.Copy(numInit)
	else
		numCurrent = numInit
	end
	dhonline_dat.STOR_Smoothers[strName] = {numInit, numCurrent, numRate}
end

function dhonline.ChangeSmootherCurrent(strName, numCurrentCall)
	if not dhonline_dat.STOR_Smoothers[strName] then print("> " .. DHONLINE_NAME .. " Smoother ERROR : ChangeSmootherCurrent has requested field " .. strName .." which hasn't been created !") return end
	if type(numCurrentCall) == "table" then
		for k,v in pairs(numCurrentCall) do
			dhonline_dat.STOR_Smoothers[strName][2][k] = numCurrentCall[k]
		end
	end
end

function dhonline.ChangeSmootherTarget(strName, numTarget)
	if not dhonline_dat.STOR_Smoothers[strName] then print("> " .. DHONLINE_NAME .. " Smoother ERROR : ChangeSmootherTarget has requested field " .. strName .." which hasn't been created !") return end
	dhonline_dat.STOR_Smoothers[strName][1] = numTarget
end

function dhonline.ChangeSmootherRate(strName, numRate)
	if not dhonline_dat.STOR_Smoothers[strName] then print("> " .. DHONLINE_NAME .. " Smoother ERROR : ChangeSmootherRate has requested field " .. strName .." which hasn't been created !") return end
	dhonline_dat.STOR_Smoothers[strName][3] = numRate
end

function dhonline.GetSmootherCurrent(strName)
	if not dhonline_dat.STOR_Smoothers[strName] then print("> " .. DHONLINE_NAME .. " Smoother ERROR : GetSmootherCurrent has requested field " .. strName .." which hasn't been created !") return nil end
	return dhonline_dat.STOR_Smoothers[strName][2]
end
*/
function dhonline.RecalcSmootherLogic(subtable)
	local previousCurrent = 0
	if (type(subtable[2]) == "table") then
		for subkey,value in pairs(subtable[2]) do
			previousCurrent = subtable[2][subkey]
			subtable[2][subkey] = subtable[2][subkey] + (subtable[1][subkey] - subtable[2][subkey]) * subtable[3] * FrameTime() * 50
			if (previousCurrent < subtable[1][subkey]) and (subtable[2][subkey] > subtable[1][subkey]) then
				subtable[2][subkey] = subtable[1][subkey]
			elseif (previousCurrent > subtable[1][subkey]) and (subtable[2][subkey] < subtable[1][subkey]) then
				subtable[2][subkey] = subtable[1][subkey]
			end
		end
	else
		subtable[2] = subtable[2] + (subtable[1] - subtable[2]) * math.Clamp( subtable[3] * 0.5 * FrameTime() * 50 , 0 , 1 )
	end
end
/*
function dhonline.RecalcAllSmoothers()
	for name,subtable in pairs(dhonline_dat.STOR_Smoothers) do
		dhonline.RecalcSmootherLogic(subtable)
	end
end


function dhonline.DeleteAllSmoothers()
	dhonline_dat.STOR_Smoothers = {}
end
*/
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
//// DERMA PANEL CONSTRUCTORS .

function dhonline.ParamTypeExists( sType )
	return table.HasValue( dhonline_dat.PANEL_Types , string.lower(sType) )
end

function dhonline.RegisterPanelConstructor( sType, fConstructor, stConvarSuffixes )
	sType = string.lower(sType)
	if dhonline.ParamTypeExists( sType ) then return end
	
	dhonline_dat.PANEL_Constructors[sType] = fConstructor
	dhonline_dat.PANEL_ConvarSuffixes[sType] = stConvarSuffixes or nil
	table.insert( dhonline_dat.PANEL_Types, sType)
	
	if DHONLINE_DEBUG then print(DHONLINE_NAME .. " > Registered Panel Constructor : "..sType) end
end

function dhonline.BuildParamConvars( sType, sFullConvarName, sDefault )
	sType = string.lower(sType)
	if not dhonline.ParamTypeExists( sType ) then return end
	
	if dhonline_dat.PANEL_ConvarSuffixes[sType] == nil then
		dhonline.CreateVar(sFullConvarName, tostring(sDefault), true, false)
		if DHONLINE_DEBUG then print(DHONLINE_NAME .. " > Added Var : "..sFullConvarName.." = "..tostring(sDefault)) end
		
	elseif type(dhonline_dat.PANEL_ConvarSuffixes[sType]) == "table" then
		for k,suffix in pairs( dhonline_dat.PANEL_ConvarSuffixes[sType] ) do
			dhonline.CreateVar(sFullConvarName .. "_" .. suffix, tostring(sDefault[k] or sDefault[1] or sDefault), true, false)
			if DHONLINE_DEBUG then print(DHONLINE_NAME .. " > Added Var : "..sFullConvarName .. "_" .. suffix.." = "..tostring(sDefault[k] or sDefault[1] or sDefault)) end
		end
	end
end

function dhonline.GetParamSuffixes( sType )
	sType = string.lower(sType)
	if not dhonline.ParamTypeExists( sType ) then return end
	
	return dhonline_dat.PANEL_ConvarSuffixes[sType]
end

function dhonline.GetParamConvars( sType, sFullConvarName )
	sType = string.lower(sType)
	if not dhonline.ParamTypeExists( sType ) then return end
	
	local myConvars = {}
	
	if dhonline_dat.PANEL_ConvarSuffixes[sType] == nil then
		table.insert(myConvars, sFullConvarName)
		
	elseif type(dhonline_dat.PANEL_ConvarSuffixes[sType]) == "table" then
		for k,suffix in pairs( dhonline_dat.PANEL_ConvarSuffixes[sType] ) do
			table.insert(myConvars, sFullConvarName .. "_" .. suffix)
		end
	end
	return myConvars
end

function dhonline.BuildParamPanel( sFullConvarName, stData )
	if not dhonline.ParamTypeExists( stData.Type ) then return end
	
	return dhonline_dat.PANEL_Constructors[stData.Type](sFullConvarName , stData)
end

function dhonline.InitializeGenericConstructors( )
	dhonline.RegisterPanelConstructor( "label" , function( sFullConvarName, stData )	
		local myPanel = vgui.Create("DLabel")
		myPanel:SetText( stData.Text or "<Error : no text !>" )
		return myPanel
	end , "noconvars" )
	dhonline.RegisterPanelConstructor( "checkbox" , function( sFullConvarName, stData )
		local myPanel = vgui.Create( "DCheckBoxLabel" )
		myPanel:SetText( stData.Text or "<Error : no text !>" )
		myPanel:SetConVar( sFullConvarName )
		return myPanel 
	end )
	dhonline.RegisterPanelConstructor( "slider" , function( sFullConvarName, stData )	
		local myPanel = vgui.Create( "DNumSlider" )
		myPanel:SetText( stData.Text or "<Error : no text !>" )
		myPanel:SetMin( tonumber(stData.Min or 0) )
		myPanel:SetMax( tonumber(stData.Max or ((stData.Min or 0) + 1)) )
		myPanel:SetDecimals( tonumber(stData.Decimals or 0) )
		myPanel:SetConVar( sFullConvarName )
		return myPanel 
	end )
	dhonline.RegisterPanelConstructor( "color" , function( sFullConvarName, stData )	
		local myPanel = vgui.Create("CtrlColor")
		myPanel:SetConVarR(sFullConvarName.."_r")
		myPanel:SetConVarG(sFullConvarName.."_g")
		myPanel:SetConVarB(sFullConvarName.."_b")
		myPanel:SetConVarA(sFullConvarName.."_a")
		return myPanel 
	end , {"r","g","b","a"})
end


/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
//// MAIN HOOKS .

function dhonline.RemoteCoreThink( themeObj )
	themeObj:CoreThink()
end
function dhonline.RemoteThink( themeObj )
	themeObj:Think()
end
function dhonline.RemotePaint( themeObj )
	themeObj:Paint()
end
function dhonline.RemotePaintMisc( themeObj )
	themeObj:PaintMisc()
end

function dhonline.HUDPaint(name)
	if dhonline.GetVar("dhonline_core_enable") <= 0 then return end
	dhonline_dat.ui_edgeSpacingRel = dhonline.GetVar("dhonline_core_ui_spacing") * 0.015
	
	--dhonline.RecalcAllSmoothers()
	
	local myThemeObjectRef = dhonline_theme.GetCurrentThemeObject()
	
	dhonline.RemoteCoreThink( myThemeObjectRef )
	
	local bOkay, strErr = pcall(function() dhonline.RemoteThink(myThemeObjectRef) end)
	if not bOkay then print(" > " .. DHONLINE_NAME .. " Think ERROR : ".. strErr) end
	
	if bOkay then
		local bOkayTwo, strErrTwo = pcall(function() dhonline.RemotePaint(myThemeObjectRef) end)
		if not bOkayTwo then print(" > " .. DHONLINE_NAME .. " Paint ERROR : ".. strErrTwo) end
	end
	
	if bOkay then
		local bOkayTwo, strErrTwo = pcall(function() dhonline.RemotePaintMisc(myThemeObjectRef) end)
		if not bOkayTwo then print(" > " .. DHONLINE_NAME .. " PaintMisc ERROR : ".. strErrTwo) end
	end
end

function dhonline.HUDShouldDraw( name )
	if (
	(dhonline.GetVar("dhonline_core_enable") <= 0)
	or (dhonline.GetVar("dhonline_core_disabledefault") <= 0)
	) then return end
	
	if name == "CHudHealth"        then return false end
	if name == "CHudBattery"       then return false end
	if name == "CHudAmmo"          then return false end
	if name == "CHudSecondaryAmmo" then return false end
end

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
//// MISC .

function dhonline.RevertTheme()
	local theme = dhonline_theme.GetCurrentThemeObject()
	for key,def in pairs(theme:GetThemeDefaultsTable()) do
		print(key .. " = " .. def)
		dhonline.SetVar(key, def)
	end
end

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
//// MOUNT FCTS.

function dhonline.ThemeAutoComplete(commandName,args)
	local myTable = dhonline_theme.GetNamesTable()
	for k,v in pairs( myTable ) do
		myTable[k] = commandName .. " " .. v
	end
	return myTable
end

function dhonline.Mount()
	print("")
	print("[ Mounting " .. DHONLINE_NAME .. " ... ]")
	
	dhonline.CreateVar("dhonline_core_enable", "1", true, false)
	dhonline.CreateVar("dhonline_core_disabledefault", "1", true, false)
	dhonline.CreateVar("dhonline_core_theme", DHONLINE_DEFAULTTHEME, true, false)
	dhonline.CreateVar("dhonline_core_ui_spacing", "1", true, false)
	
	if dhonline.MountMenu then
		dhonline.MountMenu()
		
		concommand.Add("dhonline_call_reloadtheme", dhonline.LoadCurrentTheme)
		concommand.Add("dhonline_call_reloadthemelist", dhonline.LoadAllThemes)
		concommand.Add("dhonline_call_settheme", dhonline.SetThemeCommand, dhonline.ThemeAutoComplete)
		concommand.Add("dhonline_call_reverttheme", dhonline.RevertTheme )
	end
	
	dhonline.InitializeGenericConstructors( )
	dhonline.LoadAllThemes( true )

	if DHONLINE_HOOK_HUDSHOULDDRAW then
		hook.Add( "HUDShouldDraw", "dhonlineHUDShouldDraw", dhonline.HUDShouldDraw)
	end
	if DHONLINE_HOOK_HUDPAINT then
		hook.Add( "HUDPaint", "dhonlineHUDPaint", dhonline.HUDPaint)
	end
	
	print("[ " .. DHONLINE_NAME .. " is now mounted. ]")
	print("")
	
end

function dhonline.Unmount()
	print("")
	print("] Unmounting " .. DHONLINE_NAME .. " ... [")
	dhonline_theme.RemoveAll()
	
	if dhonline.UnmountMenu then
		dhonline.UnmountMenu()
		
		concommand.Remove("dhonline_call_reloadtheme")
		concommand.Remove("dhonline_call_reloadthemelist")
		concommand.Remove("dhonline_call_settheme")
		concommand.Remove("dhonline_call_reverttheme")
	end
	
	table.Empty(dhonline_dat)
	table.Empty(dhonline)
	
	dhonline_dat = nil
	dhonline = nil
	
	if DHONLINE_HOOK_HUDSHOULDDRAW then
		hook.Remove( "HUDShouldDraw", "dhonlineHUDShouldDraw" )
	end
	if DHONLINE_HOOK_HUDPAINT then
		hook.Remove( "HUDPaint", "dhonlineHUDPaint" )
	end
	
	print("] " .. DHONLINE_NAME .. " has been unmounted. [")
	print("")
	
end

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////