local ADDON, SBG = ...

local HBD = LibStub("HereBeDragons-2.0")
local Engine = { stepIndex = 1 }
SBG.Engine = Engine

local function QuestOnLog(id)
    if not id then return false end
    if C_QuestLog and C_QuestLog.IsOnQuest then
        return C_QuestLog.IsOnQuest(id)
    end
    return false
end

local function QuestTurnedIn(id)
    if not id then return false end
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        return C_QuestLog.IsQuestFlaggedCompleted(id)
    end
    return false
end

local function QuestComplete(id)
    if not id then return false end
    if C_QuestLog and C_QuestLog.IsComplete then
        local ok = C_QuestLog.IsComplete(id)
        if ok ~= nil then return ok end
    end
    local index = GetQuestLogIndexByID and GetQuestLogIndexByID(id)
    if index and index > 0 then
        local isComplete
        if GetQuestLogTitle then
            _, _, _, _, _, isComplete = GetQuestLogTitle(index)
        end
        return isComplete == 1
    end
    return false
end

local function ObjectiveDone(id, objIndex)
    if QuestComplete(id) or QuestTurnedIn(id) then return true end
    if C_QuestLog and C_QuestLog.GetQuestObjectives then
        local objs = C_QuestLog.GetQuestObjectives(id)
        local o = objs and objs[objIndex]
        if o then
            if o.finished then return true end
            if o.numRequired and o.numFulfilled and o.numFulfilled >= o.numRequired then return true end
        end
    end
    local index = GetQuestLogIndexByID and GetQuestLogIndexByID(id)
    if index and index > 0 and GetQuestLogLeaderBoard then
        local _, _, finished = GetQuestLogLeaderBoard(objIndex, index)
        return finished
    end
    return false
end

local function ItemCount(id)
    if not id then return 0 end
    return GetItemCount(id) or 0
end

function Engine:ActiveStep()
    local guide = self.guide
    if not guide then return end
    return guide.steps[self.stepIndex]
end

