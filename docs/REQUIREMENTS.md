# Requirements

Status terms:

- **Implemented**: present in the named source.
- **Observed**: user reported or showed a narrow live result.
- **Static only**: source inspected, no reproducible live/test evidence.
- **Planned**: requirement not established in available source.
- **Missing evidence**: claimed artifact or test is unavailable.

## Functional requirements matrix

| ID | Requirement | Historical 0.4.0 | Current 0.7.4-alpha.1 | Evidence / remaining work |
|---|---|---|---|---|
| R-001 | Create, rename, duplicate, enable, reorder, and delete categories | Implemented | Implemented | Static only |
| R-002 | Organize categories under independent parent sections | Implemented | Implemented | User observed hierarchy problems during iterations; live retest required |
| R-003 | Select a parent in the bag sidebar to show all child categories | Not implemented | Not established | Claimed for missing 0.7.5; high-priority recovery and test item |
| R-004 | Expand/collapse a parent independently of selecting it | Not implemented | Not established | Claimed for missing 0.7.5 |
| R-005 | Parent counts equal the combined visible contents of children | Not implemented | Not established | Claimed for missing 0.7.5 |
| R-006 | Nest ALL/ANY groups and negate conditions | Implemented | Implemented | Parser and visual-rule source inspected |
| R-007 | Preserve unknown metadata through boolean logic | Implemented | Implemented | Source confirms three-valued logic; automated tests missing |
| R-008 | Manual item IDs override rules | Implemented | Implemented | Source inspected |
| R-009 | Higher numeric priority claims items first; stable tie order resolves equals | Implemented | Implemented | Source inspected |
| R-010 | Visual order is independent from classification tie order | Implemented | Implemented | Introduced in 0.3.3; source inspected |
| R-011 | Preview matches, unknown data, and competing earlier categories | Implemented | Implemented | Live behavior unverified |
| R-012 | Support item metadata and optional Auctionator price rules | Implemented | Implemented | Auctionator integration unverified live |
| R-013 | Provide bounded, data-only import; never execute imported Lua | Implemented | Implemented | Source inspected |
| R-014 | Import BagRules legacy/hierarchy formats and Baganator input conservatively | Implemented through format 4 | Expanded through formats 5–7 and conversion | Round-trip fixtures missing |
| R-015 | Back up current configuration before import/migration | Implemented | Implemented/expanded | Restore behavior needs tests |
| R-016 | Provide native metadata filter UI/data model | Not implemented | Implemented | Recovered source only; strict encoding described |
| R-017 | Browse icons continuously with recycled controls | Not implemented | Implemented | Recovered source only; live performance unverified |
| R-018 | Search and semantically group icon choices | Not implemented | Implemented | 98 categories/nine families in 0.7.3–0.7.4 |
| R-019 | Suggest icons and fill only missing icons, with guarded undo | Not implemented | Implemented | Recovered 0.7.2+ source; must never overwrite custom icons |
| R-020 | Use local icon filename metadata without runtime network access | Not implemented | Implemented | Redistribution terms unresolved |
| R-021 | Register EUI virtual views/categories without modifying EUI | Implemented | Implemented | Guarded source inspected; live compatibility required |
| R-022 | Prefer capability detection over hard host-version checks | Implemented | Implemented | Source inspected |
| R-023 | Defer unsafe refresh/layout work during combat | Implemented | Implemented | Taint/combat test missing |
| R-024 | Preserve native EUI appearance, theme, and default background | Partially implemented | Expanded | User repeatedly requested closer fidelity; visual acceptance test required |
| R-025 | Use the full available category-manager space | Partially implemented | Expanded | User requirement; screenshot comparison needed |
| R-026 | Keep gaps between category groups compact and consistent | Runtime adapter implemented | Expanded | User reported excessive gaps, notably Raid Prep/professions; live regression test required |
| R-027 | Show category and subcategory hierarchy in bags, not a flat child list | Partial/fallback-dependent | Expanded but limitations remain | User reported flat rendering after EUI update |
| R-028 | Survive EUI updates without reverting to an old layout | Not guaranteed | Not guaranteed | Regression observed by user; compatibility contract/tests needed |
| R-029 | Support bags and bank consistently | Bags primary; bank adapter path | Bags primary; bank limitations | Bank/offline behavior remains unverified and historically flatter |
| R-030 | Never sell, destroy, mail, deposit, or physically rearrange items | Implemented boundary | Implemented boundary | Must remain invariant |
| R-031 | Preserve the last valid hierarchy during combat and rebuild after combat | Flat fallback | Implemented in alpha.1 | Installed locally; live combat verification required |

## User experience requirements

- The addon should feel like part of EUI: same accent handling, control shapes, spacing, backgrounds, and settings navigation.
- Category management should be understandable without raw expressions, while expression mode remains available and round-trippable.
- Parent categories and subcategories need distinct icons, names, ordering, and enabled state.
- The bag sidebar should support the natural workflow “all BagRules items → one parent and all children → one child.”
- Empty selections should show an appropriate empty state rather than leaking unrelated items.
- Compact and grid modes take priority; list view and bank behavior must be labeled if unsupported.
- Icon browsing must be responsive, labeled where metadata exists, searchable, and usable without loading all icon widgets at once.

## Non-functional requirements

- Bound input sizes, token counts, nesting, collection sizes, and decompressed output.
- Do not execute import text.
- Cache item metadata only when sufficiently complete; invalidate on relevant events.
- Do not introduce runtime network dependencies.
- Preserve `BagRulesDB` across upgrades and provide explicit migration/backup behavior.
- Avoid taint and protected operations; degrade safely when host APIs are absent.
- Clearly separate implemented, live-tested, untested, and planned functionality in releases and documentation.
