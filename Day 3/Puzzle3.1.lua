function parseCurrentLine(inputLine)
    local tableIndex = 1
    local tableIndexOfSymbols = {}
    local startIndex = inputLine:find("[^%w.]")
    local sumOfValidDigits = 0
    -- add valid digits on this new line
    while (startIndex ~= nil) do
        --we found the index of the symbol track it. so we can compare to the line above. 
        tableIndexOfSymbols[tableIndex] = startIndex
        local numberBeforeSymbol = getNumberBeforeSymbol(startIndex, inputLine)
        if (numberBeforeSymbol ~= nil) then sumOfValidDigits = sumOfValidDigits + numberBeforeSymbol end
        local numberAfterSymbol = getNumberAfterSymbol(startIndex, inputLine)
        if (numberAfterSymbol ~= nil) then sumOfValidDigits = sumOfValidDigits + numberAfterSymbol end
         --now check if this symbol is touching a number from the previous line that isn't already touching a number.
         sumOfValidDigits = sumOfValidDigits + parseCurrentSymbolToPreviousLine(startIndex)
         --update startIndex to next symbol
        startIndex = inputLine:find("[^%w.]", startIndex +1)
        tableIndex = tableIndex + 1
    end

    --now check the previous line's symbol indeces and see if a number on this line that we didn't already add is touching one.
    sumOfValidDigits = sumOfValidDigits + parseCurrentLineToPreviousLineSymbols(inputLine)
    --now update previous line stuff
    PREVIOUS_LINE = inputLine
    PREVIOUS_LINE_SYMBOL_TABLE = tableIndexOfSymbols
    return sumOfValidDigits
end

function parseCurrentSymbolToPreviousLine(indexOfSymbol)
    local digitsToAdd = 0
    if (PREVIOUS_LINE ~= nil) then
        local startIndex, endIndex = PREVIOUS_LINE:find("%.?%d+%.?")
        while (startIndex ~= nil) do
            --check if the index of our symbol is touching the number if so we need to add it.
            if (startIndex <= indexOfSymbol and indexOfSymbol <= endIndex) then
                local subStart = startIndex
                local subEnd = endIndex
                if (PREVIOUS_LINE:sub(subStart,subStart) == ".") then subStart = subStart +1 end
                if (PREVIOUS_LINE:sub(subEnd, subEnd) == ".") then subEnd = subEnd -1 end
                digitsToAdd = digitsToAdd + PREVIOUS_LINE:sub(subStart, subEnd)
            end
            --if (indexOfSymbol < startIndex) then break
            --else
            local subEnd = endIndex
            if (PREVIOUS_LINE:sub(subEnd, subEnd) ~= ".") then subEnd = subEnd + 1 end
            startIndex, endIndex = PREVIOUS_LINE:find("%.?%d+%.?", subEnd)
            --end
        end
    end
    return digitsToAdd
end

