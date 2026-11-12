local LocationHandler = {}

---------------------------------------------------------------
---------------Prevent Invalid World Access--------------------
---------------------------------------------------------------

--Story-Relevant
--local _mtSora = {0xA41D9C, 0xA4161C}
--local _mtRiku = {0xA445B4, 0xA43E34}
--WriteArray(_mtSora[gameVer], {0xFF, 0x0F}) --Mysterious Tower Sora
--WriteArray(_mtRiku[gameVer], {0xFF, 0x0F}) --Mysterious Tower Riku


---------------------------------------------------------------
--------------------Reveal All Worlds--------------------------
---------------------------------------------------------------
function LocationHandler:ShowAllWorlds() --Reveals all worlds on the world map for nav
  local unlockedFlags = {0x02, 0x00}

  --Reveal the worlds on the map
  --Sora
  if ReadByte(WorldFlags.traverseTown.sora.unlocked[gameVer]+0x01) < 0x02 then --Don't overwrite world completion status
    WriteArray(WorldFlags.traverseTown.sora.unlocked[gameVer], unlockedFlags)
  end
  if ReadByte(WorldFlags.laCiteDesCloches.sora.unlocked[gameVer]+0x01) < 0x02 then
    WriteArray(WorldFlags.laCiteDesCloches.sora.unlocked[gameVer], unlockedFlags)
  end
  if ReadByte(WorldFlags.theGrid.sora.unlocked[gameVer]+0x01) < 0x02 then
    WriteArray(WorldFlags.theGrid.sora.unlocked[gameVer], unlockedFlags)
  end
  if ReadByte(WorldFlags.prankstersParadise.sora.unlocked[gameVer]+0x01) < 0x02 then
    WriteArray(WorldFlags.prankstersParadise.sora.unlocked[gameVer], unlockedFlags)
  end
  if ReadByte(WorldFlags.countryOfMusketeers.sora.unlocked[gameVer]+0x01) < 0x02 then
    WriteArray(WorldFlags.countryOfMusketeers.sora.unlocked[gameVer], unlockedFlags)
  end
  if ReadByte(WorldFlags.symphonyOfSorcery.sora.unlocked[gameVer]+0x01) < 0x02 then
    WriteArray(WorldFlags.symphonyOfSorcery.sora.unlocked[gameVer], unlockedFlags)
  end

  --Riku
  if ReadByte(WorldFlags.traverseTown.riku.unlocked[gameVer]+0x01) < 0x02 then
    WriteArray(WorldFlags.traverseTown.riku.unlocked[gameVer], unlockedFlags)
  end
  if ReadByte(WorldFlags.laCiteDesCloches.riku.unlocked[gameVer]+0x01) < 0x02 then
    WriteArray(WorldFlags.laCiteDesCloches.riku.unlocked[gameVer], unlockedFlags)
  end
  if ReadByte(WorldFlags.theGrid.riku.unlocked[gameVer]+0x01) < 0x02 then
    WriteArray(WorldFlags.theGrid.riku.unlocked[gameVer], unlockedFlags)
  end
  if ReadByte(WorldFlags.prankstersParadise.riku.unlocked[gameVer]+0x01) < 0x02 then
    WriteArray(WorldFlags.prankstersParadise.riku.unlocked[gameVer], unlockedFlags)
  end
  if ReadByte(WorldFlags.countryOfMusketeers.riku.unlocked[gameVer]+0x01) < 0x02 then
    WriteArray(WorldFlags.countryOfMusketeers.riku.unlocked[gameVer], unlockedFlags)
  end
  if ReadByte(WorldFlags.symphonyOfSorcery.riku.unlocked[gameVer]+0x01) < 0x02 then
    WriteArray(WorldFlags.symphonyOfSorcery.riku.unlocked[gameVer], unlockedFlags)
  end

  --Lock worlds
  --Sora
  WriteByte(WorldFlags.laCiteDesCloches.sora.selectable[gameVer], 0x00)
  WriteByte(WorldFlags.theGrid.sora.selectable[gameVer], 0x00)
  WriteByte(WorldFlags.prankstersParadise.sora.selectable[gameVer], 0x00)
  WriteByte(WorldFlags.countryOfMusketeers.sora.selectable[gameVer], 0x00)
  WriteByte(WorldFlags.symphonyOfSorcery.sora.selectable[gameVer], 0x00)
  WriteByte(WorldFlags.theWorldThatNeverWas.sora.selectable[gameVer], 0x00)

  --Riku
  WriteByte(WorldFlags.laCiteDesCloches.riku.selectable[gameVer], 0x00)
  WriteByte(WorldFlags.theGrid.riku.selectable[gameVer], 0x00)
  WriteByte(WorldFlags.prankstersParadise.riku.selectable[gameVer], 0x00)
  WriteByte(WorldFlags.countryOfMusketeers.riku.selectable[gameVer], 0x00)
  WriteByte(WorldFlags.symphonyOfSorcery.riku.selectable[gameVer], 0x00)
  WriteByte(WorldFlags.theWorldThatNeverWas.riku.selectable[gameVer], 0x00)

  ConsolePrint("Open World Configured")
