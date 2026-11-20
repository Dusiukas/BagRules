# BagRules

> **Alpha software:** BagRules is under active development. Features, interfaces, compatibility, and data formats may change between releases.

BagRules is a WoW Forever inventory-classification addon developed for the EllesmereUI (EUI) ecosystem. It adds user-defined categories, parent sections, rules, previews, and import/export without replacing EUI's bag interface or physically moving items.

## Screenshots

See the [BagRules screenshot gallery](SCREENSHOTS.md) for the category manager, hierarchical bag view, and searchable icon browser.

### Category manager

![BagRules category manager integrated into EllesmereUI](docs/images/category-manager.png)

### Hierarchical inventory

![BagRules hierarchical categories in the inventory sidebar](docs/images/bag-hierarchy.png)

### Icon browser

![BagRules searchable icon browser](docs/images/icon-browser.png)

## Repository status

The current development source is **0.7.4-alpha.2**. It updates the repository to the recovered 0.7.4 code and adds combat hierarchy fixes: green parent headers and the grouped sidebar are repainted when inventory changes in combat (when the host frames involved are unprotected), deferred otherwise, and rebuilt after combat ends.

A conversation describes a later **0.7.5-alpha** build with selectable parent categories, but that source archive has not been recovered. Parent headers in 0.7.4 group and collapse children; they do not select an aggregate parent view.

| Evidence | State |
|---|---|
| Checked-in `BagRules/` | 0.7.4-alpha.2; current development source |
| Original recovered package | 0.7.4-alpha; preserved privately and locally |
| Conversation-only build | 0.7.5-alpha; attachment missing |

See [Project context](docs/PROJECT_CONTEXT.md), [Requirements](docs/REQUIREMENTS.md), and [Development history](docs/DEVELOPMENT_HISTORY.md) for the migration record.

## Current checked-in capabilities

- Create, rename, enable, duplicate, reorder, and delete parent sections and categories.
- Build nested ALL/ANY/NOT rules or use expression mode.
- Assign explicit item IDs with precedence over rules.
- Classify by item metadata and optional Auctionator prices while preserving unknown values.
- Keep classification priority and visual display order separate.
- Preview matches and competing categories before saving.
- Edit native metadata filters or retain advanced legacy expressions.
- Import/export BagRules formats 1–7 and prepare Baganator-style input conservatively.
- Preview and convert compatible legacy rules while retaining unsupported rules with warnings.
- Register an independent EUI virtual view when available, with a native virtual-category fallback.
- Group native sidebar categories under collapsible parent headers.
- Browse and search client-discovered icons using a recycled, continuously scrolling picker.
- Use optional `IconFileNames` metadata for additional icon labels.
- Open settings with `/bagrules` or `/brules`; use `status`, `refresh`, or `fallback` as subcommands.

The generated 33,823-entry local icon filename index is not cleared for public redistribution and is therefore excluded from public source/packages. The picker continues to work with client metadata and the optional `IconFileNames` addon. Selectable aggregate parent views remain unrecovered 0.7.5 functionality.

## Installation for development review

1. Back up the character/account `WTF` data that contains `BagRulesDB`.
2. Copy the checked-in `BagRules` directory to the WoW Forever `Interface/AddOns` directory.
3. Enable EllesmereUI, EllesmereUIBags, and BagRules. Auctionator is optional.
4. Restart the client or run `/reload`, then open `/bagrules`.

The checked-in TOC targets interface `16001`. Other clients and EUI releases have not been verified.

## Verification status

No executable test harness or test fixtures were found in the repository or any of the 17 recovered release ZIPs. Historical release notes claim mock tests, but those results cannot currently be reproduced. The owner reported the alpha.2 combat fix working in game; taint-log and edge-case checks are not yet recorded. Other WoW/EUI layout, taint, bank, offline inventory, and upgrade behavior also require testing. See [Testing](docs/TESTING.md).

## Contributing and privacy

Read [AGENTS.md](AGENTS.md) and [CONTRIBUTING.md](CONTRIBUTING.md) before making changes. Raw ChatGPT transcripts, screenshots that may contain personal data, release recovery material, and private manifests are intentionally stored outside this public repository and must not be committed.

## License

Project licensing is pending review. Third-party dependencies and icon metadata have their own terms, and redistribution rights for the recovered generated icon filename database remain unresolved. World of Warcraft and its assets are property of Blizzard Entertainment. BagRules is an independent community project and is not affiliated with or endorsed by Blizzard Entertainment.
