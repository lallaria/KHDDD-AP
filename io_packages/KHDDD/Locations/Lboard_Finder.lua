LBoardFinder = {}

--LBoard Finder Mod

--No static pointer, so we need some helper functions to locate the memory address for lboard contents

--It is loaded once the link board is opened once

local _fileGroups = {0x14C89890} -- ([0x14C89890 + group*8])
local _offsetAddr = {0x9DF2EE}

local _scanLimit = 2000
local _lboardFile = "game/de/bin/lboard.bin"

NT = {
	N = 0x00,			--None
	E = 0x01,			--Empty
	ST = 0x02,		--Start
	STAT = 0x03,	--Stat
	I = 0x04,			--Item
	LEG = 0x06,		--Level Gate
	SECG = 0x07,	--Green Secret
	EOF = 0x08,		--End of File
	LIG = 0x16,		--Link Gate
	SECR = 0x17,	--Red Secret
	ITG = 0x26		--Item Gate
}

CN = {
	N = 0x00, 		--None
	R = 0x01, 		--Right
	D = 0x04, 		--Down
	DR = 0x05 		--Down-Right
}


MeowWowBoard = {
	{{NT.N}, {NT.N}, {NT.ITG, CN.DR}, {NT.I, CN.R, 7}, {NT.I, CN.R, 8}, {NT.I, CN.R, 9}, {NT.I, CN.N, 10}},
	{{NT.ST, CN.R}, {NT.I, CN.R, 0}, {NT.I, CN.DR, 1}, {NT.I, CN.R, 2}, {NT.I, CN.R, 3}, {NT.I, CN.R, 4}, {NT.I, CN.R, 5}, {NT.I, CN.N, 6}},
	{{NT.N}, {NT.N}, {NT.ITG, CN.R}, {NT.I, CN.R, 11}, {NT.I, CN.DR, 12}, {NT.I, CN.R, 13}, {NT.I, CN.N, 14}, {NT.N}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.I, CN.N, 15}}
}

TamaSheepBoard = {
	{{NT.ST, CN.D}},
	{{NT.I, CN.DR, 0}, {NT.I, CN.R, 1}, {NT.I, CN.R, 2}, {NT.ITG, CN.D}, {NT.I, CN.DR, 6}, {NT.I, CN.DR, 7}, {NT.I, CN.N, 10}},
	{{NT.I, CN.D, 3}, {NT.N}, {NT.N}, {NT.I, CN.R, 4}, {NT.I, CN.N, 5}, {NT.I, CN.R, 8}, {NT.I, CN.N, 9}},
	{{NT.E, CN.R}, {NT.ITG, CN.R}, {NT.I, CN.R, 11}, {NT.I, CN.R, 12}, {NT.I, CN.R, 13}, {NT.I, CN.R, 14}, {NT.I, CN.N, 15}}
}

YoggyRamBoard = {
	{{NT.N}, {NT.N}, {NT.I, CN.DR, 1}, {NT.I, CN.N, 2}},
	{{NT.N}, {NT.ST, CN.DR}, {NT.I, CN.DR, 0}, {NT.ITG, CN.R}, {NT.I, CN.R, 9}, {NT.I, CN.R, 10}, {NT.E, CN.R}, {NT.I, CN.N, 11}},
	{{NT.I, CN.DR, 3}, {NT.I, CN.DR, 5}, {NT.I, CN.DR, 6}, {NT.I, CN.N, 7}},
	{{NT.I, CN.N, 4}, {NT.ITG, CN.D}, {NT.I, CN.N, 8}},
	{{NT.N}, {NT.I, CN.D, 12}},
	{{NT.N}, {NT.I, CN.D, 13}},
	{{NT.N}, {NT.I, CN.D, 14}},
	{{NT.N}, {NT.I, CN.D, 15}},
}

KomoryBatBoard = {
	{{NT.N}, {NT.N}, {NT.I, CN.DR, 14}, {NT.I, CN.N, 15}},
	{{NT.N}, {NT.N}, {NT.ITG, CN.DR}, {NT.I, CN.R, 12}, {NT.I, CN.N, 13}},
	{{NT.ST, CN.R}, {NT.I, CN.R, 0}, {NT.I, CN.DR, 1}, {NT.ITG, CN.R}, {NT.I, CN.R, 8}, {NT.I, CN.R, 9}, {NT.I, CN.R, 10}, {NT.I, CN.N, 11}},
	{{NT.N}, {NT.N}, {NT.I, CN.DR, 2}, {NT.I, CN.R, 3}, {NT.I, CN.R, 4}, {NT.I, CN.N, 5}},
	{{NT.N}, {NT.N}, {NT.I, CN.R, 6}, {NT.I, CN.N, 7}}
}

PricklemaneBoard = {
	{{NT.N}, {NT.ST, CN.D}},
	{{NT.N}, {NT.I, CN.DR, 0}, {NT.I, CN.N, 1}, {NT.I, CN.D, 8}},
	{{NT.I, CN.R, 3}, {NT.I, CN.D, 2}, {NT.I, CN.R, 7}, {NT.I, CN.D, 6}},
	{{NT.N}, {NT.I, CN.DR, 4}, {NT.ITG, CN.DR}, {NT.I, CN.N, 5}},
	{{NT.I, CN.R, 10}, {NT.ITG, CN.D}, {NT.I, CN.N, 9}},
	{{NT.I, CN.R, 12}, {NT.I, CN.DR, 11}, {NT.I, CN.N, 13}},
	{{NT.N}, {NT.I, CN.D, 14}},
	{{NT.N}, {NT.I, CN.N, 15}}
}

HebbyReppBoard = { --Only 1 gate
	{{NT.ST, CN.R}, {NT.I, CN.R, 0}, {NT.I, CN.R, 1}, {NT.I, CN.D, 2}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.I, CN.D, 3}},
	{{NT.N}, {NT.I, CN.DR, 7}, {NT.ITG, CN.R}, {NT.I, CN.R, 4}, {NT.I, CN.R, 5}, {NT.I, CN.N, 6}},
	{{NT.I, CN.DR, 9}, {NT.I, CN.D, 8}, {NT.N}, {NT.I, CN.D, 14}},
	{{NT.I, CN.N, 10}, {NT.I, CN.R, 11}, {NT.I, CN.R, 12}, {NT.I, CN.D, 13}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.I, CN.N, 15}}
}

SirKyrooBoard = {
	{{NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.I, CN.D, 8}},
	{{NT.ST, CN.R}, {NT.I, CN.DR, 0}, {NT.I, CN.R, 1}, {NT.I, CN.DR, 2}, {NT.ITG, CN.DR}, {NT.I, CN.R, 9}, {NT.I, CN.N, 10}},
	{{NT.N}, {NT.I, CN.D, 5}, {NT.N}, {NT.I, CN.D, 3}, {NT.I, CN.N, 7}},
	{{NT.N}, {NT.I, CN.D, 6}, {NT.N}, {NT.I, CN.N, 4}},
	{{NT.N}, {NT.ITG, CN.D}},
	{{NT.I, CN.R, 12}, {NT.I, CN.DR, 11}, {NT.I, CN.N, 13}},
	{{NT.N}, {NT.I, CN.D, 14}},
	{{NT.N}, {NT.I, CN.N, 15}}
}

