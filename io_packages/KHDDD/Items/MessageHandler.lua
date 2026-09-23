--Message Handler
MessageHandler = {}

local _progTypes = {"World", "Recipe", "Flowmotion", "Key", "Goal"}
local _usefulTypes = {"Keyblades [Sora]", "Keyblades [Riku]", "Stats [Sora]", "Stats [Riku]", "Stat", "Support", "Spirit"}
local _trapTypes = {"Trap"}

MessageHandler.State = {
	msgQueue = {},
	currQueue = 0,
	msgCd = 15,
	maxCd = 15, --40 for %15 in main
	restore = false,
	msgLimit = 10, --Only 10 messages can be saved
}

function MessageHandler:localItemToColor(itemId)
	local _item = getItemById(itemId)

	local _clr = KHCOLORS.GRAY

	if _item == nil then
		return _clr
	end

	local _type = _item.Type

	if hasValue(_progTypes, _type) or _item.Usefulness == item_usefulness.progression_useful then
		_clr = KHCOLORS.PINK
	elseif hasValue(_progTypes, _type) or _item.Usefulness == item_usefulness.progression then
		_clr = KHCOLORS.YELLOW
	elseif hasValue(_usefulTypes, _type) or _item.Usefulness == item_usefulness.normal then
		_clr = KHCOLORS.GREEN
	elseif hasValue(_trapTypes, _type) then
		_clr = KHCOLORS.RED
	end

	return _clr
end

function MessageHandler:remoteItemToColor(usefulness)
	-- use modulo to get the right 'usefulness'
	local _clr = KHCOLORS.GRAY

	if usefulness == item_usefulness.progression_useful then -- 3
		_clr = KHCOLORS.PINK
	elseif usefulness == item_usefulness.special then
		_clr = KHCOLORS.PINK
	elseif math.floor(usefulness / item_usefulness.progression ) % 2 == 1 then -- 1	
		_clr = KHCOLORS.YELLOW
		if math.floor(usefulness / item_usefulness.skip_balancing ) % 2 == 1 then -- 6
			_clr = KHCOLORS.PINK 
			if math.floor(usefulness / item_usefulness.deprioritized) % 2 == 1 then -- 8
				_clr = KHCOLORS.YELLOW
			end
		end
	elseif usefulness == item_usefulness.normal then -- 2
		_clr = KHCOLORS.GREEN
	elseif usefulness == item_usefulness.trap then -- 4
		_clr = KHCOLORS.RED
	end

	return _clr
end

