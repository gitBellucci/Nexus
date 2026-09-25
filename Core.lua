local ADDON, SBG = ...
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
