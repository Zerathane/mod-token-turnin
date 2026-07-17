/*
 * mod_token_turnin - CommandScript
 *
 * Verified against uploaded headers:
 *  - CommandScript hook is GetCommands() const (NOT GetChatCommands()) -
 *    CommandScript.h:31. ScriptMgr::GetChatCommands() is the *manager*
 *    method that aggregates every CommandScript's GetCommands() output -
 *    not the one we override.
 *  - PSendSysMessage uses {}-style formatting (Acore::StringFormat), not printf %s/%u
 *    (confirmed via Chat.h:147 and the working mod_junk_to_gold.cpp example)
 *  - Player::DestroyItemCount(item, count, update, unequip_check=false) - Player.h:1366
 *  - Player::StoreNewItemInBestSlots(item_id, item_count) - Player.h:1334
 *  - Player::GetItemByPos(bag, slot) - Player.h:1263
 *  - Group::GetFirstMember() returns GroupReference*, GroupReference itself is only
 *    forward-declared in Group.h - iteration idiom (->next(), ->GetSource()) is the
 *    standard AzerothCore pattern but its exact header wasn't in what I've been given,
 *    so still worth a quick sanity check against GroupReference.h in your tree.
 *  - Group::isRaidGroup() exists (Group.h:221), but scanning via GetFirstMember() covers
 *    party and raid identically - no branching needed on group type at all.
 *
 * Confirmed via Talentspec.cpp:
 *  - TalentSpec::highestTree() is fully implemented (not dead code despite the
 *    "unused currently" comment on the class) - compares GetTalentPoints(0/1/2)
 *    and returns the tab with the most points invested.
 *
 * Confirmed via ChatHelper.h/.cpp:
 *  - A class -> talent_tab -> spec name table already exists there
 *    (ChatHelper::specs), but it's private and FormatClass() wraps it with
 *    WoW chat-link color formatting we don't want. Reproduced as our own
 *    small static table below instead (kSpecNames) - same data, no formatting,
 *    no access issues.
 *
 * Resolved design point:
 *  - difficulty (normal/heroic/10/25) is NOT part of the lookup condition.
 *    Each difficulty's token is already a distinct token_entry (distinct
 *    item_id) in game data, so difficulty is implied by which token was
 *    scanned, not resolved at query time. Lookup is purely
 *    token_entry + talent_tab -> result_item_entry.
 *
 * Resolved design point:
 *  - Full-inventory fallback is "block": StoreNewItemInBestSlots() is tried
 *    before DestroyItemCount(), so a bot with no free space keeps its token
 *    (nothing lost) and gets a chat message instead of a mailed item.
 */

#include "Bag.h"
#include "Chat.h"
#include "ChatCommand.h"
#include "DatabaseEnv.h"
#include "Group.h"
#include "Item.h"
#include "ObjectMgr.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "StringFormat.h"
#include "Talentspec.h"
#include <sstream>
#include <vector>
#include <string>

using namespace Acore::ChatCommands;

namespace
{
    // Reproduced from ChatHelper::specs (playerbots ChatHelper.cpp), which is
    // private to that class. Same data, no chat-link formatting attached.
    // class_id -> talent_tab (0/1/2) -> display name.
    std::map<uint8, std::map<uint8, std::string>> const kSpecNames =
    {
        { CLASS_WARRIOR,      { {0, "arms"},          {1, "fury"},          {2, "protection"}  } },
        { CLASS_PALADIN,      { {0, "holy"},          {1, "protection"},    {2, "retribution"} } },
        { CLASS_HUNTER,       { {0, "beast mastery"}, {1, "marksmanship"},  {2, "survival"}    } },
        { CLASS_ROGUE,        { {0, "assasination"},  {1, "combat"},        {2, "subtlety"}    } },
        { CLASS_PRIEST,       { {0, "discipline"},    {1, "holy"},          {2, "shadow"}      } },
        { CLASS_DEATH_KNIGHT, { {0, "blood"},         {1, "frost"},         {2, "unholy"}      } },
        { CLASS_SHAMAN,       { {0, "elemental"},     {1, "enhancement"},   {2, "restoration"} } },
        { CLASS_MAGE,         { {0, "arcane"},        {1, "fire"},          {2, "frost"}       } },
        { CLASS_WARLOCK,      { {0, "affliction"},    {1, "demonology"},    {2, "destruction"} } },
        { CLASS_DRUID,        { {0, "balance"},       {1, "feral combat"},  {2, "restoration"} } },
    };

