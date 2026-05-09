BotControlActions = {}

BotControlActions.definitions = BotControlActions.definitions or {}

local function AddCommand(commands, command)
    if command and command ~= "" then
        table.insert(commands, command)
    end
end

local function AddWhisper(commands, target, message)
    if BotControl.HasValue(target) and BotControl.HasValue(message) then
        table.insert(commands, {
            type = "WHISPER",
            target = target,
            message = message
        })
    end
end

local function AddParty(commands, message)
    if BotControl.HasValue(message) then
        table.insert(commands, {
            type = "PARTY",
            message = message
        })
    end
end

local function AddSlash(commands, command)
    if BotControl.HasValue(command) then
        table.insert(commands, {
            type = "SLASH",
            command = command
        })
    end
end

local function AddUniqueName(target, name)
    local index

    if not BotControl.HasValue(name) then
        return
    end

    for index = 1, table.getn(target) do
        if target[index] == name then
            return
        end
    end

    table.insert(target, name)
end

local function AddWhisperList(commands, names, message)
    local index

    for index = 1, table.getn(names) do
        AddWhisper(commands, names[index], message)
    end
end

local function AddWhisperByRoleAndClass(commands, slots, roleName, className, message)
    local index
    local slot

    if type(slots) ~= "table" then
        return
    end

    for index = 1, table.getn(slots) do
        slot = slots[index]
        if slot and slot.role == roleName and slot.class == className and BotControl.HasValue(slot.name) then
            AddWhisper(commands, slot.name, message)
        end
    end
end

local function BuildActionConfig()
    local cfg = {
        slots = BotControl.GetActiveProfileSlots(),
        namedSlots = {},
        names = {},
        roleSlots = {
            tank = {},
            heal = {},
            dps = {}
        },
        roleNames = {
            tank = {},
            heal = {},
            dps = {}
        }
    }
    local normalizedSlots = BotControl.NormalizeSlotsList(cfg.slots, table.getn(cfg.slots or {}))
    local index
    local slot

    for index = 1, table.getn(normalizedSlots) do
        slot = normalizedSlots[index]
        if BotControl.HasValue(slot.name) then
            table.insert(cfg.namedSlots, slot)
            table.insert(cfg.roleSlots[slot.role], slot)
            AddUniqueName(cfg.names, slot.name)
            AddUniqueName(cfg.roleNames[slot.role], slot.name)
        end
    end

    cfg.tankName = cfg.roleNames.tank[1] or ""
    cfg.healName = cfg.roleNames.heal[1] or ""
    cfg.dps1Name = cfg.roleNames.dps[1] or ""
    cfg.dps2Name = cfg.roleNames.dps[2] or ""
    cfg.dps3Name = cfg.roleNames.dps[3] or ""

    cfg.tankBuild = cfg.roleSlots.tank[1] and cfg.roleSlots.tank[1].spec or ""
    cfg.healBuild = cfg.roleSlots.heal[1] and cfg.roleSlots.heal[1].spec or ""
    cfg.dps1Build = cfg.roleSlots.dps[1] and cfg.roleSlots.dps[1].spec or ""
    cfg.dps2Build = cfg.roleSlots.dps[2] and cfg.roleSlots.dps[2].spec or ""
    cfg.dps3Build = cfg.roleSlots.dps[3] and cfg.roleSlots.dps[3].spec or ""

    return cfg
end

local function CopyCommand(command)
    local copy = {}
    local key
    local value

    if type(command) ~= "table" then
        return command
    end

    for key, value in pairs(command) do
        copy[key] = value
    end

    return copy
end

local function ReplaceRoleTokenInText(text, roleName, replacement)
    if type(text) ~= "string" then
        return text
    end

    return string.gsub(text, "%{" .. roleName .. "%}", replacement)
end

local function CommandContainsRoleToken(command, roleName)
    local token = "{" .. roleName .. "}"
    local key
    local value

    if type(command) == "string" then
        return string.find(command, token, 1, true) ~= nil
    end

    if type(command) ~= "table" then
        return false
    end

    for key, value in pairs(command) do
        if type(value) == "string" and string.find(value, token, 1, true) then
            return true
        end
    end

    return false
end

