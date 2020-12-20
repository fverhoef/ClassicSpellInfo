local AddonName, AddonTable = ...
local Addon = AddonTable[1]

local Database = {
    Class = select(2, UnitClass("player")),
    Types = {None = 0, Magic = 1, MagicDamage = 2, PhysicalDamage = 3, Heal = 4, Absorb = 5},
    Schools = {Physical = 0, Arcane = 1, Fire = 2, Frost = 3, Holy = 4, Shadow = 5, Nature = 6},
    AbsorbTypes = {Physical = 0, Arcane = 1, Fire = 2, Frost = 3, Holy = 4, Shadow = 5, Nature = 6, All = 7, Magic = 8},
    TotemElements = {Fire = 1, Earth = 2, Water = 3, Air = 4},
    Tags = {None = 0, Totem = 7, Lightning = 11, Shock = 12, Destruction = 13},
    SpellsById = {},
    SpellMinMaxPatterns = {
        {
            pattern = "causing (%d+) to (%d+) Fire damage to himself and (%d+) to (%d+) Fire damage", -- Hellfire
            type = {"min", "max", "min", "max"}
        },
        {
            pattern = "causing (%d+) Fire damage to himself and (%d+) Fire damage", -- Hellfire
            type = {"total", "total"}
        },
        {
            pattern = "(%d+) Arcane damage each second for 5 sec", -- Arcane Missiles
            type = {"dotTick"}
        },
        {
            pattern = "will be struck for (%d+) Nature damage.", -- Lightning Shield
            type = {"total"}
        },
        {
            pattern = "and causing (%d+) Nature damage", -- Insect Swarm
            type = {"total"}
        },
        {
            pattern = "horror for 3 sec and causes (%d+) Shadow damage", -- Death Coil
            type = {"total"}
        },
        {
            pattern = "(%d+) to (%d+)(.+)and another (%d+) to (%d+)", -- Generic Hybrid spell
            type = {"min", "max", "temp", "dotMin", "dotMax"}
        },
        {
            pattern = "(%d+) to (%d+)(.+)and another (%d+)", -- Generic Hybrid spell
            type = {"min", "max", "temp", "dotTotal"}
        },
        {
            pattern = "(%d+)(.+)and another (%d+) to (%d+)", -- Generic Hybrid spell
            type = {"total", "temp", "dotMin", "dotMax"}
        },
        {
            pattern = "(%d+)(.+)and another (%d+)", -- Generic Hybrid spell
            type = {"total", "temp", "dotTotal"}
        },
        {
            pattern = "(%d+) to (%d+)(.+)an additional (%d+) to (%d+)", -- Generic Hybrid spell
            type = {"min", "max", "temp", "dotMin", "dotMax"}
        },
        {
            pattern = "(%d+) to (%d+)(.+)an additional (%d+)", -- Generic Hybrid spell
            type = {"min", "max", "temp", "dotTotal"}
        },
        {
            pattern = "(%d+)(.+)an additional (%d+) to (%d+)", -- Generic Hybrid spell
            type = {"total", "temp", "dotMin", "dotMax"}
        },
        {
            pattern = "(%d+)(.+)an additional (%d+)", -- Generic Hybrid spell
            type = {"total", "temp", "dotTotal"}
        },
        {
            pattern = "(%d+) to (%d+)(.+) and (%d+) to (%d+)", -- Flame Shock
            type = {"min", "max", "temp", "dotMin", "dotMax"}
        },
        {
            pattern = "(%d+) to (%d+)(.+) and (%d+)", -- Flame Shock
            type = {"min", "max", "temp", "dotTotal"}
        },
        {
            pattern = "causing (%d+)(.+) and (%d+) to (%d+)", -- Flame Shock
            type = {"total", "temp", "dotMin", "dotMax"}
        },
        {
            pattern = "causing (%d+)(.+) and (%d+)", -- Flame Shock
            type = {"total", "temp", "dotTotal"}
        },
        {
            pattern = "(%d+) to (%d+) Fire damage.", -- Magma totem
            type = {"min", "max"}
        },
        {
            pattern = "(%d+) Fire damage.", -- Magma totem
            type = {"total"}
        },
        {
            pattern = "yards for (%d+) to (%d+) every ", -- Healing Stream totem
            type = {"dotMin", "dotMax"}
        },
        {
            pattern = "yards for (%d+) every ", -- Healing Stream totem
            type = {"dotTotal"}
        },
        {
            pattern = "(%d+) to (%d+)", -- Generic Normal spell
            type = {"min", "max"}
        },
        {
            pattern = "(%d+)", -- Generic no damage range spell
            type = {"total"}
        }
    },
    TotemIdsByName = {}
}
Database.Spells = {
    ["MAGE"] = {
        ["Fireball"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Fire,
            modifier = 1,
            ignoreDot = true,
            ticks = 4,
            tickInterval = 2,
            ranks = {
                {id = 133, level = 1, castTime = 2, ticks = 2},
                {id = 143, level = 6, castTime = 2, ticks = 3},
                {id = 145, level = 12, castTime = 2.5, ticks = 3},
                {id = 3140, level = 18, castTime = 3},
                {id = 8400, level = 24, castTime = 3.5},
                {id = 8401, level = 30, castTime = 3.5},
                {id = 8402, level = 36, castTime = 3.5},
                {id = 10148, level = 42, castTime = 3.5},
                {id = 10149, level = 48, castTime = 3.5},
                {id = 10150, level = 54, castTime = 3.5},
                {id = 10151, level = 60, castTime = 3.5},
                {id = 25306, level = 60, castTime = 3.5}
            }
        },
        ["Scorch"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Fire,
            modifier = 1,
            ranks = {
                {id = 2948, level = 22, castTime = 1.5},
                {id = 8444, level = 28, castTime = 1.5},
                {id = 8445, level = 34, castTime = 1.5},
                {id = 8446, level = 40, castTime = 1.5},
                {id = 10205, level = 46, castTime = 1.5},
                {id = 10206, level = 52, castTime = 1.5},
                {id = 10207, level = 58, castTime = 1.5}
            }
        },
        ["Fire Blast"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Fire,
            modifier = 1,
            ranks = {
                {id = 2136, level = 6, castTime = 0},
                {id = 2137, level = 14, castTime = 0},
                {id = 2138, level = 22, castTime = 0},
                {id = 8412, level = 30, castTime = 0},
                {id = 8413, level = 38, castTime = 0},
                {id = 10197, level = 46, castTime = 0},
                {id = 10199, level = 54, castTime = 0}
            }
        },
        ["Flamestrike"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Fire,
            aoe = true,
            modifier = 0.7,
            dotModifier = 0.3,
            ticks = 4,
            tickInterval = 2,
            ranks = {
                {id = 2120, level = 16, castTime = 3},
                {id = 2121, level = 24, castTime = 3},
                {id = 8422, level = 32, castTime = 3},
                {id = 8423, level = 40, castTime = 3},
                {id = 10215, level = 48, castTime = 3},
                {id = 10216, level = 56, castTime = 3}
            }
        },
        ["Pyroblast"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Fire,
            modifier = 1,
            coefficient = 1,
            dotCoefficient = 0.7,
            ticks = 4,
            tickInterval = 3,
            ranks = {
                {id = 11366, level = 24, castTime = 6},
                {id = 12505, level = 24, castTime = 6},
                {id = 12522, level = 30, castTime = 6},
                {id = 12523, level = 36, castTime = 6},
                {id = 12524, level = 42, castTime = 6},
                {id = 12525, level = 48, castTime = 6},
                {id = 12526, level = 54, castTime = 6},
                {id = 18809, level = 60, castTime = 6}
            }
        },
        ["Blast Wave"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Fire,
            aoe = true,
            modifier = 0.895,
            ranks = {
                {id = 11113, level = 30, castTime = 0},
                {id = 13018, level = 36, castTime = 0},
                {id = 13019, level = 44, castTime = 0},
                {id = 13020, level = 52, castTime = 0},
                {id = 13021, level = 60, castTime = 0}
            }
        },
        ["Frostbolt"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Frost,
            modifier = 0.95,
            ranks = {
                {id = 116, level = 4, castTime = 1.5},
                {id = 205, level = 8, castTime = 1.8},
                {id = 837, level = 14, castTime = 2.2},
                {id = 7322, level = 20, castTime = 2.6},
                {id = 8406, level = 26, castTime = 3},
                {id = 8407, level = 32, castTime = 3},
                {id = 8408, level = 38, castTime = 3},
                {id = 10179, level = 44, castTime = 3},
                {id = 10180, level = 50, castTime = 3},
                {id = 10181, level = 56, castTime = 3},
                {id = 25304, level = 60, castTime = 3}
            }
        },
        ["Frost Nova"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Frost,
            aoe = true,
            modifier = 0.2,
            ranks = {{id = 122, level = 10, castTime = 0}, {id = 865, level = 26, castTime = 0}, {id = 6131, level = 40, castTime = 0}, {id = 10230, level = 54, castTime = 0}}
        },
        ["Cone of Cold"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Frost,
            aoe = true,
            modifier = 0.895,
            ranks = {
                {id = 120, level = 26, castTime = 0},
                {id = 8492, level = 34, castTime = 0},
                {id = 10159, level = 42, castTime = 0},
                {id = 10160, level = 50, castTime = 0},
                {id = 10161, level = 58, castTime = 0}
            }
        },
        ["Blizzard"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Frost,
            aoe = true,
            channelled = true,
            modifier = 1,
            ticks = 8,
            tickInterval = 1,
            ranks = {
                {id = 10, level = 20, castTime = 8},
                {id = 6141, level = 28, castTime = 8},
                {id = 8427, level = 36, castTime = 8},
                {id = 10185, level = 44, castTime = 8},
                {id = 10186, level = 52, castTime = 8},
                {id = 10187, level = 60, castTime = 8}
            }
        },
        ["Arcane Explosion"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Arcane,
            aoe = true,
            modifier = 1,
            ranks = {
                {id = 1449, level = 14, castTime = 0},
                {id = 8437, level = 22, castTime = 0},
                {id = 8438, level = 30, castTime = 0},
                {id = 8439, level = 38, castTime = 0},
                {id = 10201, level = 46, castTime = 0},
                {id = 10202, level = 54, castTime = 0}
            }
        },
        ["Arcane Missiles"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Arcane,
            channelled = true,
            modifier = 1,
            ticks = 5,
            tickInterval = 1,
            showTickDamage = true,
            ranks = {
                {id = 5143, level = 8, castTime = 3, ticks = 3},
                {id = 5144, level = 16, castTime = 4, ticks = 4},
                {id = 5145, level = 24, castTime = 5},
                {id = 8416, level = 32, castTime = 5},
                {id = 8417, level = 40, castTime = 5},
                {id = 10211, level = 48, castTime = 5},
                {id = 10212, level = 56, castTime = 5},
                {id = 25345, level = 60, castTime = 5}
            }
        },

        -- Portals
        ["Portal: Stormwind"] = {type = Database.Types.Magic, school = Database.Schools.Arcane, faction = "Alliance", ranks = {{id = 10059, level = 40, castTime = 10}}},
        ["Portal: Ironforge"] = {type = Database.Types.Magic, school = Database.Schools.Arcane, faction = "Alliance", ranks = {{id = 11416, level = 40, castTime = 10}}},
        ["Portal: Darnassus"] = {type = Database.Types.Magic, school = Database.Schools.Arcane, faction = "Alliance", ranks = {{id = 11419, level = 50, castTime = 10}}},
        ["Portal: Orgrimmar"] = {type = Database.Types.Magic, school = Database.Schools.Arcane, faction = "Horde", ranks = {{id = 11417, level = 40, castTime = 10}}},
        ["Portal: Undercity"] = {type = Database.Types.Magic, school = Database.Schools.Arcane, faction = "Horde", ranks = {{id = 11418, level = 40, castTime = 10}}},
        ["Portal: Thunder Bluff"] = {type = Database.Types.Magic, school = Database.Schools.Arcane, faction = "Horde", ranks = {{id = 11420, level = 50, castTime = 10}}},

        -- Teleports
        ["Teleport: Stormwind"] = {type = Database.Types.Magic, school = Database.Schools.Arcane, faction = "Alliance", ranks = {{id = 3561, level = 20, castTime = 10}}},
        ["Teleport: Ironforge"] = {type = Database.Types.Magic, school = Database.Schools.Arcane, faction = "Alliance", ranks = {{id = 3562, level = 20, castTime = 10}}},
        ["Teleport: Darnassus"] = {type = Database.Types.Magic, school = Database.Schools.Arcane, faction = "Alliance", ranks = {{id = 3565, level = 30, castTime = 10}}},
        ["Teleport: Orgrimmar"] = {type = Database.Types.Magic, school = Database.Schools.Arcane, faction = "Horde", ranks = {{id = 3567, level = 20, castTime = 10}}},
        ["Teleport: Undercity"] = {type = Database.Types.Magic, school = Database.Schools.Arcane, faction = "Horde", ranks = {{id = 3563, level = 20, castTime = 10}}},
        ["Teleport: Thunder Bluff"] = {type = Database.Types.Magic, school = Database.Schools.Arcane, faction = "Horde", ranks = {{id = 3566, level = 30, castTime = 10}}},

        -- Conjuring
        ["Conjure Food"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Arcane,
            ranks = {
                {id = 587, level = 6, castTime = 3},
                {id = 597, level = 12, castTime = 3},
                {id = 990, level = 22, castTime = 3},
                {id = 6129, level = 32, castTime = 3},
                {id = 10144, level = 42, castTime = 3},
                {id = 10145, level = 52, castTime = 3},
                {id = 28612, level = 60, castTime = 3}
            }
        },
        ["Conjure Water"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Arcane,
            ranks = {
                {id = 5504, level = 4, castTime = 3},
                {id = 5505, level = 10, castTime = 3},
                {id = 5506, level = 20, castTime = 3},
                {id = 6127, level = 30, castTime = 3},
                {id = 10138, level = 40, castTime = 3},
                {id = 10139, level = 50, castTime = 3},
                {id = 10140, level = 60, castTime = 3}
            }
        },
        ["Conjure Gem"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Arcane,
            ranks = {{id = 759, level = 28, castTime = 3}, {id = 3552, level = 38, castTime = 3}, {id = 10053, level = 48, castTime = 3}, {id = 10054, level = 58, castTime = 3}}
        },

        -- Polymorph
        ["Polymorph"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Arcane,
            ranks = {
                {id = 118, level = 8, castTime = 1.5},
                {id = 12824, level = 20, castTime = 1.5},
                {id = 12825, level = 40, castTime = 1.5},
                {id = 12826, level = 60, castTime = 1.5},
                {id = 28271, level = 60, castTime = 1.5},
                {id = 28272, level = 60, castTime = 1.5}
            }
        },

        -- Shields
        ["Fire Ward"] = {
            type = Database.Types.Absorb,
            school = Database.Schools.Fire,
            coefficient = 0,
            ranks = {
                {id = 543, level = 20, castTime = 0, baseAbsorb = 165},
                {id = 8457, level = 30, castTime = 0, baseAbsorb = 290},
                {id = 8458, level = 40, castTime = 0, baseAbsorb = 470},
                {id = 10223, level = 50, castTime = 0, baseAbsorb = 675},
                {id = 10225, level = 60, castTime = 0, baseAbsorb = 920}
            }
        },
        ["Frost Ward"] = {
            type = Database.Types.Absorb,
            school = Database.Schools.Frost,
            coefficient = 0,
            ranks = {
                {id = 6143, level = 22, castTime = 0, baseAbsorb = 165},
                {id = 8461, level = 32, castTime = 0, baseAbsorb = 290},
                {id = 8462, level = 42, castTime = 0, baseAbsorb = 470},
                {id = 10177, level = 52, castTime = 0, baseAbsorb = 675},
                {id = 28609, level = 60, castTime = 0, baseAbsorb = 920}
            }
        },
        ["Ice Barrier"] = {
            type = Database.Types.Absorb,
            school = Database.Schools.Frost,
            coefficient = 0.1,
            ranks = {
                {id = 11426, level = 40, castTime = 0, baseAbsorb = 438, absorbPerLevel = 2.8, maxLevel = 46},
                {id = 13031, level = 46, castTime = 0, baseAbsorb = 549, absorbPerLevel = 3.2, maxLevel = 52},
                {id = 13032, level = 52, castTime = 0, baseAbsorb = 678, absorbPerLevel = 3.6, maxLevel = 58},
                {id = 13033, level = 58, castTime = 0, baseAbsorb = 818, absorbPerLevel = 4, maxLevel = 60}
            }
        },
        ["Mana Shield"] = {
            type = Database.Types.Absorb,
            school = Database.Schools.Arcane,
            coefficient = 0,
            ranks = {
                {id = 1463, level = 20, castTime = 0, baseAbsorb = 120},
                {id = 8494, level = 28, castTime = 0, baseAbsorb = 210},
                {id = 8495, level = 36, castTime = 0, baseAbsorb = 300},
                {id = 10191, level = 44, castTime = 0, baseAbsorb = 390},
                {id = 10192, level = 52, castTime = 0, baseAbsorb = 480},
                {id = 10193, level = 60, castTime = 0, baseAbsorb = 570}
            }
        }
    },
    ["PRIEST"] = {
        -- Shields
        ["Power Word: Shield"] = {
            type = Database.Types.Absorb,
            school = Database.Schools.Holy,
            coefficient = 0.1,
            ranks = {
                {id = 17, level = 6, castTime = 0, baseAbsorb = 44, absorbPerLevel = 0.8, maxLevel = 11},
                {id = 592, level = 12, castTime = 0, baseAbsorb = 88, absorbPerLevel = 1.2, maxLevel = 17},
                {id = 600, level = 18, castTime = 0, baseAbsorb = 158, absorbPerLevel = 1.6, maxLevel = 23},
                {id = 3747, level = 24, castTime = 0, baseAbsorb = 234, absorbPerLevel = 2, maxLevel = 29},
                {id = 6065, level = 30, castTime = 0, baseAbsorb = 301, absorbPerLevel = 2.3, maxLevel = 35},
                {id = 6066, level = 36, castTime = 0, baseAbsorb = 381, absorbPerLevel = 2.6, maxLevel = 41},
                {id = 10898, level = 42, castTime = 0, baseAbsorb = 484, absorbPerLevel = 3, maxLevel = 47},
                {id = 10899, level = 48, castTime = 0, baseAbsorb = 605, absorbPerLevel = 3.4, maxLevel = 53},
                {id = 10900, level = 54, castTime = 0, baseAbsorb = 763, absorbPerLevel = 3.9, maxLevel = 59},
                {id = 10901, level = 60, castTime = 0, baseAbsorb = 942, absorbPerLevel = 4.3, maxLevel = 60}
            }
        }
    },
    ["SHAMAN"] = {
        -- Heals
        ["Healing Wave"] = {
            type = Database.Types.Heal,
            school = Database.Schools.Nature,
            ranks = {
                {id = 331, level = 1, castTime = 1.5},
                {id = 332, level = 6, castTime = 2},
                {id = 547, level = 12, castTime = 2.5},
                {id = 913, level = 18, castTime = 3},
                {id = 939, level = 24, castTime = 3},
                {id = 959, level = 32, castTime = 3},
                {id = 8005, level = 40, castTime = 3},
                {id = 10395, level = 48, castTime = 3},
                {id = 10396, level = 56, castTime = 3},
                {id = 25357, level = 60, castTime = 3}
            }
        },
        ["Lesser Healing Wave"] = {
            type = Database.Types.Heal,
            school = Database.Schools.Nature,
            ranks = {
                {id = 8004, level = 20, castTime = 1.5},
                {id = 8008, level = 28, castTime = 1.5},
                {id = 8010, level = 36, castTime = 1.5},
                {id = 10466, level = 44, castTime = 1.5},
                {id = 10467, level = 52, castTime = 1.5},
                {id = 10468, level = 60, castTime = 1.5}
            }
        },
        ["Chain Heal"] = {
            type = Database.Types.Heal,
            school = Database.Schools.Nature,
            ranks = {{id = 1064, level = 40, castTime = 2.5}, {id = 10622, level = 46, castTime = 2.5}, {id = 10623, level = 54, castTime = 2.5}}
        },

        -- Damage Spells
        ["Chain Lightning"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Nature,
            tag = Database.Tags.Lightning,
            ranks = {
                {id = 421, level = 32, castTime = 2.5},
                {id = 930, level = 40, castTime = 2.5},
                {id = 2860, level = 48, castTime = 2.5},
                {id = 10605, level = 56, castTime = 2.5}
            }
        },
        ["Lightning Bolt"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Nature,
            tag = Database.Tags.Lightning,
            ranks = {
                {id = 403, level = 1, castTime = 1.5},
                {id = 529, level = 8, castTime = 2},
                {id = 548, level = 14, castTime = 2.5},
                {id = 915, level = 20, castTime = 3},
                {id = 943, level = 26, castTime = 3},
                {id = 6041, level = 32, castTime = 3},
                {id = 10391, level = 38, castTime = 3},
                {id = 10392, level = 44, castTime = 3},
                {id = 15207, level = 50, castTime = 3},
                {id = 15208, level = 56, castTime = 3}
            }
        },
        ["Earth Shock"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Nature,
            tag = Database.Tags.Shock,
            coefficient = (1.5 / 3.5) * 0.95,
            ranks = {
                {id = 8042, level = 4, castTime = 1.5},
                {id = 8044, level = 8, castTime = 1.5},
                {id = 8045, level = 14, castTime = 1.5},
                {id = 8046, level = 24, castTime = 1.5},
                {id = 10412, level = 36, castTime = 1.5},
                {id = 10413, level = 48, castTime = 1.5},
                {id = 10414, level = 60, castTime = 1.5}
            }
        },
        ["Frost Shock"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Frost,
            tag = Database.Tags.Shock,
            coefficient = (1.5 / 3.5) * 0.95,
            ranks = {
                {id = 8056, level = 20, castTime = 1.5},
                {id = 8058, level = 34, castTime = 1.5},
                {id = 10472, level = 46, castTime = 1.5},
                {id = 10473, level = 58, castTime = 1.5}
            }
        },
        ["Flame Shock"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Fire,
            tag = Database.Tags.Shock,
            coefficient = 0.214,
            dotCoefficient = 0.5209,
            ticks = 4,
            tickInterval = 3,
            ranks = {
                {id = 8050, level = 10, castTime = 1.5},
                {id = 8052, level = 18, castTime = 1.5},
                {id = 8053, level = 28, castTime = 1.5},
                {id = 10447, level = 40, castTime = 1.5},
                {id = 10448, level = 52, castTime = 1.5},
                {id = 29228, level = 60, castTime = 1.5}
            }
        },
        ["Lightning Shield"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Nature,
            coefficient = 0.267,
            ranks = {
                {id = 324, level = 8, castTime = 1.5},
                {id = 325, level = 16, castTime = 1.5},
                {id = 905, level = 24, castTime = 1.5},
                {id = 945, level = 32, castTime = 1.5},
                {id = 8134, level = 40, castTime = 1.5},
                {id = 10431, level = 48, castTime = 1.5},
                {id = 10432, level = 56, castTime = 1.5}
            }
        },

        -- Fire Totems
        ["Fire Nova Totem"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Fire,
            element = Database.TotemElements.Fire,
            tag = Database.Tags.Totem,
            aoe = true,
            coefficient = 0.15,
            ranks = {
                {id = 1535, level = 12, castTime = 1.5},
                {id = 8498, level = 22, castTime = 1.5},
                {id = 8499, level = 32, castTime = 1.5},
                {id = 11314, level = 42, castTime = 1.5},
                {id = 11315, level = 52, castTime = 1.5}
            }
        },
        ["Magma Totem"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Fire,
            element = Database.TotemElements.Fire,
            tag = Database.Tags.Totem,
            aoe = true,
            dotCoefficient = 0.32,
            ticks = 10,
            tickInterval = 2,
            ranks = {
                {id = 8190, level = 26, castTime = 1.5},
                {id = 10585, level = 36, castTime = 1.5},
                {id = 10586, level = 46, castTime = 1.5},
                {id = 10587, level = 56, castTime = 1.5}
            }
        },
        ["Searing Totem"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Fire,
            element = Database.TotemElements.Fire,
            tag = Database.Tags.Totem,
            coefficient = 0.08,
            ranks = {
                {id = 3599, level = 10, castTime = 1.5},
                {id = 6363, level = 20, castTime = 1.5},
                {id = 6364, level = 30, castTime = 1.5},
                {id = 6365, level = 40, castTime = 1.5},
                {id = 10437, level = 50, castTime = 1.5},
                {id = 10438, level = 60, castTime = 1.5}
            }
        },
        ["Flametongue Totem"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Fire,
            element = Database.TotemElements.Fire,
            tag = Database.Tags.Totem,
            ranks = {
                {id = 8227, level = 28, castTime = 1.5},
                {id = 8249, level = 38, castTime = 1.5},
                {id = 10526, level = 48, castTime = 1.5},
                {id = 16387, level = 58, castTime = 1.5}
            }
        },
        ["Frost Resistance Totem"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Fire,
            element = Database.TotemElements.Fire,
            tag = Database.Tags.Totem,
            ranks = {{id = 8181, level = 24, castTime = 1.5}, {id = 10478, level = 38, castTime = 1.5}, {id = 10479, level = 54, castTime = 1.5}}
        },

        -- Earth Totems
        ["Earthbind Totem"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Nature,
            element = Database.TotemElements.Earth,
            tag = Database.Tags.Totem,
            ranks = {{id = 2484, level = 6, castTime = 1.5}}
        },
        ["Stoneclaw Totem"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Nature,
            element = Database.TotemElements.Earth,
            tag = Database.Tags.Totem,
            ranks = {
                {id = 5730, level = 8, castTime = 1.5},
                {id = 6390, level = 18, castTime = 1.5},
                {id = 6391, level = 28, castTime = 1.5},
                {id = 6392, level = 38, castTime = 1.5},
                {id = 10427, level = 48, castTime = 1.5},
                {id = 10428, level = 58, castTime = 1.5}
            }
        },
        ["Stoneskin Totem"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Nature,
            element = Database.TotemElements.Earth,
            tag = Database.Tags.Totem,
            ranks = {
                {id = 8071, level = 4, castTime = 1.5},
                {id = 8154, level = 14, castTime = 1.5},
                {id = 8155, level = 24, castTime = 1.5},
                {id = 10406, level = 34, castTime = 1.5},
                {id = 10407, level = 44, castTime = 1.5},
                {id = 10408, level = 54, castTime = 1.5}
            }
        },
        ["Strength of Earth Totem"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Nature,
            element = Database.TotemElements.Earth,
            tag = Database.Tags.Totem,
            ranks = {
                {id = 8075, level = 10, castTime = 1.5},
                {id = 8160, level = 24, castTime = 1.5},
                {id = 8161, level = 38, castTime = 1.5},
                {id = 10442, level = 52, castTime = 1.5},
                {id = 25361, level = 60, castTime = 1.5}
            }
        },
        ["Tremor Totem"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Nature,
            element = Database.TotemElements.Earth,
            tag = Database.Tags.Totem,
            ranks = {{id = 8143, level = 18, castTime = 1.5}}
        },

        -- Water Totems
        ["Poison Cleansing Totem"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Nature,
            element = Database.TotemElements.Water,
            tag = Database.Tags.Totem,
            ranks = {{id = 8166, level = 22, castTime = 1.5}}
        },
        ["Disease Cleansing Totem"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Nature,
            element = Database.TotemElements.Water,
            tag = Database.Tags.Totem,
            ranks = {{id = 8170, level = 38, castTime = 1.5}}
        },
        ["Fire Resistance Totem"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Nature,
            element = Database.TotemElements.Water,
            tag = Database.Tags.Totem,
            ranks = {{id = 8184, level = 28, castTime = 1.5}, {id = 10537, level = 42, castTime = 1.5}, {id = 10538, level = 58, castTime = 1.5}}
        },
        ["Healing Stream Totem"] = {
            type = Database.Types.Heal,
            school = Database.Schools.Nature,
            element = Database.TotemElements.Water,
            tag = Database.Tags.Totem,
            ticks = 30,
            tickInterval = 2,
            dotCoefficient = 0.65,
            ranks = {
                {id = 5394, level = 20, castTime = 1.5},
                {id = 6375, level = 30, castTime = 1.5},
                {id = 6377, level = 40, castTime = 1.5},
                {id = 10462, level = 50, castTime = 1.5},
                {id = 10463, level = 60, castTime = 1.5}
            }
        },
        ["Mana Spring Totem"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Nature,
            element = Database.TotemElements.Water,
            tag = Database.Tags.Totem,
            ranks = {
                {id = 5675, level = 26, castTime = 1.5},
                {id = 10495, level = 36, castTime = 1.5},
                {id = 10496, level = 46, castTime = 1.5},
                {id = 10497, level = 56, castTime = 1.5}
            }
        },
        ["Mana Tide Totem"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Nature,
            element = Database.TotemElements.Water,
            tag = Database.Tags.Totem,
            ranks = {{id = 16190, level = 40, castTime = 1.5}, {id = 17354, level = 48, castTime = 1.5}, {id = 17359, level = 58, castTime = 1.5}}
        },

        -- Air Totems
        ["Grace of Air Totem"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Nature,
            element = Database.TotemElements.Air,
            tag = Database.Tags.Totem,
            ranks = {{id = 8835, level = 42, castTime = 1.5}, {id = 10627, level = 56, castTime = 1.5}, {id = 25359, level = 60, castTime = 1.5}}
        },
        ["Grounding Totem"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Nature,
            element = Database.TotemElements.Air,
            tag = Database.Tags.Totem,
            ranks = {{id = 8177, level = 30, castTime = 1.5}}
        },
        ["Nature Resistance Totem"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Nature,
            element = Database.TotemElements.Air,
            tag = Database.Tags.Totem,
            ranks = {{id = 10595, level = 30, castTime = 1.5}, {id = 10600, level = 44, castTime = 1.5}, {id = 10601, level = 60, castTime = 1.5}}
        },
        ["Sentry Totem"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Nature,
            element = Database.TotemElements.Air,
            tag = Database.Tags.Totem,
            ranks = {{id = 6495, level = 34, castTime = 1.5}}
        },
        ["Tranquil Air Totem"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Nature,
            element = Database.TotemElements.Air,
            tag = Database.Tags.Totem,
            ranks = {{id = 25908, level = 50, castTime = 1.5}}
        },
        ["Windfury Totem"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Nature,
            element = Database.TotemElements.Air,
            tag = Database.Tags.Totem,
            ranks = {{id = 8512, level = 32, castTime = 1.5}, {id = 10613, level = 42, castTime = 1.5}, {id = 10614, level = 52, castTime = 1.5}}
        },
        ["Windwall Totem"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Nature,
            element = Database.TotemElements.Air,
            tag = Database.Tags.Totem,
            ranks = {{id = 15107, level = 36, castTime = 1.5}, {id = 15111, level = 46, castTime = 1.5}, {id = 15112, level = 56, castTime = 1.5}}
        },

        -- Weapon Enchants
        ["Rockbiter Weapon"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Nature,
            ranks = {
                {id = 8017, level = 1, castTime = 1.5},
                {id = 8018, level = 8, castTime = 1.5},
                {id = 8019, level = 16, castTime = 1.5},
                {id = 10399, level = 24, castTime = 1.5},
                {id = 16314, level = 34, castTime = 1.5},
                {id = 16315, level = 44, castTime = 1.5},
                {id = 16316, level = 54, castTime = 1.5}
            }
        },
        ["Flametongue Weapon"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Fire,
            ranks = {
                {id = 8024, level = 10, castTime = 1.5},
                {id = 8027, level = 18, castTime = 1.5},
                {id = 8030, level = 26, castTime = 1.5},
                {id = 16339, level = 36, castTime = 1.5},
                {id = 16341, level = 46, castTime = 1.5},
                {id = 16342, level = 56, castTime = 1.5}
            }
        },
        ["Frostbrand Weapon"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Frost,
            ranks = {
                {id = 8033, level = 20, castTime = 1.5},
                {id = 8038, level = 28, castTime = 1.5},
                {id = 10456, level = 38, castTime = 1.5},
                {id = 16355, level = 48, castTime = 1.5},
                {id = 16356, level = 58, castTime = 1.5}
            }
        },
        ["Windfury Weapon"] = {
            type = Database.Types.Magic,
            school = Database.Schools.Air,
            ranks = {
                {id = 8232, level = 30, castTime = 1.5},
                {id = 8235, level = 40, castTime = 1.5},
                {id = 10486, level = 50, castTime = 1.5},
                {id = 16362, level = 60, castTime = 1.5}
            }
        }
    },
    ["WARLOCK"] = {
        -- Shadow
        ["Shadow Bolt"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Shadow,
            tag = Database.Tags.Destruction,
            ranks = {
                {id = 686, level = 1, castTime = 1.7},
                {id = 695, level = 6, castTime = 2.2},
                {id = 705, level = 12, castTime = 2.8},
                {id = 1088, level = 20, castTime = 3},
                {id = 1106, level = 28, castTime = 3},
                {id = 7641, level = 36, castTime = 3},
                {id = 11659, level = 44, castTime = 3},
                {id = 11660, level = 52, castTime = 3},
                {id = 11661, level = 60, castTime = 3},
                {id = 25307, level = 60, castTime = 3}
            }
        },
        ["Death Coil"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Shadow,
            coefficient = 1.5 / 3.5 / 2,
            ranks = {{id = 6789, level = 42, castTime = 1.5}, {id = 17925, level = 50, castTime = 1.5}, {id = 17926, level = 58, castTime = 1.5}}
        },
        ["Shadowburn"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Shadow,
            ranks = {
                {id = 17877, level = 20, castTime = 1.5},
                {id = 18867, level = 24, castTime = 1.5},
                {id = 18868, level = 32, castTime = 1.5},
                {id = 18869, level = 40, castTime = 1.5},
                {id = 18870, level = 48, castTime = 1.5},
                {id = 18871, level = 56, castTime = 1.5}
            }
        },
        ["Corruption"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Shadow,
            ticks = 6,
            tickInterval = 3,
            ranks = {
                {id = 172, level = 4, castTime = 2, ticks = 4},
                {id = 6222, level = 14, castTime = 2, ticks = 5},
                {id = 6223, level = 24, castTime = 2},
                {id = 7648, level = 34, castTime = 2},
                {id = 11671, level = 44, castTime = 2},
                {id = 11672, level = 54, castTime = 2},
                {id = 25311, level = 60, castTime = 2}
            }
        },
        ["Curse of Agony"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Shadow,
            ticks = 12,
            tickInterval = 2,
            ranks = {
                {id = 980, level = 8, castTime = 1.5},
                {id = 1014, level = 18, castTime = 1.5},
                {id = 6217, level = 28, castTime = 1.5},
                {id = 11711, level = 38, castTime = 1.5},
                {id = 11712, level = 48, castTime = 1.5},
                {id = 11713, level = 58, castTime = 1.5}
            }
        },
        ["Curse of Doom"] = {type = Database.Types.MagicDamage, school = Database.Schools.Shadow, ranks = {{id = 603, level = 60, castTime = 1.5}}},
        ["Drain Life"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Shadow,
            coefficient = 1,
            ticks = 5,
            tickInterval = 1,
            ranks = {
                {id = 689, level = 14, castTime = 5},
                {id = 699, level = 22, castTime = 5},
                {id = 709, level = 30, castTime = 5},
                {id = 7651, level = 38, castTime = 5},
                {id = 11699, level = 46, castTime = 5},
                {id = 11700, level = 54, castTime = 5}
            }
        },
        ["Drain Soul"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Shadow,
            coefficient = 1,
            ticks = 5,
            tickInterval = 3,
            ranks = {
                {id = 1120, level = 10, castTime = 15},
                {id = 8288, level = 24, castTime = 15},
                {id = 8289, level = 38, castTime = 15},
                {id = 11675, level = 52, castTime = 15}
            }
        },
        ["Siphon Life"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Shadow,
            coefficient = 1,
            ticks = 10,
            tickInterval = 3,
            ranks = {
                {id = 18265, level = 30, castTime = 1.5},
                {id = 18879, level = 38, castTime = 1.5},
                {id = 18880, level = 48, castTime = 1.5},
                {id = 18881, level = 58, castTime = 1.5}
            }
        },

        -- Fire
        ["Immolate"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Fire,
            coefficient = 0.13,
            dotCoefficient = 0.2,
            ticks = 5,
            tickInterval = 3,
            ranks = {
                {id = 11366, level = 1, castTime = 2},
                {id = 12505, level = 10, castTime = 2},
                {id = 12522, level = 20, castTime = 2},
                {id = 12523, level = 30, castTime = 2},
                {id = 12524, level = 40, castTime = 2},
                {id = 12525, level = 50, castTime = 2},
                {id = 12526, level = 60, castTime = 2},
                {id = 25309, level = 60, castTime = 2}
            }
        },
        ["Conflagrate"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Fire,
            ranks = {
                {id = 17962, level = 40, castTime = 1.5},
                {id = 18930, level = 48, castTime = 1.5},
                {id = 18931, level = 54, castTime = 1.5},
                {id = 18932, level = 60, castTime = 1.5}
            }
        },
        ["Searing Pain"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Fire,
            ranks = {
                {id = 5676, level = 18, castTime = 1.5},
                {id = 17919, level = 26, castTime = 1.5},
                {id = 17920, level = 34, castTime = 1.5},
                {id = 17921, level = 42, castTime = 1.5},
                {id = 17922, level = 50, castTime = 1.5},
                {id = 17923, level = 58, castTime = 1.5}
            }
        },
        ["Soul Fire"] = {type = Database.Types.MagicDamage, school = Database.Schools.Fire, ranks = {{id = 6353, level = 48, castTime = 6}, {id = 17924, level = 56, castTime = 6}}},
        ["Rain of Fire"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Fire,
            aoe = true,
            channelled = true,
            modifier = 1,
            ticks = 8,
            tickInterval = 1,
            ranks = {{id = 5740, level = 20, castTime = 8}, {id = 6219, level = 34, castTime = 8}, {id = 11677, level = 46, castTime = 8}, {id = 11678, level = 58, castTime = 8}}
        },
        ["Hellfire"] = {
            type = Database.Types.MagicDamage,
            school = Database.Schools.Fire,
            aoe = true,
            channelled = true,
            modifier = 1,
            ticks = 15,
            tickInterval = 1,
            ranks = {{id = 1949, level = 30, castTime = 8}, {id = 11683, level = 42, castTime = 8}, {id = 11684, level = 54, castTime = 8}}
        },

        -- Shields
        ["Shadow Ward"] = {
            type = Database.Types.Absorb,
            school = Database.Schools.Shadow,
            coefficient = 0,
            ranks = {
                {id = 6229, level = 32, castTime = 0, baseAbsorb = 290},
                {id = 11739, level = 42, castTime = 0, baseAbsorb = 470},
                {id = 11740, level = 52, castTime = 0, baseAbsorb = 675},
                {id = 28610, level = 60, castTime = 0, baseAbsorb = 920}
            }
        },
        ["Sacrifice"] = {
            type = Database.Types.Absorb,
            school = Database.Schools.Shadow,
            coefficient = 0,
            ranks = {
                {id = 7812, level = 16, castTime = 0, baseAbsorb = 305, absorbPerLevel = 2.3, maxLevel = 22},
                {id = 19438, level = 24, castTime = 0, baseAbsorb = 510, absorbPerLevel = 3.1, maxLevel = 30},
                {id = 19440, level = 32, castTime = 0, baseAbsorb = 770, absorbPerLevel = 3.9, maxLevel = 38},
                {id = 19441, level = 40, castTime = 0, baseAbsorb = 1095, absorbPerLevel = 4.7, maxLevel = 46},
                {id = 19442, level = 48, castTime = 0, baseAbsorb = 1470, absorbPerLevel = 5.5, maxLevel = 54},
                {id = 19443, level = 56, castTime = 0, baseAbsorb = 1905, absorbPerLevel = 6.4, maxLevel = 60}
            }
        },
        ["Spellstone"] = {type = Database.Types.Absorb, school = Database.Schools.Shadow, coefficient = 0, ranks = {{id = 128, level = 36, castTime = 0, baseAbsorb = 400}}},
        ["Greater Spellstone"] = {
            type = Database.Types.Absorb,
            school = Database.Schools.Shadow,
            coefficient = 0,
            ranks = {{id = 17729, level = 48, castTime = 0, baseAbsorb = 650}}
        },
        ["Major Spellstone"] = {type = Database.Types.Absorb, school = Database.Schools.Shadow, coefficient = 0, ranks = {{id = 17730, level = 60, castTime = 0, baseAbsorb = 900}}}
    }
}

