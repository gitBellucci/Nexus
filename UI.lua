local ADDON, SBG = ...

local UI = {}
SBG.UI = UI

local MAX_EL = 16
local MAX_STEPS = 80
local PAD = 10
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
    btn:SetSize(14, 14)
    if btn.SetHitRectInsets then btn:SetHitRectInsets(-4, -4, -4, -4) end
    local text = _G[name and (name .. "Text")]
    if text then
        text:SetText("")
        text:Hide()
    end
    -- Soften stock checkbox chrome
    pcall(function()
        btn:SetPushedTexture("")
        btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")
    end)
    return btn
end

local function ToggleElement(slot)
    if not slot or not slot.el or slot.el.textOnly then return end
    local checked = not slot.check:GetChecked()
    slot.check:SetChecked(checked)
    SBG.Engine:SetElementSkip(slot.el, checked)
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
            if g.locked then
                table.insert(items, {
                    text = (g.displayname or g.name) .. " |cffff5555(Locked)|r",
                    disabled = true,
                })
            else
                table.insert(items, {
                    text = g.displayname or g.name,
                    func = function() SBG.Engine:Load(g.key) end,
                })
            end
        end
    end
    SBG.ShowDrop(items, "cursor")
end

function UI:Init()
    local s = SBG.GetSettings()
    local f = CreateFrame("Frame", "SBGStepFrame", UIParent, BackdropTemplate)
    f:SetSize(s.windowW or 248, s.windowH or 280)
    f:SetPoint("LEFT", UIParent, "LEFT", 12, 40)
    f:SetFrameStrata("MEDIUM")
    f:SetToplevel(true)
    f:SetMovable(true)
    f:SetResizable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f:Hide()
    self.frame = f
    SBG.Paint(f, nil, "glass")
    -- Do not clip children: current-step window sits ABOVE this frame (RXP layout).

    local FOOTER_H = 22
    local HEADER_H = 34
    local GAP = 4
    f._chrome = { footer = FOOTER_H, header = HEADER_H, gap = GAP, pad = PAD }

    local function dragStart(_, button, resize)
        if SBG.GetSettings().lockFrames then return end
        if resize then
            if f:IsMoving() then f:StopMovingOrSizing() end
            if not f.sizing then
                f.sizing = true
                f:StartSizing("BOTTOMRIGHT")
            end
        else
            -- Guard: if already moving (e.g. parent OnMouseDown already called this),
            -- do nothing — prevents the grab-offset snap caused by double StartMoving().
            if f:IsMoving() or f.sizing then return end
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
        else
            -- Persist the new position so it survives Apply/Refresh
            local st = SBG.GetSettings()
            st.savedX = f:GetLeft()
            st.savedY = f:GetTop()
        end
    end
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnMouseDown", function(_, button)
        if button == "RightButton" then UI:HeaderMenu() else dragStart(_, button) end
    end)
    f:SetScript("OnMouseUp", dragStop)
    -- Live reflow while the resize grip is held (Details-style).
    f:SetScript("OnSizeChanged", function(self)
        if not self.sizing or self._layoutLock then return end
        local st = SBG.GetSettings()
        st.windowW = math.floor(self:GetWidth() + 0.5)
        st.windowH = math.floor(self:GetHeight() + 0.5)
        UI:Refresh()
    end)
    if f.SetResizeBounds then
        f:SetResizeBounds(220, 100, 520, 720)
    else
        if f.SetMinResize then f:SetMinResize(220, 100) end
        if f.SetMaxResize then f:SetMaxResize(520, 720) end
    end

    ------------------------------------------------------------------
    -- BOTTOM WINDOW chrome: guide header (not separately resized)
    ------------------------------------------------------------------
    local header = CreateFrame("Button", "SBGGuideName", f, BackdropTemplate)
    header:SetPoint("TOPLEFT", PAD, -PAD)
    header:SetPoint("TOPRIGHT", -PAD, -PAD)
    header:SetHeight(HEADER_H)
    header:SetFrameLevel(10)
    header:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function() dragStart(nil, "LeftButton") end)
    header:SetScript("OnDragStop", dragStop)
    header:SetScript("OnClick", function(_, button)
        if button == "RightButton" then UI:HeaderMenu() end
    end)
    header:SetScript("OnEnter", function(self)
        if self.chipVeil then self.chipVeil:SetColorTexture(0.08, 0.10, 0.16, 0.18) end
        if self.chipSheen then self.chipSheen:SetColorTexture(1, 1, 1, 0.18) end
    end)
    header:SetScript("OnLeave", function(self)
        if self.chipVeil then self.chipVeil:SetColorTexture(0.03, 0.04, 0.07, 0.25) end
        if self.chipSheen then self.chipSheen:SetColorTexture(1, 1, 1, 0.10) end
    end)
    f.header = header
    SBG.StyleGlassChip(header, "chip")

    f.logo = header:CreateTexture(nil, "ARTWORK")
    f.logo:SetPoint("LEFT", 12, 0)
    f.logo:SetSize(22, 22)
    f.logo:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    f.logo:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    f.factionIcon = header:CreateTexture(nil, "OVERLAY")
    f.factionIcon:SetPoint("BOTTOMRIGHT", f.logo, "BOTTOMRIGHT", 3, -3)
    f.factionIcon:SetSize(14, 14)
    f.factionIcon:Hide()

    f.title = SBG.MakeText(header, "GameFontNormal")
    f.title:SetPoint("LEFT", f.logo, "RIGHT", 8, 0)
    f.title:SetPoint("RIGHT", -14, 0)
    f.title:SetJustifyH("LEFT")
    f.title:SetWordWrap(false)

    ------------------------------------------------------------------
    -- TOP WINDOW: current step (RXP-style, sits ABOVE the bottom window)
    ------------------------------------------------------------------
    -- TOP WINDOW: current step — sits ABOVE the main frame, same width, floating with gap.
    local current = CreateFrame("Frame", "SBGCurrentStep", UIParent, BackdropTemplate)
    current:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 8)
    current:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", 0, 8)
    current:SetHeight(56)
    current:EnableMouse(true)
    current:RegisterForDrag("LeftButton")
    current:SetScript("OnMouseDown", function(_, button)
        if button == "RightButton" then UI:HeaderMenu() else dragStart(nil, button) end
    end)
    current:SetScript("OnMouseUp", dragStop)
    f.current = current
    SBG.Paint(current, nil, "glass")

    current.badge = CreateFrame("Button", nil, current, BackdropTemplate)
    current.badge:SetPoint("TOPLEFT", 8, -6)
    current.badge:SetSize(72, 22)
    current.badge:EnableMouse(true)
    current.badge:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    current.badge.glass = current.badge:CreateTexture(nil, "BACKGROUND")
    current.badge.glass:SetAllPoints()
    current.badge.glass:SetTexture(SBG.GLASS_TEX)
    current.badge.glass:SetTexCoord(0.35, 0.65, 0.20, 0.45)
    current.badge.veil = current.badge:CreateTexture(nil, "BACKGROUND", nil, 1)
    current.badge.veil:SetAllPoints()
    current.badge.veil:SetColorTexture(0.04, 0.06, 0.10, 0.55)
    current.badge.sheen = current.badge:CreateTexture(nil, "BORDER")
    current.badge.sheen:SetPoint("TOPLEFT", 1, -1)
    current.badge.sheen:SetPoint("TOPRIGHT", -1, -1)
    current.badge.sheen:SetHeight(8)
    current.badge.sheen:SetColorTexture(1, 1, 1, 0.14)
    local function rimEdge(parent, point)
        local e = parent:CreateTexture(nil, "OVERLAY")
        e:SetColorTexture(1, 1, 1, 0.28)
        if point == "T" then
            e:SetPoint("TOPLEFT"); e:SetPoint("TOPRIGHT"); e:SetHeight(1)
        elseif point == "B" then
            e:SetPoint("BOTTOMLEFT"); e:SetPoint("BOTTOMRIGHT"); e:SetHeight(1)
        elseif point == "L" then
            e:SetPoint("TOPLEFT"); e:SetPoint("BOTTOMLEFT"); e:SetWidth(1)
        else
            e:SetPoint("TOPRIGHT"); e:SetPoint("BOTTOMRIGHT"); e:SetWidth(1)
        end
        return e
    end
    rimEdge(current.badge, "T"); rimEdge(current.badge, "B")
    rimEdge(current.badge, "L"); rimEdge(current.badge, "R")

    current.badgeText = SBG.MakeText(current.badge, "GameFontNormalSmall")
    current.badgeText:SetPoint("CENTER", 0, 0)
    current.badge:SetScript("OnEnter", function(self)
        if self.veil then self.veil:SetColorTexture(0.08, 0.10, 0.16, 0.35) end
        if self.sheen then self.sheen:SetColorTexture(1, 1, 1, 0.22) end
    end)
    current.badge:SetScript("OnLeave", function(self)
        if self.veil then self.veil:SetColorTexture(0.04, 0.06, 0.10, 0.55) end
        if self.sheen then self.sheen:SetColorTexture(1, 1, 1, 0.14) end
    end)
    current.badge:SetScript("OnClick", function(_, button)
        if button == "RightButton" then UI:HeaderMenu() end
    end)

    current.hint = SBG.MakeText(current, "GameFontDisableSmall")
    current.hint:SetPoint("TOPRIGHT", -8, -8)
    current.hint:SetText("click line to skip")
    current.hint:SetAlpha(0.55)

    -- Content sits BELOW the Step badge (6px top + 22px badge + 8px gap = 36px).
    -- This ensures text never overlaps the badge or the frame top border.
    local content = CreateFrame("Frame", nil, current)
    content:SetPoint("TOPLEFT", 0, -36)
    content:SetPoint("TOPRIGHT", 0, -36)
    content:SetPoint("BOTTOMLEFT", 0, 4)
    content:SetPoint("BOTTOMRIGHT", 0, 4)
    current.content = content

    current.elements = {}
    for i = 1, MAX_EL do
        local el = CreateFrame("Button", "SBGCurEl" .. i, content)
        el:SetHeight(18)
        el:EnableMouse(true)
        el:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        el.hl = el:CreateTexture(nil, "HIGHLIGHT")
        el.hl:SetAllPoints()
        el.hl:SetTexture("Interface\\Worldmap\\UI-QuestPoi-HighlightBar")
        el.hl:SetBlendMode("ADD")
        el.hl:SetAlpha(0.55)

        el.check = MakeCheck(el, "SBGCurEl" .. i .. "Check")
        el.check:SetPoint("TOPLEFT", 8, -1)

        el.text = SBG.MakeText(el, "GameFontHighlight")
        el.text:SetPoint("TOPLEFT", el.check, "TOPRIGHT", 8, 0)
        el.text:SetPoint("RIGHT", el, "RIGHT", -8, 0)
        el.text:SetJustifyH("LEFT")
        el.text:SetJustifyV("TOP")
        el.text:SetWordWrap(true)
        pcall(function() el.text:SetNonSpaceWrap(true) end)

        el.check:SetScript("OnClick", function(self)
            if el.el then SBG.Engine:SetElementSkip(el.el, self:GetChecked()) end
        end)
        el.check:HookScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -6)
            GameTooltip:AddLine("Skip this objective", 1, 1, 1)
            GameTooltip:Show()
        end)
        el.check:HookScript("OnLeave", function() GameTooltip:Hide() end)

        el:SetScript("OnEnter", function(self)
            if self.el and not self.el.textOnly then
                SBG.Paint(self, 1, "hover")
                current.hint:SetAlpha(0.9)
            end
        end)
        el:SetScript("OnLeave", function(self)
            SBG.Paint(self, nil, "clear")
            current.hint:SetAlpha(0.55)
        end)
        el:SetScript("OnClick", function(self, button)
            if button == "RightButton" then
                UI:HeaderMenu()
                return
            end
            ToggleElement(self)
        end)

        el:Hide()
        current.elements[i] = el
    end

    ------------------------------------------------------------------
    -- FOOTER (bottom chrome, always inside)
    ------------------------------------------------------------------
    local footer = CreateFrame("Frame", "SBGFooter", f, BackdropTemplate)
    footer:SetPoint("BOTTOMLEFT", PAD, 4)
    footer:SetPoint("BOTTOMRIGHT", -PAD, 4)
    footer:SetHeight(FOOTER_H - 4)
    footer:SetFrameLevel(10)
    footer:EnableMouse(true)
    footer:RegisterForDrag("LeftButton")
    footer:SetScript("OnMouseDown", function(_, button)
        if button == "RightButton" then UI:HeaderMenu() else dragStart(nil, button) end
    end)
    footer:SetScript("OnMouseUp", dragStop)
    f.footer = footer
    SBG.Paint(footer, nil, "clear")

    f.cog = CreateFrame("Button", nil, footer)
    f.cog:SetSize(18, 18)
    f.cog:SetPoint("LEFT", 0, 0)
    local cogTex = f.cog:CreateTexture(nil, "ARTWORK")
    cogTex:SetPoint("CENTER")
    cogTex:SetSize(15, 15)
    cogTex:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
    cogTex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    f.cog.icon = cogTex
    f.cog:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    f.cog:SetScript("OnClick", function() UI:HeaderMenu() end)
    f.cog:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Settings", 1, 1, 1)
        GameTooltip:AddLine("Open options and guide menu", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    f.cog:SetScript("OnLeave", function() GameTooltip:Hide() end)

    f.footText = SBG.MakeText(footer, "GameFontDisableSmall")
    f.footText:SetPoint("LEFT", 20, 0)
    f.footText:SetPoint("RIGHT", -18, 0)
    f.footText:SetJustifyH("LEFT")
    f.footText:SetText("Sweat Beta Guide")

    local grab = CreateFrame("Button", nil, f)
    grab:SetSize(16, 16)
    grab:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 2)
    grab:SetFrameLevel(20)
    grab:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grab:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grab:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    grab:SetScript("OnMouseDown", function(self)
        dragStart(nil, "LeftButton", true)
        self:SetScript("OnUpdate", function(btn)
            if not IsMouseButtonDown("LeftButton") then
                btn:SetScript("OnUpdate", nil)
                dragStop()
            end
        end)
    end)
    grab:SetScript("OnMouseUp", function(self)
        self:SetScript("OnUpdate", nil)
        dragStop()
    end)
    f.grab = grab

    ------------------------------------------------------------------
    -- SCROLL LIST (bottom window body — under guide header)
    ------------------------------------------------------------------
    local body = CreateFrame("Frame", "SBGBottomFrame", f, BackdropTemplate)
    body:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -GAP)
    body:SetPoint("BOTTOMRIGHT", footer, "TOPRIGHT", 0, GAP)
    f.bottom = body
    SBG.Paint(body, nil, "clear")

    local scroll = CreateFrame("ScrollFrame", "SBGScrollFrame", body, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 2, -2)
    scroll:SetPoint("BOTTOMRIGHT", -22, 2)
    f.scroll = scroll
    local child = CreateFrame("Frame", "SBGScrollChild", scroll)
    child:SetSize(200, 200)
    scroll:SetScrollChild(child)
    f.child = child

    f.stepRows = {}
    for i = 1, MAX_STEPS do
        local row = CreateFrame("Button", "SBGStepRow" .. i, child, BackdropTemplate)
        row:SetHeight(24)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        row:EnableMouse(true)

        row.hl = row:CreateTexture(nil, "HIGHLIGHT")
        row.hl:SetAllPoints()
        row.hl:SetTexture("Interface\\Worldmap\\UI-QuestPoi-HighlightBar")
        row.hl:SetBlendMode("ADD")
        row.hl:SetAlpha(0.4)

        row.num = SBG.MakeText(row, "GameFontNormalSmall")
        row.num:SetPoint("BOTTOMRIGHT", -4, 3)
        row.body = SBG.MakeText(row, "GameFontHighlightSmall")
        row.body:SetPoint("TOPLEFT", 8, -5)
        row.body:SetPoint("BOTTOMRIGHT", row.num, "BOTTOMLEFT", -4, 0)
        row.body:SetJustifyH("LEFT")
        row.body:SetJustifyV("TOP")
        row.body:SetWordWrap(true)

        row:SetScript("OnEnter", function(self)
            SBG.Paint(self, 1, "hover")
            self:SetAlpha(1)
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

    self:Apply()
end

function UI:PaintStepRow(row)
    if not row then return end
    local cur = SBG.Engine.stepIndex or 1
    if row.stepIndex == cur then
        SBG.Paint(row, 1, "hover")
        row:SetAlpha(1)
        SBG.ColorSet(row.body, "text")
        SBG.ColorSet(row.num, "accent")
    else
        SBG.Paint(row, nil, "clear")
        row:SetAlpha(row.stepIndex and row.stepIndex < cur and 0.45 or 0.72)
        SBG.ColorSet(row.body, "body")
        SBG.ColorSet(row.num, "muted")
    end
end

local FACTION_ICON = {
    Alliance = "Interface\\TargetingFrame\\UI-PVP-Alliance",
    Horde = "Interface\\TargetingFrame\\UI-PVP-Horde",
}

function UI:SetGuideIcon(guide)
    local f = self.frame
    if not f or not f.logo then return end
    local icon = (guide and guide.icon) or "Interface\\Icons\\INV_Misc_Book_09"
    f.logo:SetTexture(icon)
    f.logo:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    local faction = guide and guide.enabledFor
    if not faction and SBG.player then
        faction = SBG.player.faction
    end
    if f.factionIcon then
        local tex = faction and FACTION_ICON[faction]
        if tex then
            f.factionIcon:SetTexture(tex)
            -- PVP crests are tall; crop to the emblem
            if faction == "Alliance" then
                f.factionIcon:SetTexCoord(0.07, 0.60, 0.03, 0.62)
            else
                f.factionIcon:SetTexCoord(0.05, 0.58, 0.05, 0.62)
            end
            f.factionIcon:Show()
        else
            f.factionIcon:Hide()
        end
    end
end

function UI:PaintStepBadge()
    local badge = self.frame and self.frame.current and self.frame.current.badge
    if not badge then return end
    if badge.glass then
        badge.glass:SetTexture(SBG.GLASS_TEX)
        badge.glass:Show()
    end
    if badge.veil then badge.veil:SetColorTexture(0.04, 0.06, 0.10, 0.55) end
    if badge.sheen then badge.sheen:SetColorTexture(1, 1, 1, 0.14) end
end

function UI:Apply()
    local f = self.frame
    if not f or not f.title then return end
    local s = SBG.GetSettings()
    local font = SBG.Font()
    local fs = s.fontSize or 11
    local titleSz = s.titleSize or 12
    local flags = SBG.FontFlags()

    SBG.Paint(f, s.opacity or 1, "glass")
    SBG.Paint(f.current, s.opacity or 1, "glass")
    SBG.StyleGlassChip(f.header, "chip")
    SBG.Paint(f.bottom, nil, "clear")
    SBG.Paint(f.footer, nil, "clear")
    self:PaintStepBadge()

    if f.cog and f.cog.icon then
        f.cog.icon:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
        f.cog.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end

    f:SetScale(s.scale or 1)
    if not f.sizing then
        f._layoutLock = true
        if s.windowW then f:SetWidth(s.windowW) end
        if s.windowH then f:SetHeight(s.windowH) end
        f._layoutLock = false
    end

    f.title:SetFont(font, titleSz, flags)
    SBG.ColorSet(f.title, "title")
    f.current.badgeText:SetFont(font, fs, flags)
    SBG.ColorSet(f.current.badgeText, "accent")
    f.current.hint:SetFont(font, math.max(9, fs - 2), "")
    SBG.ColorSet(f.current.hint, "muted")
    f.footText:SetFont(font, math.max(9, fs - 2), flags)
    SBG.ColorSet(f.footText, "muted")

    for i = 1, MAX_EL do
        f.current.elements[i].text:SetFont(font, fs, flags)
        SBG.ColorSet(f.current.elements[i].text, "body")
    end
    for i = 1, MAX_STEPS do
        f.stepRows[i].body:SetFont(font, fs, flags)
        f.stepRows[i].num:SetFont(font, math.max(9, fs - 1), flags)
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
        if f.current then f.current:Hide() end
        return
    end
    if not self.dismissed then
        f:Show()
        if f.current then f.current:Show() end
    end

    local index = engine.stepIndex or 1
    local total = #guide.steps
    local step = engine:ActiveStep()
    local frameW = f:GetWidth() or 248
    local wrapW = math.max(140, frameW - (PAD * 2) - 36)

    f.title:SetText(guide.displayname or guide.name)
    f.current.badgeText:SetText("Step " .. index)
    f.current.badge:SetWidth(math.max(64, f.current.badgeText:GetStringWidth() + 18))
    f.current.badge:SetHeight(22)
    self:PaintStepBadge()
    self:SetGuideIcon(guide)
    f.footText:SetText(string.format("Sweat  %d / %d", index, total))

    local shown = 0
    local height = 40 -- badge row reserved above content (6px top + 22px badge + 8px gap + 4px pad)
    for _, elData in ipairs(step and step.elements or {}) do
        local line = LineText(elData)
        if line then
            shown = shown + 1
            if shown > MAX_EL then break end
            local slot = f.current.elements[shown]
            slot.el = elData
            slot:Show()
            slot:ClearAllPoints()
            slot:SetPoint("LEFT")
            slot:SetPoint("RIGHT")
            if shown == 1 then
                slot:SetPoint("TOPLEFT", f.current.content or f.current, "TOPLEFT", 0, 0)
            else
                slot:SetPoint("TOPLEFT", f.current.elements[shown - 1], "BOTTOMLEFT", 0, -2)
            end
            slot.text:SetWidth(wrapW - 24)
            slot.text:SetText(line)
            local h = 16
            if slot.text.GetStringHeight then
                h = math.max(16, math.ceil((slot.text:GetStringHeight() or 12) * 1.15) + 2)
            end
            slot:SetHeight(h)
            SBG.Paint(slot, nil, "clear")
            if elData.textOnly then
                slot.check:SetChecked(true)
                slot.check:Hide()
            else
                slot.check:Show()
                slot.check:SetChecked(elData.completed and true or false)
            end
            height = height + h + 2
        end
    end
    for i = shown + 1, MAX_EL do
        f.current.elements[i]:Hide()
        f.current.elements[i].el = nil
    end
    -- Top window auto-heights to content; bottom window resize does not clip it.
    f.current:SetHeight(math.max(56, height + 6))

    local y = 2
    local childW = math.max(160, (f.scroll:GetWidth() or (frameW - 40)))
    f.child:SetWidth(childW)
    for i = 1, total do
        local row = f.stepRows[i]
        if not row then break end
        local st = guide.steps[i]
        local chunks = {}
        for _, elData in ipairs(st.elements) do
            local line = LineText(elData)
            if line then table.insert(chunks, line) end
        end
        local body = table.concat(chunks, "\n")
        if body == "" then body = "Click to continue" end
        row.stepIndex = i
        row.num:SetText(i < 10 and ("0" .. i) or tostring(i))
        row.body:SetWidth(childW - 32)
        row.body:SetText(body)
        local rh = 22
        if row.body.GetStringHeight then
            rh = math.max(22, math.ceil((row.body:GetStringHeight() or 12) + 10))
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 0, -y)
        row:SetPoint("TOPRIGHT", 0, -y)
        row:SetHeight(rh)
        row:Show()
        self:PaintStepRow(row)
        y = y + rh + 2
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
            pos = pos + (f.stepRows[i]:GetHeight() or 22) + 2
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
        if self.frame.current then self.frame.current:Show() end
        self:Apply()
    end
end

function UI:Toggle()
    if not self.frame then return end
    if self.frame:IsShown() then
        self.dismissed = true
        self.frame:Hide()
        if self.frame.current then self.frame.current:Hide() end
    else
        self:Show()
    end
end