end

---------------------------------------------------------------
------------------------Chests---------------------------------
---------------------------------------------------------------

chestBytes = {sora={}, riku={}}

function LocationHandler:CheckChestBits()
  --New function for tracking which chests have been opened
  if getCharacter() == 0 then --Track Sora's chests
    for i=1, #chests.sora do
      local _addr = MemoryAddresses.soraChests[gameVer]+chests.sora[i].offset
      local _chestByte = ReadByte(_addr)

      if chestBytes.sora[_addr] == nil then
        chestBytes.sora[_addr] = _chestByte
      end

      if chestBytes.sora[_addr] ~= _chestByte then
        chestBytes.sora[_addr] = _chestByte
        local _chestBits = toBits(_chestByte)

        local _validBits = {0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80}
        local _chestCheck = 0
        for j=1, #_chestBits do
          if hasValue(chests.sora[i].bitFlags, _validBits[j]) then
            _chestCheck = _chestCheck+1
            --Check if we have this found
            if _chestBits[j] == 1 and not chests.sora[i].foundChests[_chestCheck] then --Chest was found; send to AP client
              --TODO: Make sure this doesn't send repeatedly
              chests.sora[i].foundChests[_chestCheck] = true
              RoomSaveTask:StoreChest(i, j, 0)
              SendToApClient(MessageTypes.ChestChecked,{chests.sora[i].locationIDStart+(_chestCheck-1)})
            end
          end
        end
      end
    end
  else --Track Riku's chests
    for i=1, #chests.riku do
      local _addr = MemoryAddresses.rikuChests[gameVer]+chests.riku[i].offset
      local _chestByte = ReadByte(_addr)

      if chestBytes.riku[_addr] == nil then
        chestBytes.riku[_addr] = _chestByte
      end

      if chestBytes.riku[_addr] ~= _chestByte then
        chestBytes.riku[_addr] = _chestByte
        local _chestBits = toBits(_chestByte)

        local _validBits = {0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80}
        local _chestCheck = 0
        for j=1, #_chestBits do
          if hasValue(chests.riku[i].bitFlags, _validBits[j]) then
            _chestCheck = _chestCheck+1
            --Check if we have this found
            if _chestBits[j] == 1 and not chests.riku[i].foundChests[_chestCheck] then --Chest was found; send to AP client
              --TODO: Make sure this doesn't send repeatedly
              chests.riku[i].foundChests[_chestCheck] = true
              RoomSaveTask:StoreChest(i, j, 1)
              SendToApClient(MessageTypes.ChestChecked,{chests.riku[i].locationIDStart+(_chestCheck-1)})
            end
          end
        end
      end
    end
  end
end

---------------------------------------------------------------
------------------------Levels---------------------------------
---------------------------------------------------------------
function LocationHandler:CheckLevel()
  local _currChar = getCharacter()

  if ReadByte(MemoryAddresses.enablePause[gameVer]) > 0x00 then --Don't check level during transitions
    return
  end

  local _currLevel = ReadByte(levels.addr[gameVer])
  if _currChar == 0 then --Check sora
    if _currLevel > levels.soraLevel then
      levels.soraLevel = levels.soraLevel + 1
      PatchTask:WriteLevelReward(levels.soraLevel+1, 0)
      SendToApClient(MessageTypes.LevelChecked, {tostring(levels.soraLevelID+levels.soraLevel)})
      ConsolePrint("Attempting to send a check for level "..tostring(levels.soraLevel))
    end
  else --Check riku
    if _currLevel > levels.rikuLevel then
      levels.rikuLevel = levels.rikuLevel + 1
      PatchTask:WriteLevelReward(levels.rikuLevel+1, 1)
      SendToApClient(MessageTypes.LevelChecked, {tostring(levels.rikuLevelID+levels.rikuLevel)})
      ConsolePrint("Attempting to send a check for level "..tostring(levels.rikuLevel))
    end
  end
end

