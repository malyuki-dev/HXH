-- Conjuração da Magia Roubada
-- Requer: data/lib/nen/bandits_secret_system.lua

function onSay(player, words, param)
	-- O núcleo polimórfico cuida do resto (Validação de mana, dano e vetores)
	BanditsSecret.castStolen(player)
	return false
end
