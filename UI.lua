local ADDON, SBG = ...

local UI = {}
SBG.UI = UI

local MAX_EL = 16
local MAX_STEPS = 80
local BackdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil

local ICONS = {
    accept = "|TInterface\\GossipFrame\\AvailableQuestIcon:12:12:0:0|t",
    turnin = "|TInterface\\GossipFrame\\ActiveQuestIcon:12:12:0:0|t",
    complete = "|TInterface\\GossipFrame\\IncompleteQuestIcon:12:12:0:0|t",
    ["goto"] = "|TInterface\\Minimap\\POIIcons:12:12:0:0:128:128:96:112:0:16|t",
    home = "|TInterface\\Minimap\\POIIcons:12:12:0:0:128:128:64:80:0:16|t",
    fly = "|TInterface\\Minimap\\Tracking\\FlightMaster:12:12:0:0|t",
    fp = "|TInterface\\Minimap\\Tracking\\FlightMaster:12:12:0:0|t",
    hs = "|TInterface\\Icons\\INV_Misc_Rune_01:12:12:0:0|t",
    vendor = "|TInterface\\GossipFrame\\VendorGossipIcon:12:12:0:0|t",
    train = "|TInterface\\GossipFrame\\TrainerGossipIcon:12:12:0:0|t",
    collect = "|TInterface\\Minimap\\Tracking\\Banker:12:12:0:0|t",
    target = "|TInterface\\GossipFrame\\GossipGossipIcon:12:12:0:0|t",
    click = "",
}

local function Icon(el)
    return ICONS[el.kind or ""] or ICONS[el.tag or ""] or ""
end

local function LineText(el)
    local t = el and el.text
    if not t or t == "" then return nil end
    return Icon(el) .. SBG.ColorText(SBG.StripTextures(t))
end

local function MakeCheck(parent, name)
    local btn
    local ok = pcall(function()
        btn = CreateFrame("CheckButton", name, parent, "ChatConfigCheckButtonTemplate")
    end)
    if not ok or not btn then
        btn = CreateFrame("CheckButton", name, parent)
        btn:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
        btn:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
        btn:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
        btn:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    end
    btn:SetSize(12, 12)
    if btn.SetHitRectInsets then btn:SetHitRectInsets(0, 0, 0, 0) end
    local text = _G[name and (name .. "Text")]
    if text then
        text:SetText("")
        text:Hide()
    end
    return btn
end

function UI:HeaderMenu()
    local items = {
        { text = "SWEAT", isTitle = true },
        { text = "Select another guide", func = function()
            if SBG.Menu then SBG.Menu:Toggle() end
        end },
        { text = "Options...", func = function()
            if SBG.Options then SBG.Options:Toggle() end
        end },
        { text = "Go to step 1", func = function() SBG.Engine:SetStep(1) end },
        { text = "Reload guide", func = function()
            if SBGPC.guideKey then SBG.Engine:Load(SBGPC.guideKey, 1) end
        end },
    }
    if SBG.guides and #SBG.guides > 0 then
        table.insert(items, { text = "Guides", isTitle = true })
        for i = 1, #SBG.guides do
            local g = SBG.guides[i]
            table.insert(items, {
                text = g.displayname or g.name,
                func = function() SBG.Engine:Load(g.key) end,
            })
        end
    end
    SBG.ShowDrop(items, self.frame and self.frame.header)
end

