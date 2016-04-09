require("util")
require("defines")
require("lualib.gui")
require("lualib.events")

function inTable(tbl, item) for _, value in ipairs(tbl) do if value == item then return true end end return false end
function print_all(message) for _, player in pairs(game.players) do player.print(message) end end
-- global

function get_player(event)
  if event == nil then for _,v in ipairs(split(debug.traceback())) do print_all(v) end end
  return game.players[event.player_index]
end
function get_as_player(player)
  player = player.name or player
  return game.get_player(global.data.as_player[player] or player)
end
function set_as_player(player, as_player)
  player = player.name or player
  as_player = as_player.name or as_player
  global.data.as_player[player] = as_player
end
function get_as_force(player) return game.forces[global.data.as_force[player.name] or player.force.name] end
function set_as_force(player, as_force)
  if as_force.name then as_force = as_force.name end
  global.data.as_force[player.name] = as_force
end
function get_tab(player) return global.data.tab[player.name] or "settings" end
function set_tab(player, tab) global.data.tab[player.name] = tab end

function update_all()
  local tabs = {
    settings={{"settings"}, show_settings, update_settings},
    players={{"players"}, show_players, update_players},
    forces={{"forces"},show_forces, update_forces},
    diplomacy={{"diplomacy"},show_diplomacy, update_diplomacy}
  }
  for _, player in pairs(game.players) do
    local tab = get_tab(player)
    tabs[tab][3](player)
  end
end
function hide_button(player)
  gui.destroy{player.gui.top, "diplomacy_menu"}
  hide_menu(player)
end
function show_button(player)
  local main = gui.get{player.gui.top, "diplomacy_menu"}
  if not main then
    gui.add(player.gui.top, {{type="button", caption={"main_menu"}, name="diplomacy_menu"}})
  end
end

function hide_menu(player)
  gui.destroy{player.gui.left, "diplomacy_main"}
end
function show_menu(player)
  local tab = get_tab(player)
  gui.destroy{player.gui.left, "diplomacy_main"}
  local tab_model = {widget={type="button", style="image_tab_slot_style"}, style={minimal_width=100, maximal_width=100, minimal_height=32}}
  local tab_model_selected = gui.merge(tab_model, {{style="image_tab_selected_slot_style"}})
  local frame = gui.add(player.gui.left, {{type="frame", name="diplomacy_main", caption={"main_menu"}, direction="horizontal"}})
  local tabs_buttons = gui.add(frame, {{type="flow", name="tab_buttons", direction="vertical", style="slot_table_spacing_flow_style"}})
  local tabs = {
    settings={{"Settings"}, show_settings, update_settings},
    players={{"Players"}, show_players, update_players},
    forces={{"Forces"},show_forces, update_forces},
    diplomacy={{"Diplomacy"},show_diplomacy, update_diplomacy}
  }
  for key,value in pairs(tabs) do
    gui.add(tabs_buttons, (tab == key) and tab_model_selected or tab_model, {{name="diplomacy_tab{'"..key.."'}", caption=value[1]}})
  end
  gui.add(frame, {{type="flow", name="tab_area", direction="horizontal"}})
  tabs[tab][2](player)
end
function update_menu(player, tab)
  local frame = gui.add(player.gui.left, {{type="frame", name="diplomacy_main", caption={"main_menu"}, direction="horizontal"}})
  local tabs_buttons = gui.add(frame, {{type="flow", name="tab_buttons", direction="vertical", style="slot_table_spacing_flow_style"}})
  local tab_model = {widget={type="button", style="image_tab_slot_style"}, style={minimal_width=100, maximal_width=100, minimal_height=32}}
  local tab_model_selected = gui.merge(tab_model, {{style="image_tab_selected_slot_style"}})
  for key,value in pairs(tabs) do
    gui.add(tabs_buttons, (tab == key) and tab_model_selected or tab_model, {{name="diplomacy_tab{'"..key.."'}", caption=value[1]}})
  end
  gui.add(frame, {{type="flow", name="tab_area", direction="horizontal"}})
  tabs[tab][2](player)
