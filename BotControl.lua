BotControl = {}
BotControl_ProfileElements = {}
BotControl_ActionElements = {}
BotControl_ActionSubTabElements = {}
BotControl_ActionConfigElements = {}
BotControl_ActionCombatElements = {}
BotControl.selectedProfileName = nil
BotControl.selectedProfileNamesByFormat = {}
BotControl_SelectedProfileName = nil
BotControl.currentTab = "Profiles"
BotControl.currentActionsSubTab = "Config"
BotControl.activeProfileFormat = "party5"

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
BotControl.MAX_PROFILE_SLOTS = 25
BotControl.PROFILE_SLOT_ROWS = 5
BotControl.PROFILE_SLOT_TOP_OFFSET = -102
BotControl.PROFILE_SLOT_ROW_HEIGHT = 40
BotControl.PROFILE_SLOT_COLUMN_X = 24
BotControl.PROFILE_SLOT_COLUMN_WIDTH = 350
BotControl.PROFILE_SLOT_COLUMN_GAP = 26
BotControl.PROFILE_SLOT_NAME_WIDTH = 104
BotControl.PROFILE_SLOT_ROLE_DROPDOWN_X = 110
BotControl.PROFILE_SLOT_ROLE_WIDTH = 48
BotControl.PROFILE_SLOT_CLASS_WIDTH = 50
BotControl.PROFILE_SLOT_SPEC_WIDTH = 62
BotControl.PROFILE_SLOT_DROPDOWN_SPACING = -12
BotControl.PROFILE_GROUP_HEIGHT = 210
BotControl.PROFILE_GROUP_GAP_Y = 34
BotControl.PROFILE_SIDE_PANEL_GAP = 24
BotControl.PROFILE_SIDE_PANEL_WIDTH = 138
BotControl.PROFILE_SIDE_PANEL_MIN_X = 432

BotControl.PROFILE_FORMATS = {
    party5 = {
        key = "party5",
        label = "5 joueurs",
        slotCount = 5,
        columnCount = 1,
        frameHeight = 350,
        groupLayout = {
            { column = 1, row = 1 }
        }
    },
    raid10 = {
        key = "raid10",
        label = "10 joueurs",
        slotCount = 10,
        columnCount = 1,
        frameHeight = 650,
        groupLayout = {
            { column = 1, row = 1 },
            { column = 1, row = 2 }
        }
    },
    raid25 = {
        key = "raid25",
        label = "25 joueurs",
        slotCount = 25,
        columnCount = 3,
        frameHeight = 650,
        sidePanelGap = 50,
        groupLayout = {
            { column = 1, row = 1 },
            { column = 1, row = 2 },
            { column = 2, row = 1, xOffset = 20 },
            { column = 2, row = 2, xOffset = 20 },
            { column = 3, row = 1, xOffset = 40 }
        }
    }
}

BotControl.PROFILE_FORMAT_ORDER = {
    "party5",
    "raid10",
    "raid25"
}

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
        texture = "Interface\\Icons\\INV_Misc_Book_09",
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

BotControl.ACTION_COMMAND_ORDER = {
    "ComposeGroup",
    "Build",
    "Init",
    "FullSetup",
    "Summon",
    "InitBots",
    "TankAttack",
    "AttackDPS",
    "Follow",
    "Passive",
    "Stay",
    "Used"
}

