g_savedata = {
  mode = "prod",
  port = 0,
  save_name = nil,
  subsystems = {},
  currencies = {
    money = 0,
    research_point = 0,
  },
  bases = {},
}


addon = {
  name = "TSU Persistence",
  version = "0.0.0",
  commands = {},
  clock = 0,
  on_load = function()
    addon.register_command("?persistence", "version", nil, nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin, peer_id end, addon.print_version)
    addon.register_command("?persistence", "prod", nil, nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin end, function() g_savedata.mode = "prod" end)
    addon.register_command("?persistence", "debug", nil, nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin end, function() g_savedata.mode = "debug" end)
    addon.register_command("?persistence", "commands", nil, nil, function(full_message, peer_id, is_admin, is_auth, subject, verb) return is_admin, peer_id end, addon.print_all_commands)
    addon.register_command("?persistence", "init", nil, "[save_name] [port]", function(full_message, peer_id, is_admin, is_auth, subject, verb, save_name, port) return is_admin, save_name, port end, addon.init)
  end,
  on_create = function(is_world_create)
    if g_savedata.mode == "debug" then
      addon.print_version()
    end

    g_savedata.port = 3000

    currency_controller.create(is_world_create)
    base_controller.create(is_world_create)
  end,
  on_tick = function(tick)
    currency_controller.tick(tick, addon.clock)
    base_controller.tick(tick, addon.clock)

    addon.clock = addon.clock + 1
  end,
  init = function(save_name, port)
    if string.nil_or_empty(save_name) then return end
    if string.nil_or_empty(port) then return end

    port = tonumber(port)

    g_savedata.save_name = save_name
    g_savedata.port = port
    currency_controller.init(save_name, port)
    base_controller.init(save_name, port)
  end,
  on_custom_command = function(...)
    local args = { ... }
    local subject = args[5]
    local verb = args[6]
    local command = table.find(addon.commands, function(x) return x.subject == subject and x.verb == verb or x.shorthand == subject end)

    if command == nil then
      return
    end

    if command.shorthand == subject then
      table.move(args, 5, #args, 6)
    end

    addon.invoke_command(command, command.guard(table.unpack(args)))
  end,
  on_http_reply = function(port, request, reply)
    if port ~= g_savedata.port then return end
    if string.nil_or_empty(g_savedata.save_name) then return end

    local params = tag.deserialize(string.split(reply,","))

    if string.match(request, "^/data/tile/get") ~= nil then
      base_controller.read(params)
    elseif string.match(request, "^/data/currency/get") ~= nil then
      currency_controller.read(params)
    end
  end,
  register_command = function(subject, verb, shorthand, args, guard, execute)
    if guard == nil then
      guard = function() return true end
    end

    table.insert(addon.commands, {
      subject = subject,
      verb = verb,
      shorthand = shorthand,
      args = args,
      execute = execute,
      guard = guard,
    })
  end,
  print_all_commands = function(peer_id)
    for _, command in ipairs(addon.commands) do
      local text = string.format("%s %s", command.subject, command.verb)

      if command.args ~= nil then
        text = text .. " " .. command.args
      end

      console.log(text, peer_id)
    end
  end,
  print_version = function(peer_id)
    console.log(string.format("%s %s", addon.name, addon.version), peer_id)
  end,
  invoke_command = function(command, can_execute, ...)
    if not can_execute then return end

    command.execute(table.unpack({ ... }))
  end,
}


currency_controller = {
  create = function(is_world_create)
    g_savedata.currencies.money = server.getCurrency()
    g_savedata.currencies.research_point = server.getResearchPoints()
  end,
  tick = function(tick, clock)
    if g_savedata.save_name == nil then return end

    if clock % 60 == 0 then
      local currencies = {}
      currencies.money = server.getCurrency()
      currencies.research_point = server.getResearchPoints()

      if currencies.money ~= g_savedata.currencies.money or currencies.research_point ~= g_savedata.currencies.research_point then
        currency_controller.update(currencies)
        g_savedata.currencies = currencies
      end
    end
  end,
  join = function(p)
  end,
  init = function(save_name, port)
    console.log("Restore former currency data...")

    local params = {
      save_name = g_savedata.save_name,
    }

    server.httpGet(g_savedata.port, string.format("/data/currency/get?%s", tag.serialize(params, "&")))
  end,
  read = function(c)
    local money = tonumber(c.money)
    local research_point = tonumber(c.research_point)

    if money == nil or research_point == nil then return end

    server.setCurrency(money, research_point)
  end,
  update = function(currencies)
    local params = {
      save_name = g_savedata.save_name,
      money = currencies.money,
      research_point = currencies.research_point,
    }

    server.httpGet(g_savedata.port, string.format("/data/currency/post?%s", tag.serialize(params, "&")))
  end,
}


base_controller = {
  create = function(is_world_create)
    if is_world_create then
      for z = 128, -128, -1 do
        for x = -128, 128 do
          local transform = matrix.translation(x * 1000, 0, z * 1000)
          local t, s = tile.get(transform)

          if not s then goto continue end
          if t.cost == 0 then goto continue end

          table.insert(g_savedata.bases, t)

          ::continue::
        end
      end
    end

    console.notify(string.format("%d bases", #g_savedata.bases))
  end,
  tick = function(tick, clock)
    if g_savedata.save_name == nil then return end

    for i = 1, #g_savedata.bases do
      if i % 300 == clock % 300 then
        local update = tile.get(g_savedata.bases[i].transform)

        if base_controller.differents(update, g_savedata.bases[i]) then
          g_savedata.bases[i] = update
          base_controller.update(g_savedata.bases[i])
        end

        ::continue::
      end
    end
  end,
  join = function(p)
  end,
  init = function(save_name, port)
    console.log("Restore former tile data...")

    for k, t in ipairs(g_savedata.bases) do
      local params = {
        save_name = g_savedata.save_name,
        tile_name = t.tile,
      }

      server.httpGet(g_savedata.port, string.format("/data/tile/get?%s", tag.serialize(params, "&")))
    end
  end,
  read = function(t)
    local tile_name = t.tile_name
    local coal = tonumber(t.coal)
    local uranium = tonumber(t.uranium)
    local diesel = tonumber(t.diesel)
    local jet = tonumber(t.jet)
    local solid_propellant = tonumber(t.solid_propellant)

    if tile_name == nil or coal == nil or uranium == nil or diesel == nil or jet == nil or solid_propellant == nil then return end

    local b = table.find(g_savedata.bases, function(b) return b.tile == tile_name end)

    if b == nil then return end

    server.setTileInventory(b.transform, coal, uranium, diesel, jet, solid_propellant)
  end,
  update = function(t)
    local params = {
      save_name = g_savedata.save_name,
      tile_name = t.tile,
      coal = t.inventory.coal,
      uranium = t.inventory.uranium,
      diesel = t.inventory.diesel,
      jet = t.inventory.jet,
      solid_propellant = t.inventory.solid_propellant,
    }

    server.httpGet(g_savedata.port, string.format("/data/tile/post?%s", tag.serialize(params, "&")))
  end,
  purchased = function(new, old)
    return new.purchased and not old.purchased
  end,
  differents = function(new, old)
    local d = false
    d = d or new.inventory.coal ~= old.inventory.coal
    d = d or new.inventory.uranium ~= old.inventory.uranium
    d = d or new.inventory.diesel ~= old.inventory.diesel
    d = d or new.inventory.jet ~= old.inventory.jet
    d = d or new.inventory.solid_propellant ~= old.inventory.solid_propellant
    return d
  end,
}


money = {
  transact = function(amount, message)
    if server.getGameSettings().infinite_money then return true end

    if amount > 0 then
      amount = math.ceil(amount)
    elseif amount < 0 then
      amount = math.floor(amount)
    else
      return true
    end

    local money = server.getCurrency()
    local money_update = money + amount
    local not_type = 4
    local title = string.format("Accepted $%d.", amount)

    if amount < 0 then
      not_type = 2
      title = string.format("Paid out $%d.", math.abs(amount))
    end

    if money > 0 and money_update <= 0 then
      server.notify(-1, "Budgets fall into the red.", nil, 2)
    end

    server.setCurrency(money_update)

    if not string.nil_or_empty(message) then
      server.notify(-1, title, message, not_type)
    end

    return true
  end,
}

tile = {
  transact = function(transform, type, value)
    local coal, uranium, diesel, jet, solid_propellant = server.getTileInventory(transform)

    if type == "coal" then
      local subtotal = coal + value
      value = math.min(subtotal, 0)
      coal = math.max(subtotal, 0)
    elseif type == "uranium" then
      local subtotal = uranium + value
      value = math.min(subtotal, 0)
      uranium = math.max(subtotal, 0)
    elseif type == "diesel" then
      local subtotal = diesel + value
      value = math.min(subtotal, 0)
      diesel = math.max(subtotal, 0)
    elseif type == "jet" then
      local subtotal = jet + value
      value = math.min(subtotal, 0)
      jet = math.max(subtotal, 0)
    elseif type == "solid_propellant" then
      local subtotal = solid_propellant + value
      value = math.min(subtotal, 0)
      solid_propellant = math.max(subtotal, 0)
    end

    server.setTileInventory(transform, coal, uranium, diesel, jet, solid_propellant)

    return value
  end,
  get = function(transform)
    local t, s = server.getTile(transform)
    t.transform = transform
    t.inventory = {}
    t.tile = string.match(t.name, "([%w%._]+)$")

    if not s then return t, s end

    if t.cost > 0 then
      t.inventory.coal, t.inventory.uranium, t.inventory.diesel, t.inventory.jet, t.inventory.solid_propellant = server.getTileInventory(transform)
    end

    return t, s
  end,
}


tag = {
  serialize = function(tags, separator)
    if separator == nil then
      separator = ","
    end

    local texts = {}

    for key, value in pairs(tags) do
      local key_type = type(key)
      local value_type = type(value)

      if value_type == "table" then
        value = table.concat(value, ";")
      end

      local t = ""

      if key_type == "string" then
        t = key .. "=" .. value
      else
        t = value
      end

      table.insert(texts, t)
    end

    return table.concat(texts, separator)
  end,
  deserialize = function(tags)
    local deserialized_tags = {}

    for key, value in ipairs(tags) do
      local value, encoded_key = tag.encode(value)

      if encoded_key == nil then
        encoded_key = key
      end

      deserialized_tags[encoded_key] = value
    end

    return deserialized_tags
  end,
  encode = function(text)
    local key, value = tag.parseKeyValue(text)

    if key == nil then
      value = text
    end

    if string.find(text, ";", 1, true) ~= nil then
      value = string.split(value, ";")
    end

    return value, key
  end,
  parseKeyValue = function(text)
    return string.match(text, "^([%w_]+)=(.+)$")
  end,
  match = function(self, key, pattern)
    return string.match(self, "^" .. key .. "=" .. pattern .. "$") ~= nil
  end,
}


console = {
  log = function(text, peer_id)
    peer_id = peer_id or -1

    server.announce("[LOG]", text, peer_id)
  end,
  notify = function(text, peer_id)
    peer_id = peer_id or -1

    if g_savedata.mode == "debug" then
      server.announce("[NOTICE]", text, peer_id)
    end
  end,
  error = function(text, peer_id)
    peer_id = peer_id or -1

    server.announce("[ERROR]", text, peer_id)
  end
}


string.split        = function(s, separator)
  local t = {}

  for part in string.gmatch(s, "([^" .. separator .. "]+)") do
    table.insert(t, part)
  end

  return t
end

string.nil_or_empty = function(s)
  return s == nil or s == ""
end

table.aggregate     = function(t, result, func)
  for k, v in ipairs(t) do
    result = func(result, v)
  end

  return result
end

table.any           = function(t, test)
  local any = false

  for i = 1, #t do
    any = any or test(t[i], i)
  end

  return any
end

table.all           = function(t, test)
  local all = true

  for i = 1, #t do
    all = all and test(t[i], i)
  end

  return all
end

table.contains      = function(t, x)
  local contains = false

  for i = 1, #t do
    contains = contains or t[i] == x
  end

  return contains
end

table.find          = function(t, test)
  for k, v in ipairs(t) do
    if test(v, k) then
      return v, k
    end
  end

  -- for i = 1, #t do
  --   if test == nil or test(t[i], i) then
  --     return t[i], i
  --   end
  -- end

  return nil
end

table.find_all      = function(t, test)
  local items = {}

  for i = 1, #t do
    if test(t[i], i) then
      table.insert(items, t[i])
    end
  end

  return items
end

table.for_each      = function(t, action)
  for i = 1, #t do
    action(t[i], i)
  end
end

table.has           = function(t, x)
  for i = 1, #t do
    if t[i] == x then
      return true
    end
  end

  return false
end

table.intersect     = function(m, n)
  local r = {}

  for i = 1, #m do
    for j = 1, #n do
      if n[j] == m[i] then
        table.insert(r, m[i])
      end
    end
  end

  return r
end

table.keys          = function(t)
  local items = {}

  for k, v in pairs(t) do
    table.insert(items, k)
  end

  return items
end

table.random        = function(t)
  local keys = table.keys(t)

  if #keys == 0 then
    return nil
  end

  return t[keys[math.random(1, #keys)]]
end

table.select        = function(t, selector)
  local items = {}

  for i = 1, #t do
    local value = selector(t[i], i)

    if value ~= nil then
      table.insert(items, value)
    end
  end

  return items
end

table.where         = function(t, selector)
  local items = {}

  for i = 1, #t do
    if selector(t[i], i) then
      table.insert(items, t[i])
    end
  end

  return items
end

table.copy          = function(t)
  local u = {}

  for k, v in ipairs(t) do
    if type(v) == "table" then
      u[k] = table.copy(v)
    else
      u[k] = v
    end
  end

  return u
end

table.distinct      = function(t)
  local u = {}
  local hash = {}

  for _, v in ipairs(t) do
    if not hash[v] then
      u[#u + 1] = v
      hash[v] = true
    end
  end

  return u
end

table.join          = function(t1, t2)
  for k, v in ipairs(t2) do
    if t1[k] == nil then
      t1[k] = v
    end
  end
end

table.shuffle       = function(x)
  for i = #x, 2, -1 do
    local j = math.random(i)
    x[i], x[j] = x[j], x[i]
  end
end

table.take          = function(t, start, length)
  local u = {}

  if start == nil then start = 1 end
  if length == nil then length = #t end

  local i = 0

  while i < length do
    table.insert(u, t[start + i])
    i = i + 1
  end

  return u
end

addon.on_load()
onCreate        = addon.on_create
onTick          = addon.on_tick
onCustomCommand = addon.on_custom_command
httpReply       = addon.on_http_reply