ToximanderBoard = { --Only 1 gate
	{{NT.N}, {NT.N}, {NT.I, CN.D, 4}},
	{{NT.N}, {NT.I, CN.D, 1}, {NT.E, CN.D}, {NT.I, CN.DR, 7}, {NT.I, CN.R, 8}, {NT.I, CN.R, 9}, {NT.I, CN.N, 10}},
	{{NT.ST, CN.R}, {NT.I, CN.DR, 0}, {NT.I, CN.DR, 3}, {NT.ITG, CN.D}},
	{{NT.N}, {NT.I, CN.N, 2}, {NT.I, CN.D, 5}, {NT.I, CN.R, 11}, {NT.I, CN.R, 12}, {NT.I, CN.R, 13}, {NT.I, CN.R, 14}, {NT.I, CN.N, 15}},
	{{NT.N}, {NT.N}, {NT.I, CN.N, 6}}
}

FinFataleBoard = {
	{{NT.ST, CN.D}},
	{{NT.I, CN.D, 0}},
	{{NT.I, CN.DR, 1}, {NT.I, CN.DR, 2}, {NT.ITG, CN.DR}, {NT.I, CN.N, 8}},
	{{NT.I, CN.D, 4}, {NT.I, CN.D, 3}, {NT.I, CN.D, 9}},
	{{NT.I, CN.D, 5}, {NT.ITG, CN.D}, {NT.I, CN.D, 10}},
	{{NT.I, CN.D, 6}, {NT.I, CN.D, 12}, {NT.I, CN.N, 11}},
	{{NT.I, CN.N, 7}, {NT.I, CN.D, 13}},
	{{NT.N}, {NT.I, CN.R, 14}, {NT.I, CN.N, 15}}
}

TatsuSteedBoard = { --Only 1 gate
	{{NT.ST, CN.D}},
	{{NT.I, CN.DR, 0}, {NT.I, CN.R, 1}, {NT.I, CN.N, 2}},
	{{NT.I, CN.D, 3}},
	{{NT.I, CN.R, 4}, {NT.I, CN.R, 5}, {NT.I, CN.D, 6}},
	{{NT.N}, {NT.I, CN.DR, 7}, {NT.ITG, CN.DR}, {NT.I, CN.D, 10}},
	{{NT.I, CN.R, 9}, {NT.I, CN.N, 8}, {NT.I, CN.D, 13}, {NT.I, CN.R, 11}, {NT.I, CN.N, 12}},
	{{NT.N}, {NT.N}, {NT.I, CN.D, 14}},
	{{NT.N}, {NT.N}, {NT.I, CN.N, 15}}
}

NechoCatBoard = { --Only 1 gate
	{{NT.N}, {NT.I, CN.R, 15}, {NT.I, CN.D, 14}},
	{{NT.N}, {NT.N}, {NT.I, CN.DR, 11}, {NT.I, CN.R, 12}, {NT.I, CN.N, 13}},
	{{NT.N}, {NT.I, CN.R, 10}, {NT.I, CN.R, 9}, {NT.I, CN.D, 8}},
	{{NT.I, CN.R, 7}, {NT.I, CN.R, 6}, {NT.I, CN.DR, 5}, {NT.ITG, CN.N}},
	{{NT.N}, {NT.I, CN.DR, 2}, {NT.I, CN.DR, 3}, {NT.I, CN.N, 4}},
	{{NT.N}, {NT.I, CN.R, 1}, {NT.I, CN.D, 0}},
	{{NT.N}, {NT.N}, {NT.ST, CN.N}}
}

ThunderaffeBoard = { --Only 1 gate
	{{NT.N}, {NT.I, CN.DR, 1}, {NT.I, CN.N, 2}, {NT.N}, {NT.I, CN.R, 15}, {NT.I, CN.DR, 13}, {NT.I, CN.N, 14}},
	{{NT.ST, CN.R}, {NT.I, CN.DR, 0}, {NT.I, CN.DR, 5}, {NT.ITG, CN.R}, {NT.I, CN.DR, 8}, {NT.I, CN.R, 9}, {NT.I, CN.N, 10}},
	{{NT.N}, {NT.I, CN.D, 3}, {NT.I, CN.R, 6}, {NT.I, CN.N, 7}, {NT.I, CN.R, 11}, {NT.I, CN.N, 12}},
	{{NT.N}, {NT.I, CN.N, 4}}
}

KoomaPandaBoard = {
	{{NT.N}, {NT.ST, CN.D}},
	{{NT.I, CN.DR, 3}, {NT.I, CN.DR, 0}, {NT.ITG, CN.R}, {NT.I, CN.R, 6}, {NT.I, CN.D, 7}},
	{{NT.I, CN.D, 4}, {NT.I, CN.D, 1}, {NT.N}, {NT.N}, {NT.I, CN.D, 8}},
	{{NT.I, CN.N, 5}, {NT.I, CN.D, 2}, {NT.N}, {NT.N}, {NT.I, CN.R, 9}, {NT.I, CN.N, 10}},
	{{NT.I, CN.R, 11}, {NT.ITG, CN.D}},
	{{NT.I, CN.R, 13}, {NT.I, CN.DR, 12}, {NT.I, CN.N, 14}},
	{{NT.N}, {NT.I, CN.N, 15}}
}

PegaslickBoard = {
	{{NT.N}, {NT.N}, {NT.N}, {NT.I, CN.DR, 11}, {NT.I, CN.N, 12}},
	{{NT.N}, {NT.N}, {NT.ITG, CN.DR}, {NT.I, CN.N, 10}},
	{{NT.ST, CN.R}, {NT.I, CN.DR, 0}, {NT.I, CN.DR, 1}, {NT.I, CN.R, 2}, {NT.I, CN.R, 3}, {NT.I, CN.R, 4}, {NT.I, CN.R, 5}, {NT.I, CN.N, 6}},
	{{NT.N}, {NT.I, CN.D, 7}, {NT.ITG, CN.R}, {NT.I, CN.D, 13}},
	{{NT.N}, {NT.I, CN.D, 8}, {NT.N}, {NT.I, CN.R, 14}, {NT.I, CN.N, 15}},
	{{NT.N}, {NT.I, CN.N, 9}}
}

IceguinAceBoard = { --Only 1 gate
	{{NT.ST, CN.R}, {NT.I, CN.R, 0}, {NT.I, CN.R, 1}, {NT.I, CN.DR, 2}, {NT.I, CN.D, 3}},
	{{NT.N}, {NT.I, CN.R, 8}, {NT.I, CN.R, 7}, {NT.ITG, CN.D}, {NT.I, CN.R, 4}, {NT.I, CN.R, 5}, {NT.I, CN.N, 6}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.I, CN.DR, 9}, {NT.I, CN.D, 10}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.I, CN.D, 11}, {NT.I, CN.D, 12}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.I, CN.R, 13}, {NT.I, CN.R, 14}, {NT.I, CN.N, 15}}
}

