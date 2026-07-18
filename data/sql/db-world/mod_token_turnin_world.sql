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
    (`token_entry`, `class_id`, `talent_tab`, `result_item_entry`, `tier`, `difficulty`)
VALUES
    -- Leggings of the Fallen Defender
    (29767, 11, 0, 29094, 4, 'normal'),
    (29767, 11, 1, 29099, 4, 'normal'),
    (29767, 11, 2, 29088, 4, 'normal'),
    -- Pauldrons of the Fallen Defender
    (29764, 11, 0, 29095, 4, 'normal'),
    (29764, 11, 1, 29100, 4, 'normal'),
    (29764, 11, 2, 29089, 4, 'normal'),
    -- Helm of the Fallen Defender
    (29761, 11, 0, 29093, 4, 'normal'),
    (29761, 11, 1, 29098, 4, 'normal'),
    (29761, 11, 2, 29086, 4, 'normal'),
    -- Gloves of the Fallen Defender
    (29758, 11, 0, 29092, 4, 'normal'),
    (29758, 11, 1, 29097, 4, 'normal'),
    (29758, 11, 2, 29090, 4, 'normal'),
    -- Chestguard of the Fallen Defender
    (29753, 11, 0, 29091, 4, 'normal'),
    (29753, 11, 1, 29096, 4, 'normal'),
    (29753, 11, 2, 29087, 4, 'normal');
