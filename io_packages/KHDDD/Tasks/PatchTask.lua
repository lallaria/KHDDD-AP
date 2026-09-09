local PatchTask = {}

local _rewardAddr = {0xA96F28, 0xA967A8} --TODO: Find EGS Address

function PatchTask:InitPatchTable()
	--TODO: Build out reward sets so this works better
PatchTask.RewardSets = {
	{ --Set 1 - Ursula Battle
		character=0, world=1, worldAddr=WorldFlags.destinyIslands.sora.story[gameVer], story=0x00, ind=1, 
		rewardSlot=0, locals = {false, false, false, false}, ids = {2670202, 2670203, 2670204, 2670205},
		bytes = {{0x00, 0x00}, {0x00, 0x00}, {0x00, 0x00}, {0x00, 0x00}}
	},
	{ --Set 2 - Sora Dream Eaters 1
		character=0, world=3, worldAddr=WorldFlags.traverseTown.sora.story[gameVer], story=0x00, ind=0,
		rewardSlot=0, locals = {false, false}, ids = {2670206, 2670207}, bytes = {{0x00, 0x00}, {0x00, 0x00}}
	},
	{ --Set 3 - Sora Dream Eaters 2
		character=0, world=3, worldAddr=WorldFlags.traverseTown.sora.story[gameVer], story=0x7F, ind=1,
		rewardSlot = 0, locals = {false}, ids = {2670248}, bytes={{0x00, 0x00}}
	},
	{ --Set 4 - Skull Noise
		character=0, world=3, worldAddr=WorldFlags.traverseTown.sora.story[gameVer], story=0x00, ind=2,
		rewardSlot = 0, locals = {false}, ids = {2670213}, bytes={{0x00, 0x00}}
	},
	{ --Set 5 - Knockout Punch
		character=0, world=3, worldAddr = WorldFlags.traverseTown.sora.story[gameVer], story=0x30, ind=4,
		rewardSlot=0, locals={false}, ids={2670286}, bytes={{0x00, 0x00}}
	},
	{ --Set 6 - Ultima Weapon
		character=0, world=3, worldAddr=WorldFlags.traverseTown.sora.story[gameVer], story=0x01, ind=5,
		rewardSlot=0, locals={false}, ids={2670292}, bytes={{0x00, 0x00}}
	},
	{ --Set 7 - Zolephant Recipe
		character=0, world=8, worldAddr=WorldFlags.laCiteDesCloches.sora.story[gameVer], story=0x00, ind=0,
		rewardSlot=0, locals={false}, ids={2670214}, bytes={{0x00, 0x00}}
	},
	{ --Set 8 - Flashback: Frollo Warns Quasimodo
		character=0, world=8, worldAddr=WorldFlags.laCiteDesCloches.sora.story[gameVer], story=0x10, ind=1,
		rewardSlot=0, locals={false}, ids={2670215}, bytes={{0x00, 0x00}}
	},
	{ --Set 9 - Chronicle BBS & Guardian Bell
		character=0, world=8, worldAddr=WorldFlags.laCiteDesCloches.sora.story[gameVer], story=0x10, ind=2,
		rewardSlot=0, locals={false, false}, ids={2670218, 2670219}, bytes={{0x00, 0x00}, {0x00, 0x00}}
	},
	{ --Set 10 - Counter Rush
		character=0, world=9, worldAddr=WorldFlags.theGrid.sora.story[gameVer], story=0x00, ind=0,
		rewardSlot=0, locals={false}, ids={2670220}, bytes={{0x00, 0x00}}
	},
	{ --Set 11 - Dual Disc
		character=0, world=9, worldAddr=WorldFlags.theGrid.sora.story[gameVer], story=0x10, ind=2,
		rewardSlot=0, locals={false}, ids={2670223}, bytes={{0x00, 0x00}}
	},
	{ --Set 12 - Flashback: Pinocchio Lies
		character=0, world=6, worldAddr=WorldFlags.prankstersParadise.sora.story[gameVer], story=0x00, ind=0,
		rewardSlot=3, locals={false}, ids={2670224}, bytes={{0x00, 0x00}}, hasKyroo=4, kyrooBit=1
	},
	{ --Set 13 - Flashback: When World's Dream
		character=0, world=6, worldAddr=WorldFlags.prankstersParadise.sora.story[gameVer], story=0x04, ind=1,
		rewardSlot=3, locals={false}, ids={2670225}, bytes={{0x00, 0x00}}, hasKyroo=4, kyrooBit=1
	},
	{	--Set 14 - Jestabocky Recipe
		character=0, world=6, worldAddr=WorldFlags.prankstersParadise.sora.story[gameVer], story=0x07, ind=1,
		rewardSlot=0, locals={false}, ids={2670227}, bytes={{0x00, 0x00}}, hasKyroo=4, kyrooBit=1
	},
	{ --Set 15 - Circus Glossaries
		character=0, world=6, worldAddr=WorldFlags.prankstersParadise.sora.story[gameVer], story=0x10, ind=2,
		rewardSlot=0, locals={false, false, false}, ids={2670229, 2670230, 2670231}, 
		bytes={{0x00, 0x00}, {0x00, 0x00}, {0x00, 0x00}}, hasKyroo=4, kyrooBit=1
	},
	{ --Set 16 - In Search of Monstro
		character=0, world=6, worldAddr=WorldFlags.prankstersParadise.sora.story[gameVer], story=0x20, ind=2,
		rewardSlot=2, locals={false}, ids={2670232}, bytes={{0x00, 0x00}}, hasKyroo=4, kyrooBit=1
	},
	{ --Set 17 - Ferris Gear
		character=0, world=6, worldAddr=WorldFlags.prankstersParadise.sora.story[gameVer], story=0x30, ind=3,
		rewardSlot=0, locals={false}, ids={2670234}, bytes={{0x00, 0x00}}, hasKyroo=4, kyrooBit=1
	},
	{ --Set 18 - Lord Kyroo
		character=0, world=6, worldAddr=WorldFlags.prankstersParadise.sora.story[gameVer], story=0x00, ind=4,
		rewardSlot=0, locals={false}, ids={2650652}, bytes={{0x00, 0x00}}, hasKyroo=4, kyrooBit=1, kyrooRoom = 0x04
	},
	{ --Set 19 - Overnight Musketeers
		character=0, world=4, worldAddr=WorldFlags.countryOfMusketeers.sora.story[gameVer], story=0x00, ind=0,
		rewardSlot=0, locals={false}, ids={2670235}, bytes={{0x00, 0x00}}
	},
	{ --Set 20 - Tyranto Rex Recipe
		character=0, world=4, worldAddr=WorldFlags.countryOfMusketeers.sora.story[gameVer], story=0x10, ind=1,
		rewardSlot=0, locals={false}, ids={2670236}, bytes={{0x00, 0x00}}
	},
	{ --Set 21 - All for One
		character=0, world=4, worldAddr=WorldFlags.countryOfMusketeers.sora.story[gameVer], story=0x01, ind=3,
		rewardSlot=0, locals={false}, ids={2670239}, bytes={{0x00, 0x00}}
	},
	{ --Set 22 - Flashback: Sorcerer's Apprentice
		character=0, world=5, worldAddr=WorldFlags.symphonyOfSorcery.sora.story[gameVer], story=0x00, ind=0,
		rewardSlot=0, locals={false}, ids={2670240}, bytes={{0x00, 0x00}}
	},
	{ --Set 23 - Double Impact
		character=0, world=5, worldAddr=WorldFlags.symphonyOfSorcery.sora.story[gameVer], story=0x07, ind=1,
		rewardSlot=0, locals={false}, ids={2670241}, bytes={{0x00, 0x00}}
	},
	{ --Set 24 - Counterpoint
		character=0, world=5, worldAddr=WorldFlags.symphonyOfSorcery.sora.story[gameVer], story=0x00, ind=2,
		rewardSlot=0, locals={false}, ids={2670244}, bytes={{0x00, 0x00}}
	},
	{ --Set 25 - Hearts Tied to Sora
		character=0, world=10, worldAddr=WorldFlags.theWorldThatNeverWas.sora.story[gameVer], story=0x00, ind=0,
		rewardSlot=0, locals={false}, ids={2670247}, bytes={{0x00, 0x00}}
	},
	{ --Set 26 - Komory Bat
		character=1, world=3, worldAddr=WorldFlags.traverseTown.riku.story[gameVer], story=0x00, ind=0,
		rewardSlot=0, locals={false}, ids={2670249}, bytes={{0x00, 0x00}}
	},
	{ --Set 27 - Defeat Beat
		character=1, world=3, worldAddr=WorldFlags.traverseTown.riku.story[gameVer], story=0x10, ind=1,
		rewardSlot=0, locals={false, false, false, false}, ids={2670250, 2670251, 2670252, 2670253},
		bytes={{0x00, 0x00}, {0x00, 0x00}, {0x00, 0x00}, {0x00, 0x00}}
	},
	{ --Set 28 - Skull Noise
		character=1, world=3, worldAddr=WorldFlags.traverseTown.riku.story[gameVer], story=0x1F, ind=2,
		rewardSlot=0, locals={false}, ids={2670257}, bytes={{0x00, 0x00}}
	},
	{ --Set 29 - Cera Terror Recipe
		character=1, world=3, worldAddr=WorldFlags.traverseTown.riku.story[gameVer], story=0x10, ind=3,
		rewardSlot=0, locals={false}, ids={2670290}, bytes={{0x00, 0x00}}
	},
	{ --Set 30 - Knockout Punch
		character=1, world=3, worldAddr=WorldFlags.traverseTown.riku.story[gameVer], story=0x80, ind=3,
		rewardSlot=0, locals={false}, ids={2670291}, bytes={{0x00, 0x00}}
	},
	{ --Set 31 - Ultima Weapon
		character=1, world=3, worldAddr=WorldFlags.traverseTown.riku.story[gameVer], story=0x10, ind=4,
		rewardSlot=0, locals={false}, ids={2670293}, bytes={{0x00, 0x00}}
	},
	{ --Set 32 - Flashback: Dark Obsession & Sonic Impact
		character=1, world=8, worldAddr=WorldFlags.laCiteDesCloches.riku.story[gameVer], story=0x10, ind=1,
		rewardSlot=0, locals={false, false}, ids={2670258, 2670259}, bytes={{0x00, 0x00}, {0x00, 0x00}}, hasKyroo=true
	},
	{ --Set 33 - Chronicle Kingdom Hearts
		character=1, world=8, worldAddr=WorldFlags.laCiteDesCloches.riku.story[gameVer], story=0x01, ind=2,
		rewardSlot=0, locals={false}, ids={2670262}, bytes={{0x00, 0x00}}, hasKyroo=2, kyrooBit=5
	},
	{ --Set 34 - Guardian Bell
		character=1, world=8, worldAddr=WorldFlags.laCiteDesCloches.riku.story[gameVer], story=0x03, ind=2,
		rewardSlot=0, locals={false}, ids={2670263}, bytes={{0x00, 0x00}}, hasKyroo=2, kyrooBit=5
	},
	{ --Set 35 - Lord Kyroo
		character=1, world=8, worldAddr=WorldFlags.laCiteDesCloches.riku.story[gameVer], story=0x08, ind=2,
		rewardSlot=0, locals={false}, ids={2650652}, bytes={{0x00, 0x00}}, hasKyroo=2, kyrooBit=5, kyrooRoom = 0x03
	},
	{ --Set 36 - Flashback: Father and Son
		character=1, world=9, worldAddr=WorldFlags.theGrid.riku.story[gameVer], story=0x10, ind=1,
		rewardSlot=0, locals={false}, ids={2670265}, bytes={{0x00, 0x00}}
	},
	{ --Set 37 - Flashback: Stolen Disk
		character=1, world=9, worldAddr=WorldFlags.theGrid.riku.story[gameVer], story=0x01, ind=2,
		rewardSlot=0, locals={false}, ids={2670267}, bytes={{0x00, 0x00}}
	},
	{ --Set 38 - Dual Disc
		character=1, world=9, worldAddr=WorldFlags.theGrid.riku.story[gameVer], story=0x01, ind=3,
		rewardSlot=0, locals={false}, ids={2670269}, bytes={{0x00, 0x00}}
	},
	{ --Set 39 - Chronicle Chain of Memories
		character=1, world=6, worldAddr=WorldFlags.prankstersParadise.riku.story[gameVer], story=0x01, ind=1,
		rewardSlot=0, locals={false}, ids={2670270}, bytes={{0x00, 0x00}}
	},
	{ --Set 40 - Ocean's Rage
		character=1, world=6, worldAddr=WorldFlags.prankstersParadise.riku.story[gameVer], story=0x40, ind=1,
		rewardSlot=0, locals={false}, ids={2670272}, bytes={{0x00, 0x00}}
	},
	{ --Set 41 - Flashback: Bon Voyage
		character=1, world=4, worldAddr=WorldFlags.countryOfMusketeers.riku.story[gameVer], story=0x01, ind=1,
		rewardSlot=0, locals={false}, ids={2670273}, bytes={{0x00, 0x00}}
	},
	{ --Set 42 - All for One
		character=1, world=4, worldAddr=WorldFlags.countryOfMusketeers.riku.story[gameVer], story=0x30, ind=1,
		rewardSlot=0, locals={false}, ids={2670278}, bytes={{0x00, 0x00}}
	},
	{ --Set 43 - Flashback: A Magical Mishap
		character=1, world=5, worldAddr=WorldFlags.symphonyOfSorcery.riku.story[gameVer], story=0x01, ind=1,
		rewardSlot=0, locals={false}, ids={2670279}, bytes={{0x00, 0x00}}, hasKyroo=2, kyrooInd=2, kyrooBit=5
	},
	{ --Set 44 - Counterpoint
		character=1, world=5, worldAddr=WorldFlags.symphonyOfSorcery.riku.story[gameVer], story=0x01, ind=2,
		rewardSlot=0, locals={false}, ids={2670282}, bytes={{0x00, 0x00}}, hasKyroo=2, kyrooInd=2, kyrooBit=5
	},
	{ --Set 45 - Lord Kyroo
		character=1, world=5, worldAddr=WorldFlags.symphonyOfSorcery.riku.story[gameVer], story=0x08, ind=2,
		rewardSlot=0, locals={false}, ids={2650652}, bytes={{0x00, 0x00}}, hasKyroo=2, kyrooInd=2, kyrooBit=5, kyrooRoom = 0x06
	},
}

