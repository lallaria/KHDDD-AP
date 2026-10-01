local LBoard = {}

--Items used for gate requirements
local _checkItem1 = {0xA4C538, 0xA4BDB8} --First blank toy for spirit board
local _checkItem2 = {0xA4C53C, 0xA4BDBC} --Second blank toy for spirit board
local _prizeIdNameStart = {0x1096A9B8} --34 bytes per name
local _commandHeader = {0x10B7D624}

--Determine if player is in the spirit menu
local _inSpiritMenu = {0xA9B2DC, 0xA9AB5C}
local _canMove = {0xA9B2F4, 0xA9AB74}

--Find Spirit ID of board that is currently being viewed
local _activeBoard = {0x9E9A40} --TODO: Find EGS address
local _activeBoardOffset = 0x490
local _cursorPosOffset = 0x350 --Uses same addr as activeboard
--+0 is x pos, +4 is y pos

LBoard.GateCoords = {
	--First and Second indexes are coordinates for the gates
	--Third index is the type of gate (1 or 2 for Sora or Riku world)
	--Fourth index is the number of items needed to fulfill
	{{2, 0, 1, 5}, {2, 2, 1, 3}}, --Meow Wow
	{{3, 1, 1, 4}, {1, 3, 1, 2}}  --Tama Sheep
}

LBoard.SpiritItems = {}

local _pos = {}

function LBoard:FillBoardRewards() --Fill board nodes with generic item
	local _padding = 12
	local _rewardCnt = 864
	for i=1, _rewardCnt do
		--Replace all items with PRIZE_ID_Dream10
		local _base = 0x3B
		local _mod = (i-1) % 16

		WriteArray(MemoryAddresses.boardRewards[gameVer]+(_padding*(i-1)), {0x3B+_mod, 0x01, 0x3B+_mod, 0x01, 0x3B+_mod, 0x01, 0x3B+_mod, 0x01, 0x01, 0x00, 0x00}) --Last few bytes are for disposition?
	end
	self:WriteFillerNames()
end

function LBoard:WriteFillerNames()
	local _numOfItems = 15
	local _padding = 34
	for i=0, _numOfItems do
		writeTxtToGame(_prizeIdNameStart[gameVer]+(i*_padding), "Archipelago Item", 3)
	end
end

function LBoard:WriteBoardReward(spirit, id, nodeNum) --Assign a specific reward to node
	local _padding = 12
	local _initialSpot = (spirit-1)*16
	local _nodeToChange = _initialSpot+(nodeNum)
	ConsolePrint("Writing Board Reward for spirit "..tostring(spirit).." and node "..tostring(nodeNum))
	WriteArray(MemoryAddresses.boardRewards[gameVer]+(_padding*_nodeToChange), {id[1], id[2], id[1], id[2], id[1], id[2], id[1], id[2]})
end

function LBoard:ChangeGateReqs(spirit, gateNum, gateType, cnt)
	--Spirit: Which spirit to change the gate for
	--GateNum: Whether Gate 1 or Gate 2 are being changed
	--GateType: 1 for Sora Worlds Cleared, 2 for Riku Worlds Cleared
	--Cnt: How many worlds are needed to clear

	self.GateCoords[spirit][gateNum][3] = gateType
	self.GateCoords[spirit][gateNum][4] = cnt
end

function LBoard:CheckCursorPos() --Returns x and y coordinates of cursor on the link board
	local _cursorAddr = GetPointer(_activeBoard[gameVer], _cursorPosOffset)
	return {ReadByte(_cursorAddr, true), ReadByte(_cursorAddr+0x04, true)}
end

function LBoard:ChangeItemNames()
	local _currBoardAddr = GetPointer(_activeBoard[gameVer], _activeBoardOffset)
	local _spiritId = ReadByte(_currBoardAddr, true)

	if self.SpiritItems[_spiritId] ~= nil then
		for x=1, 16 do
			if self.SpiritItems[_spiritId][x] ~= nil then
				local _padding = 34
				writeTxtToGame(_prizeIdNameStart[gameVer]+(_padding*(x-1)), self.SpiritItems[_spiritId][x], 2)
			end
		end
	end
end

boardVals = {}
local _spiritInv = {0xA45A70, 0xA452F0}
function LBoard:CheckRedeems()
	local _partyLimit = 102
	local _redeemOffset = 0x56 --86
	for x=0, _partyLimit do
		if boardVals[x+1] == nil then --Set board vals if not already defined
			boardVals[x+1] = ReadArray(_spiritInv[gameVer]+(x*0x100)+_redeemOffset, 2)
		end
		local _boardVal = boardVals[x+1]
		local _currVal = ReadArray(_spiritInv[gameVer]+(x*0x100)+_redeemOffset, 2)
		if _currVal[1] > _boardVal[1] then --One of the first 8 nodes redeemed
			_bitTbl = toBits(_currVal[1] - _boardVal[2])
			for bit=1, #_bitTbl do
				if _bitTbl[bit] == 1 then
					self:RedeemNode(ReadByte(_spiritInv[gameVer]+(x*0x100)), bit)
				end
			end
		end
		if _currVal[2] > _boardVal[2] then --One of the last 8 nodes redeemed
			_bitTbl = toBits(_currVal[2] - _boardVal[2])
			for bit=1, #_bitTbl do
				self:RedeemNode(ReadByte(_spiritInv[gameVer]+(x*0x100)), bit+8)
			end
		end

		--Update board vals
		boardVals[x+1] = _currVal
	end
end

function LBoard:RedeemNode(spiritId, nodeNum)
	SendToApClient(MessageTypes.NodeChecked, {tostring(spiritId), tostring(nodeNum)})
