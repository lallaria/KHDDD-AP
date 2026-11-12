--Handles open-world related functions in the game

local WorldHandler = {}

--Tracks what worlds have been unlocked,
--Set number to the order the world was unlocked in for scaling

--TT2 Status Start: FD FF FF FF

--tt, tt2, lcdc, tg, pp, cotm, sos, twtnw
WorldHandler.WorldsUnlocked = {
	Sora={0, 0, 0, 0, 0, 0, 0, 0}, 
	Riku={0, 0, 0, 0, 0, 0, 0, 0}
}

WorldHandler.WorldIds = {
	Sora = {2691013, 2691013, 2691001, 2691002, 2691003, 2691004, 2691005, 2691006},
	Riku = {2691014, 2691014, 2691007, 2691008, 2691009, 2691010, 2691011, 2691012}
}

WorldHandler.Worlds = {
	TT = 1, TT2 = 2, LCDC = 3, TG = 4, PP = 5, COTM = 6, SOS = 7, TWTNW = 8
}

WorldHandler.BattleLevels = {0x03, 0x08, 0x0E, 0x12, 0x14, 0x1A, 0x22, 0x26}


--Can force disable world save bytes to bring up visit prompt
WorldHandler.Saves = { --{StatusOffset, Bit}
	Sora = {
					TT={{0x00, 0x01}, {0x00, 0x02}, {0x01, 0x04}}, 
					LCDC={{0x00, 0x04}, {0x00, 0x08}, {0x01, 0x08}, {0x01, 0x10}},
					TG={{0x00, 0x10}, {0x00, 0x20}, {0x00, 0x40}, {0x00, 0x80}},
					PP={{0x01, 0x20}, {0x01, 0x80}, {0x02, 0x01}},
					CotM={{0x01, 0x01}, {0x02, 0x02}, {0x02, 0x04}, {0x02, 0x10}},
					SoS={{0x01, 0x02}, {0x02, 0x20}},
					TWTNW={{0x02, 0x40}, {0x02, 0x80}}
				},
	Riku = {
		TT = {{0x00, 0x01}, {0x00, 0x02}, {0x01, 0x04}},
		LCDC = {{0x00, 0x04}, {0x00, 0x08}, {0x01, 0x08}},
		TG = {{0x00, 0x10}, {0x00, 0x20}, {0x00, 0x40}, {0x00, 0x80}, {0x02, 0x01}},
		PP = {{0x01, 0x20}, {0x01, 0x40}, {0x01, 0x80}},
		CotM = {{0x01, 0x01}, {0x02, 0x02}},
		SoS = {{0x01, 0x02}, {0x02, 0x04}, {0x02, 0x08}},
		TWTNW = {{0x02, 0x20}, {0x02, 0x40}, {0x02, 0x80}, {0x03, 0x01}}
	}
}

WorldHandler.StatusOffsets = {
  Sora = {
    TT = 0x64,
    PP = 0xB4,
    LCDC = 0xB8,
    TG = 0xAC,
    CotM = 0x94
  },
  Riku = {
    LCDC = 0xC4,
    TG = 0xBC,
    SoS = 0xA4,
    TWTNW = 0xCC
  }
}

function WorldHandler:MapLoaded()
	--Run certain functions when the world map is loaded
	ConsolePrint("Map Loaded")
	self:CheckWorlds()
	self:CheckTT2()
	self:UnlockSaves()
	self:ApplyScaling()
	self:FixMenu()
end

