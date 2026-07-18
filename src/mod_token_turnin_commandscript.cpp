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
 * Resolved design point (supersedes an earlier attempt to reuse
 * mod-playerbots' TalentSpec::highestTree()):
 *  - TalentSpec::ReadTalents() (mod-playerbots, Talentspec.cpp) detects
 *    invested points via Player::HasSpell(spellId). In-game testing showed
 *    this fails to recognize points spent in early/passive-only talents -
 *    it only picks up the tree once a talent that also grants an active,
 *    castable spell has been learned. That made highestTree() itself
 *    unreliable for low investment, not just our own "no spec" check.
 *  - Replaced with our own ResolveHighestTalentTab() below, computed
 *    directly against core's own TalentEntry/TalentTabEntry DBC stores
 *    (sTalentStore/sTalentTabStore) and Player::HasTalent(), which checks
 *    the player's actual PlayerTalentMap (m_talents) rather than the general
 *    spellbook - the correct, passive-or-active-agnostic source of truth.
 *  - This also removes the module's hard compile-time dependency on
 *    mod-playerbots (Talentspec.h no longer included), which previously
 *    broke standalone CI builds (see the removed core-build.yml history).
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
 *
 * Resolved design point:
 *  - A character with zero points in every tree (e.g. a freshly wiped talent
 *    tree) has no real spec. ResolveHighestTalentTab() returns -1 for this
 *    case explicitly rather than defaulting to tab 0, so we can skip the
 *    character with a clear message instead of handing out fabricated gear.
 *
 * Resolved design point:
 *  - A single token_entry can be shared across multiple classes (confirmed
 *    in game data - e.g. T4's "Fallen Defender" family token is looted and
 *    used identically by Warrior, Priest, and Druid, each redeeming their
 *    own 3 spec-variant items from the same token entry). The lookup query
 *    filters on class_id as well as token_entry + talent_tab, so a class
 *    outside a token's real family simply finds no matching row - same
 *    outcome as any other unconvertible token, no separate mismatch/warning
 *    handling needed.
 *
 * Resolved design point:
 *  - This module's purpose is bot-management convenience, not helping real
 *    players get gear faster - so besides excluding the invoker (see
 *    TokenTurnIn.IncludeSelf), a real grouped player (not a bot) should also
 *    be excluded from scanning by default. Detecting "is this a bot" is a
 *    genuine mod-playerbots concern (PlayerbotsMgr::GetPlayerbotAI()), unlike
 *    the TalentSpec dependency removed above - that one was dropped for
 *    being buggy, not for being playerbots-specific. This check is wrapped
 *    in #ifdef MOD_PLAYERBOTS (a macro CMake already defines when playerbots
 *    is present in the build) so the module still compiles standalone;
 *    without playerbots present, real-player filtering is simply a no-op.
 */

#include "Bag.h"
#include "Chat.h"
#include "ChatCommand.h"
#include "ConfigValueCache.h"
#include "DatabaseEnv.h"
#include "DBCStores.h"
#include "Group.h"
#include "Item.h"
#include "ObjectMgr.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "StringFormat.h"
#include <sstream>
#include <vector>
#include <string>

#ifdef MOD_PLAYERBOTS
#include "PlayerbotMgr.h"
#endif

using namespace Acore::ChatCommands;

namespace
{
    enum class TokenTurnInConfig
    {
        ENABLE,
        INCLUDE_SELF,
        INCLUDE_REAL_PLAYERS,
        NUM_CONFIGS,
    };

    class TokenTurnInConfigData : public ConfigValueCache<TokenTurnInConfig>
    {
    public:
        TokenTurnInConfigData() : ConfigValueCache(TokenTurnInConfig::NUM_CONFIGS) {}

        void BuildConfigCache() override
        {
            SetConfigValue<bool>(TokenTurnInConfig::ENABLE, "TokenTurnIn.Enable", true);
            // Default false: this module exists for bot-management convenience,
            // not to make it easier for the invoking player's own character to
            // get gear (see DESIGN.md). Off by default, opt-in for admins who
            // want the convenience for themselves too.
            SetConfigValue<bool>(TokenTurnInConfig::INCLUDE_SELF, "TokenTurnIn.IncludeSelf", false);
            // Default false: only real playerbots should be swept up when
            // scanning a group, not a real grouped friend's character.
            // Only takes effect when built with mod-playerbots present -
            // see the MOD_PLAYERBOTS guard on IsRealPlayer() below.
            SetConfigValue<bool>(TokenTurnInConfig::INCLUDE_REAL_PLAYERS, "TokenTurnIn.IncludeRealPlayers", false);
        }
    };