Addon.Database = Database

function Database:Initialize()
    for categoryName, category in next, Database.Spells do
        for i, spell in next, category do
            spell.name = i
            spell.category = categoryName
            spell.hasSpellCoefficient = spell.type == Database.Types.MagicDamage or spell.type == Database.Types.Heal or spell.type == Database.Types.Absorb
            spell.isDamage = spell.type == Database.Types.MagicDamage
            spell.isHeal = spell.type == Database.Types.Heal
            spell.isDestruction = spell.tag == Database.Tags.Destruction
            spell.isLightning = spell.tag == Database.Tags.Lightning
            spell.isShock = spell.tag == Database.Tags.Shock
            spell.isTotem = spell.tag == Database.Tags.Totem
            spell.isAbsorb = spell.type == Database.Types.Absorb

            for j = 1, #spell.ranks do
                local rank = spell.ranks[j]
                rank.number = j
                rank.spell = spell

                if spell.hasSpellCoefficient then
                    rank.ticks = rank.ticks or spell.ticks
                    rank.tickInterval = rank.tickInterval or spell.tickInterval

                    rank.baseDamage = {min = 0, max = 0, dotMin = 0, dotMax = 0, dotTick = 0}
                    rank.damage = {min = 0, max = 0, dotMin = 0, dotMax = 0, dotTick = 0}

                    if not spell.coefficient and spell.coefficient ~= 0 then
                        if not rank.coefficient then
                            rank.coefficient = Database:GetSpellCoefficient(rank.castTime, rank.level, spell.modifier, spell.aoe)
                        end
                    else
                        rank.coefficient = spell.coefficient * (1 - math.max(0, 20 - rank.level) * 0.0375)
                    end
                    if not spell.ignoreDot then
                        if not spell.dotCoefficient and spell.dotCoefficient ~= 0 then
                            if not rank.dotCoefficient then
                                rank.dotCoefficient = Database:GetSpellCoefficient(rank.castTime, rank.level, spell.dotModifier, spell.aoe)
                            end
                        else
                            rank.dotCoefficient = spell.dotCoefficient * (1 - math.max(0, 20 - rank.level) * 0.0375)
                        end
                    else
                        rank.dotCoefficient = 0
                    end
                end

                if spell.isTotem then
                    local totemName = GetSpellInfo(rank.id)
                    local romanRank = Database:RomanNumeral(rank.number)
                    if romanRank and #spell.ranks > 1 then
                        romanRank = " " .. romanRank
                    else
                        romanRank = ""
                    end

                    Database.TotemIdsByName[totemName .. romanRank] = rank.id
                end

                Database.SpellsById[rank.id] = rank
            end
        end
    end
