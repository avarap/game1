# P0 art worker prompt policy

This policy is mandatory for every worker that creates, regenerates, replaces or substantially edits visual assets under `art/`.

## Mandatory workflow

1. Read `ART_DIRECTION.md` for perspective, gameplay footprints, pivots, Y-sort, palette, lighting and technical integration.
2. Read the `PROMPT.md` located in the destination asset folder before generating or redesigning anything.
3. Use the screenshots under `docs/` only as **visual quality references**: quality bar, detail density, readability, material separation, scale confidence, environmental richness and commercial polish.
4. Never copy recognizable characters, buildings, props, maps, layouts, symbols, palettes or protected designs from those references.
5. Treat current game1 assets as replaceable implementation artifacts, not as the visual quality benchmark. A new asset must not preserve a weak design merely for visual similarity with an existing placeholder.
6. Reject output that is technically valid but visibly below the `docs/` benchmark.

## Scale override

The logical 32 px tile grid, gameplay collision footprints and feet/ground pivots remain authoritative. **Visual canvas dimensions are not a quality ceiling.** The legacy `32 x 48 px` character canvas guidance in `ART_DIRECTION.md` must not be interpreted as a maximum or acceptance target when it prevents sufficient facial, clothing, material or silhouette detail.

Workers may increase source sprite/canvas dimensions for characters, buildings and props whenever required to meet the visual quality bar, provided they preserve gameplay-scale relationships, pivots, collision/navigation semantics and crisp pixel rendering.

## Mandatory quality gate

An art PR must explain which destination `PROMPT.md` was followed and must visually compare the result against the `docs/` screenshots in terms of:

- detail density;
- silhouette readability;
- material differentiation;
- coherent scale between characters/buildings/props;
- environmental richness where applicable;
- absence of blur/vector-like rendering;
- originality;
- finished commercial-game appearance.

A result that still reads as placeholder/prototype art fails this gate even if imports, dimensions and runtime integration are technically correct.

## Folder contracts

- `art/characters/player/PROMPT.md` — protagonist.
- `art/characters/npcs/PROMPT.md` — NPCs.
- `art/environment/buildings/PROMPT.md` — buildings.
- `art/environment/cemetery/PROMPT.md` — cemetery-specific assets/compositions.
- `art/environment/props/PROMPT.md` — props and current vegetation assets.
- `art/environment/tilesets/PROMPT.md` — terrain and tile families.

When a new asset category gets its own folder, create its `PROMPT.md` before producing final art for that category.
