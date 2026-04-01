BotControl = {}
BotControl_ProfileElements = {}
BotControl_ActionElements = {}

BotControl.FIELD_DEFINITIONS = {
    { key = "tankName", label = "Tank bot", column = "left", order = 1 },
    { key = "healName", label = "Heal bot", column = "left", order = 2 },
    { key = "dps1Name", label = "DPS 1", column = "left", order = 3 },
    { key = "dps2Name", label = "DPS 2", column = "left", order = 4 },
    { key = "dps3Name", label = "DPS 3", column = "left", order = 5 },
    { key = "tankBuild", label = "Tank spec", column = "right", order = 1 },
    { key = "healBuild", label = "Heal spec", column = "right", order = 2 },
    { key = "dps1Build", label = "DPS 1 spec", column = "right", order = 3 },
    { key = "dps2Build", label = "DPS 2 spec", column = "right", order = 4 },
    { key = "dps3Build", label = "DPS 3 spec", column = "right", order = 5 }
}

local eventFrame = CreateFrame("Frame", "BotControlEventFrame")

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

function BotControl.Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[BotControl]|r " .. message)
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

function BotControl.CreateField(parent, definition)
    local rowY = -64 - ((definition.order - 1) * 56)
    local labelX
    local boxX
    local label
    local editBox

    if definition.column == "left" then
        labelX = 26
        boxX = 26
    else
        labelX = 276
        boxX = 276
    end

    label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", labelX, rowY)
    label:SetJustifyH("LEFT")
    label:SetText(definition.label)

    editBox = CreateFrame("EditBox", nil, parent)
    editBox:SetWidth(190)
    editBox:SetHeight(20)
    editBox:SetPoint("TOPLEFT", parent, "TOPLEFT", boxX, rowY - 16)
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
        editBox = editBox
    }
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

function BotControl.RegisterTabElements(frame)
    local index
    local field

    BotControl_ProfileElements = {}
    BotControl_ActionElements = {}

    BotControl.AddElement(BotControl_ProfileElements, BotControlFrameNamesHeader)
    BotControl.AddElement(BotControl_ProfileElements, BotControlFrameBuildsHeader)
    BotControl.AddElement(BotControl_ProfileElements, BotControlFrameProfileNameLabel)
    BotControl.AddElement(BotControl_ProfileElements, BotControlProfileNameEditBox)
    BotControl.AddElement(BotControl_ProfileElements, BotControlSaveProfileButton)
    BotControl.AddElement(BotControl_ProfileElements, BotControlLoadProfileButton)
    BotControl.AddElement(BotControl_ProfileElements, BotControlDeleteProfileButton)
    BotControl.AddElement(BotControl_ProfileElements, BotControlFrameSaveButton)

    if frame and frame.fields then
        for index = 1, table.getn(frame.fields) do
            field = frame.fields[index]
            if field then
                BotControl.AddElement(BotControl_ProfileElements, field.label)
                BotControl.AddElement(BotControl_ProfileElements, field.editBox)
            end
        end
    end

    BotControl.AddElement(BotControl_ActionElements, BotControlFrameComposeGroupButton)
    BotControl.AddElement(BotControl_ActionElements, BotControlFrameBuildButton)
    BotControl.AddElement(BotControl_ActionElements, BotControlFrameInitButton)
    BotControl.AddElement(BotControl_ActionElements, BotControlFullSetupButton)
    BotControl.AddElement(BotControl_ActionElements, BotControlFrameSummonButton)
    BotControl.AddElement(BotControl_ActionElements, BotControlFrameTankAttackButton)
end

function BotControl_ShowTab(tabName)
    local index
    local element

    if tabName == "Actions" then
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
    else
        tabName = "Profiles"

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
    end

    print("BotControl: switched to " .. tabName)
end

function BotControl.InitializeFrame(frame)
    if frame.isInitialized then
        return
    end

    BotControl.BuildFields(frame)
    BotControl.CreateButtons(frame)
    BotControl.RegisterTabElements(frame)
    BotControl.RegisterSpecialFrame("BotControlFrame")
    frame.isInitialized = true
end