local function ReplaceRoleTokenInCommand(command, roleName, replacement)
    local key
    local value
    local copy

    if type(command) == "string" then
        return ReplaceRoleTokenInText(command, roleName, replacement)
    end

    if type(command) ~= "table" then
        return command
    end

    copy = CopyCommand(command)
    for key, value in pairs(copy) do
        if type(value) == "string" then
            copy[key] = ReplaceRoleTokenInText(value, roleName, replacement)
        end
    end

    return copy
end

local function ExpandCommandsForRole(commands, cfg, roleName)
    local expanded = {}
    local names = cfg.roleNames[roleName] or {}
    local index
    local nameIndex
    local command

    for index = 1, table.getn(commands) do
        command = commands[index]
        if CommandContainsRoleToken(command, roleName) then
            for nameIndex = 1, table.getn(names) do
                table.insert(expanded, ReplaceRoleTokenInCommand(command, roleName, names[nameIndex]))
            end
        else
            table.insert(expanded, command)
        end
    end

    return expanded
end

local function ExpandCommandsByRoleTokens(commands, cfg)
    local expanded = commands
    local index
    local roleName

    for index = 1, table.getn(BotControl.Roles) do
        roleName = BotControl.Roles[index]
        expanded = ExpandCommandsForRole(expanded, cfg, roleName)
    end

    return expanded
end

function BotControlActions:GetConfig()
    return BuildActionConfig()
end

function BotControlActions:PrepareCommands(commands)
    return ExpandCommandsByRoleTokens(commands or {}, self:GetConfig())
end

function BotControlActions:BuildCommands()
    local cfg = self:GetConfig()
    local commands = {}
    local index
    local slot

    for index = 1, table.getn(cfg.namedSlots) do
        slot = cfg.namedSlots[index]
        if BotControl.HasValue(slot.spec) then
            AddWhisper(commands, slot.name, "talents " .. slot.spec)
        end
    end

    return commands
end

function BotControlActions:InitCommands()
    local cfg = self:GetConfig()
    local commands = {}

    AddSlash(commands, "/run SetLootMethod('master', UnitName('player'))")
    AddParty(commands, "ll -equip,-quest,-skill,-disenchant,-use,-vendor,-trash")
    AddParty(commands, "stance near")
    AddParty(commands, "rti cc none")
    AddParty(commands, "nc -loot")
    -- AddParty(commands, "nc +passive")
    -- AddParty(commands, "co -passive")
    AddParty(commands, "save mana 3")
    AddParty(commands, "follow")
    AddParty(commands, "pet defensive")
    AddParty(commands, "co -cc")
    AddWhisperList(commands, cfg.roleNames.heal, "co -offdps")
    -- AddWhisperByRoleAndClass(commands, cfg.namedSlots, "dps", "Mage", "co +cc,?")
    AddWhisperList(commands, cfg.roleNames.heal, "nc -offdps")
    AddWhisperList(commands, cfg.roleNames.heal, "save mana 2")

    AddWhisperList(commands, cfg.roleNames.tank, "stance tank")
    AddWhisperList(commands, cfg.roleNames.tank, "co +mark rti")
    -- AddWhisperList(commands, cfg.roleNames.heal, "co +wait for attack")
    -- AddWhisperList(commands, cfg.roleNames.heal, "wait for attack time 1")
    -- AddWhisperList(commands, cfg.roleNames.dps, "co +wait for attack")
    -- AddWhisperList(commands, cfg.roleNames.dps, "wait for attack time 5")

    return commands
end

function BotControlActions:SummonCommands()
    local cfg = self:GetConfig()
    local commands = {}
    local index

    AddParty(commands, "summon")
    -- for index = 1, table.getn(cfg.names) do
    --     AddWhisper(commands, cfg.names[index], "summon")
    -- end

    return commands
end

function BotControlActions:TankAttackCommands()
    local cfg = self:GetConfig()
    local commands = {}

    AddWhisperList(commands, cfg.roleNames.tank, "attack")
    -- AddWhisperList(commands, cfg.roleNames.heal, "wait for attack time 1")
    -- AddWhisperList(commands, cfg.roleNames.dps, "wait for attack time 10")

    return commands
end

function BotControlActions:AttackDPSCommands()
    local cfg = self:GetConfig()
    local commands = {}

    AddWhisperList(commands, cfg.roleNames.dps, "co -passive,?")
    AddWhisperList(commands, cfg.roleNames.dps, "nc -passive,?")    
    AddParty(commands, "pet defensive")
    AddParty(commands, "free")
    AddWhisperList(commands, cfg.roleNames.dps, "attack")
    AddParty(commands, "pet attack")

    return commands
