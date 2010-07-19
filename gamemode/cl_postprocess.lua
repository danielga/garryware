////////////////////////////////////////////////
// // GarryWare Gold                          //
// by Hurricaaane (Ha3)                       //
//  and Kilburn_                              //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Post-processing                            //
////////////////////////////////////////////////

local Sharpen = 0
local MotionBlur = 0
local ViewWobble = 0
local ColorModify = {}
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
	if not SPECTATE_RAGDOLLTIME then
		self.LastRagdollUndetect = 0
		SPECTATE_RAGDOLLTIME = 2.5
	end
	
	local hasRagdoll = ValidEntity( LocalPlayer():GetRagdollEntity() )
	if hasRagdoll and (CurTime() < ( self.LastRagdollUndetect + SPECTATE_RAGDOLLTIME)) then -- Death Ragdoll
		local ragdoll = LocalPlayer():GetRagdollEntity()
		local attachment = ragdoll:GetAttachment( 1 )
		
		if not ragdoll.triedHeadSnap then
			ragdoll.BuildBonePositions = function( self, numbones, numphysbones )
				if not self.s__boneid then
					self.s__boneid = ragdoll:LookupBone("ValveBiped.Bip01_Head1")
				end
				if self.s__boneid and self.s__boneid ~= -1 then
					local matBone = ragdoll:GetBoneMatrix( self.s__boneid )
					matBone:Scale( Vector( 0.01, 0.01, 0.01 ) )
					ragdoll:SetBoneMatrix( self.s__boneid, matBone )
					
				end
			end
			ragdoll.triedHeadSnap = true
			
		end

		origin = attachment.Pos - attachment.Ang:Forward() * 0.4
		angle  = attachment.Ang
		
	else
		if not hasRagdoll then
			self.LastRagdollUndetect = CurTime()
		end
		
		local vel = ply:GetVelocity()
		local ang = ply:EyeAngles()
		
		VelSmooth = VelSmooth * 0.5 + vel:Length() * 0.1
		WalkTimer = WalkTimer + VelSmooth * FrameTime() * 0.1
		
		angle.roll = angle.roll + ang:Right():DotProduct( vel ) * 0.005
		
		-- Motion Sickness
		if ViewWobble > 0 then
			angle.roll = angle.roll + math.sin(CurTime() * 2.5) * (ViewWobble * 15)
			ViewWobble = ViewWobble - 0.1 * FrameTime()
		end
		
		-- Make their view tilt when they strafe
		if ply:GetGroundEntity() ~= NULL then	
			angle.roll = angle.roll + math.sin( WalkTimer ) * VelSmooth * 0.001
			angle.pitch = angle.pitch + math.sin( WalkTimer * 0.3 ) * VelSmooth * 0.001
		end
	end
		
	return self.BaseClass:CalcView( ply, origin, angle, fov )
	
end

function GM:GetMotionBlurValues( x, y, fwd, spin )
	if( ValidEntity( LocalPlayer() ) and ( not LocalPlayer():IsOnGround() or LocalPlayer():KeyDown( IN_SPEED ) )) then
		fwd = fwd * 5
	end
	
	return x, y, fwd, spin
end
