EnergyLinkTask = {}

EnergyLinkTask.IsActive = false

EnergyLinkTask.FieldGauge = 0 --Last gauge outside the world map, for world map drops
EnergyLinkTask.DPValue = 0 --For when dropping on world map
EnergyLinkTask.RestoreGauge = -1 --0 if sora had dropped and 1 if riku had dropped
EnergyLinkTask.ActiveCharacter = 0

--What the dropping character had left moves to the other one, topped off from the bank unless a trap dropped them
EnergyLinkTask.Leftover = 0
EnergyLinkTask.DropDraw = 0
EnergyLinkTask.TrapDrop = false
EnergyLinkTask.AwaitingDraw = false --The client doesn't reply when the bank is empty
EnergyLinkTask.FloorGift = 0 --Part of the one-bar floor that a late bank reply pays back

EnergyLinkTask.DropToWrite = -1

EnergyLinkTask.UsingItem = false

--A death reload restores the game's post-drop refill, not what Dropped wrote, until the next room change
EnergyLinkTask.EntryGauge = nil
EnergyLinkTask.EntryRoom = {}
EnergyLinkTask.Died = false

local _dp = {0xA98024} --TODO: EGS
--Get DP: ReadShort(_dp[gameVer])

local _maxGauge = 72000
local _oneBar = _maxGauge / 3

local _bonusFlagByte = 0x1D --Flag word follows the dropPtr global
local _bonusFlag = 0x40

local function inBonusTime()
	return ReadByte(MemoryAddresses.dropPtr[gameVer]+_bonusFlagByte) & _bonusFlag ~= 0
end

local function equippedItemBoosts()
	local _abl = ReadByte(MemoryAddresses.supportAbilities[gameVer]-0x42+getCharacter()) --Item Boost; one byte per character
	local _count = 0
	for i = 0, (_abl & 0x07)-1 do --Low 3 bits: copies owned; one equip bit per copy from bit 3
		if _abl & (0x08 << i) ~= 0 then
			_count = _count + 1
		end
	end
	return _count
end

function EnergyLinkTask:Init()
	--Nop drop me not restoration
	local _dropMeNop = {0x2DE409} --TODO: EGS

	--Prevent drop-me-nots/nevers from restoring drop gauge 
	WriteArray(_dropMeNop[gameVer], {0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x76, 0x08, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90})

	self.IsActive = true
	self.ActiveCharacter = getCharacter()
end

function EnergyLinkTask:Update()
	if not self.IsActive then
		return
	end

	local _charState = ReadByte(GetPointer(MemoryAddresses.deathPtr[gameVer], MemoryAddresses.deathOffset), true)
	local _dropGauge = ReadFloat(GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset), true) --+0x0C for bonus time

	if self.EntryGauge then
		self:KeepEntryGauge(_charState)
	end

	if (_charState == 0x01 or _charState == 0x02) and self.RestoreGauge == -1 then
		self:SaveGauge()
	end

	if roomInfo[1] == 0x0B then --Need to preserve DP on world map since we can't reliably detect dropping here
		self.DPValue = ReadShort(_dp[gameVer])

		if self.ActiveCharacter ~= getCharacter() and self.RestoreGauge == -1 then --A drop occurred
			self:BeginDrop(math.abs(getCharacter()-1), self.FieldGauge, self.DPValue, false)
			self.DPValue = 0
		end
	end

	if _charState == 0x04 and self.RestoreGauge == -1 then --We have dropped
		self:OnDrop()
	end

	if (_dropGauge > 0 or inBonusTime()) and self.DropToWrite > -1 and _charState ~= 0x04 and self.RestoreGauge == -1 then --We have energy to write to the drop gauge
		self:GotEnergy(self.DropToWrite)
		self.DropToWrite = -1
	end

	if _charState ~= 0x04 and ReadByte(MemoryAddresses.enablePause[gameVer]) == 0x00 and roomInfo[1] ~= 0x0B then
		if self.RestoreGauge > -1 then
			self:Dropped()
		end
	end


	--Detect if Drop-Me-Not/Never was used
	if ReadByte(MemoryAddresses.enablePause[gameVer]) == 0x00 then
		--Can reference animation queue to determine if drop me not/never is used
		local _animPtr = {0xA37DB8} --TODO: EGS
		local _animQueueVal = ReadByte(GetPointer(_animPtr[gameVer], 0x570)+0x142, true)
		if not self.UsingItem then
			if _animQueueVal == 0x7A or _animQueueVal == 0x7B then
				--Player has used a drop-me-not
				self:RequestEnergy(_animQueueVal)
				self.UsingItem = true
			end
		else
			if _animQueueVal ~= 0x7B and _animQueueVal ~= 0x7A then --Animation ended
				self.UsingItem = false
			end
		end
	end

end

