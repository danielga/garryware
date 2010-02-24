////////////////////////////////////////////////
// -- Depth HUD : Inline                        //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// The Element Module, to register easily     //
////////////////////////////////////////////////

module( "dhonline_theme", package.seeall )

local Themes = {}
local Themes_Names = {}
local Theme_Select = ""


local THEME = {}

THEME.GenericBoxHeight = 44
THEME.GenericBoxWidth = math.floor(THEME.GenericBoxHeight * 2.2)

THEME.Parameters = {}
THEME.Parameters_Names = {}

THEME.Elements = {}
THEME.Elements_Names = {}

function THEME:GetRawName()
	return self._rawname
end

function THEME:GetDisplayName()
	return self.Name
end

function THEME:GetElementsNames()
	return table.Copy( self.Elements_Names )
end

function THEME:GetElement( sName )
	return self.Elements[sName]
end

function THEME:ImportElements( opt_sThemeOverride )
	local path = DHONLINE_THEMEDIR
	if DHONLINE_SPECIAL_ISGAMEMODE_STRAP then
		path = string.Replace(GM.Folder, "gamemodes/", "") .. "/gamemode/" .. path
	end
	local path = path .. (opt_sThemeOverride or self:GetRawName()) .."/"
	local sThemeName = self:GetRawName()
	
	for _,file in pairs(file.FindInLua(path.."*.lua")) do
		local sKeyword = string.Replace(file, ".lua", "")
		if not table.HasValue( self.Elements_Names, sKeyword ) then
			local sFile = path..file
			
			ELEMENT = dhonline.LoadElement( sThemeName, sKeyword, opt_sThemeOverride )
			
			dhonline_element.Initialize( sKeyword, ELEMENT )
			
			if self.Elements[ sKeyword ] then
				table.Add( self.Elements[ sKeyword ], ELEMENT )
			else
				self.Elements[ sKeyword ] = ELEMENT
			end
			
			table.insert( self.Elements_Names , sKeyword )
			ELEMENT = nil
		end
		
	end
	
end

function THEME:Mount()
	if self.Elements_Names and #self.Elements_Names > 0 then self:Unmount() end
	
	if self.Load then self:Load() end
	
	self.Elements = {}
	self.Elements_Names = {}

	print(DHONLINE_NAME .. " >> Mounting Theme \"".. self:GetDisplayName() .."\" :")
	
	if DHONLINE_DEBUG then print(DHONLINE_NAME .. " > Loading from [".. self:GetRawName() .."] elements :") end
	
	// Derive ?
	if (self._derivefrom) then
		if DHONLINE_DEBUG then print(DHONLINE_NAME .. " >> Deriving from [".. self._derivefrom .."] elements ...") end
		self:ImportElements( self._derivefrom )
	end
	
	self:ImportElements( )
	
	if #self.Elements_Names > 2 then // Strictly superior to 2
		table.sort(self.Elements_Names, function(a,b)
			return self.Elements[a]:GetDisplayName()
				 < self.Elements[b]:GetDisplayName()
		end)
	end
	
	if DHONLINE_DEBUG then
		for k,name in pairs( self.Elements_Names ) do
			Msg("["..name.."] ")
		end
		Msg("\n")
	end
end

function THEME:Unmount()
	print(DHONLINE_NAME .. " >> Unmounting Theme [".. self:GetDisplayName() .."].")
	
	table.Empty(self.Elements)
	table.Empty(self.Elements_Names)
	table.Empty(self.Parameters)
	table.Empty(self.Parameters_Names)
	
	--dhonline.DeleteAllSmoothers()
	
	if self.Unload then self:Unload() end
end

function THEME:GetGenericBoxSizes( )
	return self.GenericBoxWidth, self.GenericBoxHeight
end

function THEME:CoreThink()
	return
end

function THEME:Think()
	return
end

function THEME:Paint()
	//print(">> Drawing : ".. self:GetDisplayName())
	local themeRawName = self:GetRawName()
	
	for k,ELEMENT in pairs( self.Elements ) do
		local elementRawName = ELEMENT:GetRawName()
		
		if (
			ELEMENT
			and	( dhonline.GetVar( "dhonline_element_".. themeRawName .."_".. elementRawName ) > 0 )
			and ELEMENT.DrawFunction
		) then
		
			//print("Drawing : ".. ELEMENT:GetDisplayName())
			local bOkay, strErr = pcall(ELEMENT.DrawFunction, ELEMENT)
			if not bOkay then print(" > " .. DHONLINE_NAME .. " Paint ERROR on element ["..elementRawName.."] : ".. strErr) end
			
			//Recalc MY smoothers :
			
			for name,subtable in pairs(ELEMENT._SmootherTable) do
				dhonline.RecalcSmootherLogic(subtable)
			end
		
		end
	end
	
end

function THEME:PaintMisc()
	return
end

function THEME:AddParameter( sParameterName , stData )
	if stData.Type == nil or stData.Type == "" then return end

	sParameterName = string.lower(sParameterName)
	stData.Type = string.lower(stData.Type)
	if self.Parameters[sParameterName] then return end
	if not dhonline.ParamTypeExists( stData.Type ) then return end
	
	self.Parameters[sParameterName] = stData
	table.insert(self.Parameters_Names, sParameterName)
	
	if DHONLINE_DEBUG then print(DHONLINE_NAME .. " > Adding Parameters : "..sParameterName.." ["..stData.Type.."]") end
	dhonline.BuildParamConvars( stData.Type, "dhonline_theme_".. self:GetRawName() .."_".. sParameterName, stData.Defaults )