PatchTask.LevelOrders = { --TODO: Optimize; can just use integer for which message to overwrite
  --["LevelNum"] = {Atk, Mag, Def, ItemID}
  Sora = {
    ["2"] = {1, 0, 0, 0}, ["3"] = {1, 1, 1, 0}, ["4"] = {0, 1, 0, 0}, ["5"] = {1, 0, 1, 0}, 
    ["6"] = {0, 1, 0, 0}, ["7"] = {1, 1, 1, 0}, ["8"] = {1, 0, 1, 0}, ["9"] = {0, 1, 0, 0}, ["10"] = {1, 1, 1, 0},
    ["11"] = {1, 0, 0, 0}, ["12"] = {0, 1, 1, 0}, ["13"] = {1, 1, 0, 0}, ["14"] = {0, 0, 1, 0}, ["15"] = {1, 1, 1, 0},
    ["16"] = {1, 1, 0, 0}, ["17"] = {0, 0, 1, 0}, ["18"] = {1, 1, 0, 0}, ["19"] = {0, 1, 1, 0}, ["20"] = {1, 0, 0, 0},
    ["21"] = {1, 1, 1, 0}, ["22"] = {0, 1, 0, 0}, ["23"] = {1, 0, 1, 0}, ["24"] = {1, 1, 1, 0}, ["25"] = {0, 1, 0, 0},
    ["26"] = {1, 0, 1, 0}, ["27"] = {0, 1, 0, 0}, ["28"] = {1, 1, 1, 0}, ["29"] = {1, 0, 0, 0}, ["30"] = {0, 1, 1, 0},
    ["31"] = {1, 1, 0, 0}, ["32"] = {1, 0, 1, 0}, ["33"] = {0, 1, 1, 0}, ["34"] = {1, 1, 0, 0}, ["35"] = {0, 0, 1, 0},
    ["36"] = {1, 1, 0, 0}, ["37"] = {1, 0, 1, 0}, ["38"] = {0, 1, 0, 0}, ["39"] = {1, 1, 1, 0}, ["40"] = {1, 0, 1, 0},
    ["41"] = {0, 1, 0, 0}, ["42"] = {1, 0, 1, 0}, ["43"] = {0, 1, 0, 0}, ["44"] = {1, 1, 1, 0}, ["45"] = {1, 1, 0, 0},
    ["46"] = {0, 0, 1, 0}, ["47"] = {1, 1, 0, 0}, ["48"] = {0, 1, 1, 0}, ["49"] = {1, 0, 1, 0}, ["50"] = {1, 1, 0, 0},
    ["51"] = {0, 1, 1, 0}, ["52"] = {1, 0, 0, 0}, ["53"] = {1, 1, 1, 0}, ["54"] = {0, 1, 0, 0}, ["55"] = {1, 0, 1, 0},
    ["56"] = {0, 1, 0, 0}, ["57"] = {1, 1, 1, 0}, ["58"] = {1, 0, 1, 0}, ["59"] = {0, 1, 0, 0}, ["60"] = {1, 1, 1, 0},
    ["61"] = {1, 0, 0, 0}, ["62"] = {0, 1, 1, 0}, ["63"] = {1, 1, 0, 0}, ["64"] = {0, 0, 1, 0}, ["65"] = {1, 1, 1, 0},
    ["66"] = {1, 1, 0, 0}, ["67"] = {0, 0, 1, 0}, ["68"] = {1, 1, 0, 0}, ["69"] = {0, 1, 1, 0}, ["70"] = {1, 0, 0, 0},
    ["71"] = {1, 1, 1, 0}, ["72"] = {0, 1, 0, 0}, ["73"] = {1, 0, 1, 0}, ["74"] = {1, 1, 1, 0}, ["75"] = {0, 1, 0, 0},
    ["76"] = {1, 0, 1, 0}, ["77"] = {0, 1, 0, 0}, ["78"] = {1, 1, 1, 0}, ["79"] = {1, 0, 0, 0}, ["80"] = {0, 1, 1, 0},
    ["81"] = {1, 1, 0, 0}, ["82"] = {1, 0, 1, 0}, ["83"] = {0, 1, 1, 0}, ["84"] = {1, 1, 0, 0}, ["85"] = {0, 0, 1, 0},
    ["86"] = {1, 1, 0, 0}, ["87"] = {1, 0, 1, 0}, ["88"] = {0, 1, 0, 0}, ["89"] = {1, 1, 1, 0}, ["90"] = {1, 0, 1, 0},
    ["91"] = {0, 1, 0, 0}, ["92"] = {1, 0, 1, 0}, ["93"] = {0, 1, 0, 0}, ["94"] = {1, 1, 1, 0}, ["95"] = {1, 1, 0, 0},
    ["96"] = {0, 0, 1, 0}, ["97"] = {1, 1, 0, 0}, ["98"] = {0, 1, 1, 0}, ["99"] = {1, 0, 1, 0}
  },
  Riku = {
    ["2"] = {0, 0, 1, 0}, ["3"] = {1, 1, 1, 0}, ["4"] = {0, 0, 1, 0}, ["5"] = {1, 0, 1, 0},
    ["6"] = {1, 1, 0, 0}, ["7"] = {0, 1, 1, 0}, ["8"] = {1, 0, 0, 0}, ["9"] = {1, 1, 1, 0}, ["10"] = {0, 1, 0, 0},
    ["11"] = {1, 0, 1, 0}, ["12"] = {1, 1, 0, 0}, ["13"] = {0, 0, 1, 0}, ["14"] = {1, 1, 0, 0}, ["15"] = {1, 1, 1, 0},
    ["16"] = {0, 0, 1, 0}, ["17"] = {1, 1, 0, 0}, ["18"] = {0, 1, 1, 0}, ["19"] = {1, 0, 0, 0}, ["20"] = {1, 1, 1, 0},
    ["21"] = {0, 1, 0, 0}, ["22"] = {1, 0, 1, 0}, ["23"] = {1, 1, 0, 0}, ["24"] = {0, 1, 1, 0}, ["25"] = {1, 0, 0, 0},
    ["26"] = {1, 1, 1, 0}, ["27"] = {0, 1, 0, 0}, ["28"] = {1, 0, 1, 0}, ["29"] = {0, 1, 1, 0}, ["30"] = {1, 1, 0, 0},
    ["31"] = {1, 0, 1, 0}, ["32"] = {0, 1, 0, 0}, ["33"] = {1, 0, 1, 0}, ["34"] = {1, 1, 0, 0}, ["35"] = {0, 1, 1, 0},
    ["36"] = {1, 0, 0, 0}, ["37"] = {1, 1, 1, 0}, ["38"] = {0, 1, 0, 0}, ["39"] = {1, 0, 1, 0}, ["40"] = {1, 1, 1, 0},
    ["41"] = {0, 1, 0, 0}, ["42"] = {1, 0, 1, 0}, ["43"] = {0, 1, 0, 0}, ["44"] = {1, 1, 1, 0}, ["45"] = {1, 0, 0, 0},
    ["46"] = {0, 1, 1, 0}, ["47"] = {1, 1, 0, 0}, ["48"] = {1, 0, 1, 0}, ["49"] = {0, 1, 0, 0}, ["50"] = {1, 1, 1, 0},
    ["51"] = {1, 0, 0, 0}, ["52"] = {0, 1, 1, 0}, ["53"] = {1, 0, 1, 0}, ["54"] = {0, 1, 0, 0}, ["55"] = {1, 1, 1, 0},
    ["56"] = {1, 0, 0, 0}, ["57"] = {0, 1, 1, 0}, ["58"] = {1, 1, 0, 0}, ["59"] = {1, 0, 1, 0}, ["60"] = {0, 1, 0, 0},
    ["61"] = {1, 1, 1, 0}, ["62"] = {1, 0, 0, 0}, ["63"] = {0, 1, 1, 0}, ["64"] = {1, 1, 0, 0}, ["65"] = {1, 0, 1, 0},
    ["66"] = {0, 1, 1, 0}, ["67"] = {1, 1, 0, 0}, ["68"] = {0, 0, 1, 0}, ["69"] = {1, 1, 0, 0}, ["70"] = {1, 0, 1, 0},
    ["71"] = {0, 1, 0, 0}, ["72"] = {1, 1, 1, 0}, ["73"] = {1, 0, 0, 0}, ["74"] = {0, 1, 1, 0}, ["75"] = {1, 1, 0, 0},
    ["76"] = {1, 0, 1, 0}, ["77"] = {0, 1, 0, 0}, ["78"] = {1, 1, 1, 0}, ["79"] = {0, 0, 1, 0}, ["80"] = {1, 1, 0, 0},
    ["81"] = {1, 0, 1, 0}, ["82"] = {0, 1, 0, 0}, ["83"] = {1, 1, 1, 0}, ["84"] = {1, 1, 0, 0}, ["85"] = {0, 0, 1, 0},
    ["86"] = {1, 1, 0, 0}, ["87"] = {1, 0, 1, 0}, ["88"] = {0, 1, 0, 0}, ["89"] = {1, 1, 1, 0}, ["90"] = {1, 0, 1, 0},
    ["91"] = {0, 1, 0, 0}, ["92"] = {1, 0, 1, 0}, ["93"] = {0, 1, 0, 0}, ["94"] = {1, 1, 1, 0}, ["95"] = {1, 1, 0, 0},
    ["96"] = {0, 0, 1, 0}, ["97"] = {1, 1, 0, 0}, ["98"] = {1, 0, 1, 0}, ["99"] = {0, 1, 0, 0}
  }
}

