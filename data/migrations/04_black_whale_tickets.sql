-- Migration 04: Black Whale Tier Passports
-- Um jogador só pode ter 1 status VIP no Navio (Tier 1 a 5, onde 1 é o melhor).

CREATE TABLE IF NOT EXISTS `player_black_whale_ticket` (
  `player_id` int(11) NOT NULL,
  `tier` int(11) NOT NULL DEFAULT 5, -- Todo mundo começa na miséria do Tier 5
  `purchased_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`player_id`),
  FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
