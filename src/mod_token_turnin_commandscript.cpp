/*
 * mod_token_turnin - CommandScript
 *
 * Scans a player's (and, if grouped, their party/raid's) bags for tier
 * tokens, resolves the correct gear item per character from spec and class,
 * then destroys the token and awards the item. Player-initiated via
 * .tokenturnin check|redeem. See DESIGN.md for the full design rationale,
 * tier-data scope, and the history behind the decisions below.
 *
 * Two non-obvious points worth preserving before "simplifying" this file:
 *
 *  - Spec detection is hand-rolled (ResolveHighestTalentTab) rather than
 *    reusing mod-playerbots' TalentSpec: that path detects invested points
 *    via Player::HasSpell() and misses passive-only talents, misreading low
 *    investment as "no spec". Ours reads Player::HasTalent() against the real
 *    PlayerTalentMap instead. This also keeps the module free of a hard
 *    compile-time dependency on mod-playerbots, so it builds standalone.
 *
 *  - AwardItemAndNotify() calls Player::SendNewItem() after storing the item.
 *    StoreNewItemInBestSlots() alone never sends SMSG_ITEM_PUSH_RESULT, which
 *    is the packet mod-playerbots hooks to make a bot re-check and equip gear
 *    upgrades - without it, awarded items just sit inert in the bot's bags.
 */

#include "Bag.h"
#include "Chat.h"
#include "ChatCommand.h"
#include "Config.h"
#include "DatabaseEnv.h"
#include "DBCStores.h"
#include "Group.h"
#include "Item.h"
#include "Log.h"
#include "ObjectMgr.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "StringFormat.h"
#include <map>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>

#ifdef MOD_PLAYERBOTS
#include "PlayerbotMgr.h"
#endif

using namespace Acore::ChatCommands;

namespace
{
    // Cached config, (re)loaded from the .conf in OnBeforeConfigLoad. See
    // conf/mod_token_turnin.conf.dist for the full option descriptions.
    bool configEnable = true;
    bool configIncludeSelf = false;
    bool configIncludeRealPlayers = false;

    void LoadTokenTurnInConfig()
    {
        configEnable = sConfigMgr->GetOption<bool>("TokenTurnIn.Enable", true);
        // Default false: this module exists for bot-management convenience, not
        // to make it easier for the invoking player's own character to get gear
        // (see DESIGN.md). Opt-in for admins who want the convenience too.
        configIncludeSelf = sConfigMgr->GetOption<bool>("TokenTurnIn.IncludeSelf", false);
        // Default false: only real playerbots should be swept up when scanning a
        // group, not a real grouped friend's character. Only meaningful when
        // built with mod-playerbots present - see the MOD_PLAYERBOTS guard on
        // IsRealPlayer() below.
        configIncludeRealPlayers = sConfigMgr->GetOption<bool>("TokenTurnIn.IncludeRealPlayers", false);
    }

    // Packs (token_entry, class_id, talent_tab) into one key for the lookup
    // cache below. token_entry uses bits 16+ (up to 32 bits), class_id bits
    // 8-15, talent_tab bits 0-7 - no overlap since class_id/talent_tab are
    // both small TINYINT columns.
    uint64 PackTokenLookupKey(uint32 tokenEntry, uint8 classId, uint8 talentTab)
    {
        return (static_cast<uint64>(tokenEntry) << 16) | (static_cast<uint64>(classId) << 8) | talentTab;
    }

    // In-memory copy of mod_token_turnin_tokens, keyed by PackTokenLookupKey().
    // The table is static world content (only changes when the module's SQL
    // file changes), so it's loaded once up front rather than queried per bag
    // item scanned - a per-item WorldDatabase.Query() was pure overhead: a
    // full raid scan could mean well over a thousand blocking round-trips on
    // the world thread for one .tokenturnin command.
    std::unordered_map<uint64, uint32> tokenLookupCache;

    // Loads (or reloads) the token->item lookup table into memory. Called from
    // OnBeforeConfigLoad so it runs once at startup and again on `.reload
    // config`, matching how sibling modules load their static custom tables
    // (e.g. mod-individual-progression's LoadXpValues). Clears first so a
    // reload picks up edited/added rows instead of serving a stale copy.
    void LoadTokenLookupCache()
    {
        tokenLookupCache.clear();

        QueryResult result = WorldDatabase.Query(
            "SELECT token_entry, class_id, talent_tab, result_item_entry FROM mod_token_turnin_tokens");
        if (!result)
        {
            LOG_WARN("module", "TokenTurnIn: mod_token_turnin_tokens is empty or missing - no tokens will convert. Was the module's SQL applied?");
            return;
        }

        do
        {
            Field* fields = result->Fetch();
            uint32 tokenEntry = fields[0].Get<uint32>();
            uint8 classId = fields[1].Get<uint8>();
            uint8 talentTab = fields[2].Get<uint8>();
            uint32 resultItemEntry = fields[3].Get<uint32>();

            tokenLookupCache[PackTokenLookupKey(tokenEntry, classId, talentTab)] = resultItemEntry;
        } while (result->NextRow());

        LOG_INFO("module", "TokenTurnIn: loaded {} token->item mappings into cache", tokenLookupCache.size());
    }