    std::string ResolveSpecLabel(uint8 classId, uint8 talentTab)
    {
        auto classIt = kSpecNames.find(classId);
        if (classIt == kSpecNames.end())
            return "unknown";

        auto tabIt = classIt->second.find(talentTab);
        return (tabIt != classIt->second.end()) ? tabIt->second : "unknown";
    }

    // Builds a clickable in-game chat item link, e.g. |cff1eff00|Hitem:12345:0:0:0:0:0:0:0:0:0|h[Item Name]|h|r
    // Same idiom as cs_character.cpp's inventory listing. Falls back to a
    // plain entry number if the item no longer has a template (bad data).
    std::string BuildItemLink(uint32 itemEntry)
    {
        ItemTemplate const* itemTemplate = sObjectMgr->GetItemTemplate(itemEntry);
        if (!itemTemplate)
            return Acore::StringFormat("[unknown item {}]", itemEntry);

        std::ostringstream color;
        color << std::hex << ItemQualityColors[itemTemplate->Quality] << std::dec;

        return Acore::StringFormat("|c{}|Hitem:{}:0:0:0:0:0:0:0:0:0|h[{}]|h|r",
            color.str(), itemEntry, itemTemplate->Name1);
    }

    struct TokenConversionResult
    {
        std::string charName;
        std::string specLabel;
        uint32 tokenEntry = 0;
        uint32 resultItemEntry = 0;
        bool matched = false;
        bool inventoryFull = false;
    };

    // Collects the item entry of every item in the target's backpack and
    // equipped bags (bank is out of scope - tokens are looted into bags,
    // not banked). Mirrors the iteration idiom used by Player::GetItemCount.
    std::vector<Item*> CollectBagItems(Player* target)
    {
        std::vector<Item*> items;

        for (uint8 slot = INVENTORY_SLOT_ITEM_START; slot < INVENTORY_SLOT_ITEM_END; ++slot)
            if (Item* item = target->GetItemByPos(INVENTORY_SLOT_BAG_0, slot))
                items.push_back(item);

        for (uint8 bagSlot = INVENTORY_SLOT_BAG_START; bagSlot < INVENTORY_SLOT_BAG_END; ++bagSlot)
            if (Bag* bag = target->GetBagByPos(bagSlot))
                for (uint32 slot = 0; slot < bag->GetBagSize(); ++slot)
                    if (Item* item = bag->GetItemByPos(slot))
                        items.push_back(item);

        return items;
    }

