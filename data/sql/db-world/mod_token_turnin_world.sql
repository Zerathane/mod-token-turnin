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
