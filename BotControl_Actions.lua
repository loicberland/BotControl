BotControlActions = {}

BotControl = BotControl or {}
BotControl.Compat = BotControl.Compat or {}
BotControl.Compat.GlobalEnv = BotControl.Compat.GlobalEnv or getfenv(0)
local GLOBAL_ENV = BotControl.Compat.GlobalEnv

BotControlActions.definitions = BotControlActions.definitions or {}

local function AddCommand(commands, command)
    if command and command ~= "" then
        table.insert(commands, command)
    end
end

local function AddWhisper(commands, target, message, delayAfter)
    local command

    if BotControl.HasValue(target) and BotControl.HasValue(message) then
        command = {
            type = "WHISPER",
            target = target,
            message = message
        }
        if type(delayAfter) == "number" and delayAfter > 0 then
            command.delayAfter = delayAfter
        end
        table.insert(commands, command)
    end
end

local function AddParty(commands, message, delayAfter)
    local command

    if BotControl.HasValue(message) then
        command = {
            type = "PARTY",
            message = message
        }
        if type(delayAfter) == "number" and delayAfter > 0 then
            command.delayAfter = delayAfter
        end
        table.insert(commands, command)
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

local function AddWhisperList(commands, names, message, delayAfter)
    local index

    for index = 1, table.getn(names) do
        AddWhisper(commands, names[index], message, delayAfter)
    end
end

local function AddWhisperByRoleAndClass(commands, slots, roleName, className, message, delayAfter)
    local index
    local slot

    if type(slots) ~= "table" then
        return
    end

    for index = 1, table.getn(slots) do
        slot = slots[index]
        if slot and slot.role == roleName and slot.class == className and BotControl.HasValue(slot.name) then
            AddWhisper(commands, slot.name, message, delayAfter)
        end
    end
end

local function AddWhisperByClass(commands, slots, className, message, delayAfter)
    local index
    local slot

    if type(slots) ~= "table" then
        return
    end

    for index = 1, table.getn(slots) do
        slot = slots[index]
        if slot and slot.class == className and BotControl.HasValue(slot.name) then
            AddWhisper(commands, slot.name, message, delayAfter)
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

    cfg.tankBuild = cfg.roleSlots.tank[1] and cfg.roleSlots.tank[1].spec or ""
    cfg.healBuild = cfg.roleSlots.heal[1] and cfg.roleSlots.heal[1].spec or ""
    cfg.dps1Build = cfg.roleSlots.dps[1] and cfg.roleSlots.dps[1].spec or ""
    cfg.dps2Build = cfg.roleSlots.dps[2] and cfg.roleSlots.dps[2].spec or ""

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

local function ReplaceNamedTokenInText(text, tokenName, replacement)
    if type(text) ~= "string" then
        return text
    end

    return string.gsub(text, "%{" .. tokenName .. "%}", replacement or "")
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

local function ExpandCommandsByNamedTokens(commands, replacements)
    local expanded = {}
    local index
    local key
    local value
    local copy
    local command

    for index = 1, table.getn(commands) do
        command = commands[index]

        if type(command) == "string" then
            copy = command
            for key, value in pairs(replacements) do
                copy = ReplaceNamedTokenInText(copy, key, value)
            end
            table.insert(expanded, copy)
        elseif type(command) == "table" then
            copy = CopyCommand(command)
            for key, value in pairs(copy) do
                if type(value) == "string" then
                    local replacementKey
                    local replacementValue

                    for replacementKey, replacementValue in pairs(replacements) do
                        value = ReplaceNamedTokenInText(value, replacementKey, replacementValue)
                    end

                    copy[key] = value
                end
            end
            table.insert(expanded, copy)
        else
            table.insert(expanded, command)
        end
    end

    return expanded
end

function BotControlActions:GetConfig()
    local cfg = BuildActionConfig()

    cfg.playerName = UnitName("player") or ""
    if UnitExists and UnitExists("target") then
        cfg.targetName = UnitName("target") or ""
    else
        cfg.targetName = ""
    end

    return cfg
