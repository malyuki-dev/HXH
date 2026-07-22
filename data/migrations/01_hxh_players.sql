-- Migration 01: Hunter x Hunter Core Systems
-- Injeta as colunas base de sistema de Nen e Hunter License na tabela padrão "players"

ALTER TABLE `players` ADD COLUMN `hunter_license_id` VARCHAR(50) DEFAULT NULL;
ALTER TABLE `players` ADD COLUMN `nen_category` INT NOT NULL DEFAULT 0;
ALTER TABLE `players` ADD COLUMN `aura_capacity` INT NOT NULL DEFAULT 100;
