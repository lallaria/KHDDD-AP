local Spirits = {}

local RankMult = {-0.18, -0.12, -0.06, 0, 0.06, 0.12, 0.18}
local GrowthMult = {0, -0.01, 0.01}

MeowWowBoard = {
	{{-1}, {-1}, {20}, {7}, {8}, {9}, {10}},
	{{-1}, {0}, {1}, {2}, {3}, {4}, {5}, {6}},
	{{-1}, {-1}, {30}, {11}, {12}, {13}, {14}, {-1}},
	{{-1}, {-1}, {-1}, {-1}, {15}}
}

TamaSheepBoard = {
	{{-1}},
	{{0}, {1}, {2}, {20}, {6}, {7}, {10}},
	{{3}, {-1}, {-1}, {4}, {5}, {8}, {9}},
	{{-1}, {30}, {11}, {12}, {13}, {14}, {15}}
}

YoggyRamBoard = {
	{{-1}, {-1}, {1}, {2}},
	{{-1}, {-1}, {0}, {20}, {9}, {10}, {-1}, {11}},
	{{3}, {5}, {6}, {7}},
	{{4}, {30}, {8}},
	{{-1}, {12}},
	{{-1}, {13}},
	{{-1}, {14}},
	{{-1}, {15}},
}

KomoryBatBoard = {
	{{-1}, {-1}, {14}, {15}},
	{{-1}, {-1}, {20}, {12}, {13}},
	{{-1}, {0}, {1}, {30}, {8}, {9}, {10}, {11}},
	{{-1}, {-1}, {2}, {3}, {4}, {5}},
	{{-1}, {-1}, {6}, {7}}
}

PricklemaneBoard = {
	{{-1}, {-1}},
	{{-1}, {0}, {1}, {8}},
	{{3}, {2}, {7}, {6}},
	{{-1}, {4}, {20}, {5}},
	{{10}, {30}, {9}},
	{{12}, {11}, {13}},
	{{-1}, {14}},
	{{-1}, {15}}
}

HebbyReppBoard = { --Only 1 gate
	{{-1}, {0}, {1}, {2}},
	{{-1}, {-1}, {-1}, {3}},
	{{-1}, {7}, {20}, {4}, {5}, {6}},
	{{9}, {8}, {-1}, {14}},
	{{10}, {11}, {12}, {13}},
	{{-1}, {-1}, {-1}, {15}}
}

SirKyrooBoard = {
	{{-1}, {-1}, {-1}, {-1}, {8}},
	{{-1}, {0}, {1}, {2}, {20}, {9}, {10}},
	{{-1}, {5}, {-1}, {3}, {7}},
	{{-1}, {6}, {-1}, {4}},
	{{-1}, {30}},
	{{12}, {11}, {13}},
	{{-1}, {14}},
	{{-1}, {15}}
}

ToximanderBoard = { --Only 1 gate
	{{-1}, {-1}, {4}},
	{{-1}, {1}, {-1}, {7}, {8}, {9}, {10}},
	{{-1}, {0}, {3}, {20}},
	{{-1}, {2}, {5}, {11}, {12}, {13}, {14}, {15}},
	{{-1}, {-1}, {6}}
}

FinFataleBoard = {
	{{-1}},
	{{0}},
	{{1}, {2}, {20}, {8}},
	{{4}, {3}, {9}},
	{{5}, {30}, {10}},
	{{6}, {12}, {11}},
	{{7}, {13}},
	{{-1}, {14}, {15}}
}

TatsuSteedBoard = { --Only 1 gate
	{{-1}},
	{{0}, {1}, {2}},
	{{3}},
	{{4}, {5}, {6}},
	{{-1}, {7}, {20}, {10}},
	{{9}, {8}, {13}, {11}, {12}},
	{{-1}, {-1}, {14}},
	{{-1}, {-1}, {15}}
}

NechoCatBoard = { --Only 1 gate
	{{-1}, {15}, {14}},
	{{-1}, {-1}, {11}, {12}, {13}},
	{{-1}, {10}, {9}, {8}},
	{{7}, {6}, {5}, {20}},
	{{-1}, {2}, {3}, {4}},
	{{-1}, {1}, {0}},
	{{-1}, {-1}, {-1}}
}

ThunderaffeBoard = { --Only 1 gate
	{{-1}, {1}, {2}, {-1}, {15}, {13}, {14}},
	{{-1}, {0}, {5}, {20}, {8}, {9}, {10}},
	{{-1}, {3}, {6}, {7}, {11}, {12}},
	{{-1}, {4}}
}

