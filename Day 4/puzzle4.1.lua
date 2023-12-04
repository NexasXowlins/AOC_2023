function getPointOfCard(inputLine)
    local points = 0
    local startIndex = inputLine:find(" | ")
    local firstPartOfCard = inputLine:sub(1, startIndex-1)

    firstPartOfCard = firstPartOfCard:gsub("Card%s+%d+:", "")
    local secondPartOfCard = inputLine:sub(startIndex+3, #inputLine)
    for winningNumber in firstPartOfCard:gmatch("[^%s]+") do
        for playedNumber in secondPartOfCard:gmatch("[^%s]+") do
            if (winningNumber == playedNumber) then
                points = points+1
                --break
            end
        end
    end
    if (points > 0) then points = 2^(points-1) end
    return points
end

function getNumberOfCardCopies(inputLine)
    local numWins = 0
    local startIndex = inputLine:find(" | ")
    local firstPartOfCard = inputLine:sub(1, startIndex-1)
    local cardGameNumberIndex, cardGameNumberEndIndex = firstPartOfCard:find(":")
    local cardGameNumber = firstPartOfCard:sub(0, cardGameNumberIndex-1)
    cardGameNumber = cardGameNumber:gsub("Card%s*","")
    cardGameNumber = tonumber(cardGameNumber)

    if (#CARD_COPIES_TABLE < cardGameNumber and cardGameNumber ~= nil) then
        CARD_COPIES_TABLE[cardGameNumber] = 1
    elseif (cardGameNumber ~= nil) then
        CARD_COPIES_TABLE[cardGameNumber] = CARD_COPIES_TABLE[cardGameNumber] + 1
    end
    firstPartOfCard = firstPartOfCard:gsub("Card%s+%d+:", "")
    local secondPartOfCard = inputLine:sub(startIndex+3, #inputLine)
    local numCopies = CARD_COPIES_TABLE[cardGameNumber]
    for winningNumber in firstPartOfCard:gmatch("[^%s]+") do
        for playedNumber in secondPartOfCard:gmatch("[^%s]+") do
            if (winningNumber == playedNumber) then
                numWins = numWins +1
            end
        end
    end
    for x=cardGameNumber+1, cardGameNumber+numWins, 1 do
        if (CARD_COPIES_TABLE[x] ~= nil) then
            CARD_COPIES_TABLE[x] = CARD_COPIES_TABLE[x] + numCopies
        else
            CARD_COPIES_TABLE[x] = numCopies
        end
    end
    --if (points > 0) then points = 2^(points-1) end
end


local filePath = io.popen("cd"):read().."\\Day 4\\testData\\puzzleTestData4.1.txt"
local file = io.open(filePath)
local sumOfPoints = 0
local numLines = 0
local copies = 0
CARD_COPIES_TABLE = {}
if (file ~= nil) then
    for line in io.lines(filePath) do
        sumOfPoints = sumOfPoints + getPointOfCard(line)
        getNumberOfCardCopies(line)
        numLines = numLines + 1
    end
    print("Solution 1: "..sumOfPoints)
    for i=1, numLines, 1 do
        copies = copies + CARD_COPIES_TABLE[i]
    end
    print("Solution 2: "..copies)
end