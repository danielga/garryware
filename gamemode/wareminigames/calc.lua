WARE.Author = "Hurricaaane (Ha3)"

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(0,8)
	
	local a = math.random(10,99)
	local b = math.random(10,99)
	self.WareSolution = a + b
	GAMEMODE:DrawPlayersTextAndInitialStatus("Calculate and say : "..a.." + "..b.." = ?",0)
end

function WARE:StartAction()
	
end

function WARE:EndAction()
	for k,v in pairs(player.GetAll()) do 
		v:ChatPrint( "Answer was "..self.WareSolution.." !" )  
	end
end

function WARE:PlayerSay(ply, text, say)
	if text == tostring(self.WareSolution) then
		ply:WarePlayerDestinyWin( )
		for k,v in pairs(player.GetAll()) do 
			v:ChatPrint( ply:GetName() .. " has found the correct answer !" )  
		end
		return false
	else
		ply:WarePlayerDestinyLose( )
	end
end
