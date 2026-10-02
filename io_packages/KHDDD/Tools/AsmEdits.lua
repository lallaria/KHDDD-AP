local AsmEdits = {}

--Fills bytes[off+1..off+4] with the rel32 of a jmp/jcc: target minus the address of the next instruction, little-endian
local function putRel32(bytes, off, nextInstr, target)
  local d = (target - nextInstr) & 0xFFFFFFFF
  for i = 1, 4 do
    bytes[off + i] = (d >> (8 * (i - 1))) & 0xFF
  end
end

--Writes a 6-byte jcc (0F op rel32) at addr that goes to target
function AsmEdits:writeJcc(addr, op, target)
  local bytes = {0x0F, op, 0, 0, 0, 0}
  putRel32(bytes, 0x02, addr + 6, target)
  WriteArray(addr, bytes)
end

function AsmEdits:Init()
	self:OpenAllChests()
	self:IconReplace()
  self:LinkBoardIcons()
end

--Change/Nop functions that would prevent chests from opening
function AsmEdits:OpenAllChests()
	--Make ability chests open-able
	local _abFunc = {0x376EB5, 0x376D25} --TODO: EGS address was 0x376EA4; verify
    WriteArray(_abFunc[gameVer], {0x90, 0x90, 0x90, 0x90, 0x90})

    --Make world item chests open-able, even if the world item is already in inventory
    local _worldChest = {0x271A43, 0x2719E3} --TODO: EGS addess was 0x271A33; verify
    WriteArray(_worldChest[gameVer], {0x39, 0xC0, 0x90, 0x90, 0x90})

    local _abChest = {0x271956, 0x2718F6} --TODO: EGS address was 0x271946; verify
    WriteArray(_abChest[gameVer], {0xB0, 0x01})

    --Prevent battle levels from resetting from certain story events
    local _btlFunc = {0x23A980, 0x23A9F0} --TODO: EGS address was 0x23A970; verify
    WriteArray(_btlFunc[gameVer], {0x90, 0x90})
end

 local BoardIconMax = 0x15 --HP, the last anim name; the table continues with sound names

--The following function contains ai-generated code; documentation included
function AsmEdits:LinkBoardIcons()
    --Link board node icons. The PC link board's build (CDEAbilityLinkBoard@HD, Steam 0x45ED80) gives each reward node an
    --icon index from its reward's command category; the node then plays the f_de505.txa anim that the name table at
    --{0x9DF3F0, 0x9DF3E0} lists at that index. Its icon store now jumps to a stub that reads byte 3 of the node's
    --lbt_list.bin reward record, which the game never reads: 0x80 | index replaces the icon (LBoard:SetNodeIcon), any
    --other value keeps the game's. Board open and L/R spirit switches rebuild every icon, so a change shows on the next one.
    local _storeSite = {0x45F0A8, 0x45ECD8} --was: 88 42 02 44 0F B6 C0  mov [rdx+2], al; movzx r8d, al
    local _storeNext = {0x45F0AF, 0x45ECDF} --test al, al, then the upgrade and stat icon special cases
    local _nodeDone = {0x45F145, 0x45ED75}  --inc r11d, the node loop's continue
    local _stub = 0x77FB20
    local _code = {
      0x44, 0x0F, 0xB6, 0x42, 0x0A,             --+0x00          movzx r8d, byte [rdx+0xA]  reward slot, already checked < 0x10
      0x45, 0x6B, 0xC0, 0x0C,                   --+0x05          imul r8d, r8d, 12
      0x4C, 0x03, 0x87, 0x48, 0x03, 0x00, 0x00, --+0x09          add r8, [rdi+0x348]        spirit's lbt_list block, already checked non-null
      0x45, 0x0F, 0xB6, 0x40, 0x03,             --+0x10          movzx r8d, byte [r8+3]
      0x41, 0x83, 0xC0, 0x80,                   --+0x15          add r8d, -0x80
      0x41, 0x83, 0xF8, BoardIconMax,           --+0x19          cmp r8d, BoardIconMax
      0x77, 0x09,                               --+0x1D          ja +0x28
      0x44, 0x88, 0x42, 0x02,                   --+0x1F          mov [rdx+2], r8b
      0xE9, 0, 0, 0, 0,                         --+0x23          jmp node done              skips the special cases
      0x88, 0x42, 0x02,                         --+0x28 keep:    mov [rdx+2], al
      0x44, 0x0F, 0xB6, 0xC0,                   --+0x2B          movzx r8d, al
      0xE9, 0, 0, 0, 0}                         --+0x2F          jmp store next
    putRel32(_code, 0x24, _stub + 0x28, _nodeDone[gameVer])
    putRel32(_code, 0x30, _stub + 0x34, _storeNext[gameVer])
    WriteArray(_stub, _code)
    local _jmp = {0xE9, 0, 0, 0, 0, 0x90, 0x90} --jmp stub; r8 is dead here, the loop redefines it before any read
    putRel32(_jmp, 0x01, _storeSite[gameVer] + 5, _stub)
    WriteArray(_storeSite[gameVer], _jmp)
