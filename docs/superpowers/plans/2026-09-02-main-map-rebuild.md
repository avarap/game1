# Main Map Rebuild Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current cemetery layout with a new authored, commercially readable main map whose real player routes, interactions, collision footprints, Y-sort layers, and exits are verifiably functional.

**Architecture:** Keep the existing cemetery scene contract and gameplay node types, but replace the old procedural composition with authored zone data in `cemetery_map.gd`. The map script owns visual cell placement, reserved routes, and map-specific tile collision; `cemetery_map.tscn` owns interaction/marker coordinates. Tests validate both topological route connectivity and real `PlayerController` movement/collision.

**Tech Stack:** Godot 4.7.2, GDScript, TileMapLayer, CharacterBody2D/PlayerController, NavigationRegion2D, headless Godot tests, gdlint, gdformat.

**Spec:** `docs/superpowers/specs/2026-09-02-main-map-rebuild-design.md`

## Global Constraints

- Do not work directly on `main`; use `feature/main-map-rebuild`.
- Do not reuse the old cemetery layout, distribution patterns, navigation shape, interaction placement, or composition.
- Preserve Godot 4.7.2, 1280x720 reference resolution, nearest filtering, orthographic 3/4 presentation, and 32x32 logical tiles.
- Preserve the six map layers: `ground`, `paths`, `decoration_low`, `collision`, `objects_y_sorted`, `foreground_occlusion`.
- Keep world bounds at 1600x1024 for shell/camera compatibility.
- Preserve existing gameplay node types/prompts and persistent-state ownership outside the map.
- Run gdlint, gdformat check, Godot import/validation, scene smoke, and headless tests before completion.
- Produce a 1280x720 in-game capture before claiming visual acceptance.

---

### Task 1: Lock the new map contract with failing tests

**Files:**
- Modify: `tests/test_cemetery_map.gd`

**Interfaces:**
- Consumes: existing `CemeteryMap.get_world_rect()`, six named TileMapLayer nodes, named interactions/markers.
- Produces: regression contract for new coordinates, route clearance, path density, obstacle collision, navigation, and obsolete-layout rejection.

- [ ] **Step 1: Replace obsolete fixed-position expectations with new authored positions**

Use this coordinate contract:

```gdscript
const EXPECTED_POSITIONS := {
    "WorkshopArea/Workbench": Vector2(288, 768),
    "WorkshopArea/StorageChest": Vector2(480, 768),
    "WorkshopArea/SleepSpot": Vector2(352, 832),
    "CemeteryArea/CorpseDelivery": Vector2(928, 608),
    "CemeteryArea/PreparationTable": Vector2(1024, 608),
    "CemeteryArea/GravePlot": Vector2(1152, 544),
    "CemeteryArea/GraveUpgrade": Vector2(1248, 544),
}

const EXPECTED_MARKERS := {
    "PlayerSpawn": Vector2(416, 800),
    "AldrenSpawn": Vector2(800, 544),
    "ForestExit": Vector2(1536, 704),
    "VillageExit": Vector2(800, 64),
    "FutureExpansion": Vector2(1376, 160),
}
```

Also keep the previous interaction coordinates in `OBSOLETE_POSITIONS` and fail if any required interaction remains at its obsolete coordinate.

- [ ] **Step 2: Add route-connectivity helpers**

Add a flood-fill that treats a tile as blocked when `collision.get_cell_source_id(cell) != -1` and verifies a four-neighbour route from `PlayerSpawn` to the cell containing each of:

```gdscript
[
    "WorkshopArea/Workbench",
    "WorkshopArea/StorageChest",
    "WorkshopArea/SleepSpot",
    "CemeteryArea/CorpseDelivery",
    "CemeteryArea/PreparationTable",
    "CemeteryArea/GravePlot",
    "CemeteryArea/GraveUpgrade",
    "ForestExit",
    "VillageExit",
    "FutureExpansion",
]
```

Clamp flood-fill exploration to `Vector2i(0, 0)` through `Vector2i(49, 31)`.

- [ ] **Step 3: Add authored-map quality assertions**

Require:

```gdscript
if paths.get_used_cells().size() < 120:
    failures.append("Cemetery needs a substantial authored path network")
if decoration_low.get_used_cells().size() < 80:
    failures.append("Cemetery needs dense low decoration")
if objects_y_sorted.get_used_cells().size() < 30:
    failures.append("Cemetery needs enough authored graves and tall props")
```

Require representative obstacle collision cells:

```gdscript
for cell in [Vector2i(7, 20), Vector2i(12, 19), Vector2i(5, 8), Vector2i(40, 10)]:
    if collision.get_cell_source_id(cell) == -1:
        failures.append("Expected authored obstacle collision at %s" % cell)
```

- [ ] **Step 4: Add a real-player physics check**

Preload `res://player/player.tscn`. Instantiate the production player under the map, disable its physics process, place it at `PlayerSpawn`, wait two physics frames, then verify a short movement segment along the workshop apron is unobstructed:

```gdscript
var player := PLAYER_SCENE.instantiate() as PlayerController
map.add_child(player)
player.set_physics_process(false)
player.position = (map.get_node("PlayerSpawn") as Marker2D).position
await tree.physics_frame
await tree.physics_frame
var start := player.position
var hit := player.move_and_collide(Vector2(64, 0))
if hit != null or not player.position.is_equal_approx(start + Vector2(64, 0)):
    failures.append("Real player must move freely across the workshop apron")
```

Then position the player 64 px south of one representative tree collision cell and move north 96 px; require a collision result.

Convert `run()` to `static func run() -> Array[String]:` with `await` at the physics helper call, matching the existing Verdant async test pattern.

- [ ] **Step 5: Run the cemetery test and confirm RED**

Run:

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

Expected: cemetery-map failures for new coordinates, route contract, obstacle collision, and/or path-density expectations because production code still implements the old layout.

- [ ] **Step 6: Commit the RED test**

```bash
git add tests/test_cemetery_map.gd
git commit -m "test: define rebuilt cemetery map contract"
```

---

### Task 2: Replace the old cemetery composition with authored zone data

**Files:**
- Modify: `world/maps/cemetery/cemetery_map.gd`

**Interfaces:**
- Consumes: `TechnicalMap` layer fields, `CemeteryArtTileset.build()`, current production cemetery atlas, existing workshop/interaction nodes.
- Produces: `_build_ground()`, `_build_paths()`, `_build_low_decoration()`, `_build_authored_objects()`, cemetery-specific `_populate_collision()`, and deterministic reserved-route handling.

- [ ] **Step 1: Delete the old production layout routines from map startup**

Replace `_ready()` calls to `_populate_production_ground`, `_populate_production_paths`, `_populate_production_decor`, and `_populate_production_objects` with:

```gdscript
func _ready() -> void:
    _configure_layers(CemeteryArtTileset.build())
    _build_ground()
    _build_paths()
    _build_low_decoration()
    _build_authored_objects()
    _populate_collision()
    _hide_placeholders(self)
    _add_workshop_art()
```

Remove the four obsolete `_populate_production_*` methods completely.

- [ ] **Step 2: Add authored route centerlines**

Define explicit tile-space control points:

```gdscript
const MAIN_SPINE := [
    Vector2i(12, 25), Vector2i(16, 24), Vector2i(20, 22), Vector2i(24, 20),
    Vector2i(28, 18), Vector2i(32, 18), Vector2i(36, 16), Vector2i(39, 16),
]
const VILLAGE_ROUTE := [
    Vector2i(25, 19), Vector2i(25, 15), Vector2i(25, 11), Vector2i(24, 7),
    Vector2i(25, 3), Vector2i(25, 1),
]
const FOREST_ROUTE := [
    Vector2i(32, 18), Vector2i(36, 19), Vector2i(40, 20), Vector2i(44, 21),
    Vector2i(48, 22),
]
const CEMETERY_ROUTE := [
    Vector2i(28, 18), Vector2i(31, 16), Vector2i(34, 14), Vector2i(37, 13),
]
```

