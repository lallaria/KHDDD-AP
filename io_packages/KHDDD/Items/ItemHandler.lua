local ItemHandler = {}

ItemHandler.State = {
  SpecialItems = {
    KingdomKey = 0,
    WayToTheDawn = 0,
    Filler = 0
  },
  Keyblades = {Sora={},Riku={}},

  BonusStats = {
    Sora = {Hp = 0x50, Deck = 0x04, Strength = 0x06, Magic = 0x07, Defense = 0x06},
    Riku = {Hp = 0x50, Deck = 0x04, Strength = 0x06, Magic = 0x07, Defense = 0x06}
  },
  Commands = {

  },
  MiscItems = {
    Toys = {},
    DreamPieces = {},
    Food = {}
  },
  Recipes = {},
  Abilities = {
    Shared = {}
  },
  Flowmotion = {}, --Tracks obtained flowmotion
  FlowmotionVal = 0x00, --Represents total flowmotion action value

  World = {sora={},riku={},ids={}},
  Recusant = false,
  HasCat = false,
  HasBat = false,
  HasEmblems = false,
  Emblems = 0,
  ReceivedIndex=0
}

--TODO: Lord Kyroo rewards for Sora sent to AP only after beating the world (Sora only run)

function ItemHandler:Reset()
  --self:ResetKeyblades()
  -- self:RebuildKeyblades(true)
  --self:RebuildKeyblades(false)


  ConsolePrint("Item Handler Reset")
end

function ItemHandler:Receive(type, value, cnt, isLocal)
  ConsolePrint("Received " .. type .. " with value " .. value .. ". Local: " .. tostring(isLocal))

  local _ahead = true
  local _receivedAgain = false
  if cnt then
    _ahead = cnt > lastReceivedIndex
    if cnt > self.State.ReceivedIndex then
      self.State.ReceivedIndex = cnt
    elseif cnt <= self.State.ReceivedIndex then
      _receivedAgain = true
    end
  end

  if _receivedAgain then
    return
  end

  if value == 2639999 then --Victory; Not a real item
    GoalGame()
    return
  end

  if value < 2630000 then --Trap received
    ConsolePrint("Sending drop trap")
    if _ahead then
      DropTrap()
    end
    return
  end
  
  if type == "Keyblades [Sora]" or type == "Keyblades [Riku]" then
    self:GiveKeyblade(value) --Can be given both locally and remotely fine
  elseif type == "Flowmotion" then
    self:GiveFlowmotion(value, (not isLocal and _ahead)) --Only itemize if not local
  elseif type == "Flowmotion Item" then
    if _ahead and not isLocal then
      self:FlowmotionItem(value, true)
    end
  elseif type == "Command" or type == "Consumable" then
    if _ahead and not isLocal then
      self:GiveCommand(value)
    end
  elseif type == "World" then
    --self:GiveWorld(value, true)
    self:GiveWorld(value)
  elseif type == "Stats [Sora]" or type == "Stats [Riku]" then
    self:GiveStatBonus(value)
  elseif type == "Recipe" then
    self:GiveRecipe(value, not _ahead)
  elseif type == "Key" then
    self:GiveKeyItem(value, (_ahead and not isLocal)) --Only receive emblems if not local
  elseif type == "Stat" or type == "Support" or type == "Spirit" then
    self:GiveAbility(value, true)
  else
    self:GiveMiscItem(value, type)
  end

  if cnt then
    self:SaveLatestIndex(cnt)
  end
  if _ahead then
    RoomSaveTask:StoreItem(value)
  end
end

function ItemHandler:SaveLatestIndex(cnt)
  if ReadShort(WorldFlags.destinyIslands.sora.story[gameVer]+0x07) < cnt then
    WriteShort(WorldFlags.destinyIslands.sora.story[gameVer]+0x07, cnt)
    receivedInit = true
  end
end

function ItemHandler:Request()
  SendToApClient(MessageTypes.RequestAllItems,{})
end

function ItemHandler:ReceiveSpecial(value)
  ConsolePrint('todo: receive special item')
end

function ItemHandler:FindEmptySlot(addrStart, invSize, byteSize, offset) --Returns address of first empty slot
  --local slotFound = false
  --local resAddr = addrStart+offset+(invSize*byteSize)
  local _resAddr = addrStart
  local _resFound = false
  for i=0, invSize do
    if not _resFound and ReadByte(addrStart+offset+(i*byteSize)) == 0x00 then
      --Ensure a proper gap for the whole byte size
      local _isEmpty = true
      for j=1, byteSize do
        if ReadByte(addrStart+offset+(i*byteSize)+j) ~= 0x00 then
          _isEmpty = false
        end
      end
      if _isEmpty then
        _resAddr = addrStart+offset+(i*byteSize)
        _resFound = true
      end
    end
  end

  return _resAddr
end

