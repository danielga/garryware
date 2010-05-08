////////////////////////////////////////////////
// // GarryWare Gold                          //
// by Hurricaaane (Ha3)                       //
//  and Kilburn_                              //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Usermessages and VGUI                      //
////////////////////////////////////////////////

gws_NextgameStart = 0
gws_NextwarmupEnd = 0
gws_NextgameEnd = 0
gws_WarmupLen = 0
gws_WareLen = 0
gws_TimeWhenGameEnds = 0
gws_TickAnnounce = 0

gws_PrecacheSequence = 0

gws_CurrentAnnouncer = 1

gws_AmbientMusic = {}
gws_AmbientMusicIsOn = false

local function ModelList( m )
	local numberOfModels = m:ReadLong()
	local currentModelCount = #GAMEMODE.ModelPrecacheTable
	local model = ""
	
	for i=1,numberOfModels do
		table.insert( GAMEMODE.ModelPrecacheTable, m:ReadString() )
	end
	
	gws_PrecacheSequence = (gws_PrecacheSequence or 0) + 1
	
	print( "Precaching sequence #".. gws_PrecacheSequence .."." )
	for k=(currentModelCount + 1),(currentModelCount + numberOfModels) do
		model = GAMEMODE.ModelPrecacheTable[ k ]
		--print( "Precaching model " .. k .. " : " .. model )
		util.PrecacheModel( model )
	end
end
usermessage.Hook( "ModelList", ModelList )

local function GameStartTime( m )
	gws_NextgameStart = m:ReadLong()
end
usermessage.Hook( "GameStartTime", GameStartTime )

local function ServerJoinInfo( m )
	local didnotbegin = false

	gws_TimeWhenGameEnds = m:ReadFloat()
	didnotbegin = m:ReadBool()
	
	if didnotbegin == true then
		WaitShow()
	end
	print("Game ends on time : "..gws_TimeWhenGameEnds)
end
usermessage.Hook( "ServerJoinInfo", ServerJoinInfo )

local function EnableMusicVolume()
	if gws_AmbientMusicIsOn then
		gws_AmbientMusic[1]:ChangeVolume( 0.7 )
	end
end

local function EnableMusic()
	if gws_AmbientMusicIsOn then
		gws_AmbientMusic[1]:Stop()
		gws_AmbientMusic[1]:Play()
		gws_AmbientMusic[1]:ChangeVolume( 0.1 )
		gws_AmbientMusic[1]:ChangePitch( GAMEMODE:GetSpeedPercent() )
		timer.Simple( GAMEMODE.WADAT.StartFlourishLength * 0.7 , EnableMusicVolume )
	end
end

local function DisableMusic()
	if not gws_AmbientMusicIsOn then
		gws_AmbientMusic[1]:ChangeVolume( 0.1 )
		--gws_AmbientMusic[1]:Stop()
	end
end

local function PlayEnding( musicID )
	local dataRef = GAMEMODE.WADAT.TBL_GlobalWareningEpic[musicID]
	
	LocalPlayer():EmitSound( GAMEMODE.WASND.TBL_GlobalWareningEpic[musicID] , 60, GAMEMODE:GetSpeedPercent() )
	gws_AmbientMusicIsOn = true
	gws_AmbientMusic[1]:Stop( )
	timer.Simple( dataRef.Length, EnableMusic )
end

local function NextGameTimes( m )
	gws_NextwarmupEnd = m:ReadFloat()
	gws_NextgameEnd   = m:ReadFloat()
	gws_WarmupLen     = m:ReadFloat()
	gws_WareLen       = m:ReadFloat()
	local bShouldKeepAnnounce = m:ReadBool()
	local bShouldPlayMusic = m:ReadBool()
	
	if not bShouldKeepAnnounce then gws_TickAnnounce = 5 end
	
	if bShouldPlayMusic then
		local libraryID = m:ReadChar()
		local musicID = m:ReadChar()
		gws_CurrentAnnouncer = m:ReadChar()
		LocalPlayer():EmitSound( GAMEMODE.WASND.BITBL_GlobalWarening[libraryID][musicID] , 60, GAMEMODE:GetSpeedPercent() )
		gws_AmbientMusicIsOn = true
		EnableMusic()
		
	end
	
end
usermessage.Hook( "NextGameTimes", NextGameTimes )

local function EventEndgameTrigger( m )
	local achieved = m:ReadBool()
	local musicID = m:ReadChar()
	
	gws_AmbientMusicIsOn = false
	timer.Simple( 0.5, DisableMusic )
	
	if (achieved) then
		LocalPlayer():EmitSound( GAMEMODE.WASND.TBL_GlobalWareningWin[ musicID ] , 60, GAMEMODE:GetSpeedPercent() )
	else
		LocalPlayer():EmitSound( GAMEMODE.WASND.TBL_GlobalWareningLose[ musicID ] , 60, GAMEMODE:GetSpeedPercent() )
	end
end
usermessage.Hook( "EventEndgameTrigger", EventEndgameTrigger )

local function BestStreakEverBreached( m )
	GAMEMODE:SetBestStreak( m:ReadLong() )
end
usermessage.Hook( "BestStreakEverBreached", BestStreakEverBreached )