KoomaPandaBoard = {
	{{-1}, {-1}},
	{{3}, {0}, {20}, {6}, {7}},
	{{4}, {1}, {-1}, {-1}, {8}},
	{{5}, {2}, {-1}, {-1}, {9}, {10}},
	{{11}, {30}},
	{{13}, {12}, {14}},
	{{-1}, {15}}
}

PegaslickBoard = {
	{{-1}, {-1}, {-1}, {11}, {12}},
	{{-1}, {-1}, {20}, {10}},
	{{-1}, {0}, {1}, {2}, {3}, {4}, {5}, {6}},
	{{-1}, {7}, {30}, {13}},
	{{-1}, {8}, {-1}, {14}, {15}},
	{{-1}, {9}}
}

IceguinAceBoard = { --Only 1 gate
	{{-1}, {0}, {1}, {2}, {3}},
	{{-1}, {8}, {7}, {20}, {4}, {5}, {6}},
	{{-1}, {-1}, {-1}, {9}, {10}},
	{{-1}, {-1}, {-1}, {11}, {12}},
	{{-1}, {-1}, {-1}, {13}, {14}, {15}}
}

PeepstaHooBoard = { --Only 1 gate
	{{-1}, {0}, {2}, {20}, {8}},
	{{-1}, {1}, {3}, {4}, {9}, {10}},
	{{-1}, {-1}, {-1}, {5}, {6}, {11}, {12}},
	{{-1}, {-1}, {-1}, {-1}, {7}, {13}},
	{{-1}, {-1}, {-1}, {-1}, {-1}, {14}, {15}}
}

EscarglowBoard = { --Only 1 gate
	{{-1}, {3}},
	{{-1}, {2}, {13}, {12}, {11}},
	{{-1}, {1}, {14}, {15}, {10}, {9}},
	{{-1}, {0}, {6}, {7}, {20}, {8}},
	{{-1}, {4}},
	{{-1}, {5}}
}

KOKabutoBoard = {
	{{-1}, {-1}, {-1}},
	{{5}, {20}, {0}},
	{{6}, {7}, {1}, {30}},
	{{9}, {8}, {2}, {12}, {13}},
	{{-1}, {10}, {3}, {14}},
	{{-1}, {-1}, {4}, {15}},
	{{-1}, {11}}
}

WheeflowerBoard = { --Only 1 gate
	{{-1}, {-1}, {-1}, {-1}},
	{{-1}, {-1}, {-1}, {0}},
	{{-1}, {3}, {2}, {1}},
	{{-1}, {-1}, {-1}, {4}, {5}, {6}, {7}},
	{{-1}, {9}, {8}, {20}},
	{{-1}, {-1}, {-1}, {10}, {11}, {12}},
	{{-1}, {-1}, {14}, {13}, {15}}
}

GhostabockyBoard = { --Effectively 1 gate
	{{-1}, {0}, {1}, {20}, {11}, {12}},
	{{-1}, {-1}, {2}, {14}, {10}, {13}},
	{{-1}, {-1}, {3}, {15}, {9}},
	{{-1}, {-1}, {4}, {30}, {8}},
	{{-1}, {-1}, {5}, {6}, {7}}
}

ZolephantBoard = { --Only 1 gate
	{{-1}, {3}, {-1}, {-1}, {10}},
	{{-1}, {2}, {-1}, {-1}, {9}},
	{{-1}, {1}, {-1}, {7}, {8}},
	{{-1}, {0}, {4}, {20}, {11}},
	{{-1}, {-1}, {5}, {13}, {14}},
	{{-1}, {-1}, {6}, {-1}, {15}}
}

JugglePupBoard = {
	{{-1}, {-1}, {2}},
	{{-1}, {1}, {-1}, {3}, {-1}},
	{{0}, {-1}, {4}, {-1}, {5}, {-1}, {6}},
	{{-1}, {7}, {20}, {12}, {30}, {13}},
	{{-1}, {-1}, {8}, {-1}, {15}, {-1}, {14}},
	{{-1}, {-1}, {-1}, {9}, {-1}, {10}},
	{{-1}, {-1}, {-1}, {11}}
}

