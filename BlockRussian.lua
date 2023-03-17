local BR_EVENTS = {
	"CHAT_MSG_SAY",
	"CHAT_MSG_YELL",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_TEXT_EMOTE",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
}

local BR_UKRAINIAN_CHARS = {
    "Є",
    "є",
    "І",
    "і",
    "Ї",
    "ї",
    "Ґ",
    "ґ",
}

local BR_RUSSIAN_CHARS = {
    "ё",
	"Ё",
    "ы",
    "Ы",
    "э",
    "ъ",
    "Э",
    "Ъ",
}

local BR_UKRAINIAN_TOP_WORDS = {
	"що",
	"як",
	"його",
	"йому",
	"це",
	"вже",
	"був",
	"щоб",
	"також",
	"ще",
	"року",
	"якщо",
	"щодо",
	"вони",
	"або",
	"було",
	"була",
	"може",
	"бути",
	"бувший",
	"якого",
	"тому",
	"краще",
	"саме",
	"вона",
	"можуть",
	"роки",
	"такий",
	"дуже",
	"знову",
	"всього",
	"зробити",
	"були",
	"сказав",
	"важливо",
	"коли",
	"знов",
	"хоча",
	"кожен",
	"треба",
	"годин",
	"життя",
	"мати",
	"сказав",
	"батько",
	"ти",
	"ми"
}

local BR_GMATCH = string.gmatch or string.gfind

-- check if table contains value
local function BR_has_value (table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end

    return false
end

-- check if a message might be ukrainian language
local function BR_is_ukrainian(message)
	local cleaned_message = string.gsub(message, '[%p%c]', '')

	for _, character in ipairs(BR_UKRAINIAN_CHARS) do
		if string.find(cleaned_message, character) then
			return true
		end
	end

	for word in BR_GMATCH(cleaned_message, "%S+") do
		for _, character in ipairs(BR_UKRAINIAN_TOP_WORDS) do
			if string.lower(word) == character then
				return true
			end
		end
	end

	return false
end


-- check if a message might be russian language
local function BR_is_russian(message)
	local cleaned_message = string.gsub(message, '[%p%c]', '')

	for _, character in ipairs(BR_RUSSIAN_CHARS) do
		if string.find(cleaned_message, character) then
			return true
		end
	end

	return false
end

-- check if a message containts only latin characters
local function containsOnlyLatinCharacters(message)
    message = string.gsub(message, '[%p%c%s%d]', '')
    return not BR_GMATCH(message, "[^%a]")
end

local oldChatFrame_OnEvent = ChatFrame_OnEvent

-- Custom chat event handler function
-- Filter out messages on russian language
function BR_ChatFrame_OnEvent(event)
	if BR_has_value(BR_EVENTS, event) then
		---@diagnostic disable-next-line: undefined-global
		local message = arg1

		if containsOnlyLatinCharacters(message) or BR_is_ukrainian(message) then
			return oldChatFrame_OnEvent(event)
		end

		if BR_is_russian(message) then
			return true
		end

		if strfind(message, "[\208]") and not BR_is_ukrainian(message) then
			return true
		end
	end
	-- Call the original ChatFrame_OnEvent function to handle the event normally
	oldChatFrame_OnEvent(event)
end

-- Hook custom handler into the core one
ChatFrame_OnEvent = BR_ChatFrame_OnEvent