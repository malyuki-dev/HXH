local NEN_CATEGORY_NONE = -1
local NEN_CATEGORY_REFORCO = 0
local NEN_CATEGORY_TRANSFORMACAO = 1
local NEN_CATEGORY_EMISSAO = 2
local NEN_CATEGORY_MANIPULACAO = 3
local NEN_CATEGORY_MATERIALIZACAO = 4
local NEN_CATEGORY_ESPECIALIZACAO = 5

local categoriasNen = {
    [NEN_CATEGORY_REFORCO] = "Reforco",
    [NEN_CATEGORY_TRANSFORMACAO] = "Transformacao",
    [NEN_CATEGORY_EMISSAO] = "Emissao",
    [NEN_CATEGORY_MANIPULACAO] = "Manipulacao",
    [NEN_CATEGORY_MATERIALIZACAO] = "Materializacao",
    [NEN_CATEGORY_ESPECIALIZACAO] = "Especializacao"
}

function onSay(player, words, param)
    local nen = player:getNenCategory()

    if nen == NEN_CATEGORY_NONE then
        player:generateNenAffinity()
        nen = player:getNenCategory()
        local nomeAfinidade = categoriasNen[nen] or "Desconhecido"
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "O teste da agua revelou sua afinidade! Voce e do tipo: " .. nomeAfinidade .. ".")
    else
        local nomeAfinidade = categoriasNen[nen] or "Desconhecido"
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Sua aura ja foi despertada. Voce e do tipo: " .. nomeAfinidade .. ".")
    end

    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    
    return false
end
