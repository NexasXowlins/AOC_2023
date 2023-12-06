function parseInput(inputLine)
    if (inputLine:find("Time:") ~= nil) then
        parseToTable(inputLine, TIME_TABLE)
    elseif (inputLine:find("Distance:") ~= nil) then
        parseToTable(inputLine, DISTANCE_TABLE)
    end
 end


 function parseToTable(inputLine, tableList)
    local i = 0
    for entry in inputLine:gmatch("[^%s]+") do
        if (i > 0) then
            tableList[i] = tonumber(entry)
        end
        i = i+1
    end
 end

 function calculateMarginOfError()
    local marginOfErrorTotal = nil
    for i, time in ipairs(TIME_TABLE) do
        local numWaysToWin = 0
        for x=1, time-1 do
            local wayToWin = x*(time-x)
            if (wayToWin > DISTANCE_TABLE[i]) then numWaysToWin =  numWaysToWin + 1 end
        end
        if (marginOfErrorTotal == nil) then marginOfErrorTotal = numWaysToWin else marginOfErrorTotal = marginOfErrorTotal*numWaysToWin end
    end
    return marginOfErrorTotal
 end

 --[[
    part two made the range to check massive. Need a new calcluation. saw from the way the inputs were listed
    that because of the way speed worked. that once you found your first win you could subtract that same distance
    from the end of the range. and that was your last win. Then it's just a matter of figuring out how many
    are in your new range. 
    ]]
 function calculateMarginOfError2(singleTime, singleDistance)
        local numWaysToWin = 0
        for x=1, singleTime-1 do
            local wayToWin = x*(singleTime-x)
            if (wayToWin > singleDistance) then
                --only care about finding first win now caclulate last win
                local lastWin = singleTime - x
                numWaysToWin = lastWin - x + 1
                break
            end
        end
    return numWaysToWin
 end

TIME_TABLE = {}
DISTANCE_TABLE = {}
local filePath = io.popen("cd"):read().."\\Day 6\\testData\\puzzleTestData6.1.txt"
local file = io.open(filePath)
if (file ~= nil) then
    for line in io.lines(filePath) do
        parseInput(line)
    end
end
print("Solution 1: "..calculateMarginOfError())

local singleTime = nil
local singleDistance = nil
if (file ~= nil) then
    for line in io.lines(filePath) do
        if (line:find("Time:") ~= nil) then
            singleTime = line:gsub("Time:",""):gsub("%s","")
        else
            singleDistance = line:gsub("Distance:",""):gsub("%s","")
        end
    end
    print("Solution 2: "..calculateMarginOfError2(tonumber(singleTime), tonumber(singleDistance)))
end

