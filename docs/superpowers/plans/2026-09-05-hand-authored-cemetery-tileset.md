# Hand-Authored Cemetery Tileset Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace PR #142's procedural-looking cemetery terrain with a static, pixel-cleaned 128-tile atlas and a baked TileMap composition while preserving gameplay contracts.

**Architecture:** A 512x256 terrain atlas, continuous full-map ground atlas, transparent 16-piece path strip, and static Godot `TileSet` resource become the sole terrain sources for the cemetery's visual tile layers. Grave and workshop prop sheets complete the authored raster language. Authored tile placement and prop nodes live in `cemetery_map.tscn`; runtime scripts no longer construct, erase, fade, or draw the map presentation.

**Tech Stack:** Godot 4.7.2, GDScript, `TileMapLayer`, `TileSetAtlasSource`, 32x32 RGBA pixel art, nearest-neighbor rendering, GitHub Actions visual capture.

**Spec:** `docs/superpowers/specs/2026-09-05-hand-authored-cemetery-tileset-design.md`

## Global Constraints

- Work only on canonical MAP branch `feat/main-map-rebuild-commercial-pass` and PR #142.
- Do not reuse the discarded main-map layout or modify PLAYER-owned files.
- Final terrain art is static and pixel-cleaned; no generator, random scatter, `Line2D` path, gradient, antialiasing, or runtime visual composition may ship.
- Preserve world size `1600x1024`, tile size `32x32`, collisions, navigation, marker positions, interaction positions, route cells, resources, and zones.
- Visual acceptance requires inspected 1280x720 gameplay captures, not tests alone.

---

### Task 1: Lock the static-art acceptance contract

**Files:**
- Modify: `tests/test_cemetery_visual_slice.gd`
- Modify: `tests/test_cemetery_map.gd`

**Interfaces:**
- Consumes: `CemeteryMap` scene, its named `TileMapLayer` children, and the planned static atlas/resource paths.
- Produces: regression failures that reject the current 256x96 atlas and runtime visual-pass implementation.

- [ ] **Step 1: Write failing atlas and scene tests**

Add constants for `cemetery_terrain_hand_authored_32.png`, `cemetery_terrain_hand_authored.tres`, `Vector2i(512, 256)`, and `Vector2i(32, 32)`. Load the PNG as an `Image`, inspect all 128 regions, assert every tile is non-empty, and reject partial alpha. Instantiate the map and fail if any of `AuthoredVisualDressing`, `CommercialCompositionPass`, `CommercialFinishPass`, `CemeteryTerrainTileset`, or a visible `Line2D` exists.

```gdscript
const HAND_AUTHORED_ATLAS := (
	"res://art/environment/cemetery/production/atlas/cemetery_terrain_hand_authored_32.png"
)
const HAND_AUTHORED_TILESET := (
	"res://art/environment/cemetery/production/data/cemetery_terrain_hand_authored.tres"
)
const EXPECTED_ATLAS_SIZE := Vector2i(512, 256)

static func _validate_static_authored_map(map: Node, failures: Array[String]) -> void:
	for removed_node in [
		"AuthoredVisualDressing", "CommercialCompositionPass", "CommercialFinishPass"
	]:
		if map.get_node_or_null(removed_node) != null:
			failures.append("Runtime visual pass must be removed: %s" % removed_node)
	for child in map.find_children("*", "Line2D", true, false):
		if (child as Line2D).is_visible_in_tree():
			failures.append("Production paths must be authored TileMap cells")
```

- [ ] **Step 2: Run the focused suite and verify RED**

Run:

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

Expected: `CemeteryVisualSlice` fails because the new atlas/resource do not exist and runtime visual-pass nodes remain.

- [ ] **Step 3: Commit the failing contract**

```bash
git add tests/test_cemetery_visual_slice.gd tests/test_cemetery_map.gd
git commit -m "test(map): require static hand-authored cemetery terrain"
```

### Task 2: Author and validate the 128-tile terrain atlas

