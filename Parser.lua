local ADDON, SBG = ...

local HBD = LibStub("HereBeDragons-2.0")

local function SplitArgs(args)
    local t = {}
    args = args or ""
    args = args:gsub("%s*,%s*", ",")
    for arg in string.gmatch(args, "[^,]+") do
        table.insert(t, arg)
    end
    return t
end

local lastZone

local function ResolveGoto(zone, x, y)
    local element = { arrow = true, parent = true, textOnly = true }
    if zone then
        lastZone = zone
    else
        zone = lastZone
    end
    if not zone then return end

    local subzone, continent = tostring(zone):match("^(.-)/(%d+)$")
    if subzone then
        local mapId = SBG.GetMapId(subzone) or tonumber(subzone)
        x = tonumber(x)
        y = tonumber(y)
        if not (mapId and x and y) then return end
        element.wx, element.wy = x, y
        element.zone = mapId
        element.instance = tonumber(continent)
        local zx, zy = HBD:GetZoneCoordinatesFromWorld(x, y, mapId)
        if zx and zy then
            element.x = zx * 100
            element.y = zy * 100
        end
        return element
    end

    local mapId, px, py = SBG.GetMapId(zone) or tonumber(zone), tonumber(x), tonumber(y)
    if not (mapId and px and py) then return end
    element.zone, element.x, element.y = mapId, px, py
    local wx, wy, instance = HBD:GetWorldCoordinatesFromZone(px / 100, py / 100, mapId)
    element.wx, element.wy, element.instance = wx, wy, instance
    return element
end

local tags = {}

tags["goto"] = function(_, text, zone, x, y, radius, optional)
    local element = ResolveGoto(zone, x, y)
    if not element then return end
    element.text = text
    element.radius = tonumber(radius)
    radius = element.radius
    if radius then
        if optional then
            if radius == 0 then
                element.lowPrio = true
                element.radius = nil
            elseif radius > 0 then
                element.hidePin = true
                element.parent = true
            end
        elseif radius > 0 then
            element.parent = nil
            element.textOnly = nil
        elseif radius == 0 then
            element.arrow = nil
            element.radius = nil
        end
    end
    return element
end

tags.accept = function(_, text, id)
    id = tonumber(id)
    if not id then return end
    return { questId = id, text = text, kind = "accept" }
end

tags.turnin = function(_, text, id)
    id = tonumber((tostring(id or ""):match("%d+")))
    if not id then return end
    return { questId = id, text = text, kind = "turnin" }
end

tags.complete = function(_, text, id, obj)
    id = tonumber(id)
    if not id then return end
    return { questId = id, objIndex = tonumber(obj) or 1, text = text, kind = "complete" }
end

local function UnitNames(...)
    local t = {}
    for i = 1, select("#", ...) do
        local s = select(i, ...)
        if s and s ~= "" then
            for part in string.gmatch(tostring(s), "[^;]+") do
                part = strtrim(part)
                if part:sub(1, 1) == "+" then part = part:sub(2) end
                if part ~= "" then table.insert(t, part) end
            end
        end
    end
    return t
end

tags.target = function(_, text, ...)
    local names = UnitNames(...)
    return { textOnly = true, kind = "target", targets = names, unitlist = names, targetName = names[1], text = text }
end

tags.unitscan = function(_, text, ...)
    local names = UnitNames(...)
    return { textOnly = true, kind = "unitscan", unitscan = names, unitlist = names, text = text }
end

tags.mob = function(_, text, ...)
    local names = UnitNames(...)
    return { textOnly = true, kind = "mob", mobs = names, unitlist = names, mobName = names[1], text = text }
end

tags.home = function(_, text)
    return { kind = "home", text = text }
end

tags.fly = function(_, text, dest)
    return { kind = "fly", dest = dest, text = text }
end

tags.hs = function(_, text)
    return { kind = "hs", text = text }
end

tags.zone = function(_, text, dest)
    return { kind = "zone", dest = dest or text, text = text }
end

tags.zoneskip = function(_, text, dest)
    return { kind = "zoneskip", dest = dest, textOnly = true, text = text }
end

