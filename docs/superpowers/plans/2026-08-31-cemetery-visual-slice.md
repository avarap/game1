# Cemetery Visual Slice Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver a production-quality, original cemetery/workshop exterior as the first visual slice and reusable art foundation for later zones.

**Architecture:** A cemetery-only raster atlas stack and typed art catalog feed a dedicated `CemeteryMap` compositor while the generic map stack remains compatible with unmigrated zones. Named gameplay nodes, six render layers, 32 px logical tiles, 1600×1024 bounds, persistence, and zone transitions remain stable; deterministic captures provide visual evidence.

**Tech Stack:** Godot 4.7.2, GDScript, TileMapLayer/TileSetAtlasSource, PNG raster assets, GL Compatibility renderer, headless GDScript test runner.

**Spec:** `docs/superpowers/specs/2026-08-31-cemetery-visual-slice-design.md`

## Global Constraints

- References in `docs/art_example` define quality only; do not copy layouts, assets, characters, UI, palette, or distinctive designs.
- Keep 32×32 logical tiles, nearest filtering, integer or 8 px-aligned pivots, feet/base Y-sort, and 1280×720 capture output.
- Keep nodes `ground`, `paths`, `decoration_low`, `collision`, `objects_y_sorted`, and `foreground_occlusion`.
- Keep the seven interaction paths and five marker names specified in the design.
- Keep gameplay state in the persistent world controller; presentation code owns no cemetery rules or save data.
- Cemetery bounds and navigation bounds are exactly 1600×1024 px.
- Missing required production art is an error; the cemetery must not silently show colored polygon placeholders.
- Other zones continue to load with the existing exterior atlas until migrated separately.

---

### Task 1: Lock the production-art and map contracts with tests

**Files:**
- Create: `tests/test_cemetery_visual_slice.gd`
- Modify: `tests/run_tests.gd`
- Modify: `tests/test_cemetery_map.gd`

**Interfaces:**
- Consumes: current cemetery scene and six-layer contract.
- Produces: `TestCemeteryVisualSlice.run() -> Array[String]`, the acceptance contract for Tasks 2–5.

- [ ] **Step 1: Write the failing visual-slice test**

Create a test that asserts the future production resources, exact bounds, density, paths, catalog, and no visible placeholder polygons:

```gdscript
class_name TestCemeteryVisualSlice
extends RefCounted

const MAP_PATH := "res://world/maps/cemetery/cemetery_map.tscn"
const CATALOG_PATH := "res://art/environment/cemetery/production/data/cemetery_art_catalog.tres"
const EXPECTED_RECT := Rect2(Vector2.ZERO, Vector2(1600, 1024))

static func run() -> Array[String]:
	var failures: Array[String] = []
	if not ResourceLoader.exists(CATALOG_PATH):
		failures.append("Cemetery production art catalog should exist")
	var scene := load(MAP_PATH) as PackedScene
	var map := scene.instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(map)
	if map.get_world_rect() != EXPECTED_RECT:
		failures.append("Cemetery world bounds should be 1600x1024")
	for layer_name in ["ground", "paths", "decoration_low", "objects_y_sorted", "foreground_occlusion"]:
		var layer := map.get_node_or_null(layer_name) as TileMapLayer
		if layer == null or layer.get_used_cells().is_empty():
			failures.append("Production layer should be populated: %s" % layer_name)
	for polygon in map.find_children("*", "Polygon2D", true, false):
		if (polygon as Polygon2D).visible:
			failures.append("Production cemetery should not expose placeholder Polygon2D")
	map.free()
	return failures
```

- [ ] **Step 2: Register and run the RED test**

Add `_run_suite("CemeteryVisualSlice", TestCemeteryVisualSlice.run(), failures)` after `CemeteryMap`. Run:

```powershell
godot --headless --path . --script res://tests/run_tests.gd
```

Expected: `CemeteryVisualSlice` fails because the catalog and production composition do not exist.

