#include "blueprintmanager.h"
#include "pugicast.h"
#include <pugixml.hpp>
#include "item.h"

bool BlueprintManager::loadFromXml(const std::string& filename) {
    pugi::xml_document doc;
    pugi::xml_parse_result result = doc.load_file(filename.c_str());

    if (!result) {
        // file not found or invalid
        return false;
    }

    for (auto node : doc.child("blueprints").children("blueprint")) {
        Blueprint bp;
        bp.id = pugi::cast<uint32_t>(node.attribute("id").value());
        bp.name = node.attribute("name").value();
        bp.resultItemId = pugi::cast<uint16_t>(node.attribute("resultItemId").value());
        bp.resultCount = pugi::cast<uint16_t>(node.attribute("resultCount").value());

        for (auto reqNode : node.children("requirement")) {
            BlueprintRequirement req;
            req.itemId = pugi::cast<uint16_t>(reqNode.attribute("itemId").value());
            req.count = pugi::cast<uint16_t>(reqNode.attribute("count").value());
            bp.requirements.push_back(req);
        }

        blueprints[bp.id] = bp;
    }
    return true;
}

const Blueprint* BlueprintManager::getBlueprint(uint32_t id) const {
    auto it = blueprints.find(id);
    if (it != blueprints.end()) {
        return &it->second;
    }
    return nullptr;
}

bool BlueprintManager::craft(Player* player, uint32_t blueprintId) {
    if (!player) return false;

    const Blueprint* bp = getBlueprint(blueprintId);
    if (!bp) return false;

    // Verify requirements
    for (const auto& req : bp->requirements) {
        if (player->getItemTypeCount(req.itemId) < req.count) {
            player->sendTextMessage(MESSAGE_STATUS_SMALL, "You do not have the required materials.");
            return false;
        }
    }

    // Remove requirements
    for (const auto& req : bp->requirements) {
        player->removeItemOfType(req.itemId, req.count, -1, false);
    }

    // Add result
    Item* item = Item::CreateItem(bp->resultItemId, bp->resultCount);
    if (item) {
        ReturnValue ret = player->internalAddItem(item);
        if (ret != RETURNVALUE_NOERROR) {
            // Drop on floor or something if full (simplified here)
            // Just returning false here would mean materials are lost, so usually you add to inbox or floor
        }
        player->sendTextMessage(MESSAGE_INFO_DESCR, "You crafted an item.");
        return true;
    }
    
    return false;
}