end

-- wip
function hide_settings(player)
  gui.destroy{player.gui.left,"diplomacy_main", "tab_area", "settings"}
end
function show_settings(player)
  hide_settings(player)
  local tab_area = gui.get{player.gui.left, "diplomacy_main", "tab_area"}
  if tab_area then
    gui.add(tab_area, {{type="flow", name="settings", direction="vertical"}})
    update_settings(player)
  end
end
function update_settings(player)
  local tab = gui.get{player.gui.left, "diplomacy_main", "tab_area", "settings"}
  local as_player = get_as_player(player)
  local as_force = get_as_force(player)
  local frame_model = {{type="frame", direction="vertical", style="naked_frame_style"}}
  local button_model = {widget={type="button", style="controls_settings_button_style"}, style={minimal_width=50}}
  local colors = {
    ["Singleplayer"]          = {r=0.75, g=0.34, b=0.27, a=0.40},
    ["Aqua marine"]           = {r=0.47, g=0.85, b=0.88, a=1.00},
    ["Decent red"]            = {r=0.78, g=0.21, b=0.35, a=0.80},
    ["Lime green"]            = {r=0.50, g=1.00, b=0.25, a=0.80},
    ["Lemon yellow"]          = {r=1.00, g=0.95, b=0.54, a=0.70},
    ["Mulberry purple"]       = {r=0.77, g=0.29, b=0.54, a=0.90},
    ["Magic mint"]            = {r=0.66, g=0.94, b=0.81, a=1.00},
    ["Scarlet"]               = {r=0.98, g=0.15, b=0.27, a=0.50},
    ["Almond"]                = {r=0.93, g=0.87, b=0.80, a=0.70},
    ["Alien purple"]          = {r=0.98, g=0.45, b=0.99, a=1.00},
    ["White"]                 = {r=1.00, g=1.00, b=1.00, a=1.00},
    ["Lilac blue"]            = {r=0.20, g=0.50, b=1.00, a=0.60},
    ["Tropical rain forrest"] = {r=0.09, g=0.50, b=0.42, a=0.60},
    ["Barbie from hell"]      = {r=0.98, g=0.45, b=0.99, a=0.20},
    ["Golden brown"]          = {r=0.75, g=0.34, b=0.27, a=0.65},

  }
  if tab then
    gui.empty(tab)
    local presets = gui.add(tab, frame_model, {{name="presets", caption={"Presets"}}})
    gui.add(presets, {{type="checkbox",caption="One force per player",state=false}})
    gui.add(presets, {{type="checkbox",caption="Distribute between forces",state=false}})
    gui.add(presets, {{type="checkbox",caption="Everybody in the same force",state=false}})
    gui.add(tab, frame_model, {{name="game", caption={"Game"}}})
    local player_settings = gui.add(tab, frame_model, {{name="player", caption={"Player_as", as_player.name} }})
    local color_presets = gui.add(player_settings, {{type="table", name="table", colspan=5 }})
    for name, color in pairs(colors) do
        gui.add(color_presets, {{type="checkbox", caption=name, name="diplomacy_settings_player_color"..serpent.line(color,{comment=false,compact=true,numformat="%.2g"}), state=(serpent.line(color,{comment=false,compact=true,numformat="%.2g"})==serpent.line(as_player.color,{comment=false,compact=true,numformat="%.2g"}))}})
    end
    gui.add(color_presets, {{type="textfield", caption="Red", name="red", text=serpent.line(as_player.color.r,{comment=false,compact=true,numformat="%.2g"})}})
    gui.add(color_presets, {{type="textfield", caption="Green", name="green", text=serpent.line(as_player.color.g,{comment=false,compact=true,numformat="%.2g"})}})
    gui.add(color_presets, {{type="textfield", caption="Blue", name="blue", text=serpent.line(as_player.color.b,{comment=false,compact=true,numformat="%.2g"})}})
    gui.add(color_presets, {{type="textfield", caption="Alpha", name="alpha", text=serpent.line(as_player.color.a,{comment=false,compact=true,numformat="%.2g"})}})
    gui.add(color_presets, button_model, {{caption="Apply", name="diplomacy_settings_player_color_apply"}})
    gui.add(tab, frame_model, {{name="force", caption={"Force_as", as_force.name}}})
    local admin = gui.add(tab, frame_model, {{name="admin", caption={"Admin"}}})
    if remote.interfaces.auth then
      local auth = gui.add(admin, {{type="table", name="authenticate", colspan=2 }})
      gui.add(auth, {{type="label", caption="Authenticate"}})
      gui.add(auth, {{type="label", caption=""}})
      gui.add(auth, {{type="textfield", caption="Password", name="password"}})
      gui.add(auth, button_model, {{caption="Authenticate", name="diplomacy_player_authenticate"}})
      local change_password = gui.add(admin, {{type="table", name="change_password", colspan=2 }})
      gui.add(change_password, {{type="label", caption="Change Password"}})
      gui.add(change_password, {{type="label", caption=""}})
      gui.add(change_password, {{type="textfield", caption="Old Password", name="old_password"}})
      gui.add(change_password, {{type="label", caption="Old"}})
      gui.add(change_password, {{type="textfield", caption="New Password", name="new_password"}})
      gui.add(change_password, {{type="label", caption="New"}})
      gui.add(change_password, button_model, {{caption="Set New Password", name="diplomacy_player_set_password"}})
    end
  end
