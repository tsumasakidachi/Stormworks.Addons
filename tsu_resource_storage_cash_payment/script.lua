g_savedata = {
  mode = "prod",
  clock = 0,
  transaction = 0,
  last_event = 0,
  storage_default = {
    coal = 100000,
    uranium = 100,
    diesel = 100000,
    jet = 100000,
    solid_propellant = 1000,
  },
  bases = {}
}

prices = {
  coal = 1.25,
  uranium = 120,
  diesel = 2.5,
  jet = 5,
  solid_propellant = 100,
}

function onCreate(is_world_create)
  if is_world_create then
    g_savedata.bases = {}

    for z = 128, -128, -1 do
      for x = -128, 128 do
        local transform = matrix.translation(x * 1000, 0, z * 1000)
        local tile, s = server.getTile(transform)

        if tile.cost > 0 then
          tile.transform = transform

          if tile.purchased then
            reset_storage(transform)
          end

          table.insert(g_savedata.bases, tile)
        end
      end
    end
  end
end

function onTick(tick)
  local types = table.keys(prices)

  for i = 1, #g_savedata.bases do
    if i % 300 == g_savedata.clock % 300 then
      local tile_update, s = server.getTile(g_savedata.bases[i].transform)

      if tile_update.purchased then
        if g_savedata.bases[i].purchased then
          local subtotal = 0
          local differs = {}
          local storage_update = {}
          storage_update.coal, storage_update.uranium, storage_update.diesel, storage_update.jet, storage_update.solid_propellant = server.getTileInventory(g_savedata.bases[i].transform)

          for _, type in ipairs(types) do
            differs[type] = storage_update[type] - g_savedata.storage_default[type]
            subtotal = subtotal + differs[type] * prices[type]
          end

          if subtotal ~= 0 then
            g_savedata.transaction = g_savedata.transaction + subtotal
            g_savedata.last_event = g_savedata.clock
          end
        end

        reset_storage(g_savedata.bases[i].transform)
        g_savedata.bases[i].purchased = tile_update.purchased
      end
    end
  end

  if g_savedata.transaction ~= 0 and g_savedata.clock > g_savedata.last_event + 300 then
    money.transact(g_savedata.transaction, "resource in storage transacted.")
    g_savedata.transaction = 0
  end

  g_savedata.clock = g_savedata.clock + 1
end

function reset_storage(transform)
  server.setTileInventory(transform, g_savedata.storage_default.coal, g_savedata.storage_default.uranium, g_savedata.storage_default.diesel, g_savedata.storage_default.jet, g_savedata.storage_default.solid_propellant)
end

money = {
  transact = function(amount, message)
    if server.getGameSettings().infinite_money then return end

    if amount > 0 then
      amount = math.ceil(amount)
    elseif amount < 0 then
      amount = math.floor(amount)
    else
      return
    end

    local money = server.getCurrency() + amount
    local not_type = 4
    local title = string.format("Accepted $%d.", amount)

    if amount < 0 then
      not_type = 2
      title = string.format("Paid out $%d.", math.abs(amount))
    end

    server.setCurrency(money)

    server.notify(-1, title, message, not_type)
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


table.any        = function(t, test)
  local any = false

  for i = 1, #t do
    any = any or test(t[i], i)
  end

  return any
end

table.all        = function(t, test)
  local all = true

  for i = 1, #t do
    all = all and test(t[i], i)
  end

  return all
end

table.contains   = function(t, x)
  local contains = false

  for i = 1, #t do
    contains = contains or t[i] == x
  end

  return contains
end

table.find_index = function(t, test)
  for k, v in ipairs(t) do
    if test(v, k) then
      return k
    end
  end

  return nil
end

table.find       = function(t, test)
  for k, v in ipairs(t) do
    if test(v, k) then
      return v
    end
  end

  -- for i = 1, #t do
  --   if test == nil or test(t[i], i) then
  --     return t[i], i
  --   end
  -- end

  return nil
end

table.find_all   = function(t, test)
  local items = {}

  for i = 1, #t do
    if test(t[i], i) then
      table.insert(items, t[i])
    end
  end

  return items
end

table.for_each   = function(t, action)
  for i = 1, #t do
    action(t[i], i)
  end
end

table.has        = function(t, x)
  for i = 1, #t do
    if t[i] == x then
      return true
    end
  end

  return false
end

table.intersect  = function(m, n)
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

table.keys       = function(t)
  local items = {}

  for k, v in pairs(t) do
    table.insert(items, k)
  end

  return items
end

table.random     = function(t)
  local keys = table.keys(t)

  if #keys == 0 then
    return nil
  end

  return t[keys[math.random(1, #keys)]]
end

table.select     = function(t, selector)
  local items = {}

  for i = 1, #t do
    local value = selector(t[i], i)

    if value ~= nil then
      table.insert(items, value)
    end
  end

  return items
end

table.where      = function(t, selector)
  local items = {}

  for i = 1, #t do
    if selector(t[i], i) then
      table.insert(items, t[i])
    end
  end

  return items
end

table.copy       = function(t)
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

table.distinct   = function(t)
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

table.join       = function(t1, t2)
  for k, v in ipairs(t2) do
    if t1[k] == nil then
      t1[k] = v
    end
  end
end

table.shuffle    = function(x)
  for i = #x, 2, -1 do
    local j = math.random(i)
    x[i], x[j] = x[j], x[i]
  end
end

table.take       = function(t, start, length)
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
