BotControl = {}
BotControl_ProfileElements = {}
BotControl_ActionElements = {}
BotControl_ActionSubTabElements = {}
BotControl_ActionConfigElements = {}
BotControl_ActionCombatElements = {}
BotControl.selectedProfileName = nil
BotControl_SelectedProfileName = nil
BotControl.currentTab = "Profiles"
BotControl.currentActionsSubTab = "Config"

BotControl.PROFILES_FRAME_WIDTH = 595
BotControl.PROFILES_FRAME_HEIGHT = 350
BotControl.ACTIONS_CONFIG_FRAME_WIDTH = 400
BotControl.ACTIONS_COMBAT_FRAME_WIDTH = 360
BotControl.ACTIONS_BASE_HEIGHT = 146
BotControl.ACTIONS_ICON_SIZE = 36
BotControl.ACTIONS_ICON_SPACING = 12
BotControl.ACTIONS_ROW_SPACING = 16
BotControl.ACTIONS_ICONS_PER_ROW = 3
BotControl.COMMAND_INTERVAL = 0.15
BotControl.commandQueue = {}

BotControl.ACTION_BUTTON_CONFIG = {
    ComposeGroup = {
        texture = "Interface\\Icons\\Spell_Nature_MassTeleport",
        title = "Composer le groupe",
        description = "Cree le groupe avec les bots configures"
    },
    Build = {
        texture = "Interface\\Icons\\Ability_Marksmanship",
        title = "Appliquer les spes",
        description = "Applique les talents aux bots configures"
    },
    Init = {
        texture = "Interface\\Icons\\INV_Misc_Gear_01",
        title = "Initialiser",
        description = "Applique la configuration de base des bots"
    },
    FullSetup = {
        texture = "Interface\\Icons\\Spell_Holy_BlessingOfStamina",
        title = "Preparation complete",
        description = "Lance Build, Init"
    },
    Summon = {
        texture = "Interface\\Icons\\Spell_Shadow_Teleport",
        title = "Invocation",
        description = "Invoque tous les bots configures"
    },
    InitBots = {
        texture = "Interface\\Icons\\INV_Misc_Gear_01",
        title = "Initialisation bots",
        description = "Lance .bot init, .bot learn, .bot gear et .bot prepare"
    },
    TankAttack = {
        texture = "Interface\\Icons\\Ability_Warrior_Charge",
        title = "Attaque du tank",
        description = "Ordonne au tank d'attaquer, les autres attendent"
    },
    AttackDPS = {
        texture = "Interface\\Icons\\Ability_BackStab",
        title = "Attaque DPS",
        description = "Ordonne aux DPS d'attaquer"
    },
    Follow = {
        texture = "Interface\\Icons\\Ability_Hunter_Pathfinding",
        title = "Suivre",
        description = "Ordonne a tout le groupe de suivre"
    },
    Passive = {
        texture = "Interface\\Icons\\Ability_Rogue_FeignDeath",
        title = "Passif",
        description = "Ordonne au groupe de fuir / se desengager"
    },
    Stay = {
        texture = "Interface\\Icons\\Spell_Nature_TimeStop",
        title = "Rester sur place",
        description = "Ordonne au groupe de rester en place"
    },
    Used = {
        texture = "Interface\\Icons\\INV_Misc_Wrench_01",
        title = "Utiliser",
        description = "Lance la commande /p u go"
    }
}

BotControl.PROFILE_BUTTON_CONFIG = {
    Save = {
        texture = "Interface\\Icons\\INV_Misc_Note_01",
        title = "Sauvegarder le profil",
        description = "Enregistre le profil avec le nom saisi"
    },
    Load = {
        texture = "Interface\\Icons\\Spell_Arcane_PortalIronForge",
        title = "Charger le profil",
        description = "Charge le profil selectionne"
    },
    Delete = {
        texture = "Interface\\Icons\\INV_Misc_Bone_ElfSkull_01",
        title = "Supprimer le profil",
        description = "Supprime le profil selectionne"
    }
}

BotControl.FIELD_DEFINITIONS = {
    { key = "tankName", label = "Bot 1", column = "left", order = 1 },
    { key = "healName", label = "Bot 2", column = "left", order = 2 },
    { key = "dps1Name", label = "Bot 3", column = "left", order = 3 },
    { key = "dps2Name", label = "Bot 4", column = "left", order = 4 },
    { key = "dps3Name", label = "Bot 5", column = "left", order = 5 },
    { key = "tankBuild", roleKey = "tankRole", classKey = "tankClass", label = "", column = "right", order = 1, control = "classSpec" },
    { key = "healBuild", roleKey = "healRole", classKey = "healClass", label = "", column = "right", order = 2, control = "classSpec" },
    { key = "dps1Build", roleKey = "dps1Role", classKey = "dps1Class", label = "", column = "right", order = 3, control = "classSpec" },
    { key = "dps2Build", roleKey = "dps2Role", classKey = "dps2Class", label = "", column = "right", order = 4, control = "classSpec" },
    { key = "dps3Build", roleKey = "dps3Role", classKey = "dps3Class", label = "", column = "right", order = 5, control = "classSpec" }
}

BotControl.Roles = {
    "tank",
    "heal",
    "dps",
}

BotControl.Classes = {
    "Paladin",
    "Guerrier",
    "Chasseur",
    "Voleur",
    "Prêtre",
    "Mage",
    "Démoniste",
    "Chaman",
    "Druide",
}

BotControl.ClassSpecs = {
    ["Paladin"] = {
        "pve prot",
        "pve holy",
        "pve dps ret",
    },
    ["Guerrier"] = {
        "pve prot",
        "pve arms",
        "pve fury",
    },
    ["Chasseur"] = {
        "pve dps mm",
        "pve dps bm",
        "pve survival",
    },
    ["Voleur"] = {
        "pve assassination",
        "pve assassination v2",
        "pve dps combat",
    },
    ["Prêtre"] = {
        "pve heal disc",
        "pve heal holy",
        "pve dps shadow",
    },
    ["Mage"] = {
        "pve dps arcane",
        "pve dps fire",
        "pve dps frost",
    },
    ["Démoniste"] = {
        "pve dps destro",
        "pve dps affli",
    },
    ["Chaman"] = {
        "pve resto",
        "pve dps elem",
        "pve dps enh",
    },
    ["Druide"] = {
        "pve dps feral tank",
        "pve resto",
        "pve dps balance",
        "pve dps feral cat",
    },
}

local eventFrame = CreateFrame("Frame", "BotControlEventFrame")
local commandQueueFrame = CreateFrame("Frame", "BotControlCommandQueueFrame")
commandQueueFrame:Hide()

function BotControl.Trim(text)
    if not text then
        return ""
    end

    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")

    return text
end

function BotControl.HasValue(value)
    return value ~= nil and value ~= ""
end

function BotControl.GetDefaultRoleForField(key)
    if key == "tankName" or key == "tankBuild" then
        return "tank"
    end

    if key == "healName" or key == "healBuild" then
        return "heal"
    end

    return "dps"
end

function BotControl.NormalizeRole(roleName, fallbackRole)
    local index

    roleName = BotControl.Trim(roleName or "")
    for index = 1, table.getn(BotControl.Roles) do
        if BotControl.Roles[index] == roleName then
            return roleName
        end
    end

    fallbackRole = BotControl.Trim(fallbackRole or "")
    for index = 1, table.getn(BotControl.Roles) do
        if BotControl.Roles[index] == fallbackRole then
            return fallbackRole
        end
    end

    return "dps"
end

function BotControl.CopyList(source)
    local copy = {}
    local index

    if type(source) ~= "table" then
        return copy
    end

    for index = 1, table.getn(source) do
        table.insert(copy, source[index])
    end

    return copy
end

function BotControl.GetSpecsForClass(className)
    local specs = BotControl.ClassSpecs[className]

    if type(specs) ~= "table" then
        return {}
    end

    return BotControl.CopyList(specs)
end

function BotControl.IsSpecValidForClass(className, specName)
    local specs
    local index

    className = BotControl.Trim(className or "")
    specName = BotControl.Trim(specName or "")
    if not BotControl.HasValue(className) or not BotControl.HasValue(specName) then
        return false
    end

    specs = BotControl.ClassSpecs[className]
    if type(specs) ~= "table" then
        return false
    end

    for index = 1, table.getn(specs) do
        if specs[index] == specName then
            return true
        end
    end

    return false
end

function BotControl.GetClassForSpec(specName)
    local className
    local specs
    local index
    local foundClass

    specName = BotControl.Trim(specName or "")
    if not BotControl.HasValue(specName) then
        return ""
    end

    for className, specs in pairs(BotControl.ClassSpecs) do
        if type(specs) == "table" then
            for index = 1, table.getn(specs) do
                if specs[index] == specName then
                    if foundClass and foundClass ~= className then
                        return ""
                    end

                    foundClass = className
                end
            end
        end
    end

    return foundClass or ""
