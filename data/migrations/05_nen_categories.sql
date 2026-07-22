-- Migration 05: Nen Categories
-- Adicionando a coluna do Teste do Copo de Água diretamente aos Players

ALTER TABLE `players` ADD COLUMN IF NOT EXISTS `nen_category` int(11) DEFAULT NULL;