function WorldHandler:ObtainWorld(world)
	--Set world value in unlock table to sum of obtained world
	ConsolePrint("Obtained a world")
	--Calculate new world index
	local _soraIndex = 0
	local _rikuIndex = 0
	for x=1, #self.WorldsUnlocked.Sora do
		if self.WorldsUnlocked.Sora[x] >= _soraIndex then
			_soraIndex = self.WorldsUnlocked.Sora[x] + 1
		end
	end
	for x=1, #self.WorldsUnlocked.Riku do
		if self.WorldsUnlocked.Riku[x] >= _rikuIndex then
			_rikuIndex = self.WorldsUnlocked.Riku[x] + 1
		end
	end

	for x=1, #self.WorldIds.Sora do
		if self.WorldIds.Sora[x] == world then --World was just obtained
			if x == self.Worlds.TT or x == self.Worlds.TT2 then --TT2 needs special unlock check
				if self.WorldsUnlocked.Sora[self.Worlds.TT] > 0 then --Need to unlock TT2 instead
					self.WorldsUnlocked.Sora[self.Worlds.TT2] = _soraIndex
				else --Set TT1
					self.WorldsUnlocked.Sora[self.Worlds.TT] = _soraIndex
				end
			else
				self.WorldsUnlocked.Sora[x] = _soraIndex
			end
			return
		end
	end
	for x=1, #self.WorldIds.Riku do
		if self.WorldIds.Riku[x] == world then --World was just obtained
			if x == self.Worlds.TT or x == self.Worlds.TT2 then --TT2 needs special unlock check
				if self.WorldsUnlocked.Riku[self.Worlds.TT] > 0 then --Need to unlock TT2 instead
					self.WorldsUnlocked.Riku[self.Worlds.TT2] = _rikuIndex
				else
					self.WorldsUnlocked.Riku[self.Worlds.TT] = _rikuIndex
				end
			else
				self.WorldsUnlocked.Riku[x] = _rikuIndex
			end
			return
		end
	end

	if ReadByte(MemoryAddresses.world[gameVer]) == 0x0B then
		self:MapLoaded()
	end
end

-------------------WORLD DEFINITIONS---------------------
  --_world.Bytes[1] = unlocked flag address
  --_world.Bytes[2] = story flag address
  --_world.Bytes[3] = world number
  --_world.Bytes[4] = start room number
  --_world.Bytes[5] = battle level addr
  --_world.Bytes[6] = selectable address
  --_world.Bytes[7] = starting dock point address (optional)
--------------------------------------------------------- 

function WorldHandler:CheckWorlds()
	if activeCharacter == 0 then
		--Verify Sora World Access
		for x=1, #self.WorldsUnlocked.Sora do
			if self.WorldsUnlocked.Sora[x] > 0 then
				--ConsolePrint("Found Sora World")
				self:UnlockWorld(self.WorldIds.Sora[x])
			else
				if x ~= self.Worlds.TT2 then
					self:LockWorld(self.WorldIds.Sora[x])
				end
			end
		end

	else
		--Verify Riku World Access
		for x=1, #self.WorldsUnlocked.Riku do
			if self.WorldsUnlocked.Riku[x] > 0 then
				--ConsolePrint("Found Riku World")
				self:UnlockWorld(self.WorldIds.Riku[x])
			else
				if x ~= self.Worlds.TT2 then
					self:LockWorld(self.WorldIds.Riku[x])
				end
			end
		end
	end
end

function WorldHandler:LockWorld(worldId)
	local _world = getItemById(worldId)
	local _unlocked = _world.Bytes[1]
	local _selectable = _world.Bytes[6]

	WriteByte(_unlocked+0x01, 0x00) --Get rid of any world map indicator for this world
	WriteArray(_selectable, {0x00, 0x00}) --Prevents the world from being selectable
end

function WorldHandler:UnlockWorld(worldId)
	--Extract world info
	local _world = getItemById(worldId)
	local _unlocked = _world.Bytes[1]
	local _no = _world.Bytes[3]
	local _startRoom = _world.Bytes[4]
	local _selectable = _world.Bytes[6]

	--Show that progress can be made in the world
	if ReadByte(_unlocked+0x01) == 0x00 then
		WriteByte(_unlocked+0x01, 0x01)
	end
	if ReadByte(_unlocked) ~= 0x02 then --For twtnw
		WriteByte(_unlocked, 0x02)
	end

	--Make the world selectable
	WriteArray(_selectable, {_no, _startRoom})
end

