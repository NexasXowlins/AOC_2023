function retrieveDigitsFromInput(inputString)
    -- I wanted to do a gmatch which iterates over matches, but it never seemed to find a match to digits for some reason.
    -- Would be interesting to see speed in relation to doing a sub of removing all unneccesary letters, but it may be quicker to only loop through each string one time
    local firstDigit = nil
    local lastDigit = nil
    local potentialFirstWordDigit = ""
    local potentialLastWordDigit = ""
    -- strings in lua have a 0 index but it's nil, the first character is at index 1
    local startIndex = 1
    --# character denotes a length of an object
    local inputLength = #inputString
    while ((firstDigit == nil or lastDigit == nil) and startIndex <= inputLength) do
        --each iteration work our way from both the front of the string forwards and the back of the string backwards till we get a match
        if (firstDigit == nil) then
            local subPrefix = inputString:sub(startIndex, startIndex)
            if (subPrefix:match("%d")) then firstDigit = subPrefix end
        end
        if (lastDigit == nil) then
            local index = inputLength-(startIndex-1)
            local subSuffix = inputString:sub(index, index)
            if (subSuffix:match("%d")) then lastDigit = subSuffix end
        end
        startIndex = startIndex + 1
    end
    return firstDigit..lastDigit
end

--update for part 2
function substituteWordNumbers(line)
    local uppercasedLine = line:upper()
    local updated = uppercasedLine:gsub("ONE","O1E")
    updated = updated:gsub("TWO","T2O")
    updated = updated:gsub("THREE","TH3EE")
    updated = updated:gsub("FOUR","FO4R")
    updated = updated:gsub("FIVE","F5VE")
    updated = updated:gsub("SIX","S6X")
    updated = updated:gsub("SEVEN","SE7EN")
    updated = updated:gsub("EIGHT","EI8HT")
    updated = updated:gsub("NINE","N9NE")
    return updated
end



local filePath = "testData/puzzleTestData1.1.txt"
local file = io.open(filePath)
local summation = 0
local lineNum = 1

if (file ~= nil) then
    for line in io.lines(filePath) do
        -- lua auto converts numbers and strings when doing concats and and adds. 
        -- ie 7 + " test" will give "7 test" and 7 + " 7" will give 14
        local test = substituteWordNumbers(line)
        test = retrieveDigitsFromInput(test)
        print("LineNumber: "..lineNum..":"..test)
        summation = summation + test
        lineNum = lineNum + 1
    end
end
print(summation)
