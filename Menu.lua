local ADDON, SBG = ...

local Menu = {}
SBG.Menu = Menu

function Menu:Init()
    local overlay = CreateFrame("Frame", "SBGMenuOverlay", UIParent)
    overlay:SetAllPoints(UIParent)
    overlay:SetFrameStrata("DIALOG")
    overlay:EnableMouse(true)
    overlay.dim = overlay:CreateTexture(nil, "BACKGROUND")
    overlay.dim:SetAllPoints()
    overlay.dim:SetColorTexture(0, 0, 0, 0.55)
    overlay:Hide()
    overlay:SetScript("OnMouseUp", function()
        if not Menu.forceWelcome then overlay:Hide() end
    end)
    pcall(function()
        overlay:EnableKeyboard(true)
        overlay:SetScript("OnKeyDown", function(self, key)
            if key == "ESCAPE" then self:Hide() end
        end)
        if overlay.SetPropagateKeyboardInput then
            overlay:SetScript("OnShow", function(self)
                self:EnableKeyboard(true)
                self:SetPropagateKeyboardInput(false)
            end)
        end
    end)
    self.overlay = overlay

    local BackdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
    local panel = CreateFrame("Frame", "SBGMenuPanel", overlay, BackdropTemplate)
    panel:SetSize(440, 360)
    panel:SetPoint("CENTER")
    panel:EnableMouse(true)
    panel:SetScript("OnMouseUp", function() end)
    self.panel = panel
    SBG.Paint(panel, nil, "glass")
    pcall(function() panel:SetClipsChildren(true) end)

    -- Rounded liquid-glass header matching the main guide window
    local titleBar = CreateFrame("Frame", nil, panel)
    titleBar:SetPoint("TOPLEFT", 14, -14)
    titleBar:SetPoint("TOPRIGHT", -14, -14)
    titleBar:SetHeight(36)
    self.titleBar = titleBar
    SBG.StyleGlassChip(titleBar, "chip")

    self.brandIcon = titleBar:CreateTexture(nil, "ARTWORK")
    self.brandIcon:SetSize(22, 22)
    self.brandIcon:SetPoint("LEFT", 12, 0)
    self.brandIcon:SetTexture(SBG.ICON_TEX)
    self.brandIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    self.logo = SBG.MakeText(titleBar, "GameFontNormal")
    self.logo:SetPoint("LEFT", self.brandIcon, "RIGHT", 8, 0)
    self.logo:SetText("Nexus")

    self.title = SBG.MakeText(titleBar, "GameFontHighlight")
    self.title:SetPoint("LEFT", self.logo, "RIGHT", 10, 0)
    self.title:SetText("")

    local close = SBG.MakeGlassButton(titleBar, "X", 28, 24, function()
        Menu.forceWelcome = false
        overlay:Hide()
    end)
    close:SetPoint("RIGHT", -8, 0)
    self.closeBtn = close

    local opt = SBG.MakeGlassButton(titleBar, "Options", 78, 24, function()
        Menu.forceWelcome = false
        overlay:Hide()
        if SBG.Options then SBG.Options:Toggle() end
    end)
    opt:SetPoint("RIGHT", close, "LEFT", -6, 0)
    self.optBtn = opt

    self.hint = SBG.MakeText(panel, "GameFontDisableSmall")
    self.hint:SetPoint("TOPLEFT", 20, -58)
    self.hint:SetPoint("RIGHT", -20, 0)
    self.hint:SetJustifyH("LEFT")
    self.hint:SetWordWrap(true)
    self.hint:SetText("Choose a guide")

    self.welcome = SBG.MakeText(panel, "GameFontHighlight")
    self.welcome:SetPoint("TOPLEFT", 20, -58)
    self.welcome:SetPoint("RIGHT", -20, 0)
    self.welcome:SetJustifyH("LEFT")
    self.welcome:SetWordWrap(true)
    self.welcome:Hide()

    self.rows = {}
    for i = 1, 6 do
        local row = CreateFrame("Button", nil, panel)
        row:SetHeight(44)
        row:SetPoint("TOPLEFT", 18, -96 - (i - 1) * 48)
        row:SetPoint("TOPRIGHT", -18, -96 - (i - 1) * 48)
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(28, 28)
        row.icon:SetPoint("LEFT", 10, 0)
        row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        row.faction = row:CreateTexture(nil, "OVERLAY")
        row.faction:SetSize(14, 14)
        row.faction:SetPoint("BOTTOMRIGHT", row.icon, "BOTTOMRIGHT", 3, -3)
        row.faction:Hide()
        row.lock = row:CreateTexture(nil, "OVERLAY")
        row.lock:SetSize(16, 16)
        row.lock:SetPoint("TOPRIGHT", row.icon, "TOPRIGHT", 2, 2)
        row.lock:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
        -- Prefer a padlock if present; Pass icon is a clear "blocked" fallback.
        pcall(function()
            row.lock:SetTexture("Interface\\Buttons\\LockButton-Locked-Up")
        end)
        row.lock:Hide()
        row.lockBadge = SBG.MakeText(row, "GameFontNormalSmall")
        row.lockBadge:SetPoint("RIGHT", -12, 0)
        row.lockBadge:SetText("|cffff5555Locked|r")
        row.lockBadge:Hide()
        row.name = SBG.MakeText(row, "GameFontNormal")
        row.name:SetPoint("TOPLEFT", 48, -8)
        row.name:SetPoint("RIGHT", row.lockBadge, "LEFT", -8, 0)
        row.name:SetJustifyH("LEFT")
        row.sub = SBG.MakeText(row, "GameFontHighlightSmall")
        row.sub:SetPoint("TOPLEFT", 48, -24)
        row.sub:SetPoint("RIGHT", -12, 0)
        row.sub:SetJustifyH("LEFT")
        row:SetScript("OnEnter", function(self)
            if self.bg then
                if self.locked then
                    self.bg:SetColorTexture(1, 0.35, 0.35, 0.12)
                else
                    self.bg:SetColorTexture(1, 1, 1, 0.12)
                end
            end
            if self.locked then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine(self.guideName or "Guide", 1, 1, 1)
                GameTooltip:AddLine(self.lockedReason or "Locked for this character", 1, 0.35, 0.35, true)
                GameTooltip:Show()
            end
        end)
        row:SetScript("OnLeave", function(self)
            if self.locked then
                SBG.Fill(self, { 1, 0.4, 0.4 }, 0.06)
            else
                SBG.Fill(self, { 1, 1, 1 }, 0.06)
            end
            GameTooltip:Hide()
        end)
        SBG.Fill(row, { 1, 1, 1 }, 0.06)
        self.rows[i] = row
    end

    local mini = CreateFrame("Button", "SBGMinimapButton", Minimap)
    mini:SetSize(32, 32)
    mini:SetFrameStrata("MEDIUM")
    mini:SetFrameLevel(8)
    mini:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -12, -80)
    mini:SetMovable(true)
    mini:RegisterForDrag("LeftButton")
    mini:SetScript("OnDragStart", mini.StartMoving)
    mini:SetScript("OnDragStop", mini.StopMovingOrSizing)

    -- Icon must sit inside the gold ring (≈18–20px), never SetAllPoints on 32x32.
    local mtex = mini:CreateTexture(nil, "ARTWORK")
    mtex:SetSize(18, 18)
    mtex:SetPoint("CENTER", 0, 1)
    mtex:SetTexture(SBG.ICON_TEX)
    mtex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    mini.icon = mtex

    local border = mini:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(52, 52)
    border:SetPoint("TOPLEFT", mini, "TOPLEFT", -9, 9)
    mini.border = border

    mini:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")
    mini:SetScript("OnClick", function() Menu:Toggle() end)
    mini:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Nexus", 0.91, 0.72, 0.29)
        GameTooltip:AddLine("Click to pick a guide", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Right-click the viewer header for more", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)
    mini:SetScript("OnLeave", function() GameTooltip:Hide() end)
    self.minimap = mini
    self:Apply()
end

function Menu:Apply()
    local s = SBG.GetSettings()
    local font = SBG.Font()
    if not self.panel then return end
    SBG.Paint(self.panel, nil, "glass")
    if self.titleBar then SBG.StyleGlassChip(self.titleBar, "chip") end
    if self.brandIcon then
        self.brandIcon:SetTexture(SBG.ICON_TEX)
    end
    self.logo:SetFont(font, s.headerSize or 13, SBG.FontFlags())
    SBG.ColorSet(self.logo, "title")
    self.title:SetFont(font, 12, "")
    self.hint:SetFont(font, 11, "")
    SBG.ColorSet(self.hint, "muted")
    if self.welcome then
        self.welcome:SetFont(font, 12, "")
        SBG.ColorSet(self.welcome, "body")
    end
    for i = 1, #self.rows do
        local row = self.rows[i]
        SBG.Fill(row, { 1, 1, 1 }, 0.06)
        row.name:SetFont(font, 13, SBG.FontFlags())
        row.sub:SetFont(font, 11, "")
        SBG.ColorSet(row.name, "text")
        SBG.ColorSet(row.sub, "muted")
    end
    if self.optBtn and self.optBtn.PaintTheme then self.optBtn:PaintTheme() end
    if self.closeBtn and self.closeBtn.PaintTheme then self.closeBtn:PaintTheme() end
    if self.minimap then
        if self.minimap.icon then
            self.minimap.icon:ClearAllPoints()
            self.minimap.icon:SetSize(18, 18)
            self.minimap.icon:SetPoint("CENTER", 0, 1)
            self.minimap.icon:SetTexture(SBG.ICON_TEX)
            self.minimap.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        end
        if s.showMinimapButton then self.minimap:Show() else self.minimap:Hide() end
    end
end

function Menu:Refresh()
    local shown = {}
    for _, guide in ipairs(SBG.guides) do
        table.insert(shown, guide)
    end
    table.sort(shown, function(a, b)
        if (not a.locked) ~= (not b.locked) then
            return not a.locked
        end
        return (a.subtitle or a.displayname or a.name) < (b.subtitle or b.displayname or b.name)
    end)
    for i, row in ipairs(self.rows) do
        local guide = shown[i]
        if guide then
            row:Show()
            row.locked = guide.locked and true or false
            row.guideName = guide.displayname or guide.name
            row.lockedReason = guide.lockedReason
            row.icon:SetTexture(guide.icon or "Interface\\Icons\\INV_Misc_Book_09")
            if row.faction then
                local fac = guide.enabledFor
                if fac == "Alliance" then
                    row.faction:SetTexture("Interface\\TargetingFrame\\UI-PVP-Alliance")
                    row.faction:SetTexCoord(0.07, 0.60, 0.03, 0.62)
                    row.faction:Show()
                elseif fac == "Horde" then
                    row.faction:SetTexture("Interface\\TargetingFrame\\UI-PVP-Horde")
                    row.faction:SetTexCoord(0.05, 0.58, 0.05, 0.62)
                    row.faction:Show()
                else
                    row.faction:Hide()
                end
            end
            row.name:SetText(guide.displayname or guide.name)
            if guide.locked then
                row.sub:SetText((guide.subtitle or "") .. "  ·  wrong faction")
                row.lock:Show()
                row.lockBadge:Show()
                if row.icon.SetDesaturated then row.icon:SetDesaturated(true) end
                row.icon:SetVertexColor(0.45, 0.45, 0.45, 1)
                row.name:SetTextColor(0.55, 0.55, 0.55)
                row.sub:SetTextColor(0.55, 0.35, 0.35)
                row:SetAlpha(0.85)
                SBG.Fill(row, { 1, 0.4, 0.4 }, 0.06)
                row:SetScript("OnClick", function()
                    SBG.Print(guide.lockedReason or "This guide is locked for your faction.")
                end)
            else
                row.sub:SetText(guide.subtitle or guide.group or "")
                row.lock:Hide()
                row.lockBadge:Hide()
                if row.icon.SetDesaturated then row.icon:SetDesaturated(false) end
                row.icon:SetVertexColor(1, 1, 1, 1)
                SBG.ColorSet(row.name, "text")
                SBG.ColorSet(row.sub, "muted")
                row:SetAlpha(1)
                SBG.Fill(row, { 1, 1, 1 }, 0.06)
                row:SetScript("OnClick", function()
                    Menu.forceWelcome = false
                    if Menu.welcome then Menu.welcome:Hide() end
                    self.overlay:Hide()
                    SBG.Engine:Load(guide.key, 1)
                end)
            end
        else
            row:Hide()
            row.locked = false
        end
    end
end

function Menu:ShowWelcome()
    if not self.overlay then return end
    self.forceWelcome = true
    self:Refresh()
    if self.welcome then
        self.welcome:SetText("Welcome to Nexus.\nThis character has no guide yet — pick one to start leveling.")
        self.welcome:Show()
        self.welcome:SetHeight(36)
    end
    if self.hint then self.hint:Hide() end
    self.overlay:Show()
end

function Menu:Toggle()
    if not self.overlay then return end
    if self.overlay:IsShown() then
        self.forceWelcome = false
        self.overlay:Hide()
    else
        self.forceWelcome = false
        if self.welcome then self.welcome:Hide() end
        if self.hint then
            self.hint:SetText("Choose a guide")
            self.hint:Show()
        end
        self:Refresh()
        self.overlay:Show()
    end
end
