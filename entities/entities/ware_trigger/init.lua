
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NONE)
	self:SetNotSolid(true)
end

function ENT:Setup(mins, maxs, callback, ...)
	self:SetNetworkedVector("mins", mins)
	self:SetNetworkedVector("maxs", maxs)
	self.mins = mins
	self.maxs = maxs
	
	self.vmax = (maxs-mins):Length()
	self.vmax = Vector(vmax,vmax,vmax)
	
	self.TouchCallback = callback
	
	self.Exceptions = {}
	for _,v in pairs(arg) do
		self.Exceptions[v] = 1
	end
end

function ENT:IsInBox(pos)
	local diff = pos - self:GetPos()
	
	local proj_length = diff:DotProduct(self:GetForward())
	local proj_width  = diff:DotProduct(self:GetRight())
	local proj_height = diff:DotProduct(self:GetUp())
	
	return proj_length>=self.mins.x and proj_length<=self.maxs.x and
		   proj_width >=self.mins.y and proj_width <=self.maxs.y and
		   proj_height>=self.mins.z and proj_height<=self.maxs.z
end

function ENT:Think(ent)
	if not self.TouchCallback then return end
	local pos = self:GetPos()
	
	--for _,v in pairs(ents.FindInBox(pos-self.vmax, pos+self.vmax)) do
	for _,v in pairs(ents.GetAll()) do
		if not self.Exceptions[v] and v~=self and v~=self:GetParent() and self:GetClass()~="gmod_warelocation" then
			if self:IsInBox(v:GetPos()) then
				self:TouchCallback(v)
			end
		end
	end
end
