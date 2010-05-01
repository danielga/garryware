////////////////////////////////////////////////
// // Depth HUD : Inline                      //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// ConVar Reg Method - Static                 //
////////////////////////////////////////////////

dhonline.staticvars = {}

function dhonline.GetVar( sVarName, opt_bReturnString )
	if opt_bReturnString or false then
		return tostring(dhonline.staticvars[sVarName] or "")
	end
	return tonumber(dhonline.staticvars[sVarName] or 0)
end

function dhonline.CreateVar( sVarName, sContents, shouldSave, userData )
	dhonline.staticvars[sVarName] = tostring(sContents)
end

function dhonline.SetVar( sVarName, tContents )
	dhonline.staticvars[sVarName] = tostring(tContents)
end
