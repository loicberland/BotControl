BotControl = BotControl or {}

BotControl.ActionRegistry = {
    {
        key = "ComposeGroup",
        label = "Composer le groupe",
        tooltipTitle = "Composer le groupe",
        tooltipDescription = "Cree le groupe avec les bots configures",
        texture = "Interface\\Icons\\Spell_Nature_MassTeleport",
        tab = "Config",
        group = "Config",
        order = 10,
        aliases = { "compose", "composegroup" },
        builder = "ComposeGroupCommands",
        queued = false
    },
    {
        key = "Build",
        label = "Appliquer les spes",
        tooltipTitle = "Appliquer les spes",
        tooltipDescription = "Applique les talents aux bots configures",
        texture = "Interface\\Icons\\Ability_Marksmanship",
        tab = "Config",
        group = "Config",
        order = 20,
        aliases = { "build" },
        builder = "BuildCommands",
        queued = false
    },
    {
        key = "InitBots",
        label = "Initialisation bots",
        tooltipTitle = "Initialisation bots",
        tooltipDescription = "Lance .bot init, .bot learn, .bot gear et .bot prepare",
        texture = "Interface\\Icons\\INV_Misc_Gear_01",
        tab = "Config",
        group = "Config",
        order = 30,
        aliases = { "initbots", "init bots" },
        builder = "InitBotsCommands",
        queued = true
    },
    {
        key = "Init",
        label = "Initialiser",
        tooltipTitle = "Initialiser",
        tooltipDescription = "Applique la configuration de base des bots",
        texture = "Interface\\Icons\\INV_Misc_Book_09",
        tab = "Config",
        group = "Config",
        order = 40,
        aliases = { "init" },
        builder = "InitCommands",
        queued = true
    },
    {
        key = "InitTank",
        label = "Initialiser les tank",
        tooltipTitle = "Initialiser les tank",
        tooltipDescription = "Applique la configuration de base des bots tank",
        texture = "Interface\\Icons\\Ability_Warrior_DefensiveStance.blp",
        tab = "Config",
        group = "Config",
        order = 41,
        aliases = { "initTank" },
        builder = "InitCommandsTank",
        queued = true
    },
    {
        key = "InitHeal",
        label = "Initialiser les heal",
        tooltipTitle = "Initialiser les heal",
        tooltipDescription = "Applique la configuration de base des botsheal",
        texture = "Interface\\Icons\\Spell_Holy_Heal.blp",
        tab = "Config",
        group = "Config",
        order = 42,
        aliases = { "initHeal" },
        builder = "InitCommandsHeal",
        queued = true
    },
    {
        key = "Summon",
        label = "Invocation",
        tooltipTitle = "Invocation",
        tooltipDescription = "Invoque tous les bots configures",
        texture = "Interface\\Icons\\Spell_Shadow_Teleport",
        tab = "Config",
        group = "Config",
        order = 100,
        aliases = { "summon" },
        builder = "SummonCommands",
        queued = false
    },
    {
        key = "TankAttack",
        label = "Attaque du tank",
        tooltipTitle = "Attaque du tank",
        tooltipDescription = "Ordonne au tank d'attaquer, les autres attendent",
        texture = "Interface\\Icons\\Ability_Warrior_Charge",
        tab = "Combat",
        group = "Tank",
        order = 10,
        aliases = { "tankattack", "tank attack" },
        builder = "TankAttackCommands",
        queued = false
    },
    {
        key = "AttackDPS",
        label = "Attaque DPS",
        tooltipTitle = "Attaque DPS",
        tooltipDescription = "Ordonne aux DPS d'attaquer",
        texture = "Interface\\Icons\\Ability_BackStab",
        tab = "Combat",
        group = "DPS",
        order = 10,
        aliases = { "attackdps", "attack dps" },
        builder = "AttackDPSCommands",
        queued = false
    },
    {
        key = "PassiveDPS",
        label = "Passif DPS",
        tooltipTitle = "Passif DPS",
        tooltipDescription = "Ordonne uniquement aux DPS de fuir / se desengager",
        texture = "Interface\\Icons\\Ability_Rogue_FeignDeath",
        tab = "Combat",
        group = "DPS",
        order = 20,
        aliases = { "passivedps", "passive dps" },
        builder = "PassiveDPSCommands",
        queued = false
    },
    {
        key = "WaitDPS",
        label = "Wait DPS",
        tooltipTitle = "Wait DPS",
        tooltipDescription = "Ordre uniquement aux DPS d'attendre avant d'attaquer",
        texture = "Interface\\Icons\\Spell_Shadow_LastingAfflictions",
        tab = "Combat",
        group = "DPS",
        order = 30,
        aliases = { "waitdps"},
        builder = "WaitDPSCommands",
        queued = false
    },
    {
        key = "Kick",
        label = "Kick",
        tooltipTitle = "Kick",
        tooltipDescription = "Kick le sort de la cible",
        texture = "Interface\\Icons\\Ability_Kick",
        tab = "Combat",
        group = "DPS",
        order = 40,
        aliases = { "kick" },
        builder = "KickCommands",
        queued = false
    },
    {
        key = "WaitHEAL",
        label = "Wait HEAL",
        tooltipTitle = "Wait HEAL",
        tooltipDescription = "Ordre uniquement aux HEAL d'attendre avant d'attaquer",
        texture = "Interface\\Icons\\Spell_Shadow_LastingAfflictions",
        tab = "Combat",
        group = "Heal",
        order = 10,
        aliases = { "waitheal"},
        builder = "WaitHEALCommands",
        queued = false
    },
    {
        key = "Follow",
        label = "Suivre",
        tooltipTitle = "Suivre",
        tooltipDescription = "Ordonne a tout le groupe de suivre",
        texture = "Interface\\Icons\\Ability_Hunter_Pathfinding",
        tab = "Combat",
        group = "All",
        order = 10,
        aliases = { "follow" },
        builder = "FollowCommands",
        queued = false
    },
    {
        key = "Passive",
        label = "Passif",
        tooltipTitle = "Passif",
        tooltipDescription = "Ordonne au groupe de fuir / se desengager",
        texture = "Interface\\Icons\\Ability_Rogue_FeignDeath",
        tab = "Combat",
        group = "All",
        order = 20,
        aliases = { "passive" },
        builder = "PassiveCommands",
        queued = false
    },
    {
        key = "Stay",
        label = "Rester sur place",
        tooltipTitle = "Rester sur place",
        tooltipDescription = "Ordonne au groupe de rester en place",
        texture = "Interface\\Icons\\Spell_Nature_TimeStop",
        tab = "Combat",
        group = "All",
        order = 30,
        aliases = { "stay" },
        builder = "StayCommands",
        queued = false
    },
    {
        key = "Used",
        label = "Utiliser",
        tooltipTitle = "Utiliser",
        tooltipDescription = "Lance la commande /p u go",
        texture = "Interface\\Icons\\INV_Misc_Wrench_01",
        tab = "Combat",
        group = "All",
        order = 40,
        aliases = { "used" },
        builder = "UsedCommands",
        queued = false
    },
    {
        key = "Rez",
        label = "ressuscite",
        tooltipTitle = "ressuscite",
        tooltipDescription = "ressuscite tous les joueurs",
        texture = "Interface\\Icons\\Spell_Holy_Resurrection",
        tab = "Combat",
        group = "All",
        order = 50,
        aliases = { "rez" },
        builder = "RezCommands",
        queued = false
    }
}

