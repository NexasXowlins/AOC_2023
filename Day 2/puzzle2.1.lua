function getGameId(inputLine)
    --find the start and end index of game id portion the line
    local gameTagStart, gameTagEnd = inputLine:find("GAME%s+%d+:")
    local gameTag = inputLine:sub(gameTagStart,gameTagEnd)
    gameTag = gameTag:gsub("GAME%s+","")
    --take off the colon
    return gameTag:sub(1, #gameTag-1)
end

function isHintValid(setOfMarbles)
    local greenCount = getCountOfColor(setOfMarbles,"GREEN")
    local blueCount = getCountOfColor(setOfMarbles,"BLUE")
    local redCount = getCountOfColor(setOfMarbles, "RED")
    return redCount <= 12 and greenCount <= 13 and blueCount <= 14
end

function getPowerOfGame(inputLine)
    local maxGreenCount = 0
    local maxBlueCount = 0
    local maxRedCount = 0
    local gameDataSetIterator = getGameSetIterator(inputLine)
    local marbleSet = gameDataSetIterator()
    while (marbleSet ~= nil) do
        local tempCount = getCountOfColor(marbleSet, "GREEN")
        if (tempCount > maxGreenCount ) then maxGreenCount = tempCount end
        tempCount = getCountOfColor(marbleSet, "RED")
        if (tempCount > maxRedCount ) then maxRedCount = tempCount end
        tempCount = getCountOfColor(marbleSet, "BLUE")
        if (tempCount > maxBlueCount ) then maxBlueCount = tempCount end
        marbleSet = gameDataSetIterator()
    end
    return maxGreenCount*maxBlueCount*maxRedCount
end

function getCountOfColor(setOfMarbles, colorToSearchFor)
     --[[ 
        just incase they get tricky and put a color twice in the same game set
        I'm going to do a quick loop and sum for each color.
    ]]
    local colorCount = 0
    
    local marbleHintSetIterator = getMarbleSetIterator(setOfMarbles, colorToSearchFor)
    local marbleEntry = marbleHintSetIterator()
    while (marbleEntry ~= nil) do
        colorCount = colorCount + marbleEntry:gsub("[^%d]+","")
        marbleEntry = marbleHintSetIterator()
    end
    return colorCount
end


function isGameValid(inputLine)
    local gameDataSetIterator = getGameSetIterator(inputLine)
    local marbleSet = gameDataSetIterator()
    local validGame = true
    while (validGame and marbleSet ~= nil) do
        validGame = isHintValid(marbleSet)
        marbleSet = gameDataSetIterator()
    end
    return validGame
end

function getGameSetIterator(inputLine)
    return inputLine:gmatch("[^;]+")
end

function getMarbleSetIterator(marbleInput, colorToSearchFor)
    local buildRegex = "[%d+%s+]+"..colorToSearchFor
    return marbleInput:gmatch(buildRegex)
end

local validGames = 0
local powersOfGames = 0
local filePath = io.popen("cd"):read().."\\Day 2\\testData\\puzzleTestData2.1.txt"
local file = io.open(filePath)
if (file ~= nil) then
    for line in io.lines(filePath) do
        line = line:upper()
        local gameId = getGameId(line)
        line =  line:gsub("GAME%s+"..gameId..": ","")
        if (isGameValid(line)) then validGames = validGames + gameId end
        powersOfGames = powersOfGames + getPowerOfGame(line)
    end
end

print("Sum of valid games: "..validGames)
print("Sum of powers of games: "..powersOfGames)

