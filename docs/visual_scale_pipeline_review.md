# Visual Scale & Pipeline Review — Issue #94

Status: architecture recommendation for supervisor review. This does not migrate production assets.

## Baseline inspected

- `main`: `0a16c3e53a0691227d6e73ae38c3cbb056f3a822` (CI green before branch creation).
- Runtime reference: 1280×720 canvas, `canvas_items` stretch, nearest texture filtering.
- Current `ART_DIRECTION.md`: 32×32 logical tiles, 32×48 recommended human frames, 20×28 player collision footprint, 1.5× camera reference.
- Current player atlas: `art/characters/player/player_idle_walk.svg`, 5×8 atlas at 32×48 per frame. All eight rows reuse essentially the same body construction; direction differences are only tiny cue rectangles. This cannot satisfy the approved requirement for materially distinct, readable 8-direction silhouettes.
- Approved perceptual benchmark: screenshots under `docs/Screenshot_2026-08-31-*.jpg`.

## Finding

The bottleneck is not Godot, navigation or the collision footprint. It is the **visual pixel budget and asset construction**. A 32×48 frame leaves too little room for the requested readable clothing/equipment, face/hair, material separation, directional foreshortening and local lighting while keeping a strong 3/4 silhouette. The current atlas confirms the failure mode: directions collapse into one generic body.

The gameplay footprint must be decoupled from the visible canvas. A larger sprite may keep the same foot pivot and approximately the same collision footprint; tall hats, coats, tools and upper-body volume should not enlarge collision automatically.

## Options evaluated

### A — Keep 32×48

Pros: zero migration cost; smallest atlas memory.

Cons: insufficient pixel budget for the approved bar; diagonal/cardinal distinction becomes cue-based rather than silhouette-based; equipment/material detail competes for the same few pixels. Rejected as production target.

### B — 48×72 characters; 48 px visual module

Pros: 2.25× the pixels per frame versus 32×48; moderate atlas growth; enough room for more directional anatomy and clothing.

Cons: still tight for a highly detailed protagonist at 1280×720; buildings/props produced on a 32 px visual module continue to look comparatively toy-like unless their artwork is enlarged independently. Acceptable for secondary NPCs, not preferred as the global hero baseline.

### C — 64×96 characters; 64 px visual art module over existing logical world grid

Pros: 4× the pixels per frame; materially better room for face/hair, coat folds, belt/tool silhouettes, directional foreshortening, rim/highlight clusters and readable shadows. Buildings, trees and hero props can use 64 px visual modules while **logical navigation/markers may remain on the existing coordinate grid** during migration. This offers the cleanest route to the `docs/` quality bar without rewriting gameplay.

Cons: 4× character texture area and larger source atlases. Requires audit of sprite regions, animation resources and camera composition.

**Recommendation: Option C.**

## Recommended contract

### Characters

- Hero/player and important NPC frame canvas: **64×96 px**.
- Secondary/simple NPCs may use **48×72** only when visual review proves parity at gameplay zoom.
- Eight directions must be genuine drawings/constructions. Mirroring is allowed only for symmetric designs; asymmetric gear must remain physically consistent.
- Pivot remains center of feet.
- Collision remains gameplay-defined and initially unchanged (current ~20×28 reference) unless collision testing demonstrates a real need. Visible canvas and collision are separate contracts.
- Walk target: 6 frames/direction; idle at least 2 subtle frames/direction for hero/important NPCs after the baseline migration.

### World / tiles / buildings / props

Do **not** globally rescale gameplay coordinates as the first migration step.

- Preserve the existing logical grid/markers/navigation initially.
- Move the *visual authoring module* for production hero environment art toward **64 px per current 32 px logical cell** where extra detail is needed, then present at an appropriate scale/camera so physical footprints remain stable.
- Buildings should use larger native canvases and layered roofs/foreground, not upscaled low-detail 32 px art.
- Trees/large props should routinely exceed one logical cell visually; their collision remains anchored to the trunk/base footprint.
- Ground/path tiles may remain 32 logical cells while textures are authored with richer 64 px source density if the TileSet/import strategy supports it cleanly. If that introduces sampling complexity, migrate TileSet art families one zone at a time rather than changing navigation coordinates globally.

