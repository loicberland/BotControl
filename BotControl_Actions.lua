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
    SummonDistance = {
        label = "Summon distance",
        builder = "SummonDistanceCommands"
    },
    SummonTank = {
        label = "Summon tank",
        builder = "SummonTankCommands"
    },
    TankAttack = {
        label = "Tank attack",
        builder = "TankAttackCommands"
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

function BotControlActions:GetConfig()
    return BotControlConfig:GetDB()
end

function BotControlActions:BuildCommands()
    local cfg = self:GetConfig()
    local commands = {}

    AddWhisper(commands, cfg.tankName, cfg.tankBuild)
    AddWhisper(commands, cfg.healName, cfg.healBuild)
    AddWhisper(commands, cfg.dps1Name, cfg.dps1Build)
    AddWhisper(commands, cfg.dps2Name, cfg.dps2Build)
    AddWhisper(commands, cfg.dps3Name, cfg.dps3Build)

    return commands
end

function BotControlActions:InitCommands()
    local cfg = self:GetConfig()
    local commands = {}

    AddParty(commands, "ll -equip,-quest,-skill,-disenchant,-use,-vendor,-trash")
    AddParty(commands, "stance near")
    AddParty(commands, "rti cc none")
    AddParty(commands, "nc -loot")
    AddParty(commands, "nc +passive")

    AddWhisper(commands, cfg.tankName, "stance tank")
    AddWhisper(commands, cfg.healName, "co +wait for attack")
    AddWhisper(commands, cfg.dps1Name, "co +wait for attack")
    AddWhisper(commands, cfg.dps2Name, "co +wait for attack")
    AddWhisper(commands, cfg.dps3Name, "co +wait for attack")

    return commands
end

function BotControlActions:SummonDistanceCommands()
    local cfg = self:GetConfig()
    local commands = {}
    local names = {
        cfg.healName,
        cfg.dps1Name,
        cfg.dps2Name,
        cfg.dps3Name
    }
    local index
    local name

    for index = 1, table.getn(names) do
        name = names[index]
        AddWhisper(commands, name, "summon")
        AddWhisper(commands, name, "stay")
    end

    return commands
end

function BotControlActions:SummonTankCommands()
    local cfg = self:GetConfig()
    local commands = {}

    AddWhisper(commands, cfg.tankName, "summon")

    return commands
end

function BotControlActions:TankAttackCommands()
    local cfg = self:GetConfig()
    local commands = {}

    AddWhisper(commands, cfg.tankName, "attack")
    AddWhisper(commands, cfg.healName, "wait for attack time 1")
    AddWhisper(commands, cfg.dps1Name, "wait for attack time 10")
    AddWhisper(commands, cfg.dps2Name, "wait for attack time 10")
    AddWhisper(commands, cfg.dps3Name, "wait for attack time 10")

    return commands
end

function BotControlActions:ComposeGroupCommands()
    local cfg = self:GetConfig()
    local commands = {}
    local names = {
        cfg.tankName,
        cfg.healName,
        cfg.dps1Name,
        cfg.dps2Name,
        cfg.dps3Name
    }
    local index
    local name

    for index = 1, table.getn(names) do
        name = names[index]
        if BotControl.HasValue(name) then
            AddSlash(commands, ".bot add " .. name)
        end
    end

    for index = 1, table.getn(names) do
        name = names[index]
        AddWhisper(commands, name, "leave group")
    end

    for index = 1, table.getn(names) do
        name = names[index]
        if BotControl.HasValue(name) then
            AddSlash(commands, "/invite " .. name)
        end
    end

    return commands
end

function BotControlActions:RunAction(actionKey)
    local definition
    local commands

    definition = self.definitions[actionKey]
    if not definition or not self[definition.builder] then
        BotControl.Print("Unknown action: " .. tostring(actionKey))
        return
    end

    BotControl.Print("Running action: " .. definition.label)
    commands = self[definition.builder](self)
    BotControl.RunCommands(commands)
end
