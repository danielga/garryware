ELEMENT.Name = "bottom"
ELEMENT.DefaultOff = false
ELEMENT.DefaultGridPosX = 15
ELEMENT.DefaultGridPosY = 15
ELEMENT.SizeX = 40
ELEMENT.SizeY = 40

ELEMENT.STORmaxammo = {}
ELEMENT.tvars = {}

ELEMENT.RefColorBack = nil
ELEMENT.RefColorBackMin = nil
ELEMENT.ColorText = Color(255,255,255,255)
ELEMENT.ColorGood = Color(64,64,255,192)
ELEMENT.ColorBad  = Color(255,128,128,192)

function ELEMENT:Initialize( )
end

function ELEMENT:DrawFunction( )
	if LocalPlayer():Alive() then
		local SWEP = LocalPlayer():GetActiveWeapon()
		self.tvars = {}
		if SWEP:IsValid() then
			self.tvars.clip1type = SWEP:GetPrimaryAmmoType() or ""
			self.tvars.clip1     = tonumber(SWEP:Clip1()) or -1
			self.tvars.clip1left = LocalPlayer():GetAmmoCount(self.tvars.clip1type)
		else
			self.tvars.clip1 = -1
			self.tvars.clip1left = -1
		end
		if not self.STORmaxammo[SWEP] then
			self.STORmaxammo[SWEP] = self.tvars.clip1
		elseif self.tvars.clip1 > self.STORmaxammo[SWEP] then
			self.STORmaxammo[SWEP] = self.tvars.clip1
		end
		
		self.tvars.clip1max = tonumber(self.STORmaxammo[SWEP]) or 1
		
		//Sweps, not the phys/gravgun...
		if self.tvars.clip1 >= 0 and self.tvars.clip1type != -1 then	
			local smallText = ""
			local rate = -1
			if self.tvars.clip1 <= 0 then
				self.RefColorBack   = self.ColorBad
			else
				self.RefColorBack   = self.ColorGood
			end
			if self.tvars.clip1left > 0 then
				smallText = self.tvars.clip1left
				self.RefColorBackMin   = self.ColorGood
			else
				smallText = "x"
				self.RefColorBackMin   = self.ColorBad
			end
			
			rate = self.tvars.clip1 / (self.STORmaxammo[SWEP] or 1)
			
			self:DrawGWTextBox(
			2.0
			, self.tvars.clip1
			, self.RefColorBack
			, self.ColorText
			, self.ColorText
			, 2
			)
			
			self:DrawGWRelativeTextBox(
			0.0
			, 1.2
			, 30
			, 20
			, 2.0
			, smallText
			, self.RefColorBackMin
			, self.ColorText
			, self.ColorText
			, 1
			)
		
		//Gravgun/nades
		elseif self.tvars.clip1left > 0 then
			self:DrawGWTextBox(
			2.0
			, self.tvars.clip1left
			, self.ColorBack
			, self.ColorText
			, self.ColorText
			, 2
			)
		end
	end
	
	return true
end

