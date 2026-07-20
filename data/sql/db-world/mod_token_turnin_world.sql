-- mod_token_turnin
-- World database table: maps a tier token + talent tree + difficulty to the
-- resulting gear item. One token identity + spec role + difficulty = one item.
--
-- NOTE: talent_tab convention (0/1/2) must match the tab order returned by
-- TalentSpec::highestTree() in the playerbots codebase. Verify this against
-- the actual talent tab indexing before populating data (AzerothCore/WotLK
-- talent tabs are normally ordered left-to-right as tab 0/1/2 per class,
-- but confirm rather than assume).

DROP TABLE IF EXISTS `mod_token_turnin_tokens`;
CREATE TABLE `mod_token_turnin_tokens` (
  `id`                 INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `token_entry`        INT UNSIGNED   NOT NULL COMMENT 'Item entry ID of the tier token',
  `class_id`           TINYINT UNSIGNED NOT NULL COMMENT 'Class this token belongs to (Player::getClass() values)',
  `talent_tab`         TINYINT UNSIGNED NOT NULL COMMENT '0/1/2 - talent tree this row''s result item applies to',
  `result_item_entry`  INT UNSIGNED   NOT NULL COMMENT 'Gear item entry awarded on conversion',
  `tier`               TINYINT UNSIGNED NOT NULL COMMENT 'Tier number, 3-10, for bookkeeping/filtering',
  `token_name`         VARCHAR(100)   NOT NULL COMMENT 'item_template.name of token_entry, for readability only - not authoritative',
  `result_name`        VARCHAR(100)   NOT NULL COMMENT 'item_template.name of result_item_entry, for readability only - not authoritative',
  `difficulty`         VARCHAR(10)    NOT NULL COMMENT 'normal | heroic | 10 | 25',
  PRIMARY KEY (`id`),
  -- difficulty is intentionally NOT part of the lookup key: each 10/25/heroic
  -- token is already a distinct token_entry (distinct item_id) in game data,
  -- so difficulty is implied by which token was scanned, not resolved at
  -- query time. It's kept as a descriptive/bookkeeping column only.
  --
  -- class_id IS part of the lookup key: a single token_entry can be shared
  -- across multiple classes (confirmed in game data - e.g. T4's "Fallen
  -- Defender" family token is usable by Warrior, Priest, and Druid alike,
  -- each redeeming their own 3 spec-variant items from the same token). Without
  -- class_id here, two classes sharing a token would collide on (token_entry,
  -- talent_tab) alone.
  UNIQUE KEY `idx_token_lookup` (`token_entry`, `class_id`, `talent_tab`),
  KEY `idx_tier` (`tier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='mod_token_turnin conversion table';

-- Druid T4 (Fallen Defender), normal.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (29767, 29764, 29761, 29758, 29753);
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    -- Leggings of the Fallen Defender
    (29767, 11, 0, 29094, 4, 'Leggings of the Fallen Defender', 'Britches of Malorne', 'normal'),
    (29767, 11, 1, 29099, 4, 'Leggings of the Fallen Defender', 'Greaves of Malorne', 'normal'),
    (29767, 11, 2, 29088, 4, 'Leggings of the Fallen Defender', 'Legguards of Malorne', 'normal'),
    -- Pauldrons of the Fallen Defender
    (29764, 11, 0, 29095, 4, 'Pauldrons of the Fallen Defender', 'Pauldrons of Malorne', 'normal'),
    (29764, 11, 1, 29100, 4, 'Pauldrons of the Fallen Defender', 'Mantle of Malorne', 'normal'),
    (29764, 11, 2, 29089, 4, 'Pauldrons of the Fallen Defender', 'Shoulderguards of Malorne', 'normal'),
    -- Helm of the Fallen Defender
    (29761, 11, 0, 29093, 4, 'Helm of the Fallen Defender', 'Antlers of Malorne', 'normal'),
    (29761, 11, 1, 29098, 4, 'Helm of the Fallen Defender', 'Stag-Helm of Malorne', 'normal'),
    (29761, 11, 2, 29086, 4, 'Helm of the Fallen Defender', 'Crown of Malorne', 'normal'),
    -- Gloves of the Fallen Defender
    (29758, 11, 0, 29092, 4, 'Gloves of the Fallen Defender', 'Gloves of Malorne', 'normal'),
    (29758, 11, 1, 29097, 4, 'Gloves of the Fallen Defender', 'Gauntlets of Malorne', 'normal'),
    (29758, 11, 2, 29090, 4, 'Gloves of the Fallen Defender', 'Handguards of Malorne', 'normal'),
    -- Chestguard of the Fallen Defender
    (29753, 11, 0, 29091, 4, 'Chestguard of the Fallen Defender', 'Chestpiece of Malorne', 'normal'),
    (29753, 11, 1, 29096, 4, 'Chestguard of the Fallen Defender', 'Breastplate of Malorne', 'normal'),
    (29753, 11, 2, 29087, 4, 'Chestguard of the Fallen Defender', 'Chestguard of Malorne', 'normal');

-- Warrior T4 (Fallen Defender), normal. Arms/Fury share one itemization
-- (Warbringer, set 655), Protection has its own (Warbringer, set 654).
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (29767, 29764, 29761, 29758, 29753) AND `class_id` = 1;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    -- Leggings of the Fallen Defender
    (29767, 1, 0, 29022, 4, 'Leggings of the Fallen Defender', 'Warbringer Greaves', 'normal'),
    (29767, 1, 1, 29022, 4, 'Leggings of the Fallen Defender', 'Warbringer Greaves', 'normal'),
    (29767, 1, 2, 29015, 4, 'Leggings of the Fallen Defender', 'Warbringer Legguards', 'normal'),
    -- Pauldrons of the Fallen Defender
    (29764, 1, 0, 29023, 4, 'Pauldrons of the Fallen Defender', 'Warbringer Shoulderplates', 'normal'),
    (29764, 1, 1, 29023, 4, 'Pauldrons of the Fallen Defender', 'Warbringer Shoulderplates', 'normal'),
    (29764, 1, 2, 29016, 4, 'Pauldrons of the Fallen Defender', 'Warbringer Shoulderguards', 'normal'),
    -- Helm of the Fallen Defender
    (29761, 1, 0, 29021, 4, 'Helm of the Fallen Defender', 'Warbringer Battle-Helm', 'normal'),
    (29761, 1, 1, 29021, 4, 'Helm of the Fallen Defender', 'Warbringer Battle-Helm', 'normal'),
    (29761, 1, 2, 29011, 4, 'Helm of the Fallen Defender', 'Warbringer Greathelm', 'normal'),
    -- Gloves of the Fallen Defender
    (29758, 1, 0, 29020, 4, 'Gloves of the Fallen Defender', 'Warbringer Gauntlets', 'normal'),
    (29758, 1, 1, 29020, 4, 'Gloves of the Fallen Defender', 'Warbringer Gauntlets', 'normal'),
    (29758, 1, 2, 29017, 4, 'Gloves of the Fallen Defender', 'Warbringer Handguards', 'normal'),
    -- Chestguard of the Fallen Defender
    (29753, 1, 0, 29019, 4, 'Chestguard of the Fallen Defender', 'Warbringer Breastplate', 'normal'),
    (29753, 1, 1, 29019, 4, 'Chestguard of the Fallen Defender', 'Warbringer Breastplate', 'normal'),
    (29753, 1, 2, 29012, 4, 'Chestguard of the Fallen Defender', 'Warbringer Chestguard', 'normal');

-- Priest T4 (Fallen Defender), normal. Discipline/Holy share one itemization
-- (Incarnate, set 663), Shadow has its own (Incarnate, set 664).
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (29767, 29764, 29761, 29758, 29753) AND `class_id` = 5;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    -- Leggings of the Fallen Defender
    (29767, 5, 0, 29053, 4, 'Leggings of the Fallen Defender', 'Trousers of the Incarnate', 'normal'),
    (29767, 5, 1, 29053, 4, 'Leggings of the Fallen Defender', 'Trousers of the Incarnate', 'normal'),
    (29767, 5, 2, 29059, 4, 'Leggings of the Fallen Defender', 'Leggings of the Incarnate', 'normal'),
    -- Pauldrons of the Fallen Defender
    (29764, 5, 0, 29054, 4, 'Pauldrons of the Fallen Defender', 'Light-Mantle of the Incarnate', 'normal'),
    (29764, 5, 1, 29054, 4, 'Pauldrons of the Fallen Defender', 'Light-Mantle of the Incarnate', 'normal'),
    (29764, 5, 2, 29060, 4, 'Pauldrons of the Fallen Defender', 'Soul-Mantle of the Incarnate', 'normal'),
    -- Helm of the Fallen Defender
    (29761, 5, 0, 29049, 4, 'Helm of the Fallen Defender', 'Light-Collar of the Incarnate', 'normal'),
    (29761, 5, 1, 29049, 4, 'Helm of the Fallen Defender', 'Light-Collar of the Incarnate', 'normal'),
    (29761, 5, 2, 29058, 4, 'Helm of the Fallen Defender', 'Soul-Collar of the Incarnate', 'normal'),
    -- Gloves of the Fallen Defender
    (29758, 5, 0, 29055, 4, 'Gloves of the Fallen Defender', 'Handwraps of the Incarnate', 'normal'),
    (29758, 5, 1, 29055, 4, 'Gloves of the Fallen Defender', 'Handwraps of the Incarnate', 'normal'),
    (29758, 5, 2, 29057, 4, 'Gloves of the Fallen Defender', 'Gloves of the Incarnate', 'normal'),
    -- Chestguard of the Fallen Defender
    (29753, 5, 0, 29050, 4, 'Chestguard of the Fallen Defender', 'Robes of the Incarnate', 'normal'),
    (29753, 5, 1, 29050, 4, 'Chestguard of the Fallen Defender', 'Robes of the Incarnate', 'normal'),
    (29753, 5, 2, 29056, 4, 'Chestguard of the Fallen Defender', 'Shroud of the Incarnate', 'normal');

-- Hunter T4 (Fallen Hero), normal. All 3 specs are ranged DPS - one
-- itemization (Demon Stalker) applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (29765, 29762, 29759, 29756, 29755) AND `class_id` = 3;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (29765, 3, 0, 29083, 4, 'Leggings of the Fallen Hero', 'Demon Stalker Greaves', 'normal'),
    (29765, 3, 1, 29083, 4, 'Leggings of the Fallen Hero', 'Demon Stalker Greaves', 'normal'),
    (29765, 3, 2, 29083, 4, 'Leggings of the Fallen Hero', 'Demon Stalker Greaves', 'normal'),
    (29762, 3, 0, 29084, 4, 'Pauldrons of the Fallen Hero', 'Demon Stalker Shoulderguards', 'normal'),
    (29762, 3, 1, 29084, 4, 'Pauldrons of the Fallen Hero', 'Demon Stalker Shoulderguards', 'normal'),
    (29762, 3, 2, 29084, 4, 'Pauldrons of the Fallen Hero', 'Demon Stalker Shoulderguards', 'normal'),
    (29759, 3, 0, 29081, 4, 'Helm of the Fallen Hero', 'Demon Stalker Greathelm', 'normal'),
    (29759, 3, 1, 29081, 4, 'Helm of the Fallen Hero', 'Demon Stalker Greathelm', 'normal'),
    (29759, 3, 2, 29081, 4, 'Helm of the Fallen Hero', 'Demon Stalker Greathelm', 'normal'),
    (29756, 3, 0, 29085, 4, 'Gloves of the Fallen Hero', 'Demon Stalker Gauntlets', 'normal'),
    (29756, 3, 1, 29085, 4, 'Gloves of the Fallen Hero', 'Demon Stalker Gauntlets', 'normal'),
    (29756, 3, 2, 29085, 4, 'Gloves of the Fallen Hero', 'Demon Stalker Gauntlets', 'normal'),
    (29755, 3, 0, 29082, 4, 'Chestguard of the Fallen Hero', 'Demon Stalker Harness', 'normal'),
    (29755, 3, 1, 29082, 4, 'Chestguard of the Fallen Hero', 'Demon Stalker Harness', 'normal'),
    (29755, 3, 2, 29082, 4, 'Chestguard of the Fallen Hero', 'Demon Stalker Harness', 'normal');

-- Mage T4 (Fallen Hero), normal. All 3 specs are caster DPS - one
-- itemization (Aldor) applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (29765, 29762, 29759, 29756, 29755) AND `class_id` = 8;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (29765, 8, 0, 29078, 4, 'Leggings of the Fallen Hero', 'Legwraps of the Aldor', 'normal'),
    (29765, 8, 1, 29078, 4, 'Leggings of the Fallen Hero', 'Legwraps of the Aldor', 'normal'),
    (29765, 8, 2, 29078, 4, 'Leggings of the Fallen Hero', 'Legwraps of the Aldor', 'normal'),
    (29762, 8, 0, 29079, 4, 'Pauldrons of the Fallen Hero', 'Pauldrons of the Aldor', 'normal'),
    (29762, 8, 1, 29079, 4, 'Pauldrons of the Fallen Hero', 'Pauldrons of the Aldor', 'normal'),
    (29762, 8, 2, 29079, 4, 'Pauldrons of the Fallen Hero', 'Pauldrons of the Aldor', 'normal'),
    (29759, 8, 0, 29076, 4, 'Helm of the Fallen Hero', 'Collar of the Aldor', 'normal'),
    (29759, 8, 1, 29076, 4, 'Helm of the Fallen Hero', 'Collar of the Aldor', 'normal'),
    (29759, 8, 2, 29076, 4, 'Helm of the Fallen Hero', 'Collar of the Aldor', 'normal'),
    (29756, 8, 0, 29080, 4, 'Gloves of the Fallen Hero', 'Gloves of the Aldor', 'normal'),
    (29756, 8, 1, 29080, 4, 'Gloves of the Fallen Hero', 'Gloves of the Aldor', 'normal'),
    (29756, 8, 2, 29080, 4, 'Gloves of the Fallen Hero', 'Gloves of the Aldor', 'normal'),
    (29755, 8, 0, 29077, 4, 'Chestguard of the Fallen Hero', 'Vestments of the Aldor', 'normal'),
    (29755, 8, 1, 29077, 4, 'Chestguard of the Fallen Hero', 'Vestments of the Aldor', 'normal'),
    (29755, 8, 2, 29077, 4, 'Chestguard of the Fallen Hero', 'Vestments of the Aldor', 'normal');

-- Warlock T4 (Fallen Hero), normal. All 3 specs are caster DPS - one
-- itemization (Voidheart) applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (29765, 29762, 29759, 29756, 29755) AND `class_id` = 9;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (29765, 9, 0, 28966, 4, 'Leggings of the Fallen Hero', 'Voidheart Leggings', 'normal'),
    (29765, 9, 1, 28966, 4, 'Leggings of the Fallen Hero', 'Voidheart Leggings', 'normal'),
    (29765, 9, 2, 28966, 4, 'Leggings of the Fallen Hero', 'Voidheart Leggings', 'normal'),
    (29762, 9, 0, 28967, 4, 'Pauldrons of the Fallen Hero', 'Voidheart Mantle', 'normal'),
    (29762, 9, 1, 28967, 4, 'Pauldrons of the Fallen Hero', 'Voidheart Mantle', 'normal'),
    (29762, 9, 2, 28967, 4, 'Pauldrons of the Fallen Hero', 'Voidheart Mantle', 'normal'),
    (29759, 9, 0, 28963, 4, 'Helm of the Fallen Hero', 'Voidheart Crown', 'normal'),
    (29759, 9, 1, 28963, 4, 'Helm of the Fallen Hero', 'Voidheart Crown', 'normal'),
    (29759, 9, 2, 28963, 4, 'Helm of the Fallen Hero', 'Voidheart Crown', 'normal'),
    (29756, 9, 0, 28968, 4, 'Gloves of the Fallen Hero', 'Voidheart Gloves', 'normal'),
    (29756, 9, 1, 28968, 4, 'Gloves of the Fallen Hero', 'Voidheart Gloves', 'normal'),
    (29756, 9, 2, 28968, 4, 'Gloves of the Fallen Hero', 'Voidheart Gloves', 'normal'),
    (29755, 9, 0, 28964, 4, 'Chestguard of the Fallen Hero', 'Voidheart Robe', 'normal'),
    (29755, 9, 1, 28964, 4, 'Chestguard of the Fallen Hero', 'Voidheart Robe', 'normal'),
    (29755, 9, 2, 28964, 4, 'Chestguard of the Fallen Hero', 'Voidheart Robe', 'normal');

-- Rogue T4 (Fallen Champion), normal. All 3 specs are melee DPS - one
-- itemization (Netherblade) applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (29766, 29763, 29760, 29757, 29754) AND `class_id` = 4;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (29766, 4, 0, 29046, 4, 'Leggings of the Fallen Champion', 'Netherblade Breeches', 'normal'),
    (29766, 4, 1, 29046, 4, 'Leggings of the Fallen Champion', 'Netherblade Breeches', 'normal'),
    (29766, 4, 2, 29046, 4, 'Leggings of the Fallen Champion', 'Netherblade Breeches', 'normal'),
    (29763, 4, 0, 29047, 4, 'Pauldrons of the Fallen Champion', 'Netherblade Shoulderpads', 'normal'),
    (29763, 4, 1, 29047, 4, 'Pauldrons of the Fallen Champion', 'Netherblade Shoulderpads', 'normal'),
    (29763, 4, 2, 29047, 4, 'Pauldrons of the Fallen Champion', 'Netherblade Shoulderpads', 'normal'),
    (29760, 4, 0, 29044, 4, 'Helm of the Fallen Champion', 'Netherblade Facemask', 'normal'),
    (29760, 4, 1, 29044, 4, 'Helm of the Fallen Champion', 'Netherblade Facemask', 'normal'),
    (29760, 4, 2, 29044, 4, 'Helm of the Fallen Champion', 'Netherblade Facemask', 'normal'),
    (29757, 4, 0, 29048, 4, 'Gloves of the Fallen Champion', 'Netherblade Gloves', 'normal'),
    (29757, 4, 1, 29048, 4, 'Gloves of the Fallen Champion', 'Netherblade Gloves', 'normal'),
    (29757, 4, 2, 29048, 4, 'Gloves of the Fallen Champion', 'Netherblade Gloves', 'normal'),
    (29754, 4, 0, 29045, 4, 'Chestguard of the Fallen Champion', 'Netherblade Chestpiece', 'normal'),
    (29754, 4, 1, 29045, 4, 'Chestguard of the Fallen Champion', 'Netherblade Chestpiece', 'normal'),
    (29754, 4, 2, 29045, 4, 'Chestguard of the Fallen Champion', 'Netherblade Chestpiece', 'normal');

-- Paladin T4 (Fallen Champion), normal. Holy (set 624), Protection
-- (set 625), Retribution (set 626) - all distinct itemizations.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (29766, 29763, 29760, 29757, 29754) AND `class_id` = 2;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (29766, 2, 0, 29063, 4, 'Leggings of the Fallen Champion', 'Justicar Leggings', 'normal'),
    (29766, 2, 1, 29069, 4, 'Leggings of the Fallen Champion', 'Justicar Legguards', 'normal'),
    (29766, 2, 2, 29074, 4, 'Leggings of the Fallen Champion', 'Justicar Greaves', 'normal'),
    (29763, 2, 0, 29064, 4, 'Pauldrons of the Fallen Champion', 'Justicar Pauldrons', 'normal'),
    (29763, 2, 1, 29070, 4, 'Pauldrons of the Fallen Champion', 'Justicar Shoulderguards', 'normal'),
    (29763, 2, 2, 29075, 4, 'Pauldrons of the Fallen Champion', 'Justicar Shoulderplates', 'normal'),
    (29760, 2, 0, 29061, 4, 'Helm of the Fallen Champion', 'Justicar Diadem', 'normal'),
    (29760, 2, 1, 29068, 4, 'Helm of the Fallen Champion', 'Justicar Faceguard', 'normal'),
    (29760, 2, 2, 29073, 4, 'Helm of the Fallen Champion', 'Justicar Crown', 'normal'),
    (29757, 2, 0, 29065, 4, 'Gloves of the Fallen Champion', 'Justicar Gloves', 'normal'),
    (29757, 2, 1, 29067, 4, 'Gloves of the Fallen Champion', 'Justicar Handguards', 'normal'),
    (29757, 2, 2, 29072, 4, 'Gloves of the Fallen Champion', 'Justicar Gauntlets', 'normal'),
    (29754, 2, 0, 29062, 4, 'Chestguard of the Fallen Champion', 'Justicar Chestpiece', 'normal'),
    (29754, 2, 1, 29066, 4, 'Chestguard of the Fallen Champion', 'Justicar Chestguard', 'normal'),
    (29754, 2, 2, 29071, 4, 'Chestguard of the Fallen Champion', 'Justicar Breastplate', 'normal');

-- Shaman T4 (Fallen Champion), normal. Elemental (set 632), Enhancement
-- (set 633), Restoration (set 631) - all distinct itemizations.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (29766, 29763, 29760, 29757, 29754) AND `class_id` = 7;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (29766, 7, 0, 29036, 4, 'Leggings of the Fallen Champion', 'Cyclone Legguards', 'normal'),
    (29766, 7, 1, 29042, 4, 'Leggings of the Fallen Champion', 'Cyclone War-Kilt', 'normal'),
    (29766, 7, 2, 29030, 4, 'Leggings of the Fallen Champion', 'Cyclone Kilt', 'normal'),
    (29763, 7, 0, 29037, 4, 'Pauldrons of the Fallen Champion', 'Cyclone Shoulderguards', 'normal'),
    (29763, 7, 1, 29043, 4, 'Pauldrons of the Fallen Champion', 'Cyclone Shoulderplates', 'normal'),
    (29763, 7, 2, 29031, 4, 'Pauldrons of the Fallen Champion', 'Cyclone Shoulderpads', 'normal'),
    (29760, 7, 0, 29035, 4, 'Helm of the Fallen Champion', 'Cyclone Faceguard', 'normal'),
    (29760, 7, 1, 29040, 4, 'Helm of the Fallen Champion', 'Cyclone Helm', 'normal'),
    (29760, 7, 2, 29028, 4, 'Helm of the Fallen Champion', 'Cyclone Headdress', 'normal'),
    (29757, 7, 0, 29034, 4, 'Gloves of the Fallen Champion', 'Cyclone Handguards', 'normal'),
    (29757, 7, 1, 29039, 4, 'Gloves of the Fallen Champion', 'Cyclone Gauntlets', 'normal'),
    (29757, 7, 2, 29032, 4, 'Gloves of the Fallen Champion', 'Cyclone Gloves', 'normal'),
    (29754, 7, 0, 29033, 4, 'Chestguard of the Fallen Champion', 'Cyclone Chestguard', 'normal'),
    (29754, 7, 1, 29038, 4, 'Chestguard of the Fallen Champion', 'Cyclone Breastplate', 'normal'),
    (29754, 7, 2, 29029, 4, 'Chestguard of the Fallen Champion', 'Cyclone Hauberk', 'normal');

-- Hunter T5 (Vanquished Hero), normal. All 3 specs are ranged DPS - one
-- itemization (Rift Stalker) applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (30247, 30250, 30244, 30241, 30238) AND `class_id` = 3;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (30247, 3, 0, 30142, 5, 'Leggings of the Vanquished Hero', 'Rift Stalker Leggings', 'normal'),
    (30247, 3, 1, 30142, 5, 'Leggings of the Vanquished Hero', 'Rift Stalker Leggings', 'normal'),
    (30247, 3, 2, 30142, 5, 'Leggings of the Vanquished Hero', 'Rift Stalker Leggings', 'normal'),
    (30250, 3, 0, 30143, 5, 'Pauldrons of the Vanquished Hero', 'Rift Stalker Mantle', 'normal'),
    (30250, 3, 1, 30143, 5, 'Pauldrons of the Vanquished Hero', 'Rift Stalker Mantle', 'normal'),
    (30250, 3, 2, 30143, 5, 'Pauldrons of the Vanquished Hero', 'Rift Stalker Mantle', 'normal'),
    (30244, 3, 0, 30141, 5, 'Helm of the Vanquished Hero', 'Rift Stalker Helm', 'normal'),
    (30244, 3, 1, 30141, 5, 'Helm of the Vanquished Hero', 'Rift Stalker Helm', 'normal'),
    (30244, 3, 2, 30141, 5, 'Helm of the Vanquished Hero', 'Rift Stalker Helm', 'normal'),
    (30241, 3, 0, 30140, 5, 'Gloves of the Vanquished Hero', 'Rift Stalker Gauntlets', 'normal'),
    (30241, 3, 1, 30140, 5, 'Gloves of the Vanquished Hero', 'Rift Stalker Gauntlets', 'normal'),
    (30241, 3, 2, 30140, 5, 'Gloves of the Vanquished Hero', 'Rift Stalker Gauntlets', 'normal'),
    (30238, 3, 0, 30139, 5, 'Chestguard of the Vanquished Hero', 'Rift Stalker Hauberk', 'normal'),
    (30238, 3, 1, 30139, 5, 'Chestguard of the Vanquished Hero', 'Rift Stalker Hauberk', 'normal'),
    (30238, 3, 2, 30139, 5, 'Chestguard of the Vanquished Hero', 'Rift Stalker Hauberk', 'normal');

-- Mage T5 (Vanquished Hero), normal. All 3 specs are caster DPS - one
-- itemization (Tirisfal) applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (30247, 30250, 30244, 30241, 30238) AND `class_id` = 8;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (30247, 8, 0, 30207, 5, 'Leggings of the Vanquished Hero', 'Leggings of Tirisfal', 'normal'),
    (30247, 8, 1, 30207, 5, 'Leggings of the Vanquished Hero', 'Leggings of Tirisfal', 'normal'),
    (30247, 8, 2, 30207, 5, 'Leggings of the Vanquished Hero', 'Leggings of Tirisfal', 'normal'),
    (30250, 8, 0, 30210, 5, 'Pauldrons of the Vanquished Hero', 'Mantle of Tirisfal', 'normal'),
    (30250, 8, 1, 30210, 5, 'Pauldrons of the Vanquished Hero', 'Mantle of Tirisfal', 'normal'),
    (30250, 8, 2, 30210, 5, 'Pauldrons of the Vanquished Hero', 'Mantle of Tirisfal', 'normal'),
    (30244, 8, 0, 30206, 5, 'Helm of the Vanquished Hero', 'Cowl of Tirisfal', 'normal'),
    (30244, 8, 1, 30206, 5, 'Helm of the Vanquished Hero', 'Cowl of Tirisfal', 'normal'),
    (30244, 8, 2, 30206, 5, 'Helm of the Vanquished Hero', 'Cowl of Tirisfal', 'normal'),
    (30241, 8, 0, 30205, 5, 'Gloves of the Vanquished Hero', 'Gloves of Tirisfal', 'normal'),
    (30241, 8, 1, 30205, 5, 'Gloves of the Vanquished Hero', 'Gloves of Tirisfal', 'normal'),
    (30241, 8, 2, 30205, 5, 'Gloves of the Vanquished Hero', 'Gloves of Tirisfal', 'normal'),
    (30238, 8, 0, 30196, 5, 'Chestguard of the Vanquished Hero', 'Robes of Tirisfal', 'normal'),
    (30238, 8, 1, 30196, 5, 'Chestguard of the Vanquished Hero', 'Robes of Tirisfal', 'normal'),
    (30238, 8, 2, 30196, 5, 'Chestguard of the Vanquished Hero', 'Robes of Tirisfal', 'normal');

-- Warlock T5 (Vanquished Hero), normal. All 3 specs are caster DPS - one
-- itemization (Corruptor) applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (30247, 30250, 30244, 30241, 30238) AND `class_id` = 9;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (30247, 9, 0, 30213, 5, 'Leggings of the Vanquished Hero', 'Leggings of the Corruptor', 'normal'),
    (30247, 9, 1, 30213, 5, 'Leggings of the Vanquished Hero', 'Leggings of the Corruptor', 'normal'),
    (30247, 9, 2, 30213, 5, 'Leggings of the Vanquished Hero', 'Leggings of the Corruptor', 'normal'),
    (30250, 9, 0, 30215, 5, 'Pauldrons of the Vanquished Hero', 'Mantle of the Corruptor', 'normal'),
    (30250, 9, 1, 30215, 5, 'Pauldrons of the Vanquished Hero', 'Mantle of the Corruptor', 'normal'),
    (30250, 9, 2, 30215, 5, 'Pauldrons of the Vanquished Hero', 'Mantle of the Corruptor', 'normal'),
    (30244, 9, 0, 30212, 5, 'Helm of the Vanquished Hero', 'Hood of the Corruptor', 'normal'),
    (30244, 9, 1, 30212, 5, 'Helm of the Vanquished Hero', 'Hood of the Corruptor', 'normal'),
    (30244, 9, 2, 30212, 5, 'Helm of the Vanquished Hero', 'Hood of the Corruptor', 'normal'),
    (30241, 9, 0, 30211, 5, 'Gloves of the Vanquished Hero', 'Gloves of the Corruptor', 'normal'),
    (30241, 9, 1, 30211, 5, 'Gloves of the Vanquished Hero', 'Gloves of the Corruptor', 'normal'),
    (30241, 9, 2, 30211, 5, 'Gloves of the Vanquished Hero', 'Gloves of the Corruptor', 'normal'),
    (30238, 9, 0, 30214, 5, 'Chestguard of the Vanquished Hero', 'Robe of the Corruptor', 'normal'),
    (30238, 9, 1, 30214, 5, 'Chestguard of the Vanquished Hero', 'Robe of the Corruptor', 'normal'),
    (30238, 9, 2, 30214, 5, 'Chestguard of the Vanquished Hero', 'Robe of the Corruptor', 'normal');

-- Rogue T5 (Vanquished Champion), normal. All 3 specs are melee DPS - one
-- itemization (Deathmantle) applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (30245, 30248, 30242, 30239, 30236) AND `class_id` = 4;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (30245, 4, 0, 30148, 5, 'Leggings of the Vanquished Champion', 'Deathmantle Legguards', 'normal'),
    (30245, 4, 1, 30148, 5, 'Leggings of the Vanquished Champion', 'Deathmantle Legguards', 'normal'),
    (30245, 4, 2, 30148, 5, 'Leggings of the Vanquished Champion', 'Deathmantle Legguards', 'normal'),
    (30248, 4, 0, 30149, 5, 'Pauldrons of the Vanquished Champion', 'Deathmantle Shoulderpads', 'normal'),
    (30248, 4, 1, 30149, 5, 'Pauldrons of the Vanquished Champion', 'Deathmantle Shoulderpads', 'normal'),
    (30248, 4, 2, 30149, 5, 'Pauldrons of the Vanquished Champion', 'Deathmantle Shoulderpads', 'normal'),
    (30242, 4, 0, 30146, 5, 'Helm of the Vanquished Champion', 'Deathmantle Helm', 'normal'),
    (30242, 4, 1, 30146, 5, 'Helm of the Vanquished Champion', 'Deathmantle Helm', 'normal'),
    (30242, 4, 2, 30146, 5, 'Helm of the Vanquished Champion', 'Deathmantle Helm', 'normal'),
    (30239, 4, 0, 30145, 5, 'Gloves of the Vanquished Champion', 'Deathmantle Handguards', 'normal'),
    (30239, 4, 1, 30145, 5, 'Gloves of the Vanquished Champion', 'Deathmantle Handguards', 'normal'),
    (30239, 4, 2, 30145, 5, 'Gloves of the Vanquished Champion', 'Deathmantle Handguards', 'normal'),
    (30236, 4, 0, 30144, 5, 'Chestguard of the Vanquished Champion', 'Deathmantle Chestguard', 'normal'),
    (30236, 4, 1, 30144, 5, 'Chestguard of the Vanquished Champion', 'Deathmantle Chestguard', 'normal'),
    (30236, 4, 2, 30144, 5, 'Chestguard of the Vanquished Champion', 'Deathmantle Chestguard', 'normal');

-- Druid T5 (Vanquished Defender), normal. Set names are self-descriptive:
-- Wrath (Balance's signature spell), Feral, Life (Restoration).
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (30246, 30249, 30243, 30240, 30237) AND `class_id` = 11;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (30246, 11, 0, 30234, 5, 'Leggings of the Vanquished Defender', 'Nordrassil Wrath-Kilt', 'normal'),
    (30246, 11, 1, 30229, 5, 'Leggings of the Vanquished Defender', 'Nordrassil Feral-Kilt', 'normal'),
    (30246, 11, 2, 30220, 5, 'Leggings of the Vanquished Defender', 'Nordrassil Life-Kilt', 'normal'),
    (30249, 11, 0, 30235, 5, 'Pauldrons of the Vanquished Defender', 'Nordrassil Wrath-Mantle', 'normal'),
    (30249, 11, 1, 30230, 5, 'Pauldrons of the Vanquished Defender', 'Nordrassil Feral-Mantle', 'normal'),
    (30249, 11, 2, 30221, 5, 'Pauldrons of the Vanquished Defender', 'Nordrassil Life-Mantle', 'normal'),
    (30243, 11, 0, 30233, 5, 'Helm of the Vanquished Defender', 'Nordrassil Headpiece', 'normal'),
    (30243, 11, 1, 30228, 5, 'Helm of the Vanquished Defender', 'Nordrassil Headdress', 'normal'),
    (30243, 11, 2, 30219, 5, 'Helm of the Vanquished Defender', 'Nordrassil Headguard', 'normal'),
    (30240, 11, 0, 30232, 5, 'Gloves of the Vanquished Defender', 'Nordrassil Gauntlets', 'normal'),
    (30240, 11, 1, 30223, 5, 'Gloves of the Vanquished Defender', 'Nordrassil Handgrips', 'normal'),
    (30240, 11, 2, 30217, 5, 'Gloves of the Vanquished Defender', 'Nordrassil Gloves', 'normal'),
    (30237, 11, 0, 30231, 5, 'Chestguard of the Vanquished Defender', 'Nordrassil Chestpiece', 'normal'),
    (30237, 11, 1, 30222, 5, 'Chestguard of the Vanquished Defender', 'Nordrassil Chestplate', 'normal'),
    (30237, 11, 2, 30216, 5, 'Chestguard of the Vanquished Defender', 'Nordrassil Chestguard', 'normal');

-- Warrior T5 (Vanquished Defender), normal. Arms/Fury share one itemization
-- (Destroyer, set 657), Protection has its own (Destroyer, set 656).
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (30246, 30249, 30243, 30240, 30237) AND `class_id` = 1;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (30246, 1, 0, 30121, 5, 'Leggings of the Vanquished Defender', 'Destroyer Greaves', 'normal'),
    (30246, 1, 1, 30121, 5, 'Leggings of the Vanquished Defender', 'Destroyer Greaves', 'normal'),
    (30246, 1, 2, 30116, 5, 'Leggings of the Vanquished Defender', 'Destroyer Legguards', 'normal'),
    (30249, 1, 0, 30122, 5, 'Pauldrons of the Vanquished Defender', 'Destroyer Shoulderblades', 'normal'),
    (30249, 1, 1, 30122, 5, 'Pauldrons of the Vanquished Defender', 'Destroyer Shoulderblades', 'normal'),
    (30249, 1, 2, 30117, 5, 'Pauldrons of the Vanquished Defender', 'Destroyer Shoulderguards', 'normal'),
    (30243, 1, 0, 30120, 5, 'Helm of the Vanquished Defender', 'Destroyer Battle-Helm', 'normal'),
    (30243, 1, 1, 30120, 5, 'Helm of the Vanquished Defender', 'Destroyer Battle-Helm', 'normal'),
    (30243, 1, 2, 30115, 5, 'Helm of the Vanquished Defender', 'Destroyer Greathelm', 'normal'),
    (30240, 1, 0, 30119, 5, 'Gloves of the Vanquished Defender', 'Destroyer Gauntlets', 'normal'),
    (30240, 1, 1, 30119, 5, 'Gloves of the Vanquished Defender', 'Destroyer Gauntlets', 'normal'),
    (30240, 1, 2, 30114, 5, 'Gloves of the Vanquished Defender', 'Destroyer Handguards', 'normal'),
    (30237, 1, 0, 30118, 5, 'Chestguard of the Vanquished Defender', 'Destroyer Breastplate', 'normal'),
    (30237, 1, 1, 30118, 5, 'Chestguard of the Vanquished Defender', 'Destroyer Breastplate', 'normal'),
    (30237, 1, 2, 30113, 5, 'Chestguard of the Vanquished Defender', 'Destroyer Chestguard', 'normal');

-- Priest T5 (Vanquished Defender), normal. Discipline/Holy share one
-- itemization (Avatar, set 665), Shadow has its own (Avatar, set 666).
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (30246, 30249, 30243, 30240, 30237) AND `class_id` = 5;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (30246, 5, 0, 30153, 5, 'Leggings of the Vanquished Defender', 'Breeches of the Avatar', 'normal'),
    (30246, 5, 1, 30153, 5, 'Leggings of the Vanquished Defender', 'Breeches of the Avatar', 'normal'),
    (30246, 5, 2, 30162, 5, 'Leggings of the Vanquished Defender', 'Leggings of the Avatar', 'normal'),
    (30249, 5, 0, 30154, 5, 'Pauldrons of the Vanquished Defender', 'Mantle of the Avatar', 'normal'),
    (30249, 5, 1, 30154, 5, 'Pauldrons of the Vanquished Defender', 'Mantle of the Avatar', 'normal'),
    (30249, 5, 2, 30163, 5, 'Pauldrons of the Vanquished Defender', 'Wings of the Avatar', 'normal'),
    (30243, 5, 0, 30152, 5, 'Helm of the Vanquished Defender', 'Cowl of the Avatar', 'normal'),
    (30243, 5, 1, 30152, 5, 'Helm of the Vanquished Defender', 'Cowl of the Avatar', 'normal'),
    (30243, 5, 2, 30161, 5, 'Helm of the Vanquished Defender', 'Hood of the Avatar', 'normal'),
    (30240, 5, 0, 30151, 5, 'Gloves of the Vanquished Defender', 'Gloves of the Avatar', 'normal'),
    (30240, 5, 1, 30151, 5, 'Gloves of the Vanquished Defender', 'Gloves of the Avatar', 'normal'),
    (30240, 5, 2, 30160, 5, 'Gloves of the Vanquished Defender', 'Handguards of the Avatar', 'normal'),
    (30237, 5, 0, 30150, 5, 'Chestguard of the Vanquished Defender', 'Vestments of the Avatar', 'normal'),
    (30237, 5, 1, 30150, 5, 'Chestguard of the Vanquished Defender', 'Vestments of the Avatar', 'normal'),
    (30237, 5, 2, 30159, 5, 'Chestguard of the Vanquished Defender', 'Shroud of the Avatar', 'normal');

-- Paladin T5 (Vanquished Champion), normal. Holy (set 627), Protection
-- (set 628), Retribution (set 629) - all distinct itemizations.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (30245, 30248, 30242, 30239, 30236) AND `class_id` = 2;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (30245, 2, 0, 30137, 5, 'Leggings of the Vanquished Champion', 'Crystalforge Leggings', 'normal'),
    (30245, 2, 1, 30126, 5, 'Leggings of the Vanquished Champion', 'Crystalforge Legguards', 'normal'),
    (30245, 2, 2, 30132, 5, 'Leggings of the Vanquished Champion', 'Crystalforge Greaves', 'normal'),
    (30248, 2, 0, 30138, 5, 'Pauldrons of the Vanquished Champion', 'Crystalforge Pauldrons', 'normal'),
    (30248, 2, 1, 30127, 5, 'Pauldrons of the Vanquished Champion', 'Crystalforge Shoulderguards', 'normal'),
    (30248, 2, 2, 30133, 5, 'Pauldrons of the Vanquished Champion', 'Crystalforge Shoulderbraces', 'normal'),
    (30242, 2, 0, 30136, 5, 'Helm of the Vanquished Champion', 'Crystalforge Greathelm', 'normal'),
    (30242, 2, 1, 30125, 5, 'Helm of the Vanquished Champion', 'Crystalforge Faceguard', 'normal'),
    (30242, 2, 2, 30131, 5, 'Helm of the Vanquished Champion', 'Crystalforge War-Helm', 'normal'),
    (30239, 2, 0, 30135, 5, 'Gloves of the Vanquished Champion', 'Crystalforge Gloves', 'normal'),
    (30239, 2, 1, 30124, 5, 'Gloves of the Vanquished Champion', 'Crystalforge Handguards', 'normal'),
    (30239, 2, 2, 30130, 5, 'Gloves of the Vanquished Champion', 'Crystalforge Gauntlets', 'normal'),
    (30236, 2, 0, 30134, 5, 'Chestguard of the Vanquished Champion', 'Crystalforge Chestpiece', 'normal'),
    (30236, 2, 1, 30123, 5, 'Chestguard of the Vanquished Champion', 'Crystalforge Chestguard', 'normal'),
    (30236, 2, 2, 30129, 5, 'Chestguard of the Vanquished Champion', 'Crystalforge Breastplate', 'normal');

-- Shaman T5 (Vanquished Champion), normal. Elemental (set 635), Enhancement
-- (set 636), Restoration (set 634) - all distinct itemizations.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (30245, 30248, 30242, 30239, 30236) AND `class_id` = 7;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (30245, 7, 0, 30172, 5, 'Leggings of the Vanquished Champion', 'Cataclysm Leggings', 'normal'),
    (30245, 7, 1, 30192, 5, 'Leggings of the Vanquished Champion', 'Cataclysm Legplates', 'normal'),
    (30245, 7, 2, 30167, 5, 'Leggings of the Vanquished Champion', 'Cataclysm Legguards', 'normal'),
    (30248, 7, 0, 30173, 5, 'Pauldrons of the Vanquished Champion', 'Cataclysm Shoulderpads', 'normal'),
    (30248, 7, 1, 30194, 5, 'Pauldrons of the Vanquished Champion', 'Cataclysm Shoulderplates', 'normal'),
    (30248, 7, 2, 30168, 5, 'Pauldrons of the Vanquished Champion', 'Cataclysm Shoulderguards', 'normal'),
    (30242, 7, 0, 30171, 5, 'Helm of the Vanquished Champion', 'Cataclysm Headpiece', 'normal'),
    (30242, 7, 1, 30190, 5, 'Helm of the Vanquished Champion', 'Cataclysm Helm', 'normal'),
    (30242, 7, 2, 30166, 5, 'Helm of the Vanquished Champion', 'Cataclysm Headguard', 'normal'),
    (30239, 7, 0, 30170, 5, 'Gloves of the Vanquished Champion', 'Cataclysm Handgrips', 'normal'),
    (30239, 7, 1, 30189, 5, 'Gloves of the Vanquished Champion', 'Cataclysm Gauntlets', 'normal'),
    (30239, 7, 2, 30165, 5, 'Gloves of the Vanquished Champion', 'Cataclysm Gloves', 'normal'),
    (30236, 7, 0, 30169, 5, 'Chestguard of the Vanquished Champion', 'Cataclysm Chestpiece', 'normal'),
    (30236, 7, 1, 30185, 5, 'Chestguard of the Vanquished Champion', 'Cataclysm Chestplate', 'normal'),
    (30236, 7, 2, 30164, 5, 'Chestguard of the Vanquished Champion', 'Cataclysm Chestguard', 'normal');

-- T6 grouping changes from T4/T5: Conqueror = Paladin/Priest/Warlock,
-- Vanquisher = Druid/Mage/Rogue, Protector = Shaman/Hunter/Warrior.

-- Warrior T6 (Forgotten Protector), normal. Arms/Fury share one itemization
-- (Onslaught, set 672), Protection has its own (Onslaught, set 673).
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (31100, 31103, 31095, 31094, 31091) AND `class_id` = 1;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (31100, 1, 0, 30977, 6, 'Leggings of the Forgotten Protector', 'Onslaught Greaves', 'normal'),
    (31100, 1, 1, 30977, 6, 'Leggings of the Forgotten Protector', 'Onslaught Greaves', 'normal'),
    (31100, 1, 2, 30978, 6, 'Leggings of the Forgotten Protector', 'Onslaught Legguards', 'normal'),
    (31103, 1, 0, 30979, 6, 'Pauldrons of the Forgotten Protector', 'Onslaught Shoulderblades', 'normal'),
    (31103, 1, 1, 30979, 6, 'Pauldrons of the Forgotten Protector', 'Onslaught Shoulderblades', 'normal'),
    (31103, 1, 2, 30980, 6, 'Pauldrons of the Forgotten Protector', 'Onslaught Shoulderguards', 'normal'),
    (31095, 1, 0, 30972, 6, 'Helm of the Forgotten Protector', 'Onslaught Battle-Helm', 'normal'),
    (31095, 1, 1, 30972, 6, 'Helm of the Forgotten Protector', 'Onslaught Battle-Helm', 'normal'),
    (31095, 1, 2, 30974, 6, 'Helm of the Forgotten Protector', 'Onslaught Greathelm', 'normal'),
    (31094, 1, 0, 30969, 6, 'Gloves of the Forgotten Protector', 'Onslaught Gauntlets', 'normal'),
    (31094, 1, 1, 30969, 6, 'Gloves of the Forgotten Protector', 'Onslaught Gauntlets', 'normal'),
    (31094, 1, 2, 30970, 6, 'Gloves of the Forgotten Protector', 'Onslaught Handguards', 'normal'),
    (31091, 1, 0, 30975, 6, 'Chestguard of the Forgotten Protector', 'Onslaught Breastplate', 'normal'),
    (31091, 1, 1, 30975, 6, 'Chestguard of the Forgotten Protector', 'Onslaught Breastplate', 'normal'),
    (31091, 1, 2, 30976, 6, 'Chestguard of the Forgotten Protector', 'Onslaught Chestguard', 'normal');

-- Priest T6 (Forgotten Conqueror), normal. Discipline/Holy share one
-- itemization (Absolution, set 675), Shadow has its own (Absolution, set 674).
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (31098, 31101, 31097, 31092, 31089) AND `class_id` = 5;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (31098, 5, 0, 31068, 6, 'Leggings of the Forgotten Conqueror', 'Breeches of Absolution', 'normal'),
    (31098, 5, 1, 31068, 6, 'Leggings of the Forgotten Conqueror', 'Breeches of Absolution', 'normal'),
    (31098, 5, 2, 31067, 6, 'Leggings of the Forgotten Conqueror', 'Leggings of Absolution', 'normal'),
    (31101, 5, 0, 31069, 6, 'Pauldrons of the Forgotten Conqueror', 'Mantle of Absolution', 'normal'),
    (31101, 5, 1, 31069, 6, 'Pauldrons of the Forgotten Conqueror', 'Mantle of Absolution', 'normal'),
    (31101, 5, 2, 31070, 6, 'Pauldrons of the Forgotten Conqueror', 'Shoulderpads of Absolution', 'normal'),
    (31097, 5, 0, 31063, 6, 'Helm of the Forgotten Conqueror', 'Cowl of Absolution', 'normal'),
    (31097, 5, 1, 31063, 6, 'Helm of the Forgotten Conqueror', 'Cowl of Absolution', 'normal'),
    (31097, 5, 2, 31064, 6, 'Helm of the Forgotten Conqueror', 'Hood of Absolution', 'normal'),
    (31092, 5, 0, 31060, 6, 'Gloves of the Forgotten Conqueror', 'Gloves of Absolution', 'normal'),
    (31092, 5, 1, 31060, 6, 'Gloves of the Forgotten Conqueror', 'Gloves of Absolution', 'normal'),
    (31092, 5, 2, 31061, 6, 'Gloves of the Forgotten Conqueror', 'Handguards of Absolution', 'normal'),
    (31089, 5, 0, 31066, 6, 'Chestguard of the Forgotten Conqueror', 'Vestments of Absolution', 'normal'),
    (31089, 5, 1, 31066, 6, 'Chestguard of the Forgotten Conqueror', 'Vestments of Absolution', 'normal'),
    (31089, 5, 2, 31065, 6, 'Chestguard of the Forgotten Conqueror', 'Shroud of Absolution', 'normal');

-- Paladin T6 (Forgotten Conqueror), normal. Holy (set 681), Protection
-- (set 679), Retribution (set 680) - all distinct itemizations.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (31098, 31101, 31097, 31092, 31089) AND `class_id` = 2;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (31098, 2, 0, 30994, 6, 'Leggings of the Forgotten Conqueror', 'Lightbringer Leggings', 'normal'),
    (31098, 2, 1, 30995, 6, 'Leggings of the Forgotten Conqueror', 'Lightbringer Legguards', 'normal'),
    (31098, 2, 2, 30993, 6, 'Leggings of the Forgotten Conqueror', 'Lightbringer Greaves', 'normal'),
    (31101, 2, 0, 30996, 6, 'Pauldrons of the Forgotten Conqueror', 'Lightbringer Pauldrons', 'normal'),
    (31101, 2, 1, 30998, 6, 'Pauldrons of the Forgotten Conqueror', 'Lightbringer Shoulderguards', 'normal'),
    (31101, 2, 2, 30997, 6, 'Pauldrons of the Forgotten Conqueror', 'Lightbringer Shoulderbraces', 'normal'),
    (31097, 2, 0, 30988, 6, 'Helm of the Forgotten Conqueror', 'Lightbringer Greathelm', 'normal'),
    (31097, 2, 1, 30987, 6, 'Helm of the Forgotten Conqueror', 'Lightbringer Faceguard', 'normal'),
    (31097, 2, 2, 30989, 6, 'Helm of the Forgotten Conqueror', 'Lightbringer War-Helm', 'normal'),
    (31092, 2, 0, 30983, 6, 'Gloves of the Forgotten Conqueror', 'Lightbringer Gloves', 'normal'),
    (31092, 2, 1, 30985, 6, 'Gloves of the Forgotten Conqueror', 'Lightbringer Handguards', 'normal'),
    (31092, 2, 2, 30982, 6, 'Gloves of the Forgotten Conqueror', 'Lightbringer Gauntlets', 'normal'),
    (31089, 2, 0, 30992, 6, 'Chestguard of the Forgotten Conqueror', 'Lightbringer Chestpiece', 'normal'),
    (31089, 2, 1, 30991, 6, 'Chestguard of the Forgotten Conqueror', 'Lightbringer Chestguard', 'normal'),
    (31089, 2, 2, 30990, 6, 'Chestguard of the Forgotten Conqueror', 'Lightbringer Breastplate', 'normal');

-- Shaman T6 (Forgotten Protector), normal. Elemental (set 684), Enhancement
-- (set 682), Restoration (set 683) - all distinct itemizations.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (31100, 31103, 31095, 31094, 31091) AND `class_id` = 7;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (31100, 7, 0, 31020, 6, 'Leggings of the Forgotten Protector', 'Skyshatter Legguards', 'normal'),
    (31100, 7, 1, 31021, 6, 'Leggings of the Forgotten Protector', 'Skyshatter Pants', 'normal'),
    (31100, 7, 2, 31019, 6, 'Leggings of the Forgotten Protector', 'Skyshatter Leggings', 'normal'),
    (31103, 7, 0, 31023, 6, 'Pauldrons of the Forgotten Protector', 'Skyshatter Mantle', 'normal'),
    (31103, 7, 1, 31024, 6, 'Pauldrons of the Forgotten Protector', 'Skyshatter Pauldrons', 'normal'),
    (31103, 7, 2, 31022, 6, 'Pauldrons of the Forgotten Protector', 'Skyshatter Shoulderpads', 'normal'),
    (31095, 7, 0, 31014, 6, 'Helm of the Forgotten Protector', 'Skyshatter Headguard', 'normal'),
    (31095, 7, 1, 31015, 6, 'Helm of the Forgotten Protector', 'Skyshatter Cover', 'normal'),
    (31095, 7, 2, 31012, 6, 'Helm of the Forgotten Protector', 'Skyshatter Helmet', 'normal'),
    (31094, 7, 0, 31008, 6, 'Gloves of the Forgotten Protector', 'Skyshatter Gauntlets', 'normal'),
    (31094, 7, 1, 31011, 6, 'Gloves of the Forgotten Protector', 'Skyshatter Grips', 'normal'),
    (31094, 7, 2, 31007, 6, 'Gloves of the Forgotten Protector', 'Skyshatter Gloves', 'normal'),
    (31091, 7, 0, 31017, 6, 'Chestguard of the Forgotten Protector', 'Skyshatter Breastplate', 'normal'),
    (31091, 7, 1, 31018, 6, 'Chestguard of the Forgotten Protector', 'Skyshatter Tunic', 'normal'),
    (31091, 7, 2, 31016, 6, 'Chestguard of the Forgotten Protector', 'Skyshatter Chestguard', 'normal');

-- Druid T6 (Forgotten Vanquisher), normal. Balance (set 677), Feral
-- (set 676), Restoration (set 678) - all distinct itemizations.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (31099, 31102, 31096, 31093, 31090) AND `class_id` = 11;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (31099, 11, 0, 31046, 6, 'Leggings of the Forgotten Vanquisher', 'Thunderheart Pants', 'normal'),
    (31099, 11, 1, 31044, 6, 'Leggings of the Forgotten Vanquisher', 'Thunderheart Leggings', 'normal'),
    (31099, 11, 2, 31045, 6, 'Leggings of the Forgotten Vanquisher', 'Thunderheart Legguards', 'normal'),
    (31102, 11, 0, 31049, 6, 'Pauldrons of the Forgotten Vanquisher', 'Thunderheart Shoulderpads', 'normal'),
    (31102, 11, 1, 31048, 6, 'Pauldrons of the Forgotten Vanquisher', 'Thunderheart Pauldrons', 'normal'),
    (31102, 11, 2, 31047, 6, 'Pauldrons of the Forgotten Vanquisher', 'Thunderheart Spaulders', 'normal'),
    (31096, 11, 0, 31040, 6, 'Helm of the Forgotten Vanquisher', 'Thunderheart Headguard', 'normal'),
    (31096, 11, 1, 31039, 6, 'Helm of the Forgotten Vanquisher', 'Thunderheart Cover', 'normal'),
    (31096, 11, 2, 31037, 6, 'Helm of the Forgotten Vanquisher', 'Thunderheart Helmet', 'normal'),
    (31093, 11, 0, 31035, 6, 'Gloves of the Forgotten Vanquisher', 'Thunderheart Handguards', 'normal'),
    (31093, 11, 1, 31034, 6, 'Gloves of the Forgotten Vanquisher', 'Thunderheart Gauntlets', 'normal'),
    (31093, 11, 2, 31032, 6, 'Gloves of the Forgotten Vanquisher', 'Thunderheart Gloves', 'normal'),
    (31090, 11, 0, 31043, 6, 'Chestguard of the Forgotten Vanquisher', 'Thunderheart Vest', 'normal'),
    (31090, 11, 1, 31042, 6, 'Chestguard of the Forgotten Vanquisher', 'Thunderheart Chestguard', 'normal'),
    (31090, 11, 2, 31041, 6, 'Chestguard of the Forgotten Vanquisher', 'Thunderheart Tunic', 'normal');

-- Hunter T6 (Forgotten Protector), normal. All 3 specs are ranged DPS - one
-- itemization (Gronnstalker's) applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (31100, 31103, 31095, 31094, 31091) AND `class_id` = 3;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (31100, 3, 0, 31005, 6, 'Leggings of the Forgotten Protector', 'Gronnstalker''s Leggings', 'normal'),
    (31100, 3, 1, 31005, 6, 'Leggings of the Forgotten Protector', 'Gronnstalker''s Leggings', 'normal'),
    (31100, 3, 2, 31005, 6, 'Leggings of the Forgotten Protector', 'Gronnstalker''s Leggings', 'normal'),
    (31103, 3, 0, 31006, 6, 'Pauldrons of the Forgotten Protector', 'Gronnstalker''s Spaulders', 'normal'),
    (31103, 3, 1, 31006, 6, 'Pauldrons of the Forgotten Protector', 'Gronnstalker''s Spaulders', 'normal'),
    (31103, 3, 2, 31006, 6, 'Pauldrons of the Forgotten Protector', 'Gronnstalker''s Spaulders', 'normal'),
    (31095, 3, 0, 31003, 6, 'Helm of the Forgotten Protector', 'Gronnstalker''s Helmet', 'normal'),
    (31095, 3, 1, 31003, 6, 'Helm of the Forgotten Protector', 'Gronnstalker''s Helmet', 'normal'),
    (31095, 3, 2, 31003, 6, 'Helm of the Forgotten Protector', 'Gronnstalker''s Helmet', 'normal'),
    (31094, 3, 0, 31001, 6, 'Gloves of the Forgotten Protector', 'Gronnstalker''s Gloves', 'normal'),
    (31094, 3, 1, 31001, 6, 'Gloves of the Forgotten Protector', 'Gronnstalker''s Gloves', 'normal'),
    (31094, 3, 2, 31001, 6, 'Gloves of the Forgotten Protector', 'Gronnstalker''s Gloves', 'normal'),
    (31091, 3, 0, 31004, 6, 'Chestguard of the Forgotten Protector', 'Gronnstalker''s Chestguard', 'normal'),
    (31091, 3, 1, 31004, 6, 'Chestguard of the Forgotten Protector', 'Gronnstalker''s Chestguard', 'normal'),
    (31091, 3, 2, 31004, 6, 'Chestguard of the Forgotten Protector', 'Gronnstalker''s Chestguard', 'normal');

-- Rogue T6 (Forgotten Vanquisher), normal. All 3 specs are melee DPS - one
-- itemization (Slayer's) applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (31099, 31102, 31096, 31093, 31090) AND `class_id` = 4;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (31099, 4, 0, 31029, 6, 'Leggings of the Forgotten Vanquisher', 'Slayer''s Legguards', 'normal'),
    (31099, 4, 1, 31029, 6, 'Leggings of the Forgotten Vanquisher', 'Slayer''s Legguards', 'normal'),
    (31099, 4, 2, 31029, 6, 'Leggings of the Forgotten Vanquisher', 'Slayer''s Legguards', 'normal'),
    (31102, 4, 0, 31030, 6, 'Pauldrons of the Forgotten Vanquisher', 'Slayer''s Shoulderpads', 'normal'),
    (31102, 4, 1, 31030, 6, 'Pauldrons of the Forgotten Vanquisher', 'Slayer''s Shoulderpads', 'normal'),
    (31102, 4, 2, 31030, 6, 'Pauldrons of the Forgotten Vanquisher', 'Slayer''s Shoulderpads', 'normal'),
    (31096, 4, 0, 31027, 6, 'Helm of the Forgotten Vanquisher', 'Slayer''s Helm', 'normal'),
    (31096, 4, 1, 31027, 6, 'Helm of the Forgotten Vanquisher', 'Slayer''s Helm', 'normal'),
    (31096, 4, 2, 31027, 6, 'Helm of the Forgotten Vanquisher', 'Slayer''s Helm', 'normal'),
    (31093, 4, 0, 31026, 6, 'Gloves of the Forgotten Vanquisher', 'Slayer''s Handguards', 'normal'),
    (31093, 4, 1, 31026, 6, 'Gloves of the Forgotten Vanquisher', 'Slayer''s Handguards', 'normal'),
    (31093, 4, 2, 31026, 6, 'Gloves of the Forgotten Vanquisher', 'Slayer''s Handguards', 'normal'),
    (31090, 4, 0, 31028, 6, 'Chestguard of the Forgotten Vanquisher', 'Slayer''s Chestguard', 'normal'),
    (31090, 4, 1, 31028, 6, 'Chestguard of the Forgotten Vanquisher', 'Slayer''s Chestguard', 'normal'),
    (31090, 4, 2, 31028, 6, 'Chestguard of the Forgotten Vanquisher', 'Slayer''s Chestguard', 'normal');

-- Mage T6 (Forgotten Vanquisher), normal. All 3 specs are caster DPS - one
-- itemization (Tempest) applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (31099, 31102, 31096, 31093, 31090) AND `class_id` = 8;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (31099, 8, 0, 31058, 6, 'Leggings of the Forgotten Vanquisher', 'Leggings of the Tempest', 'normal'),
    (31099, 8, 1, 31058, 6, 'Leggings of the Forgotten Vanquisher', 'Leggings of the Tempest', 'normal'),
    (31099, 8, 2, 31058, 6, 'Leggings of the Forgotten Vanquisher', 'Leggings of the Tempest', 'normal'),
    (31102, 8, 0, 31059, 6, 'Pauldrons of the Forgotten Vanquisher', 'Mantle of the Tempest', 'normal'),
    (31102, 8, 1, 31059, 6, 'Pauldrons of the Forgotten Vanquisher', 'Mantle of the Tempest', 'normal'),
    (31102, 8, 2, 31059, 6, 'Pauldrons of the Forgotten Vanquisher', 'Mantle of the Tempest', 'normal'),
    (31096, 8, 0, 31056, 6, 'Helm of the Forgotten Vanquisher', 'Cowl of the Tempest', 'normal'),
    (31096, 8, 1, 31056, 6, 'Helm of the Forgotten Vanquisher', 'Cowl of the Tempest', 'normal'),
    (31096, 8, 2, 31056, 6, 'Helm of the Forgotten Vanquisher', 'Cowl of the Tempest', 'normal'),
    (31093, 8, 0, 31055, 6, 'Gloves of the Forgotten Vanquisher', 'Gloves of the Tempest', 'normal'),
    (31093, 8, 1, 31055, 6, 'Gloves of the Forgotten Vanquisher', 'Gloves of the Tempest', 'normal'),
    (31093, 8, 2, 31055, 6, 'Gloves of the Forgotten Vanquisher', 'Gloves of the Tempest', 'normal'),
    (31090, 8, 0, 31057, 6, 'Chestguard of the Forgotten Vanquisher', 'Robes of the Tempest', 'normal'),
    (31090, 8, 1, 31057, 6, 'Chestguard of the Forgotten Vanquisher', 'Robes of the Tempest', 'normal'),
    (31090, 8, 2, 31057, 6, 'Chestguard of the Forgotten Vanquisher', 'Robes of the Tempest', 'normal');

-- Warlock T6 (Forgotten Conqueror), normal. All 3 specs are caster DPS - one
-- itemization (Malefic) applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (31098, 31101, 31097, 31092, 31089) AND `class_id` = 9;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (31098, 9, 0, 31053, 6, 'Leggings of the Forgotten Conqueror', 'Leggings of the Malefic', 'normal'),
    (31098, 9, 1, 31053, 6, 'Leggings of the Forgotten Conqueror', 'Leggings of the Malefic', 'normal'),
    (31098, 9, 2, 31053, 6, 'Leggings of the Forgotten Conqueror', 'Leggings of the Malefic', 'normal'),
    (31101, 9, 0, 31054, 6, 'Pauldrons of the Forgotten Conqueror', 'Mantle of the Malefic', 'normal'),
    (31101, 9, 1, 31054, 6, 'Pauldrons of the Forgotten Conqueror', 'Mantle of the Malefic', 'normal'),
    (31101, 9, 2, 31054, 6, 'Pauldrons of the Forgotten Conqueror', 'Mantle of the Malefic', 'normal'),
    (31097, 9, 0, 31051, 6, 'Helm of the Forgotten Conqueror', 'Hood of the Malefic', 'normal'),
    (31097, 9, 1, 31051, 6, 'Helm of the Forgotten Conqueror', 'Hood of the Malefic', 'normal'),
    (31097, 9, 2, 31051, 6, 'Helm of the Forgotten Conqueror', 'Hood of the Malefic', 'normal'),
    (31092, 9, 0, 31050, 6, 'Gloves of the Forgotten Conqueror', 'Gloves of the Malefic', 'normal'),
    (31092, 9, 1, 31050, 6, 'Gloves of the Forgotten Conqueror', 'Gloves of the Malefic', 'normal'),
    (31092, 9, 2, 31050, 6, 'Gloves of the Forgotten Conqueror', 'Gloves of the Malefic', 'normal'),
    (31089, 9, 0, 31052, 6, 'Chestguard of the Forgotten Conqueror', 'Robe of the Malefic', 'normal'),
    (31089, 9, 1, 31052, 6, 'Chestguard of the Forgotten Conqueror', 'Robe of the Malefic', 'normal'),
    (31089, 9, 2, 31052, 6, 'Chestguard of the Forgotten Conqueror', 'Robe of the Malefic', 'normal');

-- T6 also introduced Belt/Bracers/Boots tokens beyond the classic 5 slots -
-- initially missed. Each piece carries the same itemset id as its class's
-- already-confirmed 5-piece set, so role pairing carries over with no new
-- confirmation needed (spot-checked: 34858 Vanquisher Boots -> itemset 677 ->
-- 'Thunderheart Footwraps' = Balance Druid, matches the known 677=Balance).

-- Warrior T6 extra slots (Forgotten Protector).
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (34851, 34854, 34857) AND `class_id` = 1;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (34851, 1, 0, 34441, 6, 'Bracers of the Forgotten Protector', 'Onslaught Bracers', 'normal'),
    (34851, 1, 1, 34441, 6, 'Bracers of the Forgotten Protector', 'Onslaught Bracers', 'normal'),
    (34851, 1, 2, 34442, 6, 'Bracers of the Forgotten Protector', 'Onslaught Wristguards', 'normal'),
    (34854, 1, 0, 34546, 6, 'Belt of the Forgotten Protector', 'Onslaught Belt', 'normal'),
    (34854, 1, 1, 34546, 6, 'Belt of the Forgotten Protector', 'Onslaught Belt', 'normal'),
    (34854, 1, 2, 34547, 6, 'Belt of the Forgotten Protector', 'Onslaught Waistguard', 'normal'),
    (34857, 1, 0, 34569, 6, 'Boots of the Forgotten Protector', 'Onslaught Treads', 'normal'),
    (34857, 1, 1, 34569, 6, 'Boots of the Forgotten Protector', 'Onslaught Treads', 'normal'),
    (34857, 1, 2, 34568, 6, 'Boots of the Forgotten Protector', 'Onslaught Boots', 'normal');

-- Priest T6 extra slots (Forgotten Conqueror).
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (34848, 34853, 34856) AND `class_id` = 5;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (34848, 5, 0, 34435, 6, 'Bracers of the Forgotten Conqueror', 'Cuffs of Absolution', 'normal'),
    (34848, 5, 1, 34435, 6, 'Bracers of the Forgotten Conqueror', 'Cuffs of Absolution', 'normal'),
    (34848, 5, 2, 34434, 6, 'Bracers of the Forgotten Conqueror', 'Bracers of Absolution', 'normal'),
    (34853, 5, 0, 34527, 6, 'Belt of the Forgotten Conqueror', 'Belt of Absolution', 'normal'),
    (34853, 5, 1, 34527, 6, 'Belt of the Forgotten Conqueror', 'Belt of Absolution', 'normal'),
    (34853, 5, 2, 34528, 6, 'Belt of the Forgotten Conqueror', 'Cord of Absolution', 'normal'),
    (34856, 5, 0, 34562, 6, 'Boots of the Forgotten Conqueror', 'Boots of Absolution', 'normal'),
    (34856, 5, 1, 34562, 6, 'Boots of the Forgotten Conqueror', 'Boots of Absolution', 'normal'),
    (34856, 5, 2, 34563, 6, 'Boots of the Forgotten Conqueror', 'Treads of Absolution', 'normal');

-- Paladin T6 extra slots (Forgotten Conqueror).
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (34848, 34853, 34856) AND `class_id` = 2;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (34848, 2, 0, 34432, 6, 'Bracers of the Forgotten Conqueror', 'Lightbringer Bracers', 'normal'),
    (34848, 2, 1, 34433, 6, 'Bracers of the Forgotten Conqueror', 'Lightbringer Wristguards', 'normal'),
    (34848, 2, 2, 34431, 6, 'Bracers of the Forgotten Conqueror', 'Lightbringer Bands', 'normal'),
    (34853, 2, 0, 34487, 6, 'Belt of the Forgotten Conqueror', 'Lightbringer Belt', 'normal'),
    (34853, 2, 1, 34488, 6, 'Belt of the Forgotten Conqueror', 'Lightbringer Waistguard', 'normal'),
    (34853, 2, 2, 34485, 6, 'Belt of the Forgotten Conqueror', 'Lightbringer Girdle', 'normal'),
    (34856, 2, 0, 34559, 6, 'Boots of the Forgotten Conqueror', 'Lightbringer Treads', 'normal'),
    (34856, 2, 1, 34560, 6, 'Boots of the Forgotten Conqueror', 'Lightbringer Stompers', 'normal'),
    (34856, 2, 2, 34561, 6, 'Boots of the Forgotten Conqueror', 'Lightbringer Boots', 'normal');

-- Shaman T6 extra slots (Forgotten Protector).
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (34851, 34854, 34857) AND `class_id` = 7;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (34851, 7, 0, 34437, 6, 'Bracers of the Forgotten Protector', 'Skyshatter Bands', 'normal'),
    (34851, 7, 1, 34439, 6, 'Bracers of the Forgotten Protector', 'Skyshatter Wristguards', 'normal'),
    (34851, 7, 2, 34438, 6, 'Bracers of the Forgotten Protector', 'Skyshatter Bracers', 'normal'),
    (34854, 7, 0, 34542, 6, 'Belt of the Forgotten Protector', 'Skyshatter Cord', 'normal'),
    (34854, 7, 1, 34545, 6, 'Belt of the Forgotten Protector', 'Skyshatter Girdle', 'normal'),
    (34854, 7, 2, 34543, 6, 'Belt of the Forgotten Protector', 'Skyshatter Belt', 'normal'),
    (34857, 7, 0, 34566, 6, 'Boots of the Forgotten Protector', 'Skyshatter Treads', 'normal'),
    (34857, 7, 1, 34567, 6, 'Boots of the Forgotten Protector', 'Skyshatter Greaves', 'normal'),
    (34857, 7, 2, 34565, 6, 'Boots of the Forgotten Protector', 'Skyshatter Boots', 'normal');

-- Druid T6 extra slots (Forgotten Vanquisher).
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (34852, 34855, 34858) AND `class_id` = 11;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (34852, 11, 0, 34446, 6, 'Bracers of the Forgotten Vanquisher', 'Thunderheart Bands', 'normal'),
    (34852, 11, 1, 34444, 6, 'Bracers of the Forgotten Vanquisher', 'Thunderheart Wristguards', 'normal'),
    (34852, 11, 2, 34445, 6, 'Bracers of the Forgotten Vanquisher', 'Thunderheart Bracers', 'normal'),
    (34855, 11, 0, 34555, 6, 'Belt of the Forgotten Vanquisher', 'Thunderheart Cord', 'normal'),
    (34855, 11, 1, 34556, 6, 'Belt of the Forgotten Vanquisher', 'Thunderheart Waistguard', 'normal'),
    (34855, 11, 2, 34554, 6, 'Belt of the Forgotten Vanquisher', 'Thunderheart Belt', 'normal'),
    (34858, 11, 0, 34572, 6, 'Boots of the Forgotten Vanquisher', 'Thunderheart Footwraps', 'normal'),
    (34858, 11, 1, 34573, 6, 'Boots of the Forgotten Vanquisher', 'Thunderheart Treads', 'normal'),
    (34858, 11, 2, 34571, 6, 'Boots of the Forgotten Vanquisher', 'Thunderheart Boots', 'normal');

-- Hunter T6 extra slots (Forgotten Protector). Single itemization for all specs.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (34851, 34854, 34857) AND `class_id` = 3;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (34851, 3, 0, 34443, 6, 'Bracers of the Forgotten Protector', 'Gronnstalker''s Bracers', 'normal'),
    (34851, 3, 1, 34443, 6, 'Bracers of the Forgotten Protector', 'Gronnstalker''s Bracers', 'normal'),
    (34851, 3, 2, 34443, 6, 'Bracers of the Forgotten Protector', 'Gronnstalker''s Bracers', 'normal'),
    (34854, 3, 0, 34549, 6, 'Belt of the Forgotten Protector', 'Gronnstalker''s Belt', 'normal'),
    (34854, 3, 1, 34549, 6, 'Belt of the Forgotten Protector', 'Gronnstalker''s Belt', 'normal'),
    (34854, 3, 2, 34549, 6, 'Belt of the Forgotten Protector', 'Gronnstalker''s Belt', 'normal'),
    (34857, 3, 0, 34570, 6, 'Boots of the Forgotten Protector', 'Gronnstalker''s Boots', 'normal'),
    (34857, 3, 1, 34570, 6, 'Boots of the Forgotten Protector', 'Gronnstalker''s Boots', 'normal'),
    (34857, 3, 2, 34570, 6, 'Boots of the Forgotten Protector', 'Gronnstalker''s Boots', 'normal');

-- Rogue T6 extra slots (Forgotten Vanquisher). Single itemization for all specs.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (34852, 34855, 34858) AND `class_id` = 4;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (34852, 4, 0, 34448, 6, 'Bracers of the Forgotten Vanquisher', 'Slayer''s Bracers', 'normal'),
    (34852, 4, 1, 34448, 6, 'Bracers of the Forgotten Vanquisher', 'Slayer''s Bracers', 'normal'),
    (34852, 4, 2, 34448, 6, 'Bracers of the Forgotten Vanquisher', 'Slayer''s Bracers', 'normal'),
    (34855, 4, 0, 34558, 6, 'Belt of the Forgotten Vanquisher', 'Slayer''s Belt', 'normal'),
    (34855, 4, 1, 34558, 6, 'Belt of the Forgotten Vanquisher', 'Slayer''s Belt', 'normal'),
    (34855, 4, 2, 34558, 6, 'Belt of the Forgotten Vanquisher', 'Slayer''s Belt', 'normal'),
    (34858, 4, 0, 34575, 6, 'Boots of the Forgotten Vanquisher', 'Slayer''s Boots', 'normal'),
    (34858, 4, 1, 34575, 6, 'Boots of the Forgotten Vanquisher', 'Slayer''s Boots', 'normal'),
    (34858, 4, 2, 34575, 6, 'Boots of the Forgotten Vanquisher', 'Slayer''s Boots', 'normal');

-- Mage T6 extra slots (Forgotten Vanquisher). Single itemization for all specs.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (34852, 34855, 34858) AND `class_id` = 8;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (34852, 8, 0, 34447, 6, 'Bracers of the Forgotten Vanquisher', 'Bracers of the Tempest', 'normal'),
    (34852, 8, 1, 34447, 6, 'Bracers of the Forgotten Vanquisher', 'Bracers of the Tempest', 'normal'),
    (34852, 8, 2, 34447, 6, 'Bracers of the Forgotten Vanquisher', 'Bracers of the Tempest', 'normal'),
    (34855, 8, 0, 34557, 6, 'Belt of the Forgotten Vanquisher', 'Belt of the Tempest', 'normal'),
    (34855, 8, 1, 34557, 6, 'Belt of the Forgotten Vanquisher', 'Belt of the Tempest', 'normal'),
    (34855, 8, 2, 34557, 6, 'Belt of the Forgotten Vanquisher', 'Belt of the Tempest', 'normal'),
    (34858, 8, 0, 34574, 6, 'Boots of the Forgotten Vanquisher', 'Boots of the Tempest', 'normal'),
    (34858, 8, 1, 34574, 6, 'Boots of the Forgotten Vanquisher', 'Boots of the Tempest', 'normal'),
    (34858, 8, 2, 34574, 6, 'Boots of the Forgotten Vanquisher', 'Boots of the Tempest', 'normal');

-- Warlock T6 extra slots (Forgotten Conqueror). Single itemization for all specs.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (34848, 34853, 34856) AND `class_id` = 9;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (34848, 9, 0, 34436, 6, 'Bracers of the Forgotten Conqueror', 'Bracers of the Malefic', 'normal'),
    (34848, 9, 1, 34436, 6, 'Bracers of the Forgotten Conqueror', 'Bracers of the Malefic', 'normal'),
    (34848, 9, 2, 34436, 6, 'Bracers of the Forgotten Conqueror', 'Bracers of the Malefic', 'normal'),
    (34853, 9, 0, 34541, 6, 'Belt of the Forgotten Conqueror', 'Belt of the Malefic', 'normal'),
    (34853, 9, 1, 34541, 6, 'Belt of the Forgotten Conqueror', 'Belt of the Malefic', 'normal'),
    (34853, 9, 2, 34541, 6, 'Belt of the Forgotten Conqueror', 'Belt of the Malefic', 'normal'),
    (34856, 9, 0, 34564, 6, 'Boots of the Forgotten Conqueror', 'Boots of the Malefic', 'normal'),
    (34856, 9, 1, 34564, 6, 'Boots of the Forgotten Conqueror', 'Boots of the Malefic', 'normal'),
    (34856, 9, 2, 34564, 6, 'Boots of the Forgotten Conqueror', 'Boots of the Malefic', 'normal');

-- T7 introduces Death Knight into the token model and reverts to the classic
-- 5 slots (Helm/Shoulder/Chest/Hands/Legs) - no extra belt/feet/wrist tokens
-- this tier. Groups carry the T6 masks forward (Conqueror/Protector/
-- Vanquisher), but Death Knight joins Vanquisher rather than forming its own
-- group. Token prefix is "Lost" for T7 10-man; result items are "Heroes' ...".
-- Confirmed class-tab mapping per class via each item set's set-bonus text
-- (e.g. "Water Shield" = Restoration, "Lightning Bolt" = Elemental), not
-- assumed from naming alone.

-- Paladin T7 10-man (Heroes' Redemption), Lost Conqueror family. Holy
-- (Regalia), Protection (Plate), Retribution (Battlegear) - all distinct.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (40616, 40622, 40610, 40613, 40619) AND `class_id` = 2;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    -- Helm of the Lost Conqueror
    (40616, 2, 0, 39628, 7, 'Helm of the Lost Conqueror', 'Heroes'' Redemption Headpiece', '10'),
    (40616, 2, 1, 39640, 7, 'Helm of the Lost Conqueror', 'Heroes'' Redemption Faceguard', '10'),
    (40616, 2, 2, 39635, 7, 'Helm of the Lost Conqueror', 'Heroes'' Redemption Helm', '10'),
    -- Spaulders of the Lost Conqueror
    (40622, 2, 0, 39631, 7, 'Spaulders of the Lost Conqueror', 'Heroes'' Redemption Spaulders', '10'),
    (40622, 2, 1, 39642, 7, 'Spaulders of the Lost Conqueror', 'Heroes'' Redemption Shoulderguards', '10'),
    (40622, 2, 2, 39637, 7, 'Spaulders of the Lost Conqueror', 'Heroes'' Redemption Shoulderplates', '10'),
    -- Chestguard of the Lost Conqueror
    (40610, 2, 0, 39629, 7, 'Chestguard of the Lost Conqueror', 'Heroes'' Redemption Tunic', '10'),
    (40610, 2, 1, 39638, 7, 'Chestguard of the Lost Conqueror', 'Heroes'' Redemption Breastplate', '10'),
    (40610, 2, 2, 39633, 7, 'Chestguard of the Lost Conqueror', 'Heroes'' Redemption Chestpiece', '10'),
    -- Gloves of the Lost Conqueror
    (40613, 2, 0, 39632, 7, 'Gloves of the Lost Conqueror', 'Heroes'' Redemption Gloves', '10'),
    (40613, 2, 1, 39639, 7, 'Gloves of the Lost Conqueror', 'Heroes'' Redemption Handguards', '10'),
    (40613, 2, 2, 39634, 7, 'Gloves of the Lost Conqueror', 'Heroes'' Redemption Gauntlets', '10'),
    -- Leggings of the Lost Conqueror
    (40619, 2, 0, 39630, 7, 'Leggings of the Lost Conqueror', 'Heroes'' Redemption Greaves', '10'),
    (40619, 2, 1, 39641, 7, 'Leggings of the Lost Conqueror', 'Heroes'' Redemption Legguards', '10'),
    (40619, 2, 2, 39636, 7, 'Leggings of the Lost Conqueror', 'Heroes'' Redemption Legplates', '10');

-- Priest T7 10-man (Heroes' Faith), Lost Conqueror family. Discipline/Holy
-- share one itemization (Regalia of Faith), Shadow has its own (Garb of Faith).
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (40616, 40622, 40610, 40613, 40619) AND `class_id` = 5;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (40616, 5, 0, 39514, 7, 'Helm of the Lost Conqueror', 'Heroes'' Crown of Faith', '10'),
    (40616, 5, 1, 39514, 7, 'Helm of the Lost Conqueror', 'Heroes'' Crown of Faith', '10'),
    (40616, 5, 2, 39521, 7, 'Helm of the Lost Conqueror', 'Heroes'' Circlet of Faith', '10'),
    (40622, 5, 0, 39518, 7, 'Spaulders of the Lost Conqueror', 'Heroes'' Shoulderpads of Faith', '10'),
    (40622, 5, 1, 39518, 7, 'Spaulders of the Lost Conqueror', 'Heroes'' Shoulderpads of Faith', '10'),
    (40622, 5, 2, 39529, 7, 'Spaulders of the Lost Conqueror', 'Heroes'' Mantle of Faith', '10'),
    (40610, 5, 0, 39515, 7, 'Chestguard of the Lost Conqueror', 'Heroes'' Robe of Faith', '10'),
    (40610, 5, 1, 39515, 7, 'Chestguard of the Lost Conqueror', 'Heroes'' Robe of Faith', '10'),
    (40610, 5, 2, 39523, 7, 'Chestguard of the Lost Conqueror', 'Heroes'' Raiments of Faith', '10'),
    (40613, 5, 0, 39519, 7, 'Gloves of the Lost Conqueror', 'Heroes'' Gloves of Faith', '10'),
    (40613, 5, 1, 39519, 7, 'Gloves of the Lost Conqueror', 'Heroes'' Gloves of Faith', '10'),
    (40613, 5, 2, 39530, 7, 'Gloves of the Lost Conqueror', 'Heroes'' Handwraps of Faith', '10'),
    (40619, 5, 0, 39517, 7, 'Leggings of the Lost Conqueror', 'Heroes'' Leggings of Faith', '10'),
    (40619, 5, 1, 39517, 7, 'Leggings of the Lost Conqueror', 'Heroes'' Leggings of Faith', '10'),
    (40619, 5, 2, 39528, 7, 'Leggings of the Lost Conqueror', 'Heroes'' Pants of Faith', '10');

-- Warlock T7 10-man (Heroes' Plagueheart), Lost Conqueror family. All 3
-- specs are caster DPS - one itemization applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (40616, 40622, 40610, 40613, 40619) AND `class_id` = 9;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (40616, 9, 0, 39496, 7, 'Helm of the Lost Conqueror', 'Heroes'' Plagueheart Circlet', '10'),
    (40616, 9, 1, 39496, 7, 'Helm of the Lost Conqueror', 'Heroes'' Plagueheart Circlet', '10'),
    (40616, 9, 2, 39496, 7, 'Helm of the Lost Conqueror', 'Heroes'' Plagueheart Circlet', '10'),
    (40622, 9, 0, 39499, 7, 'Spaulders of the Lost Conqueror', 'Heroes'' Plagueheart Shoulderpads', '10'),
    (40622, 9, 1, 39499, 7, 'Spaulders of the Lost Conqueror', 'Heroes'' Plagueheart Shoulderpads', '10'),
    (40622, 9, 2, 39499, 7, 'Spaulders of the Lost Conqueror', 'Heroes'' Plagueheart Shoulderpads', '10'),
    (40610, 9, 0, 39497, 7, 'Chestguard of the Lost Conqueror', 'Heroes'' Plagueheart Robe', '10'),
    (40610, 9, 1, 39497, 7, 'Chestguard of the Lost Conqueror', 'Heroes'' Plagueheart Robe', '10'),
    (40610, 9, 2, 39497, 7, 'Chestguard of the Lost Conqueror', 'Heroes'' Plagueheart Robe', '10'),
    (40613, 9, 0, 39500, 7, 'Gloves of the Lost Conqueror', 'Heroes'' Plagueheart Gloves', '10'),
    (40613, 9, 1, 39500, 7, 'Gloves of the Lost Conqueror', 'Heroes'' Plagueheart Gloves', '10'),
    (40613, 9, 2, 39500, 7, 'Gloves of the Lost Conqueror', 'Heroes'' Plagueheart Gloves', '10'),
    (40619, 9, 0, 39498, 7, 'Leggings of the Lost Conqueror', 'Heroes'' Plagueheart Leggings', '10'),
    (40619, 9, 1, 39498, 7, 'Leggings of the Lost Conqueror', 'Heroes'' Plagueheart Leggings', '10'),
    (40619, 9, 2, 39498, 7, 'Leggings of the Lost Conqueror', 'Heroes'' Plagueheart Leggings', '10');

-- Warrior T7 10-man (Heroes' Dreadnaught), Lost Protector family. Arms/Fury
-- share one itemization (Battlegear), Protection has its own (Plate).
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (40617, 40623, 40611, 40614, 40620) AND `class_id` = 1;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (40617, 1, 0, 39605, 7, 'Helm of the Lost Protector', 'Heroes'' Dreadnaught Helmet', '10'),
    (40617, 1, 1, 39605, 7, 'Helm of the Lost Protector', 'Heroes'' Dreadnaught Helmet', '10'),
    (40617, 1, 2, 39610, 7, 'Helm of the Lost Protector', 'Heroes'' Dreadnaught Greathelm', '10'),
    (40623, 1, 0, 39608, 7, 'Spaulders of the Lost Protector', 'Heroes'' Dreadnaught Shoulderplates', '10'),
    (40623, 1, 1, 39608, 7, 'Spaulders of the Lost Protector', 'Heroes'' Dreadnaught Shoulderplates', '10'),
    (40623, 1, 2, 39613, 7, 'Spaulders of the Lost Protector', 'Heroes'' Dreadnaught Pauldrons', '10'),
    (40611, 1, 0, 39606, 7, 'Chestguard of the Lost Protector', 'Heroes'' Dreadnaught Battleplate', '10'),
    (40611, 1, 1, 39606, 7, 'Chestguard of the Lost Protector', 'Heroes'' Dreadnaught Battleplate', '10'),
    (40611, 1, 2, 39611, 7, 'Chestguard of the Lost Protector', 'Heroes'' Dreadnaught Breastplate', '10'),
    (40614, 1, 0, 39609, 7, 'Gloves of the Lost Protector', 'Heroes'' Dreadnaught Gauntlets', '10'),
    (40614, 1, 1, 39609, 7, 'Gloves of the Lost Protector', 'Heroes'' Dreadnaught Gauntlets', '10'),
    (40614, 1, 2, 39622, 7, 'Gloves of the Lost Protector', 'Heroes'' Dreadnaught Handguards', '10'),
    (40620, 1, 0, 39607, 7, 'Leggings of the Lost Protector', 'Heroes'' Dreadnaught Legplates', '10'),
    (40620, 1, 1, 39607, 7, 'Leggings of the Lost Protector', 'Heroes'' Dreadnaught Legplates', '10'),
    (40620, 1, 2, 39612, 7, 'Leggings of the Lost Protector', 'Heroes'' Dreadnaught Legguards', '10');

-- Hunter T7 10-man (Heroes' Cryptstalker), Lost Protector family. All 3
-- specs are ranged DPS - one itemization applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (40617, 40623, 40611, 40614, 40620) AND `class_id` = 3;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (40617, 3, 0, 39578, 7, 'Helm of the Lost Protector', 'Heroes'' Cryptstalker Headpiece', '10'),
    (40617, 3, 1, 39578, 7, 'Helm of the Lost Protector', 'Heroes'' Cryptstalker Headpiece', '10'),
    (40617, 3, 2, 39578, 7, 'Helm of the Lost Protector', 'Heroes'' Cryptstalker Headpiece', '10'),
    (40623, 3, 0, 39581, 7, 'Spaulders of the Lost Protector', 'Heroes'' Cryptstalker Spaulders', '10'),
    (40623, 3, 1, 39581, 7, 'Spaulders of the Lost Protector', 'Heroes'' Cryptstalker Spaulders', '10'),
    (40623, 3, 2, 39581, 7, 'Spaulders of the Lost Protector', 'Heroes'' Cryptstalker Spaulders', '10'),
    (40611, 3, 0, 39579, 7, 'Chestguard of the Lost Protector', 'Heroes'' Cryptstalker Tunic', '10'),
    (40611, 3, 1, 39579, 7, 'Chestguard of the Lost Protector', 'Heroes'' Cryptstalker Tunic', '10'),
    (40611, 3, 2, 39579, 7, 'Chestguard of the Lost Protector', 'Heroes'' Cryptstalker Tunic', '10'),
    (40614, 3, 0, 39582, 7, 'Gloves of the Lost Protector', 'Heroes'' Cryptstalker Handguards', '10'),
    (40614, 3, 1, 39582, 7, 'Gloves of the Lost Protector', 'Heroes'' Cryptstalker Handguards', '10'),
    (40614, 3, 2, 39582, 7, 'Gloves of the Lost Protector', 'Heroes'' Cryptstalker Handguards', '10'),
    (40620, 3, 0, 39580, 7, 'Leggings of the Lost Protector', 'Heroes'' Cryptstalker Legguards', '10'),
    (40620, 3, 1, 39580, 7, 'Leggings of the Lost Protector', 'Heroes'' Cryptstalker Legguards', '10'),
    (40620, 3, 2, 39580, 7, 'Leggings of the Lost Protector', 'Heroes'' Cryptstalker Legguards', '10');

-- Shaman T7 10-man (Heroes' Earthshatter), Lost Protector family. Elemental
-- (Garb), Enhancement (Battlegear), Restoration (Regalia) - all distinct.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (40617, 40623, 40611, 40614, 40620) AND `class_id` = 7;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (40617, 7, 0, 39594, 7, 'Helm of the Lost Protector', 'Heroes'' Earthshatter Helm', '10'),
    (40617, 7, 1, 39602, 7, 'Helm of the Lost Protector', 'Heroes'' Earthshatter Faceguard', '10'),
    (40617, 7, 2, 39583, 7, 'Helm of the Lost Protector', 'Heroes'' Earthshatter Headpiece', '10'),
    (40623, 7, 0, 39596, 7, 'Spaulders of the Lost Protector', 'Heroes'' Earthshatter Shoulderpads', '10'),
    (40623, 7, 1, 39604, 7, 'Spaulders of the Lost Protector', 'Heroes'' Earthshatter Shoulderguards', '10'),
    (40623, 7, 2, 39590, 7, 'Spaulders of the Lost Protector', 'Heroes'' Earthshatter Spaulders', '10'),
    (40611, 7, 0, 39592, 7, 'Chestguard of the Lost Protector', 'Heroes'' Earthshatter Hauberk', '10'),
    (40611, 7, 1, 39597, 7, 'Chestguard of the Lost Protector', 'Heroes'' Earthshatter Chestguard', '10'),
    (40611, 7, 2, 39588, 7, 'Chestguard of the Lost Protector', 'Heroes'' Earthshatter Tunic', '10'),
    (40614, 7, 0, 39593, 7, 'Gloves of the Lost Protector', 'Heroes'' Earthshatter Gloves', '10'),
    (40614, 7, 1, 39601, 7, 'Gloves of the Lost Protector', 'Heroes'' Earthshatter Grips', '10'),
    (40614, 7, 2, 39591, 7, 'Gloves of the Lost Protector', 'Heroes'' Earthshatter Handguards', '10'),
    (40620, 7, 0, 39595, 7, 'Leggings of the Lost Protector', 'Heroes'' Earthshatter Kilt', '10'),
    (40620, 7, 1, 39603, 7, 'Leggings of the Lost Protector', 'Heroes'' Earthshatter War-Kilt', '10'),
    (40620, 7, 2, 39589, 7, 'Leggings of the Lost Protector', 'Heroes'' Earthshatter Legguards', '10');

-- Rogue T7 10-man (Heroes' Bonescythe), Lost Vanquisher family. All 3 specs
-- are melee DPS - one itemization applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (40618, 40624, 40612, 40615, 40621) AND `class_id` = 4;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (40618, 4, 0, 39561, 7, 'Helm of the Lost Vanquisher', 'Heroes'' Bonescythe Helmet', '10'),
    (40618, 4, 1, 39561, 7, 'Helm of the Lost Vanquisher', 'Heroes'' Bonescythe Helmet', '10'),
    (40618, 4, 2, 39561, 7, 'Helm of the Lost Vanquisher', 'Heroes'' Bonescythe Helmet', '10'),
    (40624, 4, 0, 39565, 7, 'Spaulders of the Lost Vanquisher', 'Heroes'' Bonescythe Pauldrons', '10'),
    (40624, 4, 1, 39565, 7, 'Spaulders of the Lost Vanquisher', 'Heroes'' Bonescythe Pauldrons', '10'),
    (40624, 4, 2, 39565, 7, 'Spaulders of the Lost Vanquisher', 'Heroes'' Bonescythe Pauldrons', '10'),
    (40612, 4, 0, 39558, 7, 'Chestguard of the Lost Vanquisher', 'Heroes'' Bonescythe Breastplate', '10'),
    (40612, 4, 1, 39558, 7, 'Chestguard of the Lost Vanquisher', 'Heroes'' Bonescythe Breastplate', '10'),
    (40612, 4, 2, 39558, 7, 'Chestguard of the Lost Vanquisher', 'Heroes'' Bonescythe Breastplate', '10'),
    (40615, 4, 0, 39560, 7, 'Gloves of the Lost Vanquisher', 'Heroes'' Bonescythe Gauntlets', '10'),
    (40615, 4, 1, 39560, 7, 'Gloves of the Lost Vanquisher', 'Heroes'' Bonescythe Gauntlets', '10'),
    (40615, 4, 2, 39560, 7, 'Gloves of the Lost Vanquisher', 'Heroes'' Bonescythe Gauntlets', '10'),
    (40621, 4, 0, 39564, 7, 'Leggings of the Lost Vanquisher', 'Heroes'' Bonescythe Legplates', '10'),
    (40621, 4, 1, 39564, 7, 'Leggings of the Lost Vanquisher', 'Heroes'' Bonescythe Legplates', '10'),
    (40621, 4, 2, 39564, 7, 'Leggings of the Lost Vanquisher', 'Heroes'' Bonescythe Legplates', '10');

-- Mage T7 10-man (Heroes' Frostfire), Lost Vanquisher family. All 3 specs
-- are caster DPS - one itemization applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (40618, 40624, 40612, 40615, 40621) AND `class_id` = 8;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (40618, 8, 0, 39491, 7, 'Helm of the Lost Vanquisher', 'Heroes'' Frostfire Circlet', '10'),
    (40618, 8, 1, 39491, 7, 'Helm of the Lost Vanquisher', 'Heroes'' Frostfire Circlet', '10'),
    (40618, 8, 2, 39491, 7, 'Helm of the Lost Vanquisher', 'Heroes'' Frostfire Circlet', '10'),
    (40624, 8, 0, 39494, 7, 'Spaulders of the Lost Vanquisher', 'Heroes'' Frostfire Shoulderpads', '10'),
    (40624, 8, 1, 39494, 7, 'Spaulders of the Lost Vanquisher', 'Heroes'' Frostfire Shoulderpads', '10'),
    (40624, 8, 2, 39494, 7, 'Spaulders of the Lost Vanquisher', 'Heroes'' Frostfire Shoulderpads', '10'),
    (40612, 8, 0, 39492, 7, 'Chestguard of the Lost Vanquisher', 'Heroes'' Frostfire Robe', '10'),
    (40612, 8, 1, 39492, 7, 'Chestguard of the Lost Vanquisher', 'Heroes'' Frostfire Robe', '10'),
    (40612, 8, 2, 39492, 7, 'Chestguard of the Lost Vanquisher', 'Heroes'' Frostfire Robe', '10'),
    (40615, 8, 0, 39495, 7, 'Gloves of the Lost Vanquisher', 'Heroes'' Frostfire Gloves', '10'),
    (40615, 8, 1, 39495, 7, 'Gloves of the Lost Vanquisher', 'Heroes'' Frostfire Gloves', '10'),
    (40615, 8, 2, 39495, 7, 'Gloves of the Lost Vanquisher', 'Heroes'' Frostfire Gloves', '10'),
    (40621, 8, 0, 39493, 7, 'Leggings of the Lost Vanquisher', 'Heroes'' Frostfire Leggings', '10'),
    (40621, 8, 1, 39493, 7, 'Leggings of the Lost Vanquisher', 'Heroes'' Frostfire Leggings', '10'),
    (40621, 8, 2, 39493, 7, 'Leggings of the Lost Vanquisher', 'Heroes'' Frostfire Leggings', '10');

-- Druid T7 10-man (Heroes' Dreamwalker), Lost Vanquisher family. Balance
-- (Garb), Feral (Battlegear), Restoration (Regalia) - all distinct.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (40618, 40624, 40612, 40615, 40621) AND `class_id` = 11;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (40618, 11, 0, 39545, 7, 'Helm of the Lost Vanquisher', 'Heroes'' Dreamwalker Cover', '10'),
    (40618, 11, 1, 39553, 7, 'Helm of the Lost Vanquisher', 'Heroes'' Dreamwalker Headguard', '10'),
    (40618, 11, 2, 39531, 7, 'Helm of the Lost Vanquisher', 'Heroes'' Dreamwalker Headpiece', '10'),
    (40624, 11, 0, 39548, 7, 'Spaulders of the Lost Vanquisher', 'Heroes'' Dreamwalker Mantle', '10'),
    (40624, 11, 1, 39556, 7, 'Spaulders of the Lost Vanquisher', 'Heroes'' Dreamwalker Shoulderpads', '10'),
    (40624, 11, 2, 39542, 7, 'Spaulders of the Lost Vanquisher', 'Heroes'' Dreamwalker Spaulders', '10'),
    (40612, 11, 0, 39547, 7, 'Chestguard of the Lost Vanquisher', 'Heroes'' Dreamwalker Vestments', '10'),
    (40612, 11, 1, 39554, 7, 'Chestguard of the Lost Vanquisher', 'Heroes'' Dreamwalker Raiments', '10'),
    (40612, 11, 2, 39538, 7, 'Chestguard of the Lost Vanquisher', 'Heroes'' Dreamwalker Robe', '10'),
    (40615, 11, 0, 39544, 7, 'Gloves of the Lost Vanquisher', 'Heroes'' Dreamwalker Gloves', '10'),
    (40615, 11, 1, 39557, 7, 'Gloves of the Lost Vanquisher', 'Heroes'' Dreamwalker Handgrips', '10'),
    (40615, 11, 2, 39543, 7, 'Gloves of the Lost Vanquisher', 'Heroes'' Dreamwalker Handguards', '10'),
    (40621, 11, 0, 39546, 7, 'Leggings of the Lost Vanquisher', 'Heroes'' Dreamwalker Trousers', '10'),
    (40621, 11, 1, 39555, 7, 'Leggings of the Lost Vanquisher', 'Heroes'' Dreamwalker Legguards', '10'),
    (40621, 11, 2, 39539, 7, 'Leggings of the Lost Vanquisher', 'Heroes'' Dreamwalker Leggings', '10');

-- Death Knight T7 10-man (Heroes' Scourgeborne), Lost Vanquisher family.
-- First class to join the token model: pre-T7 tier tokens never dropped for
-- DK, so no historical data was needed for tiers 3-6. Blood (Plate, tank)
-- has its own itemization; Frost/Unholy (Battlegear, DPS) share the other.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (40618, 40624, 40612, 40615, 40621) AND `class_id` = 6;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (40618, 6, 0, 39625, 7, 'Helm of the Lost Vanquisher', 'Heroes'' Scourgeborne Faceguard', '10'),
    (40618, 6, 1, 39619, 7, 'Helm of the Lost Vanquisher', 'Heroes'' Scourgeborne Helmet', '10'),
    (40618, 6, 2, 39619, 7, 'Helm of the Lost Vanquisher', 'Heroes'' Scourgeborne Helmet', '10'),
    (40624, 6, 0, 39627, 7, 'Spaulders of the Lost Vanquisher', 'Heroes'' Scourgeborne Pauldrons', '10'),
    (40624, 6, 1, 39621, 7, 'Spaulders of the Lost Vanquisher', 'Heroes'' Scourgeborne Shoulderplates', '10'),
    (40624, 6, 2, 39621, 7, 'Spaulders of the Lost Vanquisher', 'Heroes'' Scourgeborne Shoulderplates', '10'),
    (40612, 6, 0, 39623, 7, 'Chestguard of the Lost Vanquisher', 'Heroes'' Scourgeborne Chestguard', '10'),
    (40612, 6, 1, 39617, 7, 'Chestguard of the Lost Vanquisher', 'Heroes'' Scourgeborne Battleplate', '10'),
    (40612, 6, 2, 39617, 7, 'Chestguard of the Lost Vanquisher', 'Heroes'' Scourgeborne Battleplate', '10'),
    (40615, 6, 0, 39624, 7, 'Gloves of the Lost Vanquisher', 'Heroes'' Scourgeborne Handguards', '10'),
    (40615, 6, 1, 39618, 7, 'Gloves of the Lost Vanquisher', 'Heroes'' Scourgeborne Gauntlets', '10'),
    (40615, 6, 2, 39618, 7, 'Gloves of the Lost Vanquisher', 'Heroes'' Scourgeborne Gauntlets', '10'),
    (40621, 6, 0, 39626, 7, 'Leggings of the Lost Vanquisher', 'Heroes'' Scourgeborne Legguards', '10'),
    (40621, 6, 1, 39620, 7, 'Leggings of the Lost Vanquisher', 'Heroes'' Scourgeborne Legplates', '10'),
    (40621, 6, 2, 39620, 7, 'Leggings of the Lost Vanquisher', 'Heroes'' Scourgeborne Legplates', '10');

-- T7 25-man (Valorous). Same Lost Conqueror/Protector/Vanquisher groups and
-- class-tab mapping as the 10-man data above, at the ilvl 213 tier and a
-- distinct set of token/result item_template entries. All entries below were
-- sourced and cross-checked directly against a live item_template (class
-- mask, InventoryType per slot, and ItemLevel=213), not carried over from
-- the 10-man research.

-- Paladin T7 25-man (Valorous Redemption), Lost Conqueror family. Holy
-- (Regalia), Protection (Plate), Retribution (Battlegear) - all distinct.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (40625, 40628, 40631, 40634, 40637) AND `class_id` = 2;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (40631, 2, 0, 40571, 7, 'Crown of the Lost Conqueror', 'Valorous Redemption Headpiece', '25'),
    (40631, 2, 1, 40581, 7, 'Crown of the Lost Conqueror', 'Valorous Redemption Faceguard', '25'),
    (40631, 2, 2, 40576, 7, 'Crown of the Lost Conqueror', 'Valorous Redemption Helm', '25'),
    (40637, 2, 0, 40573, 7, 'Mantle of the Lost Conqueror', 'Valorous Redemption Spaulders', '25'),
    (40637, 2, 1, 40584, 7, 'Mantle of the Lost Conqueror', 'Valorous Redemption Shoulderguards', '25'),
    (40637, 2, 2, 40578, 7, 'Mantle of the Lost Conqueror', 'Valorous Redemption Shoulderplates', '25'),
    (40625, 2, 0, 40569, 7, 'Breastplate of the Lost Conqueror', 'Valorous Redemption Tunic', '25'),
    (40625, 2, 1, 40579, 7, 'Breastplate of the Lost Conqueror', 'Valorous Redemption Breastplate', '25'),
    (40625, 2, 2, 40574, 7, 'Breastplate of the Lost Conqueror', 'Valorous Redemption Chestpiece', '25'),
    (40628, 2, 0, 40570, 7, 'Gauntlets of the Lost Conqueror', 'Valorous Redemption Gloves', '25'),
    (40628, 2, 1, 40580, 7, 'Gauntlets of the Lost Conqueror', 'Valorous Redemption Handguards', '25'),
    (40628, 2, 2, 40575, 7, 'Gauntlets of the Lost Conqueror', 'Valorous Redemption Gauntlets', '25'),
    (40634, 2, 0, 40572, 7, 'Legplates of the Lost Conqueror', 'Valorous Redemption Greaves', '25'),
    (40634, 2, 1, 40583, 7, 'Legplates of the Lost Conqueror', 'Valorous Redemption Legguards', '25'),
    (40634, 2, 2, 40577, 7, 'Legplates of the Lost Conqueror', 'Valorous Redemption Legplates', '25');

-- Priest T7 25-man (Valorous Faith), Lost Conqueror family. Discipline/Holy
-- share one itemization (Regalia of Faith), Shadow has its own (Garb of Faith).
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (40625, 40628, 40631, 40634, 40637) AND `class_id` = 5;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (40631, 5, 0, 40447, 7, 'Crown of the Lost Conqueror', 'Valorous Crown of Faith', '25'),
    (40631, 5, 1, 40447, 7, 'Crown of the Lost Conqueror', 'Valorous Crown of Faith', '25'),
    (40631, 5, 2, 40456, 7, 'Crown of the Lost Conqueror', 'Valorous Circlet of Faith', '25'),
    (40637, 5, 0, 40450, 7, 'Mantle of the Lost Conqueror', 'Valorous Shoulderpads of Faith', '25'),
    (40637, 5, 1, 40450, 7, 'Mantle of the Lost Conqueror', 'Valorous Shoulderpads of Faith', '25'),
    (40637, 5, 2, 40459, 7, 'Mantle of the Lost Conqueror', 'Valorous Mantle of Faith', '25'),
    (40625, 5, 0, 40449, 7, 'Breastplate of the Lost Conqueror', 'Valorous Robe of Faith', '25'),
    (40625, 5, 1, 40449, 7, 'Breastplate of the Lost Conqueror', 'Valorous Robe of Faith', '25'),
    (40625, 5, 2, 40458, 7, 'Breastplate of the Lost Conqueror', 'Valorous Raiments of Faith', '25'),
    (40628, 5, 0, 40445, 7, 'Gauntlets of the Lost Conqueror', 'Valorous Gloves of Faith', '25'),
    (40628, 5, 1, 40445, 7, 'Gauntlets of the Lost Conqueror', 'Valorous Gloves of Faith', '25'),
    (40628, 5, 2, 40454, 7, 'Gauntlets of the Lost Conqueror', 'Valorous Handwraps of Faith', '25'),
    (40634, 5, 0, 40448, 7, 'Legplates of the Lost Conqueror', 'Valorous Leggings of Faith', '25'),
    (40634, 5, 1, 40448, 7, 'Legplates of the Lost Conqueror', 'Valorous Leggings of Faith', '25'),
    (40634, 5, 2, 40457, 7, 'Legplates of the Lost Conqueror', 'Valorous Pants of Faith', '25');

-- Warlock T7 25-man (Valorous Plagueheart), Lost Conqueror family. All 3
-- specs are caster DPS - one itemization applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (40625, 40628, 40631, 40634, 40637) AND `class_id` = 9;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (40631, 9, 0, 40421, 7, 'Crown of the Lost Conqueror', 'Valorous Plagueheart Circlet', '25'),
    (40631, 9, 1, 40421, 7, 'Crown of the Lost Conqueror', 'Valorous Plagueheart Circlet', '25'),
    (40631, 9, 2, 40421, 7, 'Crown of the Lost Conqueror', 'Valorous Plagueheart Circlet', '25'),
    (40637, 9, 0, 40424, 7, 'Mantle of the Lost Conqueror', 'Valorous Plagueheart Shoulderpads', '25'),
    (40637, 9, 1, 40424, 7, 'Mantle of the Lost Conqueror', 'Valorous Plagueheart Shoulderpads', '25'),
    (40637, 9, 2, 40424, 7, 'Mantle of the Lost Conqueror', 'Valorous Plagueheart Shoulderpads', '25'),
    (40625, 9, 0, 40423, 7, 'Breastplate of the Lost Conqueror', 'Valorous Plagueheart Robe', '25'),
    (40625, 9, 1, 40423, 7, 'Breastplate of the Lost Conqueror', 'Valorous Plagueheart Robe', '25'),
    (40625, 9, 2, 40423, 7, 'Breastplate of the Lost Conqueror', 'Valorous Plagueheart Robe', '25'),
    (40628, 9, 0, 40420, 7, 'Gauntlets of the Lost Conqueror', 'Valorous Plagueheart Gloves', '25'),
    (40628, 9, 1, 40420, 7, 'Gauntlets of the Lost Conqueror', 'Valorous Plagueheart Gloves', '25'),
    (40628, 9, 2, 40420, 7, 'Gauntlets of the Lost Conqueror', 'Valorous Plagueheart Gloves', '25'),
    (40634, 9, 0, 40422, 7, 'Legplates of the Lost Conqueror', 'Valorous Plagueheart Leggings', '25'),
    (40634, 9, 1, 40422, 7, 'Legplates of the Lost Conqueror', 'Valorous Plagueheart Leggings', '25'),
    (40634, 9, 2, 40422, 7, 'Legplates of the Lost Conqueror', 'Valorous Plagueheart Leggings', '25');

-- Warrior T7 25-man (Valorous Dreadnaught), Lost Protector family. Arms/Fury
-- share one itemization (Battlegear), Protection has its own (Plate).
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (40626, 40629, 40632, 40635, 40638) AND `class_id` = 1;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (40632, 1, 0, 40528, 7, 'Crown of the Lost Protector', 'Valorous Dreadnaught Helmet', '25'),
    (40632, 1, 1, 40528, 7, 'Crown of the Lost Protector', 'Valorous Dreadnaught Helmet', '25'),
    (40632, 1, 2, 40546, 7, 'Crown of the Lost Protector', 'Valorous Dreadnaught Greathelm', '25'),
    (40638, 1, 0, 40530, 7, 'Mantle of the Lost Protector', 'Valorous Dreadnaught Shoulderplates', '25'),
    (40638, 1, 1, 40530, 7, 'Mantle of the Lost Protector', 'Valorous Dreadnaught Shoulderplates', '25'),
    (40638, 1, 2, 40548, 7, 'Mantle of the Lost Protector', 'Valorous Dreadnaught Pauldrons', '25'),
    (40626, 1, 0, 40525, 7, 'Breastplate of the Lost Protector', 'Valorous Dreadnaught Battleplate', '25'),
    (40626, 1, 1, 40525, 7, 'Breastplate of the Lost Protector', 'Valorous Dreadnaught Battleplate', '25'),
    (40626, 1, 2, 40544, 7, 'Breastplate of the Lost Protector', 'Valorous Dreadnaught Breastplate', '25'),
    (40629, 1, 0, 40527, 7, 'Gauntlets of the Lost Protector', 'Valorous Dreadnaught Gauntlets', '25'),
    (40629, 1, 1, 40527, 7, 'Gauntlets of the Lost Protector', 'Valorous Dreadnaught Gauntlets', '25'),
    (40629, 1, 2, 40545, 7, 'Gauntlets of the Lost Protector', 'Valorous Dreadnaught Handguards', '25'),
    (40635, 1, 0, 40529, 7, 'Legplates of the Lost Protector', 'Valorous Dreadnaught Legplates', '25'),
    (40635, 1, 1, 40529, 7, 'Legplates of the Lost Protector', 'Valorous Dreadnaught Legplates', '25'),
    (40635, 1, 2, 40547, 7, 'Legplates of the Lost Protector', 'Valorous Dreadnaught Legguards', '25');

-- Hunter T7 25-man (Valorous Cryptstalker), Lost Protector family. All 3
-- specs are ranged DPS - one itemization applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (40626, 40629, 40632, 40635, 40638) AND `class_id` = 3;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (40632, 3, 0, 40505, 7, 'Crown of the Lost Protector', 'Valorous Cryptstalker Headpiece', '25'),
    (40632, 3, 1, 40505, 7, 'Crown of the Lost Protector', 'Valorous Cryptstalker Headpiece', '25'),
    (40632, 3, 2, 40505, 7, 'Crown of the Lost Protector', 'Valorous Cryptstalker Headpiece', '25'),
    (40638, 3, 0, 40507, 7, 'Mantle of the Lost Protector', 'Valorous Cryptstalker Spaulders', '25'),
    (40638, 3, 1, 40507, 7, 'Mantle of the Lost Protector', 'Valorous Cryptstalker Spaulders', '25'),
    (40638, 3, 2, 40507, 7, 'Mantle of the Lost Protector', 'Valorous Cryptstalker Spaulders', '25'),
    (40626, 3, 0, 40503, 7, 'Breastplate of the Lost Protector', 'Valorous Cryptstalker Tunic', '25'),
    (40626, 3, 1, 40503, 7, 'Breastplate of the Lost Protector', 'Valorous Cryptstalker Tunic', '25'),
    (40626, 3, 2, 40503, 7, 'Breastplate of the Lost Protector', 'Valorous Cryptstalker Tunic', '25'),
    (40629, 3, 0, 40504, 7, 'Gauntlets of the Lost Protector', 'Valorous Cryptstalker Handguards', '25'),
    (40629, 3, 1, 40504, 7, 'Gauntlets of the Lost Protector', 'Valorous Cryptstalker Handguards', '25'),
    (40629, 3, 2, 40504, 7, 'Gauntlets of the Lost Protector', 'Valorous Cryptstalker Handguards', '25'),
    (40635, 3, 0, 40506, 7, 'Legplates of the Lost Protector', 'Valorous Cryptstalker Legguards', '25'),
    (40635, 3, 1, 40506, 7, 'Legplates of the Lost Protector', 'Valorous Cryptstalker Legguards', '25'),
    (40635, 3, 2, 40506, 7, 'Legplates of the Lost Protector', 'Valorous Cryptstalker Legguards', '25');

-- Shaman T7 25-man (Valorous Earthshatter), Lost Protector family. Elemental
-- (Garb), Enhancement (Battlegear), Restoration (Regalia) - all distinct.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (40626, 40629, 40632, 40635, 40638) AND `class_id` = 7;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (40632, 7, 0, 40516, 7, 'Crown of the Lost Protector', 'Valorous Earthshatter Helm', '25'),
    (40632, 7, 1, 40521, 7, 'Crown of the Lost Protector', 'Valorous Earthshatter Faceguard', '25'),
    (40632, 7, 2, 40510, 7, 'Crown of the Lost Protector', 'Valorous Earthshatter Headpiece', '25'),
    (40638, 7, 0, 40518, 7, 'Mantle of the Lost Protector', 'Valorous Earthshatter Shoulderpads', '25'),
    (40638, 7, 1, 40524, 7, 'Mantle of the Lost Protector', 'Valorous Earthshatter Shoulderguards', '25'),
    (40638, 7, 2, 40513, 7, 'Mantle of the Lost Protector', 'Valorous Earthshatter Spaulders', '25'),
    (40626, 7, 0, 40514, 7, 'Breastplate of the Lost Protector', 'Valorous Earthshatter Hauberk', '25'),
    (40626, 7, 1, 40523, 7, 'Breastplate of the Lost Protector', 'Valorous Earthshatter Chestguard', '25'),
    (40626, 7, 2, 40508, 7, 'Breastplate of the Lost Protector', 'Valorous Earthshatter Tunic', '25'),
    (40629, 7, 0, 40515, 7, 'Gauntlets of the Lost Protector', 'Valorous Earthshatter Gloves', '25'),
    (40629, 7, 1, 40520, 7, 'Gauntlets of the Lost Protector', 'Valorous Earthshatter Grips', '25'),
    (40629, 7, 2, 40509, 7, 'Gauntlets of the Lost Protector', 'Valorous Earthshatter Handguards', '25'),
    (40635, 7, 0, 40517, 7, 'Legplates of the Lost Protector', 'Valorous Earthshatter Kilt', '25'),
    (40635, 7, 1, 40522, 7, 'Legplates of the Lost Protector', 'Valorous Earthshatter War-Kilt', '25'),
    (40635, 7, 2, 40512, 7, 'Legplates of the Lost Protector', 'Valorous Earthshatter Legguards', '25');

-- Rogue T7 25-man (Valorous Bonescythe), Lost Vanquisher family. All 3 specs
-- are melee DPS - one itemization applies regardless of spec. (DB has a
-- second, unused duplicate entry per piece with a different displayid; the
-- entries used here are the ones actually wired into npc_vendor/loot.)
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (40627, 40630, 40633, 40636, 40639) AND `class_id` = 4;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (40633, 4, 0, 40499, 7, 'Crown of the Lost Vanquisher', 'Valorous Bonescythe Helmet', '25'),
    (40633, 4, 1, 40499, 7, 'Crown of the Lost Vanquisher', 'Valorous Bonescythe Helmet', '25'),
    (40633, 4, 2, 40499, 7, 'Crown of the Lost Vanquisher', 'Valorous Bonescythe Helmet', '25'),
    (40639, 4, 0, 40502, 7, 'Mantle of the Lost Vanquisher', 'Valorous Bonescythe Pauldrons', '25'),
    (40639, 4, 1, 40502, 7, 'Mantle of the Lost Vanquisher', 'Valorous Bonescythe Pauldrons', '25'),
    (40639, 4, 2, 40502, 7, 'Mantle of the Lost Vanquisher', 'Valorous Bonescythe Pauldrons', '25'),
    (40627, 4, 0, 40495, 7, 'Breastplate of the Lost Vanquisher', 'Valorous Bonescythe Breastplate', '25'),
    (40627, 4, 1, 40495, 7, 'Breastplate of the Lost Vanquisher', 'Valorous Bonescythe Breastplate', '25'),
    (40627, 4, 2, 40495, 7, 'Breastplate of the Lost Vanquisher', 'Valorous Bonescythe Breastplate', '25'),
    (40630, 4, 0, 40496, 7, 'Gauntlets of the Lost Vanquisher', 'Valorous Bonescythe Gauntlets', '25'),
    (40630, 4, 1, 40496, 7, 'Gauntlets of the Lost Vanquisher', 'Valorous Bonescythe Gauntlets', '25'),
    (40630, 4, 2, 40496, 7, 'Gauntlets of the Lost Vanquisher', 'Valorous Bonescythe Gauntlets', '25'),
    (40636, 4, 0, 40500, 7, 'Legplates of the Lost Vanquisher', 'Valorous Bonescythe Legplates', '25'),
    (40636, 4, 1, 40500, 7, 'Legplates of the Lost Vanquisher', 'Valorous Bonescythe Legplates', '25'),
    (40636, 4, 2, 40500, 7, 'Legplates of the Lost Vanquisher', 'Valorous Bonescythe Legplates', '25');

-- Mage T7 25-man (Valorous Frostfire), Lost Vanquisher family. All 3 specs
-- are caster DPS - one itemization applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (40627, 40630, 40633, 40636, 40639) AND `class_id` = 8;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (40633, 8, 0, 40416, 7, 'Crown of the Lost Vanquisher', 'Valorous Frostfire Circlet', '25'),
    (40633, 8, 1, 40416, 7, 'Crown of the Lost Vanquisher', 'Valorous Frostfire Circlet', '25'),
    (40633, 8, 2, 40416, 7, 'Crown of the Lost Vanquisher', 'Valorous Frostfire Circlet', '25'),
    (40639, 8, 0, 40419, 7, 'Mantle of the Lost Vanquisher', 'Valorous Frostfire Shoulderpads', '25'),
    (40639, 8, 1, 40419, 7, 'Mantle of the Lost Vanquisher', 'Valorous Frostfire Shoulderpads', '25'),
    (40639, 8, 2, 40419, 7, 'Mantle of the Lost Vanquisher', 'Valorous Frostfire Shoulderpads', '25'),
    (40627, 8, 0, 40418, 7, 'Breastplate of the Lost Vanquisher', 'Valorous Frostfire Robe', '25'),
    (40627, 8, 1, 40418, 7, 'Breastplate of the Lost Vanquisher', 'Valorous Frostfire Robe', '25'),
    (40627, 8, 2, 40418, 7, 'Breastplate of the Lost Vanquisher', 'Valorous Frostfire Robe', '25'),
    (40630, 8, 0, 40415, 7, 'Gauntlets of the Lost Vanquisher', 'Valorous Frostfire Gloves', '25'),
    (40630, 8, 1, 40415, 7, 'Gauntlets of the Lost Vanquisher', 'Valorous Frostfire Gloves', '25'),
    (40630, 8, 2, 40415, 7, 'Gauntlets of the Lost Vanquisher', 'Valorous Frostfire Gloves', '25'),
    (40636, 8, 0, 40417, 7, 'Legplates of the Lost Vanquisher', 'Valorous Frostfire Leggings', '25'),
    (40636, 8, 1, 40417, 7, 'Legplates of the Lost Vanquisher', 'Valorous Frostfire Leggings', '25'),
    (40636, 8, 2, 40417, 7, 'Legplates of the Lost Vanquisher', 'Valorous Frostfire Leggings', '25');

-- Druid T7 25-man (Valorous Dreamwalker), Lost Vanquisher family. Balance
-- (Garb), Feral (Battlegear), Restoration (Regalia) - all distinct.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (40627, 40630, 40633, 40636, 40639) AND `class_id` = 11;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (40633, 11, 0, 40467, 7, 'Crown of the Lost Vanquisher', 'Valorous Dreamwalker Cover', '25'),
    (40633, 11, 1, 40473, 7, 'Crown of the Lost Vanquisher', 'Valorous Dreamwalker Headguard', '25'),
    (40633, 11, 2, 40461, 7, 'Crown of the Lost Vanquisher', 'Valorous Dreamwalker Headpiece', '25'),
    (40639, 11, 0, 40470, 7, 'Mantle of the Lost Vanquisher', 'Valorous Dreamwalker Mantle', '25'),
    (40639, 11, 1, 40494, 7, 'Mantle of the Lost Vanquisher', 'Valorous Dreamwalker Shoulderpads', '25'),
    (40639, 11, 2, 40465, 7, 'Mantle of the Lost Vanquisher', 'Valorous Dreamwalker Spaulders', '25'),
    (40627, 11, 0, 40469, 7, 'Breastplate of the Lost Vanquisher', 'Valorous Dreamwalker Vestments', '25'),
    (40627, 11, 1, 40471, 7, 'Breastplate of the Lost Vanquisher', 'Valorous Dreamwalker Raiments', '25'),
    (40627, 11, 2, 40463, 7, 'Breastplate of the Lost Vanquisher', 'Valorous Dreamwalker Robe', '25'),
    (40630, 11, 0, 40466, 7, 'Gauntlets of the Lost Vanquisher', 'Valorous Dreamwalker Gloves', '25'),
    (40630, 11, 1, 40472, 7, 'Gauntlets of the Lost Vanquisher', 'Valorous Dreamwalker Handgrips', '25'),
    (40630, 11, 2, 40460, 7, 'Gauntlets of the Lost Vanquisher', 'Valorous Dreamwalker Handguards', '25'),
    (40636, 11, 0, 40468, 7, 'Legplates of the Lost Vanquisher', 'Valorous Dreamwalker Trousers', '25'),
    (40636, 11, 1, 40493, 7, 'Legplates of the Lost Vanquisher', 'Valorous Dreamwalker Legguards', '25'),
    (40636, 11, 2, 40462, 7, 'Legplates of the Lost Vanquisher', 'Valorous Dreamwalker Leggings', '25');

-- Death Knight T7 25-man (Valorous Scourgeborne), Lost Vanquisher family.
-- Blood (Plate, tank) has its own itemization; Frost/Unholy (Battlegear,
-- DPS) share the other.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (40627, 40630, 40633, 40636, 40639) AND `class_id` = 6;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (40633, 6, 0, 40565, 7, 'Crown of the Lost Vanquisher', 'Valorous Scourgeborne Faceguard', '25'),
    (40633, 6, 1, 40554, 7, 'Crown of the Lost Vanquisher', 'Valorous Scourgeborne Helmet', '25'),
    (40633, 6, 2, 40554, 7, 'Crown of the Lost Vanquisher', 'Valorous Scourgeborne Helmet', '25'),
    (40639, 6, 0, 40568, 7, 'Mantle of the Lost Vanquisher', 'Valorous Scourgeborne Pauldrons', '25'),
    (40639, 6, 1, 40557, 7, 'Mantle of the Lost Vanquisher', 'Valorous Scourgeborne Shoulderplates', '25'),
    (40639, 6, 2, 40557, 7, 'Mantle of the Lost Vanquisher', 'Valorous Scourgeborne Shoulderplates', '25'),
    (40627, 6, 0, 40559, 7, 'Breastplate of the Lost Vanquisher', 'Valorous Scourgeborne Chestguard', '25'),
    (40627, 6, 1, 40550, 7, 'Breastplate of the Lost Vanquisher', 'Valorous Scourgeborne Battleplate', '25'),
    (40627, 6, 2, 40550, 7, 'Breastplate of the Lost Vanquisher', 'Valorous Scourgeborne Battleplate', '25'),
    (40630, 6, 0, 40563, 7, 'Gauntlets of the Lost Vanquisher', 'Valorous Scourgeborne Handguards', '25'),
    (40630, 6, 1, 40552, 7, 'Gauntlets of the Lost Vanquisher', 'Valorous Scourgeborne Gauntlets', '25'),
    (40630, 6, 2, 40552, 7, 'Gauntlets of the Lost Vanquisher', 'Valorous Scourgeborne Gauntlets', '25'),
    (40636, 6, 0, 40567, 7, 'Legplates of the Lost Vanquisher', 'Valorous Scourgeborne Legguards', '25'),
    (40636, 6, 1, 40556, 7, 'Legplates of the Lost Vanquisher', 'Valorous Scourgeborne Legplates', '25'),
    (40636, 6, 2, 40556, 7, 'Legplates of the Lost Vanquisher', 'Valorous Scourgeborne Legplates', '25');

-- T8 (Ulduar) carries forward the exact same Conqueror/Protector/Vanquisher
-- groups and class-tab mapping as T7. One real wrinkle: Blizzard's tier-
-- prefix rotation means T8 10-man reuses the "Valorous" prefix (already used
-- for T7 25-man) at a new ilvl (219, vs T7 25-man's 213) rather than
-- introducing a new prefix; T8 25-man will be "Conqueror's" (ilvl 226).
-- Token/result-item entries and class-tab mapping cross-checked directly
-- against a live item_template (class mask, InventoryType per slot,
-- ItemLevel=219, and the same word-per-role naming convention verified
-- against T7's data for every hybrid class).

-- Paladin T8 10-man (Valorous Aegis), Wayward Conqueror family. Holy
-- (Regalia), Protection (Plate), Retribution (Battlegear) - all distinct.
-- Word-per-slot convention (Headpiece/Faceguard/Helm for Holy/Prot/Ret helm,
-- etc.) matches T7's Paladin sets exactly, role-for-role.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (45635, 45644, 45647, 45650, 45659) AND `class_id` = 2;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (45647, 2, 0, 45372, 8, 'Helm of the Wayward Conqueror', 'Valorous Aegis Headpiece', '10'),
    (45647, 2, 1, 45382, 8, 'Helm of the Wayward Conqueror', 'Valorous Aegis Faceguard', '10'),
    (45647, 2, 2, 45377, 8, 'Helm of the Wayward Conqueror', 'Valorous Aegis Helm', '10'),
    (45659, 2, 0, 45373, 8, 'Spaulders of the Wayward Conqueror', 'Valorous Aegis Spaulders', '10'),
    (45659, 2, 1, 45385, 8, 'Spaulders of the Wayward Conqueror', 'Valorous Aegis Shoulderguards', '10'),
    (45659, 2, 2, 45380, 8, 'Spaulders of the Wayward Conqueror', 'Valorous Aegis Shoulderplates', '10'),
    (45635, 2, 0, 45374, 8, 'Chestguard of the Wayward Conqueror', 'Valorous Aegis Tunic', '10'),
    (45635, 2, 1, 45381, 8, 'Chestguard of the Wayward Conqueror', 'Valorous Aegis Breastplate', '10'),
    (45635, 2, 2, 45375, 8, 'Chestguard of the Wayward Conqueror', 'Valorous Aegis Battleplate', '10'),
    (45644, 2, 0, 45370, 8, 'Gloves of the Wayward Conqueror', 'Valorous Aegis Gloves', '10'),
    (45644, 2, 1, 45383, 8, 'Gloves of the Wayward Conqueror', 'Valorous Aegis Handguards', '10'),
    (45644, 2, 2, 45376, 8, 'Gloves of the Wayward Conqueror', 'Valorous Aegis Gauntlets', '10'),
    (45650, 2, 0, 45371, 8, 'Leggings of the Wayward Conqueror', 'Valorous Aegis Greaves', '10'),
    (45650, 2, 1, 45384, 8, 'Leggings of the Wayward Conqueror', 'Valorous Aegis Legguards', '10'),
    (45650, 2, 2, 45379, 8, 'Leggings of the Wayward Conqueror', 'Valorous Aegis Legplates', '10');

-- Priest T8 10-man (Valorous Sanctification), Wayward Conqueror family.
-- Discipline/Holy share one itemization (Regalia of Faith equivalent),
-- Shadow has its own (Garb of Faith equivalent).
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (45635, 45644, 45647, 45650, 45659) AND `class_id` = 5;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (45647, 5, 0, 45386, 8, 'Helm of the Wayward Conqueror', 'Valorous Cowl of Sanctification', '10'),
    (45647, 5, 1, 45386, 8, 'Helm of the Wayward Conqueror', 'Valorous Cowl of Sanctification', '10'),
    (45647, 5, 2, 45391, 8, 'Helm of the Wayward Conqueror', 'Valorous Circlet of Sanctification', '10'),
    (45659, 5, 0, 45390, 8, 'Spaulders of the Wayward Conqueror', 'Valorous Shoulderpads of Sanctification', '10'),
    (45659, 5, 1, 45390, 8, 'Spaulders of the Wayward Conqueror', 'Valorous Shoulderpads of Sanctification', '10'),
    (45659, 5, 2, 45393, 8, 'Spaulders of the Wayward Conqueror', 'Valorous Mantle of Sanctification', '10'),
    (45635, 5, 0, 45389, 8, 'Chestguard of the Wayward Conqueror', 'Valorous Robe of Sanctification', '10'),
    (45635, 5, 1, 45389, 8, 'Chestguard of the Wayward Conqueror', 'Valorous Robe of Sanctification', '10'),
    (45635, 5, 2, 45395, 8, 'Chestguard of the Wayward Conqueror', 'Valorous Raiments of Sanctification', '10'),
    (45644, 5, 0, 45387, 8, 'Gloves of the Wayward Conqueror', 'Valorous Gloves of Sanctification', '10'),
    (45644, 5, 1, 45387, 8, 'Gloves of the Wayward Conqueror', 'Valorous Gloves of Sanctification', '10'),
    (45644, 5, 2, 45392, 8, 'Gloves of the Wayward Conqueror', 'Valorous Handwraps of Sanctification', '10'),
    (45650, 5, 0, 45388, 8, 'Leggings of the Wayward Conqueror', 'Valorous Leggings of Sanctification', '10'),
    (45650, 5, 1, 45388, 8, 'Leggings of the Wayward Conqueror', 'Valorous Leggings of Sanctification', '10'),
    (45650, 5, 2, 45394, 8, 'Leggings of the Wayward Conqueror', 'Valorous Pants of Sanctification', '10');

-- Warlock T8 10-man (Valorous Deathbringer), Wayward Conqueror family.
-- All 3 specs are caster DPS - one itemization applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (45635, 45644, 45647, 45650, 45659) AND `class_id` = 9;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (45647, 9, 0, 45417, 8, 'Helm of the Wayward Conqueror', 'Valorous Deathbringer Hood', '10'),
    (45647, 9, 1, 45417, 8, 'Helm of the Wayward Conqueror', 'Valorous Deathbringer Hood', '10'),
    (45647, 9, 2, 45417, 8, 'Helm of the Wayward Conqueror', 'Valorous Deathbringer Hood', '10'),
    (45659, 9, 0, 45422, 8, 'Spaulders of the Wayward Conqueror', 'Valorous Deathbringer Shoulderpads', '10'),
    (45659, 9, 1, 45422, 8, 'Spaulders of the Wayward Conqueror', 'Valorous Deathbringer Shoulderpads', '10'),
    (45659, 9, 2, 45422, 8, 'Spaulders of the Wayward Conqueror', 'Valorous Deathbringer Shoulderpads', '10'),
    (45635, 9, 0, 45421, 8, 'Chestguard of the Wayward Conqueror', 'Valorous Deathbringer Robe', '10'),
    (45635, 9, 1, 45421, 8, 'Chestguard of the Wayward Conqueror', 'Valorous Deathbringer Robe', '10'),
    (45635, 9, 2, 45421, 8, 'Chestguard of the Wayward Conqueror', 'Valorous Deathbringer Robe', '10'),
    (45644, 9, 0, 45419, 8, 'Gloves of the Wayward Conqueror', 'Valorous Deathbringer Gloves', '10'),
    (45644, 9, 1, 45419, 8, 'Gloves of the Wayward Conqueror', 'Valorous Deathbringer Gloves', '10'),
    (45644, 9, 2, 45419, 8, 'Gloves of the Wayward Conqueror', 'Valorous Deathbringer Gloves', '10'),
    (45650, 9, 0, 45420, 8, 'Leggings of the Wayward Conqueror', 'Valorous Deathbringer Leggings', '10'),
    (45650, 9, 1, 45420, 8, 'Leggings of the Wayward Conqueror', 'Valorous Deathbringer Leggings', '10'),
    (45650, 9, 2, 45420, 8, 'Leggings of the Wayward Conqueror', 'Valorous Deathbringer Leggings', '10');

-- Warrior T8 10-man (Valorous Siegebreaker), Wayward Protector family.
-- Arms/Fury share one itemization (Battlegear), Protection has its own (Plate).
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (45636, 45645, 45648, 45651, 45660) AND `class_id` = 1;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (45648, 1, 0, 45431, 8, 'Helm of the Wayward Protector', 'Valorous Siegebreaker Helmet', '10'),
    (45648, 1, 1, 45431, 8, 'Helm of the Wayward Protector', 'Valorous Siegebreaker Helmet', '10'),
    (45648, 1, 2, 45425, 8, 'Helm of the Wayward Protector', 'Valorous Siegebreaker Greathelm', '10'),
    (45660, 1, 0, 45433, 8, 'Spaulders of the Wayward Protector', 'Valorous Siegebreaker Shoulderplates', '10'),
    (45660, 1, 1, 45433, 8, 'Spaulders of the Wayward Protector', 'Valorous Siegebreaker Shoulderplates', '10'),
    (45660, 1, 2, 45428, 8, 'Spaulders of the Wayward Protector', 'Valorous Siegebreaker Pauldrons', '10'),
    (45636, 1, 0, 45429, 8, 'Chestguard of the Wayward Protector', 'Valorous Siegebreaker Battleplate', '10'),
    (45636, 1, 1, 45429, 8, 'Chestguard of the Wayward Protector', 'Valorous Siegebreaker Battleplate', '10'),
    (45636, 1, 2, 45424, 8, 'Chestguard of the Wayward Protector', 'Valorous Siegebreaker Breastplate', '10'),
    (45645, 1, 0, 45430, 8, 'Gloves of the Wayward Protector', 'Valorous Siegebreaker Gauntlets', '10'),
    (45645, 1, 1, 45430, 8, 'Gloves of the Wayward Protector', 'Valorous Siegebreaker Gauntlets', '10'),
    (45645, 1, 2, 45426, 8, 'Gloves of the Wayward Protector', 'Valorous Siegebreaker Handguards', '10'),
    (45651, 1, 0, 45432, 8, 'Leggings of the Wayward Protector', 'Valorous Siegebreaker Legplates', '10'),
    (45651, 1, 1, 45432, 8, 'Leggings of the Wayward Protector', 'Valorous Siegebreaker Legplates', '10'),
    (45651, 1, 2, 45427, 8, 'Leggings of the Wayward Protector', 'Valorous Siegebreaker Legguards', '10');

-- Hunter T8 10-man (Valorous Scourgestalker), Wayward Protector family.
-- All 3 specs are ranged DPS - one itemization applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (45636, 45645, 45648, 45651, 45660) AND `class_id` = 3;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (45648, 3, 0, 45361, 8, 'Helm of the Wayward Protector', 'Valorous Scourgestalker Headpiece', '10'),
    (45648, 3, 1, 45361, 8, 'Helm of the Wayward Protector', 'Valorous Scourgestalker Headpiece', '10'),
    (45648, 3, 2, 45361, 8, 'Helm of the Wayward Protector', 'Valorous Scourgestalker Headpiece', '10'),
    (45660, 3, 0, 45363, 8, 'Spaulders of the Wayward Protector', 'Valorous Scourgestalker Spaulders', '10'),
    (45660, 3, 1, 45363, 8, 'Spaulders of the Wayward Protector', 'Valorous Scourgestalker Spaulders', '10'),
    (45660, 3, 2, 45363, 8, 'Spaulders of the Wayward Protector', 'Valorous Scourgestalker Spaulders', '10'),
    (45636, 3, 0, 45364, 8, 'Chestguard of the Wayward Protector', 'Valorous Scourgestalker Tunic', '10'),
    (45636, 3, 1, 45364, 8, 'Chestguard of the Wayward Protector', 'Valorous Scourgestalker Tunic', '10'),
    (45636, 3, 2, 45364, 8, 'Chestguard of the Wayward Protector', 'Valorous Scourgestalker Tunic', '10'),
    (45645, 3, 0, 45360, 8, 'Gloves of the Wayward Protector', 'Valorous Scourgestalker Handguards', '10'),
    (45645, 3, 1, 45360, 8, 'Gloves of the Wayward Protector', 'Valorous Scourgestalker Handguards', '10'),
    (45645, 3, 2, 45360, 8, 'Gloves of the Wayward Protector', 'Valorous Scourgestalker Handguards', '10'),
    (45651, 3, 0, 45362, 8, 'Leggings of the Wayward Protector', 'Valorous Scourgestalker Legguards', '10'),
    (45651, 3, 1, 45362, 8, 'Leggings of the Wayward Protector', 'Valorous Scourgestalker Legguards', '10'),
    (45651, 3, 2, 45362, 8, 'Leggings of the Wayward Protector', 'Valorous Scourgestalker Legguards', '10');

-- Shaman T8 10-man (Valorous Worldbreaker), Wayward Protector family.
-- Elemental (Garb), Enhancement (Battlegear), Restoration (Regalia) - all distinct.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (45636, 45645, 45648, 45651, 45660) AND `class_id` = 7;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (45648, 7, 0, 45408, 8, 'Helm of the Wayward Protector', 'Valorous Worldbreaker Helm', '10'),
    (45648, 7, 1, 45412, 8, 'Helm of the Wayward Protector', 'Valorous Worldbreaker Faceguard', '10'),
    (45648, 7, 2, 45402, 8, 'Helm of the Wayward Protector', 'Valorous Worldbreaker Headpiece', '10'),
    (45660, 7, 0, 45410, 8, 'Spaulders of the Wayward Protector', 'Valorous Worldbreaker Shoulderpads', '10'),
    (45660, 7, 1, 45415, 8, 'Spaulders of the Wayward Protector', 'Valorous Worldbreaker Shoulderguards', '10'),
    (45660, 7, 2, 45404, 8, 'Spaulders of the Wayward Protector', 'Valorous Worldbreaker Spaulders', '10'),
    (45636, 7, 0, 45411, 8, 'Chestguard of the Wayward Protector', 'Valorous Worldbreaker Hauberk', '10'),
    (45636, 7, 1, 45413, 8, 'Chestguard of the Wayward Protector', 'Valorous Worldbreaker Chestguard', '10'),
    (45636, 7, 2, 45405, 8, 'Chestguard of the Wayward Protector', 'Valorous Worldbreaker Tunic', '10'),
    (45645, 7, 0, 45406, 8, 'Gloves of the Wayward Protector', 'Valorous Worldbreaker Gloves', '10'),
    (45645, 7, 1, 45414, 8, 'Gloves of the Wayward Protector', 'Valorous Worldbreaker Grips', '10'),
    (45645, 7, 2, 45401, 8, 'Gloves of the Wayward Protector', 'Valorous Worldbreaker Handguards', '10'),
    (45651, 7, 0, 45409, 8, 'Leggings of the Wayward Protector', 'Valorous Worldbreaker Kilt', '10'),
    (45651, 7, 1, 45416, 8, 'Leggings of the Wayward Protector', 'Valorous Worldbreaker War-Kilt', '10'),
    (45651, 7, 2, 45403, 8, 'Leggings of the Wayward Protector', 'Valorous Worldbreaker Legguards', '10');

-- Rogue T8 10-man (Valorous Terrorblade), Wayward Vanquisher family. All 3
-- specs are melee DPS - one itemization applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (45637, 45646, 45649, 45652, 45661) AND `class_id` = 4;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (45649, 4, 0, 45398, 8, 'Helm of the Wayward Vanquisher', 'Valorous Terrorblade Helmet', '10'),
    (45649, 4, 1, 45398, 8, 'Helm of the Wayward Vanquisher', 'Valorous Terrorblade Helmet', '10'),
    (45649, 4, 2, 45398, 8, 'Helm of the Wayward Vanquisher', 'Valorous Terrorblade Helmet', '10'),
    (45661, 4, 0, 45400, 8, 'Spaulders of the Wayward Vanquisher', 'Valorous Terrorblade Pauldrons', '10'),
    (45661, 4, 1, 45400, 8, 'Spaulders of the Wayward Vanquisher', 'Valorous Terrorblade Pauldrons', '10'),
    (45661, 4, 2, 45400, 8, 'Spaulders of the Wayward Vanquisher', 'Valorous Terrorblade Pauldrons', '10'),
    (45637, 4, 0, 45396, 8, 'Chestguard of the Wayward Vanquisher', 'Valorous Terrorblade Breastplate', '10'),
    (45637, 4, 1, 45396, 8, 'Chestguard of the Wayward Vanquisher', 'Valorous Terrorblade Breastplate', '10'),
    (45637, 4, 2, 45396, 8, 'Chestguard of the Wayward Vanquisher', 'Valorous Terrorblade Breastplate', '10'),
    (45646, 4, 0, 45397, 8, 'Gloves of the Wayward Vanquisher', 'Valorous Terrorblade Gauntlets', '10'),
    (45646, 4, 1, 45397, 8, 'Gloves of the Wayward Vanquisher', 'Valorous Terrorblade Gauntlets', '10'),
    (45646, 4, 2, 45397, 8, 'Gloves of the Wayward Vanquisher', 'Valorous Terrorblade Gauntlets', '10'),
    (45652, 4, 0, 45399, 8, 'Leggings of the Wayward Vanquisher', 'Valorous Terrorblade Legplates', '10'),
    (45652, 4, 1, 45399, 8, 'Leggings of the Wayward Vanquisher', 'Valorous Terrorblade Legplates', '10'),
    (45652, 4, 2, 45399, 8, 'Leggings of the Wayward Vanquisher', 'Valorous Terrorblade Legplates', '10');

-- Mage T8 10-man (Valorous Kirin Tor), Wayward Vanquisher family. All 3
-- specs are caster DPS - one itemization applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (45637, 45646, 45649, 45652, 45661) AND `class_id` = 8;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (45649, 8, 0, 45365, 8, 'Helm of the Wayward Vanquisher', 'Valorous Kirin Tor Hood', '10'),
    (45649, 8, 1, 45365, 8, 'Helm of the Wayward Vanquisher', 'Valorous Kirin Tor Hood', '10'),
    (45649, 8, 2, 45365, 8, 'Helm of the Wayward Vanquisher', 'Valorous Kirin Tor Hood', '10'),
    (45661, 8, 0, 45369, 8, 'Spaulders of the Wayward Vanquisher', 'Valorous Kirin Tor Shoulderpads', '10'),
    (45661, 8, 1, 45369, 8, 'Spaulders of the Wayward Vanquisher', 'Valorous Kirin Tor Shoulderpads', '10'),
    (45661, 8, 2, 45369, 8, 'Spaulders of the Wayward Vanquisher', 'Valorous Kirin Tor Shoulderpads', '10'),
    (45637, 8, 0, 45368, 8, 'Chestguard of the Wayward Vanquisher', 'Valorous Kirin Tor Tunic', '10'),
    (45637, 8, 1, 45368, 8, 'Chestguard of the Wayward Vanquisher', 'Valorous Kirin Tor Tunic', '10'),
    (45637, 8, 2, 45368, 8, 'Chestguard of the Wayward Vanquisher', 'Valorous Kirin Tor Tunic', '10'),
    (45646, 8, 0, 46131, 8, 'Gloves of the Wayward Vanquisher', 'Valorous Kirin Tor Gauntlets', '10'),
    (45646, 8, 1, 46131, 8, 'Gloves of the Wayward Vanquisher', 'Valorous Kirin Tor Gauntlets', '10'),
    (45646, 8, 2, 46131, 8, 'Gloves of the Wayward Vanquisher', 'Valorous Kirin Tor Gauntlets', '10'),
    (45652, 8, 0, 45367, 8, 'Leggings of the Wayward Vanquisher', 'Valorous Kirin Tor Leggings', '10'),
    (45652, 8, 1, 45367, 8, 'Leggings of the Wayward Vanquisher', 'Valorous Kirin Tor Leggings', '10'),
    (45652, 8, 2, 45367, 8, 'Leggings of the Wayward Vanquisher', 'Valorous Kirin Tor Leggings', '10');

-- Druid T8 10-man (Valorous Nightsong), Wayward Vanquisher family. Balance
-- (Garb), Feral (Battlegear), Restoration (Regalia) - all distinct.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (45637, 45646, 45649, 45652, 45661) AND `class_id` = 11;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (45649, 11, 0, 46313, 8, 'Helm of the Wayward Vanquisher', 'Valorous Nightsong Cover', '10'),
    (45649, 11, 1, 45356, 8, 'Helm of the Wayward Vanquisher', 'Valorous Nightsong Headguard', '10'),
    (45649, 11, 2, 45346, 8, 'Helm of the Wayward Vanquisher', 'Valorous Nightsong Headpiece', '10'),
    (45661, 11, 0, 45352, 8, 'Spaulders of the Wayward Vanquisher', 'Valorous Nightsong Mantle', '10'),
    (45661, 11, 1, 45359, 8, 'Spaulders of the Wayward Vanquisher', 'Valorous Nightsong Shoulderpads', '10'),
    (45661, 11, 2, 45349, 8, 'Spaulders of the Wayward Vanquisher', 'Valorous Nightsong Spaulders', '10'),
    (45637, 11, 0, 45354, 8, 'Chestguard of the Wayward Vanquisher', 'Valorous Nightsong Vestments', '10'),
    (45637, 11, 1, 45358, 8, 'Chestguard of the Wayward Vanquisher', 'Valorous Nightsong Raiments', '10'),
    (45637, 11, 2, 45348, 8, 'Chestguard of the Wayward Vanquisher', 'Valorous Nightsong Robe', '10'),
    (45646, 11, 0, 45351, 8, 'Gloves of the Wayward Vanquisher', 'Valorous Nightsong Gloves', '10'),
    (45646, 11, 1, 45355, 8, 'Gloves of the Wayward Vanquisher', 'Valorous Nightsong Handgrips', '10'),
    (45646, 11, 2, 45345, 8, 'Gloves of the Wayward Vanquisher', 'Valorous Nightsong Handguards', '10'),
    (45652, 11, 0, 45353, 8, 'Leggings of the Wayward Vanquisher', 'Valorous Nightsong Trousers', '10'),
    (45652, 11, 1, 45357, 8, 'Leggings of the Wayward Vanquisher', 'Valorous Nightsong Legguards', '10'),
    (45652, 11, 2, 45347, 8, 'Leggings of the Wayward Vanquisher', 'Valorous Nightsong Leggings', '10');

-- Death Knight T8 10-man (Valorous Darkruned), Wayward Vanquisher family.
-- Blood (Plate, tank) has its own itemization; Frost/Unholy (Battlegear,
-- DPS) share the other.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (45637, 45646, 45649, 45652, 45661) AND `class_id` = 6;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (45649, 6, 0, 45336, 8, 'Helm of the Wayward Vanquisher', 'Valorous Darkruned Faceguard', '10'),
    (45649, 6, 1, 45342, 8, 'Helm of the Wayward Vanquisher', 'Valorous Darkruned Helmet', '10'),
    (45649, 6, 2, 45342, 8, 'Helm of the Wayward Vanquisher', 'Valorous Darkruned Helmet', '10'),
    (45661, 6, 0, 45339, 8, 'Spaulders of the Wayward Vanquisher', 'Valorous Darkruned Pauldrons', '10'),
    (45661, 6, 1, 45344, 8, 'Spaulders of the Wayward Vanquisher', 'Valorous Darkruned Shoulderplates', '10'),
    (45661, 6, 2, 45344, 8, 'Spaulders of the Wayward Vanquisher', 'Valorous Darkruned Shoulderplates', '10'),
    (45637, 6, 0, 45335, 8, 'Chestguard of the Wayward Vanquisher', 'Valorous Darkruned Chestguard', '10'),
    (45637, 6, 1, 45340, 8, 'Chestguard of the Wayward Vanquisher', 'Valorous Darkruned Battleplate', '10'),
    (45637, 6, 2, 45340, 8, 'Chestguard of the Wayward Vanquisher', 'Valorous Darkruned Battleplate', '10'),
    (45646, 6, 0, 45337, 8, 'Gloves of the Wayward Vanquisher', 'Valorous Darkruned Handguards', '10'),
    (45646, 6, 1, 45341, 8, 'Gloves of the Wayward Vanquisher', 'Valorous Darkruned Gauntlets', '10'),
    (45646, 6, 2, 45341, 8, 'Gloves of the Wayward Vanquisher', 'Valorous Darkruned Gauntlets', '10'),
    (45652, 6, 0, 45338, 8, 'Leggings of the Wayward Vanquisher', 'Valorous Darkruned Legguards', '10'),
    (45652, 6, 1, 45343, 8, 'Leggings of the Wayward Vanquisher', 'Valorous Darkruned Legplates', '10'),
    (45652, 6, 2, 45343, 8, 'Leggings of the Wayward Vanquisher', 'Valorous Darkruned Legplates', '10');

-- T8 25-man (Conqueror's, ilvl 226). Same groups/class-tab mapping as the
-- 10-man data above; result-item entries resolved the same way (95 distinct
-- pieces, several with duplicate item_template entries disambiguated via
-- npc_vendor/reference_loot_template presence) and cross-checked against a
-- live item_template (class mask, InventoryType per slot, ItemLevel=226).

-- Paladin T8 25-man (Conqueror's Aegis), Wayward Conqueror family. Holy
-- (Regalia), Protection (Plate), Retribution (Battlegear) - all distinct.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (45632, 45638, 45641, 45653, 45656) AND `class_id` = 2;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (45638, 2, 0, 46180, 8, 'Crown of the Wayward Conqueror', 'Conqueror''s Aegis Headpiece', '25'),
    (45638, 2, 1, 46175, 8, 'Crown of the Wayward Conqueror', 'Conqueror''s Aegis Faceguard', '25'),
    (45638, 2, 2, 46156, 8, 'Crown of the Wayward Conqueror', 'Conqueror''s Aegis Helm', '25'),
    (45656, 2, 0, 46182, 8, 'Mantle of the Wayward Conqueror', 'Conqueror''s Aegis Spaulders', '25'),
    (45656, 2, 1, 46177, 8, 'Mantle of the Wayward Conqueror', 'Conqueror''s Aegis Shoulderguards', '25'),
    (45656, 2, 2, 46152, 8, 'Mantle of the Wayward Conqueror', 'Conqueror''s Aegis Shoulderplates', '25'),
    (45632, 2, 0, 46178, 8, 'Breastplate of the Wayward Conqueror', 'Conqueror''s Aegis Tunic', '25'),
    (45632, 2, 1, 46173, 8, 'Breastplate of the Wayward Conqueror', 'Conqueror''s Aegis Breastplate', '25'),
    (45632, 2, 2, 46154, 8, 'Breastplate of the Wayward Conqueror', 'Conqueror''s Aegis Battleplate', '25'),
    (45641, 2, 0, 46179, 8, 'Gauntlets of the Wayward Conqueror', 'Conqueror''s Aegis Gloves', '25'),
    (45641, 2, 1, 46174, 8, 'Gauntlets of the Wayward Conqueror', 'Conqueror''s Aegis Handguards', '25'),
    (45641, 2, 2, 46155, 8, 'Gauntlets of the Wayward Conqueror', 'Conqueror''s Aegis Gauntlets', '25'),
    (45653, 2, 0, 46181, 8, 'Legplates of the Wayward Conqueror', 'Conqueror''s Aegis Greaves', '25'),
    (45653, 2, 1, 46176, 8, 'Legplates of the Wayward Conqueror', 'Conqueror''s Aegis Legguards', '25'),
    (45653, 2, 2, 46153, 8, 'Legplates of the Wayward Conqueror', 'Conqueror''s Aegis Legplates', '25');

-- Priest T8 25-man (Conqueror's Sanctification), Wayward Conqueror family.
-- Discipline/Holy share one itemization, Shadow has its own.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (45632, 45638, 45641, 45653, 45656) AND `class_id` = 5;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (45638, 5, 0, 46197, 8, 'Crown of the Wayward Conqueror', 'Conqueror''s Cowl of Sanctification', '25'),
    (45638, 5, 1, 46197, 8, 'Crown of the Wayward Conqueror', 'Conqueror''s Cowl of Sanctification', '25'),
    (45638, 5, 2, 46172, 8, 'Crown of the Wayward Conqueror', 'Conqueror''s Circlet of Sanctification', '25'),
    (45656, 5, 0, 46190, 8, 'Mantle of the Wayward Conqueror', 'Conqueror''s Shoulderpads of Sanctification', '25'),
    (45656, 5, 1, 46190, 8, 'Mantle of the Wayward Conqueror', 'Conqueror''s Shoulderpads of Sanctification', '25'),
    (45656, 5, 2, 46165, 8, 'Mantle of the Wayward Conqueror', 'Conqueror''s Mantle of Sanctification', '25'),
    (45632, 5, 0, 46193, 8, 'Breastplate of the Wayward Conqueror', 'Conqueror''s Robe of Sanctification', '25'),
    (45632, 5, 1, 46193, 8, 'Breastplate of the Wayward Conqueror', 'Conqueror''s Robe of Sanctification', '25'),
    (45632, 5, 2, 46168, 8, 'Breastplate of the Wayward Conqueror', 'Conqueror''s Raiments of Sanctification', '25'),
    (45641, 5, 0, 46188, 8, 'Gauntlets of the Wayward Conqueror', 'Conqueror''s Gloves of Sanctification', '25'),
    (45641, 5, 1, 46188, 8, 'Gauntlets of the Wayward Conqueror', 'Conqueror''s Gloves of Sanctification', '25'),
    (45641, 5, 2, 46163, 8, 'Gauntlets of the Wayward Conqueror', 'Conqueror''s Handwraps of Sanctification', '25'),
    (45653, 5, 0, 46195, 8, 'Legplates of the Wayward Conqueror', 'Conqueror''s Leggings of Sanctification', '25'),
    (45653, 5, 1, 46195, 8, 'Legplates of the Wayward Conqueror', 'Conqueror''s Leggings of Sanctification', '25'),
    (45653, 5, 2, 46170, 8, 'Legplates of the Wayward Conqueror', 'Conqueror''s Pants of Sanctification', '25');

-- Warlock T8 25-man (Conqueror's Deathbringer), Wayward Conqueror family.
-- All 3 specs are caster DPS - one itemization applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (45632, 45638, 45641, 45653, 45656) AND `class_id` = 9;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (45638, 9, 0, 46140, 8, 'Crown of the Wayward Conqueror', 'Conqueror''s Deathbringer Hood', '25'),
    (45638, 9, 1, 46140, 8, 'Crown of the Wayward Conqueror', 'Conqueror''s Deathbringer Hood', '25'),
    (45638, 9, 2, 46140, 8, 'Crown of the Wayward Conqueror', 'Conqueror''s Deathbringer Hood', '25'),
    (45656, 9, 0, 46136, 8, 'Mantle of the Wayward Conqueror', 'Conqueror''s Deathbringer Shoulderpads', '25'),
    (45656, 9, 1, 46136, 8, 'Mantle of the Wayward Conqueror', 'Conqueror''s Deathbringer Shoulderpads', '25'),
    (45656, 9, 2, 46136, 8, 'Mantle of the Wayward Conqueror', 'Conqueror''s Deathbringer Shoulderpads', '25'),
    (45632, 9, 0, 46137, 8, 'Breastplate of the Wayward Conqueror', 'Conqueror''s Deathbringer Robe', '25'),
    (45632, 9, 1, 46137, 8, 'Breastplate of the Wayward Conqueror', 'Conqueror''s Deathbringer Robe', '25'),
    (45632, 9, 2, 46137, 8, 'Breastplate of the Wayward Conqueror', 'Conqueror''s Deathbringer Robe', '25'),
    (45641, 9, 0, 46135, 8, 'Gauntlets of the Wayward Conqueror', 'Conqueror''s Deathbringer Gloves', '25'),
    (45641, 9, 1, 46135, 8, 'Gauntlets of the Wayward Conqueror', 'Conqueror''s Deathbringer Gloves', '25'),
    (45641, 9, 2, 46135, 8, 'Gauntlets of the Wayward Conqueror', 'Conqueror''s Deathbringer Gloves', '25'),
    (45653, 9, 0, 46139, 8, 'Legplates of the Wayward Conqueror', 'Conqueror''s Deathbringer Leggings', '25'),
    (45653, 9, 1, 46139, 8, 'Legplates of the Wayward Conqueror', 'Conqueror''s Deathbringer Leggings', '25'),
    (45653, 9, 2, 46139, 8, 'Legplates of the Wayward Conqueror', 'Conqueror''s Deathbringer Leggings', '25');

-- Warrior T8 25-man (Conqueror's Siegebreaker), Wayward Protector family.
-- Arms/Fury share one itemization (Battlegear), Protection has its own (Plate).
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (45633, 45639, 45642, 45654, 45657) AND `class_id` = 1;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (45639, 1, 0, 46151, 8, 'Crown of the Wayward Protector', 'Conqueror''s Siegebreaker Helmet', '25'),
    (45639, 1, 1, 46151, 8, 'Crown of the Wayward Protector', 'Conqueror''s Siegebreaker Helmet', '25'),
    (45639, 1, 2, 46166, 8, 'Crown of the Wayward Protector', 'Conqueror''s Siegebreaker Greathelm', '25'),
    (45657, 1, 0, 46149, 8, 'Mantle of the Wayward Protector', 'Conqueror''s Siegebreaker Shoulderplates', '25'),
    (45657, 1, 1, 46149, 8, 'Mantle of the Wayward Protector', 'Conqueror''s Siegebreaker Shoulderplates', '25'),
    (45657, 1, 2, 46167, 8, 'Mantle of the Wayward Protector', 'Conqueror''s Siegebreaker Pauldrons', '25'),
    (45633, 1, 0, 46146, 8, 'Breastplate of the Wayward Protector', 'Conqueror''s Siegebreaker Battleplate', '25'),
    (45633, 1, 1, 46146, 8, 'Breastplate of the Wayward Protector', 'Conqueror''s Siegebreaker Battleplate', '25'),
    (45633, 1, 2, 46162, 8, 'Breastplate of the Wayward Protector', 'Conqueror''s Siegebreaker Breastplate', '25'),
    (45642, 1, 0, 46148, 8, 'Gauntlets of the Wayward Protector', 'Conqueror''s Siegebreaker Gauntlets', '25'),
    (45642, 1, 1, 46148, 8, 'Gauntlets of the Wayward Protector', 'Conqueror''s Siegebreaker Gauntlets', '25'),
    (45642, 1, 2, 46164, 8, 'Gauntlets of the Wayward Protector', 'Conqueror''s Siegebreaker Handguards', '25'),
    (45654, 1, 0, 46150, 8, 'Legplates of the Wayward Protector', 'Conqueror''s Siegebreaker Legplates', '25'),
    (45654, 1, 1, 46150, 8, 'Legplates of the Wayward Protector', 'Conqueror''s Siegebreaker Legplates', '25'),
    (45654, 1, 2, 46169, 8, 'Legplates of the Wayward Protector', 'Conqueror''s Siegebreaker Legguards', '25');

-- Hunter T8 25-man (Conqueror's Scourgestalker), Wayward Protector family.
-- All 3 specs are ranged DPS - one itemization applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (45633, 45639, 45642, 45654, 45657) AND `class_id` = 3;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (45639, 3, 0, 46143, 8, 'Crown of the Wayward Protector', 'Conqueror''s Scourgestalker Headpiece', '25'),
    (45639, 3, 1, 46143, 8, 'Crown of the Wayward Protector', 'Conqueror''s Scourgestalker Headpiece', '25'),
    (45639, 3, 2, 46143, 8, 'Crown of the Wayward Protector', 'Conqueror''s Scourgestalker Headpiece', '25'),
    (45657, 3, 0, 46145, 8, 'Mantle of the Wayward Protector', 'Conqueror''s Scourgestalker Spaulders', '25'),
    (45657, 3, 1, 46145, 8, 'Mantle of the Wayward Protector', 'Conqueror''s Scourgestalker Spaulders', '25'),
    (45657, 3, 2, 46145, 8, 'Mantle of the Wayward Protector', 'Conqueror''s Scourgestalker Spaulders', '25'),
    (45633, 3, 0, 46141, 8, 'Breastplate of the Wayward Protector', 'Conqueror''s Scourgestalker Tunic', '25'),
    (45633, 3, 1, 46141, 8, 'Breastplate of the Wayward Protector', 'Conqueror''s Scourgestalker Tunic', '25'),
    (45633, 3, 2, 46141, 8, 'Breastplate of the Wayward Protector', 'Conqueror''s Scourgestalker Tunic', '25'),
    (45642, 3, 0, 46142, 8, 'Gauntlets of the Wayward Protector', 'Conqueror''s Scourgestalker Handguards', '25'),
    (45642, 3, 1, 46142, 8, 'Gauntlets of the Wayward Protector', 'Conqueror''s Scourgestalker Handguards', '25'),
    (45642, 3, 2, 46142, 8, 'Gauntlets of the Wayward Protector', 'Conqueror''s Scourgestalker Handguards', '25'),
    (45654, 3, 0, 46144, 8, 'Legplates of the Wayward Protector', 'Conqueror''s Scourgestalker Legguards', '25'),
    (45654, 3, 1, 46144, 8, 'Legplates of the Wayward Protector', 'Conqueror''s Scourgestalker Legguards', '25'),
    (45654, 3, 2, 46144, 8, 'Legplates of the Wayward Protector', 'Conqueror''s Scourgestalker Legguards', '25');

-- Shaman T8 25-man (Conqueror's Worldbreaker), Wayward Protector family.
-- Elemental (Garb), Enhancement (Battlegear), Restoration (Regalia) - all distinct.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (45633, 45639, 45642, 45654, 45657) AND `class_id` = 7;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (45639, 7, 0, 46209, 8, 'Crown of the Wayward Protector', 'Conqueror''s Worldbreaker Helm', '25'),
    (45639, 7, 1, 46212, 8, 'Crown of the Wayward Protector', 'Conqueror''s Worldbreaker Faceguard', '25'),
    (45639, 7, 2, 46201, 8, 'Crown of the Wayward Protector', 'Conqueror''s Worldbreaker Headpiece', '25'),
    (45657, 7, 0, 46211, 8, 'Mantle of the Wayward Protector', 'Conqueror''s Worldbreaker Shoulderpads', '25'),
    (45657, 7, 1, 46203, 8, 'Mantle of the Wayward Protector', 'Conqueror''s Worldbreaker Shoulderguards', '25'),
    (45657, 7, 2, 46204, 8, 'Mantle of the Wayward Protector', 'Conqueror''s Worldbreaker Spaulders', '25'),
    (45633, 7, 0, 46206, 8, 'Breastplate of the Wayward Protector', 'Conqueror''s Worldbreaker Hauberk', '25'),
    (45633, 7, 1, 46205, 8, 'Breastplate of the Wayward Protector', 'Conqueror''s Worldbreaker Chestguard', '25'),
    (45633, 7, 2, 46198, 8, 'Breastplate of the Wayward Protector', 'Conqueror''s Worldbreaker Tunic', '25'),
    (45642, 7, 0, 46207, 8, 'Gauntlets of the Wayward Protector', 'Conqueror''s Worldbreaker Gloves', '25'),
    (45642, 7, 1, 46200, 8, 'Gauntlets of the Wayward Protector', 'Conqueror''s Worldbreaker Grips', '25'),
    (45642, 7, 2, 46199, 8, 'Gauntlets of the Wayward Protector', 'Conqueror''s Worldbreaker Handguards', '25'),
    (45654, 7, 0, 46210, 8, 'Legplates of the Wayward Protector', 'Conqueror''s Worldbreaker Kilt', '25'),
    (45654, 7, 1, 46208, 8, 'Legplates of the Wayward Protector', 'Conqueror''s Worldbreaker War-Kilt', '25'),
    (45654, 7, 2, 46202, 8, 'Legplates of the Wayward Protector', 'Conqueror''s Worldbreaker Legguards', '25');

-- Rogue T8 25-man (Conqueror's Terrorblade), Wayward Vanquisher family. All
-- 3 specs are melee DPS - one itemization applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (45634, 45640, 45643, 45655, 45658) AND `class_id` = 4;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (45640, 4, 0, 46125, 8, 'Crown of the Wayward Vanquisher', 'Conqueror''s Terrorblade Helmet', '25'),
    (45640, 4, 1, 46125, 8, 'Crown of the Wayward Vanquisher', 'Conqueror''s Terrorblade Helmet', '25'),
    (45640, 4, 2, 46125, 8, 'Crown of the Wayward Vanquisher', 'Conqueror''s Terrorblade Helmet', '25'),
    (45658, 4, 0, 46127, 8, 'Mantle of the Wayward Vanquisher', 'Conqueror''s Terrorblade Pauldrons', '25'),
    (45658, 4, 1, 46127, 8, 'Mantle of the Wayward Vanquisher', 'Conqueror''s Terrorblade Pauldrons', '25'),
    (45658, 4, 2, 46127, 8, 'Mantle of the Wayward Vanquisher', 'Conqueror''s Terrorblade Pauldrons', '25'),
    (45634, 4, 0, 46123, 8, 'Breastplate of the Wayward Vanquisher', 'Conqueror''s Terrorblade Breastplate', '25'),
    (45634, 4, 1, 46123, 8, 'Breastplate of the Wayward Vanquisher', 'Conqueror''s Terrorblade Breastplate', '25'),
    (45634, 4, 2, 46123, 8, 'Breastplate of the Wayward Vanquisher', 'Conqueror''s Terrorblade Breastplate', '25'),
    (45643, 4, 0, 46124, 8, 'Gauntlets of the Wayward Vanquisher', 'Conqueror''s Terrorblade Gauntlets', '25'),
    (45643, 4, 1, 46124, 8, 'Gauntlets of the Wayward Vanquisher', 'Conqueror''s Terrorblade Gauntlets', '25'),
    (45643, 4, 2, 46124, 8, 'Gauntlets of the Wayward Vanquisher', 'Conqueror''s Terrorblade Gauntlets', '25'),
    (45655, 4, 0, 46126, 8, 'Legplates of the Wayward Vanquisher', 'Conqueror''s Terrorblade Legplates', '25'),
    (45655, 4, 1, 46126, 8, 'Legplates of the Wayward Vanquisher', 'Conqueror''s Terrorblade Legplates', '25'),
    (45655, 4, 2, 46126, 8, 'Legplates of the Wayward Vanquisher', 'Conqueror''s Terrorblade Legplates', '25');

-- Mage T8 25-man (Conqueror's Kirin Tor), Wayward Vanquisher family. All 3
-- specs are caster DPS - one itemization applies regardless of spec.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (45634, 45640, 45643, 45655, 45658) AND `class_id` = 8;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (45640, 8, 0, 46129, 8, 'Crown of the Wayward Vanquisher', 'Conqueror''s Kirin Tor Hood', '25'),
    (45640, 8, 1, 46129, 8, 'Crown of the Wayward Vanquisher', 'Conqueror''s Kirin Tor Hood', '25'),
    (45640, 8, 2, 46129, 8, 'Crown of the Wayward Vanquisher', 'Conqueror''s Kirin Tor Hood', '25'),
    (45658, 8, 0, 46134, 8, 'Mantle of the Wayward Vanquisher', 'Conqueror''s Kirin Tor Shoulderpads', '25'),
    (45658, 8, 1, 46134, 8, 'Mantle of the Wayward Vanquisher', 'Conqueror''s Kirin Tor Shoulderpads', '25'),
    (45658, 8, 2, 46134, 8, 'Mantle of the Wayward Vanquisher', 'Conqueror''s Kirin Tor Shoulderpads', '25'),
    (45634, 8, 0, 46130, 8, 'Breastplate of the Wayward Vanquisher', 'Conqueror''s Kirin Tor Tunic', '25'),
    (45634, 8, 1, 46130, 8, 'Breastplate of the Wayward Vanquisher', 'Conqueror''s Kirin Tor Tunic', '25'),
    (45634, 8, 2, 46130, 8, 'Breastplate of the Wayward Vanquisher', 'Conqueror''s Kirin Tor Tunic', '25'),
    (45643, 8, 0, 46132, 8, 'Gauntlets of the Wayward Vanquisher', 'Conqueror''s Kirin Tor Gauntlets', '25'),
    (45643, 8, 1, 46132, 8, 'Gauntlets of the Wayward Vanquisher', 'Conqueror''s Kirin Tor Gauntlets', '25'),
    (45643, 8, 2, 46132, 8, 'Gauntlets of the Wayward Vanquisher', 'Conqueror''s Kirin Tor Gauntlets', '25'),
    (45655, 8, 0, 46133, 8, 'Legplates of the Wayward Vanquisher', 'Conqueror''s Kirin Tor Leggings', '25'),
    (45655, 8, 1, 46133, 8, 'Legplates of the Wayward Vanquisher', 'Conqueror''s Kirin Tor Leggings', '25'),
    (45655, 8, 2, 46133, 8, 'Legplates of the Wayward Vanquisher', 'Conqueror''s Kirin Tor Leggings', '25');

-- Druid T8 25-man (Conqueror's Nightsong), Wayward Vanquisher family.
-- Balance (Garb), Feral (Battlegear), Restoration (Regalia) - all distinct.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (45634, 45640, 45643, 45655, 45658) AND `class_id` = 11;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (45640, 11, 0, 46191, 8, 'Crown of the Wayward Vanquisher', 'Conqueror''s Nightsong Cover', '25'),
    (45640, 11, 1, 46161, 8, 'Crown of the Wayward Vanquisher', 'Conqueror''s Nightsong Headguard', '25'),
    (45640, 11, 2, 46184, 8, 'Crown of the Wayward Vanquisher', 'Conqueror''s Nightsong Headpiece', '25'),
    (45658, 11, 0, 46196, 8, 'Mantle of the Wayward Vanquisher', 'Conqueror''s Nightsong Mantle', '25'),
    (45658, 11, 1, 46157, 8, 'Mantle of the Wayward Vanquisher', 'Conqueror''s Nightsong Shoulderpads', '25'),
    (45658, 11, 2, 46187, 8, 'Mantle of the Wayward Vanquisher', 'Conqueror''s Nightsong Spaulders', '25'),
    (45634, 11, 0, 46194, 8, 'Breastplate of the Wayward Vanquisher', 'Conqueror''s Nightsong Vestments', '25'),
    (45634, 11, 1, 46159, 8, 'Breastplate of the Wayward Vanquisher', 'Conqueror''s Nightsong Raiments', '25'),
    (45634, 11, 2, 46186, 8, 'Breastplate of the Wayward Vanquisher', 'Conqueror''s Nightsong Robe', '25'),
    (45643, 11, 0, 46189, 8, 'Gauntlets of the Wayward Vanquisher', 'Conqueror''s Nightsong Gloves', '25'),
    (45643, 11, 1, 46158, 8, 'Gauntlets of the Wayward Vanquisher', 'Conqueror''s Nightsong Handgrips', '25'),
    (45643, 11, 2, 46183, 8, 'Gauntlets of the Wayward Vanquisher', 'Conqueror''s Nightsong Handguards', '25'),
    (45655, 11, 0, 46192, 8, 'Legplates of the Wayward Vanquisher', 'Conqueror''s Nightsong Trousers', '25'),
    (45655, 11, 1, 46160, 8, 'Legplates of the Wayward Vanquisher', 'Conqueror''s Nightsong Legguards', '25'),
    (45655, 11, 2, 46185, 8, 'Legplates of the Wayward Vanquisher', 'Conqueror''s Nightsong Leggings', '25');

-- Death Knight T8 25-man (Conqueror's Darkruned), Wayward Vanquisher family.
-- Blood (Plate, tank) has its own itemization; Frost/Unholy (Battlegear,
-- DPS) share the other.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (45634, 45640, 45643, 45655, 45658) AND `class_id` = 6;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (45640, 6, 0, 46120, 8, 'Crown of the Wayward Vanquisher', 'Conqueror''s Darkruned Faceguard', '25'),
    (45640, 6, 1, 46115, 8, 'Crown of the Wayward Vanquisher', 'Conqueror''s Darkruned Helmet', '25'),
    (45640, 6, 2, 46115, 8, 'Crown of the Wayward Vanquisher', 'Conqueror''s Darkruned Helmet', '25'),
    (45658, 6, 0, 46122, 8, 'Mantle of the Wayward Vanquisher', 'Conqueror''s Darkruned Pauldrons', '25'),
    (45658, 6, 1, 46117, 8, 'Mantle of the Wayward Vanquisher', 'Conqueror''s Darkruned Shoulderplates', '25'),
    (45658, 6, 2, 46117, 8, 'Mantle of the Wayward Vanquisher', 'Conqueror''s Darkruned Shoulderplates', '25'),
    (45634, 6, 0, 46118, 8, 'Breastplate of the Wayward Vanquisher', 'Conqueror''s Darkruned Chestguard', '25'),
    (45634, 6, 1, 46111, 8, 'Breastplate of the Wayward Vanquisher', 'Conqueror''s Darkruned Battleplate', '25'),
    (45634, 6, 2, 46111, 8, 'Breastplate of the Wayward Vanquisher', 'Conqueror''s Darkruned Battleplate', '25'),
    (45643, 6, 0, 46119, 8, 'Gauntlets of the Wayward Vanquisher', 'Conqueror''s Darkruned Handguards', '25'),
    (45643, 6, 1, 46113, 8, 'Gauntlets of the Wayward Vanquisher', 'Conqueror''s Darkruned Gauntlets', '25'),
    (45643, 6, 2, 46113, 8, 'Gauntlets of the Wayward Vanquisher', 'Conqueror''s Darkruned Gauntlets', '25'),
    (45655, 6, 0, 46121, 8, 'Legplates of the Wayward Vanquisher', 'Conqueror''s Darkruned Legguards', '25'),
    (45655, 6, 1, 46116, 8, 'Legplates of the Wayward Vanquisher', 'Conqueror''s Darkruned Legplates', '25'),
    (45655, 6, 2, 46116, 8, 'Legplates of the Wayward Vanquisher', 'Conqueror''s Darkruned Legplates', '25');

-- T3 (Naxxramas, vanilla-era tier set). Structurally different from T4+:
-- only 8 slots (Helm/Shoulder/Chest/Hands/Wrist/Waist/Legs/Feet - no ring,
-- rings drop directly from Kel'Thuzad and aren't part of this module's
-- scope), and each class has exactly one itemization (no talent-tab
-- branching - all 3 tabs resolve to the same piece).
--
-- Class groupings are new and were NOT assumed from T4-T8's Conqueror/
-- Protector/Vanquisher convention - they're read directly off the real
-- `Desecrated <slot>` tokens' AllowableClass in item_template: mask 9
-- (Warrior+Rogue), mask 400 (Priest+Mage+Warlock), mask 1094
-- (Paladin+Hunter+Shaman+Druid). A 2/3/4 split, not 3/3/3.
--
-- Real Vanilla acquisition is a quest turn-in (to a class-specific NPC)
-- that also consumes crafting materials (Wartorn Scraps, profession mats,
-- gold) alongside the token. Decided out of scope for this module -
-- redeem just needs the token, materials/quest waived entirely. Same
-- reasoning as every other tier: the module's value is cutting bag-
-- management overhead for a full bot roster, not replicating the exact
-- acquisition mechanic.

-- Warrior T3 (Dreadnaught), Warrior+Rogue family. Single itemization -
-- no talent-tab branching, all 3 tabs share the same piece per slot.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (22349, 22352, 22353, 22354, 22355, 22356, 22357, 22358) AND `class_id` = 1;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (22353, 1, 0, 22418, 3, 'Desecrated Helmet', 'Dreadnaught Helmet', 'normal'),
    (22353, 1, 1, 22418, 3, 'Desecrated Helmet', 'Dreadnaught Helmet', 'normal'),
    (22353, 1, 2, 22418, 3, 'Desecrated Helmet', 'Dreadnaught Helmet', 'normal'),
    (22354, 1, 0, 22419, 3, 'Desecrated Pauldrons', 'Dreadnaught Pauldrons', 'normal'),
    (22354, 1, 1, 22419, 3, 'Desecrated Pauldrons', 'Dreadnaught Pauldrons', 'normal'),
    (22354, 1, 2, 22419, 3, 'Desecrated Pauldrons', 'Dreadnaught Pauldrons', 'normal'),
    (22349, 1, 0, 22416, 3, 'Desecrated Breastplate', 'Dreadnaught Breastplate', 'normal'),
    (22349, 1, 1, 22416, 3, 'Desecrated Breastplate', 'Dreadnaught Breastplate', 'normal'),
    (22349, 1, 2, 22416, 3, 'Desecrated Breastplate', 'Dreadnaught Breastplate', 'normal'),
    (22357, 1, 0, 22421, 3, 'Desecrated Gauntlets', 'Dreadnaught Gauntlets', 'normal'),
    (22357, 1, 1, 22421, 3, 'Desecrated Gauntlets', 'Dreadnaught Gauntlets', 'normal'),
    (22357, 1, 2, 22421, 3, 'Desecrated Gauntlets', 'Dreadnaught Gauntlets', 'normal'),
    (22355, 1, 0, 22423, 3, 'Desecrated Bracers', 'Dreadnaught Bracers', 'normal'),
    (22355, 1, 1, 22423, 3, 'Desecrated Bracers', 'Dreadnaught Bracers', 'normal'),
    (22355, 1, 2, 22423, 3, 'Desecrated Bracers', 'Dreadnaught Bracers', 'normal'),
    (22356, 1, 0, 22422, 3, 'Desecrated Waistguard', 'Dreadnaught Waistguard', 'normal'),
    (22356, 1, 1, 22422, 3, 'Desecrated Waistguard', 'Dreadnaught Waistguard', 'normal'),
    (22356, 1, 2, 22422, 3, 'Desecrated Waistguard', 'Dreadnaught Waistguard', 'normal'),
    (22352, 1, 0, 22417, 3, 'Desecrated Legplates', 'Dreadnaught Legplates', 'normal'),
    (22352, 1, 1, 22417, 3, 'Desecrated Legplates', 'Dreadnaught Legplates', 'normal'),
    (22352, 1, 2, 22417, 3, 'Desecrated Legplates', 'Dreadnaught Legplates', 'normal'),
    (22358, 1, 0, 22420, 3, 'Desecrated Sabatons', 'Dreadnaught Sabatons', 'normal'),
    (22358, 1, 1, 22420, 3, 'Desecrated Sabatons', 'Dreadnaught Sabatons', 'normal'),
    (22358, 1, 2, 22420, 3, 'Desecrated Sabatons', 'Dreadnaught Sabatons', 'normal');

-- Rogue T3 (Bonescythe), Warrior+Rogue family. Single itemization -
-- no talent-tab branching, all 3 tabs share the same piece per slot.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (22349, 22352, 22353, 22354, 22355, 22356, 22357, 22358) AND `class_id` = 4;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (22353, 4, 0, 22478, 3, 'Desecrated Helmet', 'Bonescythe Helmet', 'normal'),
    (22353, 4, 1, 22478, 3, 'Desecrated Helmet', 'Bonescythe Helmet', 'normal'),
    (22353, 4, 2, 22478, 3, 'Desecrated Helmet', 'Bonescythe Helmet', 'normal'),
    (22354, 4, 0, 22479, 3, 'Desecrated Pauldrons', 'Bonescythe Pauldrons', 'normal'),
    (22354, 4, 1, 22479, 3, 'Desecrated Pauldrons', 'Bonescythe Pauldrons', 'normal'),
    (22354, 4, 2, 22479, 3, 'Desecrated Pauldrons', 'Bonescythe Pauldrons', 'normal'),
    (22349, 4, 0, 22476, 3, 'Desecrated Breastplate', 'Bonescythe Breastplate', 'normal'),
    (22349, 4, 1, 22476, 3, 'Desecrated Breastplate', 'Bonescythe Breastplate', 'normal'),
    (22349, 4, 2, 22476, 3, 'Desecrated Breastplate', 'Bonescythe Breastplate', 'normal'),
    (22357, 4, 0, 22481, 3, 'Desecrated Gauntlets', 'Bonescythe Gauntlets', 'normal'),
    (22357, 4, 1, 22481, 3, 'Desecrated Gauntlets', 'Bonescythe Gauntlets', 'normal'),
    (22357, 4, 2, 22481, 3, 'Desecrated Gauntlets', 'Bonescythe Gauntlets', 'normal'),
    (22355, 4, 0, 22483, 3, 'Desecrated Bracers', 'Bonescythe Bracers', 'normal'),
    (22355, 4, 1, 22483, 3, 'Desecrated Bracers', 'Bonescythe Bracers', 'normal'),
    (22355, 4, 2, 22483, 3, 'Desecrated Bracers', 'Bonescythe Bracers', 'normal'),
    (22356, 4, 0, 22482, 3, 'Desecrated Waistguard', 'Bonescythe Waistguard', 'normal'),
    (22356, 4, 1, 22482, 3, 'Desecrated Waistguard', 'Bonescythe Waistguard', 'normal'),
    (22356, 4, 2, 22482, 3, 'Desecrated Waistguard', 'Bonescythe Waistguard', 'normal'),
    (22352, 4, 0, 22477, 3, 'Desecrated Legplates', 'Bonescythe Legplates', 'normal'),
    (22352, 4, 1, 22477, 3, 'Desecrated Legplates', 'Bonescythe Legplates', 'normal'),
    (22352, 4, 2, 22477, 3, 'Desecrated Legplates', 'Bonescythe Legplates', 'normal'),
    (22358, 4, 0, 22480, 3, 'Desecrated Sabatons', 'Bonescythe Sabatons', 'normal'),
    (22358, 4, 1, 22480, 3, 'Desecrated Sabatons', 'Bonescythe Sabatons', 'normal'),
    (22358, 4, 2, 22480, 3, 'Desecrated Sabatons', 'Bonescythe Sabatons', 'normal');

-- Priest T3 (Faith), Priest+Mage+Warlock family. Single itemization -
-- no talent-tab branching, all 3 tabs share the same piece per slot.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (22351, 22366, 22367, 22368, 22369, 22370, 22371, 22372) AND `class_id` = 5;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (22367, 5, 0, 22514, 3, 'Desecrated Circlet', 'Circlet of Faith', 'normal'),
    (22367, 5, 1, 22514, 3, 'Desecrated Circlet', 'Circlet of Faith', 'normal'),
    (22367, 5, 2, 22514, 3, 'Desecrated Circlet', 'Circlet of Faith', 'normal'),
    (22368, 5, 0, 22515, 3, 'Desecrated Shoulderpads', 'Shoulderpads of Faith', 'normal'),
    (22368, 5, 1, 22515, 3, 'Desecrated Shoulderpads', 'Shoulderpads of Faith', 'normal'),
    (22368, 5, 2, 22515, 3, 'Desecrated Shoulderpads', 'Shoulderpads of Faith', 'normal'),
    (22351, 5, 0, 22512, 3, 'Desecrated Robe', 'Robe of Faith', 'normal'),
    (22351, 5, 1, 22512, 3, 'Desecrated Robe', 'Robe of Faith', 'normal'),
    (22351, 5, 2, 22512, 3, 'Desecrated Robe', 'Robe of Faith', 'normal'),
    (22371, 5, 0, 22517, 3, 'Desecrated Gloves', 'Gloves of Faith', 'normal'),
    (22371, 5, 1, 22517, 3, 'Desecrated Gloves', 'Gloves of Faith', 'normal'),
    (22371, 5, 2, 22517, 3, 'Desecrated Gloves', 'Gloves of Faith', 'normal'),
    (22369, 5, 0, 22519, 3, 'Desecrated Bindings', 'Bindings of Faith', 'normal'),
    (22369, 5, 1, 22519, 3, 'Desecrated Bindings', 'Bindings of Faith', 'normal'),
    (22369, 5, 2, 22519, 3, 'Desecrated Bindings', 'Bindings of Faith', 'normal'),
    (22370, 5, 0, 22518, 3, 'Desecrated Belt', 'Belt of Faith', 'normal'),
    (22370, 5, 1, 22518, 3, 'Desecrated Belt', 'Belt of Faith', 'normal'),
    (22370, 5, 2, 22518, 3, 'Desecrated Belt', 'Belt of Faith', 'normal'),
    (22366, 5, 0, 22513, 3, 'Desecrated Leggings', 'Leggings of Faith', 'normal'),
    (22366, 5, 1, 22513, 3, 'Desecrated Leggings', 'Leggings of Faith', 'normal'),
    (22366, 5, 2, 22513, 3, 'Desecrated Leggings', 'Leggings of Faith', 'normal'),
    (22372, 5, 0, 22516, 3, 'Desecrated Sandals', 'Sandals of Faith', 'normal'),
    (22372, 5, 1, 22516, 3, 'Desecrated Sandals', 'Sandals of Faith', 'normal'),
    (22372, 5, 2, 22516, 3, 'Desecrated Sandals', 'Sandals of Faith', 'normal');

-- Mage T3 (Frostfire), Priest+Mage+Warlock family. Single itemization -
-- no talent-tab branching, all 3 tabs share the same piece per slot.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (22351, 22366, 22367, 22368, 22369, 22370, 22371, 22372) AND `class_id` = 8;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (22367, 8, 0, 22498, 3, 'Desecrated Circlet', 'Frostfire Circlet', 'normal'),
    (22367, 8, 1, 22498, 3, 'Desecrated Circlet', 'Frostfire Circlet', 'normal'),
    (22367, 8, 2, 22498, 3, 'Desecrated Circlet', 'Frostfire Circlet', 'normal'),
    (22368, 8, 0, 22499, 3, 'Desecrated Shoulderpads', 'Frostfire Shoulderpads', 'normal'),
    (22368, 8, 1, 22499, 3, 'Desecrated Shoulderpads', 'Frostfire Shoulderpads', 'normal'),
    (22368, 8, 2, 22499, 3, 'Desecrated Shoulderpads', 'Frostfire Shoulderpads', 'normal'),
    (22351, 8, 0, 22496, 3, 'Desecrated Robe', 'Frostfire Robe', 'normal'),
    (22351, 8, 1, 22496, 3, 'Desecrated Robe', 'Frostfire Robe', 'normal'),
    (22351, 8, 2, 22496, 3, 'Desecrated Robe', 'Frostfire Robe', 'normal'),
    (22371, 8, 0, 22501, 3, 'Desecrated Gloves', 'Frostfire Gloves', 'normal'),
    (22371, 8, 1, 22501, 3, 'Desecrated Gloves', 'Frostfire Gloves', 'normal'),
    (22371, 8, 2, 22501, 3, 'Desecrated Gloves', 'Frostfire Gloves', 'normal'),
    (22369, 8, 0, 22503, 3, 'Desecrated Bindings', 'Frostfire Bindings', 'normal'),
    (22369, 8, 1, 22503, 3, 'Desecrated Bindings', 'Frostfire Bindings', 'normal'),
    (22369, 8, 2, 22503, 3, 'Desecrated Bindings', 'Frostfire Bindings', 'normal'),
    (22370, 8, 0, 22502, 3, 'Desecrated Belt', 'Frostfire Belt', 'normal'),
    (22370, 8, 1, 22502, 3, 'Desecrated Belt', 'Frostfire Belt', 'normal'),
    (22370, 8, 2, 22502, 3, 'Desecrated Belt', 'Frostfire Belt', 'normal'),
    (22366, 8, 0, 22497, 3, 'Desecrated Leggings', 'Frostfire Leggings', 'normal'),
    (22366, 8, 1, 22497, 3, 'Desecrated Leggings', 'Frostfire Leggings', 'normal'),
    (22366, 8, 2, 22497, 3, 'Desecrated Leggings', 'Frostfire Leggings', 'normal'),
    (22372, 8, 0, 22500, 3, 'Desecrated Sandals', 'Frostfire Sandals', 'normal'),
    (22372, 8, 1, 22500, 3, 'Desecrated Sandals', 'Frostfire Sandals', 'normal'),
    (22372, 8, 2, 22500, 3, 'Desecrated Sandals', 'Frostfire Sandals', 'normal');

-- Warlock T3 (Plagueheart), Priest+Mage+Warlock family. Single itemization -
-- no talent-tab branching, all 3 tabs share the same piece per slot.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (22351, 22366, 22367, 22368, 22369, 22370, 22371, 22372) AND `class_id` = 9;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (22367, 9, 0, 22506, 3, 'Desecrated Circlet', 'Plagueheart Circlet', 'normal'),
    (22367, 9, 1, 22506, 3, 'Desecrated Circlet', 'Plagueheart Circlet', 'normal'),
    (22367, 9, 2, 22506, 3, 'Desecrated Circlet', 'Plagueheart Circlet', 'normal'),
    (22368, 9, 0, 22507, 3, 'Desecrated Shoulderpads', 'Plagueheart Shoulderpads', 'normal'),
    (22368, 9, 1, 22507, 3, 'Desecrated Shoulderpads', 'Plagueheart Shoulderpads', 'normal'),
    (22368, 9, 2, 22507, 3, 'Desecrated Shoulderpads', 'Plagueheart Shoulderpads', 'normal'),
    (22351, 9, 0, 22504, 3, 'Desecrated Robe', 'Plagueheart Robe', 'normal'),
    (22351, 9, 1, 22504, 3, 'Desecrated Robe', 'Plagueheart Robe', 'normal'),
    (22351, 9, 2, 22504, 3, 'Desecrated Robe', 'Plagueheart Robe', 'normal'),
    (22371, 9, 0, 22509, 3, 'Desecrated Gloves', 'Plagueheart Gloves', 'normal'),
    (22371, 9, 1, 22509, 3, 'Desecrated Gloves', 'Plagueheart Gloves', 'normal'),
    (22371, 9, 2, 22509, 3, 'Desecrated Gloves', 'Plagueheart Gloves', 'normal'),
    (22369, 9, 0, 22511, 3, 'Desecrated Bindings', 'Plagueheart Bindings', 'normal'),
    (22369, 9, 1, 22511, 3, 'Desecrated Bindings', 'Plagueheart Bindings', 'normal'),
    (22369, 9, 2, 22511, 3, 'Desecrated Bindings', 'Plagueheart Bindings', 'normal'),
    (22370, 9, 0, 22510, 3, 'Desecrated Belt', 'Plagueheart Belt', 'normal'),
    (22370, 9, 1, 22510, 3, 'Desecrated Belt', 'Plagueheart Belt', 'normal'),
    (22370, 9, 2, 22510, 3, 'Desecrated Belt', 'Plagueheart Belt', 'normal'),
    (22366, 9, 0, 22505, 3, 'Desecrated Leggings', 'Plagueheart Leggings', 'normal'),
    (22366, 9, 1, 22505, 3, 'Desecrated Leggings', 'Plagueheart Leggings', 'normal'),
    (22366, 9, 2, 22505, 3, 'Desecrated Leggings', 'Plagueheart Leggings', 'normal'),
    (22372, 9, 0, 22508, 3, 'Desecrated Sandals', 'Plagueheart Sandals', 'normal'),
    (22372, 9, 1, 22508, 3, 'Desecrated Sandals', 'Plagueheart Sandals', 'normal'),
    (22372, 9, 2, 22508, 3, 'Desecrated Sandals', 'Plagueheart Sandals', 'normal');

-- Paladin T3 (Redemption), Paladin+Hunter+Shaman+Druid family. Single itemization -
-- no talent-tab branching, all 3 tabs share the same piece per slot.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (22350, 22359, 22360, 22361, 22362, 22363, 22364, 22365) AND `class_id` = 2;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (22360, 2, 0, 22428, 3, 'Desecrated Headpiece', 'Redemption Headpiece', 'normal'),
    (22360, 2, 1, 22428, 3, 'Desecrated Headpiece', 'Redemption Headpiece', 'normal'),
    (22360, 2, 2, 22428, 3, 'Desecrated Headpiece', 'Redemption Headpiece', 'normal'),
    (22361, 2, 0, 22429, 3, 'Desecrated Spaulders', 'Redemption Spaulders', 'normal'),
    (22361, 2, 1, 22429, 3, 'Desecrated Spaulders', 'Redemption Spaulders', 'normal'),
    (22361, 2, 2, 22429, 3, 'Desecrated Spaulders', 'Redemption Spaulders', 'normal'),
    (22350, 2, 0, 22425, 3, 'Desecrated Tunic', 'Redemption Tunic', 'normal'),
    (22350, 2, 1, 22425, 3, 'Desecrated Tunic', 'Redemption Tunic', 'normal'),
    (22350, 2, 2, 22425, 3, 'Desecrated Tunic', 'Redemption Tunic', 'normal'),
    (22364, 2, 0, 22426, 3, 'Desecrated Handguards', 'Redemption Handguards', 'normal'),
    (22364, 2, 1, 22426, 3, 'Desecrated Handguards', 'Redemption Handguards', 'normal'),
    (22364, 2, 2, 22426, 3, 'Desecrated Handguards', 'Redemption Handguards', 'normal'),
    (22362, 2, 0, 22424, 3, 'Desecrated Wristguards', 'Redemption Wristguards', 'normal'),
    (22362, 2, 1, 22424, 3, 'Desecrated Wristguards', 'Redemption Wristguards', 'normal'),
    (22362, 2, 2, 22424, 3, 'Desecrated Wristguards', 'Redemption Wristguards', 'normal'),
    (22363, 2, 0, 22431, 3, 'Desecrated Girdle', 'Redemption Girdle', 'normal'),
    (22363, 2, 1, 22431, 3, 'Desecrated Girdle', 'Redemption Girdle', 'normal'),
    (22363, 2, 2, 22431, 3, 'Desecrated Girdle', 'Redemption Girdle', 'normal'),
    (22359, 2, 0, 22427, 3, 'Desecrated Legguards', 'Redemption Legguards', 'normal'),
    (22359, 2, 1, 22427, 3, 'Desecrated Legguards', 'Redemption Legguards', 'normal'),
    (22359, 2, 2, 22427, 3, 'Desecrated Legguards', 'Redemption Legguards', 'normal'),
    (22365, 2, 0, 22430, 3, 'Desecrated Boots', 'Redemption Boots', 'normal'),
    (22365, 2, 1, 22430, 3, 'Desecrated Boots', 'Redemption Boots', 'normal'),
    (22365, 2, 2, 22430, 3, 'Desecrated Boots', 'Redemption Boots', 'normal');

-- Hunter T3 (Cryptstalker), Paladin+Hunter+Shaman+Druid family. Single itemization -
-- no talent-tab branching, all 3 tabs share the same piece per slot.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (22350, 22359, 22360, 22361, 22362, 22363, 22364, 22365) AND `class_id` = 3;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (22360, 3, 0, 22438, 3, 'Desecrated Headpiece', 'Cryptstalker Headpiece', 'normal'),
    (22360, 3, 1, 22438, 3, 'Desecrated Headpiece', 'Cryptstalker Headpiece', 'normal'),
    (22360, 3, 2, 22438, 3, 'Desecrated Headpiece', 'Cryptstalker Headpiece', 'normal'),
    (22361, 3, 0, 22439, 3, 'Desecrated Spaulders', 'Cryptstalker Spaulders', 'normal'),
    (22361, 3, 1, 22439, 3, 'Desecrated Spaulders', 'Cryptstalker Spaulders', 'normal'),
    (22361, 3, 2, 22439, 3, 'Desecrated Spaulders', 'Cryptstalker Spaulders', 'normal'),
    (22350, 3, 0, 22436, 3, 'Desecrated Tunic', 'Cryptstalker Tunic', 'normal'),
    (22350, 3, 1, 22436, 3, 'Desecrated Tunic', 'Cryptstalker Tunic', 'normal'),
    (22350, 3, 2, 22436, 3, 'Desecrated Tunic', 'Cryptstalker Tunic', 'normal'),
    (22364, 3, 0, 22441, 3, 'Desecrated Handguards', 'Cryptstalker Handguards', 'normal'),
    (22364, 3, 1, 22441, 3, 'Desecrated Handguards', 'Cryptstalker Handguards', 'normal'),
    (22364, 3, 2, 22441, 3, 'Desecrated Handguards', 'Cryptstalker Handguards', 'normal'),
    (22362, 3, 0, 22443, 3, 'Desecrated Wristguards', 'Cryptstalker Wristguards', 'normal'),
    (22362, 3, 1, 22443, 3, 'Desecrated Wristguards', 'Cryptstalker Wristguards', 'normal'),
    (22362, 3, 2, 22443, 3, 'Desecrated Wristguards', 'Cryptstalker Wristguards', 'normal'),
    (22363, 3, 0, 22442, 3, 'Desecrated Girdle', 'Cryptstalker Girdle', 'normal'),
    (22363, 3, 1, 22442, 3, 'Desecrated Girdle', 'Cryptstalker Girdle', 'normal'),
    (22363, 3, 2, 22442, 3, 'Desecrated Girdle', 'Cryptstalker Girdle', 'normal'),
    (22359, 3, 0, 22437, 3, 'Desecrated Legguards', 'Cryptstalker Legguards', 'normal'),
    (22359, 3, 1, 22437, 3, 'Desecrated Legguards', 'Cryptstalker Legguards', 'normal'),
    (22359, 3, 2, 22437, 3, 'Desecrated Legguards', 'Cryptstalker Legguards', 'normal'),
    (22365, 3, 0, 22440, 3, 'Desecrated Boots', 'Cryptstalker Boots', 'normal'),
    (22365, 3, 1, 22440, 3, 'Desecrated Boots', 'Cryptstalker Boots', 'normal'),
    (22365, 3, 2, 22440, 3, 'Desecrated Boots', 'Cryptstalker Boots', 'normal');

-- Shaman T3 (Earthshatterer), Paladin+Hunter+Shaman+Druid family. Single itemization -
-- no talent-tab branching, all 3 tabs share the same piece per slot.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (22350, 22359, 22360, 22361, 22362, 22363, 22364, 22365) AND `class_id` = 7;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (22360, 7, 0, 22466, 3, 'Desecrated Headpiece', 'Earthshatter Headpiece', 'normal'),
    (22360, 7, 1, 22466, 3, 'Desecrated Headpiece', 'Earthshatter Headpiece', 'normal'),
    (22360, 7, 2, 22466, 3, 'Desecrated Headpiece', 'Earthshatter Headpiece', 'normal'),
    (22361, 7, 0, 22467, 3, 'Desecrated Spaulders', 'Earthshatter Spaulders', 'normal'),
    (22361, 7, 1, 22467, 3, 'Desecrated Spaulders', 'Earthshatter Spaulders', 'normal'),
    (22361, 7, 2, 22467, 3, 'Desecrated Spaulders', 'Earthshatter Spaulders', 'normal'),
    (22350, 7, 0, 22464, 3, 'Desecrated Tunic', 'Earthshatter Tunic', 'normal'),
    (22350, 7, 1, 22464, 3, 'Desecrated Tunic', 'Earthshatter Tunic', 'normal'),
    (22350, 7, 2, 22464, 3, 'Desecrated Tunic', 'Earthshatter Tunic', 'normal'),
    (22364, 7, 0, 22469, 3, 'Desecrated Handguards', 'Earthshatter Handguards', 'normal'),
    (22364, 7, 1, 22469, 3, 'Desecrated Handguards', 'Earthshatter Handguards', 'normal'),
    (22364, 7, 2, 22469, 3, 'Desecrated Handguards', 'Earthshatter Handguards', 'normal'),
    (22362, 7, 0, 22471, 3, 'Desecrated Wristguards', 'Earthshatter Wristguards', 'normal'),
    (22362, 7, 1, 22471, 3, 'Desecrated Wristguards', 'Earthshatter Wristguards', 'normal'),
    (22362, 7, 2, 22471, 3, 'Desecrated Wristguards', 'Earthshatter Wristguards', 'normal'),
    (22363, 7, 0, 22470, 3, 'Desecrated Girdle', 'Earthshatter Girdle', 'normal'),
    (22363, 7, 1, 22470, 3, 'Desecrated Girdle', 'Earthshatter Girdle', 'normal'),
    (22363, 7, 2, 22470, 3, 'Desecrated Girdle', 'Earthshatter Girdle', 'normal'),
    (22359, 7, 0, 22465, 3, 'Desecrated Legguards', 'Earthshatter Legguards', 'normal'),
    (22359, 7, 1, 22465, 3, 'Desecrated Legguards', 'Earthshatter Legguards', 'normal'),
    (22359, 7, 2, 22465, 3, 'Desecrated Legguards', 'Earthshatter Legguards', 'normal'),
    (22365, 7, 0, 22468, 3, 'Desecrated Boots', 'Earthshatter Boots', 'normal'),
    (22365, 7, 1, 22468, 3, 'Desecrated Boots', 'Earthshatter Boots', 'normal'),
    (22365, 7, 2, 22468, 3, 'Desecrated Boots', 'Earthshatter Boots', 'normal');

-- Druid T3 (Dreamwalker), Paladin+Hunter+Shaman+Druid family. Single itemization -
-- no talent-tab branching, all 3 tabs share the same piece per slot.
DELETE FROM `mod_token_turnin_tokens` WHERE `token_entry` IN (22350, 22359, 22360, 22361, 22362, 22363, 22364, 22365) AND `class_id` = 11;
INSERT INTO `mod_token_turnin_tokens`
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `token_name`, `result_name`, `difficulty`)
VALUES
    (22360, 11, 0, 22490, 3, 'Desecrated Headpiece', 'Dreamwalker Headpiece', 'normal'),
    (22360, 11, 1, 22490, 3, 'Desecrated Headpiece', 'Dreamwalker Headpiece', 'normal'),
    (22360, 11, 2, 22490, 3, 'Desecrated Headpiece', 'Dreamwalker Headpiece', 'normal'),
    (22361, 11, 0, 22491, 3, 'Desecrated Spaulders', 'Dreamwalker Spaulders', 'normal'),
    (22361, 11, 1, 22491, 3, 'Desecrated Spaulders', 'Dreamwalker Spaulders', 'normal'),
    (22361, 11, 2, 22491, 3, 'Desecrated Spaulders', 'Dreamwalker Spaulders', 'normal'),
    (22350, 11, 0, 22488, 3, 'Desecrated Tunic', 'Dreamwalker Tunic', 'normal'),
    (22350, 11, 1, 22488, 3, 'Desecrated Tunic', 'Dreamwalker Tunic', 'normal'),
    (22350, 11, 2, 22488, 3, 'Desecrated Tunic', 'Dreamwalker Tunic', 'normal'),
    (22364, 11, 0, 22493, 3, 'Desecrated Handguards', 'Dreamwalker Handguards', 'normal'),
    (22364, 11, 1, 22493, 3, 'Desecrated Handguards', 'Dreamwalker Handguards', 'normal'),
    (22364, 11, 2, 22493, 3, 'Desecrated Handguards', 'Dreamwalker Handguards', 'normal'),
    (22362, 11, 0, 22495, 3, 'Desecrated Wristguards', 'Dreamwalker Wristguards', 'normal'),
    (22362, 11, 1, 22495, 3, 'Desecrated Wristguards', 'Dreamwalker Wristguards', 'normal'),
    (22362, 11, 2, 22495, 3, 'Desecrated Wristguards', 'Dreamwalker Wristguards', 'normal'),
    (22363, 11, 0, 22494, 3, 'Desecrated Girdle', 'Dreamwalker Girdle', 'normal'),
    (22363, 11, 1, 22494, 3, 'Desecrated Girdle', 'Dreamwalker Girdle', 'normal'),
    (22363, 11, 2, 22494, 3, 'Desecrated Girdle', 'Dreamwalker Girdle', 'normal'),
    (22359, 11, 0, 22489, 3, 'Desecrated Legguards', 'Dreamwalker Legguards', 'normal'),
    (22359, 11, 1, 22489, 3, 'Desecrated Legguards', 'Dreamwalker Legguards', 'normal'),
    (22359, 11, 2, 22489, 3, 'Desecrated Legguards', 'Dreamwalker Legguards', 'normal'),
    (22365, 11, 0, 22492, 3, 'Desecrated Boots', 'Dreamwalker Boots', 'normal'),
    (22365, 11, 1, 22492, 3, 'Desecrated Boots', 'Dreamwalker Boots', 'normal'),
    (22365, 11, 2, 22492, 3, 'Desecrated Boots', 'Dreamwalker Boots', 'normal');
