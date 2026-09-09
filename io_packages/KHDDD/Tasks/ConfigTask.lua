local ConfigTask = {}

ConfigTask.State = {
	SavedKbStats = {},
	ExpSet = false
}

ConfigTask.SlotDataTypes = {
  KeybladeStats = 0,
  Character = 1,
  SkipDI = 2,
  Exp = 3,
  SkipLC = 4,
  FastGoMode = 5,
  RecipeCnt = 6,
  WinCon = 7,
  StatBoost = 8,
  LordKyroo = 9,
  LocalItemNotifs = 10,
  RemoteItemNotifs = 11,
  PatchInfo = 12,
  VanillaLevels = 13,
  EmblemReqs = 14
}

function ConfigTask:ParseSlotData(slotType, msgVal)
	if slotType == self.SlotDataTypes.KeybladeStats then
      self:SaveKeybladeStats(msgVal)
    elseif slotType == self.SlotDataTypes.Character then
      self:SetCharacter(msgVal)
    elseif slotType == self.SlotDataTypes.SkipDI then
      self:SetDI(msgVal)
    elseif slotType == self.SlotDataTypes.Exp then
      self:SetExpMult(msgVal)
    elseif slotType == self.SlotDataTypes.SkipLC then
      self:SetLC(msgVal)
    elseif slotType == self.SlotDataTypes.FastGoMode then
    	self:SetFastGoMode(msgVal)
    elseif slotType == self.SlotDataTypes.RecipeCnt then
      self:SetRecipeReq(msgVal)
    elseif slotType == self.SlotDataTypes.WinCon then
      self:SetGoal(msgVal)
    elseif slotType == self.SlotDataTypes.StatBoost then
    	self:SetStatBoost(msgVal)
    elseif slotType == self.SlotDataTypes.LordKyroo then
    	self:SetLordKyroo(msgVal)
    elseif slotType == self.SlotDataTypes.LocalItemNotifs then
    	self:SetItemNotifs(msgVal)
    elseif slotType == self.SlotDataTypes.RemoteItemNotifs then
    	self:SetRemoteNotifs(msgVal)
    elseif slotType == self.SlotDataTypes.PatchInfo then
    	self:PatchGame(msgVal)
    elseif slotType == self.SlotDataTypes.VanillaLevels then
    	self:SetVanillaLevels(msgVal)
    elseif slotType == self.SlotDataTypes.EmblemReqs then
    	self:SetEmblemReq(msgVal)
    end
end