end

function BotControl.ExtractBuildSelection(buildData, fallbackClass)
    local className = ""
    local specName = ""

    if type(buildData) == "table" then
        className = BotControl.Trim(buildData.class or "")
        specName = BotControl.Trim(buildData.spec or buildData.build or "")
    elseif type(buildData) == "string" then
        specName = BotControl.Trim(buildData)
    end

    if not BotControl.HasValue(className) then
        className = BotControl.Trim(fallbackClass or "")
    end

    if not BotControl.HasValue(className) and BotControl.HasValue(specName) then
        className = BotControl.GetClassForSpec(specName)
    end

    return className, specName
end

function BotControl.CreateProfileBuildEntry(className, specName)
    return {
        class = BotControl.Trim(className or ""),
        spec = BotControl.Trim(specName or "")
    }
end

function BotControl.CreateProfileSlotEntry(name, roleName, className, specName, fallbackRole)
    return {
        name = BotControl.Trim(name or ""),
        role = BotControl.NormalizeRole(roleName, fallbackRole),
        class = BotControl.Trim(className or ""),
        spec = BotControl.Trim(specName or "")
    }
end

function BotControl.ExtractSlotSelection(slotData, fallbackName, fallbackRole, fallbackBuild)
    local name = BotControl.Trim(fallbackName or "")
    local roleName = BotControl.NormalizeRole(nil, fallbackRole)
    local className
    local specName

    className, specName = BotControl.ExtractBuildSelection(fallbackBuild)

    if type(slotData) == "table" then
        if BotControl.HasValue(slotData.name) then
            name = BotControl.Trim(slotData.name)
        end

        roleName = BotControl.NormalizeRole(slotData.role, roleName)
        className, specName = BotControl.ExtractBuildSelection(slotData, className)
    end

    return name, roleName, className, specName
end

function BotControl.UpdateDropdownValue(dropdown, value, emptyText)
    value = BotControl.Trim(value or "")
    dropdown.selectedValue = value

    if BotControl.HasValue(value) then
        UIDropDownMenu_SetSelectedValue(dropdown, value)
        UIDropDownMenu_SetText(value, dropdown)
    else
        UIDropDownMenu_SetText(emptyText or "", dropdown)
    end
end

function BotControl.SetupDropdown(dropdown, items, selectedValue, emptyText, onSelect)
    local menuFrame = dropdown

    dropdown.items = items or {}
    dropdown.emptyText = emptyText or ""
    dropdown.onSelect = onSelect

    UIDropDownMenu_Initialize(dropdown, function(level)
        local index
        local optionValue
        local optionText
        local info

        if level and level ~= 1 then
            return
        end

        for index = 1, table.getn(menuFrame.items) do
            optionValue = menuFrame.items[index]
            optionText = optionValue
            if optionText == "" then
                optionText = "-"
            end
            info = UIDropDownMenu_CreateInfo()
            info.text = optionText
            info.value = optionValue
            do
                local selectedOption = optionValue
                info.func = function()
                    BotControl.UpdateDropdownValue(menuFrame, selectedOption, menuFrame.emptyText)

                    if menuFrame.onSelect then
                        menuFrame.onSelect(selectedOption)
                    end
                end
            end
            UIDropDownMenu_AddButton(info, 1)
        end
    end)

    BotControl.UpdateDropdownValue(dropdown, selectedValue, emptyText)
end

function BotControl.Print(message)
    return
end

function BotControl.Toggle()
    if not BotControlFrame then
        return
    end

    if BotControlFrame:IsShown() then
        BotControlFrame:Hide()
    else
        BotControl_LayoutButtons()
        BotControlFrame:Show()
    end
end

function BotControl.RegisterSpecialFrame(frameName)
    local index

    if not frameName then
        return
    end

    if type(UISpecialFrames) ~= "table" then
        UISpecialFrames = {}
    end

    for index = 1, table.getn(UISpecialFrames) do
        if UISpecialFrames[index] == frameName then
            return
        end
    end

    table.insert(UISpecialFrames, frameName)
end

function BotControl.CreateTextField(parent, definition)
    local rowY = -78 - ((definition.order - 1) * 40)
    local labelX
    local boxX
    local label
    local editBox

    if definition.column == "left" then
        labelX = 24
        boxX = 24
    else
        labelX = 222
        boxX = 222
    end

    label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", labelX, rowY)
    label:SetJustifyH("LEFT")
    label:SetText(definition.label)

    editBox = CreateFrame("EditBox", nil, parent)
    if definition.column == "left" then
        editBox:SetWidth(140)
    else
        editBox:SetWidth(150)
    end
    editBox:SetHeight(20)
    editBox:SetPoint("TOPLEFT", parent, "TOPLEFT", boxX, rowY - 14)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(GameFontHighlightSmall)
    editBox:SetJustifyH("LEFT")
    editBox:SetTextInsets(6, 6, 2, 2)
    editBox:SetMaxLetters(64)

    editBox:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    editBox:SetBackdropColor(0, 0, 0, 0.8)
    editBox:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    editBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)

    return {
        key = definition.key,
        label = label,
        editBox = editBox,
        CollectValues = function(self, values)
            values[self.key] = BotControl.Trim(self.editBox:GetText() or "")
        end,
        ApplyValues = function(self, values)
            self.editBox:SetText(values[self.key] or "")
        end
    }
end

function BotControl.CreateClassSpecField(parent, definition)
    local rowY = -78 - ((definition.order - 1) * 40)
    local roleDropdown
    local classDropdown
    local specDropdown
    local field
    local roleItems = BotControl.CopyList(BotControl.Roles)
    local classItems = BotControl.CopyList(BotControl.Classes)
    local roleDropdownX = 150
    local roleDropdownWidth = 42
    local classDropdownWidth = 56
    local firstDropdownSpacing = -18
    local dropdownSpacing = -18
    local specDropdownWidth = 68

    table.insert(classItems, 1, "")

    roleDropdown = CreateFrame("Frame", "BotControl" .. definition.key .. "RoleDropDown", parent, "UIDropDownMenuTemplate")
    roleDropdown:ClearAllPoints()
    roleDropdown:SetPoint("TOPLEFT", parent, "TOPLEFT", roleDropdownX, rowY - 8)
    UIDropDownMenu_SetWidth(roleDropdownWidth, roleDropdown)
    UIDropDownMenu_JustifyText("LEFT", roleDropdown)

    classDropdown = CreateFrame("Frame", "BotControl" .. definition.key .. "ClassDropDown", parent, "UIDropDownMenuTemplate")
    classDropdown:ClearAllPoints()
    classDropdown:SetPoint("LEFT", roleDropdown, "RIGHT", firstDropdownSpacing, 0)
    UIDropDownMenu_SetWidth(classDropdownWidth, classDropdown)
    UIDropDownMenu_JustifyText("LEFT", classDropdown)

    specDropdown = CreateFrame("Frame", "BotControl" .. definition.key .. "SpecDropDown", parent, "UIDropDownMenuTemplate")
    specDropdown:ClearAllPoints()
    specDropdown:SetPoint("LEFT", classDropdown, "RIGHT", dropdownSpacing, 0)
    UIDropDownMenu_SetWidth(specDropdownWidth, specDropdown)
    UIDropDownMenu_JustifyText("LEFT", specDropdown)

    field = {
        key = definition.key,
        roleKey = definition.roleKey,
        classKey = definition.classKey,
        roleDropdown = roleDropdown,
        classDropdown = classDropdown,
        specDropdown = specDropdown,
        roleItems = roleItems,
        classItems = classItems,
        currentRole = BotControl.GetDefaultRoleForField(definition.key),
        currentClass = "",
        currentSpec = ""
    }

    field.RefreshSpecDropdown = function(self, preserveLegacySpec)
        local specItems = {}

        if BotControl.HasValue(self.currentClass) then
            specItems = BotControl.GetSpecsForClass(self.currentClass)
            if not BotControl.IsSpecValidForClass(self.currentClass, self.currentSpec) then
                if table.getn(specItems) > 0 then
                    self.currentSpec = specItems[1]
                else
                    self.currentSpec = ""
                end
            end
        elseif preserveLegacySpec and BotControl.HasValue(self.currentSpec) then
            table.insert(specItems, self.currentSpec)
        else
            self.currentSpec = ""
        end

        BotControl.SetupDropdown(self.specDropdown, specItems, self.currentSpec, "Spe", function(selectedSpec)
            self.currentSpec = BotControl.Trim(selectedSpec or "")
        end)
    end

    field.SetSelection = function(self, roleName, className, specName, preserveLegacySpec)
        self.currentRole = BotControl.NormalizeRole(roleName, BotControl.GetDefaultRoleForField(self.key))
        self.currentClass = BotControl.Trim(className or "")
        self.currentSpec = BotControl.Trim(specName or "")

        BotControl.SetupDropdown(self.roleDropdown, self.roleItems, self.currentRole, "Role", function(selectedRole)
            self.currentRole = BotControl.NormalizeRole(selectedRole, BotControl.GetDefaultRoleForField(self.key))
        end)

        BotControl.SetupDropdown(self.classDropdown, self.classItems, self.currentClass, "Classe", function(selectedClass)
            local specs

            self.currentClass = BotControl.Trim(selectedClass or "")
            if BotControl.HasValue(self.currentClass) then
                if not BotControl.IsSpecValidForClass(self.currentClass, self.currentSpec) then
                    specs = BotControl.GetSpecsForClass(self.currentClass)
                    if table.getn(specs) > 0 then
                        self.currentSpec = specs[1]
                    else
                        self.currentSpec = ""
                    end
                end
            else
                self.currentSpec = ""
            end

            self:RefreshSpecDropdown(false)
        end)

        self:RefreshSpecDropdown(preserveLegacySpec)
    end

    field.CollectValues = function(self, values)
        values[self.roleKey] = BotControl.NormalizeRole(self.currentRole, BotControl.GetDefaultRoleForField(self.key))
        values[self.classKey] = BotControl.Trim(self.currentClass or "")
        values[self.key] = BotControl.Trim(self.currentSpec or "")
    end

    field.ApplyValues = function(self, values)
        self:SetSelection(values[self.roleKey], values[self.classKey], values[self.key], true)
    end

    field:SetSelection(BotControl.GetDefaultRoleForField(definition.key), "", "", false)

    return field
