# Hand-Authored Cemetery Tileset Design

## Objective

Replace the cemetery map's visually procedural terrain system with a static, deliberately authored pixel-art tileset and a baked map composition. The result must read as a commercially credible dark-rural cemetery environment at the real 1280x720 gameplay camera, while preserving the existing world bounds, collisions, navigation, interaction locations, and zone contracts.

This work belongs only to the canonical MAP branch `feat/main-map-rebuild-commercial-pass` and PR #142. It must not modify the PLAYER branch or PR #141.

## Current failure

The current MAP head uses a 256x96 atlas containing only 24 tiles. `CemeteryVisualDressing`, `CemeteryCommercialComposition`, and `CemeteryCommercialFinish` then construct much of the presentation during `_ready()` by remapping cells, drawing `Line2D` paths, erasing earlier layers, changing opacity, and adding sprites from coordinate arrays. The resulting screenshots expose flat green fields, repeated dash patterns, vector-like roads, abrupt shoulders, and weak material transitions.

Passing structural tests does not make this visually acceptable. The runtime composition code also prevents the scene file from being the authoritative authored layout.

## Art direction

- Logical tile size: exactly 32x32 pixels.
- Perspective: top-down three-quarter RPG terrain compatible with the current buildings, trees, and 64x96 character scale.
- Palette: desaturated olive greens, umber dirt, cold grey stone, muted blue-green water, dark moss, and restrained warm ochre accents.
- Lighting: common upper-left key light; lower-right material edges are darker.
- Pixel language: opaque intentional clusters, hard pixel edges, no antialiasing, gradients, vector strokes, blur, interpolation, or single-pixel noise fields.
- Surface language: broad readable clusters with sparse local detail. Repetition is broken with materially different silhouettes and cluster placement, not random speckle.
- Paths: worn earthen tracks with irregular shoulders contained inside the tile system. They must never be rendered as `Line2D` or smooth vector ribbons.
- Originality: no old main-map layout, composition, object distribution, or navigation design is restored.

## Static atlas contract

Create `art/environment/cemetery/production/atlas/cemetery_terrain_hand_authored_32.png` as a 512x256 RGBA PNG arranged as 16 columns by 8 rows. Every cell is a complete 32x32 authored tile.

| Row | Atlas cells | Family |
| --- | --- | --- |
| 0 | `(0..15, 0)` | Living grass, dry grass, moss, wet grass, rocky grass variants |
| 1 | `(0..15, 1)` | Dirt, mud, packed earth, stone and wet-soil fills |
| 2 | `(0..15, 2)` | Grass-to-dirt edges, corners, insets and eroded shoulders |
| 3 | `(0..15, 3)` | Grass-to-mud edges, corners, ruts and puddled shoulders |
| 4 | `(0..15, 4)` | Grass-to-stone edges, corners, broken slabs and moss seams |
| 5 | `(0..15, 5)` | Earthen path straights, bends, T-junctions, crossroad and ends |
| 6 | `(0..15, 6)` | Cemetery/plaza paving, cracked stone, grave aisles and detail overlays |
| 7 | `(0..15, 7)` | Water fills, shoreline edges/corners, reeds and damp-bank details |

The committed atlas is the production asset. Generated concept material may guide it, but it is not accepted directly: final cells require pixel cleanup, grid inspection, palette reduction, binary alpha, seam inspection, and an exact content baseline in tests. No generator or authoring script is committed or invoked by the game.

The final scene also uses four static companion sheets. `cemetery_ground_hand_authored_32.png` is a continuous 1600x1024 pixel-cleaned ground painting, mapped one 32x32 region per map cell to eliminate repeated stamp fields. `cemetery_paths_hand_authored_32.png` is a transparent 16-cell bitmask strip containing an isolated patch, four ends, two straights, four corners, four T-junctions, and one crossroad. `cemetery_graves_hand_authored_48.png` provides sixteen distinct grave and memorial silhouettes. `cemetery_workshop_props_hand_authored_64.png` provides a workbench, storage chest, bed, and preparation table in a fixed 2x2 sheet. These are committed raster assets with hard alpha; none is constructed at runtime.

## Godot resource contract

Create `art/environment/cemetery/production/data/cemetery_terrain_hand_authored.tres` as a static `TileSet` resource using the terrain atlas as source 0, continuous ground as source 1, and transparent path strip as source 2, all with nearest filtering and 32x32 regions. `ground`, `paths`, and `decoration_low` reference this resource directly from `cemetery_map.tscn`.

`CemeteryTerrainTileset.build()` and its runtime atlas construction are removed. The scene does not need code to discover or create terrain tiles.

## Authored map composition

The existing rebuilt 1600x1024 gameplay footprint and collision/navigation/interactions remain authoritative. Only its visual terrain and dressing presentation is replaced.

- `ground`: complete static coverage, composed in large irregular material clusters. The workshop uses packed earth/mud wear, the cemetery uses tired grass/moss/stone seams, and the forest uses deeper grass/rocky variation.
- `paths`: all routes are baked TileMap cells using path family row 5 and transition cells. Main, village, cemetery, workshop, and grave-aisle routes must be readable without vector underlays.
- `decoration_low`: sparse static overlays from rows 6 and 7, placed deliberately near path shoulders, graves, workshop wear, damp pockets, and forest edges.
- `objects_y_sorted` and `foreground_occlusion`: retain functional props and depth, but visual nodes created at runtime are baked into the scene with stable ownership and pivots.
- Water is represented in the atlas even if the accepted cemetery layout only uses a small damp pool or drainage pocket; it must not obstruct the required route cells.

The scene removes the nodes `AuthoredVisualDressing`, `CommercialCompositionPass`, and `CommercialFinishPass`. The scripts `cemetery_visual_dressing.gd`, `cemetery_commercial_composition.gd`, `cemetery_commercial_finish.gd`, and `cemetery_terrain_tileset.gd` are deleted after their useful authored placements have been baked or replaced. No visible `Line2D` or placeholder `Polygon2D` remains in the production map.

## Gameplay invariants

The change must preserve:

- world size `1600x1024`;
- tile size `32x32`;
- required `TileMapLayer` names;
- current collision cells and navigation region;
- Player, Aldren, exit, and expansion markers;
- Workbench, StorageChest, SleepSpot, CorpseDelivery, PreparationTable, GravePlot, and GraveUpgrade positions;
- all required traversable route cells;
- harvestable forest resources and zoning boundaries.

No PLAYER files are modified.

## Verification

Automated checks must establish:

1. the new atlas is exactly 512x256, contains 128 non-empty 32x32 tiles, uses binary alpha, and matches its approved SHA-256 baseline;
2. terrain families differ at pixel level and no atlas row is a repeated copy of another row;
3. all visual terrain layers reference the static `.tres` resource;
4. the three runtime visual-pass nodes, their scripts, `CemeteryTerrainTileset`, and visible `Line2D` paths are absent;
5. ground/path material variety and required route cells remain present;
6. collision, navigation, interactions, markers, world bounds, smoke launch, lint, and formatting remain green.

Visual acceptance requires fresh real-gameplay captures at 1280x720 for day, night, overview, workshop, cemetery graves, plaza, and forest path. Review must explicitly reject visible grid bands, repeated stamp fields, smooth vector roads, broken transitions, weak landmarks, or unreadable routes. At least one critique/revision cycle is required before calling the pass ready.

## Non-goals

- Redesigning gameplay geometry, collisions, navigation, interactions, or zones.
- Editing the PLAYER implementation.
- Rebuilding buildings, character sprites, UI, or the village map.
- Adding a runtime terrain generator, random decorator, shader-based noise, or procedural autotiling system.