function ItemHandler:FindExistingSlot(addrStart, invSize, bytes, byteSize, offset)
  local _resAddr = 0x00
  local _resAddrFound = false

  for i=0, invSize do
    local _foundAddr = addrStart+(i*byteSize)+offset
    if ReadByte(_foundAddr) == bytes[1] then
      _resAddrFound = true
      for j=2, #bytes do
          if ReadByte(_foundAddr+(j-1)) ~= bytes[j] then
            _resAddrFound = false
            ConsolePrint("First byte matched but not following ones")
          end
      end
      if _resAddrFound then
        return _resAddr
      end
    end
  end
end

-- ############################################################
-- ####################  Key Items  ###########################
-- ############################################################
function ItemHandler:GiveKeyItem(value, canReceive)
  local _key = getItemById(value)
  if _key.Name == "Lucky Emblem" then
    if canReceive then
      self:GiveLuckyEmblem()
    end
    return
  end
  WriteArray(MemoryAddresses.keyItems[gameVer]+_key.Offset, _key.Bytes)
  self.State.Recusant = true --Only key item is the recusant sigil
end

function ItemHandler:GiveLuckyEmblem()
  if ReadByte(MemoryAddresses.emblems[gameVer]) == 0x00 then --Obtained item for the first time
    WriteArray(MemoryAddresses.emblems[gameVer], {0x0D, 0x08})
  end

  local _currVal = ReadByte(MemoryAddresses.emblems[gameVer]+0x02)
  _currVal = math.min(_currVal, 98)+0x01 --Don't try to receive more than we can
  self.State.Emblems = _currVal
  WriteByte(MemoryAddresses.emblems[gameVer]+0x02, _currVal)

  if self.State.Emblems >= Configs.EmblemReqs and Configs.EmblemReqs > 0 then --Send location for finding all emblems
    SendToApClient(MessageTypes.StoryChecked, {"2670300"})
  end
end


-- ############################################################
-- ######################  Worlds  ############################
-- ############################################################

-------------------WORLD DEFINITIONS---------------------
  --_world.Bytes[1] = unlocked flag address
  --_world.Bytes[2] = story flag address
  --_world.Bytes[3] = world number
  --_world.Bytes[4] = start room number
  --_world.Bytes[5] = battle level addr
  --_world.Bytes[6] = selectable address
  --_world.Bytes[7] = starting dock point address (optional)
--------------------------------------------------------- 

function ItemHandler:GiveWorld(value)
  WorldHandler:ObtainWorld(value)
  self:PlaceWorldItem(value)
end

function ItemHandler:PlaceWorldItem(value) --Places world items in designated inventory spot
  if value == 2691013 then --Check for TT2 Sora
    if WorldHandler.WorldsUnlocked.Sora[WorldHandler.Worlds.TT2] > 0 then
      WriteArray(MemoryAddresses.keyItems[gameVer]+62, {0x1F, 0x04})
      return
    end
  elseif value == 2691014 then --Check for TT2 Riku
    if WorldHandler.WorldsUnlocked.Riku[WorldHandler.Worlds.TT2] > 0 then
      WriteArray(MemoryAddresses.keyItems[gameVer]+66, {0x21, 0x04})
      return
    end
  end
  local _worldInvItem = getItemById(value+100)
  WriteArray(MemoryAddresses.keyItems[gameVer]+_worldInvItem.Offset, _worldInvItem.Bytes)
end

-- ############################################################
-- ######################  Keyblades  #########################
-- ############################################################

function ItemHandler:GiveKeyblade(value)
  local _keyAddr = MemoryAddresses.keyblades[gameVer]
  local _keyblade = getItemById(value)

  if _keyblade.Type == "Keyblades [Riku]" then
    _keyAddr = MemoryAddresses.rikuKeyblades[gameVer]
  end

  local _keybladeSlot = _keyAddr+_keyblade.Offset
  --if _keyblade.Type == "Keyblades [Riku]" then
  --  _keybladeSlot = _keyAddr-_keyblade.Offset
  --end

  WriteArray(_keybladeSlot, _keyblade.Bytes)

  if _keyblade.Type == "Keyblades [Riku]" then
    table.insert(self.State.Keyblades.Riku, value)
  else
    table.insert(self.State.Keyblades.Sora, value)
  end

end