HalbirdBoard = {
	{{-1}, {-1}, {-1}, {0}},
	{{11}, {10}, {1}, {-1}, {-1}, {-1}, {15}},
	{{-1}, {9}, {8}, {2}, {13}, {14}},
	{{-1}, {-1}, {20}, {3}, {12}},
	{{-1}, {-1}, {-1}, {4}, {30}},
	{{-1}, {-1}, {-1}, {5}, {6}},
	{{-1}, {-1}, {-1}, {-1}, {7}}
}

StaggercepsBoard = { --Only 1 gate
	{{-1}, {-1}, {4}, {3}},
	{{-1}, {0}, {1}, {2}},
	{{-1}, {5}, {7}, {20}, {9}, {10}},
	{{-1}, {6}, {-1}, {8}, {-1}},
	{{-1}, {-1}, {-1}, {13}, {11}, {12}},
	{{-1}, {-1}, {-1}, {14}, {-1}, {15}}
}

FishboneBoard = { --Only 1 gate
	{{0}, {1}, {2}, {3}, {4}},
	{{-1}, {6}, {5}, {7}},
	{{-1}, {8}, {20}},
	{{9}, {-1}, {10}},
	{{-1}, {12}, {11}, {14}},
	{{-1}, {13}, {-1}, {15}}
}

FlowbermeowBoard = { --Draft accidentally had an extra item node; replaced with empty
	{{-1}, {11}, {15}},
	{{9}, {10}, {14}, {13}},
	{{8}, {20}, {30}, {12}},
	{{-1}, {6}, {5}},
	{{-1}, {7}, {4}},
	{{-1}, {0}, {1}, {2}, {-1}, {3}}
}

CyberYogBoard = { --Only 1 gate
	{{-1}, {-1}, {-1}, {-1}, {7}, {12}},
	{{0}, {1}, {6}, {20}, {10}, {11}, {-1}, {15}},
	{{-1}, {2}, {5}, {8}, {-1}, {13}},
	{{-1}, {3}, {-1}, {9}, {-1}, {14}},
	{{4}}
}

ChefKyrooBoard = {
	{{-1}, {-1}, {-1}},
	{{-1}, {20}, {0}, {1}},
	{{7}, {6}, {-1}, {2}},
	{{8}, {9}, {-1}, {3}},
	{{-1}, {10}, {-1}, {4}, {5}},
	{{13}, {12}, {11}, {30}},
	{{-1}, {-1}, {14}},
	{{-1}, {-1}, {15}}
}

LordKyrooBoard = { --Draft accidentally had an extra item node; replaced with empty
	{{-1}, {-1}, {-1}, {4}},
	{{1}, {0}, {2}, {3}},
	{{-1}, {5}, {-1}, {6}},
	{{-1}, {20}, {9}, {30}, {13}, {14}, {15}},
	{{-1}, {7}, {-1}, {11}},
	{{-1}, {8}, {10}, {12}}
}

TatsuBlazeBoard = {
	{{-1}, {-1}, {-1}},
	{{-1}, {-1}, {0}, {20}, {8}, {9}, {10}},
	{{-1}, {-1}, {1}, {-1}, {-1}, {-1}, {11}},
	{{-1}, {3}, {2}, {4}},
	{{-1}, {6}, {5}, {30}},
	{{-1}, {-1}, {13}, {12}},
	{{-1}, {-1}, {14}, {15}}
}

ElectricornBoard = {
	{{-1}, {-1}, {-1}, {-1}, {-1}, {7}, {8}, {9}},
	{{-1}, {-1}, {-1}, {-1}, {20}, {6}, {-1}, {10}},
	{{-1}, {0}, {1}, {2}, {3}, {4}, {5}},
	{{-1}, {-1}, {-1}, {-1}, {30}, {11}, {-1}, {15}},
	{{-1}, {-1}, {-1}, {-1}, {-1}, {12}, {13}, {14}}
}

WoeflowerBoard = { --Only 1 gate
	{{-1}, {2}, {-1}, {3}},
	{{-1}, {1}, {-1}, {-1}, {8}, {9}, {10}},
	{{-1}, {0}, {20}, {6}, {7}, {11}, {12}},
	{{-1}, {4}, {-1}, {-1}, {13}, {14}, {15}},
	{{-1}, {5}}
}

JestabockyBoard = { --Draft had an extra node, placing empty
	{{-1}},
	{{0}, {20}, {9}, {10}, {-1}, {11}},
	{{1}, {2}, {3}},
	{{30}, {-1}, {4}},
	{{12}, {-1}, {5}, {8}},
	{{13}, {-1}, {6}, {7}},
	{{14}},
	{{15}}
}

