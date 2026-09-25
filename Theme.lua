local ADDON, SBG = ...

SBG.Defaults = {
    theme = "blue",
    scale = 1,
    opacity = 1,
    fontSize = 9,
    arrowSize = 32,
    arrowScale = 1,
    showArrow = true,
    showPin = true,
    showMinimapButton = true,
    showNext = true,
    lockFrames = false,
    autoAdvance = true,
    enableTargetMacro = true,
    enableTargetMarking = true,
    enableMobMarking = true,
    enableEnemyMarking = true,
    enableFriendlyTargeting = true,
    enableEnemyTargeting = true,
    notifyOnTargetUpdates = true,
    windowW = 235,
    windowH = 125,
    autoHeight = false,
}

-- Palettes match RXP Blue / Red / Gold / DarkMode / Green (Sweat names).
SBG.Themes = {
    blue = {
        name = "Sweat Blue",
        bg = { 12 / 255, 12 / 255, 27 / 255 },
        bar = { 18 / 255, 18 / 255, 40 / 255 },
        hover = { 54 / 255, 62 / 255, 109 / 255 },
        border = { 22 / 255, 22 / 255, 44 / 255 },
        accent = { 140 / 255, 155 / 255, 255 / 255 },
        text = { 1, 1, 1 },
        muted = { 0.70, 0.72, 0.82 },
        body = { 1, 1, 1 },
    },
    red = {
        name = "Sweat Red",
        bg = { 19 / 255, 0, 0 },
        bar = { 31 / 255, 0, 0 },
        hover = { 81 / 255, 0, 0 },
        border = { 81 / 255, 0, 0 },
        accent = { 0.90, 0.20, 0.18 },
        text = { 1, 1, 1 },
        muted = { 0.80, 0.60, 0.60 },
        body = { 1, 1, 1 },
    },
    gold = {
        name = "Sweat Gold",
        bg = { 32 / 255, 18 / 255, 0 },
        bar = { 48 / 255, 27 / 255, 0 },
        hover = { 125 / 255, 71 / 255, 0 },
        border = { 125 / 255, 71 / 255, 0 },
        accent = { 0.95, 0.75, 0.20 },
        text = { 1, 1, 1 },
        muted = { 0.80, 0.70, 0.45 },
        body = { 1, 1, 1 },
    },
    dark = {
        name = "Dark Mode",
        bg = { 14 / 255, 14 / 255, 14 / 255 },
        bar = { 19 / 255, 19 / 255, 19 / 255 },
        hover = { 0.35, 0.35, 0.38 },
        border = { 0.35, 0.35, 0.38 },
        accent = { 0.85, 0.85, 0.88 },
        text = { 1, 1, 1 },
        muted = { 0.65, 0.65, 0.68 },
        body = { 1, 1, 1 },
    },
    green = {
        name = "Sweat Green",
        bg = { 6 / 255, 23 / 255, 12 / 255 },
        bar = { 9 / 255, 34 / 255, 17 / 255 },
        hover = { 4 / 255, 113 / 255, 65 / 255 },
        border = { 4 / 255, 113 / 255, 65 / 255 },
        accent = { 0 / 255, 203 / 255, 66 / 255 },
        text = { 1, 1, 1 },
        muted = { 0.55, 0.75, 0.60 },
        body = { 1, 1, 1 },
    },
}

function SBG.EnsureDB()
    SBGDB = SBGDB or {}
    SBGDB.profiles = SBGDB.profiles or {}
    SBGDB.currentProfile = SBGDB.currentProfile or "Default"
    if not SBGDB.profiles[SBGDB.currentProfile] then
        SBGDB.profiles[SBGDB.currentProfile] = {}
    end
    local s = SBGDB.profiles[SBGDB.currentProfile]
    for k, v in pairs(SBG.Defaults) do
        if s[k] == nil then s[k] = v end
    end
    -- Old custom overlay themes (crimson / color squares) → Sweat Blue once.
    if not s.themeMigrated then
        local remap = { crimson = true, ivory = true, midnight = true, forest = true, red = true, gold = true, dark = true, green = true }
        if remap[s.theme] or not SBG.Themes[s.theme] then
            s.theme = "blue"
        end
        s.themeMigrated = true
    end
    if not SBG.Themes[s.theme] then s.theme = "blue" end
    if (s.windowW == 360 and s.windowH == 420) or (s.windowW == 340 and s.windowH == 220) or (s.windowW == 260 and s.windowH == 200) then
        s.windowW = 235
        s.windowH = 160
    end
    if s.arrowSize == 28 or s.arrowSize == 56 then
        s.arrowSize = 32
        s.arrowScale = 1
    end
    if not s.arrowScale then s.arrowScale = 1 end
    SBGPC = SBGPC or {}
    SBGPC.stepIndex = SBGPC.stepIndex or 1
    return s
