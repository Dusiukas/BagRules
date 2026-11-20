# Contributing to BagRules

BagRules is in an evidence-recovery and stabilization phase. Read `AGENTS.md` and the files under `docs/` before changing code.

## Before changing code

- Confirm the target baseline. The Git tree is 0.4.0-alpha; 0.7.4-alpha is a private recovered candidate, not the current branch.
- Check for unrelated working-tree changes and preserve them.
- Open an issue or discuss any source replacement, database migration, public API change, or new third-party dataset first.
- Never add raw conversations, personal information, credentials, or private recovery material.

## Change expectations

- Keep manual assignment, priority, stable tie order, three-valued rule logic, and display-order invariants intact.
- Detect EUI capabilities at runtime and keep integrations guarded.
- Do not patch EUI files or perform physical item actions.
- Keep import parsing data-only and bounded; unsupported input should fail conservatively.
- Include a migration path for persistent-schema or export-format changes.
- Match EUI theme and layout conventions, including compact spacing and safe fallbacks.

## Verification

Document each change as one of: implemented, statically checked, mock-tested, live-tested, untested, or planned. Do not use “tested” without naming the environment and test evidence.

At minimum:

1. Run whitespace/static checks.
2. Exercise rule precedence and unknown-value behavior.
3. Exercise import/export round trips for affected versions.
4. Test the applicable scenarios in `docs/TESTING.md` in WoW Forever with EUI.
5. Update the changelog and relevant documentation.

## Commits and releases

Use focused commits with meaningful messages, but do not commit, push, tag, or publish during the migration until the owner explicitly approves the recovered result. Release ZIPs must contain one installable `BagRules` folder and must be produced from reviewed Git source, not an untracked private archive.

## Bug reports

Include the BagRules version, WoW client/interface version, EUI/EUI Bags version, layout mode, bag or bank context, reproduction steps, Lua errors, and sanitized screenshots. State whether the problem occurs in or out of combat.