- [ ] **Step 3: Strengthen navigation assertions**

In `test_cemetery_map.gd`, assert `get_world_rect().size == Vector2(1600, 1024)` and that navigation vertices stay within that rectangle. Preserve every existing assertion.

- [ ] **Step 4: Run formatting/static checks**

Run `gdformat --check tests/test_cemetery_visual_slice.gd tests/test_cemetery_map.gd tests/run_tests.gd` and `gdlint` on those files. Expected: clean, with only the deliberate RED runtime assertions failing.

- [ ] **Step 5: Commit**

```powershell
git add tests/test_cemetery_visual_slice.gd tests/test_cemetery_map.gd tests/run_tests.gd
git commit -m "test: define cemetery visual slice contract"
```

### Task 2: Add raster atlas sources and typed art catalog

**Files:**
- Create: `art/environment/cemetery/production/atlas/tileset_cemetery_ground_32.png`
- Create: `art/environment/cemetery/production/atlas/tileset_cemetery_paths_32.png`
- Create: `art/environment/cemetery/production/atlas/tileset_cemetery_decals_32.png`
- Create: `art/environment/cemetery/production/atlas/props_cemetery_64.png`
- Create: `art/environment/cemetery/production/cemetery_visual_spec.gd`
- Create: `art/environment/cemetery/production/data/cemetery_art_catalog.tres`
- Create: `world/maps/cemetery/cemetery_art_tileset.gd`
- Create: `tests/test_cemetery_art_catalog.gd`
- Modify: `tests/run_tests.gd`

**Interfaces:**
- Produces: `CemeteryVisualSpec` resources with `id`, `texture`, `region`, `pivot_px`, `footprint_px`, and `layer_role`; `CemeteryArtTileset.build() -> TileSet` with sources 0–3 and 32 px tiles.
- Consumes: palette, scale, originality, and pivot rules from the spec.

- [ ] **Step 1: Write catalog validation tests**

Assert that every texture loads, atlas dimensions and regions are divisible by 32, pivots/footprints are divisible by 8, IDs are unique, regions do not overlap within a texture, and layer roles are one of `low`, `y_sorted`, `foreground`.

- [ ] **Step 2: Run the catalog test RED**

Register `CemeteryArtCatalog` in `run_tests.gd` and run the suite. Expected: missing script/resource/assets.

- [ ] **Step 3: Produce the original raster atlas family**

Create crisp, non-antialiased PNG atlases using the approved palette and original designs. Ground and path atlases are 1024×1024; decals are 512×512; props are 1024×1024. Include at least four ground variants, complete path edges/corners/junctions, six low-decoration families, five grave-marker families, three plot states, walls, gate, iron fence, preparation furniture, delivery cart, stones, and vegetation. Use no text, logos, copied silhouettes, or elements lifted from reference screenshots.

- [ ] **Step 4: Implement typed metadata and TileSet builder**

Use an exported Resource contract:

```gdscript
class_name CemeteryVisualSpec
extends Resource

@export var id: StringName
@export var texture: Texture2D
@export var region := Rect2i()
@export var pivot_px := Vector2i()
@export var footprint_px := Vector2i()
@export_enum("low", "y_sorted", "foreground") var layer_role := "y_sorted"
```

`CemeteryArtTileset.build()` creates visual atlas sources without physics; collision stays on the technical source/layer.

- [ ] **Step 5: Run tests and import validation**

Run `godot --headless --path . --editor --quit`, then the complete test suite. Expected: catalog tests pass; Task 1 remains RED only on missing map population.

- [ ] **Step 6: Commit**

```powershell
git add art/environment/cemetery/production world/maps/cemetery/cemetery_art_tileset.gd tests/test_cemetery_art_catalog.gd tests/run_tests.gd
git commit -m "feat: add modular cemetery raster art kit"
```

### Task 3: Build reusable cemetery prop scenes

