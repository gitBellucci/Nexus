local ADDON, SBG = ...

local HBD = LibStub("HereBeDragons-2.0")
local Pins = {}
SBG.Pins = Pins

function Pins:Init()
    local mini = CreateFrame("Frame", "SBGMinimapPin", Minimap)
    mini:SetSize(10, 10)
    mini:SetFrameStrata("HIGH")
    local tex = mini:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints()
    tex:SetTexture("Interface\\Buttons\\WHITE8X8")
    mini.tex = tex
    mini:Hide()
    self.minimap = mini

    local world = CreateFrame("Frame", "SBGWorldMapPin", WorldMapFrame)
    world:SetSize(12, 12)
    local wtex = world:CreateTexture(nil, "OVERLAY")
    wtex:SetAllPoints()
    wtex:SetTexture("Interface\\Buttons\\WHITE8X8")
    world.tex = wtex
    world:Hide()
    self.world = world
    self:Apply()
end

function Pins:Apply()
    local t = SBG.Theme()
    if self.minimap and self.minimap.tex then
        self.minimap.tex:SetVertexColor(t.accent[1], t.accent[2], t.accent[3], 1)
    end
    if self.world and self.world.tex then
        self.world.tex:SetVertexColor(t.accent[1], t.accent[2], t.accent[3], 1)
    end
    if self.minimap then
        if SBG.GetSettings().showPin then
            -- shown by updater
        else
            self.minimap:Hide()
        end
        self.minimap.tex:SetRotation(0.785)
    end
    if self.world and self.world.tex then
        self.world.tex:SetRotation(0.785)
    end
end

function Pins:SetTarget(element)
    self.target = element
    if not element or not SBG.GetSettings().showPin then
        if self.minimap then self.minimap:Hide() end
        if self.world then self.world:Hide() end
    end
end

function Pins:UpdateMinimap()
    if not SBG.ready then return end
    local pin, el = self.minimap, self.target
    if not pin then return end
    if not SBG.GetSettings().showPin or not el or not el.wx or el.hidePin then
        pin:Hide()
        return
    end
    local x, y, instance = HBD:GetPlayerWorldPosition()
    local facing = GetPlayerFacing()
    if not (x and facing) then
        pin:Hide()
        return
    end
    local angle, dist = HBD:GetWorldVector(instance, x, y, el.wx, el.wy)
    if not dist then
        pin:Hide()
        return
    end
    local radius = (Minimap:GetWidth() / 2) - 8
    local view = 180
    if C_Minimap and C_Minimap.GetViewRadius then
        view = C_Minimap.GetViewRadius() or view
    end
    local r = math.min(radius, (dist / view) * radius)
    local rad = angle - facing
    pin:ClearAllPoints()
    pin:SetPoint("CENTER", Minimap, "CENTER", math.sin(rad) * r, math.cos(rad) * r)
    pin:Show()
end

function Pins:UpdateWorld()
    local pin, el = self.world, self.target
    if not pin then return end
    if not SBG.GetSettings().showPin or not el or not el.zone or not el.x or el.hidePin then
        pin:Hide()
        return
    end
    if not WorldMapFrame or not WorldMapFrame:IsShown() then
        pin:Hide()
        return
    end
    local mapId = WorldMapFrame.GetMapID and WorldMapFrame:GetMapID()
    if mapId ~= el.zone then
        pin:Hide()
        return
    end
    pin:SetParent(WorldMapFrame.ScrollContainer or WorldMapFrame)
    pin:ClearAllPoints()
    local w = (WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer:GetWidth()) or WorldMapFrame:GetWidth()
    local h = (WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer:GetHeight()) or WorldMapFrame:GetHeight()
    pin:SetPoint("CENTER", WorldMapFrame.ScrollContainer or WorldMapFrame, "TOPLEFT", (el.x / 100) * w, -(el.y / 100) * h)
    pin:Show()
end

local t = 0
SBG.events:HookScript("OnUpdate", function(_, elapsed)
    t = t + elapsed
    if t < 0.1 then return end
    t = 0
    Pins:UpdateMinimap()
    Pins:UpdateWorld()
end)