function Engine:VisibleSteps()
    local guide = self.guide
    if not guide then return {} end
    local out = {}
    local from = math.max(1, self.stepIndex)
    for i = from, math.min(#guide.steps, from + 2) do
        table.insert(out, guide.steps[i])
    end
    return out
end

local function IsCompleter(el)
    if not el or el.textOnly then return false end
    if el.kind == "click" or el.kind == "accept" or el.kind == "turnin"
        or el.kind == "complete" or el.kind == "home" or el.kind == "fly"
        or el.kind == "hs" or el.kind == "zone" or el.kind == "collect"
        or el.kind == "vendor" or el.kind == "train" then
        return true
    end
    if el.tag == "goto" and el.radius and el.radius > 0 and not el.hidePin then
        return true
    end
    return false
end

function Engine:RefreshCoords(el)
    if not el or el.wx then return end
    if not el.zone or not el.x or not el.y then return end
    local wx, wy, instance = HBD:GetWorldCoordinatesFromZone(el.x / 100, el.y / 100, el.zone)
    el.wx, el.wy, el.instance = wx, wy, instance
end

function Engine:ShouldSkipStep(step)
    if not step then return true end
    for _, el in ipairs(step.elements) do
        if el.kind == "zoneskip" and el.dest and SBG.InZone(el.dest) then
            return true
        end
        if el.kind == "bindlocation" and el.skipIfUnbound and not SBG.IsBoundTo(el.areaId) then
            return true
        end
        if el.kind == "accept" and (QuestOnLog(el.questId) or QuestTurnedIn(el.questId)) then
            -- keep step if other work remains
        end
    end
    local hasWork = false
    for _, el in ipairs(step.elements) do
        if IsCompleter(el) and not el.completed then
            hasWork = true
            break
        end
        if el.kind == "click" then hasWork = true end
    end
    if not hasWork then
        for _, el in ipairs(step.elements) do
            if el.kind == "accept" and (QuestOnLog(el.questId) or QuestTurnedIn(el.questId)) then
                return true
            end
            if el.kind == "turnin" and QuestTurnedIn(el.questId) then
                return true
            end
        end
    end
    return false
end

function Engine:Evaluate(el)
    if not el or el.completed then return end
    if el.kind == "accept" then
        if QuestOnLog(el.questId) or QuestTurnedIn(el.questId) then el.completed = true end
    elseif el.kind == "turnin" then
        if QuestTurnedIn(el.questId) then el.completed = true end
    elseif el.kind == "complete" then
        if ObjectiveDone(el.questId, el.objIndex or 1) then el.completed = true end
    elseif el.kind == "collect" then
        if ItemCount(el.itemId) >= (el.count or 1) then el.completed = true end
    elseif el.kind == "zone" or el.kind == "fly" then
        if el.dest and SBG.InZone(el.dest) then el.completed = true end
    elseif el.kind == "home" then
        local area = el.areaId
        if el.step then
            for _, other in ipairs(el.step.elements) do
                if other.kind == "bindlocation" then area = other.areaId end
            end
        end
        if area and SBG.IsBoundTo(area) then el.completed = true end
    elseif el.kind == "hs" then
        -- completed by zone skip sibling or click
    elseif el.tag == "goto" and el.radius and el.radius > 0 then
        self:RefreshCoords(el)
        if el.wx then
            local x, y, instance = HBD:GetPlayerWorldPosition()
            if x then
                local _, dist = HBD:GetWorldVector(instance, x, y, el.wx, el.wy)
                if dist and dist <= el.radius then
                    el.completed = true
                    if el.hidePin or el.textOnly then el.skip = true end
                end
            end
        end
    end
end

function Engine:ArrowTarget()
    local step = self:ActiveStep()
    if not step then return end
    local x, y, instance = HBD:GetPlayerWorldPosition()
    local best, bestDist
    for _, el in ipairs(step.elements) do
        if el.tag == "goto" and el.arrow and not el.skip and not el.completed then
            if type(el.parent) == "table" and el.parent.completed and not el.parent.textOnly then
                -- skip child of a finished parent
            else
                self:RefreshCoords(el)
                if el.wx then
                    local dist
                    if x then
                        local _, d = HBD:GetWorldVector(instance, x, y, el.wx, el.wy)
                        dist = d
                        if not dist and el.instance then
                            _, dist = HBD:GetWorldVector(el.instance, x, y, el.wx, el.wy)
                        end
                    end
                    if not best then
                        best, bestDist = el, dist
                    elseif dist and (not bestDist or dist < bestDist) then
                        best, bestDist = el, dist
                    end
                elseif not best then
                    best = el
                end
            end
        end
    end
    return best
end

function Engine:StepDone(step)
    step = step or self:ActiveStep()
    if not step then return false end
    local completers = 0
    local done = 0
    for _, el in ipairs(step.elements) do
        if IsCompleter(el) then
            completers = completers + 1
            if el.completed then done = done + 1 end
        end
    end
    if completers == 0 then return false end
    return done >= completers
end

function Engine:ClickComplete()
    local step = self:ActiveStep()
    if not step then return end
    for _, el in ipairs(step.elements) do
        if IsCompleter(el) then
            el.completed = true
        end
    end
    self:Advance()
end

function Engine:SetElementSkip(el, skip)
    if not el then return end
    if skip then
        el.completed = true
    else
        el.completed = nil
    end
    if self:StepDone() then
        self:Advance()
    else
        self:Update()
    end
end

function Engine:CompleteElement(el)
    if not el then
        self:ClickComplete()
        return
    end
    el.completed = true
    if self:StepDone() then
        self:Advance()
    else
        self:Update()
    end
end

function Engine:HasCompleters(step)
    for _, el in ipairs(step.elements) do
        if IsCompleter(el) then return true end
    end
    return false
end

function Engine:SetStep(index)
    local guide = self.guide
    if not guide then return end
    index = math.max(1, math.min(#guide.steps, index))
    self.stepIndex = index
    SBGPC.stepIndex = index
    local step = guide.steps[index]
    if step then
        for _, el in ipairs(step.elements) do
            el.completed = nil
            el.skip = nil
        end
    end
    self:SkipFinished()
    self:Update()
end

function Engine:Advance()
    if not self.guide then return end
    if self.stepIndex >= #self.guide.steps then
        SBG.Print("Guide finished.")
        self:Update()
        return
    end
    self:SetStep(self.stepIndex + 1)
end

function Engine:Retreat()
    if not self.guide then return end
    self:SetStep(self.stepIndex - 1)
end

function Engine:SkipFinished()
    local guard = 0
    while self.guide and self.stepIndex <= #self.guide.steps and guard < 80 do
        guard = guard + 1
        local step = self:ActiveStep()
        if not step then break end
        for _, el in ipairs(step.elements) do
            self:Evaluate(el)
        end
        if self:ShouldSkipStep(step) or self:StepDone(step) then
            if self.stepIndex >= #self.guide.steps then break end
            self.stepIndex = self.stepIndex + 1
            SBGPC.stepIndex = self.stepIndex
        else
            break
        end
    end
end

function Engine:Load(key, index)
    local guide = SBG.guideByKey[key]
    if not guide then
        SBG.Print("Guide not found.")
        return
    end
    if guide.locked then
        SBG.Print(guide.lockedReason or "This guide is locked for your faction.")
        return
    end
    self.guide = guide
    SBGPC.guideKey = key
    self:SetStep(index or 1)
    if SBG.UI then SBG.UI:Show() end
    SBG.Print("Loaded |cffe8b84a" .. (guide.displayname or guide.name) .. "|r")
end

function Engine:Update()
    if SBG.UI then SBG.UI:Refresh() end
    local target = self:ArrowTarget()
    if SBG.Arrow then SBG.Arrow:SetTarget(target) end
    if SBG.Pins then SBG.Pins:SetTarget(target) end
    if SBG.Targeting then SBG.Targeting:UpdateFromStep(self:ActiveStep()) end
end

function Engine:OnUpdate()
    if not SBG.ready or not self.guide then return end
    local step = self:ActiveStep()
    if not step then return end
    local changed
    for _, el in ipairs(step.elements) do
        local before = el.completed
        self:Evaluate(el)
        if el.completed ~= before then changed = true end
    end
    if self:StepDone(step) then
        if SBG.GetSettings().autoAdvance and self.stepIndex < #self.guide.steps then
            self:Advance()
        elseif changed and SBG.UI then
            SBG.UI:Refresh()
        end
        return
    end
    local target = self:ArrowTarget()
    if SBG.Arrow then SBG.Arrow:SetTarget(target) end
    if SBG.Pins then SBG.Pins:SetTarget(target) end
    if changed then
        if SBG.UI then SBG.UI:Refresh() end
        if SBG.Targeting then SBG.Targeting:UpdateFromStep(step) end
    end
end

function Engine:OnEvent(event, ...)
    if event == "HEARTHSTONE_BOUND" then
        local step = self:ActiveStep()
        if step then
            for _, el in ipairs(step.elements) do
                if el.kind == "home" then el.completed = true end
            end
        end
    end
    if self.guide then
        self:OnUpdate()
        if SBG.UI then SBG.UI:Refresh() end
    end
end

local ticker = 0
SBG.events:SetScript("OnUpdate", function(_, elapsed)
    ticker = ticker + elapsed
    if ticker < 0.2 then return end
    ticker = 0
    Engine:OnUpdate()
end)
