-- BotControl 2.4.3: independent action bar. Only bot commands, no protected spells.
BotControlBar = { categories = {
    { key = "Config", label = "Config", default = "Summon" },
    { key = "Tank", label = "Tank", default = "TankAttack" },
    { key = "DPS", label = "DPS", default = "AttackDPS" },
    { key = "Heal", label = "Heal", default = "WaitHEAL" },
    { key = "All", label = "General", default = "Follow" },
    { key = "Marks", label = "Marks", default = "RaidMark8" }
}, menus = {}, buttons = {}, customButtons = {} }
local Bar = BotControlBar
local unknownIcon = "Interface\\Icons\\INV_Misc_QuestionMark"
local backdrop = { bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16,
    edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } }
local function Count(t) return table.getn(t or {}) end
local function Clamp(value, minimum, maximum, fallback)
    return math.max(minimum, math.min(maximum, math.floor(tonumber(value) or fallback)))
end
local function Label(parent, text, x, y, template)
    local f = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
    f:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    f:SetText(text)
    return f
end
local function TextButton(parent, text, x, y, width, click)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetWidth(width); b:SetHeight(24); b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    b:SetText(text); b:SetScript("OnClick", click)
    return b
end
local function Window(name, title, width, height)
    local f = CreateFrame("Frame", name, UIParent)
    f:SetWidth(width); f:SetHeight(height); f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:SetBackdrop(backdrop); f:SetBackdropColor(0.06, 0.06, 0.06, 0.98)
    f:SetFrameStrata("DIALOG"); f:SetClampedToScreen(true); f:EnableMouse(true); f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function() f:StartMoving() end)
    f:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)
    Label(f, title, 18, -16, "GameFontNormalLarge")
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    close:SetScript("OnClick", function() f:Hide() end)
    BotControl.RegisterSpecialFrame(name)
    f:Hide()
    return f
end

function Bar:GetDB()
    local owner = BotControlConfig:GetDB()
    if type(owner.actionBar) ~= "table" then owner.actionBar = {} end
    local db = owner.actionBar
    if db.orientation ~= "vertical" then db.orientation = "horizontal" end
    if db.horizontalDirection ~= "DOWN" then db.horizontalDirection = "UP" end
    if db.verticalDirection ~= "LEFT" then db.verticalDirection = "RIGHT" end
    db.size = Clamp(db.size, 24, 64, 36)
    db.spacing = Clamp(db.spacing, 0, 16, 4)
    db.customCount = Clamp(db.customCount, 0, 10, 2)
    if db.locked == nil then db.locked = true end
    if db.labels == nil then db.labels = false end
    if type(db.main) ~= "table" then db.main = {} end
    if type(db.custom) ~= "table" then db.custom = { "Stay", "Kick" } end
    if type(db.profileNames) ~= "table" then db.profileNames = {} end
    for _, category in ipairs(self.categories) do
        local action = BotControl.GetActionByKey(db.main[category.key])
        if not action or action.group ~= category.key then
            db.main[category.key] = category.default
        end
    end
    return db
end

function Bar:GetCategoryActions(categoryKey)
    local list = {}
    for _, action in ipairs(BotControl.GetOrderedRegistryActions()) do
        if action.group == categoryKey then table.insert(list, action) end
    end
    table.sort(list, function(a, b)
        if (a.order or 999) == (b.order or 999) then return a.key < b.key end
        return (a.order or 999) < (b.order or 999)
    end)
    return list
end

function Bar:Run(actionKey)
    if BotControl.GetActionByKey(actionKey) then BotControl_RunNamedAction(actionKey) end
end

function Bar:NewIcon(parent, name)
    local b = CreateFrame("Button", name, parent)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:SetBackdrop(backdrop); b:SetBackdropColor(0, 0, 0, 0.9)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetPoint("TOPLEFT", b, "TOPLEFT", 3, -3)
    b.icon:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -3, 3)
    b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    b.caption = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    b.caption:SetPoint("TOP", b, "BOTTOM", 0, -2)
    b.mark = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    b.mark:SetPoint("TOPRIGHT", b, "TOPRIGHT", -2, -2)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return b
end