PeepstaHooBoard = { --Only 1 gate
	{{NT.ST, CN.R}, {NT.I, CN.DR, 0}, {NT.I, CN.DR, 2}, {NT.ITG, CN.R}, {NT.I, CN.D, 8}},
	{{NT.N}, {NT.I, CN.N, 1}, {NT.I, CN.R, 3}, {NT.I, CN.D, 4}, {NT.I, CN.R, 9}, {NT.I, CN.D, 10}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.I, CN.R, 5}, {NT.I, CN.D, 6}, {NT.I, CN.DR, 11}, {NT.I, CN.N, 12}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.I, CN.N, 7}, {NT.I, CN.D, 13}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.I, CN.R, 14}, {NT.I, CN.N, 15}}
}

EscarglowBoard = { --Only 1 gate
	{{NT.N}, {NT.I, CN.D, 3}},
	{{NT.N}, {NT.I, CN.D, 2}, {NT.I, CN.DR, 13}, {NT.I, CN.R, 12}, {NT.I, CN.D, 11}},
	{{NT.N}, {NT.I, CN.D, 1}, {NT.I, CN.R, 14}, {NT.I, CN.N, 15}, {NT.I, CN.D, 10}, {NT.I, CN.D, 9}},
	{{NT.ST, CN.R}, {NT.I, CN.DR, 0}, {NT.I, CN.R, 6}, {NT.I, CN.R, 7}, {NT.ITG, CN.R}, {NT.I, CN.N, 8}},
	{{NT.N}, {NT.I, CN.D, 4}},
	{{NT.N}, {NT.I, CN.N, 5}}
}

KOKabutoBoard = {
	{{NT.N}, {NT.N}, {NT.ST, CN.D}},
	{{NT.I, CN.DR, 5}, {NT.ITG, CN.R}, {NT.I, CN.D, 0}},
	{{NT.I, CN.R, 6}, {NT.I, CN.D, 7}, {NT.I, CN.DR, 1}, {NT.ITG, CN.D}},
	{{NT.I, CN.R, 9}, {NT.I, CN.D, 8}, {NT.I, CN.D, 2}, {NT.I, CN.DR, 12}, {NT.I, CN.N, 13}},
	{{NT.N}, {NT.I, CN.D, 10}, {NT.I, CN.D, 3}, {NT.I, CN.D, 14}},
	{{NT.N}, {NT.E, CN.D}, {NT.I, CN.N, 4}, {NT.I, CN.N, 15}},
	{{NT.N}, {NT.I, CN.N, 11}}
}

WheeflowerBoard = { --Only 1 gate
	{{NT.N}, {NT.N}, {NT.N}, {NT.ST, CN.D}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.I, CN.D, 0}},
	{{NT.N}, {NT.I, CN.R, 3}, {NT.I, CN.R, 2}, {NT.I, CN.D, 1}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.I, CN.DR, 4}, {NT.I, CN.R, 5}, {NT.I, CN.R, 6}, {NT.I, CN.N, 7}},
	{{NT.N}, {NT.I, CN.R, 9}, {NT.I, CN.R, 8}, {NT.ITG, CN.D}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.I, CN.DR, 10}, {NT.I, CN.R, 11}, {NT.I, CN.N, 12}},
	{{NT.N}, {NT.N}, {NT.I, CN.R, 14}, {NT.I, CN.R, 13}, {NT.I, CN.N, 15}}
}

GhostabockyBoard = { --Effectively 1 gate
	{{NT.ST, CN.R}, {NT.I, CN.R, 0}, {NT.I, CN.DR, 1}, {NT.ITG, CN.DR}, {NT.I, CN.DR, 11}, {NT.I, CN.D, 12}},
	{{NT.N}, {NT.N}, {NT.I, CN.D, 2}, {NT.I, CN.D, 14}, {NT.I, CN.D, 10}, {NT.I, CN.N, 13}},
	{{NT.N}, {NT.N}, {NT.I, CN.D, 3}, {NT.I, CN.N, 15}, {NT.I, CN.D, 9}},
	{{NT.N}, {NT.N}, {NT.I, CN.DR, 4}, {NT.ITG, CN.R}, {NT.I, CN.D, 8}},
	{{NT.N}, {NT.N}, {NT.I, CN.R, 5}, {NT.I, CN.R, 6}, {NT.I, CN.N, 7}}
}

ZolephantBoard = { --Only 1 gate; Added Node 11 as an extra
	{{NT.N}, {NT.I, CN.D, 3}, {NT.N}, {NT.I, CN.R, 11}, {NT.I, CN.D, 10}},
	{{NT.N}, {NT.I, CN.D, 2}, {NT.N}, {NT.N}, {NT.I, CN.D, 9}},
	{{NT.N}, {NT.I, CN.D, 1}, {NT.N}, {NT.I, CN.DR, 7}, {NT.I, CN.N, 8}},
	{{NT.ST, CN.R}, {NT.I, CN.R, 0}, {NT.I, CN.DR, 4}, {NT.ITG, CN.DR}, {NT.I, CN.N, 12}},
	{{NT.N}, {NT.N}, {NT.I, CN.D, 5}, {NT.I, CN.R, 13}, {NT.I, CN.D, 14}},
	{{NT.N}, {NT.N}, {NT.I, CN.N, 6}, {NT.N}, {NT.I, CN.N, 15}}
}

JugglePupBoard = {
	{{NT.ST, CN.D}, {NT.N}, {NT.I, CN.D, 2}},
	{{NT.E, CN.D}, {NT.I, CN.DR, 1}, {NT.E, CN.R}, {NT.I, CN.DR, 3}, {NT.E, CN.D}},
	{{NT.I, CN.R, 0}, {NT.E, CN.N}, {NT.I, CN.DR, 4}, {NT.E, CN.N}, {NT.I, CN.DR, 5}, {NT.E, CN.R}, {NT.I, CN.N, 6}},
	{{NT.N}, {NT.I, CN.R, 7}, {NT.ITG, CN.D}, {NT.I, CN.R, 12}, {NT.ITG, CN.DR}, {NT.I, CN.D, 13}},
	{{NT.N}, {NT.N}, {NT.I, CN.R, 8}, {NT.E, CN.D}, {NT.I, CN.N, 15}, {NT.E, CN.R}, {NT.I, CN.N, 14}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.I, CN.DR, 9}, {NT.E, CN.R}, {NT.I, CN.N, 10}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.I, CN.N, 11}}
}

HalbirdBoard = {
	{{NT.N}, {NT.N}, {NT.N}, {NT.I, CN.D, 0}},
	{{NT.I, CN.R, 11}, {NT.I, CN.D, 10}, {NT.I, CN.R, 1}, {NT.ST, CN.D}, {NT.N}, {NT.E, CN.DR}, {NT.I, CN.N, 15}},
	{{NT.N}, {NT.I, CN.R, 9}, {NT.I, CN.D, 8}, {NT.I, CN.D, 2}, {NT.I, CN.DR, 13}, {NT.I, CN.N, 14}},
	{{NT.N}, {NT.N}, {NT.ITG, CN.R}, {NT.I, CN.D, 3}, {NT.I, CN.D, 12}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.I, CN.DR, 4}, {NT.ITG, CN.N}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.I, CN.R, 5}, {NT.I, CN.D, 6}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.I, CN.N, 7}}
}