function BotControl.CreateButtons(frame)
    local fullSetupButton
    local saveProfileButton
    local loadProfileButton
    local deleteProfileButton
    local profilesTabButton
    local actionsTabButton

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

    if not BotControlFullSetupButton then
        fullSetupButton = CreateFrame("Button", "BotControlFullSetupButton", frame, "UIPanelButtonTemplate")
        fullSetupButton:SetText("Full setup")
        fullSetupButton:SetWidth(140)
        fullSetupButton:SetHeight(24)
        fullSetupButton:SetScript("OnClick", function()
            BotControl_RunNamedAction("FullSetup")
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
            BotControl_LoadProfile(BotControl.GetProfileName())
        end)
    end

    if not BotControlDeleteProfileButton then
        deleteProfileButton = CreateFrame("Button", "BotControlDeleteProfileButton", frame, "UIPanelButtonTemplate")
        deleteProfileButton:SetText("Delete profile")
        deleteProfileButton:SetWidth(110)
        deleteProfileButton:SetHeight(24)
        deleteProfileButton:SetScript("OnClick", function()
            BotControl_DeleteProfile(BotControl.GetProfileName())
        end)
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
        values[field.key] = BotControl.Trim(field.editBox:GetText() or "")
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
        text = values[field.key] or ""
        field.editBox:SetText(text)
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
            tank = values.tankBuild or "",
            heal = values.healBuild or "",
            dps1 = values.dps1Build or "",
            dps2 = values.dps2Build or "",
            dps3 = values.dps3Build or ""
        }
    }
end

function BotControl.BuildValuesFromProfile(profile)
    local values = {}

    if type(profile) ~= "table" then
        return values
    end

    if type(profile.bots) ~= "table" then
        profile.bots = {}
    end
    if type(profile.builds) ~= "table" then
        profile.builds = {}
    end

    values.tankName = profile.bots.tank or ""
    values.healName = profile.bots.heal or ""
    values.dps1Name = profile.bots.dps1 or ""
    values.dps2Name = profile.bots.dps2 or ""
    values.dps3Name = profile.bots.dps3 or ""
    values.tankBuild = profile.builds.tank or ""
    values.healBuild = profile.builds.heal or ""
    values.dps1Build = profile.builds.dps1 or ""
    values.dps2Build = profile.builds.dps2 or ""
    values.dps3Build = profile.builds.dps3 or ""

    return values
end

function BotControl_SaveProfile(profileName)
    local frame = BotControlFrame
    local db
    local values

    profileName = BotControl.Trim(profileName or "")
    if not BotControl.HasValue(profileName) then
        print("BotControl: profile name is empty")
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
    print("BotControl: profile saved -> " .. profileName)
end

function BotControl_LoadProfile(profileName)
    local frame = BotControlFrame
    local db = BotControlConfig:GetDB()
    local profile
    local values
    local key

    profileName = BotControl.Trim(profileName or "")
    if not BotControl.HasValue(profileName) then
        print("BotControl: profile name is empty")
        return
    end

    if type(db.profiles) ~= "table" then
        db.profiles = {}
    end

    profile = db.profiles[profileName]
    if type(profile) ~= "table" then
        print("BotControl: profile not found -> " .. profileName)
        return
    end

    values = BotControl.BuildValuesFromProfile(profile)

    for key, value in pairs(values) do
        BotControlConfig:SetValue(key, value)
    end

    BotControl.SyncGroupsToDB(values)
    BotControl.ApplyValuesToUI(frame, values)
    print("BotControl: profile loaded -> " .. profileName)
end

function BotControl_DeleteProfile(profileName)
    local db = BotControlConfig:GetDB()

    profileName = BotControl.Trim(profileName or "")
    if not BotControl.HasValue(profileName) then
        print("BotControl: profile name is empty")
        return
    end

    if type(db.profiles) ~= "table" then
        db.profiles = {}
    end

    if not db.profiles[profileName] then
        print("BotControl: profile not found -> " .. profileName)
        return
    end

    db.profiles[profileName] = nil
    print("BotControl: profile deleted -> " .. profileName)
end

