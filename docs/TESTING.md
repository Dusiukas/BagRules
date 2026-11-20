# Testing and verification

## Current evidence

| Area | Status |
|---|---|
| Source/version inventory | Verified by local hashes and archive inspection |
| Checked-in static source review | Completed |
| Active 0.7.4-alpha.1 static source review | Completed at feature/module level; combat patch reviewed |
| Automated tests | Not available |
| Historical mock-test claims | Not reproducible |
| Live WoW Forever/EUI testing | Incomplete / not independently reproduced |
| 0.7.5 parent-selection testing | Impossible until source/archive recovery |
| Combat hierarchy hotfix | alpha.1 observed going flat in combat; alpha.2 owner-reported working in game (2026-11-20); taint log not recorded |

No release should say only “tested.” Name the BagRules version, client/interface, EUI version, test type, and result.

## Static checks

- Confirm the TOC version, interface, dependency names, saved variables, and file load order.
- Parse/load every Lua module with a compatible Lua tool where available.
- Scan for `loadstring`, unbounded import paths, accidental runtime network assumptions, and direct EUI file modifications.
- Verify documentation links and run `git diff --check`.
- Compare release contents against expected manifests and reject extra top-level folders or private files.

## Deterministic logic tests to add

### Rule parser and evaluator

- Operators, parentheses, aliases, quoted strings, escapes, money units, and quality names.
- Maximum length, tokens, nesting, and invalid numeric values.
- Truth tables for AND, OR, and NOT with true/false/unknown.
- Missing fields and type mismatches remain unknown.
- `NOT unknown` does not match.

### Classification

- Manual ID beats every rule.
- Higher priority wins overlap.
- Equal priority uses stable tie order.
- Moving visual order does not change classification.
- Disabled category or parent cannot claim items.
- Invalid expression is excluded and reported.
- Incomplete asynchronous item information is not cached as complete.

### Import/export and migration

- Round-trip formats 1–4 for checked-in source and 5–7 for recovered candidate source.
- Reject oversized, malformed, duplicate, deeply nested, trailing, and executable-looking input.
- Verify bounded Base64, DEFLATE, CBOR, and JSON behavior.
- Verify conservative Baganator translation warnings and unknown preservation under negation.
- Verify backup-before-import and restore behavior.
- Upgrade representative `BagRulesDB` states from each schema; verify IDs, ties, sections, icons, manual assignments, and preferences.

### Recovered native filters and icons

- Encode/decode every set, flag, range, exclusion, and alternative-method boundary.
- Reject more than the supported 128 alternatives and other size limits.
- Continuous scrolling should recycle a bounded widget pool and retain selection.
- Searches and family/category filters should return stable results.
- Suggestions and fill-missing must not replace a custom icon.
- Undo should apply only to the guarded automatic operation.
- Filename enrichment must only label client/catalogue-discovered IDs and must not access the network.

## Live WoW Forever matrix

Record client build, interface number, EUI/EUI Bags version, Auctionator version, character, bag mode, and whether the test ran in combat.

1. Fresh install with no `BagRulesDB`; open plugin page and fallback window.
2. Upgrade from 0.4.0 database to the candidate version; reload and relog.
3. Create parents and children, rename, duplicate, reorder, drag between parents, enable/disable, and delete with reassignment.
4. Create overlapping manual, priority, and equal-tie rules and inspect actual bag assignments.
5. Exercise missing item info, quest/bind/openable flags, stack counts, and Auctionator prices.
6. Switch EUI compact, grid, and list layouts; resize and change scale.
7. Inspect spacing around empty/non-empty Raid Prep and profession parents.
8. Select BagRules/all, a parent, and a child; expand/collapse independently; validate counts and empty state.
9. Open bags, bank, and any offline/cross-character inventory view.
10. Enter/leave combat while changing bags or receiving items; check taint log and deferred refresh.
11. Disable/re-enable BagRules and dependencies; verify clean fallback and no stale registrations.
12. Import legacy and Baganator data, review warnings, cancel, apply, restore backup, and reload.
13. Browse/search icons for an extended period and observe frame rate/memory.

## Acceptance evidence

For each scenario, retain a sanitized result record with expected/actual behavior, errors, and screenshots where useful. Keep personal screenshots private until reviewed for publication. A feature is live-tested only after this record exists.