end

function LBoard:NameToBoard(spiritId, nodeNum, pName)
	ConsolePrint("Attempting to write name")
	local _addToBoard = Boards[spiritId]
	if _addToBoard ~= nil then
		for y=1, #_addToBoard do
			for x=1, #_addToBoard[y] do
				if _addToBoard[y][x][1] == nodeNum then
					table.insert(_addToBoard[y][x], pName)
					ConsolePrint(pName.." written to "..tostring(y)..","..tostring(x))
				end
			end
		end
	else
		ConsolePrint("Failed to write requested name")
	end
end

function LBoard:DisplayOwningPlayer()
	local _nameWritten = false

	--local _pos = self:CheckCursorPos()
	local _x = _pos[1]
	local _y = _pos[2]
	local _spiritPtr = GetPointer(_activeBoard[gameVer], _activeBoardOffset)
	local _activeSpirit = ReadByte(_spiritPtr, true)

	local _brdScan = Boards[_activeSpirit]

	if _brdScan ~= nil then
		if _brdScan[_y+1] ~= nil then
			if _brdScan[_y+1][_x+1] ~= nil then
				if #_brdScan[_y+1][_x+1] > 1 then --Name present in node
					writeTxtToGame(_commandHeader[gameVer], _brdScan[_y+1][_x+1][2], 1)
					_nameWritten = true
				end
			end
		end
	end
		

	if _nameWritten == false then
		writeTxtToGame(_commandHeader[gameVer], "Command", 1)
	end

end

local _worldsBeaten = {0, 0}
function LBoard:CheckGateReqs()

	--For setting required items
	local _maxReq = 7 ----At least 7 items are needed
	local _baseItm = 100-_maxReq

	--Are we hovering over a gate
	if self.GateCoords[current_spirit] == nil then
		return
	end

	--Function is called whenever spiritId changes

	--Gate 1 conditions are tied to amount of blank item 1
	--Gate 2 conditions are tied to amount of blank item 2

	local _blank1Amt = _baseItm+(self:WorldsBeaten(self.GateCoords[current_spirit][1][3]))
	local _blank2Amt = 0
	if self.GateCoords[_activeSpirit][2] ~= nil then --Spirit has 2 gates
		_blank2Amt = _baseItm+(self:WorldsBeaten(self.GateCoords[current_spirit][2][3]))
	end

	WriteArray(_checkItem1[gameVer], {0x01, 0x08, _blank1Amt})
	if _blank2Amt > 0 then
		WriteArray(_checkItem2[gameVer], {0x02, 0x08, _blank2Amt})
	end
end

function LBoard:WorldsBeaten(character)
	local _worldsBeaten = 0
	if character == 1 then --Tally Sora worlds
		local _soraFlags = {
			ReadByte(WorldFlags.laCiteDesCloches.sora.story[gameVer]),
			ReadByte(WorldFlags.theGrid.sora.story[gameVer]),
			ReadByte(WorldFlags.prankstersParadise.sora.story[gameVer]),
			ReadByte(WorldFlags.countryOfMusketeers.sora.story[gameVer]),
			ReadByte(WorldFlags.symphonyOfSorcery.sora.story[gameVer]),
			ReadByte(WorldFlags.traverseTown.sora.story[gameVer]+0x03),
			ReadByte(WorldFlags.theWorldThatNeverWas.sora.story[gameVer])
		}
		for x in _soraFlags do
			if x > 0x10 then
				_worldsBeaten = _worldsBeaten + 1
			end
		end
	else --Tally Riku worlds
		local _rikuFlags = {
			ReadByte(WorldFlags.laCiteDesCloches.riku.story[gameVer]),
			ReadByte(WorldFlags.theGrid.riku.story[gameVer]),
			ReadByte(WorldFlags.prankstersParadise.riku.story[gameVer]),
			ReadByte(WorldFlags.countryOfMusketeers.riku.story[gameVer]),
			ReadByte(WorldFlags.symphonyOfSorcery.riku.story[gameVer]),
			ReadByte(WorldFlags.traverseTown.riku.story[gameVer]+0x02),
			ReadByte(WorldFlags.theWorldThatNeverWas.riku.story[gameVer]+0x01) --For defeating ansem
		}
		for x in _rikuFlags do
			if x > 0x10 then
				_worldsBeaten = _worldsBeaten + 1
			end
		end
	end
	return _worldsBeaten
end

current_spirit = 0
function LBoard:CheckSpiritChange()
	local _spiritPtr = GetPointer(_activeBoard[gameVer], _activeBoardOffset)
	local _activeSpirit = ReadByte(_spiritPtr, true)

	if _activeSpirit > 0 and _activeSpirit < 55 then
		if _activeSpirit ~= current_spirit then
			current_spirit = _activeSpirit
			self:OnSpiritChange()
		end
	end
end

function LBoard:OnSpiritChange()
	self:CheckGateReqs()
end

local _inMenu = false
function LBoard:Update()
	--Check if player is in the spirit menu
	if ReadByte(_inSpiritMenu[gameVer]) ~= 0x06 or ReadByte(_canMove[gameVer]) ~= 0x04 then
		if _inMenu then --TODO: Find condition for being specifically on the link board
			self:Exit()
			_inMenu = false
		end
		return
	end
	_inMenu = true

	_pos = self:CheckCursorPos()
	self:CheckGateReqs()
	self:ChangeItemNames()
	self:CheckRedeems()
	self:DisplayOwningPlayer()
end

function LBoard:Exit() --Player left the link board
	self:WriteFillerNames()
end

return LBoard