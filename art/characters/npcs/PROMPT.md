# NPC art generation prompt

Mandatory contract for any worker creating or replacing NPC artwork in this folder.

## Reference policy
Use `docs/` screenshots only as quality/style benchmarks. Never copy recognizable characters, costumes, faces, props, symbols, palettes or compositions.

## GAME1 ART BIBLE
- 3/4 top-down handcrafted high-density pixel art.
- Strong readable silhouettes and stylized-believable anatomy.
- Muted medieval palette consistent with `ART_DIRECTION.md`.
- Soft upper-left light, shadows down-right.
- Crisp deliberate pixel clusters; no blur, fake pixelation or painted anti-aliasing.
- Commercial indie-game finish, not placeholder quality.
- Source resolution may increase whenever identity/detail requires it; preserve feet pivot and gameplay footprint rather than forcing tiny canvases.
- All designs original to game1.

## NPC requirements
Every NPC must be distinguishable by silhouette before color alone. Define: role, age, body shape, social status, personality, clothing, 3 distinctive visual traits, palette accent and carried prop. Avoid palette-swapped clones.

Support consistent `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW` views and current feet-centered Y-sort contract. Character identity, clothing construction and proportions must remain stable across all directions.

## Generation prompt template
Use the attached `docs/` screenshots only as VISUAL QUALITY REFERENCES. Create an ORIGINAL game1 NPC for a darkly humorous medieval management RPG. Role: [ROLE]. Age: [AGE]. Body shape: [BODY]. Personality: [PERSONALITY]. Social status: [STATUS]. Clothing: [CLOTHING]. Distinctive traits: [TRAITS]. Accent color: [ACCENT]. Prop: [PROP]. Match only the references' detail density, pixel craftsmanship, readability, material separation, scale confidence and commercial polish. Use 3/4 top-down handcrafted pixel art with strong silhouette, expressive face, crisp pixel clusters and soft upper-left lighting. Increase source resolution when needed; do not sacrifice identity to a small canvas. Produce consistent eight-direction views suitable for idle/walk animation.

## Reject the result if
- it reads as generic filler or a palette swap;
- facial/clothing identity disappears at gameplay scale;
- proportions or costume drift between directions;
- it uses vector-smooth edges, blur or pseudo-pixel filters;
- it resembles a recognizable character from a reference game;
- it is merely a minor edit of an existing simplistic game1 sprite.
