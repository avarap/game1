# Tileset and terrain art generation prompt

Mandatory contract for any worker creating or replacing tilesets in this folder.

## Reference policy
Use `docs/` screenshots only as visual quality, density and polish references. Do not copy recognizable terrain tiles, map layouts, borders, vegetation patterns, palettes or compositions.

## GAME1 ART BIBLE
- 3/4 top-down handcrafted high-density pixel art.
- Logical tile grid remains 32 x 32 px for gameplay compatibility.
- Visual richness comes from tile families, transitions, overlays and decorations, not from abandoning the grid contract.
- Muted natural medieval palette consistent with `ART_DIRECTION.md`.
- Soft upper-left lighting and coherent shadow language.
- Crisp deliberate pixel clusters; no blur, vector smoothness or fake pixel filters.
- Commercial indie-game finish; all designs original to game1.

## Tileset requirements
Terrain must avoid obvious repeated stamps and large visually empty surfaces. Provide compatible variants for base terrain, worn areas, edges, corners, transitions and low decorations. Use controlled noise, clustered detail and organic boundaries while keeping gameplay readability. Roads and paths must remain legible. Decorative overlays must not encode gameplay, collisions or navigation.

## Generation prompt template
Use the attached `docs/` screenshots only as VISUAL QUALITY REFERENCES. Create an ORIGINAL game1 tileset family for [ZONE/TERRAIN]. Match only their environmental density, pixel craftsmanship, terrain richness, transition quality, readability and commercial polish. Preserve game1's logical 32 x 32 tile grid. Produce cohesive base tiles, multiple non-clone variants, edges, corners, transitions, worn states and compatible low-detail overlays such as grass clumps, leaves, stones, roots, cracks or flowers. Use handcrafted crisp pixel clusters and coherent upper-left lighting. Avoid obvious tiling seams, repeated noise stamps, empty flat color fields and recognizable layouts from reference games.

## Reject the result if
- repeated tiles are immediately obvious at normal gameplay zoom;
- terrain is mostly flat fill plus a few random pixels;
- transitions form mechanical square borders;
- detail destroys path or interaction readability;
- it uses blur, painted anti-aliasing or post-pixelation;
- it reproduces recognizable reference-game terrain.