function WorldHandler:CheckTT2() --Check for each character's respective TT2 access
	if getCharacter() == 0 then --Grant access to Sora TT2 if needed
		local _soraTT2Val = ReadByte(WorldFlags.traverseTown.sora.story[gameVer]+0x03)
		if self.WorldsUnlocked.Sora[self.Worlds.TT2] > 0 and _soraTT2Val ~= 0x72 then
			if ReadByte(WorldFlags.traverseTown.sora.story[gameVer]) ~= 0x31 and _soraTT2Val >= 0x11 and ReadByte(WorldFlags.traverseTown.sora.story[gameVer]+0x04) == 0x00 then --Player has not beaten tt2
				WriteByte(WorldFlags.traverseTown.sora.story[gameVer]+0x03, 0x72)
				--Reset status as well
				--WriteInt(MemoryAddresses.worldStatusS[gameVer]+self.StatusOffsets.Sora.TT, 0xFFFFFFFD)
			end
		elseif self.WorldsUnlocked.Sora[self.Worlds.TT2] == 0 and _soraTT2Val >= 0x40 then
			--Get rid of premature TT2 unlock
      	WriteByte(WorldFlags.traverseTown.sora.story[gameVer]+0x03, _soraTT2Val-0x40)
      --WriteInt(MemoryAddresses.worldStatusS[gameVer]+self.StatusOffsets.Sora.TT, 0)
		end
	else --Grant Riku access to TT2 if needed
		local _rikuTT2Val = ReadByte(WorldFlags.traverseTown.riku.story[gameVer]+0x03)
		if self.WorldsUnlocked.Riku[self.Worlds.TT2] > 0 and _rikuTT2Val == 0x00 or _rikuTT2Val == 0x03 then --0x03 check fixes story break
			if ReadByte(WorldFlags.traverseTown.riku.story[gameVer]+0x02) >= 0x7F then --TT1 cleared
				WriteByte(WorldFlags.traverseTown.riku.story[gameVer]+0x03, 0x01)
			end
		elseif self.WorldsUnlocked.Riku[self.Worlds.TT2] == 0 or ReadByte(WorldFlags.traverseTown.riku.story[gameVer]+0x02) < 0x7F then
			if _rikuTT2Val ~= 0x00 then --Remove premature unlock
				WriteByte(WorldFlags.traverseTown.riku.story[gameVer]+0x03, 0x00)
			end
		end
	end
end

function WorldHandler:UnlockSaves()
	--Unlocks save points for each world
	local _currChar = getCharacter()

	local _bits = {0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80}

	local _worldSet = {}

	local _statusUsed = 0x00

	local _storyProg = {}

	local _tt1Cleared = false

	if _currChar == 0 then --Sora
		_worldSet = WorldHandler.Saves.Sora
		table.insert(_storyProg, ReadByte(WorldFlags.traverseTown.sora.story[gameVer]+0x03)) --Needs to be higher than 0x02
		table.insert(_storyProg, ReadByte(WorldFlags.laCiteDesCloches.sora.story[gameVer]))
		table.insert(_storyProg, ReadByte(WorldFlags.theGrid.sora.story[gameVer]))
		table.insert(_storyProg, ReadByte(WorldFlags.prankstersParadise.sora.story[gameVer]))
		table.insert(_storyProg, ReadByte(WorldFlags.countryOfMusketeers.sora.story[gameVer]))
		table.insert(_storyProg, ReadByte(WorldFlags.symphonyOfSorcery.sora.story[gameVer]))

		if _storyProg[1] >= 0x02 then
			_tt1Cleared = true
		end

		_statusUsed = MemoryAddresses.worldStatusS[gameVer]
	else
		_worldSet = WorldHandler.Saves.Riku
		table.insert(_storyProg, ReadByte(WorldFlags.traverseTown.riku.story[gameVer]+0x02)) --Needs to be higher than 0x1F
		table.insert(_storyProg, ReadByte(WorldFlags.laCiteDesCloches.riku.story[gameVer]))
		table.insert(_storyProg, ReadByte(WorldFlags.theGrid.riku.story[gameVer]))
		table.insert(_storyProg, ReadByte(WorldFlags.prankstersParadise.riku.story[gameVer]))
		table.insert(_storyProg, ReadByte(WorldFlags.countryOfMusketeers.riku.story[gameVer]))
		table.insert(_storyProg, ReadByte(WorldFlags.symphonyOfSorcery.riku.story[gameVer]))

		if _storyProg[1] >= 0x1F then
			_tt1Cleared = true
		end
		_statusUsed = MemoryAddresses.worldStatusR[gameVer]
	end

	local _savesToUnlock = {}

	--Go through each world
	if _tt1Cleared then
		table.insert(_savesToUnlock, _worldSet.TT)
	end
	if _storyProg[2] >= 0x11 then
		table.insert(_savesToUnlock, _worldSet.LCDC)
	end
	if _storyProg[3] >= 0x11 then
		table.insert(_savesToUnlock, _worldSet.TG)
	end
	if _storyProg[4] >= 0x11 then
		table.insert(_savesToUnlock, _worldSet.PP)
	end
	if _storyProg[5] >= 0x11 then
		table.insert(_savesToUnlock, _worldSet.CotM)
	end
	if _storyProg[6] >= 0x11 then
		table.insert(_savesToUnlock, _worldSet.SoS)
	end

	--Unlock each save

	--Iterate through saves we intend to unlock
	for x=1, #_savesToUnlock do
		local _tbl = _savesToUnlock[x]
		for y=1, #_tbl do
			local _saveProg = _tbl[y]
			local _offset = _saveProg[1]
			local _val = _saveProg[2]
			local _bitIndex = findValue(_bits, _val)

			local _saveVal = ReadByte(_statusUsed+_offset)
			local _saveBits = toBits(_saveVal)

			if _saveBits[_bitIndex] == 0 or _saveBits[_bitIndex] == nil then
				WriteByte(_statusUsed+_offset, _saveVal+_val)
			end
		end

	end

