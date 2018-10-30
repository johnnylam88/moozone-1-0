--[[--------------------------------------------------------------------
    Copyright (C) 2018 Johnny C. Lam.
    See the file LICENSE.txt for copying permission.
--]]--------------------------------------------------------------------

local MAJOR, MINOR = "MooZone-1.0", 1
assert(LibStub, MAJOR .. " requires LibStub")
assert(LibStub("CallbackHandler-1.0", true), MAJOR .. " requires CallbackHandler-1.0")
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

------------------------------------------------------------------------

local format = string.format
local next = next
local pairs = pairs
local setmetatable = setmetatable
local strfind = string.find
local strjoin = strjoin
local strmatch = string.match
local tonumber = tonumber
local tostring = tostring
local tostringall = tostringall
local type = type
local wipe = wipe
-- GLOBALS: _G
-- GLOBALS: GetAddOnMetadata
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local GREEN_FONT_COLOR_CODE = GREEN_FONT_COLOR_CODE
local NORMAL_FONT_COLOR_CODE = NORMAL_FONT_COLOR_CODE

--[[--------------------------------------------------------------------
    Debugging code from LibResInfo-1.0 by Phanx.
    https://github.com/Phanx/LibResInfo
--]]--------------------------------------------------------------------

local isAddon = GetAddOnMetadata(MAJOR, "Version")

local DEBUG_LEVEL = isAddon and 6 or 0
local DEBUG_FRAME = ChatFrame1

local function debug(level, text, ...)
	if level <= DEBUG_LEVEL then
		if ... then
			if type(text) == "string" and strfind(text, "%%[dfqsx%d%.]") then
				text = format(text, ...)
			else
				text = strjoin(" ", tostringall(text, ...))
			end
		else
			text = tostring(text)
		end
		DEBUG_FRAME:AddMessage(GREEN_FONT_COLOR_CODE .. MAJOR .. FONT_COLOR_CODE_CLOSE .. " " .. text)
	end
end

if isAddon then
	-- GLOBALS: SLASH_MOOZONE1
	-- GLOBALS: SlashCmdList
	SLASH_MOOZONE1 = "/moozone"
	SlashCmdList.MOOZONE = function(input)
		input = tostring(input or "")

		local CURRENT_CHAT_FRAME
		for i = 1, 10 do
			local cf = _G["ChatFrame"..i]
			if cf and cf:IsVisible() then
				CURRENT_CHAT_FRAME = cf
				break
			end
		end

		local of = DEBUG_FRAME
		DEBUG_FRAME = CURRENT_CHAT_FRAME

		if strmatch(input, "^%s*[0-9]%s*$") then
			local v = tonumber(input)
			debug(0, "Debug level set to", input)
			DEBUG_LEVEL = v
			DEBUG_FRAME = of
			return
		end

		local f = _G[input]
		if type(f) == "table" and type(f.AddMessage) == "function" then
			debug(0, "Debug frame set to", input)
			DEBUG_FRAME = f
			return
		end

		debug(0, "Version " .. MINOR .. " loaded. Usage:")
		debug(0, format("%s%s %s%s - change debug verbosity, valid range is 0-6",
			NORMAL_FONT_COLOR_CODE, SLASH_MOOZONE1, DEBUG_LEVEL, FONT_COLOR_CODE_CLOSE))
		debug(0, format("%s%s %s%s -- change debug output frame",
			NORMAL_FONT_COLOR_CODE, SLASH_MOOZONE1, of:GetName(), FONT_COLOR_CODE_CLOSE))

		DEBUG_FRAME = of
	end
end

------------------------------------------------------------------------

lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
lib.callbacksInUse = lib.callbacksInUse or {}

local eventFrame = lib.eventFrame or CreateFrame("Frame")
lib.eventFrame = eventFrame
eventFrame:UnregisterAllEvents()

eventFrame:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self, event, ...)
end)

function lib.callbacks:OnUsed(lib, callback)
	if not next(lib.callbacksInUse) then
		debug(1, "Callbacks in use! Starting up...")
		eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	end
	lib.callbacksInUse[callback] = true
end

function lib.callbacks:OnUnused(lib, callback)
	lib.callbacksInUse[callback] = nil
	if not next(lib.callbacksInUse) then
		debug(1, "No callbacks in use. Shutting down...")
		eventFrame:UnregisterAllEvents()
	end
end

------------------------------------------------------------------------

-- Localized names for every possible zone type.
local zoneNames = lib.zoneNames or {}
lib.zoneNames = zoneNames
do
	zoneNames.world = _G.CHANNEL_CATEGORY_WORLD
	zoneNames.arena = _G.ARENA
	zoneNames.battleground = _G.BATTLEFIELDS
	zoneNames.dungeon = _G.CALENDAR_TYPE_DUNGEON
	zoneNames.raid = _G.RAID
	zoneNames.scenario = _G.SCENARIOS
	zoneNames.lfg_dungeon = _G.LOOKING_FOR_DUNGEON
	zoneNames.lfg_raid = _G.RAID_FINDER
end

function lib:GetLocalizedZone(zone)
	return zoneNames[zone] or zone
end

function lib:ZoneIterator()
	return pairs(zoneNames)
end

------------------------------------------------------------------------

-- GLOBALS: IsInGroup
-- GLOBALS: IsInInstance
-- GLOBALS: IsInRaid
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE

local zone = "world"

function lib:GetZone()
	return zone
end

local function UpdateZone(self, event)
	local newZone
	if IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
		newZone = "lfg_raid"
	elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		newZone = "lfg_dungeon"
	else
		-- instanceType is "arena", "none", "party", "pvp", "raid", or "scenario".
		local _, instanceType = IsInInstance()
		if instanceType == "arena" then
			newZone = "arena"
		elseif instanceType == "party" then
			newZone = "dungeon"
		elseif instanceType == "pvp" then
			newZone = "battleground"
		elseif instanceType == "scenario" then
			newZone = "scenario"
		elseif IsInRaid() then
			newZone = "raid"
		else
			newZone = "world"
		end
	end
	if zone ~= newZone then
		debug(3, "UpdateZone", event, zone, newZone)
		lib.callbacks:Fire("MooZone_ZoneChanged", zone, newZone)
		zone = newZone
	end
end

eventFrame.PLAYER_ENTERING_WORLD = UpdateZone
eventFrame.ZONE_CHANGED_NEW_AREA = UpdateZone