-- ############################################################
-- ########################  Stats  ###########################
-- ############################################################
function ItemHandler:GiveStatBonus(value)
  local _stat = getItemById(value)
  if _stat.Type == "Stats [Sora]" then
    if string.find(_stat.Name, "HP") then
      ConsolePrint("Inserting HP increase")
      self.State.BonusStats.Sora.Hp = self.State.BonusStats.Sora.Hp + _stat.Bytes[1]
      --table.insert(self.State.BonusStats.Sora.Hp, _stat.Bytes[1])
    elseif string.find(_stat.Name, "Deck") then
      ConsolePrint("Inserting deck increase")
      self.State.BonusStats.Sora.Deck = self.State.BonusStats.Sora.Deck + _stat.Bytes[1]
      --table.insert(self.State.BonusStats.Sora.Deck, _stat.Bytes[1])
    elseif string.find(_stat.Name, "Strength") then
      ConsolePrint("Inserting strength increase")
      self.State.BonusStats.Sora.Strength = self.State.BonusStats.Sora.Strength + Configs.StatBonus
      --table.insert(self.State.BonusStats.Sora.Strength, Configs.StatBonus)
    elseif string.find(_stat.Name, "Magic") then
      ConsolePrint("Inserting magic increase")
      self.State.BonusStats.Sora.Magic = self.State.BonusStats.Sora.Magic + Configs.StatBonus
      --table.insert(self.State.BonusStats.Sora.Magic, Configs.StatBonus)
    elseif string.find(_stat.Name, "Defense") then
      ConsolePrint("Inserting defense increase")
      self.State.BonusStats.Sora.Defense = self.State.BonusStats.Sora.Defense + Configs.StatBonus
      --table.insert(self.State.BonusStats.Sora.Defense, Configs.StatBonus)
    end
  elseif _stat.Type == "Stats [Riku]" then
    if string.find(_stat.Name, "HP") then
      ConsolePrint("Inserting HP increase")
      self.State.BonusStats.Riku.Hp = self.State.BonusStats.Riku.Hp + _stat.Bytes[1]
      --table.insert(self.State.BonusStats.Riku.Hp, _stat.Bytes[1])
    elseif string.find(_stat.Name, "Deck") then
      ConsolePrint("Inserting deck increase")
      self.State.BonusStats.Riku.Deck = self.State.BonusStats.Riku.Deck + _stat.Bytes[1]
      --table.insert(self.State.BonusStats.Riku.Deck, _stat.Bytes[1])
    elseif string.find(_stat.Name, "Strength") then
      ConsolePrint("Inserting strength increase")
      self.State.BonusStats.Riku.Strength = self.State.BonusStats.Riku.Strength + Configs.StatBonus
      --table.insert(self.State.BonusStats.Riku.Strength, Configs.StatBonus)
    elseif string.find(_stat.Name, "Magic") then
      ConsolePrint("Inserting magic increase")
      self.State.BonusStats.Riku.Magic = self.State.BonusStats.Riku.Magic + Configs.StatBonus
      --table.insert(self.State.BonusStats.Riku.Magic, Configs.StatBonus)
    elseif string.find(_stat.Name, "Defense") then
      ConsolePrint("Inserting defense increase")
      self.State.BonusStats.Riku.Defense = self.State.BonusStats.Riku.Defense + Configs.StatBonus
      --table.insert(self.State.BonusStats.Riku.Defense, Configs.StatBonus)
    end
  end
end

function ItemHandler:RebuildStats()
  --Calculate stat amounts
  if getCharacter() == 0 then
    WriteShort(Stats.riku.maxHp[gameVer], self.State.BonusStats.Sora.Hp)
    WriteByte(Stats.sora.deckSize[gameVer], self.State.BonusStats.Sora.Deck)
    WriteByte(Stats.sora.strength[gameVer][1], self.State.BonusStats.Sora.Strength)
    WriteByte(Stats.sora.strength[gameVer][2], self.State.BonusStats.Sora.Strength)
    WriteByte(Stats.sora.magic[gameVer][1], self.State.BonusStats.Sora.Magic)
    WriteByte(Stats.sora.magic[gameVer][2], self.State.BonusStats.Sora.Magic)
    WriteByte(Stats.sora.defense[gameVer][1], self.State.BonusStats.Sora.Defense)
    WriteByte(Stats.sora.defense[gameVer][2], self.State.BonusStats.Sora.Defense)
  else
    WriteShort(Stats.riku.maxHp[gameVer], self.State.BonusStats.Riku.Hp)
    WriteByte(Stats.sora.deckSize[gameVer], self.State.BonusStats.Riku.Deck)
    WriteByte(Stats.sora.strength[gameVer][1], self.State.BonusStats.Riku.Strength)
    WriteByte(Stats.sora.strength[gameVer][2], self.State.BonusStats.Riku.Strength)
    WriteByte(Stats.sora.magic[gameVer][1], self.State.BonusStats.Riku.Magic)
    WriteByte(Stats.sora.magic[gameVer][2], self.State.BonusStats.Riku.Magic)
    WriteByte(Stats.sora.defense[gameVer][1], self.State.BonusStats.Riku.Defense)
    WriteByte(Stats.sora.defense[gameVer][2], self.State.BonusStats.Riku.Defense)
  end

end

-- ############################################################
-- ######################  Commands  ##########################
-- ############################################################
function ItemHandler:GiveCommand(value)
  local _cmdAddr = MemoryAddresses.commandStock[gameVer]
  local _cmd = getItemById(value)

  if _cmd.Type == "Consumable" then
    --Scan to see if consumable exists
    local _hasItem = self:FindExistingSlot(MemoryAddresses.consumableStart[gameVer], 500, _cmd.Bytes, 0x08, 0x00)
    if _hasItem == 0x00 or _hasItem == nil then
      local _emptySlotAddr = self:FindEmptySlot(_cmdAddr, 500, 0x08, 0x00)
      WriteByte(_emptySlotAddr, _cmd.Bytes[1])
      WriteByte(_emptySlotAddr+0x05, 0x01)
    else
      local _currStock = ReadByte(_hasItem+0x05)
      WriteByte(_hasItem+0x05, _currStock+0x01)
    end

  elseif _cmd.Type == "Command" then
    local _emptySlotAddr = self:FindEmptySlot(_cmdAddr, 1000, 0x08, 0x00)

    WriteByte(_emptySlotAddr, _cmd.Bytes[1])
  end