---------------------------------------------------------------
-------------------Story Locations-----------------------------
---------------------------------------------------------------
function LocationHandler:CheckStory()
  if ReadByte(MemoryAddresses.cutscenePauseType[gameVer]) == 0x00 and ReadByte(MemoryAddresses.enablePause[gameVer]) == 0x00 then
    return --Don't need to check story if it is not currently being incremented
  end

  local _currWorld = roomInfo[1]
  local _currChar = getCharacter()
  local _storyAddr = 0x00
  if _currWorld == 0x03 then --Traverse Town
    if _currChar == 0 then
      _storyAddr = WorldFlags.traverseTown.sora.story[gameVer]
    else
      _storyAddr = WorldFlags.traverseTown.riku.story[gameVer]
    end
  elseif _currWorld == 0x01 then --Destiny Islands
    _storyAddr = WorldFlags.destinyIslands.sora.story[gameVer]
  elseif _currWorld == 0x04 then --CotM
    if _currChar == 0 then
      _storyAddr = WorldFlags.countryOfMusketeers.sora.story[gameVer]
    else
      _storyAddr = WorldFlags.countryOfMusketeers.riku.story[gameVer]
    end
  elseif _currWorld == 0x05 then --SoS
    if _currChar == 0 then
      _storyAddr = WorldFlags.symphonyOfSorcery.sora.story[gameVer]
    else
      _storyAddr = WorldFlags.symphonyOfSorcery.riku.story[gameVer]
    end
  elseif _currWorld == 0x06 then --PP
    if _currChar == 0 then
      _storyAddr = WorldFlags.prankstersParadise.sora.story[gameVer]
    else
      _storyAddr = WorldFlags.prankstersParadise.riku.story[gameVer]
    end
  elseif _currWorld == 0x08 then --LCdC
    if _currChar == 0 then
      _storyAddr = WorldFlags.laCiteDesCloches.sora.story[gameVer]
    else
      _storyAddr = WorldFlags.laCiteDesCloches.riku.story[gameVer]
    end
  elseif _currWorld == 0x09 then --TG
    if _currChar == 0 then
      _storyAddr = WorldFlags.theGrid.sora.story[gameVer]
    else
      _storyAddr = WorldFlags.theGrid.riku.story[gameVer]
    end
  elseif _currWorld == 0x0A then --TWTNW
    if _currChar == 0 then
      _storyAddr = WorldFlags.theWorldThatNeverWas.sora.story[gameVer]
    else
      _storyAddr = WorldFlags.theWorldThatNeverWas.riku.story[gameVer]
    end
  elseif _currWorld == 0x02 then --Check for AVN beaten
    if _currChar == 1 then
      local _avnCheck = {0xA445B4, 0xA43E34}
      if ReadByte(_avnCheck[gameVer]+0x02) >= 0x07 then
        for i=1, #worldEvents do
          if worldEvents[i].ID == 2670295 then --AVN location ID
            if not worldEvents[i].sent then
              SendToApClient(MessageTypes.StoryChecked, {worldEvents[i].ID})
              worldEvents[i].sent = true
            end
          end
        end
      end
      return
    end
  end

  local _storiesFound = {}
  for i=1, #worldEvents do
    if worldEvents[i].worldNo == _currWorld and worldEvents[i].char == _currChar and not worldEvents[i].sent then
      if ReadByte(_storyAddr+(worldEvents[i].LookAt-0x01)) >= worldEvents[i].StoryBit[worldEvents[i].LookAt] then
        if worldEvents[i].ID == 2670206 or worldEvents[i].ID == 2670207 or worldEvents[i].ID == 2670248 then
          if ReadByte(MemoryAddresses.room[gameVer]) ~= 0x02 and ReadByte(WorldFlags.traverseTown.sora.story[gameVer]+0x02) < 0x03 then --Prevent command menu fix from erroneously sending this out
            return
          end
        end
        if worldEvents[i].ID == 2670249 and ReadByte(WorldFlags.traverseTown.riku.story[gameVer]+0x01) == 0x1F and rikuSpiritFix == 1 then --Do not send out Komory Bat check prematurely
          return
        end
        table.insert(_storiesFound, tostring(worldEvents[i].ID))
        worldEvents[i].sent = true --Prevents this story point from being checked repeatedly
      end
    end
  end

  if #_storiesFound > 0 then
    SendToApClient(MessageTypes.StoryChecked, _storiesFound)
  end

end

