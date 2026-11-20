# Changelog

The repository now carries the reviewed 0.7.4 source plus the alpha.1 and alpha.2 combat fixes. Older entries document the recovered release lineage.

## 0.7.4-alpha.2 — current development source

- Fixed bags still turning flat in combat on alpha.1. EUI rebuilds its flat layout when inventory changes in combat, so skipping BagRules' pass left the flat layout on screen. The runtime hierarchy and grouped native sidebar now repaint in combat when none of the frames they move is protected (`IsProtected()`).
- If any affected frame is protected, the repaint is deferred. Existing headings are kept only while the layout under them is unchanged; stale headings are hidden instead of overlapping rebuilt rows.
- After combat, the open bag is repainted once if an adapter is still deferred.
- Owner-reported live test on 2026-11-20: the fix works in game. Detailed status output, taint log and bank/list/offline cases were not recorded.

## 0.7.4-alpha.1

- Updated the repository source from 0.4.0 to the complete recovered 0.7.4 codebase.
- Preserved the last validated green parent headers and grouped sidebar layout during combat instead of immediately exposing flat per-category labels.
- Queued combat-time layout work and added a delayed rebuild after `PLAYER_REGEN_ENABLED`.
- Kept the generated local-use icon filename database out of public distribution pending permission review; client metadata and optional `IconFileNames` remain supported.
- Live combat verification is required before the hotfix is considered tested.

## Migration documentation

- Added persistent project instructions and technical documentation.
- Corrected the public feature description and later updated it for the integrated 0.7.4 source.
- Recorded the privately recovered 0.7.4 package and the missing conversation-linked 0.7.5 package.
- Raw conversations and recovery artifacts remain outside public Git history.

## 0.7.5-alpha — conversation evidence only

- Described parent categories as directly selectable in the native bag sidebar.
- Described parent counts aggregated from children, a separate expand/collapse control, and parent selection showing items from populated children.
- Reported limitations for list view, bank/offline views, combat fallback, and incompatible layouts.
- The linked binary/source/test attachments have not been recovered; implementation and test claims are unverified.

## 0.7.4-alpha — integrated recovered baseline

- Added a generated local icon filename index derived from a community listfile.
- Reported 33,823 retained filename mappings and 75 excluded obvious placeholders.
- Kept icon discovery client/catalogue-driven and avoided runtime network access.
- Redistribution terms for the generated metadata remain unresolved.

## 0.7.3-alpha — recovered privately, not integrated

- Expanded icon taxonomy to 98 detailed categories grouped into nine families.

## 0.7.2-alpha — recovered privately, not integrated

- Added continuous icon browsing with recycled buttons, suggestions, fill-missing, and guarded undo behavior.

## 0.7.1-alpha — recovered privately, not integrated

- Integrated import, layout, icon browsing, and native-sidebar work.

## 0.7.0-alpha — recovered privately, not integrated

- Added conservative conversion of legacy rule data.

## 0.6.0-alpha — recovered privately, not integrated

- Added native metadata filter storage, encoding, and decoding.

## 0.5.0-alpha — recovered privately, not integrated

- Added a more compact category manager layout.

## 0.4.0-alpha — current Git source

- Added independent parent sections/categories and hierarchy synchronization.
- Preserved category classification, previews, import/export, and EUI adapters from earlier releases.

## 0.3.3-alpha — recovered release history

- Separated visual display order from classification tie order.

## 0.3.2-alpha — recovered release history

- Added category-manager drag-and-drop behavior.

## 0.3.1-alpha — referenced, archive missing

- Described as a tooltip hotfix in the historical conversation.

## 0.3.0-alpha — recovered release history

- Added the category manager and visual rule builder.

## 0.2.5-alpha — recovered release history

- Tightened compact-layout packing and spacing.

## 0.2.4-alpha — recovered release history

- Replaced version assumptions with capability and geometry compatibility checks.

## 0.2.3-alpha — recovered release history

- Added runtime sections without requiring host modification.

## 0.2.2-alpha — referenced, archive missing

- Used a temporary local host patch that was superseded by the runtime adapter in 0.2.3.

## 0.2.1-alpha — recovered release history

- Added section fallback behavior.

## 0.2.0-alpha — recovered release history

- Added import functionality.

## 0.1.0-alpha — recovered release history

- Initial development package.
