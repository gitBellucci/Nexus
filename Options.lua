local ADDON, SBG = ...

local Options = {}
SBG.Options = Options

local BackdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil

local function DialogBackdrop(frame)
    if not frame.SetBackdrop then return end
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    frame:SetBackdropColor(0, 0, 0, 1)
end

local function InsetBackdrop(frame)
    if not frame.SetBackdrop then return end
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
end

local function Header(parent, text)
    local fs = SBG.MakeText(parent, "GameFontNormal")
    fs:SetText(text)
    fs:SetJustifyH("LEFT")
    fs:SetHeight(20)
    return fs
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
    f:SetSize(700, 500)
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
    DialogBackdrop(f)

    local headerTex = f:CreateTexture(nil, "ARTWORK")
    headerTex:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    headerTex:SetSize(360, 64)
    headerTex:SetPoint("TOP", 0, 12)
    f.headerTex = headerTex

    f.title = SBG.MakeText(f, "GameFontNormal")
    f.title:SetPoint("TOP", headerTex, "TOP", 0, -14)
    f.title:SetText("Sweat Beta Guide")

    local close
    pcall(function()
        close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    end)
    if not close then
        close = CreateFrame("Button", nil, f)
        close:SetSize(32, 32)
        close:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
        close:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
        close:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    end
    close:SetPoint("TOPRIGHT", -4, -4)
    close:SetScript("OnClick", function() f:Hide() end)
    f.close = close

    local tabNames = {
        { id = "general", name = "General" },
        { id = "look", name = "Look and Feel" },
        { id = "targeting", name = "Targeting" },
    }
    self.tabs = {}
    for i, info in ipairs(tabNames) do
        local tab = CreateFrame("Button", "SBGOptTab" .. i, f, BackdropTemplate)
        tab:SetSize(128, 24)
        tab:SetNormalFontObject(GameFontNormalSmall)
        tab:SetHighlightFontObject(GameFontHighlightSmall)
        tab:SetText(info.name)
        if tab.SetBackdrop then
            tab:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8X8",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 12,
                insets = { left = 3, right = 3, top = 3, bottom = 3 },
            })
            tab:SetBackdropColor(0.1, 0.1, 0.12, 1)
            tab:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        end
        if i == 1 then
            tab:SetPoint("TOPLEFT", 16, -40)
        else
            tab:SetPoint("LEFT", self.tabs[i - 1], "RIGHT", 4, 0)
        end
        tab.cat = info.id
        tab:SetScript("OnClick", function() Options:ShowCat(info.id) end)
        self.tabs[i] = tab
    end

    local body = CreateFrame("Frame", nil, f, BackdropTemplate)
    body:SetPoint("TOPLEFT", 18, -68)
    body:SetPoint("BOTTOMRIGHT", -18, 16)
    InsetBackdrop(body)
    f.body = body

    local scroll = CreateFrame("ScrollFrame", "SBGOptionsScroll", body, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 8, -8)
    scroll:SetPoint("BOTTOMRIGHT", -28, 8)
    f.scroll = scroll
    local child = CreateFrame("Frame", nil, scroll)
    child:SetSize(620, 800)
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
        local reset = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
        reset:SetSize(140, 22)
        reset:SetText("Reset Profile")
        reset:SetScript("OnClick", function()
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
        local themeBtn = CreateFrame("Button", "SBGThemeDrop", themeRow, "UIPanelButtonTemplate")
        themeBtn:SetSize(180, 22)
        themeBtn:SetPoint("LEFT", 160, 0)
        themeBtn:SetScript("OnClick", function()
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
            SBG.ShowDrop(items, themeBtn)
        end)
        p.themeBtn = themeBtn
        self.themeBtn = themeBtn

        local gh = Header(p, "Guide Window")
        local scale = Range(p, "Window Scale", "scale", 0.2, 2, 0.05,
            "Scale of the main window. Alt+drag the corner to resize.",
            function(n) if SBG.UI.frame then SBG.UI.frame:SetScale(n) end end,
            function() SBG.ApplyAll() end)
        local font = Range(p, "Guide Font Size", "fontSize", 9, 18, 1,
            "Change font size of the Guide Window",
            nil, function() SBG.ApplyAll() end)
        local opac = Range(p, "Window Opacity", "opacity", 0.4, 1, 0.05,
            "Background opacity of the guide window",
            nil, function() SBG.ApplyAll() end)

        local ah = Header(p, "Waypoint Arrow")
        local arrow = Range(p, "Arrow Scale", "arrowScale", 0.2, 2, 0.05,
            "Scale of the Waypoint Arrow",
            function() if SBG.Arrow then SBG.Arrow:Apply() end end,
            function() SBG.ApplyAll() end)

        local mh = Header(p, "Map")
        local pin = Toggle(p, "Show minimap pin", "showPin",
            "Show the waypoint pin on the minimap", function() SBG.ApplyAll() end)

        layout(p, { h, themeRow, gh, scale, font, opac, ah, arrow, mh, pin })
        self.scale, self.fontSize, self.opacity = scale, font, opac
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
        layout(p, { h, macro, notify, markF, markM, markU })
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
        if selected then
            b:SetNormalFontObject(GameFontHighlightSmall)
            if b.SetBackdropColor then b:SetBackdropColor(0.2, 0.2, 0.22, 1) end
        else
            b:SetNormalFontObject(GameFontNormalSmall)
            if b.SetBackdropColor then b:SetBackdropColor(0.1, 0.1, 0.12, 1) end
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
    if self.themeBtn then
        local th = SBG.Theme()
        self.themeBtn:SetText(th.name)
    end
    if self.profileLabel then
        self.profileLabel:SetText("Active Profile: " .. (SBGDB.currentProfile or "Default"))
    end
    local paint = {
        self.lock, self.mini, self.hideArrow, self.autoAdvance,
        self.scale, self.fontSize, self.opacity, self.arrowScale, self.showPin,
        self.enableTargetMacro, self.notifyOnTargetUpdates,
        self.enableTargetMarking, self.enableMobMarking, self.enableEnemyMarking,
    }
    for i = 1, #paint do
        if paint[i] and paint[i].Paint then paint[i]:Paint() end
    end
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