EagliderBoard = { --Only 1 gate
	{{-1}, {2}, {3}, {4}, {5}, {6}},
	{{0}, {-1}, {7}, {20}, {8}, {9}, {10}},
	{{1}, {-1}, {-1}, {11}, {12}, {13}, {14}},
	{{-1}, {-1}, {-1}, {-1}, {-1}},
	{{-1}, {-1}, {-1}, {-1}, {15}}
}

MeMeBunnyBoard = {
	{{-1}, {0}, {1}, {2}, {3}},
	{{-1}, {4}, {20}, {7}},
	{{-1}, {5}, {6}, {8}},
	{{-1}, {11}, {30}, {9}, {10}},
	{{-1}, {12}, {13}},
	{{-1}, {-1}, {14}, {15}}
}

DrillSyeBoard = { --Only 1 gate
	{{-1}, {0}, {2}, {3}, {4}, {5}, {6}},
	{{-1}, {-1}, {9}, {8}, {20}, {7}},
	{{-1}, {1}, {10}, {11}, {12}, {13}},
	{{-1}, {-1}, {-1}, {-1}, {14}, {15}}
}

TyrantoRexBoard = {
	{{-1}, {0}, {2}, {3}, {4}, {5}},
	{{-1}, {1}, {-1}, {-1}, {-1}, {20}, {11}},
	{{-1}, {30}, {6}, {7}, {8}, {12}},
	{{-1}, {-1}, {-1}, {9}, {-1}, {13}, {14}},
	{{-1}, {-1}, {-1}, {10}, {-1}, {-1}, {15}}
}

MajikLapinBoard = {
	{{-1}, {-1}, {-1}},
	{{-1}, {-1}, {0}, {1}},
	{{4}, {3}, {2}},
	{{-1}, {20}, {5}, {6}, {7}},
	{{9}, {8}, {30}, {12}, {13}},
	{{11}, {10}, {-1}, {15}, {14}}
}

CeraTerrorBoard = {
	{{-1}, {-1}, {-1}},
	{{-1}, {-1}, {0}},
	{{-1}, {20}, {1}, {2}},
	{{7}, {6}, {3}, {30}, {11}, {12}},
	{{9}, {8}, {4}, {13}, {14}},
	{{10}, {-1}, {5}, {-1}, {15}}
}

SkelterwildBoard = {
	{{-1}, {-1}, {-1}},
	{{-1}, {-1}, {0}, {1}},
	{{-1}, {3}, {2}, {4}, {20}},
	{{-1}, {-1}, {5}, {-1}, {6}},
	{{13}, {30}, {-1}, {-1}, {7}},
	{{14}, {11}, {10}, {9}, {8}},
	{{15}, {12}}
}

DuckyGooseBoard = {
	{{-1}, {0}, {-1}, {1}, {-1}, {2}, {-1}, {3}},
	{{-1}, {-1}, {-1}, {-1}, {-1}, {-1}, {-1}, {-1}},
	{{-1}, {5}, {-1}, {-1}, {-1}, {-1}, {-1}, {4}},
	{{-1}, {-1}, {-1}, {-1}, {15}, {-1}, {-1}, {20}},
	{{-1}, {6}, {-1}, {-1}, {-1}, {14}, {-1}, {12}},
	{{-1}, {-1}, {-1}, {-1}, {11}, {-1}, {13}, {-1}},
	{{-1}, {7}, {-1}, {-1}, {-1}, {10}},
	{{-1}, {30}, {8}, {-1}, {9}, {-1}}
}

AuraLionBoard = { --Only had 15 items specified; added 1; also 1 gate
	{{-1}, {-1}, {-1}},
	{{-1}, {-1}, {0}},
	{{-1}, {2}, {1}, {4}},
	{{3}, {-1}, {20}, {5}},
	{{-1}, {7}, {6}, {11}, {12}, {13}},
	{{-1}, {8}, {9}, {10}, {14}},
	{{-1}, {-1}, {-1}, {-1}, {15}}
}

RyuDragonBoard = { --Only 1 gate
	{{3}, {2}, {-1}, {0}, {1}},
	{{4}, {5}, {20}},
	{{-1}, {7}, {6}, {10}, {11}},
	{{-1}, {-1}, {-1}, {9}, {12}, {-1}, {15}},
	{{8}, {-1}, {-1}, {14}, {13}}
}