end

function BotControl.CreateField(parent, definition)
    if definition.control == "classSpec" then
        return BotControl.CreateClassSpecField(parent, definition)
    end

    return BotControl.CreateTextField(parent, definition)
end

function BotControl.BuildFields(frame)
    local index
    local definition

    frame.fields = {}

    for index = 1, table.getn(BotControl.FIELD_DEFINITIONS) do
        definition = BotControl.FIELD_DEFINITIONS[index]
        table.insert(frame.fields, BotControl.CreateField(frame, definition))
    end
end

function BotControl.AddElement(targetTable, element)
    if not targetTable or not element then
        return
    end

    table.insert(targetTable, element)
end

function BotControl_UpdateFrameSizeForView(mainTab, subTab)
    local frame = BotControlFrame
    local width
    local height
    local iconCount
    local rows

    if not frame then
        return
    end

    if mainTab == "Profiles" then
        BotControl.currentTab = "Profiles"
        width = BotControl.PROFILES_FRAME_WIDTH
        height = BotControl.PROFILES_FRAME_HEIGHT
    else
        BotControl.currentTab = "Actions"
        if subTab == "Combat" then
            BotControl.currentActionsSubTab = "Combat"
            width = BotControl.ACTIONS_COMBAT_FRAME_WIDTH
            if BotControl_ActionCombatElements and table.getn(BotControl_ActionCombatElements) > 0 then
                iconCount = table.getn(BotControl_ActionCombatElements)
            else
                iconCount = 6
            end
        else
            BotControl.currentActionsSubTab = "Config"
            width = BotControl.ACTIONS_CONFIG_FRAME_WIDTH
            if BotControl_ActionConfigElements and table.getn(BotControl_ActionConfigElements) > 0 then
                iconCount = table.getn(BotControl_ActionConfigElements)
            else
                iconCount = 6
            end
        end

        rows = math.ceil(iconCount / BotControl.ACTIONS_ICONS_PER_ROW)
        height = BotControl.ACTIONS_BASE_HEIGHT + (rows * (BotControl.ACTIONS_ICON_SIZE + BotControl.ACTIONS_ROW_SPACING))
    end

    frame:SetWidth(width)
    frame:SetHeight(height)
end

function BotControl_UpdateFrameSize(viewName, iconCount)
    if viewName == "Profiles" then
        BotControl_UpdateFrameSizeForView("Profiles")
    elseif viewName == "Combat" then
        BotControl_UpdateFrameSizeForView("Actions", "Combat")
    else
        BotControl_UpdateFrameSizeForView("Actions", "Config")
    end
end

function BotControl.GetSortedProfileNames()
    local db = BotControlConfig:GetDB()
    local names = {}
    local profileName

    if type(db.profiles) ~= "table" then
        return names
    end

    for profileName in pairs(db.profiles) do
        table.insert(names, profileName)
    end

    table.sort(names)

    return names
end

function BotControl.GetSelectedProfileName()
    if BotControl.HasValue(BotControl.selectedProfileName) then
        return BotControl.selectedProfileName
    end

    return BotControl.GetProfileName()
end

function BotControl.SelectProfile(profileName)
    profileName = BotControl.Trim(profileName or "")
    if not BotControl.HasValue(profileName) then
        BotControl.selectedProfileName = nil
        BotControl_SelectedProfileName = nil
        if BotControlProfileNameEditBox then
            BotControlProfileNameEditBox:SetText("")
        end
        return
    end

    BotControl.selectedProfileName = profileName
    BotControl_SelectedProfileName = profileName

    if BotControlProfileNameEditBox then
        BotControlProfileNameEditBox:SetText(profileName)
    end

    BotControl.RefreshProfileList()
end

function BotControl.RefreshProfileList()
    local names = BotControl.GetSortedProfileNames()
    local selectedName = BotControl.selectedProfileName
    local rowButtons = BotControl.profileListButtons
    local row
    local rowButton
    local name

    if not rowButtons then
        return
    end

    if selectedName and not BotControlConfig:GetDB().profiles[selectedName] then
        selectedName = nil
        BotControl.selectedProfileName = nil
        BotControl_SelectedProfileName = nil
    end

    for row = 1, table.getn(rowButtons) do
        rowButton = rowButtons[row]
        name = names[row]

        if name then
            rowButton.profileName = name
            rowButton.text:SetText(name)
            rowButton:Show()

            if selectedName == name then
                rowButton.text:SetTextColor(0.2, 1, 0.2, 1)
            else
                rowButton.text:SetTextColor(1, 1, 1, 1)
            end
        else
            rowButton.profileName = nil
            rowButton.text:SetText("")
            rowButton.text:SetTextColor(1, 1, 1, 1)
            rowButton:Hide()
        end
    end
end

function BotControl.CleanupButtonTemplate(button)
    local buttonName
    local region
    local regions
    local index

    if not button then
        return
    end

    if button:GetFontString() then
        button:GetFontString():SetText("")
        button:GetFontString():Hide()
    end

    buttonName = button:GetName()
    if buttonName then
        region = getglobal(buttonName .. "Left")
        if region then
            region:SetTexture(nil)
            region:Hide()
        end

        region = getglobal(buttonName .. "Middle")
        if region then
            region:SetTexture(nil)
            region:Hide()
        end

        region = getglobal(buttonName .. "Right")
        if region then
            region:SetTexture(nil)
            region:Hide()
        end

        region = getglobal(buttonName .. "LeftDisabled")
        if region then
            region:SetTexture(nil)
            region:Hide()
        end

        region = getglobal(buttonName .. "MiddleDisabled")
        if region then
            region:SetTexture(nil)
            region:Hide()
        end

        region = getglobal(buttonName .. "RightDisabled")
        if region then
            region:SetTexture(nil)
            region:Hide()
        end
    end

    regions = { button:GetRegions() }
    for index = 1, table.getn(regions) do
        region = regions[index]
        if region and region ~= button:GetNormalTexture() and region ~= button:GetPushedTexture() and region ~= button:GetHighlightTexture() and region ~= button:GetDisabledTexture() and region ~= button.iconTexture then
            if region.GetObjectType and region:GetObjectType() == "FontString" then
                region:SetText("")
                region:Hide()
            end
        end
    end
end

function BotControl_SetActionButtonIcon(button, texturePath, title, description)
    if not button then
        return
    end

    BotControl.CleanupButtonTemplate(button)
    button:SetWidth(36)
    button:SetHeight(36)
    button:SetText("")
    button:SetNormalTexture(nil)
    button:SetPushedTexture(nil)
    button:SetDisabledTexture(nil)
    button:SetHighlightTexture(nil)

    if not button.iconTexture then
        button.iconTexture = button:CreateTexture(nil, "ARTWORK")
        button.iconTexture:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
        button.iconTexture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
        button.iconTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end

    button.iconTexture:SetTexture(texturePath)
    button.iconTexture:SetVertexColor(1, 1, 1)
    button.tooltipTitle = title or ""
    button.tooltipDescription = description or ""

    button:SetScript("OnEnter", function(self)
        if self.iconTexture then
            self.iconTexture:SetVertexColor(1, 1, 1)
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.tooltipTitle or "")
        if BotControl.HasValue(self.tooltipDescription) then
            GameTooltip:AddLine(self.tooltipDescription, 1, 1, 1, 1)
        end
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        if button.iconTexture then
            button.iconTexture:SetVertexColor(1, 1, 1)
        end
        GameTooltip:Hide()
    end)

    button:SetScript("OnMouseDown", function(self)
        if self.iconTexture then
            self.iconTexture:SetPoint("TOPLEFT", self, "TOPLEFT", 3, -3)
            self.iconTexture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1)
            self.iconTexture:SetVertexColor(0.8, 0.8, 0.8)
        end
    end)

    button:SetScript("OnMouseUp", function(self)
        if self.iconTexture then
            self.iconTexture:ClearAllPoints()
            self.iconTexture:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2)
            self.iconTexture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2)
            self.iconTexture:SetVertexColor(1, 1, 1)
        end
    end)