end

function BotControlActions:FollowCommands()
    local commands = {}

    AddParty(commands, "follow")

    return commands
end

function BotControlActions:PassiveCommands()
    local commands = {}

    AddParty(commands, "pet passive")
    AddParty(commands, "nc +passive,?")
    AddParty(commands, "co +passive,?")

    return commands
end

function BotControlActions:PassiveDPSCommands()
    local cfg = self:GetConfig()
    local commands = {}

    AddWhisperList(commands, cfg.roleNames.dps, "pet passive")
    AddWhisperList(commands, cfg.roleNames.dps, "nc +passive,?")
    AddWhisperList(commands, cfg.roleNames.dps, "co +passive,?")

    return commands
end

function BotControlActions:StayCommands()
    local commands = {}

    AddParty(commands, "stay")

    return commands
end

function BotControlActions:UsedCommands()
    local commands = {}

    AddParty(commands, "u go")

    return commands
end

function BotControlActions:InitBotsCommands()
    local cfg = self:GetConfig()
    local commands = {}
    local index
    local name

    for index = 1, table.getn(cfg.names) do
        name = cfg.names[index]
        AddWhisper(commands, cfg.names[index], "reset ai")
        AddSlash(commands, ".bot init " .. name)
        AddSlash(commands, ".bot learn " .. name)
        AddSlash(commands, ".bot gear " .. name)
        AddSlash(commands, ".bot prepare " .. name)
        AddSlash(commands, ".bot reagents " .. name)
        AddSlash(commands, ".bot consumables " .. name)
        AddSlash(commands, ".bot enchants " .. name)
        AddSlash(commands, ".bot food " .. name)
        AddSlash(commands, ".bot potions " .. name)
    end

    return commands
end

function BotControlActions:ComposeGroupCommands()
    local cfg = self:GetConfig()
    local commands = {}
    local index
    local name

    for index = 1, table.getn(cfg.names) do
        name = cfg.names[index]
        AddSlash(commands, ".bot add " .. name)
    end

    for index = 1, table.getn(cfg.names) do
        AddWhisper(commands, cfg.names[index], "leave group")
    end

    for index = 1, table.getn(cfg.names) do
        name = cfg.names[index]
        AddSlash(commands, "/invite " .. name)
    end

    return commands
end

function BotControlActions:GetActionDefinition(actionKey)
    if BotControl and BotControl.GetActionByKey then
        return BotControl.GetActionByKey(actionKey)
    end

    return self.definitions and self.definitions[actionKey]
end

function BotControlActions:RunAction(actionKey)
    local action
    local commands
    local builder
    local sequence
    local index

    action = self:GetActionDefinition(actionKey)
    if not action then
        return
    end

    sequence = action.sequence
    if type(sequence) == "table" and table.getn(sequence) > 0 then
        for index = 1, table.getn(sequence) do
            self:RunAction(sequence[index])
        end
        return
    end

    builder = action.builder
    if not builder or not self[builder] then
        return
    end

    commands = self[builder](self)
    commands = self:PrepareCommands(commands)

    if action.queued and BotControl.RunCommandsQueued then
        BotControl.RunCommandsQueued(commands)
    else
        BotControl.RunCommands(commands)
    end
end

function BotControlActions:RefreshDefinitions()
    local orderedActions
    local index
    local action

    self.definitions = {}

    if BotControl and BotControl.GetOrderedRegistryActions then
        orderedActions = BotControl.GetOrderedRegistryActions()
        for index = 1, table.getn(orderedActions) do
            action = orderedActions[index]
            self.definitions[action.key] = action
        end
    end
end

function BotControlActions.CreateLegacyActionWrappers()
    local orderedActions
    local index
    local actionKey

    if not BotControl or not BotControl.GetOrderedRegistryActions then
        return
    end

    orderedActions = BotControl.GetOrderedRegistryActions()
    for index = 1, table.getn(orderedActions) do
        actionKey = orderedActions[index].key
        local wrappedActionKey = actionKey
        _G["BotControl_Action_" .. actionKey] = function()
            if BotControlActions and BotControlActions.RunAction then
                BotControlActions:RunAction(wrappedActionKey)
            end
        end
    end
end

BotControlActions:RefreshDefinitions()
BotControlActions.CreateLegacyActionWrappers()
