--Message Handler
MessageHandler = {}

local _progTypes = {"World", "Recipe", "Flowmotion", "Key", "Goal"}
local _usefulTypes = {"Keyblades [Sora]", "Keyblades [Riku]", "Stats [Sora]", "Stats [Riku]", "Stat", "Support", "Spirit"}
local _trapTypes = {"Trap"}

MessageHandler.State = { --Track intended info states for the different worlds
	msgQueue = {},
	currQueue = 0,
	msgCd = 15,
	maxCd = 15, --40 for %15 in main
	restore = false,
	msgLimit = 10, --Only 10 messages can be saved
	di = {
		sora = 0x00
	},
	tt = {
		sora = 0x00,
		riku = 0x00
	},
	lcdc = {
		sora = 0x00,
		riku = 0x00
	},
	tg = {
		sora = 0x00,
		riku = 0x00
	},
	pp = {
		sora = 0x00,
		riku = 0x00
	},
	cotm = {
		sora = 0x00,
		riku = 0x00
	},
	sos = {
		sora = 0x00,
		riku = 0x00
	},
	twtnw = {
		sora = 0x00,
		riku = 0x00
	},
}

function MessageHandler:localItemToColor(itemId)
	local _item = getItemById(itemId)

	local _clr = KHCOLORS.GRAY

	if _item == nil then
		return _clr
	end

	local _type = _item.Type

	if hasValue(_progTypes, _type) or _item.Usefulness == item_usefulness.progression then
		_clr = KHCOLORS.YELLOW
	elseif hasValue(_usefulTypes, _type) or _item.Usefulness == item_usefulness.normal then
		_clr = KHCOLORS.GREEN
	elseif hasValue(_trapTypes, _type) then
		_clr = KHCOLORS.RED
	end

	return _clr
end

function MessageHandler:remoteItemToColor(usefulness)
	local _clr = KHCOLORS.GRAY

	if usefulness == item_usefulness.progression then
		_clr = KHCOLORS.YELLOW
	elseif usefulness == item_usefulness.normal then
		_clr = KHCOLORS.GREEN
	elseif usefulness == item_usefulness.trap then
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

function MessageHandler:checkInfoVal(worldNo, character)
	if worldNo == 0x01 then
		return self.State.di.sora
	elseif worldNo == 0x03 then
		if character == 0 then
			return self.State.tt.sora
		else
			return self.State.tt.riku
		end
	elseif worldNo == 0x08 then
		if character == 0 then
			return self.State.lcdc.sora
		else
			return self.State.lcdc.riku
		end
	elseif worldNo == 0x09 then
		if character == 0 then
			return self.State.tg.sora
		else
			return self.State.tg.riku
		end
	elseif worldNo == 0x06 then
		if character == 0 then
			return self.State.pp.sora
		else
			return self.State.pp.riku
		end
	elseif worldNo == 0x04 then
		if character == 0 then
			return self.State.cotm.sora
		else
			return self.State.cotm.riku
		end
	elseif worldNo == 0x05 then
		if character == 0 then
			return self.State.sos.sora
		else
			return self.State.sos.riku
		end
	elseif worldNo == 0x0A then
		if character == 0 then
			return self.State.twtnw.sora
		else
			return self.State.twtnw.riku
		end
	end
	return 0
end