end

function BotControl.StyleActionButtons()
    local config

    config = BotControl.ACTION_BUTTON_CONFIG.ComposeGroup
    BotControl_SetActionButtonIcon(BotControlFrameComposeGroupButton, config.texture, config.title, config.description)

    config = BotControl.ACTION_BUTTON_CONFIG.Build
    BotControl_SetActionButtonIcon(BotControlFrameBuildButton, config.texture, config.title, config.description)

    config = BotControl.ACTION_BUTTON_CONFIG.Init
    BotControl_SetActionButtonIcon(BotControlFrameInitButton, config.texture, config.title, config.description)

    config = BotControl.ACTION_BUTTON_CONFIG.FullSetup
    BotControl_SetActionButtonIcon(BotControlFullSetupButton, config.texture, config.title, config.description)

    config = BotControl.ACTION_BUTTON_CONFIG.Summon
    BotControl_SetActionButtonIcon(BotControlFrameSummonButton, config.texture, config.title, config.description)

    config = BotControl.ACTION_BUTTON_CONFIG.InitBots
    BotControl_SetActionButtonIcon(BotControlInitBotsButton, config.texture, config.title, config.description)

    config = BotControl.ACTION_BUTTON_CONFIG.TankAttack
    BotControl_SetActionButtonIcon(BotControlFrameTankAttackButton, config.texture, config.title, config.description)

    config = BotControl.ACTION_BUTTON_CONFIG.AttackDPS
    BotControl_SetActionButtonIcon(BotControlAttackDPSButton, config.texture, config.title, config.description)

    config = BotControl.ACTION_BUTTON_CONFIG.Follow
    BotControl_SetActionButtonIcon(BotControlFollowButton, config.texture, config.title, config.description)

    config = BotControl.ACTION_BUTTON_CONFIG.Passive
    BotControl_SetActionButtonIcon(BotControlPassiveButton, config.texture, config.title, config.description)

    config = BotControl.ACTION_BUTTON_CONFIG.Stay
    BotControl_SetActionButtonIcon(BotControlStayButton, config.texture, config.title, config.description)

    config = BotControl.ACTION_BUTTON_CONFIG.Used
    BotControl_SetActionButtonIcon(BotControlUsedButton, config.texture, config.title, config.description)
end

function BotControl.StyleProfileControls()
    local config

    if BotControlProfileNameEditBox then
        BotControlProfileNameEditBox:SetBackdropColor(0, 0, 0, 0.92)
        BotControlProfileNameEditBox:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)
        BotControlProfileNameEditBox:SetTextColor(1, 1, 1, 1)
    end

    config = BotControl.PROFILE_BUTTON_CONFIG.Save
    BotControl_SetActionButtonIcon(BotControlSaveProfileButton, config.texture, config.title, config.description)

    config = BotControl.PROFILE_BUTTON_CONFIG.Load
    BotControl_SetActionButtonIcon(BotControlLoadProfileButton, config.texture, config.title, config.description)

    config = BotControl.PROFILE_BUTTON_CONFIG.Delete
    BotControl_SetActionButtonIcon(BotControlDeleteProfileButton, config.texture, config.title, config.description)
end

function BotControl.RegisterTabElements(frame)
    local index
    local field

    BotControl_ProfileElements = {}
    BotControl_ActionElements = {}
    BotControl_ActionSubTabElements = {}
    BotControl_ActionConfigElements = {}
    BotControl_ActionCombatElements = {}

    BotControl.AddElement(BotControl_ProfileElements, BotControlFrameNamesHeader)
    BotControl.AddElement(BotControl_ProfileElements, BotControlFrameBuildsHeader)
    BotControl.AddElement(BotControl_ProfileElements, BotControlFrameProfileNameLabel)
    BotControl.AddElement(BotControl_ProfileElements, BotControlProfilesListLabel)
    BotControl.AddElement(BotControl_ProfileElements, BotControlProfilesListFrame)
    BotControl.AddElement(BotControl_ProfileElements, BotControlProfileNameEditBox)
    BotControl.AddElement(BotControl_ProfileElements, BotControlSaveProfileButton)
    BotControl.AddElement(BotControl_ProfileElements, BotControlLoadProfileButton)
    BotControl.AddElement(BotControl_ProfileElements, BotControlDeleteProfileButton)
    BotControl.AddElement(BotControl_ProfileElements, BotControlFrameSaveButton)

    if BotControl.profileListButtons then
        for index = 1, table.getn(BotControl.profileListButtons) do
            BotControl.AddElement(BotControl_ProfileElements, BotControl.profileListButtons[index])
        end
    end

    if frame and frame.fields then
        for index = 1, table.getn(frame.fields) do
            field = frame.fields[index]
            if field then
                BotControl.AddElement(BotControl_ProfileElements, field.label)
                if field.editBox then
                    BotControl.AddElement(BotControl_ProfileElements, field.editBox)
                end
                if field.roleDropdown then
                    BotControl.AddElement(BotControl_ProfileElements, field.roleDropdown)
                end
                if field.classDropdown then
                    BotControl.AddElement(BotControl_ProfileElements, field.classDropdown)
                end
                if field.specDropdown then
                    BotControl.AddElement(BotControl_ProfileElements, field.specDropdown)
                end
            end
        end
    end

    BotControl.AddElement(BotControl_ActionElements, BotControlFrameComposeGroupButton)
    BotControl.AddElement(BotControl_ActionElements, BotControlFrameBuildButton)
    BotControl.AddElement(BotControl_ActionElements, BotControlFrameInitButton)
    BotControl.AddElement(BotControl_ActionElements, BotControlFullSetupButton)
    BotControl.AddElement(BotControl_ActionElements, BotControlFrameSummonButton)
    BotControl.AddElement(BotControl_ActionElements, BotControlInitBotsButton)
    BotControl.AddElement(BotControl_ActionElements, BotControlFrameTankAttackButton)
    BotControl.AddElement(BotControl_ActionElements, BotControlAttackDPSButton)
    BotControl.AddElement(BotControl_ActionElements, BotControlFollowButton)
    BotControl.AddElement(BotControl_ActionElements, BotControlPassiveButton)
    BotControl.AddElement(BotControl_ActionElements, BotControlStayButton)
    BotControl.AddElement(BotControl_ActionElements, BotControlUsedButton)
    BotControl.AddElement(BotControl_ActionElements, BotControlActionsSubTabConfig)
    BotControl.AddElement(BotControl_ActionElements, BotControlActionsSubTabCombat)

    BotControl.AddElement(BotControl_ActionSubTabElements, BotControlActionsSubTabConfig)
    BotControl.AddElement(BotControl_ActionSubTabElements, BotControlActionsSubTabCombat)

    BotControl.AddElement(BotControl_ActionConfigElements, BotControlFrameComposeGroupButton)
    BotControl.AddElement(BotControl_ActionConfigElements, BotControlFrameBuildButton)
    BotControl.AddElement(BotControl_ActionConfigElements, BotControlFrameInitButton)
    BotControl.AddElement(BotControl_ActionConfigElements, BotControlFullSetupButton)
    BotControl.AddElement(BotControl_ActionConfigElements, BotControlFrameSummonButton)
    BotControl.AddElement(BotControl_ActionConfigElements, BotControlInitBotsButton)

    BotControl.AddElement(BotControl_ActionCombatElements, BotControlFrameTankAttackButton)
    BotControl.AddElement(BotControl_ActionCombatElements, BotControlAttackDPSButton)
    BotControl.AddElement(BotControl_ActionCombatElements, BotControlFollowButton)
    BotControl.AddElement(BotControl_ActionCombatElements, BotControlPassiveButton)
    BotControl.AddElement(BotControl_ActionCombatElements, BotControlStayButton)
    BotControl.AddElement(BotControl_ActionCombatElements, BotControlUsedButton)
end

