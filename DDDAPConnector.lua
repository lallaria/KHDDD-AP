---------------------------------------------------
------ Kingdom Hearts Dream Drop Distance AP ------
------                by Lux                 ------
---------------------------------------------------
------ Special Thanks to Sonicshadowsilver2, Meebo, & Krujo
---------------------------------------------------

--LOCAL TESTING NOTES:
--Deck Up Riku item in-game rewards Strength Up Riku in AP
--Hide world and stat key item descriptions when not paused
--Sora level 8 did not display level up text (Faith)
--Maybe read level text on the actual prompt to determine which rewards to display?

local socket = require("socket")
ItemHandler = require("KHDDD.Items.ItemHandler")
local ItemDefs = require("KHDDD.Items.ItemDefs")
local Spirits = require("KHDDD.Items.Spirits")
local LocationDefs = require("KHDDD.Locations.LocationDefs")
local LocationHandler = require("KHDDD.Locations.LocationHandler")
local StoryHandler = require("KHDDD.Locations.StoryHandler")
local PromptTask = require("KHDDD.Tasks.PromptTask")
local ConfigTask = require("KHDDD.Tasks.ConfigTask")
RoomSaveTask = require("KHDDD.Tasks.RoomSaveTask")
local SoftlockTask = require("KHDDD.Tasks.SoftlockTask")
local MessageHandler = require("KHDDD.Items.MessageHandler")
WorldHandler = require("KHDDD.Locations.WorldHandler")
PatchTask = require("KHDDD.Tasks.PatchTask")

LUAGUI_NAME = "DDD AP Connector [Socket]"
LUAGUI_AUTH = "Lux"
LUAGUI_DESC = "Kingdom Hearts DDD AP Integration using Socket"

--Game Version
local _isEpic = 0x7F7109
local _isSteam = 0x7F7041

gameVer = 0 --1 for Steam; 2 for Epic


--Define Globals
local gameID = GAME_ID
local engineType = ENGINE_TYPE

local canExecute = false
local gameStarted = false
local connectionInitialized = false

local handshake = false

frameCount = 0
connected = false

local client



-- ############################################################
-- ####################  Globals  #############################
-- ############################################################
--  --rikuKeyblades = 0xA4C288,
MemoryAddresses = { --Primary memory addresses to reference
  keyblades = {0xA4C264, 0xA4BAE4},
  --rikuKeyblades = {0xA4C2A2, 0xA4BB22},
  rikuKeyblades = {0xA4C284, 0xA4BB04},
  commandStockStart = {0xA4C6D4, 0xA4BF44},
  commandStock = {0xA4C77C, 0xA4BFEC},
  commandDeckPopup = {0xA4C404, 0xA4BC84},
  equippedCommands = {0xA4D9D8, 0xA4D258},
  dodgeRollStock = {0xA4C70C, 0xA4BF8C},
  airSlideStock = {0xA4C714, 0xA4BF94},
  blockStock = {0xA4C71C, 0xA4BF9C},
  consumableStart = {0xA4C6FC, 0xA4BF7C},
  actionFlags = {0xA98088, 0xA97908},
  commandActions = {0xA9806C, 0xA978EC},
  soraChests = {0x00A42DC0, 0xA42640},
  rikuChests = {0x00A455D8, 0xA44E58},
  toys = {0xA4C535, 0xA4BDB5},
  food = {0xA4C4E8, 0xA4BD68},
  dreamPieces = {0xA4C468, 0xA4BCE8},
  keyItems = {0xA4C2A4, 0xA4BB24},
  malleableFantasy = {0xA4C498, 0xA4BD18},
  recipes = {0xA4C2F4, 0xA4BB74}, --Drak Quack: 0xA4C34A
  soraExp = {0xA98010, 0xA97890}, --Actual xp
  supportAbilities = {0xA4D85C, 0xA4D0DC},
  world = {0x9CF730, 0x9CF720},
  room = {0x9CF731, 0x9CF721},
  map = {0x9CF734, 0x9CF724},
  btl = {0x9CF736, 0x9CF726},
  evt = {0x9CF738, 0x9CF728},
  entr = {0x9CF732, 0x9CF722},
  save = {0xA40760, 0xA3FFE0},
  shop = {0x10AD8A20, 0x10AD82A0},
  worldStatusS = {0xA41ED8, 0xA41758},
  worldStatusR = {0xA446F0, 0xA43F70},
  chestDataS = {0x1097AE00, 0x1097A680},
  chestDataR = {0x1097CEC0, 0x1097C740},
  dropEnabler = {0xA45A6C, 0xA452EC}, --C004 disables drop to Sora
  dropPtr = {0xA97FC0, 0xA97840},
  dropOffset = 0x1B0,
  pauseType = {0xA9B2D8, 0xA9AB58}, --03 is normal pause
  character = {0xA40760, 0xA3FFE0},
  deathPtr = {0xA97FC0, 0xA97840},
  deathOffset = 0x1A0,
  enablePause = {0xA9B31C, 0xA9AB9C},
  cutscenePauseType = {0xA3D06C, 0xA3C8EC},
  medals = {0xA51768, 0xA50FE8},
  lboard = {0x11992780, 0x11992000},
  boardRewards = {0x10986D60, 0x109865E0},
  expTable = {0x7B2A94, 0x7B2C34},
  subMenu = {0xA9B2F4, 0xA9AB74},
  emblems = {0xA4C568, 0xA4BDE8}
}

--Link board info:
--Meow Wow level gate type is +0x81 from lboard start. 0x16 is link gate, 0x4 is item
--Cost applies to both gate req and redeem price

EquippedCommands = {
  {0xA4D9D8, 0xA4D258}, --Sora Deck 1
  {0xA4DB16, 0xA4D396}, --Sora Deck 2
  {0xA4DC54, 0xA4D4D4}, --Sora Deck 3
  {0xA4DD92, 0xA4D612}, --Riku Deck 1
  {0xA4DED0, 0xA4D750}, --Riku Deck 2
  {0xA4E00E, 0xA4D88E},  --Riku Deck 3
}

DropAddresses = {
  sora = {
    world = {0xA41D10, 0xA41590},
    room = {0xA41D11, 0xA41591},
    map = {0xA41D14, 0xA41594},
    btl = {0xA41D16, 0xA41596},
    evt = {0xA41D18, 0xA41598},
  },
  riku = {
    world = {0xA44528, 0xA43DA8},
    room = {0xA44529, 0xA43DA9},
    map = {0xA4452C, 0xA43DAC},
    btl = {0xA4452E, 0xA43DAE},
    evt = {0xA44530, 0xA43DB0},
  }
}

Configs = {
  --Game Settings
  WorldScaling = true,
  SkipDI = true,
  SkipLightCycle = true,
  AutoCraftSpirits = true,
  FastGoMode = false,
  ExpMult = 10,
  StatBonus = 2,

  --AP Settings
  Character = 0, --0 for both; 1 for Sora Only; 2 for Riku Only
  Deathlink = false,
  RecipeReqs = 0, --Additional recipes needed to win the seed (Meow Wow and Komory Bat are always required)
  Goal = 0, --0: Final Boss; 1: Super Boss
  FightKyroo = 0,
  LocalItemNotifs = 0,
  RemoteItemNotifs = 0,
  VanillaLevels = false,
  EmblemReqs = 0
}

ItemOverwrite = {
  dummyNameAddr = {0x10944CF2, 0x10944572},
  dummyDescAddr = {0x1095622C, 0x10955AAC},
  --dummyDesc = "An AP Item.",
  dummyDesc = "An item for another world.",
  dummyId = {0x13, 0x08},
  dummyName = "AP Item",
  --Stats Riku
  food16NameAddr = {0x10944ABC, 0x1094433C},
  food16DescAddr = {0x10955C4C, 0x109554CC},
  food17NameAddr = {0x10944AD6, 0x10944356},
  food17DescAddr = {0x10955C70, 0x109554F0},
  food18NameAddr = {0x10944AF0, 0x10944370},
  food18DescAddr = {0x10955C94, 0x10955514},
  food19NameAddr = {0x10944B0A, 0x1094438A},
  food19DescAddr = {0x10955CB8, 0x10955538},
  food20NameAddr = {0x10944B24, 0x109443A4},
  food20DescAddr = {0x10955CDC, 0x1095555C},
  recipe55NameAddr = {0x10943E58, 0x109436D8},
  recipe55DescAddr = {0x1095299E, 0x1095221E},
  key36NameAddr = {0x1094420C, 0x10943A8C},
  key37NameAddr = {0x10944224, 0x10943AA4},
  key38NameAddr = {0x1094423C, 0x10943ABC},
  key39NameAddr = {0x10944254, 0x10943AD4},
  key40NameAddr = {0x1094426C, 0x10943AEC},
  recipeNameAddr = {0x10944CD6, 0x10944556}, --TOY 18
  recipeDescAddr = {0x109561FC, 0x10955A7C},
  --toy17NameAddr = {},
  --toy17DescAddr = {},
  toy16NameAddr = {0x10944CBA, 0x1094453A}, --TOY 16
  toy16DescAddr = {0x109561CC, 0x10955A4C},
  --toy15NameAddr = {},
  --toy15DescAddr = {},
  toy14NameAddr = {0x10944C9E,0x1094451E},
  toy14DescAddr = {0x1095619C,0x10955A1C},

  levelUpTxtAddr = {0x10946494, 0x10945D14},
  strIncreasedTxt = {0x10946494, 0x10945D14},
  magIncreasedTxt = {0x109464BC, 0x10945D3C},
  defIncreasedTxt = {0x109464DE, 0x10945D5E},
  hpIncreasedTxt = {0x10946504, 0x10945D84},
  deckCapIncreasedTxt = {0x10946530, 0x10945DB0},
  dropBonusTxt = {0x10946562, 0x10945DE2},
  keyItemNames = {0x10943EEC, 0x1094376C},
  keyItemDescs = {0x10952ACA, 0x1095234A},
  linkInfo1 = {0x10957982, 0x10957202},
  linkInfo2 = {0x10957A16, 0x10957296},
  linkBoardTxt = {0x10B7D4DC, 0x10B7CD5C},
  glossaryAddr = {0xA52049, 0xA518C9},
  glossaryName = {0x109443FA, 0x10943C7A},
  glossaryDesc = {0xF8FF05C, 0xF8FE8DC}
}

