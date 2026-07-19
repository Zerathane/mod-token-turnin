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