function BotControl_ShowActionsSubTab(tabName)
    local index
    local element

    if tabName ~= "Combat" then
        tabName = "Config"
    end

    BotControl.currentActionsSubTab = tabName

    for index = 1, table.getn(BotControl_ActionSubTabElements) do
        element = BotControl_ActionSubTabElements[index]
        if element then
            element:Show()
        end
    end

    if tabName == "Combat" then
        for index = 1, table.getn(BotControl_ActionConfigElements) do
            element = BotControl_ActionConfigElements[index]
            if element then
                element:Hide()
            end
        end

        for index = 1, table.getn(BotControl_ActionCombatElements) do
            element = BotControl_ActionCombatElements[index]
            if element then
                element:Show()
            end
        end
    else
        for index = 1, table.getn(BotControl_ActionCombatElements) do
            element = BotControl_ActionCombatElements[index]
            if element then
                element:Hide()
            end
        end

        for index = 1, table.getn(BotControl_ActionConfigElements) do
            element = BotControl_ActionConfigElements[index]
            if element then
                element:Show()
            end
        end
    end

    BotControl_UpdateFrameSizeForView("Actions", tabName)
    BotControl_LayoutButtons()
end

function BotControl_ShowTab(tabName)
    local index
    local element

    if tabName == "Actions" then
        BotControl.currentTab = "Actions"

        for index = 1, table.getn(BotControl_ProfileElements) do
            element = BotControl_ProfileElements[index]
            if element then
                element:Hide()
            end
        end

        for index = 1, table.getn(BotControl_ActionElements) do
            element = BotControl_ActionElements[index]
            if element then
                element:Show()
            end
        end

        BotControl_ShowActionsSubTab("Config")
    else
        tabName = "Profiles"
        BotControl.currentTab = "Profiles"

        for index = 1, table.getn(BotControl_ProfileElements) do
            element = BotControl_ProfileElements[index]
            if element then
                element:Show()
            end
        end

        for index = 1, table.getn(BotControl_ActionElements) do
            element = BotControl_ActionElements[index]
            if element then
                element:Hide()
            end
        end

        BotControl.RefreshProfileList()
        BotControl_UpdateFrameSizeForView("Profiles")
        BotControl_LayoutButtons()
    end

end

function BotControl.InitializeFrame(frame)
    if frame.isInitialized then
        return
    end

    BotControl.BuildFields(frame)
    BotControl.CreateButtons(frame)
    BotControl.StyleActionButtons()
    BotControl.StyleProfileControls()
    BotControl.RegisterTabElements(frame)
    BotControl.RegisterSpecialFrame("BotControlFrame")
    frame.isInitialized = true
end

function BotControl.CreateButtons(frame)
    local fullSetupButton
    local initBotsButton
    local attackDpsButton
    local followButton
    local passiveButton
    local stayButton
    local usedButton
    local saveProfileButton
    local loadProfileButton
    local deleteProfileButton
    local configSubTabButton
    local combatSubTabButton
    local profileListLabel
    local profileListFrame
    local profileListButton
    local profilesTabButton
    local actionsTabButton
    local index

    if not frame then
        return
    end

    if not BotControlTabProfiles then
        profilesTabButton = CreateFrame("Button", "BotControlTabProfiles", frame, "UIPanelButtonTemplate")
        profilesTabButton:SetText("Profiles")
        profilesTabButton:SetWidth(90)
        profilesTabButton:SetHeight(22)
        profilesTabButton:SetScript("OnClick", function()
            BotControl_ShowTab("Profiles")
        end)
    end

    if not BotControlTabActions then
        actionsTabButton = CreateFrame("Button", "BotControlTabActions", frame, "UIPanelButtonTemplate")
        actionsTabButton:SetText("Actions")
        actionsTabButton:SetWidth(90)
        actionsTabButton:SetHeight(22)
        actionsTabButton:SetScript("OnClick", function()
            BotControl_ShowTab("Actions")
        end)
    end

    if not BotControlActionsSubTabConfig then
        configSubTabButton = CreateFrame("Button", "BotControlActionsSubTabConfig", frame, "UIPanelButtonTemplate")
        configSubTabButton:SetText("Config")
        configSubTabButton:SetWidth(78)
        configSubTabButton:SetHeight(20)
        configSubTabButton:SetScript("OnClick", function()
            BotControl_ShowActionsSubTab("Config")
        end)
    end

    if not BotControlActionsSubTabCombat then
        combatSubTabButton = CreateFrame("Button", "BotControlActionsSubTabCombat", frame, "UIPanelButtonTemplate")
        combatSubTabButton:SetText("Combat")
        combatSubTabButton:SetWidth(78)
        combatSubTabButton:SetHeight(20)
        combatSubTabButton:SetScript("OnClick", function()
            BotControl_ShowActionsSubTab("Combat")
        end)
    end

    if not BotControlFullSetupButton then
        fullSetupButton = CreateFrame("Button", "BotControlFullSetupButton", frame, "UIPanelButtonTemplate")
        fullSetupButton:SetText("Full setup")
        fullSetupButton:SetWidth(140)
        fullSetupButton:SetHeight(24)
        fullSetupButton:SetScript("OnClick", function()
            BotControl_RunNamedAction("FullSetup")
        end)
    end

    if not BotControlInitBotsButton then
        initBotsButton = CreateFrame("Button", "BotControlInitBotsButton", frame, "UIPanelButtonTemplate")
        initBotsButton:SetText("Init bots")
        initBotsButton:SetWidth(110)
        initBotsButton:SetHeight(24)
        initBotsButton:SetScript("OnClick", function()
            BotControl_RunNamedAction("InitBots")
        end)
    end

    if not BotControlAttackDPSButton then
        attackDpsButton = CreateFrame("Button", "BotControlAttackDPSButton", frame, "UIPanelButtonTemplate")
        attackDpsButton:SetText("Attack DPS")
        attackDpsButton:SetWidth(110)
        attackDpsButton:SetHeight(24)
        attackDpsButton:SetScript("OnClick", function()
            BotControl_RunNamedAction("AttackDPS")
        end)
    end

    if not BotControlFollowButton then
        followButton = CreateFrame("Button", "BotControlFollowButton", frame, "UIPanelButtonTemplate")
        followButton:SetText("Follow")
        followButton:SetWidth(110)
        followButton:SetHeight(24)
        followButton:SetScript("OnClick", function()
            BotControl_RunNamedAction("Follow")
        end)
    end

    if not BotControlPassiveButton then
        passiveButton = CreateFrame("Button", "BotControlPassiveButton", frame, "UIPanelButtonTemplate")
        passiveButton:SetText("Passif")
        passiveButton:SetWidth(110)
        passiveButton:SetHeight(24)
        passiveButton:SetScript("OnClick", function()
            BotControl_RunNamedAction("Passive")
        end)
    end

    if not BotControlStayButton then
        stayButton = CreateFrame("Button", "BotControlStayButton", frame, "UIPanelButtonTemplate")
        stayButton:SetText("Stay")
        stayButton:SetWidth(110)
        stayButton:SetHeight(24)
        stayButton:SetScript("OnClick", function()
            BotControl_RunNamedAction("Stay")
        end)
    end

    if not BotControlUsedButton then
        usedButton = CreateFrame("Button", "BotControlUsedButton", frame, "UIPanelButtonTemplate")
        usedButton:SetText("Used")
        usedButton:SetWidth(110)
        usedButton:SetHeight(24)
        usedButton:SetScript("OnClick", function()
            BotControl_RunNamedAction("Used")
        end)
    end

    if not BotControlSaveProfileButton then
        saveProfileButton = CreateFrame("Button", "BotControlSaveProfileButton", frame, "UIPanelButtonTemplate")
        saveProfileButton:SetText("Save profile")
        saveProfileButton:SetWidth(110)
        saveProfileButton:SetHeight(24)
        saveProfileButton:SetScript("OnClick", function()
            BotControl_SaveProfile(BotControl.GetProfileName())
        end)
    end

    if not BotControlLoadProfileButton then
        loadProfileButton = CreateFrame("Button", "BotControlLoadProfileButton", frame, "UIPanelButtonTemplate")
        loadProfileButton:SetText("Load profile")
        loadProfileButton:SetWidth(110)
        loadProfileButton:SetHeight(24)
        loadProfileButton:SetScript("OnClick", function()
            BotControl_LoadProfile(BotControl.GetSelectedProfileName())
        end)
    end

    if not BotControlDeleteProfileButton then
        deleteProfileButton = CreateFrame("Button", "BotControlDeleteProfileButton", frame, "UIPanelButtonTemplate")
        deleteProfileButton:SetText("Delete profile")
        deleteProfileButton:SetWidth(110)
        deleteProfileButton:SetHeight(24)
        deleteProfileButton:SetScript("OnClick", function()
            BotControl_DeleteProfile(BotControl.GetSelectedProfileName())
        end)
    end

    if not BotControlProfilesListLabel then
        profileListLabel = frame:CreateFontString("BotControlProfilesListLabel", "OVERLAY", "GameFontNormal")
        profileListLabel:SetJustifyH("LEFT")
        profileListLabel:SetText("Profils enregistres")
    end

    if not BotControlProfilesListFrame then
        profileListFrame = CreateFrame("Frame", "BotControlProfilesListFrame", frame)
        profileListFrame:SetWidth(140)
        profileListFrame:SetHeight(180)
        profileListFrame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        profileListFrame:SetBackdropColor(0, 0, 0, 0.5)
        profileListFrame:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)
    end

    if not BotControl.profileListButtons then
        BotControl.profileListButtons = {}

        for index = 1, 8 do
            profileListButton = CreateFrame("Button", nil, BotControlProfilesListFrame)
            profileListButton:SetWidth(122)
            profileListButton:SetHeight(16)
            profileListButton.text = profileListButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            profileListButton.text:SetPoint("LEFT", profileListButton, "LEFT", 2, 0)
            profileListButton.text:SetPoint("RIGHT", profileListButton, "RIGHT", -2, 0)
            profileListButton.text:SetJustifyH("LEFT")
            profileListButton.text:SetText("")
            profileListButton:SetScript("OnClick", function(self)
                BotControl.SelectProfile(self.profileName)
            end)

            if index == 1 then
                profileListButton:SetPoint("TOPLEFT", BotControlProfilesListFrame, "TOPLEFT", 8, -8)
            else
                profileListButton:SetPoint("TOPLEFT", BotControl.profileListButtons[index - 1], "BOTTOMLEFT", 0, -4)
            end

            BotControl.profileListButtons[index] = profileListButton
        end
    end