KHSCII = {
  A = 0x41,B = 0x42,C = 0x43,D = 0x44,E = 0x45,F = 0x46,
  G = 0x47,H = 0x48,I = 0x49,J = 0x4A,K = 0x4B,
  L = 0x4C,M = 0x4D,N = 0x4E,O = 0x4F,P = 0x50,
  Q = 0x51,R = 0x52,S = 0x53,T = 0x54,U = 0x55,
  V = 0x56,W = 0x57,X = 0x58,Y = 0x59,Z = 0x5A,
  a = 0x61,b = 0x62,c = 0x63,d = 0x64,e = 0x65,f = 0x66,
  g = 0x67,h = 0x68,i = 0x69,j = 0x6A,k = 0x6B,
  l = 0x6C,m = 0x6D,n = 0x6E,o = 0x6F,p = 0x70,
  q = 0x71,r = 0x72,s = 0x73,t = 0x74,u = 0x75,
  v = 0x76,w = 0x77,x = 0x78,y = 0x79,z = 0x7A,
  One = 0x31, Two = 0x32, Three = 0x33, Four = 0x34, Five = 0x35,
  Six = 0x36, Seven = 0x37, Eight = 0x38, Nine = 0x39, Zero = 0x30,
  Period = 0x2E,Space = 0x20,Exclamation = 0x21, And = 0x26, Colon = 0x3A,
  LeftParen = 0x28, LeftBracket = 0x5B, RightBracket = 0x5D, Apostrophe = 0x27,
  Enter = 0x0A, ForwardSlash = 0x2F, BackSlash = 0x5C
}

KHCOLORS = {
  RED = {0x22, 0xE0}, --Trap
  YELLOW = {0x26, 0xE0}, --Player
  CYAN = {0x25, 0xE0}, --Filler
  GREEN = {0x24, 0xE0},
  PINK = {0x23, 0xE0}, --Progression
  BLUE = {0x21, 0xE0}, --Useful
  GRAY = {0x20, 0xE0},
}

--Record: A51940

Stats = { --Stats for sora and riku
  currHpPtr = {0xA37DB8, 0xA37638},
  currHpOffset = 0x71C,
  sora = {
    maxHp = {0xA4D8D0, 0xA4D150}, --HP Bonus is +20 --Also potentially 0xA98022
    currHp = {0xA4D8D2, 0xA4D152},

    strength = {{0xA4D8E5, 0xA98035}, {0xA4D165, 0xA978B5}}, --Also potentially 0xA98035
    magic = {{0xA4D8E6, 0xA98036}, {0xA4D166, 0xA978B6}}, --Also potentially 0xA98036
    defense = {{0xA4D8E7, 0xA98037}, {0xA4D167, 0xA978B7}}, --Also potentially 0xA98037
    exp = {0xA98010, 0xA97890},
    nextLevel = {0xA4D8CC, 0xA4D14C},
    deckSize = {0xA98039, 0xA978B9},
  },
  riku = {
    maxHp = {0xA98020, 0xA978A0}
  }
}

KeybladeStats = {
  soraBase = {0x9D6F9C, 0x9D6F8C}, --+0 is strength, +1 is magic
  rikuBase = {0x9D6FA8, 0x9D6F98}, --15 kbs
  offset = 0x18 --# of bytes between each keyblade entry
}

WorldFlags = {
  destinyIslands = {
    worldNo = 0x01,
    sora = {
      story = {0xA41D94, 0xA41614},
      info = {0xA41E50, 0xA416D0}
    }
  },
  traverseTown = {
    worldNo = 0x03,
    sora = {
      story = {0xA41DA4, 0xA41624},
      unlocked = {0xA41F04, 0xA41784},
      battle = {0xA41DFF, 0xA4167F},
      selectable = {0x10978F18, 0x10978798},
      startRoom = 0x01,
      secretPortal = {0x64, 0x01, 0x05},
      info = {0xA41E54, 0xA416D4},
    },
    riku = {
      story = {0xA445BC, 0xA43E3C},
      unlocked = {0xA4471C, 0xA43F9C},
      battle = {0xA44617, 0xA43E97},
      selectable = {0x10978FD0, 0x10978850},
      startRoom = 0x01,
      secretPortal = {0x65, 0x01, 0x06},
      info = {0xA4466A, 0xA43EEA}, --EGS
    },

    secretPortalAddr = {0xA515C0, 0xA50E40}
  },
  laCiteDesCloches = {
    worldNo = 0x08,
    sora = {
      unlocked = {0xA41F18, 0xA41798},
      selectable = {0x10978F28, 0x109787A8},
      story = {0xA41DCC, 0xA4164C},
      startRoom = 0x0A,
      battle = {0xA41E04, 0xA41684},
      secretPortal = {0x66, 0x01, 0x01},
      info = {0xA41E5C, 0xA416DC},
    },
    riku = {
      unlocked = {0xA44730, 0xA43FB0},
      selectable = {0x10978FE0, 0x10978860},
      story = {0xA445E4, 0xA43E64},
      startRoom = 0x0A,
      battle = {0xA4461C, 0xA43E9C},
      secretPortal = {0x67, 0x01, 0x01},
      info = {0xA44674, 0xA43EF4}, --EGS
    },

    secretPortalAddr = {0xA515C4, 0xA50E44}
  },
  theGrid = {
    worldNo = 0x09,
    sora = {
      unlocked = {0xA41F1C, 0xA4179C},
      selectable = {0x10978F48, 0x109787C8},
      story = {0xA41DD4, 0xA41654},
      startRoom = 0x08,
      battle = {0xA41E05, 0xA41685},
      secretPortal = {0x6A, 0x01, 0x04},
      info = {0xA41E5E, 0xA416DE},

    },
    riku = {
      unlocked = {0xA44734, 0xA43FB4},
      story = {0xA445EC, 0xA43E6C},
      selectable = {0x10979000, 0x10978880},
      startRoom = 0x08,
      battle = {0xA4461D, 0xA43E9D},
      secretPortal = {0x6B, 0x01, 0x01},
      info = {0xA44676, 0xA43EF6},
    },

    secretPortalAddr = {0xA515CC, 0xA50E4C}
  },
  prankstersParadise = {
    worldNo = 0x06,
    sora = {
      unlocked = {0xA41F10, 0xA41790},
      selectable = {0x10978F38, 0x109787B8},
      story = {0xA41DBC, 0xA4163C},
      startRoom = 0x01,
      battle = {0xA41E02, 0xA41682},
      secretPortal = {0x68, 0x01, 0x04},
      info = {0xA41E58, 0xA416D8},
    },
    riku = {
      unlocked = {0xA44728, 0xA43FA8},
      story = {0xA445D4, 0xA43E54},
      selectable = {0x10978FF0, 0x10978870},
      startRoom = 0x06,
      battle = {0xA4461A, 0xA43E9A},
      secretPortal = {0x69, 0x01, 0x0A},
      info = {0xA44670, 0xA43EF0},
    },

    secretPortalAddr = {0xA515C8, 0xA50E48}
  },
  countryOfMusketeers = {
    worldNo = 0x04,
    sora = {
      unlocked = {0xA41F08, 0xA41788},
      selectable = {0x10978F68, 0x109787E8},
      story = {0xA41DAC, 0xA4162C},
      startRoom = 0x0F,
      battle = {0xA41E00, 0xA41680},
      secretPortal = {0x6C, 0x01, 0x03},
      info = {0xA41E56, 0xA416D6},
    },
    riku = {
      unlocked = {0xA44720, 0xA43FA0},
      story = {0xA445C4, 0xA43E44},
      selectable = {0x10979020, 0x109788A0},
      startRoom = 0x02,
      battle = {0xA44618, 0xA43E98},
      secretPortal = {0x6D, 0x01, 0x0C},
      info = {0xA4466C, 0xA43EEC} --EGS
    },

    secretPortalAddr = {0xA515D0, 0xA50E50}
  },
  symphonyOfSorcery = {
    worldNo = 0x05,
    sora = {
      unlocked = {0xA41F0C, 0xA4178C},
      selectable = {0x10978F78, 0x109787F8},
      story = {0xA41DB4, 0xA41634},
      startRoom = 0x0F,
      dockPoint = {0x10979106, 0x10978986},
      battle = {0xA41E01, 0xA41681},
      secretPortal = {0x6E, 0x01, 0x01},
      info = {0xA41E58, 0xA416D8},
    },
    riku = {
      unlocked = {0xA44724, 0xA43FA4},
      story = {0xA445CC, 0xA43E4C},
      selectable = {0x10979030, 0x109788B0},
      startRoom = 0x0F,
      battle = {0xA44619, 0xA43E99},
      info = {0xA4466E, 0xA43EEE},
    },

    secretPortalAddr = {0xA515D4, 0xA50E54}
  },
  theWorldThatNeverWas = {
    worldNo = 0x0A,
    sora = {
      unlocked = {0xA41F20, 0xA417A0},
      selectable = {0x10978F88, 0x10978808},
      story = {0xA41DDC, 0xA4165C},
      startRoom = 0x01,
      dockPoint = {0x1097913A, 0x109789BA},
      battle = {0xA41E06, 0xA41686},
      info = {0xA41E60, 0xA416E0},
    },
    riku = {
      unlocked = {0xA44738, 0xA43FB8},
      story = {0xA445F4, 0xA43E74},
      selectable = {0x10979040, 0x109788C0},
      startRoom = 0x04,
      battle = {0xA4461E, 0xA43E9E},
      dockPoint = {0x1097919E, 0x10978A1E},
      GOPoint = {0x109791AA, 0x10978A2A}, --For Memory's Skyscraper; unlocks for GO mode
      info = {0xA44678, 0xA43EF8},
    },
  }
}

--Dream Eater Address: 0xA62244

item_usefulness = {
  progression = 1,
  normal = 2,
  trap = 4,
  special = 5
}

MessageTypes = {
  Invalid = -1,
  Test = 0,
  ChestChecked = 1,
  LevelChecked = 2,
  ReceiveAllItems = 3,
  RequestAllItems = 4,
  ReceiveSingleItem = 5,
  StoryChecked = 6,
  ClientCommand = 7,
  Deathlink = 8,
  PortalChecked = 9,
  SendSlotData = 10,
  Victory = 11,
  Handshake = 12,
  GetCurrentIndex = 13,
  ItemPrompt = 14,
  DataStorage = 15,
  HasSlotData = 16,
  Closed = 20
}
HandshakeSent = false
HandshakeReceived = false

--Items
items = {}
abilities = {}

--Locations
chests = {}
levels = {
  addr = {0xA98034, 0xA978B4},
  soraLevel = 1,
  soraLevelID = 2660000,
  rikuLevel = 1,
  rikuLevelID = 2660100,
  levelCap=50
}
worldEvents = {}
portalDigits = {}