BotControl.ACTION_COMMAND_ALIASES = {
    ComposeGroup = {
        "compose"
    },
    Build = {
        "build"
    },
    Init = {
        "init"
    },
    FullSetup = {
        "fullsetup"
    },
    Summon = {
        "summon"
    },
    InitBots = {
        "initbots"
    },
    TankAttack = {
        "tankattack"
    },
    AttackDPS = {
        "attackdps"
    },
    Follow = {
        "follow"
    },
    Passive = {
        "passive"
    },
    Stay = {
        "stay"
    },
    Used = {
        "used"
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

function BotControl.NormalizeCommandAlias(text)
    text = BotControl.Trim(text or "")
    text = string.lower(text)
    text = string.gsub(text, "[%s%-%_]+", "")
    text = string.gsub(text, "[^%w]", "")

    return text
end

function BotControl.GetDefaultRoleForField(key)
    local slotIndex

    if key == "tankName" or key == "tankBuild" then
        return "tank"
    end

    if key == "healName" or key == "healBuild" then
        return "heal"
    end

    slotIndex = tonumber(string.match(key or "", "^slot(%d+)"))
    if slotIndex then
        return BotControl.GetDefaultRoleForSlotIndex(slotIndex)
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

function BotControl.NormalizeProfileFormat(formatKey)
    if type(formatKey) == "number" then
        if formatKey == 10 then
            formatKey = "raid10"
        elseif formatKey == 25 then
            formatKey = "raid25"
        else
            formatKey = "party5"
        end
    end

    if type(BotControl.PROFILE_FORMATS[formatKey]) == "table" then
        return formatKey
    end

    return "party5"
end

function BotControl.GetProfileFormatConfig(formatKey)
    return BotControl.PROFILE_FORMATS[BotControl.NormalizeProfileFormat(formatKey)]
end

function BotControl.GetProfileSlotCount(formatKey)
    return BotControl.GetProfileFormatConfig(formatKey).slotCount
end

function BotControl.GetProfileColumnCount(formatKey)
    return BotControl.GetProfileFormatConfig(formatKey).columnCount
end

function BotControl.GetProfileFrameHeight(formatKey)
    return BotControl.GetProfileFormatConfig(formatKey).frameHeight or BotControl.PROFILES_FRAME_HEIGHT
end

function BotControl.GetProfileGroupPosition(formatKey, groupIndex)
    local config = BotControl.GetProfileFormatConfig(formatKey)
    local groupLayout = config.groupLayout or {}

    return groupLayout[groupIndex] or groupLayout[1] or { column = 1, row = 1 }
end

function BotControl.GetProfileGroupX(formatKey, groupIndex)
    local groupPosition = BotControl.GetProfileGroupPosition(formatKey, groupIndex)

    return BotControl.PROFILE_SLOT_COLUMN_X
        + ((groupPosition.column - 1) * (BotControl.PROFILE_SLOT_COLUMN_WIDTH + BotControl.PROFILE_SLOT_COLUMN_GAP))
        + (groupPosition.xOffset or 0)
end

function BotControl.GetProfileSidePanelX(formatKey)
    local config = BotControl.GetProfileFormatConfig(formatKey)
    local groupLayout = config.groupLayout or {}
    local sidePanelGap = config.sidePanelGap or BotControl.PROFILE_SIDE_PANEL_GAP
    local maxRightX = 0
    local groupIndex
    local groupX
    local computedX

    for groupIndex = 1, table.getn(groupLayout) do
        groupX = BotControl.GetProfileGroupX(formatKey, groupIndex) + BotControl.PROFILE_SLOT_COLUMN_WIDTH
        if groupX > maxRightX then
            maxRightX = groupX
        end
    end

    if maxRightX == 0 then
        maxRightX = BotControl.PROFILE_SLOT_COLUMN_X + BotControl.PROFILE_SLOT_COLUMN_WIDTH
    end

    computedX = maxRightX + sidePanelGap

    if computedX < BotControl.PROFILE_SIDE_PANEL_MIN_X then
        return BotControl.PROFILE_SIDE_PANEL_MIN_X
    end

    return computedX
end

function BotControl.GetProfilesFrameWidth(formatKey)
    local width = BotControl.GetProfileSidePanelX(formatKey) + BotControl.PROFILE_SIDE_PANEL_WIDTH + 24

    if width < BotControl.PROFILES_FRAME_WIDTH then
        width = BotControl.PROFILES_FRAME_WIDTH
    end

    return width
end

function BotControl.GetDefaultRoleForSlotIndex(slotIndex)
    if slotIndex == 1 then
        return "tank"
    end

    if slotIndex == 2 then
        return "heal"
    end

    return "dps"
end

function BotControl.NormalizeSlotsList(slots, slotCount)
    local normalized = {}
    local index
    local slot

    slotCount = slotCount or table.getn(slots or {})

    for index = 1, slotCount do
        slot = type(slots) == "table" and slots[index] or nil
        normalized[index] = BotControl.CreateProfileSlotEntry(
            slot and slot.name or "",
            slot and slot.role or nil,
            slot and slot.class or "",
            slot and (slot.spec or slot.build) or "",
            BotControl.GetDefaultRoleForSlotIndex(index)
        )
    end

    return normalized
end

function BotControl.BuildValuesFromSlots(slots, slotCount)
    local values = {}
    local normalizedSlots = BotControl.NormalizeSlotsList(slots, slotCount)
    local index
    local slot

    slotCount = slotCount or table.getn(normalizedSlots)

    for index = 1, slotCount do
        slot = normalizedSlots[index] or {}
        values["slot" .. index .. "Name"] = slot.name or ""
        values["slot" .. index .. "Role"] = slot.role or BotControl.GetDefaultRoleForSlotIndex(index)
        values["slot" .. index .. "Class"] = slot.class or ""
        values["slot" .. index .. "Spec"] = slot.spec or ""
    end

    return values
end

function BotControl.BuildSlotsFromValues(values, slotCount)
    local slots = {}
    local index

    slotCount = slotCount or BotControl.MAX_PROFILE_SLOTS

    if type(values) ~= "table" then
        values = {}
    end

    for index = 1, slotCount do
        slots[index] = BotControl.CreateProfileSlotEntry(
            values["slot" .. index .. "Name"],
            values["slot" .. index .. "Role"],
            values["slot" .. index .. "Class"],
            values["slot" .. index .. "Spec"],
            BotControl.GetDefaultRoleForSlotIndex(index)
        )
    end

    return slots
end

function BotControl.HasAnySlotData(slots)
    local index
    local slot

    if type(slots) ~= "table" then
        return false
    end

    for index = 1, table.getn(slots) do
        slot = slots[index]
        if type(slot) == "table" and (
            BotControl.HasValue(slot.name) or
            BotControl.HasValue(slot.class) or
            BotControl.HasValue(slot.spec)
        ) then
            return true
        end
    end

    return false
end

function BotControl.BuildLegacySlotsFromDB(db)
    return {
        BotControl.CreateProfileSlotEntry(db.tankName, db.tankRole, db.tankClass, db.tankBuild, "tank"),
        BotControl.CreateProfileSlotEntry(db.healName, db.healRole, db.healClass, db.healBuild, "heal"),
        BotControl.CreateProfileSlotEntry(db.dps1Name, db.dps1Role, db.dps1Class, db.dps1Build, "dps"),
        BotControl.CreateProfileSlotEntry(db.dps2Name, db.dps2Role, db.dps2Class, db.dps2Build, "dps"),
        BotControl.CreateProfileSlotEntry(db.dps3Name, db.dps3Role, db.dps3Class, db.dps3Build, "dps")
    }
end

function BotControl.GetLegacyRoleGroups(slots)
    local groups = {
        tank = {},
        heal = {},
        dps = {}
    }
    local normalizedSlots = BotControl.NormalizeSlotsList(slots, table.getn(slots or {}))
    local index
    local slot

    for index = 1, table.getn(normalizedSlots) do
        slot = normalizedSlots[index]
        if BotControl.HasValue(slot.name) or BotControl.HasValue(slot.spec) or BotControl.HasValue(slot.class) then
            table.insert(groups[slot.role], slot)
        end
    end

    return groups
end

function BotControl.BuildLegacyValuesFromSlots(slots)
    local groups = BotControl.GetLegacyRoleGroups(slots)
    local values = {}

    values.tankName = groups.tank[1] and groups.tank[1].name or ""
    values.tankRole = groups.tank[1] and groups.tank[1].role or "tank"
    values.tankClass = groups.tank[1] and groups.tank[1].class or ""
    values.tankBuild = groups.tank[1] and groups.tank[1].spec or ""

    values.healName = groups.heal[1] and groups.heal[1].name or ""
    values.healRole = groups.heal[1] and groups.heal[1].role or "heal"
    values.healClass = groups.heal[1] and groups.heal[1].class or ""
    values.healBuild = groups.heal[1] and groups.heal[1].spec or ""

    values.dps1Name = groups.dps[1] and groups.dps[1].name or ""
    values.dps1Role = groups.dps[1] and groups.dps[1].role or "dps"
    values.dps1Class = groups.dps[1] and groups.dps[1].class or ""
    values.dps1Build = groups.dps[1] and groups.dps[1].spec or ""

    values.dps2Name = groups.dps[2] and groups.dps[2].name or ""
    values.dps2Role = groups.dps[2] and groups.dps[2].role or "dps"
    values.dps2Class = groups.dps[2] and groups.dps[2].class or ""
    values.dps2Build = groups.dps[2] and groups.dps[2].spec or ""

    values.dps3Name = groups.dps[3] and groups.dps[3].name or ""
    values.dps3Role = groups.dps[3] and groups.dps[3].role or "dps"
    values.dps3Class = groups.dps[3] and groups.dps[3].class or ""
    values.dps3Build = groups.dps[3] and groups.dps[3].spec or ""

    return values
end

function BotControl.ApplyLegacyStateFromSlots(slots)
    local db = BotControlConfig:GetDB()
    local values = BotControl.BuildLegacyValuesFromSlots(slots)

    if type(db.bots) ~= "table" then
        db.bots = {}
    end
    if type(db.builds) ~= "table" then
        db.builds = {}
    end

    db.tankName = values.tankName
    db.healName = values.healName
    db.dps1Name = values.dps1Name
    db.dps2Name = values.dps2Name
    db.dps3Name = values.dps3Name

    db.tankRole = values.tankRole
    db.healRole = values.healRole
    db.dps1Role = values.dps1Role
    db.dps2Role = values.dps2Role
    db.dps3Role = values.dps3Role

    db.tankClass = values.tankClass
    db.healClass = values.healClass
    db.dps1Class = values.dps1Class
    db.dps2Class = values.dps2Class
    db.dps3Class = values.dps3Class

    db.tankBuild = values.tankBuild
    db.healBuild = values.healBuild
    db.dps1Build = values.dps1Build
    db.dps2Build = values.dps2Build
    db.dps3Build = values.dps3Build

    db.bots.tank = values.tankName
    db.bots.heal = values.healName
    db.bots.dps1 = values.dps1Name
    db.bots.dps2 = values.dps2Name
    db.bots.dps3 = values.dps3Name

    db.builds.tank = values.tankBuild
    db.builds.heal = values.healBuild
    db.builds.dps1 = values.dps1Build
    db.builds.dps2 = values.dps2Build
    db.builds.dps3 = values.dps3Build
end

function BotControl.EnsureProfileStorage()
    local db = BotControlConfig:GetDB()
    local legacyProfileNames = {}
    local profileName
    local formatKey
    local workingSet

    if type(db.profiles) ~= "table" then
        db.profiles = {}
    end

    for profileName in pairs(db.profiles) do
        if profileName ~= "party5" and profileName ~= "raid10" and profileName ~= "raid25" then
            table.insert(legacyProfileNames, profileName)
        end
    end

    if type(db.profiles.party5) ~= "table" then
        db.profiles.party5 = {}
    end
    if type(db.profiles.raid10) ~= "table" then
        db.profiles.raid10 = {}
    end
    if type(db.profiles.raid25) ~= "table" then
        db.profiles.raid25 = {}
    end

    for _, profileName in ipairs(legacyProfileNames) do
        if db.profiles.party5[profileName] == nil then
            db.profiles.party5[profileName] = db.profiles[profileName]
        end
        db.profiles[profileName] = nil
    end

    if type(db.currentSlotsByFormat) ~= "table" then
        db.currentSlotsByFormat = {}
    end

    for _, formatKey in ipairs(BotControl.PROFILE_FORMAT_ORDER) do
        if type(db.currentSlotsByFormat[formatKey]) ~= "table" then
            db.currentSlotsByFormat[formatKey] = {}
        end

        workingSet = db.currentSlotsByFormat[formatKey]
        if type(workingSet.slots) ~= "table" then
            workingSet.slots = {}
        end

        workingSet.slots = BotControl.NormalizeSlotsList(workingSet.slots, BotControl.GetProfileSlotCount(formatKey))
    end

    if not BotControl.HasAnySlotData(db.currentSlotsByFormat.party5.slots) then
        db.currentSlotsByFormat.party5.slots = BotControl.NormalizeSlotsList(BotControl.BuildLegacySlotsFromDB(db), 5)
    end

    db.activeProfileFormat = BotControl.NormalizeProfileFormat(db.activeProfileFormat)
    BotControl.activeProfileFormat = db.activeProfileFormat
end

function BotControl.GetActiveProfileFormat()
    return BotControl.NormalizeProfileFormat(BotControl.activeProfileFormat)
end

function BotControl.GetProfilesTable(formatKey)
    local db = BotControlConfig:GetDB()

    BotControl.EnsureProfileStorage()
    formatKey = BotControl.NormalizeProfileFormat(formatKey)

    return db.profiles[formatKey]
end

function BotControl.GetWorkingSlots(formatKey)
    local db = BotControlConfig:GetDB()

    BotControl.EnsureProfileStorage()
    formatKey = BotControl.NormalizeProfileFormat(formatKey)

    return BotControl.NormalizeSlotsList(db.currentSlotsByFormat[formatKey].slots, BotControl.GetProfileSlotCount(formatKey))
end

function BotControl.SetWorkingSlots(formatKey, slots)
    local db = BotControlConfig:GetDB()

    BotControl.EnsureProfileStorage()
    formatKey = BotControl.NormalizeProfileFormat(formatKey)
    db.currentSlotsByFormat[formatKey].slots = BotControl.NormalizeSlotsList(slots, BotControl.GetProfileSlotCount(formatKey))

    if BotControl.GetActiveProfileFormat() == formatKey then
        BotControl.ApplyLegacyStateFromSlots(db.currentSlotsByFormat[formatKey].slots)
    end
end

function BotControl.GetActiveProfileSlots()
    return BotControl.GetWorkingSlots(BotControl.GetActiveProfileFormat())
end

function BotControl.BuildProfileFromSlots(formatKey, slots)
    local normalizedSlots = BotControl.NormalizeSlotsList(slots, BotControl.GetProfileSlotCount(formatKey))
    local profile = {
        slots = normalizedSlots
    }
    local legacyValues

    if BotControl.NormalizeProfileFormat(formatKey) == "party5" then
        legacyValues = BotControl.BuildLegacyValuesFromSlots(normalizedSlots)
        profile.bots = {
            tank = legacyValues.tankName,
            heal = legacyValues.healName,
            dps1 = legacyValues.dps1Name,
            dps2 = legacyValues.dps2Name,
            dps3 = legacyValues.dps3Name
        }
        profile.builds = {
            tank = BotControl.CreateProfileBuildEntry(legacyValues.tankClass, legacyValues.tankBuild),
            heal = BotControl.CreateProfileBuildEntry(legacyValues.healClass, legacyValues.healBuild),
            dps1 = BotControl.CreateProfileBuildEntry(legacyValues.dps1Class, legacyValues.dps1Build),
            dps2 = BotControl.CreateProfileBuildEntry(legacyValues.dps2Class, legacyValues.dps2Build),
            dps3 = BotControl.CreateProfileBuildEntry(legacyValues.dps3Class, legacyValues.dps3Build)
        }
    end

    return profile
end

function BotControl.BuildSlotsFromProfile(profile, formatKey)
    local slots = {}
    local index
    local name
    local roleName
    local className
    local specName

    formatKey = BotControl.NormalizeProfileFormat(formatKey)
    if type(profile) ~= "table" then
        return BotControl.NormalizeSlotsList(slots, BotControl.GetProfileSlotCount(formatKey))
    end

    if type(profile.slots) == "table" then
        return BotControl.NormalizeSlotsList(profile.slots, BotControl.GetProfileSlotCount(formatKey))
    end

    if formatKey ~= "party5" then
        return BotControl.NormalizeSlotsList(slots, BotControl.GetProfileSlotCount(formatKey))
    end

    if type(profile.bots) ~= "table" then
        profile.bots = {}
    end
    if type(profile.builds) ~= "table" then
        profile.builds = {}
    end

    for index = 1, 5 do
        if index == 1 then
            name, roleName, className, specName = BotControl.ExtractSlotSelection(nil, profile.bots.tank, "tank", profile.builds.tank)
        elseif index == 2 then
            name, roleName, className, specName = BotControl.ExtractSlotSelection(nil, profile.bots.heal, "heal", profile.builds.heal)
        elseif index == 3 then
            name, roleName, className, specName = BotControl.ExtractSlotSelection(nil, profile.bots.dps1, "dps", profile.builds.dps1)
        elseif index == 4 then
            name, roleName, className, specName = BotControl.ExtractSlotSelection(nil, profile.bots.dps2, "dps", profile.builds.dps2)
        else
            name, roleName, className, specName = BotControl.ExtractSlotSelection(nil, profile.bots.dps3, "dps", profile.builds.dps3)
        end

        slots[index] = BotControl.CreateProfileSlotEntry(name, roleName, className, specName, BotControl.GetDefaultRoleForSlotIndex(index))
    end

    return BotControl.NormalizeSlotsList(slots, 5)
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
    if not BotControl.HasValue(message) then
        return
    end

    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99BotControl:|r " .. message)
    elseif print then
        print("BotControl: " .. message)
    end
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
    local rowY = definition.rowY or (-78 - ((definition.order - 1) * 40))
    local labelX
    local boxX
    local label
    local editBox

    if definition.labelX then
        labelX = definition.labelX
        boxX = definition.boxX or definition.labelX
    elseif definition.column == "left" then
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
    if definition.editWidth then
        editBox:SetWidth(definition.editWidth)
    elseif definition.column == "left" then
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
    local rowY = definition.rowY or (-78 - ((definition.order - 1) * 40))
    local roleDropdown
    local classDropdown
    local specDropdown
    local field
    local roleItems = BotControl.CopyList(BotControl.Roles)
    local classItems = BotControl.CopyList(BotControl.Classes)
    local roleDropdownX = definition.roleDropdownX or 150
    local roleDropdownWidth = definition.roleDropdownWidth or 42
    local classDropdownWidth = definition.classDropdownWidth or 56
    local firstDropdownSpacing = definition.firstDropdownSpacing or -18
    local dropdownSpacing = definition.dropdownSpacing or -18
    local specDropdownWidth = definition.specDropdownWidth or 68
    local dropdownName = definition.namePrefix or definition.key

    table.insert(classItems, 1, "")

    roleDropdown = CreateFrame("Frame", "BotControl" .. dropdownName .. "RoleDropDown", parent, "UIDropDownMenuTemplate")
    roleDropdown:ClearAllPoints()
    roleDropdown:SetPoint("TOPLEFT", parent, "TOPLEFT", roleDropdownX, rowY - 8)
    UIDropDownMenu_SetWidth(roleDropdownWidth, roleDropdown)
    UIDropDownMenu_JustifyText("LEFT", roleDropdown)

    classDropdown = CreateFrame("Frame", "BotControl" .. dropdownName .. "ClassDropDown", parent, "UIDropDownMenuTemplate")
    classDropdown:ClearAllPoints()
    classDropdown:SetPoint("LEFT", roleDropdown, "RIGHT", firstDropdownSpacing, 0)
    UIDropDownMenu_SetWidth(classDropdownWidth, classDropdown)
    UIDropDownMenu_JustifyText("LEFT", classDropdown)

    specDropdown = CreateFrame("Frame", "BotControl" .. dropdownName .. "SpecDropDown", parent, "UIDropDownMenuTemplate")
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

function BotControl.CreateProfileSlotField(parent, slotIndex)
    local nameKey = "slot" .. slotIndex .. "Name"
    local roleKey = "slot" .. slotIndex .. "Role"
    local classKey = "slot" .. slotIndex .. "Class"
    local specKey = "slot" .. slotIndex .. "Spec"
    local nameField
    local specField
    local field

    nameField = BotControl.CreateTextField(parent, {
        key = nameKey,
        label = "Bot " .. slotIndex,
        rowY = -78,
        labelX = BotControl.PROFILE_SLOT_COLUMN_X,
        boxX = BotControl.PROFILE_SLOT_COLUMN_X,
        editWidth = BotControl.PROFILE_SLOT_NAME_WIDTH
    })

    specField = BotControl.CreateClassSpecField(parent, {
        key = specKey,
        roleKey = roleKey,
        classKey = classKey,
        rowY = -78,
        roleDropdownX = BotControl.PROFILE_SLOT_COLUMN_X + BotControl.PROFILE_SLOT_ROLE_DROPDOWN_X,
        roleDropdownWidth = BotControl.PROFILE_SLOT_ROLE_WIDTH,
        classDropdownWidth = BotControl.PROFILE_SLOT_CLASS_WIDTH,
        specDropdownWidth = BotControl.PROFILE_SLOT_SPEC_WIDTH,
        firstDropdownSpacing = BotControl.PROFILE_SLOT_DROPDOWN_SPACING,
        dropdownSpacing = BotControl.PROFILE_SLOT_DROPDOWN_SPACING,
        namePrefix = "ProfileSlot" .. slotIndex
    })

    field = {
        slotIndex = slotIndex,
        label = nameField.label,
        editBox = nameField.editBox,
        roleDropdown = specField.roleDropdown,
        classDropdown = specField.classDropdown,
        specDropdown = specField.specDropdown,
        CollectValues = function(self, values)
            nameField:CollectValues(values)
            specField:CollectValues(values)
        end,
        ApplyValues = function(self, values)
            nameField:ApplyValues(values)
            specField:ApplyValues(values)
        end,
        SetVisible = function(self, isVisible)
            if isVisible then
                self.label:Show()
                self.editBox:Show()
                self.roleDropdown:Show()
                self.classDropdown:Show()
                self.specDropdown:Show()
            else
                self.label:Hide()
                self.editBox:Hide()
                self.roleDropdown:Hide()
                self.classDropdown:Hide()
                self.specDropdown:Hide()
            end
        end
    }

    return field
end

function BotControl.BuildFields(frame)
    local index

    frame.fields = {}
    frame.profileSlotFields = {}

    for index = 1, BotControl.MAX_PROFILE_SLOTS do
        frame.profileSlotFields[index] = BotControl.CreateProfileSlotField(frame, index)
        table.insert(frame.fields, frame.profileSlotFields[index])
    end
end

function BotControl.LayoutProfileFields(frame)
    local formatKey = BotControl.GetActiveProfileFormat()
    local slotCount = BotControl.GetProfileSlotCount(formatKey)
    local shouldShowFields = BotControl.currentTab == "Profiles"
    local slotField
    local slotIndex
    local groupIndex
    local rowIndex
    local groupPosition
    local columnX
    local rowY

    if not frame or not frame.profileSlotFields then
        return
    end

    for slotIndex = 1, table.getn(frame.profileSlotFields) do
        slotField = frame.profileSlotFields[slotIndex]
        if slotField then
            if shouldShowFields and slotIndex <= slotCount then
                groupIndex = math.floor((slotIndex - 1) / BotControl.PROFILE_SLOT_ROWS) + 1
                rowIndex = (slotIndex - 1) - ((groupIndex - 1) * BotControl.PROFILE_SLOT_ROWS)
                groupPosition = BotControl.GetProfileGroupPosition(formatKey, groupIndex)
                columnX = BotControl.GetProfileGroupX(formatKey, groupIndex)
                rowY = BotControl.PROFILE_SLOT_TOP_OFFSET
                    - ((groupPosition.row - 1) * (BotControl.PROFILE_GROUP_HEIGHT + BotControl.PROFILE_GROUP_GAP_Y))
                    - (rowIndex * BotControl.PROFILE_SLOT_ROW_HEIGHT)

                slotField.label:ClearAllPoints()
                slotField.label:SetPoint("TOPLEFT", frame, "TOPLEFT", columnX, rowY)
                slotField.label:SetText("Bot " .. slotIndex)

                slotField.editBox:ClearAllPoints()
                slotField.editBox:SetPoint("TOPLEFT", frame, "TOPLEFT", columnX, rowY - 14)
                slotField.editBox:SetWidth(BotControl.PROFILE_SLOT_NAME_WIDTH)

                slotField.roleDropdown:ClearAllPoints()
                slotField.roleDropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", columnX + BotControl.PROFILE_SLOT_ROLE_DROPDOWN_X, rowY - 8)
                UIDropDownMenu_SetWidth(BotControl.PROFILE_SLOT_ROLE_WIDTH, slotField.roleDropdown)

                slotField.classDropdown:ClearAllPoints()
                slotField.classDropdown:SetPoint("LEFT", slotField.roleDropdown, "RIGHT", BotControl.PROFILE_SLOT_DROPDOWN_SPACING, 0)
                UIDropDownMenu_SetWidth(BotControl.PROFILE_SLOT_CLASS_WIDTH, slotField.classDropdown)

                slotField.specDropdown:ClearAllPoints()
                slotField.specDropdown:SetPoint("LEFT", slotField.classDropdown, "RIGHT", BotControl.PROFILE_SLOT_DROPDOWN_SPACING, 0)
                UIDropDownMenu_SetWidth(BotControl.PROFILE_SLOT_SPEC_WIDTH, slotField.specDropdown)

                slotField:SetVisible(true)
            else
                slotField:SetVisible(false)
            end
        end
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
        width = BotControl.GetProfilesFrameWidth(BotControl.GetActiveProfileFormat())
        height = BotControl.GetProfileFrameHeight(BotControl.GetActiveProfileFormat())
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
    local profiles = BotControl.GetProfilesTable(BotControl.GetActiveProfileFormat())
    local names = {}
    local profileName

    if type(profiles) ~= "table" then
        return names
    end

    for profileName in pairs(profiles) do
        table.insert(names, profileName)
    end

    table.sort(names)

    return names
end

function BotControl.GetSelectedProfileName()
    local formatKey = BotControl.GetActiveProfileFormat()
    local selectedName = BotControl.selectedProfileNamesByFormat[formatKey]

    if BotControl.HasValue(selectedName) then
        return selectedName
    end

    if BotControl.HasValue(BotControl.selectedProfileName) then
        return BotControl.selectedProfileName
    end

    return BotControl.GetProfileName()
end

function BotControl.SelectProfile(profileName)
    local formatKey = BotControl.GetActiveProfileFormat()

    profileName = BotControl.Trim(profileName or "")
    if not BotControl.HasValue(profileName) then
        BotControl.selectedProfileNamesByFormat[formatKey] = nil
        BotControl.selectedProfileName = nil
        BotControl_SelectedProfileName = nil
        if BotControlProfileNameEditBox then
            BotControlProfileNameEditBox:SetText("")
        end
        return
    end

    BotControl.selectedProfileNamesByFormat[formatKey] = profileName
    BotControl.selectedProfileName = profileName
    BotControl_SelectedProfileName = profileName

    if BotControlProfileNameEditBox then
        BotControlProfileNameEditBox:SetText(profileName)
    end

    BotControl.RefreshProfileList()
end

function BotControl.RefreshProfileList()
    local names = BotControl.GetSortedProfileNames()
    local formatKey = BotControl.GetActiveProfileFormat()
    local selectedName = BotControl.selectedProfileNamesByFormat[formatKey]
    local profiles = BotControl.GetProfilesTable(formatKey)
    local rowButtons = BotControl.profileListButtons
    local row
    local rowButton
    local name

    if not rowButtons then
        return
    end

    if selectedName and type(profiles[selectedName]) ~= "table" then
        selectedName = nil
        BotControl.selectedProfileNamesByFormat[formatKey] = nil
        BotControl.selectedProfileName = nil
        BotControl_SelectedProfileName = nil
    end

    if selectedName then
        BotControl.selectedProfileName = selectedName
        BotControl_SelectedProfileName = selectedName
    end

    if BotControlProfileNameEditBox then
        BotControlProfileNameEditBox:SetText(selectedName or "")
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

function BotControl.UpdateProfileSubTabs()
    local formatKey = BotControl.GetActiveProfileFormat()
    local button
    local index
    local subTabButtons = {
        party5 = BotControlProfilesSubTab5,
        raid10 = BotControlProfilesSubTab10,
        raid25 = BotControlProfilesSubTab25
    }

    for index = 1, table.getn(BotControl.PROFILE_FORMAT_ORDER) do
        button = subTabButtons[BotControl.PROFILE_FORMAT_ORDER[index]]
        if button then
            if BotControl.PROFILE_FORMAT_ORDER[index] == formatKey then
                button:Disable()
            else
                button:Enable()
            end
        end
    end
end

function BotControl.LoadActiveSlotsToUI(frame)
    local slots = BotControl.GetActiveProfileSlots()
    local values = BotControl.BuildValuesFromSlots(slots, BotControl.MAX_PROFILE_SLOTS)

    BotControl.ApplyValuesToUI(frame, values)
    BotControl.ApplyLegacyStateFromSlots(slots)
end

function BotControl.SaveActiveSlotsFromUI(frame)
    local formatKey = BotControl.GetActiveProfileFormat()
    local slots = BotControl.BuildSlotsFromValues(BotControl.GetFieldValuesFromUI(frame), BotControl.GetProfileSlotCount(formatKey))

    BotControl.SetWorkingSlots(formatKey, slots)

    return slots
end

function BotControl_ShowProfilesSubTab(formatKey)
    local frame = BotControlFrame
    local db = BotControlConfig:GetDB()
    local currentFormat = BotControl.GetActiveProfileFormat()

    formatKey = BotControl.NormalizeProfileFormat(formatKey)
    if not frame then
        return
    end

    if frame.fields and currentFormat then
        BotControl.SaveActiveSlotsFromUI(frame)
    end

    BotControl.activeProfileFormat = formatKey
    db.activeProfileFormat = formatKey
    BotControl.selectedProfileName = BotControl.selectedProfileNamesByFormat[formatKey]
    BotControl_SelectedProfileName = BotControl.selectedProfileName

    BotControl.LoadActiveSlotsToUI(frame)
    BotControl.LayoutProfileFields(frame)
    BotControl.UpdateProfileSubTabs()
    BotControl.RefreshProfileList()
    BotControl_UpdateFrameSizeForView("Profiles")
    BotControl_LayoutButtons()
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

function BotControl_SetActionButtonIcon(button, texturePath, title, description, slashCommand)
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
    button.tooltipSlashCommand = slashCommand or ""

    button:SetScript("OnEnter", function(self)
        if self.iconTexture then
            self.iconTexture:SetVertexColor(1, 1, 1)
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.tooltipTitle or "")
        if BotControl.HasValue(self.tooltipDescription) then
            GameTooltip:AddLine(self.tooltipDescription, 1, 1, 1, 1)
        end
        if BotControl.HasValue(self.tooltipSlashCommand) then
            GameTooltip:AddLine("Commande : " .. self.tooltipSlashCommand, 0.6, 0.85, 1, 1)
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

function BotControl.GetCanonicalActionSlashAlias(actionName)
    local actionAliases = BotControl.ACTION_COMMAND_ALIASES or {}
    local canonicalAlias = actionAliases[actionName] and actionAliases[actionName][1]

    if BotControl.HasValue(canonicalAlias) then
        return canonicalAlias
    end

    return BotControl.NormalizeCommandAlias(actionName)
end

function BotControl.GetActionSlashDisplayCommand(actionName)
    local canonicalAlias

    if not BotControl.HasValue(actionName) then
        return ""
    end

    canonicalAlias = BotControl.GetCanonicalActionSlashAlias(actionName)
    if not BotControl.HasValue(canonicalAlias) then
        return ""
    end

    return "/bc " .. canonicalAlias
end

function BotControl.StyleActionButtons()
    local config

    config = BotControl.ACTION_BUTTON_CONFIG.ComposeGroup
    BotControl_SetActionButtonIcon(BotControlFrameComposeGroupButton, config.texture, config.title, config.description, BotControl.GetActionSlashDisplayCommand("ComposeGroup"))

    config = BotControl.ACTION_BUTTON_CONFIG.Build
    BotControl_SetActionButtonIcon(BotControlFrameBuildButton, config.texture, config.title, config.description, BotControl.GetActionSlashDisplayCommand("Build"))

    config = BotControl.ACTION_BUTTON_CONFIG.Init
    BotControl_SetActionButtonIcon(BotControlFrameInitButton, config.texture, config.title, config.description, BotControl.GetActionSlashDisplayCommand("Init"))

    config = BotControl.ACTION_BUTTON_CONFIG.FullSetup
    BotControl_SetActionButtonIcon(BotControlFullSetupButton, config.texture, config.title, config.description, BotControl.GetActionSlashDisplayCommand("FullSetup"))

    config = BotControl.ACTION_BUTTON_CONFIG.Summon
    BotControl_SetActionButtonIcon(BotControlFrameSummonButton, config.texture, config.title, config.description, BotControl.GetActionSlashDisplayCommand("Summon"))

    config = BotControl.ACTION_BUTTON_CONFIG.InitBots
    BotControl_SetActionButtonIcon(BotControlInitBotsButton, config.texture, config.title, config.description, BotControl.GetActionSlashDisplayCommand("InitBots"))

    config = BotControl.ACTION_BUTTON_CONFIG.TankAttack
    BotControl_SetActionButtonIcon(BotControlFrameTankAttackButton, config.texture, config.title, config.description, BotControl.GetActionSlashDisplayCommand("TankAttack"))

    config = BotControl.ACTION_BUTTON_CONFIG.AttackDPS
    BotControl_SetActionButtonIcon(BotControlAttackDPSButton, config.texture, config.title, config.description, BotControl.GetActionSlashDisplayCommand("AttackDPS"))

    config = BotControl.ACTION_BUTTON_CONFIG.Follow
    BotControl_SetActionButtonIcon(BotControlFollowButton, config.texture, config.title, config.description, BotControl.GetActionSlashDisplayCommand("Follow"))

    config = BotControl.ACTION_BUTTON_CONFIG.Passive
    BotControl_SetActionButtonIcon(BotControlPassiveButton, config.texture, config.title, config.description, BotControl.GetActionSlashDisplayCommand("Passive"))

    config = BotControl.ACTION_BUTTON_CONFIG.Stay
    BotControl_SetActionButtonIcon(BotControlStayButton, config.texture, config.title, config.description, BotControl.GetActionSlashDisplayCommand("Stay"))

    config = BotControl.ACTION_BUTTON_CONFIG.Used
    BotControl_SetActionButtonIcon(BotControlUsedButton, config.texture, config.title, config.description, BotControl.GetActionSlashDisplayCommand("Used"))
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
    BotControl.AddElement(BotControl_ProfileElements, BotControlProfilesSubTab5)
    BotControl.AddElement(BotControl_ProfileElements, BotControlProfilesSubTab10)
    BotControl.AddElement(BotControl_ProfileElements, BotControlProfilesSubTab25)
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

        BotControl.LayoutProfileFields(BotControlFrame)
        BotControl.UpdateProfileSubTabs()
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
    local profileSubTab5Button
    local profileSubTab10Button
    local profileSubTab25Button
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

    if not BotControlProfilesSubTab5 then
        profileSubTab5Button = CreateFrame("Button", "BotControlProfilesSubTab5", frame, "UIPanelButtonTemplate")
        profileSubTab5Button:SetText("5 joueurs")
        profileSubTab5Button:SetWidth(82)
        profileSubTab5Button:SetHeight(20)
        profileSubTab5Button:SetScript("OnClick", function()
            BotControl_ShowProfilesSubTab("party5")
        end)
    end

    if not BotControlProfilesSubTab10 then
        profileSubTab10Button = CreateFrame("Button", "BotControlProfilesSubTab10", frame, "UIPanelButtonTemplate")
        profileSubTab10Button:SetText("10 joueurs")
        profileSubTab10Button:SetWidth(86)
        profileSubTab10Button:SetHeight(20)
        profileSubTab10Button:SetScript("OnClick", function()
            BotControl_ShowProfilesSubTab("raid10")
        end)
    end

    if not BotControlProfilesSubTab25 then
        profileSubTab25Button = CreateFrame("Button", "BotControlProfilesSubTab25", frame, "UIPanelButtonTemplate")
        profileSubTab25Button:SetText("25 joueurs")
        profileSubTab25Button:SetWidth(86)
        profileSubTab25Button:SetHeight(20)
        profileSubTab25Button:SetScript("OnClick", function()
            BotControl_ShowProfilesSubTab("raid25")
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
    local formatKey = BotControl.GetActiveProfileFormat()
    local slotCount = BotControl.GetProfileSlotCount(formatKey)

    if type(values) ~= "table" then
        return
    end

    if values[1] then
        BotControl.SetWorkingSlots(formatKey, values)
    else
        BotControl.SetWorkingSlots(formatKey, BotControl.BuildSlotsFromValues(values, slotCount))
    end
end

function BotControl.BuildProfileFromValues(values, formatKey)
    formatKey = BotControl.NormalizeProfileFormat(formatKey)
    return BotControl.BuildProfileFromSlots(formatKey, BotControl.BuildSlotsFromValues(values, BotControl.GetProfileSlotCount(formatKey)))
end

function BotControl.BuildValuesFromProfile(profile, formatKey)
    formatKey = BotControl.NormalizeProfileFormat(formatKey)
    return BotControl.BuildValuesFromSlots(BotControl.BuildSlotsFromProfile(profile, formatKey), BotControl.MAX_PROFILE_SLOTS)
end

function BotControl_SaveProfile(profileName)
    local frame = BotControlFrame
    local formatKey = BotControl.GetActiveProfileFormat()
    local profiles
    local slots

    profileName = BotControl.Trim(profileName or "")
    if not BotControl.HasValue(profileName) then
        return
    end

    if frame and frame.fields then
        slots = BotControl.SaveActiveSlotsFromUI(frame)
    else
        slots = BotControl.GetActiveProfileSlots()
    end

    profiles = BotControl.GetProfilesTable(formatKey)
    profiles[profileName] = BotControl.BuildProfileFromSlots(formatKey, slots)
    BotControl.selectedProfileNamesByFormat[formatKey] = profileName
    BotControl.selectedProfileName = profileName
    BotControl_SelectedProfileName = profileName
    BotControl.RefreshProfileList()
end

function BotControl_LoadProfile(profileName)
    local frame = BotControlFrame
    local formatKey = BotControl.GetActiveProfileFormat()
    local profiles = BotControl.GetProfilesTable(formatKey)
    local profile
    local slots

    profileName = BotControl.Trim(profileName or "")
    if not BotControl.HasValue(profileName) then
        return
    end

    profile = profiles[profileName]
    if type(profile) ~= "table" then
        return
    end

    slots = BotControl.BuildSlotsFromProfile(profile, formatKey)
    BotControl.SetWorkingSlots(formatKey, slots)
    BotControl.ApplyValuesToUI(frame, BotControl.BuildValuesFromSlots(slots, BotControl.MAX_PROFILE_SLOTS))
    BotControl.selectedProfileNamesByFormat[formatKey] = profileName
    BotControl.selectedProfileName = profileName
    BotControl_SelectedProfileName = profileName
    BotControl.RefreshProfileList()
end

function BotControl_DeleteProfile(profileName)
    local formatKey = BotControl.GetActiveProfileFormat()
    local profiles = BotControl.GetProfilesTable(formatKey)

    profileName = BotControl.Trim(profileName or "")
    if not BotControl.HasValue(profileName) then
        return
    end

    if not profiles[profileName] then
        return
    end

    profiles[profileName] = nil
    if BotControl.selectedProfileName == profileName then
        BotControl.selectedProfileName = nil
    end
    if BotControl.selectedProfileNamesByFormat[formatKey] == profileName then
        BotControl.selectedProfileNamesByFormat[formatKey] = nil
    end
    BotControl.RefreshProfileList()
end

function BotControl_LayoutButtons()
    local frame = BotControlFrame
    local profilesTabButton = BotControlTabProfiles
    local actionsTabButton = BotControlTabActions
    local configSubTabButton = BotControlActionsSubTabConfig
    local combatSubTabButton = BotControlActionsSubTabCombat
    local profileSubTab5Button = BotControlProfilesSubTab5
    local profileSubTab10Button = BotControlProfilesSubTab10
    local profileSubTab25Button = BotControlProfilesSubTab25
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
    local sidePanelX = BotControl.GetProfileSidePanelX(BotControl.GetActiveProfileFormat())

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

    if profileSubTab5Button then
        profileSubTab5Button:ClearAllPoints()
        profileSubTab5Button:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -60)
    end

    if profileSubTab10Button then
        profileSubTab10Button:ClearAllPoints()
        if profileSubTab5Button then
            profileSubTab10Button:SetPoint("LEFT", profileSubTab5Button, "RIGHT", 8, 0)
        else
            profileSubTab10Button:SetPoint("TOPLEFT", frame, "TOPLEFT", 110, -60)
        end
    end

    if profileSubTab25Button then
        profileSubTab25Button:ClearAllPoints()
        if profileSubTab10Button then
            profileSubTab25Button:SetPoint("LEFT", profileSubTab10Button, "RIGHT", 8, 0)
        elseif profileSubTab5Button then
            profileSubTab25Button:SetPoint("LEFT", profileSubTab5Button, "RIGHT", 96, 0)
        else
            profileSubTab25Button:SetPoint("TOPLEFT", frame, "TOPLEFT", 204, -60)
        end
    end

    if namesHeader then
        namesHeader:ClearAllPoints()
        namesHeader:SetText("Bots")
        namesHeader:SetPoint("TOPLEFT", frame, "TOPLEFT", 24, -84)
    end

    if buildsHeader then
        buildsHeader:ClearAllPoints()
        buildsHeader:SetText("")
        buildsHeader:SetPoint("TOPLEFT", frame, "TOPLEFT", 190, -84)
    end

    if profilesListLabel then
        profilesListLabel:ClearAllPoints()
        profilesListLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", sidePanelX + 4, -58)
    end

    if profilesListFrame then
        profilesListFrame:ClearAllPoints()
        profilesListFrame:SetWidth(138)
        profilesListFrame:SetHeight(160)
        profilesListFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", sidePanelX, -76)
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

        if initBotsButton then
            initBotsButton:ClearAllPoints()
            if buildButton then
                initBotsButton:SetPoint("LEFT", buildButton, "RIGHT", iconSpacing, 0)
            end
        end

        if initButton then
            initButton:ClearAllPoints()
            if initBotsButton then
                initButton:SetPoint("LEFT", initBotsButton, "RIGHT", iconSpacing, 0)
            end
        end

        if fullSetupButton then
            fullSetupButton:ClearAllPoints()
        end

        if summonButton then
            summonButton:ClearAllPoints()
            if composeGroupButton then
                summonButton:SetPoint("TOPLEFT", composeGroupButton, "BOTTOMLEFT", 0, -rowSpacing)
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

    BotControl.LayoutProfileFields(frame)
    BotControl.UpdateProfileSubTabs()

end

function BotControl.Save()
    BotControl.SaveActiveSlotsFromUI(BotControlFrame)
end

function BotControl.Load()
    BotControl.LoadActiveSlotsToUI(BotControlFrame)
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

function BotControl.RegisterActionSlashAlias(map, alias, actionName)
    alias = BotControl.NormalizeCommandAlias(alias)
    if not BotControl.HasValue(alias) or not BotControl.HasValue(actionName) then
        return
    end

    if not map[alias] then
        map[alias] = actionName
    end
end

function BotControl.AppendUniqueActionName(target, lookup, actionName)
    if not BotControl.HasValue(actionName) or lookup[actionName] then
        return
    end

    lookup[actionName] = true
    table.insert(target, actionName)
end

function BotControl.GetOrderedActionNames()
    local orderedActions = {}
    local knownActions = {}
    local defaultOrder = BotControl.ACTION_COMMAND_ORDER or {}
    local actionName
    local index

    for index = 1, table.getn(defaultOrder) do
        BotControl.AppendUniqueActionName(orderedActions, knownActions, defaultOrder[index])
    end

    for actionName in pairs(BotControl.ACTION_BUTTON_CONFIG or {}) do
        BotControl.AppendUniqueActionName(orderedActions, knownActions, actionName)
    end

    if BotControlActions and BotControlActions.definitions then
        for actionName in pairs(BotControlActions.definitions) do
            BotControl.AppendUniqueActionName(orderedActions, knownActions, actionName)
        end
    end

    return orderedActions
end

function BotControl.GetActionSlashMap()
    local map = {}
    local orderedActions = BotControl.GetOrderedActionNames()
    local actionAliases = BotControl.ACTION_COMMAND_ALIASES or {}
    local actionName
    local aliases
    local actionConfig
    local definition
    local index
    local aliasIndex

    for index = 1, table.getn(orderedActions) do
        actionName = orderedActions[index]
        actionConfig = BotControl.ACTION_BUTTON_CONFIG[actionName]
        definition = BotControlActions and BotControlActions.definitions and BotControlActions.definitions[actionName]
        aliases = actionAliases[actionName] or {}

        BotControl.RegisterActionSlashAlias(map, actionName, actionName)

        if definition and definition.label then
            BotControl.RegisterActionSlashAlias(map, definition.label, actionName)
        end

        if actionConfig and actionConfig.title then
            BotControl.RegisterActionSlashAlias(map, actionConfig.title, actionName)
        end

        for aliasIndex = 1, table.getn(aliases) do
            BotControl.RegisterActionSlashAlias(map, aliases[aliasIndex], actionName)
        end
    end

    return map
end

function BotControl.ResolveActionSlashCommand(message)
    local map = BotControl.GetActionSlashMap()

    return map[BotControl.NormalizeCommandAlias(message)]
end

function BotControl.GetActionSlashHelp()
    local aliases = {}
    local orderedActions = BotControl.GetOrderedActionNames()
    local actionAliases = BotControl.ACTION_COMMAND_ALIASES or {}
    local index
    local actionName
    local canonicalAlias

    for index = 1, table.getn(orderedActions) do
        actionName = orderedActions[index]
        canonicalAlias = actionAliases[actionName] and actionAliases[actionName][1]
        if not BotControl.HasValue(canonicalAlias) then
            canonicalAlias = string.lower(actionName)
        end
        table.insert(aliases, canonicalAlias)
    end

    return "/bc <action> : " .. table.concat(aliases, ", ")
end

function BotControl.SetupSlashCommands()
    SLASH_BOTCONTROL1 = "/bc"
    SlashCmdList["BOTCONTROL"] = function(message)
        local trimmedMessage = BotControl.Trim(message or "")
        local actionName
        local normalizedMessage

        if trimmedMessage == "" then
            BotControl.Toggle()
            return
        end

        normalizedMessage = BotControl.NormalizeCommandAlias(trimmedMessage)
        if normalizedMessage == "help" or normalizedMessage == "aide" then
            BotControl.Print("Sans argument, /bc ouvre ou ferme l'interface.")
            BotControl.Print(BotControl.GetActionSlashHelp())
            return
        end

        actionName = BotControl.ResolveActionSlashCommand(trimmedMessage)
        if actionName then
            BotControl_RunNamedAction(actionName)
            return
        end

        BotControl.Print("Commande inconnue : /bc " .. trimmedMessage)
        BotControl.Print(BotControl.GetActionSlashHelp())
    end
end

function BotControl.HandleEvent()
    local db

    if event == "ADDON_LOADED" and arg1 == "BotControl" then
        BotControlConfig:Initialize()
        BotControl.EnsureProfileStorage()
        BotControl.SetupSlashCommands()
    elseif event == "PLAYER_LOGIN" then
        db = BotControlConfig:GetDB()
        BotControl.EnsureProfileStorage()
        BotControl.InitializeFrame(BotControlFrame)
        BotControl.activeProfileFormat = BotControl.NormalizeProfileFormat(db.activeProfileFormat)
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
    BotControl.EnsureProfileStorage()
    db = BotControlConfig:GetDB()
    BotControl.InitializeFrame(frame)
    BotControl_LayoutButtons()
    BotControl.activeProfileFormat = BotControl.NormalizeProfileFormat(db.activeProfileFormat)
    BotControl.Load()
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
