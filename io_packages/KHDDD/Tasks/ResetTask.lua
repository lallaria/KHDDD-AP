--Wipes the decks and rebuilds movement/flowmotion stock entries from the received AP ids (/reset_movement)

local ResetTask = {}

ResetTask.Pending = nil --Comma separated AP ids queued by the client

--Movement/defense commands (0x02-0x1B) and flowmotion items (0x1C-0x21) belong in the stock once each
local _uniqueFirst = 0x02
local _uniqueLast = 0x21
local _deckNames = {"Deck 1", "Deck 2", "Deck 3"}

--Commands that overflowed past the stock keep the stock entry shape: {id, 0, masks 00/00 or 07/07, 0, count 0/1, 0, 0}
local function _readStray(addr)
  local _b = ReadArray(addr, 0x08)
  local _masks = (_b[3] == 0x00 and _b[4] == 0x00) or (_b[3] == 0x07 and _b[4] == 0x07)
  if _b[1] >= _uniqueFirst and _b[1] < 0xEC and _b[2] == 0x00 and _masks and _b[5] == 0x00 and _b[6] <= 0x01 and _b[7] == 0x00 and _b[8] == 0x00 then
    return _b
  end
  return nil
end

--Resets all six decks to the game's defaults and rebuilds unique stock entries from the received AP ids (comma separated)
function ResetTask:ResetMovement(receivedIds)
  local _start = MemoryAddresses.commandStockStart[gameVer]
  local _grid = MemoryAddresses.commandStock[gameVer] --Overflow writes are 8-byte aligned to this
  local _stockEntries = ItemHandler.StockEntries

  --Every default deck needs stock 6 (id 0x01) in slot 8; without it the template would leave decks unusable
  if ReadShort(_start+(6*0x08)) ~= 0x01 then
    ConsolePrint("Movement reset aborted: stock entry 6 is not the default action")
    return
  end

  local _expected = {}
  for _apId in string.gmatch(receivedIds or "", "%d+") do
    local _item = getItemById(_apId)
    if _item ~= nil and _item.Type == "Command" and _item.Bytes[1] >= _uniqueFirst and _item.Bytes[1] <= 0x1B then
      _expected[_item.Bytes[1]] = true
    elseif _item ~= nil and _item.Type == "Flowmotion" then
      ItemHandler:GiveFlowmotion(_item.ID, false)
      local _first = _item.ID+6
      local _last = _item.ID+6
      if _item.ID == 2661006 then --All flowmotion
        _first = 2661007
        _last = 2661011
      end
      for x=_first, _last do
        _expected[getItemById(x).Bytes[1]] = true
      end
    end
  end

  --Recover overflowed commands from the deck tails (after the 6-character name) before wiping them
  local _strays = {}
  for d=1, #EquippedCommands do
    local _deck = EquippedCommands[d][gameVer]
    local _addr = _deck+0xF4+((_grid-(_deck+0xF4)) % 0x08)
    while _addr+0x08 <= _deck+0x13E do
      local _b = _readStray(_addr)
      if _b ~= nil and _b[1] > _uniqueLast then
        table.insert(_strays, _b)
      end
      _addr = _addr+0x08
    end
  end

  --Defaults seen on untouched decks: stock 6 in slot 8, Dodge Roll (stock 7) in slot 9, Block (stock 9) in the defense slot
  local _hasDodge = ReadShort(_start+(7*0x08)) == 0x03
  local _hasBlock = ReadShort(_start+(9*0x08)) == 0x0D
  local _inDefault = {[6] = true, [7] = _hasDodge, [9] = _hasBlock}

  for d=1, #EquippedCommands do
    local _deck = EquippedCommands[d][gameVer]
    local _defenseSlot = 14
    if d > 3 then
      _defenseSlot = 15 --Riku decks
    end
    local _slots = {[8] = 6}
    if _hasDodge then _slots[9] = 7 end
    if _hasBlock then _slots[_defenseSlot] = 9 end

    for s=0, 30 do
      local _stock = _slots[s]
      if _stock ~= nil then
        WriteArray(_deck+(s*0x06), {_stock & 0xFF, _stock >> 8, 0xFF, 0xFF, 0xFF, 0x00})
      else
        WriteArray(_deck+(s*0x06), {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00})
      end
    end

    --46 category bytes at +0xBA hold the active action slot-8 (0xFF = none), as the game's new-deck init writes them;
    --byte 0 jump, 4 ground dodge, 12 defense
    local _categories = {}
    for x=1, 46 do
      _categories[x] = 0xFF
    end
    _categories[1] = 0x00
    if _hasDodge then _categories[5] = 0x01 end
    if _hasBlock then _categories[13] = _defenseSlot-8 end
    WriteArray(_deck+0xBA, _categories)

    local _name = {}
    for c in string.gmatch(_deckNames[((d-1) % 3)+1], ".") do
      table.insert(_name, string.byte(c))
      table.insert(_name, 0x00)
    end
    for x=#_name+1, 0x13E-0xE8 do
      _name[x] = 0x00
    end
    WriteArray(_deck+0xE8, _name)
  end

  --The entries the default decks point at are the copies to keep
  local _found = {}
  for i, _isDefault in pairs(_inDefault) do
    if _isDefault then
      _found[ReadShort(_start+(i*0x08))] = true
    end
  end
  local _removed = 0
  for i=0, _stockEntries-1 do
    local _addr = _start+(i*0x08)
    local _id = ReadShort(_addr)
    if not _inDefault[i] and _id >= _uniqueFirst and _id <= _uniqueLast then
      if _found[_id] then
        WriteArray(_addr, {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00})
        _removed = _removed+1
      else
        _found[_id] = true
      end
    end
  end

  local _added = 0
  for _id, _ in pairs(_expected) do
    if not _found[_id] then
      local _addr = ItemHandler:FindEmptyStockSlot()
      if _addr then
        WriteArray(_addr, {_id, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00})
        _added = _added+1
      end
    end
  end

  local _recovered = 0
  for _, _b in ipairs(_strays) do
    local _addr = ItemHandler:FindEmptyStockSlot()
    if _addr then
      WriteArray(_addr, {_b[1], 0x00, 0x00, 0x00, 0x00, _b[6], 0x00, 0x00})
      _recovered = _recovered+1
    end
  end

  --Equip masks must match the decks; flowmotion items stay 07/07 as FlowmotionItem writes them
  for i=0, _stockEntries-1 do
    local _addr = _start+(i*0x08)
    local _id = ReadShort(_addr)
    if _id ~= 0x00 then
      local _equip = 0x00
      if _inDefault[i] or (_id >= 0x1C and _id <= _uniqueLast) then
        _equip = 0x07
      end
      WriteArray(_addr+0x02, {_equip, _equip})
    end
  end

  --Overflow writes between the stock and the decks share their shape with real ability/stat values, so they are only logged
  local _addr = _start+(_stockEntries*0x08)
  _addr = _addr+((_grid-_addr) % 0x08)
  while _addr+0x08 <= EquippedCommands[1][gameVer] do
    local _b = _readStray(_addr)
    if _b ~= nil then
      ConsolePrint(string.format("Possible stray command 0x%02X at 0x%X (may be ability/stat data)", _b[1], _addr))
    end
    _addr = _addr+0x08
  end

  ConsolePrint("Decks reset; removed "..tostring(_removed).." duplicates, added "..tostring(_added).." missing, recovered "
    ..tostring(_recovered).." of "..tostring(#_strays).." commands found in deck memory")
end

--Stock/deck writes while a menu, cutscene or respawn is active desync the game's cached command lists
function ResetTask:RunPending()
  if self.Pending == nil or RoomSaveTask.PrepareLoad then
    return
  end
  if ReadByte(MemoryAddresses.enablePause[gameVer]) > 0x00 or ReadByte(MemoryAddresses.pauseType[gameVer]) > 0x00
      or ReadByte(MemoryAddresses.cutscenePauseType[gameVer]) > 0x00 then
    return
  end
  local _ids = self.Pending
  self.Pending = nil
  self:ResetMovement(_ids)
end

return ResetTask
