function parseLine(inputLine)
    if (inputLine:find(":") ~= nil) then
        DATA_BEING_READ = inputLine
    else
        local destinationStart = nil
        local sourceStart = nil
        local range = nil
        local index = 1
        --grab our values for each line
        for number in inputLine:gmatch("[^%s]+") do
            if (index==1) then destinationStart = tonumber(number)
            elseif (index==2) then sourceStart = tonumber(number)
            elseif (index==3) then range = tonumber(number) end
            index = index +1
        end
        -- go ahead and update all our seeds based on this line input. essentially building the mapping as we read each line and updating the value for each entity
        for i,seed in pairs(SEED_TABLE) do
            if (DATA_BEING_READ == "seed-to-soil map:" and (seed.soil == 0 or seed.soil == i)) then
                seed.soil = getMappedValue(i,destinationStart, sourceStart, range)
                seed.fertilizer = seed.soil
                seed.water = seed.fertilizer
                seed.light = seed.water
                seed.temperature = seed.light
                seed.humidity = seed.temperature
                seed.location = seed.location
            elseif (DATA_BEING_READ == "soil-to-fertilizer map:" and (seed.fertilizer == 0 or seed.fertilizer == seed.soil)) then
                seed.fertilizer = getMappedValue(seed.soil,destinationStart, sourceStart, range)
                seed.water = seed.fertilizer
                seed.light = seed.water
                seed.temperature = seed.light
                seed.humidity = seed.temperature
                seed.location = seed.location
            elseif (DATA_BEING_READ == "fertilizer-to-water map:" and (seed.water == 0 or seed.water == seed.fertilizer)) then
                seed.water = getMappedValue(seed.fertilizer,destinationStart, sourceStart, range)
                seed.light = seed.water
                seed.temperature = seed.light
                seed.humidity = seed.temperature
                seed.location = seed.location
            elseif (DATA_BEING_READ == "water-to-light map:" and (seed.light == 0 or seed.light == seed.water)) then
                seed.light = getMappedValue(seed.water,destinationStart, sourceStart, range)
                seed.temperature = seed.light
                seed.humidity = seed.temperature
                seed.location = seed.location
            elseif (DATA_BEING_READ == "light-to-temperature map:" and (seed.temperature == 0 or seed.temperature == seed.light)) then
                seed.temperature = getMappedValue(seed.light,destinationStart, sourceStart, range)
                seed.humidity = seed.temperature
                seed.location = seed.location
            elseif (DATA_BEING_READ == "temperature-to-humidity map:" and (seed.humidity == 0 or seed.humidity == seed.temperature)) then
                seed.humidity = getMappedValue(seed.temperature,destinationStart, sourceStart, range)
                seed.location = seed.location
            elseif (DATA_BEING_READ == "humidity-to-location map:" and (seed.location == 0 or seed.location == seed.humidity)) then
                seed.location = getMappedValue(seed.humidity,destinationStart, sourceStart, range)
            end
        end
    end
end

function getMappedValue(sourceValue, destinationStart, sourceStart, range)
    local destinationValue = sourceValue
    if (sourceStart <= sourceValue and sourceValue < (sourceStart+range)) then
        destinationValue = destinationStart + (sourceValue- sourceStart)
    end
    return destinationValue
end

function parseSeed(seedLine)
    local seedList = seedLine:gsub("seeds:%s*", "")
    for seedNumber in seedList:gmatch("[^%s]+") do
        local num = tonumber(seedNumber)
        SEED_TABLE[num] =  {seedNumber =num, soil = 0, fertilizer = 0, water =0, light =0, temperature =0, humidity =0, location =0}
    end
end

