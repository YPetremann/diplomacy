require("defines")
require("lualib.gui")
require("lualib.events")
global.data = {tab={},as_player={},as_force={}}
function inTable(tbl, item) for _, value in ipairs(tbl) do if value == item then return true end end return false end
function print_all(message) for _, player in pairs(game.players) do player.print(message) end end
function update_all()
  for _, player in pairs(game.players) do
    update_settings(player)
    update_forces(player)
    update_players(player)
    update_diplomacy(player)
  end
end
function hide_menu(player)
  gui.destroy{player.gui.left, "diplomacy_main"}
end
function show_menu(player)
  local tab = global.data.tab[player.name]
  gui.destroy{player.gui.left, "diplomacy_main"}
  local tab_model = {widget={type="button", style="image_tab_slot_style"}, style={minimal_width=100, maximal_width=100, minimal_height=32}}
  local tab_model_selected = gui.merge(tab_model, {{style="image_tab_selected_slot_style"}})

  local frame = gui.add(player.gui.left, {{type="frame", name="diplomacy_main", caption={"main_menu"}, direction="horizontal"}})
  local tabs_buttons = gui.add(frame, {{type="flow", name="tab_buttons", direction="vertical", style="slot_table_spacing_flow_style"}})
  local tabs = {settings={"Settings",show_settings}, players={"Players",show_players}, forces={"Forces",show_forces}, diplomacy={"Diplomacy",show_diplomacy}}
  for key,value in pairs(tabs) do
    gui.add(tabs_buttons, (tab == key) and tab_model_selected or tab_model, {{name="diplomacy_tab{'"..key.."'}", caption=value[1]}})
  end
  gui.add(frame, {{type="flow", name="tab_area", direction="horizontal"}})
  tabs[tab][2](player)
end
function update_menu(player, tab)
  gui.destroy{player.gui.left, "diplomacy_main"}
  local frame = gui.add(player.gui.left, {{type="frame", name="diplomacy_main", caption={"main_menu"}, direction="horizontal"}})
  local tabs_buttons = gui.add(frame, {{type="flow", name="tab_buttons", direction="vertical", style="slot_table_spacing_flow_style"}})
  local tab_model = {widget={type="button", style="image_tab_slot_style"}, style={minimal_width=100, maximal_width=100, minimal_height=32}}
  local tab_model_selected = gui.merge(tab_model, {{style="image_tab_selected_slot_style"}})
  local tabs = {settings={"Settings",show_settings}, players={"Players",show_players}, forces={"Forces",show_forces}, diplomacy={"Diplomacy",show_diplomacy}}
  for key,value in pairs(tabs) do
    gui.add(tabs_buttons, (tab == key) and tab_model_selected or tab_model, {{name="diplomacy_tab{'"..key.."'}", caption=value[1]}})
  end
  gui.add(frame, {{type="flow", name="tab_area", direction="horizontal"}})
  tabs[tab][2](player)
end


function on_gui_click_diplomacy_tab(event, params)
  local player = game.players[event.player_index]
  global.data.tab[player.name] = params[1]
  show_menu(player)