PatchTask.BonusSlots = {
	--Sora Bonuses
	["2670201"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x01, 0x05, 0x34}}, --Ursula
	["2670211"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x03, 0x0A, 0x3D}}, --Hockomonkey 1
	["2670212"] = {type=self.BONUS.DECK, rewardTxt="Archipelago Item!", evtInfo={0x03, 0x0A, 0x3D}}, --Hockomonkey 2
	["2670298"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x03, 0x03, 0x3B}}, --Boss Gauntlet 1
	["2670299"] = {type=self.BONUS.DROP, rewardTxt="Archipelago Item!", evtInfo={0x03, 0x03, 0x3B}}, --Boss Gauntlet 2
	["2670216"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x08, 0x0A, 0x35}}, --Flower Battle
	["2670217"] = {type=self.BONUS.DECK, rewardTxt="Archipelago Item!", evtInfo={0x08, 0x13, 0x36}}, --Wargoyle
	["2670221"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x09, 0x0C, 0x34}}, --Rinzler 1
	["2670222"] = {type=self.BONUS.DROP, rewardTxt="Archipelago Item!", evtInfo={0x09, 0x0C, 0x34}}, --Rinzler 2
	["2670226"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x06, 0x01, 0x34}}, --Pinnochio Battle
	["2670233"] = {type=self.BONUS.DECK, rewardTxt="Archipelago Item!", evtInfo={0x06, 0x0D, 0x37}}, --Lobster
	["2670238"] = {type=self.BONUS.DECK, rewardTxt="Archipelago Item!", evtInfo={0x04, 0x03, 0x34}}, --Pete
	["2670242"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x05, 0x0B, 0x34}}, --Spellican 1
	["2670243"] = {type=self.BONUS.DROP, rewardTxt="Archipelago Item!", evtInfo={0x05, 0x0B, 0x34}}, --Spellican 2
	["2670245"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x0A, 0x0C, 0x34}}, --Xemnas
	--Sora Secret Portals
	["2680201"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x03, 0x0A, 0x3F}}, --Sora TT Secret Portal
	["2680203"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x08, 0x13, 0x37}}, --Sora LCDC Secret Portal
	["2680205"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x09, 0x0C, 0x35}}, --Sora TG Secret Portal
	["2680207"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x06, 0x05, 0x38}}, --Sora PP Secret Portal
	["2680209"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x04, 0x03, 0x39}}, --Sora COTM Secret Portal
	["2680211"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x05, 0x0B, 0x35}}, --Sora SOS Secret Portal
	--Riku Bonuses
	["2670254"] = {type=self.BONUS.DROP, rewardTxt="Archipelago Item!", evtInfo={0x03, 0x01, 0x43}}, --Save Shiki
	["2670255"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x03, 0x0B, 0x46}}, --Hockomonkey 1
	["2670256"] = {type=self.BONUS.DECK, rewardTxt="Archipelago Item!", evtInfo={0x03, 0x0B, 0x46}}, --Hockomonkey 2
	["2670288"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x03, 0x08, 0x45}}, --Cera Terror 1
	["2670289"] = {type=self.BONUS.DECK, rewardTxt="Archipelago Item!", evtInfo={0x03, 0x08, 0x45}}, --Cera Terror 2
	["2670260"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x08, 0x0E, 0x3B}}, --Wargoyle 1
	["2670261"] = {type=self.BONUS.DROP, rewardTxt="Archipelago Item!", evtInfo={0x08, 0x0E, 0x3B}}, --Wargoyle 2
	["2670264"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x09, 0x0B, 0x3A}}, --Light Cycle
	["2670266"] = {type=self.BONUS.DECK, rewardTxt="Archipelago Item!", evtInfo={0x09, 0x08, 0x38}}, --City Battle
	["2670268"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x09, 0x01, 0x37}}, --Commantis
	["2670271"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x06, 0x0A, 0x3B}}, --Char Clobster
	["2670275"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x04, 0x0C, 0x3B}}, --Holey Moley
	["2670280"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x05, 0x3E, 0x01}}, --Chernobog 1
	["2670281"] = {type=self.BONUS.DECK, rewardTxt="Archipelago Item!", evtInfo={0x05, 0x3E, 0x01}}, --Chernobog 2
	["2670283"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x0A, 0x0A, 0x39}}, --Ansem
	--Riku Secret Portals
	["2680202"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x03, 0x0B, 0x48}}, --Riku TT Secret Portal
	["2680204"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x08, 0x0E, 0x3C}}, --Riku LCDC Secret Portal
	["2680206"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x09, 0x01, 0x3D}}, --Riku TG Secret Portal
	["2680208"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x06, 0x12, 0x3C}}, --Riku PP Secret Portal
	["2680210"] = {type=self.BONUS.HP, rewardTxt="Archipelago Item!", evtInfo={0x04, 0x0C, 0x3C}}, --Riku COTM Secret Portal
	--TODO: Lord Kyroo has 2 Reward Bonuses (Max HP Increased & Drop Bonuses)
}
end