StaggercepsBoard = { --Only 1 gate
	{{NT.N}, {NT.N}, {NT.I, CN.R, 4}, {NT.I, CN.D, 3}},
	{{NT.ST, CN.R}, {NT.I, CN.DR, 0}, {NT.I, CN.R, 1}, {NT.I, CN.D, 2}},
	{{NT.N}, {NT.I, CN.D, 5}, {NT.I, CN.R, 7}, {NT.ITG, CN.D}, {NT.I, CN.DR, 9}, {NT.I, CN.N, 10}},
	{{NT.N}, {NT.I, CN.N, 6}, {NT.N}, {NT.I, CN.DR, 8}, {NT.E, CN.D}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.I, CN.D, 13}, {NT.I, CN.R, 11}, {NT.I, CN.N, 12}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.I, CN.R, 14}, {NT.E, CN.R}, {NT.I, CN.N, 15}}
}

FishboneBoard = { --Only 1 gate
	{{NT.I, CN.DR, 0}, {NT.I, CN.R, 1}, {NT.I, CN.DR, 2}, {NT.I, CN.R, 3}, {NT.I, CN.N, 4}},
	{{NT.ST, CN.N}, {NT.I, CN.R, 6}, {NT.I, CN.DR, 5}, {NT.I, CN.N, 7}},
	{{NT.E, CN.DR}, {NT.I, CN.R, 8}, {NT.ITG, CN.D}},
	{{NT.I, CN.N, 9}, {NT.N}, {NT.I, CN.D, 10}},
	{{NT.N}, {NT.I, CN.DR, 12}, {NT.I, CN.R, 11}, {NT.I, CN.D, 14}},
	{{NT.N}, {NT.I, CN.N, 13}, {NT.N}, {NT.I, CN.N, 15}}
}

FlowbermeowBoard = { --Draft accidentally had an extra item node; replaced with empty
	{{NT.N}, {NT.I, CN.D, 11}, {NT.I, CN.D, 15}},
	{{NT.I, CN.DR, 9}, {NT.I, CN.D, 10}, {NT.I, CN.DR, 14}, {NT.I, CN.D, 13}},
	{{NT.I, CN.R, 8}, {NT.ITG, CN.D}, {NT.ITG, CN.DR}, {NT.I, CN.N, 12}},
	{{NT.N}, {NT.I, CN.DR, 6}, {NT.I, CN.D, 5}},
	{{NT.N}, {NT.I, CN.N, 7}, {NT.I, CN.D, 4}},
	{{NT.ST, CN.R}, {NT.I, CN.R, 0}, {NT.I, CN.R, 1}, {NT.I, CN.R, 2}, {NT.E, CN.R}, {NT.I, CN.N, 3}}
}

CyberYogBoard = { --Only 1 gate
	{{NT.ST, CN.D}, {NT.N}, {NT.N}, {NT.E, CN.DR}, {NT.I, CN.N, 7}, {NT.I, CN.D, 12}},
	{{NT.I, CN.R, 0}, {NT.I, CN.DR, 1}, {NT.I, CN.DR, 6}, {NT.ITG, CN.DR}, {NT.I, CN.R, 10}, {NT.I, CN.DR, 11}, {NT.E, CN.R}, {NT.I, CN.N, 15}},
	{{NT.N}, {NT.I, CN.DR, 2}, {NT.I, CN.N, 5}, {NT.I, CN.D, 8}, {NT.N}, {NT.I, CN.D, 13}},
	{{NT.N}, {NT.I, CN.D, 3}, {NT.N}, {NT.I, CN.N, 9}, {NT.N}, {NT.I, CN.N, 14}},
	{{NT.N}, {NT.I, CN.N, 4}}
}

ChefKyrooBoard = {
	{{NT.N}, {NT.N}, {NT.ST, CN.D}},
	{{NT.N}, {NT.ITG, CN.DR}, {NT.I, CN.R, 0}, {NT.I, CN.D, 1}},
	{{NT.I, CN.DR, 7}, {NT.I, CN.N, 6}, {NT.N}, {NT.I, CN.D, 2}},
	{{NT.I, CN.R, 8}, {NT.I, CN.D, 9}, {NT.N}, {NT.I, CN.D, 3}},
	{{NT.N}, {NT.I, CN.N, 10}, {NT.N}, {NT.I, CN.DR, 4}, {NT.I, CN.N, 5}},
	{{NT.I, CN.R, 13}, {NT.I, CN.R, 12}, {NT.I, CN.DR, 11}, {NT.ITG, CN.N}},
	{{NT.N}, {NT.N}, {NT.I, CN.D, 14}},
	{{NT.N}, {NT.N}, {NT.I, CN.N, 15}}
}

LordKyrooBoard = { --Draft accidentally had an extra item node; replaced with empty
	{{NT.N}, {NT.ST, CN.D}, {NT.N}, {NT.I, CN.D, 4}},
	{{NT.I, CN.R, 1}, {NT.I, CN.DR, 0}, {NT.I, CN.R, 2}, {NT.I, CN.D, 3}},
	{{NT.N}, {NT.I, CN.D, 5}, {NT.N}, {NT.I, CN.D, 6}},
	{{NT.N}, {NT.ITG, CN.DR}, {NT.I, CN.D, 9}, {NT.ITG, CN.DR}, {NT.I, CN.R, 13}, {NT.I, CN.R, 14}, {NT.I, CN.N, 15}},
	{{NT.N}, {NT.I, CN.D, 7}, {NT.E, CN.D}, {NT.I, CN.D, 11}},
	{{NT.N}, {NT.I, CN.N, 8}, {NT.I, CN.N, 10}, {NT.I, CN.N, 12}}
}

TatsuBlazeBoard = {
	{{NT.N}, {NT.N}, {NT.ST, CN.D}},
	{{NT.N}, {NT.N}, {NT.I, CN.DR, 0}, {NT.ITG, CN.R}, {NT.I, CN.R, 8}, {NT.I, CN.R, 9}, {NT.I, CN.D, 10}},
	{{NT.N}, {NT.N}, {NT.I, CN.D, 1}, {NT.N}, {NT.N}, {NT.N}, {NT.I, CN.N, 11}},
	{{NT.N}, {NT.I, CN.R, 3}, {NT.I, CN.DR, 2}, {NT.I, CN.N, 4}},
	{{NT.N}, {NT.I, CN.DR, 6}, {NT.I, CN.R, 5}, {NT.ITG, CN.D}},
	{{NT.N}, {NT.I, CN.N, 7}, {NT.I, CN.DR, 13}, {NT.I, CN.D, 12}},
	{{NT.N}, {NT.N}, {NT.I, CN.N, 14}, {NT.I, CN.N, 15}}
}

ElectricornBoard = {
	{{NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.I, CN.DR, 7}, {NT.I, CN.R, 8}, {NT.I, CN.D, 9}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.ITG, CN.DR}, {NT.I, CN.N, 6}, {NT.N}, {NT.I, CN.N, 10}},
	{{NT.ST, CN.R}, {NT.I, CN.R, 0}, {NT.I, CN.R, 1}, {NT.I, CN.R, 2}, {NT.I, CN.DR, 3}, {NT.I, CN.R, 4}, {NT.I, CN.N, 5}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.ITG, CN.R}, {NT.I, CN.D, 11}, {NT.N}, {NT.I, CN.D, 15}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.I, CN.R, 12}, {NT.I, CN.R, 13}, {NT.I, CN.N, 14}}
}