end

--TODO: Designate first several command stock slots to action commands prone to glitching
function ItemHandler:FixAirSlide()
  --Sometimes when loading a save, the game thinks that Air Slide is equipped when it is not
  --To prevent this from happening, make sure its equipped

  --This function is incorrectly written. If air slide is validly equipped the action becomes disabled
  --It should be disabling air slide if it is not equipped or not in inventory

  --Last slot of deck 1 will be reserved for Air Slide
  local _airSlideEquipped = self:FindExistingSlot(MemoryAddresses.commandStock[gameVer], 2000, {0x06}, 0x08, 0x00)
  if _airSlideEquipped ~= nil then
    ConsolePrint("Air Slide found; fixing...")
    --Air slide was obtained; check and see if either character have it equipped

    --Get index of air slide in inventory
    local _cmdStart = {0xA4C6D4, 0xA4BF54}
    local _airSlideIndex = (_airSlideEquipped-_cmdStart[gameVer])/0x08

    --TODO: Might need to account for command index greater than 255

    if ReadByte(_airSlideEquipped+0x02) > 0x00 then --Equipped for sora
      ConsolePrint("Fixing Air Slide for Sora")
      local _equipBits = toBits(ReadByte(_airSlideEquipped+0x02))
      if _equipBits[1] == 0x01 then --Equipped in Deck 1
        local _soraDeck1 = {0xA4DA14, 0xA4D294}
        WriteArray(_soraDeck1[gameVer], {_airSlideIndex, 0x00})
      end
      if _equipBits[2] == 0x01 then --Equipped in Deck 2
        local _soraDeck2 = {0xA4DB52, 0xA4D3D2}
        WriteArray(_soraDeck2[gameVer], {_airSlideIndex, 0x00})
      end
      if _equipBits[3] == 0x01 then --Equipped in Deck 3
        local _soraDeck3 = {0xA4DC90, 0xA4D510}
        WriteArray(_soraDeck3[gameVer], {_airSlideIndex, 0x00})
      end
    end

    if ReadByte(_airSlideEquipped+0x03) > 0x00 then --Equipped for riku
      ConsolePrint("Fixing Air Slide for Riku")
      local _equipBits = toBits(ReadByte(_airSlideEquipped+0x03))
      if _equipBits[1] == 0x01 then --Equipped in Deck 1
        local _rikuDeck1 = {0xA4DDCE, 0xA4D64E}
        WriteArray(_rikuDeck1[gameVer], {_airSlideIndex, 0x00})
      end
      if _equipBits[2] == 0x01 then --Equipped in Deck 2
        local _rikuDeck2 = {0xA4DF0C, 0xA4D78C}
        WriteArray(_rikuDeck2[gameVer], {_airSlideIndex, 0x00})
      end
      if _equipBits[3] == 0x01 then --Equipped in Deck 3
        local _rikuDeck3 = {0xA4E04A, 0xA4D8CA}
        WriteArray(_rikuDeck3[gameVer], {_airSlideIndex, 0x00})
      end
    end

  end

end