SpiritStats = {}

--Needed to fix pause after DE tutorial
fixPause = false

keepDropActive = -1 --Prevent the drop manager from doing its thing

lastHp = 80 --Prevents deathlink from triggering in succession
lastDeathTime = 0
holdDeathlink = false

holdDropTrap = false

menuFixApplied = 0 --Tracks if story vals need to be reset for sora TT1
--0: Menu fix did not get applied or no longer needs to
--1: Menu fix was applied and sora's story needs to be corrected later
--2: Menu fix temporarily disabled; awaiting sora's events to finish

rikuSpiritFix = 0 --Tracks if story vals need to be reset for riku TT1
--0: Menu fix did not get applied or no longer needs to
--1: Menu fix was applied and riku's story needs to be corrected
--2: Menu fix disabled

activeCharacter = 0

roomInfo = {0x00, 0x00, 0x00} --[world, room, map/btl/evt]

--currentReceivedIndex = 0 --Updates when a new item is obtained and is saved to the medals value on change
lastReceivedIndex = 0 --Updates when save file is loaded
receivedInit = false --Have we received our items after connecting to the server?

local _soraUnboundSent = false
local _rikuUnboundSent = false
doingPortal = false

-- ############################################################
-- ######################  Game State  ########################
-- ############################################################
function initGameState() --Updates various world/event flags to an initial state after connecting
  --Write Traverse Town story flag to immediately unlock World Map
  if ReadByte(WorldFlags.traverseTown.sora.story[gameVer]) < 0x11 then
    WriteByte(WorldFlags.traverseTown.sora.story[gameVer], 0x11)
  end
  makeDummyItem()

  fixMenuOptions()
  removeInitialMovement()

  LocationHandler:ShowAllWorlds() --Allows full navigation of world map

  ItemHandler:RemoveFlowmotionItems()

  RoomSaveTask:Init() --Initialize room saves

end

function RunReports()
  if ReadByte(ItemOverwrite.glossaryAddr[gameVer]) == 0x00 then --Show glossary
    WriteByte(ItemOverwrite.glossaryAddr[gameVer], 0x01)
  end
  if ReadByte(ItemOverwrite.glossaryDesc[gameVer] == 0x53) then --Update glossary txt
    
    ItemHandler:CheckMacguffins() --Gets recent key item results
    local _recipeCnt = #ItemHandler.State.Recipes
    local _embCnt = ItemHandler.State.Emblems

    if Configs.Goal == 0 then --Final boss goal
      local _conditionsMet = 0
      local _goalTxt = "GOAL: Defeat the final boss. ||Requirements: |"
      local _meowTxt = "Meow Wow: NOT FOUND |"
      local _batTxt = "Komory Bat: NOT FOUND |"
      local _sigilTxt = "Recusant Sigil: NOT FOUND |"
      local _reqTxt = "Required Recipes: "..tostring(_recipeCnt).."/"..tostring(Configs.RecipeReqs).." |"
      local _embTxt = ""

      local _goTxt = ""
      if _recipeCnt >= Configs.RecipeReqs then
        _reqTxt = _reqTxt.." [COMPLETE] |"
        _conditionsMet = _conditionsMet + 1
      end
      if ItemHandler.State.HasCat then
        _meowTxt = "Meow Wow: OBTAINED |"
        _conditionsMet = _conditionsMet + 1
      end
      if ItemHandler.State.HasBat then
        _batTxt = "Komory Bat: OBTAINED |"
        _conditionsMet = _conditionsMet + 1
      end
      if ItemHandler.State.Recusant then
        _sigilTxt = "Recusant Sigil: OBTAINED |"
        _conditionsMet = _conditionsMet + 1
      end
      if Configs.EmblemReqs > 0 then
        _embTxt = "Required Emblems: "..tostring(_embCnt).."/"..tostring(Configs.EmblemReqs)
        if _embCnt >= Configs.EmblemReqs then
          _embTxt = _embTxt.." [COMPLETE]"
          _conditionsMet = _conditionsMet + 1
        end
      else
        _conditionsMet = _conditionsMet + 1
      end

      if _conditionsMet == 5 then --Go mode available
        --Verify twtnw access
        local _hasTwtnw = true
        if ReadByte(WorldFlags.theWorldThatNeverWas.sora.unlocked[gameVer]) == 0x00 then
          if Configs.Character < 2 then
            _goTxt = _goTxt.." |Need to find TWTNW for Sora!"
            _hasTwtnw = false
          end
        end
        if ReadByte(WorldFlags.theWorldThatNeverWas.riku.unlocked[gameVer]) == 0x00 then
          if Configs.Character == 0 or Configs.Character == 2 then
            _goTxt = _goTxt.." |Need to find TWTNW for Riku!"
            _hasTwtnw = false
          end
        end
        if _hasTwtnw then
          _goTxt = " |YOU ARE IN GO MODE!"
        end
      end

       writeTxtToGame(ItemOverwrite.glossaryDesc[gameVer], _goalTxt.._meowTxt.._batTxt.._sigilTxt.._reqTxt.._embTxt.._goTxt, 3)

    elseif Configs.Goal == 1 then --Superboss goal
      local _conditionsMet = 0
      local _portalsNeeded = false
      local _goalTxt = "GOAL: Defeat Julius. ||Requirements: |"
      local _reqTxt = "Required Recipes: "..tostring(_recipeCnt).."/"..tostring(Configs.RecipeReqs)
      local _portalTxt = "||Secret Portals to Complete: |"
      local _embTxt = ""
      local _goTxt = ""
      if _recipeCnt >= Configs.RecipeReqs then
        _reqTxt = _reqTxt.." [COMPLETE]"
        _conditionsMet = _conditionsMet + 1
      end
      if Configs.EmblemReqs > 0 then
        _embTxt = "Required Emblems: "..tostring(_embCnt).."/"..tostring(Configs.EmblemReqs)
        if _embCnt >= Configs.EmblemReqs then
          _embTxt = _embTxt.." [COMPLETE]"
          _conditionsMet = _conditionsMet + 1
        end
      else
        _conditionsMet = _conditionsMet + 1
      end
      if Configs.Character < 2 then --Sora portals
        _portalTxt = _portalTxt.."|SORA|"
        if ReadByte(WorldFlags.traverseTown.sora.story[gameVer]+0x07) == 0x00 then
          _portalTxt = _portalTxt.."Traverse Town |"
          _portalsNeeded = true
        end
        if ReadByte(WorldFlags.laCiteDesCloches.sora.story[gameVer]+0x07) == 0x00 then
          _portalTxt = _portalTxt.."La Cite des Cloches |"
          _portalsNeeded = true
        end
        if ReadByte(WorldFlags.theGrid.sora.story[gameVer]+0x07) == 0x00 then
          _portalTxt = _portalTxt.."The Grid |"
          _portalsNeeded = true
        end
        if ReadByte(WorldFlags.prankstersParadise.sora.story[gameVer]+0x07) == 0x00 then
          _portalTxt = _portalTxt.."Pranksters Paradise |"
          _portalsNeeded = true
        end
        if ReadByte(WorldFlags.countryOfMusketeers.sora.story[gameVer]+0x07) == 0x00 then
          _portalTxt = _portalTxt.."Country of the Musketeers |"
          _portalsNeeded = true
        end
        if ReadByte(WorldFlags.symphonyOfSorcery.sora.story[gameVer]+0x07) == 0x00 then
          _portalTxt = _portalTxt.."Symphony of Sorcery |"
          _portalsNeeded = true
        end
      end
      if Configs.Character == 0 or Configs.Character == 2 then --Riku portals
        _portalTxt = _portalTxt.."|RIKU|"
        if ReadByte(WorldFlags.traverseTown.riku.story[gameVer]+0x07) == 0x00 then
          _portalTxt = _portalTxt.."Traverse Town |"
          _portalsNeeded = true
        end
        if ReadByte(WorldFlags.laCiteDesCloches.riku.story[gameVer]+0x07) == 0x00 then
          _portalTxt = _portalTxt.."La Cite des Cloches |"
          _portalsNeeded = true
        end
        if ReadByte(WorldFlags.theGrid.riku.story[gameVer]+0x07) == 0x00 then
          _portalTxt = _portalTxt.."The Grid |"
          _portalsNeeded = true
        end
        if ReadByte(WorldFlags.prankstersParadise.riku.story[gameVer]+0x07) == 0x00 then
          _portalTxt = _portalTxt.."Pranksters Paradise |"
          _portalsNeeded = true
        end
        if ReadByte(WorldFlags.countryOfMusketeers.riku.story[gameVer]+0x07) == 0x00 then
          _portalTxt = _portalTxt.."Country of the Musketeers |"
          _portalsNeeded = true
        end

      end
      if not _portalsNeeded then
        _conditionsMet = _conditionsMet + 1
      end

      if _conditionsMet == 3 then --Can fight Julius
        _goTxt = "| Julius can be found in the manhole after |clearing TT2."
      end
      writeTxtToGame(ItemOverwrite.glossaryDesc[gameVer], _goalTxt.._reqTxt.._embTxt.._portalTxt.._goTxt, 3)
    end

   
  end
end