end

function WorldHandler:ApplyStockBattleLevels()
	local _worldBattleLvls = {
			0x00,
			0x00,
			WorldFlags.traverseTown.sora.battle[gameVer],
			WorldFlags.countryOfMusketeers.sora.battle[gameVer],
			WorldFlags.symphonyOfSorcery.sora.battle[gameVer],
			WorldFlags.prankstersParadise.sora.battle[gameVer],
			0x00,
			WorldFlags.laCiteDesCloches.sora.battle[gameVer],
			WorldFlags.theGrid.sora.battle[gameVer]
		}

		if getCharacter() == 1 then --Need riku levels instead
			_worldBattleLvls = {
			0x00,
			0x00,
			WorldFlags.traverseTown.riku.battle[gameVer],
			WorldFlags.countryOfMusketeers.riku.battle[gameVer],
			WorldFlags.symphonyOfSorcery.riku.battle[gameVer],
			WorldFlags.prankstersParadise.riku.battle[gameVer],
			0x00,
			WorldFlags.laCiteDesCloches.riku.battle[gameVer],
			WorldFlags.theGrid.riku.battle[gameVer]
		}
		end

		local _stockLevels = {0x00, 0x00, 0x14, 0x1A, 0x22, 0x12, 0x00, 0x08, 0x0E}

		local _world = ReadByte(MemoryAddresses.world[gameVer])
		if _world > 0x00 and _world < 0x0A then
			local _lvlToApply = _stockLevels[_world]
			WriteByte(_worldBattleLvls[_world], _lvlToApply)
			ConsolePrint("Updating to stock battle level")
		end
end