PatchTask.BONUS = {
	HP = 1,
	DECK = 2,
	DROP = 3
}



--Dive rewards might also be missions?
PatchTask.MissionDict = {
	["2670228"] = {0x10A2A4D6, 0x10A29D56}, --High Jump
	["2670285"] = {0x10A2A1FE, 0x10A29A7E}, --Sliding Sidewinder
	["2670237"] = {0x10A2A746, 0x10A29FC6}, --Slide Roll
	["2670276"] = {0x10A2ABDE, 0x10A2A45E}, --Shadow Slide
	["2670277"] = {0x10A2ABD6, 0x10A2A456}, --Shadow Strike
	["2670246"] = {0x10A2AC6E, 0x10A2A4EE}, --Recusant Sigil
	["2680212"] = {0x10A2AD9E, 0x10A2A61E}, --Unbound (Sora)
	["2680213"] = {0x10A2ADE6, 0x10A2A666} --Unbound (Riku)
}

function PatchTask:AssignBonusRewards(locId, itemName)
	self.BonusSlots[tostring(locId)].rewardTxt = string.sub(itemName, 1, 20)
end

function PatchTask:WriteBonusRewards()
	writeTxtToGame(ItemOverwrite.hpIncreasedTxt[gameVer], " ", 20)
	writeTxtToGame(ItemOverwrite.deckCapIncreasedTxt[gameVer], " ", 20)
	writeTxtToGame(ItemOverwrite.dropBonusTxt[gameVer], " ", 20)
	for key, value in pairs(self.BonusSlots) do
		if compareArrays(value.evtInfo, roomInfo) then
			if value.type == self.BONUS.HP then
				writeTxtToGame(ItemOverwrite.hpIncreasedTxt[gameVer], value.rewardTxt, 3)
			elseif value.type == self.BONUS.DECK then
				writeTxtToGame(ItemOverwrite.deckCapIncreasedTxt[gameVer], value.rewardTxt, 3)
			else
				writeTxtToGame(ItemOverwrite.dropBonusTxt[gameVer], value.rewardTxt, 3)
			end
		end
	end