    TokenTurnInConfigData tokenTurnInConfig;

    class TokenTurnInWorldScript : public WorldScript
    {
    public:
        TokenTurnInWorldScript() : WorldScript("TokenTurnInWorldScript", { WORLDHOOK_ON_BEFORE_CONFIG_LOAD }) {}

        void OnBeforeConfigLoad(bool reload) override
        {
            tokenTurnInConfig.Initialize(reload);
        }
    };

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

    // Returns the talent tab (0/1/2) with the most points invested for this
    // character's class, or -1 if no points are invested anywhere. Computed
    // directly against core's TalentEntry/TalentTabEntry stores and
    // Player::HasTalent() (checks the real PlayerTalentMap, passive or
    // active) rather than mod-playerbots' TalentSpec - see header comment.
    int32 ResolveHighestTalentTab(Player* target)
    {
        uint32 classMask = target->getClassMask();
        uint32 points[3] = { 0, 0, 0 };

        for (uint32 i = 0; i < sTalentStore.GetNumRows(); ++i)
        {
            TalentEntry const* talentInfo = sTalentStore.LookupEntry(i);
            if (!talentInfo)
                continue;

            TalentTabEntry const* talentTabInfo = sTalentTabStore.LookupEntry(talentInfo->TalentTab);
            if (!talentTabInfo)
                continue;

            if ((classMask & talentTabInfo->ClassMask) == 0)
                continue;

            // TalentTabID 41 is a known DBC quirk (mirrors the equivalent
            // correction in mod-playerbots' TalentListEntry::tabPage()).
            uint32 tab = talentTabInfo->TalentTabID == 41 ? 1 : talentTabInfo->tabpage;
            if (tab > 2)
                continue;

            for (uint8 rank = 0; rank < MAX_TALENT_RANK; ++rank)
            {
                uint32 spellId = talentInfo->RankID[rank];
                if (!spellId)
                    continue;

                if (target->HasTalent(spellId, target->GetActiveSpec()))
                {
                    points[tab] += rank + 1;
                    break;
                }
            }
        }

        if (points[0] + points[1] + points[2] == 0)
            return -1;

        uint8 best = 0;
        if (points[1] > points[best]) best = 1;
        if (points[2] > points[best]) best = 2;
        return best;
    }

    struct TokenConversionResult
    {
        std::string charName;
        std::string specLabel;
        uint32 tokenEntry = 0;
        uint32 resultItemEntry = 0;
        uint32 count = 1;
        bool matched = false;
        bool inventoryFull = false;
        bool noSpec = false;
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

        // 1. Resolve current spec. -1 means no points invested anywhere
        //    (e.g. freshly wiped talents) - bail out with a clear message
        //    rather than defaulting to a fabricated spec.
        int32 highestTab = ResolveHighestTalentTab(target);
        if (highestTab < 0)
        {
            TokenConversionResult noSpec;
            noSpec.charName = target->GetName();
            noSpec.matched = false;
            noSpec.noSpec = true;
            return { noSpec };
        }

        uint8 talentTab = static_cast<uint8>(highestTab);
        std::string specLabel = ResolveSpecLabel(target->getClass(), talentTab);