**Files:**
- Create: `art/environment/cemetery/production/cemetery_art_catalog.gd`
- Create: `art/environment/cemetery/production/cemetery_prop_visual.gd`
- Create: `art/environment/cemetery/production/scenes/cemetery_prop_visual.tscn`
- Create: `art/environment/cemetery/production/scenes/workshop_exterior.tscn`
- Create: `art/environment/cemetery/production/scenes/preparation_shelter.tscn`
- Create: `tests/test_cemetery_prop_visuals.gd`
- Modify: `tests/run_tests.gd`

**Interfaces:**
- Consumes: stable catalog IDs from Task 2.
- Produces: `CemeteryArtCatalog.get_spec(id: StringName) -> CemeteryVisualSpec` and `CemeteryPropVisual.configure(id: StringName) -> void`.

- [ ] **Step 1: Write failing scene/pivot tests**

Test a grave, tree, gate, workshop, and preparation shelter. Each must configure a non-null texture, set `Sprite2D.centered = false`, position the base sprite at `-Vector2(spec.pivot_px)`, and put upper occlusion under a `foreground` child when specified.

- [ ] **Step 2: Run tests RED**

Run the complete suite. Expected: missing catalog loader and reusable scenes.

- [ ] **Step 3: Implement catalog lookup and generic prop visual**

Load the `.tres` catalog once per scene instance, reject unknown required IDs with `push_error`, and never substitute a colored polygon. Keep collision out of the visual scene.

- [ ] **Step 4: Compose workshop and preparation scenes**

Use the prop atlas, base/foreground separation, warm light nodes, and base-contact pivots. Keep interactive `Area2D` nodes in the map scene, not inside these visuals.

- [ ] **Step 5: Run tests and scene-load smoke**

Run import, full tests, and `godot --headless --path . --quit-after 3`. Expected: all Task 2/3 tests pass.

- [ ] **Step 6: Commit**

```powershell
git add art/environment/cemetery/production tests/test_cemetery_prop_visuals.gd tests/run_tests.gd
git commit -m "feat: add reusable cemetery prop visuals"
```

### Task 4: Compose the cemetery zone and navigation

**Files:**
- Create: `world/maps/cemetery/cemetery_map.gd`
- Modify: `world/maps/cemetery/cemetery_map.tscn`
- Modify: `world/navigation/world_navigation_region.gd`
- Modify: `tests/test_cemetery_visual_slice.gd`
- Modify: `tests/test_cemetery_map.gd`
- Modify: `tests/test_world_zone_integration.gd`

**Interfaces:**
- Consumes: `CemeteryArtTileset.build()`, catalog IDs, and reusable scenes from Tasks 2–3.
- Produces: deterministic five-sector composition, exact 1600×1024 bounds, obstacle-aware navigation, unchanged named gameplay contract.

- [ ] **Step 1: Extend RED tests for route and sector coverage**

Assert at least three ground variants in representative 6×6 regions, populated paths/decor/objects/foreground, and navigation connectivity between player spawn, Aldren spawn, workshop, preparation area, ForestExit, and VillageExit.

- [ ] **Step 2: Run focused tests RED**

Run the full suite and confirm failures are specific to production composition/navigation.

- [ ] **Step 3: Implement the dedicated compositor**

`CemeteryMap` extends `TechnicalMap`, overrides cemetery-ready composition, and authors the south gate, southwest workshop, central grave fields, northeast preparation yard, and wooded perimeter. Use deterministic coordinate arrays/data tables; keep clear interaction radii and continuous primary routes.

- [ ] **Step 4: Replace presentation anchors without changing gameplay actions**

Attach production scenes to `BuildingVisualAnchor` and preparation anchors; remove or hide placeholder `Visual` polygons. Preserve exact node paths, action enums, collision layers/masks, and controller discovery.

- [ ] **Step 5: Align collision and navigation**

Generate collision footprints for walls, graves, trees, and buildings while leaving routes and markers clear. Build navigation from the 1600×1024 bounds with obstacle outlines or equivalent baked traversable polygons; do not leave the current 1600×1000 rectangle.