function UI:Init()
    local s = SBG.GetSettings()
    local f = CreateFrame("Frame", "SBGStepFrame", UIParent, BackdropTemplate)
    f:SetSize(s.windowW or 260, s.windowH or 200)
    f:SetPoint("LEFT", UIParent, "LEFT", 8, 40)
    f:SetFrameStrata("LOW")
    f:SetToplevel(true)
    f:SetMovable(true)
    f:SetResizable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f:Hide()
    self.frame = f
    SBG.Paint(f, nil, "clear")

    local function dragStart(_, button, resize)
        if SBG.GetSettings().lockFrames then return end
        if resize then
            f.sizing = true
            f:StartSizing("BOTTOMRIGHT")
        else
            f:StartMoving()
        end
    end
    local function dragStop()
        f:StopMovingOrSizing()
        if f.sizing then
            local st = SBG.GetSettings()
            st.windowW = math.floor(f:GetWidth() + 0.5)
            st.windowH = math.floor(f:GetHeight() + 0.5)
            f.sizing = false
            UI:Refresh()
        end
    end
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnMouseDown", function(_, button)
        if button == "RightButton" then UI:HeaderMenu() else dragStart(_, button) end
    end)
    f:SetScript("OnMouseUp", dragStop)
    if f.SetResizeBounds then
        f:SetResizeBounds(220, 80, 480, 700)
    else
        if f.SetMinResize then f:SetMinResize(220, 80) end
        if f.SetMaxResize then f:SetMaxResize(480, 700) end
    end

    local bottom = CreateFrame("Frame", "SBGBottomFrame", f, BackdropTemplate)
    bottom:SetPoint("TOPLEFT", 3, -3)
    bottom:SetPoint("BOTTOMRIGHT", -3, 14)
    f.bottom = bottom
    SBG.Paint(bottom)

    local header = CreateFrame("Button", "SBGGuideName", f, BackdropTemplate)
    header:SetPoint("BOTTOMLEFT", bottom, "TOPLEFT", 0, -9)
    header:SetPoint("BOTTOMRIGHT", bottom, "TOPRIGHT", 0, -9)
    header:SetHeight(35)
    header:SetFrameLevel(8)
    header:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function() dragStart(nil, "LeftButton") end)
    header:SetScript("OnDragStop", dragStop)
    header:SetScript("OnClick", function(_, button)
        if button == "RightButton" then UI:HeaderMenu() end
    end)
    f.header = header
    SBG.Paint(header)

    f.logo = header:CreateTexture(nil, "ARTWORK")
    f.logo:SetPoint("CENTER", header, "LEFT", 16, 0)
    f.logo:SetSize(36, 36)
    f.logo:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    f.logo:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    f.classIcon = header:CreateTexture(nil, "OVERLAY")
    f.classIcon:SetPoint("CENTER", f.logo, "BOTTOMRIGHT", -4, 8)
    f.classIcon:SetSize(20, 20)
    f.classIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
    local coords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[SBG.player.class]
    if coords then f.classIcon:SetTexCoord(unpack(coords)) end

    f.title = SBG.MakeText(header, "GameFontNormal")
    f.title:SetPoint("LEFT", 34, 0)
    f.title:SetPoint("RIGHT", -8, 0)
    f.title:SetJustifyH("CENTER")
    f.title:SetWordWrap(true)

    local current = CreateFrame("Frame", "SBGCurrentStep", f, BackdropTemplate)
    current:SetPoint("BOTTOMLEFT", header, "TOPLEFT", 0, 2)
    current:SetPoint("BOTTOMRIGHT", header, "TOPRIGHT", 0, 2)
    current:SetHeight(40)
    current:EnableMouse(true)
    current:RegisterForDrag("LeftButton")
    current:SetScript("OnMouseDown", function(_, button)
        if button == "RightButton" then UI:HeaderMenu() else dragStart(nil, button) end
    end)
    current:SetScript("OnMouseUp", dragStop)
    f.current = current
    SBG.Paint(current)
    current.elements = {}

    current.badge = CreateFrame("Frame", nil, current, BackdropTemplate)
    current.badge:SetPoint("TOPLEFT", 7, 5)
    current.badge:SetSize(54, 17)
    SBG.Paint(current.badge)
    current.badgeText = SBG.MakeText(current.badge, "GameFontNormalSmall")
    current.badgeText:SetPoint("CENTER", 1, 0)

    for i = 1, MAX_EL do
        local el = CreateFrame("Frame", "SBGCurEl" .. i, current)
        el:SetHeight(16)
        el.check = MakeCheck(el, "SBGCurEl" .. i .. "Check")
        el.check:SetPoint("TOPLEFT", 6, -1)
        el.text = SBG.MakeText(el, "GameFontHighlight")
        el.text:SetPoint("TOPLEFT", el.check, "TOPRIGHT", 11, 0)
        el.text:SetPoint("RIGHT", el, "RIGHT", -6, 0)
        el.text:SetJustifyH("LEFT")
        el.text:SetJustifyV("TOP")
        el.text:SetWordWrap(true)
        pcall(function() el.text:SetNonSpaceWrap(true) end)
        el.check:SetScript("OnClick", function(self)
            if el.el then SBG.Engine:SetElementSkip(el.el, self:GetChecked()) end
        end)
        el:Hide()
        current.elements[i] = el
    end

    local scroll = CreateFrame("ScrollFrame", "SBGScrollFrame", bottom, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 4, -8)
    scroll:SetPoint("BOTTOMRIGHT", -22, 6)
    f.scroll = scroll
    local child = CreateFrame("Frame", "SBGScrollChild", scroll)
    child:SetSize(220, 200)
    scroll:SetScrollChild(child)
    f.child = child
    f.stepRows = {}
    for i = 1, MAX_STEPS do
        local row = CreateFrame("Button", "SBGStepRow" .. i, child, BackdropTemplate)
        row:SetHeight(22)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        row.num = SBG.MakeText(row, "GameFontNormalSmall")
        row.num:SetPoint("BOTTOMRIGHT", -2, 2)
        row.body = SBG.MakeText(row, "GameFontHighlightSmall")
        row.body:SetPoint("TOPLEFT", 6, -4)
        row.body:SetPoint("BOTTOMRIGHT", row.num, "BOTTOMLEFT", -2, 0)
        row.body:SetJustifyH("LEFT")
        row.body:SetJustifyV("TOP")
        row.body:SetWordWrap(true)
        row:SetScript("OnEnter", function(self)
            SBG.Paint(self, 1, "hover")
        end)
        row:SetScript("OnLeave", function(self)
            UI:PaintStepRow(self)
        end)
        row:SetScript("OnClick", function(self, button)
            if not self.stepIndex then return end
            if button == "RightButton" then
                SBG.ShowDrop({
                    { text = "Go to step " .. self.stepIndex, func = function()
                        SBG.Engine:SetStep(self.stepIndex)
                    end },
                    { text = "Options...", func = function()
                        if SBG.Options then SBG.Options:Toggle() end
                    end },
                    { text = "Select another guide", func = function()
                        if SBG.Menu then SBG.Menu:Toggle() end
                    end },
                }, self)
            else
                SBG.Engine:SetStep(self.stepIndex)
            end
        end)
        SBG.Paint(row, nil, "clear")
        row:Hide()
        f.stepRows[i] = row
    end

    local footer = CreateFrame("Frame", "SBGFooter", f, BackdropTemplate)
    footer:SetPoint("BOTTOMLEFT", 3, 0)
    footer:SetPoint("BOTTOMRIGHT", -3, 0)
    footer:SetHeight(20)
    footer:SetFrameLevel(8)
    footer:EnableMouse(true)
    footer:RegisterForDrag("LeftButton")
    footer:SetScript("OnMouseDown", function(_, button)
        if button == "RightButton" then UI:HeaderMenu() else dragStart(nil, button) end
    end)
    footer:SetScript("OnMouseUp", dragStop)
    f.footer = footer
    SBG.Paint(footer)

    f.cog = CreateFrame("Button", nil, footer)
    f.cog:SetSize(18, 18)
    f.cog:SetPoint("LEFT", 2, 1)
    f.cog:SetNormalTexture("Interface\\Icons\\INV_Misc_Gear_01")
    f.cog:GetNormalTexture():SetTexCoord(0.08, 0.92, 0.08, 0.92)
    f.cog:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")
    f.cog:SetScript("OnClick", function() UI:HeaderMenu() end)
    f.cog:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Options", 1, 1, 1)
        GameTooltip:AddLine("Right-click the header for the same menu", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    f.cog:SetScript("OnLeave", function() GameTooltip:Hide() end)

    f.footText = SBG.MakeText(footer, "GameFontDisableSmall")
    f.footText:SetPoint("LEFT", 24, 1)
    f.footText:SetPoint("RIGHT", -18, 1)
    f.footText:SetJustifyH("LEFT")
    f.footText:SetText("Sweat Beta Guide")

    local grab = CreateFrame("Button", nil, footer)
    grab:SetSize(16, 16)
    grab:SetPoint("BOTTOMRIGHT", footer, "BOTTOMRIGHT", -1, 2)
    grab:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grab:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grab:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    grab:SetScript("OnMouseDown", function() dragStart(nil, "LeftButton", true) end)
    grab:SetScript("OnMouseUp", dragStop)
    f.grab = grab

    self:Apply()
end

function UI:PaintStepRow(row)
    if not row then return end
    local cur = SBG.Engine.stepIndex or 1
    if row.stepIndex == cur then
        SBG.Paint(row, 1, "hover")
        row:SetAlpha(1)
        SBG.ColorSet(row.body, "text")
        SBG.ColorSet(row.num, "text")
    else
        -- Sit on the bottom pane — no extra card behind the text.
        SBG.Paint(row, nil, "clear")
        row:SetAlpha(0.66)
        SBG.ColorSet(row.body, "body")
        SBG.ColorSet(row.num, "muted")
    end
end

function UI:Apply()
    local f = self.frame
    if not f or not f.title then return end
    local s = SBG.GetSettings()
    local t = SBG.Theme()
    local font = SBG.Font()
    SBG.Paint(f, nil, "clear")
    SBG.Paint(f.bottom)
    SBG.Paint(f.header)
    SBG.Paint(f.current)
    SBG.Paint(f.footer)
    SBG.Paint(f.current.badge)
    f:SetScale(s.scale or 1)
    if not f.sizing then
        if s.windowW then f:SetWidth(s.windowW) end
        if s.windowH then f:SetHeight(s.windowH) end
    end
    f.title:SetFont(font, 11, "")
    SBG.ColorSet(f.title, "text")
    f.current.badgeText:SetFont(font, s.fontSize or 12, "")
    SBG.ColorSet(f.current.badgeText, "accent")
    f.footText:SetFont(font, 9, "")
    SBG.ColorSet(f.footText, "muted")
    for i = 1, MAX_EL do
        f.current.elements[i].text:SetFont(font, (s.fontSize or 12) + 1, "")
        SBG.ColorSet(f.current.elements[i].text, "body")
    end
    for i = 1, MAX_STEPS do
        f.stepRows[i].body:SetFont(font, s.fontSize or 12, "")
        f.stepRows[i].num:SetFont(font, math.max(9, (s.fontSize or 12) - 1), "")
    end
    self:Refresh()
end

function UI:Refresh()
    local f = self.frame
    if not f or not f.title then return end
    local engine = SBG.Engine
    local guide = engine.guide
    if not guide then
        f:Hide()
        return
    end
    if not self.dismissed then f:Show() end

    local index = engine.stepIndex or 1
    local total = #guide.steps
    local step = engine:ActiveStep()
    f.title:SetText(guide.displayname or guide.name)
    f.current.badgeText:SetText("Step " .. index)
    f.current.badge:SetWidth(math.max(48, f.current.badgeText:GetStringWidth() + 10))
    if guide.icon then f.logo:SetTexture(guide.icon) end
    f.footText:SetText(string.format("Sweat  %d / %d", index, total))

    local wrapW = math.max(140, f:GetWidth() - 40)
    local shown = 0
    local height = 18
    for _, el in ipairs(step and step.elements or {}) do
        local line = LineText(el)
        if line then
            shown = shown + 1
            if shown > MAX_EL then break end
            local slot = f.current.elements[shown]
            slot.el = el
            slot:Show()
            slot:ClearAllPoints()
            slot:SetPoint("LEFT")
            slot:SetPoint("RIGHT")
            if shown == 1 then
                slot:SetPoint("TOPLEFT", f.current, "TOPLEFT", 0, -14)
            else
                slot:SetPoint("TOPLEFT", f.current.elements[shown - 1], "BOTTOMLEFT", 0, 0)
            end
            slot.text:SetWidth(wrapW - 28)
            slot.text:SetText(line)
            local h = 16
            if slot.text.GetStringHeight then
                h = math.max(14, math.ceil((slot.text:GetStringHeight() or 12) * 1.1) + 1)
            end
            slot:SetHeight(h)
            if el.textOnly then
                slot.check:SetChecked(true)
                slot.check:Hide()
            else
                slot.check:Show()
                slot.check:SetChecked(el.completed and true or false)
            end
            height = height + h
        end
    end
    for i = shown + 1, MAX_EL do
        f.current.elements[i]:Hide()
        f.current.elements[i].el = nil
    end
    f.current:SetHeight(math.max(28, height + 4))

    local y = 2
    local childW = math.max(180, (f.scroll:GetWidth() or 200))
    f.child:SetWidth(childW)
    for i = 1, total do
        local row = f.stepRows[i]
        if not row then break end
        local st = guide.steps[i]
        local chunks = {}
        for _, el in ipairs(st.elements) do
            local line = LineText(el)
            if line then table.insert(chunks, "   " .. line) end
        end
        local body = table.concat(chunks, "\n")
        if body == "" then body = "   Click to continue" end
        row.stepIndex = i
        row.num:SetText(i < 10 and ("0" .. i) or tostring(i))
        row.body:SetWidth(childW - 28)
        row.body:SetText(body)
        local rh = 22
        if row.body.GetStringHeight then
            rh = math.max(20, math.ceil((row.body:GetStringHeight() or 12) + 8))
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 2, -y)
        row:SetPoint("TOPRIGHT", -2, -y)
        row:SetHeight(rh)
        row:Show()
        self:PaintStepRow(row)
        y = y + rh + 3
    end
    for i = total + 1, MAX_STEPS do
        f.stepRows[i]:Hide()
        f.stepRows[i].stepIndex = nil
    end
    f.child:SetHeight(math.max(f.scroll:GetHeight() or 80, y + 4))

    if self.lastIndex ~= index then
        self.lastIndex = index
        local pos = 0
        for i = 1, index - 1 do
            pos = pos + (f.stepRows[i]:GetHeight() or 22) + 3
        end
        local max = f.scroll:GetVerticalScrollRange() or 0
        if pos > max then pos = max end
        f.scroll:SetVerticalScroll(pos)
    end
end

function UI:Show()
    self.dismissed = false
    if self.frame then
        self.frame:Show()
        self:Apply()
    end
end

function UI:Toggle()
    if not self.frame then return end
    if self.frame:IsShown() then
        self.dismissed = true
        self.frame:Hide()
    else
        self:Show()
    end
end