local ACTION_TAB_ORDER = {
    Config = 1,
    Combat = 2
}

local ACTION_GROUP_ORDER = {
    Config = 1,
    Tank = 1,
    DPS = 2,
    Heal = 3,
    All = 4
}

local function TrimText(text)
    if not text then
        return ""
    end

    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")

    return text
end

local function NormalizeAliasText(text)
    text = TrimText(text or "")
    text = string.lower(text)
    text = string.gsub(text, "[%s%-%_]+", "")
    text = string.gsub(text, "[^%w]", "")

    return text
end

local function CompareActions(left, right)
    local leftTabOrder = ACTION_TAB_ORDER[left.tab] or 99
    local rightTabOrder = ACTION_TAB_ORDER[right.tab] or 99
    local leftGroupOrder = ACTION_GROUP_ORDER[left.group] or 99
    local rightGroupOrder = ACTION_GROUP_ORDER[right.group] or 99
    local leftOrder = left.order or 9999
    local rightOrder = right.order or 9999
    local leftKey = left.key or ""
    local rightKey = right.key or ""

    if leftTabOrder ~= rightTabOrder then
        return leftTabOrder < rightTabOrder
    end

    if leftGroupOrder ~= rightGroupOrder then
        return leftGroupOrder < rightGroupOrder
    end

    if leftOrder ~= rightOrder then
        return leftOrder < rightOrder
    end

    return leftKey < rightKey
