# WarTracker
WarTracker is a FiveM event tracking resource.
Use it to collect stats about what are your players doing to improve their experience.


## How to Install
* Add `start wartracker` to your `server.cfg`
* Add `server_script '@wartracker/wartracker.lua'` to your `__resource.lua`
* Add `server_script '@wartracker/wartracker_mysql.lua'` to store events in database (for [MySQL Async](https://github.com/brouznouf/fivem-mysql-async "MySQL Async"))


## Usage
```lua
WarTracker.RegisterEvent('Jobs', 'jobFailed')
AddEventHandler('your_resource:jobFailed', function(jobName)
  WarTracker.SendEvent('Jobs', 'jobFailed', jobName)
end)

WarTracker.RegisterEvent('Market', 'itemPurchased')
AddEventHandler('your_resource:itemPurchased', function(item, count)
  WarTracker.SendEvent('Market', 'itemPurchased', { item = item, count = count })
end)

WarTracker.RegisterServerEvent('playerDropped')
```

## API
```lua
--Events
AddEventHandler('wartracker:eventReported', function(category, name, event)
    Citizen.Trace(event.time) --os.time()
    Citizen.Trace(event.value)
end)

-- Functions
WarTracker.SetLogEnabled(enabled)

WarTracker.RegisterEvent(category, name)
WarTracker.SendEvent(category, name, value)
WarTracker.RegisterServerEvent(eventName)

WarTracker.GetEventCount()
WarTracker.ClearEvents()

-- wartracker_mysql.lua
WarTracker.MySQL.SetLogEnabled(enabled)
WarTracker.MySQL.SetDumpInterval(interval)
WarTracker.MySQL.SetDumpMinEventCount(count)
```


## Changelog
### 1.1
* (MySQL) Use configurable deferred event queue dump
* New API
  - `WarTracker.GetEventCount()`
  - `WarTracker.ClearEvents()`
  - `WarTracker.MySQL.SetLogEnabled(enabled)`
  - `WarTracker.MySQL.SetDumpInterval(interval)`
  - `WarTracker.MySQL.SetDumpMinEventCount(count)`

### 1.0
* Initial release