function ConfigTask:SaveKeybladeStats(msgVals)
	--Save this stat
	--local _kbStr = tonumber(msgVals[1])
	--local _kbMag = tonumber(msgVals[2])
	--table.insert(self.State.SavedKbStats, msgVals)

	for i=1, #msgVals do
		if i%2 == 0 then --Ensure we have the stat pairs
			table.insert(self.State.SavedKbStats, {msgVals[i-1], msgVals[i]})
			local _kbStr = tonumber(msgVals[i-1])
			local _kbMag = tonumber(msgVals[i])

			--Apply this stat
			if #self.State.SavedKbStats-1 < 30 then
				--Apply the stats
				ConsolePrint("Recording str "..tostring(_kbStr).." mag "..tostring(_kbMag).." for kb "..tostring(#self.State.SavedKbStats-1))

				if #self.State.SavedKbStats-1 < 15 then --Sora keyblade
					WriteArray(KeybladeStats.soraBase[gameVer] + (KeybladeStats.offset * (#self.State.SavedKbStats-1)), {_kbStr, _kbMag})
				else --Riku keyblade
					WriteArray(KeybladeStats.rikuBase[gameVer] + ((KeybladeStats.offset) * (#self.State.SavedKbStats-16)), {_kbStr, _kbMag})
				end
			end
		end
	end
end

function ConfigTask:PatchGame(msgVals)
	local _soraChestRange = {2650211, 2650435}
	local _rikuChestRange = {2650436, 2650648}
	local _levelRange = {2660000, 2660200}

	for i=1, #msgVals do
		if i%2 == 0 then --Message pair
			local _locId = tonumber(msgVals[i-1])
			local _itemId = tonumber(msgVals[i]) 

			--Chest Patching
			--Each Chest entry is 8 bytes
			--Location IDs are not logged in same order as chests appear in itemtd

			if _locId >= _soraChestRange[1] and _locId <= _rikuChestRange[2] then --Location is a chest
				local _useAddr = MemoryAddresses.chestDataR[gameVer]
				local _useChar = 1
				if _locId <= _soraChestRange[2] then --Sora Chest
					_useAddr = MemoryAddresses.chestDataS[gameVer]
					_useChar = 0
				end

				local _chestStart = _useAddr+0x1A --ID of first item
				--local _chestOffset = _locId - _soraChestRange[1]
				local _chestInfo = getChestById(_locId, _useChar)
				local _chestOffset = _locId - _chestInfo.locationIDStart + 1

				_itemId = PatchTask:ChangeToCompatibleItem(_itemId, true)

				local _itemInfo = getItemById(_itemId)
				local _itemBytes = _itemInfo.Bytes

				--ConsolePrint("Location Offset: "..tostring(_chestOffset))

				--TODO: Traverse Town Fountain Plaza Balloon [Sora] not recorded correctly
				local _entries = _chestInfo.entries
				local _itemDest = _chestStart+(_entries[_chestOffset]*8)

				--ConsolePrint("Item Dest: "..tostring(_itemDest))


				if #_itemBytes == 1 then
					table.insert(_itemBytes, 0x00)
				end

				if _itemDest > 0x00 then
					WriteArray(_itemDest, _itemBytes)
				end
				--WriteArray(_chestStart+_chestOffset, _itemBytes)
				--ConsolePrint("Patched Chest")
			elseif _locId > _levelRange[1] and _locId < _levelRange[2] then --Level
				_itemId = PatchTask:ChangeToCompatibleItem(_itemId)
				PatchTask:AssignLevelRewards(_locId, _itemId)
			else --Reward
				if PatchTask.MissionDict[tostring(_locId)] ~= nil then
					_itemId = PatchTask:ChangeToCompatibleItem(_itemId, false, true)
					local _itemInfo = getItemById(_itemId)
					PatchTask:AssignMissionRewards(_locId, _itemInfo.Bytes)
				elseif PatchTask.BonusSlots[tostring(_locId)] ~= nil then
					_itemId = PatchTask:ChangeToCompatibleItem(_itemId, false, false)
					local _itemInfo = getItemById(_itemId)
					PatchTask:AssignBonusRewards(_locId, _itemInfo.Name)
				else
					_itemId = PatchTask:ChangeToCompatibleItem(_itemId, false, true)
					local _itemInfo = getItemById(_itemId)
					PatchTask:SetRewardForLocation(_locId, _itemInfo.Bytes)
				end
			end
		end
	end
end

--Config Setters
function ConfigTask:SetCharacter(msgVal)
	Configs.Character = tonumber(msgVal[1])
	ConsolePrint("Setting Character to "..msgVal[1])
end

function ConfigTask:SetRecipeReq(msgVal)
	Configs.RecipeReqs = tonumber(msgVal[1])
	local _reqStr = "Required Recipes: "..msgVal[1]
	writeTxtToGame(ItemOverwrite.recipeDescAddr[gameVer], _reqStr, 1)
	ConsolePrint("Setting required recipes to "..msgVal[1])
end

function ConfigTask:SetEmblemReq(msgVal)
	Configs.EmblemReqs = tonumber(msgVal[1])
	local _reqStr = "Required: "..msgVal[1]
	writeTxtToGame(ItemOverwrite.toy14DescAddr[gameVer], _reqStr, 1)
	ConsolePrint("Setting required emblems to "..msgVal[1])
end

function ConfigTask:SetGoal(msgVal)
	Configs.Goal = tonumber(msgVal[1])
	ConsolePrint("Goal value: "..tostring(Configs.Goal))
	ConsolePrint("Setting goal to "..tostring(msgVal[1]))
end

function ConfigTask:SetDI(msgVal)
	if msgVal[1] == "1" then --Want to play DI
		Configs.SkipDI = false
	else
		Configs.SkipDI = true
	end
	ConsolePrint("Setting DI Skip to "..msgVal[1])
end

function ConfigTask:SetLC(msgVal)
	if msgVal[1] == "1" then --Want to skip LC
		Configs.SkipLightCycle = true
	else
		Configs.SkipLightCycle = false
	end
	ConsolePrint("Setting LC Skip to "..msgVal[1])
end

function ConfigTask:SetFastGoMode(msgVal)
	if msgVal[1] == "1" then
		Configs.FastGoMode = true
	else
		Configs.FastGoMode = false
	end
	ConsolePrint("Setting Fast GO to "..msgVal[1])
end

function ConfigTask:SetExpMult(msgVal)
	Configs.ExpMult = tonumber(msgVal[1])
	self:WriteExpTable()
	ConsolePrint("Setting Exp Mult to "..msgVal[1])
end

function ConfigTask:SetStatBoost(msgVal)
	Configs.StatBonus = tonumber(msgVal[1])
	ConsolePrint("Setting Stat Bonus to "..msgVal[1])
end

function ConfigTask:SetLordKyroo(msgVal)
	ConsolePrint("Setting Lord Kyroo to "..msgVal[1])
	if msgVal[1] == "1" then
		Configs.LordKyroo = true
	else
		Configs.LordKyroo = false
	end
end

function ConfigTask:SetItemNotifs(msgVal)
	ConsolePrint("Setting Received Notifications to "..msgVal[1])
	Configs.LocalItemNotifs = tonumber(msgVal[1])
end

function ConfigTask:SetRemoteNotifs(msgVal)
	ConsolePrint("Setting Sent Notifications to "..msgVal[1])
	Configs.RemoteItemNotifs = tonumber(msgVal[1])
end

function ConfigTask:SetVanillaLevels(msgVal)
	ConsolePrint("Setting Vanilla Levels to "..msgVal[1])
	if msgVal[1] == "1" then
		Configs.VanillaLevels = true
	else
		Configs.VanillaLevels = false
	end
end

function ConfigTask:WriteExpTable()
	if self.State.ExpSet or ReadByte(MemoryAddresses.expTable[gameVer]) < 0x28 then
		return
	end
	local _realExpMult = 1/Configs.ExpMult
	for x=0, 98 do
		local _nextAddr = MemoryAddresses.expTable[gameVer]+(x*4)
		local _tableVal = ReadInt(_nextAddr)
		WriteInt(_nextAddr, math.floor(_tableVal*_realExpMult))
	end
	self.State.ExpSet = true
end

return ConfigTask