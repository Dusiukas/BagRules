# BagRules 0.4.0-alpha — Independent parent categories

Replace only the BagRules folder with this version. Back up `WTF/Account/<account>/SavedVariables/BagRules.lua` with WoW closed before upgrading; the saved data migrates automatically, but do not downgrade without restoring that backup. No host files need changing. The existing renderer and compact packing module are unchanged.

Open `/bagrules` > Categories. **+ Category** creates a parent (even an empty one). Click the parent name to manage its settings; click the small +/- button to expand or collapse it. Rename once with **Save name** and all children inherit the new label. **+ Subcategory** creates a disabled child with a Never rule in the selected parent. In the child editor, use the Parent dropdown rather than typing a section name. Use Rule presets to set a common rule, or edit conditions in Visual/Expression mode. Presets replace only the draft rule until saved; enable the child and Save changes to apply. Expand/Collapse all, drag-and-drop, move up/down and duplicate controls are available. Parent toggles affect all children without changing their individual enabled flags. Empty parents remain visible in settings, not bags. To delete a nonempty parent, choose a destination for the children, then confirm Delete parent twice; no child rules are deleted. Duplicate parent copies its child rules as new categories, with new IDs and later tie positions.

Parents have permanent IDs; legacy child section names become derived renderer labels. New exports use `BAGRULES/4`: parent definitions, including empty/disabled parents and ordering, plus child expressions, parent references, manual assignments and stable tie order. Previous BagRules /1, /2, /3 and Baganator formats remain importable. Older addon releases cannot import /4. Existing integration settings are not part of share exports. Data migration retains category IDs, expressions, priorities, manual IDs and import warnings. Rules stay separate from display order.

Settings retain EUI native widgets when exposed and shared palette / accent callbacks; the new controls need actual in-game verification. Rule presets cover common materials, equipment, quest items, consumables and recipes using existing metadata-based rule definitions. They are not a full item database. Per-parent custom appearances, direct editing from items, right-click menus and a full searchable template/icon library remain future enhancements. Automated tests use Lua 5.4 mocks, not the game client.

Previous release notes follow.

# BagRules 0.3.3-alpha — Inventory display order

Replace only BagRules and reload. In `/bagrules` → Categories, drag a section header to place the entire section before or after another. Drag a category above/below another category to reorder or move it between sections; drop it on a section header to append it there. The accent-coloured line shows where it will go; a highlighted header means move into that section. Scroll near the tree edges while dragging. Click a section header or category to target Move up/down as an alternative; the existing section dropdown can also move a category. Clear search, save/discard any draft and leave combat before rearranging. Invalid or outside drops are ignored. Existing nonempty sections are movable; a section without categories disappears. The layout is saved immediately. No EUI files or native inventory renderer changes.

Existing rule priorities, manual assignments and previous equal-priority tie order are preserved: display order no longer controls ties. Use Advanced priority to change classification intentionally. Old saved data and BAGRULES/1 and /2 exports remain readable. If display order differs from classification order, exports use BAGRULES/3, with a separate tie-order field; older BagRules versions cannot import that format. Exports use /2 when possible. This is an experimental UI update; drag input, scroll and visual drop feedback need in-game testing. Earlier release notes below are historical.

# BagRules 0.3.1-alpha — Tooltip hotfix

Fixes visual rule row hover errors on WoW Forever by using the single-argument GameTooltip:SetText call. No rule, profile, inventory layout or styling changes. Replace only BagRules and reload.

# BagRules 0.3.0-alpha — Category Manager

Install by replacing only the BagRules addon folder, keeping BagRulesDB saved variables. No EllesmereUI files are modified. Open `/bagrules` → Categories. The category and section tree is searchable and shows counts of currently assigned bag slots. Select a category, select a group or condition, and choose its property, operator and value. Match ALL / ANY groups can nest and be negated. Use Expression mode for raw rules; viewing or switching modes without editing preserves the original expression. Save changes or Discard before changing categories. New categories begin disabled with a Never rule; set a rule and enable before saving. Advanced contains numeric classification priority, manual item IDs and import warnings; Appearance contains a small common-icon palette and file-ID input. The live preview reports matching slots, competing matches and unavailable data; counts remain an estimate of BagRules classification, not a promise of the final native item rendering. Section names are edited through a field or existing-section selector; Move up/down controls display order. Full template library, drag/drop, searchable icon library, and editing from bags are future milestones.

