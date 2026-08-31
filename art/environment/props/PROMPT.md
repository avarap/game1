# Prop and vegetation art generation prompt

Mandatory contract for any worker creating or replacing props in this folder, including trees and vegetation assets currently stored here.

## Reference policy
Use `docs/` screenshots only as visual quality references. Extract density, material readability, silhouette quality, scale relationships and polish. Never copy recognizable props, vegetation shapes, symbols, palettes or compositions.

## GAME1 ART BIBLE
- 3/4 top-down handcrafted high-density pixel art.
- Strong readable silhouette at gameplay scale.
- Material-specific pixel treatment for wood, stone, metal, cloth, foliage, bark, glass and soil.
- Muted natural medieval palette consistent with `ART_DIRECTION.md`.
- Soft upper-left light; shadows down-right.
- Crisp deliberate clusters; no blur, smooth vector appearance or fake pixel filter.
- Commercial indie-game finish; original game1 design.
- Visible sprite dimensions may exceed gameplay footprint whenever detail requires it.

## Prop requirements
Small props must still communicate construction and material. Large props and vegetation must use layered silhouettes and internal variation rather than flat geometric masses. Trees should have substantial canopies, visible trunk structure, irregular foliage clusters, readable base/pivot and non-clone variation. Sets must look related without being palette-swapped duplicates.

## Generation prompt template
Use the attached `docs/` screenshots only as VISUAL QUALITY REFERENCES. Create an ORIGINAL game1 [PROP TYPE] for a darkly humorous medieval management RPG. Match only their pixel craftsmanship, material richness, silhouette readability, scale confidence and commercial polish. Use 3/4 top-down handcrafted pixel art, crisp clusters and coherent upper-left lighting. Materials: [MATERIALS]. Distinctive features: [FEATURES]. Preserve the logical gameplay footprint and ground-contact pivot, but increase visible sprite dimensions whenever needed for convincing detail. Transparent background, no UI, no text, no unrelated scene elements.

For vegetation sets, generate multiple structurally different variants rather than recolors.

## Reject the result if
- it reads as a primitive icon or flat geometric symbol;
- materials are differentiated only by color;
- trees are simple circles/blobs on trunks;
- variants are obvious clones;
- it relies on blur, smooth vector edges or post-pixelation;
- it copies recognizable reference-game props.