end

function check_admin(player)
  if remote.interfaces.auth then
    if remote.call("auth", "is_admin", player.name) then
      if remote.call("auth", "validate", global.data.auth_tokens[player.name]) then
        return true
      end
    else
      player.print("Need to be admin to do that...")
      return false
    end
  else
    return true
  end
end

-- working
function hide_players(player)
  gui.destroy(player.gui.left,{"diplomacy_main", "tab_area", "players"})
end
function show_players(player)
  hide_settings(player)
  local tab_area = gui.get{player.gui.left, "diplomacy_main", "tab_area"}
  local button_model = {widget={type="button", style="controls_settings_button_style"},style={minimal_width=10}}
  if tab_area then
    local tab_players = gui.add(tab_area, {{type="frame", name="players", caption={"Players"}, direction="vertical", style="naked_frame_style"}})
    local table_players = gui.add(tab_players, {{type="table", name="table", colspan=3, style="electric_network_sections_table_style"}})
    local label_model = {widget={type="label", caption={"Player"}, style="caption_label_style"},style={minimal_width=200}}
    gui.add(table_players, label_model, {{caption={"Player"}, name='head_0'}})
    gui.add(table_players, label_model, {{caption={"Actions"}, name='head_1'}})
    gui.add(table_players, label_model, {{caption={"Force"}, name='head_2'}})
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
      gui.add(actions, button_model, {{caption={"Forces"}, name="diplomacy_go_forces{'"..player.name.."'}"}})
      gui.add(actions, button_model, {{caption={"Settings"}, name="diplomacy_go_settings{'"..player.name.."'}"}})
      if remote.interfaces.auth then
        gui.add(actions, button_model, {{caption={"Toggle_Admin"}, name="diplomacy_toggle_admin{'"..player.name.."'}"}})
      end
      gui.add(table_players, {{type="label", caption=player.force.name, name="diplomacy_players_force_"..player.name.."'}"}})
    end
  end
end

function hide_forces(player)
  gui.destroy{player.gui.left,"diplomacy_main", "tab_area", "forces"}