The native settings plugin inherits EUI's existing background, navigation and theme. Normal buttons/labels and fixed-choice dropdowns use shared EUI factories when available. Custom tree rows, variable-choice dropdowns and toggles use host theme constants, fonts and accent registration. Accent changes repaint existing custom UI state through EUI RegAccent, with re-read on page open/cache restore if absent. No additional user theme setting, no page rebuild on an accent event, no changes to saved rules from styling. Fallback window is separate and uses neutral colours when native integration is unavailable. The exact installed EUI settings-core package was not supplied; API signatures checked against public source and exercised with mocks, not actual Forever settings rendering. Inventory renderer unchanged from v0.2.5, including existing green inventory section headers.

The Wago fixture, rule tests and simulated UI tests are in the source package. Test visual editing of a disposable category, preview, save, import preservation, then change the EUI accent and theme and reopen BagRules. Send screenshots or BugSack errors if any native widget differs or fails. The sections below retain historical release notes; the 0.3.0 instructions above supersede earlier editor descriptions.

---

# BagRules 0.2.5-alpha — tighter nested sections

Replace only your BagRules folder; keep the saved variables and do not patch EllesmereUI. This build defaults to tighter packing when BagRules uses Nested sections and the host uses Compact mode. General > **Tighter packing within nested Compact sections** switches between the new packing and the previous native-band layout. The status command reports `Packing: compact` or `Packing: native bands` when the runtime hierarchy is active.

The new planner measures the short counted category label in the actual host font, uses the larger of that width and the existing native item footprint, uses an 8 UI-unit horizontal gutter and a 4-unit vertical row gutter, and greedily packs each section in existing category order. It retains native item positions relative to their own group, so already-wrapped multi-row categories are not internally reshaped. It shortens compact label frames, hides their redundant divider lines, preserves full-width parent section lines, and retains native behaviour for special/unsectioned groups. Grid/List, bank and offline inventory behaviour is unchanged. Unsupported measurement or over-wide blocks retain the old hierarchy packing. All previous combat and cursor safeguards remain. Actual WoW rendering, drag/drop, combat and taint behaviour must still be verified on the client.

---

# BagRules for EllesmereUI — 0.2.4-alpha

An independent rule-based category extension for WoW Forever (TOC interface 16001). This is a development build, not a certified in-game release. Earlier releases used green accents and blue-charcoal panels; 0.3.0 uses host theme helpers. The custom editing controls use original frames styled to match, not a wholesale replacement of the inventory UI.

## Install

1. Ensure EllesmereUI and its Bags module are installed and enabled. Update them if you can. Auctionator is optional; it is needed only for market-price rules.
2. Exit WoW or log out. Extract the `BagRules` folder directly into your active WoW Forever client's `Interface/AddOns` folder. There must be a file `Interface/AddOns/BagRules/BagRules.toc`, not another nested BagRules directory.
3. Start the game, enable BagRules on the AddOns screen, then enter the world. Use `/bagrules status` to see API registration status.
4. Open your inventory and choose **BagRules** in the view selector if it appears. If your EllesmereUI build lacks Virtual Views, look for the newly registered categories after the built-in categories instead.
5. Type `/bagrules` to open the editor. With the plugin API available the editor is under BagRules > Advanced Bag Categories in EllesmereUI. `/bagrules fallback` opens a separate green-themed fallback editor if native settings do not work. `/bagrules refresh` re-registers categories and clears cached item/auction data.

If testing a development addon, make a backup of your normal WTF folder first. Existing EUI categories and item assignments are never intentionally changed by BagRules; the only persistent settings we write belong to `BagRulesDB`. No item selling, destroying, mailing, depositing or physical sorting is implemented.

## What works in the code

