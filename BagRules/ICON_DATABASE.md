# Local icon filename metadata

Source: user-provided `community-listfile.csv` from https://github.com/wowdev/wow-listfile (download: https://github.com/wowdev/wow-listfile/releases/latest/download/community-listfile.csv).

Source SHA-256: `46888c4d1a7534c24973718b77b3927573b81cf9a4f7c02e512fb6a268c37d18`.

2,278,345 source rows; 33,898 interface/icons/*.blp IDs; 33,823 retained filename mappings after excluding 75 obvious placeholders. Some retained community filenames may be inaccurate, inferred or later renamed. These are filename labels, not a full Wowhead item/spell name index. The addon intersects a locally generated index with the existing client-discovered catalogue; assets from other expansions are not injected from the index.

The upstream repository did not display an explicit redistribution licence when checked. The generated index is supplied only in the owner's private/local package and is not cleared for public redistribution. Public Git source therefore contains a blank `IconFileIndex.lua` placeholder. Before distributing the derived database publicly, verify applicable permissions; alternatively distribute the generator and let users build their own local metadata. The source generator was referenced in the historical development archive but has not yet been recovered into this repository.

No network use is required in game. A locally generated index is read-only and is not written into SavedVariables. Without it, the picker uses client-discovered labels and the optional `IconFileNames` addon.