end
function show_forces(player)
  local as_player = get_as_player(player)
  hide_forces(player)
  local tab_area = gui.get{player.gui.left, "diplomacy_main", "tab_area"}
  if tab_area then
    local tab_forces = gui.add(tab_area, {{type="frame", name="forces", caption={"Forces_as", as_player.name}, direction="vertical", style="naked_frame_style"}})
    local table_forces = gui.add(tab_forces, {{type="table", name="table", colspan=3, style="electric_network_sections_table_style"}})
    local label_model = {widget={type="label", caption={"Player"}, style="caption_label_style"},style={minimal_width=200}}
    local button_model = {widget={type="button", style="controls_settings_button_style"},style={minimal_width=25}}
    gui.add(table_forces, label_model, {{caption={"Force"}, name='head_0'}})
    gui.add(table_forces, label_model, {{caption={"Actions"}, name='head_1'}})
    gui.add(table_forces, label_model, {{caption={"Players"}, name='head_2'}})
    gui.add(table_forces, {{type="textfield", name="diplomacy_force_textfield"}})
    local actions = gui.add(table_forces, {{type="flow", name='head_4', direction="horizontal", style="slot_table_spacing_flow_style"}})
    gui.add(actions, button_model, {{caption={"Add"}, name="diplomacy_force_new_button"}})
    gui.add(table_forces, {{type="checkbox", caption={"Join"},state=true, name='diplomacy_force_checkbox'}})
    update_forces(player)
  end
end
function update_forces(player)
  local as_player = get_as_player(player)
  local table_forces = gui.get{player.gui.left, "diplomacy_main", "tab_area", "forces", "table"}
  if table_forces then
    gui.empty(table_forces,{'head_0', 'head_1', 'head_2', "diplomacy_force_textfield", 'head_4', 'diplomacy_force_checkbox'})
    local button_model = {widget={type="button", style="controls_settings_button_style"},style={minimal_width=25}}
    local button_disabled_model = gui.merge(button_model, {style={font_color={r = 0, g = 0, b = 0, a = 0.25}}})
    for _, force in pairs(game.forces) do
      gui.add(table_forces,{{type="label", caption=force.name}})
      local actions = gui.add(table_forces,{{type="flow", direction="horizontal", style="slot_table_spacing_flow_style"}})
      if as_player.force.name == force.name then
        gui.add(actions, button_disabled_model, {{caption={"Join"}}})
      else
        gui.add(actions, button_model, {{name="diplomacy_force_join_button{'"..force.name.."'}", caption={"Join"}}})
      end
      if as_player.force.name == force.name or inTable({"player","enemy","neutral"},force.name) then
        gui.add(actions, button_disabled_model, {{caption={"Merge"}}})
      else
        gui.add(actions, button_model, {{name="diplomacy_force_merge_button{'"..force.name.."'}", caption={"Merge"}}})
      end
      gui.add(actions, button_model, {{name="diplomacy_go_diplomacy{'"..force.name.."'}", caption={"Diplomacy"}}})
      local players = gui.add(table_forces, {{type="flow", direction="horizontal", style="slot_table_spacing_flow_style"}})
      for _, player2 in pairs(force.players) do
        gui.add(players, player2.connected and button_model or button_disabled_model, {{caption=player2.name, name="diplomacy_force_player_button{'"..player2.name.."'}"}})
      end
    end
  end
end

function hide_diplomacy(player)
  gui.destroy(player.gui.left,{"diplomacy_main", "tab_area", "diplomacy"})
end
function show_diplomacy(player)
  hide_diplomacy(player)
  local as_force = get_as_force(player)
  local tab_area = gui.get{player.gui.left, "diplomacy_main", "tab_area"}
  if tab_area then
    local tab_diplomacy = gui.add(tab_area, {{type="frame", name="diplomacy", caption={"Diplomacy_as", as_force.name}, direction="vertical", style="naked_frame_style"}})
    local table_diplomacy = gui.add(tab_diplomacy, {{type="table", name="table", colspan=3, style="electric_network_sections_table_style"}})
    local label_model = {widget={type="label", caption={"Player"}, style="caption_label_style"},style={minimal_width=200}}
    gui.add(table_diplomacy, label_model, {{caption={"Force"}, name="head_0"}})
    gui.add(table_diplomacy, label_model, {widget={caption={"Our_stance"}, name="head_1"},style={minimal_width=92}})
    gui.add(table_diplomacy, label_model, {widget={caption={"Their_stance"}, name="head_2"},style={minimal_width=92}})
    update_diplomacy(player)
  end
