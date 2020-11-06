local AddonName, AddonTable = ...
local Addon = AddonTable[1]

Addon.config = {
    defaults = {
        profile = {
            modifySpellDamage = true,
            showNextRank = true
        }
    }
}

function Addon:SetupConfig()
    Addon.config.db = Addon.Libs.AceDB:New(AddonName .. "_DB", Addon.config.defaults)
end