function allPortalsWon()
  local _soraPortalsWon = true
  local _rikuPortalsWon = true

  local _soraPortals = {}
  table.insert(_soraPortals, ReadByte(WorldFlags.traverseTown.sora.story[gameVer]+0x07))
  table.insert(_soraPortals, ReadByte(WorldFlags.laCiteDesCloches.sora.story[gameVer]+0x07))
  table.insert(_soraPortals, ReadByte(WorldFlags.theGrid.sora.story[gameVer]+0x07))
  table.insert(_soraPortals, ReadByte(WorldFlags.prankstersParadise.sora.story[gameVer]+0x07))
  table.insert(_soraPortals, ReadByte(WorldFlags.countryOfMusketeers.sora.story[gameVer]+0x07))
  table.insert(_soraPortals, ReadByte(WorldFlags.symphonyOfSorcery.sora.story[gameVer]+0x07))

  local _rikuPortals = {}
  table.insert(_rikuPortals, ReadByte(WorldFlags.traverseTown.riku.story[gameVer]+0x07))
  table.insert(_rikuPortals, ReadByte(WorldFlags.laCiteDesCloches.riku.story[gameVer]+0x07))
  table.insert(_rikuPortals, ReadByte(WorldFlags.theGrid.riku.story[gameVer]+0x07))
  table.insert(_rikuPortals, ReadByte(WorldFlags.prankstersParadise.riku.story[gameVer]+0x07))
  table.insert(_rikuPortals, ReadByte(WorldFlags.countryOfMusketeers.riku.story[gameVer]+0x07))

  if Configs.Character < 2 then --Check Sora's worlds
    for x=1, #_soraPortals do
      if _soraPortals[x] == 0x00 then
        _soraPortalsWon = false
      end
    end
  end
  if Configs.Character == 0 or Configs.Character == 2 then --Check Riku's worlds
    for x=1, #_rikuPortals do
      if _rikuPortals[x] == 0x00 then
        _rikuPortalsWon = false
      end
    end
  end

  local _returnWin = -1 --Neither character has cleared every portal
  if _soraPortalsWon and not _rikuPortalsWon then
    _returnWin = 1
    --Send location for Sora Unbound
    if not _soraUnboundSent then
      SendToApClient(MessageTypes.PortalChecked, {"2680212"})
      _soraUnboundSent = true
    end
  elseif not _soraPortalsWon and _rikuPortalsWon then
    _returnWin = 2
    --Send location for Riku Unbound
    if not _rikuUnboundSent then
      SendToApClient(MessageTypes.PortalChecked, {"2680213"})
      _rikuUnboundSent = true
    end
  elseif _soraPortalsWon and _rikuPortalsWon then
    --Send location for both Unbound keyblades
    if not _soraUnboundSent then
      SendToApClient(MessageTypes.PortalChecked, {"2680212"})
      _soraUnboundSent = true
    end
    if not _rikuUnboundSent then
      SendToApClient(MessageTypes.PortalChecked, {"2680213"})
      _rikuUnboundSent = true
    end
    _returnWin = 3
  end
  return _returnWin

end

function setSecretPortals()
    --Enable Secret Portals if the world is beaten
    local _ttSecret = WorldFlags.traverseTown.sora.secretPortal
    local _lcdsSecret = WorldFlags.laCiteDesCloches.sora.secretPortal
    local _ppSecret = WorldFlags.prankstersParadise.sora.secretPortal
    local _tgSecret = WorldFlags.theGrid.sora.secretPortal
    local _cotmSecret = WorldFlags.countryOfMusketeers.sora.secretPortal
    local _sosSecret = WorldFlags.symphonyOfSorcery.sora.secretPortal

    if getCharacter() == 1 then
      _ttSecret = WorldFlags.traverseTown.riku.secretPortal
      _lcdsSecret = WorldFlags.laCiteDesCloches.riku.secretPortal
      _ppSecret = WorldFlags.prankstersParadise.riku.secretPortal
      _tgSecret = WorldFlags.theGrid.riku.secretPortal
      _cotmSecret = WorldFlags.countryOfMusketeers.riku.secretPortal

      if ReadByte(WorldFlags.traverseTown.riku.story[gameVer]+0x04) >= 0x01 and allPortalsWon() >= 2 then --Riku beat TT2; Enable Julius
        --Advance story to allow manhole to spawn
        if #ItemHandler.State.Recipes >= Configs.RecipeReqs then
          if ReadByte(WorldFlags.traverseTown.riku.story[gameVer]+0x04) < 0x4F then
            WriteByte(WorldFlags.traverseTown.riku.story[gameVer]+0x04, 0x4F)
          end
          --Write Fountain Plaza Room Flags
          local fntMap = {0xA43466, 0xA42CE6}

          WriteByte(fntMap[gameVer], 0x04)
          WriteByte(fntMap[gameVer]+0x02, 0x01)
          WriteByte(fntMap[gameVer]+0x04, 0x05)
        end
      end

    else
      if ReadByte(WorldFlags.traverseTown.sora.story[gameVer]+0x04) >= 0x3F then --Sora beat TT2; Enable Julius
        if allPortalsWon() == 1 or allPortalsWon() == 3 then
          if #ItemHandler.State.Recipes >= Configs.RecipeReqs then
            --Advance story to allow manhole to spawn
            if ReadByte(WorldFlags.traverseTown.sora.story[gameVer]+0x04) < 0x8F then
              WriteByte(WorldFlags.traverseTown.sora.story[gameVer]+0x04, 0x8F)
            end
            --Write Fountain Plaza Room Flags
            local fntMap = {0xA40C4E, 0xA404CE}

            WriteByte(fntMap[gameVer], 0x04)
            WriteByte(fntMap[gameVer]+0x02, 0x01)
            WriteByte(fntMap[gameVer]+0x04, 0x05)
          end
        end
      end
    end

    WriteArray(WorldFlags.traverseTown.secretPortalAddr[gameVer], _ttSecret)
    WriteArray(WorldFlags.laCiteDesCloches.secretPortalAddr[gameVer], _lcdsSecret)
    WriteArray(WorldFlags.theGrid.secretPortalAddr[gameVer], _tgSecret)
    WriteArray(WorldFlags.prankstersParadise.secretPortalAddr[gameVer], _ppSecret)
    WriteArray(WorldFlags.countryOfMusketeers.secretPortalAddr[gameVer], _cotmSecret)
    WriteArray(WorldFlags.symphonyOfSorcery.secretPortalAddr[gameVer], _sosSecret)

end

function removeInitialMovement()
  if ReadByte(MemoryAddresses.airSlideStock[gameVer]) == 0x06 and lastReceivedIndex == 0 then --Get rid of initial movement
    local _removeBytes = {0x00, 0x00, 0x00, 0x00}
    local _unequipArr = {0xFF, 0xFF}

    for i=1, #EquippedCommands do
      --Unequip Dodge Roll
      --WriteArray(EquippedCommands[i]+0x36, _unequipArr)
      --WriteByte(EquippedCommands[i]+0xBE, 0xFF)

      --Unequip Air Slide
      WriteArray(EquippedCommands[i][gameVer]+0x3C, _unequipArr)
      WriteByte(EquippedCommands[i][gameVer]+0xC0, 0xFF)

      --Unequip Block
      --WriteArray(EquippedCommands[i]+0x54, _unequipArr)
      --WriteByte(EquippedCommands[i]+0xC6, 0xFF)
    end

    --Disable Command's Action Flag
    WriteByte(MemoryAddresses.actionFlags[gameVer]-20, 0x00)

    --Remove commands from inventory
    --WriteArray(MemoryAddresses.blockStock, _removeBytes)
      WriteArray(MemoryAddresses.airSlideStock[gameVer], _removeBytes)
    --WriteArray(MemoryAddresses.dodgeRollStock, _removeBytes)
  end
end

function fixMenuOptions()
  --Reveal Commmand Deck and Spirit menu options at the start of the playthrough
  local _soraProg = ReadArray(WorldFlags.traverseTown.sora.story[gameVer], 0x08)
  local _rikuProg = ReadArray(WorldFlags.traverseTown.riku.story[gameVer], 0x08)

  --Prevent tutorial message from popping up for the command deck
  WriteArray(MemoryAddresses.commandDeckPopup[gameVer], {0x10, 0x0A})
  --Remove tutorial messages for world map and drop
  local mapDropTutorial = {0xA4C3F2, 0xA4BC72}
  WriteArray(mapDropTutorial[gameVer], {0x07, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x0A, 0x0A})

  if _soraProg[3] <= 0x01 then --Player has not advanced far enough into TT
    WriteByte(WorldFlags.traverseTown.sora.story[gameVer]+0x01, 0xF1) --Unveils spirit and command options
    menuFixApplied = 1
  else --Player has progressed far enough to keep this disabled
    menuFixApplied = 0
  end

  if _rikuProg[2] < 0x1F and rikuSpiritFix == 0 then
    ConsolePrint("Fixing riku menu")
    WriteByte(WorldFlags.traverseTown.riku.story[gameVer]+0x01, 0x1F) --Unveils spirit option for riku
    rikuSpiritFix = 1
  end
  if _rikuProg[2] == 0x1F and rikuSpiritFix == 0 then
    if _rikuProg[3] == 0x00 then
      rikuSpiritFix = 1
    end
  end

end

function onCharacterChange()
  --TODO: Fix stat abilities getting disabled
  ConsolePrint("Character changed")

  --Fix Sora getting stuck after Xemnas
  if ReadByte(DropAddresses.sora.world[gameVer]) < 0x03 or ReadByte(DropAddresses.sora.world[gameVer]) == 0x0A and ReadByte(DropAddresses.sora.room[gameVer]) == 0x13 then --Sora is in an invalid world
    WriteByte(DropAddresses.sora.world[gameVer], 0x0B)
    WriteByte(DropAddresses.sora.room[gameVer], 0x01)
  end

  setSecretPortals()

  WorldHandler:ApplyScaling()
  if ReadByte(roomInfo[1]) == 0x0B or ReadByte(DropAddresses.sora.world[gameVer]) == 0x0B or ReadByte(DropAddresses.riku.world[gameVer]) == 0x0B then
    WorldHandler:MapLoaded()
  end

  local _charLvl = ReadByte(levels.addr[gameVer])
  PatchTask:WriteLevelReward(_charLvl+0x01, getCharacter())


  MessageHandler.State.restore = true
end

local _isPaused = false
function checkPause()
  local _pauseType = ReadByte(MemoryAddresses.pauseType[gameVer])
  if not _isPaused then
    if _pauseType > 0x00 then
      onPauseChange()
      --Check to remove invalid items from stock
      ItemHandler:RemoveAbilityFromStock()
      _isPaused = true
    end
  else
    if _pauseType == 0x00 then
      onPauseChange()
      _isPaused = false
    end
  end
end

function onPauseChange()
  ItemHandler:RebuildFlowmotion() --TODO: Nop this to prevent rebuild?
  if not Configs.VanillaLevels then
    ItemHandler:RebuildStats()
  end
  ItemHandler:RebuildAbilities()

  if ReadByte(roomInfo[1]) == 0x0B then
    --Accounts for being warped to world map from a room index of 01
    WorldHandler:MapLoaded()
  end
end