end
function update_diplomacy(player)
  local as_force = get_as_force(player)
  local table_diplomacy = gui.get{player.gui.left, "diplomacy_main", "tab_area", "diplomacy", "table"}
  if table_diplomacy then
    gui.empty(table_diplomacy, {'head_0', 'head_1', 'head_2'})
    local button_model = {widget={type="button", style="controls_settings_button_style"}, style={minimal_width=50}}
    local none_model = {widget={type="button", caption={"none"}, style="slot_button_style"}, style={minimal_width=92, maximal_width=92}}
    local ally_model = gui.merge(none_model, {{caption={"ally"}, style="green_slot_button_style"}})
    local enemy_model = gui.merge(none_model, {{caption={"enemy"}, style="not_available_slot_button_style"}})
    for _, force in pairs(game.forces) do
      gui.add(table_diplomacy, button_model, {{caption=force.name, name="diplomacy_go_diplomacy{'"..force.name.."'}"}})
      local link = true
      if force.name == as_force.name then
        gui.add(table_diplomacy, none_model)
        gui.add(table_diplomacy, none_model)
      else
        local our_model =   as_force.get_cease_fire(force.name) and ally_model or enemy_model
        local their_model = force.get_cease_fire(as_force.name) and ally_model or enemy_model
        gui.add(table_diplomacy, our_model, {{name="diplomacy_diplomacy_change_button{'"..force.name.."'}"}})
        gui.add(table_diplomacy, their_model)
      end
    end
  end
end

function on_gui_click_diplomacy_menu(event, params) -- OK
  local player = get_player(event)
  local main = gui.get{player.gui.left, "diplomacy_main"}
  if main then
    hide_menu(player)
  else
    show_menu(player)
  end
end
function on_gui_click_diplomacy_tab(event, params) -- OK
  local player = get_player(event)
  set_tab(player,params[1])
  show_menu(player)
end
function on_gui_click_diplomacy_go_settings(event, params) -- OK
  local player = get_player(event)
  set_as_player(player, params[1])
  set_tab(player, "settings")
  show_menu(player)
end
function on_gui_click_diplomacy_toggle_admin(event, params) -- OK
  local player = get_player(event)
  local as_player = params[1]
  local role = check_admin(game.get_player(as_player)) and "player" or "admin"
  remote.call("auth", "set_role", global.data.auth_tokens[player.name], as_player, role)
end
function on_gui_click_diplomacy_go_forces(event, params) -- OK
  local player = get_player(event)
  set_as_player(player, params[1])
  set_tab(player, "forces")
  show_menu(player)
end
function on_gui_click_diplomacy_go_diplomacy(event, params) -- OK
  local player = get_player(event)
  set_as_force(player, params[1])
  set_tab(player, "diplomacy")
  show_menu(player)
end
function on_gui_click_diplomacy_force_new_button(event, params) -- PERM
  local player = get_player(event)
  if not check_admin(player) then return end
  local as_player = get_as_player(player)
  local force = gui.get{player.gui.left, "diplomacy_main", "tab_area", "forces", "table", "diplomacy_force_textfield"}.text
  local join = gui.get{player.gui.left, "diplomacy_main", "tab_area", "forces", "table", "diplomacy_force_checkbox"}.state

  if force == "" then player.print({"create_force_no_name"}) return end
  if game.forces[force] then player.print({"create_force_exist"}) return end
  force = game.create_force(force)
  print_all({"create_force", force.name, player.name})
  if join then on_gui_click_diplomacy_force_join_button(event, {force.name}) end

  update_all()