end

function BotControlActions:PrepareCommands(commands)
    local cfg = self:GetConfig()
    local expanded = ExpandCommandsByRoleTokens(commands or {}, cfg)

    return ExpandCommandsByNamedTokens(expanded, {
        player = cfg.playerName,
        target = cfg.targetName
    })
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
    local whisperDelay = BotControl.REPEAT_WHISPER_INTERVAL or 0.4

    AddSlash(commands, "/run SetLootMethod('master', UnitName('player'))")
    AddParty(commands, "ll -equip,-quest,-skill,-disenchant,-use,-vendor,-trash", whisperDelay)
    AddParty(commands, "stance near", whisperDelay)
    AddParty(commands, "formation arrow", whisperDelay)
    AddParty(commands, "rti cc none", whisperDelay)
    AddParty(commands, "nc -loot", whisperDelay)
    AddParty(commands, "save mana 3", whisperDelay)
    AddParty(commands, "follow", whisperDelay)
    AddParty(commands, "pet defensive", whisperDelay)
    AddParty(commands, "co -cc", whisperDelay)
    AddParty(commands, "nc -grind", whisperDelay)
    AddWhisperByClass(commands, cfg.namedSlots, "Chasseur", "ss growl")
    
    -- AddParty(commands, "nc +passive")
    -- AddParty(commands, "co -passive")
    -- AddWhisperList(commands, cfg.roleNames.heal, "co -offdps,?")
    -- AddWhisperList(commands, cfg.roleNames.heal, "nc -offdps,?")
    -- AddWhisperList(commands, cfg.roleNames.heal, "save mana 2")
    -- AddWhisperList(commands, cfg.roleNames.heal, "co +aoe,?")
    -- AddWhisperList(commands, cfg.roleNames.heal, "nc +aoe,?")

    -- AddWhisperList(commands, cfg.roleNames.tank, "stance tank")
    -- AddWhisperList(commands, cfg.roleNames.tank, "co +mark rti,?")
    -- AddWhisperList(commands, cfg.roleNames.heal, "co -wait for attack")
    -- AddWhisperList(commands, cfg.roleNames.heal, "wait for attack time 1")
    -- AddWhisperList(commands, cfg.roleNames.dps, "co -wait for attack")
    -- AddWhisperList(commands, cfg.roleNames.dps, "wait for attack time 5")
    
    -- AddWhisperByRoleAndClass(commands, cfg.namedSlots, "tank", "Paladin", "ss divine protection")
    -- AddWhisperByClass(commands, cfg.namedSlots, "Chaman", "ss bloodlust")
    return commands
end

function BotControlActions:InitCommandsTank()
    local cfg = self:GetConfig()
    local commands = {}
    local whisperDelay = BotControl.REPEAT_WHISPER_INTERVAL or 0.4

    AddWhisperList(commands, cfg.roleNames.tank, "stance tank", whisperDelay)
    AddWhisperList(commands, cfg.roleNames.tank, "co +close,+pull,+tank assist,-ranged,-stealth,-behind", whisperDelay)
    AddWhisperList(commands, cfg.roleNames.tank, "nc +tank assist,-stealth", whisperDelay)

    AddWhisperByRoleAndClass(commands, cfg.namedSlots, "tank", "Druide", "co +tank feral")
    AddWhisperByRoleAndClass(commands, cfg.namedSlots, "tank", "Guerrier", "co +protection")
    AddWhisperByRoleAndClass(commands, cfg.namedSlots, "tank", "Paladin", "co +protection")
    AddWhisperByRoleAndClass(commands, cfg.namedSlots, "tank", "Druide", "nc +tank feral")
    AddWhisperByRoleAndClass(commands, cfg.namedSlots, "tank", "Guerrier", "nc +protection")
    AddWhisperByRoleAndClass(commands, cfg.namedSlots, "tank", "Paladin", "nc +protection")
    AddWhisperByRoleAndClass(commands, cfg.namedSlots, "tank", "Druide", "de +tank feral")
    AddWhisperByRoleAndClass(commands, cfg.namedSlots, "tank", "Guerrier", "de +protection")
    AddWhisperByRoleAndClass(commands, cfg.namedSlots, "tank", "Paladin", "de +protection")
    AddWhisperByRoleAndClass(commands, cfg.namedSlots, "tank", "Druide", "react +tank feral")
    AddWhisperByRoleAndClass(commands, cfg.namedSlots, "tank", "Guerrier", "react +protection")
    AddWhisperByRoleAndClass(commands, cfg.namedSlots, "tank", "Paladin", "react +protection")
    
    AddWhisperByRoleAndClass(commands, cfg.namedSlots, "tank", "Druide", "co -offheal")
    AddWhisperByRoleAndClass(commands, cfg.namedSlots, "tank", "Paladin", "co -offheal")
    
    AddWhisperByRoleAndClass(commands, cfg.namedSlots, "tank", "Druide", "co -cure")

    AddWhisperList(commands, cfg.roleNames.tank, "co +mark rti,?", whisperDelay)
    AddWhisperByRoleAndClass(commands, cfg.namedSlots, "tank", "Paladin", "ss divine protection", whisperDelay)
    return commands