end

function BotControl.GetProfileName()
    if not BotControlProfileNameEditBox then
        return ""
    end

    return BotControl.Trim(BotControlProfileNameEditBox:GetText() or "")
end

function BotControl.GetFieldValuesFromUI(frame)
    local values = {}
    local index
    local field

    if not frame or not frame.fields then
        return values
    end

    for index = 1, table.getn(frame.fields) do
        field = frame.fields[index]
        if field and field.CollectValues then
            field:CollectValues(values)
        elseif field and field.editBox then
            values[field.key] = BotControl.Trim(field.editBox:GetText() or "")
        end
    end

    return values
end

function BotControl.ApplyValuesToUI(frame, values)
    local index
    local field
    local text

    if not frame or not frame.fields or type(values) ~= "table" then
        return
    end

    for index = 1, table.getn(frame.fields) do
        field = frame.fields[index]
        if field and field.ApplyValues then
            field:ApplyValues(values)
        elseif field and field.editBox then
            text = values[field.key] or ""
            field.editBox:SetText(text)
        end
    end
end

function BotControl.SyncGroupsToDB(values)
    local db

    if type(values) ~= "table" then
        return
    end

    db = BotControlConfig:GetDB()
    if type(db.bots) ~= "table" then
        db.bots = {}
    end
    if type(db.builds) ~= "table" then
        db.builds = {}
    end

    db.bots.tank = values.tankName or ""
    db.bots.heal = values.healName or ""
    db.bots.dps1 = values.dps1Name or ""
    db.bots.dps2 = values.dps2Name or ""
    db.bots.dps3 = values.dps3Name or ""

    db.builds.tank = values.tankBuild or ""
    db.builds.heal = values.healBuild or ""
    db.builds.dps1 = values.dps1Build or ""
    db.builds.dps2 = values.dps2Build or ""
    db.builds.dps3 = values.dps3Build or ""
end

function BotControl.BuildProfileFromValues(values)
    return {
        bots = {
            tank = values.tankName or "",
            heal = values.healName or "",
            dps1 = values.dps1Name or "",
            dps2 = values.dps2Name or "",
            dps3 = values.dps3Name or ""
        },
        builds = {
            tank = BotControl.CreateProfileBuildEntry(values.tankClass, values.tankBuild),
            heal = BotControl.CreateProfileBuildEntry(values.healClass, values.healBuild),
            dps1 = BotControl.CreateProfileBuildEntry(values.dps1Class, values.dps1Build),
            dps2 = BotControl.CreateProfileBuildEntry(values.dps2Class, values.dps2Build),
            dps3 = BotControl.CreateProfileBuildEntry(values.dps3Class, values.dps3Build)
        },
        slots = {
            BotControl.CreateProfileSlotEntry(values.tankName, values.tankRole, values.tankClass, values.tankBuild, "tank"),
            BotControl.CreateProfileSlotEntry(values.healName, values.healRole, values.healClass, values.healBuild, "heal"),
            BotControl.CreateProfileSlotEntry(values.dps1Name, values.dps1Role, values.dps1Class, values.dps1Build, "dps"),
            BotControl.CreateProfileSlotEntry(values.dps2Name, values.dps2Role, values.dps2Class, values.dps2Build, "dps"),
            BotControl.CreateProfileSlotEntry(values.dps3Name, values.dps3Role, values.dps3Class, values.dps3Build, "dps")
        }
    }
end

function BotControl.BuildValuesFromProfile(profile)
    local values = {}
    local name
    local roleName
    local className
    local specName
    local slots

    if type(profile) ~= "table" then
        return values
    end

    if type(profile.bots) ~= "table" then
        profile.bots = {}
    end
    if type(profile.builds) ~= "table" then
        profile.builds = {}
    end
    if type(profile.slots) == "table" then
        slots = profile.slots
    end

    values.tankName = profile.bots.tank or ""
    values.healName = profile.bots.heal or ""
    values.dps1Name = profile.bots.dps1 or ""
    values.dps2Name = profile.bots.dps2 or ""
    values.dps3Name = profile.bots.dps3 or ""

    name, roleName, className, specName = BotControl.ExtractSlotSelection(slots and slots[1], profile.bots.tank, "tank", profile.builds.tank)
    values.tankName = name
    values.tankRole = roleName
    values.tankClass = className
    values.tankBuild = specName

    name, roleName, className, specName = BotControl.ExtractSlotSelection(slots and slots[2], profile.bots.heal, "heal", profile.builds.heal)
    values.healName = name
    values.healRole = roleName
    values.healClass = className
    values.healBuild = specName

    name, roleName, className, specName = BotControl.ExtractSlotSelection(slots and slots[3], profile.bots.dps1, "dps", profile.builds.dps1)
    values.dps1Name = name
    values.dps1Role = roleName
    values.dps1Class = className
    values.dps1Build = specName

    name, roleName, className, specName = BotControl.ExtractSlotSelection(slots and slots[4], profile.bots.dps2, "dps", profile.builds.dps2)
    values.dps2Name = name
    values.dps2Role = roleName
    values.dps2Class = className
    values.dps2Build = specName

    name, roleName, className, specName = BotControl.ExtractSlotSelection(slots and slots[5], profile.bots.dps3, "dps", profile.builds.dps3)
    values.dps3Name = name
    values.dps3Role = roleName
    values.dps3Class = className
    values.dps3Build = specName

    return values
end

function BotControl_SaveProfile(profileName)
    local frame = BotControlFrame
    local db
    local values

    profileName = BotControl.Trim(profileName or "")
    if not BotControl.HasValue(profileName) then
        return
    end

    if frame then
        BotControlConfig:SaveFromUI(frame)
    end

    values = BotControl.GetFieldValuesFromUI(frame)
    if not next(values) then
        values = {
            tankName = BotControlConfig:GetValue("tankName"),
            healName = BotControlConfig:GetValue("healName"),
            dps1Name = BotControlConfig:GetValue("dps1Name"),
            dps2Name = BotControlConfig:GetValue("dps2Name"),
            dps3Name = BotControlConfig:GetValue("dps3Name"),
            tankRole = BotControlConfig:GetValue("tankRole"),
            healRole = BotControlConfig:GetValue("healRole"),
            dps1Role = BotControlConfig:GetValue("dps1Role"),
            dps2Role = BotControlConfig:GetValue("dps2Role"),
            dps3Role = BotControlConfig:GetValue("dps3Role"),
            tankClass = BotControlConfig:GetValue("tankClass"),
            healClass = BotControlConfig:GetValue("healClass"),
            dps1Class = BotControlConfig:GetValue("dps1Class"),
            dps2Class = BotControlConfig:GetValue("dps2Class"),
            dps3Class = BotControlConfig:GetValue("dps3Class"),
            tankBuild = BotControlConfig:GetValue("tankBuild"),
            healBuild = BotControlConfig:GetValue("healBuild"),
            dps1Build = BotControlConfig:GetValue("dps1Build"),
            dps2Build = BotControlConfig:GetValue("dps2Build"),
            dps3Build = BotControlConfig:GetValue("dps3Build")
        }
    end

    db = BotControlConfig:GetDB()
    if type(db.profiles) ~= "table" then
        db.profiles = {}
    end

    db.profiles[profileName] = BotControl.BuildProfileFromValues(values)
    BotControl.SyncGroupsToDB(values)
    BotControl.selectedProfileName = profileName
    BotControl.RefreshProfileList()
end