end

function Database:ParseDescription(rank, description)
    if not rank.baseDescription or not rank.pattern then
        rank.baseDescription = description
        rank.description = description

        for k, pattern in pairs(Database.SpellMinMaxPatterns) do
            if string.find(rank.baseDescription, pattern.pattern) then
                local data = {}
                _, _, data[1], data[2], data[3], data[4], data[5], data[6] = string.find(rank.baseDescription, pattern.pattern)
                for l, type in pairs(pattern.type) do
                    if type == "total" then
                        rank.baseDamage.min = tonumber(data[l])
                        rank.baseDamage.max = tonumber(data[l])
                    elseif type == "dotTotal" then
                        rank.baseDamage.dotMin = tonumber(data[l])
                        rank.baseDamage.dotMax = tonumber(data[l])
                    elseif type == "min" then
                        rank.baseDamage.min = tonumber(data[l])
                    elseif type == "max" then
                        rank.baseDamage.max = tonumber(data[l])
                    elseif type == "dotMin" then
                        rank.baseDamage.dotMin = tonumber(data[l])
                    elseif type == "dotMax" then
                        rank.baseDamage.dotMax = tonumber(data[l])
                    elseif type == "dotTick" then
                        rank.baseDamage.dotMin = tonumber(rank.ticks * data[l])
                        rank.baseDamage.dotMax = tonumber(rank.ticks * data[l])
                    end
                end
                rank.pattern = pattern
                break
            end
        end

        if rank.ticks then
            rank.baseDamage.dotTick = (rank.baseDamage.dotMin + rank.baseDamage.dotMax) / 2 / rank.ticks
        end
    end
