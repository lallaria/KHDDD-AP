--Refunds certain items if the player dies while in a room

local RoomSaveTask = {}

RoomSaveTask.State = {
	Room = 0x00,
	Evt = 0x00,
	ItemIds = {},
	Exp = 0,
	ChestsSora = {},
	ChestsRiku = {}
}

RoomSaveTask.ValidTypes = {"Command", "Recipe", "Consumable", "Support", "Spirit", "World"}
RoomSaveTask.PrepareLoad = false

function RoomSaveTask:Init()
	self.State.Room = ReadByte(MemoryAddresses.room[gameVer])
	self.State.Evt = ReadByte(MemoryAddresses.evt[gameVer])
end

function RoomSaveTask:GetRoomChange() --Determine if the room has changed
	local _currRoom = roomInfo[2]
	local _currEvt = roomInfo[3]
	if self.State.Room ~= _currRoom or self.State.Evt ~= _currEvt then
		ConsolePrint("Room changed")
		self:OnRoomChange()
		self.State.Room = _currRoom
		self.State.Evt = _currEvt
	end
end

function RoomSaveTask:OnRoomChange()
	if self.PrepareLoad then --Redeem items before clearing the list to be safe
		self:RestoreItems()
		self.PrepareLoad = false
	end
	self.State.Exp = 0
	self.State.ItemIds = {} --Vanilla room save occurred; clear list
	self.State.ChestsSora = {}
	self.State.ChestsRiku = {}
end

function RoomSaveTask:StoreItem(id) --Store items to prepare for potential room save
	local _targetItem = getItemById(id)
	if hasValue(self.ValidTypes, _targetItem.Type) then --Can be saved
		table.insert(self.State.ItemIds, id)
	end	
end

function RoomSaveTask:StoreChest(index, bit, soraOrRiku)
	ConsolePrint("Storing Chests - Index: "..tostring(index).." Bit: "..tostring(bit).." Character: "..tostring(soraOrRiku))
	if soraOrRiku == 0 then
		table.insert(self.State.ChestsSora, {MemoryAddresses.soraChests[gameVer]+chests.sora[index].offset, bit})
	else
		table.insert(self.State.ChestsRiku, {MemoryAddresses.rikuChests[gameVer]+chests.riku[index].offset, bit})
	end
end

function RoomSaveTask:CheckPlayerState() --See if player has died
	local _ptr = GetPointer(MemoryAddresses.deathPtr[gameVer], MemoryAddresses.deathOffset)
	if not self.PrepareLoad then
		if ReadByte(_ptr, true) == 3 then --Player died
			ConsolePrint("Player died; preparing load from room save")
			self.PrepareLoad = true
		end
	else
		self:RestoreChests() --Chests need to be restored before player state can update
		if ReadByte(_ptr, true) == 0x01 or ReadByte(_ptr, true) == 0x02 then --Player respawned
			ConsolePrint("Restoring items")
			self:RestoreItems()
			if not Configs.VanillaLevels then
				ItemHandler:RebuildStats()
			end
  			ItemHandler:RebuildAbilities()
			self.PrepareLoad = false
		end
	end
end

function RoomSaveTask:StoreExp()
	local _exp = ReadInt(MemoryAddresses.soraExp[gameVer])
	if _exp > self.State.Exp then
		self.State.Exp = _exp
	end
end

function RoomSaveTask:RestoreChests()
	local _bits = {0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80}

	for i=1, #self.State.ChestsSora do
		local _data = self.State.ChestsSora[i]
		local _currVal = ReadByte(_data[1])
		local _chestBits = toBits(_currVal)
		if _chestBits[_data[2]] == 0 or _chestBits[_data[2]] == nil then
			WriteByte(_data[1], _currVal+_bits[_data[2]])
		end
	end

	for i=1, #self.State.ChestsRiku do
		local _data = self.State.ChestsRiku[i]
		local _currVal = ReadByte(_data[1])
		local _chestBits = toBits(_currVal)
		if _chestBits[_data[2]] == 0 or _chestBits[_data[2]] == nil then
			WriteByte(_data[1], _currVal+_bits[_data[2]])
		end
	end
end

function RoomSaveTask:RestoreItems() --Put items likely lost to death back into inventory
	for i=1, #self.State.ItemIds do
		sendToInv(self.State.ItemIds[i])
	end
	ConsolePrint("Restoring EXP")
	if self.State.Exp > ReadInt(MemoryAddresses.soraExp[gameVer]) then
		WriteInt(MemoryAddresses.soraExp[gameVer], self.State.Exp)
	end
end

return RoomSaveTask