function BotControl_LayoutButtons()
    local frame = BotControlFrame
    local profilesTabButton = BotControlTabProfiles
    local actionsTabButton = BotControlTabActions
    local profileNameLabel = BotControlFrameProfileNameLabel
    local profileNameEditBox = BotControlProfileNameEditBox
    local saveProfileButton = BotControlSaveProfileButton
    local loadProfileButton = BotControlLoadProfileButton
    local deleteProfileButton = BotControlDeleteProfileButton
    local composeGroupButton = BotControlFrameComposeGroupButton
    local buildButton = BotControlFrameBuildButton
    local initButton = BotControlFrameInitButton
    local fullSetupButton = BotControlFullSetupButton
    local summonButton = BotControlFrameSummonButton
    local tankAttackButton = BotControlFrameTankAttackButton
    local saveButton = BotControlFrameSaveButton

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

    if profileNameLabel then
        profileNameLabel:ClearAllPoints()
        profileNameLabel:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 126)
    end

    if profileNameEditBox then
        profileNameEditBox:ClearAllPoints()
        profileNameEditBox:SetWidth(190)
        profileNameEditBox:SetHeight(20)
        profileNameEditBox:SetPoint("LEFT", profileNameLabel, "RIGHT", 12, 0)
    end

    if saveProfileButton then
        saveProfileButton:ClearAllPoints()
        saveProfileButton:SetWidth(110)
        saveProfileButton:SetHeight(24)
        saveProfileButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 88)
    end

    if loadProfileButton then
        loadProfileButton:ClearAllPoints()
        loadProfileButton:SetWidth(110)
        loadProfileButton:SetHeight(24)
        if saveProfileButton then
            loadProfileButton:SetPoint("LEFT", saveProfileButton, "RIGHT", 10, 0)
        else
            loadProfileButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 140, 88)
        end
    end

    if deleteProfileButton then
        deleteProfileButton:ClearAllPoints()
        deleteProfileButton:SetWidth(110)
        deleteProfileButton:SetHeight(24)
        if loadProfileButton then
            deleteProfileButton:SetPoint("LEFT", loadProfileButton, "RIGHT", 10, 0)
        else
            deleteProfileButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 260, 88)
        end
    end

    if composeGroupButton then
        composeGroupButton:ClearAllPoints()
        composeGroupButton:SetWidth(140)
        composeGroupButton:SetHeight(24)
        composeGroupButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 54)
    end

    if buildButton then
        buildButton:ClearAllPoints()
        buildButton:SetWidth(100)
        buildButton:SetHeight(24)
        buildButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 170, 54)
    end

    if initButton then
        initButton:ClearAllPoints()
        initButton:SetWidth(100)
        initButton:SetHeight(24)
        initButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 280, 54)
    end

    if fullSetupButton then
        fullSetupButton:ClearAllPoints()
        fullSetupButton:SetWidth(140)
        fullSetupButton:SetHeight(24)
        if initButton then
            fullSetupButton:SetPoint("LEFT", initButton, "RIGHT", 10, 0)
        else
            fullSetupButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 390, 54)
        end
    end

    if summonButton then
        summonButton:ClearAllPoints()
        summonButton:SetWidth(120)
        summonButton:SetHeight(24)
        summonButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 20)
    end

    if tankAttackButton then
        tankAttackButton:ClearAllPoints()
        tankAttackButton:SetWidth(120)
        tankAttackButton:SetHeight(24)
        tankAttackButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 150, 20)
    end

    if saveButton then
        saveButton:ClearAllPoints()
        saveButton:SetWidth(100)
        saveButton:SetHeight(24)
        saveButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 20)
    end

    print("BotControl: layout applied")
end

function BotControl.Save()
    BotControlConfig:SaveFromUI(BotControlFrame)
    BotControl.SyncGroupsToDB(BotControl.GetFieldValuesFromUI(BotControlFrame))
    BotControl.Print("Configuration saved.")
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

    if not BotControl.HasValue(command) then
        return
    end

    editBox = ChatFrameEditBox or DEFAULT_CHAT_FRAME.editBox
    if not editBox then
        BotControl.Print("Unable to access chat edit box for command: " .. command)
        return
    end

    ChatFrame_OpenChat(command, DEFAULT_CHAT_FRAME)
    if ChatFrameEditBox and ChatFrameEditBox:GetText() == command then
        ChatEdit_SendText(ChatFrameEditBox, 0)
    elseif DEFAULT_CHAT_FRAME.editBox and DEFAULT_CHAT_FRAME.editBox:GetText() == command then
        ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
    else
        editBox:SetText(command)
        ChatEdit_SendText(editBox, 0)
    end
end

function BotControl.RunCommand(command)
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

function BotControl.RunCommands(commands)
    local index

    if type(commands) ~= "table" then
        return
    end

    for index = 1, table.getn(commands) do
        BotControl.RunCommand(commands[index])
    end
end

function BotControl.SetupSlashCommands()
    SLASH_BOTCONTROL1 = "/bc"
    SlashCmdList["BOTCONTROL"] = function()
        BotControl.Toggle()
    end
end

function BotControl.HandleEvent()
    if event == "ADDON_LOADED" and arg1 == "BotControl" then
        BotControlConfig:Initialize()
        if type(BotControlDB.profiles) ~= "table" then
            BotControlDB.profiles = {}
        end
        BotControl.SetupSlashCommands()
    elseif event == "PLAYER_LOGIN" then
        BotControl.InitializeFrame(BotControlFrame)
        BotControl_LayoutButtons()
        BotControl.Load()
    end
end

function BotControl_OnLoad(frame)
    BotControlConfig:Initialize()
    if type(BotControlDB.profiles) ~= "table" then
        BotControlDB.profiles = {}
    end
    BotControl.InitializeFrame(frame)
    BotControl_LayoutButtons()
    frame:SetScript("OnShow", BotControl_LayoutButtons)
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
    else
        BotControlActions:RunAction(actionName)
    end
end