### Camera

- Keep 1280×720 as the validation viewport.
- Nearest filtering and integer-aligned pixel presentation remain mandatory.
- Do not hard-lock 1.5× zoom. Re-evaluate gameplay zoom after 64×96 integration; target framing should preserve roughly the same *world awareness* while making the hero readable.
- Candidate zooms for the first showcase: 1.0×, 1.25× and 1.5×, with pixel-stability checked in Godot. Prefer the closest stable value that shows the hero and environment at the `docs/` perceived scale without excessive cropping.

## Memory / atlas impact

Raw RGBA frame area (before compression):

| Frame | Pixels | Relative to 32×48 | RGBA bytes/frame |
|---|---:|---:|---:|
| 32×48 | 1,536 | 1.00× | 6,144 |
| 48×72 | 3,456 | 2.25× | 13,824 |
| 64×96 | 6,144 | 4.00× | 24,576 |

For 8 directions × 6 walk frames, 64×96 is ~1.125 MiB raw RGBA per walk set before engine/import compression. This is modest for the vertical slice and is a reasonable trade for visual readability.

## Animation / atlas impact

- Existing atlas region assumptions based on 32×48 must be replaced by data-driven frame sizes per character sheet.
- Do not scale the current 32×48 SVG up; redraw/re-author at native target resolution.
- Keep nearest filtering and avoid fractional Sprite2D scale values on final assets.
- AnimationTree/state logic should remain behaviorally unchanged; only texture regions/frame resources should migrate.

## Pivot / collision / navigation impact

- Feet pivot remains the stable Y-sort anchor.
- Larger upper-body/roof/tree art may overlap more screen space; use foreground layers/occlusion rather than enlarging collision to match the picture.
- Navigation polygons and markers should not be rescaled automatically. Validate doors, narrow passages and interaction reach after each migrated environment slice.
- A visual building can become much larger while retaining the same logical doorway/footprint if the composition is designed around that anchor.

## Incremental migration plan

1. **Hero benchmark:** redraw player at 64×96 with eight genuinely distinct directions; integrate only a showcase/test scene first.
2. **Key NPC benchmark:** Brother Aldren at the same body scale, preserving existing spawn/navigation/persistence contracts.
3. **Cemetery hero slice:** rebuild one representative house/workshop façade, 3–5 gravestone/prop families and vegetation at the new visual density while keeping logical anchors.
4. **Camera lock:** compare 1.0/1.25/1.5 framing in the reproducible QA capture flow from #96 and select the stable gameplay zoom.
5. **Tile family migration:** migrate cemetery ground/path/edge families only after character/building composition is validated; do not change every map simultaneously.
6. **Remaining world/UI polish:** expand production only after supervisor visual acceptance against `docs/`.

Each step must preserve Godot 4.7.2 import, smoke, navigation/transitions and the full relevant suite.

## Acceptance consequence

The current 32×48 player atlas and similarly sparse environment assets should be treated as **functional placeholders**, not final art. Passing CI does not make them visually acceptable. Future CHARACTERS/WORLD/POLISH issues should use 64×96 / high-density native art as the default starting point unless a side-by-side in-game comparison proves a smaller asset genuinely meets the benchmark.

## Evidence included

`docs/visual_scale_comparison.svg` provides a deterministic visual-scale sheet at the real 1280×720 validation canvas showing the baseline 32×48 envelope versus 48×72 and 64×96 envelopes alongside proportional building/prop density. It is an architecture benchmark, not production art. Final perceptual approval must use #96 in-game capture against the screenshots in `docs/`.