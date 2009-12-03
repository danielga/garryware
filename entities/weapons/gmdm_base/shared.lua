////////////////////////////////////////////////
// -- Garry's Mod Deathmatch Weapon Base      //
// by SteveUK                                 //
//--------------------------------------------//
////////////////////////////////////////////////

SWEP.ViewModelFOV	= 55

GMDMLastShoot = 0

SWEP.CustomSecondaryAmmo = false
SWEP.Primary.Ammo = "Buckshot"

SWEP.HoldType = "smg"

SWEP.AllowRicochet = true
SWEP.AllowPenetration = true

SWEP.PenetrationMax = 32
SWEP.PenetrationMaxWood = 128
SWEP.MaxRicochet = 1
SWEP.ImpactEffects = true

SWEP.CanSprintAndShoot = false

function SWEP:Initialize()

	if(SERVER ) then
		self:SetWeaponHoldType( self.HoldType )
		self:SetNPCMinBurst( 30 )
		self:SetNPCMaxBurst( 30 )
		self:SetNPCFireRate( 0.01 )
	end
	
	self.Weapon:SetNetworkedBool( "Ironsights", false )
end

SWEP.SprayTime = 0.1
SWEP.SprayAccuracy = 0.5

function SWEP:GetStanceAccuracyBonus( )

	if( self.Owner:IsNPC() ) then
		return 0.8
	end
	
	if( self.ConstantAccuracy ) then
		return 1.0
	end
	
	local LastAccuracy = self.LastAccuracy or 0
	local Accuracy = 1.0
	local LastShoot = GMDMLastShoot
	
	local speed = self.Owner:GetVelocity():Length()
	-- 200 walk, 500 sprint, 705 noclip
	local speedperc = math.Clamp( math.abs( speed / 705 ), 0, 1 )	
	
	if( CurTime() <= LastShoot + self.SprayTime ) then
		Accuracy = Accuracy * self.SprayAccuracy
	end
	
	if( speed > 10 ) then -- moving
		Accuracy = Accuracy * ( ( ( 1 - speedperc ) + 0.1 ) / 1.5 )
	end
	
	if( self.Owner:KeyDown( IN_DUCK ) == true ) then -- ducking moving forward
		Accuracy = Accuracy * 1.75
	end

	if( self.Owner:KeyDown( IN_LEFT ) or self.Owner:KeyDown( IN_RIGHT ) ) then -- just strafing
		Accuracy = Accuracy * 0.95
	end
	
	if( LastAccuracy != 0 ) then
		if( Accuracy > LastAccuracy ) then
			Accuracy = math.Approach( self.LastAccuracy, Accuracy, FrameTime() * 2 )
		else
			Accuracy = math.Approach( self.LastAccuracy, Accuracy, FrameTime() * -2 )
		end
	end
	
	self.LastAccuracy = Accuracy
	return Accuracy
	
end


function SWEP:GMDMShootBullet( dmg, snd, pitch, yaw, numbul, cone )

	if( not self ) then return end
	
	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01
	
	if( self.Owner and self.Owner:IsPlayer() ) then
		self.Owner:SetNetworkedInt( "BulletType", 0 ) -- 0 = normal hit (no ricochet or wallbang)
	end
	
	if( self.GMDMShootBulletEx ) then
		self:GMDMShootBulletEx( dmg, numbul, cone, 1 )
	end
	
	if not IsFirstTimePredicted() then return end

	if( snd != nil ) then
		self.Weapon:EmitSound( snd )
	end

	if( self.Owner and self.Owner:IsPlayer() ) then
		self.Owner:Recoil( pitch, yaw )
	end
	
	// Make gunsmoke
	local effectdata = EffectData()
		effectdata:SetOrigin( self.Owner:GetShootPos() )
		effectdata:SetEntity( self.Weapon )
		effectdata:SetStart( self.Owner:GetShootPos() )
		effectdata:SetNormal( self.Owner:GetAimVector() )
		effectdata:SetAttachment( 1 )
	util.Effect( "GMDM_GunSmoke", effectdata )
	
	//if ( SinglePlayer() and CLIENT ) then return end
	//if ( not SinglePlayer() and SERVER ) then return end
	
	//util.ScreenShake( self.Owner:GetShootPos(), 100, 0.2, 0.5, 256 )
	
	self:NoteGMDMShot()
	
end


function SWEP:BulletPenetrate( bouncenum, attacker, tr, dmginfo, isplayer )
end