WoeflowerBoard = { --Only 1 gate
	{{NT.N}, {NT.I, CN.DR, 2}, {NT.E, CN.R}, {NT.I, CN.N, 3}},
	{{NT.N}, {NT.I, CN.D, 1}, {NT.N}, {NT.N}, {NT.I, CN.DR, 8}, {NT.I, CN.R, 9}, {NT.I, CN.N, 10}},
	{{NT.ST, CN.R}, {NT.I, CN.DR, 0}, {NT.ITG, CN.R}, {NT.I, CN.R, 6}, {NT.I, CN.DR, 7}, {NT.I, CN.R, 11}, {NT.I, CN.N, 12}},
	{{NT.N}, {NT.I, CN.D, 4}, {NT.N}, {NT.N}, {NT.I, CN.R, 13}, {NT.I, CN.R, 14}, {NT.I, CN.N, 15}},
	{{NT.N}, {NT.I, CN.N, 5}}
}

JestabockyBoard = { --Draft had an extra node, placing empty
	{{NT.ST, CN.D}},
	{{NT.I, CN.DR, 0}, {NT.ITG, CN.R}, {NT.I, CN.R, 9}, {NT.I, CN.R, 10}, {NT.E, CN.R}, {NT.I, CN.N, 11}},
	{{NT.I, CN.DR, 1}, {NT.I, CN.R, 2}, {NT.I, CN.D, 3}},
	{{NT.ITG, CN.D}, {NT.N}, {NT.I, CN.D, 4}},
	{{NT.I, CN.D, 12}, {NT.N}, {NT.I, CN.D, 5}, {NT.I, CN.D, 8}},
	{{NT.I, CN.D, 13}, {NT.N}, {NT.I, CN.R, 6}, {NT.I, CN.N, 7}},
	{{NT.I, CN.D, 14}},
	{{NT.I, CN.N, 15}}
}

EagliderBoard = { --Only 1 gate
	{{NT.ST, CN.DR}, {NT.I, CN.R, 2}, {NT.I, CN.DR, 3}, {NT.I, CN.R, 4}, {NT.I, CN.R, 5}, {NT.I, CN.N, 6}},
	{{NT.I, CN.D, 0}, {NT.N}, {NT.I, CN.R, 7}, {NT.ITG, CN.DR}, {NT.I, CN.R, 8}, {NT.I, CN.R, 9}, {NT.I, CN.N, 10}},
	{{NT.I, CN.N, 1}, {NT.N}, {NT.N}, {NT.I, CN.R, 11}, {NT.I, CN.DR, 12}, {NT.I, CN.R, 13}, {NT.I, CN.N, 14}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.E, CN.D}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.I, CN.N, 15}}
}

MeMeBunnyBoard = {
	{{NT.ST, CN.R}, {NT.I, CN.DR, 0}, {NT.I, CN.DR, 1}, {NT.I, CN.R, 2}, {NT.I, CN.N, 3}},
	{{NT.N}, {NT.I, CN.DR, 4}, {NT.ITG, CN.R}, {NT.I, CN.D, 7}},
	{{NT.N}, {NT.I, CN.R, 5}, {NT.I, CN.D, 6}, {NT.I, CN.D, 8}},
	{{NT.N}, {NT.I, CN.DR, 11}, {NT.ITG, CN.D}, {NT.I, CN.R, 9}, {NT.I, CN.N, 10}},
	{{NT.N}, {NT.I, CN.N, 12}, {NT.I, CN.D, 13}},
	{{NT.N}, {NT.N}, {NT.I, CN.R, 14}, {NT.I, CN.N, 15}}
}

DrillSyeBoard = { --Only 1 gate
	{{NT.ST, CN.R}, {NT.I, CN.DR, 0}, {NT.I, CN.R, 2}, {NT.I, CN.R, 3}, {NT.I, CN.DR, 4}, {NT.I, CN.R, 5}, {NT.I, CN.N, 6}},
	{{NT.N}, {NT.E, CN.D}, {NT.I, CN.DR, 9}, {NT.I, CN.R, 8}, {NT.ITG, CN.R}, {NT.I, CN.N, 7}},
	{{NT.N}, {NT.I, CN.N, 1}, {NT.I, CN.R, 10}, {NT.I, CN.R, 11}, {NT.I, CN.DR, 12}, {NT.I, CN.N, 13}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.I, CN.R, 14}, {NT.I, CN.N, 15}}
}

TyrantoRexBoard = {
	{{NT.ST, CN.R}, {NT.I, CN.DR, 0}, {NT.I, CN.R, 2}, {NT.I, CN.R, 3}, {NT.I, CN.R, 4}, {NT.I, CN.DR, 5}},
	{{NT.N}, {NT.I, CN.D, 1}, {NT.N}, {NT.N}, {NT.N}, {NT.ITG, CN.DR}, {NT.I, CN.N, 11}},
	{{NT.N}, {NT.ITG, CN.R}, {NT.I, CN.R, 6}, {NT.I, CN.DR, 7}, {NT.I, CN.N, 8}, {NT.I, CN.D, 12}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.I, CN.D, 9}, {NT.N}, {NT.I, CN.R, 13}, {NT.I, CN.D, 14}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.I, CN.N, 10}, {NT.N}, {NT.N}, {NT.I, CN.N, 15}}
}

MajikLapinBoard = {
	{{NT.N}, {NT.N}, {NT.ST, CN.D}},
	{{NT.N}, {NT.N}, {NT.I, CN.DR, 0}, {NT.I, CN.N, 1}},
	{{NT.I, CN.R, 4}, {NT.I, CN.DR, 3}, {NT.I, CN.D, 2}},
	{{NT.N}, {NT.ITG, CN.DR}, {NT.I, CN.DR, 5}, {NT.I, CN.R, 6}, {NT.I, CN.N, 7}},
	{{NT.I, CN.R, 9}, {NT.I, CN.D, 8}, {NT.ITG, CN.R}, {NT.I, CN.R, 12}, {NT.I, CN.D, 13}},
	{{NT.I, CN.R, 11}, {NT.I, CN.N, 10}, {NT.N}, {NT.I, CN.R, 15}, {NT.I, CN.N, 14}}
}

CeraTerrorBoard = {
	{{NT.N}, {NT.N}, {NT.ST, CN.D}},
	{{NT.N}, {NT.N}, {NT.I, CN.D, 0}},
	{{NT.N}, {NT.ITG, CN.DR}, {NT.I, CN.DR, 1}, {NT.I, CN.D, 2}},
	{{NT.I, CN.R, 7}, {NT.I, CN.D, 6}, {NT.I, CN.D, 3}, {NT.ITG, CN.DR}, {NT.I, CN.R, 11}, {NT.I, CN.N, 12}},
	{{NT.I, CN.DR, 9}, {NT.I, CN.N, 8}, {NT.I, CN.D, 4}, {NT.I, CN.R, 13}, {NT.I, CN.D, 14}},
	{{NT.I, CN.N, 10}, {NT.N}, {NT.I, CN.N, 5}, {NT.N}, {NT.I, CN.N, 15}}
}