    class TokenTurnInWorldScript : public WorldScript
    {
    public:
        TokenTurnInWorldScript() : WorldScript("TokenTurnInWorldScript", { WORLDHOOK_ON_BEFORE_CONFIG_LOAD }) {}

        void OnBeforeConfigLoad(bool /*reload*/) override
        {
            LoadTokenTurnInConfig();
            LoadTokenLookupCache();
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
        { CLASS_ROGUE,        { {0, "assassination"}, {1, "combat"},        {2, "subtlety"}    } },
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

    // Wraps Player::StoreNewItemInBestSlots() (kept as-is - it already
    // correctly handles the N-tokens-to-N-items case: equip one, then store
    // the rest as a bag stack) and adds one thing it doesn't do: fire
    // SMSG_ITEM_PUSH_RESULT via Player::SendNewItem(). mod-playerbots' "item
    // push result" trigger (WorldPacketHandlerStrategy.cpp) is what makes a
    // bot re-check its gear for upgrades and equip them - StoreNewItemInBestSlots()
    // alone never sends that packet (confirmed against Player.cpp), so
    // without this the item just sits in the bag until something else (e.g.
    // a GM's .additem, which does call SendNewItem) happens to prompt a
    // recheck. GetItemByEntry() after the fact is a loose match (it doesn't
    // guarantee *this* is the newly-added instance if the bot already had
    // one), but that's fine here - the packet's job is just to make the bot
    // look, and its own gear-check logic re-evaluates from scratch anyway.
    bool AwardItemAndNotify(Player* target, uint32 itemEntry, uint32 count)
    {
        if (!target->StoreNewItemInBestSlots(itemEntry, count))
            return false;

        if (Item* awarded = target->GetItemByEntry(itemEntry))
            target->SendNewItem(awarded, count, true, false);

        return true;
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

            auto cacheIt = tokenLookupCache.find(PackTokenLookupKey(tokenEntry, target->getClass(), talentTab));
            if (cacheIt == tokenLookupCache.end())
                continue;

            uint32 resultItemEntry = cacheIt->second;

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
                if (AwardItemAndNotify(target, resultItemEntry, tokenCount))
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

    // doConvert selects the verb tense: "check" is describing a hypothetical
    // (would convert), "redeem" is reporting something that already happened
    // (converted). Deliberately just a tense swap, not an extra tag/suffix -
    // which command you typed already tells you the mode, so repeating that
    // as a label on every line would just be noise.
    void ReportResults(ChatHandler* handler, std::vector<TokenConversionResult> const& results, bool doConvert)
    {
        char const* verb = doConvert ? "Converted" : "Would convert";

        for (auto const& r : results)
        {
            if (r.matched)
            {
                // inventoryFull means the award/destroy step was attempted and
                // failed - report that as its own outcome rather than printing
                // the success verb ("Converted") followed by a contradicting
                // "not consumed" line.
                if (r.inventoryFull)
                    handler->PSendSysMessage(
                        "[TokenTurnIn] {} ({}) -> Failed to convert Token: {} -> Item: {} (no inventory space, token not consumed)",
                        r.charName, r.specLabel, BuildItemLink(r.tokenEntry), BuildItemLink(r.resultItemEntry));
                else if (r.count > 1)
                    handler->PSendSysMessage(
                        "[TokenTurnIn] {} ({}) -> {} Token: {} x{} -> Item: {} x{}",
                        r.charName, r.specLabel, verb, BuildItemLink(r.tokenEntry), r.count, BuildItemLink(r.resultItemEntry), r.count);
                else
                    handler->PSendSysMessage(
                        "[TokenTurnIn] {} ({}) -> {} Token: {} -> Item: {}",
                        r.charName, r.specLabel, verb, BuildItemLink(r.tokenEntry), BuildItemLink(r.resultItemEntry));
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

        if (configIncludeSelf)
            scope.push_back(invoker);

        if (Group* group = invoker->GetGroup())
        {
            for (GroupReference* itr = group->GetFirstMember(); itr != nullptr; itr = itr->next())
            {
                Player* member = itr->GetSource();

                // Skip anything we can't safely scan and mutate: a member with
                // no active session or not currently in world (e.g. mid-logout),
                // the invoker (added above only when IncludeSelf is set), and
                // real players unless IncludeRealPlayers is enabled.
                if (!member || !member->GetSession() || !member->IsInWorld())
                    continue;
                if (member == invoker)
                    continue;
                if (!configIncludeRealPlayers && IsRealPlayer(member))
                    continue;

                scope.push_back(member);
            }
        }

        return scope;
    }

    void RunTokenTurnIn(ChatHandler* handler, bool doConvert)
    {
        if (!configEnable)
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
            // Empty scope has two distinct causes - report the one that
            // actually applies rather than always blaming group membership.
            if (!invoker->GetGroup())
                handler->PSendSysMessage(
                    "[TokenTurnIn] Nothing to scan - you are not in a group, and self-conversion is disabled (TokenTurnIn.IncludeSelf).");
            else
                handler->PSendSysMessage(
                    "[TokenTurnIn] Nothing to scan - no eligible group members found (self-conversion and/or TokenTurnIn.IncludeRealPlayers may need enabling).");
            return;
        }

        for (Player* target : scope)
        {
            auto results = ScanAndResolve(target, doConvert);
            ReportResults(handler, results, doConvert);
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
