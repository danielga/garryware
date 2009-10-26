--Effects included in init.lua
function GM:MakeAppearEffect( pos )
	local ed = EffectData()
	ed:SetOrigin( pos )
	util.Effect("ware_appear", ed, true, true)
end

function GM:MakeDisappearEffect( pos )
	local ed = EffectData()
	ed:SetOrigin( pos )
	util.Effect("ware_disappear", ed, true, true)
end

function GM:MakeLandmarkEffect( pos )
	local ed = EffectData()
	ed:SetOrigin( pos )
	util.Effect("ware_landmark", ed, true, true)
end