SkelterwildBoard = {
	{{NT.N}, {NT.N}, {NT.ST, CN.D}},
	{{NT.N}, {NT.N}, {NT.I, CN.DR, 0}, {NT.I, CN.N, 1}},
	{{NT.N}, {NT.I, CN.DR, 3}, {NT.I, CN.DR, 2}, {NT.I, CN.R, 4}, {NT.ITG, CN.D}},
	{{NT.N}, {NT.E, CN.D}, {NT.I, CN.N, 5}, {NT.N}, {NT.I, CN.D, 6}},
	{{NT.I, CN.DR, 13}, {NT.ITG, CN.D}, {NT.N}, {NT.N}, {NT.I, CN.D, 7}},
	{{NT.I, CN.D, 14}, {NT.I, CN.D, 11}, {NT.I, CN.R, 10}, {NT.I, CN.R, 9}, {NT.I, CN.N, 8}},
	{{NT.I, CN.N, 15}, {NT.I, CN.N, 12}}
}

DuckyGooseBoard = {
	{{NT.ST, CN.R}, {NT.I, CN.DR, 0}, {NT.E, CN.R}, {NT.I, CN.R, 1}, {NT.E, CN.R}, {NT.I, CN.R, 2}, {NT.E, CN.R}, {NT.I, CN.D, 3}},
	{{NT.N}, {NT.E, CN.D}, {NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.E, CN.D}},
	{{NT.N}, {NT.I, CN.D, 5}, {NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.I, CN.D, 4}},
	{{NT.N}, {NT.E, CN.D}, {NT.N}, {NT.N}, {NT.I, CN.D, 15}, {NT.N}, {NT.N}, {NT.ITG, CN.D}},
	{{NT.N}, {NT.I, CN.D, 6}, {NT.N}, {NT.N}, {NT.E, CN.R}, {NT.I, CN.R, 14}, {NT.E, CN.D}, {NT.I, CN.D, 12}},
	{{NT.N}, {NT.E, CN.D}, {NT.N}, {NT.N}, {NT.I, CN.R, 11}, {NT.E, CN.D}, {NT.I, CN.R, 13}, {NT.E, CN.N}},
	{{NT.N}, {NT.I, CN.D, 7}, {NT.N}, {NT.N}, {NT.N}, {NT.I, CN.D, 10}},
	{{NT.N}, {NT.ITG, CN.R}, {NT.I, CN.R, 8}, {NT.E, CN.R}, {NT.I, CN.R, 9}, {NT.E, CN.N}}
}

AuraLionBoard = { --Only had 15 items specified; added 1; also 1 gate
	{{NT.N}, {NT.N}, {NT.ST, CN.D}},
	{{NT.N}, {NT.N}, {NT.I, CN.D, 0}},
	{{NT.N}, {NT.I, CN.DR, 2}, {NT.I, CN.DR, 1}, {NT.I, CN.D, 4}},
	{{NT.I, CN.R, 3}, {NT.E, CN.N}, {NT.ITG, CN.D}, {NT.I, CN.N, 5}},
	{{NT.N}, {NT.I, CN.DR, 7}, {NT.I, CN.D, 6}, {NT.I, CN.DR, 11}, {NT.I, CN.R, 12}, {NT.I, CN.N, 13}},
	{{NT.N}, {NT.I, CN.N, 8}, {NT.I, CN.R, 9}, {NT.I, CN.R, 10}, {NT.I, CN.D, 14}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.I, CN.N, 15}}
}

RyuDragonBoard = { --Only 1 gate
	{{NT.I, CN.DR, 3}, {NT.I, CN.R, 2}, {NT.ST, CN.R}, {NT.I, CN.R, 0}, {NT.I, CN.N, 1}},
	{{NT.I, CN.R, 4}, {NT.I, CN.R, 5}, {NT.ITG, CN.D}},
	{{NT.N}, {NT.I, CN.DR, 7}, {NT.I, CN.D, 6}, {NT.I, CN.DR, 10}, {NT.I, CN.N, 11}},
	{{NT.E, CN.DR}, {NT.E, CN.N}, {NT.E, CN.R}, {NT.I, CN.R, 9}, {NT.I, CN.DR, 12}, {NT.E, CN.R}, {NT.I, CN.N, 15}},
	{{NT.I, CN.N, 8}, {NT.N}, {NT.N}, {NT.I, CN.R, 14}, {NT.I, CN.N, 13}}
}

DrakQuackBoard = {
	{{NT.ST, CN.DR}, {NT.E, CN.R}, {NT.I, CN.R, 0}, {NT.E, CN.R}, {NT.I, CN.R, 1}, {NT.E, CN.R}, {NT.I, CN.R, 2}, {NT.ITG, CN.D}},
	{{NT.E, CN.D}, {NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.I, CN.D, 11}},
	{{NT.I, CN.D, 3}, {NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.E, CN.D}},
	{{NT.E, CN.D}, {NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.I, CN.D, 15}, {NT.N}, {NT.I, CN.D, 12}},
	{{NT.I, CN.D, 4}, {NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.E, CN.R}, {NT.I, CN.D, 14}, {NT.E, CN.D}},
	{{NT.E, CN.D}, {NT.N}, {NT.N}, {NT.I, CN.R, 10}, {NT.E, CN.D}, {NT.N}, {NT.E, CN.R}, {NT.I, CN.N, 13}},
	{{NT.I, CN.D, 5}, {NT.N}, {NT.N}, {NT.N}, {NT.I, CN.R, 9}, {NT.E, CN.D}},
	{{NT.ITG, CN.R}, {NT.I, CN.R, 6}, {NT.E, CN.R}, {NT.I, CN.R, 7}, {NT.E, CN.R}, {NT.I, CN.N, 8}}
}

KeebaTigerBoard = { --Only 1 gate
	{{NT.N}, {NT.ITG, CN.DR}, {NT.I, CN.R, 6}, {NT.I, CN.D, 7}, {NT.N}, {NT.E, CN.DR}, {NT.I, CN.N, 15}},
	{{NT.ST, CN.DR}, {NT.I, CN.DR, 1}, {NT.I, CN.D, 3}, {NT.I, CN.DR, 8}, {NT.I, CN.R, 11}, {NT.I, CN.D, 12}},
	{{NT.E, CN.D}, {NT.I, CN.N, 2}, {NT.I, CN.D, 4}, {NT.E, CN.R}, {NT.I, CN.D, 9}, {NT.I, CN.R, 13}, {NT.I, CN.N, 14}},
	{{NT.I, CN.N, 0}, {NT.N}, {NT.I, CN.N, 5}, {NT.N}, {NT.I, CN.N, 10}}
}

MeowjestyBoard = {
	{{NT.I, CN.R, 8}, {NT.I, CN.R, 7}, {NT.I, CN.DR, 6}, {NT.I, CN.R, 9}, {NT.I, CN.N, 10}},
	{{NT.N}, {NT.N}, {NT.ITG, CN.D}},
	{{NT.N}, {NT.ST, CN.R}, {NT.I, CN.DR, 0}, {NT.I, CN.R, 1}, {NT.I, CN.R, 2}, {NT.I, CN.R, 3}, {NT.I, CN.R, 4}, {NT.I, CN.N, 5}},
	{{NT.N}, {NT.N}, {NT.ITG, CN.D}},
	{{NT.I, CN.R, 13}, {NT.I, CN.R, 12}, {NT.I, CN.R, 11}, {NT.I, CN.R, 14}, {NT.I, CN.N, 15}}
}

