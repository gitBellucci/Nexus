local ADDON, SBG = ...
_G.SwetBetaGuide = SBG
_G.Nexus = SBG
_G.SBG = SBG

SBG.name = ADDON
SBG.guides = {}
SBG.guideByKey = {}
SBG.events = CreateFrame("Frame")

local CLASS_FILE, CLASS_NAME = UnitClass("player")
SBG.player = {
    class = CLASS_FILE,
    className = CLASS_NAME,
    race = select(2, UnitRace("player")),
    faction = UnitFactionGroup("player"),
    locale = GetLocale(),
}

local function RefreshPlayer()
    local classFile, className = UnitClass("player")
    if classFile and classFile ~= "" then
        SBG.player.class = classFile
        SBG.player.className = className
    end
    local _, race = UnitRace("player")
    if race and race ~= "" then
        SBG.player.race = race
    end
    local faction = UnitFactionGroup("player")
    if faction and faction ~= "" then
        SBG.player.faction = faction
    end
    SBG.player.locale = GetLocale()
end
SBG.RefreshPlayer = RefreshPlayer

SBG.GOLD = { 0.91, 0.72, 0.29, 1 }
SBG.INK = { 0.93, 0.90, 0.82, 1 }

function SBG.Print(...)
    DEFAULT_CHAT_FRAME:AddMessage("|cffc9a227Nexus|r: " .. tostring(...))
end

function SBG.Applies(text)
    if not text or text == "" then return true end
    if not SBG.player.faction then RefreshPlayer() end
    local class = SBG.player.class
    local race = SBG.player.race
    local faction = SBG.player.faction
    local level = UnitLevel("player") or 1
    local isMatch = false
    for group in string.gmatch(text, "[^/]+") do
        local ok = true
        for token in string.gmatch(group, "!?[%w]+") do
            local negate = false
            if token:sub(1, 1) == "!" then
                token = token:sub(2)
                negate = true
            end
            if token == "Undead" then token = "Scourge" end
            local upper = string.upper(token)
            local hit = upper == class or token == race or token == faction or (tonumber(token) and level >= tonumber(token))
            if (not hit) ~= negate then
                ok = false
                break
            end
        end
        if ok then
            isMatch = true
            break
        end
    end
    return isMatch
end

function SBG.ColorText(text)
    if not text then return "" end
    text = text:gsub("|cRXP_FRIENDLY_", "|cff00FF25")
    text = text:gsub("|cRXP_ENEMY_", "|cffFF5722")
    text = text:gsub("|cRXP_LOOT_", "|cff00BCD4")
    text = text:gsub("|cRXP_WARN_", "|cffFCDC00")
    text = text:gsub("|cRXP_PICK_", "|cffDB2EEF")
    text = text:gsub("|cRXP_BUY_", "|cff0E8312")
    return text
end

function SBG.StripTextures(text)
    if not text then return "" end
    return text:gsub("|T.-|t", "")
end

function SBG.RegisterGuide(content)
    local guide = SBG.ParseGuide(content)
    if not guide then return end
    if guide.enabledFor and not SBG.Applies(guide.enabledFor) then
        guide.locked = true
        guide.lockedReason = "Requires " .. guide.enabledFor
    else
        guide.locked = false
    end
    table.insert(SBG.guides, guide)
    SBG.guideByKey[guide.key] = guide
end

local function After(sec, fn)
    if C_Timer and C_Timer.After then
        C_Timer.After(sec, fn)
        return
    end
    local holder = CreateFrame("Frame")
    local acc = 0
    holder:SetScript("OnUpdate", function(self, elapsed)
        acc = acc + elapsed
        if acc >= sec then
            self:SetScript("OnUpdate", nil)
            fn()
        end
    end)
end

local function Dispatch(event, ...)
    if SBG.Engine and SBG.Engine.OnEvent then
        SBG.Engine:OnEvent(event, ...)
    end
    if event == "ADDON_LOADED" then
        local name = ...
        if name ~= ADDON then return end
        RefreshPlayer()
        SBG.EnsureDB()
        if SBG.UI then SBG.UI:Init() end
        if SBG.Arrow then SBG.Arrow:Init() end
        if SBG.Pins then SBG.Pins:Init() end
        if SBG.Menu then SBG.Menu:Init() end
        if SBG.Options then SBG.Options:Init() end
        if SBG.Targeting then SBG.Targeting:Init() end
        SBG.ApplyAll()
        SBG.ready = true
        SBG.Print("Type |cffe8b84a/nexus|r to open guides.")
    elseif event == "PLAYER_LOGIN" then
        RefreshPlayer()
        local key = SBGPC.guideKey
        if key and not SBG.guideByKey[key] then
            for _, g in ipairs(SBG.guides) do
                if not g.locked and g.name and key:find(g.name, 1, true) then
                    key = g.key
                    SBGPC.guideKey = key
                    break
                end
            end
        end
        if key and SBG.guideByKey[key] and not SBG.guideByKey[key].locked then
            SBG.Engine:Load(key, SBGPC.stepIndex or 1)
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        if SBG.welcomeTried then return end
        SBG.welcomeTried = true
        local key = SBGPC.guideKey
        if key and SBG.guideByKey[key] and not SBG.guideByKey[key].locked then return end
        After(1.25, function()
            local k = SBGPC.guideKey
            if k and SBG.guideByKey[k] and not SBG.guideByKey[k].locked then return end
            if SBG.Menu and SBG.Menu.ShowWelcome then SBG.Menu:ShowWelcome() end
        end)
    end
end

SBG.events:SetScript("OnEvent", function(_, event, ...)
    Dispatch(event, ...)
end)
SBG.events:RegisterEvent("ADDON_LOADED")
SBG.events:RegisterEvent("PLAYER_LOGIN")
SBG.events:RegisterEvent("PLAYER_ENTERING_WORLD")
SBG.events:RegisterEvent("QUEST_ACCEPTED")
SBG.events:RegisterEvent("QUEST_TURNED_IN")
SBG.events:RegisterEvent("QUEST_LOG_UPDATE")
SBG.events:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
SBG.events:RegisterEvent("ZONE_CHANGED")
SBG.events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
SBG.events:RegisterEvent("ZONE_CHANGED_INDOORS")
SBG.events:RegisterEvent("BAG_UPDATE_DELAYED")
SBG.events:RegisterEvent("PLAYER_LEVEL_UP")
pcall(function() SBG.events:RegisterEvent("HEARTHSTONE_BOUND") end)

SLASH_NEXUS1 = "/nexus"
SlashCmdList["NEXUS"] = function(msg)
    msg = strtrim(msg or ""):lower()
    if msg == "hide" or msg == "show" then
        if SBG.UI then SBG.UI:Toggle() end
    elseif msg == "reset" then
        if SBG.Engine then SBG.Engine:SetStep(1) end
    elseif msg == "opt" or msg == "options" or msg == "config" then
        if SBG.Options then SBG.Options:Toggle() end
    elseif msg == "arrow" then
        if SBG.Arrow then SBG.Arrow:Reset() end
        SBG.Print("Waypoint arrow restored.")
    else
        if SBG.Menu then SBG.Menu:Toggle() end
    end
end
