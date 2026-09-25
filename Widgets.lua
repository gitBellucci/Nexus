local ADDON, SBG = ...

function SBG.Fill(frame, rgb, a)
    if not frame.bg then
        frame.bg = frame:CreateTexture(nil, "BACKGROUND")
        frame.bg:SetAllPoints()
    end
    local c = rgb or SBG.Theme().bg
    local s = SBG.GetSettings()
    frame.bg:SetColorTexture(c[1], c[2], c[3], a or s.opacity or 0.94)
end

function SBG.AccentLine(frame, side)
    local tex = frame:CreateTexture(nil, "BORDER")
    local t = SBG.Theme()
    if side == "top" then
        tex:SetPoint("TOPLEFT")
        tex:SetPoint("TOPRIGHT")
        tex:SetHeight(2)
    elseif side == "left" then
        tex:SetPoint("TOPLEFT")
        tex:SetPoint("BOTTOMLEFT")
        tex:SetWidth(3)
    end
    tex:SetColorTexture(t.accent[1], t.accent[2], t.accent[3], 1)
    return tex
end

function SBG.ChromeBtn(parent, kind, tooltip, onClick)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(22, 22)
    b.kind = kind
    b.tooltip = tooltip
    b.marks = {}
    local function mark(w, h, rot, ox, oy)
        local tex = b:CreateTexture(nil, "ARTWORK")
        tex:SetTexture("Interface\\Buttons\\WHITE8X8")
        tex:SetSize(w, h)
        tex:SetPoint("CENTER", ox or 0, oy or 0)
        if rot then tex:SetRotation(rot) end
        table.insert(b.marks, tex)
        return tex
    end
    if kind == "close" then
        mark(11, 1.15, 0.785)
        mark(11, 1.15, -0.785)
    elseif kind == "prev" then
        mark(8, 1.15, 0.70, 1, 2.4)
        mark(8, 1.15, -0.70, 1, -2.4)
    elseif kind == "next" then
        mark(8, 1.15, -0.70, -1, 2.4)
        mark(8, 1.15, 0.70, -1, -2.4)
    elseif kind == "dots" then
        mark(2.2, 2.2, nil, -5, 0)
        mark(2.2, 2.2, nil, 0, 0)
        mark(2.2, 2.2, nil, 5, 0)
    end
    function b:Paint(rgb)
        local c = rgb or SBG.Theme().accent
        for i = 1, #self.marks do
            self.marks[i]:SetVertexColor(c[1], c[2], c[3], 1)
        end
    end
    b:SetScript("OnEnter", function(self)
        local t = SBG.Theme()
        if self.bg then self.bg:SetColorTexture(t.hover[1], t.hover[2], t.hover[3], 0.95) end
        self:Paint(t.text)
        if self.tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
            GameTooltip:AddLine(self.tooltip, 1, 1, 1)
            GameTooltip:Show()
        end
    end)
    b:SetScript("OnLeave", function(self)
        SBG.Fill(self, { 0, 0, 0 }, 0)
        self:Paint(SBG.Theme().accent)
        GameTooltip:Hide()
    end)
    b:SetScript("OnClick", onClick)
    SBG.Fill(b, { 0, 0, 0 }, 0)
    b:Paint()
    return b
end

function SBG.ToggleRow(parent, label, key, onChange)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(308, 28)
    row.key = key
    row.cap = SBG.MakeText(row, "GameFontHighlight")
    row.cap:SetPoint("LEFT", 10, 0)
    row.cap:SetText(label)
    row.val = SBG.MakeText(row, "GameFontNormal")
    row.val:SetPoint("RIGHT", -10, 0)
    local function paint()
        local on = SBG.GetSettings()[key]
        local t = SBG.Theme()
        SBG.Fill(row, t.bar, 0.55)
        SBG.ColorSet(row.cap, "body")
        row.val:SetText(on and "ON" or "OFF")
        if on then
            SBG.ColorSet(row.val, "accent")
        else
            SBG.ColorSet(row.val, "muted")
        end
    end
    row.Paint = paint
    row:SetScript("OnEnter", function(self)
        local t = SBG.Theme()
        if self.bg then self.bg:SetColorTexture(t.hover[1], t.hover[2], t.hover[3], 0.95) end
    end)
    row:SetScript("OnLeave", function() paint() end)
    row:SetScript("OnClick", function()
        local s = SBG.GetSettings()
        s[key] = not s[key]
        paint()
        if onChange then onChange(s[key]) end
    end)
    paint()
    return row
end

function SBG.IconBtn(parent, caption, w, h)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(w or 24, h or 24)
    b.label = SBG.MakeText(b)
    b.label:SetPoint("CENTER")
    b.label:SetText(caption)
    b:SetScript("OnEnter", function(self)
        local t = SBG.Theme()
        if self.bg then self.bg:SetColorTexture(t.hover[1], t.hover[2], t.hover[3], 1) end
    end)
    b:SetScript("OnLeave", function(self)
        SBG.Fill(self, SBG.Theme().bar, 0.35)
    end)
    SBG.Fill(b, SBG.Theme().bar, 0.35)
    return b