local function EventEveryoneState( m )
	local achieved = m:ReadBool()

	if (achieved) then
		LocalPlayer():EmitSound( GAMEMODE.WASND.EveryoneWon, 100, GAMEMODE:GetSpeedPercent() )
	else
		LocalPlayer():EmitSound( GAMEMODE.WASND.EveryoneLost, 100, GAMEMODE:GetSpeedPercent() )
	end
end
usermessage.Hook( "EventEveryoneState", EventEveryoneState )

local function PlayerTeleported( m )
	if not m:ReadBool() then
		local musicID = m:ReadChar()
		LocalPlayer():EmitSound( GAMEMODE.WASND.TBL_GlobalWareningTeleport[ musicID ] , 60, GAMEMODE:GetSpeedPercent() )
	end
	LocalPlayer():EmitSound( table.Random(GAMEMODE.WASND.TBL_Teleport) , 40, GAMEMODE:GetSpeedPercent() )
end
usermessage.Hook( "PlayerTeleported", PlayerTeleported )




local function EntityTextChangeColor( m )
	local target = m:ReadEntity()
	local r,g,b,a = m:ReadChar() + 128, m:ReadChar() + 128, m:ReadChar() + 128, m:ReadChar() + 128
	
	if ValidEntity(target) and target.SetEntityColor then
		target:SetEntityColor(r,g,b,a)
	else
		timer.Simple( 0, function(target,r,g,b,a) if ValidEntity(target) and target.SetEntityColor then target:SetEntityColor(r,g,b,a) end end )
	end
end
usermessage.Hook( "EntityTextChangeColor", EntityTextChangeColor )


/*----------------------------------
VGUI Includes
------------------------------------*/

local vgui_transit = vgui.RegisterFile( "vgui_transitscreen.lua" )
local vgui_wait = vgui.RegisterFile( "vgui_waitscreen.lua" )
local vgui_clock = vgui.RegisterFile( "vgui_clock.lua" )
local vgui_clockgame = vgui.RegisterFile( "vgui_clockgame.lua" )
local TransitVGUI = vgui.CreateFromTable( vgui_transit )
local WaitVGUI = vgui.CreateFromTable( vgui_wait )
local ClockVGUI = vgui.CreateFromTable( vgui_clock )
local ClockGameVGUI = vgui.CreateFromTable( vgui_clockgame )


local function Transit( m )
	TransitVGUI:Show()
	RunConsoleCommand("r_cleardecals")
	
	timer.Simple( 2.7, function() TransitVGUI:Hide() end )
end
usermessage.Hook( "Transit", Transit )

function WaitShow( m ) --used in ServerJoinInfo
	WaitVGUI:Show()
end
usermessage.Hook( "WaitShow", WaitShow )

local function WaitHide( m )
	WaitVGUI:Hide()
end
usermessage.Hook( "WaitHide", WaitHide )

local function EndOfGamemode( m )
	ClockVGUI:Hide()
	ClockGameVGUI:Hide()
	
	timer.Simple( GAMEMODE.WADAT.EpilogueFlourishDelayAfterEndOfGamemode, PlayEnding, 2 )
end
usermessage.Hook( "EndOfGamemode", EndOfGamemode )

local function SpecialFlourish( m )
	local musicID = m:ReadChar()
	local dataRef = GAMEMODE.WADAT.TBL_GlobalWareningEpic[musicID]
	timer.Simple( dataRef.StartDalay + dataRef.MusicFadeDelay, function() gws_AmbientMusic[1]:ChangeVolume( 0.0 ) end )
	timer.Simple( dataRef.StartDalay, PlayEnding, musicID )
end
usermessage.Hook( "SpecialFlourish", SpecialFlourish )


local function HitConfirmation( m )
	LocalPlayer():EmitSound( GAMEMODE.WASND.Confirmation, GAMEMODE:GetSpeedPercent() )
end
usermessage.Hook( "HitConfirmation", HitConfirmation )

local function DoRagdollEffect( ply, optvectPush, optiObjNumber, iIter)
	if not ValidEntity( ply ) then return end
	
	local ragdoll = ply:GetRagdollEntity()
	if ragdoll then
		local physobj = nil
		if optiObjNumber >= 0 then
			physobj = ragdoll:GetPhysicsObjectNum( optiObjNumber )
			
		else
			physobj = ragdoll:GetPhysicsObject( )
			
		end
		
		--print(ply:GetModel(), physobj:GetMass() )
		
		if physobj and physobj:IsValid() and physobj ~= NULL then
			physobj:SetVelocity( 10^6 * optvectPush )
			
		else
			timer.Simple(0, function() DoRagdollEffect( ply, optvectPush, optiObjNumber, iIter - 1) end)
		
		end
		
	else
		if iIter > 0 then
			timer.Simple(0, function() DoRagdollEffect( ply, optvectPush, optiObjNumber, iIter - 1) end)
		end
	end
	
end

local function PlayerRagdollEffect( m )
	local ply = m:ReadEntity()
	local optvectPush = m:ReadVector()
	local optiObjNumber = m:ReadChar()
	
	if not ValidEntity( ply ) then return end
	
	DoRagdollEffect( ply, optvectPush, optiObjNumber, 20)
end
usermessage.Hook( "PlayerRagdollEffect", PlayerRagdollEffect )
