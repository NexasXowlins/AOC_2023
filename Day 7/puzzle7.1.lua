function parseHandInput(inputLine, lineIndex)
    --split the line into hand and bid
    local lineItr = inputLine:gmatch("[^%s]+")
    local hand = lineItr()
    local bid = lineItr()
    local handIndex = 1
    local handMatches = {}
    local convertedHand = {}
    local rank = 0
    --[[
        the idea is that convert face cards to their numerical value,and aggregate matches together.
        Then based on the link of the matches we can determine our hand type. In addition we can 
        make a converted hand of all numbers for high card tie matches. 
    ]]
    for character in hand:gmatch("%w") do
        local conversion = FACE_CARDS[character]
        if (conversion == nil) then conversion = tonumber(character) end
        if (handMatches[conversion] == nil) then handMatches[conversion] = 1
        else handMatches[conversion] = handMatches[conversion] + 1 end
        table.insert(convertedHand, handIndex, conversion)
        handIndex = handIndex + 1
    end

    if (handMatches[0] ~=nil) then
        --had jokers update the hand
        local jokerCount = handMatches[0]
        local indexOfMostMatches = 0
        local mostMatches = 0
        local highestNumber = 0
        --now find highest number and mostMatches
        for i, num in pairs(handMatches) do
            if (i > 0) then
                if (num > mostMatches) then 
                    mostMatches = num
                    indexOfMostMatches = i
                end
                if (i > highestNumber) then highestNumber = i end
            end
        end
        -- if most matches is 1 then we are currently high card, and so just add ourselves as matches of high card
        --otherwise find where we had the most matches and extend that further
        if (mostMatches == 1) then handMatches[highestNumber] = handMatches[highestNumber] + jokerCount
        else handMatches[indexOfMostMatches] = handMatches[indexOfMostMatches] + jokerCount end
        --remove jokers from the match count. But it persists in the hand layout. 
        handMatches[0] = nil
    end
    --going to rank my hands in ascending order ie high card is 7 five of a kind is 1
    local lengthofHandMatches = lengthOfTable(handMatches)
    if (lengthofHandMatches == 5) then rank = 7
    elseif (lengthofHandMatches == 4) then rank = 6
    elseif (lengthofHandMatches == 3) then
        for i, num in pairs(handMatches) do
           if (num == 3) then
                --three of a kind
                rank = 4
                break
           elseif (num == 2) then
                --two pair
                rank = 5
                break
           end
        end
    elseif (lengthofHandMatches == 2) then
        for i, num in pairs(handMatches) do
            if (num == 3) then
                --full house
                rank = 3
                break
            elseif (num == 4) then
                --four of a kind
                rank = 2
                break
            end
        end
        --there could be a hand of all jokers so default rank to 1
    elseif (lengthofHandMatches <= 1) then rank = 1 end

    HANDS[lineIndex] = {handRank = rank, hand = convertedHand, bid = bid }
end

function compareHands(hand1, hand2)
    local lowerRank = hand1.handRank > hand2.handRank
    if (not lowerRank and hand1.handRank == hand2.handRank ) then
        --check if the hand ranks were equal for high card by position
        for i=1,#hand1.hand do
            lowerRank = hand1.hand[i] < hand2.hand[i]
            if (lowerRank or (not lowerRank and hand1.hand[i] ~= hand2.hand[i] )) then
                --hand two has a higher rank by high card position. just break.
                break
            end
        end
    end
    return lowerRank
end

--[[
    tables that don't us insert function to add the values will not allow the use of # for length
    need to calculate manually
]]
function lengthOfTable(tableList)
    local count = 0
    for _ in pairs(tableList) do
        count = count + 1
    end
    return count
end


FACE_CARDS = {A = 14, K =13, Q=12,J=11,T=10}

HANDS = {}
local filePath = io.popen("cd"):read().."\\Day 7\\testData\\puzzleTestData7.1.txt"
local file = io.open(filePath)
if (file ~= nil) then
    local lineIndex =1
    for line in io.lines(filePath) do
        parseHandInput(line, lineIndex)
        lineIndex = lineIndex + 1
    end
end

table.sort(HANDS, compareHands)

local winnings = nil
for i,hand in pairs(HANDS) do
    local handWinnings = i*hand.bid
    if (winnings == nil) then winnings = handWinnings
    else winnings = winnings + handWinnings end
end
print("Total Winnings Part 1: "..winnings)

FACE_CARDS = {A = 14, K =13, Q=12,J=0,T=10}
HANDS = {}
if (file ~= nil) then
    local lineIndex =1
    for line in io.lines(filePath) do
        parseHandInput(line, lineIndex)
        lineIndex = lineIndex + 1
    end
end
table.sort(HANDS, compareHands)
winnings =0
for i,hand in pairs(HANDS) do
    local handWinnings = i*hand.bid
    if (winnings == nil) then winnings = handWinnings
    else winnings = winnings + handWinnings end
end
print("Total Winnings Part 2: "..winnings)