end
function on_gui_click_diplomacy_force_join_button(event, params) -- PERM
  local player = get_player(event)
  if not check_admin(player) then return end
  local as_player = get_as_player(player)
  local as_force = get_as_force(player)
  local force = game.forces[params[1]]

  if force then
    if as_player.force == as_force then set_as_force(player, force) end
    as_player.force = force
    print_all({(player.name == as_player.name) and "join_force" or "join_force_as", as_player.name, force.name, player.name})
  end

  update_all()
end
function on_gui_click_diplomacy_force_merge_button(event, params) -- PERM
  local player = get_player(event)
  if not check_admin(player) then return end
  local as_player = get_as_player(player)
  local selected = game.forces[params[1]]

  if selected and selected.valid then
    print_all({"merge_force", selected.name, as_player.force.name, player.name})
    game.merge_forces(selected.name, as_player.force.name)
  end

  update_all()
end
function on_gui_click_diplomacy_diplomacy_change_button(event, params) -- PERM
  local player = get_player(event)
  if not check_admin(player) then return end
  local as_force = get_as_force(player)
  local to_force = game.forces[params[1]]

  as_force.set_cease_fire(to_force.name, not as_force.get_cease_fire(to_force.name))
  print_all({"set_diplomacy", as_force.name, as_force.get_cease_fire(to_force.name) and {"ally"} or {"enemy"}, to_force.name, player.name})

  update_all(player)
end
function on_gui_click_diplomacy_settings_player_color(event, params) -- PERM
  local player = game.players[event.player_index]
  local as_player = get_as_player(player)
  local color = params
  as_player.color = color
  update_all(player)
end
function on_gui_click_diplomacy_settings_player_color_apply(event, params) -- PERM
  local player = game.players[event.player_index]
  local as_player = get_as_player(player)
  local color = {
    r=gui.get{player.gui.left, "diplomacy_main", "tab_area", "settings", "player", "table", "red"}.text,
    g=gui.get{player.gui.left, "diplomacy_main", "tab_area", "settings", "player", "table", "green"}.text,
    b=gui.get{player.gui.left, "diplomacy_main", "tab_area", "settings", "player", "table", "blue"}.text,
    a=gui.get{player.gui.left, "diplomacy_main", "tab_area", "settings", "player", "table", "alpha"}.text
  }
  on_gui_click_diplomacy_settings_player_color(event, color)
end

function on_gui_click_diplomacy_player_authenticate(event, params) -- PERM
  local player = game.players[event.player_index]
  local password = gui.get{player.gui.left, "diplomacy_main", "tab_area", "settings", "admin", "authenticate",  "password"}.text
  global.data.auth_tokens[player.name] = remote.call("auth", "authenticate", player.name, password)
end
function on_gui_click_diplomacy_player_set_password(event, params) -- PERM
  local player = game.players[event.player_index]
  local oldpass = gui.get{player.gui.left, "diplomacy_main", "tab_area", "settings", "admin", "change_password",  "old_password"}.text
  local newpass = gui.get{player.gui.left, "diplomacy_main", "tab_area", "settings", "admin", "change_password",  "new_password"}.text
  remote.call("auth", "set_password", player.name, newpass, oldpass)
