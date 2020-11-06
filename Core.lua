local AddonName, AddonTable = ...

if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then
    return
end

local AceAddon = _G.LibStub("AceAddon-3.0")
local Addon = AceAddon:NewAddon(AddonName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
AddonTable[1] = Addon
_G.ClassicSpellInfo = Addon

Addon.Libs = {}
function Addon:AddLib(name, major, minor)
    if not name then
        return
    end

    Addon.Libs[name] = _G.LibStub(major, minor)
end

Addon:AddLib("AceConsole", "AceConsole-3.0")
Addon:AddLib("AceDB", "AceDB-3.0")
Addon:AddLib("AceDBOptions", "AceDBOptions-3.0")
Addon:AddLib("AceConfig", "AceConfig-3.0")
Addon:AddLib("AceConfigDialog", "AceConfigDialog-3.0")
Addon:AddLib("AceConfigRegistry", "AceConfigRegistry-3.0")
Addon:AddLib("SharedMedia", "LibSharedMedia-3.0")

function Addon:OnInitialize()
    Addon:SetupConfig()
    Addon.Database:Initialize()

    Addon:HookSetSpell(GameTooltip)
    Addon:HookSetSpell(ItemRefTooltip)

    Addon:RegisterEvent("PLAYER_DAMAGE_DONE_MODS", Addon.OnEvent)
    Addon:RegisterEvent("PLAYER_ENTERING_WORLD", Addon.OnEvent)
    Addon:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", Addon.OnEvent)
    Addon:RegisterEvent("PLAYER_LEVEL_UP", Addon.OnEvent)
    Addon:RegisterEvent("PLAYER_UPDATE_RESTING", Addon.OnEvent)
    Addon:RegisterEvent("PLAYER_XP_UPDATE", Addon.OnEvent)
    Addon:RegisterEvent("SKILL_LINES_CHANGED", Addon.OnEvent)
    Addon:RegisterEvent("UNIT_ATTACK", Addon.OnEvent)
    Addon:RegisterEvent("UNIT_ATTACK_POWER", Addon.OnEvent)
    Addon:RegisterEvent("UNIT_ATTACK_SPEED", Addon.OnEvent)
    Addon:RegisterEvent("UNIT_DAMAGE", Addon.OnEvent)
    Addon:RegisterEvent("UNIT_LEVEL", Addon.OnEvent)
    Addon:RegisterEvent("UNIT_MODEL_CHANGED", Addon.OnEvent)
    Addon:RegisterEvent("UNIT_RANGED_ATTACK_POWER", Addon.OnEvent)
    Addon:RegisterEvent("UNIT_RANGEDDAMAGE", Addon.OnEvent)
    Addon:RegisterEvent("UNIT_RESISTANCES", Addon.OnEvent)
    Addon:RegisterEvent("UNIT_STATS", Addon.OnEvent)
end

function Addon:HookSetSpell(tip)
    tip:HookScript("OnTooltipSetSpell", function(tooltip)
        local spellName, spellId = tooltip:GetSpell()
        if spellId then
            if Addon.config.db.profile.modifySpellDamage and not IsShiftKeyDown() then
                Addon.Database:ModifyTooltip(tooltip, spellId)
            end

            if Addon.config.db.profile.showNextRank then
                local isMaxKnownRank = Addon.Database:IsMaxKnownRank(spellId)
                local isMaxRank = Addon.Database:IsMaxRank(spellId)
                if isMaxKnownRank and not isMaxRank then
                    local nextRank = Addon.Database:GetNextRank(spellId)
                    if nextRank then
                        tooltip:AddLine("|cffa0bed2Next rank available at level " .. nextRank.level .. ".|r") -- TODO: Localize
                    end
                end
            end

            tooltip:Show()
        end
    end)
end

Addon.OnEvent = function(event, ...)
    if string.find(event, "UNIT_") then
        local unitTarget = select(1, ...)
        if unitTarget == "player" then
            Addon.Database:UpdateCharacterStats()
        end
    else
        Addon.Database:UpdateCharacterStats()
    end
end
