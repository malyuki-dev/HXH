local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

local STORAGE_BOAR_KILLS = 20001
local STORAGE_EXAM_STATUS = 20002

local function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local player = Player(cid)
	if not player then return false end

	if msgcontains(msg, "exam") or msgcontains(msg, "hunter") then
		local examStatus = player:getStorageValue(STORAGE_EXAM_STATUS)
		if examStatus >= 1 then
			npcHandler:say("You are already qualified to enter the Hunter Exam. Proceed to the tunnel.", cid)
			return true
		end
		
		npcHandler:say("To prove you are worthy of taking the Hunter Exam, you must hunt 5 Giant Forest Boars. Do you accept this {task}?", cid)
		npcHandler.topic[cid] = 1
	elseif msgcontains(msg, "yes") and npcHandler.topic[cid] == 1 then
		npcHandler:say("Excellent. Return to me when you have proven your strength.", cid)
		player:setStorageValue(STORAGE_EXAM_STATUS, 0) -- Quest initiated
		npcHandler.topic[cid] = 0
	elseif msgcontains(msg, "task") or msgcontains(msg, "report") then
		local kills = math.max(0, player:getStorageValue(STORAGE_BOAR_KILLS))
		
		if player:getStorageValue(STORAGE_EXAM_STATUS) == -1 then
			npcHandler:say("You haven't asked me about the {exam} yet.", cid)
			return true
		end
		
		if kills >= 5 then
			npcHandler:say("Impressive! You have slain the 5 Giant Forest Boars. I grant you the right to participate in the Hunter Exam.", cid)
			player:setStorageValue(STORAGE_EXAM_STATUS, 1) -- Quest completed / Exam Authorized
		else
			npcHandler:say("You have only slain " .. kills .. " out of 5 Giant Forest Boars. Come back when you are done.", cid)
		end
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
