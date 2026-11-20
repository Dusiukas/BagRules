# Known issues and unresolved inconsistencies

## Recovery and source state

1. **The 0.7.4-alpha.1 combat fix still needs live verification.** Source and installed files are updated, but an enter-combat bag refresh and post-combat rebuild must be observed in game.
2. **The latest described 0.7.5 source is missing.** The conversation claims selectable parent categories and links ZIP/source/test downloads, but no durable copy was recovered.
3. **Two referenced intermediate archives are missing.** 0.2.2 and 0.3.1 are described in history but were not found.
4. **The original ChatGPT export directory was absent.** Recovery used the two user-supplied shared conversations. Unshared/branched messages may therefore be absent.
5. **Most original screenshots and generated attachments are unavailable.** Transcript references remain, but only local release archives and a category-manager HTML mockup were recovered.

## Verification gaps

6. **There is no recovered test harness.** No test/spec/fixture/mock files exist in Git or the 17 release ZIPs. Historical “tests passed” claims are not reproducible.
7. **Live WoW Forever verification is incomplete.** Layout, taint/combat safety, EUI update compatibility, Auctionator pricing, bank/offline inventory, and saved-variable upgrades need testing.
8. **Checked-in documentation inside the addon may describe historical behavior.** Treat `BagRules/README.md` as package-era notes; root documentation is the migration truth source.

## Runtime and UX issues reported historically

9. **Hierarchy may render flat or disappear after EUI changes.** The user observed categories/subcategories in the manager but not bags, and later an EUI update reverted the layout.
10. **Parent categories are not directly selectable in available source.** Current 0.7.4-alpha.1 groups/collapses children only; aggregate parent selection is claimed only by the missing 0.7.5 build.
11. **Group spacing can be excessive.** Raid Prep and profession sections were called out. Compact/grid geometry needs regression tests.
12. **Bank, offline inventory, and list mode are weaker targets.** The 0.7.5 description limits parent-selection behavior to compact/grid bags; flat or fallback rendering may occur elsewhere.
13. **Nested runtime layout remains experimental.** In combat or incompatible layouts, fallback grouping may expose items under an “outside selected category” style group according to the 0.7.5 description.
14. **Translation is approximate for some external searches.** Unsupported Baganator or legacy semantics remain unknown or produce warnings; they must not silently broaden matches.

## Policy and distribution

15. **Repository visibility conflicts with early intent.** The repository is public, while initial setup discussion recommended private development. No visibility change was authorized.
16. **Project licensing is undecided.** Do not add a license until ownership and dependency terms are reviewed.
17. **Icon database redistribution is unresolved.** The recovered generated index depends on community filename data whose redistribution terms were not established.
18. **No automated release packaging exists in Git.** GitHub Actions, release ZIP validation, and a reviewed release process remain planned.

## Documentation resolution rule

When a missing artifact is later recovered, verify its hash and contents, add it to the private manifest, compare it against 0.7.4 and current Git, and update these documents before integrating code.
