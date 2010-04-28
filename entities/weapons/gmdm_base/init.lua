////////////////////////////////////////////////
-- -- Garry's Mod Deathmatch Weapon Base      --
-- by SteveUK                                 --
//--------------------------------------------//
////////////////////////////////////////////////


AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
include( "ai_translations.lua" )

local ActIndex = {}
	ActIndex[ "pistol" ] 		= ACT_HL2MP_IDLE_PISTOL
	ActIndex[ "smg" ] 			= ACT_HL2MP_IDLE_SMG1
	ActIndex[ "grenade" ] 		= ACT_HL2MP_IDLE_GRENADE
	ActIndex[ "ar2" ] 			= ACT_HL2MP_IDLE_AR2
	ActIndex[ "shotgun" ] 		= ACT_HL2MP_IDLE_SHOTGUN
	ActIndex[ "rpg" ]	 		= ACT_HL2MP_IDLE_RPG
	ActIndex[ "physgun" ] 		= ACT_HL2MP_IDLE_PHYSGUN
	ActIndex[ "crossbow" ] 		= ACT_HL2MP_IDLE_CROSSBOW
	ActIndex[ "melee" ] 		= ACT_HL2MP_IDLE_MELEE
	ActIndex[ "slam" ] 			= ACT_HL2MP_IDLE_SLAM
	ActIndex[ "normal" ]		= ACT_HL2MP_IDLE
	
function SWEP:SetWeaponHoldType( t )

	local index = ActIndex[ t ]
	
	if (index == nil) then
		Msg( "Error! Weapon's act index is NIL!\n" )
		return
	end

	self.ActivityTranslate = {}
	self.ActivityTranslate [ ACT_HL2MP_IDLE ] 					= index
	self.ActivityTranslate [ ACT_HL2MP_WALK ] 					= index+1
	self.ActivityTranslate [ ACT_HL2MP_RUN ] 					= index+2
	self.ActivityTranslate [ ACT_HL2MP_IDLE_CROUCH ] 			= index+3
	self.ActivityTranslate [ ACT_HL2MP_WALK_CROUCH ] 			= index+4
	self.ActivityTranslate [ ACT_HL2MP_GESTURE_RANGE_ATTACK ] 	= index+5
	self.ActivityTranslate [ ACT_HL2MP_GESTURE_RELOAD ] 		= index+6
	self.ActivityTranslate [ ACT_HL2MP_JUMP ] 					= index+7
	self.ActivityTranslate [ ACT_RANGE_ATTACK1 ] 				= index+8
	
	self:SetupWeaponHoldTypeForAI( t )

end


////////////////////////////////////////////////
-- Translate a player's Activity into a weapon's activity
-- So for example, ACT_HL2MP_RUN becomes ACT_HL2MP_RUN_PISTOL
-- Depending on how you want the player to be holding the weapon.

function SWEP:TranslateActivity( act )

	if ( self.Owner:IsNPC() ) then
		if ( self.ActivityTranslateAI[ act ] ) then
			return self.ActivityTranslateAI[ act ]
		end
		return -1
	end

	if ( self.ActivityTranslate[ act ] ~= nil ) then
		return self.ActivityTranslate[ act ]
	end
	
	return -1

end

function SWEP:OnRestore()

end

function SWEP:AcceptInput( name, activator, caller )
	return false
end

function SWEP:KeyValue( key, value )

end

function SWEP:OnRemove()
end

function SWEP:Equip( NewOwner )

end

SWEP.EquipAmmo = SWEP.Equip

function SWEP:GetCapabilities()
	return CAP_WEAPON_RANGE_ATTACK1 | CAP_INNATE_RANGE_ATTACK1 | CAP_WEAPON_RANGE_ATTACK2 | CAP_INNATE_RANGE_ATTACK2
	
end

function SWEP:NPCShoot_Primary( ShootPos, ShootDir )
	self:PrimaryAttack()

end

function SWEP:NPCShoot_Secondary( ShootPos, ShootDir )
	self:PrimaryAttack()

end

function SWEP:Deploy()

	-- If it's silenced, we need to play a different anim.
	if( self.SupportsSilencer and self:GetNetworkedBool( "Silenced" ) == true ) then
		self:SendWeaponAnim( ACT_VM_DRAW_SILENCED )
	else
		self:SendWeaponAnim( ACT_VM_DRAW )
	end
	
	-- Quick switch.
	return true
end 

////////////////////////////////////////////////
////////////////////////////////////////////////