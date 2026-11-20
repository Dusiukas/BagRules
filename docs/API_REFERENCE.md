# API and data reference

This reference describes the active 0.7.4-alpha.1 source. BagRules does not declare a stable third-party API yet.

## Addon metadata

- Interface: `16001`
- Required: `EllesmereUI`, `EllesmereUIBags`
- Optional: `Auctionator`
- Saved variable: `BagRulesDB`
- Slash commands: `/bagrules`, `/brules`

Slash subcommands:

| Command | Effect |
|---|---|
| no argument | Opens the EUI plugin category page when possible, otherwise fallback settings |
| `status` | Prints integration/registration state |
| `refresh` | Reapplies the configuration, invalidates cached metadata, and re-registers supported EUI integrations |
| `fallback` | Opens the standalone fallback settings frame |

## Rule expression language

Boolean syntax: `AND` or `&`, `OR` or `|`, `NOT` or `!`, and parentheses. Keywords are `all`, `never`, and `unknown`.

| Field | Type |
|---|---|
| `id`, `class`, `subclass`, `itemlevel`, `requiredlevel`, `bindtype`, `count` | number |
| `vendor`, `ahprice` | money in copper or `g`/`s`/`c` suffix form |
| `ratio` | number |
| `quality` | 0–7 or quality name |
| `name`, `type`, `subtype`, `slot` | text |
| `bound`, `boe`, `unbound`, `quest`, `craftingreagent`, `itemset`, `openable` | boolean |

Operators are `=`, `!=`, `>`, `>=`, `<`, `<=`; text additionally supports `~` for case-insensitive contains. Aliases include `weapon`, `armor`/`armour`, `consumable`, `container`, `reagent`, `tradegoods`, `recipe`, `questitem`, `ammunition`/`projectile`, and `junk`.

Examples:

```text
quality >= rare & itemlevel >= 40
craftingreagent & !quest
(weapon | armor) & unbound
name ~ "potion"
```

Only a definite true result matches. Missing/type-incompatible metadata produces unknown.

## Core methods

The addon table is passed between modules as `BR`. Important checked-in methods are:

| Method | Purpose |
|---|---|
| `Initialize()` | Normalize defaults and persistent data |
| `NewSection`, `RenameSection`, `SetSectionEnabled`, `DeleteSection`, `DuplicateSection` | Parent lifecycle |
| `NewCategory`, `SaveCategory`, `Delete` | Category lifecycle |
| `MoveSection`, `StepSection`, `MoveCategory`, `Move` | Visual hierarchy/order |
| `SectionGroups`, `SyncHierarchy` | Normalized parent/category views |
| `Item` | Build typed item metadata from client, slot, and optional price APIs |
| `ClassifyItem`, `Classify` | Apply manual and rule classification |
| `Apply` | Compile enabled configuration and register EUI integrations |
| `Invalidate`, `Refresh` | Clear caches and request host refresh |
| `Preview` | Evaluate a draft against current bags and report matches/unknown/shadowed counts |
| `Export`, `PrepareImport`, `Import` | Versioned data exchange and application |
| `RegisterOptions` | Register EUI plugin page and slash commands |

Methods are internal and may change until a public API is declared.

## Classification order

1. Enabled categories in enabled parents are compiled.
2. Manual item-ID matches are checked first.
3. Rule matches are checked by descending `priority`.
4. Equal priorities use persistent `tie` order.
5. Display order comes from section/category arrays and does not alter steps 2–4.

## Persistent data model

Exact normalization occurs in `Core.lua`; conceptually:

```text
BagRulesDB
  enabled, native, view, sectionLayout, keepPinned
  nextID, nextSectionID
  sections[]: id, name, enabled
  categories[]:
    id, name, enabled, icon
    expr, priority, tie
    sectionID, section
    manual[]
    sourceSearch, source, warning
  backup
```

Do not edit the database schema without a migration and round-trip tests.

## Export/import formats

| Header | Meaning |
|---|---|
| `BAGRULES/1` | Basic category records |
| `BAGRULES/2` | Extended category metadata |
| `BAGRULES/3` | Explicit classification tie order |
| `BAGRULES/4` | Parent definitions and category-parent references; current export |
| `BAGRULES/5` | Native-filter era format |
| `BAGRULES/6` | Extended native-filter format |
| `BAGRULES/7` | Parent-icon format; current export |
| `BGR!1!…` or JSON | Baganator input decoded and translated conservatively |

Current code reads formats 1–7 plus supported Baganator input.

## EUI host capabilities used

- `EUI_CategoryManager:RegisterVirtualCategory` / `UnregisterVirtualCategory`
- `EUI_CategoryManager:RegisterVirtualView` / `UnregisterVirtualView`
- `EUI_CategoryManager:RefreshVirtualCategories` / `RefreshVirtualViews`
- optional hierarchy marker `BagRulesSectionsAPI == 1`
- `EllesmereUI:RegisterPlugin`, `OpenPlugin`, and accent callback facilities
- observational EUI Bags methods used by `RuntimeSections.lua` when all required geometry capabilities exist

Every call is capability-checked and protected. Absence produces fallback behavior.

## Native filter model

Native filters contain inclusion sets (classes, qualities, slots, bindings, items), boolean flags (bound, quest, crafting reagent, openable, BOE, unbound, item set), numeric ranges (item level, required level, count, vendor, auction price), exclusions, subclass/name sets, and alternative methods. Serialization is bounded, with at most 128 alternative methods.