end

function PatchTask:AssignLevelRewards(locId, itemId)
	local _isSora = locId < 2660100
	if _isSora then
		PatchTask.LevelOrders.Sora[tostring(locId-2660000)][4] = itemId
	else
		PatchTask.LevelOrders.Riku[tostring(locId-2660100)][4] = itemId
	end

	--Level table updated; update level reward text
  local _currLvl = ReadByte(levels.addr[gameVer])
  PatchTask:WriteLevelReward(_currLvl+1, getCharacter())
end

function PatchTask:WriteLevelReward(lvl, character)

	if lvl > 99 or lvl < 2 then --Invalid levels
		return
	end
	if Configs.VanillaLevels then
		writeTxtToGame(ItemOverwrite.strIncreasedTxt[gameVer], "Strength increased!", 0)
		writeTxtToGame(ItemOverwrite.magIncreasedTxt[gameVer], "Magic increased!", 0)
		writeTxtToGame(ItemOverwrite.defIncreasedTxt[gameVer], "Defense increased!", 0)
		return
	end

	local _useTbl = {}
	if character == 0 then
		_useTbl = self.LevelOrders.Sora
	else
		_useTbl = self.LevelOrders.Riku
	end

	local _strLen = 16 --Allowed characters in level up box
	local _useStr = "Archipelago Item"
	local _useLvl = string.sub(tostring(lvl), 1, _strLen)
	if _useTbl[_useLvl][4] > 0 then
		_useStr = getItemById(_useTbl[_useLvl][4]).Name
	end

	local _writeDest = 0x00
	writeTxtToGame(ItemOverwrite.strIncreasedTxt[gameVer], " ", 19)
	writeTxtToGame(ItemOverwrite.magIncreasedTxt[gameVer], " ", 16)
	writeTxtToGame(ItemOverwrite.defIncreasedTxt[gameVer], " ", 18)
	if _useTbl[_useLvl][1] == 1 then
		_writeDest = ItemOverwrite.strIncreasedTxt[gameVer]
	elseif _useTbl[_useLvl][2] == 1 then
		_writeDest = ItemOverwrite.magIncreasedTxt[gameVer]
	elseif _useTbl[_useLvl][3] == 1 then
		_writeDest = ItemOverwrite.defIncreasedTxt[gameVer]
	end

	if _writeDest == 0x00 then
		ConsolePrint("Something went wrong while writing level up txt")
		return
	end

	local _useLen = _strLen-#_useStr
	if _useLen < 0 then
		_useLen = 0
	end
	writeTxtToGame(_writeDest, _useStr, _useLen)
