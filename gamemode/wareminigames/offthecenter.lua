WARE.Author = "Hurricaaane (Ha3)"
WARE.Room = "hexaprism"
 
WARE.CircleRadius = 0
WARE.HeightLimit = 0

WARE.CenterEntity = nil

function WARE:IsPlayable()
	if team.NumPlayers(TEAM_HUMANS) >= 2 then
		return true
	end
	return false
end

function WARE:Initialize()
	self.LastThinkDo = 0
	
	GAMEMODE:RespawnAllPlayers( true, true )
	
	GAMEMODE:SetWareWindupAndLength(4, 4)
	
	GAMEMODE:SetPlayersInitialStatus( true )
	GAMEMODE:DrawInstructions( "Away from the center! Don't fall!" )
	
	do
		local centerpos = GAMEMODE:GetEnts("center")[1]:GetPos()
		local apos      = GAMEMODE:GetEnts("land_a")[1]:GetPos()
		self.CircleRadius = (centerpos - apos):Length() - 64
		
		local ent = ents.Create("ware_ringzone")
		ent:SetPos( centerpos + Vector(0,0,8) )
		ent:SetAngles( Angle(0,0,0) )
		ent:Spawn()
		ent:Activate()
		
		ent.LastActTime = 0
		
		ent:SetZSize(self.CircleRadius * 2.0)
		ent:SetZColor( Color(0,0,0) )
		
		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
		
		self.CenterEntity = ent
	end
	
	do
		local pitposz = GAMEMODE:GetEnts("pit_measure")[1]:GetPos().z
		local aposz   = GAMEMODE:GetEnts("land_measure")[1]:GetPos().z
		self.HeightLimit = pitposz + (aposz - pitposz) * 0.8
		
	end
	
end

function WARE:StartAction()	
	for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		v:Give( "sware_crowbar" )
	end
	return
end

function WARE:EndAction()

end

function WARE:Think( )
	for k,v in pairs(team.GetPlayers(TEAM_HUMANS)) do 
		if v:GetPos().z < self.HeightLimit then
			v:ApplyLose( )
		end
	end
	
	
	
	if (CurTime() < (self.LastThinkDo + 0.1)) then return end
	self.LastThinkDo = CurTime()
	
	local ring = self.CenterEntity
	local sphere = ents.FindInSphere(ring:GetPos(), self.CircleRadius*0.95)
	for _,target in pairs(sphere) do
		if target:IsPlayer() then
			target:ApplyLose()
		end
		
		if (target:IsPlayer() and target:IsWarePlayer()) then
			if (CurTime() > (ring.LastActTime + 0.2)) then
				ring.LastActTime = CurTime()
				ring:EmitSound("ambient/levels/labs/electric_explosion1.wav")
				
				local effectdata = EffectData( )
					effectdata:SetOrigin( ring:GetPos( ) )
					effectdata:SetNormal( Vector(0,0,1) )
				util.Effect( "waveexplo", effectdata, true, true )
				
				target:SetGroundEntity( NULL )
				target:SetVelocity(target:GetVelocity()*(-1) + (target:GetPos() + Vector(0,0,32) - ring:GetPos()):Normalize() * 500)
			
			end
		end
	end
end
