
include('shared.lua')

ENT.RenderGroup 		= RENDERGROUP_TRANSLUCENT
//local DominationMat = Material("SGM/playercircle")

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self.TextColor = Color( 255, 255, 255, 255 )
	if (CLIENT) then
		self.Entity:SetRenderBoundsWS(self.Entity:GetPos()+Vector(-128,-128,-128), self.Entity:GetPos()+Vector(128,128,128))
	end
end

/*---------------------------------------------------------
   Name: DrawPre
---------------------------------------------------------*/
function ENT:Draw()
	/*
	print("drawing "..self.Entity:GetNWString("text","NOR DRAWING ANYTHING"))
	local pos = self.Entity:GetPos()
	local pos_toscreen = pos:ToScreen()
	print(pos_toscreen.x .. " , " .. pos_toscreen.y)
	
	
	surface.SetMaterial( DominationMat )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRectRotated(pos_toscreen.x, pos_toscreen.y - 2, 52, 52, 0)
	draw.SimpleTextOutlined( self.Entity:GetNWString("text","") , "WAREIns", pos_toscreen.x, pos_toscreen.y, self.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 0, 0, 0, self.TextColor.a ) );
	*/
end



function DrawWareText()
	for k,v in pairs(ents.FindByClass("ware_text")) do
		local pos = v:GetPos()
		local pos_toscreen = pos:ToScreen()
		
		draw.SimpleTextOutlined( v:GetNWString("text","") , "WAREIns", pos_toscreen.x, pos_toscreen.y, v.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 0, 0, 0, v.TextColor.a ) );
	end
end
hook.Add("HUDPaint", "DrawWareText", DrawWareText)


function ENT:SetEntityColor(r,g,b,a)
	self.TextColor = Color(r,g,b,a)
end
