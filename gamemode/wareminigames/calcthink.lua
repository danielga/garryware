WARE.Author = "Hurricaaane (Ha3)"
WARE.Room = "none"

function WARE:Initialize()
	GAMEMODE:SetWareWindupAndLength(0,8)
	
	local init = math.random(2,9)
	local mul = math.random(2,2)
	local negative = math.random(0,1)
	local add = math.random(1,9)
	local ismul = math.random(0,1)
	
	if negative == 1 then
		add = -add
	end
	
	local one, two, three
	if ismul == 1 then
		one = init
		two = one * mul
		three = two * mul
		self.WareSolution = three * mul
	else
		one = init + negative * (-add * 10)
		two = one + add
		three = two + add
		self.WareSolution = three + add
	end
	
	GAMEMODE:DrawPlayersTextAndInitialStatus("Think : "..one.." , "..two.." , "..three.." , ?",0)
	for k,v in pairs(player.GetAll()) do 
		v:ChatPrint( "Think : "..one.." , "..two.." , "..three.." , ?" )  
	end
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
