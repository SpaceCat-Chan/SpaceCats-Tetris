math.randomseed(os.time()) --set up math.random

function pairsV(tab) --from https://stackoverflow.com/questions/40454472/lua-iterate-over-table-sorted-by-values
	local keys = {}
	for k in pairs(tab) do
		keys[#keys + 1] = k
	end
	table.sort(keys, function(a, b) return tab[a] > tab[b] end)
	local j = 0
	return function()
		j = j + 1  
		local k = keys[j]
		if k ~= nil then
			return k, tab[k]
		end
	end
end

function DeepCopy(orig) --DeepCopy function
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
        end
        setmetatable(copy, DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function sortedKeys(query, sortFunction) --got this from https://stackoverflow.com/questions/19260423/how-to-keep-the-order-of-a-lua-table-with-string-keys
  local keys, len = {}, 0
  for k,_ in pairs(query) do
    len = len + 1
    keys[len] = k
  end
  table.sort(keys, sortFunction)
  return keys
end

function FormatNumber(input) --got this from https://www.gammon.com.au/forum/bbshowpost.php?bbsubject_id=8541
	if input > 1000 then
		local result = string.gsub(tostring(input), "(%d)(%d%d%d)$", "%1,%2", 1)
		while true do
			result, found = string.gsub(result, "(%d)(%d%d%d),", "%1,%2,", 1)
			if found == 0 then break end
		end
		return result
	else
		return tostring(input)
	end
end

function SetUpWorld() --Create all the slots that Minos can be in
	InactiveMinos = {}
	SwapInactiveMinos = {}
	for x=1,25 do
		InactiveMinos[x] = {}
		SwapInactiveMinos[x] = {}
		for y=1,10 do
			InactiveMinos[x][y] = {}
			SwapInactiveMinos[x][y] = {}
		end
	end
end

function love.load() --loading function
	
	MainTextX = 20
	ScreenX = 230
	
	love.window.setTitle("SpaceCats Classic Tetris") --set the window title
	
	love.window.setMode(800, 720, {vsync = false})
	
	StandardFont = love.graphics.setNewFont(18)
	LargeFont = love.graphics.newFont(36)
	
	ProtSettings = {}
	local line = love.filesystem.read("ProtSettings.txt")
	for l in line:gmatch("[^;]+ = [^;]+;") do
		local Setting,Value = l:match("([^;]+) = ([^;]+);")
		ProtSettings[Setting] = Value
	end
	
	Controls = {} --set up Controls table
	local line = love.filesystem.read("Controls.txt") --load Controls from Controls.txt
	for l in line:gmatch("[^;]+ = [^;]+;") do
		local Control,Key = l:match("(.+) = (.+);")
		Controls[Key] = Control
	end
	
	Settings = {} --set up Settings Table
	local line = love.filesystem.read("Settings.txt") --load Settings from Settings.txt
	for line in line:gmatch("[^;]+ = [^;]+;") do
		local Setting,Value = line:match("(.+) = (.+);")
		if Setting ~= "SRS" and Setting ~= "Pentominos" then
			Settings[Setting] = tonumber(Value)
		else
			Settings[Setting] = Value
		end
	end
	
	if not love.filesystem.getInfo("Highscores.txt") then --check if the Highscores.txt exists
		love.filesystem.write("Highscores.txt", "1 = "..tostring(0)..";") --if it doesn't. then create it
		love.filesystem.append("Highscores.txt", "2 = "..tostring(0)..";")
		love.filesystem.append("Highscores.txt", "3 = "..tostring(0)..";")
		love.filesystem.append("Highscores.txt", "4 = "..tostring(0)..";")
		love.filesystem.append("Highscores.txt", "5 = "..tostring(0)..";")
	end
	
	Highscores = {}
	local line = love.filesystem.read("Highscores.txt") --load highscores from Highscores.txt
	for l in line:gmatch("%d+ = %d+;") do
		local Number,Score = l:match("(%d+) = (%d+);")
		Highscores[tonumber(Number)] = tonumber(Score)
	end
	
	if not love.filesystem.getInfo("SwapHighscores.txt") then --check if the Highscores.txt exists
		love.filesystem.write("SwapHighscores.txt", "1 = "..tostring(0)..";") --if it doesn't. then create it
		love.filesystem.append("SwapHighscores.txt", "2 = "..tostring(0)..";")
		love.filesystem.append("SwapHighscores.txt", "3 = "..tostring(0)..";")
		love.filesystem.append("SwapHighscores.txt", "4 = "..tostring(0)..";")
		love.filesystem.append("SwapHighscores.txt", "5 = "..tostring(0)..";")
	end
	
	SwapHighscores = {}
	local line = love.filesystem.read("SwapHighscores.txt") --load highscores from Highscores.txt
	for l in line:gmatch("%d+ = %d+;") do
		local Number,Score = l:match("(%d+) = (%d+);")
		SwapHighscores[tonumber(Number)] = tonumber(Score)
	end
	
	if not love.filesystem.getInfo("HiddenHighscores.txt") then --check if the Highscores.txt exists
		love.filesystem.write("HiddenHighscores.txt", "1 = "..tostring(0)..";") --if it doesn't. then create it
		love.filesystem.append("HiddenHighscores.txt", "2 = "..tostring(0)..";")
		love.filesystem.append("HiddenHighscores.txt", "3 = "..tostring(0)..";")
		love.filesystem.append("HiddenHighscores.txt", "4 = "..tostring(0)..";")
		love.filesystem.append("HiddenHighscores.txt", "5 = "..tostring(0)..";")
	end
	
	HiddenHighscores = {}
	local line = love.filesystem.read("HiddenHighscores.txt") --load highscores from Highscores.txt
	for l in line:gmatch("%d+ = %d+;") do
		local Number,Score = l:match("(%d+) = (%d+);")
		HiddenHighscores[tonumber(Number)] = tonumber(Score)
	end
	
	if not love.filesystem.getInfo("PuyoHighscores.txt") then --check if the Highscores.txt exists
		love.filesystem.write("PuyoHighscores.txt", "1 = "..tostring(0)..";") --if it doesn't. then create it
		love.filesystem.append("PuyoHighscores.txt", "2 = "..tostring(0)..";")
		love.filesystem.append("PuyoHighscores.txt", "3 = "..tostring(0)..";")
		love.filesystem.append("PuyoHighscores.txt", "4 = "..tostring(0)..";")
		love.filesystem.append("PuyoHighscores.txt", "5 = "..tostring(0)..";")
	end
	
	PuyoHighscores = {}
	local line = love.filesystem.read("PuyoHighscores.txt") --load highscores from Highscores.txt
	for l in line:gmatch("%d+ = %d+;") do
		local Number,Score = l:match("(%d+) = (%d+);")
		PuyoHighscores[tonumber(Number)] = tonumber(Score)
	end
	
	Soft_Drop = {Timer = 0, Activated = false} --set up timers
	Move_Left = {Timer = 0, Activated = false}
	Move_Right = {Timer = 0, Activated = false}
	
	Status = "Menu" --set up status screen
	ActiveMinos = {} --set up ActiveMinos Table
	SwapActiveMinos = {} --set up active minos for the swap mode
	SwapState = 0
	MovTimer = 0
	SwapMovTimer = 0
	
	GhostMinos = {}
	SwapGhostMinos = {}
	
	
	Score = {} --set up all the score values
	Score.Singles = 0
	Score.Doubles = 0
	Score.Triples = 0
	Score.Tetris = 0
	Score.STetris = 0
	
	ScoreAmount = 0
	
	Level = 1 --set up the Level Value
	ChosenLevel = 1 --set up the level that the player choose
	MovReset = 0 --set up the MovReset Value
	SwapMovReset = 0
	
	PuyoTimer = 0
	PuyoWaiting = false
	PuyoWaitState = {}
	Chain = 1
	
	UpComming = {}
	
	CurrentMode = "Standard"
	
	BackGround = love.graphics.newImage("BackGround.png")
	Title = love.graphics.newImage("Title.png")
	
	Images = { --setting up table for easier access
		OPieceImage = love.graphics.newImage("Minos/OPiece.png"), --set up all of the images
		SPieceImage = love.graphics.newImage("Minos/SPiece.png"),
		ZPieceImage = love.graphics.newImage("Minos/ZPiece.png"),
		LPieceImage = love.graphics.newImage("Minos/LPiece.png"),
		JPieceImage = love.graphics.newImage("Minos/JPiece.png"),
		TPieceImage = love.graphics.newImage("Minos/TPiece.png"),
		IPieceImage = love.graphics.newImage("Minos/IPiece.png")
	}
	
	Ghost = { --setting up a table for easier access
		OPieceImage = love.graphics.newImage("Minos/OPieceGhost.png"), --set up all of the Ghost images
		SPieceImage = love.graphics.newImage("Minos/SPieceGhost.png"),
		ZPieceImage = love.graphics.newImage("Minos/ZPieceGhost.png"),
		LPieceImage = love.graphics.newImage("Minos/LPieceGhost.png"),
		JPieceImage = love.graphics.newImage("Minos/JPieceGhost.png"),
		TPieceImage = love.graphics.newImage("Minos/TPieceGhost.png"),
		IPieceImage = love.graphics.newImage("Minos/IPieceGhost.png"),
		[1] = love.graphics.newImage("Minos/OPieceGhost.png"),
		[2] = love.graphics.newImage("Minos/SPieceGhost.png"),
		[3] = love.graphics.newImage("Minos/ZPieceGhost.png"),
		[4] = love.graphics.newImage("Minos/JPieceGhost.png"),
		[5] = love.graphics.newImage("Minos/TPieceGhost.png"),
		[6] = love.graphics.newImage("Minos/IPieceGhost.png"),
		[7] = love.graphics.newImage("Minos/LPieceGhost.png")
	}
	
	Puyo = { --setting up a table for easier access
		[1] = love.graphics.newImage("Minos/OPiece.png"), --set up all of the images
		[2] = love.graphics.newImage("Minos/SPiece.png"),
		[3] = love.graphics.newImage("Minos/ZPiece.png"),
		[4] = love.graphics.newImage("Minos/JPiece.png"),
		[5] = love.graphics.newImage("Minos/TPiece.png"),
		[6] = love.graphics.newImage("Minos/IPiece.png"),
		[7] = love.graphics.newImage("Minos/LPiece.png")
	}
	
	Blank = love.graphics.newImage("Minos/Blank.png")
	
	TetrominoList = {} --set up the list of Tetrominos
	TetrominoList.OPiece = { --each piece contains:
		Image = Images.OPieceImage, --an image
		CurrentRotation = 0, --some rotation info
		MainPiece = {0,0}, --the Main Minos
		[1] = {1,0}, --three other Minos, all of their cordinates are relative to the Main Minos
		[2] = {0,1},
		[3] = {1,1}
	}
	TetrominoList.SPiece = {
		Image = Images.SPieceImage,
		CurrentRotation = 0,
		MainPiece = {0,0},
		[1] = {-1,0},
		[2] = {0,1},
		[3] = {1,1}
	}
	TetrominoList.ZPiece = {
		Image = Images.ZPieceImage,
		CurrentRotation = 0,
		MainPiece = {0,0},
		[1] = {1,0},
		[2] = {0,1},
		[3] = {-1,1}
	}
	TetrominoList.LPiece = {
		Image = Images.LPieceImage,
		CurrentRotation = 0,
		MainPiece = {0,0},
		[1] = {-1,0},
		[2] = {1,0},
		[3] = {1,1}
	}
	TetrominoList.JPiece = {
		Image = Images.JPieceImage,
		CurrentRotation = 0,
		MainPiece = {0,0},
		[1] = {1,0},
		[2] = {-1,0},
		[3] = {-1,1}
	}
	TetrominoList.TPiece = {
		Image = Images.TPieceImage,
		CurrentRotation = 0,
		MainPiece = {0,0},
		[1] = {-1,0},
		[2] = {1,0},
		[3] = {0,1}
	}
	TetrominoList.IPeice = {
		Image = Images.IPieceImage,
		CurrentRotation = 0,
		MainPiece = {0,0},
		[1] = {1,0},
		[2] = {2,0},
		[3] = {-1,0}
	}
	
	PentominoList = {} --set up the list of Pentominos
	PentominoList.OPiece = { --each piece contains:
		Image = Images.OPieceImage, --an image
		CurrentRotation = 0, --some rotation info
		MainPiece = {0,0}, --the Main Minos
		[1] = {1,0}, --FOUR other Minos, all of their cordinates are relative to the Main Minos
		[2] = {0,1},
		[3] = {1,1},
		[4] = {0,-1}
	}
	PentominoList.SPiece = {
		Image = Images.SPieceImage,
		CurrentRotation = 0,
		MainPiece = {0,0},
		[1] = {-1,0},
		[2] = {0,1},
		[3] = {1,1},
		[4] = {-2,0}
	}
	PentominoList.ZPiece = {
		Image = Images.ZPieceImage,
		CurrentRotation = 0,
		MainPiece = {0,0},
		[1] = {1,0},
		[2] = {0,1},
		[3] = {-1,1},
		[4] = {1,-1}
	}
	PentominoList.LPiece = {
		Image = Images.LPieceImage,
		CurrentRotation = 0,
		MainPiece = {0,0},
		[1] = {-1,0},
		[2] = {1,0},
		[3] = {1,1},
		[4] = {-1,-1}
	}
	PentominoList.JPiece = {
		Image = Images.JPieceImage,
		CurrentRotation = 0,
		MainPiece = {0,0},
		[1] = {1,0},
		[2] = {-1,0},
		[3] = {-1,1},
		[4] = {0,-1}
	}
	PentominoList.TPiece = {
		Image = Images.TPieceImage,
		CurrentRotation = 0,
		MainPiece = {0,0},
		[1] = {-1,0},
		[2] = {1,0},
		[3] = {0,1},
		[4] = {0,2}
	}
	PentominoList.IPeice = {
		Image = Images.IPieceImage,
		CurrentRotation = 0,
		MainPiece = {0,0},
		[1] = {1,0},
		[2] = {2,0},
		[3] = {-1,0},
		[4] = {-2,0}
	}
	
	
	Offsets = {} --this is a very advanced table, if you wanna know what it is used for, check out https://tetris.wiki/SRS#How_Guideline_SRS_Really_Works
	Offsets.I = {}
	
	HoldSpot = {}
	
	Offsets.I[0] = {
		[1] = {0,0},
		[2] = {-1,0},
		[3] = {2,0},
		[4] = {-1,0},
		[5] = {2,0}
	}
	Offsets.I[1] = {
		[1] = {-1,0},
		[2] = {0,0},
		[3] = {0,0},
		[4] = {0,1},
		[5] = {0,-2}
	}
	Offsets.I[2] = {
		[1] = {-1,1},
		[2] = {1,1},
		[3] = {-2,1},
		[4] = {1,0},
		[5] = {-2,0}
	}
	Offsets.I[3] = {
		[1] = {0,1},
		[2] = {0,1},
		[3] = {0,1},
		[4] = {0,-1},
		[5] = {0,2}
	}
	
	Offsets.O = {}
	
	Offsets.O[0] = {
		[1] = {0,0},
		[2] = {0,0}
	}
	Offsets.O[1] = {
		[1] = {0,-1},
		[2] = {0,0}
	}
	Offsets.O[2] = {
		[1] = {-1,-1},
		[2] = {0,0}
	}
	Offsets.O[3] = {
		[1] = {-1,0},
		[2] = {0,0}
	}
	
	Offsets.Other = {}
	
	Offsets.Other[0] = {
		[1] = {0,0},
		[2] = {0,0},
		[3] = {0,0},
		[4] = {0,0},
		[5] = {0,0}
	}
	Offsets.Other[1] = {
		[1] = {0,0},
		[2] = {1,0},
		[3] = {1,-1},
		[4] = {0,2},
		[5] = {1,2}
	}
	Offsets.Other[2] = {
		[1] = {0,0},
		[2] = {0,0},
		[3] = {0,0},
		[4] = {0,0},
		[5] = {0,0}
	}
	Offsets.Other[3] = {
		[1] = {0,0},
		[2] = {-1,0},
		[3] = {-1,-1},
		[4] = {0,2},
		[5] = {-1,2}
	}
	
	
	SetUpWorld() --set up world for drawing reasons
end

function HoldSwitch()
	
	local ACMinos = false
	if SwapState == 0 then
		ACMinos = ActiveMinos
	else
		AcMinos = SwapActiveMinos
	end
	
	if HoldSpot.Image == nil then
		HoldSpot = ACMinos
		SetActiveMinos(SwapState)
		if HoldSpot.Image == TetrominoList.IPeice.Image then
			HoldSpot.MainPiece[2] = 23
		else
			HoldSpot.MainPiece[2] = 24
		end
		HoldSpot.MainPiece[1] = 6
	else
		if SwapState == 0 then
			HoldSpot, ActiveMinos = ActiveMinos, HoldSpot
		else
			HoldSpot, SwapActiveMinos = SwapActiveMinos, HoldSpot
		end
		if HoldSpot.Image == TetrominoList.IPeice.Image then
			HoldSpot.MainPiece[2] = 23
		else
			HoldSpot.MainPiece[2] = 24
		end
		HoldSpot.MainPiece[1] = 6
		NewGhostPiece(SwapState)
	end
	HoldLock = true
end

function FindTranslation(A,B) --finds the translations between two offsets (https://tetris.wiki/SRS)
	local Translation = {}
	for k,v in ipairs(A) do
		Translation[k] = {v[1] - B[k][1], v[2] - B[k][2]}
	end
	return Translation
end

function RotateAroundCenter(Pos,Dir) --rotates a pair of cordinates around the center point (0,0), Dir: False == Clockwise, True == Counter Clockwise
	if Dir then
		return {Pos[2] * (-1), Pos[1], Image = Pos.Image}
	else
		return {Pos[2], Pos[1] * (-1), Image = Pos.Image}
	end
end

function FindKey(Table, Value) --function that finds a value in a table, and returns the key
	for k,v in pairs(Table) do
		if v == Value then
			return k
		end
	end
end

function CopyList(List)
	local Copy = DeepCopy(List)
	for k,v in pairs(Copy) do
		Copy[k].Image = List[k].Image
	end
	return Copy
end

function SetActiveMinos(LocSwapState) --put a random Tetrominos in ActiveMinos
	local Test = false
	repeat
		local TakeList = {}
		if Settings.Pentominos == "false" then --logic for pentominos
			TakeList = CopyList(TetrominoList)
		elseif Settings.Pentominos == "true" then
			TakeList = CopyList(PentominoList)
		else
			local Num = math.random()
			if Num > 0.25 then
				TakeList = CopyList(TetrominoList)
			else
				TakeList = CopyList(PentominoList)
			end
		end
		local TetrominoID = math.random(7) --random number
		local I = 1 --start number
		local Final = false --PlaceHolder value
		for k,v in pairs(TakeList) do --go through all Tetrominos
			if I == TetrominoID then --check if we are on the correct Tetrominos yet
				local ImagePlaceHolder = v.Image --store Image to a PlaceHolder
				Final = DeepCopy(v) --copy Tetrominos to PlaceHolder value
				Final.Image = ImagePlaceHolder --paste it into Final
				break --exit for loop
			end
			I = I + 1
		end
		if Final.Image == Images.IPieceImage then --check if Final is an IPiece
			Final.MainPiece = {6,23} --if it is set the position to a special position
		else
			Final.MainPiece = {6,24} --set up position of Tetrominos
		end
		
		if CurrentMode == "Puyo" then
			local Types = {}
			for num=1,ProtSettings.MaxPolsInPeice do
				table.insert(Types, math.random(ProtSettings.Polarities))
			end
			for k,Minos in ipairs(Final) do
				Final[k].Image = Puyo[Types[math.random(ProtSettings.MaxPolsInPeice)]]
			end
			Final.MainPiece.Image = Puyo[Types[math.random(ProtSettings.MaxPolsInPeice)]]
		end
		
		if LocSwapState == 0 then
			ActiveMinos = UpComming --copy UpComming to ActiveMinos
		else
			SwapActiveMinos = UpComming --or to SwapActiveMinos, depends really
		end
		UpComming = Final --copy PlaceHolder to UpComming
		
		if LocSwapState == 0 then
			Test = ActiveMinos.MainPiece
		else
			Test = SwapActiveMinos.MainPiece
		end
		
	until Test --repeat if ActiveMinos is empty
	NewGhostPiece(LocSwapState) --make the ghost image
end

function CheckOverlap(Pos, LocSwapState) --function to check if a spot is occypied by another Minos
	
	local SWorld = false
	if LocSwapState == 0 then
		SWorld = InactiveMinos
	else
		SWorld = SwapInactiveMinos
	end
	
	if Pos[2] < 26 then
		if SWorld[Pos[2]] == nil then
			return true
		end
		if SWorld[Pos[2]][Pos[1]] == nil then --if spot is not empty or out of boundry
			return true --return true
		end
		if SWorld[Pos[2]][Pos[1]].Image ~= nil then
			if CurrentMode == "Puyo" then
				local Type = SWorld[Pos[2]][Pos[1]].Type
				return true, Type
			else
				return true
			end
		end
	else
		if SWorld[1] == nil then
			return true
		end
		if SWorld[1][Pos[1]] == nil then --if spot is not empty or out of boundry
			return true --return true
		end
	end
	return false --else return false
end --return true, if spot is out of boundry, or it is not empty

function RotateMain(Dir, LocSwapState) --Function that rotates ActiveMinos, Dir: False == Clockwise, True == Counter Clockwise
	
	local ACMinos = false
	if LocSwapState == 0 then
		ACMinos = ActiveMinos
	else
		ACMinos = SwapActiveMinos
	end
	
	if Settings.SRS == "false" then --check if SRS is enabled
		--if it is not
		local Fail = false --set up Fail Value
		for k,Minos in ipairs(ACMinos) do --for every non-main Minos in ActiveMinos
			local RotMinos = RotateAroundCenter(Minos, Dir) --placeholder Minos
			RotMinos[1], RotMinos[2] = RotMinos[1] + ACMinos.MainPiece[1], RotMinos[2] + ACMinos.MainPiece[2] --convert placeholder values to absolute values
			if CheckOverlap(RotMinos, LocSwapState) then --check for overlap
				Fail = true --if overlap is found, set Fail to true
				break --and exit the for loop
			end
		end
		if not Fail then --if rotation check did not fail
			for MinosNum,__ in ipairs(ActiveMinos) do --rotate all the pieces
				ACMinos[MinosNum] = RotateAroundCenter(ACMinos[MinosNum], Dir)
			end
			if LocSwapState == 0 then
				if MovReset < 10 then --check if MovReset is less than 10
					MovTimer = 0 --reset MovTimer
					MovReset = MovReset + 1 --add 1 to MovReset
				end
			else
				if SwapMovReset < 10 then
					SwapMovTimer = 0
					SwapMovReset = SwapMovReset + 1
				end
			end
			NewGhostPiece(LocSwapState)
		end
	else
		--if SRS is enabled
		local OffsetOrig = ACMinos.CurrentRotation --store the current rotation
		local OffsetNew = (Dir) and (OffsetOrig - 1) or (OffsetOrig + 1) --figure out the new rotation
		if OffsetNew < 0 then OffsetNew = 3 end --make sure it is still within 0-3 (inclusive)
		if OffsetNew > 3 then OffsetNew = 0 end
		
		local OffsetTable = false --set up OffsetTable variable
		if ACMinos.Image == Images.OPieceImage then --check what Offset Table to used
			OffsetTable = Offsets.O --O Piece
		elseif ACMinos.Image == Images.IPieceImage then
			OffsetTable = Offsets.I --I Piece
		else
			OffsetTable = Offsets.Other --Other Pieces
		end
		local Translations = FindTranslation(OffsetTable[OffsetOrig], OffsetTable[OffsetNew]) --get the Translation table from it
		local FinalTranslation = false --set up FinalTranslation table
		
		local TotalFail = true --set up TotalFail
		for k,Translation in ipairs(Translations) do --loop through all translation in Translations
			local Fail = false --set up Fail
			for kk,Minos in ipairs(ACMinos) do ----loop through all non-Main Minos
				local RotMinos = RotateAroundCenter(Minos, Dir) -- get the rotated version
				RotMinos = {RotMinos[1] + ACMinos.MainPiece[1] + Translation[1], RotMinos[2] + ACMinos.MainPiece[2] + Translation[2]} --apply a translation and convert cordinates to Absolute values
				if CheckOverlap(RotMinos, LocSwapState) then --check for overlap
					Fail = true --if overlap is detected, set fail to true
					break --break out of this for loop
				end
			end
			
			local RotMinos = DeepCopy(ACMinos.MainPiece) --same as above, but for the main piece
			RotMinos = {RotMinos[1] + Translation[1], RotMinos[2] + Translation[2]}
			if CheckOverlap(RotMinos, LocSwapState) then
				Fail = true
			end
			
			if not Fail then --if the check above did not fail
				FinalTranslation = Translation --store which translation succeded
				TotalFail = false --set TotalFail to false
				break --break out of the Translation for loop
			end
		end
		
		if not TotalFail then --if rotation check did not fail
			for MinosNum,__ in ipairs(ACMinos) do --rotate all the pieces
				ACMinos[MinosNum] = RotateAroundCenter(ACMinos[MinosNum], Dir)
			end
			ACMinos.MainPiece[1] = ACMinos.MainPiece[1] + FinalTranslation[1]
			ACMinos.MainPiece[2] = ACMinos.MainPiece[2] + FinalTranslation[2] --apply translation to the MainPiece
			ACMinos.CurrentRotation = OffsetNew
			if LocSwapState == 0 then
				if MovReset < 10 then --check if MovReset is less than 10
					MovTimer = 0 --reset MovTimer
					MovReset = MovReset + 1 --add 1 to MovReset
				end
			else
				if SwapMovReset < 10 then
					SwapMovTimer = 0
					SwapMovReset = SwapMovReset + 1
				end
			end
			NewGhostPiece(LocSwapState)
		end
	end
end

function NewGhostPiece(LocSwapState)
	local ImagePlaceHolder, ImageMain, Image1, Image2, Image3 = false, false, false, false, false
	local GMinos = false
	
	if LocSwapState == 0 then
		ImagePlaceHolder = ActiveMinos.Image
		if CurrentMode == "Puyo" then
			ImageMain = ActiveMinos.MainPiece.Image
			Image1 = ActiveMinos[1].Image
			Image2 = ActiveMinos[2].Image
			Image3 = ActiveMinos[3].Image
		end
		GhostMinos = DeepCopy(ActiveMinos)
		GMinos = GhostMinos
	else
		ImagePlaceHolder = SwapActiveMinos.Image
		if CurrentMode == "Puyo" then
			ImageMain = SwapActiveMinos.MainPiece.Image
			Image1 = SwapActiveMinos[1].Image
			Image2 = SwapActiveMinos[2].Image
			Image3 = SwapActiveMinos[3].Image
		end
		SwapGhostMinos = DeepCopy(SwapActiveMinos)
		GMinos = SwapGhostMinos
	end
	
	GMinos.Image = ImagePlaceHolder
	if CurrentMode == "Puyo" then
		GMinos.MainPiece.Image = ImageMain
		GMinos[1].Image = Image1
		GMinos[2].Image = Image2
		GMinos[3].Image = Image3
	end
	local Key = FindKey(Images, GMinos.Image)
	GMinos.Image = Ghost[Key]
	if CurrentMode == "Puyo" then
		local Key = FindKey(Puyo, GMinos.MainPiece.Image)
		GMinos.MainPiece.Image = Ghost[Key]
		local Key = FindKey(Puyo, GMinos[1].Image)
		GMinos[1].Image = Ghost[Key]
		local Key = FindKey(Puyo, GMinos[2].Image)
		GMinos[2].Image = Ghost[Key]
		local Key = FindKey(Puyo, GMinos[3].Image)
		GMinos[3].Image = Ghost[Key]
	end
	repeat
	until GhostPieceDown(LocSwapState)
end

function GhostPieceDown(LocSwapState) --move GhostMinos down by one
	
	local GMinos = false
	if LocSwapState == 0 then
		GMinos = GhostMinos
	else
		GMinos = SwapGhostMinos
	end
	
	local Lock = false --set up Lock value
	for k,Minos in ipairs(GMinos) do --check every non-main Minos
		local MovMinos = {Minos[1] + GMinos.MainPiece[1], Minos[2] + GMinos.MainPiece[2] - 1} --create PlaceHolder, and move it down by one
		if CheckOverlap(MovMinos, LocSwapState) then --check for overlap
			Lock = true --if ovelap is found, set Lock to true
			break --exit the for loop
		end
	end
	local MovMinos = {
		GMinos.MainPiece[1],
		GMinos.MainPiece[2] - 1
	} --same as above but for MainPiece
	if CheckOverlap(MovMinos, LocSwapState) then
		Lock = true --no need for break here since we are not in a for loop
	end
	if not Lock then
		GMinos.MainPiece[2] = GMinos.MainPiece[2] - 1 --if Lock was not detected then move piece down by one
	else
		return true --return true if piece was locked
	end
end

function MainPieceDown(LocSwapState) --move ActiveMinos down by one, lock piece if it is on the ground
	
	local ACMinos = false
	if LocSwapState == 0 then
		ACMinos = ActiveMinos
	else
		ACMinos = SwapActiveMinos
	end
	
	local Lock = false --set up Lock value
	for k,Minos in ipairs(ACMinos) do --check every non-main Minos
		local MovMinos = {Minos[1] + ACMinos.MainPiece[1], Minos[2] + ACMinos.MainPiece[2] - 1} --create PlaceHolder, and move it down by one
		if CheckOverlap(MovMinos, LocSwapState) then --check for overlap
			Lock = true --if ovelap is found, set Lock to true
			break --exit the for loop
		end
	end
	local MovMinos = {ACMinos.MainPiece[1], ACMinos.MainPiece[2] - 1} --same as above but for MainPiece
	if CheckOverlap(MovMinos, LocSwapState) then
		Lock = true --no need for break here since we are not in a for loop
	end
	if not Lock then
		ACMinos.MainPiece[2] = ACMinos.MainPiece[2] - 1 --if Lock was not detected then move piece down by one
	else
		local SWorld = false
		if LocSwapState == 0 then
			SWorld = InactiveMinos
		else
			SWorld = SwapInactiveMinos
		end
		
		local Pos = {}
		Pos[1] = {ACMinos.MainPiece[1], ACMinos.MainPiece[2]}
		Pos[2] = {ACMinos[1][1] + ACMinos.MainPiece[1], ACMinos[1][2] + ACMinos.MainPiece[2]}
		Pos[3] = {ACMinos[2][1] + ACMinos.MainPiece[1], ACMinos[2][2] + ACMinos.MainPiece[2]}
		Pos[4] = {ACMinos[3][1] + ACMinos.MainPiece[1], ACMinos[3][2] + ACMinos.MainPiece[2]}
		if ACMinos[4] then
			Pos[5] = {ACMinos[4][1] + ACMinos.MainPiece[1], ACMinos[4][2] + ACMinos.MainPiece[2]}
		end
		
		for k,Minos in ipairs(ACMinos) do --for every non-main Minos in ActiveMinos
			if CurrentMode == "Puyo" then
				SWorld[ACMinos.MainPiece[2] + Minos[2]][ACMinos.MainPiece[1] + Minos[1]].Image = Minos.Image --copy image to InactiveMinos at the correct location
				SWorld[ACMinos.MainPiece[2] + Minos[2]][ACMinos.MainPiece[1] + Minos[1]].Type = FindKey(Puyo, Minos.Image)
			else
				SWorld[ACMinos.MainPiece[2] + Minos[2]][ACMinos.MainPiece[1] + Minos[1]].Image = ACMinos.Image
			end
		end
		if CurrentMode == "Puyo" then
			SWorld[ACMinos.MainPiece[2]][ACMinos.MainPiece[1]].Image = ACMinos.MainPiece.Image --same as above but for MainPiece
			SWorld[ACMinos.MainPiece[2]][ACMinos.MainPiece[1]].Type = FindKey(Puyo, ACMinos.MainPiece.Image)
		else
			SWorld[ACMinos.MainPiece[2]][ACMinos.MainPiece[1]].Image = ACMinos.Image --same as above but for MainPiece
		end
		SetActiveMinos(LocSwapState) --get a new ActiveMinos
		if LocSwapState == 0 then
			MovTimer = 0 --reset the MovTimer
			MovReset = 0 --reset MovReset
		else
			SwapMovTimer = 0
			SwapMovReset = 0
		end
		HoldLock = false
		return true, Pos --return true if piece was locked
	end
end

function MainPieceSide(Side, LocSwapState) --Side: -1 = left, 1 = right
	
	local ACMinos = false
	if LocSwapState == 0 then
		ACMinos = ActiveMinos
	else
		ACMinos = SwapActiveMinos
	end
	
	local Fail = false --set up Fail variable
	for k,Minos in ipairs(ACMinos) do --loop through all non-main minos
		local MovMinos = {Minos[1] + ACMinos.MainPiece[1] + Side, Minos[2] + ACMinos.MainPiece[2]} --set up a moved version, and set it to an absolute position
		if CheckOverlap(MovMinos, LocSwapState) then --check for overlap
			Fail = true --if the overlap is found, then set Fail to true
			break --exit the for loop
		end
	end
	local MovMinos = {ACMinos.MainPiece[1] + Side, ACMinos.MainPiece[2]} --same as above but for the main piece
	if CheckOverlap(MovMinos, LocSwapState) then
		Fail = true
	end
	if not Fail then --if Fail is not true
		ACMinos.MainPiece[1] = ACMinos.MainPiece[1] + Side --move it
		if LocSwapState == 0 then
			if MovReset < 10 then --check if MovReset is less than 10
				MovTimer = 0 --reset the MovTimer timer
				MovReset = MovReset + 1 --add one to MovReset
			end
		else
			if SwapMovReset < 10 then
				SwapMovTimer = 0
				SwapMovReset = SwapMovReset + 1
			end
		end
		NewGhostPiece(LocSwapState)
	end
end

function PuyoWorldGravity(LocSwapState)
	
	local SWorld = false
	if LocSwapState == 0 then
		SWorld = InactiveMinos
	else
		SWorld = SwapInactiveMinos
	end
	
	local ListOfChanged = {}
	
	for y=2,25 do
		for x,Minos in pairs(SWorld[y]) do
			if Minos.Image ~= nil then
				local CurrentLowest = {x,y}
				while not (CheckOverlap({CurrentLowest[1], CurrentLowest[2] - 1}, LocSwapState)) do
					CurrentLowest = {CurrentLowest[1], CurrentLowest[2] - 1}
				end
				if CurrentLowest[2] ~= y then
					SWorld[CurrentLowest[2]][CurrentLowest[1]].Image = Minos.Image
					SWorld[CurrentLowest[2]][CurrentLowest[1]].Type = Minos.Type
					SWorld[y][x] = {}
					AddToTable(ListOfChanged, CurrentLowest)
				end
			end
		end
	end
	return ListOfChanged
end

function ConvertToNormal(Table)
	Result = {}
	for x,Row in pairs(Table) do
		for y,__ in pairs(Row) do
			table.insert(Result, {x,y})
		end
	end
	return Result
end

function AddToTable(Table,Input)
    if Table[Input[1]] == nil then
        Table[Input[1]] = {}
        Table[Input[1]][Input[2]] = true
    else
		Table[Input[1]][Input[2]] = true
    end
end

function CheckTable(Table, Input)
    if Table[Input[1]] == nil then
        return false
    end
    return Table[Input[1]][Input[2]]
end

function CountTable(Table)
	local Count = 0
	for k,v in pairs(Table) do
		for kk,vv in pairs(v) do
			Count = Count + 1
		end
	end
	return Count
end

function FindChain(Pos, LocSwapState, Table, Type)
	
	if not Table then
		Table = {}
	end
	
	local State, GotType = CheckOverlap(Pos, LocSwapState)
	if GotType then
		if (GotType == Type) or (Type == nil) then
			Type = GotType
			if not CheckTable(Table, Pos) then
				AddToTable(Table, Pos)
				FindChain({Pos[1] - 1, Pos[2]}, LocSwapState, Table, Type)
				FindChain({Pos[1] + 1, Pos[2]}, LocSwapState, Table, Type)
				FindChain({Pos[1], Pos[2] - 1}, LocSwapState, Table, Type)
				FindChain({Pos[1], Pos[2] + 1}, LocSwapState, Table, Type)
				return Table, CountTable(Table)
			end
		end
	end
end

function CheckLine(Row, LocSwapState) --checks a line and returns if it is full or not
	
	local SWorld = false
	if LocSwapState == 0 then
		SWorld = InactiveMinos
	else
		SWorld = SwapInactiveMinos
	end
	
	local Count = 0 --set up Count Value
	for k,v in pairs(SWorld[Row]) do --loop through all Minos in the Row
		if v.Image ~= nil then --check if they have something in them
			Count = Count + 1 --add one to Count if they do
		end
	end
	if Count == 10 then --if Count is 10
		return true, Row --return true and Row number
	end
end

function CheckAbove(Row, LocSwapState) --check how many Minos are in the Row and above the Row
	
	local SWorld = false
	if LocSwapState == 0 then
		SWorld = InactiveMinos
	else
		SWorld = SwapInactiveMinos
	end
	
	local Count = 0 --set up Count
	for y=Row,25 do --loop through all Rows above Row, (and including Row)
		for k,Minos in pairs(SWorld[y]) do --loop through all Minos 
			if Minos.Image ~= nil then --check if there is something there
				Count = Count + 1 --add one to Count if there is
			end
		end
	end
	return Count --return Count
end

function ClearLines(LocSwapState) --Clears all lines, and adds them to the score
	local Lines = 0 --set up lines counter
	local SpecLines = {} --set up table
	for x=1,25 do --loop through all lines
		local Success = CheckLine(x, LocSwapState) --check each of them
		if Success then --if the check was succesful
			Lines = Lines + 1 --add one to Lines
			SpecLines[x] = true --add the line number to SpecLines
		end
	end
	if Lines == 1 then --if Lines is 1
		Score.Singles = Score.Singles + 1 --add 1 to Singles
		ScoreAmount = ScoreAmount + (ProtSettings.Single * Level)
	elseif Lines == 2 then --if Lines is 2
		Score.Doubles = Score.Doubles + 1 --add 1 to Doubles
		ScoreAmount = ScoreAmount + (ProtSettings.Double * Level)
	elseif Lines == 3 then --if Lines is 3
		Score.Triples = Score.Triples + 1 --add 1 to Triples
		ScoreAmount = ScoreAmount + (ProtSettings.Triple * Level)
	elseif Lines == 4 then --if Lines is 4
		Score.Tetris = Score.Tetris + 1 --add 1 to Tetrs
		ScoreAmount = ScoreAmount + (ProtSettings.Tetris * Level)
	elseif Lines == 5 then --if Lines is 5 (Pentominos much?)
		Score.STetris = Score.STetris + 1 --add 1 to STetrs
		ScoreAmount = ScoreAmount + (ProtSettings.STetris * Level)
	end
	
	local SWorld = false
	if LocSwapState == 0 then
		SWorld = InactiveMinos
	else
		SWorld = SwapInactiveMinos
	end
	
	for x=25,1,-1 do --loop through all lines from top to bottom
		if SpecLines[x] ~= nil then --if that line is in SpecLines
			for y=x,25 do --loop through all Lines above x
				SWorld[y] = SWorld[y + 1] --replace it with the line above
			end
			SWorld[25] = {} --set line 25 to an empty table
			for y=1,10 do --reset line 25
				SWorld[25][y] = {}
			end
		end
	end
	NewGhostPiece(LocSwapState) --remake the ghost peice
end

function WriteControlsToFile() --function that writes the controls to a file
	local Done = false --PlaceHolder variable
	for k,v in pairs(Controls) do --loop through all Controls
		if Done then --check the PlaceHolder variable
			love.filesystem.append("Controls.txt", v.." = "..k..";") --if it is true, append Control to file
		else
			love.filesystem.write("Controls.txt", v.." = "..k..";") --else, write Control to file
			Done = true --set PlaceHolder to true
		end
	end
end

function WriteSettingsToFile() --function that writes the Settings to a file
	local Done = false --PlaceHolder variable
	for k,v in pairs(Settings) do --loop through all Settings
		if Done then --check the PlaceHolder variable
			love.filesystem.append("Settings.txt", k.." = "..v..";") --if it is true, append Setting to file
		else
			love.filesystem.write("Settings.txt", k.." = "..v..";") --else, write Setting to file
			Done = true --set PlaceHolder to true
		end
	end
end

function SwapScreens()
	if SwapState == 0 then
		SwapState = 1
	else
		SwapState = 0
	end
end

function WriteScoresToFile() --function that writes highscores to file
	
	local HighscoresText = false
	local HighscoresTable = false
	if CurrentMode == "Standard" then
		HighscoresText = "Highscores.txt"
		HighscoresTable = Highscores
	elseif CurrentMode == "Swap" then
		HighscoresText = "SwapHighscores.txt"
		HighscoresTable = SwapHighscores
	elseif CurrentMode == "Hidden" then
		HighscoresText = "HiddenHighscores.txt"
		HighscoresTable = HiddenHighscores
	else
		HighscoresText = "PuyoHighscores.txt"
		HighscoresTable = PuyoHighscores
	end
	
	love.filesystem.write(HighscoresText, "1 = "..tostring(HighscoresTable[1])..";") --score 1
	love.filesystem.append(HighscoresText, "2 = "..tostring(HighscoresTable[2])..";") --score 2
	love.filesystem.append(HighscoresText, "3 = "..tostring(HighscoresTable[3])..";") --score 3
	love.filesystem.append(HighscoresText, "4 = "..tostring(HighscoresTable[4])..";") --score 4
	love.filesystem.append(HighscoresText, "5 = "..tostring(HighscoresTable[5])..";") --score 5
end

function SubmitCurrentScore() --adds the current score to the list, and saves it
	
	local HighscoresTable = false
	if CurrentMode == "Standard" then
		HighscoresTable = Highscores
	elseif CurrentMode == "Swap" then
		HighscoresTable = SwapHighscores
	elseif CurrentMode == "Hidden" then
		HighscoresTable = HiddenHighscores
	else
		HighscoresTable = PuyoHighscores
	end
	
	table.insert(HighscoresTable, ScoreAmount) --insert the current score into the Highscores table
	table.sort(HighscoresTable, function(a,b) return a > b end) --sort the table, largest first
	HighscoresTable[6] = nil --remove the last value from the table
	WriteScoresToFile() --Write Highscores to file
end

function love.update(dt) --Update Function
	if Status == "Game" then --check the Status, make sure it is "Game"
		if (MovTimer > ((85.52 * 0.88^Level)/100)) and not (PuyoWaiting) then --If the Movement Timer is above the threshold
			local state, Pos = MainPieceDown(0) --Move ActiveMinos down by one
			if state and (CurrentMode ~= "Puyo") then --if ActiveMinos was Locked
				ClearLines(0) --Clear all the lines
			elseif state and (CurrentMode == "Puyo") then
				PuyoWaiting = "remove"
				PuyoWaitState = Pos
			end
			MovTimer = 0 --reset the MovTimer
		elseif not PuyoWaiting then
			MovTimer = MovTimer + dt --if the Movement Timer is not above the threshold, then add dt to it
		else
			if PuyoTimer > tonumber(ProtSettings.TimerBetweenAction) then
				if PuyoWaiting == "remove" then
					local OldDetected = {}
					for k,Remove in ipairs(PuyoWaitState) do
						local Detected, Length = FindChain(Remove, 0)
						if Length ~= nil then
							if Length > tonumber(ProtSettings.ChainLength) then
								
								local DupeTest = false
								for k,v in pairs(OldDetected) do
									for x,Row in pairs(v) do
										for y,__ in pairs(Row) do
											if CheckTable(Detected, {x,y}) then
												DupeTest = true
											end
											break
										end
										break
									end
									if DupeTest then
										break
									end
								end
								
								if not DupeTest then
									for x,Row in pairs(Detected) do
										for y,__ in pairs(Row) do
											InactiveMinos[y][x] = {}
										end
									end
									ScoreAmount = ScoreAmount + (Length * Chain * 100 * Level)
									Chain = Chain + 1
									Score.Singles = Score.Singles + 1
									OldDetected[#OldDetected + 1] = Detected
								end
							end
						end
					end
					PuyoWaiting = "gravity"
					PuyoTimer = 0
					PuyoWaitState = {}
				elseif PuyoWaiting == "gravity" then
					PuyoWaitState = PuyoWorldGravity(0)
					NewGhostPiece(0)
					if (CountTable(PuyoWaitState) ~= 0) then
						PuyoWaiting = "remove"
						PuyoWaitState = ConvertToNormal(PuyoWaitState)
					else
						PuyoWaiting = nil
						Chain = 1
						PuyoWaitState = {}
					end
					PuyoTimer = 0
				end
			else
				PuyoTimer = PuyoTimer + dt * 1000
			end
		end
		if CurrentMode == "Swap" then
			if SwapMovTimer > ((85.52 * 0.88^Level)/100) then --If the Movement Timer is above the threshold
				local state = MainPieceDown(1) --Move ActiveMinos down by one
				if state then --if ActiveMinos was Locked
					ClearLines(1) --Clear all the lines
				end
				SwapMovTimer = 0 --reset the MovTimer
			else
				SwapMovTimer = SwapMovTimer + dt --if the Movement Timer is not above the threshold, then add dt to it
			end
		end
		if Soft_Drop.Activated and not PuyoWaiting then --if the Soft_Drop button is being held down
			if Soft_Drop.Timer == 0 then --check if it was just pressed
				local state, Pos = MainPieceDown(SwapState) --if it was just pressed, move ActiveMinos down by one
				if state and (CurrentMode ~= "Puyo") then --if ActiveMinos was Locked
					ClearLines(SwapState) --Clear all the lines
				elseif state and CurrentMode == "Puyo" then
					PuyoWaiting = "remove"
					PuyoWaitState = Pos
				end
				Soft_Drop.Timer = Soft_Drop.Timer + (dt * 1000) --add time to the Soft_Drop Timer
			elseif Soft_Drop.Timer > Settings.AutoRepeat_Delay then --else, if Soft_Drop Timer is more that AutoRepeat_Delay
				local state, Pos = MainPieceDown(SwapState) --move ActiveMinos down by one
				if state and (CurrentMode ~= "Puyo") then --if ActiveMinos was Locked
					ClearLines(SwapState) --Clear all the lines
				elseif state and CurrentMode == "Puyo" then
					PuyoWaiting = "remove"
					PuyoWaitState = Pos
				end
				Soft_Drop.Timer = Settings.AutoRepeat_Delay - Settings.AutoRepeat_Speed --Reset Soft_Drop Timer
			else
				Soft_Drop.Timer = Soft_Drop.Timer + (dt * 1000) --if Soft_Drop Timer fulfills none of the above, add some time to it
			end
		end
		if Move_Left.Activated then --if the Move_Left button is being held down
			if Move_Left.Timer == 0 then --was it just pressed?
				MainPieceSide(-1, SwapState) --if yes, move it left
				Move_Left.Timer = Move_Left.Timer + (dt * 1000) --and add time to the timer
			elseif Move_Left.Timer > Settings.AutoRepeat_Delay then --else, if the timer is more than the delay
				MainPieceSide(-1, SwapState) --move it left
				Move_Left.Timer = Settings.AutoRepeat_Delay - Settings.AutoRepeat_Speed --and reset the timer
			else
				Move_Left.Timer = Move_Left.Timer + (dt * 1000) --add time to the timer
			end
		end
		if Move_Right.Activated then --same as above, but right instead of left
			if Move_Right.Timer == 0 then
				MainPieceSide(1, SwapState)
				Move_Right.Timer = Move_Right.Timer + (dt * 1000)
			elseif Move_Right.Timer > Settings.AutoRepeat_Delay then
				MainPieceSide(1, SwapState)
				Move_Right.Timer = Settings.AutoRepeat_Delay - Settings.AutoRepeat_Speed
			else
				Move_Right.Timer = Move_Right.Timer + (dt * 1000)
			end
		end
		if (CheckAbove(21, 0) > 0) or (CheckAbove(21, 1) > 0) then --if the amount above the red line is more that 0
			Status = "Dead" --set the status to "Dead"
			HoldSpot = {}
			SubmitCurrentScore() --submit the score to the Highscore table
		end
		if love.keyboard.isDown("escape") then
			Status = "Pause"
		end
	elseif love.keyboard.isDown("return") and Status == "Dead" and not Prohibit then --if the player presses the enter key while Status is "Dead"
		Status = "Menu" --reset the Status
		SetUpWorld() --reset the world
		SetActiveMinos() --get a new ActiveMinos
		UpComming = {} --reset UpComming
		
		Prohibit = true --set up prohibiter
	elseif love.keyboard.isDown("return") and Status == "Menu" and (CurrentMode == "Standard" or CurrentMode == "Hidden" or CurrentMode == "Puyo") and not Prohibit then --if the player presses the enter key while Status is "Menu"
		Status = "Game"
		SetUpWorld() --reset the world
		SetActiveMinos(0) --get a new ActiveMinos
		
		SwapState = 0
		
		Score.Singles = 0 --reset all the line counters
		Score.Doubles = 0
		Score.Triples = 0
		Score.Tetris = 0
		Score.STetris = 0
		ScoreAmount = 0 --reset the score counter
		
		Prohibit = true --set up prohibiter
	elseif love.keyboard.isDown("return") and Status == "Menu" and CurrentMode == "Swap" and not Prohibit then --if the player presses the enter key while Status is "Menu"
		Status = "Game"
		SetUpWorld() --reset the world
		SetActiveMinos(0) --get a new ActiveMinos
		SetActiveMinos(1)
		
		SwapState = 0
		
		Score.Singles = 0 --reset all the line counters
		Score.Doubles = 0
		Score.Triples = 0
		Score.Tetris = 0
		Score.STetris = 0
		ScoreAmount = 0 --reset the score counter
		
		Prohibit = true --set up prohibiter
	elseif love.keyboard.isDown("return") and Status == "Pause" and not Prohibit then --if enter is pressed while Status is "Pause"
		Status = "Game" --set Status to "Game"
		
		Prohibit = true --set up prohibiter
	elseif love.keyboard.isDown("return") and Status == "Controls" and not Prohibit then --if enter is pressed while Status is "Controls"
		Status = OldStatus -- set Status to what is was before
		OldStatus = nil --clear placeholder variable
		WriteControlsToFile() --write controls to a file
		
		Prohibit = true --set up prohibiter
	elseif love.keyboard.isDown("return") and Status == "Settings" and not Prohibit then --if enter is pressed while Status is "Settings"
		if not SelectSetting then --if no setting is selected
			Status = "Menu" --set Status to "Menu"
			WriteSettingsToFile() --write Settings to file
			
			Prohibit = true --set up prohibiter
		else
			Settings[SelectSetting] = tonumber(SelectValue) --else, copy the setting to the Settings table
			SelectSetting = nil --and clear the SelectSetting values
			SelectValue = nil
			
			Prohibit = true --set up prohibiter
		end
	end
	Level = math.max(math.floor((Score.Singles + (Score.Doubles * 2) + (Score.Triples * 3) + (Score.Tetris * 4))/10) + 1, ChosenLevel) --handle levels
end

function love.draw() --drawing function
	love.graphics.draw(BackGround,0,0)
	love.graphics.setColor(0,0,0,0.5)
	love.graphics.rectangle("fill", 0, 0, 800, 720)
	love.graphics.setColor(1,1,1)
	if not (CurrentMode == "Swap") then
		for y,Row in pairs(InactiveMinos) do --loop through all lines
			for x,Minos in pairs(Row) do --loop through all minos in that line
				if Minos.Image ~= nil and Status ~= "Pause" and Status ~= "Controls" and (not (CurrentMode == "Hidden")) then --check if it is empty
					love.graphics.draw(Minos.Image, 28 * x + ScreenX, 714 - (28 * y)) --draw the minos
				else
					love.graphics.draw(Blank, 28 * x + ScreenX, 714 - (28 * y)) --if the spot is empty, draw the backgrounf sprite
				end
			end
		end
	else
		local MainIM = false
		local SideIM = false
		if SwapState == 0 then
			MainIM = InactiveMinos
			SideIM = SwapInactiveMinos
		else
			MainIM = SwapInactiveMinos
			SideIM = InactiveMinos
		end
		
		for y,Row in pairs(MainIM) do --loop through all lines
			for x,Minos in pairs(Row) do --loop through all minos in that line
				if Minos.Image ~= nil and Status ~= "Pause" and Status ~= "Controls" then --check if it is empty
					love.graphics.draw(Minos.Image, 28 * x + ScreenX, 714 - (28 * y)) --draw the minos
				else
					love.graphics.draw(Blank, 28 * x + ScreenX, 714 - (28 * y)) --if the spot is empty, draw the background sprite
				end
			end
		end
		
		if Status == "Game" or Status == "Dead" then
			for y,Row in pairs(SideIM) do
				for x,Minos in pairs(Row) do
					if Minos.Image ~= nil and Status ~= "Pause" and Status ~= "Contols" then
						love.graphics.draw(Minos.Image, 350 + 14 * x + ScreenX, 567 - (14 * y), 0, 0.5, 0.5)
					else
						love.graphics.draw(Blank, 350 + 14 * x + ScreenX, 567 - (14 * y), 0, 0.5, 0.5)
					end
				end
			end
			
			love.graphics.rectangle("line", 368 + ScreenX, 567, 140, -350)
			love.graphics.setColor(1,0,0)
			love.graphics.line(368 + ScreenX, 287, 508 + ScreenX, 287)
			love.graphics.setColor(1,1,1)
		end
	end
	
	if Status == "Game" then
		
		local MainAM
		local SideAM
		local MainGM
		local SideGM
		if SwapState == 0 then
			MainAM = ActiveMinos
			SideAM = SwapActiveMinos
			MainGM = GhostMinos
			SideGM = SwapGhostMinos
		else
			MainAM = SwapActiveMinos
			SideAM = ActiveMinos
			MainGM = SwapGhostMinos
			SideGM = GhostMinos
		end
		
		if not (CurrentMode == "Puyo") then
			love.graphics.draw(MainAM.Image, 28 * MainAM.MainPiece[1] + ScreenX, 714 - (28 * MainAM.MainPiece[2])) --draw the MainPiece of ActiveMinos
			for MinosNum,v in ipairs(MainAM) do --draw all the other Pieces
				love.graphics.draw(MainAM.Image, 28 * (MainAM[MinosNum][1] + MainAM.MainPiece[1]) + ScreenX, 714 - (28 * (MainAM[MinosNum][2] + MainAM.MainPiece[2])))
			end
			
			love.graphics.draw(MainGM.Image, 28 * MainGM.MainPiece[1] + ScreenX, 714 - (28 * MainGM.MainPiece[2])) --draw the MainPiece of GhostMinos
			for MinosNum,v in ipairs(MainGM) do --draw all the other Pieces
				love.graphics.draw(MainGM.Image, 28 * (MainGM[MinosNum][1] + MainGM.MainPiece[1]) + ScreenX, 714 - (28 * (MainGM[MinosNum][2] + MainGM.MainPiece[2])))
			end
			
			if CurrentMode == "Swap" then
				love.graphics.draw(SideAM.Image, 350 + 14 * SideAM.MainPiece[1] + ScreenX, 567 - (14 * SideAM.MainPiece[2]), 0, 0.5, 0.5) --draw the MainPiece of ActiveMinos
				for MinosNum,v in ipairs(SideAM) do --draw all the other Pieces
					love.graphics.draw(SideAM.Image, 350 + 14 * (SideAM[MinosNum][1] + SideAM.MainPiece[1]) + ScreenX, 567 - (14 * (SideAM[MinosNum][2] + SideAM.MainPiece[2])), 0, 0.5, 0.5)
				end
				
				love.graphics.draw(SideGM.Image, 350 + 14 * SideGM.MainPiece[1] + ScreenX, 567 - (14 * SideGM.MainPiece[2]), 0, 0.5, 0.5) --draw the MainPiece of GhostMinos
				for MinosNum,v in ipairs(SideGM) do --draw all the other Pieces
					love.graphics.draw(SideGM.Image, 350 + 14 * (SideGM[MinosNum][1] + SideGM.MainPiece[1]) + ScreenX, 567 - (14 * (SideGM[MinosNum][2] + SideGM.MainPiece[2])), 0, 0.5, 0.5)
				end
			end
			
			love.graphics.line(MainTextX, 400, MainTextX + 150, 400, MainTextX + 150, 250, MainTextX, 250, MainTextX, 400)
			love.graphics.print("Next:", MainTextX + 3, 250)
			love.graphics.draw(UpComming.Image, MainTextX + 61, 311) --draw the MainPiece of GhostMinos
			for MinosNum,v in ipairs(UpComming) do --draw all the other Pieces
				love.graphics.draw(UpComming.Image, (28 * UpComming[MinosNum][1]) + MainTextX + 61, (28 * UpComming[MinosNum][2] * (-1)) + 311)
			end
			
			
			love.graphics.line(MainTextX, 570, MainTextX + 150, 570, MainTextX + 150, 420, MainTextX, 420, MainTextX, 570)
			love.graphics.print("Hold:", MainTextX + 3, 420)
			if HoldSpot.Image then
				love.graphics.draw(HoldSpot.Image, MainTextX + 61, 481) --draw the MainPiece of HoldSpot
				for MinosNum,v in ipairs(HoldSpot) do --draw all the other Pieces
					love.graphics.draw(HoldSpot.Image, (28 * HoldSpot[MinosNum][1]) + MainTextX + 61, (28 * HoldSpot[MinosNum][2] * (-1)) + 481)
				end
			end
		else
			love.graphics.draw(MainAM.MainPiece.Image, 28 * MainAM.MainPiece[1] + ScreenX, 714 - (28 * MainAM.MainPiece[2])) --draw the MainPiece of ActiveMinos
			for MinosNum,v in ipairs(MainAM) do --draw all the other Pieces
				love.graphics.draw(MainAM[MinosNum].Image, 28 * (MainAM[MinosNum][1] + MainAM.MainPiece[1]) + ScreenX, 714 - (28 * (MainAM[MinosNum][2] + MainAM.MainPiece[2])))
			end
			
			love.graphics.draw(MainGM.MainPiece.Image, 28 * MainGM.MainPiece[1] + ScreenX, 714 - (28 * MainGM.MainPiece[2])) --draw the MainPiece of GhostMinos
			for MinosNum,v in ipairs(MainGM) do --draw all the other Pieces
				love.graphics.draw(MainGM[MinosNum].Image, 28 * (MainGM[MinosNum][1] + MainGM.MainPiece[1]) + ScreenX, 714 - (28 * (MainGM[MinosNum][2] + MainGM.MainPiece[2])))
			end
			
			if CurrentMode == "Swap" then
				love.graphics.draw(SideAM.MainPiece.Image, 350 + 14 * SideAM.MainPiece[1] + ScreenX, 567 - (14 * SideAM.MainPiece[2]), 0, 0.5, 0.5) --draw the MainPiece of ActiveMinos
				for MinosNum,v in ipairs(SideAM) do --draw all the other Pieces
					love.graphics.draw(SideAM[MinosNum].Image, 350 + 14 * (SideAM[MinosNum][1] + SideAM.MainPiece[1]) + ScreenX, 567 - (14 * (SideAM[MinosNum][2] + SideAM.MainPiece[2])), 0, 0.5, 0.5)
				end
				
				love.graphics.draw(SideGM.MainPiece.Image, 350 + 14 * SideGM.MainPiece[1] + ScreenX, 567 - (14 * SideGM.MainPiece[2]), 0, 0.5, 0.5) --draw the MainPiece of GhostMinos
				for MinosNum,v in ipairs(SideGM) do --draw all the other Pieces
					love.graphics.draw(SideGM[MinosNum].Image, 350 + 14 * (SideGM[MinosNum][1] + SideGM.MainPiece[1]) + ScreenX, 567 - (14 * (SideGM[MinosNum][2] + SideGM.MainPiece[2])), 0, 0.5, 0.5)
				end
			end
			
			
			love.graphics.line(MainTextX, 400, MainTextX + 150, 400, MainTextX + 150, 250, MainTextX, 250, MainTextX, 400)
			love.graphics.print("Next:", MainTextX + 3, 250)
			love.graphics.draw(UpComming.MainPiece.Image, MainTextX + 61, 311) --draw the MainPiece of GhostMinos
			for MinosNum,v in ipairs(UpComming) do --draw all the other Pieces
				love.graphics.draw(UpComming[MinosNum].Image, (28 * UpComming[MinosNum][1]) + MainTextX + 61, (28 * UpComming[MinosNum][2] * (-1)) + 311)
			end
			
			
			love.graphics.line(MainTextX, 570, MainTextX + 150, 570, MainTextX + 150, 420, MainTextX, 420, MainTextX, 570)
			love.graphics.print("Hold:", MainTextX + 3, 420)
			if HoldSpot.Image then
				love.graphics.draw(HoldSpot.MainPiece.Image, MainTextX + 61, 481) --draw the MainPiece of HoldSpot
				for MinosNum,v in ipairs(HoldSpot) do --draw all the other Pieces
					love.graphics.draw(HoldSpot[MinosNum].Image, (28 * HoldSpot[MinosNum][1]) + MainTextX + 61, (28 * HoldSpot[MinosNum][2] * (-1)) + 481)
				end
			end
		end
	end
	
	love.graphics.setLineWidth(4) --draw some lines
	love.graphics.setColor(1,0,0)
	love.graphics.line(ScreenX + 28,154,ScreenX + 308,154)
	love.graphics.setColor(1,1,1)
	
	--draw a bunch of text
	love.graphics.print("Singles:", MainTextX, 15, 0); love.graphics.print(FormatNumber(Score.Singles), MainTextX + 110, 15, 0) --Singles
	love.graphics.print("Doubles:", MainTextX, 37, 0); love.graphics.print(FormatNumber(Score.Doubles), MainTextX + 110, 37, 0) --Doubles
	love.graphics.print("Triples:", MainTextX, 59, 0); love.graphics.print(FormatNumber(Score.Triples), MainTextX + 110, 59, 0) --Triples
	love.graphics.print("Tetris:", MainTextX, 81, 0); love.graphics.print(FormatNumber(Score.Tetris), MainTextX + 110, 81, 0) --Tetrises
	love.graphics.print("Super Tetris:", MainTextX, 103, 0); love.graphics.print(FormatNumber(Score.STetris), MainTextX + 110, 103, 0) --Super Tetrises (5 lines)
	local TotalLines = Score.Singles + (Score.Doubles * 2) + (Score.Triples * 3) + (Score.Tetris * 4) + (Score.STetris * 5) --calculation, not drawing
	love.graphics.print("Total Lines:", MainTextX, 125, 0); love.graphics.print(FormatNumber(TotalLines), MainTextX + 110, 125, 0) --total amount of lines
	love.graphics.print("Score:", MainTextX, 147, 0); love.graphics.print(FormatNumber(ScoreAmount), MainTextX + 110, 147, 0) --current score
	love.graphics.print("Level:", MainTextX, 169, 0); love.graphics.print(FormatNumber(Level), MainTextX + 110, 169, 0) --current level
	
	local HighscoresTable = false
	if CurrentMode == "Standard" then
		HighscoresTable = Highscores
	elseif CurrentMode == "Swap" then
		HighscoresTable = SwapHighscores
	elseif CurrentMode == "Hidden" then
		HighscoresTable = HiddenHighscores
	else
		HighscoresTable = PuyoHighscores
	end
	
	--draw more text
	love.graphics.print("Highscores:", MainTextX, 714 - 132, 0) --Highscores text
	love.graphics.print("1:", MainTextX, 714 - 110, 0); love.graphics.print(FormatNumber(HighscoresTable[1]), MainTextX + 20, 714 - 110, 0) --score 1
	love.graphics.print("2:", MainTextX, 714 - 88, 0); love.graphics.print(FormatNumber(HighscoresTable[2]), MainTextX + 20, 714 - 88, 0) --score 2
	love.graphics.print("3:", MainTextX, 714 - 66, 0); love.graphics.print(FormatNumber(HighscoresTable[3]), MainTextX + 20, 714 - 66, 0) --score 3
	love.graphics.print("4:", MainTextX, 714 - 44, 0); love.graphics.print(FormatNumber(HighscoresTable[4]), MainTextX + 20, 714 - 44, 0) --score 4
	love.graphics.print("5:", MainTextX, 714 - 22, 0); love.graphics.print(FormatNumber(HighscoresTable[5]), MainTextX + 20, 714 - 22, 0) --score 5
	
	love.graphics.line(ScreenX + 28,800,ScreenX + 28,0,ScreenX + 308,0,ScreenX + 308,800)
	
	if Status ~= "Game" then --if the player is not in a game
		love.graphics.draw(Title, ScreenX + 45, 0) --draw the title
	end
	if Status == "Dead" then --if the player is dead, draw that text
		love.graphics.setFont(LargeFont)
		love.graphics.print("You Died", MainTextX + 10, 300, 0)
		love.graphics.setFont(StandardFont)
	end
	if Status == "Menu" then --if the player is one the menu
		
		
		love.graphics.setFont(LargeFont)
		love.graphics.print("Press Enter\nTo Start", MainTextX + 10, 300, 0)
		love.graphics.setFont(StandardFont)
		
		love.graphics.print("Developed By: \nSpaceCat~Chan \nMany Ideas By: \nJadeeye", 550, 3) --draw credits
		
		love.graphics.print("Choose Level:", MainTextX, 195, 0)
		love.graphics.line(MainTextX + 30, 220, MainTextX + 40, 245, MainTextX + 20, 245, MainTextX + 30, 220)
		love.graphics.print(ChosenLevel, (MainTextX + 24) - ((#tostring(ChosenLevel) - 1) * 5), 248, 0)
		love.graphics.line(MainTextX + 30, 300, MainTextX + 40, 275, MainTextX + 20, 275, MainTextX + 30, 300)
		
		love.graphics.line(600, 640, 600, 670, 780, 670, 780, 640, 600, 640) --draw the Settings Button
		love.graphics.print("Settings", 653, 643, 0)
		
		love.graphics.setFont(LargeFont)
		love.graphics.print("Modes:", 550, 90)
		love.graphics.setFont(StandardFont)
		
		love.graphics.rectangle("line", 550, 130, 110, 25)
		if CurrentMode == "Standard" then
			love.graphics.print({{1, 0.5, 0.5}, "Standard"}, 553, 133)
		else
			love.graphics.print("Standard", 553, 133)
		end
		
		love.graphics.rectangle("line", 550, 170, 110, 25)
		if CurrentMode == "Swap" then
			love.graphics.print({{1, 0.5, 0.5}, "Swap"}, 553, 173)
		else
			love.graphics.print("Swap", 553, 173)
		end
		
		love.graphics.rectangle("line", 550, 210, 110, 25)
		if CurrentMode == "Hidden" then
			love.graphics.print({{1, 0.5, 0.5}, "Hidden"}, 553, 213)
		else
			love.graphics.print("Hidden", 553, 213)
		end
		
		love.graphics.rectangle("line", 550, 250, 110, 25)
		if CurrentMode == "Puyo" then
			love.graphics.print({{1, 0.5, 0.5}, "Puyo"}, 553, 253)
		else
			love.graphics.print("Puyo", 553, 253)
		end
	end
	if Status == "Pause" then --if the player is paused
		love.graphics.setFont(LargeFont)
		love.graphics.print("Paused", MainTextX + 10, 300, 0) --print some text
		love.graphics.setFont(StandardFont)
		love.graphics.print("Press Enter To Resume", MainTextX + 10, 344, 0)
	end
	if Status == "Pause" or Status == "Menu" then --if the player is paused or on the menu
		love.graphics.line(600, 680, 600, 710, 780, 710, 780, 680, 600, 680) --draw the Controls Button
		love.graphics.print("Controls", 653, 683, 0)
	end
	
	if Status == "Controls" then --if the player is in the Settings
		love.graphics.setFont(LargeFont)
		love.graphics.print("Enter To Exit", 550, 0, 0) --draw some text
		love.graphics.setFont(StandardFont)
		local Count = 1 --set up Count variable
		for k,v in pairsV(Controls) do --loop through all items in Controls, in order of values
			love.graphics.print(v, 603, (27 * Count * 2), 0) --draw text
			love.graphics.line(600, (27 * Count * 2) + 25, 600, (27 * (Count) * 2) + 50, 780, (27 * (Count) * 2) + 50, 780, (27 * Count * 2) + 25, 600, (27 * Count * 2) + 25) --draw box
			if ReplaceControl == v then --check if current Control is selected
				love.graphics.print("Press A Key", 603, (27 * Count * 2) + 27, 0) --if it is, print "Press A Key"
			else
				love.graphics.print(k, 603, (27 * Count * 2) + 27, 0) --else, print normally
			end
			Count = Count + 1 --add one to Count
		end
		love.graphics.line(600, (27 * Count * 2) + 25, 600, (27 * (Count) * 2) + 50, 780, (27 * (Count) * 2) + 50, 780, (27 * Count * 2) + 25, 600, (27 * Count * 2) + 25) --draw the reset buttons box
		love.graphics.print("Reset", 603, (27 * Count * 2) + 27, 0) --draw the reset text
	end
	
	if Status == "Settings" then
		love.graphics.setFont(LargeFont)
		love.graphics.print("Enter To Exit", 550, 0, 0) --draw some text
		love.graphics.setFont(StandardFont)
		local Count = 1 --set up Count variable
		for _,k in pairs(sortedKeys(Settings)) do --loop through all items in Settings, in order-of-a-lua-table-with-string-keys
			local v = Settings[k] --set up v Variable
			love.graphics.print(k, 603, (27 * Count * 2), 0) --draw text
			love.graphics.line(600, (27 * Count * 2) + 25, 600, (27 * (Count) * 2) + 50, 780, (27 * (Count) * 2) + 50, 780, (27 * Count * 2) + 25, 600, (27 * Count * 2) + 25) --draw box
			if k == SelectSetting then
				love.graphics.print(SelectValue.."_", 603, (27 * Count * 2) + 27, 0) --draw text in box
			else
				love.graphics.print(v, 603, (27 * Count * 2) + 27, 0) --draw text in box
			end
			Count = Count + 1 --add one to Count
		end
		love.graphics.line(600, (27 * Count * 2) + 25, 600, (27 * (Count) * 2) + 50, 780, (27 * (Count) * 2) + 50, 780, (27 * Count * 2) + 25, 600, (27 * Count * 2) + 25) --draw the reset buttons box
		love.graphics.print("Reset", 603, (27 * Count * 2) + 27, 0) --draw the reset text
	end
end

function love.keypressed(K) --function for when player presses a button
	if Status == "Game" then --if Status is "Menu"
		if Controls[K] == "Rot_Left" then --when Rot_Left button is pressed
			RotateMain(true, SwapState) --rotate ActiveMinos left
		end
		if Controls[K] == "Rot_Right" then --when Rot_Right is pressed
			RotateMain(false, SwapState) --rotate ActiveMinos right
		end
		if Controls[K] == "Soft_Drop" then --when Soft_Drop is pressed
			Soft_Drop.Activated = true --activate Soft_Drop
		end
		if Controls[K] == "Move_Left" then --same as above
			Move_Left.Activated = true
		end
		if Controls[K] == "Move_Right" then --same as above
			Move_Right.Activated = true
		end
		if Controls[K] == "Hard_Drop" then --when Hard_Drop is pressed
			if not PuyoWaiting then
				local State, Pos = false, false
				repeat
					State, Pos = MainPieceDown(SwapState)
				until State --keep moving ActiveMinos down, until it locks
				if CurrentMode ~= "Puyo" then
					ClearLines(SwapState)
				else
					PuyoWaiting = "remove"
					PuyoWaitState = Pos
				end
			end
		end
		if Controls[K] == "Hold" and not HoldLock then
			HoldSwitch(SwapState)
		end
		if Controls[K] == "Swap" and CurrentMode == "Swap" then
			SwapScreens()
		end
	elseif ReplaceControl then --if a Control is selected
		local Key = FindKey(Controls, ReplaceControl) --quick placeholder
		if Controls[K] then
			Controls[K], Controls[Key] = Controls[Key], Controls[K]
		else
			Controls[K] = ReplaceControl --set up the new Control
			Controls[Key] = nil --clear the old one
		end
		ReplaceControl = nil --clear ReplaceControl
	elseif SelectSetting then
		if tonumber(K) then
			SelectValue = SelectValue..K
		elseif K == "backspace" and SelectValue ~= "" then
			SelectValue = SelectValue:gsub(".$","")
		end
	end
end

function love.keyreleased(K) --function for when player releases a button
	if Controls[K] == "Move_Left" then --when Move_Left is released
		Move_Left.Activated = false --de-activate Move_Left
		Move_Left.Timer = 0 ---set the Move_Left Timer to 0
	end
	if Controls[K] == "Move_Right" then --same as above
		Move_Right.Activated = false
		Move_Right.Timer = 0
	end
	if Controls[K] == "Soft_Drop" then --same as above
		Soft_Drop.Activated = false
		Soft_Drop.Timer = 0
	end
	if K == "return" then --reset Prohibit once enter is released
		Prohibit = false
	end
end

function love.mousepressed(x, y, button, istouch, presses) --function for when player presses the mouse
	if Status == "Menu" or Status == "Pause" then --if Status is Menu or Pause
		if (x > 600 and x < 780) and (y > 680 and y < 710) then --if mouse  was clicked within the bounding box of the Controls Button
			if button == 1 then --if it was a left click
				OldStatus = Status --remember what the Status was before
				Status = "Controls" --set current Status to "Controls"
			end
		end
	end
	
	if Status == "Controls" then --if the Status is "Controls"
		local Count = 1 --set up Count variable
		for k,v in pairsV(Controls) do --loop through all Controls in order
			if (x > 600 and x < 780) and (y > (27 * Count * 2) + 25 and y < (27 * (Count) * 2) + 50) then --check if it is within that controls boundingbox
				if button == 1 and not ReplaceControl then --if it was a left click and another Control is not already selected
					ReplaceControl = v --select the control
				end
			end
			Count = Count + 1 --add one to counter
		end
		if (x > 600 and x < 780) and (y > (27 * Count * 2) + 25 and y < (27 * (Count) * 2) + 50) then
			if love.filesystem.remove("Controls.txt") then
				love.event.quit("restart")
			end
		end
	end
	
	if ReplaceControl and button == 2 then --if a control is selected, and the player makes a right click
		ReplaceControl = nil --de-select control
	end
	
	if Status == "Settings" then
		local Count = 1 --set up Count variable
		for _,k in pairs(sortedKeys(Settings)) do --loop through all Settings in order
			local v = Settings[k] --set up v
			if (x > 600 and x < 780) and (y > (27 * Count * 2) + 25 and y < (27 * (Count) * 2) + 50) then --check if it is within that Settings boundingbox
				if button == 1 and not SelectSetting then --if it was a left click and another Setting is not already selected
					if k == "SRS" then --if the setting is "SRS"
						if v == "true" then --flip the status of it
							Settings[k] = "false"
						else
							Settings[k] = "true"
						end
					elseif k == "Pentominos" then --if the settings is "Pentominos"
						if v == "false" then --set it to the next setting
							Settings[k] = "Sometimes"
						elseif v == "Sometimes" then
							Settings[k] = "true"
						else
							Settings[k] = "false"
						end
					else
						SelectSetting = k -- else select the setting
						SelectValue = tostring(v)
					end
				end
			end
			Count = Count + 1 --add one to counter
		end
		if (x > 600 and x < 780) and (y > (27 * Count * 2) + 25 and y < (27 * (Count) * 2) + 50) then
			if love.filesystem.remove("Settings.txt") then
				love.event.quit("restart")
			end
		end
	end
	
	if Status == "Menu" then
		if (x > MainTextX + 20 and x < MainTextX + 40) and (y > 220 and y < 245) then
			if button == 1 then
				ChosenLevel = ChosenLevel + 1
			end
		end
		if (x > MainTextX + 20 and x < MainTextX + 40) and (y > 275 and y < 300) then
			if button == 1 and ChosenLevel > 1 then
				ChosenLevel = ChosenLevel - 1
			end
		end
		
		if (x > 600 and x < 780) and (y > 640 and y < 670) then --if mouse  was clicked within the bounding box of the Settings Button
			if button == 1 then --if it was a left click
				Status = "Settings" --set current Status to "Settings"
			end
		end
		
		if (x > 550 and x < 660) then
			if (y > 130 and y < 155) then
				if button == 1 then
					CurrentMode = "Standard"
				end
			end
			if (y > 170 and y < 195) then
				if button == 1 then
					CurrentMode = "Swap"
				end
			end
			if (y > 210 and y < 235) then
				if button == 1 then
					CurrentMode = "Hidden"
				end
			end
			if (y > 250 and y < 275) then
				if button == 1 then
					CurrentMode = "Puyo"
				end
			end
		end
	end
end

function love.focus(F)
	if (not F) and Status == "Game" then
		Status = "Pause"
	end
end