end

function Database:UpdateDescription(rank)
    Database:UpdateValues(rank, spellPower, spellDamage)

    rank.description = rank.baseDescription
    if rank.pattern then
        for _, type in pairs(rank.pattern.type) do
            if type == "total" or type == "max" then
                rank.description = string.gsub(rank.description, format("%i", rank.baseDamage.max), format("%i", rank.damage.max), 1)
            elseif type == "dotTotal" or type == "dotMax" then
                rank.description = string.gsub(rank.description, format("%i", rank.baseDamage.dotMax), format("%i", rank.damage.dotMax), 1)
            elseif type == "min" then
                rank.description = string.gsub(rank.description, format("%i", rank.baseDamage.min), format("%i", rank.damage.min), 1)
            elseif type == "dotMin" then
                rank.description = string.gsub(rank.description, format("%i", rank.baseDamage.dotMin), format("%i", rank.damage.dotMin), 1)
            elseif type == "dotTick" then
                rank.description = string.gsub(rank.description, format("%i", rank.baseDamage.dotTick), format("%i", rank.damage.dotTick), 1)
            end
        end
    end
end

function Database:UpdateValues(rank)
    local stats = Database:GetCharacterStats()

    local power = (rank.spell.isHeal and stats.healingPower) or
                      (rank.spell.isDamage and (rank.spell.school == Database.Schools.Arcane and stats.spellPower.arcane) or
                          (rank.spell.school == Database.Schools.Fire and stats.spellPower.fire) or (rank.spell.school == Database.Schools.Frost and stats.spellPower.frost) or
                          (rank.spell.school == Database.Schools.Holy and stats.spellPower.holy) or (rank.spell.school == Database.Schools.Shadow and stats.spellPower.shadow) or
                          (rank.spell.school == Database.Schools.Nature and stats.spellPower.nature)) or 0
    local multiplier = (rank.spell.isHeal and stats.healingDone) or
                           (rank.spell.isDamage and (rank.spell.school == Database.Schools.Arcane and stats.spellDamage.arcane) or
                               (rank.spell.school == Database.Schools.Fire and stats.spellDamage.fire) or (rank.spell.school == Database.Schools.Frost and stats.spellDamage.frost) or
                               (rank.spell.school == Database.Schools.Holy and stats.spellDamage.holy) or
                               (rank.spell.school == Database.Schools.Shadow and stats.spellDamage.shadow) or
                               (rank.spell.school == Database.Schools.Nature and stats.spellDamage.nature)) or 1

    -- spell/type specific modifiers
    if rank.spell.isLightning then
        power = power + (stats.spellPower.lightning or 0)
        multiplier = multiplier * (stats.spellDamage.lightning or 1)
    elseif rank.spell.isShock then
        power = power + (stats.spellPower.shocks or 0)
        multiplier = multiplier * (stats.spellDamage.shock or 1)
    elseif rank.spell.isTotem and rank.spell.element == Database.TotemElements.Fire then
        multiplier = multiplier * (stats.spellDamage.fireTotem or 1)
    elseif rank.spell.name == "Lesser Healing Wave" then
        power = power + (stats.lesserHealingWave or 0)
    end

    local directMultiplier = multiplier
    if rank.spell.name == "Immolate" then
        directMultiplier = directMultiplier * (stats.spellDamage.immolateDirect or 1)
    elseif rank.spell.name == "Flash of Light" then
        directMultiplier = directMultiplier * (stats.spellDamage.flashOfLight or 1)
    elseif rank.spell.name == "Holy Light" then
        directMultiplier = directMultiplier * (stats.spellDamage.holyLight or 1)
    end

    rank.damage.min = directMultiplier * (rank.baseDamage.min + power * rank.coefficient)
    rank.damage.max = directMultiplier * (rank.baseDamage.max + power * rank.coefficient)

    local dotMultiplier = multiplier
    if rank.spell.name == "Curse of Agony" then
        dotMultiplier = dotMultiplier * stats.spellDamage.curseOfAgony
    end

    if rank.baseDamage.dotMin > 0 then
        rank.damage.dotMin = dotMultiplier * (rank.baseDamage.dotMin + power * rank.dotCoefficient)
    else
        rank.damage.dotMin = 0
    end
    if rank.baseDamage.dotMax > 0 then
        rank.damage.dotMax = dotMultiplier * (rank.baseDamage.dotMax + power * rank.dotCoefficient)
        if rank.damage.dotMin <= 0 then
            rank.damage.dotMin = rank.damage.dotMax
        end
        rank.damage.dotTick = (rank.damage.dotMin + rank.damage.dotMax) / 2 / rank.ticks
    end
