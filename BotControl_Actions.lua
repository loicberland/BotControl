BotControlActions = {}

BotControlActions.definitions = {
    ComposeGroup = {
        label = "Compose group",
        builder = "ComposeGroupCommands"
    },
    Build = {
        label = "Build",
        builder = "BuildCommands"
    },
    Init = {
        label = "Init",
        builder = "InitCommands"
    },
    Summon = {
        label = "Summon",
        builder = "SummonCommands"
    },
    InitBots = {
        label = "Init bots",
        builder = "InitBotsCommands"
    },
    TankAttack = {
        label = "Tank attack",
        builder = "TankAttackCommands"
    },
    AttackDPS = {
        label = "Attack DPS",
        builder = "AttackDPSCommands"
    },
    Follow = {
        label = "Follow",
        builder = "FollowCommands"
    },
    Passive = {
        label = "Passive",
        builder = "PassiveCommands"
    },
    Stay = {
        label = "Stay",
        builder = "StayCommands"
    },
    Used = {
        label = "Used",
        builder = "UsedCommands"
    }
}

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

    AddParty(commands, "ll -equip,-quest,-skill,-disenchant,-use,-vendor,-trash")
    AddParty(commands, "stance near")
    AddParty(commands, "rti cc none")
    AddParty(commands, "nc -loot")
    -- AddParty(commands, "nc +passive")
    -- AddParty(commands, "co -passive")
    AddParty(commands, "save mana 2")
    AddParty(commands, "follow")
    AddParty(commands, "co -cc")

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
    AddWhisperList(commands, cfg.roleNames.heal, "wait for attack time 1")
    AddWhisperList(commands, cfg.roleNames.dps, "wait for attack time 10")

    return commands
end

function BotControlActions:AttackDPSCommands()
    local cfg = self:GetConfig()
    local commands = {}

    AddWhisperList(commands, cfg.roleNames.dps, "attack")

    return commands
end

function BotControlActions:FollowCommands()
    local commands = {}

    AddParty(commands, "follow")
    AddParty(commands, "co -passive")

    return commands
end

function BotControlActions:PassiveCommands()
    local commands = {}

    AddParty(commands, "flee")

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

function BotControlActions:RunAction(actionKey)
    local definition
    local commands

    definition = self.definitions[actionKey]
    if not definition or not self[definition.builder] then
        return
    end

    commands = self[definition.builder](self)
    BotControl.RunCommands(self:PrepareCommands(commands))
end

function BotControl_Action_Build()
    if BotControlActions and BotControlActions.RunAction then
        BotControlActions:RunAction("Build")
    end
end

function BotControl_Action_Init()
    if BotControlActions and BotControlActions.RunAction then
        BotControlActions:RunAction("Init")
    end
end

function BotControl_Action_Summon()
    if BotControlActions and BotControlActions.RunAction then
        BotControlActions:RunAction("Summon")
    end
end

function BotControl_Action_InitBots()
    local commands

    if BotControlActions and BotControlActions.InitBotsCommands and BotControl.RunCommandsQueued then
        commands = BotControlActions:InitBotsCommands()
        BotControl.RunCommandsQueued(BotControlActions:PrepareCommands(commands))
    end
end

function BotControl_Action_AttackDPS()
    if BotControlActions and BotControlActions.RunAction then
        BotControlActions:RunAction("AttackDPS")
    end
end

function BotControl_Action_Follow()
    if BotControlActions and BotControlActions.RunAction then
        BotControlActions:RunAction("Follow")
    end
end

function BotControl_Action_Passive()
    if BotControlActions and BotControlActions.RunAction then
        BotControlActions:RunAction("Passive")
    end
end

function BotControl_Action_Stay()
    if BotControlActions and BotControlActions.RunAction then
        BotControlActions:RunAction("Stay")
    end
end

function BotControl_Action_Used()
    if BotControlActions and BotControlActions.RunAction then
        BotControlActions:RunAction("Used")
    end
end

function BotControl_Action_FullSetup()
    if BotControl_Action_Build then
        BotControl_Action_Build()
    end

    if BotControl_Action_Init then
        BotControl_Action_Init()
    end
end
