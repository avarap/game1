# Main Map Rebuild — Design

Date: 2026-09-02
Status: approved by default per project direction
Scope: main cemetery map only

## Goal

Replace the current cemetery layout with a new production-quality main map built from scratch. The old map layout, distribution patterns, navigation shape, interaction placement, and composition are not design inputs. Existing technical contracts may be retained only when they remain useful: Godot 4.7.2, 32 px logical tiles, the six map layers, existing gameplay interaction node types, world transition markers, and production assets that meet the art bar.

The result must be immediately playable with the real player controller and must support the vertical-slice cemetery loop without blocking routes or interactions.

## Success criteria

- New composition is visually distinct from the previous cemetery map.
- Main routes are readable at gameplay zoom and do not rely on debug labels.
- Player can travel from spawn to workshop, cemetery work area, forest exit, and village exit.
- Every required cemetery interaction remains accessible.
- Large scenery has collision matching its physical footprint.
- Tall scenery participates in Y-sort or foreground occlusion correctly.
- Collision never covers required spawn, exit, or interaction approach cells.
- Map remains within 1600x1024 world bounds for compatibility with current shell/camera assumptions.
- Navigation polygon exists after map initialization.
- Existing gameplay systems remain owned by the world shell; the map does not duplicate persistent cemetery state.
- Relevant headless tests, gdlint, gdformat check, and project import remain clean.
- A 1280x720 in-game capture is required before visual acceptance.

## Spatial composition

The new cemetery is organized as a dense hub rather than a uniform grid.

### 1. Workshop refuge — south-west

The player begins near the workshop in a sheltered clearing. The workshop sits against the western/southern vegetation edge, with a readable apron in front of its entrance. Workbench, chest, and sleep spot form a compact triangle around the entrance instead of a straight row.

Purpose: home anchor, recovery, storage, crafting, visual warmth.

### 2. Processional spine — south-west to north-east

A broad dirt path leaves the workshop clearing and curves north-east through the center of the map. It is the primary navigation line and the first visual read after spawning.

Purpose: connect all major zones without making the map feel like a cross-shaped test layout.

### 3. Reception yard — central-east

Corpse delivery and preparation sit in a practical service yard beside the processional spine. The yard has enough clear floor for future delivery presentation and avoids mixing corpse logistics directly into decorative grave rows.

Purpose: operational readability and future funeral transport integration.

### 4. Operational cemetery — north-east / east-center

Active graves form small irregular clusters separated by narrow walking lanes. GravePlot and GraveUpgrade sit on the southern edge of this zone so the player approaches the cemetery rather than standing inside a regimented grid.

Purpose: support management gameplay while retaining an organic medieval layout.

### 5. Old cemetery — north-west / center-left

An older, denser area uses crooked grave clusters, stones, trees, and partial enclosure. It is visually richer but does not contain mandatory interactions. It creates atmosphere, depth, and contrast with the maintained operational section.

Purpose: world history and premium composition without introducing new gameplay scope.

### 6. Transition corridors

- VillageExit: northern edge, reached through a narrower processional continuation.
- ForestExit: eastern edge, reached through a greener side path.
- FutureExpansion: north-east beyond the operational cemetery, reserved with a clear approach.

Each exit gets a visually readable corridor of at least two logical tiles of practical clearance around the player path.

## Layer responsibilities

The map keeps the established visual contract:

- `ground`: terrain variants only.
- `paths`: authored path shapes and worn clearings.
- `decoration_low`: grass tufts, flowers, small stones, leaf clusters, stains.
- `collision`: invisible technical collision cells for perimeter and tile-scale blockers.
- `objects_y_sorted`: graves, trees, posts, larger props, and other scenery whose base defines depth.
- `foreground_occlusion`: only canopy/roof elements that should cover the player at specific depth relationships.

The new layout must not call the old `_populate_production_*` routines or reproduce their formulas.

## Layout data model

Composition is authored from explicit zone data instead of procedural arithmetic patterns.

`cemetery_map.gd` will define:

- named path cell arrays / authored path segments;
- named grave clusters;
- named tree/prop placements;
- reserved route cells;
- physical obstacle footprints;
- key approach zones for interactions and transitions.

Random generation is not used for gameplay-critical composition. If deterministic decorative scatter is retained, it may only place low decoration outside reserved cells and authored landmarks.