end

function SBG.Switch(parent, label, key, onChange)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(300, 28)
    row.key = key
    row.track = CreateFrame("Frame", nil, row)
    row.track:SetSize(40, 20)
    row.track:SetPoint("LEFT")
    SBG.Fill(row.track, { 0.18, 0.18, 0.2 }, 1)
    row.knob = row.track:CreateTexture(nil, "OVERLAY")
    row.knob:SetSize(16, 16)
    row.knob:SetTexture("Interface\\Buttons\\WHITE8X8")
    row.txt = SBG.MakeText(row, "GameFontHighlight")
    row.txt:SetPoint("LEFT", row.track, "RIGHT", 10, 0)
    row.txt:SetText(label)
    local function paint()
        local on = SBG.GetSettings()[key]
        local t = SBG.Theme()
        if on then
            SBG.Fill(row.track, t.accent, 0.95)
            row.knob:ClearAllPoints()
            row.knob:SetPoint("RIGHT", row.track, "RIGHT", -2, 0)
            row.knob:SetVertexColor(0.08, 0.08, 0.09, 1)
        else
            SBG.Fill(row.track, { 0.22, 0.22, 0.24 }, 1)
            row.knob:ClearAllPoints()
            row.knob:SetPoint("LEFT", row.track, "LEFT", 2, 0)
            row.knob:SetVertexColor(0.75, 0.75, 0.78, 1)
        end
        SBG.ColorSet(row.txt, "body")
    end
    row.Paint = paint
    row:SetScript("OnClick", function()
        local s = SBG.GetSettings()
        s[key] = not s[key]
        paint()
        if onChange then onChange(s[key]) end
    end)
    paint()
    return row
end

function SBG.Slider(parent, label, key, minV, maxV, step, fmt, onLive, onCommit)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(300, 38)
    row.cap = SBG.MakeText(row, "GameFontHighlight")
    row.cap:SetPoint("TOPLEFT")
    row.cap:SetText(label)
    row.val = SBG.MakeText(row)
    row.val:SetPoint("TOPRIGHT")
    local bar = CreateFrame("StatusBar", nil, row)
    bar:SetSize(300, 8)
    bar:SetPoint("TOPLEFT", 0, -22)
    bar:SetMinMaxValues(minV, maxV)
    bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
    bar:EnableMouse(true)
    row.bar = bar
    row.bg = bar:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints()
    row.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
    row.bg:SetVertexColor(0.18, 0.18, 0.2, 1)
    local function setFromCursor()
        local l = bar:GetLeft()
        local w = bar:GetWidth()
        if not (l and w) or w == 0 then return end
        local x = GetCursorPosition() / bar:GetEffectiveScale()
        local pct = (x - l) / w
        if pct < 0 then pct = 0 end
        if pct > 1 then pct = 1 end
        local n = minV + pct * (maxV - minV)
        n = math.floor(n / step + 0.5) * step
        if n < minV then n = minV end
        if n > maxV then n = maxV end
        SBG.GetSettings()[key] = n
        bar:SetValue(n)
        row.val:SetText(string.format(fmt, n))
        if onLive then onLive(n) end
    end
    bar:SetScript("OnMouseDown", function(self)
        self.drag = true
        setFromCursor()
    end)
    bar:SetScript("OnMouseUp", function(self)
        self.drag = false
        if onCommit then onCommit(SBG.GetSettings()[key]) end
    end)
    bar:SetScript("OnUpdate", function(self)
        if self.drag then
            if IsMouseButtonDown("LeftButton") then
                setFromCursor()
            else
                self.drag = false
                if onCommit then onCommit(SBG.GetSettings()[key]) end
            end
        end
    end)
    function row:Paint()
        local t = SBG.Theme()
        local n = SBG.GetSettings()[key] or minV
        bar:SetStatusBarColor(t.accent[1], t.accent[2], t.accent[3], 1)
        bar:SetValue(n)
        row.val:SetText(string.format(fmt, n))
        SBG.ColorSet(row.cap, "body")
        SBG.ColorSet(row.val, "accent")
    end
    row:Paint()
    return row
end

function SBG.ResizeGrip(frame, minW, minH, maxW, maxH, onDone)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(minW, minH, maxW, maxH)
    else
        if frame.SetMinResize then frame:SetMinResize(minW, minH) end
        if frame.SetMaxResize then frame:SetMaxResize(maxW, maxH) end
    end
    local grip = CreateFrame("Button", nil, frame)
    grip:SetSize(16, 16)
    grip:SetPoint("BOTTOMRIGHT", -2, 2)
    grip:SetFrameLevel(frame:GetFrameLevel() + 5)
    local tex = grip:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    tex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetScript("OnEnter", function()
        tex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    end)
    grip:SetScript("OnLeave", function()
        tex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    end)
    grip:SetScript("OnMouseDown", function()
        if SBG.GetSettings().lockFrames then return end
        tex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
        frame.sizing = true
        frame:StartSizing("BOTTOMRIGHT")
    end)
    grip:SetScript("OnMouseUp", function()
        frame.sizing = false
        frame:StopMovingOrSizing()
        tex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        if onDone then onDone(frame:GetWidth(), frame:GetHeight()) end
    end)
    frame:SetScript("OnSizeChanged", function(self, w, h)
        if onDone then onDone(w, h) end
    end)
    return grip
