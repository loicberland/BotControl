BotControl = {}

BotControl.FIELD_DEFINITIONS = {
    { key = "tankName", label = "Tank bot", column = "left", order = 1 },
    { key = "healName", label = "Heal bot", column = "left", order = 2 },
    { key = "dps1Name", label = "DPS 1", column = "left", order = 3 },
    { key = "dps2Name", label = "DPS 2", column = "left", order = 4 },
    { key = "dps3Name", label = "DPS 3", column = "left", order = 5 },
    { key = "tankBuild", label = "Build tank", column = "right", order = 1 },
    { key = "healBuild", label = "Build heal", column = "right", order = 2 },
    { key = "dps1Build", label = "Build DPS 1", column = "right", order = 3 },
    { key = "dps2Build", label = "Build DPS 2", column = "right", order = 4 },
    { key = "dps3Build", label = "Build DPS 3", column = "right", order = 5 }
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
        BotControlFrame:Show()
    end
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
        labelX = 296
        boxX = 296
    end

    label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", labelX, rowY)
    label:SetJustifyH("LEFT")
    label:SetText(definition.label)

    editBox = CreateFrame("EditBox", nil, parent)
    editBox:SetWidth(228)
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

function BotControl.InitializeFrame(frame)
    if frame.isInitialized then
        return
    end

    BotControl.BuildFields(frame)
    frame.isInitialized = true
end

function BotControl.Save()
    BotControlConfig:SaveFromUI(BotControlFrame)
    BotControl.Print("Configuration saved.")
end

function BotControl.Load()
    BotControlConfig:LoadToUI(BotControlFrame)
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

    -- WoW 2.4.3 does not provide a single modern helper that safely covers all slash commands.
    -- We therefore inject the text into the chat edit box and send it as if the player typed it.
    -- This is more compatible for commands such as /invite and raw dot commands like ".bot add".
    -- SendChatMessage cannot execute slash commands, and helpers like RunMacroText / custom
    -- slash dispatchers are not a reliable replacement for every server/private-server command.
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
        BotControl.SetupSlashCommands()
    elseif event == "PLAYER_LOGIN" then
        BotControl.InitializeFrame(BotControlFrame)
        BotControl.Load()
    end
end

function BotControl_OnLoad(frame)
    BotControl.InitializeFrame(frame)
    eventFrame:RegisterEvent("ADDON_LOADED")
    eventFrame:RegisterEvent("PLAYER_LOGIN")
    eventFrame:SetScript("OnEvent", BotControl.HandleEvent)
end

function BotControl_SaveButton_OnClick()
    BotControl.Save()
end

function BotControl_RunNamedAction(actionName)
    BotControl.Save()
    BotControlActions:RunAction(actionName)
end
