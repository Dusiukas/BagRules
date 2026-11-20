# Development history

## Origin

The project began during a broader WoW Forever addon review. The user identified the largest inventory pain point as deciding what to keep, sell, or organize without turning the game into work. Existing EUI bags were visually preferred, while Baganator's dynamic category ideas were attractive. The chosen direction was therefore an EUI-native classifier and category editor, not a replacement inventory UI.

Early research identified EUI virtual-category integration as the viable extension point. The design then moved through a proof of concept, rule engine, native-looking settings, hierarchy/layout work, legacy import, and icon browsing.

## Recovered release chronology

| Version | Recovered | Development milestone |
|---|---:|---|
| 0.1.0 | Yes | Initial addon source |
| 0.2.0 | Yes | Import support |
| 0.2.1 | Yes | Section fallback |
| 0.2.2 | No | Temporary host patch; later superseded |
| 0.2.3 | Yes | Runtime sections without host patch |
| 0.2.4 | Yes | Capability/geometry compatibility |
| 0.2.5 | Yes | Tighter compact packing |
| 0.3.0 | Yes | Category manager and visual rules |
| 0.3.1 | No | Referenced tooltip hotfix |
| 0.3.2 | Yes | Drag and drop |
| 0.3.3 | Yes | Display order separated from classification tie order |
| 0.4.0 | Yes; current Git | Independent parent sections/categories |
| 0.5.0 | Yes | Compact manager redesign |
| 0.6.0 | Yes | Native metadata filters |
| 0.7.0 | Yes | Legacy conversion |
| 0.7.1 | Yes | Import/layout/icon/native-sidebar integration |
| 0.7.2 | Yes | Continuous smart icon browser |
| 0.7.3 | Yes | Expanded icon taxonomy |
| 0.7.4 | Yes; integrated baseline | Local icon filename database; generated index retained locally only |
| 0.7.4-alpha.1 | Superseded | Combat hierarchy/sidebar preservation and delayed post-combat rebuild; still went flat in combat in game |
| 0.7.4-alpha.2 | Current | Repaint unprotected hierarchy/sidebar frames in combat; drop stale headings; post-combat repaint |
| 0.7.5 | No | Transcript claims selectable parent categories |

## User feedback that shaped the project

- Categories and subcategories sometimes appeared in the manager but not correctly in bags.
- A later EUI update caused the bag layout to revert or flatten, demonstrating that integration cannot assume fixed host geometry.
- Gaps between parent groups were too large, particularly around Raid Prep and profession groups.
- The settings interface needed to match EUI's real colors, background, controls, and use of available space.
- The bag sidebar needed parents and children rather than a flat subcategory list.
- Many icons lacked useful labels; the user requested a browsable, searchable filename/name database.
- Parent categories needed to be directly selectable, with selection showing all items from their children.

## Latest available sources

Hash comparison established the original checked-in tree as 0.4.0. The owner later identified the complete 0.7.4 ZIP as the newest release and authorized updating the active source. Version 0.7.4-alpha.1 adds the combat hierarchy fix. No 0.7.5 ZIP, source package, test package, or extracted addon directory was found locally. Conversation download links used temporary sandbox attachment URLs and are not durable source evidence.

## Tests and attachments

The historical conversation and package READMEs mention mock test results and, for some releases, separate source/test downloads. None of the 17 recovered release ZIPs contains a test, spec, fixture, or mock file. No runnable harness was recovered, so those claims cannot be reproduced.

The transcript contains references to numerous uploaded screenshots and files. Some release ZIPs and the category-manager HTML mockup were recovered locally; most original screenshots and transient generated attachments were not. Their absence is recorded rather than replaced with reconstructed evidence.

## Migration preservation

Private history contains:

- complete visible user/assistant transcript exports for both shared conversations;
- the 17 recovered release ZIPs;
- a snapshot of the checked-in 0.4.0 addon;
- an extracted 0.7.4 addon snapshot;
- the HTML category-manager mockup and a generated README artifact;
- SHA-256 and file-inventory manifests.

These materials are intentionally excluded from GitHub. The public repository receives only consolidated, sanitized documentation.
