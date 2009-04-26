
HUDParticleThinkTime = CurTime()
HUDParticles = {}

function HUDThinkAboutParticles()
	if CurTime() - HUDParticleThinkTime > 0.05 then
		for k,sprite in pairs(HUDParticles) do
			if sprite:IsValid() == false then
				table.remove(HUDParticles,k)
			else
				local sx,sy = sprite:GetPos()
				sprite.Velocity.y = sprite.Velocity.y + sprite.grav
				sprite:MoveTo(sx + (sprite.Velocity.x*0.1)*sprite.resist, sy + (sprite.Velocity.y*0.1)*sprite.resist, 0.0001/FrameTime(),0)
			end
		end
	end
end

function HUDMakeParticles(materialpath,number,duration,posx,posy,sizemin,sizemax,sizeendmin,sizeendmax,dir_angle,diffusemin,diffusemax,distancemin,distancemax,color,colorend,gravity,resist)
	local sprite
	local randang
	local distance
	local sizeto
	local materialdec = Material(materialpath)
	for i=1,number do
		sprite = CreateSprite( materialdec )
		sprite:SetTerm( duration )
		sprite:SetPos( posx, posy )
		
		size = math.random(sizemin,sizemax)
		sprite:SetSize( size, size )
		sprite:SetColor( color )
		
		randang = math.rad( dir_angle + math.random(diffusemin,diffusemax) )
		distance = math.random(distancemin,distancemax)
		sprite.Velocity = Vector(math.cos(randang)*distance,math.sin(randang)*distance,0)
		sprite:MoveTo(posx + sprite.Velocity.x*0.1, posy + sprite.Velocity.y*0.1, 0.0001/FrameTime(),0)
		
		sizeto = math.random(sizeendmin,sizeendmax)
		sprite:SizeTo( sizeto, sizeto, duration, 0 )
		sprite:ColorTo( colorend, duration, 0 )
		
		sprite.grav = gravity
		sprite.resist = resist
		
		sprite:SetZPos(-128)
		
		table.insert(HUDParticles,sprite)
	end
end

/*
local function RemoteMakeParticles( m )
	local data = m:GetDecodedData()
	HUDMakeParticles(data.materialpath,data.number,data.duration,data.posx_rel*ScrW(),data.posy*ScrH(),data.sizemin,data.sizemax,data.sizeendmin,data.sizeendmax,data.dir_angle,data.diffusemin,data.diffusemax,data.distancemin,data.distancemax,data.color,data.colorend,data.gravity,data.resist)
end
datastream.Hook( "RemoteMakeParticles", RemoteMakeParticles )
*/

Sharpen = 0
MotionBlur = 0
ViewWobble = 0
ColorModify = {}
ColorModify[ "$pp_colour_addr" ] 		= 0
ColorModify[ "$pp_colour_addg" ] 		= 0
ColorModify[ "$pp_colour_addb" ] 		= 0
ColorModify[ "$pp_colour_brightness" ] 	= 0
ColorModify[ "$pp_colour_contrast" ] 	= 1.2
ColorModify[ "$pp_colour_colour" ] 		= 1
ColorModify[ "$pp_colour_mulr" ] 		= 0
ColorModify[ "$pp_colour_mulg" ] 		= 1
ColorModify[ "$pp_colour_mulb" ] 		= 1

local function DrawInternal()

	if ( Sharpen > 0 ) then
		DrawSharpen( Sharpen, 0.5 )
		Sharpen = math.Approach( Sharpen, 0, FrameTime() * 0.5 )
	end

	if ( MotionBlur > 0 ) then
		DrawMotionBlur( 1 - MotionBlur, 1.0, 0.0 )
		MotionBlur = MotionBlur - 0.1 * FrameTime()
	end
	
	local approach = FrameTime() * 0.3
	
	ColorModify[ "$pp_colour_mulr" ] 		= math.Approach( ColorModify[ "$pp_colour_mulr" ], 0, approach )
	ColorModify[ "$pp_colour_mulg" ]		= math.Approach( ColorModify[ "$pp_colour_mulg" ], 0, approach )
	ColorModify[ "$pp_colour_mulb" ] 		= math.Approach( ColorModify[ "$pp_colour_mulb" ], 0, approach )
	ColorModify[ "$pp_colour_colour" ] 		= math.Approach( ColorModify[ "$pp_colour_colour" ], 1, approach )
	ColorModify[ "$pp_colour_brightness" ] 	= math.Approach( ColorModify[ "$pp_colour_brightness" ], 0, approach )
	ColorModify[ "$pp_colour_addr" ] 		= math.Approach( ColorModify[ "$pp_colour_addr" ], 0, approach )
	ColorModify[ "$pp_colour_addg" ] 		= math.Approach( ColorModify[ "$pp_colour_addg" ], 0, approach )
	ColorModify[ "$pp_colour_addb" ] 		= math.Approach( ColorModify[ "$pp_colour_addb" ], 0, approach )
	
	DrawColorModify( ColorModify )
	
	if not LocalPlayer():Alive() then
		Sharpen = 0
		MotionBlur = 0
		ViewWobble = 0
	end

end
hook.Add( "RenderScreenspaceEffects", "RenderPostProcessing", DrawInternal )


local WalkTimer = 0
local VelSmooth = 0

function GM:CalcView( ply, origin, angle, fov )

	local vel = ply:GetVelocity()
	local ang = ply:EyeAngles()
	
	VelSmooth = VelSmooth * 0.5 + vel:Length() * 0.1
	WalkTimer = WalkTimer + VelSmooth * FrameTime() * 0.1
	
	angle.roll = angle.roll + ang:Right():DotProduct( vel ) * 0.005
	
	// motion sickness
	if ViewWobble > 0 then
		angle.roll = angle.roll + math.sin(CurTime() * 2.5) * (ViewWobble * 15)
		ViewWobble = ViewWobble - 0.1 * FrameTime()
	end
	
	// make their view tilt when they strafe
	if ply:GetGroundEntity() != NULL then	
		angle.roll = angle.roll + math.sin( WalkTimer ) * VelSmooth * 0.001
		angle.pitch = angle.pitch + math.sin( WalkTimer * 0.3 ) * VelSmooth * 0.001
	end
		
	return self.BaseClass:CalcView( ply, origin, angle, fov )
	
end