    // Core scan+resolve logic shared by "check" and "redeem".
    // doConvert = false -> report only, no destroy/award.
    std::vector<TokenConversionResult> ScanAndResolve(Player* target, bool doConvert)
    {
        std::vector<TokenConversionResult> results;

        // 1. Resolve current spec via playerbots talent logic.
        TalentSpec spec(target);
        uint8 talentTab = static_cast<uint8>(spec.highestTree());
        std::string specLabel = ResolveSpecLabel(target->getClass(), talentTab);

        // 2. Scan backpack + bags for any token_entry present in
        //    mod_token_turnin_tokens. Difficulty is NOT part of the lookup -
        //    it's implied by which token_entry was found, since each
        //    difficulty's token is already a distinct item_id in game data.
        for (Item* item : CollectBagItems(target))
        {
            uint32 tokenEntry = item->GetEntry();

            QueryResult queryResult = WorldDatabase.Query(
                "SELECT result_item_entry FROM mod_token_turnin_tokens WHERE token_entry = {} AND talent_tab = {}",
                tokenEntry, talentTab);

            if (!queryResult)
                continue;

            uint32 resultItemEntry = queryResult->Fetch()[0].Get<uint32>();

            TokenConversionResult match;
            match.charName = target->GetName();
            match.specLabel = specLabel;
            match.tokenEntry = tokenEntry;
            match.resultItemEntry = resultItemEntry;
            match.matched = true;

            // 3. Award before destroying: if there's no room for the result
            //    item, the token is left untouched rather than lost.
            if (doConvert)
            {
                if (target->StoreNewItemInBestSlots(resultItemEntry, 1))
                    target->DestroyItemCount(tokenEntry, 1, true);
                else
                    match.inventoryFull = true;
            }

            results.push_back(match);
        }

        if (results.empty())
        {
            TokenConversionResult none;
            none.charName = target->GetName();
            none.matched = false;
            results.push_back(none);
        }

        return results;
    }

    void ReportResults(ChatHandler* handler, std::vector<TokenConversionResult> const& results)
    {
        for (auto const& r : results)
        {
            if (r.matched)
            {
                handler->PSendSysMessage(
                    "[TokenTurnIn] {} ({}) -> Token: {} -> Item: {}",
                    r.charName, r.specLabel, BuildItemLink(r.tokenEntry), BuildItemLink(r.resultItemEntry));

                if (r.inventoryFull)
                    handler->PSendSysMessage(
                        "[TokenTurnIn] {} has no inventory space for {} - token not consumed",
                        r.charName, BuildItemLink(r.resultItemEntry));
            }
            else
            {
                handler->PSendSysMessage(
                    "[TokenTurnIn] No convertible tokens found on {}", r.charName);
            }
        }
    }

    // Collects self, and if grouped, party/raid members. GetFirstMember() covers
    // both party and raid identically - no need to branch on isRaidGroup().
    std::vector<Player*> ResolveScanScope(Player* invoker)
    {
        std::vector<Player*> scope;
        scope.push_back(invoker);

        if (Group* group = invoker->GetGroup())
        {
            for (GroupReference* itr = group->GetFirstMember(); itr != nullptr; itr = itr->next())
            {
                if (Player* member = itr->GetSource())
                    if (member != invoker)
                        scope.push_back(member);
            }
        }

        return scope;
    }

    void RunTokenTurnIn(ChatHandler* handler, bool doConvert)
    {
        Player* invoker = handler->GetPlayer();
        if (!invoker)
            return;

        for (Player* target : ResolveScanScope(invoker))
        {
            auto results = ScanAndResolve(target, doConvert);
            ReportResults(handler, results);
        }
    }

    bool HandleTokenTurnInCheckCommand(ChatHandler* handler)
    {
        RunTokenTurnIn(handler, false);
        return true;
    }

    bool HandleTokenTurnInRedeemCommand(ChatHandler* handler)
    {
        RunTokenTurnIn(handler, true);
        return true;
    }
}

class mod_token_turnin_commandscript : public CommandScript
{
public:
    mod_token_turnin_commandscript() : CommandScript("mod_token_turnin_commandscript") {}

    std::vector<ChatCommandBuilder> GetCommands() const override
    {
        static std::vector<ChatCommandBuilder> tokenTurnInSubCommands =
        {
            { "check",  HandleTokenTurnInCheckCommand,  SEC_PLAYER, Console::No },
            { "redeem", HandleTokenTurnInRedeemCommand, SEC_PLAYER, Console::No },
        };

        static std::vector<ChatCommandBuilder> commandTable =
        {
            { "tokenturnin", tokenTurnInSubCommands },
        };

        return commandTable;
    }
};

void AddSC_mod_token_turnin()
{
    new mod_token_turnin_commandscript();
}