function EnergyLinkTask:RequestEnergy(itemUsed)
	local _itemPercent = {[0x7A] = 50, [0x7B] = 100} --Same as the game's Drop-Me-Not code at 0x2DE360

	local _currentEnergy = ReadFloat(GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset), true)
	local _percent = _itemPercent[itemUsed] * (100 + 10*equippedItemBoosts()) // 100 --Each Item Boost adds 10% of the base
	local _requestedEnergy = _percent * 0.01 * _maxGauge
	if _requestedEnergy + _currentEnergy > _maxGauge then --Should not request more than maximum drop
		local _amtOver = (_requestedEnergy + _currentEnergy) - _maxGauge
		_requestedEnergy = _requestedEnergy - _amtOver
	end
	if _requestedEnergy <= 0 then --Full gauge; a 0 request makes the client log "Not enough energy"
		return
	end

	--Replies come in order, so a drop request still unanswered found the bank empty
	self.AwaitingDraw = false
	SendToApClient(MessageTypes.RequestingEnergy, {tostring(_requestedEnergy)})
end

--Mirrors the game's refill: clamp to max, stop bonus time and reset it.
--At 0 the game restarts bonus time next frame, so an empty gauge drops after bonus time instead of at once.
function EnergyLinkTask:SetGauge(amt)
	local _bar = GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset)
	local _flags = MemoryAddresses.dropPtr[gameVer]+_bonusFlagByte
	WriteFloat(_bar, math.max(0, math.min(amt, _maxGauge)), true)
	WriteFloat(_bar+0x08, 1920, true) --Bonus time in frames
	WriteInt(_bar+0x0C, 32, true) --Bonus time in seconds
	WriteByte(_flags, ReadByte(_flags) & ~_bonusFlag)
end

function EnergyLinkTask:GotEnergy(amt) --Energy reponse received from server
	_barAddr = GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset)
	local _currentEnergy = ReadFloat(_barAddr, true)
	self:SetGauge(_currentEnergy+amt)
	ConsolePrint("Added to energy")
end

function EnergyLinkTask:EnergyFromServer(amt)
	if self.AwaitingDraw then
		self.AwaitingDraw = false
		if self.RestoreGauge > -1 then
			self.DropDraw = amt
			return
		end
		amt = amt - self.FloorGift --Arrived after Dropped wrote the one-bar floor
		self.FloorGift = 0
		if amt <= 0 then
			return
		end
	end
	self.DropToWrite = math.max(self.DropToWrite, 0) + amt
end

function EnergyLinkTask:SaveGauge()
	if roomInfo[1] ~= 0x0B then
		self.FieldGauge = ReadFloat(GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset), true)
	end
end

function EnergyLinkTask:OnPause()
	if roomInfo[1] ~= 0x0B then
		self:SaveGauge()
	end
	self.DPValue = ReadShort(_dp[gameVer])
end

function EnergyLinkTask:SendDP(dpAmt)
	if dpAmt <= 0 then --Don't need to send a message with 0 dp
		return
	end
	ConsolePrint("Sending DP to server")
	SendToApClient(MessageTypes.SendingEnergy, {tostring(dpAmt)})
end

function EnergyLinkTask:Dropped()
	local _bar = GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset)
	if ReadFloat(_bar, true) <= 0 then
		return
	end
	local _gauge = self.Leftover + self.DropDraw
	self.FloorGift = 0
	if not self.TrapDrop and _gauge < _oneBar then --The game covers what the bank can't, up to one bar
		self.FloorGift = _oneBar - _gauge
		_gauge = _oneBar
	end
	self:SetGauge(_gauge)
	self.ActiveCharacter = getCharacter()
	self.RestoreGauge = -1
	self.EntryGauge = ReadFloat(_bar, true)
	self.EntryRoom = {roomInfo[1], roomInfo[2]}
	self.Died = false
	ConsolePrint("Drop gauge: "..tostring(self.Leftover).." carried + "..tostring(self.DropDraw).." from bank = "..tostring(self.EntryGauge))
end

function EnergyLinkTask:KeepEntryGauge(charState)
	if charState == 0x03 then
		self.Died = true
	elseif self.Died then
		if (charState == 0x01 or charState == 0x02) and ReadByte(MemoryAddresses.enablePause[gameVer]) == 0x00 then
			self:SetGauge(self.EntryGauge)
			self.Died = false
			ConsolePrint("Restored post-drop gauge after death")
		end
	elseif roomInfo[1] ~= self.EntryRoom[1] or roomInfo[2] ~= self.EntryRoom[2] then
		self.EntryGauge = nil
	end
end

function EnergyLinkTask:OnDrop()
	--Until the post-drop refill the gauge holds what the dropping character had left. DeliverDrop clears holdDropTrap after this frame
	local _left = ReadFloat(GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset), true)
	self:BeginDrop(getCharacter(), _left, ReadShort(_dp[gameVer]), holdDropTrap == true)
end

function EnergyLinkTask:BeginDrop(dropper, leftover, dp, isTrap)
	self:SendDP(dp)
	self.RestoreGauge = dropper
	self.EntryGauge = nil
	self.Leftover = math.min(math.max(leftover, 0), _maxGauge)
	self.DropDraw = 0
	self.TrapDrop = isTrap
	local _topOff = _maxGauge - self.Leftover
	if not isTrap and _topOff > 0 then
		self.AwaitingDraw = true
		SendToApClient(MessageTypes.RequestingEnergy, {tostring(_topOff)})
	end
	ConsolePrint((isTrap and "Trap drop" or "Drop").." with "..tostring(self.Leftover).." left")
end

return EnergyLinkTask