DrakQuackBoard = {
	{{-1}, {-1}, {0}, {-1}, {1}, {-1}, {2}, {20}},
	{{-1}, {-1}, {-1}, {-1}, {-1}, {-1}, {-1}, {11}},
	{{3}, {-1}, {-1}, {-1}, {-1}, {-1}, {-1}, {-1}},
	{{-1}, {-1}, {-1}, {-1}, {-1}, {15}, {-1}, {12}},
	{{4}, {-1}, {-1}, {-1}, {-1}, {-1}, {14}, {-1}},
	{{-1}, {-1}, {-1}, {10}, {-1}, {-1}, {-1}, {13}},
	{{5}, {-1}, {-1}, {-1}, {9}, {-1}},
	{{30}, {6}, {-1}, {7}, {-1}, {8}}
}

KeebaTigerBoard = { --Only 1 gate
	{{-1}, {20}, {6}, {7}, {-1}, {-1}, {15}},
	{{-1}, {1}, {3}, {8}, {11}, {12}},
	{{-1}, {2}, {4}, {-1}, {9}, {13}, {14}},
	{{0}, {-1}, {5}, {-1}, {10}}
}

MeowjestyBoard = {
	{{8}, {7}, {6}, {9}, {10}},
	{{-1}, {-1}, {20}},
	{{-1}, {-1}, {0}, {1}, {2}, {3}, {4}, {5}},
	{{-1}, {-1}, {30}},
	{{13}, {12}, {11}, {14}, {15}}
}

SudoNekuBoard = { --Only 1 gate
	{{-1}, {1}, {2}, {6}, {7}, {12}, {13}},
	{{-1}, {0}, {5}, {20}, {8}, {11}, {14}},
	{{-1}, {3}, {4}, {-1}, {9}, {10}, {15}}
}

FrootzCatBoard = {
	{{-1}, {-1}, {11}},
	{{10}, {9}, {20}, {12}, {13}, {14}, {15}},
	{{-1}, {8}, {-1}, {5}},
	{{6}, {7}, {2}, {3}, {4}},
	{{30}, {1}, {0}},
	{{-1}, {-1}, {-1}}
}

UrsaCircusBoard = {
	{{1}, {0}, {-1}},
	{{-1}, {-1}, {2}, {3}},
	{{-1}, {20}, {4}, {30}, {12}},
	{{-1}, {6}, {5}, {11}, {13}, {14}},
	{{-1}, {7}, {8}, {9}, {10}, {15}}
}

KabKannonBoard = {
	{{14}, {15}, {7}, {6}, {20}},
	{{13}, {-1}, {8}, {9}, {5}},
	{{11}, {12}, {-1}, {10}, {4}},
	{{30}, {-1}, {-1}, {-1}, {3}},
	{{-1}, {2}, {1}, {0}, {-1}}
}

RRSealBoard = {
	{{-1}, {-1}, {2}, {-1}},
	{{-1}, {0}, {-2}, {3}, {20}, {-1}, {6}},
	{{1}, {-1}, {4}, {-1}, {8}, {7}},
	{{-1}, {-1}, {-1}, {5}, {-1}, {9}},
	{{-1}, {-1}, {11}, {30}, {12}, {10}},
	{{-1}, {-1}, {-1}, {13}, {-1}, {15}},
	{{-1}, {-1}, {-1}, {14}}
}

CatanukiBoard = {
	{{13}, {12}, {11}, {14}, {15}},
	{{-1}, {-1}, {20}},
	{{-1}, {-1}, {5}},
	{{9}, {10}, {-1}},
	{{8}, {-1}, {0}},
	{{7}, {-1}, {1}},
	{{6}, {30}, {2}, {3}, {4}}
}

BeatalikeBoard = { --Only 1 gate
	{{-1}, {11}, {10}, {-1}, {12}, {13}, {14}},
	{{5}, {-1}, {-1}, {9}, {-1}, {-1}, {-1}},
	{{4}, {-1}, {-1}, {8}, {-1}, {-1}, {15}},
	{{-1}, {3}, {2}, {7}, {20}},
	{{-1}, {-1}, {-1}, {-1}, {-1}},
	{{-1}, {-1}, {1}, {0}, {6}}
}

TubguinAceBoard = {
	{{-1}, {13}, {14}, {15}, {11}, {10}},
	{{20}, {12}, {-1}, {-1}, {-1}, {9}, {8}},
	{{-1}, {-1}, {-1}, {-1}, {-1}, {-1}, {30}},
	{{7}, {6}, {-1}, {-1}, {-1}, {2}, {3}},
	{{-1}, {5}, {4}, {-1}, {0}, {1}}
}