end

--Big item pictures (the "OBTAINED" popup and menus) for key items other than 0x400, treats above 0x70D and toys above
--0x80C, which would otherwise show itxxxx.ctt, a black square. Rows are {first id, last id, file in item/jp/bin} and the
--first matching row wins. Names are at most 11 characters. Each file ships as raw/item/jp/bin/<name>.ctt (a loose
--remastered/ .dds never attaches to a name the game doesn't ship), laid out like the game's own item pictures:
--little-endian int32s {0x100, 1, -2, 0}; "<name>.dds" padded to 32 bytes and int32s {0x140, -1, .dds size, -2};
--item/jp/bin/itxxxx.ctt with <name> at 0x60, each byte +0x11; the square .dds, padded to 16 bytes. List it in mod.yml.
local ItemImages = {
  {0x0813, 0x0813, "it0813.ctt"}, --AP item: AP logo
  {0x080D, 0x080D, "it080d.ctt"}, --Lucky Emblem
  {0x041D, 0x041D, "it041d.ctt"}, --Recusant Sigil
  {0x0423, 0x0427, "it0423.ctt"}, --Sora's stat boosts: stat-up card
  {0x070F, 0x0713, "it0423.ctt"}, --Riku's stat boosts: stat-up card
  {0x0401, 0x0403, "it0401.ctt"}, --TWTNW Sora, Riku: the game's world logo, menu/*/camp/report/etc/bin/rp_top_wd_ico_07
  {0x0405, 0x0407, "it0405.ctt"}, --TT (ico_01)
  {0x0409, 0x040B, "it0409.ctt"}, --LCdC (ico_02)
  {0x040D, 0x040F, "it040d.ctt"}, --TG (ico_04)
  {0x0411, 0x0413, "it0411.ctt"}, --PP (ico_03)
  {0x0415, 0x0417, "it0415.ctt"}, --CotM (ico_05)
  {0x0419, 0x041B, "it0419.ctt"}, --SoS (ico_06)
  {0x041F, 0x0421, "it0405.ctt"}, --TT2, not an item yet
}

--Small item icons: the "OBTAINED" banner frame (frame table in itemget_02_n.l2d) and the pause menu icon id (icon.l2d
--draws sprite id - 0x64). Rows are {first id, last id, banner frame, menu icon}; KEEP leaves the game's own choice, and
--the first matching row wins.
local KEEP = 0xFFFF
local ItemIcons = {
  {0x0813, 0x0813, 5, KEEP},    --AP item: banner frame 5, which the shipped itemget_02_n.l2d points at the AP logo
  {0x080D, 0x080D, 6, 0x7A},    --Lucky Emblem: banner frame 6 and menu sprite 22, which the shipped layouts add or point at it
}
for id = 0x0401, 0x0421, 2 do --world items get the star, menu sprite 32; 0x041D is the Recusant Sigil
  if id ~= 0x041D then
    ItemIcons[#ItemIcons + 1] = {id, id, KEEP, 0x84}
  end
end

--The following function contains ai-generated code; documentation included
function AsmEdits:IconReplace()
    --Item icons from ItemIcons. The icon helper at {0x272560, 0x272500} takes the item id in esi and dil = 0 for the banner
    --frame or nonzero for the menu icon id, and returns ebx through its epilogue at {0x2726F3, 0x272693}. Right after it
    --computes the item's category into eax, a jmp now goes to a lookup at 0x77FE00 (unused .text tail, same in both builds):
    --a matching row whose value is not KEEP puts it in ebx and returns; otherwise the replaced cmp/ja run and the helper
    --continues to its category jump table.
    local _iconHookSite = {0x27257E, 0x27251E} --was: 83 F8 09 0F 87 6C 01 00 00  cmp eax, 9; ja epilogue
    local _iconDispatch = {0x272587, 0x272527} --the cdqe after that ja, leading to the category jump table
    local _iconEpilogue = {0x2726F3, 0x272693}
    local _iconLookup = 0x77FE00
    local _iconRows = _iconLookup + 0x50
    local _iconCode = {
      0x48, 0x8D, 0x0D, 0, 0, 0, 0,       --+0x00          lea rcx, [rows]
      0x0F, 0xB7, 0x11,                   --+0x07 row:     movzx edx, word [rcx]    first id; 0 ends the rows
      0x85, 0xD2,                         --+0x0A          test edx, edx
      0x74, 0x2E,                         --+0x0C          jz +0x3C
      0x39, 0xD6,                         --+0x0E          cmp esi, edx
      0x72, 0x24,                         --+0x10          jb +0x36
      0x0F, 0xB7, 0x51, 0x02,             --+0x12          movzx edx, word [rcx+2]  last id
      0x39, 0xD6,                         --+0x16          cmp esi, edx
      0x77, 0x1C,                         --+0x18          ja +0x36
      0x0F, 0xB7, 0x51, 0x04,             --+0x1A          movzx edx, word [rcx+4]  banner frame
      0x40, 0x84, 0xFF,                   --+0x1E          test dil, dil
      0x74, 0x04,                         --+0x21          jz +0x27
      0x0F, 0xB7, 0x51, 0x06,             --+0x23          movzx edx, word [rcx+6]  menu icon
      0x81, 0xFA, 0xFF, 0xFF, 0x00, 0x00, --+0x27          cmp edx, 0xFFFF          KEEP
      0x74, 0x0D,                         --+0x2D          je +0x3C
      0x89, 0xD3,                         --+0x2F          mov ebx, edx
      0xE9, 0, 0, 0, 0,                   --+0x31          jmp epilogue
      0x48, 0x83, 0xC1, 0x08,             --+0x36 next:    add rcx, 8
      0xEB, 0xCB,                         --+0x3A          jmp +0x07
      0x83, 0xF8, 0x09,                   --+0x3C no row:  cmp eax, 9
      0x0F, 0x87, 0, 0, 0, 0,             --+0x3F          ja epilogue
      0xE9, 0, 0, 0, 0}                   --+0x45          jmp dispatch
    putRel32(_iconCode, 0x03, _iconLookup + 0x07, _iconRows)
    putRel32(_iconCode, 0x32, _iconLookup + 0x36, _iconEpilogue[gameVer])
    putRel32(_iconCode, 0x41, _iconLookup + 0x45, _iconEpilogue[gameVer])
    putRel32(_iconCode, 0x46, _iconLookup + 0x4A, _iconDispatch[gameVer])
    local _iconRowBytes = {}
    for _, r in ipairs(ItemIcons) do --8-byte rows: u16 first id, u16 last id, u16 banner frame, u16 menu icon
      for _, v in ipairs(r) do
        table.move({v & 0xFF, v >> 8}, 1, 2, #_iconRowBytes + 1, _iconRowBytes)
      end
    end
    table.move({0, 0}, 1, 2, #_iconRowBytes + 1, _iconRowBytes) --a first id of 0 ends the rows
    assert(_iconRows + #_iconRowBytes <= 0x780000, "ItemIcons has too many rows for the .text tail")
    WriteArray(_iconRows, _iconRowBytes)
    WriteArray(_iconLookup, _iconCode)
    local _iconJmp = {0xE9, 0, 0, 0, 0, 0x90, 0x90, 0x90, 0x90} --jmp lookup; nop x4 fills the rest of the ja
    putRel32(_iconJmp, 0x01, _iconHookSite[gameVer] + 5, _iconLookup)
    WriteArray(_iconHookSite[gameVer], _iconJmp)

    --Banner frames above 5. The banner code turns frames 1-5 into layout times 1.0-5.0 through a switch (three copies) and
    --leaves 0.0, frame 0's keyblade, for any other frame. Each switch now converts the frame itself and jumps to where the
    --switch rejoins, 0x49 bytes on.
    local _bannerFrameSwitches = { --{{Steam, EGS} address, cvtsi2ss ModRM for xmm6 and the frame register}
      {{0x1B88CC, 0x1B893C}, 0xF1}, --was: 83 E9 01 74 3C ...  sub ecx, 1; je ...
      {{0x1B901F, 0x1B908F}, 0xF3}, --was: 83 EB 01 74 3C ...  sub ebx, 1; je ...
      {{0x1B9188, 0x1B91F8}, 0xF3}, --was: 83 EB 01 74 3C ...  sub ebx, 1; je ...
    }
    for _, s in ipairs(_bannerFrameSwitches) do
      WriteArray(s[1][gameVer], {0xF3, 0x0F, 0x2A, s[2], 0xEB, 0x43}) --cvtsi2ss xmm6, frame; jmp +0x49
    end

    --Item pictures from ItemImages. The image name dispatcher at {0x26F770, 0x26F710} keeps the item id in edi and the name
    --buffer in rbx; its key, treat and toy cases send ids without a picture of their own to the default case, which copies
    --"itxxxx.ctt". Those three branches now go to a lookup in the unused tail of .text past its last function (was: 00 bytes,
    --0x77FC00 in both builds), followed by the rows. Each entry rebuilds the full id in edi; a matching row's 12-byte name
    --is copied to rbx and the lookup returns like the dispatcher does, and no match still goes to the default case.
    local _keyImageJne = {0x26F7EA, 0x26F78A}  --was: 0F 85 DF 04 00 00  jne default (key items other than 0x400)
    local _treatImageJa = {0x26F87C, 0x26F81C} --was: 0F 87 4D 04 00 00  ja default (treats above 0x70D; edi = id - 0x700)
    local _toyImageJa = {0x26FAD6, 0x26FA76}   --was: 0F 87 F3 01 00 00  ja default (toys above 0x80C; edi = id - 0x800)
    local _imageDefault = {0x26FCCF, 0x26FC6F}
    local _lookup = 0x77FC00
    local _rows = _lookup + 0x50
    local _code = {
      0x81, 0xC7, 0x00, 0x08, 0x00, 0x00, --+0x00 toy entry:   add edi, 0x800
      0xEB, 0x06,                         --+0x06              jmp +0x0E
      0x81, 0xC7, 0x00, 0x07, 0x00, 0x00, --+0x08 treat entry: add edi, 0x700
      0x48, 0x8D, 0x05, 0, 0, 0, 0,       --+0x0E key entry:   lea rax, [rows]
      0x0F, 0xB7, 0x08,                   --+0x15 row:         movzx ecx, word [rax]    first id; 0 ends the rows
      0x85, 0xC9,                         --+0x18              test ecx, ecx
      0x0F, 0x84, 0, 0, 0, 0,             --+0x1A              jz default
      0x39, 0xCF,                         --+0x20              cmp edi, ecx
      0x72, 0x20,                         --+0x22              jb +0x44
      0x0F, 0xB7, 0x48, 0x02,             --+0x24              movzx ecx, word [rax+2]  last id
      0x39, 0xCF,                         --+0x28              cmp edi, ecx
      0x77, 0x18,                         --+0x2A              ja +0x44
      0x48, 0x8B, 0x48, 0x04,             --+0x2C              mov rcx, [rax+4]         name bytes 0-7
      0x48, 0x89, 0x0B,                   --+0x30              mov [rbx], rcx
      0x8B, 0x48, 0x0C,                   --+0x33              mov ecx, [rax+0x0C]      name bytes 8-11
      0x89, 0x4B, 0x08,                   --+0x36              mov [rbx+8], ecx
      0x48, 0x8B, 0x5C, 0x24, 0x30,       --+0x39              mov rbx, [rsp+0x30]      the dispatcher's own epilogue
      0x48, 0x83, 0xC4, 0x20,             --+0x3E              add rsp, 0x20
      0x5F,                               --+0x42              pop rdi
      0xC3,                               --+0x43              ret
      0x48, 0x83, 0xC0, 0x10,             --+0x44 next row:    add rax, 0x10
      0xEB, 0xCB}                         --+0x48              jmp +0x15
    putRel32(_code, 0x11, _lookup + 0x15, _rows)
    putRel32(_code, 0x1C, _lookup + 0x20, _imageDefault[gameVer])
    local _rowBytes = {}
    for _, r in ipairs(ItemImages) do --16-byte rows: u16 first id, u16 last id, name padded with NULs to 12 bytes
      assert(#r[3] <= 11, "ItemImages name longer than 11 characters: " .. r[3])
      local _row = {r[1] & 0xFF, r[1] >> 8, r[2] & 0xFF, r[2] >> 8, string.byte(r[3], 1, -1)}
      for i = #_row + 1, 16 do _row[i] = 0 end
      table.move(_row, 1, 16, #_rowBytes + 1, _rowBytes)
    end
    table.move({0, 0, 0, 0}, 1, 4, #_rowBytes + 1, _rowBytes) --a first id of 0 ends the rows
    assert(_rows + #_rowBytes <= _iconLookup, "ItemImages has too many rows for the .text tail")
    WriteArray(_rows, _rowBytes)
    WriteArray(_lookup, _code)
    self:writeJcc(_keyImageJne[gameVer], 0x85, _lookup + 0x0E)
    self:writeJcc(_treatImageJa[gameVer], 0x87, _lookup + 0x08)
    self:writeJcc(_toyImageJa[gameVer], 0x87, _lookup)
end

return AsmEdits