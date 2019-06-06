WarTracker.MySQL = { }
WarTracker.MySQL.__index = WarTracker.MySQL


local tableName = 'WarTracker' -- Edit this if you want

-- Do not change anything below!
local schema = 'CREATE TABLE IF NOT EXISTS '..tableName..' (\
	ReportId INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,\
	Time INT(10) NOT NULL,\
	Category MEDIUMTEXT NOT NULL,\
	Name MEDIUMTEXT NOT NULL,\
	Value MEDIUMTEXT DEFAULT NULL\
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;'

local dumpInterval = 60000
local dumpMinEventCount = nil

local eventQueue = { }

local isLogEnabled = true

local function log(message)
	if not isLogEnabled then return end
	Citizen.Trace('['..os.date('%c')..'] [WarTracker.MySQL] '..message..'\n')
end

local function extractValue(event)
	if not event.value then return 'NULL' end
	if type(event.value) == 'table' then return json.encode(event.value) end
	return tostring(event.value)
end

local function dumpEventQueue()
	if #eventQueue == 0 then return end

	local dumpStartTime = os.clock()

	local query = 'INSERT INTO '..tableName..' (Time, Category, Name, Value) VALUES '
	local queryParams = { }
	local eventCount = #eventQueue

	for i = 1, eventCount do
		query = query..'(@time'..i..', @category'..i..', @name'..i..', @value'..i..')'
		if i ~= eventCount then query = query..', ' end

		local eventData = eventQueue[i]
		queryParams['@time'..i] = eventData.event.time
		queryParams['@category'..i] = eventData.category
		queryParams['@name'..i] = eventData.name
		queryParams['@value'..i] = extractValue(eventData.event)
	end

	MySQL.Async.execute(query, queryParams, function()
		local dumpTotalTime = os.clock() - dumpStartTime
		log(string.format('Dumped %d event(s) for %d ms', eventCount, math.floor(dumpTotalTime / 1000)))
	end)

	eventQueue = { }
	WarTracker.ClearEvents()
end


function WarTracker.MySQL.SetLogEnabled(enabled)
	isLogEnabled = enabled
end

function WarTracker.MySQL.SetDumpInterval(interval)
	dumpInterval = interval
end

function WarTracker.MySQL.SetDumpMinEventCount(count)
	dumpMinEventCount = count
end


-- Init
MySQL.ready(function()
	MySQL.Async.execute(schema, { }, function()
		while true do
			if dumpMinEventCount then
				if WarTracker.GetEventCount() >= dumpMinEventCount then
					dumpEventQueue()
				end
			else
				dumpEventQueue()
			end

			Citizen.Wait(dumpInterval)
		end
	end)
end)

AddEventHandler('wartracker:eventReported', function(category, name, event)
	table.insert(eventQueue, {
		category = category,
		name = name,
		event = event,
	})
end)

AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() ~= resourceName then return end

	dumpEventQueue()
end)