end

function Database:RomanNumeral(number)
    local roman = nil
    if number == 1 then
        roman = "I"
    elseif number == 2 then
        roman = "II"
    elseif number == 3 then
        roman = "III"
    elseif number == 4 then
        roman = "IV"
    elseif number == 5 then
        roman = "V"
    elseif number == 6 then
        roman = "VI"
    elseif number == 7 then
        roman = "VII"
    elseif number == 8 then
        roman = "VIII"
    elseif number == 9 then
        roman = "IX"
    elseif number == 10 then
        roman = "X"
    end

    return roman
end

function Database:GetCharacterStats()
    if not Database.Stats then
        Database:UpdateCharacterStats()
    end

    return Database.Stats
end

function Database:UpdateCharacterStats()
    local baseDamage = 1
    local baseHealing = 1

    -- Sayge's Dark Fortune of Damage
    if Database:PlayerHasAura(23768) then
        baseDamage = baseDamage * 1.1
    end
    -- Power Infusion 
    if Database:PlayerHasAura(10060) then
        baseDamage = baseDamage * 1.2
    end
    -- Arcane Power
    if Database:PlayerHasAura(12042) then
        baseDamage = baseDamage * 1.3
    end
    -- Nature Aligned
    if Database:PlayerHasAura(23734) then
        baseDamage = baseDamage * 1.2
        baseHealing = baseHealing * 1.2
    end

    local stats = {
        spellPower = {
            holy = GetSpellBonusDamage(2),
            fire = GetSpellBonusDamage(3),
            nature = GetSpellBonusDamage(4),
            frost = GetSpellBonusDamage(5),
            shadow = GetSpellBonusDamage(6),
            arcane = GetSpellBonusDamage(7)
        },
        spellDamage = {holy = baseDamage, fire = baseDamage, nature = baseDamage, frost = baseDamage, shadow = baseDamage, arcane = baseDamage},
        healingPower = GetSpellBonusHealing(),
        healingDone = baseHealing
    }

    if Database.Class == "DRUID" then
        local talents = Database:GetDruidTalents()
        stats.healingDone = stats.healingDone + talents.giftOfNature / 100
    elseif Database.Class == "MAGE" then
        local talents = Database:GetMageTalents()
        stats.spellDamage.holy = stats.spellDamage.holy + (talents.arcaneInstability) / 100
        stats.spellDamage.fire = stats.spellDamage.fire + (talents.arcaneInstability + talents.firePower) / 100
        stats.spellDamage.nature = stats.spellDamage.nature + (talents.arcaneInstability) / 100
        stats.spellDamage.frost = stats.spellDamage.frost + (talents.arcaneInstability + talents.piercingIce) / 100
        stats.spellDamage.shadow = stats.spellDamage.shadow + (talents.arcaneInstability) / 100
        stats.spellDamage.arcane = stats.spellDamage.arcane + (talents.arcaneInstability) / 100
    elseif Database.Class == "PALADIN" then
        local talents = Database:GetPaladinTalents()
        stats.holyLight = stats.healingDone + talents.healingLight / 100
        stats.flashOfLight = stats.healingDone + talents.healingLight / 100
    elseif Database.Class == "PRIEST" then
        local talents = Database:GetPriestTalents()
        stats.healingDone = stats.healingDone + talents.spiritualHealing / 100
        stats.spellDamage.holy = stats.spellDamage.holy + (talents.forceOfWill) / 100
        stats.spellDamage.fire = stats.spellDamage.fire + (talents.forceOfWill) / 100
        stats.spellDamage.nature = stats.spellDamage.nature + (talents.forceOfWill) / 100
        stats.spellDamage.frost = stats.spellDamage.frost + (talents.forceOfWill) / 100
        stats.spellDamage.shadow = stats.spellDamage.shadow + (talents.forceOfWill) / 100
        stats.spellDamage.arcane = stats.spellDamage.arcane + (talents.forceOfWill) / 100
    elseif Database.Class == "SHAMAN" then
        local talents = Database:GetShamanTalents()
        stats.healingDone = stats.healingDone + talents.purification / 100
        stats.spellDamage.lightning = 1 + (talents.concussion) / 100
        stats.spellDamage.shock = 1 + (talents.concussion) / 100
        stats.spellDamage.fireTotem = 1 + (talents.callOfFlame) / 100

        for itemSlot = 1, 18 do
            local itemId = GetInventoryItemID("player", itemSlot)
            if itemId then
                if itemId == 23199 then -- Totem of the Storm
                    stats.spellPower.lightning = 33
                    break
                elseif itemId == 22395 then -- Totem of Rage
                    stats.spellPower.shocks = 30
                    break
                elseif itemId == 23200 then -- Totem of Sustaining
                    stats.spellPower.lesserHealingWave = 53
                    break
                elseif itemId == 22396 then -- Totem of Sustaining
                    stats.spellPower.lesserHealingWave = 80
                    break
                end
            end
        end

    elseif Database.Class == "WARLOCK" then
        local talents = Database:GetWarlockTalents()
        stats.spellDamage.fire = stats.spellDamage.fire + (talents.emberstorm) / 100
        stats.spellDamage.shadow = stats.spellDamage.shadow + (talents.shadowMastery) / 100
        stats.spellDamage.curseOfAgony = 1 + (talents.improvedAgony) / 100
        stats.spellDamage.immolateDirect = 1 + (talents.improvedImmolate) / 100
    end

    Database.Stats = stats