---------------------------------------------------------------
-------------------Lord Kyroo----------------------------------
---------------------------------------------------------------
local _kyrooDefeated = false
local _kyrooLCDC = false
local _kyrooPP = false
local _kyrooSOS = false
allowKyroo = true --If false, dont retrigger the kyroo fight
function LocationHandler:LordKyroo()
  --Appears in LCDC Nave [Riku], PP Promontory [Sora], and SOS Moonlight Wood [Riku]

  --If solo seed and all locations for that character have been visited; force trigger the battle
  if getCharacter() == 0 then
    if Configs.Character == 1 and roomInfo[1] == 0x06 then
      if ReadByte(WorldFlags.prankstersParadise.sora.story[gameVer]) == 0x11 then --World cleared; check kyroo now
        --if ReadByte(WorldFlags.prankstersParadise.sora.story[gameVer]+0x03) == 0x47 then --Lost to Kyroo
        if not _kyrooDefeated then  
          --Start fight in promontory
          if roomInfo[2] == 0x04 and allowKyroo then
            WriteByte(MemoryAddresses.map[gameVer], 0x39)
            WriteByte(MemoryAddresses.btl[gameVer], 0x39)
            WriteByte(MemoryAddresses.evt[gameVer], 0x39)
            allowKyroo = false
          end
        end
      end
    end
  end

  if getCharacter() == 1 then
    if Configs.Character == 2 then
      if ReadByte(WorldFlags.laCiteDesCloches.riku.story[gameVer]) == 0x11 and ReadByte(WorldFlags.symphonyOfSorcery.riku.story[gameVer]) == 0x11 then
        --World Cleared; See if Lord Kyroo needs to be rematched
        if roomInfo[1] == 0x08 and roomInfo[2] == 0x03 and allowKyroo then -- 0x03 then
          --Start Nave Battle
          WriteByte(MemoryAddresses.map[gameVer], 0x3D)
          WriteByte(MemoryAddresses.btl[gameVer], 0x3D)
          WriteByte(MemoryAddresses.evt[gameVer], 0x3D)
          allowKyroo = false
        elseif roomInfo[1] == 0x05 and roomInfo[2] == 0x06 and allowKyroo then
          --Start Moonlight Wood Battle
          WriteByte(MemoryAddresses.map[gameVer], 0x37)
          WriteByte(MemoryAddresses.btl[gameVer], 0x37)
          WriteByte(MemoryAddresses.evt[gameVer], 0x37)
          allowKyroo = false
        end
      end
    end
  end

  if not _kyrooDefeated then
    --TODO: Do world check before doing the bit functions

    --Send the check
    local _foughtPP = toBits(ReadByte(WorldFlags.prankstersParadise.sora.story[gameVer]+0x03))
    local _wonPP = toBits(ReadByte(WorldFlags.prankstersParadise.sora.story[gameVer]+0x04))
    local _foughtLCDC = toBits(ReadByte(WorldFlags.laCiteDesCloches.riku.story[gameVer]+0x02))
    local _foughtSOS = toBits(ReadByte(WorldFlags.symphonyOfSorcery.riku.story[gameVer]+0x02))

    if Configs.Character == 0 then
      if _wonPP[1] == 1 or _foughtLCDC[5] == 1 or _foughtSOS[5] == 1 then
        SendToApClient(MessageTypes.StoryChecked, {"2650652"})
        SendToApClient(MessageTypes.StoryChecked, {"2650651"})
        SendToApClient(MessageTypes.StoryChecked, {"2650650"})
        SendToApClient(MessageTypes.StoryChecked, {"2650649"})
        _kyrooDefeated = true
      end
    elseif Configs.Character == 1 then
      if _wonPP[5] == 1 then
        SendToApClient(MessageTypes.StoryChecked, {"2650652"})
        SendToApClient(MessageTypes.StoryChecked, {"2650650"})
        _kyrooDefeated = true
      end
    elseif Configs.Character == 2 then
      if _foughtLCDC[5] == 1 or _foughtSOS[5] == 1 then
        SendToApClient(MessageTypes.StoryChecked, {"2650652"})
        SendToApClient(MessageTypes.StoryChecked, {"2650651"})
        SendToApClient(MessageTypes.StoryChecked, {"2650649"})
        _kyrooDefeated = true
      end
    end

    --Check if he was fought in these locations
    if not _kyrooPP and Configs.Character < 2 then
      if _foughtPP[8] == 1 then
        SendToApClient(MessageTypes.StoryChecked, {"2650650"})
        _kyrooPP = true
      end
    end

    if not _kyrooLCDC and (Configs.Character == 0 or Configs.Character == 2) then
      if _foughtLCDC[4] == 1 then
        SendToApClient(MessageTypes.StoryChecked, {"2650649"})
        _kyrooLCDC = true
      end
    end
    if not _kyrooSOS and (Configs.Character == 0 or Configs.Character == 2) then
      if _foughtSOS[4] == 1 then
        SendToApClient(MessageTypes.StoryChecked, {"2650651"})
        _kyrooSOS = true
      end
    end
  end    
