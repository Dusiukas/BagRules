# BagRules development instructions

This file is the primary instruction source for all coding agents working in this repository. `CLAUDE.md` delegates to it. Read the documentation in `docs/` before changing behavior.

## Project and evidence state

- BagRules is a WoW Forever inventory-classification addon for the EllesmereUI (EUI) ecosystem.
- The active addon source is `0.7.4-alpha.1`: the recovered 0.7.4 codebase plus a combat hierarchy hotfix. The earlier Git baseline was 0.4.0-alpha.
- The generated 33,823-entry `IconFileIndex.lua` is retained only in the owner's local package. Public source uses an empty placeholder until redistribution permission is confirmed.
- The historical conversation describes and links a `0.7.5-alpha` build with selectable parent categories. That attachment has not been recovered. Treat 0.7.5 behavior as a requirement and historical claim, not as available or verified source.
- Private recovery material lives outside this public repository at `%USERPROFILE%\Desktop\BagRules-History`. It includes raw conversation transcripts, release ZIPs, manifests, and source snapshots.
- Never copy raw transcripts, personal information, credentials, or unrelated conversation material into this repository.

When evidence conflicts, use this order: current source and Git history; recovered release source; user-authored statements and observed screenshots; assistant-authored historical summaries. Record unresolved conflicts rather than filling gaps.

## Safety and scope

- Preserve the current addon source unless a task explicitly authorizes integration or replacement.
- Do not overwrite newer source with an older release. Compare by version and file content first.
- Do not modify EllesmereUI or EllesmereUIBags files. Integrate only through detected public capabilities and guarded runtime adapters.
- Do not commit, push, publish a release, or change repository visibility without explicit user approval.
- Do not add a license until the project code, dependencies, and icon metadata redistribution terms have been reviewed.
- Keep user data compatible. Back up and migrate `BagRulesDB` deliberately; preserve supported import/export formats unless a documented migration is provided.
- BagRules classifies and displays items. It must not sell, destroy, mail, deposit, or physically rearrange items.

## Behavioral invariants

- Manual item-ID assignment wins before rule evaluation.
- Rule categories are evaluated by descending numeric classification priority. Stable tie order resolves equal priorities.
- Visual display order is independent of classification tie order.
- Unknown item metadata remains unknown. In particular, negating an unknown result must remain unknown rather than become true.
- Rule evaluation, import, and conversion must fail conservatively. Unsupported conditions must not silently broaden a match.
- Feature support is determined by capability detection, not a hard-coded EUI version gate.
- UI changes should match the installed EUI visual language, use its accent/theme facilities where available, and retain a safe fallback window.
- Secure/combat state must be respected. Defer unsafe refreshes and geometry changes until combat ends.
- Custom icons must not be replaced by automatic suggestions. Local icon metadata must not perform runtime network requests.

## Development workflow

1. Check `git status` and preserve unrelated user changes.
2. Identify whether a change targets the active 0.7.4-alpha.1 line, historical 0.4 behavior, or the planned post-recovery line.
3. Update requirements and decisions when behavior changes.
4. Add focused tests where possible. Historical claims are not test evidence.
5. Run static checks and the manual WoW/EUI matrix in `docs/TESTING.md` in proportion to the change.
6. Report what is implemented, statically checked, live-tested, untested, and planned as separate states.
7. Leave commits and pushes for explicit user approval.

## Compatibility targets

- Primary client: WoW Forever, interface `16001` in the checked-in TOC.
- Required addons: EllesmereUI and EllesmereUIBags.
- Optional integration: Auctionator price data.
- Compact and grid bag layouts are the historical primary target. List view, bank/offline inventory, nested runtime headers, and combat behavior require explicit verification.

## Documentation responsibilities

- Keep the root `README.md` limited to capabilities actually present in the checked-in source, with recovered or planned work clearly labeled.
- Record user-visible changes in `CHANGELOG.md`.
- Update `docs/API_REFERENCE.md` for schema, rule, command, or adapter changes.
- Update `docs/DESIGN_DECISIONS.md` for architectural choices and rejected approaches.
- Update `docs/KNOWN_ISSUES.md`, `docs/ROADMAP.md`, and `docs/TESTING.md` as evidence changes.
- Never cite a missing file as recovered or a historical assistant assertion as live-tested.
