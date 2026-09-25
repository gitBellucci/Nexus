local ADDON, SBG = ...

SBG.mapId = {
    ["Durotar"] = 1411,
    ["Mulgore"] = 1412,
    ["The Barrens"] = 1413,
    ["Kalimdor"] = 1414,
    ["Eastern Kingdoms"] = 1415,
    ["Alterac Mountains"] = 1416,
    ["Arathi Highlands"] = 1417,
    ["Badlands"] = 1418,
    ["Blasted Lands"] = 1419,
    ["Tirisfal Glades"] = 1420,
    ["Silverpine Forest"] = 1421,
    ["Western Plaguelands"] = 1422,
    ["Eastern Plaguelands"] = 1423,
    ["Hillsbrad Foothills"] = 1424,
    ["The Hinterlands"] = 1425,
    ["Dun Morogh"] = 1426,
    ["Searing Gorge"] = 1427,
    ["Burning Steppes"] = 1428,
    ["Elwynn Forest"] = 1429,
    ["Deadwind Pass"] = 1430,
    ["Duskwood"] = 1431,
    ["Loch Modan"] = 1432,
    ["Redridge Mountains"] = 1433,
    ["Stranglethorn Vale"] = 1434,
    ["Swamp of Sorrows"] = 1435,
    ["Westfall"] = 1436,
    ["Wetlands"] = 1437,
    ["Teldrassil"] = 1438,
    ["Darkshore"] = 1439,
    ["Ashenvale"] = 1440,
    ["Thousand Needles"] = 1441,
    ["Stonetalon Mountains"] = 1442,
    ["Desolace"] = 1443,
    ["Feralas"] = 1444,
    ["Dustwallow Marsh"] = 1445,
    ["Tanaris"] = 1446,
    ["Azshara"] = 1447,
    ["Felwood"] = 1448,
    ["Un'Goro Crater"] = 1449,
    ["Moonglade"] = 1450,
    ["Silithus"] = 1451,
    ["Winterspring"] = 1452,
    ["Stormwind City"] = 1453,
    ["Orgrimmar"] = 1454,
    ["Ironforge"] = 1455,
    ["Thunder Bluff"] = 1456,
    ["Darnassus"] = 1457,
    ["Undercity"] = 1458,
}

SBG.mapName = {}
for name, id in pairs(SBG.mapId) do
    SBG.mapName[id] = name
end

SBG.subzoneMapId = {
    ["Thelsamar"] = 1432,
    ["Menethil Harbor"] = 1437,
    ["Auberdine"] = 1439,
    ["Astranaar"] = 1440,
    ["Crossroads"] = 1413,
    ["Ratchet"] = 1413,
    ["Brill"] = 1420,
    ["Grom'gol"] = 1434,
}
for name, id in pairs(SBG.subzoneMapId) do
    SBG.mapId[name] = id
end

SBG.bindNames = {
    [380] = { "crossroads", "croisée", "la croisée", "the crossroads" },
    [362] = { "razor hill", "tranchecolline" },
    [16509] = { "stormwind", "hurlevent" },
}

function SBG.GetMapId(zone)
    if not zone then return end
    return SBG.mapId[zone] or tonumber(zone)
end

function SBG.CurrentMapId()
    if C_Map and C_Map.GetBestMapForUnit then
        return C_Map.GetBestMapForUnit("player")
    end
end

function SBG.InZone(zoneList)
    local current = SBG.CurrentMapId()
    if not current or not zoneList then return false end
    for name in string.gmatch(zoneList, "[^/]+") do
        name = strtrim(name)
        local id = SBG.GetMapId(name)
        if id and current == id then return true end
        if SBG.mapName[current] and SBG.mapName[current]:lower() == name:lower() then
            return true
        end
    end
    return false
end

function SBG.IsBoundTo(areaId)
    local bind = string.lower(GetBindLocation() or "")
    local names = SBG.bindNames[tonumber(areaId)]
    if not names then return bind ~= "" end
    for _, n in ipairs(names) do
        if bind:find(n, 1, true) then return true end
    end
    return false
end
