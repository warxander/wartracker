WarTracker = { }
WarTracker.__index = WarTracker


local events = { }
local isLogEnabled = false

local function log(message, forced)
	if not forced and not isLogEnabled then return end
	Citizen.Trace('['..os.date('%c')..'] [WarTracker] '..message..'\n')
end


function WarTracker.SetLogEnabled(enabled)
	isLogEnabled = enabled
end

function WarTracker.RegisterEvent(category, name)
	if not events[category] then
		log('Registering '..category..' category...')
		events[category] = { }
	end

	if not events[category][name] then
		log('Registering '..category..':'..name..' event...')
		events[category][name] = { }
	end
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