--20 and 30 represent the 2 item gates
Boards = {MeowWowBoard, TamaSheepBoard, YoggyRamBoard, KomoryBatBoard,
			PricklemaneBoard, HebbyReppBoard, SirKyrooBoard, ToximanderBoard,
			FinFataleBoard, TatsuSteedBoard, NechoCatBoard, ThunderaffeBoard,
			KoomaPandaBoard, PegaslickBoard, IceguinAceBoard, PeepstaHooBoard,
			EscarglowBoard, KOKabutoBoard, WheeflowerBoard, GhostabockyBoard,
			ZolephantBoard, JugglePupBoard, HalbirdBoard, StaggercepsBoard,
			FishboneBoard, FlowbermeowBoard, CyberYogBoard, ChefKyrooBoard,
			LordKyrooBoard, TatsuBlazeBoard, ElectricornBoard, WoeflowerBoard,
			JestabockyBoard, EagliderBoard, MeMeBunnyBoard, DrillSyeBoard,
			TyrantoRexBoard, MajikLapinBoard, CeraTerrorBoard, SkelterwildBoard,
			DuckyGooseBoard, AuraLionBoard, RyuDragonBoard, DrakQuackBoard,
			KeebaTigerBoard, MeowjestyBoard, SudoNekuBoard, FrootzCatBoard,
			UrsaCircusBoard, KabKannonBoard, RRSealBoard, CatanukiBoard,
			BeatalikeBoard, TubguinAceBoard}

