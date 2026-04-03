BotControlConfig = {}

BotControlConfig.defaults = {
    tankName = "",
    healName = "",
    dps1Name = "",
    dps2Name = "",
    dps3Name = "",
    tankBuild = "",
    healBuild = "",
    dps1Build = "",
    dps2Build = "",
    dps3Build = "",
    profiles = {},
    bots = {
        tank = "",
        heal = "",
        dps1 = "",
        dps2 = "",
        dps3 = ""
    },
    builds = {
        tank = "",
        heal = "",
        dps1 = "",
        dps2 = "",
        dps3 = ""
    }
}

local function CopyDefaults(target, defaults)
    local key

    if not target then
        target = {}
    end

    for key in pairs(defaults) do
        if target[key] == nil then
            target[key] = defaults[key]
        end
    end

    return target
end

function BotControlConfig:Initialize()
    if type(BotControlDB) ~= "table" then
        BotControlDB = {}
    end

    BotControlDB = CopyDefaults(BotControlDB, self.defaults)
end

function BotControlConfig:GetDB()
    return BotControlDB or self.defaults
end

function BotControlConfig:GetValue(key)
    local db = self:GetDB()
    return db[key] or ""
end

function BotControlConfig:SetValue(key, value)
    local db = self:GetDB()
    db[key] = value or ""
end

function BotControlConfig:LoadToUI(frame)
    local fields
    local index
    local field

    if not frame or not frame.fields then
        return
    end

    fields = frame.fields

    for index = 1, table.getn(fields) do
        field = fields[index]
        field.editBox:SetText(self:GetValue(field.key))
    end
end

function BotControlConfig:SaveFromUI(frame)
    local fields
    local index
    local field
    local text

    if not frame or not frame.fields then
        return
    end

    fields = frame.fields

    for index = 1, table.getn(fields) do
        field = fields[index]
        text = field.editBox:GetText() or ""
        self:SetValue(field.key, BotControl.Trim(text))
    end
end