- Nine editable starting categories. Create, duplicate, enable/disable, delete and reorder your own categories (up to 100 in this alpha); manual item IDs win first, then higher numerical priority, then display order.
- Name, icon file ID, visual condition builder and advanced expression editor.
- Parentheses, AND / OR / NOT, comparison operators, string matching, numeric quality thresholds, optional auction-price rules.
- Test your draft rule against the current backpack, with match counts, unknown data, and collisions with earlier BagRules categories. This is an estimate before host filtering, not necessarily the exact rendered results. The preview lists up to six matches.
- Account-wide settings, versioned text import/export and one previous-category-list backup on import. Import replaces the list only after all rules have been validated. Supports Baganator BGR!1! (raw DEFLATE + CBOR or JSON) and plain JSON version 1/2 custom category bundles.
- Public `RegisterVirtualView` and `RegisterVirtualCategory` adapters. The independent view is the default when available. Native categories can be enabled under General for the conventional bag/bank classification. If the view is unavailable, the native adapter is automatically used when View is enabled. To disable integration entirely, switch Enable BagRules off.
- Native item links, item data and live binding/stack information when available. Cached item information invalidated on relevant events. Apply/refresh is deferred while in combat.

New categories start disabled and have an editable sample rule. Apply the desired name, expression and icon, then Enable. Edits are drafts until Apply; selecting another category discards an unapplied draft. The toggle and order operations take effect immediately. Import/export includes categories, order, enabled flags, priority, section labels, manual IDs, original search and translation warnings; global integration toggles are not included.

## Wago / Baganator import (new in 0.2)

1. Exit WoW, back up `WTF` and replace the old BagRules folder with the new one. Do not delete the BagRules saved variables. Old configurations and BAG RULES/1 exports remain readable.
2. Open `/bagrules` → Import / Export. Paste a `BGR!1!` string from Wago or decoded Baganator JSON.
3. Click Import once to validate. The preview reports category count, section count, manual IDs and warnings. Full translation warnings appear in chat. No write occurs at this step.
4. Click Import again to replace existing categories. The previous category list is backed up. Choose Restore backup and then Import twice if needed.
5. Select the BagRules inventory view. Existing EUI pins, Junk and free slots are still host-managed. Select Nested sections in General to try the standalone runtime layout on compatible EllesmereUI Bags versions (reviewed 9.9 and 9.9.1). Other layouts keep flat headers.
6. The Categories editor exposes priority, section and comma-separated manual IDs. Higher priority wins; display order breaks ties. Manual assignments precede automatic rules. Move up/down changes display order.

The real supplied Wago bundle (`veMHzL7gK`) is included in the development tests, not installed as your default profile. It yields 34 categories, five sections and 11 manual IDs. No Baganator, Syndicator or decoding libraries are needed. Import is an experimental translation of supported search atoms, **not complete Baganator parity**. Profession, quest, binding, item-set, pet, openable and food/drink mappings use available client item metadata and may differ. Retail-only equipment-set membership remains unknown; unknown results never turn into a match through NOT. Some item IDs are Retail items that may not exist in Forever. Built-in recents, empty slots and other fallback entries are mapped to host behaviour or reported as skipped; unsupported built-in rules or advanced options are not recreated. German name matching is ASCII-case-insensitive, not full Unicode case folding. Use the import warnings and Test Rule when reviewing a translated category.

The decoder is original, data-only and bounded. It supports the definite-length CBOR subset used in this test, not every possible future Baganator format. No Lua source is evaluated. Imported expressions remain editable in native BagRules syntax; `never` represents an empty/explicit-only rule, `unknown` represents unavailable information.

## Rules reference

The syntax is original BagRules syntax, inspired by Baganator. It is not a drop-in implementation of Baganator's expression grammar.