function WorldHandler:ApplyScaling()
	local _hasTT2 = false
	local _char = getCharacter()

	if _char == 0 then --Apply Sora's scalings
		local _worldBattleLvls = {
			WorldFlags.traverseTown.sora.battle[gameVer],
			WorldFlags.laCiteDesCloches.sora.battle[gameVer],
			WorldFlags.theGrid.sora.battle[gameVer],
			WorldFlags.prankstersParadise.sora.battle[gameVer],
			WorldFlags.countryOfMusketeers.sora.battle[gameVer],
			WorldFlags.symphonyOfSorcery.sora.battle[gameVer]
		}

		for x=1, #WorldHandler.WorldsUnlocked.Sora do --In case a dupe is received; dont leave bounds
			if WorldHandler.WorldsUnlocked.Sora[x] > #WorldHandler.BattleLevels then
				WorldHandler.WorldsUnlocked.Sora[x] = #WorldHandler.BattleLevels
			end
		end

		if WorldHandler.WorldsUnlocked.Sora[WorldHandler.Worlds.TT] > 0 then
			WriteByte(_worldBattleLvls[1], 
								WorldHandler.BattleLevels[WorldHandler.WorldsUnlocked.Sora[WorldHandler.Worlds.TT]])
		end
		if WorldHandler.WorldsUnlocked.Sora[WorldHandler.Worlds.TT2] > 0 then
			WriteByte(_worldBattleLvls[1], 
								WorldHandler.BattleLevels[WorldHandler.WorldsUnlocked.Sora[WorldHandler.Worlds.TT2]])
		end
		if WorldHandler.WorldsUnlocked.Sora[WorldHandler.Worlds.LCDC] > 0 then
			WriteByte(_worldBattleLvls[2], 
								WorldHandler.BattleLevels[WorldHandler.WorldsUnlocked.Sora[WorldHandler.Worlds.LCDC]])
		end
		if WorldHandler.WorldsUnlocked.Sora[WorldHandler.Worlds.TG] > 0 then
			WriteByte(_worldBattleLvls[3], 
								WorldHandler.BattleLevels[WorldHandler.WorldsUnlocked.Sora[WorldHandler.Worlds.TG]])
		end
		if WorldHandler.WorldsUnlocked.Sora[WorldHandler.Worlds.PP] > 0 then
			WriteByte(_worldBattleLvls[4], 
								WorldHandler.BattleLevels[WorldHandler.WorldsUnlocked.Sora[WorldHandler.Worlds.PP]])
		end
		if WorldHandler.WorldsUnlocked.Sora[WorldHandler.Worlds.COTM] > 0 then
			WriteByte(_worldBattleLvls[5], 
								WorldHandler.BattleLevels[WorldHandler.WorldsUnlocked.Sora[WorldHandler.Worlds.COTM]])
		end
		if WorldHandler.WorldsUnlocked.Sora[WorldHandler.Worlds.SOS] > 0 then
			WriteByte(_worldBattleLvls[6], 
								WorldHandler.BattleLevels[WorldHandler.WorldsUnlocked.Sora[WorldHandler.Worlds.SOS]])
		end
	else
		local _worldBattleLvls = {
			WorldFlags.traverseTown.riku.battle[gameVer],
			WorldFlags.laCiteDesCloches.riku.battle[gameVer],
			WorldFlags.theGrid.riku.battle[gameVer],
			WorldFlags.prankstersParadise.riku.battle[gameVer],
			WorldFlags.countryOfMusketeers.riku.battle[gameVer],
			WorldFlags.symphonyOfSorcery.riku.battle[gameVer]
		}

		for x=1, #WorldHandler.WorldsUnlocked.Riku do --In case a dupe is received; dont leave bounds
			if WorldHandler.WorldsUnlocked.Riku[x] > #WorldHandler.BattleLevels then
				WorldHandler.WorldsUnlocked.Riku[x] = #WorldHandler.BattleLevels
			end
		end

		if WorldHandler.WorldsUnlocked.Riku[WorldHandler.Worlds.TT] > 0 then
			WriteByte(_worldBattleLvls[1], 
								WorldHandler.BattleLevels[WorldHandler.WorldsUnlocked.Riku[WorldHandler.Worlds.TT]])
		end
		if WorldHandler.WorldsUnlocked.Riku[WorldHandler.Worlds.TT2] > 0 then
			WriteByte(_worldBattleLvls[1], 
								WorldHandler.BattleLevels[WorldHandler.WorldsUnlocked.Riku[WorldHandler.Worlds.TT2]])
		end
		if WorldHandler.WorldsUnlocked.Riku[WorldHandler.Worlds.LCDC] > 0 then
			WriteByte(_worldBattleLvls[2], 
								WorldHandler.BattleLevels[WorldHandler.WorldsUnlocked.Riku[WorldHandler.Worlds.LCDC]])
		end
		if WorldHandler.WorldsUnlocked.Riku[WorldHandler.Worlds.TG] > 0 then
			WriteByte(_worldBattleLvls[3], 
								WorldHandler.BattleLevels[WorldHandler.WorldsUnlocked.Riku[WorldHandler.Worlds.TG]])
		end
		if WorldHandler.WorldsUnlocked.Riku[WorldHandler.Worlds.PP] > 0 then
			WriteByte(_worldBattleLvls[4], 
								WorldHandler.BattleLevels[WorldHandler.WorldsUnlocked.Riku[WorldHandler.Worlds.PP]])
		end
		if WorldHandler.WorldsUnlocked.Riku[WorldHandler.Worlds.COTM] > 0 then
			WriteByte(_worldBattleLvls[5], 
								WorldHandler.BattleLevels[WorldHandler.WorldsUnlocked.Riku[WorldHandler.Worlds.COTM]])
		end
		if WorldHandler.WorldsUnlocked.Riku[WorldHandler.Worlds.SOS] > 0 then
			WriteByte(_worldBattleLvls[6], 
								WorldHandler.BattleLevels[WorldHandler.WorldsUnlocked.Riku[WorldHandler.Worlds.SOS]])
		end
	end

end