tags.use = function(_, text, id)
    return { textOnly = true, itemId = tonumber(id), text = text }
end

tags.bindlocation = function(_, text, id, flag)
    return { kind = "bindlocation", areaId = tonumber(id), skipIfUnbound = tonumber(flag) == 1, textOnly = true, text = text }
end

tags.collect = function(_, text, id, count)
    return { kind = "collect", itemId = tonumber(id), count = tonumber(count) or 1, text = text }
end

tags.vendor = function(_, text)
    return { kind = "click", text = text or "Vendor trash" }
end

tags.train = function(_, text, spell)
    return { kind = "click", text = text, spellId = tonumber(spell) }
end

tags.fp = function(_, text, dest)
    return { kind = "click", dest = dest, text = text or ("Get the " .. (dest or "") .. " flight path") }
end

tags.xp = function(_, text)
    return { textOnly = true, text = text }
end

local ignored = {
    skipgossip = true, money = true, itemcount = true, itemStat = true,
    isQuestAvailable = true, isOnQuest = true, isQuestTurnedIn = true,
    subzone = true, aura = true, cast = true, deathskip = true,
    loop = true, label = true, requires = true, optional = true,
    season = true, xprate = true, completewith = true, sticky = true,
    softcore = true, hardcore = true, maxlevel = true, minlevel = true,
}

function SBG.ParseLine(line, step)
    line = line:gsub("^%s+", ""):gsub("%s+$", "")
    if line == "" or line:sub(1, 2) == "--" then return end

    local classtag = line:match("%s*<<%s*(.+)$")
    if classtag then
        line = line:gsub("%s*<<%s*(.+)$", "")
        if not SBG.Applies(classtag) then return end
    end

    local steptag, value = line:match("^#(%S+)%s*(.*)$")
    if steptag then
        if steptag == "completewith" then step.completewith = value end
        return
    end

    local text
    line = line:gsub("%s*>>%s*(.*)$", function(t)
        if t ~= "" then text = t end
        return ""
    end)
    line = strtrim(line)

    local element
    local tag, args = line:match("^%.(%S+)%s*(.*)$")
    if tag then
        if ignored[tag] then
            if tag == "zoneskip" then
                element = tags.zoneskip(line, text, unpack(SplitArgs(args)))
            end
        elseif tags[tag] then
            element = tags[tag](line, text, unpack(SplitArgs(args)))
            if element then element.tag = tag end
        elseif text then
            element = { kind = "click", text = text, tag = tag }
        end
    elseif line:sub(1, 1) == "+" then
        element = { kind = "click", text = line:sub(2) }
    elseif text then
        element = { text = text, textOnly = true }
    end

    if not element then return end
    element.step = step
    table.insert(step.elements, element)
    return element
end

function SBG.ParseGuide(content)
    if type(content) ~= "string" then return end
    content = content:gsub("%-%-[^\r\n]*", "")
    local guide = { steps = {} }
    local skipGuide, skipStep
    local current

    for raw in string.gmatch(content, "[^\n\r]+") do
        local line = strtrim(raw)
        if line:sub(1, 4) == "step" then
            local classtag = line:match("<<%s*(.+)")
            if classtag and not SBG.Applies(classtag) then
                skipStep = true
                current = nil
            else
                skipStep = false
                current = { elements = {}, index = #guide.steps + 1 }
                table.insert(guide.steps, current)
            end
        elseif not skipStep then
            if current then
                SBG.ParseLine(line, current)
            else
                local enabled = line:match("^<<%s*(.+)$")
                if enabled then
                    guide.enabledFor = enabled
                    if not SBG.Applies(enabled) then skipGuide = true end
                else
                    local tag, value = line:match("^#(%S+)%s*(.*)$")
                    if tag and value then
                        guide[tag] = strtrim(value)
                    end
                end
            end
        end
        if skipGuide then return end
    end

    guide.name = guide.name or "Untitled"
    guide.displayname = guide.displayname or guide.name
    guide.key = (guide.group or "SBG") .. "|" .. guide.name
    guide.icon = guide.icon ~= "" and guide.icon or "Interface\\Icons\\INV_Misc_Book_09"
    return guide
end