end

function PatchTask:AssignMissionRewards(locId, rewardBytes)
	local locStr = tostring(locId)

	if #rewardBytes == 1 then
		table.insert(rewardBytes, 0x00)
	end

	if locStr == "2680212" or locStr == "2680213" then --Assign all possible unbound locations
		for i=1, 6-(locId-2680212) do
			WriteArray(self.MissionDict[locStr][gameVer]+(0x90*(i-1)), rewardBytes)
		end
		return
	end
	if #rewardBytes == 1 then
		table.insert(rewardBytes, 0x00)
	end
	WriteArray(self.MissionDict[locStr][gameVer], rewardBytes)
	ConsolePrint("Mission Reward Set")
end

function PatchTask:SetRewardForLocation(locId, itemBytes)
	local _itemSet = false
	for i=1, #self.RewardSets do --Find location id in set table
		if _itemSet then --Break out of loop after finding location
			break
		end

		local _multiLocations = {2650652, 2680212, 2680213}

		for locs=1, #self.RewardSets[i].ids do --Iterate through location ids in each entry
			if self.RewardSets[i].ids[locs] == locId then --Record item info if location is found
				self.RewardSets[i].bytes[locs] = itemBytes
				self.RewardSets[i].locals[locs] = true
				if not hasValue(_multiLocations, locId) then --We need to continue the loop if trying to place rewards that appear multiple times
					_itemSet = true
				end
			end
		end
	end