function WorldHandler:FixMenu()
	--Re-enable command menu if player leaves TT1 for some reason
	if getCharacter() == 0 and ReadByte(WorldFlags.traverseTown.sora.story[gameVer]+0x01) < 0xF1 then
		WriteByte(WorldFlags.traverseTown.sora.story[gameVer]+0x01, 0xF1)
	end

	--Force reveal world map if not there
	if ReadByte(WorldFlags.traverseTown.sora.story[gameVer]) < 0x11 then
		WriteByte(WorldFlags.traverseTown.sora.story[gameVer], 0x11)
	end
	if ReadByte(WorldFlags.traverseTown.riku.story[gameVer]) < 0x31 then
		WriteByte(WorldFlags.traverseTown.riku.story[gameVer], 0x31)
	end
end

function WorldHandler:RestoreWorldKeyTxt()
	writeTxtToGame(ItemOverwrite.keyItemNames[gameVer], "TWTNW Sora", 0) --Key Item 2 replacement
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer], "The World That Never Was for Sora", 3)

  writeTxtToGame(ItemOverwrite.keyItemNames[gameVer]+(22*2), "TWTNW Riku", 0) --Key Item 4 replacement
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+(38*2), "World That Never Was for Riku", 3)

  writeTxtToGame(ItemOverwrite.keyItemNames[gameVer]+(22*4), "TT Sora", 2) --Key Item 6 replacement
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+140, "Traverse Town for Sora", 3)

  writeTxtToGame(ItemOverwrite.keyItemNames[gameVer]+(22*6), "TT Riku", 2) --Key Item 8 replacement
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+204, "Traverse Town for Riku", 3)

  writeTxtToGame(ItemOverwrite.keyItemNames[gameVer]+(22*8), "LCdC Sora", 2) --Key Item 10 replacement
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+268, "La Cite des Cloches for Sora", 3)

  writeTxtToGame(ItemOverwrite.keyItemNames[gameVer]+224, "LCdC Riku", 2) --Key Item 12 replacement
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+336, "La Cite des Cloches for Riku", 3)

  writeTxtToGame(ItemOverwrite.keyItemNames[gameVer]+272, "TG Sora", 2) --Key Item 14 replacement
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+404, "The Grid for Sora", 3)

  writeTxtToGame(ItemOverwrite.keyItemNames[gameVer]+320, "TG Riku", 2) --Key Item 16 replacement
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+472, "The Grid for Riku", 3)

  writeTxtToGame(ItemOverwrite.keyItemNames[gameVer]+368, "PP Sora", 2) --Key Item 18 replacement
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+540, "Pranksters Paradise for Sora", 3)

  writeTxtToGame(ItemOverwrite.keyItemNames[gameVer]+416, "PP Riku", 2) --Key Item 20 replacement
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+608, "Pranksters Paradise for Riku", 3)

  writeTxtToGame(ItemOverwrite.keyItemNames[gameVer]+464, "CotM Sora", 2) --Key Item 22 replacement
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+676, "Country of Musketeers for Sora", 3)

  writeTxtToGame(ItemOverwrite.keyItemNames[gameVer]+512, "CotM Riku", 2) --Key Item 24 replacement
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+744, "Country of Musketeers for Riku", 3)

  --add 10 if wrong
  writeTxtToGame(ItemOverwrite.keyItemNames[gameVer]+560, "SoS Sora", 2) --Key Item 26 replacement
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+812, "Symphony of Sorcery for Sora", 3)

  writeTxtToGame(ItemOverwrite.keyItemNames[gameVer]+608, "SoS Riku", 2) --Key Item 28 replacement
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+880, "Symphony of Sorcery for Riku", 3)

  --Recusant's Sigil for additional ending condition
  writeTxtToGame(ItemOverwrite.keyItemNames[gameVer]+656, "Recusant Sigil", 2) --Key Item 30 replacement
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+948, "Sigil of the Recusant.", 3)

  --Traverse Town 2
  writeTxtToGame(ItemOverwrite.keyItemNames[gameVer]+704, "TT2 Sora", 2) --Key Item 32 replacement
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+1016, "Traverse Town 2nd Visit for Sora", 2)

  writeTxtToGame(ItemOverwrite.keyItemNames[gameVer]+752, "TT2 Riku", 2) --Key Item 34 replacement
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+1084, "Traverse Town 2nd Visit for Riku", 2)
end

return WorldHandler