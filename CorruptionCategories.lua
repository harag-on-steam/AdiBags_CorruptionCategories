--[[
AdiBags - Corruption Categories
Copyright 2020 Harag (harag@cortexx.net)
All rights reserved.

This file is an extension to AdiBags.

AdiBags is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

AdiBags is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with AdiBags.  If not, see <http://www.gnu.org/licenses/>.
--]]

--<GLOBALS
local _G = _G
local abs = _G.math.abs
local GetItemInfo = _G.GetItemInfo
local GetSpellInfo = _G.GetSpellInfo
local GetContainerItemLink = _G.GetContainerItemLink
local max = _G.max
local min = _G.min
local pairs = _G.pairs
local select = _G.select
local unpack = _G.unpack
--GLOBALS>

local addon = LibStub('AceAddon-3.0'):GetAddon('AdiBags')
local L = addon.L

--local mod = addon:NewModule('CorruptionCategories', 'ABEvent-1.0')
local mod = addon:RegisterFilter("CorruptionCategories", 94)
mod.uiName = "|cffb685ff" .. L['Corruption Categories']
mod.uiDesc = L['Put corrupted items in their own sections.']


local CRITICAL = 1
local HASTE = 2
local MASTERY = 3
local VERSATILITY = 4
local ALL_SECONDARIES = 5

local AVOIDANCE = 6
local LEECH = 7

local DMG = 8
local AOE = 9
local COOLDOWN = 10
local INTELLIGENCE = 11

local FLAT = 12
local PROC = 13
local MAGNITUDE = 14

-- bonusId -> spellId, corruptionAmount, name, rank, effect, effectType

