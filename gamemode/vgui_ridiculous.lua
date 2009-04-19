
PANEL.Base = "DPanel"

/*---------------------------------------------------------
   Name: gamemode:HUDThink
---------------------------------------------------------*/
function PANEL:Init()
	self:SetSkin( "ware" )
	self.List = vgui.Create( "DListView", self )
	self.List:SetDrawBackground( false )
	self.List:SetSortable( false )
	
	local Col1 = self.List:AddColumn( "Winners" )
	local Wins = self.List:AddColumn( "Win" )
	local Losses = self.List:AddColumn( "Fail" )

	Col1:SetMinWidth( 164 )
	Col1:SetMaxWidth( 164 )
	
	Wins:SetMinWidth( 32 )
	Wins:SetMaxWidth( 32 )
	
	Losses:SetMinWidth( 32 )
	Losses:SetMaxWidth( 32 )	
	
	self.List2 = vgui.Create( "DListView", self )
	self.List2:SetDrawBackground( false )
	self.List2:SetSortable( false )
	
	local Col1_2 = self.List2:AddColumn( "Failures" )
	local Wins_2 = self.List2:AddColumn( "Win" )
	local Losses_2 = self.List2:AddColumn( "Fail" )
	
	Col1_2:SetMinWidth( 164 )
	Col1_2:SetMaxWidth( 164 )
	
	Wins_2:SetMinWidth( 32 )
	Wins_2:SetMaxWidth( 32 )
	
	Losses_2:SetMinWidth( 32 )
	Losses_2:SetMaxWidth( 32 )	
		
	self.NextThink = RealTime()
	
	self.BubbleTexPath = "sprites/ware_bubble"
	self.BubbleTexID   = surface.GetTextureID( self.BubbleTexPath )
	
	self.LockTexPath = "sprites/ware_lock"
	self.LockTexID   = surface.GetTextureID( self.LockTexPath )
	
	self.Minispacing = 12
	self.Wincount = 0
	self.Failcount = 0
end

function PANEL:Hide()
	self:SetVisible( false )
end

/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function PANEL:Think()

	if ( self.NextThink > RealTime() ) then return end
	self.NextThink = RealTime() + 0.5
	
	local Wins = {}
	for k, ply in pairs( team.GetPlayers(TEAM_UNASSIGNED) ) do
		local winNum = ply:Frags( )
		local loseNum = ply:Deaths( )
		if (ply:GetNWInt("ware_achieved",0) > 0) then
			Wins[ -winNum*10000 - 100*loseNum - 1*(ply:UserID()) ] = ply
		end
	end
	local Fails_2 = {}
	for k, ply in pairs( team.GetPlayers(TEAM_UNASSIGNED) ) do
		local winNum_2 = ply:Frags( )
		local loseNum_2 = ply:Deaths( )
		if (ply:GetNWInt("ware_achieved",0) == 0) then
			Fails_2[ -winNum_2*10000 - 100*loseNum_2 - 1*(ply:UserID()) ] = ply
		end
	end
	
	self.List:Clear()
	for k, ply in SortedPairs( Wins ) do
		local win  = ply:Frags( )
		local fail = ply:Deaths( )
		local line = self.List:AddLine( ply:Nick(), win, fail )
		line.goodness = true
		line.destiny = ply:GetNWInt("ware_hasdestiny",0)
	end
	self.List:DataLayout()
	
	self.List2:Clear()
	for k, ply in SortedPairs( Fails_2 ) do
		local win_2  = ply:Frags( )
		local fail_2 = ply:Deaths( )
		local line = self.List2:AddLine( ply:Nick(), win_2, fail_2 )
		line.goodness = false
		line.destiny = ply:GetNWInt("ware_hasdestiny",0)
	end
	self.List2:DataLayout()
	
	self.Wincount  = table.Count(Wins)
	self.Failcount = table.Count(Fails_2)
	
	self:InvalidateLayout()
end


/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self:SetSize( 560, 200 )
	self:SetPos( ScrW()/2 - self:GetWide()/2 , 0 )
	
	self.List:StretchToParent( self.Minispacing*2, 6,    560/2 + 32         ,  5 )
	self.List2:StretchToParent( 560/2 + 32,        6,    self.Minispacing*2 ,  5 )
	
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Paint()
	local achieved = 0
	local hasdestiny = 0
	if LocalPlayer():IsValid() then
		achieved = LocalPlayer():GetNWInt("ware_achieved",0)
		hasdestiny = LocalPlayer():GetNWInt("ware_hasdestiny",0)
	end
	draw.RoundedBox( 0,                   self.Minispacing,    3, self:GetWide()/2-self.Minispacing,  3, Color(0,0,0,255) )
	draw.RoundedBox( 0,                   self.Minispacing,    6, self:GetWide()/2-self.Minispacing, 16, Color(0,0,192,200) )
	draw.RoundedBox( 0,                   self.Minispacing,   22, self:GetWide()/2-self.Minispacing,  3, Color(0,0,0,255) )
	
	draw.RoundedBox( 0,  self:GetWide()/2,    3, self:GetWide()/2-self.Minispacing,  3, Color(0,0,0,255) )
	draw.RoundedBox( 0,  self:GetWide()/2,    6, self:GetWide()/2-self.Minispacing, 16, Color(192,0,0,200) )
	draw.RoundedBox( 0,  self:GetWide()/2,   22, self:GetWide()/2-self.Minispacing,  3, Color(0,0,0,255) )
	
	
	surface.SetTexture( self.BubbleTexID )
	if (CurTime() < NextgameStart) then
		surface.SetDrawColor( 255,255,255,255 )
	elseif (CurTime() < NextwarmupEnd) then
		surface.SetDrawColor( 255,245,165,255 )
	else
		if (achieved > 0) then
			surface.SetDrawColor( 166,195,250,255 )
		elseif (achieved <= 0) then
			surface.SetDrawColor( 250,165,165,255 )
		end
	end
	local hasdestinyNot
	if hasdestiny <= 0 then
		hasdestinyNot = 1
	else
		hasdestinyNot = 0
	end
	surface.DrawTexturedRectRotated(self:GetWide()/2, 24, 64 + hasdestinyNot*math.cos(CurTime()*16)*4, 64 + hasdestinyNot*math.cos(CurTime()*16)*4, 0)
	
	surface.SetDrawColor( 166,195,250,255 )
	surface.DrawTexturedRectRotated(self.Minispacing               , 14, 24, 24, 0)
	surface.SetDrawColor( 250,165,165,255 )
	surface.DrawTexturedRectRotated(self:GetWide()-self.Minispacing, 14, 24, 24, 0)

	draw.SimpleText( self.Wincount , "WAREScore", self.Minispacing               , 14, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
	
	draw.SimpleText( self.Failcount, "WAREScore", self:GetWide()-self.Minispacing, 14, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
	
	if hasdestiny > 0 then
		surface.SetTexture( self.LockTexID )
		surface.SetDrawColor( 255,255,255,255 )
		surface.DrawTexturedRectRotated(self:GetWide()/2, 24, 16 + math.Clamp(16*(CurTime() - NextgameStart)/GameLen,0,24), 16 + math.Clamp(16*(CurTime() - NextgameStart)/GameLen,0,24), 0)
	end
end