function BotControl_LoadProfile(profileName)
    local frame = BotControlFrame
    local db = BotControlConfig:GetDB()
    local profile
    local values
    local key

    profileName = BotControl.Trim(profileName or "")
    if not BotControl.HasValue(profileName) then
        return
    end

    if type(db.profiles) ~= "table" then
        db.profiles = {}
    end

    profile = db.profiles[profileName]
    if type(profile) ~= "table" then
        return
    end

    values = BotControl.BuildValuesFromProfile(profile)

    for key, value in pairs(values) do
        BotControlConfig:SetValue(key, value)
    end

    BotControl.SyncGroupsToDB(values)
    BotControl.ApplyValuesToUI(frame, values)
    BotControl.selectedProfileName = profileName
    BotControl.RefreshProfileList()
end

function BotControl_DeleteProfile(profileName)
    local db = BotControlConfig:GetDB()

    profileName = BotControl.Trim(profileName or "")
    if not BotControl.HasValue(profileName) then
        return
    end

    if type(db.profiles) ~= "table" then
        db.profiles = {}
    end

    if not db.profiles[profileName] then
        return
    end

    db.profiles[profileName] = nil
    if BotControl.selectedProfileName == profileName then
        BotControl.selectedProfileName = nil
    end
    BotControl.RefreshProfileList()
end

function BotControl_LayoutButtons()
    local frame = BotControlFrame
    local profilesTabButton = BotControlTabProfiles
    local actionsTabButton = BotControlTabActions
    local configSubTabButton = BotControlActionsSubTabConfig
    local combatSubTabButton = BotControlActionsSubTabCombat
    local namesHeader = BotControlFrameNamesHeader
    local buildsHeader = BotControlFrameBuildsHeader
    local profileNameLabel = BotControlFrameProfileNameLabel
    local profilesListLabel = BotControlProfilesListLabel
    local profilesListFrame = BotControlProfilesListFrame
    local profileNameEditBox = BotControlProfileNameEditBox
    local saveProfileButton = BotControlSaveProfileButton
    local loadProfileButton = BotControlLoadProfileButton
    local deleteProfileButton = BotControlDeleteProfileButton
    local composeGroupButton = BotControlFrameComposeGroupButton
    local buildButton = BotControlFrameBuildButton
    local initButton = BotControlFrameInitButton
    local fullSetupButton = BotControlFullSetupButton
    local summonButton = BotControlFrameSummonButton
    local initBotsButton = BotControlInitBotsButton
    local tankAttackButton = BotControlFrameTankAttackButton
    local attackDpsButton = BotControlAttackDPSButton
    local followButton = BotControlFollowButton
    local passiveButton = BotControlPassiveButton
    local stayButton = BotControlStayButton
    local usedButton = BotControlUsedButton
    local saveButton = BotControlFrameSaveButton
    local iconSpacing = BotControl.ACTIONS_ICON_SPACING
    local rowSpacing = BotControl.ACTIONS_ROW_SPACING
    local actionsAnchor

    if not frame then
        return
    end

    if profilesTabButton then
        profilesTabButton:ClearAllPoints()
        profilesTabButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -30)
    end

    if actionsTabButton then
        actionsTabButton:ClearAllPoints()
        if profilesTabButton then
            actionsTabButton:SetPoint("LEFT", profilesTabButton, "RIGHT", 10, 0)
        else
            actionsTabButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 120, -30)
        end
    end

    if configSubTabButton then
        configSubTabButton:ClearAllPoints()
        configSubTabButton:SetWidth(78)
        configSubTabButton:SetHeight(20)
        configSubTabButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -60)
    end

    if combatSubTabButton then
        combatSubTabButton:ClearAllPoints()
        combatSubTabButton:SetWidth(78)
        combatSubTabButton:SetHeight(20)
        if configSubTabButton then
            combatSubTabButton:SetPoint("LEFT", configSubTabButton, "RIGHT", 8, 0)
        else
            combatSubTabButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 106, -60)
        end
    end

    if namesHeader then
        namesHeader:ClearAllPoints()
        namesHeader:SetText("Bots")
        namesHeader:SetPoint("TOPLEFT", frame, "TOPLEFT", 24, -58)
    end

    if buildsHeader then
        buildsHeader:ClearAllPoints()
        buildsHeader:SetText("")
        buildsHeader:SetPoint("TOPLEFT", frame, "TOPLEFT", 190, -58)
    end

    if profilesListLabel then
        profilesListLabel:ClearAllPoints()
        profilesListLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 436, -58)
    end

    if profilesListFrame then
        profilesListFrame:ClearAllPoints()
        profilesListFrame:SetWidth(138)
        profilesListFrame:SetHeight(160)
        profilesListFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 432, -76)
    end

    if profileNameLabel then
        profileNameLabel:ClearAllPoints()
        if profilesListFrame then
            profileNameLabel:SetPoint("TOPLEFT", profilesListFrame, "BOTTOMLEFT", 0, -14)
        else
            profileNameLabel:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 394, 84)
        end
    end

    if profileNameEditBox then
        profileNameEditBox:ClearAllPoints()
        profileNameEditBox:SetWidth(138)
        profileNameEditBox:SetHeight(22)
        profileNameEditBox:SetPoint("TOPLEFT", profileNameLabel, "BOTTOMLEFT", 0, -6)
    end

    if saveProfileButton then
        saveProfileButton:ClearAllPoints()
        saveProfileButton:SetWidth(36)
        saveProfileButton:SetHeight(36)
        if profileNameEditBox then
            saveProfileButton:SetPoint("TOPLEFT", profileNameEditBox, "BOTTOMLEFT", 0, -10)
        else
            saveProfileButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 394, 20)
        end
    end

    if loadProfileButton then
        loadProfileButton:ClearAllPoints()
        loadProfileButton:SetWidth(36)
        loadProfileButton:SetHeight(36)
        if saveProfileButton then
            loadProfileButton:SetPoint("LEFT", saveProfileButton, "RIGHT", 8, 0)
        else
            loadProfileButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 466, 20)
        end
    end

    if deleteProfileButton then
        deleteProfileButton:ClearAllPoints()
        deleteProfileButton:SetWidth(36)
        deleteProfileButton:SetHeight(36)
        if loadProfileButton then
            deleteProfileButton:SetPoint("LEFT", loadProfileButton, "RIGHT", 8, 0)
        elseif saveProfileButton then
            deleteProfileButton:SetPoint("LEFT", saveProfileButton, "RIGHT", 8, 0)
        end
    end

    if BotControl.currentTab == "Actions" and BotControl.currentActionsSubTab == "Combat" and combatSubTabButton then
        actionsAnchor = combatSubTabButton
    elseif configSubTabButton then
        actionsAnchor = configSubTabButton
    else
        actionsAnchor = actionsTabButton
    end

    if BotControl.currentTab == "Actions" and BotControl.currentActionsSubTab == "Combat" then
        if tankAttackButton then
            tankAttackButton:ClearAllPoints()
            if actionsAnchor then
                tankAttackButton:SetPoint("TOPLEFT", actionsAnchor, "BOTTOMLEFT", 0, -24)
            else
                tankAttackButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -104)
            end
        end

        if attackDpsButton then
            attackDpsButton:ClearAllPoints()
            if tankAttackButton then
                attackDpsButton:SetPoint("LEFT", tankAttackButton, "RIGHT", iconSpacing, 0)
            end
        end

        if followButton then
            followButton:ClearAllPoints()
            if attackDpsButton then
                followButton:SetPoint("LEFT", attackDpsButton, "RIGHT", iconSpacing, 0)
            end
        end

        if passiveButton then
            passiveButton:ClearAllPoints()
            if tankAttackButton then
                passiveButton:SetPoint("TOPLEFT", tankAttackButton, "BOTTOMLEFT", 0, -rowSpacing)
            end
        end

        if stayButton then
            stayButton:ClearAllPoints()
            if passiveButton then
                stayButton:SetPoint("LEFT", passiveButton, "RIGHT", iconSpacing, 0)
            end
        end

        if usedButton then
            usedButton:ClearAllPoints()
            if stayButton then
                usedButton:SetPoint("LEFT", stayButton, "RIGHT", iconSpacing, 0)
            end
        end

        if composeGroupButton then
            composeGroupButton:ClearAllPoints()
        end
        if buildButton then
            buildButton:ClearAllPoints()
        end
        if initButton then
            initButton:ClearAllPoints()
        end
        if fullSetupButton then
            fullSetupButton:ClearAllPoints()
        end
        if summonButton then
            summonButton:ClearAllPoints()
        end
        if initBotsButton then
            initBotsButton:ClearAllPoints()
        end
    else
        if composeGroupButton then
            composeGroupButton:ClearAllPoints()
            if actionsAnchor then
                composeGroupButton:SetPoint("TOPLEFT", actionsAnchor, "BOTTOMLEFT", 0, -24)
            else
                composeGroupButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -104)
            end
        end

        if buildButton then
            buildButton:ClearAllPoints()
            if composeGroupButton then
                buildButton:SetPoint("LEFT", composeGroupButton, "RIGHT", iconSpacing, 0)
            end
        end

        if initButton then
            initButton:ClearAllPoints()
            if buildButton then
                initButton:SetPoint("LEFT", buildButton, "RIGHT", iconSpacing, 0)
            end
        end

        if fullSetupButton then
            fullSetupButton:ClearAllPoints()
            if composeGroupButton then
                fullSetupButton:SetPoint("TOPLEFT", composeGroupButton, "BOTTOMLEFT", 0, -rowSpacing)
            end
        end

        if summonButton then
            summonButton:ClearAllPoints()
            if fullSetupButton then
                summonButton:SetPoint("LEFT", fullSetupButton, "RIGHT", iconSpacing, 0)
            end
        end

        if initBotsButton then
            initBotsButton:ClearAllPoints()
            if summonButton then
                initBotsButton:SetPoint("LEFT", summonButton, "RIGHT", iconSpacing, 0)
            end
        end

        if tankAttackButton then
            tankAttackButton:ClearAllPoints()
        end
        if attackDpsButton then
            attackDpsButton:ClearAllPoints()
        end
        if followButton then
            followButton:ClearAllPoints()
        end
        if passiveButton then
            passiveButton:ClearAllPoints()
        end
        if stayButton then
            stayButton:ClearAllPoints()
        end
        if usedButton then
            usedButton:ClearAllPoints()
        end
    end

    if saveButton then
        saveButton:ClearAllPoints()
        saveButton:SetText("Save")
        if saveButton:GetFontString() then
            saveButton:GetFontString():Show()
        end
        saveButton:SetWidth(88)
        saveButton:SetHeight(24)
        saveButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 24, 20)
    end

