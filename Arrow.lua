local ADDON, SBG = ...

local HBD = LibStub("HereBeDragons-2.0")
local Arrow = {}
SBG.Arrow = Arrow

local ARROW_TEX = "Interface\\AddOns\\" .. ADDON .. "\\Textures\\navarrow"
local LOWER = math.pi / 64
local UPPER = 2 * math.pi - LOWER

function Arrow:Init()
    local f = CreateFrame("Frame", "SBGArrowFrame", UIParent)
    f:SetSize(32, 32)
    f:SetPoint("TOP", UIParent, "TOP", 0, 0)
    f:SetFrameStrata("HIGH")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self)
        if not SBG.GetSettings().lockFrames then self:StartMoving() end
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
    f:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end
    end)
    f:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
    end)
    f:Hide()

    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    tex:SetTexture(ARROW_TEX)
    tex:SetVertexColor(1, 1, 1, 1)
    f.texture = tex

    local dist = SBG.MakeText(f, "GameFontNormal")
    dist:SetJustifyH("CENTER")
    dist:SetJustifyV("MIDDLE")
    dist:SetPoint("TOP", f, "BOTTOM", 0, -5)
    f.text = dist

    f.orientation = 0
    f.distance = 0
    f.alpha = 1
    self.frame = f
    f:SetScript("OnUpdate", function(self) Arrow:Draw(self) end)
    self:Apply()
end

function Arrow:Reset()
    local f = self.frame
    if not f then return end
    f:ClearAllPoints()
    f:SetPoint("TOP", UIParent, "TOP", 0, 0)
    f:SetAlpha(1)
    f.alpha = 1
    SBG.GetSettings().showArrow = true
    if f.element then f:Show() end
    self:Apply()
end

function Arrow:Apply()
    local f = self.frame
    if not f then return end
    local s = SBG.GetSettings()
    local scale = s.arrowScale or 1
    local size = 32 * scale
    f:SetSize(size, size)
    f.text:SetFont(SBG.Font(), 9, "OUTLINE")
    f.text:SetTextColor(1, 1, 1, 1)
    f.texture:SetVertexColor(1, 1, 1, 1)
    if not s.showArrow then
        f:Hide()
    end
end

function Arrow:SetTarget(element)
    local f = self.frame
    if not f then return end
    if f.element ~= element then
        f.element = element
        f.forceUpdate = true
        f.distance = nil
        f.wrongContinent = false
    end
    local s = SBG.GetSettings()
    if not s.showArrow or not element then
        f:Hide()
        return
    end
    f:Show()
end

function Arrow:Draw(f)
    f = f or self.frame
    if not f then return end
    local s = SBG.GetSettings()
    if not s.showArrow then
        f:Hide()
        return
    end
    local el = f.element
    if not el then return end

    if not el.wx then
        if SBG.Engine and SBG.Engine.RefreshCoords then
            SBG.Engine:RefreshCoords(el)
        end
    end

    local x, y, instance = HBD:GetPlayerWorldPosition()
    local facing = GetPlayerFacing()

    local angle, dist
    if x and el.wx then
        angle, dist = HBD:GetWorldVector(instance, x, y, el.wx, el.wy)
        if not dist and el.instance then
            angle, dist = HBD:GetWorldVector(el.instance, x, y, el.wx, el.wy)
        end
    end

    if not dist and el.instance and instance and el.instance ~= instance and instance ~= -1 then
        f.alpha = 1
        f:SetAlpha(1)
        f.texture:SetRotation(0)
        f.text:SetText("~")
        f:Show()
        return
    end

    if not (dist and facing) then
        -- Keep the arrow visible. Right-click look / loading can briefly
        -- nil out facing; fading to 0 made it impossible to recover.
        f:SetAlpha(1)
        f.alpha = 1
        f:Show()
        if not facing then
            f.text:SetText(f.distance and string.format("(%dyd)", f.distance) or "...")
        else
            f.text:SetText("~")
        end
        return
    elseif f.alpha ~= 1 then
        f.alpha = 1
        f:SetAlpha(1)
    end
    f:Show()

    local orientation = angle - facing
    local diff = math.abs(orientation - (f.orientation or 0))
    dist = math.floor(dist)
    if diff > LOWER and diff < UPPER or f.forceUpdate then
        f.orientation = orientation
        f.texture:SetRotation(orientation)
        f.forceUpdate = false
    end

    if dist ~= f.distance then
        f.distance = dist
        local title = el.title
        if not title and el.step then
            title = el.step.arrowtext or el.step.title
            if not title and el.step.index then
                title = "Step " .. el.step.index
            end
        end
        if title and title ~= "" then
            f.text:SetText(string.format("%s\n(%dyd)", SBG.ColorText(title), dist))
        else
            f.text:SetText(string.format("(%dyd)", dist))
        end
    end
end