--m_deXX0 records from btlparam.bin; hp/str/mag/def are x10, exp is a percent of the game's exp table
function Spirits:DefineSpiritStats()
SpiritStats = { --Base stats for Dream Eaters
	{hp=360, str=84, mag=111, def=66, exp=90,
		fireRes=105, iceRes=105, elecRes=105, waterRes=105, darkRes=105, lightRes=105}, --Meow Wow
	{hp=381, str=87, mag=106, def=75, exp=93,
		fireRes=120, iceRes=120, elecRes=120, waterRes=120, darkRes=120, lightRes=120}, --Tama Sheep
	{hp=413, str=95, mag=103, def=73, exp=101,
		fireRes=55, iceRes=135, elecRes=115, waterRes=165, darkRes=115, lightRes=115}, --Yoggy Ram
	{hp=327, str=82, mag=108, def=59, exp=90,
		fireRes=90, iceRes=90, elecRes=90, waterRes=90, darkRes=45, lightRes=140}, --Komory Bat
	{hp=370, str=97, mag=81, def=76, exp=99,
		fireRes=100, iceRes=100, elecRes=100, waterRes=100, darkRes=100, lightRes=100}, --Pricklemane
	{hp=349, str=95, mag=84, def=62, exp=86,
		fireRes=45, iceRes=110, elecRes=90, waterRes=140, darkRes=90, lightRes=90}, --Hebby Repp
	{hp=316, str=82, mag=103, def=69, exp=91,
		fireRes=95, iceRes=95, elecRes=145, waterRes=45, darkRes=95, lightRes=95}, --Sir Kyroo
	{hp=349, str=97, mag=81, def=66, exp=91,
		fireRes=90, iceRes=90, elecRes=90, waterRes=90, darkRes=45, lightRes=140}, --Toximander
	{hp=360, str=84, mag=84, def=71, exp=87,
		fireRes=100, iceRes=100, elecRes=150, waterRes=50, darkRes=100, lightRes=100}, --Fin Fatale
	{hp=338, str=87, mag=100, def=73, exp=104,
		fireRes=90, iceRes=90, elecRes=140, waterRes=45, darkRes=90, lightRes=90}, --Tatsu Steed
	{hp=381, str=92, mag=98, def=67, exp=109,
		fireRes=85, iceRes=85, elecRes=85, waterRes=85, darkRes=40, lightRes=135}, --Necho Cat
	{hp=457, str=102, mag=114, def=71, exp=118,
		fireRes=115, iceRes=165, elecRes=55, waterRes=115, darkRes=115, lightRes=115}, --Thunderaffe
	{hp=468, str=102, mag=79, def=69, exp=103,
		fireRes=105, iceRes=105, elecRes=105, waterRes=105, darkRes=105, lightRes=105}, --Kooma Panda
	{hp=457, str=105, mag=100, def=71, exp=114,
		fireRes=110, iceRes=110, elecRes=110, waterRes=110, darkRes=160, lightRes=55}, --Pegaslick
	{hp=381, str=92, mag=111, def=68, exp=106,
		fireRes=160, iceRes=55, elecRes=110, waterRes=100, darkRes=110, lightRes=110}, --Iceguin Ace
	{hp=316, str=79, mag=127, def=62, exp=93,
		fireRes=95, iceRes=95, elecRes=95, waterRes=95, darkRes=45, lightRes=145}, --Peepsta Hoo
	{hp=349, str=77, mag=111, def=79, exp=97,
		fireRes=110, iceRes=110, elecRes=110, waterRes=110, darkRes=110, lightRes=110}, --Escarglow
	{hp=370, str=97, mag=98, def=81, exp=107,
		fireRes=110, iceRes=110, elecRes=110, waterRes=110, darkRes=110, lightRes=110}, --KO Kabuto
	{hp=306, str=77, mag=108, def=59, exp=87,
		fireRes=130, iceRes=80, elecRes=80, waterRes=40, darkRes=80, lightRes=80}, --Wheeflower
	{hp=370, str=100, mag=95, def=62, exp=101,
		fireRes=90, iceRes=90, elecRes=90, waterRes=90, darkRes=45, lightRes=140}, --Ghostabocky
	{hp=478, str=105, mag=81, def=68, exp=105,
		fireRes=110, iceRes=110, elecRes=160, waterRes=55, darkRes=110, lightRes=110}, --Zolephant
	{hp=392, str=95, mag=95, def=69, exp=96,
		fireRes=160, iceRes=55, elecRes=110, waterRes=100, darkRes=110, lightRes=110}, --Juggle Pup
	{hp=435, str=107, mag=81, def=66, exp=111,
		fireRes=100, iceRes=100, elecRes=100, waterRes=100, darkRes=150, lightRes=50}, --Halbird
	{hp=381, str=95, mag=100, def=80, exp=110,
		fireRes=110, iceRes=110, elecRes=110, waterRes=110, darkRes=110, lightRes=110}, --Staggerceps
	{hp=327, str=87, mag=84, def=75, exp=88,
		fireRes=100, iceRes=100, elecRes=100, waterRes=100, darkRes=50, lightRes=150}, --Fishbone
	{hp=392, str=97, mag=117, def=72, exp=116,
		fireRes=100, iceRes=100, elecRes=100, waterRes=100, darkRes=150, lightRes=50}, --Flowbermeow
	{hp=424, str=100, mag=108, def=75, exp=111,
		fireRes=120, iceRes=170, elecRes=60, waterRes=120, darkRes=120, lightRes=120}, --Cyber Yog
	{hp=381, str=84, mag=108, def=69, exp=94,
		fireRes=55, iceRes=130, elecRes=110, waterRes=160, darkRes=110, lightRes=110}, --Chef Kyroo
	{hp=360, str=97, mag=106, def=73, exp=113,
		fireRes=100, iceRes=150, elecRes=50, waterRes=100, darkRes=100, lightRes=100}, --Lord Kyroo
	{hp=338, str=90, mag=103, def=64, exp=94,
		fireRes=45, iceRes=115, elecRes=95, waterRes=145, darkRes=95, lightRes=95}, --Tatsu Blaze
	{hp=468, str=102, mag=103, def=72, exp=118,
		fireRes=110, iceRes=160, elecRes=55, waterRes=110, darkRes=110, lightRes=110}, --Electricorn
	{hp=327, str=84, mag=114, def=62, exp=104,
		fireRes=130, iceRes=80, elecRes=30, waterRes=80, darkRes=40, lightRes=130}, --Woeflower
	{hp=370, str=100, mag=92, def=62, exp=99,
		fireRes=90, iceRes=140, elecRes=45, waterRes=90, darkRes=90, lightRes=90}, --Jestabocky
	{hp=435, str=105, mag=81, def=64, exp=107,
		fireRes=50, iceRes=120, elecRes=100, waterRes=150, darkRes=100, lightRes=100}, --Eaglider
	{hp=360, str=105, mag=84, def=67, exp=95,
		fireRes=90, iceRes=90, elecRes=90, waterRes=90, darkRes=90, lightRes=90}, --Me Me Bunny
	{hp=489, str=107, mag=76, def=71, exp=109,
		fireRes=110, iceRes=110, elecRes=110, waterRes=110, darkRes=110, lightRes=110}, --Drill Sye
	{hp=511, str=117, mag=90, def=72, exp=120,
		fireRes=55, iceRes=130, elecRes=110, waterRes=160, darkRes=110, lightRes=110}, --Tyranto Rex
	{hp=370, str=84, mag=111, def=68, exp=102,
		fireRes=90, iceRes=90, elecRes=90, waterRes=90, darkRes=45, lightRes=140}, --Majik Lapin
	{hp=500, str=112, mag=76, def=72, exp=115,
		fireRes=105, iceRes=105, elecRes=105, waterRes=105, darkRes=105, lightRes=105}, --Cera Terror
	{hp=500, str=120, mag=90, def=83, exp=125,
		fireRes=150, iceRes=50, elecRes=100, waterRes=90, darkRes=100, lightRes=100}, --Skelterwild
	{hp=349, str=79, mag=98, def=66, exp=92,
		fireRes=145, iceRes=45, elecRes=95, waterRes=85, darkRes=95, lightRes=95}, --Ducky Goose
	{hp=478, str=110, mag=108, def=76, exp=121,
		fireRes=115, iceRes=115, elecRes=115, waterRes=115, darkRes=165, lightRes=55}, --Aura Lion
	{hp=500, str=115, mag=92, def=77, exp=123,
		fireRes=55, iceRes=130, elecRes=110, waterRes=160, darkRes=110, lightRes=110}, --Ryu Dragon
	{hp=360, str=82, mag=100, def=67, exp=100,
		fireRes=45, iceRes=110, elecRes=90, waterRes=140, darkRes=90, lightRes=90}, --Drak Quack
	{hp=489, str=112, mag=103, def=77, exp=122,
		fireRes=115, iceRes=115, elecRes=115, waterRes=115, darkRes=55, lightRes=165}, --Keeba Tiger

	--Rare Spirits
	{hp=396, str=89, mag=117, def=66, exp=108,
		fireRes=105, iceRes=105, elecRes=105, waterRes=105, darkRes=105, lightRes=105}, --Meowjesty
	{hp=384, str=100, mag=89, def=62, exp=103,
		fireRes=45, iceRes=110, elecRes=90, waterRes=140, darkRes=90, lightRes=90}, --Sudo Neku
	{hp=419, str=97, mag=103, def=67, exp=130,
		fireRes=85, iceRes=85, elecRes=85, waterRes=85, darkRes=40, lightRes=135}, --Frootz Cat
	{hp=514, str=108, mag=83, def=69, exp=123,
		fireRes=105, iceRes=105, elecRes=105, waterRes=105, darkRes=105, lightRes=105}, --Ursa Circus
	{hp=407, str=102, mag=103, def=81, exp=128,
		fireRes=110, iceRes=110, elecRes=110, waterRes=110, darkRes=110, lightRes=110}, --Kab Kannon
	{hp=431, str=100, mag=100, def=69, exp=115,
		fireRes=160, iceRes=55, elecRes=110, waterRes=100, darkRes=110, lightRes=110}, --R & R Seal
	{hp=455, str=110, mag=109, def=71, exp=117,
		fireRes=100, iceRes=100, elecRes=60, waterRes=100, darkRes=115, lightRes=115}, --Catanuki
	{hp=538, str=118, mag=92, def=77, exp=121,
		fireRes=110, iceRes=110, elecRes=110, waterRes=50, darkRes=110, lightRes=110}, --Beatalike
	{hp=419, str=100, mag=117, def=66, exp=98,
		fireRes=70, iceRes=130, elecRes=150, waterRes=70, darkRes=100, lightRes=100}, --Tubguin Ace

}
end

local function f32(x)
	return (string.unpack("f", string.pack("f", x)))
end

--Matches the game's level-up recalculation, including its float32 rounding.
--rank is 0-6; growth packs 2-bit str, mag, def, hp modifiers from the low bits up.
function Spirits:GetStats(id, level, rank, growth)
	local _base = SpiritStats[id]
	local _level = level <= 50 and level+10 or (level-50)*0.5+60
	local _rank = f32(RankMult[rank+1])
	local _rankTenth = f32(_rank*f32(0.1))
	local _rankOne = f32(_rank+1)
	local function stat(base, shift)
		local _mult = f32(f32(_rankTenth+f32(GrowthMult[(growth >> shift & 3)+1]))+_rankOne)
		return math.floor(f32(f32(f32(_mult*base)*_level)/100))
	end
	return {hp=stat(_base.hp, 6), str=stat(_base.str, 0), mag=stat(_base.mag, 2), def=stat(_base.def, 4)}
end

return Spirits