SudoNekuBoard = { --Only 1 gate
	{{NT.N}, {NT.I, CN.DR, 1}, {NT.I, CN.D, 2}, {NT.I, CN.DR, 6}, {NT.I, CN.D, 7}, {NT.I, CN.DR, 12}, {NT.I, CN.D, 13}},
	{{NT.ST, CN.R}, {NT.I, CN.D, 0}, {NT.I, CN.DR, 5}, {NT.ITG, CN.N}, {NT.I, CN.D, 8}, {NT.I, CN.D, 11}, {NT.I, CN.D, 14}},
	{{NT.N}, {NT.I, CN.R, 3}, {NT.I, CN.N, 4}, {NT.N}, {NT.I, CN.R, 9}, {NT.I, CN.N, 10}, {NT.I, CN.N, 15}}
}

FrootzCatBoard = {
	{{NT.N}, {NT.N}, {NT.I, CN.D, 11}},
	{{NT.I, CN.R, 10}, {NT.I, CN.D, 9}, {NT.ITG, CN.DR}, {NT.I, CN.R, 12}, {NT.I, CN.R, 13}, {NT.I, CN.R, 14}, {NT.I, CN.N, 15}},
	{{NT.N}, {NT.I, CN.D, 8}, {NT.E, CN.R}, {NT.I, CN.D, 5}},
	{{NT.I, CN.DR, 6}, {NT.I, CN.N, 7}, {NT.I, CN.DR, 2}, {NT.I, CN.R, 3}, {NT.I, CN.N, 4}},
	{{NT.ITG, CN.R}, {NT.I, CN.R, 1}, {NT.I, CN.D, 0}},
	{{NT.N}, {NT.N}, {NT.ST, CN.N}}
}

UrsaCircusBoard = {
	{{NT.I, CN.R, 1}, {NT.I, CN.R, 0}, {NT.ST, CN.D}},
	{{NT.N}, {NT.N}, {NT.I, CN.DR, 2}, {NT.I, CN.D, 3}},
	{{NT.N}, {NT.ITG, CN.DR}, {NT.I, CN.D, 4}, {NT.ITG, CN.DR}, {NT.I, CN.D, 12}},
	{{NT.N}, {NT.I, CN.D, 6}, {NT.I, CN.N, 5}, {NT.I, CN.N, 11}, {NT.I, CN.R, 13}, {NT.I, CN.D, 14}},
	{{NT.N}, {NT.I, CN.R, 7}, {NT.I, CN.R, 8}, {NT.I, CN.R, 9}, {NT.I, CN.N, 10}, {NT.I, CN.N, 15}}
}

KabKannonBoard = {
	{{NT.I, CN.DR, 14}, {NT.I, CN.N, 15}, {NT.I, CN.DR, 7}, {NT.I, CN.R, 6}, {NT.ITG, CN.D}},
	{{NT.I, CN.R, 13}, {NT.E, CN.D}, {NT.I, CN.R, 8}, {NT.I, CN.D, 9}, {NT.I, CN.D, 5}},
	{{NT.I, CN.DR, 11}, {NT.I, CN.N, 12}, {NT.N}, {NT.I, CN.N, 10}, {NT.I, CN.D, 4}},
	{{NT.ITG, CN.D}, {NT.N}, {NT.N}, {NT.N}, {NT.I, CN.D, 3}},
	{{NT.E, CN.R}, {NT.I, CN.R, 2}, {NT.I, CN.R, 1}, {NT.I, CN.R, 0}, {NT.ST, CN.N}}
}

RRSealBoard = {
	{{NT.ST, CN.R}, {NT.E, CN.D}, {NT.I, CN.DR, 2}, {NT.E, CN.D}},
	{{NT.N}, {NT.I, CN.DR, 0}, {NT.E, CN.N}, {NT.I, CN.DR, 3}, {NT.ITG, CN.R}, {NT.E, CN.DR}, {NT.I, CN.N, 6}},
	{{NT.I, CN.R, 1}, {NT.E, CN.N}, {NT.I, CN.DR, 4}, {NT.E, CN.N}, {NT.I, CN.R, 8}, {NT.I, CN.D, 7}},
	{{NT.N}, {NT.N}, {NT.E, CN.R}, {NT.I, CN.D, 5}, {NT.N}, {NT.I, CN.D, 9}},
	{{NT.N}, {NT.N}, {NT.I, CN.DR, 11}, {NT.ITG, CN.R}, {NT.I, CN.D, 12}, {NT.I, CN.N, 10}},
	{{NT.N}, {NT.N}, {NT.E, CN.R}, {NT.I, CN.DR, 13}, {NT.E, CN.R}, {NT.I, CN.N, 15}},
	{{NT.N}, {NT.N}, {NT.N}, {NT.I, CN.N, 14}}
}

CatanukiBoard = {
	{{NT.I, CN.R, 13}, {NT.I, CN.R, 12}, {NT.I, CN.DR, 11}, {NT.I, CN.R, 14}, {NT.I, CN.N, 15}},
	{{NT.N}, {NT.N}, {NT.ITG, CN.D}},
	{{NT.N}, {NT.N}, {NT.I, CN.D, 5}},
	{{NT.I, CN.DR, 9}, {NT.I, CN.N, 10}, {NT.ST, CN.D}},
	{{NT.I, CN.D, 8}, {NT.N}, {NT.I, CN.D, 0}},
	{{NT.I, CN.D, 7}, {NT.N}, {NT.I, CN.D, 1}},
	{{NT.I, CN.R, 6}, {NT.ITG, CN.R}, {NT.I, CN.R, 2}, {NT.I, CN.R, 3}, {NT.I, CN.N, 4}}
}

BeatalikeBoard = { --Only 1 gate
	{{NT.N}, {NT.I, CN.R, 11}, {NT.I, CN.R, 10}, {NT.E, CN.DR}, {NT.I, CN.R, 12}, {NT.I, CN.R, 13}, {NT.I, CN.D, 14}},
	{{NT.I, CN.D, 5}, {NT.N}, {NT.N}, {NT.I, CN.D, 9}, {NT.N}, {NT.N}, {NT.E, CN.D}},
	{{NT.I, CN.D, 4}, {NT.N}, {NT.N}, {NT.I, CN.D, 8}, {NT.N}, {NT.N}, {NT.I, CN.N, 15}},
	{{NT.E, CN.R}, {NT.I, CN.R, 3}, {NT.I, CN.D, 2}, {NT.I, CN.R, 7}, {NT.ITG, CN.D}},
	{{NT.N}, {NT.N}, {NT.E, CN.D}, {NT.ST, CN.D}, {NT.E, CN.D}},
	{{NT.N}, {NT.N}, {NT.I, CN.R, 1}, {NT.I, CN.R, 0}, {NT.I, CN.N, 6}}
}