function onRoomChange()
  if #MessageHandler.State.msgQueue > 0 then
    MessageHandler.State.msgCd = 0
  else
    MessageHandler:restoreMissions()
  end
  if roomInfo[1] == 0x0B then
    LocationHandler.allowKyroo = true

    WorldHandler:MapLoaded()
  end
  if not Configs.VanillaLevels then
    ItemHandler:RebuildStats()
  end
  ItemHandler:RebuildAbilities()
  ItemHandler:RebuildFlowmotion()
  PatchTask:WriteBonusRewards()
  PatchTask:ResetRewards()
  _exeTime = -1
  setSecretPortals()

  if roomInfo[1] == 0x03 then
    if ReadByte(MemoryAddresses.worldStatusS[gameVer]+0x64) >= 0xFE then --Should never be this value
      WriteInt(MemoryAddresses.worldStatusS[gameVer]+0x64, 0x00)
    end

    if roomInfo[2] == 0x04 then
      if ReadShort(MemoryAddresses.world[gameVer]+0x10) == 0x010B then
        --Entered 4th district via flick rush menu; dont actually visit
        if getCharacter() == 0 and WorldHandler.WorldsUnlocked.Sora[1] == 0 or getCharacter() == 1 and WorldHandler.WorldsUnlocked.Riku[1] == 0 then
          WriteShort(MemoryAddresses.world[gameVer], 0x010C)
        end
      end
    end
  end
end

function makeDummyItem()
  --TOY 20 is unused, so we will make it our dummy item
  --Overwrite the item details
  writeTxtToGame(ItemOverwrite.dummyNameAddr[gameVer], ItemOverwrite.dummyName, 0)
  --writeTxtToGame(ItemOverwrite.dummyDescAddr, ItemOverwrite.dummyDesc, 7)
  writeTxtToGame(ItemOverwrite.dummyDescAddr[gameVer], ItemOverwrite.dummyDesc, 3)

  --TOY 18
  writeTxtToGame(ItemOverwrite.recipeNameAddr[gameVer], "Recipes", 3)
  --writeTxtToGame(ItemOverwrite.recipeDescAddr, "Recipes Required: "..tostring(Configs.RecipeReqs), 1)

  --TOY 16
  --writeTxtToGame(ItemOverwrite.dummyAbilityNameAddr[gameVer], "Ability", 3)
  --writeTxtToGame(ItemOverwrite.dummyAbilityDescAddr[gameVer], "Check log for Ability", 2)

  --Toy 14
  writeTxtToGame(ItemOverwrite.toy14NameAddr[gameVer], "Lucky Emblem", 3)
  --writeTxtToGame(ItemOverwrite.toy14DescAddr[gameVer], "", 3)

  --Replace chest data with this item
  for i=0, 226 do
    WriteArray(MemoryAddresses.chestDataS[gameVer]+0x1A+(8*i), ItemOverwrite.dummyId)
    WriteArray(MemoryAddresses.chestDataR[gameVer]+0x1A+(8*i), ItemOverwrite.dummyId)
  end

  --Overwrite unused Key Items for AP specific items
  local _nameSize = 10 --Number of characters per name
  local _descSize = 15 --Number of characters per desc

  --Write replacement key items
  WorldHandler:RestoreWorldKeyTxt() --World items

  --Write replacement stat items
  writeStatKeys()

  writeTxtToGame(ItemOverwrite.recipe55NameAddr[gameVer], "Flowmotion", 2) --Recipe 55 replacement
  writeTxtToGame(ItemOverwrite.recipe55DescAddr[gameVer], "Grants all Flowmotion abilities.", 2)

  --Replace reward text
  writeTxtToGame(ItemOverwrite.hpIncreasedTxt[gameVer], "Archipelago Item!", 4)
  writeTxtToGame(ItemOverwrite.dropBonusTxt[gameVer], "Archipelago Item!", 9)
  writeTxtToGame(ItemOverwrite.deckCapIncreasedTxt[gameVer], "Archipelago Item!", 7)

  --GO Mode Report
  --glossaryAddr, glossaryName, glossaryDesc
  writeTxtToGame(ItemOverwrite.glossaryName[gameVer], "GO Mode Report", 3)
  writeTxtToGame(ItemOverwrite.glossaryDesc[gameVer], "Meow Wow, Komory Bat, Recusant Sigil", 3)

end

function writeStatKeys()

  --Riku Stats

  writeTxtToGame(ItemOverwrite.food16NameAddr[gameVer], "HP Up [R]", 3)
  writeTxtToGame(ItemOverwrite.food16DescAddr[gameVer], "Max HP Up Riku", 3)

  writeTxtToGame(ItemOverwrite.food17NameAddr[gameVer], "Deck Up [R]", 3)
  writeTxtToGame(ItemOverwrite.food17DescAddr[gameVer], "Deck Cap Up Riku", 3)

  writeTxtToGame(ItemOverwrite.food18NameAddr[gameVer], "Str Up [R]", 3)
  writeTxtToGame(ItemOverwrite.food18DescAddr[gameVer], "Strength Up Riku", 3)

  writeTxtToGame(ItemOverwrite.food19NameAddr[gameVer], "Mag Up [R]", 3)
  writeTxtToGame(ItemOverwrite.food19DescAddr[gameVer], "Magic Up Riku", 3)

  writeTxtToGame(ItemOverwrite.food20NameAddr[gameVer], "Def Up [R]", 3)
  writeTxtToGame(ItemOverwrite.food20DescAddr[gameVer], "Defense Up Riku", 3)

  --Sora Stats

  writeTxtToGame(ItemOverwrite.key36NameAddr[gameVer], "HP Up [S]", 3) --36
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+1152, "Max HP Up Sora", 3)

  writeTxtToGame(ItemOverwrite.key37NameAddr[gameVer], "Deck Up [S]", 3) --37
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+1186, "Deck Cap Up Sora", 3)

  writeTxtToGame(ItemOverwrite.key38NameAddr[gameVer], "Str Up [S]", 3) --38
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+1220, "Strength Up Sora", 3)

  writeTxtToGame(ItemOverwrite.key39NameAddr[gameVer], "Mag Up [S]", 3) --39
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+1254, "Magic Up Sora", 3)  

  writeTxtToGame(ItemOverwrite.key40NameAddr[gameVer], "Def Up [S]", 3) --40
  writeTxtToGame(ItemOverwrite.keyItemDescs[gameVer]+1288, "Defense Up Sora", 3)


end

--Dummy Item Inventory
local _dummyInv = {0xA4C580, 0xA4BE00}
local _abilityInv = {0xA4C570, 0xA4BDF0}
local _flowmotionKeyInv = {0xA4C360, 0xA4BBE0}
function removeDummyItem()
  if ReadByte(_dummyInv[gameVer]) > 0x00 then --We have a dummy; wipe it
    WriteArray(_dummyInv[gameVer], {0x00, 0x00, 0x00})
  end
  if ReadByte(_abilityInv[gameVer]) > 0x00 then
    WriteArray(_abilityInv[gameVer], {0x00, 0x00, 0x00})
  end
  if ReadByte(_flowmotionKeyInv[gameVer]) > 0x00 then
    WriteArray(_flowmotionKeyInv[gameVer], {0x00, 0x00})
  end
end

local _foodStart = {0xA4C520, 0xA4BDA0}
function removeStatKeys()
  for i=70, 80, 2 do --Remove stat key items
    if ReadByte(MemoryAddresses.keyItems[gameVer]+i) > 0x00 then
      WriteByte(MemoryAddresses.keyItems[gameVer]+i, 0x00)
      WriteByte(MemoryAddresses.keyItems[gameVer]+i+1, 0x00)
    end
  end
  for i=0, 20, 4 do
    if ReadByte(_foodStart[gameVer]+i) > 0x00 then
      WriteArray(_foodStart[gameVer]+i, {0x00, 0x00, 0x00, 0x00})
    end
  end
end

function ReceiveDeathlink(dateTime) --For receiving deathlink
  deathTime = tonumber(dateTime)
  if deathTime ~= nil and lastDeathTime ~= nil then
    if deathTime >= lastDeathTime + 3 then
      ConsolePrint("Deathlink Received")
      holdDeathlink = true
      --killPlayer()
      lastDeathTime = deathTime
    end
  end
end

function DropTrap()
  holdDropTrap = true
end

function DeliverDrop()
  if holdDropTrap then
    --Make sure player can drop

    if roomInfo[1] == 0x0B or roomInfo[1] == 0x01 then
      return
    end

    if ReadByte(MemoryAddresses.enablePause[gameVer]) == 0x00 and ReadByte(MemoryAddresses.cutscenePauseType[gameVer]) == 0x00 then
      forceDrop()
    end

    --See if drop has succeeded
    local _ptr = GetPointer(MemoryAddresses.deathPtr[gameVer], MemoryAddresses.deathOffset)
    if ReadByte(_ptr, true) == 4 then --Drop happened
      ConsolePrint("Drop happened")
      holdDropTrap = false
    end

  end
end

local _deathlinkSent = false
local _fromDeathlink = false
function CheckDeathlink() --For sending deathlink
  --Get current hp

  if roomInfo[1] == 0x0B or roomInfo[1] == 0x01 or roomInfo[2] >= 0x3C then
    return
  end

  local _hpPtr = GetPointer(Stats.currHpPtr[gameVer], Stats.currHpOffset)
  local _hpVal = ReadByte(_hpPtr, true)
  local _statePtr = GetPointer(MemoryAddresses.deathPtr[gameVer], MemoryAddresses.deathOffset)
  local _stateVal = ReadByte(_statePtr, true)

  local _canPause = ReadByte(MemoryAddresses.enablePause[gameVer])
  local _canPause2 = ReadByte(MemoryAddresses.cutscenePauseType[gameVer])

  if _stateVal == 3 and not _deathlinkSent and not _fromDeathlink then --Player is dead
    if _hpVal == 0x00 then --Make sure death wasn't caused by some other source
      ConsolePrint("Player died; sending deathlink")
      _deathlinkSent = true
      deathDate = os.date("!%Y%m%d%H%M%S")
      SendToApClient(MessageTypes.Deathlink, {tostring(deathDate)})
    end
  end

  if _hpVal > 0x00 and _canPause == 0x00 and _canPause2 == 0x00 and _stateVal ~= 3 then --Deathlink status can be cleared
    _deathlinkSent = false
    _fromDeathlink = false
  end

end

function ManageDrop()

  if keepDropActive > -1 then --We are not disabling the drop right now
    if keepDropActive ~= getCharacter() then
      keepDropActive = -1
    end
    return
  end

  --Trying an alternate method to manage drop meter
  local _dropVal = ReadByte(MemoryAddresses.dropEnabler[gameVer])
  if _dropVal ~= 0x00 then
    WriteArray(MemoryAddresses.dropEnabler[gameVer], {0x00, 0x00})
  end

  local _dropGaugeAddr = GetPointer(MemoryAddresses.dropPtr[gameVer], MemoryAddresses.dropOffset)
  --Keep gauge full
  WriteByte(_dropGaugeAddr+0x01, 0xFF, true)
  WriteByte(_dropGaugeAddr+0x02, 0x47, true)
  WriteByte(_dropGaugeAddr+0x03, 0x47, true)