function Bar:SetAction(b, key)
    b.actionKey = key

    local action = BotControl.GetActionByKey(key)
    b.icon:SetTexture(action and action.texture or unknownIcon)

    if action and action.raidMark and action.raidMark > 0 then
        local index = action.raidMark - 1
        local left = (index % 4) / 4
        local top = math.floor(index / 4) / 4

        b.icon:SetTexCoord(left, left + 0.25, top, top + 0.25)
    else
        b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end
end

function Bar:Tooltip(b, category, secondary)
    local action = BotControl.GetActionByKey(b.actionKey)
    GameTooltip:SetOwner(b, "ANCHOR_RIGHT")

    if action then
        GameTooltip:SetText(
            action.tooltipTitle or action.label or action.key,
            1, 0.82, 0
        )
        GameTooltip:AddLine(
            action.tooltipDescription or "",
            0.8, 0.8, 0.8, true
        )
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(
            "Clic gauche : executer",
            0.6, 0.85, 1
        )
    else
        GameTooltip:SetText("Aucune action affectee", 1, 0.82, 0)
    end

    GameTooltip:AddLine(secondary, 0.6, 0.85, 1, true)
    GameTooltip:Show()
end

function Bar:SetMain(categoryKey, actionKey)
    local action = BotControl.GetActionByKey(actionKey)
    if not action or action.group ~= categoryKey then return end
    self:GetDB().main[categoryKey] = actionKey
    self.menus[categoryKey].open = false
    GameTooltip:Hide()
    self:Layout()
end

function Bar:ToggleMenu(categoryKey)
    local menu = self.menus[categoryKey]
    menu.open = not menu.open
    self:Layout()
end

function Bar:RememberPosition()
    local db = self:GetDB()
    -- Store the bottom-left corner in UIParent units, never an anchor to a button.
    db.x = self.frame:GetLeft()
    db.y = self.frame:GetBottom()
end

function Bar:RestorePosition()
    local db = self:GetDB()
    self.frame:ClearAllPoints()
    if type(db.x) == "number" and type(db.y) == "number" then
        self.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", db.x, db.y)
    else
        self.frame:SetPoint("CENTER", UIParent, "CENTER", 0, -180)
    end
end

function Bar:UpdateManager()
    if not self.manager then return end
    local format = BotControl.GetActiveProfileFormat()
    local counts = { party5 = "5", raid10 = "10", raid25 = "25" }
    self.manager.number:SetText(counts[format] or "5")
end

