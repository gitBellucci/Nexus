local ADDON, SBG = ...

SBG.Defaults = {
    theme = "dark",
    scale = 1,
    opacity = 1,
    fontSize = 11,
    titleSize = 12,
    headerSize = 13,
    fontOutline = true,
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
    windowW = 248,
    windowH = 180,
    autoHeight = false,
}

-- Themes tint the shared liquid-glass art (veil / edges / accents). Texture stays the same.
SBG.Themes = {
    blue = {
        name = "Nexus Blue",
        bg = { 0.05, 0.06, 0.10 },
        bar = { 0.08, 0.09, 0.14 },
        hover = { 0.22, 0.32, 0.55 },
        border = { 0.55, 0.68, 0.95 },
        accent = { 0.62, 0.78, 1.00 },
        text = { 0.96, 0.97, 1.00 },
        muted = { 0.68, 0.72, 0.82 },
        body = { 0.92, 0.93, 0.96 },
        tint = { 0.06, 0.10, 0.22 },
        tintA = 0.58,
        title = { 0.70, 0.82, 1.00 },
    },
    red = {
        name = "Nexus Red",
        bg = { 0.08, 0.02, 0.02 },
        bar = { 0.12, 0.04, 0.04 },
        hover = { 0.48, 0.14, 0.12 },
        border = { 0.90, 0.38, 0.32 },
        accent = { 0.98, 0.42, 0.36 },
        text = { 1.00, 0.96, 0.96 },
        muted = { 0.80, 0.62, 0.60 },
        body = { 0.96, 0.92, 0.92 },
        tint = { 0.22, 0.04, 0.04 },
        tintA = 0.60,
        title = { 1.00, 0.55, 0.42 },
    },
    gold = {
        name = "Nexus Gold",
        bg = { 0.08, 0.05, 0.01 },
        bar = { 0.12, 0.08, 0.02 },
        hover = { 0.45, 0.30, 0.08 },
        border = { 0.92, 0.74, 0.28 },
        accent = { 0.98, 0.82, 0.32 },
        text = { 1.00, 0.97, 0.90 },
        muted = { 0.80, 0.72, 0.50 },
        body = { 0.96, 0.93, 0.86 },
        tint = { 0.18, 0.12, 0.02 },
        tintA = 0.58,
        title = { 1.00, 0.85, 0.35 },
    },
    dark = {
        name = "Dark Mode",
        bg = { 0.05, 0.05, 0.05 },
        bar = { 0.10, 0.10, 0.10 },
        hover = { 0.30, 0.30, 0.32 },
        border = { 0.62, 0.62, 0.66 },
        accent = { 0.90, 0.90, 0.92 },
        text = { 0.96, 0.96, 0.97 },
        muted = { 0.62, 0.62, 0.66 },
        body = { 0.90, 0.90, 0.92 },
        tint = { 0.04, 0.04, 0.05 },
        tintA = 0.68,
        title = { 0.92, 0.92, 0.94 },
    },
    green = {
        name = "Nexus Green",
        bg = { 0.02, 0.07, 0.04 },
        bar = { 0.04, 0.10, 0.06 },
        hover = { 0.08, 0.36, 0.20 },
        border = { 0.28, 0.80, 0.48 },
        accent = { 0.35, 0.92, 0.52 },
        text = { 0.94, 1.00, 0.96 },
        muted = { 0.55, 0.74, 0.62 },
        body = { 0.90, 0.96, 0.92 },
        tint = { 0.03, 0.14, 0.07 },
        tintA = 0.58,
        title = { 0.45, 0.95, 0.58 },
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
    if not s.themeMigrated then
        local remap = { crimson = true, ivory = true, midnight = true, forest = true }
        if remap[s.theme] or not SBG.Themes[s.theme] then
            s.theme = "blue"
        end
        s.themeMigrated = true
    end
    if not SBG.Themes[s.theme] then s.theme = "blue" end
    if (s.windowW == 360 and s.windowH == 420) or (s.windowW == 340 and s.windowH == 220)
        or (s.windowW == 260 and s.windowH == 200) or (s.windowW == 235 and s.windowH == 125)
        or (s.windowW == 248 and s.windowH == 280) then
        s.windowW = 248
        s.windowH = 180
    end
    if s.arrowSize == 28 or s.arrowSize == 56 then
        s.arrowSize = 32
        s.arrowScale = 1
    end
    if not s.arrowScale then s.arrowScale = 1 end
    if s.fontSize and s.fontSize < 9 then s.fontSize = 11 end
    if not s.titleSize then s.titleSize = SBG.Defaults.titleSize end
    if not s.headerSize then s.headerSize = SBG.Defaults.headerSize end
    if s.fontOutline == nil then s.fontOutline = true end
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

function SBG.FontFlags()
    local s = SBG.GetSettings()
    return s.fontOutline and "OUTLINE" or ""
end

function SBG.MakeText(parent, template)
    return parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
end

SBG.GLASS_TEX = "Interface\\AddOns\\SwetBetaGuide\\Media\\glass"
SBG.GLASS_CHIP = "Interface\\AddOns\\SwetBetaGuide\\Media\\glasschip"
SBG.GLASS_PILL = "Interface\\AddOns\\SwetBetaGuide\\Media\\glasspill"
SBG.ICON_TEX = "Interface\\AddOns\\SwetBetaGuide\\Textures\\icon"

-- Rounded liquid-glass bar (header / chips). Transparent corners = soft round look.
function SBG.StyleGlassChip(frame, which)
    if not frame then return end
    which = which or "chip"
    local t = SBG.Theme()
    if frame.SetBackdrop then frame:SetBackdrop(nil) end
    if frame.bg then frame.bg:Hide() end
    if frame.glassBg then frame.glassBg:Hide() end
    if frame.glassVeil then frame.glassVeil:Hide() end
    if frame.glassSheen then frame.glassSheen:Hide() end
    if frame.glassEdgeT then
        frame.glassEdgeT:Hide(); frame.glassEdgeB:Hide()
        frame.glassEdgeL:Hide(); frame.glassEdgeR:Hide()
    end

    if not frame.chipBg then
        local tex = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
        tex:SetAllPoints()
        frame.chipBg = tex
        local veil = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
        veil:SetPoint("TOPLEFT", 4, -2)
        veil:SetPoint("BOTTOMRIGHT", -4, 2)
        frame.chipVeil = veil
        local sheen = frame:CreateTexture(nil, "BORDER")
        sheen:SetPoint("TOPLEFT", 10, -2)
        sheen:SetPoint("TOPRIGHT", -10, -2)
        sheen:SetHeight(10)
        frame.chipSheen = sheen
    end
    local path = (which == "pill") and SBG.GLASS_PILL or SBG.GLASS_CHIP
    frame.chipBg:SetTexture(path)
    frame.chipBg:SetTexCoord(0.02, 0.98, 0.08, 0.92)
    frame.chipBg:Show()
    local tint = t.tint or { 0.03, 0.04, 0.07 }
    if frame.chipVeil then
        frame.chipVeil:SetColorTexture(tint[1], tint[2], tint[3], 0.42)
        frame.chipVeil:Show()
    end
    if frame.chipSheen then
        local ac = t.accent or { 1, 1, 1 }
        frame.chipSheen:SetColorTexture(ac[1], ac[2], ac[3], 0.16)
        frame.chipSheen:Show()
    end
end

function SBG.ClearGlassChip(frame)
    if not frame then return end
    if frame.chipBg then frame.chipBg:Hide() end
    if frame.chipVeil then frame.chipVeil:Hide() end
    if frame.chipSheen then frame.chipSheen:Hide() end
end

-- Compact liquid-glass text button (Options / Close / Reset).
function SBG.MakeGlassButton(parent, text, w, h, onClick)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(w or 80, h or 24)
    SBG.StyleGlassChip(b, "pill")
    b.label = SBG.MakeText(b, "GameFontNormalSmall")
    b.label:SetPoint("CENTER", 0, 0)
    b.label:SetText(text or "")
    local function paintIdle(self)
        local t = SBG.Theme()
        local tint = t.tint or { 0.03, 0.04, 0.07 }
        if self.chipVeil then self.chipVeil:SetColorTexture(tint[1], tint[2], tint[3], 0.42) end
        if self.chipSheen then
            local ac = t.accent
            self.chipSheen:SetColorTexture(ac[1], ac[2], ac[3], 0.16)
        end
        self.label:SetTextColor(t.text[1], t.text[2], t.text[3])
    end
    paintIdle(b)
    b:SetScript("OnEnter", function(self)
        local t = SBG.Theme()
        local hov = t.hover
        if self.chipVeil then self.chipVeil:SetColorTexture(hov[1], hov[2], hov[3], 0.45) end
        if self.chipSheen then
            local ac = t.accent
            self.chipSheen:SetColorTexture(ac[1], ac[2], ac[3], 0.28)
        end
        self.label:SetTextColor(1, 1, 1)
    end)
    b:SetScript("OnLeave", paintIdle)
    b:SetScript("OnClick", function(self, button)
        if onClick then onClick(self, button) end
    end)
    function b:SetText(txt)
        self.label:SetText(txt or "")
    end
    function b:GetText()
        return self.label:GetText()
    end
    b.PaintTheme = paintIdle
    return b
end

local function HideOldEdges(frame)
    if frame.edgeT then frame.edgeT:Hide() end
    if frame.edgeB then frame.edgeB:Hide() end
    if frame.edgeL then frame.edgeL:Hide() end
    if frame.edgeR then frame.edgeR:Hide() end
end

local function EnsureFill(frame)
    if not frame.bg then
        frame.bg = frame:CreateTexture(nil, "BACKGROUND", nil, -4)
        frame.bg:SetAllPoints()
    end
    return frame.bg
end

local function EnsureGlassStack(frame)
    if frame.glassBg then return end

    local glass = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
    glass:SetAllPoints()
    glass:SetTexture(SBG.GLASS_TEX)
    glass:SetTexCoord(0.04, 0.96, 0.04, 0.96)
    frame.glassBg = glass

    -- Dark readable veil over the art
    local veil = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
    veil:SetAllPoints()
    veil:SetColorTexture(0.03, 0.04, 0.07, 0.62)
    frame.glassVeil = veil

    -- Soft top sheen (liquid glass highlight)
    local sheen = frame:CreateTexture(nil, "BACKGROUND", nil, -6)
    sheen:SetPoint("TOPLEFT", 0, 0)
    sheen:SetPoint("TOPRIGHT", 0, 0)
    sheen:SetHeight(36)
    sheen:SetColorTexture(1, 1, 1, 0.07)
    frame.glassSheen = sheen

    -- Hairline edge (neutral, not theme-colored)
    local function edge(name, point, w, h)
        local e = frame:CreateTexture(nil, "BORDER", nil, 0)
        e:SetColorTexture(1, 1, 1, 0.14)
        if point == "TOP" then
            e:SetPoint("TOPLEFT", 0, 0)
            e:SetPoint("TOPRIGHT", 0, 0)
            e:SetHeight(h or 1)
        elseif point == "BOTTOM" then
            e:SetPoint("BOTTOMLEFT", 0, 0)
            e:SetPoint("BOTTOMRIGHT", 0, 0)
            e:SetHeight(h or 1)
        elseif point == "LEFT" then
            e:SetPoint("TOPLEFT", 0, 0)
            e:SetPoint("BOTTOMLEFT", 0, 0)
            e:SetWidth(w or 1)
        else
            e:SetPoint("TOPRIGHT", 0, 0)
            e:SetPoint("BOTTOMRIGHT", 0, 0)
            e:SetWidth(w or 1)
        end
        frame[name] = e
    end
    edge("glassEdgeT", "TOP")
    edge("glassEdgeB", "BOTTOM")
    edge("glassEdgeL", "LEFT")
    edge("glassEdgeR", "RIGHT")
end

local function ShowGlass(frame, a, showEdges)
    EnsureGlassStack(frame)
    local t = SBG.Theme()
    local tint = t.tint or { 0.02, 0.03, 0.06 }
    local tintA = (t.tintA or 0.55) + (1 - (a or 1)) * 0.22
    frame.glassBg:Show()
    frame.glassBg:SetAlpha(a or 1)
    frame.glassVeil:Show()
    frame.glassVeil:SetColorTexture(tint[1], tint[2], tint[3], tintA)
    frame.glassSheen:Show()
    local ac = t.accent or { 1, 1, 1 }
    frame.glassSheen:SetColorTexture(ac[1], ac[2], ac[3], 0.08)
    local border = t.border or { 1, 1, 1 }
    local ae = showEdges and 0.40 or 0
    if frame.glassEdgeT then
        frame.glassEdgeT:SetColorTexture(border[1], border[2], border[3], ae)
        frame.glassEdgeB:SetColorTexture(border[1], border[2], border[3], ae)
        frame.glassEdgeL:SetColorTexture(border[1], border[2], border[3], ae)
        frame.glassEdgeR:SetColorTexture(border[1], border[2], border[3], ae)
        frame.glassEdgeT:Show(); frame.glassEdgeB:Show()
        frame.glassEdgeL:Show(); frame.glassEdgeR:Show()
    end
end

local function HideGlass(frame)
    if frame.glassBg then frame.glassBg:Hide() end
    if frame.glassVeil then frame.glassVeil:Hide() end
    if frame.glassSheen then frame.glassSheen:Hide() end
    if frame.glassEdgeT then
        frame.glassEdgeT:Hide()
        frame.glassEdgeB:Hide()
        frame.glassEdgeL:Hide()
        frame.glassEdgeR:Hide()
    end
end

-- which: "glass" | "pane" | "bar" | "frost" | "hover" | "clear" | nil
function SBG.Paint(frame, alpha, which)
    local s = SBG.GetSettings()
    local t = SBG.Theme()
    local a = alpha or s.opacity or 1
    HideOldEdges(frame)
    if frame.SetBackdrop then frame:SetBackdrop(nil) end

    if which == "clear" then
        HideGlass(frame)
        if frame.bg then
            frame.bg:SetColorTexture(0, 0, 0, 0)
            frame.bg:Hide()
        end
        return
    end

    if which == "glass" then
        ShowGlass(frame, a, true)
        if frame.bg then frame.bg:Hide() end
        return
    end

    if which == "pane" then
        HideGlass(frame)
        local bg = EnsureFill(frame)
        bg:Show()
        local c = t.bg
        bg:SetColorTexture(c[1], c[2], c[3], 0.78)
        return
    end

    if which == "bar" then
        HideGlass(frame)
        local bg = EnsureFill(frame)
        bg:Show()
        local c = t.bar
        bg:SetColorTexture(c[1], c[2], c[3], 0.62)
        return
    end

    if which == "frost" then
        HideGlass(frame)
        local bg = EnsureFill(frame)
        bg:Show()
        local c = t.accent
        bg:SetColorTexture(c[1], c[2], c[3], 0.12)
        return
    end

    if which == "hover" then
        HideGlass(frame)
        local bg = EnsureFill(frame)
        bg:Show()
        local c = t.hover
        bg:SetColorTexture(c[1], c[2], c[3], 0.35)
        return
    end

    HideGlass(frame)
    if frame.bg then
        frame.bg:SetColorTexture(0, 0, 0, 0)
        frame.bg:Hide()
    end
end

function SBG.ColorSet(fs, which)
    local t = SBG.Theme()
    local c = t[which] or t.text
    if which == "title" then c = t.title or t.accent end
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