| Expression | Meaning |
|---|---|
| `tradegoods & subclass = 5` | Cloth materials (numeric IDs are language-independent) |
| `tradegoods & subclass = 9` | Herbs |
| `tradegoods & (subclass = 6 \| subclass = 7)` | Leather or metal/stone |
| `name ~ "Healing"` | Case-insensitive plain substring match |
| `id = 2589 \| id = 2592` | Two specific item IDs |
| `weapon \| armor` | All weapons or armour |
| `boe & unbound & quality >= uncommon` | Unbound bind-on-equip equipment or other qualifying items |
| `unbound & (weapon \| armor) & ahprice >= 20s & ratio >= 2` | Unbound gear estimated to auction for at least 20 silver and twice vendor value |
| `!quest & vendor >= 10s` | Items known not to be quest class, worth at least 10 silver to a vendor |
| `ammunition` | Projectile item class |
| `count >= 20` | Live stack size (not total across bags or characters) |
| `all` | Explicit catch-all; place at the end if used |

`&` / `and`, `|` / `or`, `!` / `not` use normal precedence: NOT, AND, OR. Use parentheses to make groups explicit. Comparisons: `=`, `!=`, `>=`, `<=`, `>`, `<`; text also supports `~` (plain contains). Quoted text accepts escaped quotes and backslashes. Text matching is ASCII case-insensitive; item class/subclass numeric IDs are better for multi-language setups. Money fields use copper by default, or one suffix (`g`, `s`, `c`), e.g. `1.5g`, `50s`. Quality names or numeric qualities 0–7 are accepted. Boolean fields use true/false, or just the field name for true.

| Field | Meaning |
|---|---|
| id | Item ID |
| name | Localised item name |
| class / subclass | Numeric WoW item class and subclass |
| type / subtype | Localised class/subclass names |
| quality | Poor, common, uncommon, rare, epic, legendary, artifact, heirloom (0–7) |
| itemlevel / requiredlevel | Item info's item level and required level |
| slot | API equipment slot token, e.g. INVTYPE_WEAPON |
| bindtype / boe | Binding type code; boe is bind-on-equip type, not proof an item is still unbound |
| bound / unbound | Actual live binding state, if API reports it |
| quest | Item class 12; not a complete database of items useful for quests |
| count | Live stack quantity |
| vendor | Vendor sell price per item, copper |
| ahprice | Auctionator estimated market price per item, copper |
| ratio | ahprice/vendor, unknown when vendor price is zero or missing |