end

function SBG.GetSettings()
    return SBG.EnsureDB()
end

function SBG.Theme()
    local s = SBG.GetSettings()
    return SBG.Themes[s.theme] or SBG.Themes.blue
end

function SBG.Font()
    local path = GameFontNormal:GetFont()
    return path or "Fonts\\FRIZQT__.TTF"
end

function SBG.MakeText(parent, template)
    return parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
end

-- RXP uses an 8px decorative edge. Recreate the thickness without their texture.
local CHROME = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true,
    tileSize = 8,
    edgeSize = 8,
    insets = { left = 4, right = 2, top = 2, bottom = 4 },
}

local function HideOldEdges(frame)
    if frame.edgeT then frame.edgeT:Hide() end
    if frame.edgeB then frame.edgeB:Hide() end
    if frame.edgeL then frame.edgeL:Hide() end
    if frame.edgeR then frame.edgeR:Hide() end
end

function SBG.Paint(frame, alpha, which)
    local t = SBG.Theme()
    local s = SBG.GetSettings()
    local a = alpha or s.opacity or 1
    HideOldEdges(frame)

    if which == "clear" then
        if frame.SetBackdrop then frame:SetBackdrop(nil) end
        if frame.bg then
            frame.bg:SetColorTexture(0, 0, 0, 0)
            frame.bg:Hide()
        end
        return
    end

    local c = t.bg
    if which == "bar" then c = t.bar end
    if which == "hover" then c = t.hover end

    -- List rows / highlights: color only, no extra box.
    if which == "bar" or which == "hover" then
        if frame.SetBackdrop then frame:SetBackdrop(nil) end
        SBG.Fill(frame, c, a)
        if frame.bg then frame.bg:Show() end
        return
    end

    if frame.SetBackdrop then
        frame:SetBackdrop(CHROME)
        frame:SetBackdropColor(c[1], c[2], c[3], a)
        local b = t.border or t.bg
        frame:SetBackdropBorderColor(b[1], b[2], b[3], 1)
        if frame.bg then
            frame.bg:SetColorTexture(0, 0, 0, 0)
            frame.bg:Hide()
        end
    else
        SBG.Fill(frame, c, a)
        if frame.bg then frame.bg:Show() end
    end
end

function SBG.ColorSet(fs, which)
    local t = SBG.Theme()
    local c = t[which] or t.text
    fs:SetTextColor(c[1], c[2], c[3], 1)
end

function SBG.ApplyAll()
    if SBG.UI and SBG.UI.Apply then SBG.UI:Apply() end
    if SBG.Arrow and SBG.Arrow.Apply then SBG.Arrow:Apply() end
    if SBG.Pins and SBG.Pins.Apply then SBG.Pins:Apply() end
    if SBG.Menu and SBG.Menu.Apply then SBG.Menu:Apply() end
    if SBG.Options and SBG.Options.Apply then SBG.Options:Apply() end
    if SBG.Targeting and SBG.Targeting.Apply then SBG.Targeting:Apply() end
end

function SBG.OpenCoords(el)
    if not el or not el.x or not el.y then return end
    local text = string.format("%.1f, %.1f", el.x, el.y)
    if IsShiftKeyDown() then
        local eb = ChatEdit_GetActiveWindow and ChatEdit_GetActiveWindow()
        if not eb and ChatFrame1EditBox then
            ChatEdit_ActivateChat(ChatFrame1EditBox)
            eb = ChatFrame1EditBox
        end
        if eb then eb:Insert(text) end
        return
    end
    pcall(function()
        if C_Map and C_Map.SetUserWaypoint and UiMapPoint and el.zone then
            C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(el.zone, el.x / 100, el.y / 100))
            if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
                C_SuperTrack.SetSuperTrackedUserWaypoint(true)
            end
        end
    end)
    pcall(function()
        if el.zone then
            ShowUIPanel(WorldMapFrame)
            if WorldMapFrame and WorldMapFrame.SetMapID then
                WorldMapFrame:SetMapID(el.zone)
            end
        end
    end)
    SBG.Print(text)
end