function parseLineSolution2(inputLine)
    if (inputLine:find(":") ~= nil) then
        DATA_BEING_READ = inputLine
    else
        local destinationStart = nil
        local sourceStart = nil
        local range = nil
        local index = 1
        for number in inputLine:gmatch("[^%s]+") do
            if (index==1) then destinationStart = tonumber(number)
            elseif (index==2) then sourceStart = tonumber(number)
            elseif (index==3) then range = tonumber(number) end
            index = index +1
        end
        if (DATA_BEING_READ == "seed-to-soil map:" ) then
            table.insert(SEED_TO_SOIL_RANGES, {from = sourceStart, to = sourceStart + range, adjustment = destinationStart-sourceStart, tableMapPtr = SOIL_TO_FERTILIZER_RANGES })
        elseif (DATA_BEING_READ == "soil-to-fertilizer map:") then
            table.insert(SOIL_TO_FERTILIZER_RANGES, {from = sourceStart, to = sourceStart + range, adjustment = destinationStart-sourceStart, tableMapPtr = FERTILIZER_TO_WATER_RANGES })
        elseif (DATA_BEING_READ == "fertilizer-to-water map:") then
            table.insert(FERTILIZER_TO_WATER_RANGES, {from = sourceStart, to = sourceStart + range, adjustment = destinationStart-sourceStart, tableMapPtr = WATER_TO_LIGHT_RANGES })
        elseif (DATA_BEING_READ == "water-to-light map:") then
            table.insert(WATER_TO_LIGHT_RANGES, {from = sourceStart, to = sourceStart + range, adjustment = destinationStart-sourceStart, tableMapPtr = LIGHT_TO_TEMPERATURE_RANGES })
        elseif (DATA_BEING_READ == "light-to-temperature map:") then
            table.insert(LIGHT_TO_TEMPERATURE_RANGES, {from = sourceStart, to = sourceStart + range, adjustment = destinationStart-sourceStart, tableMapPtr = TEMPERATURE_TO_HUMIDTY_RANGES })
        elseif (DATA_BEING_READ == "temperature-to-humidity map:") then
            table.insert(TEMPERATURE_TO_HUMIDTY_RANGES, {from = sourceStart, to = sourceStart + range, adjustment = destinationStart-sourceStart, tableMapPtr = HUMIDITY_TO_LOCATION_RANGES })
        elseif (DATA_BEING_READ == "humidity-to-location map:") then
            table.insert(HUMIDITY_TO_LOCATION_RANGES, {from = sourceStart, to = sourceStart + range, adjustment = destinationStart-sourceStart, tableMapPtr = nil })
        end
    end
