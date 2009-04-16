if (SERVER) then
   AddCSLuaFile ("shared.lua");

   SWEP.Weight = 5;
   SWEP.AutoSwitchTo = false;
   SWEP.AutoSwitchFrom = false;
end

if (CLIENT) then
   SWEP.PrintName = "PROJECTILE CROWBAR";
   SWEP.Slot = 1;
   SWEP.SlotPos = 3;
   SWEP.DrawAmmo = false;
   SWEP.DrawCrosshair = true;
end

/*
SWEP.Author = "Hurricaaane";
SWEP.Contact = "http://www.youtube.com/profile?user=Hurricaaane";
SWEP.Purpose = "Projectile Crowbar";
SWEP.Instructions = "Left click throws a crowbar.";
*/

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.ViewModel		= "models/weapons/v_crowbar.mdl"		
SWEP.WorldModel		= "models/weapons/w_crowbar.mdl"

SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo = "none";

SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo = "none";

SWEP.Delay = 0.3
SWEP.TickDelay = 0.1

local ShootSound = Sound ("weapons/slam/throw.wav");

function SWEP:Think()
end

function SWEP:ThrowCrowbar(shotPower)
	local tr = self.Owner:GetEyeTrace();

	if (!SERVER) then return end;

	local ent = ents.Create ("ware_proj_crowbar");	

	local Forward = self.Owner:EyeAngles():Forward()
	ent:SetPos( self.Owner:GetShootPos() + Forward * 0 )
	ent:SetAngles (self.Owner:EyeAngles());
	ent:Spawn();
	ent:SetOwner(self.Owner)
	ent:Activate( )
	
	local trail_entity = util.SpriteTrail( ent,  //Entity
											0,  //iAttachmentID
											Color( 255, 255, 255, 92 ),  //Color
											false, // bAdditive
											0.7, //fStartWidth
											1.2, //fEndWidth
											0.4, //fLifetime
											1 / ((0.7+1.2) * 0.5), //fTextureRes
											"trails/physbeam.vmt" ) //strTexture
	
	local phys = ent:GetPhysicsObject()
	phys:ApplyForceCenter (self.Owner:GetAimVector():GetNormalized() * shotPower);
	
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.TickDelay ) 
end

function SWEP:PrimaryAttack()
	self.Weapon:EmitSound (ShootSound);
	
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW ) 		// View model animation
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				// 3rd Person Animation
	
	if (CLIENT) then return end
	self:ThrowCrowbar(100000);
	
	self.Owner:StripWeapon("ware_weap_crowbar");
end

function SWEP:SecondaryAttack()
end