function Bar:Create()
    if self.frame then self:Layout(); return end
    local f = CreateFrame("Frame", "BotControlActionBar", UIParent)
    self.frame = f
    f:SetFrameStrata("MEDIUM"); f:SetMovable(true); f:SetClampedToScreen(true)
    self.manager = self:NewIcon(f, "BotControlBarManager")
    self.manager.icon:SetTexture("Interface\\Icons\\INV_Misc_GroupNeedMore")
    self.manager.number = self.manager:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.manager.number:SetPoint("CENTER", self.manager, "CENTER", 0, 0)
    self.manager.caption:SetText("Grp")
        local manager = self.manager
    manager:RegisterForDrag("LeftButton")

    manager:SetScript("OnMouseDown", function(_, button)
        button = button or arg1
        manager.suppressClick = false

        if button == "LeftButton" and IsShiftKeyDown() then
            manager.suppressClick = true
        end
    end)

    manager:SetScript("OnDragStart", function()
        if Bar:GetDB().locked or not IsShiftKeyDown() then
            return
        end

        manager.suppressClick = true
        manager.isDragging = true
        GameTooltip:Hide()
        f:StartMoving()
    end)

    manager:SetScript("OnDragStop", function()
        if not manager.isDragging then
            return
        end

        f:StopMovingOrSizing()
        manager.isDragging = false
        Bar:RememberPosition()
    end)

    manager:SetScript("OnClick", function(_, button)
        button = button or arg1

        if manager.suppressClick then
            return
        end

        if button == "RightButton" then
            Bar:ToggleOptions()
        elseif not IsShiftKeyDown() then
            BotControl.Toggle()
        end
    end)
    self.manager:SetScript("OnEnter", function()
        local db = Bar:GetDB()
        local format = BotControl.GetActiveProfileFormat()
        GameTooltip:SetOwner(Bar.manager, "ANCHOR_RIGHT")
        GameTooltip:SetText("BotControl - " .. BotControl.GetProfileFormatConfig(format).label)
        GameTooltip:AddLine("Dernier profil charge / enregistre :", 0.8, 0.8, 0.8)
        GameTooltip:AddLine(db.profileNames[format] or "Composition manuelle", 1, 1, 1)
        GameTooltip:AddLine("Clic gauche : composition et profils", 0.6, 0.85, 1)
        GameTooltip:AddLine("Clic droit : reglages de la barre", 0.6, 0.85, 1)
        if db.locked then
            GameTooltip:AddLine("Position verrouillee", 0.6, 0.6, 0.6)
        else
            GameTooltip:AddLine(
                "Maj + glisser clic gauche : deplacer",
                0.6, 0.85, 1
            )
        end
        GameTooltip:Show()
    end)
    for _, category in ipairs(self.categories) do
        local key, label = category.key, category.label
        local b = self:NewIcon(f, "BotControlBar" .. key)
        self.buttons[key] = b
        b.caption:SetText(({ Config = "Cfg", Tank = "Tank", DPS = "DPS", Heal = "Heal", All = "Gen" })[key] or label)
        b:SetScript("OnClick", function(_, button)
            button = button or arg1
            if button == "RightButton" then Bar:ToggleMenu(key) else Bar:Run(b.actionKey) end
        end)
        b:SetScript("OnEnter", function()
            Bar:Tooltip(b, label, "Clic droit : ouvrir / fermer le sous-menu")
        end)
        local menu = CreateFrame("Frame", nil, f)
        menu:SetFrameLevel(f:GetFrameLevel() + 5)
        menu.buttons = {}; menu.open = false
        self.menus[key] = menu
        for index, action in ipairs(self:GetCategoryActions(key)) do
            local actionKey = action.key
            local item = self:NewIcon(menu)
            menu.buttons[index] = item
            self:SetAction(item, actionKey)
            item:SetScript("OnClick", function(_, button)
                button = button or arg1
                if button == "RightButton" then Bar:SetMain(key, actionKey) else Bar:Run(actionKey) end
            end)
            item:SetScript("OnEnter", function()
                Bar:Tooltip(item, label, "Clic droit : choisir comme bouton principal")
            end)
        end
    end
    for index = 1, 10 do
        local slot = index
        local b = self:NewIcon(f, "BotControlBarCustom" .. index)
        self.customButtons[index] = b
        b.caption:SetText("P" .. index)
        b:SetScript("OnClick", function(_, button)
            button = button or arg1
            if button == "RightButton" or not b.actionKey then Bar:OpenPicker(slot) else Bar:Run(b.actionKey) end
        end)
        b:SetScript("OnEnter", function()
            Bar:Tooltip(b, "Raccourci " .. slot, "Clic droit : choisir une action de n'importe quelle categorie")
        end)
    end
    self:Layout(); self:RestorePosition(); f:Show()
end