## Collision model

The inherited generic internal rectangle is unsuitable for the new map and must not be used.

Collision will be composed from:

1. perimeter barriers with intentional openings at world-transition corridors where required by the world shell;
2. workshop footprint;
3. tree trunk footprints;
4. major grave/monument footprints where their physical mass should block movement;
5. walls/fences or dense scenery only where they visually imply blocking.

Small grass, flowers, scattered stones, path edges, and purely decorative grave details remain non-blocking.

Required approach space around interactables is protected by reserved cells. Reserved cells can never receive scenery collision.

## Navigation

`WorldNavigationRegion` remains the navigation owner. The map must continue to expose `NavigationRegion` and world bounds compatible with the existing region builder. Collision and route tests are the primary guarantee for the player; navigation polygon availability remains a regression check for NPC compatibility.

## Interaction placement

Existing interaction node types and prompts are preserved, but their map positions change to fit the new composition.

Target placement intent:

- PlayerSpawn: workshop apron.
- Workbench: beside workshop exterior wall, reachable from apron.
- StorageChest: opposite side of workshop entrance, not in a row with Workbench.
- SleepSpot: sheltered close to workshop.
- CorpseDelivery: reception yard near east service route.
- PreparationTable: adjacent but with independent approach space.
- GravePlot: entry to operational cemetery.
- GraveUpgrade: nearby maintenance point, not overlapping GravePlot approach.
- AldrenSpawn: central processional path / cemetery threshold.
- VillageExit: north corridor.
- ForestExit: east corridor.
- FutureExpansion: north-east reserved approach.

Exact coordinates are implementation details and may be adjusted to preserve collision clearance and composition.

## Visual hierarchy

At 1280x720 and 1.5x zoom, the player should immediately read:

1. warm workshop anchor;
2. brighter/worn main path;
3. operational cemetery cluster;
4. darker old cemetery mass;
5. forest/village exit corridors.

Tall tree masses frame edges and corners rather than forming a uniform border. The center remains readable. Grave density increases away from the workshop and decreases around required routes.

## Atmosphere

Use the existing cemetery palette: dark soil, grey-green vegetation, cold stone, and limited warm accents around workshop/important interactions. Existing chimney smoke may remain. No second time-of-day system is introduced.

## Performance

- Prefer TileMapLayer cells for ground/path/low decoration.
- Keep Node2D/StaticBody2D object count focused on large interactive/occluding props.
- Avoid per-frame map generation.
- Build authored layout once during `_ready()`.
- Keep collision shapes simple rectangles where visually adequate.

## Testing strategy

Update `tests/test_cemetery_map.gd` so it validates the new design instead of preserving obsolete coordinates.

Add assertions for:

- required layers and 32 px tile size;
- 1600x1024 world bounds;
- required interactions and markers inside bounds;
- no required interaction/marker placed on collision;
- new positions differ from the obsolete map baseline where useful as a regression guard;
- main paths contain substantial authored coverage;
- reserved route cells are collision-free;
- representative large scenery cells/footprints are collidable;
- NavigationRegion produces a polygon;
- no `CemeteryController` is introduced into the map.

If the repository already has a movement harness suitable for the real player, add/extend a cemetery traversal test covering spawn -> workshop -> reception -> operational cemetery -> forest route -> village route. Otherwise add a deterministic route-clearance test at the map-cell level in this task and leave full input simulation to the integration harness.

## Files in scope

Primary:

- `world/maps/cemetery/cemetery_map.gd`
- `world/maps/cemetery/cemetery_map.tscn`
- `tests/test_cemetery_map.gd`

Optional only if required by tests or map-specific implementation:

- a new cemetery-local layout helper under `world/maps/cemetery/`
- a cemetery-specific traversal test under `tests/`
- visual capture output under the repository's existing capture location

Out of scope:

- player controller redesign;
- persistent cemetery-system logic;
- village/forest redesign;
- new quest systems;
- broad art-direction rewrite;
- reuse of old cemetery layout/composition.

## Acceptance

The implementation is acceptable only when the new map is visibly and structurally distinct, the main player routes are clear, required gameplay interactions are reachable, collision follows visible physical masses, navigation remains valid, automated checks pass, and a 1280x720 capture demonstrates the composition in-game.
