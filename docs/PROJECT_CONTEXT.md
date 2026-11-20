# Project context

## Purpose

BagRules adds rule-driven inventory categories to WoW Forever while preserving EllesmereUI's native bag experience. The project grew from a request for Baganator-like category rules, hierarchical organization, and useful icon selection without adopting a replacement bag UI or turning play into inventory administration.

## Repository and migration state

- Local repository: `%USERPROFILE%\Desktop\BagRules`
- GitHub remote: `https://github.com/Dusiukas/BagRules.git`
- Branch: `main`, tracking `origin/main`
- Verified migration baseline: commit `493e981`, clean before documentation work
- Active addon version: `0.7.4-alpha.1` (recovered 0.7.4 plus combat hierarchy hotfix)
- Private history: `%USERPROFILE%\Desktop\BagRules-History`
- Original requested export location: `%USERPROFILE%\Desktop\ChatGPT-Export` (not present during recovery)

The GitHub repository is currently public. An earlier setup discussion recommended making it private initially. This is an unresolved policy difference; no visibility change was made.

## Recovered evidence

Two shared ChatGPT conversations were recovered as chronological Markdown outside the repository:

- “WoW Forever Addons List,” 17–20 November 2026: product discovery, design, implementation iterations, user feedback, screenshots/files, and releases through a claimed 0.7.5 build.
- “GitHub Setup for Addon,” 20 November 2026: repository setup, public-description decisions, migration constraints, and persistent-documentation requirements.

Seventeen release ZIPs were recovered from local Downloads: 0.1.0, 0.2.0, 0.2.1, 0.2.3–0.2.5, 0.3.0, 0.3.2–0.3.3, 0.4.0, 0.5.0, 0.6.0, and 0.7.0–0.7.4. SHA-256 and inventory manifests are stored privately. Archives for 0.2.2, 0.3.1, and 0.7.5 were not found.

Hash comparison established the original Git tree as 0.4.0. The complete recovered 0.7.4 source was then integrated as the active baseline and patched to 0.7.4-alpha.1 for deferred combat hierarchy refreshes. The conversations describe 0.7.5, but only as transcript evidence and unavailable attachment links.

### Historical 0.4.0 versus active 0.7.4-alpha.1

| Comparison | Result |
|---|---|
| `RuleEngine.lua` | Byte/content hash matched 0.7.4; core expression semantics did not change |
| `Import.lua` | Byte/content hash matched 0.7.4; bounded Baganator decoding/translation was already present |
| `Core.lua`, `Options.lua`, `RuntimeSections.lua`, `VisualRules.lua` | Updated to recovered 0.7.4 behavior; Core and RuntimeSections include the alpha.1 combat fix |
| `BagRules.toc`, package `README.md` | Changed for later modules/version/dependencies and release documentation |
| `NativeFilters.lua`, `NativeSidebar.lua`, `IconSearch.lua`, `IconFileIndex.lua`, `ICON_DATABASE.md` | Added from the recovered later line; public `IconFileIndex.lua` is intentionally empty pending redistribution review |

The 0.7.4 TOC lists optional `IconFileNames` support in addition to Auctionator. The owner explicitly selected 0.7.4 as the newest release baseline on 20 November 2026.

## Evidence policy

Use the following confidence order:

1. Current source and Git history.
2. Recovered release source and package metadata.
3. User-authored requirements and observations in the transcript.
4. Assistant-authored release summaries and test claims.

An assistant saying a package passed tests is not reproducible test evidence. A screenshot report such as “working” is evidence for the specific observed interaction only, not the whole release.

## Product boundaries

- BagRules classifies items and controls views/categories; it does not sell, destroy, mail, deposit, or physically sort items.
- EUI and EUI Bags remain dependencies and are not patched.
- Auctionator is optional and supplies price data when available.
- No runtime service, Python process, AI model, or network access is required.
- Raw transcripts, personal data, screenshots, and recovered binaries remain outside the public repository.

## Current migration outcome

This documentation records the recovered knowledge without replacing addon source. Integration of 0.7.4 or any recovered 0.7.5 artifact requires a separate review, diff, live test, and explicit approval. No commit or push is part of this migration pass.
