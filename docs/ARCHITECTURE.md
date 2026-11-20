# Architecture

## Runtime shape

```text
WoW events / bag slots / optional Auctionator prices
                    |
                    v
          Core item metadata cache
                    |
                    v
     bounded parser + three-valued rule engine
                    |
       manual IDs -> priority -> stable tie
                    |
                    v
       category ID + parent/display hierarchy
                    |
          +---------+----------+
          |                    |
 EUI virtual view/category   runtime layout adapter
          |                    |
          +---------+----------+
                    v
              EUI Bags UI
```

Configuration flows through the EUI plugin settings page when available and through a fallback frame otherwise. Import/export remains data-only. Persistent state is in the account-level `BagRulesDB` saved variable.

## Core modules

| File | Responsibility |
|---|---|
| `BagRules.toc` | Client metadata, dependencies, saved variable, load order |
| `RuleEngine.lua` | Bounded expression tokenizer/parser, AST evaluation, field/operator validation, three-valued logic |
| `Import.lua` | Bounded Base64/DEFLATE/CBOR/JSON decoding and conservative Baganator translation |
| `Core.lua` | Database defaults/migration, category/section operations, metadata collection, classification, preview, import/export, EUI registration, events |
| `RuntimeSections.lua` | Optional observational layout adapter for section headers and compact geometry on compatible EUI Bags builds |
| `VisualRules.lua` | Conversion and editing model for nested visual rules |
| `Options.lua` | EUI plugin page, fallback settings window, drag/drop manager, preview, slash commands |

## Modules added in the 0.7.4 line

These files are part of the active source:

| File | Responsibility |
|---|---|
| `NativeFilters.lua` | Native filter sets, flags, numeric ranges, exclusions, alternative methods, bounded serialization |
| `NativeSidebar.lua` | Extended native sidebar and hierarchy behavior |
| `IconSearch.lua` | Icon discovery, taxonomy, query, suggestions, continuous/recycled browser UI |
| `IconFileIndex.lua` | Generated icon file-ID/name mapping used to label discovered client icons |
| `ICON_DATABASE.md` | Generation/source notes and database counts |

Public `IconFileIndex.lua` is an empty placeholder until redistribution terms are reviewed. The owner's local package contains their generated index; the public picker falls back to client metadata and optional `IconFileNames`.

## Classification lifecycle

1. Initialization normalizes `BagRulesDB`, assigns persistent category/section IDs, and migrates earlier fields conservatively.
2. Enabled categories in enabled parents are compiled. Invalid expressions are counted and excluded.
3. Categories are sorted for classification by descending priority and stable tie value.
4. Metadata is obtained from the client, bag slot, and optional Auctionator API. Incomplete asynchronous item data is not cached as complete.
5. Manual item IDs are checked first across compiled categories.
6. Rule ASTs are evaluated in classification order. Only a definite `true` matches; `nil` represents unknown.
7. The resulting category is mapped separately into visual section/category order.
8. EUI integrations refresh outside combat. Missing capabilities produce a fallback status, not a host modification.

## Rule model

Expressions support parentheses, `AND`/`&`, `OR`/`|`, `NOT`/`!`, keywords (`all`, `never`, `unknown`), aliases, and typed comparisons. Text contains uses `~`. The parser is bounded to 8,192 bytes, 2,048 tokens, and nesting depth 24 in 0.4.0.

Three-valued logic is intentional: for an unknown operand, `NOT unknown` stays unknown; false dominates AND, true dominates OR, and otherwise unknown propagates. This prevents missing metadata from becoming a match through negation.

## EUI integration

`Core.lua` capability-detects `EUI_CategoryManager` functions. It prefers a virtual view when configured and available, with virtual categories as a conventional or fallback mode. Hierarchy support is opt-in through a detected host capability; otherwise names may be rendered as paths or parent-only groups. `RuntimeSections.lua` observes compatible bag controls and adjusts headers/geometry without secure item hooks.

The missing 0.7.5 design reportedly adds selectable parents through native selectable views plus a runtime adapter because EUI did not expose a direct external parent-group filtering API. That design must be verified against recovered source before adoption.

## Persistence and compatibility

The database owns categories, parent sections, enabled state, view/native preferences, layout choice, manual IDs, expressions, priority, stable ties, icons, source warnings, backup data, and monotonically assigned IDs. Export formats are versioned rather than serialized Lua. Any schema change must include normalization and downgrade/restore considerations.
