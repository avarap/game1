# Building art generation prompt

Mandatory contract for any worker creating or replacing building artwork in this folder.

## Reference policy
Use `docs/` screenshots only as visual quality references. Extract density, readability, material richness, scale relationships and polish. Do not reproduce recognizable buildings, layouts, props, palettes, symbols or compositions.

## GAME1 ART BIBLE
- 3/4 top-down handcrafted high-density pixel art.
- Buildings must feel substantial relative to characters, never miniature because of arbitrary sprite limits.
- Strong gameplay silhouette and clearly readable entrances.
- Distinct materials for stone, timber, plaster, roof, glass, metal and wear.
- Muted medieval palette consistent with `ART_DIRECTION.md`.
- Soft upper-left light; shadows down-right.
- Crisp deliberate pixel clusters; no blur, vector smoothness or fake pixel filter.
- Commercial indie-game finish; original game1 design.

## Building requirements
Use enough source resolution to show roof structure, beams, doors, windows, masonry, weathering, repairs and small decorative details. Preserve logical 32 px gameplay modules, doors, pivots, occlusion and collision contracts; visual canvas size may grow beyond those footprints.

## Generation prompt template
Use the attached `docs/` screenshots only as VISUAL QUALITY REFERENCES. Create one ORIGINAL medieval [BUILDING TYPE] for game1. Match only their detail density, pixel craftsmanship, material readability, visual hierarchy, confident scale and commercial polish. Use a 3/4 top-down view, substantial believable proportions, a clear interactable doorway, layered roof/facade depth, weathered materials and coherent upper-left lighting. Include [FEATURES]. Keep the logical gameplay footprint compatible with game1, but increase the visual sprite resolution whenever required for high-quality architecture. Isolated asset, transparent background, no characters, no UI, no text.

## Reject the result if
- it looks like a tiny icon or placeholder;
- walls/roof are flat blocks without material construction;
- door scale is implausible next to a character;
- details are painted/blurry instead of pixel-authored;
- it copies recognizable architecture from the references;
- it is just an enlarged version of the current minimal SVG geometry.