end

function THEME:GetParametersNames( )
	return self.Parameters_Names
end

function THEME:BuildParameterPanel( sParamName )
	local sFullConvarName = "dhonline_theme_".. self:GetRawName() .."_".. sParamName
	return dhonline.BuildParamPanel( sFullConvarName , self.Parameters[sParamName] )
end

function THEME:GetParameterSettings( sParameterName )
	if not self.Parameters[sParameterName] then
		print("> " .. DHONLINE_NAME .. " Parameter ERROR : Requested field ".. sParameterName .. " that doesn't exist !")
		return 0
	end

	local sFullConvarName = "dhonline_theme_".. self:GetRawName() .."_".. sParameterName
	local sType = self.Parameters[sParameterName].Type
	
	self.TEMP_myValues = dhonline.GetParamConvars( sType, sFullConvarName )
	for k,v in pairs( self.TEMP_myValues ) do
		self.TEMP_myValues[k] = dhonline.GetVar( v )
	end
	return (#self.TEMP_myValues == 1) and self.TEMP_myValues[1] or self.TEMP_myValues
end

function THEME:GetNumber( sParameterName )
	local myParam = self:GetParameterSettings( sParameterName )
	
	if (type(myParam) == "table") then
		return myParam[1]
	end
	return tonumber(self:GetParameterSettings( sParameterName ))
end

function THEME:GetThemeConvarTable( )
	local myFullConvars = {}
	for k,sParameterName in pairs( self.Parameters_Names ) do
		local sType = self.Parameters[sParameterName].Type
		local sFullConvarName = "dhonline_theme_".. self:GetRawName() .."_".. sParameterName
		
		table.Add( myFullConvars, dhonline.GetParamConvars( sType, sFullConvarName ) )
	end
	
	table.insert(myFullConvars, "dhonline_core_ui_spacing")
	return myFullConvars
end

function THEME:GetThemeDefaultsTable()
	local Defaults = {}
	for k,sParameterName in pairs( self.Parameters_Names ) do
		local sType = self.Parameters[sParameterName].Type
		local sFullConvarName = "dhonline_theme_".. self:GetRawName() .."_".. sParameterName
		
		local stSuffixes = dhonline.GetParamSuffixes( sType )
		local ttDefaults = self.Parameters[sParameterName].Defaults
		
		if stSuffixes == nil then
			Defaults[sFullConvarName] = tostring(ttDefaults)
			
		elseif type(stSuffixes) == "table" then
			for k,sSuffix in pairs( stSuffixes ) do
				Defaults[sFullConvarName .. "_" .. sSuffix] = tostring(ttDefaults[k] or ttDefaults[1] or ttDefaults)
			end
		end
		
	end
	
	Defaults["dhonline_core_ui_spacing"] = 1
	
	return Defaults
end

function THEME:GetElementsConvarTable()
	local sThemeName = self:GetRawName()
	local ConVars = {}
	for k,sName in pairs(self.Elements_Names) do
		local sCvarPrefix = "dhonline_element_" .. sThemeName .. "_" .. sName
		
		table.insert(ConVars, sCvarPrefix)
		table.insert(ConVars, sCvarPrefix .. "_x")
		table.insert(ConVars, sCvarPrefix .. "_y")
	end
	return ConVars
end

function THEME:GetElementsDefaultsTable()
	local sThemeName = self:GetRawName()
	local Defaults = {}
	for k,sName in pairs(self.Elements_Names) do
		local sCvarPrefix = "dhonline_element_" .. sThemeName .. "_" .. sName
		
		Defaults[sCvarPrefix]         = ( not (self.Elements[sName].DefaultOff or false ) ) and "1" or "0"
		Defaults[sCvarPrefix .. "_x"] = self.Elements[sName].DefaultGridPosX
		Defaults[sCvarPrefix .. "_y"] = self.Elements[sName].DefaultGridPosY
	end
	return Defaults
end

local dhi_theme_meta = {__index=THEME}



function Register( sName, dTheme )
	if Themes[sName] then return end
	
	if DHONLINE_DEBUG then print(DHONLINE_NAME .. " >> Registering Theme ["..sName.."]") end
	
	dTheme._rawname = sName
	dTheme.Name = dTheme.Name or sName
	
	setmetatable(dTheme, dhi_theme_meta)
	
	//if dTheme.Initialize then dTheme:Initialize() end
	Themes[sName] = dTheme
	table.insert(Themes_Names, sName)
end

function GetCurrentTheme()
	if Themes[Theme_Select] then
		return Theme_Select
	else
		return DHONLINE_DEFAULTTHEME
	end
end

function SetTheme( sName )
	local selTheme = dhonline_theme.GetCurrentTheme()
	if not Themes[sName] then sName = dhonline_theme.GetCurrentTheme() end
	
	if Themes[selTheme] then Themes[selTheme]:Unmount() end
	Themes[sName]:Mount()
	
	Theme_Select = sName
end

function GetCurrentThemeObject()
	return Themes[dhonline_theme.GetCurrentTheme()]
end

function GetThemeObject( sName )
	if not Themes[sName] then return end
	
	return Themes[sName]
end

function GetNamesTable()
	return table.Copy( Themes_Names )
end

function RemoveAll()
	local selTheme = dhonline_theme.GetCurrentTheme()
	if Themes[selTheme] then Themes[selTheme]:Unmount() end
	
	selTheme = ""
	table.Empty(Themes_Names)
	table.Empty(Themes)
end