end

function PatchTask:CheckForPatch()
	local _rewardOffset = self:ShouldReward()

	if _rewardOffset > -1 then
		local _currWorld = roomInfo[1]
		local _sep = 24
		local _flag = -1
		local _ind = 0

		for tblInd=#self.RewardSets, 1, -1 do --Iterate through reward sets
			local _tbl = self.RewardSets[tblInd]
			if _tbl.world == _currWorld and _tbl.character == getCharacter() then
				--Table entry matches character and current world; check story
				local _byte = ReadByte(_tbl.worldAddr+_tbl.ind)
				
				--Account for Lord Kyroo
				if _tbl.hasKyroo and _tbl.ids[1] ~= 2650652 then
					if _tbl.hasKyroo == self.RewardSets[tblInd].ind then
						--Remove kyroo progress from final check
						local _foughtLK = toBits(_byte)
						if _foughtLK[_tbl.kyrooBit] == 1 then --Kyroo was fought; remove progress
							local _bitTbl = {0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80}
							_byte = _byte - _bitTbl[_tbl.kyrooBit]
						end
					end
				end

				local _skipKyrooCheck = false --Do a check to skip over kyroo entry
				if _tbl.kyrooRoom then
					if roomInfo[2] ~= _tbl.kyrooRoom then
						_skipKyrooCheck = true
					end
				end

				--Compare the story
				if _byte > _tbl.story and _flag < 0 and not _skipKyrooCheck then --Story is good

					_flag = _byte --Prevents other rewards from being placed
					--Do some manual checks for LK in Sora's Prankster's...
					if _tbl.character == 0 and _currWorld == 6 and _tbl.ind == 4 then
						if roomInfo[2] ~= 0x04 then
							_flag = -1 --Prevents other rewards from being placed
						end
					end

					for locs=1, #_tbl.ids do
						--Local check
						if _flag >= 0 then --There is a local item here
							local _writeArr = _tbl.bytes[locs]
							if not _tbl.locals[locs] then
								_writeArr = {0x13, 0x08}
							end

							if #_writeArr == 1 then --Pad bytes to make valid item id
								table.insert(_writeArr, 0x00)
							end

							local _writeDest = _rewardAddr[gameVer]-((_rewardOffset+locs-1)*_sep)
							WriteArray(_writeDest, _writeArr)

						end
					end

				end

			end
		end
	end
