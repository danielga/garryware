WARE.Author = "Hurricaaane (Ha3)"
WARE.Room = "hexaprism"

WARE.Models = {
"models/Combine_turrets/Ceiling_turret.mdl",
"models/props_c17/gravestone003a.mdl",
"models/props_junk/TrashBin01a.mdl",
"models/props_c17/FurnitureFridge001a.mdl",
"models/props_c17/oildrum001.mdl",
"models/props_debris/metal_panel02a.mdl",
"models/props_interiors/Radiator01a.mdl",
"models/props_interiors/refrigeratorDoor01a.mdl",
"models/props_junk/wood_crate001a.mdl"
 }
 
WARE.StringPos = {
"land_a",
"land_b",
"land_c",
"land_d",
"land_e",
"land_f"
}

WARE.Positions = {}

function WARE:IsPlayable()
	return false
end

function WARE:GetModelList()
	return self.Models
end


function WARE:Initialize()
	GAMEMODE:RespawnAllPlayers( true, true )
	
	GAMEMODE:SetWareWindupAndLength(2, 8)
	
	GAMEMODE:SetPlayersInitialStatus( false )
	GAMEMODE:DrawInstructions( "Grab a prop!" )
	
	local pitposz = GAMEMODE:GetEnts("pit_measure")[1]:GetPos().z
	local aposz   = GAMEMODE:GetEnts("land_measure")[1]:GetPos().z
	self.zlimit = pitposz + (aposz - pitposz) * 0.8
	
	local ratio = 1.2
	local minimum = 3
	local num = math.Clamp(math.ceil( team.NumPlayers(TEAM_HUMANS) * ratio) , minimum, 64)
	
	self.Positions = {}
	local centerpos    = GAMEMODE:GetEnts("center")[1]:GetPos()
	local alandmeasure = math.floor((GAMEMODE:GetEnts("land_a")[1]:GetPos() - centerpos):Length() * 0.5)
	for i=1,num do
		table.insert( self.Positions, Vector(0,0,192) + centerpos + Angle(0, math.random(0,360), 0):Forward() * math.random(alandmeasure * 0.5, alandmeasure) )
	end
	
	for _,pos in ipairs(self.Positions) do
		local prop = ents.Create("prop_physics")
		prop:SetModel("models/props_wasteland/laundry_cart001.mdl")
		prop:SetPos(pos)
		prop:SetAngles(Angle(math.random(-180,180),math.random(-180,180),math.random(-180,180)))
		prop:Spawn()
		
		GAMEMODE:AppendEntToBin(cart)
		GAMEMODE:MakeAppearEffect(pos)
	end
	
end

function WARE:GravGunOnPickedUp(ply, ent)
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent:SetColor(Color(255,255,255,100))
	ent.CartOwner=ply
	ply.Cart=ent
end

function WARE:StartAction()	

end

function WARE:EndAction()

end

function WARE:Think( )
	for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		if v:GetPos().z < self.zlimit then
			v:ApplyLose( )
		end
	end
end