local CORRUPTIONS = {
	[6483] = {315607, 10, "Avoidant", 1, AVOIDANCE, FLAT},
	[6484] = {315608, 15, "Avoidant", 2, AVOIDANCE, FLAT},
	[6485] = {315609, 20, "Avoidant", 3, AVOIDANCE, FLAT},

	[6474] = {315544, 10, "Expedient", 1, HASTE, FLAT},
	[6475] = {315545, 15, "Expedient", 2, HASTE, FLAT},
	[6476] = {315546, 20, "Expedient", 3, HASTE, FLAT},

	[6471] = {315529, 10, "Masterful", 1, MASTERY, FLAT},
	[6472] = {315530, 15, "Masterful", 2, MASTERY, FLAT},
	[6473] = {315531, 20, "Masterful", 3, MASTERY, FLAT},

	[6480] = {315554, 10, "Severe", 1, CRITICAL, FLAT},
	[6481] = {315557, 15, "Severe", 2, CRITICAL, FLAT},
	[6482] = {315558, 20, "Severe", 3, CRITICAL, FLAT},

	[6477] = {315549, 10, "Versatile", 1, VERSATILITY, FLAT},
	[6478] = {315552, 15, "Versatile", 2, VERSATILITY, FLAT},
	[6479] = {315553, 20, "Versatile", 3, VERSATILITY, FLAT},

	[6493] = {315590, 17, "Siphoner", 1, LEECH, FLAT},
	[6494] = {315591, 28, "Siphoner", 2, LEECH, FLAT},
	[6495] = {315592, 45, "Siphoner", 3, LEECH, FLAT},

	[6437] = {315277, 10, "Strikethrough", 1, CRITICAL, MAGNITUDE},
	[6438] = {315281, 15, "Strikethrough", 2, CRITICAL, MAGNITUDE},
	[6439] = {315282, 20, "Strikethrough", 3, CRITICAL, MAGNITUDE},

	[6555] = {318266, 15, "RacingPulse", 1, HASTE, PROC},
	[6559] = {318492, 20, "RacingPulse", 2, HASTE, PROC},
	[6560] = {318496, 35, "RacingPulse", 3, HASTE, PROC},

	[6556] = {318268, 15, "DeadlyMomentum", 1, CRITICAL, PROC},
	[6561] = {318493, 20, "DeadlyMomentum", 2, CRITICAL, PROC},
	[6562] = {318497, 35, "DeadlyMomentum", 3, CRITICAL, PROC},

	[6558] = {318270, 15, "SurgingVitality", 1, VERSATILITY, PROC},
	[6565] = {318495, 20, "SurgingVitality", 2, VERSATILITY, PROC},
	[6566] = {318499, 35, "SurgingVitality", 3, VERSATILITY, PROC},

	[6557] = {318269, 15, "HonedMind", 1, MASTERY, PROC},
	[6563] = {318494, 20, "HonedMind", 2, MASTERY, PROC},
	[6564] = {318498, 35, "HonedMind", 3, MASTERY, PROC},

	[6549] = {318280, 25, "EchoingVoid", 1, AOE, PROC},
	[6550] = {318485, 35, "EchoingVoid", 2, AOE, PROC},
	[6551] = {318486, 60, "EchoingVoid", 3, AOE, PROC},

	[6552] = {318274, 20, "InfiniteStars", 1, DMG, PROC},
	[6553] = {318487, 50, "InfiniteStars", 2, DMG, PROC},
	[6554] = {318488, 75, "InfiniteStars", 3, DMG, PROC},

	[6547] = {318303, 12, "IneffableTruth", 1, COOLDOWN, PROC},
	[6548] = {318484, 30, "IneffableTruth", 2, COOLDOWN, PROC},

	[6537] = {318276, 25, "TwilightDevastation", 1, AOE, PROC},
	[6538] = {318477, 50, "TwilightDevastation", 2, AOE, PROC},
	[6539] = {318478, 75, "TwilightDevastation", 3, AOE, PROC},

	[6543] = {318481, 10, "TwistedAppendage", 1, DMG, PROC},
	[6544] = {318482, 35, "TwistedAppendage", 2, DMG, PROC},
	[6545] = {318483, 66, "TwistedAppendage", 3, DMG, PROC},

	[6540] = {318286, 15, "VoidRitual", 1, ALL_SECONDARIES, PROC},
	[6541] = {318479, 35, "VoidRitual", 2, ALL_SECONDARIES, PROC},
	[6542] = {318480, 66, "VoidRitual", 3, ALL_SECONDARIES, PROC},

	[6573] = {318272, 15, "GushingWound", 0, DMG, PROC},

	[6546] = {318239, 15, "GlimpseOfClarity", 0, COOLDOWN, PROC},

	[6571] = {318293, 30, "SearingFlames", 0, AOE, PROC},
	[6572] = {316651, 50, "ObsidianSkin", 0, AOE, PROC},
	[6567] = {318294, 35, "DevourVitality", 0, DMG, PROC},
	[6568] = {316780, 25, "WhisperedTruths", 0, COOLDOWN, PROC},
	[6570] = {318299, 20, "FlashOfInsight", 0, INTELLIGENCE, PROC},
	[6569] = {317290, 25, "LashOfTheVoid", 0, DMG, PROC},
}

local PRESERVED_CONTAMINANT = {
	[177970] = 6483, [177971] = 6484, [177972] = 6485, -- Avoidant
	[177973] = 6474, [177974] = 6475, [177975] = 6476, -- Expedient
	[177986] = 6471, [177987] = 6472, [177988] = 6473, -- Masterful
	[177992] = 6480, [177993] = 6481, [177994] = 6482, -- Severe
	[178010] = 6477, [178011] = 6478, [178012] = 6479, -- Versatile
	[177995] = 6493, [177996] = 6494, [177997] = 6495, -- Siphoner
	[177998] = 6437, [177999] = 6438, [178000] = 6439, -- Strikethrough
	[177989] = 6555, [177990] = 6559, [177991] = 6560, -- Racing Pulse
	[177955] = 6556, [177965] = 6561, [177966] = 6562, -- Deadly Momentum
	[178001] = 6558, [178002] = 6565, [178003] = 6566, -- Surging Vitality
	[177978] = 6557, [177979] = 6563, [177980] = 6564, -- Honed Mind
	[177967] = 6549, [177968] = 6550, [177969] = 6551, -- Echoing Void
	[177983] = 6552, [177984] = 6553, [177985] = 6554, -- Infinite Stars
	[177981] = 6547, [177982] = 6548, -- Ineffable Truth
	[178004] = 6537, [178005] = 6538, [178006] = 6539, -- Twilight Devastation
	[178007] = 6543, [178008] = 6544, [178009] = 6545, -- Twisted Appendage
	[178013] = 6540, [178013] = 6541, [178013] = 6542, -- Void Ritual
	[177977] = 6573, -- Gushing Wound
	[177976] = 6546, -- Glimpse of Clarity
}

