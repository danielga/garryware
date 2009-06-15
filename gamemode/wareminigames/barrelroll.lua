WARE.Author = "Hurricaaane (Ha3)"
--WARE.Room = ""

//Temporary disable
function WARE:IsPlayable()
	return false
end

--STILL WORK IN PROGRESS
/*
function WARE:IsPlayable()
	return false --Game only plays on debug.
end
*/
function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(1,5)
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Do a barrel roll !",0)
	return
end

function WARE:StartAction()
	for k,pl in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		pl.Barrel = ents.Create( "player_barrel" )
		
		pl.Barrel:SetPlayer( pl )
		pl.Barrel:SetPos( pl:GetPos() + Vector( 0, 0, 16 ) )
			
		pl.Barrel:Spawn()
		pl:SetNWEntity( "Barrel", pl.Barrel )
		
		pl:SpectateEntity( pl.Barrel )
		pl:Spectate( OBS_MODE_CHASE )
	end
	return
end

function WARE:EndAction()
	for k,pl in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		pl:UnSpectate( )
		pl.Barrel:Remove()
		pl:SetEyeAngles(Angle(0,0,0))
		
		GAMEMODE:PlayerSetModel(pl)
	end
	for k,pl in pairs(player.GetAll()) do 
		if pl.Barrel != nil then
			pl:SpectateEntity( nil )
			pl.Barrel:Remove()
		end
		pl:Spawn()
	end
end

function WARE:Think( )
	for k,pl in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
		if pl.Barrel then
			pl:SetPos( pl.Barrel:GetPos() )
			local phys = pl.Barrel:GetPhysicsObject()
			local angvel = phys:GetAngleVelocity()
			local roll = pl.Barrel:GetNWFloat("roll", 0) + angvel.z * FrameTime()
			pl.Barrel:SetNWFloat("roll", roll )
			if roll > 360 || roll < -360 then
				pl:WarePlayerDestinyWin( )
			end
		end
	end
end
