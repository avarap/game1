# Player art generation prompt

This file is a mandatory generation contract for any worker that creates or replaces player artwork in this folder.

## Reference policy

Use the screenshots in `docs/` only as visual quality references. Extract only quality bar, detail density, readability, material separation, environmental richness, scale relationships and polish. Do not copy any recognizable character, costume, face, prop, symbol, palette, composition or protected design.

## GAME1 ART BIBLE

- Perspective: 3/4 top-down 2D.
- Style: handcrafted high-density pixel art.
- Proportions: stylized but believable; readable at gameplay scale.
- Silhouette: strong and immediately recognizable.
- Palette: muted natural medieval base colors with controlled accents, consistent with `ART_DIRECTION.md`.
- Lighting: soft directional light from upper-left; shadows down-right.
- Pixel treatment: deliberate clusters, crisp edges, no blur, no painted anti-aliasing, no fake pixel-art filter.
- Quality target: finished commercial indie-game artwork, never placeholder/prototype quality.
- Scale: quality takes precedence over minimizing sprite dimensions. Increase source resolution when needed while preserving the existing gameplay footprint, feet pivot and collision contract.
- Originality: all designs must be original to game1.

## Character target

Create the original game1 protagonist as a distinctive medieval cemetery keeper / undertaker suitable for a darkly humorous management RPG.

Requirements:
- memorable silhouette;
- expressive head and face readable at gameplay scale;
- clear material separation for skin, hair, cloth, leather, metal and tools;
- practical work clothing rather than heroic armor;
- enough pixel resolution to communicate personality, clothing construction and wear;
- consistent proportions and palette in every direction;
- no chibi simplification caused only by an arbitrary canvas limit.

## Required views and animation compatibility

Support `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW` and the current feet-centered pivot/Y-sort contract. Idle and walk assets must stay compatible with the runtime animation system. Mirroring is allowed only when no asymmetric design element would become incorrect.

## Generation prompt template

Use the attached `docs/` screenshots only as VISUAL QUALITY REFERENCES. Create an ORIGINAL protagonist for game1, a darkly humorous medieval cemetery-management RPG. Match the references only in detail density, pixel craftsmanship, readability, material richness, scale confidence and commercial polish. Use 3/4 top-down handcrafted pixel art, strong silhouette, believable stylized proportions, muted medieval colors, crisp deliberate pixel clusters and soft upper-left lighting. Do not copy any recognizable character, costume, face, prop or composition. Preserve game1's feet pivot and gameplay footprint, but increase source sprite dimensions whenever required to achieve a detailed, expressive, production-quality character. Produce consistent directional views suitable for an eight-direction idle/walk spritesheet.

## Reject the result if

- it looks like a prototype, placeholder or icon;
- the face/clothes cannot carry identity because the sprite is too small;
- large areas are flat geometric blocks with minimal material detail;
- it relies on blur, vector smoothness or post-pixelation;
- directions change proportions, clothing or colors;
- it copies recognizable reference-game designs;
- it is merely a higher-resolution version of the current simplistic SVG without a genuine redesign.