end

function BotControlActions:InitCommandsHeal()
    local cfg = self:GetConfig()
    local commands = {}
    local whisperDelay = BotControl.REPEAT_WHISPER_INTERVAL or 0.4
    AddWhisperList(commands, cfg.roleNames.heal, "save mana 2", whisperDelay)
    AddWhisperList(commands, cfg.roleNames.heal, "co -offdps", whisperDelay)
    AddWhisperList(commands, cfg.roleNames.heal, "co +aoe", whisperDelay)
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
    AddWhisperByRoleAndClass(commands, cfg.namedSlots, "tank", "Paladin", "cast avenger's shield")

    return commands
end

function BotControlActions:AttackDPSCommands()
    local cfg = self:GetConfig()
    local commands = {}

    AddWhisperList(commands, cfg.roleNames.dps, "co -passive,?")
    AddWhisperList(commands, cfg.roleNames.dps, "nc -passive,?")   
    -- AddWhisperList(commands, cfg.roleNames.dps, "free")
    AddWhisperList(commands, cfg.roleNames.dps, "attack")
    AddWhisperList(commands, cfg.roleNames.dps, "pet defensive")
    AddWhisperList(commands, cfg.roleNames.dps, "pet attack")

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

function BotControlActions:WaitDPSCommands()
    local cfg = self:GetConfig()
    local commands = {}

    AddWhisperList(commands, cfg.roleNames.dps, "co +wait for attack")
    AddWhisperList(commands, cfg.roleNames.dps, "wait for attack time 4")

    return commands
end

function BotControlActions:WaitHEALCommands()
    local cfg = self:GetConfig()
    local commands = {}

    AddWhisperList(commands, cfg.roleNames.heal, "co +wait for attack")
    AddWhisperList(commands, cfg.roleNames.heal, "wait for attack time 1")

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

function BotControlActions:KickCommands()
    local commands = {}
    local cfg = self:GetConfig()

    AddWhisperByClass(commands, cfg.namedSlots, "Mage", "cast counterspell")

    return commands
end

function BotControlActions:RezCommands()
    local cfg = self:GetConfig()
    local commands = {}
    local index
    local name

    for index = 1, table.getn(cfg.names) do
        name = cfg.names[index]
        AddWhisper(commands, name, ".revive " .. name)
    end

    AddWhisper(commands, name, ".revive " .. cfg.playerName)

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
        GLOBAL_ENV["BotControl_Action_" .. actionKey] = function()
            if BotControlActions and BotControlActions.RunAction then
                BotControlActions:RunAction(wrappedActionKey)
            end
        end
    end
end

BotControlActions:RefreshDefinitions()
BotControlActions.CreateLegacyActionWrappers()
