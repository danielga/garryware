
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

	Col1:SetMinWidth( 170 )
	Col1:SetMaxWidth( 170 )
	
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
	
	Col1_2:SetMinWidth( 170 )
	Col1_2:SetMaxWidth( 170 )
	
	Wins_2:SetMinWidth( 32 )
	Wins_2:SetMaxWidth( 32 )
	
	Losses_2:SetMinWidth( 32 )
	Losses_2:SetMaxWidth( 32 )	
		
	self.NextThink = RealTime()
	
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
			Wins[ -winNum - 0.001*loseNum - 0.00001*(ply:UserID()) ] = ply
		end
	end
	local Fails_2 = {}
	for k, ply in pairs( team.GetPlayers(TEAM_UNASSIGNED) ) do
		local winNum_2 = ply:Frags( )
		local loseNum_2 = ply:Deaths( )
		if (ply:GetNWInt("ware_achieved",0) == 0) then
			Fails_2[ -winNum_2 - 0.001*loseNum_2 - 0.00001*(ply:UserID()) ] = ply
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
	
end


/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self:SetSize( 468, 200 )
	self:SetPos( ScrW()/2 - self:GetWide()/2 , 0 )
	
	self.List:StretchToParent( 5,5,236,5 )
	self.List2:StretchToParent( 236,5,5,5 )
	
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Paint()
	draw.RoundedBox( 4,                0, 3, self:GetWide()/2, 18, Color(0,0,192,200) )
	draw.RoundedBox( 4, self:GetWide()/2, 3, self:GetWide()/2, 18, Color(192,0,0,200) )
end