- [ ] **Step 6: Run complete validation**

Run import, main-scene smoke, and the full suite. Expected: `CemeteryVisualSlice`, `CemeteryMap`, `CemeteryGameplay`, NPC navigation, and world zone integration pass.

- [ ] **Step 7: Commit**

```powershell
git add world/maps/cemetery world/navigation/world_navigation_region.gd tests
git commit -m "feat: compose production cemetery visual slice"
```

### Task 5: Integrate atmosphere and deterministic visual evidence

**Files:**
- Create: `world/maps/cemetery/cemetery_atmosphere.gd`
- Create: `world/maps/cemetery/cemetery_atmosphere.tscn`
- Modify: `world/maps/cemetery/cemetery_map.tscn`
- Modify: `tools/visual_capture/capture_manifest.gd`
- Modify: `tests/test_visual_capture.gd`
- Modify: `tests/test_world_atmosphere.gd`
- Create: `docs/visual/cemetery_slice/README.md`

**Interfaces:**
- Consumes: completed cemetery scene and existing day/night authority.
- Produces: presentation-only mist/motes/local lights plus capture IDs `cemetery_gate`, `cemetery_grave_field`, `cemetery_preparation`, and `cemetery_y_sort_crossing` in addition to existing captures.

- [ ] **Step 1: Write failing atmosphere/capture assertions**

Assert new capture IDs, 1280×720 output, approved camera zoom, cemetery context, and an atmosphere node that contains no independent clock/timer authority.

- [ ] **Step 2: Run tests RED**

Expected: new scene and manifest IDs missing.

- [ ] **Step 3: Add restrained atmosphere**

Implement cool modulation inputs, low-density mist/motes, and warm localized lights driven by existing day/night state. Effects must use the GL Compatibility renderer and remain presentation-only.

- [ ] **Step 4: Add deterministic capture views and instructions**

Set stable camera positions for gate, field, workshop, preparation, and Y-sort crossing. Document exact commands and human comparison criteria against `docs/art_example`; require `capture_metadata.json` with commit SHA.

- [ ] **Step 5: Run all available verification**

Run:

```powershell
godot --headless --path . --editor --quit
godot --headless --path . --quit-after 3
godot --headless --path . --script res://tests/run_tests.gd
```

When Bash and Godot 4.7.2 are available, run `bash tools/visual_capture/run_capture.sh` and inspect every cemetery image for routes, pivots, Y-sort, character scale, day/night legibility, originality, and finish.

- [ ] **Step 6: Commit**

```powershell
git add world/maps/cemetery tools/visual_capture tests docs/visual/cemetery_slice
git commit -m "feat: add cemetery atmosphere and visual evidence"
```

### Task 6: Final integration and acceptance review

**Files:**
- Modify only files required by verified integration findings.

**Interfaces:**
- Consumes: Tasks 1–5.
- Produces: a clean full-suite result and a reviewed visual evidence set.

- [ ] **Step 1: Run formatting and lint globally**

Run `gdformat --check .` and `gdlint .`; fix only findings caused by this plan.

- [ ] **Step 2: Run Godot verification**

Run import, smoke, and full headless suite with Godot 4.7.2. Record exact commands and results.

- [ ] **Step 3: Review visual captures**

Compare day/night and sector captures with `docs/art_example` for density, hierarchy, material separation, route clarity, character integration, lighting, and perceived finish. Reject visible repetition, placeholder geometry, blur, floating pivots, unreadable interactions, or copied reference content.

- [ ] **Step 4: Commit integration fixes**

```powershell
git add world/maps/cemetery tools/visual_capture/capture_manifest.gd tests/test_cemetery_visual_slice.gd tests/test_cemetery_map.gd tests/test_visual_capture.gd tests/test_world_atmosphere.gd
git commit -m "fix: complete cemetery visual slice acceptance"
```