function ItemHandler:RemoveFlowmotionItems()
  ConsolePrint("Removing initial flowmotion items")
  local _soraDeck1 = {0xA4DA14, 0xA4D294} --Air slide active
  local _soraDeck2 = {0xA4DB52, 0xA4D3D2}
  local _soraDeck3 = {0xA4DC90, 0xA4D510}
  local _rikuDeck1 = {0xA4DDCE, 0xA4D64E}
  local _rikuDeck2 = {0xA4DF0C, 0xA4D78C}
  local _rikuDeck3 = {0xA4E04A, 0xA4D8CA}

  local _flowOffsetStart = 0x36
  local _flowOffset = 0x06

  local _slotEquipStart = 0x90

  if ReadByte(_soraDeck1[gameVer]+_flowOffsetStart) == 0x0A then --Flowmotion items need to be removed

    --Remove Active Equip val
    for x=1, 9 do
      WriteArray(_soraDeck1[gameVer]+_flowOffsetStart+((x-1)*_flowOffset), {0xFF, 0xFF})
      WriteArray(_soraDeck2[gameVer]+_flowOffsetStart+((x-1)*_flowOffset), {0xFF, 0xFF})
      WriteArray(_soraDeck3[gameVer]+_flowOffsetStart+((x-1)*_flowOffset), {0xFF, 0xFF})
      WriteArray(_rikuDeck1[gameVer]+_flowOffsetStart+((x-1)*_flowOffset), {0xFF, 0xFF})
      WriteArray(_rikuDeck2[gameVer]+_flowOffsetStart+((x-1)*_flowOffset), {0xFF, 0xFF})
      WriteArray(_rikuDeck3[gameVer]+_flowOffsetStart+((x-1)*_flowOffset), {0xFF, 0xFF})
    end

    local _emptySlotCont = {0xFF, 0xFF, 0xFF, 0xFF,
                            0xFF, 0xFF, 0xFF, 0xFF,
                            0xFF, 0xFF, 0xFF, 0xFF,
                            0xFF, 0xFF, 0xFF, 0xFF}

    --Remove Slot Equip val
    WriteArray(_soraDeck1[gameVer]+_slotEquipStart, _emptySlotCont)
    WriteArray(_soraDeck2[gameVer]+_slotEquipStart, _emptySlotCont)
    WriteArray(_soraDeck3[gameVer]+_slotEquipStart, _emptySlotCont)
    --Riku requires more filler
    table.insert(_emptySlotCont, 0xFF)
    table.insert(_emptySlotCont, 0xFF)
    table.insert(_emptySlotCont, 0xFF)
    table.insert(_emptySlotCont, 0xFF)
    WriteArray(_rikuDeck1[gameVer]+_slotEquipStart, _emptySlotCont)
    WriteArray(_rikuDeck2[gameVer]+_slotEquipStart, _emptySlotCont)
    WriteArray(_rikuDeck3[gameVer]+_slotEquipStart, _emptySlotCont)

    --Remove from command stock
    --When re-adding to inv, should be formatted: {ID, 0x00, 0x07, 0x07}
    --Start wipe: 0xA4C724 --Can technically start command stock from here
    --End Wipe: 0xA4C764
    local _flowStockStart = {0xA4C724, 0xA4BFA4}
    local _emptyStockCont = {}
    for x=0, 64 do
      table.insert(_emptyStockCont, 0x00)
    end
    WriteArray(_flowStockStart[gameVer], _emptyStockCont)

  end
end

function ItemHandler:FlowmotionItem(flowmotion, isRestored)
  --Get itemized flowmotion id
  local _item = flowmotion + 6

  if isRestored then
    _item = flowmotion
  end

  --Add to inventory
  if _item > 0 then
    if not isRestored then
      RoomSaveTask:StoreItem(_item)
    end

    local _cmd = getItemById(_item)
    local _emptySlotAddr = self:FindEmptySlot(MemoryAddresses.commandStock[gameVer], 1000, 0x08, 0x00)

    WriteArray(_emptySlotAddr, {_cmd.Bytes[1], 0x00, 0x07, 0x07})
    RoomSaveTask:StoreItem(flowmotion)

  elseif flowmotion == 2661006 then --All flowmotion received

    for x=2661007, 2661011 do
      local _cmd = getItemById(x)
      local _emptySlotAddr = self:FindEmptySlot(MemoryAddresses.commandStock[gameVer], 1000, 0x08, 0x00)
      WriteArray(_emptySlotAddr, {_cmd.Bytes[1], 0x00, 0x07, 0x07})
      if not isRestored then
        RoomSaveTask:StoreItem(x)
      end
    end
  end
end

-- ############################################################
-- ######################  Flowmotion  ########################
-- ############################################################

--Documentation:
--Base
--?: 0x01
--Wall Kick: 0x02 - Bit 2
--Pole Spin: 0x04 - Bit 3
--Pole Swing: 0x08 - Bit 4
--Rail Slide: 0x10 - Bit 5
--?: 0x20 - Bit 6
--Superjump: 0x40 - Bit 7
--ShockDive: 0x80 - Bit 8

--Offset +0x01
--Buzzsaw: 0x01
--Blow-Off: 0x02
--Wheel Rush: 0x04
--Sliding Dive: 0x08


function ItemHandler:GiveFlowmotion(value, itemize)
  --Add the flowmotion to the itemhandler state
  if itemize == nil then
    itemize = true
  end
  local _flow = getItemById(value)
  if itemize then
    self:FlowmotionItem(value, false) --Add it to inventory
  end
  ConsolePrint("Granting flowmotion ".._flow.Name.." inserting "..tostring(_flow.Bytes[1]))
  table.insert(self.State.Flowmotion, _flow.Bytes[1])
  --if value == 2661003 then --Need to grant shock dive with super jump
  --  table.insert(self.State.Flowmotion, 0x80)
  --end
  self.State.Flowmotion = removeDuplicates(self.State.Flowmotion)

  --Set flowmotion val
  local _newFlow = 0x80 --Init at 0x80 for instant access to shock dive
  for i=1, #self.State.Flowmotion do
    _newFlow = _newFlow + self.State.Flowmotion[i]
  end
  _newFlow = math.min(0xDE, _newFlow)
  self.State.FlowmotionVal = _newFlow

  --table.insert(self.State.Flowmotion, 0x00)
end

