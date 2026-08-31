# Cemetery Visual Slice Design

## Goal

Replace the provisional cemetery presentation with an original, production-quality first zone whose density, readability, and finish are comparable to the images in `docs/art_example`, without copying their layouts, assets, characters, interface, or distinctive designs. The cemetery and workshop become the visual standard and reusable foundation for later zones.

## Scope

This slice includes the complete exterior cemetery, the gravekeeper workshop exterior, terrain, paths, boundaries, grave fields, preparation area, vegetation, props, localized light, atmosphere, and the player and Brother Aldren as seen in this zone. Gameplay services, save data, economy, quests, dialogue, and non-cemetery zones remain functionally unchanged.

All seven existing cemetery interactions remain available:

- workshop workbench, storage chest, and sleep spot;
- corpse delivery, preparation table, grave plot, and grave upgrade.

The player spawn, Aldren spawn, forest exit, village exit, and future expansion marker remain present and reachable, although their coordinates may change with the new composition.

## Visual Direction

The approved concept uses a compact top-down 3/4 cemetery organized around a warm workshop anchor, a readable main gate, organic grave clusters, a separate preparation corner, broken masonry and iron boundaries, and a wooded misty perimeter. The cemetery is cool, damp, worn, and melancholic; amber windows and lanterns identify important locations.

The source palette remains the named palette in `ART_DIRECTION.md`. Light arrives from the upper left and shadows fall down-right. Pixel edges remain crisp with nearest filtering. The reference images establish the quality bar only; all production assets and composition must be original.

## World Composition

The map is authored as five connected sectors:

1. **South gate and approach:** a strong entrance silhouette, clear transition route, and visual reveal into the grounds.
2. **Southwest workshop yard:** workshop, workbench, storage, sleeping interaction, material clutter, and warm localized light.
3. **Central grave fields:** irregular groups with readable walking aisles, mixed grave states, and visible restoration contrast.
4. **Northeast preparation yard:** corpse delivery and preparation functions gathered into a visually distinct service area.
5. **Perimeter:** broken walls, iron fencing, trees, shrubs, and mist that frame the playable area without hiding required routes.

Primary routes use continuous value and material contrast. Secondary routes may be worn or partially overgrown. Decorative density increases away from interaction radii and navigation corridors.

## Modular Art Kit

The provisional SVG atlas is replaced for this zone by original raster pixel-art resources organized under `art/environment/cemetery/production/`. Source assets use PNG with lossless import and nearest filtering.

The kit contains:

- `tileset_cemetery_ground_32.png` and `tileset_cemetery_paths_32.png` as 1024×1024 atlases with 32 px cells, multiple base variants, and edge/transition families;
- `tileset_cemetery_decals_32.png` as a 512×512 atlas with 32 px cells for non-colliding low decoration;
- `props_cemetery_64.png` as a 1024×1024 modular prop atlas and, only where native canvas requires it, `props_cemetery_128.png` as a 2048×2048 large-object atlas;
- path surfaces, corners, junctions, worn overlays, moss, cracks, leaves, stone chips, and dead grass;
- modular wall, pillar, gate, and iron-fence pieces aligned to 32 px modules;
- grave bases and markers in fresh, worn, damaged, and restored states;
- vegetation in low decoration, Y-sorted object, and foreground-occlusion variants;
- workshop exterior, preparation shelter, furniture, containers, tools, and narrative clutter;
- reusable shadow and localized-light presentation resources.

Large objects have a ground-contact pivot. When an object can cover the player, its base and upper occlusion are separate presentation layers. Visible canvas size never determines collision size.

`cemetery_visual_spec.gd` and `data/cemetery_art_catalog.tres` provide stable asset IDs plus atlas region, `pivot_px`, `footprint_px`, layer role, and variant metadata. Pivots and footprints align to 8 px. Complex interactables are reusable scenes under `art/environment/cemetery/scenes/`. The current SVG resources remain available to zones that have not migrated, but the cemetery production scene does not use them as a visual fallback.

## Scene and Code Boundaries

