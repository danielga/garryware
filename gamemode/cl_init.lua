include( 'shared.lua' )
include( 'cl_hud.lua' )
include( 'cl_postprocess.lua' )
include( 'cl_usermsg.lua' )
include( 'skin.lua' )
include( "tables.lua" )

/*
MusCursor = 1
MusGame = { {"........a4..a4..........a4..a4..","weapons/wrench_hit_build_fail.wav"} ,
			{"a4..b4..........b4c5d5..........","weapons/wrench_hit_build_success1.wav"} }
MusInterval = 0.12
MusRealTime = 0
*/


function GM:Think()
	self.BaseClass:Think()
	
	if (TickAnnounce > 0 && CurTime() < NextgameEnd ) then
		if (CurTime() > (NextgameEnd - (WareLen/6)*TickAnnounce )) then
			if     TickAnnounce == 5 then LocalPlayer():EmitSound( GAMEMODE.Left5 )
			elseif TickAnnounce == 4 then LocalPlayer():EmitSound( GAMEMODE.Left4 )
			elseif TickAnnounce == 3 then LocalPlayer():EmitSound( GAMEMODE.Left3 )
			elseif TickAnnounce == 2 then LocalPlayer():EmitSound( GAMEMODE.Left2 )
			elseif TickAnnounce == 1 then LocalPlayer():EmitSound( GAMEMODE.Left1 )
			end
			TickAnnounce = TickAnnounce - 1
		end
	end
	
	--"Make your own music" module
	/*
	local Pitch = 0
	local NoPitch
	local Note = "."
	local OctaveSt, Octave
	local Pnum = 0
	local Offset = 0
	if (NextgameStart < CurTime() && CurTime() < NextgameEnd && (RealTime() - MusRealTime) > MusInterval) then
		if MusCursor > MusGame[1][1]:len() then MusCursor = 1 end
		
		
		for Index,Patch in pairs(MusGame) do
			NoPitch = false
			local Note = Patch[1]:sub(MusCursor,MusCursor)
			if (Note != ".") then
				OctaveSt = Patch[1]:sub(MusCursor+1,MusCursor+1)
			end
			if (OctaveSt == "0") then Octave = 0 end
			if (OctaveSt == "1") then Octave = 1 end
			if (OctaveSt == "2") then Octave = 2 end
			if (OctaveSt == "3") then Octave = 3 end
			if (OctaveSt == "4") then Octave = 4 end
			if (OctaveSt == "5") then Octave = 5 end
			if (OctaveSt == "6") then Octave = 6 end
			if (OctaveSt == "7") then Octave = 7 end
			if (OctaveSt == "8") then Octave = 8 end
			if (OctaveSt == "9") then Octave = 9 end
			
			if (Note == "c") then Pnum = -9+(12*(Octave-4))
			elseif (Note == "d") then Pnum = -7+(12*(Octave-4))
			elseif (Note == "e") then Pnum = -5+(12*(Octave-4))
			elseif (Note == "f") then Pnum = -4+(12*(Octave-4))
			elseif (Note == "g") then Pnum = -2+(12*(Octave-4))
			elseif (Note == "a") then Pnum = 0+(12*(Octave-4))
			elseif (Note == "b") then Pnum = 2+(12*(Octave-4))
			
			elseif (Note == "C") then Pnum = -9+(12*(Octave-4))+1
			elseif (Note == "D") then Pnum = -7+(12*(Octave-4))+1
			elseif (Note == "F") then Pnum = -4+(12*(Octave-4))+1
			elseif (Note == "G") then Pnum = -2+(12*(Octave-4))+1
			elseif (Note == "A") then Pnum = 0+(12*(Octave-4))+1
			else NoPitch = true Pnum = 0 end

			if (NoPitch == true) then
				Pitch = 0
			else
				Highness = Pnum + Offset
				Pitch = 2^(Highness/12)
			end
			Pitch = Pitch * 100
			LocalPlayer():EmitSound(Patch[2],100,Pitch)
		end
			
		MusCursor = MusCursor + 2
		MusRealTime = RealTime()
	end
	*/
end


