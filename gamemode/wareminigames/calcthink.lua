WARE.Author = "Hurricaaane (Ha3)"
WARE.Room = "none"

function WARE:Initialize()

	GAMEMODE:SetWareWindupAndLength(2,8)
	GAMEMODE:DrawPlayersTextAndInitialStatus("Prepare to type in the chat ...",0)
	
end

function WARE:StartAction()

	local init = math.random(2,19)
	local mul = math.random(2,2)
	local negative = math.random(0,1)
	local add = math.random(1,9)
	local ismul = math.random(1,7)
	
	if negative == 1 then
		add = -add
	end
	
	local one, two, three
	if ismul == 7 then
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

function WARE:EndAction()
	for k,v in pairs(player.GetAll()) do 
		v:ChatPrint( "Answer was "..self.WareSolution.." !" )  
	end
end

function WARE:PlayerSay(ply, text, say)
	if text == tostring(self.WareSolution) then
		ply:WarePlayerDestinyWin( )
		if ((ply:GetNWInt("ware_hasdestiny",0) > 0) and (ply:GetNWInt("ware_achieved",0) <= 0)) then
			for k,v in pairs(player.GetAll()) do 
				v:ChatPrint( ply:GetName() .. " thought he could have multiple tries." )  
			end
		else
			for k,v in pairs(player.GetAll()) do 
				v:ChatPrint( ply:GetName() .. " has found the correct answer !" )  
			end
		end
		return false
	else
		ply:WarePlayerDestinyLose( )
	end
end
