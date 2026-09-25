local ADDON, SBG = ...

local Targeting = {}
SBG.Targeting = Targeting

local function wipe(t)
    for k in pairs(t) do t[k] = nil end
    return t
end

Targeting.macroName = "SweatTarget"
Targeting.followMacroName = "SweatFollow"

local targetList, mobList, unitscanList = {}, {}, {}
local announced, queued = {}, {}
local announcedOnce

local function InCombat()
    return InCombatLockdown and InCombatLockdown()
end

local function CanCreate()
    local n = GetNumMacros and GetNumMacros() or 0
    return n < 119
end

local function AddNames(list, names)
    if not names then return end
    for i = 1, #names do
        local n = names[i]
        if type(n) == "string" and n ~= "" then
            table.insert(list, n)
        end
    end
end

function Targeting:Collect(step)
    local targets, mobs, scans = {}, {}, {}
    if not step then return targets, mobs, scans end
    for _, el in ipairs(step.elements) do
        if not el.completed and not el.skip then
            if el.kind == "target" or el.tag == "target" then
                AddNames(targets, el.targets or el.unitlist)
                if el.targetName then table.insert(targets, el.targetName) end
            elseif el.kind == "mob" or el.tag == "mob" then
                AddNames(mobs, el.mobs or el.unitlist)
                if el.mobName then table.insert(mobs, el.mobName) end
            elseif el.kind == "unitscan" or el.tag == "unitscan" then
                AddNames(scans, el.unitscan or el.unitlist)
            end
        end
    end
    local function uniq(src)
        local seen, out = {}, {}
        for i = 1, #src do
            local n = src[i]
            if n and not seen[n] then
                seen[n] = true
                table.insert(out, n)
            end
        end
        return out
    end
    return uniq(targets), uniq(mobs), uniq(scans)
end

function Targeting:UpdateMacro(queuedTargets)
    local s = SBG.GetSettings()
    if not s.enableTargetMacro then return end
    if InCombat() then
        queued = queuedTargets or queued
        return
    end

    if not GetMacroInfo(self.macroName) then
        if not CanCreate() then
            SBG.Print("Macro capacity reached.")
            return
        end
        CreateMacro(self.macroName, "Ability_eyeoftheowl", "")
    end

    local names = queuedTargets or {}
    if not queuedTargets then
        for i = 1, #unitscanList do table.insert(names, unitscanList[i]) end
        for i = 1, #mobList do table.insert(names, mobList[i]) end
        for i = 1, #targetList do table.insert(names, targetList[i]) end
    end

    local seen = {}
    for i = #names, 1, -1 do
        if seen[names[i]] then
            names[i] = false
        else
            seen[names[i]] = true
        end
    end

    local content
    local news = ""
    for i = #names, 1, -1 do
        local n = names[i]
        if n then
            if content then
                content = content .. "\n/targetexact " .. n
            else
                content = "/targetexact " .. n
            end
            if not announced[n] and s.notifyOnTargetUpdates then
                news = news .. " " .. n .. ","
            end
            announced[n] = true
            if #content > 255 then
                content = content:gsub("^\n?[^\n]*[\n]*", "")
            end
        end
    end

    if content then
        while #content > 200 do
            content = content:gsub("^\n?[^\n]*[\n]*", "")
        end
        -- Orange circle raid marker (index 2) on whatever we just targeted.
        content = content .. "\n/script SetRaidTarget(\"target\",2)\n/targetlasttarget [dead]"
    else
        content = "//Sweat - current step has no configured targets"
    end

    EditMacro(self.macroName, self.macroName, nil, content)

    if news ~= "" and s.notifyOnTargetUpdates then
        SBG.Print("Targeting macro updated with:" .. news:sub(1, -2))
    end
    if not announcedOnce and s.notifyOnTargetUpdates and next(seen) then
        announcedOnce = true
        s.macroAnnounced = true
        SBG.Print("A macro has been automatically built. Put |cffe8b84a" .. self.macroName .. "|r on your bars.")
    end
    queued = {}
end

function Targeting:UpdateFromStep(step)
    targetList, mobList, unitscanList = self:Collect(step)
    wipe(announced)
    if SBG.GetSettings().enableTargetMacro then
        self:UpdateMacro()
    end
end

function Targeting:MarkerIndex(kind, index)
    index = (index or 1) - 1
    if kind == "friendly" then
        return (index % 4) + 1
    elseif kind == "unitscan" then
        return 5
    elseif kind == "mob" then
        return 8 - (index % 3)
    end
    return 8
end

function Targeting:Mark(kind, unit, index)
    if not unit then return end
    if UnitIsDead and UnitIsDead(unit) and kind ~= "friendly" then return end
    if UnitIsPlayer and UnitIsPlayer(unit) then return end
    -- Prefer orange circle (2) for the primary step target; fall back by kind.
    local id = 2
    if kind ~= "friendly" and kind ~= "mob" and kind ~= "unitscan" then
        id = self:MarkerIndex(kind, index) or 2
    elseif kind == "unitscan" then
        id = 2
    elseif kind == "mob" then
        id = self:MarkerIndex(kind, index) or 2
    else
        id = 2 -- friendly / primary: orange circle
    end
    if not id then return end
    local cur = GetRaidTargetIndex and GetRaidTargetIndex(unit)
    if cur == nil and SetRaidTarget then
        SetRaidTarget(unit, id)
    elseif cur ~= id and SetRaidTarget and kind == "friendly" then
        SetRaidTarget(unit, id)
    end
end

local BINDING_CMD = "SBG_SWEATTARGET"