end
script.on_load(function() -- OK
  if not global.data then global.data = {} end
  if not global.data.as_player then global.data.as_player = {} end
  if not global.data.as_force then global.data.as_force = {} end
  if not global.data.tab then global.data.tab = {} end
  if not global.data.auth_tokens then global.data.auth_tokens = {} end
end)
---[[
script.on_init(function()
  global.data = {tab={},as_player={},as_force={}, auth_tokens={}}
end)
events.register(defines.events,1,function(event) -- DEV
  if not global.buffer then global.buffer = {} end
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
    if event.name == defines.events.on_gui_click then
      table.insert(global.buffer, {
        element={
          name=event.element.name
        },
        name=event.name,
        player_index=event.player_index,
        tick=event.tick,
      })
    else
      table.insert(global.buffer, event)
    end
  end
  if (#game.players > 0) and (#global.buffer > 0) then
    print_event = table.remove(global.buffer,1)
    print_event.name = events[event.name]
    --print_all(serpent.line(print_event,{comment=false,compact=true,numformat="%.2g"}))
  end
end)
--[[]]--]]
events.register(defines.events.on_player_created, 1, function(event)
  local player = game.players[event.player_index]
  show_button(player)
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
remote.add_interface("diplomacy", {unit_test = function(grp)
  local player = game.players[1]
  local event = {player_index=1}
  if not global.unit_test then global.unit_test = 0 end
  if grp > 0 then global.unit_test = grp end

  if grp == -1 or global.unit_test == 0  then print_all("print_all") end
  if grp == -1 or global.unit_test == 1  then print_all("hide_button") hide_button(player) end
  if grp == -1 or global.unit_test == 2  then print_all("show_button") show_button(player) end
  if grp == -1 or global.unit_test == 3  then print_all("hide_menu") on_gui_click_diplomacy_menu(event, params) end
  if grp == -1 or global.unit_test == 4  then print_all("show_menu") on_gui_click_diplomacy_menu(event, params) end
  show_menu(player)
  if grp == -1 or global.unit_test == 5  then print_all("update_all") update_all() end
  if grp == -1 or global.unit_test == 6  then print_all("tab > settings") on_gui_click_diplomacy_tab(event, {"settings"}) end
  if grp == -1 or global.unit_test == 7  then print_all("tab > players") on_gui_click_diplomacy_tab(event, {"players"}) end
  if grp == -1 or global.unit_test == 8  then print_all("tab > forces") on_gui_click_diplomacy_tab(event, {"forces"}) end
  if grp == -1 or global.unit_test == 9  then print_all("tab > diplomacy") on_gui_click_diplomacy_tab(event, {"diplomacy"}) end
  if grp == -1 or global.unit_test == 10 then print_all("go_settings") on_gui_click_diplomacy_go_settings(event, {player.name}) end
  if grp == -1 or global.unit_test == 11 then print_all("go_forces") on_gui_click_diplomacy_go_forces(event, {player.name}) end
  gui.get{player.gui.left, "diplomacy_main", "tab_area", "forces", "table", "diplomacy_force_textfield"}.text = "another_force"
  gui.get{player.gui.left, "diplomacy_main", "tab_area", "forces", "table", "diplomacy_force_checkbox"}.state = true
  if grp == -1 or global.unit_test == 13 then print_all("new_force;join") on_gui_click_diplomacy_force_new_button(event, {}) end
  gui.get{player.gui.left, "diplomacy_main", "tab_area", "forces", "table", "diplomacy_force_textfield"}.text = "third_force"
  gui.get{player.gui.left, "diplomacy_main", "tab_area", "forces", "table", "diplomacy_force_checkbox"}.state = false
  if grp == -1 or global.unit_test == 14 then print_all("new_force") on_gui_click_diplomacy_force_new_button(event, {}) end
  if grp == -1 or global.unit_test == 15 then print_all("join") on_gui_click_diplomacy_force_join_button(event, {"third_force"}) end
  if grp == -1 or global.unit_test == 12 then print_all("go_diplomacy") on_gui_click_diplomacy_go_diplomacy(event, {player.force.name}) end
  if grp == -1 or global.unit_test == 15 then print_all("") on_gui_click_diplomacy_force_join_button(event, {"third_force"}) end
  --~ if grp == -1 or global.unit_test == 0 then print_all("") (player) end
  --~ if grp == -1 or global.unit_test == 0 then print_all("") (player) end

  global.unit_test = global.unit_test + 1
end})