end

function SBG.GlyphBtn(parent, glyph, tooltip, onClick)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(20, 20)
    b.label = SBG.MakeText(b, "GameFontNormal")
    b.label:SetPoint("CENTER", 0, 0)
    b.label:SetText(glyph)
    b.tooltip = tooltip
    b:SetScript("OnEnter", function(self)
        local t = SBG.Theme()
        if self.bg then self.bg:SetColorTexture(t.hover[1], t.hover[2], t.hover[3], 0.95) end
        if self.tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
            GameTooltip:AddLine(self.tooltip, 1, 1, 1)
            GameTooltip:Show()
        end
    end)
    b:SetScript("OnLeave", function(self)
        SBG.Fill(self, { 0, 0, 0 }, 0)
        GameTooltip:Hide()
    end)
    b:SetScript("OnClick", onClick)
    SBG.Fill(b, { 0, 0, 0 }, 0)
    return b
end

function SBG.BurgerBtn(parent, tooltip, onClick)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(20, 20)
    b.lines = {}
    for i = 1, 3 do
        local line = b:CreateTexture(nil, "ARTWORK")
        line:SetTexture("Interface\\Buttons\\WHITE8X8")
        line:SetSize(12, 1)
        line:SetPoint("CENTER", 0, 5 - (i - 1) * 5)
        b.lines[i] = line
    end
    b.tooltip = tooltip
    b:SetScript("OnEnter", function(self)
        local t = SBG.Theme()
        if self.bg then self.bg:SetColorTexture(t.hover[1], t.hover[2], t.hover[3], 0.95) end
        if self.tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
            GameTooltip:AddLine(self.tooltip, 1, 1, 1)
            GameTooltip:Show()
        end
    end)
    b:SetScript("OnLeave", function(self)
        SBG.Fill(self, { 0, 0, 0 }, 0)
        GameTooltip:Hide()
    end)
    b:SetScript("OnClick", onClick)
    SBG.Fill(b, { 0, 0, 0 }, 0)
    return b
end

function SBG.HideDrop()
    if SBG._drop then SBG._drop:Hide() end
    if SBG._dropCatch then SBG._dropCatch:Hide() end
end

function SBG.ShowDrop(items, anchor)
    if not SBG._drop then
        local d = CreateFrame("Frame", "SBGDropFrame", UIParent)
        d:SetFrameStrata("TOOLTIP")
        d:SetToplevel(true)
        d:EnableMouse(true)
        d:SetWidth(210)
        SBG.Fill(d)
        d.rows = {}
        for i = 1, 20 do
            local r = CreateFrame("Button", nil, d)
            r:SetHeight(22)
            r:SetPoint("TOPLEFT", 4, -4 - (i - 1) * 22)
            r:SetPoint("TOPRIGHT", -4, -4 - (i - 1) * 22)
            r.label = SBG.MakeText(r, "GameFontHighlightSmall")
            r.label:SetPoint("LEFT", 8, 0)
            r.label:SetJustifyH("LEFT")
            r:SetScript("OnEnter", function(self)
                if self.disabled then return end
                local t = SBG.Theme()
                if self.bg then self.bg:SetColorTexture(t.hover[1], t.hover[2], t.hover[3], 1) end
            end)
            r:SetScript("OnLeave", function(self)
                SBG.Fill(self, SBG.Theme().bg, 0.15)
            end)
            SBG.Fill(r, SBG.Theme().bg, 0.15)
            d.rows[i] = r
        end
        local catch = CreateFrame("Button", "SBGDropCatch", UIParent)
        catch:SetAllPoints(UIParent)
        catch:SetFrameStrata("DIALOG")
        catch:Hide()
        catch:SetScript("OnClick", SBG.HideDrop)
        SBG._drop = d
        SBG._dropCatch = catch
    end
    local d = SBG._drop
    SBG.Fill(d)
    local n = 0
    for i = 1, #items do
        local item = items[i]
        n = n + 1
        local r = d.rows[n]
        r.label:SetText(item.text or "")
        r.disabled = item.isTitle or item.disabled
        if item.isTitle then
            SBG.ColorSet(r.label, "muted")
            r:SetScript("OnClick", nil)
            r:EnableMouse(false)
        else
            SBG.ColorSet(r.label, "body")
            r:EnableMouse(true)
            r:SetScript("OnClick", function()
                SBG.HideDrop()
                if item.func then item.func() end
            end)
        end
        SBG.Fill(r, SBG.Theme().bg, 0.15)
        r:Show()
    end
    for i = n + 1, #d.rows do
        d.rows[i]:Hide()
    end
    d:SetHeight(8 + n * 22)
    d:ClearAllPoints()
    if type(anchor) == "table" and anchor.GetLeft then
        d:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -4)
    else
        local x, y = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        d:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / scale, y / scale)
    end
    SBG._dropCatch:Show()
    d:Show()
end