**Files:**
- Create: `art/environment/cemetery/production/atlas/cemetery_terrain_hand_authored_32.png`
- Create: `art/environment/cemetery/production/data/cemetery_terrain_hand_authored.tres`
- Modify: `tests/test_cemetery_visual_slice.gd`
- Delete: `art/environment/cemetery/production/atlas/terrain_ground_paths_32.png`
- Delete: `world/maps/cemetery/cemetery_terrain_tileset.gd`

**Interfaces:**
- Consumes: the atlas row/cell contract in the design spec.
- Produces: a static 16x8 atlas and `TileSet` resource used directly by the three visual tile layers.

- [ ] **Step 1: Produce concept/reference material**

Create one cohesive top-down three-quarter cemetery terrain reference using the approved olive/umber/grey/blue-green palette and upper-left lighting. Treat it only as source material; do not place generated output directly in the game.

- [ ] **Step 2: Assemble and pixel-clean the atlas**

Author each 32x32 cell according to the eight-row atlas table. Remove interpolated pixels, reduce the palette, enforce binary alpha, repair edge continuity, and inspect a nearest-neighbor 4x contact sheet. Do not commit an authoring script.

- [ ] **Step 3: Create the static TileSet resource**

Create a `TileSet` with tile size 32x32, one `TileSetAtlasSource` using the new PNG, and all `(0..15, 0..7)` tiles. Save it to the exact `.tres` path, then verify it reloads through `ResourceLoader`.

- [ ] **Step 4: Pin the approved pixel baseline**

Run `sha256sum` on the finished PNG and copy its 64-character value verbatim into `EXPECTED_TERRAIN_ATLAS_SHA256` in `test_cemetery_visual_slice.gd`. Add pixel comparisons proving each material family and path-shape group contains distinct cells.

- [ ] **Step 5: Run import and focused tests**

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/run_tests.gd
```

Expected: atlas-content assertions pass; scene-static assertions remain red until Task 3.

- [ ] **Step 6: Commit the authored asset system**

```bash
git add art/environment/cemetery/production tests/test_cemetery_visual_slice.gd
git rm art/environment/cemetery/production/atlas/terrain_ground_paths_32.png
git rm world/maps/cemetery/cemetery_terrain_tileset.gd
git commit -m "feat(map): add hand-authored cemetery terrain tileset"
```

### Task 3: Bake the cemetery presentation into the scene

**Files:**
- Modify: `world/maps/cemetery/cemetery_map.tscn`
- Modify: `tests/test_cemetery_visual_slice.gd`
- Modify: `tests/test_cemetery_map.gd`
- Modify: `tests/test_cemetery_zoning.gd`
- Delete: `world/maps/cemetery/cemetery_visual_dressing.gd`
- Delete: `world/maps/cemetery/cemetery_commercial_composition.gd`
- Delete: `world/maps/cemetery/cemetery_commercial_finish.gd`

**Interfaces:**
- Consumes: `cemetery_terrain_hand_authored.tres` and the existing gameplay geometry.
- Produces: a self-contained `CemeteryMap` whose visual state is complete immediately after deserialization.

- [ ] **Step 1: Replace terrain references**

Assign the static `TileSet` resource directly to `ground`, `paths`, and `decoration_low`. Remove the four runtime terrain/composition script resources and the three visual-pass nodes from the scene.

- [ ] **Step 2: Author ground material zones**

Paint complete ground coverage with broad irregular clusters: packed workshop wear around cells `(7..19, 19..27)`, mossy cemetery terrain around `(30..43, 5..19)`, forest grass/rock clusters outside the functional zones, and restrained wet ground near the cemetery edge. Avoid row bands and per-cell alternation.

- [ ] **Step 3: Author paths and transitions**

Use atlas row 5 for every required route, bends, junctions, and endpoints. Use rows 2–4 for shoulders and row 6 for the cemetery/plaza surface. Preserve every `REQUIRED_ROUTE_CELLS` entry and grave aisle while eliminating all `Line2D` underlays.

- [ ] **Step 4: Bake decoration and prop depth**

Move useful tree, grave, sign, grass, transition, landmark, and foreground nodes into explicit scene-owned nodes with stable positions, pivots, nearest filtering, and Y-sort. Do not retain scripts that add, hide, erase, fade, or reposition these visuals during `_ready()`.

- [ ] **Step 5: Verify gameplay invariants**

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/run_tests.gd
```