function Targeting:GetBoundKey()
    local k1, k2 = GetBindingKey(BINDING_CMD)
    return k1 or k2
end

function Targeting:RefreshKeybindButton()
    local btn = self.keybindBtn
    if not btn then return end
    local key = self:GetBoundKey()
    if key then
        btn:SetText(key)
    else
        btn:SetText("Click to bind")
    end
end

function Targeting:ClearKeybind()
    local k1, k2 = GetBindingKey(BINDING_CMD)
    if k1 then SetBinding(k1) end
    if k2 then SetBinding(k2) end
    pcall(SaveBindings, GetCurrentBindingSet and GetCurrentBindingSet() or 1)
    self:RefreshKeybindButton()
    SBG.Print("SweatTarget keybind cleared.")
end

function Targeting:BindKey(key)
    if not key or key == "UNKNOWN" or key == "LSHIFT" or key == "RSHIFT"
        or key == "LCTRL" or key == "RCTRL" or key == "LALT" or key == "RALT"
        or key == "ESCAPE" then
        return false
    end
    local mod = ""
    if IsShiftKeyDown() then mod = "SHIFT-" .. mod end
    if IsControlKeyDown() then mod = "CTRL-" .. mod end
    if IsAltKeyDown() then mod = "ALT-" .. mod end
    local full = mod .. key
    -- Free previous binds for this command
    local k1, k2 = GetBindingKey(BINDING_CMD)
    if k1 then SetBinding(k1) end
    if k2 then SetBinding(k2) end
    local ok = SetBinding(full, BINDING_CMD)
    if ok then
        pcall(SaveBindings, GetCurrentBindingSet and GetCurrentBindingSet() or 1)
        self:RefreshKeybindButton()
        SBG.Print("SweatTarget bound to |cffe8b84a" .. full .. "|r")
        return true
    end
    SBG.Print("Could not bind key " .. full)
    return false
end

function Targeting:StartKeybindCapture(btn)
    if InCombat and InCombatLockdown and InCombatLockdown() then
        SBG.Print("Leave combat to set a keybind.")
        return
    end
    if not self.binder then
        local b = CreateFrame("Frame", "SBGKeybindCapture", UIParent)
        b:SetAllPoints(UIParent)
        b:SetFrameStrata("TOOLTIP")
        b:EnableMouse(true)
        b:EnableKeyboard(true)
        b:Hide()
        b.hint = b:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        b.hint:SetPoint("CENTER")
        b.hint:SetText("Press a key to bind SweatTarget\n(Escape to cancel · Right-click to clear)")
        b.hint:SetTextColor(1, 0.85, 0.35)
        b.dim = b:CreateTexture(nil, "BACKGROUND")
        b.dim:SetAllPoints()
        b.dim:SetColorTexture(0, 0, 0, 0.55)
        b:SetScript("OnKeyDown", function(self, key)
            if key == "ESCAPE" then
                self:Hide()
                SBG.Print("Keybind cancelled.")
                return
            end
            if Targeting:BindKey(key) then
                self:Hide()
            end
        end)
        b:SetScript("OnMouseUp", function(self, button)
            if button == "RightButton" then
                Targeting:ClearKeybind()
                self:Hide()
            end
        end)
        pcall(function()
            if b.SetPropagateKeyboardInput then
                b:SetScript("OnShow", function(self)
                    self:EnableKeyboard(true)
                    self:SetPropagateKeyboardInput(false)
                end)
            end
        end)
        self.binder = b
    end
    if btn then
        btn:SetText("Press a key…")
    end
    self.binder:Show()
    self.binder:Raise()
end

function Targeting:Apply()
    local s = SBG.GetSettings()
    if not s.enableTargetMacro then
        if GetMacroInfo(self.macroName) then
            pcall(DeleteMacro, self.macroName)
        end
        self:RefreshKeybindButton()
        return
    end
    if SBG.Engine then
        self:UpdateFromStep(SBG.Engine:ActiveStep())
    end
    self:RefreshKeybindButton()
end

function Targeting:ScanUnit(unit)
    if not unit then return end
    local name = UnitName(unit)
    if not name then return end
    local s = SBG.GetSettings()
    if s.enableFriendlyTargeting then
        for i, n in ipairs(targetList) do
            if n == name then
                if s.enableTargetMarking then self:Mark("friendly", unit, i) end
            end
        end
    end
    if s.enableEnemyTargeting then
        for i, n in ipairs(mobList) do
            if n == name then
                if s.enableMobMarking then self:Mark("mob", unit, i) end
            end
        end
        for i, n in ipairs(unitscanList) do
            if n == name then
                if s.enableEnemyMarking then self:Mark("unitscan", unit, i) end
            end
        end
    end
end

function Targeting:OnEvent(event, arg1)
    if event == "PLAYER_REGEN_ENABLED" then
        if queued and next(queued) then
            self:UpdateMacro(queued)
        else
            self:UpdateMacro()
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        self:ScanUnit("target")
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        self:ScanUnit("mouseover")
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        self:ScanUnit(arg1)
    end
end

function Targeting:Init()
    self.frame = CreateFrame("Frame")
    self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    self.frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
    pcall(function() self.frame:RegisterEvent("NAME_PLATE_UNIT_ADDED") end)
    self.frame:SetScript("OnEvent", function(_, event, ...)
        Targeting:OnEvent(event, ...)
    end)
    -- Binding names for the Key Bindings UI / SetBinding
    _G.BINDING_HEADER_SBGHEADER = "Sweat Beta Guide"
    _G.BINDING_NAME_SBG_SWEATTARGET = "Keybind current step target targeting"
end
