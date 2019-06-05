local schema = 'CREATE TABLE IF NOT EXISTS WarTracker (\
	ReportId INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,\
	Time INT(10) NOT NULL,\
	Category MEDIUMTEXT NOT NULL,\
	Name MEDIUMTEXT NOT NULL,\
	Value MEDIUMTEXT DEFAULT NULL\
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;'

local function extractValue(event)
	if not event.value then return 'NULL' end
	if type(event.value) == 'table' then return json.encode(event.value) end
	return tostring(event.value)
end


MySQL.ready(function()
	MySQL.Sync.execute(schema)
end)

AddEventHandler('wartracker:eventReported', function(category, name, event)
	MySQL.Async.execute('INSERT INTO WarTracker (Time, Category, Name, Value) VALUES (@time, @category, @name, @value)', {
		['@time'] = event.time,
		['@category'] = category,
		['@name'] = name,
		['@value'] = extractValue(event),
	})
end)