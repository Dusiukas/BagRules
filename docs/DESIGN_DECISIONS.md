# Design decisions

## D-001 — Extend EUI rather than replace it

BagRules uses EUI category/view integration and preserves the native bag experience. A separate Baganator-style inventory window was rejected because the user prefers EUI's appearance and behavior. EUI files must not be patched.

## D-002 — Capability detection, not host-version gates

EUI updates changed APIs and geometry during development. The addon detects callable registration, refresh, layout, and optional hierarchy facilities and degrades safely. Hard-coding a single EUI version was rejected.

## D-003 — Classification and display order are separate

Classification uses manual assignment, then descending numeric priority, then stable tie order. Dragging a category for display must not unexpectedly change which category claims overlapping items. This separation was introduced after early ordering behavior proved confusing.

## D-004 — Unknown is a real logical state

Item data can be asynchronous or unavailable. The rule engine therefore uses true, false, and unknown. Negation never converts unknown metadata into a definite match. Silently treating missing values as false was rejected because `NOT missing` would over-classify items.

## D-005 — Imports are bounded data, never code

BagRules implements its own bounded expression parser and bounded decoders for supported Baganator input. It does not call `loadstring` or evaluate imported Lua. Size, depth, token, node, and collection limits protect the client. Unsupported translations remain unknown or generate warnings rather than broad matches.

## D-006 — Versioned exports and conservative migration

Persistent profiles are exported using explicit `BAGRULES/n` records. The checked-in source reads formats 1–4; recovered source extends the sequence through 7. Imports create a backup before replacement. Schema changes must be additive or explicitly migrated.

## D-007 — BagRules does not perform physical item actions

The addon classifies and displays. Selling, destroying, mailing, banking, and moving items were deliberately excluded to reduce risk and avoid secure-action complexity.

## D-008 — UI should look native to EUI

The settings page uses EUI plugin registration, accents, controls, background, and navigation when possible, plus a fallback window. The user rejected designs that looked like a generic standalone dark panel. Compact spacing and use of the available manager area are acceptance requirements.

## D-009 — Runtime hierarchy must remain optional

Stock EUI capabilities do not consistently expose external nested groups. The checked-in source uses paths, parent grouping, or a detected hierarchy extension and an observational runtime layout adapter. A mandatory host patch was used briefly around 0.2.2 and then rejected in favor of the 0.2.3 adapter.

## D-010 — Parent selection is distinct from expansion

The requested interaction is: select BagRules for all; select a parent for the union of its populated children; select a child for that child alone. Expansion/collapse must use a separate control. The transcript claims this was implemented in 0.7.5, but source is missing, so it remains an unverified target decision.

## D-011 — Icon browsing is local and incremental

The later icon browser discovers icons from the client/catalogue, recycles a bounded number of UI buttons, and enriches known IDs with a local filename index. It does not query the internet at runtime. Automatic suggestions or fill operations never overwrite a user-selected icon.

The recovered filename index was generated from a community listfile. Because redistribution rights are unresolved, integration is blocked pending provenance/license review. Shipping a 147 MB raw CSV was rejected; the recovered build reports a reduced set of 33,823 mappings and 75 excluded placeholders.

## D-012 — Native filters complement expressions

Recovered 0.6+ code represents common metadata choices as bounded sets, flags, numeric ranges, exclusions, and alternative methods while retaining expression compatibility. This supports a friendly UI without giving up precise advanced rules.

## D-013 — Historical claims are not verification

Release summaries, generated download links, and assistant test statements are useful leads, not proof. A feature is called live-tested only when the environment and reproducible evidence are available. Missing attachments are documented as missing.