end

---------------------------------------------------------------
-------------------Secret Portals------------------------------
---------------------------------------------------------------
LocationHandler.inAPortal = false
LocationHandler.portalsWon = 0
function LocationHandler:CheckPortal()
  local _portalsWonAddr = {0xA51940, 0xA511C0}

  local _currChar = getCharacter()
  local _world = roomInfo[1]
  local _room = roomInfo[2]
  local _evt = roomInfo[3]
  --local _worldCheck = {}
  _worldCheck = ""

  --Check which world to look at
  if _world == 0x03 then
    --_worldCheck = portalDigits.traverseTown
    _worldCheck = "traverseTown"
  elseif _world == 0x04 then
    --_worldCheck = portalDigits.countryOfMusketeers
    _worldCheck = "countryOfMusketeers"
  elseif _world == 0x05 then
    --_worldCheck = portalDigits.symphonyOfSorcery
    _worldCheck = "symphonyOfSorcery"
  elseif _world == 0x06 then
    --_worldCheck = portalDigits.prankstersParadise
    _worldCheck = "prankstersParadise"
  elseif _world == 0x08 then
    --_worldCheck = portalDigits.laCiteDesCloches
    _worldCheck = "laCiteDesCloches"
  elseif _world == 0x09 then
    --_worldCheck = portalDigits.theGrid
    _worldCheck = "theGrid"
  else --Invalid world
    return
  end

  --Determine which portal details to look at based on character
  if _currChar == 0 then
    --_portalDetails = _worldCheck.sora
    _portalChar = "sora"
  else
    if _world == 0x05 then
      return --Riku has no secret portal in SoS
    end
    _portalChar = "riku"
    --_portalDetails = _worldCheck.riku
  end

  if not self.inAPortal then --Player is not yet in a secret portal fight
    --if _room == _portalDetails.bossRoom and _evt == _portalDetails.evt then --Portal fight is being done
    if _room == portalDigits[_worldCheck][_portalChar].bossRoom and _evt == portalDigits[_worldCheck][_portalChar].evt then
      self.inAPortal = true

      --Apply stock world battle level
      WorldHandler:ApplyStockBattleLevels()


      self.portalsWon = ReadByte(_portalsWonAddr[gameVer])
    end
  else
    --Check for fail condition

    --if _evt ~= _portalDetails.evt then --Fight exited
    if _evt ~= portalDigits[_worldCheck][_portalChar].evt then
      WorldHandler:ApplyScaling() --Restore to mod-specific scalings
      if ReadByte(_portalsWonAddr[gameVer]) > self.portalsWon then --Player won the fight
        ConsolePrint("Portal fight won")
        --SendToApClient(MessageTypes.PortalChecked, {tostring(_portalDetails.portalId)})
        SendToApClient(MessageTypes.PortalChecked, {tostring(portalDigits[_worldCheck][_portalChar].portalId)})

        --Write Portal Fight victory status to the story progression
        --WriteByte(_portalDetails.saveAddr, 0x01)
        WriteByte(portalDigits[_worldCheck][_portalChar].saveAddr, 0x01)

        --Recheck secret portals (for granting access to julius)
        setSecretPortals()

        self.inAPortal = false
      else --Player did not win the fight
        self.inAPortal = false
        ConsolePrint("Portal fight failed")
      end
    end
  end
end

---------------------------------------------------------------
-------------------Julius Defeated-----------------------------
---------------------------------------------------------------
LocationHandler.superbossesDefeated = false
function LocationHandler:JuliusDefeated()
  --Check if all superbosses location should be sent
  local _allBossesDefeated = false

  local _soraDefeated = false
  local _rikuDefeated = false
  if ReadByte(WorldFlags.traverseTown.sora.story[gameVer]+0x05) >= 0x04 then
    _soraDefeated = true
  end
  if ReadByte(WorldFlags.traverseTown.riku.story[gameVer]+0x04) >= 0x7F then
    _rikuDefeated = true
  end

  if Configs.Character == 1 and _soraDefeated then
    _allBossesDefeated = true
  elseif Configs.Character == 2 and _rikuDefeated then
    _allBossesDefeated = true
  elseif Configs.Character == 0 and _soraDefeated and _rikuDefeated then
    _allBossesDefeated = true
  end

  if _allBossesDefeated and not self.superbossesDefeated then --Send the message that all superbosses have been defeated
    SendToApClient(MessageTypes.StoryChecked, {2670294})
    self.superbossesDefeated = true
  end
  
end

return LocationHandler