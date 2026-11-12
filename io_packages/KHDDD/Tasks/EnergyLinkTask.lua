EnergyLinkTask = {}

EnergyLinkTask.IsActive = false

EnergyLinkTask.GaugeValue = -1 --Updates on pause or world map to track manual drops
EnergyLinkTask.DPValue = 0 --For when dropping on world map
EnergyLinkTask.RestoreGauge = -1 --0 if sora had dropped and 1 if riku had dropped
EnergyLinkTask.ActiveCharacter = 0

EnergyLinkTask.DropToWrite = -1

EnergyLinkTask.UsingItem = false

EnergyLinkTask.NaturalDrop = false

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

function EnergyLinkTask:Update()
	if not self.IsActive then
		return
	end

	local _charState = ReadByte(GetPointer(MemoryAddresses.deathPtr[gameVer], MemoryAddresses.deathOffset), true)
	local _dropGauge = ReadFloat(GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset), true) --+0x0C for bonus time

	if ReadByte(MemoryAddresses.pauseType[gameVer]) == 0x03 then --We need to preserve the current gauge value
		self:SaveGauge() --We need to preserve the current gauge value
	end

	if roomInfo[1] == 0x0B then --Need to preserve DP on world map since we can't reliably detect dropping here
		self.DPValue = ReadShort(_dp[gameVer])

		if self.ActiveCharacter ~= getCharacter() then --A drop occurred
			if self.RestoreGauge == -1 then
				self.RestoreGauge = math.abs(getCharacter()-1) --Was it Sora or Riku
				self:SendDP(self.DPValue)
				self.DPValue = 0
			end
		end
	end

	if _charState == 0x04 and self.RestoreGauge == -1 then --We have dropped
		self:OnDrop()
	end

	if _dropGauge > 0 and self.DropToWrite > -1 and _charState ~= 0x04 and not self.NaturalDrop then --We have energy to write to the drop gauge
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

function EnergyLinkTask:RequestAllEnergy()
	SendToApClient(MessageTypes.RequestingEnergy, {tostring(72000)})
end

function EnergyLinkTask:GotEnergy(amt) --Energy reponse received from server
	_barAddr = GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset)
	local _currentEnergy = ReadFloat(_barAddr, true)
	WriteFloat(_barAddr, _currentEnergy+amt, true)
	ConsolePrint("Added to energy")
end

function EnergyLinkTask:EnergyFromServer(amt)
	self.DropToWrite = amt
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
	if not timedout then --Player manually dropped and drop gauge needs to be transferred
		if ReadFloat(GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset), true) > 0 then
			self.ActiveCharacter = getCharacter()
			if self.NaturalDrop then
				WriteFloat(GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset), self.DropToWrite, true)
				self.DropToWrite = -1
				self.NaturalDrop = false
				ConsolePrint("Restored using write amount")
			else
				WriteFloat(GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset), self.GaugeValue, true)
				self.GaugeValue = -1
				ConsolePrint("Restored using saved amount")
			end
			self.RestoreGauge = -1
			ConsolePrint("SUCCESS")
		end
	end
end

function EnergyLinkTask:OnDrop()
	self.DPValue = ReadShort(_dp[gameVer])
	self:SendDP(self.DPValue)
	self.DPValue = 0
	local _bar = GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset)
	
	--TODO: Detect if gauge timed out naturally
	self.RestoreGauge = getCharacter()

	if ReadFloat(_bar+0x0C, true) == 0 then --Timer expired naturally
		ConsolePrint("Player dropped naturally")
		self.GaugeValue = 0
		self:RequestAllEnergy()
		self.NaturalDrop = true
	end
end

return EnergyLinkTask