end

--TODO: Add TT2 to inventory if TT1 is already obtained
function PatchTask:ChangeToCompatibleItem(newId, forChest, forReward)
	local _itemId = newId
	if _itemId > 2691000 and _itemId < 2691100 then --Change to itemized world item
		_itemId = _itemId + 100
	elseif _itemId > 2661000 and _itemId < 2661007 then --Itemize flowmotion
		_itemId = _itemId + 6
	elseif _itemId > 2631000 and _itemId < 2631100 then --Itemize stats
		if forChest or forReward then --Use condensed item info for chests/rewards
			_itemId = _itemId + 100
		end
	--elseif _itemId > 2671028 and _itemId < 2672000 then --Itemize stat ability
	--	if forChest then
	--		_itemId = 2672000
	--	end
	end
	return _itemId
end

function PatchTask:ShouldReward()
	local _rew = -1
	if ReadByte(MemoryAddresses.enablePause[gameVer]) > 0x00 then
		local _sep = 24
		for i=0, 3 do
			if ReadByte(_rewardAddr[gameVer]-(_sep*i)) == 0x01 then
				if ReadByte(_rewardAddr[gameVer]-(_sep*i)+1) == 0x08 then
					_rew = i
					break
				end
			end
		end
	end
	return _rew
end

function PatchTask:InRewardSet(id)
	for x=1, #self.RewardSets do
		for y=1, #self.RewardSets[x] do
			if self.RewardSets[x][y] == id then
				return x
			end
		end
	end
	return 0
end


function PatchTask:ResetRewards()
	if ReadByte(MemoryAddresses.enablePause[gameVer]) > 0x00 then
		local _sep = 24
		for i=0, 3 do
			WriteArray(_rewardAddr[gameVer]-(_sep*i), {0x00, 0x00})
		end
	end
end

return PatchTask