end
--[[Parses the seed line into it's ranges and creates a range entry in the seed table]]
function parseRangeSeedLine(inputLine)
    local seedList = inputLine:gsub("seeds:%s*", "")
    local seedStart = nil
    local index = 1
    for seedNumber in seedList:gmatch("[^%s]+") do
    
        if (index % 2 == 0) then
            table.insert(SEED_TABLE, {sourceStart = seedStart, range = tonumber(seedNumber)})
        else
            seedStart = tonumber(seedNumber)
        end
        index = index + 1
    end
end

function getLowestLocaton()
    local location = nil
    for _,seed in pairs(SEED_TABLE) do
        if (location == nil) then location = seed.location
        elseif (seed.location < location) then location = seed.location end
    end
    return location
end
--[[Now that we have the tables filled out. Go ahead and order them in the list by their from value.
    this allows us to short cut updating the ranges as we need to. Because as soon as we find a range we are in
    we can stop our current loop
]]
function orderMapsAndCondense()
    table.sort(SEED_TO_SOIL_RANGES, function(entry1, entry2) return entry1.from < entry2.from end )
    table.sort(SOIL_TO_FERTILIZER_RANGES, function(entry1, entry2) return entry1.from < entry2.from end )
    table.sort(FERTILIZER_TO_WATER_RANGES, function(entry1, entry2) return entry1.from < entry2.from end )
    table.sort(WATER_TO_LIGHT_RANGES, function(entry1, entry2) return entry1.from < entry2.from end )
    table.sort(LIGHT_TO_TEMPERATURE_RANGES, function(entry1, entry2) return entry1.from < entry2.from end )
    table.sort(TEMPERATURE_TO_HUMIDTY_RANGES, function(entry1, entry2) return entry1.from < entry2.from end )
    table.sort(HUMIDITY_TO_LOCATION_RANGES, function(entry1, entry2) return entry1.from < entry2.from end )
    --create a table of tables
    MAPS = {SEED_TO_SOIL_RANGES, SOIL_TO_FERTILIZER_RANGES, FERTILIZER_TO_WATER_RANGES, WATER_TO_LIGHT_RANGES, LIGHT_TO_TEMPERATURE_RANGES,TEMPERATURE_TO_HUMIDTY_RANGES,HUMIDITY_TO_LOCATION_RANGES}
end

function runit()
    local ranges = {}
    for i,seed in pairs(SEED_TABLE) do
        --generate the initial ranges to check
        ranges[i] = {from = seed.sourceStart, to = seed.sourceStart + seed.range}
    end

    for _,map in pairs(MAPS) do
        --see if we can make any new ranges from each map
        local newRanges = {}
        for _,range in pairs(ranges) do
            --start with our current ranges
            for _,mapping in pairs(map) do
                --check each range that existed in this map
                if (range.from < mapping.from) then
                    --if the starting range from is less than the first ranges from then we can check if we can expand the current range
                    --this either makes a range that includes our overlapping, or just returns the same range we have.  
                    table.insert(newRanges, {from = range.from, to = math.min(range.to, mapping.from)})
                    range.from = mapping.from
                    --this basically checking if our range has now reached its end to be checked. If it has then we can stop
                    --otherwise we need to check the other ranges in this map
                    if (range.from > range.to) then
                        break
                    end
                end
                --this does the same as above but checks for the overlap to the left of the range
                if (range.from <= mapping.to) then
                    table.insert(newRanges, {from =  range.from + mapping.adjustment, to = math.min(range.to, mapping.to) + mapping.adjustment})
                    range.from = mapping.to
                    if (range.from > range.to) then
                        break
                    end
                end
            end
            --if we have a valid new range add it to our new list
            if (range.from <= range.to) then
                table.insert(newRanges,range)
            end
        end
        --reset the ranges for the next loop
        ranges = newRanges
    end
    local min = math.huge
    --now that we have an ordered list. down to the location ranges only. We can find the smallest from value
    for i,v in pairs(ranges) do
        min = math.min(min, v.from)
    end
    return min
end


SEED_TABLE = {}
DATA_BEING_READ = nil
local filePath = io.popen("cd"):read().."\\Day 5\\testData\\puzzleTestData5.1.txt"
local file = io.open(filePath)
if (file ~= nil) then
    for line in io.lines(filePath) do
        if (line:sub(1,6) == "seeds:") then
            parseSeed(line)
        elseif (#line >1) then
            parseLine(line)
        end
    end
end

print("Solution 1 Lowest Seed Location: "..getLowestLocaton())

--[[Solution 2 requires some finessing and doing range subtraction so build the ranges for each mapping]]
HUMIDITY_TO_LOCATION_RANGES = {}
TEMPERATURE_TO_HUMIDTY_RANGES = {}
LIGHT_TO_TEMPERATURE_RANGES = {}
WATER_TO_LIGHT_RANGES = {}
FERTILIZER_TO_WATER_RANGES = {}
SOIL_TO_FERTILIZER_RANGES = {}
SEED_TO_SOIL_RANGES = {}

MAPS = {}

SEED_TABLE={}
DATA_BEING_READ =nil
if (file ~= nil) then
    for line in io.lines(filePath) do
        if (line:sub(1,6) == "seeds:") then
            parseRangeSeedLine(line)
        elseif (#line >1) then
            parseLineSolution2(line)
        end
    end
end
orderMapsAndCondense()


--print("Solution 2 Lowest Seed Location: "..findLowestLocation())
print("Solution 2 Lowest Seed Location: "..runit())