end
--[[
global.buffer = {}
evens.register(defines.events,1,function(event)
  events = { [0] = "on_tick",                          [1] = "on_gui_click",                [2] = "on_entity_died",
             [3] = "on_picked_up_item",                [4] = "on_built_entity",             [5] = "on_sector_scanned",
             [6] = "on_player_mined_item",             [7] = "on_put_item",                 [8] = "on_rocket_launched",
             [9] = "on_preplayer_mined_item",         [10] = "on_chunk_generated",         [11] = "on_player_crafted_item", 
            [12] = "on_robot_built_entity",           [13] = "on_robot_pre_mined",         [14] = "on_robot_mined",
            [15] = "on_research_started",             [16] = "on_research_finished",       [17] = "on_player_rotated_entity",
            [18] = "on_marked_for_deconstruction",    [19] = "on_canceled_deconstruction", [20] = "on_trigger_created_entity",
            [21] = "on_train_changed_state",          [22] = "on_player_created",          [23] = "on_resource_depleted", 
            [24] = "on_player_driving_changed_state", [25] = "on_force_created",           [26] = "on_forces_merging"}
  if event.name ~= defines.events.on_tick and event.name ~= defines.events.on_chunk_generated then
    table.insert(global.buffer, event)
  end
  if (#game.players > 0) and (#global.buffer > 0) then
    print_event = table.remove(global.buffer,1)
    print_event.name = events[event.name]
    print_all(serpent.line(print_event))
  end
end) --[[ ]] -- ]]
-- wip
function hide_settings(player)
  gui.destroy{player.gui.left,"diplomacy_main", "tab_area", "settings"}
end
function show_settings(player)
  hide_settings(player)
  local tab_area = gui.get{player.gui.left, "diplomacy_main", "tab_area"}
  if tab_area then
    gui.add(tab_area, {{type="frame", name="settings", caption="Settings (as "..global.data.as_player[player.name]..")", direction="vertical", style="naked_frame_style"}})
    update_settings(player)
  end
end
function update_settings(player)
  local tab = gui.get{player.gui.left, "diplomacy_main", "tab_area", "settings"}
  if tab then
    gui.empty(tab)
    gui.add(tab, {{type="label", caption="TODO : start settings, player settings, admin settings, localisation"}})
    gui.add(tab, {{type="label", caption="If you find any bugs, please report them on the mod topic."}})
  end
end
-- working
function hide_players(player)
  gui.destroy(player.gui.left,{"diplomacy_main", "tab_area", "players"})
end
function show_players(player)
  hide_settings(player)
  local tab_area = gui.get{player.gui.left, "diplomacy_main", "tab_area"}
  if tab_area then
    local tab_players = gui.add(tab_area, {{type="frame", name="players", caption="Players", direction="vertical", style="naked_frame_style"}})
    local table_players = gui.add(tab_players, {{type="table", name="table", colspan=3, style="electric_network_sections_table_style"}})
    local label_model = {{type="label", caption="Player", style="caption_label_style"},{minimal_width=150}}
    gui.add(table_players, label_model, {{caption="Player", name='head_0'}})
    gui.add(table_players, label_model, {{caption="Actions", name='head_1'}})
    gui.add(table_players, label_model, {{caption="Force", name='head_2'}})
    update_players(player)
  end
end
function update_players(player)
  local table_players = gui.get{player.gui.left, "diplomacy_main", "tab_area", "players", "table"}
  if table_players then
    gui.empty(table_players,{'head_0', 'head_1', 'head_2'})
    for _, player in pairs(game.players) do
      gui.add(table_players, {{type="label", caption=player.name, style="mod_list_label_style"}})
      local actions = gui.add(table_players, {{type="flow", style="slot_table_spacing_flow_style"}})
      local button_model = {widget={type="button", style="controls_settings_button_style"},style={minimal_width=50}}
      gui.add(actions, button_model, {{caption="Force", name="diplomacy_players_force_button{'"..player.name.."'}"}})
      gui.add(actions, button_model, {{caption="Settings", name="diplomacy_players_settings_button{'"..player.name.."'}"}})
      gui.add(table_players, {{type="label", caption=player.force.name, name="diplomacy_players_force_"..player.name.."'}"}})
    end
  end
end
function hide_forces(player)
  gui.destroy{player.gui.left,"diplomacy_main", "tab_area", "forces"}
end
function show_forces(player)
  local as_player = game.get_player(global.data.as_player[player.name])
  hide_forces(player)
  local tab_area = gui.get{player.gui.left, "diplomacy_main", "tab_area"}
  if tab_area then
    local tab_forces = gui.add(tab_area, {{type="frame", name="forces", caption="Forces (as "..as_player.name..")", direction="vertical", style="naked_frame_style"}})
    local table_forces = gui.add(tab_forces, {{type="table", name="table", colspan=3, style="electric_network_sections_table_style"}})
    local label_model = {{type="label", caption="Player", style="caption_label_style"},{minimal_width=150}}
    local button_model = {widget={type="button", style="controls_settings_button_style"},style={minimal_width=25}}
    gui.add(table_forces, label_model, {{caption="Force", name='head_0'}})
    gui.add(table_forces, label_model, {{caption="Actions", name='head_1'}})
    gui.add(table_forces, label_model, {{caption="Players", name='head_2'}})
    gui.add(table_forces, {{type="textfield", name="diplomacy_force_textfield"}})
    local actions = gui.add(table_forces, {{type="flow", name='head_4', direction="horizontal", style="slot_table_spacing_flow_style"}})
    gui.add(actions, button_model, {{caption="Add", name="diplomacy_force_new_button"}})
    gui.add(table_forces, {{type="checkbox", caption="join",state=true, name='diplomacy_force_checkbox'}})
    update_forces(player)
  end
end
function update_forces(player)
  local as_player = game.get_player(global.data.as_player[player.name])
  local table_forces = gui.get{player.gui.left, "diplomacy_main", "tab_area", "forces", "table"}
  if table_forces then
    gui.empty(table_forces,{'head_0', 'head_1', 'head_2', "diplomacy_force_textfield", 'head_4', 'diplomacy_force_checkbox'})
    local button_model = {widget={type="button", style="controls_settings_button_style"},style={minimal_width=25}}
    local button_disabled_model = gui.merge(button_model, {style={font_color={r = 0, g = 0, b = 0, a = 0.25}}})
    for _, force in pairs(game.forces) do
      gui.add(table_forces,{{type="label", caption=force.name}})
      local actions = gui.add(table_forces,{{type="flow", direction="horizontal", style="slot_table_spacing_flow_style"}})
      if as_player.force.name == force.name then
        gui.add(actions, button_disabled_model, {{caption="Join"}})
      else
        gui.add(actions, button_model, {{name="diplomacy_force_join_button{'"..force.name.."'}", caption="Join"}})
      end
      if as_player.force.name == force.name or inTable({"player","enemy","neutral"},force.name) then
        gui.add(actions, button_disabled_model, {{caption="Merge"}})
      else
        gui.add(actions, button_model, {{name="diplomacy_force_merge_button{'"..force.name.."'}", caption="Merge"}})
      end
      gui.add(actions, button_model, {{name="diplomacy_force_diplomacy_button{'"..force.name.."'}", caption="Diplomacy"}})
      local players = gui.add(table_forces, {{type="flow", direction="horizontal", style="slot_table_spacing_flow_style"}})
      for _, player2 in pairs(force.players) do
        gui.add(players, player2.connected and button_model or button_disaabled_model, {{caption=player2.name, name="diplomacy_force_player_button{'"..player2.name.."'}"}})
      end
    end
  end
end
function hide_diplomacy(player)
  gui.destroy(player.gui.left,{"diplomacy_main", "tab_area", "diplomacy"})
end
function show_diplomacy(player)
  hide_diplomacy(player)
  local as_force = game.forces[global.data.as_force[player.name]]
  local tab_area = gui.get{player.gui.left, "diplomacy_main", "tab_area"}
  if tab_area then
    local tab_diplomacy = gui.add(tab_area, {{type="frame", name="diplomacy", caption="Diplomacy (as "..as_force.name..")", direction="vertical", style="naked_frame_style"}})
    local table_diplomacy = gui.add(tab_diplomacy, {{type="table", name="table", colspan=3, style="electric_network_sections_table_style"}})
    local label_model = {widget={type="label", caption="Player", style="caption_label_style"},style={minimal_width=150}}
    gui.add(table_diplomacy, label_model, {{caption="Force", name="head_0"}})
    gui.add(table_diplomacy, label_model, {widget={caption="Our Stance", name="head_1"},style={minimal_width=80}})
    gui.add(table_diplomacy, label_model, {widget={caption="Their stance", name="head_2"},style={minimal_width=80}})
    update_diplomacy(player)
  end
end
function update_diplomacy(player)
  local as_force = game.forces[global.data.as_force[player.name]]
  local table_diplomacy = gui.get{player.gui.left, "diplomacy_main", "tab_area", "diplomacy", "table"}
  if table_diplomacy then
    gui.empty(table_diplomacy, {'head_0', 'head_1', 'head_2'})
    local button_model = {widget={type="button", style="controls_settings_button_style"}, style={minimal_width=50}}
    local neutral_model = {widget={type="button", caption="-", style="slot_button_style"}, style={minimal_width=80, maximal_width=80}}
    local ally_model = gui.merge(neutral_model, {{caption="ally", style="green_slot_button_style"}})
    local enemy_model = gui.merge(neutral_model, {{caption="enemy", style="not_available_slot_button_style"}})
    for _, force in pairs(game.forces) do
      gui.add(table_diplomacy, button_model, {{caption=force.name, name="diplomacy_diplomacy_force_button{'"..force.name.."'}"}})
      local link = true
      if force.name == as_force.name then
        gui.add(table_diplomacy, neutral_model)
        gui.add(table_diplomacy, neutral_model)
      else
        local our_model = as_force.get_cease_fire(force.name) and ally_model or enemy_model
        local their_model = force.get_cease_fire(as_force.name) and ally_model or enemy_model
        gui.add(table_diplomacy, our_model, {{name="diplomacy_diplomacy_change_button{'"..force.name.."'}"}})
        gui.add(table_diplomacy, their_model)
      end
    end
  end
end

function on_gui_click_diplomacy_menu_button(event, params)
  local player = game.players[event.player_index]
  local main = gui.get{player.gui.left, "diplomacy_main"}
  if main then
    hide_menu(player)
  else
    show_menu(player)
  end
end
function on_gui_click_diplomacy_players_force_button(event, params)
  local player = game.players[event.player_index]
  global.data.as_player[player.name]=params[1]
  global.data.tab[player.name] = "forces"
  show_menu(player)
end
function on_gui_click_diplomacy_players_settings_button(event, params)
  local player = game.players[event.player_index]
  global.data.as_player[player.name]=params[1]
  global.data.tab[player.name] = "settings"
  show_menu(player)
end
function on_gui_click_diplomacy_force_player_button(event, params)
  local player = game.players[event.player_index]
  global.data.as_player[player.name]=params[1]
  global.data.tab[player.name] = "forces"
  show_menu(player)
end
function on_gui_click_diplomacy_force_new_button(event, params)
  local player = game.players[event.player_index]
  local as_player = game.get_player(global.data.as_player[player.name])
  local force = gui.get{player.gui.left, "diplomacy_main", "tab_area", "forces", "table", "diplomacy_force_textfield"}.text
  local join = gui.get{player.gui.left, "diplomacy_main", "tab_area", "forces", "table", "diplomacy_force_checkbox"}.state
  if force == "" then player.print("Can't create a force with no name !") return end
  if game.forces[force] then player.print("A force with that name already exists!") return end
  print_all("New force '"..force.."' created by player '"..player.name.."'.")
  if join then
    if player.name == as_player.name then
      print_all("Player '"..as_player.name.."' joined force '"..force.."'.")
      global.data.as_force[player.name] = force.name
    else
      print_all("Player '"..as_player.name.."' has been moved to force '"..force.."' by '"..player.name.."'.")
    end
    as_player.force = game.create_force(force)
  else
    game.create_force(force)
  end
  update_all()
end
function on_gui_click_diplomacy_force_join_button(event, params)
  local player = game.players[event.player_index]
  local as_player = game.get_player(global.data.as_player[player.name])
  local force = game.forces[params[1]]
  if force then
    if player.name == as_player.name then
      print_all("Player '"..as_player.name.."' joined force '"..force.name.."'.")
      global.data.as_force[player.name] = force.name
    else
      print_all("Player '"..as_player.name.."' has been moved to force '"..force.name.."' by '"..player.name.."'.")
    end
    as_player.force = force
  end
  update_all()
end
function on_gui_click_diplomacy_force_merge_button(event, params)
  local player = game.players[event.player_index]
  local selected = game.forces[params[1]]
  if selected and selected.valid then
    print_all("Merging force '" .. selected.name .. "' in '" .. player.force.name .."'.")
    game.merge_forces(selected.name, player.force.name)
    update_all()
  end
end
function on_gui_click_diplomacy_force_diplomacy_button(event, params)
  local player = game.players[event.player_index]
  global.data.as_force[player.name]=params[1]
  global.data.tab[player.name] = "diplomacy"
  show_menu(player)
end
function on_gui_click_diplomacy_diplomacy_force_button(event, params)
  local player = game.players[event.player_index]
  global.data.as_force[player.name]=params[1]
  global.data.tab[player.name] = "diplomacy"
  show_menu(player)
end
function on_gui_click_diplomacy_diplomacy_change_button(event, params)
  local player = game.players[event.player_index]
  local as_force = game.forces[global.data.as_force[player.name]]
  local to_force = params[1]
  as_force.set_cease_fire(to_force, not as_force.get_cease_fire(to_force))
  print_all("Player '" .. player.name .. "' has defined '"..as_force.name.."' as "..(as_force.get_cease_fire(to_force) and "ally" or "enemy").." of '"..to_force.."'.")
  update_all(player)
end

script.on_load(function(event)
  if not global.data then global.data = {} end
  if not global.data.as_player then global.data.as_player = {} end
  if not global.data.as_force then global.data.as_force = {} end
  if not global.data.tab then global.data.tab = {} end
end)
events.register(defines.events.on_player_created, 1, function(event)
  local player = game.players[event.player_index]
  global.data.as_player[player.name]=player.name
  global.data.as_force[player.name]=player.force.name
  global.data.tab[player.name]="settings"
  game.players[event.player_index].gui.top.add({type="button", caption={"main_menu"}, name="diplomacy_menu_button"})
  update_all(player)
end)
events.register(defines.events.on_gui_click, 1, function(event)
  local element = event.element.name
  local function_name = element
  local function_params = {}
  if string.find(element, "%{") then
    function_name = string.sub(element, 0, string.find(element, "%{")-1)
    function_params = assert(loadstring("return "..string.sub(element, string.find(element, "%{")+0)))()
  end
  callback = _G["on_gui_click_"..function_name]
  if type(callback)=="function" then 
    callback(event, function_params)
  end
end)
