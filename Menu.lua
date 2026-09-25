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
    if panel.SetBackdrop then
        panel:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 },
        })
        panel:SetBackdropColor(0, 0, 0, 1)
    else
        SBG.Fill(panel, { 0.05, 0.05, 0.08 }, 1)
    end

    local titleBar = CreateFrame("Frame", nil, panel)
    titleBar:SetPoint("TOPLEFT", 12, -12)
    titleBar:SetPoint("TOPRIGHT", -12, -12)
    titleBar:SetHeight(28)
    self.titleBar = titleBar

    self.logo = SBG.MakeText(titleBar, "GameFontNormalLarge")
    self.logo:SetPoint("LEFT", 8, 0)
    self.logo:SetText("Sweat Beta Guide")

    self.title = SBG.MakeText(titleBar, "GameFontHighlight")
    self.title:SetPoint("LEFT", self.logo, "RIGHT", 10, 0)
    self.title:SetText("")

    local close
    pcall(function()
        close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    end)
    if not close then
        close = SBG.ChromeBtn(titleBar, "close", "Close", function()
            Menu.forceWelcome = false
            overlay:Hide()
        end)
    else
        close:SetScript("OnClick", function()
            Menu.forceWelcome = false
            overlay:Hide()
        end)
    end
    close:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -4, -4)
    self.closeBtn = close

    local opt = CreateFrame("Button", nil, titleBar, "UIPanelButtonTemplate")
    opt:SetSize(80, 22)
    opt:SetPoint("RIGHT", -8, 0)
    opt:SetText("Options")
    opt:SetScript("OnClick", function()
        Menu.forceWelcome = false
        overlay:Hide()
        if SBG.Options then SBG.Options:Toggle() end
    end)
    self.optBtn = opt

    self.hint = SBG.MakeText(panel, "GameFontDisableSmall")
    self.hint:SetPoint("TOPLEFT", 20, -48)
    self.hint:SetPoint("RIGHT", -20, 0)
    self.hint:SetJustifyH("LEFT")
    self.hint:SetWordWrap(true)
    self.hint:SetText("Choose a guide")

    self.welcome = SBG.MakeText(panel, "GameFontHighlight")
    self.welcome:SetPoint("TOPLEFT", 20, -48)
    self.welcome:SetPoint("RIGHT", -20, 0)
    self.welcome:SetJustifyH("LEFT")
    self.welcome:SetWordWrap(true)
    self.welcome:Hide()

    self.rows = {}
    for i = 1, 6 do
        local row = CreateFrame("Button", nil, panel)
        row:SetHeight(44)
        row:SetPoint("TOPLEFT", 18, -92 - (i - 1) * 48)
        row:SetPoint("TOPRIGHT", -18, -92 - (i - 1) * 48)
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(28, 28)
        row.icon:SetPoint("LEFT", 10, 0)
        row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        row.name = SBG.MakeText(row, "GameFontNormal")
        row.name:SetPoint("TOPLEFT", 48, -8)
        row.name:SetJustifyH("LEFT")
        row.sub = SBG.MakeText(row, "GameFontHighlightSmall")
        row.sub:SetPoint("TOPLEFT", 48, -24)
        row.sub:SetJustifyH("LEFT")
        row:SetScript("OnEnter", function(self)
            local t = SBG.Theme()
            if self.bg then self.bg:SetColorTexture(t.hover[1], t.hover[2], t.hover[3], 1) end
        end)
        row:SetScript("OnLeave", function(self)
            SBG.Fill(self, SBG.Theme().bar, 0.55)
        end)
        SBG.Fill(row, SBG.Theme().bar, 0.55)
        self.rows[i] = row
    end

    local mini = CreateFrame("Button", "SBGMinimapButton", Minimap)
    mini:SetSize(32, 32)
    mini:SetFrameStrata("MEDIUM")
    mini:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -12, -80)
    mini:SetMovable(true)
    mini:RegisterForDrag("LeftButton")
    mini:SetScript("OnDragStart", mini.StartMoving)
    mini:SetScript("OnDragStop", mini.StopMovingOrSizing)
    local mtex = mini:CreateTexture(nil, "ARTWORK")
    mtex:SetAllPoints()
    mtex:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    mtex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    local border = mini:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT", mini, "TOPLEFT", -10, 10)
    mini:SetScript("OnClick", function() Menu:Toggle() end)
    mini:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Sweat Beta Guide", 0.91, 0.72, 0.29)
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
    local t = SBG.Theme()
    local font = SBG.Font()
    if not self.panel then return end
    self.logo:SetFont(font, 14, "")
    self.logo:SetTextColor(1, 0.82, 0)
    self.title:SetFont(font, 13, "")
    self.hint:SetFont(font, 11, "")
    self.hint:SetTextColor(0.8, 0.8, 0.8)
    if self.welcome then
        self.welcome:SetFont(font, 12, "")
        self.welcome:SetTextColor(1, 1, 1)
    end
    for i = 1, #self.rows do
        local row = self.rows[i]
        SBG.Fill(row, t.bar, 0.55)
        row.name:SetFont(font, 13, "")
        row.sub:SetFont(font, 11, "")
        SBG.ColorSet(row.name, "text")
        SBG.ColorSet(row.sub, "muted")
    end
    if self.minimap then
        if s.showMinimapButton then self.minimap:Show() else self.minimap:Hide() end
    end
end

function Menu:Refresh()
    local shown = {}
    for _, guide in ipairs(SBG.guides) do
        table.insert(shown, guide)
    end
    table.sort(shown, function(a, b)
        return (a.displayname or a.name) < (b.displayname or b.name)
    end)
    for i, row in ipairs(self.rows) do
        local guide = shown[i]
        if guide then
            row:Show()
            row.icon:SetTexture(guide.icon or "Interface\\Icons\\INV_Misc_Book_09")
            row.name:SetText(guide.displayname or guide.name)
            row.sub:SetText(guide.subtitle or guide.group or "")
            row:SetScript("OnClick", function()
                Menu.forceWelcome = false
                if Menu.welcome then Menu.welcome:Hide() end
                self.overlay:Hide()
                SBG.Engine:Load(guide.key, 1)
            end)
        else
            row:Hide()
        end
    end
end

function Menu:ShowWelcome()
    if not self.overlay then return end
    self.forceWelcome = true
    self:Refresh()
    if self.welcome then
        self.welcome:SetText("Welcome to Sweat Beta Guide.\nThis character has no guide yet — pick one to start leveling.")
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