function MessageHandler:setInfoVal(worldNo, character, val)
	if worldNo == 0x01 then
		self.State.di.sora = val
	elseif worldNo == 0x03 then
		if character == 0 then
			self.State.tt.sora = val
		else
			self.State.tt.riku = val
		end
	elseif worldNo == 0x08 then
		if character == 0 then
			self.State.lcdc.sora = val
		else
			self.State.lcdc.riku = val
		end
	elseif worldNo == 0x09 then
		if character == 0 then
			self.State.tg.sora = val
		else
			self.State.tg.riku = val
		end
	elseif worldNo == 0x06 then
		if character == 0 then
			self.State.pp.sora = val
		else
			self.State.pp.riku = val
		end
	elseif worldNo == 0x04 then
		if character == 0 then
			self.State.cotm.sora = val
		else
			self.State.cotm.riku = val
		end
	elseif worldNo == 0x05 then
		if character == 0 then
			self.State.sos.sora = val
		else
			self.State.sos.riku = val
		end
	elseif worldNo == 0x0A then
		if character == 0 then
			self.State.twtnw.sora = val
		else
			self.State.twtnw.riku = val
		end
	end
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
	--Destiny Islands
	local _valCheck = self:checkInfoVal(0x01, 0)
	if _valCheck > 0x02 then
		WriteByte(self:getInfoAddr(0x01, 0), _valCheck)
	end

	--Traverse Town
	_valCheck = self:checkInfoVal(0x03, 0)
	if _valCheck > 0x02 then
		WriteByte(self:getInfoAddr(0x03, 0), _valCheck)
	end
	_valCheck = self:checkInfoVal(0x03, 1)
	if _valCheck > 0x02 then
		WriteByte(self:getInfoAddr(0x03, 1), _valCheck)
	end

	--La Cite des Cloches
	_valCheck = self:checkInfoVal(0x08, 0)
	if _valCheck > 0x02 then
		WriteByte(self:getInfoAddr(0x08, 0), _valCheck)
	end
	_valCheck = self:checkInfoVal(0x08, 1)
	if _valCheck > 0x02 then
		WriteByte(self:getInfoAddr(0x08, 1), _valCheck)
	end

	--The Grid
	_valCheck = self:checkInfoVal(0x09, 0)
	if _valCheck > 0x02 then
		WriteByte(self:getInfoAddr(0x09, 0), _valCheck)
	end
	_valCheck = self:checkInfoVal(0x09, 1)
	if _valCheck > 0x02 then
		WriteByte(self:getInfoAddr(0x09, 1), _valCheck)
	end

	--Prankster's Paradise
	_valCheck = self:checkInfoVal(0x06, 0)
	if _valCheck > 0x02 then
		WriteByte(self:getInfoAddr(0x06, 0), _valCheck)
	end
	_valCheck = self:checkInfoVal(0x06, 1)
	if _valCheck > 0x02 then
		WriteByte(self:getInfoAddr(0x06, 1), _valCheck)
	end

	--Country of Musketeers
	_valCheck = self:checkInfoVal(0x04, 0)
	if _valCheck > 0x02 then
		WriteByte(self:getInfoAddr(0x04, 0), _valCheck)
	end
	_valCheck = self:checkInfoVal(0x04, 1)
	if _valCheck > 0x02 then
		WriteByte(self:getInfoAddr(0x04, 1), _valCheck)
	end

	--Symphony of Sorcery
	_valCheck = self:checkInfoVal(0x05, 0)
	if _valCheck > 0x02 then
		WriteByte(self:getInfoAddr(0x05, 0), _valCheck)
	end
	_valCheck = self:checkInfoVal(0x05, 1)
	if _valCheck > 0x02 then
		WriteByte(self:getInfoAddr(0x05, 1), _valCheck)
	end

	--The World That Never Was
	_valCheck = self:checkInfoVal(0x0A, 0)
	if _valCheck > 0x02 then
		WriteByte(self:getInfoAddr(0x0A, 0), _valCheck)
	end
	_valCheck = self:checkInfoVal(0x0A, 1)
	if _valCheck > 0x02 then
		WriteByte(self:getInfoAddr(0x0A, 1), _valCheck)
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

	if _currInfoVal > 0x02 then --Store current mission value to restore later
		self:setInfoVal(_world, _character, _currInfoVal)
	else --Alternate to other mission type
		if _currInfoVal == 0x01 then
			_missionOverwrite = 0x02
		end
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
			self:writeColorToGame(ItemOverwrite.linkInfo1[gameVer]+(#_partialMsg*2)+4, " ", _player, "!", KHCOLORS.PINK, _filler)
		else
			self:writeColorToGame(ItemOverwrite.linkInfo2[gameVer], "Sent ", _name, " to ", _clr, 3)
			self:writeColorToGame(ItemOverwrite.linkInfo2[gameVer]+(#_partialMsg*2)+4, " ", _player, "!", KHCOLORS.PINK, _filler)
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