end

function Database:GetDruidTalents()
    local talents = {reflection = 0, giftOfNature = 0}

    if (Database.Class == "DRUID") then
        -- Gift of Nature (2, 4, 6, 8, 10)%
        local lookup = {2, 4, 6, 8, 10}
        spellRank = select(5, GetTalentInfo(3, 12))
        if (spellRank > 0) and (spellRank <= 5) then
            talents.giftOfNature = lookup[spellRank];
        end
    end

    return talents
end

function Database:GetMageTalents()
    local talents = {arcaneInstability = 0, criticalMass = 0, firePower = 0, arcaneFocus = 0, elementalPrecision = 0, piercingIce = 0, arcaneMeditation = 0}

    if (Database.Class == "MAGE") then
        -- Arcane Instability (1, 2, 3)%
        local lookup = {1, 2, 3}
        local spellRank = select(5, GetTalentInfo(1, 15))
        if (spellRank > 0) and (spellRank <= 3) then
            talents.arcaneInstability = lookup[spellRank]
        end

        -- Critical Mass (2, 4, 6)%
        lookup = {2, 4, 6}
        spellRank = select(5, GetTalentInfo(2, 13))
        if (spellRank > 0) and (spellRank <= 3) then
            talents.criticalMass = lookup[spellRank]
        end

        -- Fire Power (2, 4, 6)%
        lookup = {2, 4, 6, 8, 10}
        spellRank = select(5, GetTalentInfo(2, 15))
        if (spellRank > 0) and (spellRank <= 5) then
            talents.firePower = lookup[spellRank]
        end

        -- Arcane Focus  (2, 4, 6, 8, 10)%
        lookup = {2, 4, 6, 8, 10}
        spellRank = select(5, GetTalentInfo(1, 2))
        if (spellRank > 0) and (spellRank <= 5) then
            talents.arcaneFocus = lookup[spellRank]
        end

        -- Piercing Ice (2, 4, 6)%
        lookup = {2, 4, 6}
        spellRank = select(5, GetTalentInfo(3, 8))
        if (spellRank > 0) and (spellRank <= 3) then
            talents.piercingIce = lookup[spellRank]
        end
    end

    return talents
