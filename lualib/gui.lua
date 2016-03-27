function inTable(tbl, item) for _, value in ipairs(tbl) do if value == item then return true end end return false end
function split(str)
  local result = {}
  for part in string.gmatch(str, '([^\n]+)') do table.insert(result, part); end
  return result
end
gui={}
gui.merge = function(model, merge)
  local element = {widget={}, style={}}
  if model.widget ~= nil then for key, value in pairs(model.widget) do element.widget[key] = value end end
  if model[1] ~= nil then for key, value in pairs(model[1]) do element.widget[key] = value end end
  if model.style ~= nil then for key, value in pairs(model.style) do element.style[key] = value end end
  if model[2] ~= nil then for key, value in pairs(model[2]) do element.widget[key] = value end end
  if merge ~= nil then
    if merge.widget ~= nil then for key, value in pairs(merge.widget) do element.widget[key] = value end end
    if merge[1] ~= nil then for key, value in pairs(merge[1]) do element.widget[key] = value end end
    if merge.style ~= nil then for key, value in pairs(merge.style) do element.style[key] = value end end
    if merge[2] ~= nil then for key, value in pairs(merge[2]) do element.style[key] = value end end
  end
  return element
end
gui.add = function(parent, model, merge)
  local element = gui.merge(model, merge)
  if parent == nil then for _,v in ipairs(split(debug.traceback())) do print_all(v) end end
  if element.widget.name == nil then element.widget.name = parent.name.."_"..element.widget.type.."_"..(#parent.children_names + 1) end
  if parent[element.widget.name] ~= nil then element.widget.name = element.widget.name.."_"..(#parent.children_names + 1) end
  local child = parent.add(element.widget)
  if element.style ~= nil then for key, value in pairs(element.style) do child.style[key] = value end end
  return child
end
gui.validate = function(widget)
  -- validate gui element
  return (widget and widget.valid) and widget or nil
end
gui.get = function(nodes)
  -- get widget by following path, return false if unreachable
  widget = table.remove(nodes, 1)
  for _, node in ipairs(nodes) do
    if not gui.validate(widget) then return nil end
    widget = widget[node]
  end
  return gui.validate(widget)
end
gui.destroy = function(widget, nodes)
  -- destroy widget by following path if reachable
  local element = gui.get(widget,nodes)
  if element then element.destroy() end
end
gui.empty = function(widget, list)
  -- destroy widget childs
  if list == nil then list = {} end
  for _, name in pairs(widget.children_names) do
    if not inTable(list, name) then
      widget[name].destroy()
    end
  end
end