Expected: all Cemetery map, zoning, traversal, navigation, interaction, visual-slice, and bootstrap tests pass.

- [ ] **Step 6: Commit the static scene**

```bash
git add world/maps/cemetery/cemetery_map.tscn tests/test_cemetery_visual_slice.gd tests/test_cemetery_map.gd tests/test_cemetery_zoning.gd
git rm world/maps/cemetery/cemetery_visual_dressing.gd world/maps/cemetery/cemetery_commercial_composition.gd world/maps/cemetery/cemetery_commercial_finish.gd
git commit -m "refactor(map): bake cemetery presentation into TileMap layers"
```

### Task 4: Run technical quality gates

**Files:**
- Modify only files identified by failing format/lint tests, without broad refactors.

**Interfaces:**
- Consumes: the completed static atlas and map scene.
- Produces: a CI-ready MAP head with no known technical regression.

- [ ] **Step 1: Run formatting and lint**

```bash
find . -type f -name '*.gd' -not -path './.git/*' -print0 | sort -z | xargs -0 gdlint
find . -type f -name '*.gd' -not -path './.git/*' -print0 | sort -z | xargs -0 gdformat --check
```

- [ ] **Step 2: Run import, smoke, and bootstrap**

```bash
godot --headless --path . --editor --quit
timeout 15s godot --headless --path .
godot --headless --path . --script res://tests/run_tests.gd
```

Expected: all commands exit successfully; the timed smoke test may exit with timeout only after the main scene has launched without script/resource errors.

- [ ] **Step 3: Inspect repository scope**

Run `git diff --check`, `git status --short`, and `git diff --name-status origin/feat/main-map-rebuild-commercial-pass...HEAD`. Reject PLAYER changes, generated `.import`/`.uid` sidecars, authoring scripts, or unrelated files.

- [ ] **Step 4: Commit any focused gate correction**

Stage each exact file reported by the failed gate explicitly, confirm the staged name list with `git diff --cached --name-only`, then commit with `git commit -m "fix(map): satisfy static terrain quality gates"`. Skip this commit when no correction is required.

### Task 5: Capture, critique, revise, and publish evidence

**Files:**
- Modify: terrain atlas or static scene only when the visual critique identifies a concrete defect.
- Update: PR #142 conversation with final evidence links and acceptance summary.

**Interfaces:**
- Consumes: the technically green MAP head and existing visual-capture runner.
- Produces: reviewable 1280x720 gameplay evidence tied to the final commit SHA.

- [ ] **Step 1: Capture the real gameplay views**

```bash
GODOT_BIN=godot bash tools/visual_capture/run_capture.sh /tmp/game1-map-handmade-captures
```

Confirm that `cemetery_day`, `cemetery_night`, `cemetery_overview`, `cemetery_workshop`, `cemetery_graves`, `cemetery_plaza`, and `cemetery_forest_path` are all 1280x720 and metadata records the current SHA.

- [ ] **Step 2: Perform visual critique**

Inspect the full-resolution captures for grid bands, repeated stamps, flat material fields, vector-like paths, seams, abrupt transitions, weak landmarks, occlusion errors, route readability, and scale consistency with PLAYER.

- [ ] **Step 3: Complete at least one focused revision cycle**

Correct every concrete defect found in the atlas or static scene, rerun the relevant tests, and recapture the affected views. Do not weaken tests to accept visible defects.

- [ ] **Step 4: Commit the reviewed art**

```bash
git add art/environment/cemetery/production world/maps/cemetery/cemetery_map.tscn
git commit -m "fix(map): complete handmade terrain visual review"
```

- [ ] **Step 5: Push the canonical branch and verify CI**

Push `feat/main-map-rebuild-commercial-pass` without force. Wait for `gdscript-quality`, `validate-and-test`, `visual-capture`, and branch governance to succeed on the final SHA.

- [ ] **Step 6: Inspect the CI artifact and update PR #142**

Download `cemetery-visual-captures`, verify dimensions and metadata, inspect the exact uploaded files, and add a PR comment linking the run and artifact. Report visual acceptance as ready for human review, not already accepted.