Implement `_paint_path_segment(from_cell, to_cell, radius)` using integer interpolation and a radius of 1 tile so routes are roughly 3 tiles wide. Paint a wider radius-2 clearing around workshop cells `(10..16, 23..27)` and reception cells `(27..33, 17..20)`.

Track every painted path cell in `_reserved_cells: Dictionary`.

- [ ] **Step 3: Build ground and low decoration without reusing the old formulas**

Fill all 50x32 ground cells. Use authored zone rectangles to select variants: darker old cemetery on the west/north-west, slightly cleaner workshop clearing in south-west, colder operational cemetery in north-east. Add low decoration from a fixed list of clusters and a deterministic seeded RNG only after rejecting `_reserved_cells`, interaction approach cells, and obstacle cells.

Use seed `9022026` so captures and tests remain reproducible.

- [ ] **Step 4: Author grave and vegetation clusters**

Create explicit arrays. Use grave atlas cells `(0..3, 3)` and existing tree/prop atlas cells already used by the cemetery production atlas.

Old cemetery grave cells:

```gdscript
[
    Vector2i(6, 7), Vector2i(9, 6), Vector2i(12, 8), Vector2i(15, 7),
    Vector2i(7, 11), Vector2i(10, 10), Vector2i(14, 12), Vector2i(17, 10),
    Vector2i(5, 14), Vector2i(9, 15), Vector2i(13, 14), Vector2i(17, 15),
]
```

Operational cemetery grave cells:

```gdscript
[
    Vector2i(34, 8), Vector2i(37, 8), Vector2i(40, 9), Vector2i(43, 8),
    Vector2i(33, 11), Vector2i(36, 11), Vector2i(40, 12), Vector2i(44, 11),
    Vector2i(35, 14), Vector2i(39, 14), Vector2i(43, 14),
]
```

Tree/large-prop anchors:

```gdscript
[
    Vector2i(4, 5), Vector2i(8, 4), Vector2i(14, 4), Vector2i(19, 6),
    Vector2i(4, 10), Vector2i(18, 12), Vector2i(4, 18), Vector2i(7, 20),
    Vector2i(12, 19), Vector2i(17, 27), Vector2i(22, 28), Vector2i(31, 27),
    Vector2i(39, 27), Vector2i(45, 26), Vector2i(46, 15), Vector2i(40, 10),
]
```

Do not place an authored object if its cell is reserved.

- [ ] **Step 5: Add cemetery-specific collision instead of inherited internal rectangle**

Override `_populate_collision()` in `CemeteryMap`. Add perimeter collision except intentional route apertures around VillageExit `(24..26, y=0)` and ForestExit `(x=49, y=21..23)`.

Add workshop body cells:

```gdscript
for y in range(18, 22):
    for x in range(6, 16):
        if not (y == 21 and x in [10, 11, 12]):
            _set_collision_if_free(Vector2i(x, y))
```

Add collision at all tree anchors and representative two-cell monument footprints where needed. `_set_collision_if_free(cell)` must refuse cells in `_reserved_cells` or explicit protected approach cells.

- [ ] **Step 6: Preserve art presentation but move workshop art with the new anchor**

Keep `_hide_placeholders`, `_add_workshop_art`, and `_add_atlas_sprite` behaviour. Do not scale or recolor the workshop texture in code.

- [ ] **Step 7: Run tests**

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

Expected: map-composition assertions improve, while coordinate assertions may still fail until Task 3 updates the scene.

- [ ] **Step 8: Run format checks and commit**

```bash
gdformat world/maps/cemetery/cemetery_map.gd
gdlint world/maps/cemetery/cemetery_map.gd
git add world/maps/cemetery/cemetery_map.gd
git commit -m "feat: rebuild cemetery map composition"
```

---

### Task 3: Recompose gameplay nodes and prove real-player traversal

**Files:**
- Modify: `world/maps/cemetery/cemetery_map.tscn`
- Modify: `tests/test_cemetery_map.gd`

**Interfaces:**
- Consumes: new authored route/collision topology from Task 2.
- Produces: final interaction coordinates, transition coordinates, and production-player traversal assertions.