function ItemHandler:RebuildFlowmotion()
  if ReadByte(MemoryAddresses.actionFlags[gameVer]) ~= self.State.FlowmotionVal then --Player has too much flowmotion; rebuild
    WriteArray(MemoryAddresses.actionFlags[gameVer], {self.State.FlowmotionVal, 0xFF}) --Write 0xFF to always have access to attacks
  end
end

-- ############################################################
-- ######################  Abilities  #########################
-- ############################################################

--Byte 0: Sora Count/Equip
--Byte 1: Riku Count/Equip (Stat abilities only)
--Byte 2: Visible (not sure what values greater than 5 mean)

function ItemHandler:GiveAbility(value, addToTable)
  local _ability = getAbilityById(value)
  local _addr = MemoryAddresses.supportAbilities[gameVer]+_ability.Offset

  local _equipBytes = {0x08, 0x10, 0x20, 0x40, 0x80}

  if _ability.Type == "Stat" then --Auto-equip
    --Calculate expected value from item state
    local _amtObtained = 0
    local _equipVal = 0
    for i=1, #self.State.Abilities.Shared do
      if self.State.Abilities.Shared[i] == value then
        _amtObtained = _amtObtained+1
        if _amtObtained > #_equipBytes then
          _equipVal = _equipBytes[#_equipBytes]
        else
          _equipVal = _equipVal+_equipBytes[_amtObtained]
        end
      end
    end
    _equipVal = _equipVal + _amtObtained

    local _isSoraOrRiku = getCharacter()
    _addr = _addr+_isSoraOrRiku --Stat abilities for Riku are offset by 1
    WriteByte(_addr, _equipVal)
    WriteByte(_addr+1+math.abs(_isSoraOrRiku-1), 0x05)
  else --Toggleable ability
    if addToTable then --Only write toggleables on intial add
      local _currByte = ReadByte(_addr)
      WriteByte(_addr, _currByte+1)
      WriteByte(_addr+0x02, 0x05)
    end
  end

  --TODO: Write stat ups to sora/riku specific table
  if addToTable then
    table.insert(self.State.Abilities.Shared, value)
  end
end

function ItemHandler:RemoveAbilityFromStock()
  --Remove stat abilities added to command stock via chests
  abilityBounds = {{0xEC, 0xFF}, {0x00, 0x16}}

  for i=0, 4000, 8 do
    local _currAddr = MemoryAddresses.commandStockStart[gameVer]+i
    local _currByte = ReadByte(_currAddr)
    if _currByte >= abilityBounds[1][1] and _currByte <= abilityBounds[1][2] then
      WriteArray(_currAddr, {0x00, 0x00})
    elseif _currByte >= abilityBounds[2][1] and _currByte <= abilityBounds[2][2] then
      if ReadByte(_currAddr+1) == 0x01 then
        WriteArray(_currAddr, {0x00, 0x00})
      end
    end
  end
end

function ItemHandler:RebuildAbilities()
  --Reset status of all Stat abilities
  for i=1, #self.State.Abilities.Shared do
    local _ability = getAbilityById(self.State.Abilities.Shared[i])
    local _addr = MemoryAddresses.supportAbilities[gameVer]+_ability.Offset
    if _ability.Type == "Stat" then --Stat ups need to be re-equipped
      WriteByte(_addr, 0x00)
    end
    if _ability.Type == "Support" or _ability.Type == "Spirit" then
      local _abVal = ReadByte(_addr)

      --Check for first equip bit
      local _abBits = toBits(_abVal)
      local _bitTbl = {0x08, 0x10, 0x20, 0x40, 0x80}
      for j=1, #_bitTbl do
        if _abBits[3+j] == 1 then --Equipped; remove from this check
          _abVal = _abVal-_bitTbl[j]
        end
      end

      local _checkVal = _abVal%10 --Get number unlocked

      if countValues(self.State.Abilities.Shared, _ability.ID) > _checkVal then
        WriteByte(_addr, _abVal+0x01) --Re-enable ability
        ConsolePrint("Re-enabling ability")
      end
    end
  end

  --Re-equip all Stat abilities
  for i=1, #self.State.Abilities.Shared do
    local _ability = getAbilityById(self.State.Abilities.Shared[i])
    local _addr = MemoryAddresses.supportAbilities[gameVer]+_ability.Offset
    if _ability.Type == "Stat" then --Stat ups need to be re-equipped
      self:GiveAbility(_ability.ID, false)
    end
  end
end

-- ############################################################
-- #######################  Recipes  ##########################
-- ############################################################
function ItemHandler:GiveRecipe(value, skipCraft, skipItem)
  local _item = getItemById(value)
  local _slotNo = value-2701001 --Base address for meow wow; recipes need to go in proper slot
  local _targetSlot = MemoryAddresses.recipes[gameVer]+(_slotNo*2)
  ConsolePrint("Target Slot: "..toHex(tostring(_targetSlot)))
  if not skipItem then
    WriteArray(_targetSlot, _item.Bytes)
  end
  table.insert(self.State.Recipes, value)
  self.State.Recipes = removeDuplicates(self.State.Recipes)
  self:UpdateRecipeTotal()
  if Configs.AutoCraftSpirits and not skipCraft then
    self:CraftSpirits(value)
  end
end

function ItemHandler:RecipeToState(value)
  --This table only logs a recipe to the state table without adding to inventory or auto-crafting
  table.insert(self.State.Recipes, value)
  self:UpdateRecipeTotal()
end

function ItemHandler:RecipeToInv(value)
  --This only adds the recipe to inventory; does not add to state
  local _item = getItemById(value)
  local _slotNo = value-2701001 --Base address for meow wow; recipes need to go in proper slot
  local _targetSlot = MemoryAddresses.recipes[gameVer]+(_slotNo*2)
  ConsolePrint("Target Slot: "..toHex(tostring(_targetSlot)))
  WriteArray(_targetSlot, _item.Bytes)
  self:UpdateRecipeTotal()
  if Configs.AutoCraftSpirits then
    self:CraftSpirits(value)
  end
end

function ItemHandler:UpdateRecipeTotal()
  --Shows how many recipes the player owns
  local _recipeItemAddr = {0xA4C578, 0xA4BDF8}
  if _uniqueRecipes ~= nil then
    WriteArray(_recipeItemAddr[gameVer], {0x11, 0x08})
    WriteShort(_recipeItemAddr[gameVer]+0x02, #self.State.Recipes)
  end
end

function ItemHandler:CheckMacguffins()

  --TODO: READ KEY ITEMS FROM INDEXES

  local _hasMacguffin = false

  local _hasCat = false
  local _hasBat = false
  local _hasRecusant = false
  local _hasEmblem = false

  --Standard Goal

  --Check for required items on standard run
  if Configs.Goal == 0 then
    if ReadByte(MemoryAddresses.recipes[gameVer]+0x01) > 0x00 then --Has cat
      _hasCat = true
    end
    if ReadByte(MemoryAddresses.recipes[gameVer]+0x06) > 0x00 then --Has bat
      _hasBat = true
    end
    if ReadByte(MemoryAddresses.keyItems[gameVer]+58) > 0x00 then --Has recusant sigil
      _hasRecusant = true
    end
    if ReadByte(MemoryAddresses.emblems[gameVer]+0x02) >= Configs.EmblemReqs then
      _hasEmblem = true
    end

    if _hasCat and _hasBat and _hasRecusant and _hasEmblem and #self.State.Recipes >= Configs.RecipeReqs then
      _hasMacguffin = true

      --Unlock fast go save points
      local _fastGoSora = {0x1097913E, 0x109789BE}
      WriteArray(_fastGoSora[gameVer], {0x0A, 0x03, 0x57})

      --Unlock for Riku
      local _fastGoRiku = {0x109791AA, 0x10978A2A}
      WriteArray(_fastGoRiku[gameVer], {0x0A, 0x0D})

      --Set world status to reveal points
      local _statusS = ReadByte(MemoryAddresses.worldStatusS[gameVer]+0x02)
      if _statusS < 0x80 then
        WriteByte(MemoryAddresses.worldStatusS[gameVer]+0x02, _statusS+0x80)
      end
      if ReadByte(MemoryAddresses.worldStatusR[gameVer]+0x03) == 0x00 then
        WriteByte(MemoryAddresses.worldStatusR[gameVer]+0x03, 0x01)
        --WriteInt(MemoryAddresses.worldStatusR[gameVer]+0xCC, 0)
      end
      if ReadInt(MemoryAddresses.worldStatusR[gameVer]+0xCC) > 0 then
        WriteInt(MemoryAddresses.worldStatusR[gameVer]+0xCC, 0)
      end
    end

    self.State.HasCat = _hasCat
    self.State.HasBat = _hasBat
    self.State.Recusant = _hasRecusant
    self.State.HasEmblems = _hasEmblem
  end

  if Configs.Goal == 1 and #self.State.Recipes >= Configs.RecipeReqs and self.State.Emblems >= Configs.EmblemReqs then --Simplified goal for superbosses
    _hasMacguffin = true
  end

  if Configs.Goal == 2 and self.State.Emblems >= Configs.EmblemReqs then
    _hasMacguffin = true
  end

  return _hasMacguffin

end

function ItemHandler:CraftSpirits(value)
  math.randomseed(os.time()) --Set seed to ensure randomness

  local _baseRecipe = getItemById(value)

  local _spiritId = (value - 2701001)+1 --Get int value representing spirit

  local _spiritInv = {0xA45A70, 0xA452F0}
  local _spiritOffset = 0x100 --Add this to base address for each spirit in inventory

  --TODO: Make this account for local spirit crafting
  local _spiritAddr = _spiritInv[gameVer] + (_spiritOffset * #self.State.Recipes)

  --Write Spirit Type to inventory
  WriteInt(_spiritAddr, _spiritId)

  --Assign a random disposition & rank
  local _dispositionOffset = 0x02
  local _dispositions = {0x00, 0x10, 0x20, 0x30}
  local _rank = math.random(0, 6) --Add these amounts to dispositions to adjust rank
  WriteByte(_spiritAddr+_dispositionOffset, _dispositions[math.random(1, 4)]+_rank)

  local _levelOffset = 0x03 --Add this to spirit addr to change spirit level
  local _currHpOffset = 0x04 --This is the Hp of the spirit
  local _nameOffset = 0x06 --Spirit Name

  local _maxHpOffset = 0x30
  local _statOffset = 0x3D

  --Write Spirit Stats
  local _spiritStats = SpiritStats[_spiritId]
  local _hpBonus = math.random()+math.random(0, 3)
  local _strBonus = math.random()+math.random(0, 3)
  local _magBonus = math.random()+math.random(0, 3)
  local _defBonus = math.random()+math.random(0, 3)
  WriteByte(_spiritAddr+_maxHpOffset, math.floor(_spiritStats.hp+_hpBonus))
  WriteByte(_spiritAddr+_currHpOffset, math.floor(_spiritStats.hp+_hpBonus))
  WriteByte(_spiritAddr+_statOffset, math.floor(_spiritStats.str+_strBonus))
  WriteByte(_spiritAddr+_statOffset+1, math.floor(_spiritStats.mag+_magBonus))
  WriteByte(_spiritAddr+_statOffset+2, math.floor(_spiritStats.def+_defBonus))
  WriteByte(_spiritAddr+_statOffset+3, _spiritStats.fireRes)
  WriteByte(_spiritAddr+_statOffset+4, _spiritStats.iceRes)
  WriteByte(_spiritAddr+_statOffset+5, _spiritStats.elecRes)
  WriteByte(_spiritAddr+_statOffset+6, _spiritStats.waterRes)
  WriteByte(_spiritAddr+_statOffset+7, _spiritStats.darkRes)
  WriteByte(_spiritAddr+_statOffset+8, _spiritStats.lightRes)

  --Write level
  local _levelToUse = levels.soraLevel-1
  if getCharacter() == 1 then
    _levelToUse = levels.rikuLevel-1
  end
  if _levelToUse < 1 then
    _levelToUse = 1
  end
  WriteByte(_spiritAddr+_levelOffset, _levelToUse)

  --Write Spirit Name
  local _spiritName = string.sub(_baseRecipe.Name, 1, #_baseRecipe.Name-7)
  writeTxtToGame(_spiritAddr+_nameOffset, _spiritName, 0)

  local _affinityOffset = 0x1E
  WriteByte(_spiritAddr+_affinityOffset, 0x22) --2/2 Affinity
  --0x1F Unknown

  --Color
  local _colorOffset = 0x20
  --TODO: Get colors from AP side
  WriteInt(_spiritAddr+_colorOffset, math.random(0x00, 0xFF)) --R
  WriteInt(_spiritAddr+_colorOffset+0x01, math.random(0x00, 0xFF)) --G
  WriteInt(_spiritAddr+_colorOffset+0x02, math.random(0x00, 0xFF)) --B
  --WriteArray(_spiritAddr+_colorOffset, {0xFF, 0xFF, 0xFF}) --White Dream Eater
  local _expOffset = 0x24
  WriteInt(_spiritAddr+_expOffset, ReadInt(MemoryAddresses.soraExp[gameVer]))


end

-- ############################################################
-- ######################  Misc Items  ########################
-- ############################################################

function ItemHandler:GiveMiscItem(value, type)
  local _itemAddr = 0x00
  local _invList

  if type == "Toy" then
    _itemAddr = MemoryAddresses.toys[gameVer]
    _invList = self.State.MiscItems.Toys
  elseif type == "Food" then
    _itemAddr = MemoryAddresses.food[gameVer]
    _invList = self.State.MiscItems.Food
  elseif type == "DreamPieces" then
    _itemAddr = MemoryAddresses.dreamPieces[gameVer]
    _invList = self.State.MiscItems.DreamPieces
  end
  local _item = getItemById(value)

  local _hasItem = self:FindExistingSlot(_itemAddr, #_invList, _item.Bytes, 4, 0x00)

  if _hasItem == 0x00 then
    local emptySlotAddr = self:FindEmptySlot(_itemAddr, #_invList, 4, 0x00)
    WriteArray(emptySlotAddr, _item.Bytes) --TODO: CONSIDER EXISTING QUANTITIES
    WriteByte(emptySlotAddr+0x02, 0x01) --Writes one of this item
    table.insert(_invList, value)


    if type == "Toy" then
      self.State.MiscItems.Toys = _invList
    elseif type == "Food" then
      self.State.MiscItems.Food = _invList
    elseif type == "DreamPieces" then
      self.State.MiscItems.DreamPieces = _invList
    end

  else
    local _currAmt = ReadByte(_hasItem+0x02)
    WriteByte(_hasItem+0x02, _currAmt+0x01)
  end

end



return ItemHandler