end

local _fixPause = false
local _helpRiku = false
function SkipDETutorial()
  local tutorialInMenu = {0xA9B2D0, 0xA9AB50}
  local menuOpen = {0xA43440, 0xA42CC0}
  local pauseState = {0xA9B2F4, 0xA9AB74}
  local isPaused = {0xA9B302, 0xA9AB82}

  if ReadByte(tutorialInMenu[gameVer]) == 0x0E then
    --Prevent tutorial from showing up
    WriteByte(tutorialInMenu[gameVer], 0x01)
    WriteByte(MemoryAddresses.pauseType[gameVer], 0x03)

    --WriteByte(0xA9B2D0, 0x00)
    --WriteByte(0xA9B2D8, 0x00)
    --WriteByte(0xA9B2DC, 0x06)
    --WriteByte(0xA9B2F4, 0x0E)
    --WriteByte(0xA9B302, 0x00)

    _fixPause = true
  end

  --Fix Riku's 2nd District cutscene
  if getCharacter() == 1 and roomInfo[2] == 0x02 then
    if ReadByte(WorldFlags.traverseTown.riku.story[gameVer]+0x01) == 0x07 and ReadByte(MemoryAddresses.evt[gameVer]) <= 0x0001 and ReadByte(MemoryAddresses.cutscenePauseType[gameVer]) ~= 0x03 then
      if ReadByte(menuOpen[gameVer]) == 0x00 and ReadByte(tutorialInMenu[gameVer]) ~= 0x00 then
        WriteByte(MemoryAddresses.evt[gameVer], 0x0001)
        WriteByte(MemoryAddresses.map[gameVer], 0x0001)
        WriteByte(MemoryAddresses.btl[gameVer], 0x0001)
        --WriteByte(MemoryAddresses.room, 0x03)
        WriteByte(menuOpen[gameVer], 0x01) --Evt flag for Riku 2nd District

        WriteByte(pauseState[gameVer], 0x04) --Some kind of pause state

        _helpRiku = true
      end
    end
  end

  if _fixPause and ReadByte(MemoryAddresses.pauseType[gameVer]) == 0x03 and ReadByte(isPaused[gameVer]) == 0x00 and ReadByte(tutorialInMenu[gameVer]) == 0x00 and ReadByte(MemoryAddresses.cutscenePauseType[gameVer]) == 0x00 then
    --Prevent game from allowing player to open the main menu in battle
    WriteByte(MemoryAddresses.pauseType[gameVer], 0x00)
    _fixPause = false
  end

  if _helpRiku and getCharacter() == 1 and ReadByte(MemoryAddresses.room[gameVer]) ~= 0x02 then
    --Continue Riku's events if he leaves the room and the event was not triggered correctly
    if ReadByte(WorldFlags.traverseTown.riku.story[gameVer]+0x01) < 0x77 then --Have to make up the story
      WriteByte(MemoryAddresses.room[gameVer], 0x02)
    end
    _helpRiku = false
  end
end


function SetStartingLocation() --Sends player to the world map
  fixMenuOptions()
  WriteByte(WorldFlags.traverseTown.sora.story[gameVer], 0x11)
  WriteByte(WorldFlags.traverseTown.riku.story[gameVer], 0x31)
  WriteByte(WorldFlags.traverseTown.riku.story[gameVer]+0x01, 0x1F) --Force enable the menu fix for riku initially
  WriteByte(MemoryAddresses.world[gameVer], 0x0B)
  WriteByte(MemoryAddresses.room[gameVer], 0x01)
  WriteByte(DropAddresses.riku.world[gameVer], 0x0B)
  WriteByte(DropAddresses.riku.room[gameVer], 0x01)
  WriteByte(DropAddresses.sora.world[gameVer], 0x0B)
  WriteByte(DropAddresses.sora.room[gameVer], 0x01)

  --Write some main story so it doesn't interfere during gameplay
  --local _rgSora = {0xA41DC4, 0xA41644}
  --local _rgRiku = {0xA445DC, 0xA43E5C}
  --WriteArray(_rgSora[gameVer], {0xFF, 0xFF, 0xFF, 0xFF}) --Radiant Garden Sora
  --WriteArray(_rgRiku[gameVer], {0xFF, 0xFF, 0xFF, 0xFF}) --Radiant Garden Riku

  --Update save location
  local _saveLocation = {0xA40764, 0xA3FFE4}
  WriteArray(_saveLocation[gameVer], {0x0B, 0x01, 0x01})
end

-- ############################################################
-- ######################Game Commands#########################
-- ############################################################

function forceDrop()
  --ConsolePrint("Received forced drop")
  
  --Where are the drop gauge values
  ptr = GetPointer(MemoryAddresses.dropPtr[gameVer], 0x1B0)

  --Quickly re-enable dropping
  --WriteArray(MemoryAddresses.dropEnabler, {0x00, 0x00})
  keepDropActive = getCharacter()

  --Force the drop; set related gauge and bonus time bytes to 0
  WriteArray(ptr+0x01, {0x00, 0x00, 0x00}, true) --Gauge value
  WriteArray(ptr+0x0A, {0x00, 0x00, 0x00, 0x00}, true) --Bonus time value

end

function unstuck()
  if getCharacter() == 0 then
    --Send Riku to World Map
    ConsolePrint("Sending Riku to the World Map")
    WriteByte(DropAddresses.riku.world[gameVer], 0x0B)
    WriteByte(DropAddresses.riku.room[gameVer], 0x01)
    --WriteByte(DropAddresses.riku.map, 0x0001)
    --WriteByte(DropAddresses.riku.btl, 0x0001)
    --WriteByte(DropAddresses.riku.evt, 0x0001)
  else
    --Send Sora to World Map
    ConsolePrint("Sending Sora to the World Map")
    WriteByte(DropAddresses.sora.world[gameVer], 0x0B)
    WriteByte(DropAddresses.sora.room[gameVer], 0x01)
    --WriteByte(DropAddresses.sora.map, 0x0001)
    --WriteByte(DropAddresses.sora.btl, 0x0001)
    --WriteByte(DropAddresses.sora.evt, 0x0001)

  end
end

function killPlayer() --For death link
  
  if holdDeathlink then
    if ReadByte(MemoryAddresses.cutscenePauseType[gameVer]) ~= 0x00 then
      return
    end
    if ReadByte(MemoryAddresses.pauseType[gameVer]) ~= 0x00 then
      return
    end
    ConsolePrint("Deathlink triggered")
    local _ptr = GetPointer(MemoryAddresses.deathPtr[gameVer], MemoryAddresses.deathOffset)
    _fromDeathlink = true
    WriteByte(_ptr, 3, true) --Set to 4 for instant drop
    holdDeathlink = false
  end
end

-- ############################################################
-- ######################  Socket  ############################
-- #############  Special Thanks to Krujo & Shananas  #########
-- ############################################################

function ConnectToApClient()

  local ok, err = client:connect("127.0.0.1", 13713)

  if ok or err == "already connected" then
    ConsolePrint("Connected to client!")
    return true
  elseif err == "timeout" then
    return false
  else
    return false
  end
end

function SendToApClient(type,messages)
  if client then
    local message = tostring(type)
    for i = 1, #messages do
      message = message .. ";" .. tostring(messages[i])
    end
    message = message .. "\n"

    ConsolePrint("Sending message:" .. message)
    client:send(message)
  end
end

function SocketHasMessages()
  if client then
    local ready = socket.select({client}, nil, 0)
    if #ready > 0 then
      return true
    end
  end
  return false
end