end

local function CopyActionList(actions)
    local copy = {}
    local index

    for index = 1, table.getn(actions or {}) do
        table.insert(copy, actions[index])
    end

    return copy
end

function BotControl.GetOrderedRegistryActions()
    local ordered = CopyActionList(BotControl.ActionRegistry or {})

    table.sort(ordered, CompareActions)

    return ordered
end

function BotControl.GetActionsForTab(tabName)
    local source = BotControl.ACTIONS_BY_TAB and BotControl.ACTIONS_BY_TAB[tabName]

    return CopyActionList(source or {})
end

function BotControl.GetActionsForGroup(tabName, groupName)
    local source

    if BotControl.ACTIONS_BY_GROUP
        and BotControl.ACTIONS_BY_GROUP[tabName]
        and BotControl.ACTIONS_BY_GROUP[tabName][groupName] then
        source = BotControl.ACTIONS_BY_GROUP[tabName][groupName]
    end

    return CopyActionList(source or {})
end

function BotControl.GetActionByKey(actionKey)
    if not BotControl.ACTION_BY_KEY then
        return nil
    end

    return BotControl.ACTION_BY_KEY[actionKey]
end

function BotControl.BuildActionLookupTables()
    local orderedActions = BotControl.GetOrderedRegistryActions()
    local actionButtonConfig = {}
    local actionCommandOrder = {}
    local actionCommandAliases = {}
    local actionsByKey = {}
    local actionsByTab = {
        Config = {},
        Combat = {}
    }
    local actionsByGroup = {
        Config = {
            Config = {}
        },
        Combat = {
            Tank = {},
            DPS = {},
            Heal = {},
            All = {}
        }
    }
    local slashMap = {}
    local index
    local aliasIndex
    local action
    local alias

    for index = 1, table.getn(orderedActions) do
        action = orderedActions[index]
        actionsByKey[action.key] = action
        table.insert(actionCommandOrder, action.key)

        actionButtonConfig[action.key] = {
            texture = action.texture,
            title = action.tooltipTitle or action.label or action.key,
            description = action.tooltipDescription or ""
        }

        actionCommandAliases[action.key] = CopyActionList(action.aliases or {})

        if actionsByTab[action.tab] then
            table.insert(actionsByTab[action.tab], action)
        end

        if actionsByGroup[action.tab] and actionsByGroup[action.tab][action.group] then
            table.insert(actionsByGroup[action.tab][action.group], action)
        end

        slashMap[NormalizeAliasText(action.key)] = action.key
        if action.label then
            slashMap[NormalizeAliasText(action.label)] = action.key
        end
        if action.tooltipTitle then
            slashMap[NormalizeAliasText(action.tooltipTitle)] = action.key
        end

        for aliasIndex = 1, table.getn(action.aliases or {}) do
            alias = action.aliases[aliasIndex]
            if NormalizeAliasText(alias) ~= "" and not slashMap[NormalizeAliasText(alias)] then
                slashMap[NormalizeAliasText(alias)] = action.key
            end
        end
    end

    BotControl.ACTION_BUTTON_CONFIG = actionButtonConfig
    BotControl.ACTION_COMMAND_ORDER = actionCommandOrder
    BotControl.ACTION_COMMAND_ALIASES = actionCommandAliases
    BotControl.ACTION_BY_KEY = actionsByKey
    BotControl.ACTIONS_BY_TAB = actionsByTab
    BotControl.ACTIONS_BY_GROUP = actionsByGroup
    BotControl.ORDERED_ACTIONS = orderedActions
    BotControl.ACTION_SLASH_MAP = slashMap
end

BotControl.BuildActionLookupTables()