end

function BotControl.Save()
    BotControlConfig:SaveFromUI(BotControlFrame)
    BotControl.SyncGroupsToDB(BotControl.GetFieldValuesFromUI(BotControlFrame))
end

function BotControl.Load()
    local db = BotControlConfig:GetDB()

    BotControlConfig:LoadToUI(BotControlFrame)
    BotControl.SyncGroupsToDB({
        tankName = db.tankName or "",
        healName = db.healName or "",
        dps1Name = db.dps1Name or "",
        dps2Name = db.dps2Name or "",
        dps3Name = db.dps3Name or "",
        tankBuild = db.tankBuild or "",
        healBuild = db.healBuild or "",
        dps1Build = db.dps1Build or "",
        dps2Build = db.dps2Build or "",
        dps3Build = db.dps3Build or ""
    })
end

function BotControl.SendChatCommand(commandType, message, target)
    if not BotControl.HasValue(message) then
        return
    end

    if commandType == "WHISPER" and BotControl.HasValue(target) then
        SendChatMessage(message, "WHISPER", nil, target)
    elseif commandType == "PARTY" then
        SendChatMessage(message, "PARTY")
    end
end

function BotControl.ExecuteSlashCommand(command)
    local editBox
    local targetEditBox

    if not BotControl.HasValue(command) then
        return
    end

    editBox = ChatFrameEditBox or DEFAULT_CHAT_FRAME.editBox
    if not editBox then
        return
    end

    ChatFrame_OpenChat(command, DEFAULT_CHAT_FRAME)
    if ChatFrameEditBox and ChatFrameEditBox:GetText() == command then
        targetEditBox = ChatFrameEditBox
        ChatEdit_SendText(targetEditBox, 0)
    elseif DEFAULT_CHAT_FRAME.editBox and DEFAULT_CHAT_FRAME.editBox:GetText() == command then
        targetEditBox = DEFAULT_CHAT_FRAME.editBox
        ChatEdit_SendText(targetEditBox, 0)
    else
        editBox:SetText(command)
        targetEditBox = editBox
        ChatEdit_SendText(targetEditBox, 0)
    end

    if targetEditBox then
        targetEditBox:SetText("")
        if ChatEdit_DeactivateChat then
            ChatEdit_DeactivateChat(targetEditBox)
        else
            targetEditBox:ClearFocus()
            targetEditBox:Hide()
        end
    end
end

function BotControl.ExecuteCommandNow(command)
    if type(command) == "string" then
        BotControl.ExecuteSlashCommand(command)
        return
    end

    if type(command) ~= "table" then
        return
    end

    if command.type == "WHISPER" or command.type == "PARTY" then
        BotControl.SendChatCommand(command.type, command.message, command.target)
    elseif command.type == "SLASH" then
        BotControl.ExecuteSlashCommand(command.command)
    end
end

function BotControl.ProcessCommandQueue()
    local command

    if not BotControl.commandQueue or table.getn(BotControl.commandQueue) == 0 then
        commandQueueFrame:Hide()
        return
    end

    command = table.remove(BotControl.commandQueue, 1)
    BotControl.ExecuteCommandNow(command)

    if table.getn(BotControl.commandQueue) == 0 then
        commandQueueFrame:Hide()
    end
end

commandQueueFrame.elapsed = 0
commandQueueFrame:SetScript("OnUpdate", function()
    commandQueueFrame.elapsed = commandQueueFrame.elapsed + arg1

    if commandQueueFrame.elapsed < BotControl.COMMAND_INTERVAL then
        return
    end

    commandQueueFrame.elapsed = 0
    BotControl.ProcessCommandQueue()
end)

function BotControl.RunCommand(command)
    BotControl.ExecuteCommandNow(command)
end

function BotControl.QueueCommand(command)
    if not command then
        return
    end

    table.insert(BotControl.commandQueue, command)
    commandQueueFrame.elapsed = BotControl.COMMAND_INTERVAL
    commandQueueFrame:Show()
end

function BotControl.RunCommands(commands)
    local index

    if type(commands) ~= "table" then
        return
    end

    for index = 1, table.getn(commands) do
        BotControl.RunCommand(commands[index])
    end
end

function BotControl.RunCommandsQueued(commands)
    local index

    if type(commands) ~= "table" then
        return
    end

    for index = 1, table.getn(commands) do
        BotControl.QueueCommand(commands[index])
    end
end

function BotControl.SetupSlashCommands()
    SLASH_BOTCONTROL1 = "/bc"
    SlashCmdList["BOTCONTROL"] = function()
        BotControl.Toggle()
    end
end

function BotControl.HandleEvent()
    local db

    if event == "ADDON_LOADED" and arg1 == "BotControl" then
        BotControlConfig:Initialize()
        db = BotControlConfig:GetDB()
        if type(db.profiles) ~= "table" then
            db.profiles = {}
        end
        BotControl.SetupSlashCommands()
    elseif event == "PLAYER_LOGIN" then
        BotControl.InitializeFrame(BotControlFrame)
        BotControl_LayoutButtons()
        BotControl.Load()
        BotControl.RefreshProfileList()
    end
end

function BotControl.OnFrameShow()
    BotControl_LayoutButtons()
    BotControl.RefreshProfileList()

    if BotControl.currentTab == "Actions" then
        BotControl_UpdateFrameSizeForView("Actions", BotControl.currentActionsSubTab or "Config")
    else
        BotControl_UpdateFrameSizeForView("Profiles")
    end
end

function BotControl_OnLoad(frame)
    local db

    BotControlConfig:Initialize()
    db = BotControlConfig:GetDB()
    if type(db.profiles) ~= "table" then
        db.profiles = {}
    end
    BotControl.InitializeFrame(frame)
    BotControl_LayoutButtons()
    BotControl.RefreshProfileList()
    BotControl_UpdateFrameSizeForView("Profiles")
    frame:SetScript("OnShow", BotControl.OnFrameShow)
    BotControl_ShowTab("Profiles")
    eventFrame:RegisterEvent("ADDON_LOADED")
    eventFrame:RegisterEvent("PLAYER_LOGIN")
    eventFrame:SetScript("OnEvent", BotControl.HandleEvent)
end

function BotControl_SaveButton_OnClick()
    BotControl.Save()
end

function BotControl_RunNamedAction(actionName)
    BotControl.Save()

    if actionName == "FullSetup" then
        BotControl_Action_FullSetup()
    elseif actionName == "Build" then
        BotControl_Action_Build()
    elseif actionName == "Init" then
        BotControl_Action_Init()
    elseif actionName == "Summon" then
        BotControl_Action_Summon()
    elseif actionName == "InitBots" then
        BotControl_Action_InitBots()
    elseif actionName == "AttackDPS" then
        BotControl_Action_AttackDPS()
    elseif actionName == "Follow" then
        BotControl_Action_Follow()
    elseif actionName == "Passive" then
        BotControl_Action_Passive()
    elseif actionName == "Stay" then
        BotControl_Action_Stay()
    elseif actionName == "Used" then
        BotControl_Action_Used()
    else
        BotControlActions:RunAction(actionName)
    end
end