function HandleMessage(msg)
  if msg.type == nil then
    ConsolePrint("No message type defined; cannot handle")
    return
  end

  --Receive Multiple Items from Server
  if msg.type == MessageTypes.ReceiveAllItems then
    ConsolePrint("Receiving all items")
    --ItemHandler:Reset()

    local _skipNext = false
    local _totReceived = 1
    for i = 1, #msg.values-1 do
      if _skipNext then
        _skipNext = false
      else
        local _msg = msg.values[i]
        local _itemType = getItemById(tonumber(_msg)).Type
        if msg.values[i+1] == "local" then
          --TODO: Remove invalid items from stock (abilities)
          --TODO: Still perform special functions like world unlocking
          --TODO: Directly invoking room save like this might result in duped items
          --      when re-receiving all from server
          ItemHandler:Receive(_itemType, tonumber(_msg), tonumber(msg.values[#msg.values])+_totReceived, true)
          --ReceiveLocalItem(tonumber(_msg), tonumber(msg.values[#msg.values])+_totReceived)
          --RoomSaveTask:StoreItem(tonumber(_msg))
          _skipNext = true
        else
          ConsolePrint(msg.values[#msg.values])
          ItemHandler:Receive(_itemType, tonumber(_msg), tonumber(msg.values[#msg.values])+_totReceived)
          --ReceiveItem(tonumber(_msg), tonumber(msg.values[#msg.values])+_totReceived)
        end
        _totReceived = _totReceived + 1
      end
    end

  --Receive Single Item from Server
  elseif msg.type == MessageTypes.ReceiveSingleItem then
    ConsolePrint("Receiving single item")
    local _itemType = getItemById(tonumber(msg.values[1])).Type
    if #msg.values > 2 then
      --Local item; add to roomsave and do not receive
      --ReceiveLocalItem(tonumber(msg.values[1]), tonumber(msg.values[2]))
      ItemHandler:Receive(_itemType, tonumber(msg.values[1]), tonumber(msg.values[2]), true)
      --RoomSaveTask:StoreItem(tonumber(msg.values[1]))
      return
    end
    --ReceiveItem(tonumber(msg.values[1]), tonumber(msg.values[2]))
    ItemHandler:Receive(_itemType, tonumber(msg.values[1]), tonumber(msg.values[2]))
    --RoomSaveTask:StoreItem(tonumber(msg.values[1]))


  elseif msg.type == MessageTypes.ItemPrompt then
    local _itemName = msg.values[1]
    local _playerName = msg.values[2]
    local _itemCategory = msg.values[3]

    if Configs.RemoteItemNotifs == 0 or Configs.RemoteItemNotifs == tonumber(_itemCategory) then
      MessageHandler:remoteReceived(_itemName, _playerName, tonumber(_itemCategory))
    end

    --ConsolePrint("Remote item message: Sent ".._itemName.." to ".._playerName.." | ".._itemCategory)

  elseif msg.type == MessageTypes.ClientCommand then
    local _cmdId = tonumber(msg.values[1])
    
    if _cmdId == 0 then --Force drop command
      forceDrop()
    elseif _cmdId == 1 then --Unstuck command
      unstuck()
    elseif _cmdId == 2 then --Death
      --killPlayer()
      holdDeathlink = true
    elseif _cmdId == 3 then --Deathlink Toggle
      if msg.values[2] ~= nil then
        if msg.values[2] == "True" then
          ConsolePrint("Enabling Deathlink")
          Configs.Deathlink = true
        else
          ConsolePrint("Disabling Deathlink")
          Configs.Deathlink = false
        end
      end
    end
  elseif msg.type == MessageTypes.Deathlink then
    local _deathTime = msg.values[1]
    ReceiveDeathlink(_deathTime)

  elseif msg.type == MessageTypes.SendSlotData then
    local _slotType = tonumber(msg.values[1])
    local _sentVals = {}
    for i=2, #msg.values do
      table.insert(_sentVals, tostring(msg.values[i]))
    end

    ConfigTask:ParseSlotData(_slotType, _sentVals)

  elseif msg.type == MessageTypes.Handshake then
    if not HandshakeReceived then
      SendToApClient(MessageTypes.HasSlotData, {"0"})
    else
      SendToApClient(MessageTypes.HasSlotData, {"1"})
    end
    HandshakeReceived = true
    ConsolePrint("Received handshake; Requesting items: "..msg.values[1])
    if msg.values[1] == "True" then
      SendToApClient(MessageTypes.RequestAllItems, {"Requesting Items"})
    end


  elseif msg.type == MessageTypes.GetCurrentIndex then
    SendToApClient(MessageTypes.GetCurrentIndex, {tostring(currentReceivedIndex)})
  end


end

local _receiveBuffer = ""
function ReceiveFromApClient()
  if SocketHasMessages() then
    local message, err, partial = client:receive('*l')
    if message then
      if _receiveBuffer ~= "" then
        message = _receiveBuffer .. message
        receiveBuffer = ""
      end
      ConsolePrint("Full message received: "..message)
      local parts = SplitString(message, ";")
      local type = tonumber(parts[1])
      local newMessage = {
        type = GetMessageType(type),
        values = {}
      }

      for i = 2, #parts do
        table.insert(newMessage.values, parts[i])
      end

      --Check if connection is closed
      if newMessage.type == MessageTypes.Closed then
        ConsolePrint("Server Closed; Resetting Client")
        CloseConnection()
        return
      end

      return newMessage

    elseif partial and #partial > 0 then
      receiveBuffer = receiveBuffer .. partial
      ConsolePrint("Partial message received")
    elseif err then
      ConsolePrint("Error receiving message: " .. err)
      if err == "timeout" then
        ConsolePrint("Please relaunch the AP Client")
        CloseConnection()
      end
    end
  else
    return nil
  end
end

function CloseConnection()
  --Close the socket connection and reset game state
  connectionInitialized = false
  gameStarted = false
  HandshakeSent = false
  HandshakeReceived = false
  client:close()
  client = socket.tcp()
  client:settimeout(0)
end

-- ############################################################
-- ######################  Helpers  ###########################
-- ############################################################

function ReceiveItem(itemID, itemCnt)
  if itemID == 2639999 then --Victory; Not a real item
    GoalGame()
    return
  end

  if itemID == nil then
    ConsolePrint("Invalid item received. Val: "..itemID)
    return
  end

  if itemID < 2630000 then --Trap received
    ConsolePrint("Sending drop trap")
    if lastReceivedIndex < currentReceivedIndex then
      DropTrap()
    end
    return
  end

  --Distribute real item
  local _item = getItemById(itemID)
  local _type = _item.Type
  if itemCnt <= currentReceivedIndex or lastReceivedIndex > currentReceivedIndex then
    checkIfCanReceive(itemID, _type)
  else

    --Check if a notification should be sent for this item
    if Configs.LocalItemNotifs == 0 then
      MessageHandler:msgReceived(itemID, 0)
    elseif Configs.LocalItemNotifs == 1 then
      local _progTypes = {"World", "Recipe", "Flowmotion", "Key", "Goal"}
      if hasValue(_progTypes, _type) or _item.Usefulness == item_usefulness.progression then
        MessageHandler:msgReceived(itemID, 0)
      end
    end


    ItemHandler:Receive(_type, itemID)
    RoomSaveTask:StoreItem(itemID)
  end
  updateReceived(itemCnt)
end

function ReceiveLocalItem(itemID, itemCnt)
  if itemID == nil then
    ConsolePrint("Local item invalid. Val: "..itemID)
    return
  end

  --TODO: RECEIVE COMMANDS IF THEY WERE OBTAINED FROM BONUS OR LEVEL UP

  if itemCnt <= currentReceivedIndex then
    return
  end

  local _item = getItemById(itemID)
  local _type = _item.Type
  
  local validTypes = {"Recipe", "Flowmotion", "World", "Key", "Stat", "Support", "Spirit", "Stats [Sora]", "Stats [Riku]"}

  --See if we should autocraft or record ability
  --local _isBehind = currentReceivedIndex < lastReceivedIndex
  local _isBehind = itemCnt < lastReceivedIndex

  if hasValue(validTypes, _type) then --Specially handle this item
    --Do not write physical item to inventory; only write the unique functionality
    if _type == "Recipe" then
      ConsolePrint("Local recipe obtained with behind value: "..tostring(_isBehind))
      ItemHandler:GiveRecipe(itemID, _isBehind, true)
    elseif _type == "Flowmotion" then
      ItemHandler:GiveFlowmotion(itemID, false)
    elseif _type == "World" and not _isBehind then
      WorldHandler:ObtainWorld(itemID) --TODO: This does not appear to be applying battle level correctly
      ItemHandler:PlaceWorldItem(itemID)
    elseif _type == "Key" then
      ItemHandler:GiveKeyItem(itemID) --TODO: Make sure this doesn't duplicate
    elseif _type == "Support" or _type == "Spirit" then
      ItemHandler:GiveAbility(itemID, not _isBehind)
    elseif _type == "Stat" then
      ItemHandler:GiveAbility(itemID, true)
    elseif _type == "Stats [Sora]" or _type == "Stats [Riku]" then
      ItemHandler:GiveStatBonus(itemID)
    end
  end

  updateReceived(itemCnt)

end

function toHex(str)
  return string.format("%X", str)
end

function toBits(num)
    -- returns a table of bits, least significant first.
    local t={} -- will contain the bits
    while num>0 do
        rest=math.fmod(num,2)
        t[#t+1]=rest
        num=(num-rest)/2
    end
    return t
end

function compareArrays(arr1, arr2)
  if #arr1 ~= #arr2 then
    return false
  end

  for i, v in ipairs(arr1) do
    if v ~= arr2[i] then
      return false
    end
  end

  return true
end

function hasValue(arr, val)
  for index, value in ipairs(arr) do
    if value == val then
      return true
    end
  end
  return false
end

function countValues(arr, val)
  local _cnt = 0
  for index, value in ipairs(arr) do
    if value == val then
      _cnt = _cnt + 1
    end
  end
  return _cnt
end

function findValue(arr, val)
  for index, value in ipairs(arr) do
    if value == val then
      return index
    end
  end
end

function removeDuplicates(arr)
  local _uniqueArr = {}
  local _seen = {}

  for _, value in ipairs(arr) do
    if not _seen[value] then
      table.insert(_uniqueArr, value)
      _seen[value] = true
    end
  end

  return _uniqueArr

end

function getChestById(loc_id, theChar)
  local _tempId = loc_id
  local _chestFound = false
  local _useChests = chests.sora
  if theChar == 1 then
    _useChests = chests.riku
  end
  for i = 1, #_useChests do
    if i+1 == #_useChests+1 then
      while _useChests[i].locationIDStart < _tempId and not _chestFound do
        _tempId = _tempId - 1
      end
    end
    while _useChests[i].locationIDStart < _tempId and _tempId < _useChests[i+1].locationIDStart and not _chestFound do
      _tempId = _tempId - 1
    end

    if _tempId == _useChests[i].locationIDStart then
      _chestFound = true
      return _useChests[i]
    end
  end
end

function getItemById(item_id)
  for i = 1, #items do
    if items[i].ID == tonumber(item_id) then
      return items[i]
    end
  end
  for i = 1, #abilities do
    if abilities[i].ID == tonumber(item_id) then
      return abilities[i]
    end
  end
end

function getAbilityById(ab_id)
  for i = 1, #abilities do
    if abilities[i].ID == ab_id then
      return abilities[i]
    end
  end
end

function SplitString(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function GetArraySum(arr)
  local _arrSum = 0
  for i=1, #arr do
    _arrSum = _arrSum + arr[i]
  end
  return _arrSum
end

function GetMessageType(value)
  for name, number in pairs(MessageTypes) do
    if number == value then
        return MessageTypes[name]
    end
  end
  return nil
end

function textToKHSCII(value)
  --Returns byte array based on string
  returnArr = {}
  for i=1, #value do
    local c = value:sub(i, i)
    local charCode = charToKHSCII(c)
    table.insert(returnArr, charCode)
    table.insert(returnArr, 0x00)
  end
  return returnArr
end

function charToKHSCII(char)
  local returnChars = {
    ["A"] = KHSCII.A,["B"] = KHSCII.B,["C"] = KHSCII.C,["D"] = KHSCII.D,
    ["E"] = KHSCII.E,["F"] = KHSCII.F,["G"] = KHSCII.G,["H"] = KHSCII.H,
    ["I"] = KHSCII.I,["J"] = KHSCII.J,["K"] = KHSCII.K,["L"] = KHSCII.L,
    ["M"] = KHSCII.M,["N"] = KHSCII.N,["O"] = KHSCII.O,["P"] = KHSCII.P,
    ["Q"] = KHSCII.Q,["R"] = KHSCII.R,["S"] = KHSCII.S,["T"] = KHSCII.T,
    ["U"] = KHSCII.U,["V"] = KHSCII.V,["W"] = KHSCII.W,["X"] = KHSCII.X,
    ["Y"] = KHSCII.Y,["Z"] = KHSCII.Z,
    ["a"] = KHSCII.a,["b"] = KHSCII.b,["c"] = KHSCII.c,["d"] = KHSCII.d,
    ["e"] = KHSCII.e,["f"] = KHSCII.f,["g"] = KHSCII.g,["h"] = KHSCII.h,
    ["i"] = KHSCII.i,["j"] = KHSCII.j,["k"] = KHSCII.k,["l"] = KHSCII.l,
    ["m"] = KHSCII.m,["n"] = KHSCII.n,["o"] = KHSCII.o,["p"] = KHSCII.p,
    ["q"] = KHSCII.q,["r"] = KHSCII.r,["s"] = KHSCII.s,["t"] = KHSCII.t,
    ["u"] = KHSCII.u,["v"] = KHSCII.v,["w"] = KHSCII.w,["x"] = KHSCII.x,
    ["y"] = KHSCII.y,["z"] = KHSCII.z,
    ["0"] = KHSCII.Zero,["1"] = KHSCII.One,["2"] = KHSCII.Two,["3"] = KHSCII.Three,
    ["4"] = KHSCII.Four,["5"] = KHSCII.Five,["6"] = KHSCII.Six,["7"] = KHSCII.Seven,
    ["8"] = KHSCII.Eight,["9"] = KHSCII.Nine, [":"] = KHSCII.Colon,
    ["."] = KHSCII.Period,[" "] = KHSCII.Space,["!"] = KHSCII.Exclamation,["&"] = KHSCII.And,
    ["("] = KHSCII.LeftParen, ["["] = KHSCII.LeftBracket, ["]"] = KHSCII.RightBracket,
    ["'"] = KHSCII.Apostrophe, ["|"] = KHSCII.Enter, ["/"] = KHSCII.ForwardSlash, 
    ["\\"] = KHSCII.BackSlash
  }

  if returnChars[char] == nil then
    returnChars[char] = KHSCII.Period
  end

  return returnChars[char]
end

function writeTxtToGame(startAddr, txt, fillerCnt)
  txtBytes = textToKHSCII(txt)
  for i=1, fillerCnt do
    table.insert(txtBytes, 0x00)
    table.insert(txtBytes, 0x00)
  end
  WriteArray(startAddr, txtBytes)
end

function getCharacter() --Returns 0 for sora, 1 for riku
  return activeCharacter
end

function updateCharacter()
  if ReadByte(MemoryAddresses.character[gameVer]) ~= activeCharacter then
    activeCharacter = ReadByte(MemoryAddresses.character[gameVer])
    onCharacterChange()
  end
end

function updateRoomInfo()
  local _readInfo = ReadArray(MemoryAddresses.world[gameVer], 0x05)
  if _readInfo[1] ~= roomInfo[1] or _readInfo[2] ~= roomInfo[2] or _readInfo[5] ~= roomInfo[3] then
    roomInfo[1] = _readInfo[1]
    roomInfo[2] = _readInfo[2]
    roomInfo[3] = _readInfo[5]
    onRoomChange()
    dataStorage()
  end 
end

function updateReceived(itemCnt)
  if currentReceivedIndex < lastReceivedIndex then --Increment current received until we reach our last received
    currentReceivedIndex = currentReceivedIndex+1
  else --Fill with item index of latest received
    if itemCnt > currentReceivedIndex then
      currentReceivedIndex = itemCnt
    end
    receivedInit = true --We have finished receiving the intial set of items from the mod
  end
  --WriteInt(MemoryAddresses.medals[gameVer], currentReceivedIndex)
  WriteShort(WorldFlags.destinyIslands.sora.story[gameVer]+0x07, currentReceivedIndex)
  ConsolePrint("Current Received Index: "..tostring(currentReceivedIndex))
  ConsolePrint("Last Received Index: "..tostring(lastReceivedIndex))
  ConsolePrint("Item Cnt: "..tostring(itemCnt))
end

--This function is needed for room save to work
function sendToInv(itemId)
  local _item = getItemById(itemId)
  if _item.Type == "Support" or _item.Type == "Spirit" then --Ability redeemed
    ItemHandler:GiveAbility(itemId, true)
  elseif _item.Type == "World" then --Send world item
    ItemHandler:PlaceWorldItem(itemId)
  elseif _item.Type == "Recipe" then --Recipes don't need to be re-added to our state
    ItemHandler:RecipeToInv(itemId)
  else
    ItemHandler:Receive(_item.Type, itemId)
  end
end

function checkIfCanReceive(id, type)
  local validTypes = {"Stats [Sora]", "Stats [Riku]", "Recipe", "Flowmotion", "World", "Key", "Stat"}
  if hasValue(validTypes, type) and not receivedInit then
    --For recipe, create a version that only adds to table and bypasses adding recipe to inventory and auto-craft
    if type ~= "Recipe" and type ~= "Key" and type ~= "Stat" then
      ConsolePrint("Successfully received stat/movement/world")
      ItemHandler:Receive(type, id)
      RoomSaveTask:StoreItem(id)
    elseif type == "Key" or type == "Stat" then
      ItemHandler:Receive(type, id) --Don't store this in room save
    else
      ConsolePrint("Successfully received recipe")
      ItemHandler:RecipeToState(id)
    end
  end
end

function dataStorage()
  --Send some info to the server for data storage
  SendToApClient(MessageTypes.DataStorage, {tostring(roomInfo[1]), tostring(roomInfo[2]), tostring(getCharacter())})
end

-- ############################################################
-- ######################  Game Setup  ########################
-- ############################################################

function main()
  updateRoomInfo()

  MessageHandler:runItemQueue()
  MessageHandler:clearItemQueue()

  LocationHandler:CheckChestBits()
  LocationHandler:CheckLevel()
  LocationHandler:CheckStory()
  LocationHandler:JuliusDefeated()
  LocationHandler:CheckPortal() --Move back to _onframe if this does not consistently check

  removeStatKeys() --TODO: Maybe run this less often?

  killPlayer() --Check if deathlink is received

  removeDummyItem()

  updateCharacter()

  ManageDrop() --Disabled dropping

  RoomSaveTask:StoreExp()

  ItemHandler:RebuildFlowmotion()

  doingPortal = LocationHandler.inAPortal
  
end

function APCommunication() --Interpret AP messages
  while true do --Using a loop allows us to get multiple messages per frame
    local msg = ReceiveFromApClient()
    if msg then
      HandleMessage(msg)
    else
      break
    end
  end
end

function OnGameStart()
  local connected =  ConnectToApClient()

  if connected then
    connectionInitialized = true
    gameStarted = true
    initGameState()
    lastReceivedIndex = ReadShort(WorldFlags.destinyIslands.sora.story[gameVer]+0x07)
    --lastReceivedIndex = ReadInt(MemoryAddresses.medals[gameVer])

    --Nop functions that prevent AP stuff from working correctly

    --Prevents abilities from overwriting
    local _abFunc = {0x376EB5, 0x376EA4}
    local _worldChest = {0x271A43, 0x271A33}
    local _abChest = {0x271956, 0x271946}
    local _btlFunc = {0x23A980, 0x23A970}
    WriteArray(_abFunc[gameVer], {0x90, 0x90, 0x90, 0x90, 0x90}) --TODO: Get EGS Address
    --Make world item chests open-able
    WriteArray(_worldChest[gameVer], {0x39, 0xC0, 0x90, 0x90, 0x90}) --TODO: Get EGS Address
    --Make recipe chests open-able
    --WriteArray(0x2719FA, {0x39, 0xC0, 0x90, 0x90, 0x90})
    --Make ability chests open-able
    WriteArray(_abChest[gameVer], {0xB0, 0x01})

    --Prevent battle level from being overwritten (may only apply to riku?)
    WriteArray(_btlFunc[gameVer], {0x90, 0x90})

    --Game Clear Flag
    --WriteByte(0xA40780, 0x01)

    ------------------ENABLE DEV CHEATS--------------------
    --cheatGame()
  end
end

function GoalGame()
  SendToApClient(MessageTypes.Victory, {"Game Completed"})
end

function GameVersion()
  if ReadLong(_isEpic) == 0x7265737563697065 then
    ConsolePrint("Running KHDDD AP for EGS")
    gameVer = 2
    return true
  elseif ReadLong(_isSteam) == 0x7265737563697065 then
    ConsolePrint("Running KHDDD AP for Steam")
    gameVer = 1
    return true
  end
  return false
end

function _OnInit()
  local _gameDetected = GameVersion()

  ConsolePrint("Game ID: ".. tostring(gameID))

  --Initialize Socket
  client = socket.tcp()
  client:settimeout(0)

  --Initialize items and locations
  LocationDefs:DefineChests()
  LocationDefs:DefineWorldEvents()
  LocationDefs:DefinePortals()
  ItemDefs:DefineItems()
  ItemDefs:DefineAbilities()
  PatchTask:InitPatchTable()
  Spirits:DefineSpiritStats()

  if gameID == 3899271824 and _gameDetected then
    canExecute = true
  else
    ConsolePrint("Dream Drop Distance not detected. Make sure your game is up to date.")
  end
end

local _exeTime = -1
function timerStart()
  if not _isPaused then
    _exeTime = os.clock()
  end
end

function timerEnd(funcName)
  if _exeTime == -1 then
    return
  end
  local _endTime = os.clock()
  local _totalTime = _endTime - _exeTime
  local _formatStr = string.format("%.6f", _totalTime)
  if _formatStr ~= "0.000000" and _formatStr ~= "0.001000" then
    ConsolePrint(string.format("Execution time for "..funcName..": %.6f seconds", _totalTime))
  end
  _exeTime = -1
end

function _OnFrame()

  frameCount = (frameCount+1)%30
  if not gameStarted then
    if frameCount == 0 and ReadByte(MemoryAddresses.world[gameVer]) ~= 0xFF then --Save file is loaded if not on title screen
      OnGameStart()
    end
    return
  end

  if not HandshakeSent then
    --Request handshake from server
    SendToApClient(MessageTypes.Handshake, {"Requesting Handshake"})
    HandshakeSent = true
    return
  end
  if not HandshakeReceived then
    APCommunication()
  end

  if frameCount == 0 and canExecute then --Dont run main logic every frame
    APCommunication()
    main()
  end

  --Skip Dream Eater Tutorial
  SkipDETutorial()

  StoryHandler:OverwriteStoryVars()

  checkPause()

  if Configs.LordKyroo then
    LocationHandler:LordKyroo()
  end

  DeliverDrop() --For sending drop traps

  MessageHandler:checkForRestore()

  --Room Save
  RoomSaveTask:GetRoomChange()
  RoomSaveTask:CheckPlayerState()

  --Prevent potential softlocks
  SoftlockTask:PreventSoftlocks()

  --Check if reward items need to be replaced
  PatchTask:CheckForPatch()

  --Is player in report
  if ReadByte(MemoryAddresses.subMenu[gameVer]) == 0x07 then --Reports are open
    RunReports()
  end

  if Configs.Deathlink then
    CheckDeathlink()
  end
end