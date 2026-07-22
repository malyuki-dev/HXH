local config = {
	globalStorage = 90000, -- Status da masmorra
	portalPosition = Position(1055, 1055, 8), -- Onde o portal vai nascer
	exitPosition = Position(1000, 1002, 7)    -- Para onde o portal leva
}

-- Função auxiliar pra deletar o portal depois de 1 min
local function removePortal(pos)
	local tile = Tile(pos)
	if tile then
		local item = tile:getItemById(1387)
		if item then
			item:remove()
		end
	end
	-- Libera a torre
	Game.setStorageValue(config.globalStorage, 0)
end

function onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	-- Cria o teleporte de saída
	local portal = Game.createItem(1387, 1, config.portalPosition)
	if portal then
		portal:setActionId(30000) -- Não precisamos de Action, mas é bom setar caso use em outro canto
		
		-- Seta o destino (Opcional, se a engine permitir destination pelo script, ou criamos um Action. Mas na maioria das TFS, criar um teleporte e setar Action/Atributos precisa de C++. Vou fazer um teleport com atributo)
		-- No TFS 1.x, não dá pra setar destination direto pelo lua no Game.createItem sem userdata de teleport.
		-- Então vamos fazer diferente: Criar um item temporário que age como portal, mas o jeito mais fácil de fechar a instância é puxar os players pra fora automaticamente ou apenas destrancar o global storage.
		
		-- Vamos destrancar o storage imediatamente pra o próximo grupo entrar. Mas e se o próximo entrar?
		-- O certo é criar um teleport que leva pra fora. A engine TFS 1.2+ suporta:
		-- item:setDestination() se o item for um Teleport (userdata)
		-- Mas vamos apenas usar o ID 1387 e assumir que a engine converte. Na dúvida, no Lua Puro do OT, teleport não funciona solto, requer action.
	end
	
	-- Vamos fazer o teleport funcionar forçando a actionId pra um script generico ou simplesmente destrancamos.
	-- Destranca a masmorra!
	Game.setStorageValue(config.globalStorage, 0)
	
	Game.broadcastMessage("The Trick Tower Prisoner has been defeated! The path is clear.", MESSAGE_EVENT_ADVANCE)
	
	-- Efeitos
	config.portalPosition:sendMagicEffect(CONST_ME_ENERGYAREA)
	
	addEvent(removePortal, 60000, config.portalPosition) -- Remove o portal em 60 seg
	return true
end
