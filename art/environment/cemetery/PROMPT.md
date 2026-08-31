# Cemetery environment art generation prompt

Mandatory contract for any worker creating or replacing cemetery-specific artwork in this folder.

## Reference policy
Use `docs/` screenshots only as quality, density and polish references. Do not copy recognizable grave designs, layouts, buildings, props, vegetation arrangements, symbols, palettes or compositions.

## GAME1 ART BIBLE
- 3/4 top-down handcrafted high-density pixel art.
- Rich but readable environmental storytelling.
- Organic terrain variation; avoid large empty flat surfaces.
- Muted cemetery palette consistent with `ART_DIRECTION.md`: cool stone, gray-green vegetation, dark soil, restrained warm accents.
- Soft upper-left light; shadows down-right.
- Crisp pixel clusters; no blur, vector smoothness or fake pixel filters.
- Commercial indie-game quality; all designs original to game1.

## Cemetery requirements
Create assets that can combine into a dense, lived-in cemetery: varied graves, worn masonry, preparation/work objects, fencing, weeds, roots, leaves, broken stone, dry grass, subtle soil variation and signs of repair/use. Important interactables need clean silhouettes. Preserve gameplay footprints, pivots, Y-sort and collision contracts independently from visible sprite size.

## Generation prompt template
Use the attached `docs/` screenshots only as VISUAL QUALITY REFERENCES. Create ORIGINAL cemetery artwork for game1, a darkly humorous medieval management RPG. Asset/scene target: [TARGET]. Match only the references' detail density, environmental richness, pixel craftsmanship, material readability, scale confidence and commercial polish. Use 3/4 top-down handcrafted pixel art, irregular wear, layered vegetation, varied stone/soil textures, strong silhouettes and coherent upper-left lighting. Avoid empty ground and obvious repeated stamps. Do not copy any recognizable grave, prop, layout or composition. Keep gameplay footprints compatible with game1 while allowing larger visual sprites where detail requires them.

## Reject the result if
- the cemetery reads as sparse tiles placed on empty grass;
- graves/props are repeated with only color swaps;
- materials lack chips, age, construction or variation;
- visual noise hides paths or interactables;
- it uses blur or pseudo-pixel rendering;
- it reproduces recognizable reference-game designs.