end

function Database:GetPaladinTalents()
    local talents = {healingLight = 0, holyPower = 0, anticipation = 0}

    if (Database.Class == "PALADIN") then
        -- Healing Light (4, 8, 12)%
        local lookup = {4, 8, 12}
        local spellRank = select(5, GetTalentInfo(1, 5))
        if (spellRank > 0) and (spellRank <= 3) then
            talents.healingLight = lookup[spellRank];
        end

        -- Holy Power (1, 2, 3, 4, 5)%
        lookup = {1, 2, 3, 4, 5}
        spellRank = select(5, GetTalentInfo(1, 13))
        if (spellRank > 0) and (spellRank <= 5) then
            talents.holyPower = lookup[spellRank];
        end
    end

    return talents
end

function Database:GetPriestTalents()
    local talents = {holySpecialization = 0, forceOfWill = 0, meditation = 0, improvedPowerWordShield = 0}

    if (Database.Class == "PRIEST") then
        -- Improved Renew (5, 10, 15)%
        local lookup = {5, 10, 15}
        local spellRank = select(5, GetTalentInfo(2, 2))
        if (spellRank > 0) and (spellRank <= 3) then
            talents.improvedRenew = lookup[spellRank]
        end

        -- Holy Specialization (1, 2, 3, 4, 5)%
        lookup = {1, 2, 3, 4, 5}
        local spellRank = select(5, GetTalentInfo(2, 3))
        if (spellRank > 0) and (spellRank <= 5) then
            talents.holySpecialization = lookup[spellRank]
        end

        -- Spiritual Healing (2, 4, 6, 8, 10)%
        lookup = {2, 4, 6, 8, 10}
        local spellRank = select(5, GetTalentInfo(2, 15))
        if (spellRank > 0) and (spellRank <= 5) then
            talents.spiritualHealing = lookup[spellRank]
        end

        -- Improved Power Word: Shield (5, 10, 15)%
        lookup = {5, 10, 15}
        spellRank = select(5, GetTalentInfo(1, 5))
        if (spellRank > 0) and (spellRank <= 3) then
            talents.improvedPowerWordShield = lookup[spellRank]
        end
    end

    return talents
end