function Bar:Layout()
    if not self.frame then return end
    local db = self:GetDB()
    local vertical = db.orientation == "vertical"
    local size, spacing = db.size, db.spacing
    -- Optional captions reserve their own space: no overlap with neighbouring icons.
    local step = size + spacing + (db.labels and vertical and 16 or 0)
    local labelHeight = db.labels and 16 or 0
    local categoryCount = Count(self.categories)
    local total = 1 + categoryCount + db.customCount
    local length = total * step - spacing + 8 + (db.customCount > 0 and 8 or 0)
    self.frame:SetWidth(vertical and size or length)
    self.frame:SetHeight(vertical and length or size + labelHeight)
    local function Place(b, offset)
        b:SetWidth(size); b:SetHeight(size); b:ClearAllPoints()
        b:SetPoint("TOPLEFT", Bar.frame, "TOPLEFT", vertical and 0 or offset, vertical and -offset or 0)
        if db.labels then b.caption:Show() else b.caption:Hide() end
        b:Show()
    end
    Place(self.manager, 0)
    for index, category in ipairs(self.categories) do
        local b = self.buttons[category.key]
        Place(b, index * step + 8)
        self:SetAction(b, db.main[category.key])
        local menu = self.menus[category.key]
        local direction = vertical and db.verticalDirection or db.horizontalDirection
        b.mark:SetText(vertical and (direction == "LEFT" and "<" or ">") or (direction == "UP" and "^" or "v"))
        b:SetBackdropBorderColor(menu.open and 1 or 0.5, menu.open and 0.82 or 0.5, menu.open and 0 or 0.5, 1)
        local n = Count(menu.buttons)
        local span = n * (size + spacing) - spacing
        menu:SetWidth(vertical and math.max(size, span) or size)
        menu:SetHeight(vertical and size or math.max(size, span))
        menu:ClearAllPoints()
        if vertical then
            if direction == "LEFT" then menu:SetPoint("RIGHT", b, "LEFT", -spacing - 4, 0)
            else menu:SetPoint("LEFT", b, "RIGHT", spacing + 4, 0) end
        else
            if direction == "UP" then menu:SetPoint("BOTTOM", b, "TOP", 0, spacing + 4)
            else menu:SetPoint("TOP", b, "BOTTOM", 0, -spacing - 4 - labelHeight) end
        end
        for i, item in ipairs(menu.buttons) do
            item:SetWidth(size); item:SetHeight(size); item:ClearAllPoints()
            local delta = (i - 1) * (size + spacing)
            if vertical then
                if direction == "LEFT" then item:SetPoint("RIGHT", menu, "RIGHT", -delta, 0)
                else item:SetPoint("LEFT", menu, "LEFT", delta, 0) end
            else
                if direction == "UP" then item:SetPoint("BOTTOM", menu, "BOTTOM", 0, delta)
                else item:SetPoint("TOP", menu, "TOP", 0, -delta) end
            end
            item.caption:Hide()
            item.mark:SetText(item.actionKey == b.actionKey and "*" or "")
        end
        if menu.open then menu:Show() else menu:Hide() end
    end
    for i, b in ipairs(self.customButtons) do
        if i <= db.customCount then
            Place(b, (categoryCount + i) * step + 16)
            local key = db.custom[i]
            if not BotControl.GetActionByKey(key) then key = nil end
            self:SetAction(b, key)
        else b:Hide() end
    end
    self:UpdateManager()
end

function Bar:SetCustom(slot, actionKey)
    if slot < 1 or slot > 10 then return end
    if actionKey and not BotControl.GetActionByKey(actionKey) then return end
    self:GetDB().custom[slot] = actionKey
    GameTooltip:Hide()
    self:Layout()
    if self.options then self:RefreshOptions() end
    if self.picker then self.picker:Hide() end
end

function Bar:OpenPicker(slot)
    if not self.picker then
        local f = Window("BotControlActionPicker", "Choisir un raccourci", 460, 440)
        self.picker = f
        f:SetFrameStrata("FULLSCREEN_DIALOG")
        f.subtitle = Label(f, "", 18, -45)
        f.filters = {}
        local filterStep = math.floor(428 / Count(self.categories))
        for i, category in ipairs(self.categories) do
            local key = category.key

            f.filters[i] = TextButton(
                f,
                category.label,
                16 + (i - 1) * filterStep,
                -72,
                filterStep - 4,
                function()
                    f.category = key
                    f.page = 1
                    Bar:RefreshPicker()
                end
            )
        end
        f.rows = {}
        for i = 1, 9 do
            local row = TextButton(f, "", 20, -104 - (i - 1) * 29, 420, function() end)
            row:SetScript("OnClick", function() Bar:SetCustom(f.slot, row.actionKey) end)
            row:SetScript("OnEnter", function() Bar:Tooltip(row, "Raccourci " .. f.slot, "Clic gauche : affecter ce raccourci") end)
            row:SetScript("OnLeave", function() GameTooltip:Hide() end)
            f.rows[i] = row
        end
        f.previous = TextButton(f, "<", 20, -374, 38, function() f.page = f.page - 1; Bar:RefreshPicker() end)
        f.next = TextButton(f, ">", 65, -374, 38, function() f.page = f.page + 1; Bar:RefreshPicker() end)
        f.pageLabel = Label(f, "", 115, -380)
        TextButton(f, "Vider ce raccourci", 264, -374, 176, function() Bar:SetCustom(f.slot, nil) end)
    end
    local f = self.picker
    f.slot = slot; f.page = 1
    local action = BotControl.GetActionByKey(self:GetDB().custom[slot])
    f.category = action and action.group or "Config"
    self:RefreshPicker(); f:Show()
