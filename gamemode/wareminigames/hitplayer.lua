WARE.Author = "Hurricaaane (Ha3)"
WARE.Room = "empty"

function WARE:IsPlayable()
	if team.NumPlayers(TEAM_HUMANS) >= 3 then
		return true
	end
	
	return false
end

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(2, 3)

	GAMEMODE:SetPlayersInitialStatus( false )
	GAMEMODE:DrawInstructions( "Hit a player!" )

	return
end

function WARE:StartAction()	
	for _,v in pairs(team.GetPlayers(TEAM_HUMANS)) do
		v:Give( "weapon_crowbar" )
	end
	
	return
end

function WARE:EndAction()
	for _,v in pairs(player.GetAll()) do
		v:SetColor(255, 255, 255, 255)
		if v:GetRagdollEntity() then
			v:GetRagdollEntity():Remove()
			
		end
		
	end
	
end


function WARE:EntityTakeDamage( ent, inflictor, attacker, amount )
	if not ValidEntity( ent ) or not ent:IsPlayer() or not ent:IsWarePlayer() then return end
	if not ValidEntity( attacker ) or not attacker:IsPlayer() or not attacker:IsWarePlayer() then return end
	
	attacker:ApplyWin( )
	if not ent:GetLocked() then ent:ApplyLose() end
	
	ent:SetColor(255, 255, 255, 64)
	ent:CreateRagdoll()
	ent:StripWeapons()
	local ragdollent = ent:GetRagdollEntity()
	
	if ValidEntity(ragdoll) then
		local ragphys = ragdoll:GetPhysicsObjectNum( 0 )
		ragphys:ApplyForceCenter( Vector(0, 0, 10000) )
	end
end