- [ ] **Step 1: Move workshop anchor and required nodes**

Set:

```text
WorkshopArea/BuildingVisualAnchor = (352, 704)
WorkshopArea/Workbench = (288, 768)
WorkshopArea/StorageChest = (480, 768)
WorkshopArea/SleepSpot = (352, 832)
CemeteryArea/CorpseDelivery = (928, 608)
CemeteryArea/PreparationTable = (1024, 608)
CemeteryArea/GravePlot = (1152, 544)
CemeteryArea/GraveUpgrade = (1248, 544)
PlayerSpawn = (416, 800)
AldrenSpawn = (800, 544)
ForestExit = (1536, 704)
VillageExit = (800, 64)
FutureExpansion = (1376, 160)
```

Do not change node types, scripts, prompts, actions, collision layers, or interaction shape sizes.

- [ ] **Step 2: Strengthen the player traversal test**

Use the production player as in `TestVerdantTestMap`. Test several short physical segments rather than teleport-only topology:

```gdscript
var segments := [
    [Vector2(416, 800), Vector2(128, 0)],
    [Vector2(704, 704), Vector2(96, -64)],
    [Vector2(864, 640), Vector2(128, 0)],
    [Vector2(1344, 704), Vector2(128, 0)],
]
```

For each segment, set `player.position`, wait one physics frame, call `move_and_collide(delta)`, and fail if a collision occurs on the reserved corridor. Keep the representative obstacle collision test so the same production player proves blockers work.

- [ ] **Step 3: Run the complete headless suite**

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

Expected: PASS.

- [ ] **Step 4: Commit the scene composition**

```bash
git add world/maps/cemetery/cemetery_map.tscn tests/test_cemetery_map.gd
git commit -m "feat: integrate cemetery gameplay routes"
```

---

### Task 4: Validate import, formatting, smoke, capture, and PR readiness

**Files:**
- Potential generated capture only: use the repository's established visual-capture location/pattern; do not alter unrelated art.

**Interfaces:**
- Consumes: completed map branch.
- Produces: verification evidence and a reviewable branch/PR.

- [ ] **Step 1: Run formatting/lint gates**

```bash
gdlint world/maps/cemetery/cemetery_map.gd tests/test_cemetery_map.gd
gdformat --check world/maps/cemetery/cemetery_map.gd tests/test_cemetery_map.gd
```

Expected: both commands exit 0.

- [ ] **Step 2: Validate Godot import**

```bash
godot --headless --path . --editor --quit
```

Expected: exit 0 with no parser/import errors.

- [ ] **Step 3: Smoke the production main scene**

```bash
godot --headless --path . --quit-after 3
```

Expected: exit 0.

- [ ] **Step 4: Run full tests again**

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

Expected: PASS with zero failures.

- [ ] **Step 5: Capture the cemetery at gameplay resolution**

Run the production game at 1280x720, enter the cemetery from the normal world shell, leave camera zoom at the current gameplay value, and capture a frame from the workshop/processional-spine composition that includes the player and at least one major route branch. Store it using the existing project capture convention. Do not use an editor-only viewport as acceptance evidence.

- [ ] **Step 6: Review capture against the visual hierarchy**

Reject the capture if any of these are true:

- workshop/path are not immediately readable;
- center is clogged by trees/foreground;
- operational cemetery looks like a rigid repeated grid;
- player silhouette disappears into ground values;
- route to forest or village has ambiguous blockage;
- props visibly imply collision where none exists, or vice versa.

If rejected, adjust only `cemetery_map.gd` authored placements/decoration, rerun Tasks 3–4 verification, and recapture.

- [ ] **Step 7: Commit capture/last visual adjustments**

```bash
git add world/maps/cemetery/cemetery_map.gd <capture-path-if-tracked>
git commit -m "polish: finalize cemetery map composition"
```

Skip the commit if no tracked file changed.

- [ ] **Step 8: Open a PR without merging it**

Create a PR from `feature/main-map-rebuild` to `main` summarizing: new composition, gameplay-node relocation, collision redesign, route tests, real-player physics evidence, command results, and capture path. Do not self-merge.
