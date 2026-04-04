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

local function BuildRoleSlot(name, roleName, buildName, fallbackRole)
    return {
        name = BotControl.Trim(name or ""),
        role = BotControl.NormalizeRole(roleName, fallbackRole),
        build = BotControl.Trim(buildName or "")
    }
end

local function ResolveConfigByRole(db)
    local cfg = {}
    local slots = {
        BuildRoleSlot(db.tankName, db.tankRole, db.tankBuild, "tank"),
        BuildRoleSlot(db.healName, db.healRole, db.healBuild, "heal"),
        BuildRoleSlot(db.dps1Name, db.dps1Role, db.dps1Build, "dps"),
        BuildRoleSlot(db.dps2Name, db.dps2Role, db.dps2Build, "dps"),
        BuildRoleSlot(db.dps3Name, db.dps3Role, db.dps3Build, "dps")
    }
    local dpsSlots = {}
    local index
    local slot

    for index = 1, table.getn(slots) do
        slot = slots[index]

        if slot.role == "tank" then
            if not BotControl.HasValue(cfg.tankName) then
                cfg.tankName = slot.name
                cfg.tankBuild = slot.build
            end
        elseif slot.role == "heal" then
            if not BotControl.HasValue(cfg.healName) then
                cfg.healName = slot.name
                cfg.healBuild = slot.build
            end
        elseif BotControl.HasValue(slot.name) or BotControl.HasValue(slot.build) then
            table.insert(dpsSlots, slot)
        end
    end

    cfg.dps1Name = dpsSlots[1] and dpsSlots[1].name or ""
    cfg.dps1Build = dpsSlots[1] and dpsSlots[1].build or ""
    cfg.dps2Name = dpsSlots[2] and dpsSlots[2].name or ""
    cfg.dps2Build = dpsSlots[2] and dpsSlots[2].build or ""
    cfg.dps3Name = dpsSlots[3] and dpsSlots[3].name or ""
    cfg.dps3Build = dpsSlots[3] and dpsSlots[3].build or ""

    cfg.tankName = cfg.tankName or ""
    cfg.tankBuild = cfg.tankBuild or ""
    cfg.healName = cfg.healName or ""
    cfg.healBuild = cfg.healBuild or ""

    return cfg
end

function BotControlActions:GetConfig()
    return ResolveConfigByRole(BotControlConfig:GetDB())
end

function BotControlActions:BuildCommands()
    local cfg = self:GetConfig()
    local commands = {}

    AddWhisper(commands, cfg.tankName, "talents " .. cfg.tankBuild)
    AddWhisper(commands, cfg.healName, "talents " .. cfg.healBuild)
    AddWhisper(commands, cfg.dps1Name, "talents " .. cfg.dps1Build)
    AddWhisper(commands, cfg.dps2Name, "talents " .. cfg.dps2Build)
    AddWhisper(commands, cfg.dps3Name, "talents " .. cfg.dps3Build)

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

function BotControlActions:SummonCommands()
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
        AddWhisper(commands, name, "summon")
    end

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

function BotControlActions:AttackDPSCommands()
    local cfg = self:GetConfig()
    local commands = {}
    local dpsNames = {
        cfg.dps1Name,
        cfg.dps2Name,
        cfg.dps3Name
    }
    local index
    local name

    for index = 1, table.getn(dpsNames) do
        name = dpsNames[index]
        AddWhisper(commands, name, "attack")
    end

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
            AddSlash(commands, ".bot init " .. name)
            AddSlash(commands, ".bot learn " .. name)
            AddSlash(commands, ".bot gear " .. name)
            AddSlash(commands, ".bot prepare " .. name)
        end
    end

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
        return
    end

    commands = self[definition.builder](self)
    BotControl.RunCommands(commands)
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
        BotControl.RunCommandsQueued(commands)
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
