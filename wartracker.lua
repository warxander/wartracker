WarTracker = { }
WarTracker.__index = WarTracker


local serverEventCategoryName = '__serverEvent' -- Edit this if you want

-- Do not change anything below!
local events = { }
local isLogEnabled = false

local function log(message, forced)
	if not forced and not isLogEnabled then return end
	Citizen.Trace('['..os.date('%c')..'] [WarTracker] '..message..'\n')
end


function WarTracker.SetLogEnabled(enabled)
	isLogEnabled = enabled
end

function WarTracker.RegisterServerEvent(eventName)
	if not WarTracker.RegisterEvent(serverEventCategoryName, eventName) then return end

	AddEventHandler(eventName, function(...)
		local eventValue = nil
		local args = { ... }
		local argc = #args

		if argc ~= 0 then
			if argc == 1 then
				eventValue = args[1]
			else
				eventValue = { }
				for i = 1, argc do table.insert(eventValue, args[i]) end
			end
		end

		WarTracker.SendEvent(serverEventCategoryName, eventName, eventValue)
	end)
end

function WarTracker.RegisterEvent(category, name)
	if not events[category] then
		log('Registering '..category..' category...')
		events[category] = { }
	end

	if not events[category][name] then
		log('Registering '..category..':'..name..' event...')
		events[category][name] = { }
		return true
	end

	return false
end

function WarTracker.SendEvent(category, name, value)
	if not events[category] then
		log('No such event category: '..category, true)
		return
	end

	if not events[category] then
		log('No such event name: '..name, true)
		return
	end

	local event = {
		time = os.time(),
		value = value,
	}

	table.insert(events[category][name], event)
	TriggerEvent('wartracker:eventReported', category, name, event)
end

function WarTracker.GetEventCount()
	local eventCount = 0

	for _, eventLists in pairs(events) do
		for _, eventList in pairs(eventLists) do
			eventCount = eventCount + #eventList
		end
	end

	return eventCount
end

function WarTracker.ClearEvents()
	for _, eventLists in pairs(events) do
		for _, eventList in pairs(eventLists) do
			eventList = { }
		end
	end
end