TubguinAceBoard = {
	{{NT.N}, {NT.I, CN.DR, 13}, {NT.I, CN.R, 14}, {NT.I, CN.N, 15}, {NT.I, CN.R, 11}, {NT.I, CN.D, 10}},
	{{NT.ITG, CN.DR}, {NT.I, CN.N, 12}, {NT.N}, {NT.N}, {NT.N}, {NT.I, CN.R, 9}, {NT.I, CN.D, 8}},
	{{NT.E, CN.D}, {NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.N}, {NT.ITG, CN.D}},
	{{NT.I, CN.R, 7}, {NT.I, CN.D, 6}, {NT.N}, {NT.N}, {NT.N}, {NT.I, CN.DR, 2}, {NT.I, CN.N, 3}},
	{{NT.N}, {NT.I, CN.R, 5}, {NT.I, CN.R, 4}, {NT.ST, CN.R}, {NT.I, CN.R, 0}, {NT.I, CN.N, 1}}
}

function Lboard_Addr()
	--Location file group pointer
	local _scanOffset = ReadByte(_offsetAddr[gameVer])*8
	local _pointerAddr = ReadLong(_fileGroups[gameVer]+_scanOffset)

	--Verify that stuff is at the address

	local _filesAddr = ReadLong(_pointerAddr+0x50, true)

	if _filesAddr == nil then
		return nil
	end
	if _filesAddr == 0 then
		return nil
	end
	
	--Find pointer for lboard.bin
	for x = 1, _scanLimit do
		if ReadString(_filesAddr+0x44, #_lboardFile, true) == _lboardFile then
			return ReadLong(_filesAddr+0x20, true)
		end
		_filesAddr = ReadLong(_filesAddr + 0x08, true)
	end

	--Not found
	return nil
end

--Only run function if we can be confident the board is actually loaded
local _activeBoard = {0x9E9A40, 0x9E9A30}
local _activeBoardOffset = 0x490

LBoardFinder.LBoard = nil

function LBoardFinder:FinderUpdate()
	local _activeBoardInfo = GetPointer(_activeBoard[gameVer], _activeBoardOffset)
	local _activeInfo = ReadArray(_activeBoardInfo, 4, true)

	--Is a spirit board active
	for x=2, #_activeInfo do
		if _activeInfo[x] > 0 then --Something other than the link board has been loaded
			self.LBoard = nil
			return
		end
	end

	--If we make it here the link board is likely loaded
	if self.LBoard == nil then --Perform the check
		self.LBoard = Lboard_Addr()
		if self.LBoard ~= nil then --Did the check succeed
			self:PatchBoards()
			ConsolePrint("Link board loaded")
		end
	end
end

function CoordsToByte(coords) --Converts table coordinates into a single byte
	bitTbl = {0, 0, 0, 0, 0, 0, 0, 0}
	rowBits = toBits(coords[1])
	colBits = toBits(coords[2])

	--Remove last 4 bits
	rowBits[8] = nil
	rowBits[7] = nil
	rowBits[6] = nil
	rowBits[5] = nil
	--del rowBits[-4:]
	colBits[8] = nil
	colBits[7] = nil
	colBits[6] = nil
	colBits[5] = nil
	--del colBits[-4:]

	for i=1, #rowBits do
		bitTbl[5-i] = rowBits[i]
	end

	for i=1, #colBits do
		bitTbl[9-i] = colBits[i]
	end

	--result = toByte(bitTbl)
	--print("Coords "+str(coords[0])+","+str(coords[1])+" result in "+f"{result:x}"+" using bittbl: "+str(bitTbl))

	return toByte(bitTbl)
end

--File modification happens here
local padding = 16
local entry = 0
local offset = 0
linkBoardOffsets = {
	0x110, --Meow Wow
	0x250, --Tama Sheep
	0x3A0, --Yoggy Ram
	0x4F0, --Komory Bat
	0x630, --Pricklemane
	0x780, --Hebby Repp
	0x8B0, --Sir Kyroo
	0x9F0, --Toximander
	0xB30, --Fin Fatale
	0xC80, --Tatsu Steed
	0xDC0, --Necho Cat
	0xEF0, --Thunderaffe
	0x1040, --Kooma Panda
	0x1190, --Pegaslick
	0x12D0, --Iceguin Ace
	0x1400, --Peepsta Hoo
	0x1560, --Escarglow
	0x1690, --KO Kabuto
	0x17E0, --Wheeflower
	0x1920, --Ghostabocky
	0x1A60, --Zolephant
	0x1BA0, --Juggle Pup
	0x1DC0, --Halbird
	0x1F10, --Staggerceps
	0x2070, --Fishbone
	0x21C0, --Flowbermeow
	0x2310, --Cyber Yog
	0x2460, --Chef Kyroo
	0x25C0, --Lord Kyroo
	0x2730, --Tatsu Blaze
	0x2880, --Electricorn
	0x29C0, --Woeflower
	0x2B00, --Jestabocky
	0x2C70, --Eaglider
	0x2DB0, --Me Me Bunny
	0x2EF0, --Drill Sye
	0x3040, --Tyranto Rex
	0x31B0, --Majik Lapin
	0x32F0, --Cera Terror
	0x3450, --Skelterwild
	0x35C0, --Ducky Goose
	0x37D0, --Aura Lion
	0x3930, --Ryu Dragon
	0x3AA0, --Drak Quack
	0x3CC0, --Keeba Tiger
	0x3E30, --Meowjesty
	0x3F80, --Sudo Neku
	0x40B0, --Frootz Cat
	0x4200, --Ursa Circus
	0x4350, --Kab Kannon
	0x44E0, --R & R Seal
	0x4700, --Catanuki
	0x4880, --Beatalike
	0x4A30, --Tubguin Ace
}

boardList = {MeowWowBoard, TamaSheepBoard, YoggyRamBoard, KomoryBatBoard,
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
function LBoardFinder:PatchBoards() --TODO: Only mod boards of spirits in party
	for i=1, #boardList do
		entry = 0
		offset = linkBoardOffsets[i]
		CurrentBoard = boardList[i]
		gateNum = 0

		for x=1, #CurrentBoard do
			for y=1, #CurrentBoard[x] do
				local ind = offset+(padding*entry)+self.LBoard
				if CurrentBoard[x][y][1] ~= NT.N then
					local byteCoord = CoordsToByte({x-1, y-1})

					--Wipe entry for node to clear unset data
					WriteArray(ind, {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}, true)

					--Write node position
					WriteByte(ind, byteCoord, true)
					--Write node type
					WriteByte(ind+0x01, CurrentBoard[x][y][1], true)
					--Write node connection
					WriteByte(ind+0x03, CurrentBoard[x][y][2], true)

					if CurrentBoard[x][y][1] == NT.ITG then --Item gate
						--Write item requirement details
						WriteByte(ind+0x09, 0x08, true) 				--Item category
						WriteByte(ind+0x08, 0x01+gateNum, true) --Item ID
						WriteByte(ind+0x0A, 0x07, true) 				--Num Required

						gateNum = gateNum + 1

					end

					--Write reward info if applicable
					if CurrentBoard[x][y][1] == NT.I then
						--Make cost 0
						WriteByte(ind+0x08, 0x00, true)
						--Set reward index
						WriteByte(ind+0x0A, CurrentBoard[x][y][3], true)
					end

					--Increment entry count
					entry = entry + 1

				end
			end
		end
		--Write EoF node
		WriteArray(offset+(padding*entry)+self.LBoard, {0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}, true)
	end

	ConsolePrint("Boards Patched")
end

return LBoardFinder