EnergyLinkTask = {}

EnergyLinkTask.IsActive = false
EnergyLinkTask.IsPaused = false

EnergyLinkTask.GaugeValue = 0 --Updates on pause or world map to track manual drops
EnergyLinkTask.DPValue = 0 --For when dropping on world map
EnergyLinkTask.RestoreGauge = -1 --0 if sora had dropped and 1 if riku had dropped
EnergyLinkTask.ActiveCharacter = 0

EnergyLinkTask.UsingItem = false

local _dp = {0xA98024} --TODO: EGS
--Get DP: ReadShort(_dp[gameVer])

function EnergyLinkTask:Init()
	--Nop drop me not restoration
	local _dropMeNop = {0x2DE409} --TODO: EGS

	--Prevent drop-me-nots/nevers from restoring drop gauge 
	WriteArray(_dropMeNop[gameVer], {0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x76, 0x08, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90})

	self.IsActive = true
	self.ActiveCharacter = getCharacter()
end

local _isDropped = false
function EnergyLinkTask:Update()
	if not self.IsActive then
		return
	end

	local _charState = ReadByte(GetPointer(MemoryAddresses.deathPtr[gameVer], MemoryAddresses.deathOffset), true)

	if not self.IsPaused then
		if ReadByte(MemoryAddresses.pauseType[gameVer]) == 0x03 or roomInfo[1] == 0x0B then
			self:OnPause()
			self.IsPaused = true
		end
	else
		if ReadByte(MemoryAddresses.pauseType[gameVer]) == 0x00 and roomInfo[1] ~= 0x0B then
			self.IsPaused = false
		end
	end

	if not self.IsPaused and ReadByte(MemoryAddresses.enablePause[gameVer]) == 0x00 then
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

	if roomInfo[1] == 0x0B then
		if self.ActiveCharacter ~= getCharacter() then --Player dropped
			self.RestoreGauge = math.abs(getCharacter()-1) --Was it Sora or Riku
			self:SendDP(self.DPValue)
			self.DPValue = 0
		end
	end

	if not _isDropped and _charState == 0x04 then
		_isDropped = true
		self:OnDrop()
	elseif _isDropped and _charState ~= 0x04 and ReadByte(MemoryAddresses.enablePause[gameVer]) == 0x00 then
		if self.RestoreGauge > -1 then
			ConsolePrint("Player Dropped in Invalid area")
			self:SendDP(self.DPValue)
			self.DPValue = 0
			self:Dropped()
			_isDropped = false
		end
	end

	if _charState ~= 0x04 and ReadByte(MemoryAddresses.enablePause[gameVer]) == 0x00 and roomInfo[1] ~= 0x0B then
		if self.RestoreGauge > -1 then
			ConsolePrint("Writing Drop Gauge Value")
			if ReadFloat(GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset), true) > 0 then
				self:Dropped()
			end
		end
	end
end

function EnergyLinkTask:RequestEnergy(itemUsed)
	local _energyToRequest = {24000, 48000}
	local _maxEnergy = 72000

	local _currentEnergy = ReadFloat(GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset), true)
	local _requestedEnergy = _energyToRequest[itemUsed-0x79]
	if _requestedEnergy + _currentEnergy > _maxEnergy then --Should not request more than maximum drop
		local _amtOver = (_requestedEnergy + _currentEnergy) - _maxEnergy
		_requestedEnergy = _requestedEnergy - _amtOver
	end

	--Send the request
	SendToApClient(MessageTypes.RequestingEnergy, {tostring(_requestedEnergy)})
end

function EnergyLinkTask:GotEnergy(amt) --Energy reponse received from server
	_barAddr = GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset)
	local _currentEnergy = ReadFloat(_barAddr, true)
	WriteFloat(_barAddr, _currentEnergy+amt, true)
end

function EnergyLinkTask:SaveGauge()
	local _readBar = ReadFloat(GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset), true)
	if _readBar > 0 then
		self.GaugeValue = _readBar
		ConsolePrint("Saved Gauge: "..tostring(self.GaugeValue))
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
	ConsolePrint("ATTEMPTING TO OVERWRITE ENERGY")
	if ReadFloat(GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset), true) > 0 then
		self.ActiveCharacter = getCharacter()
		WriteFloat(GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset), self.GaugeValue, true)
		self.RestoreGauge = -1
		ConsolePrint("SUCCESS")
	end
end

function EnergyLinkTask:OnDrop()
	self.DPValue = ReadShort(_dp[gameVer])
	self:SendDP(self.DPValue)
	self.DPValue = 0
	local _bar = GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset)
	if roomInfo[1] == 0x0B or _bar == MemoryAddresses.dropOffset or ReadFloat(_bar, true) > 0 then
		--Still had gauge; Drop was manual
		ConsolePrint("PLAYER DROPPED EARLY DOING RESTORE")
		self.RestoreGauge = getCharacter()
	end
end

return EnergyLinkTask