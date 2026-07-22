-- Migration 02: Greed Island Binder
-- Criação da tabela relacional para armazenamento de Cartas do Livro de Greed Island (0-99 Slots)

CREATE TABLE IF NOT EXISTS `player_greed_island` (
  `player_id` int(11) NOT NULL,
  `card_id` int(11) NOT NULL,
  `acquired_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE,
  UNIQUE KEY `player_card_unique` (`player_id`, `card_id`) -- Um jogador não pode ter mais de 1 mesma carta do slot restrito
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
