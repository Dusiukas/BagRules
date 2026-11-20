# Roadmap

## P0 — Complete and approve recovery

- Recover the 0.7.5 install ZIP, source package, and any associated test package if still available.
- Recover or export the original project screenshots and generated attachments where privacy permits.
- Retain the completed 0.4.0-to-0.7.4 comparison and diff any recovered 0.7.5 source module by module.
- Review the generated icon database provenance and redistribution terms.
- Reconstruct a runnable local test harness from source behavior rather than relying on historical claims.
- Run the full live smoke matrix against the installed WoW Forever and EUI versions.
- Obtain owner approval before committing, replacing source, pushing, or publishing.

## P1 — Establish a reviewed integration baseline

- Live-test and stabilize the integrated 0.7.4-alpha.1 baseline.
- Verify the combat hierarchy/sidebar hotfix across bag updates, entering/leaving combat, and `/reload`.
- Preserve `BagRulesDB` and formats 1–4 while adding later native formats and migrations.
- Add deterministic tests for parser bounds, three-valued logic, classification precedence, imports, hierarchy, native filters, and icon selection.
- Verify category/section rendering after current EUI updates.
- Implement or recover selectable parent categories with a separate expansion control.
- Confirm compact spacing and full-width manager layout using sanitized reference screenshots.

## P2 — Compatibility and usability

- Validate compact, grid, and list layouts explicitly; document unsupported combinations.
- Validate bags, bank, and offline/cross-character views.
- Add combat/taint and reload/upgrade regression coverage.
- Improve semantic icon labels, suggestions, result counts, favorites, and recent icons without replacing custom choices.
- Improve native-filter discoverability and warnings for approximate conversions.
- Profile classification, item metadata caching, refresh frequency, and icon browser recycling.

## P3 — Project operations

- Decide repository visibility and licensing.
- Add issue templates with the required client/EUI/layout/combat information.
- Add CI static checks and deterministic unit tests.
- Add automated, validated packaging of one installable `BagRules` folder.
- Publish GitHub Releases only from reviewed tags and include verification status in every release note.
- Consider `develop` or short-lived feature branches only after the migration baseline is approved.

## Explicitly out of scope unless requirements change

- Replacing EUI Bags with a standalone inventory window.
- Modifying EUI/EUI Bags source files.
- Automatic selling, destroying, mailing, depositing, or physical sorting.
- Runtime web requests or an external service.
- Claiming compatibility with other WoW clients before testing them.