function Database:GetShamanTalents()
    local talents = {concussion = 0, callOfFlame = 0, callOfThunder = 0, naturesGuidance = 0, tidalMastery = 0, purification = 0}

    if (Database.Class == "SHAMAN") then
        -- Concussion (1, 2, 3, 4, 5)%
        local lookup = {1, 2, 3, 4, 5}
        local spellRank = select(5, GetTalentInfo(1, 2))
        if (spellRank > 0) and (spellRank <= 5) then
            talents.concussion = lookup[spellRank]
        end

        -- Call of Flame (5, 10, 15)%
        lookup = {5, 10, 15}
        spellRank = select(5, GetTalentInfo(1, 5))
        if (spellRank > 0) and (spellRank <= 3) then
            talents.callOfFlame = lookup[spellRank]
        end

        -- Call of Thunder (1, 2, 3, 4, 6)%
        lookup = {1, 2, 3, 4, 6}
        spellRank = select(5, GetTalentInfo(1, 8))
        if (spellRank > 0) and (spellRank <= 5) then
            talents.callOfThunder = lookup[spellRank]
        end

        -- Nature's Guidance (1, 2, 3)%
        lookup = {1, 2, 3}
        spellRank = select(5, GetTalentInfo(3, 6))
        if (spellRank > 0) and (spellRank <= 3) then
            talents.naturesGuidance = lookup[spellRank]
        end

        -- Tidal Mastery (1, 2, 3, 4, 5)%
        lookup = {1, 2, 3, 4, 5}
        spellRank = select(5, GetTalentInfo(3, 11))
        if (spellRank > 0) and (spellRank <= 5) then
            talents.tidalMastery = lookup[spellRank]
        end

        -- Purification (2, 4, 6, 8, 10)%
        lookup = {2, 4, 6, 8, 10}
        spellRank = select(5, GetTalentInfo(3, 14))
        if (spellRank > 0) and (spellRank <= 3) then
            talents.purification = lookup[spellRank]
        end
    end

    return talents
end

function Database:GetWarlockTalents()
    local talents = {
        improvedAgony = 0,
        shadowMastery = 0,
        improvedVoidwalker = 0,
        improvedSpellstone = 0,
        devastation = 0,
        improvedSearingPain = 0,
        improvedImmolate = 0,
        emberstorm = 0
    }

    if (Database.Class == "WARLOCK") then
        -- Improved Curse of Agony (2, 4, 6)%
        lookup = {2, 4, 6}
        spellRank = select(5, GetTalentInfo(1, 7))
        if (spellRank > 0) and (spellRank <= 3) then
            talents.improvedAgony = lookup[spellRank];
        end

        -- Shadow Mastery (2, 4, 6, 8, 10)%
        lookup = {2, 4, 6, 8, 10}
        spellRank = select(5, GetTalentInfo(1, 16))
        if (spellRank > 0) and (spellRank <= 5) then
            talents.shadowMastery = lookup[spellRank];
        end

        -- Improved Voidwalker (10, 20, 30)%
        local lookup = {10, 20, 30}
        local spellRank = select(5, GetTalentInfo(2, 5))
        if (spellRank > 0) and (spellRank <= 3) then
            talents.improvedVoidwalker = lookup[spellRank];
        end

        -- Improved Spellstone (15, 30)%
        lookup = {15, 30}
        spellRank = select(5, GetTalentInfo(2, 17))
        if (spellRank > 0) and (spellRank <= 2) then
            talents.improvedSpellstone = lookup[spellRank];
        end

        -- Devestation (1, 2, 3, 4, 5)%
        lookup = {1, 2, 3, 4, 5}
        spellRank = select(5, GetTalentInfo(3, 7))
        if (spellRank > 0) and (spellRank <= 5) then
            talents.devastation = lookup[spellRank];
        end

        -- Improved Searing Pain (2, 4, 6, 8, 10)%
        lookup = {2, 4, 6, 8, 10}
        spellRank = select(5, GetTalentInfo(3, 11))
        if (spellRank > 0) and (spellRank <= 5) then
            talents.improvedSearingPain = lookup[spellRank];
        end

        -- Improved Immolate (5, 10, 15, 20, 25)%
        lookup = {5, 10, 15, 20, 25}
        spellRank = select(5, GetTalentInfo(3, 13))
        if (spellRank > 0) and (spellRank <= 5) then
            talents.improvedImmolate = lookup[spellRank];
        end

        -- Emberstorm (2, 4, 6, 8, 10)%
        lookup = {2, 4, 6, 8, 10}
        spellRank = select(5, GetTalentInfo(3, 15))
        if (spellRank > 0) and (spellRank <= 5) then
            talents.emberstorm = lookup[spellRank];
        end
    end

    return talents
end

function Database:PlayerHasAura(auraId)
    local i = 1
    local spellId = select(10, UnitAura("player", i))
    while spellId do
        if spellId == auraId then
            return true
        end

        i = i + 1
        spellId = select(10, UnitAura("player", i))
    end

    return false
end

-- Calculate the spell power coefficient for given cast time, level, modifier and whether the spell is an AoE spell
function Database:GetSpellCoefficient(castTime, level, modifier, aoe)
    local coefficient = math.min(math.max(castTime or 1.5, 1.5), 3.5) / 3.5
    coefficient = coefficient / ((aoe and 3) or 1)
    coefficient = coefficient * (modifier or 1)
    coefficient = coefficient * (1 - math.max(0, 20 - level) * 0.0375)
    return coefficient
end

-- Get the spell id for the aura with the given name
function Database:GetAuraId(spellName, unit)
    local auraName, spellId
    for i = 1, 255 do
        auraName, _, _, _, _, _, _, _, _, spellId = UnitBuff(unit, i)
        if auraName == spellName then
            break
        elseif not auraName then
            spellId = nil
            break
        end
    end
    return spellId
end

-- Retrieve a spell by it's ID
function Database:GetSpellById(spellId)
    return Database.SpellsById[spellId]
end

-- Get the next available rank for a given spell
function Database:GetNextRank(spellId)
    local rank = Database:GetSpellById(spellId)
    local nextRank = rank
    if rank then
        for _, spellRank in next, rank.spell.ranks do
            if spellRank.level > rank.level or (spellRank.level == rank.level and spellRank.number > rank.number) then
                nextRank = spellRank
                break
            end
        end
    end

    return nextRank
end

-- Get the max rank for a given spell
function Database:GetMaxRank(spellId)
    local rank = Database:GetSpellById(spellId)
    local maxRank = rank
    if rank then
        for _, spellRank in next, rank.spell.ranks do
            if spellRank.level > maxRank.level or (spellRank.level == maxRank.level and spellRank.number > maxRank.number) then
                maxRank = spellRank
            end
        end
    end

    return maxRank
end

-- Check whether the given spell is the max rank
function Database:IsMaxRank(spellId)
    local maxRank = Database:GetMaxRank(spellId)
    return (maxRank and maxRank.id or nil) == spellId
end

-- Get the max know rank for a given spell
function Database:GetMaxKnownRank(spellId)
    local rank = Database:GetSpellById(spellId)
    local maxRank = rank
    if rank then
        for _, spellRank in next, rank.spell.ranks do
            if (spellRank.level > maxRank.level or (spellRank.level == maxRank.level and spellRank.number > maxRank.number)) and IsSpellKnown(spellRank.id) then
                maxRank = spellRank
            end
        end
    end

    return maxRank
end

-- Check whether the given spell is the max known rank
function Database:IsMaxKnownRank(spellId)
    local maxKnownRank = Database:GetMaxKnownRank(spellId)
    return (maxKnownRank and maxKnownRank.id or nil) == spellId
end

-- Find the totem with the given name
function Database:FindTotem(totemName)
    local rank = Database.TotemIdsByName[totemName]
    if not rank then
        local spell = Database.Spells.SHAMAN[totemName]
        if spell then
            for i = 1, #spell.ranks do
                if IsSpellKnown(spell.ranks[i].id) then
                    rank = spell.ranks[i].id
                end
            end
        end
    end

    return rank
end

-- modify the given tool tip's spell damage numbers
function Database:ModifyTooltip(tooltip, spellId)
    local rank = Database:GetSpellById(spellId)
    if rank and rank.spell.hasSpellCoefficient then
        local name = tooltip:GetName()
        local tooltipText = _G[name .. "TextLeft4"]
        local description = tooltipText:GetText()
        if description then
            -- TODO: localize this or find another way of doing it
            if string.find(description, "Cooldown remaining:") then
                tooltipText = _G[name .. "TextLeft5"]
                description = tooltipText:GetText()
            end
            Database:ParseDescription(rank, description)
            Database:UpdateDescription(rank)
            tooltipText:SetText(rank.description)
        end
    end
end
