function getPointOfCard(inputLine)
    local points = 0
    local startIndex = inputLine:find(" | ")
    local firstPartOfCard = inputLine:sub(1, startIndex-1)

    --extracts the winning numbers
    firstPartOfCard = firstPartOfCard:gsub("Card%s+%d+:", "")
    --extracts your matching numbers
    local secondPartOfCard = inputLine:sub(startIndex+3, #inputLine)
    for winningNumber in firstPartOfCard:gmatch("[^%s]+") do
        -- see if there is a match of a winning number in the play numbers
        for playedNumber in secondPartOfCard:gmatch("[^%s]+") do
            if (winningNumber == playedNumber) then
                --each matching number gain a point
                points = points+1
            end
        end
    end
    -- the equation of points is essentially after the first 1 your cards start gaining points as a power of 2
    if (points > 0) then points = 2^(points-1) end
    return points
end

function getNumberOfCardCopies(inputLine)
    local numWins = 0
    local startIndex = inputLine:find(" | ")
    --begin by finding our seperator
    local firstPartOfCard = inputLine:sub(1, startIndex-1)
    --now instead of disregarding the card index, extract it so we can make a table
    local cardGameNumberIndex, cardGameNumberEndIndex = firstPartOfCard:find(":")
    local cardGameNumber = firstPartOfCard:sub(0, cardGameNumberIndex-1)
    cardGameNumber = cardGameNumber:gsub("Card%s*","")
    cardGameNumber = tonumber(cardGameNumber)

    --we made a table to store each copy of the card we need to make.
    --[[
        if the length of the our table, an array, is less than our cardgame number then our match spawned a copy of a card we havent read yet.
    ]]
    if (#CARD_COPIES_TABLE < cardGameNumber and cardGameNumber ~= nil) then
        --just initialize to 1   
        CARD_COPIES_TABLE[cardGameNumber] = 1
    elseif (cardGameNumber ~= nil) then
        --otherwise we just need to add a copy of the card. 
        CARD_COPIES_TABLE[cardGameNumber] = CARD_COPIES_TABLE[cardGameNumber] + 1
    end
    firstPartOfCard = firstPartOfCard:gsub("Card%s+%d+:", "")
    local secondPartOfCard = inputLine:sub(startIndex+3, #inputLine)
    local numCopies = CARD_COPIES_TABLE[cardGameNumber]
    -- now loop for each copy of the card we have. Adding more copies of the future cards as we generate them
    for winningNumber in firstPartOfCard:gmatch("[^%s]+") do
        for playedNumber in secondPartOfCard:gmatch("[^%s]+") do
            if (winningNumber == playedNumber) then
                numWins = numWins +1
            end
        end
    end
    --this will see how many wins on the card we had. then add a copy of each sequential card for the win. 
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