-- Migration 03: Phantom Troupe (Genei Ryodan)
-- Facção exclusiva de PvP. Apenas 13 vagas únicas.

CREATE TABLE IF NOT EXISTS `phantom_troupe` (
  `spider_number` int(11) NOT NULL, -- 0 (Líder) a 12 (Pernas)
  `player_id` int(11) NOT NULL,
  `joined_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`spider_number`), -- Apenas 1 pessoa pode ter a aranha #4, por exemplo.
  UNIQUE KEY `unique_troupe_player` (`player_id`), -- Um jogador não pode ter duas tatuagens.
  FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