end

function Bar:RefreshPicker()
    local f = self.picker
    local actions = self:GetCategoryActions(f.category)
    local pages = math.max(1, math.ceil(Count(actions) / 9))
    f.page = math.max(1, math.min(pages, f.page))
    f.subtitle:SetText("Perso " .. f.slot .. " - choisir une action")
    for i, category in ipairs(self.categories) do
        if category.key == f.category then f.filters[i]:Disable() else f.filters[i]:Enable() end
    end
    for i, row in ipairs(f.rows) do
        local action = actions[(f.page - 1) * 9 + i]
        if action then
            row.actionKey = action.key; row:SetText(action.label); row:Show()
        else row:Hide() end
    end
    f.pageLabel:SetText(f.page .. " / " .. pages)
    if f.page > 1 then f.previous:Enable() else f.previous:Disable() end
    if f.page < pages then f.next:Enable() else f.next:Disable() end
end

local function Slider(parent, name, title, y, minimum, maximum, field)
    local s = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    s:SetWidth(235); s:SetHeight(16); s:SetPoint("TOPLEFT", parent, "TOPLEFT", 24, y)
    s:SetMinMaxValues(minimum, maximum); s:SetValueStep(1)
    _G[name .. "Low"]:SetText(tostring(minimum)); _G[name .. "High"]:SetText(tostring(maximum))
    s:SetScript("OnValueChanged", function()
        if parent.refreshing then return end
        Bar:GetDB()[field] = Clamp(s:GetValue(), minimum, maximum, minimum)
        Bar:Layout(); Bar:RefreshOptions()
    end)
    s.title = title; s.field = field; s.titleLabel = _G[name .. "Text"]
    return s
end

function Bar:CreateOptions()
    local f = Window("BotControlBarOptions", "BotControl - Reglages de la barre", 620, 565)
    self.options = f
    Label(f, "Disposition", 24, -55)
    f.orientation = TextButton(f, "", 24, -80, 235, function()
        local db = Bar:GetDB()
        db.orientation = db.orientation == "horizontal" and "vertical" or "horizontal"
        Bar:Layout(); Bar:RefreshOptions()
    end)
    f.direction = TextButton(f, "", 24, -116, 235, function()
        local db = Bar:GetDB()
        if db.orientation == "vertical" then db.verticalDirection = db.verticalDirection == "LEFT" and "RIGHT" or "LEFT"
        else db.horizontalDirection = db.horizontalDirection == "UP" and "DOWN" or "UP" end
        Bar:Layout(); Bar:RefreshOptions()
    end)
    f.sliders = {
        Slider(f, "BotControlBarSizeSlider", "Taille des boutons", -180, 24, 64, "size"),
        Slider(f, "BotControlBarSpacingSlider", "Espacement", -243, 0, 16, "spacing"),
        Slider(f, "BotControlBarCustomSlider", "Raccourcis personnalises", -306, 0, 10, "customCount")
    }
    f.lock = CreateFrame("CheckButton", "BotControlBarLockCheck", f, "UICheckButtonTemplate")
    f.lock:SetWidth(26); f.lock:SetHeight(26); f.lock:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -348)
    _G["BotControlBarLockCheckText"]:SetText("Verrouiller la position")
    f.lock:SetScript("OnClick", function() Bar:GetDB().locked = not not f.lock:GetChecked(); Bar:Layout() end)
    f.labels = CreateFrame("CheckButton", "BotControlBarLabelsCheck", f, "UICheckButtonTemplate")
    f.labels:SetWidth(26); f.labels:SetHeight(26); f.labels:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -382)
    _G["BotControlBarLabelsCheckText"]:SetText("Afficher les categories")
    f.labels:SetScript("OnClick", function() Bar:GetDB().labels = not not f.labels:GetChecked(); Bar:Layout() end)
    TextButton(f, "Recentrer la barre", 24, -426, 235, function()
        local db = Bar:GetDB(); db.x = nil; db.y = nil; Bar:RestorePosition()
    end)
    Label(f, "Affectation des raccourcis", 300, -55)
    f.customRows = {}
    for i = 1, 10 do
        local slot = i
        f.customRows[i] = TextButton(f, "", 300, -80 - (i - 1) * 36, 290, function() Bar:OpenPicker(slot) end)
    end
    local note = Label(f, "", 24, -474, "GameFontHighlightSmall")
    note:SetWidth(560); note:SetJustifyH("LEFT")
    note:SetText("Clic droit sur une categorie : ouvrir / fermer.\nClic droit dans un sous-menu : choisir le principal.\nLes clics gauches executent les actions et laissent les menus ouverts.")
    TextButton(f, "Profils", 300, -426, 138, function()
        f:Hide(); BotControl_ShowTab("Profiles"); BotControlFrame:Show()
    end)
    TextButton(f, "Fermer", 452, -426, 138, function() f:Hide() end)