function SWEP:RicochetCallback( bouncenum, attacker, tr, dmginfo )

	if( not self ) then return end
	
	local DoDefaultEffect = false
	if ( not tr.HitWorld ) then DoDefaultEffect = true end
	if ( tr.HitSky ) then return end
	
	if ( tr.MatType != MAT_METAL ) then

		 if ( tr.MatType != MAT_FLESH and self.ImpactEffects ) then
		 
			local effectdata = EffectData()
				effectdata:SetOrigin( tr.HitPos )
				effectdata:SetNormal( tr.HitNormal )
				effectdata:SetScale( dmginfo:GetDamage() / 10000 )
			util.Effect( "GMDM_HitSmoke", effectdata )			
			
			if ( SERVER ) then
				util.ScreenShake( tr.HitPos, 100, 0.2, 1, 128 )
			end
			
		end

		return
	end
	
	if( self.AllowRicochet == false ) then return { damage = true, effects = DoDefaultEffect } end
	
	if ( bouncenum > self.MaxRicochet ) then return end
	
	// Bounce vector (Don't worry - I don't understand the maths either :x)
	local DotProduct = tr.HitNormal:Dot( tr.Normal * -1 )
	local Dir = ( 2 * tr.HitNormal * DotProduct ) + tr.Normal
	Dir:Normalize()
	
	local bullet = 
	{	
		Num 		= 1,
		Src 		= tr.HitPos,
		Dir 		= Dir,	
		Spread 		= Vector( 0.05, 0.05, 0 ),
		Tracer		= 1,
		TracerName 	= "GMDM_RicochetTrace",
		Force		= 5,
		Damage		= damage,
		AmmoType 	= "Pistol",
		HullSize	= 2
	}
		
	-- BLaNK
	-- Added conditional to stop errors when bullets ricoshet after weapon switch.
	bullet.Callback    = function( a, b, c ) if( self.RicochetCallback ) then return self:RicochetCallback( bouncenum+1, a, b, c ) end end
	
	timer.Simple( 0.05, attacker.FireBullets, attacker, bullet, true )
	attacker:SetNetworkedInt( "BulletType", 2 ) -- 2 = Ricochet
	
	return { damage = true, effects = DoDefaultEffect }
		
end

function SWEP:RicochetCallback_Redirect( a, b, c ) return self:RicochetCallback( 0, a, b, c ) end


function SWEP:WeaponKilledPlayer( pl, dmginfo )
	Msg( "[GMDM] Weapon " .. self:GetClass() .. " owned by " .. self:GetOwner():Name() .. " killed player " .. pl:Name() .. "\n" )
end

function SWEP:NoteGMDMShot()
	GMDMLastShoot = CurTime()
	
	// No prediction in SP. Make sure it knows when we last shot.
	if ( SinglePlayer() ) then
		self.Owner:SendLua( "GMDMLastShoot = CurTime()" )
	end

end

function SWEP:Reload()
	local canReload = self.Weapon:DefaultReload( ACT_VM_RELOAD )
	if canReload and self.Weapon.CustomReload then
		self.Weapon:CustomReload()
	end
end

function SWEP:CanShootWeapon()

	if( self.Owner:IsNPC() ) then
		return true
	end
	
	// Cannot fire weapon if we were running less than 0.1 second ago.
	if( self.CanSprintAndShoot == false ) then
		if( self.Owner:KeyDown( IN_SPEED ) ) then return false end
		if ( self.LastSprintTime and CurTime() - self.LastSprintTime < 0.1 ) then return false end
	end
	
	return true

end

function SWEP:Think()

	// Keep track of the last time we were running while holding this weapon..
	if ( self.Owner and self.Owner:KeyDown( IN_SPEED ) ) then
		self.LastSprintTime = CurTime()
	end

end

////////////////////////////////////////////////
// Return true to allow the weapon to holster.

function SWEP:Holster( wep )
	return true
end

function SWEP:Deploy()
	return true
end


////////////////////////////////////////////////
// A convenience function to shoot bullets

function SWEP:GMDMShootBulletEx( damage, num_bullets, aimcone, tracerfreq )
	
	if( self.SupportsSilencer and self.Weapon:GetNetworkedBool( "Silenced", false ) == true ) then
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK_SILENCED )
	else
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		// View model animation
	end
	self.Owner:MuzzleFlash()							// Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )			// 3rd Person Animation
	
	/* 
	   This seems to partially fix the "stream of bullets",
	   but even when it's protected, the tracer is still seen multiple times,
	   the p228 is especially bad.
	*/
	if not IsFirstTimePredicted() then return end

	local bullet = {}
	bullet.Num 		= num_bullets
	bullet.Src 		= self.Owner:GetShootPos()			// Source
	bullet.Dir 		= self.Owner:GetAimVector()			// Dir of bullet
	bullet.Spread 	= Vector( aimcone, aimcone, 0 )		// Aim Cone
	bullet.Tracer	= tracerfreq						// Show a tracer on every x bullets 
	bullet.Force	= 10								// Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.AmmoType = "Pistol"
	bullet.TracerName 	= "Tracer"
	bullet.HullSize	= 4
	bullet.Callback    = function( a, b, c ) return self:RicochetCallback_Redirect( a, b, c ) end
	
	self.Owner:FireBullets( bullet )
	
end

/*---------------------------------------------------------
   Name: SWEP:CustomAmmoCount()
			Should report the amount of 'custom' ammo left.
---------------------------------------------------------*/
function SWEP:CustomAmmoCount()
	return 0
end

////////////////////////////////////////////////
////////////////////////////////////////////////