Aliases: `weapon`, `armor` / `armour`, `consumable`, `container`, `reagent`, `tradegoods`, `recipe`, `questitem`, `ammunition` / `projectile`, `junk` (poor quality, not host's manual junk mark), `all`.

Unknown data is evaluated conservatively: `!unbound` does not match when binding is unknown. Auction data is an estimate, may be absent or stale, and does not guarantee a sale. Scan your auction market with Auctionator and use `/bagrules refresh` if necessary. There is no automatic selling and no claim of upgrade value or alt relevance in this alpha.

## Integration limitations

- GitHub main's published EUIBags TOC was version 9.9 during research. The screenshot used for design showed EUI 7.4.4. Those versions are not assumed interchangeable. The code probes supported functions at runtime. The new optional runtime layout uses a post-hook on EUI_Bags:RefreshInventory for compatible host renderers; versions 9.9 and 9.9.1 have been source-reviewed. Private renderer functions are not replaced.
- The public virtual view is bags-only, has a flat group list and retains host Junk filtering. Pinned items follow host rules when the pinned section is enabled. It cannot be set as the host's default through the API reviewed here.
- Native category order is restricted to the external block after native categories. Host's manually assigned, junk, and special-bag items may bypass it. Native classification can be applied where the host calls providers (bank/offline), but live binding and count may be unknown offline. Real bank and offline rendering still need testing.
- BagRules native providers use order -999 onward, so they are intentionally prioritised ahead of ordinary order-0 or positive-order extensions. Other extensions can be enabled alongside it, but matching categories may be empty. Use independent-view-only mode if you want other addons to keep their normal classifications.
- The native Junk Marker is never overridden. No category-based transfers, drag-to-rule assignment, tooltip/stat/recipe/alt awareness, Syndicator or TSM integration. Nested display is experimental and restricted to the runtime adapter.
- Controls have been smoke-tested only in a mock UI. Native visual fidelity, screen sizing, in-game APIs, combat safety and host-specific compatibility still need actual Forever testing.

## Troubleshooting

- `/console scriptErrors 1` and `/reload` enable error display. If an error occurs, capture the full message and stack trace and report `/bagrules status` and the installed EllesmereUI/Bags versions. To hide it later, `/console scriptErrors 0`.
- If neither adapter is available, update EllesmereUI and enable the Bags module. The package cannot add native bag capabilities where the host does not expose any supported category API.
- To uninstall, disable BagRules in AddOns and reload or restart. No host assignments were created by the addon. Removing BagRules' own saved variables is optional and deletes its configuration.

## Technical references

- Category API: https://github.com/EllesmereGaming/EllesmereUI/blob/main/EllesmereUIBags/EllesmereUIBags_Categories.lua
- Plugin API: https://github.com/EllesmereGaming/EllesmereUI/blob/main/PLUGINS_API.md
- Host TOC: https://github.com/EllesmereGaming/EllesmereUI/blob/main/EllesmereUIBags/EllesmereUIBags.toc
- Integration precedent: https://github.com/HydraxSkarrag/BagProfessions

No source code from the host or Baganator is bundled. Public API names and ordinary WoW item IDs are used for interoperability.

## v0.2.1: section layout fallback

The editor groups consecutive categories under clickable section headers and allows groups to collapse. General > Bag display layout offers three modes: Section / Category (original), Category names only (short flat headers), and Section overview (merges displayed items by section, not by rule). These modes share the same classification engine, priorities and saved categories. The public host API does not provide true nested section headers inside bags. No internal host functions are hooked or replaced.

## v0.2.3: standalone runtime sections (no host patch)

Install this addon folder alone. No Python script, host replacement files, or modified EllesmereUI files are included or required. If you applied the v0.2.2 local patch, undo it with that version's original --undo command, or restore your untouched 9.9 host files before testing the new adapter. Existing BagRulesDB, import data, priority and sections are preserved.

Open /bagrules > General > Bag display layout > Nested sections, then open the BagRules view. Run /bagrules status while the bags are open. Expect `Section API: runtime nested (N sections)` when the adapter succeeds. A `flat: ...` diagnostic tells you why it declined the layout. The section count is for nonempty sections. The header buttons collapse or expand all matching children; search temporarily opens matching sections. Collapse state is session-only. The host still handles stack merging, pins, junk and item interactions.

The adapter uses a public item overlay registration to observe native slot-parent frames and hooksecurefunc on EUI_Bags:RefreshInventory to reflow the complete rendered blocks after the host's normal paint. It accepts host versions based on available capabilities, not the version string, and checks selected sidebar entry, child anchors, known frames, per-group item counts, and layout boundaries before any native frame movement. It changes anchors and visibility of existing frame parents out of combat, not secure item button IDs, actions, attributes, or data. It introduces independent plain section-header buttons. It adjusts the native scroll child's height, not the bag window's automatic size; a taller layout may require scrolling. It does not use or distribute host source code.

The fallback uses the stock flat Section / Category layout during combat refreshes, cursor interaction, select modes, List mode, unsupported host versions and unexpected geometry. If the adapter errors, it attempts to restore original anchors and visibility and disables runtime layout for the session. Select Section / Category in General or disable BagRules and /reload if needed. If a previous host patch is still present, its existing integration remains compatible but is not needed for this version. Never interpret automated mocks as live taint or interaction validation. Test in a safe out-of-combat area before testing combat.

## v0.2.4: update-resistant compatibility

The exact supplied 9.9 and 9.9.1 packages have identical non-directory file contents except the version line in the TOC. The fixed 9.9 gate has been removed. The adapter checks its required bag and category manager methods before registering, validates the native frame layout on each refresh, and reports missing APIs or incompatible layout details in /bagrules status along with the detected EUI Bags version. A changed version alone does not disable the adapter. Future renderer changes may still need a BagRules update; simulated compatibility is not live verification. No host changes, rule changes, or saved-data migration are required.

### Inventory ordering (0.3.3)
Nested BagRules inventory uses the saved manager section and category order, even if the native layout presents groups in a different sequence. Pinned/Recent stay first, Uncategorised and native Junk last. Empty categories are omitted. Rule precedence and item ordering within each category are unchanged.
