
if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

SWEP.Base				= "gmdm_base"
SWEP.PrintName			= "HLSS"			
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

function SWEP:Deploy()
	self.Owner:DrawViewModel( false )
end

function SWEP:PrimaryAttack()

end

function SWEP:DrawHUD()

end

function SWEP:SecondaryAttack()

end

function SWEP:Think()
	if (CLIENT) then
		if GetConVar("voice_inputfromfile"):GetInt() > 0 && self.Owner:IsSpeaking( ) then
			RunConsoleCommand("ware_hlss")
		end
	end
end