function parseCurrentLineToPreviousLineSymbols(inputLine)
    local digitsToAdd = 0
    if (#PREVIOUS_LINE_SYMBOL_TABLE > 0) then
        local startIndex, endIndex = inputLine:find("%.?%d+%.?")
        while (startIndex ~= nil) do
            for tableIndex, previousSymbolIndex in ipairs(PREVIOUS_LINE_SYMBOL_TABLE) do
                if (startIndex <= previousSymbolIndex and previousSymbolIndex <= endIndex) then
                    --there is potential that the number is at the start of the line or end of the line. and may not hava '.' in front or after so adjust accordingly\
                    local subStart = startIndex
                    local subEnd = endIndex
                    if (inputLine:sub(subStart,subStart) == ".") then subStart = subStart +1 end
                    if (inputLine:sub(subEnd, subEnd) == ".") then subEnd = subEnd -1 end
                    digitsToAdd = digitsToAdd + inputLine:sub(subStart, subEnd)
                end
                -- if this next index is past the endIndex of this set of digits then don't check the other symbols just break out and continue while loop
                --if (previousSymbolIndex > endIndex) then break end
            end
            local subEnd = endIndex
            if (inputLine:sub(subEnd, subEnd) ~= ".") then subEnd = subEnd + 1 end
            startIndex, endIndex = inputLine:find("%.?%d+%.?", subEnd)
        end
    end
    return digitsToAdd
end

function getNumberBeforeSymbol(indexOfSymbol, inputLine)
    local index = indexOfSymbol - 1
    local characterBeforeSymbol = inputLine:sub(index, index)
    local digitBefore = nil
    while characterBeforeSymbol:match("%d") do
        if(digitBefore == nil) then
            digitBefore = characterBeforeSymbol
        else
            digitBefore = characterBeforeSymbol..digitBefore
        end
        index = index - 1
        characterBeforeSymbol = inputLine:sub(index, index)
    end
    return digitBefore
end

function getNumberAfterSymbol(indexOfSymbol, inputLine)
    local index = indexOfSymbol + 1
    local characterAfterSymbol = inputLine:sub(index, index)
    local digitAfter = nil
    while characterAfterSymbol:match("%d") do
        if(digitAfter == nil) then
            digitAfter = characterAfterSymbol
        else
            digitAfter = digitAfter..characterAfterSymbol
        end
        index = index + 1
        characterAfterSymbol = inputLine:sub(index, index)
    end
    return digitAfter
end

function gears(inputLine)
    local tableIndex = 1
    local tableIndexOfSymbols = {}
    local startIndex = inputLine:find("[*]")
    local sumOfValidGears = 0
    -- add valid digits on this new line
    while (startIndex ~= nil) do
        tableIndexOfSymbols[tableIndex] = startIndex
        local numberBeforeSymbol = getNumberBeforeSymbol(startIndex, inputLine)
        local numberAfterSymbol = getNumberAfterSymbol(startIndex, inputLine)
        if (PREVIOUS_LINE ~= nil and (numberBeforeSymbol ~= nil and numberAfterSymbol ~= nil)) then sumOfValidGears = sumOfValidGears + (tonumber(numberBeforeSymbol)*tonumber(numberAfterSymbol)) end

         --now if we had a number before or after then we need to compare to the line before to see if we have a gear
         if (PREVIOUS_LINE ~= nil and (numberBeforeSymbol ~= nil or numberAfterSymbol ~= nil)) then
            local gearToTest = nil
            if (numberBeforeSymbol ~= nil ) then gearToTest = numberBeforeSymbol
            else gearToTest = numberAfterSymbol end
            sumOfValidGears = sumOfValidGears + parseGearFromPreviousLine(startIndex, gearToTest)
         end
        startIndex = inputLine:find("[*]", startIndex +1)
        tableIndex = tableIndex + 1
    end

    -- now check all the numbers on this line and if there are at least two line before it check if there is an '*' sandwiched between numbers
    if (PREVIOUS_LINE ~= nil and PREVIOUS_LINE_MINUS_ONE ~= nil) then
        --we have 3 lines check for the sandwich
        sumOfValidGears = sumOfValidGears + sandwichParse(inputLine)
    end
    PREVIOUS_LINE_MINUS_ONE = PREVIOUS_LINE
    PREVIOUS_LINE = inputLine
    PREVIOUS_LINE_SYMBOL_TABLE = tableIndexOfSymbols
    return sumOfValidGears
end

function parseGearFromPreviousLine(indexPfAsterisk, nearbyGear)
    local gearDigits = 0
    local startIndex, endIndex = PREVIOUS_LINE:find("%d+")
    while (startIndex ~= nil) do
        if (startIndex-1 <= indexPfAsterisk and indexPfAsterisk <= endIndex+1) then
            local gear = PREVIOUS_LINE:sub(startIndex,endIndex)
            gearDigits = gearDigits + (tonumber(gear)*tonumber(nearbyGear))
        end
        startIndex, endIndex = PREVIOUS_LINE:find("%d+", endIndex+1)
    end
    return gearDigits;
end

function sandwichParse(inputLine)
    local sandwichGearsSum = 0
    local startIndex, endIndex = inputLine:find("%d+")
    --loop through current finding all the digits
    while (startIndex ~= nil) do
        --compare to each * index of the previous line
        for i, index in ipairs(PREVIOUS_LINE_SYMBOL_TABLE) do
            if (startIndex-1 <= index and index <= endIndex+1) then
                --if it align now check top line digits
                local previousMinusOneStart, previousMinusOneEnd = PREVIOUS_LINE_MINUS_ONE:find("%d+")
                while (previousMinusOneStart ~= nil) do
                    if (previousMinusOneStart <= index and index <= previousMinusOneEnd+1) then
                        --sandwich found now generate the gear
                        local topNumber = PREVIOUS_LINE_MINUS_ONE:sub(previousMinusOneStart, previousMinusOneEnd)
                        local bottomNumber = inputLine:sub(startIndex, endIndex)
                        sandwichGearsSum = sandwichGearsSum + (tonumber(topNumber)*tonumber(bottomNumber))
                    end
                    previousMinusOneStart, previousMinusOneEnd = PREVIOUS_LINE_MINUS_ONE:find("%d+", previousMinusOneEnd+1)
                end
            end
        end
        startIndex, endIndex = inputLine:find("%d+", endIndex + 1)
    end
    return sandwichGearsSum
end


PREVIOUS_LINE = nil
PREVIOUS_LINE_SYMBOL_TABLE = {}
PREVIOUS_LINE_MINUS_ONE = nil

local filePath = io.popen("cd"):read().."\\Day 3\\testData\\puzzleTestData3.1.txt"
local file = io.open(filePath)
local sumOfDigits = 0
if (file ~= nil) then
    for line in io.lines(filePath) do
        local parseValue = parseCurrentLine(line)
        if (parseValue ~= nil) then
            sumOfDigits = sumOfDigits + parseValue
        end
    end
    print(sumOfDigits)
end

PREVIOUS_LINE = nil
PREVIOUS_LINE_MINUS_ONE = nil
PREVIOUS_LINE_SYMBOL_TABLE = {}

if (file ~= nil) then
    for line in io.lines(filePath) do
        sumOfDigits = sumOfDigits + gears(line)
    end
    print(sumOfDigits)
end