`world/maps/cemetery/cemetery_map.gd` owns deterministic cemetery layout population and exposes the existing map contract. Generic `TechnicalMap` remains available to other zones and does not accumulate cemetery-specific composition rules.

`world/maps/map_art_tileset.gd` continues to provide shared tile-set construction but gains a way to build the cemetery production atlas without changing the atlas contract used by other maps. Cemetery-specific asset paths and placement metadata live beside the cemetery map rather than in the generic presenter.

`world/maps/cemetery/cemetery_map.tscn` owns named gameplay nodes, markers, collision/nav helpers, and scene-authored anchors. Presentation code may replace placeholder visuals but must not own cemetery state or gameplay rules.

The playable bounds remain `50×32` logical tiles (`1600×1024 px`). Navigation bounds must use the same rectangle rather than the current mismatched `1600×1000` fallback. Internal grave, wall, tree, and building footprints must be reflected in navigation so NPC paths cannot cross visual obstacles.

## Runtime Data Flow

On zone load, the cemetery map builds its approved TileSet, configures the six established render layers, and populates the deterministic authored layout. Scene anchors then attach large sprites and gameplay interaction scenes. The zone manager places the player and NPCs using named markers. Existing controllers discover the same named interactions as before.

Missing optional decoration must fail soft by omitting that decoration. Missing required atlases, gameplay nodes, layers, or markers must be surfaced by automated tests and Godot resource-load errors; the map must not silently fall back to colored placeholder polygons.

## Characters and Camera

The slice uses native 64×96 frames for the player and Brother Aldren, with feet-based pivots and collision/navigation independent of visible canvas size. Movement direction contracts stay compatible with the existing eight-direction presenter. The initial gameplay proof retains the 1280×720 capture size and tests 1.25× and 1.5× camera zoom, selecting the most readable result without changing logical tile size.

## Atmosphere and Lighting

The existing day/night controller remains the only temporal authority. Cemetery presentation adds restrained mist, ambient motes, cool environmental modulation, soft ground shadows, and warm light around the workshop and preparation area. Effects must preserve route and interaction readability at day and night and remain compatible with the GL Compatibility renderer.

## Testing and Acceptance

Automated tests verify:

- all six render layers use 32 px logical tiles and load the approved cemetery raster atlas;
- every catalog atlas dimension and region is a multiple of 32 px, every pivot/footprint is a multiple of 8 px, and catalog regions do not overlap;
- required gameplay nodes and markers exist, are inside map bounds, do not occupy collision cells, and remain navigation-reachable;
- the production map contains meaningful variation across terrain, path, decoration, Y-sorted object, and foreground layers;
- visible production nodes do not use fallback `Polygon2D` placeholders;
- large objects use documented ground pivots and occlusion separation;
- navigation bounds equal `1600×1024 px` and representative routes connect the two zone exits, workshop, central field, preparation yard, player spawn, and Aldren spawn;
- cemetery gameplay, persistence, zone transitions, NPC navigation, and the complete headless suite remain green.

The visual capture manifest adds representative views of the gate, central grave field, workshop yard, preparation yard, and a player/prop Y-sort crossing during day and night at 1280×720. Human acceptance compares those captures with `docs/art_example` for density, hierarchy, material readability, character integration, lighting, and perceived finish. Each capture set records the source commit in `capture_metadata.json`. Automated green status alone cannot approve visual quality.

## Implementation Order and Parallel Boundaries

1. Establish contracts and failing structural tests.
2. Build the raster terrain/transition kit and cemetery TileSet interface.
3. Build independent prop/building/vegetation families and their typed visual catalog.
4. Compose the cemetery scene and adapt collisions, navigation, interactions, and markers.
5. Integrate character scale, atmosphere, capture views, and run perceptual review.

Asset-family production and structural test work may run in parallel because they touch separate files. TileSet integration precedes final map composition. Final scene integration and full-suite verification are serialized to avoid conflicts in shared scene and map code.

## Out of Scope

- Reworking forest, village, mine, interiors, or UI in this delivery.
- Changing cemetery simulation rules, save formats, economy, quests, or dialogue.
- Copying or tracing any protected reference content.
- Treating the generated concept sketch as a shippable game asset.