end

function Bar:RefreshOptions()
    local f, db = self.options, self:GetDB()
    if not f then return end
    f.refreshing = true
    f.orientation:SetText("Barre : " .. (db.orientation == "vertical" and "verticale" or "horizontale"))
    local direction = db.orientation == "vertical" and db.verticalDirection or db.horizontalDirection
    local names = { UP = "haut", DOWN = "bas", LEFT = "gauche", RIGHT = "droite" }
    f.direction:SetText("Sous-menus vers : " .. names[direction])
    for _, slider in ipairs(f.sliders) do
        slider:SetValue(db[slider.field]); slider.titleLabel:SetText(slider.title .. " : " .. db[slider.field])
    end
    f.lock:SetChecked(db.locked); f.labels:SetChecked(db.labels)
    for i, row in ipairs(f.customRows) do
        local action = BotControl.GetActionByKey(db.custom[i])
        row:SetText(i .. " - " .. (action and action.label or "Choisir une action..."))
        if i <= db.customCount then row:Show() else row:Hide() end
    end
    f.refreshing = false
end

function Bar:ToggleOptions()
    if not self.options then self:CreateOptions() end
    if self.options:IsShown() then self.options:Hide()
    else self:RefreshOptions(); self.options:Show() end
end

-- Called after the existing profile layout, preserving all composition controls.
function Bar:LayoutProfiles()
    if not BotControlFrame then return end
    if BotControlTabProfiles then BotControlTabProfiles:SetText("Profils") end
    if BotControlTabActions then
        BotControlTabActions:SetText("Reglages")
        BotControlTabActions:SetScript("OnClick", function() Bar:ToggleOptions() end)
    end
    if not self.compose then
        self.compose = TextButton(BotControlFrame, "Composer le groupe", 0, 0, 170, function() Bar:Run("ComposeGroup") end)
        self.closeProfiles = TextButton(BotControlFrame, "Fermer", 0, 0, 88, function() BotControlFrame:Hide() end)
    end
    self.compose:ClearAllPoints(); self.compose:SetPoint("BOTTOMLEFT", BotControlFrame, "BOTTOMLEFT", 124, 20)
    self.closeProfiles:ClearAllPoints(); self.closeProfiles:SetPoint("BOTTOMLEFT", BotControlFrame, "BOTTOMLEFT", 304, 20)
    if BotControl.currentTab == "Profiles" then self.compose:Show(); self.closeProfiles:Show()
    else self.compose:Hide(); self.closeProfiles:Hide() end
    if BotControlFrameSaveButton then BotControlFrameSaveButton:SetText("Appliquer") end
    self:UpdateManager()
end

function Bar:RememberProfile(name)
    local format = BotControl.GetActiveProfileFormat()
    self:GetDB().profileNames[format] = name
    self:UpdateManager()
end

function Bar:Initialize()
    local db = self:GetDB()
    for _, format in ipairs(BotControl.PROFILE_FORMAT_ORDER) do
        local name = db.profileNames[format]
        if name and BotControl.GetProfilesTable(format)[name] then
            BotControl.selectedProfileNamesByFormat[format] = name
        end
    end
    self:Create(); self:LayoutProfiles()
    BotControl.RefreshProfileList()
end
