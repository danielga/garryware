WARE.Author = "Hurricaaane (Ha3)"
WARE.Room = "empty"

local circlecolor = Color(185,220,255,255)

WARE.CircleRadius = 64

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(3,4)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Don't be on the circles !",1)
	
	local entsky = GAMEMODE:GetEnts("dark_inair")
	self.zsky = entsky[1]:GetPos().z
	
	local ratio = 0.6
	local num = #GAMEMODE:GetEnts({"dark_ground","light_ground"})*ratio
	local entposcopy = GAMEMODE:GetRandomLocations(num, {"dark_ground","light_ground"} )
	for k,v in pairs(entposcopy) do
		local ent = ents.Create("ware_ringzone");
		ent:SetPos(v:GetPos() + Vector(0,0,4) )
		ent:SetAngles(Angle(0,0,0));
		ent:Spawn();
		ent:Activate()
		
		ent:SetZSize(self.CircleRadius*2)
		GAMEMODE:AppendEntToBin(ent)
		
		ent:SetNWString("selcolor","lightblue")
		ent:SetZColor(circlecolor)
		
		ent.LastActTime = 0

		GAMEMODE:AppendEntToBin(ent)
		GAMEMODE:MakeAppearEffect(ent:GetPos())
	end
	for k,v in pairs(player.GetAll()) do 
		v:SetFriction(1000)
	end
	
	
	return
end

function WARE:StartAction()
	for _,v in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do
		v:Give( "ware_weap_crowbar" )
	end
	return
end

function WARE:EndAction()
	for k,v in pairs(player.GetAll()) do 
		v:SetFriction(1)
	end
end


function WARE:Think( )
	for k,ring in pairs(ents.FindByClass("ware_ringzone")) do
		local sphere = ents.FindInSphere(ring:GetPos(),self.CircleRadius)
		for _,target in pairs(sphere) do
			if target:IsPlayer() then
				target:WarePlayerDestinyLose()
			end
			
			if target:IsPlayer() or ( target:GetClass() == "ware_proj_crowbar" ) then
				if (CurTime() > (ring.LastActTime + 0.2)) then
					ring.LastActTime = CurTime()
					ring:EmitSound("ambient/levels/labs/electric_explosion1.wav")
					
					local effectdata = EffectData( )
						effectdata:SetOrigin( ring:GetPos( ) )
						effectdata:SetNormal( Vector(0,0,1) )
					util.Effect( "waveexplo", effectdata, true, true )
					
					if (target:IsPlayer() == false) then
						target:EmitSound("weapons/flame_thrower_airblast_rocket_redirect.wav")
						target:GetPhysicsObject():ApplyForceCenter((target:GetPos() - ring:GetPos()):Normalize() * 150000)
						
						if ((target.Deflected or false) == false) then
							target.Deflected = true
							local trail_entity = util.SpriteTrail( target,  //Entity
																	0,  //iAttachmentID
																	Color( 255, 255, 255, 255 ),  //Color
																	false, // bAdditive
																	8, //fStartWidth
																	0, //fEndWidth
																	0.2, //fLifetime
																	1 / ((0.7+1.2) * 0.5), //fTextureRes
																	"trails/tube.vmt" ) //strTexture
						end
						
						
					else
						target:SetGroundEntity( NULL )
						target:SetVelocity(target:GetVelocity()*(-1) + (target:GetPos() + Vector(0,0,32) - ring:GetPos()):Normalize() * 500)
					end
				
				end
			end
		end
	end
	for k,ent in pairs(ents.FindByClass("ware_proj_crowbar")) do
		if (ent:GetPos().z > self.zsky) then
			ent:GetPhysicsObject():ApplyForceCenter(Vector(0,0,-1)*15000)
		end
	end
end
