
local meta = FindMetaTable( "Player" )
if (!meta) then return end 

meta.OldPrintMessage = meta.PrintMessage;

-- Only useful when game starts since we're assuming every player is in the same environment
function meta:GetEnvironment()
	if #ents.FindByClass("func_wareroom")==0 then
		return ware_env.Get(1)
	end
	
	for _,v in pairs(ware_env.GetTable()) do
		if v.Players[self] then
			return v
		end
	end
end

function meta:GiveOverride(class)
	local w = ents.Create(class)
	w:SetPos(self:GetPos() + Vector(0,0,24))
	w:Spawn()
end

function meta:SetAchievedNoDestiny( hasAchievedInt )
	--You can't change the achieved status on someone who has a destiny
	--because he already earned the points
	if self:GetNWInt("ware_hasdestiny") > 0 then return end
	self:SetNWInt("ware_achieved",hasAchievedInt)
end

function meta:WarePlayerDestinyWin()
	if self:Team() != TEAM_UNASSIGNED       then return end
	if self:GetNWInt("ware_hasdestiny") > 0 then return end
	
	self:SetNWInt("ware_achieved", 1 )
	self:SetNWInt("ware_hasdestiny", 1 )
	self:EmitSound(GAMEMODE.WinOther)
	self:AddFrags( 1 )
	
	self:PrintMessage(HUD_PRINTCENTER , "Success !")
	local rp = RecipientFilter()
	rp:AddPlayer( self )
	umsg.Start("EventDestinySet", rp)
		umsg.Long(1)
	umsg.End()
	
	local ed = EffectData()
	ed:SetOrigin( self:GetPos() )
	util.Effect("ware_good", ed, true, true)
end

function meta:WarePlayerDestinyLose( )
	if self:Team() != TEAM_UNASSIGNED then return end
	if self:GetNWInt("ware_hasdestiny") > 0 then return end
	
	self:SetNWInt("ware_achieved", 0 )
	self:SetNWInt("ware_hasdestiny", 1 )
	
	self:EmitSound(GAMEMODE.LoseOther)
	self:AddDeaths( 1 )
	
	self:PrintMessage(HUD_PRINTCENTER , "Fail !")
	local rp = RecipientFilter()
	rp:AddPlayer( self )
	umsg.Start("EventDestinySet", rp)
		umsg.Long(0)
	umsg.End()
	
	local ed = EffectData()
	ed:SetOrigin( self:GetPos() )
	util.Effect("ware_bad", ed, true, true)
end

function meta:PrintMessage( t, m )

	if( t == HUD_PRINTCENTER ) then
		if( CLIENT ) then
			GAMEMODE:AddCenterMessage( m );
		else
			local rp = RecipientFilter();
			rp:AddPlayer( self );
					
			-- send our user message
			umsg.Start( "gmdm_printcenter", rp );
			umsg.String( m );
			umsg.End();		
		end
		
		return;
	end
	
	return self:OldPrintMessage( t, m );
end

//
// Called by weapons to add recoil
//
function meta:Recoil( pitch, yaw )

	// On the client it can sometimes process the same usercmd twice
	// This function returns true if it's the first time we're doing this usercmd
	if ( !SinglePlayer() && !IsFirstTimePredicted() ) then return end

	// People shouldn't really be playing in SP
	// But if they are they won't get recoil because the weapons aren't predicted
	// So the clientside stuff never fires the recoil
	if ( SERVER && SinglePlayer() ) then 
	
		// Please don't call SendLua in multiplayer games. This uses a lot of bandwidth
		self:SendLua( "LocalPlayer():Recoil("..pitch..","..yaw..")" )
		return 
		
	end
	
	self.LastShoot = 0.5
	self.LastShootSize = math.abs(yaw) + math.abs(pitch)
	
	self.RecoilYaw = self.RecoilYaw or 0
	self.RecoilPitch = self.RecoilPitch or 0
	
	self.RecoilYaw = self.RecoilYaw 		+ yaw
	self.RecoilPitch = self.RecoilPitch 	+ pitch

end

//
// Shot attacked
//
function meta:DoRecoilThink( pitch, yaw )

	if ( SERVER ) then return end
	if ( self != LocalPlayer() ) then return end
	
	local pitch 	= self.RecoilPitch	or 0
	local yaw 		= self.RecoilYaw  	or 0
	
	pitch = pitch
	yaw = yaw
	
	local pitch_d	= math.Approach( pitch, 0.0, 20.0 * FrameTime() * math.abs(pitch) )
	local yaw_d		= math.Approach( yaw, 0.0, 20.0 * FrameTime() * math.abs(yaw) )
	
	self.RecoilPitch 	= pitch_d
	self.RecoilYaw 		= yaw_d
		
	// Update eye angles
	local eyes = self:EyeAngles()
		eyes.pitch = eyes.pitch + ( pitch - pitch_d )
		eyes.yaw = eyes.yaw + ( yaw - yaw_d )
		eyes.roll = 0
	self:SetEyeAngles( eyes )

end

//
// Think
//
function meta:Think( )

	// We spread the recoil out over a few frames to make it less of a shock
	// This function adds the recoil
	self:DoRecoilThink()

end