local function ParseItemLink(link)
	local itemString = string.match(link, "item:[%-?%d:]+")
	if not itemString then return end

	local itemSplit = {}
	for v in string.gmatch(itemString, ":(%d*)") do
		table.insert(itemSplit, v and tonumber(v) or 0)
	end

	local itemId = itemSplit[1]
	local enchantId = itemSplit[2]
	local gemId = itemSplit[3]

	local bonuses = {}
	local numBonuses = itemSplit[13]
	for index = 1, numBonuses do
	  bonuses[itemSplit[13 + index]] = true
	end

	return itemId, enchantId, gemId, bonuses
end

function mod:Filter(slotData)
	local itemLink = GetContainerItemLink(slotData.bag, slotData.slot)
	if not itemLink then return end

	local itemId, _, _, bonusIds = ParseItemLink(itemLink)

	local bonusId = PRESERVED_CONTAMINANT[itemId]
	if bonusId then
		return self:GetSectionName(bonusId)
	end

	if bonusIds then
		for bonusId, _ in pairs(bonusIds) do
			if CORRUPTIONS[bonusId] then
				return self:GetSectionName(bonusId)
			end
		end
	end
end

function mod:GetSectionName(corruptionId)
	local corruption = self.corruptions[corruptionId]
	local splitBy = self.db.profile[corruption.name]

	if "corruption" == splitBy then return "|cffb685ff" .. corruption.displayName end
	if "byRank" == splitBy then return "|cffb685ff" .. corruption.displayName .. " " .. tonumber(corruption.rank) end

	return "|cffb685ff" .. L['Corruption Gear']
end

function mod:OnInitialize()
	self.corruptions = {}
	local profile = {}

	for corruptionId, corruptionProperties in pairs(CORRUPTIONS) do
		local name, _, icon = GetSpellInfo(corruptionProperties[1])

		local info = {
			name = corruptionProperties[3],
			displayName = name,
			icon = icon,
			spellId = corruptionProperties[1],
			rank = corruptionProperties[4],
			corruptionAmount = corruptionProperties[2],
		}
		self.corruptions[corruptionId] = info
		profile[info.name] = "corruption"
	end

	self.db = addon.db:RegisterNamespace(self.moduleName, { profile = profile })
end

function mod:GetOptions()
	local options = {}
	local order = 0

	for id, info in pairs(self.corruptions) do
		local splitableInto = {
			doNotSeparate = L['No Separate Section'],
			corruption = L['Separate Section'],
		}

		if info.rank then
			splitableInto.byRank = L['Separate Section per Rank']
		end

		order = order + 10

		options[info.name] = {
			name = info.displayName,
			desc = L['Select in which section to place this corruption'],
			type = 'select',
			values = splitableInto,
			order = order,
		}
	end

	local templatesForLater = {
		equippableOnly = {
			name = L['Only equippable items'],
			desc = L['Do not show level of items that cannot be equipped.'],
			type = 'toggle',
			order = 10,
		} and nil,
		colorScheme = {
			name = L['Color scheme'],
			desc = L['Which color scheme should be used for each stat?'],
			type = 'select',
			values = {
				none  = L['None'],
				gem   = L['Gem colors'],
			},
			order = 20,
		} and nil,
		minLevel = {
			name = L['Mininum level'],
			desc = L['Do not show for item levels under this threshold.'],
			type = 'range',
			min = 1,
			max = 1000,
			step = 1,
			bigStep = 10,
			order = 30,
		},
	}

	return options, addon:GetOptionHandler(self)
end