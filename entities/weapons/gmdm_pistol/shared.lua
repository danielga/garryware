
if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

SWEP.Base				= "gmdm_base"
SWEP.PrintName			= "#Pistol"			
SWEP.Slot				= 1
SWEP.SlotPos			= 0
SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= true
SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

function SWEP:Initialize()

	self:GMDMInit()
	self:SetWeaponHoldType( "pistol" )
	
end

local ShootSound = Sound( "Weapon_Pistol.NPC_Single" )

SWEP.RunArmAngle  = Angle( 70, 0, 0 )
SWEP.RunArmOffset = Vector( 25, 4, 0 )

/*---------------------------------------------------------
   PRIMARY
   Semi Auto
---------------------------------------------------------*/

SWEP.Primary.ClipSize		= 12
SWEP.Primary.DefaultClip	= 12
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Pistol"

function SWEP:PrimaryAttack()

	self.Weapon:SetNextPrimaryFire( CurTime() + 0.1 )
	self.Weapon:SetNextSecondaryFire( CurTime() + 0.1 )
	
	if ( !self:CanShootWeapon() ) then return end
	if ( !self:CanPrimaryAttack() ) then return end
	
	self:GMDMShootBullet( 15, ShootSound, math.Rand( -1, -0.5 ), math.Rand( -1, 1 ) )
	
	self:TakePrimaryAmmo( 1 )

end


/*---------------------------------------------------------
   SECONDARY
   Automatic (Uses Primary Ammo)
---------------------------------------------------------*/

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:SecondaryAttack()
	return false
end