function MessageHandler:writeColorToGame(startAddr, txt1, coloredTxt, txt2, color, filler)
	writeTxtToGame(startAddr, txt1, 5) --Ensure there is space for colored txt
	local _coloredOffset = (#txt1*2)
	WriteArray(startAddr+_coloredOffset, color)
	writeTxtToGame(startAddr+_coloredOffset+2, coloredTxt, 0)
	local _txt2Offset = _coloredOffset+(#coloredTxt*2)+2
	WriteArray(startAddr+_txt2Offset, {KHSCII.LeftParen, 0xE0})
	writeTxtToGame(startAddr+_txt2Offset+2, txt2.."!", filler)
end

function MessageHandler:getInfoAddr(worldNo, character)
	if worldNo == 0x01 then
		return WorldFlags.destinyIslands.sora.info[gameVer]
	elseif worldNo == 0x03 then
		if character == 0 then
			return WorldFlags.traverseTown.sora.info[gameVer]
		else
			return WorldFlags.traverseTown.riku.info[gameVer]
		end
	elseif worldNo == 0x08 then
		if character == 0 then
			return WorldFlags.laCiteDesCloches.sora.info[gameVer]
		else
			return WorldFlags.laCiteDesCloches.riku.info[gameVer]
		end
	elseif worldNo == 0x09 then
		if character == 0 then
			return WorldFlags.theGrid.sora.info[gameVer]
		else
			return WorldFlags.theGrid.riku.info[gameVer]
		end
	elseif worldNo == 0x06 then
		if character == 0 then
			return WorldFlags.prankstersParadise.sora.info[gameVer]
		else
			return WorldFlags.prankstersParadise.riku.info[gameVer]
		end
	elseif worldNo == 0x04 then
		if character == 0 then
			return WorldFlags.countryOfMusketeers.sora.info[gameVer]
		else
			return WorldFlags.countryOfMusketeers.riku.info[gameVer]
		end
	elseif worldNo == 0x05 then
		if character == 0 then
			return WorldFlags.symphonyOfSorcery.sora.info[gameVer]
		else
			return WorldFlags.symphonyOfSorcery.riku.info[gameVer]
		end
	elseif worldNo == 0x0A then
		if character == 0 then
			return WorldFlags.theWorldThatNeverWas.sora.info[gameVer]
		else
			return WorldFlags.theWorldThatNeverWas.riku.info[gameVer]
		end
	end

	return 0x00
end

local _isSaving = {0x00, 0xA9AB50}
function MessageHandler:checkForRestore()
	--Restore missions under various circumstances
	if ReadByte(_isSaving[gameVer]) == 0x0A or ReadByte(MemoryAddresses.world[gameVer]) == 0x0B or self.State.restore then --Player has the save menu opened
		self:restoreMissions()
	end
	local _statePtr = GetPointer(MemoryAddresses.deathPtr[gameVer], MemoryAddresses.deathOffset)
  	local _stateVal = ReadByte(_statePtr, true)
  	if _stateVal == 3 then --Player died; need to restore the mission
  		self:restoreMissions()
  	end
end

function MessageHandler:restoreMissions()
	if self.State.pending then
		WriteByte(self.State.pending.addr, self.State.pending.val)
		self.State.pending = nil
	end
	self.State.restore = false
end

function MessageHandler:runItemQueue()

	if #self.State.msgQueue == 0 then
		self.State.msgCd = 0
		return
	end

	--Checks to do to ensure that we don't let the player miss messages while also not decreasing cd
	if ReadByte(MemoryAddresses.enablePause[gameVer]) > 0x00 or ReadByte(MemoryAddresses.pauseType[gameVer]) > 0x00 or ReadByte(MemoryAddresses.cutscenePauseType[gameVer]) > 0x00 then
		self.State.msgCd = self.State.maxCd
		return
	end 

	if self.State.msgCd > 0 then
		self.State.msgCd = self.State.msgCd-1
		return
	end

	--Get intended world
	local _world = ReadByte(MemoryAddresses.world[gameVer])
	local _character = getCharacter()
	local _infoAddr = self:getInfoAddr(_world, _character)

	if _infoAddr == 0x00 then --In an invalid world
		return
	end

	local _currInfoVal = ReadByte(_infoAddr)

	local _missionOverwrite = 0x01

	if self.State.pending == nil then --1 and 2 are only ever ours; anything else is the game's value
		self.State.pending = {addr = _infoAddr, val = (_currInfoVal > 0x02) and _currInfoVal or 0x00}
	end
	if _currInfoVal == 0x01 then --Alternate so the game sees a change
		_missionOverwrite = 0x02
	end

	if #self.State.msgQueue[#self.State.msgQueue] < 3 then --Local
		local _itemId = self.State.msgQueue[#self.State.msgQueue][1]

		if getItemById(_itemId) ~= nil then


			local _clr = self:localItemToColor(_itemId)
			local _item = getItemById(_itemId)
			local _name = _item.Name

			--Calculate number of characters that should be taken up
			local _msgLimit = 72
			if _missionOverwrite == 0x02 then
				_msgLimit = 46
			end
			local _fullMsg = "Received ".._name.."!"
			local _filler = 3
			if #_fullMsg < _msgLimit then
				_filler = _msgLimit-#_fullMsg
			end

			if _missionOverwrite == 0x01 then
				self:writeColorToGame(ItemOverwrite.linkInfo1[gameVer], "Received ", _name, "", _clr, _filler)
			else
				self:writeColorToGame(ItemOverwrite.linkInfo2[gameVer], "Received ", _name, "", _clr, _filler)
			end
			WriteByte(_infoAddr, _missionOverwrite)
		end
	else
		local _queueData = self.State.msgQueue[#self.State.msgQueue]
		local _name = _queueData[1]
		local _clr = self:remoteItemToColor(_queueData[3])
		local _player = _queueData[2]

		--Calculate number of characters that should be taken up
		local _msgLimit = 72
		if _missionOverwrite == 0x02 then
			_msgLimit = 46
		end
		local _fullMsg = "Sent ".._name.." to ".._player.."!"
		local _filler = 3
		if #_fullMsg < _msgLimit then
			_filler = _msgLimit-#_fullMsg
		end

		local _partialMsg = "Sent ".._name.."to "
		if _missionOverwrite == 0x01 then
			self:writeColorToGame(ItemOverwrite.linkInfo1[gameVer], "Sent ", _name, " to ", _clr, 3)
			self:writeColorToGame(ItemOverwrite.linkInfo1[gameVer]+(#_partialMsg*2)+4, " ", _player, "!", KHCOLORS.BLUE, _filler)
		else
			self:writeColorToGame(ItemOverwrite.linkInfo2[gameVer], "Sent ", _name, " to ", _clr, 3)
			self:writeColorToGame(ItemOverwrite.linkInfo2[gameVer]+(#_partialMsg*2)+4, " ", _player, "!", KHCOLORS.BLUE, _filler)
		end
		WriteByte(_infoAddr, _missionOverwrite)


	end

	table.remove(self.State.msgQueue)
	self.State.msgCd = self.State.maxCd
end

function MessageHandler:msgReceived(itemId)
	local _item = getItemById(itemId)
	table.insert(self.State.msgQueue, {itemId, _item.Name})
	if #self.State.msgQueue > self.State.msgLimit then
		table.remove(self.State.msgQueue, 1)
	end
end

function MessageHandler:remoteReceived(itemName, playerName, usefulness)
	table.insert(self.State.msgQueue, {itemName, playerName, usefulness})
	if #self.State.msgQueue > self.State.msgLimit then
		table.remove(self.State.msgQueue, 1)
	end
end

local _dPad = {0x9E9E98, 0x9E9E88}
--local _queueClearTimer = 12 --For %15 on main
local _queueClearTimer = 6 --For %30 on main
function MessageHandler:clearItemQueue()
	if ReadByte(_dPad[gameVer]) == 0x80 then
		_queueClearTimer = _queueClearTimer - 1
	else
		_queueClearTimer = 12
	end
	if _queueClearTimer <= 0 then
		self.State.msgQueue = {}
		_queueClearTimer = 12
	end
end

return MessageHandler