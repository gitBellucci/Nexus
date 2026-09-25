local ADDON, SBG = ...

local Options = {}
SBG.Options = Options

local BackdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil

local function Header(parent, text)
    local wrap = CreateFrame("Frame", nil, parent)
    wrap:SetSize(520, 26)
    SBG.StyleGlassChip(wrap, "pill")
    local fs = SBG.MakeText(wrap, "GameFontNormal")
    fs:SetPoint("LEFT", 12, 0)
    fs:SetText(text)
    fs:SetTextColor(0.95, 0.82, 0.35)
    wrap.label = fs
    return wrap
end

local function Toggle(parent, label, key, desc, onChange)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(520, 26)
    local name = "SBGOpt_" .. key
    local box
    pcall(function()
        box = CreateFrame("CheckButton", name, row, "ChatConfigCheckButtonTemplate")
    end)
    if not box then
        box = CreateFrame("CheckButton", name, row)
        box:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
        box:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
        box:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
        box:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    end
    box:SetPoint("LEFT", 0, 0)
    box:SetSize(26, 26)
    local fs = _G[name .. "Text"]
    if fs then
        fs:ClearAllPoints()
        fs:SetPoint("LEFT", box, "RIGHT", 4, 0)
        fs:SetFontObject(GameFontHighlight)
        fs:SetText(label)
        fs:Show()
    else
        fs = SBG.MakeText(row, "GameFontHighlight")
        fs:SetPoint("LEFT", box, "RIGHT", 4, 0)
        fs:SetText(label)
    end
    row.box = box
    row.key = key
    function row:Paint()
        box:SetChecked(SBG.GetSettings()[key] and true or false)
    end
    box:SetScript("OnClick", function(self)
        SBG.GetSettings()[key] = self:GetChecked() and true or false
        if onChange then onChange(SBG.GetSettings()[key]) end
    end)
    box:SetScript("OnEnter", function(self)
        if not desc then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(label, 1, 1, 1)
        GameTooltip:AddLine(desc, 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    box:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row:Paint()
    return row
end

local function Range(parent, label, key, minV, maxV, step, desc, onLive, onCommit)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(280, 44)
    local cap = SBG.MakeText(row, "GameFontHighlight")
    cap:SetPoint("TOPLEFT", 4, 0)
    cap:SetText(label)
    local val = SBG.MakeText(row, "GameFontNormal")
    val:SetPoint("TOPRIGHT", -4, 0)
    local name = "SBGSlider_" .. key
    local sl
    pcall(function()
        sl = CreateFrame("Slider", name, row, "OptionsSliderTemplate")
    end)
    if sl then
        sl:SetPoint("TOPLEFT", 8, -18)
        sl:SetPoint("TOPRIGHT", -8, -18)
        sl:SetMinMaxValues(minV, maxV)
        sl:SetValueStep(step)
        if sl.SetObeyStepOnDrag then sl:SetObeyStepOnDrag(true) end
        local low, high, txt = _G[name .. "Low"], _G[name .. "High"], _G[name .. "Text"]
        if low then low:SetText("") end
        if high then high:SetText("") end
        if txt then txt:SetText("") end
    else
        sl = SBG.Slider(row, label, key, minV, maxV, step, "%.2f", onLive, onCommit).bar
        sl:ClearAllPoints()
        sl:SetPoint("TOPLEFT", 8, -22)
        sl:SetPoint("TOPRIGHT", -8, -22)
    end
    row.sl = sl
    row.val = val
    function row:Paint()
        local n = SBG.GetSettings()[key] or minV
        row._painting = true
        sl:SetValue(n)
        row._painting = nil
        if step >= 1 then
            val:SetText(string.format("%d", n))
        else
            val:SetText(string.format("%.2f", n))
        end
    end
    sl:SetScript("OnValueChanged", function(_, n)
        if row._painting then return end
        n = math.floor(n / step + 0.5) * step
        SBG.GetSettings()[key] = n
        row:Paint()
        if onLive then onLive(n) end
    end)
    sl:SetScript("OnMouseUp", function()
        if onCommit then onCommit(SBG.GetSettings()[key]) end
    end)
    sl:SetScript("OnEnter", function(self)
        if not desc then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(label, 1, 1, 1)
        GameTooltip:AddLine(desc, 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    sl:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row:Paint()
    return row
end

local THEME_ORDER = { "blue", "red", "gold", "dark", "green" }

function Options:Init()
    local f = CreateFrame("Frame", "SBGOptionsFrame", UIParent, BackdropTemplate)
    f:SetSize(640, 480)
    f:SetPoint("CENTER")
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetToplevel(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()
    self.frame = f
    SBG.Paint(f, nil, "glass")
    pcall(function() f:SetClipsChildren(true) end)

    local titleBar = CreateFrame("Frame", nil, f)
    titleBar:SetPoint("TOPLEFT", 14, -14)
    titleBar:SetPoint("TOPRIGHT", -14, -14)
    titleBar:SetHeight(36)
    f.titleBar = titleBar
    SBG.StyleGlassChip(titleBar, "chip")

    f.brandIcon = titleBar:CreateTexture(nil, "ARTWORK")
    f.brandIcon:SetSize(22, 22)
    f.brandIcon:SetPoint("LEFT", 12, 0)
    f.brandIcon:SetTexture(SBG.ICON_TEX)
    f.brandIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    f.title = SBG.MakeText(titleBar, "GameFontNormal")
    f.title:SetPoint("LEFT", f.brandIcon, "RIGHT", 8, 0)
    f.title:SetText("Sweat Beta Guide")
    f.title:SetTextColor(1, 0.85, 0.35)

    local close = SBG.MakeGlassButton(titleBar, "X", 28, 24, function() f:Hide() end)
    close:SetPoint("RIGHT", -8, 0)
    f.close = close

    local tabNames = {
        { id = "general", name = "General" },
        { id = "look", name = "Look and Feel" },
        { id = "targeting", name = "Targeting" },
    }
    self.tabs = {}
    for i, info in ipairs(tabNames) do
        local tab = SBG.MakeGlassButton(f, info.name, 128, 26, function()
            Options:ShowCat(info.id)
        end)
        if i == 1 then
            tab:SetPoint("TOPLEFT", 16, -58)
        else
            tab:SetPoint("LEFT", self.tabs[i - 1], "RIGHT", 6, 0)
        end
        tab.cat = info.id
        self.tabs[i] = tab
    end

    local body = CreateFrame("Frame", nil, f, BackdropTemplate)
    body:SetPoint("TOPLEFT", 16, -92)
    body:SetPoint("BOTTOMRIGHT", -16, 16)
    SBG.Paint(body, nil, "pane")
    f.body = body

    local scroll = CreateFrame("ScrollFrame", "SBGOptionsScroll", body, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 8, -8)
    scroll:SetPoint("BOTTOMRIGHT", -28, 8)
    f.scroll = scroll
    local child = CreateFrame("Frame", nil, scroll)
    child:SetSize(560, 800)
    scroll:SetScrollChild(child)
    f.child = child

    local pages = {}
    self.pages = pages
    local function page(id)
        local p = CreateFrame("Frame", nil, child)
        p:SetAllPoints()
        p:Hide()
        pages[id] = p
        return p
    end
    local function layout(p, widgets)
        local y = -4
        for i = 1, #widgets do
            local w = widgets[i]
            w:SetPoint("TOPLEFT", p, "TOPLEFT", 8, y)
            y = y - (w:GetHeight() or 24) - 6
        end
        p._h = math.abs(y) + 24
    end

    do
        local p = page("general")
        local h = Header(p, "General")
        local lock = Toggle(p, "Lock Frames", "lockFrames",
            "Disable dragging the guide window", function() SBG.ApplyAll() end)
        local mini = Toggle(p, "Enable Minimap Button", "showMinimapButton",
            "Show the Sweat button on the minimap", function() SBG.ApplyAll() end)
        local hide = Toggle(p, "Hide waypoint arrow", "hideArrow",
            "Hide the direction arrow", function(v)
                SBG.GetSettings().showArrow = not v
                SBG.ApplyAll()
            end)
        hide.box:SetScript("OnClick", function(self)
            local v = self:GetChecked() and true or false
            SBG.GetSettings().hideArrow = v
            SBG.GetSettings().showArrow = not v
            SBG.ApplyAll()
        end)
        function hide:Paint()
            local s = SBG.GetSettings()
            hide.box:SetChecked(not s.showArrow)
        end
        local adv = Toggle(p, "Auto-advance when a step completes", "autoAdvance",
            "Automatically go to the next step when all goals are done", function() SBG.ApplyAll() end)
        local ph = Header(p, "Profiles")
        local profile = SBG.MakeText(p, "GameFontHighlight")
        profile:SetHeight(20)
        profile:SetJustifyH("LEFT")
        p.profile = profile
        local reset = SBG.MakeGlassButton(p, "Reset Profile", 140, 24, function()
            local name = SBGDB.currentProfile or "Default"
            SBGDB.profiles[name] = { themeMigrated = true, theme = "blue" }
            SBG.EnsureDB()
            SBG.ApplyAll()
            Options:Apply()
            SBG.Print("Profile reset.")
        end)
        layout(p, { h, lock, mini, hide, adv, ph, profile, reset })
        self.lock, self.mini, self.hideArrow, self.autoAdvance = lock, mini, hide, adv
        self.profileLabel = profile
    end

    do
        local p = page("look")
        local h = Header(p, "Look and Feel")
        local themeRow = CreateFrame("Frame", nil, p)
        themeRow:SetSize(520, 32)
        local themeCap = SBG.MakeText(themeRow, "GameFontHighlight")
        themeCap:SetPoint("LEFT", 4, 0)
        themeCap:SetText("Choose Theme")
        local themeBtn = SBG.MakeGlassButton(themeRow, "Sweat Blue", 180, 24, function(btn)
            local items = {}
            for _, id in ipairs(THEME_ORDER) do
                local th = SBG.Themes[id]
                table.insert(items, {
                    text = th.name,
                    func = function()
                        SBG.GetSettings().theme = id
                        SBG.ApplyAll()
                        Options:Apply()
                    end,
                })
            end
            SBG.ShowDrop(items, btn)
        end)
        themeBtn:SetPoint("LEFT", 160, 0)
        p.themeBtn = themeBtn
        self.themeBtn = themeBtn

        local gh = Header(p, "Guide Window")
        local scale = Range(p, "Window Scale", "scale", 0.2, 2, 0.05,
            "Scale of the main window. Drag the corner to resize.",
            function(n) if SBG.UI.frame then SBG.UI.frame:SetScale(n) end end,
            function() SBG.ApplyAll() end)
        local fontSz = Range(p, "Step Font Size", "fontSize", 9, 18, 1,
            "Font size of step text in the guide window",
            nil, function() SBG.ApplyAll() end)
        local titleSz = Range(p, "Guide Title Size", "titleSize", 10, 18, 1,
            "Font size of the guide name in the header",
            nil, function() SBG.ApplyAll() end)
        local headSz = Range(p, "Menu Title Size", "headerSize", 11, 18, 1,
            "Font size of titles in the guide selector / options",
            nil, function() SBG.ApplyAll() end)
        local opac = Range(p, "Window Opacity", "opacity", 0.4, 1, 0.05,
            "Background opacity of the guide window",
            nil, function() SBG.ApplyAll() end)
        local outline = Toggle(p, "Font outline", "fontOutline",
            "Add a black outline to guide text for readability", function() SBG.ApplyAll() end)

        local ah = Header(p, "Waypoint Arrow")
        local arrow = Range(p, "Arrow Scale", "arrowScale", 0.2, 2, 0.05,
            "Scale of the Waypoint Arrow",
            function() if SBG.Arrow then SBG.Arrow:Apply() end end,
            function() SBG.ApplyAll() end)

        local mh = Header(p, "Map")
        local pin = Toggle(p, "Show minimap pin", "showPin",
            "Show the waypoint pin on the minimap", function() SBG.ApplyAll() end)

        layout(p, { h, themeRow, gh, scale, fontSz, titleSz, headSz, opac, outline, ah, arrow, mh, pin })
        self.scale, self.fontSize, self.titleSize, self.headerSize = scale, fontSz, titleSz, headSz
        self.opacity, self.fontOutline = opac, outline
        self.arrowScale, self.showPin = arrow, pin
    end

    do
        local p = page("targeting")
        local h = Header(p, "Targeting")
        local macro = Toggle(p, "Automatically create a targeting macro", "enableTargetMacro",
            "Creates the account macro SweatTarget and updates it from the current step",
            function() if SBG.Targeting then SBG.Targeting:Apply() end end)
        local notify = Toggle(p, "Notify on targeting macro updates", "notifyOnTargetUpdates",
            "Print a chat message when the targeting macro changes")
        local markF = Toggle(p, "Mark friendly targets", "enableTargetMarking",
            "Set raid markers on NPCs from .target lines")
        local markM = Toggle(p, "Mark enemy mobs", "enableMobMarking",
            "Set raid markers on NPCs from .mob lines")
        local markU = Toggle(p, "Mark unitscan targets", "enableEnemyMarking",
            "Set raid markers on NPCs from .unitscan lines")

        -- Keybind button row
        local kbRow = CreateFrame("Frame", nil, p)
        kbRow:SetSize(520, 26)
        local kbLabel = SBG.MakeText(kbRow, "GameFontHighlight")
        kbLabel:SetPoint("LEFT", 0, 0)
        kbLabel:SetText("Keybind current step target targeting")
        local kbBtn = SBG.MakeGlassButton(kbRow, "Click to bind", 140, 22, function(self)
            if SBG.Targeting then SBG.Targeting:StartKeybindCapture(self) end
        end)
        kbBtn:SetPoint("RIGHT", kbRow, "RIGHT", 0, 0)
        kbBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine("Keybind current step target targeting", 1, 1, 1)
            GameTooltip:AddLine("Press a key to bind · Right-click the overlay to clear", 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end)
        kbBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        -- Store reference so we can refresh the button label
        if SBG.Targeting then SBG.Targeting.keybindBtn = kbBtn end
        kbRow.kbBtn = kbBtn
        self.kbRow = kbRow

        layout(p, { h, macro, notify, markF, markM, markU, kbRow })
        self.enableTargetMacro, self.notifyOnTargetUpdates = macro, notify
        self.enableTargetMarking, self.enableMobMarking, self.enableEnemyMarking = markF, markM, markU
    end

    self:ShowCat("general")
    self:Apply()
end

function Options:ShowCat(id)
    self.cat = id
    for k, p in pairs(self.pages) do
        if k == id then p:Show() else p:Hide() end
    end
    for i = 1, #self.tabs do
        local b = self.tabs[i]
        local selected = b.cat == id
        local t = SBG.Theme()
        if selected then
            local hov = t.hover
            if b.chipVeil then b.chipVeil:SetColorTexture(hov[1], hov[2], hov[3], 0.50) end
            if b.label then b.label:SetTextColor(1, 1, 1) end
        else
            if b.PaintTheme then b:PaintTheme() end
        end
    end
    local p = self.pages[id]
    if p and p._h then
        self.frame.child:SetHeight(math.max(self.frame.scroll:GetHeight() or 400, p._h))
    end
    self.frame.scroll:SetVerticalScroll(0)
end

function Options:Apply()
    local f = self.frame
    if not f or not f.title then return end
    local s = SBG.GetSettings()
    SBG.Paint(f, nil, "glass")
    if f.titleBar then SBG.StyleGlassChip(f.titleBar, "chip") end
    if f.body then SBG.Paint(f.body, nil, "pane") end
    if f.brandIcon then f.brandIcon:SetTexture(SBG.ICON_TEX) end
    local font = SBG.Font()
    f.title:SetFont(font, s.headerSize or 13, SBG.FontFlags())
    SBG.ColorSet(f.title, "title")
    if self.themeBtn then
        local th = SBG.Theme()
        self.themeBtn:SetText(th.name)
    end
    if self.profileLabel then
        self.profileLabel:SetText("Active Profile: " .. (SBGDB.currentProfile or "Default"))
    end
    local paint = {
        self.lock, self.mini, self.hideArrow, self.autoAdvance,
        self.scale, self.fontSize, self.titleSize, self.headerSize,
        self.opacity, self.fontOutline, self.arrowScale, self.showPin,
        self.enableTargetMacro, self.notifyOnTargetUpdates,
        self.enableTargetMarking, self.enableMobMarking, self.enableEnemyMarking,
    }
    for i = 1, #paint do
        if paint[i] and paint[i].Paint then paint[i]:Paint() end
    end
    if self.themeBtn and self.themeBtn.PaintTheme then self.themeBtn:PaintTheme() end
    if f.close and f.close.PaintTheme then f.close:PaintTheme() end
    for i = 1, #(self.tabs or {}) do
        if self.tabs[i].PaintTheme then self.tabs[i]:PaintTheme() end
    end
    if self.cat then self:ShowCat(self.cat) end
    -- Refresh keybind button label
    if SBG.Targeting then SBG.Targeting:RefreshKeybindButton() end
end

function Options:Toggle()
    if not self.frame then self:Init() end
    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self:Apply()
        self.frame:Show()
    end
end
