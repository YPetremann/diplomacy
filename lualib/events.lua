require("util")
events = {}
events_db = {}
events.register = function(event, id, callback)
  -- register an event
  if event == defines.events then event = -1 end
  if events_db[event] == nil then events_db[event] = {} end
  events_db[event][id] = callback
end
events.unregister = function(event, id)
  if events_db[event] == nil then events_db[event] = {} end
  events_db[event][id] = nil
end
script.on_event(defines.events,function(event)
  if events_db[-1] then
    for _,callback in pairs(events_db[-1]) do
      callback(table.deepcopy(event))
    end
  end
  if events_db[event.name] then
    for _,callback in ipairs(events_db[event.name]) do
      callback(table.deepcopy(event))
    end
  end
end)