        // 2. Scan backpack + bags for any token_entry present in
        //    mod_token_turnin_tokens for this character's own class.
        //    Difficulty is NOT part of the lookup - it's implied by which
        //    token_entry was found, since each difficulty's token is already
        //    a distinct item_id in game data. class_id IS part of the lookup:
        //    a token shared by multiple classes (see header) only matches the
        //    row for the holder's own class.
        for (Item* item : CollectBagItems(target))
        {
            uint32 tokenEntry = item->GetEntry();
            uint32 tokenCount = item->GetCount();

            QueryResult queryResult = WorldDatabase.Query(
                "SELECT result_item_entry FROM mod_token_turnin_tokens WHERE token_entry = {} AND class_id = {} AND talent_tab = {}",
                tokenEntry, target->getClass(), talentTab);

            if (!queryResult)
                continue;

            uint32 resultItemEntry = queryResult->Fetch()[0].Get<uint32>();

            TokenConversionResult match;
            match.charName = target->GetName();
            match.specLabel = specLabel;
            match.tokenEntry = tokenEntry;
            match.resultItemEntry = resultItemEntry;
            match.count = tokenCount;
            match.matched = true;

            // 3. Award before destroying: if there's no room for the result
            //    items, the token stack is left untouched rather than lost.
            //    A whole stack found in one slot converts in a single sweep -
            //    count matches whatever was actually in that slot, not a
            //    hardcoded 1, so a stack of e.g. 3 doesn't need 3 separate
            //    .tokenturnin redeem runs to fully clear.
            if (doConvert)
            {
                if (target->StoreNewItemInBestSlots(resultItemEntry, tokenCount))
                    target->DestroyItemCount(tokenEntry, tokenCount, true);
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
                if (r.count > 1)
                    handler->PSendSysMessage(
                        "[TokenTurnIn] {} ({}) -> Token: {} x{} -> Item: {} x{}",
                        r.charName, r.specLabel, BuildItemLink(r.tokenEntry), r.count, BuildItemLink(r.resultItemEntry), r.count);
                else
                    handler->PSendSysMessage(
                        "[TokenTurnIn] {} ({}) -> Token: {} -> Item: {}",
                        r.charName, r.specLabel, BuildItemLink(r.tokenEntry), BuildItemLink(r.resultItemEntry));

                if (r.inventoryFull)
                    handler->PSendSysMessage(
                        "[TokenTurnIn] {} has no inventory space for {} - token not consumed",
                        r.charName, BuildItemLink(r.resultItemEntry));
            }
            else if (r.noSpec)
            {
                handler->PSendSysMessage(
                    "[TokenTurnIn] {} has no talents invested - spec cannot be determined, skipped",
                    r.charName);
            }
            else
            {
                handler->PSendSysMessage(
                    "[TokenTurnIn] No convertible tokens found on {}", r.charName);
            }
        }
    }

    // True for a real (non-bot) player. Without mod-playerbots present there's
    // no such thing as a bot, so everyone counts as "real" - the
    // TokenTurnIn.IncludeRealPlayers filter below simply has nothing to do.
    bool IsRealPlayer(Player* player)
    {
#ifdef MOD_PLAYERBOTS
        return PlayerbotsMgr::instance().GetPlayerbotAI(player) == nullptr;
#else
        (void)player;
        return true;
#endif
    }

    // Collects, if grouped, party/raid members - GetFirstMember() covers both
    // identically, no need to branch on isRaidGroup(). Includes the invoker
    // themselves only if TokenTurnIn.IncludeSelf is enabled, and real (non-bot)
    // group members only if TokenTurnIn.IncludeRealPlayers is enabled: this
    // module exists for bot-management convenience, not to make it easier for
    // real characters to get gear (see DESIGN.md), so both are excluded by
    // default.
    std::vector<Player*> ResolveScanScope(Player* invoker)
    {
        std::vector<Player*> scope;

        bool includeRealPlayers = tokenTurnInConfig.GetConfigValue<bool>(TokenTurnInConfig::INCLUDE_REAL_PLAYERS);

        if (tokenTurnInConfig.GetConfigValue<bool>(TokenTurnInConfig::INCLUDE_SELF))
            scope.push_back(invoker);

        if (Group* group = invoker->GetGroup())
        {
            for (GroupReference* itr = group->GetFirstMember(); itr != nullptr; itr = itr->next())
            {
                if (Player* member = itr->GetSource())
                    if (member != invoker)
                        if (includeRealPlayers || !IsRealPlayer(member))
                            scope.push_back(member);
            }
        }

        return scope;
    }

    void RunTokenTurnIn(ChatHandler* handler, bool doConvert)
    {
        if (!tokenTurnInConfig.GetConfigValue<bool>(TokenTurnInConfig::ENABLE))
        {
            handler->PSendSysMessage("[TokenTurnIn] This module is currently disabled.");
            return;
        }

        Player* invoker = handler->GetPlayer();
        if (!invoker)
            return;

        std::vector<Player*> scope = ResolveScanScope(invoker);
        if (scope.empty())
        {
            handler->PSendSysMessage(
                "[TokenTurnIn] Nothing to scan - you are not in a group, and self-conversion is disabled (TokenTurnIn.IncludeSelf).");
            return;
        }

        for (Player* target : scope)
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
    new TokenTurnInWorldScript();
}
