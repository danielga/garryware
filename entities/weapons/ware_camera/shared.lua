
if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

SWEP.Base				= "gmdm_base"
SWEP.PrintName			= "Camera"			
SWEP.Slot				= 1
SWEP.SlotPos			= 0
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false
SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

function SWEP:Initialize()

	self:GMDMInit()
	self:SetWeaponHoldType( "pistol" )
	
end

local ShootSound = Sound( "NPC_CScanner.TakePhoto" )

SWEP.RunArmAngle  = Angle( 70, 0, 0 )
SWEP.RunArmOffset = Vector( 25, 4, 0 )

function SWEP:Deploy()

	self.Owner:DrawViewModel( false )

end

/*---------------------------------------------------------
   PRIMARY
   Semi Auto
---------------------------------------------------------*/

SWEP.Primary.ClipSize		= 2
SWEP.Primary.DefaultClip	= 2
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

function SWEP:PrimaryAttack()

	self.Weapon:SetNextPrimaryFire( CurTime() + 0.3 )
	self.Weapon:SetNextSecondaryFire( CurTime() + 0.3 )
	
	if ( !self:CanShootWeapon() ) then return end
	if ( !self:CanPrimaryAttack() ) then return end
	
	if (SERVER) then
		self.Weapon:SetNWFloat("phototick",CurTime())
		for k,target in pairs(team.GetPlayers(TEAM_UNASSIGNED)) do 
			
			local direction = (target:GetPos() - self.Owner:GetShootPos()):GetNormalized()
			local aiming  = self.Owner:GetAimVector()
			if (direction:DotProduct(aiming) > math.acos(math.rad(34)) && target != self.Owner) then
				local pos = self.Owner:GetShootPos()
				local targetpo = self.Owner:GetAimVector()
				local tracedata = {}
				tracedata.start = self.Owner:GetShootPos()
				tracedata.endpos = target:GetPos()
				tracedata.filter = {self.Owner , target}
				local trace = util.TraceLine(tracedata)
				if trace.Hit == false then
					GAMEMODE:WarePlayerDestinyLose( target )
				end 
			end
		end
	end
	
	self:TakePrimaryAmmo( 1 )
	self.Weapon:EmitSound( ShootSound )

end

function SWEP:DrawHUD()
	surface.SetDrawColor(0,0,0,255)
	surface.DrawRect( 0, 0, ScrW(), ScrH()*0.1 )
	surface.DrawRect( 0, ScrH() - ScrH()*0.1, ScrW(), ScrH()*0.1 )
	
	surface.DrawRect( 0, ScrH()*0.1 ,ScrW()*0.1, ScrH() - ScrH()*0.2 )
	surface.DrawRect( ScrW() - ScrW()*0.1, ScrH()*0.1 ,ScrW()*0.1, ScrH() - ScrH()*0.2 )
	
	local phototick = self.Weapon:GetNWFloat("phototick",0)
	if (CurTime() - phototick < 0.7) then
		surface.SetDrawColor(255,255,255,255 - math.Clamp(255*(CurTime() - phototick)/0.7,0,255))
		surface.DrawRect( 0, 0, ScrW(), ScrH() )
	end
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

function SWEP:TranslateFOV()
	return 40
end

