# Cemetery Zoning Pass Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the rebuilt cemetery map read and play as three authored spaces: a workshop yard, a fenced cemetery with distinct grave lanes, and a forest resource zone with harvestable trees.

**Architecture:** Keep the canonical `CemeteryMap` scene and its existing gameplay contracts. Add authored cell groups for workshop terrain, cemetery perimeter and grave aisles, plus a dedicated `ForestResources` node using the existing production tree resource scene; extend visual dressing so resource nodes use the map's tree art instead of prototype polygons.

**Tech Stack:** Godot 4.7.2, GDScript, TileMapLayer, existing `ResourceNode` / `tree_resource.tscn`, GitHub Actions visual capture.

**Spec:** `GAME1_RULES.md`, `art/environment/cemetery/production/ART_DIRECTION.md`

## Global Constraints

- Work only in PR #139 / `feat/main-map-rebuild-commercial-pass`.
- Do not reuse the discarded previous main-map layout or spatial distribution.
- Preserve existing interaction nodes, collisions/navigation contracts and 32x32 logical grid.
- Prefer authored asymmetric cell lists over procedural or mathematical distribution.
- Real 1280x720 captures remain mandatory visual evidence.

---

### Task 1: Author workshop, cemetery lanes and forest resources

**Files:**
- Create: `tests/test_cemetery_zoning.gd`
- Modify: `tests/run_tests.gd`
- Modify: `world/maps/cemetery/cemetery_map.gd`
- Modify: `world/maps/cemetery/cemetery_map.tscn`
- Modify: `world/maps/cemetery/cemetery_visual_dressing.gd`

**Interfaces:**
- Consumes: `CemeteryArtTileset.build()`, `res://world/resources/tree_resource.tscn`, existing map layers `ground`, `paths`, `objects_y_sorted`, `collision`.
- Produces: `ForestResources` Node2D; authored cemetery fence/gate cells; internal grave aisle path cells; visibly grounded workshop yard; six or more real harvestable `ResourceNode` instances in the forest zone.

- [ ] **Step 1: Write the failing zoning test**

Add `TestCemeteryZoning` that instantiates the real cemetery scene and verifies: `ForestResources` exists with at least six `ResourceNode` children; all resource positions are outside the workshop and grave field; cemetery perimeter has visible structural cells on north/east/west boundaries with at least two deliberate gate gaps; grave lanes contain continuous path cells separating grave clusters; workshop terrain uses multiple authored non-base ground materials.

- [ ] **Step 2: Run test to verify RED**

Run: `godot --headless --path . --script res://tests/run_tests.gd`

Expected: `CemeteryZoning` fails because `ForestResources`, explicit fence/gate coverage and grave-lane paths do not yet exist.

- [ ] **Step 3: Implement the minimal authored zoning pass**

In `cemetery_map.gd`, add explicit cell arrays for workshop soil mass, cemetery fence perimeter, gate gaps and two irregular grave aisles. Paint the cemetery perimeter on `objects_y_sorted`, keep gates traversable, and paint grave aisles on `paths`. In `cemetery_map.tscn`, add `ForestResources` with scattered instances of `tree_resource.tscn` at authored non-grid-like positions. In `cemetery_visual_dressing.gd`, hide prototype tree polygons under those resources and attach the existing tree texture with feet-aligned pivots.

- [ ] **Step 4: Verify GREEN and regression gates**

Run: `godot --headless --path . --editor --quit`; `godot --headless --path . --quit-after 3`; `godot --headless --path . --script res://tests/run_tests.gd`; `gdlint` and `gdformat --check` on touched GDScript files.

Expected: cemetery map/navigation/traversal/zoning suites pass. Any pre-existing unrelated `VerdantTestMap` failure is reported separately and not misrepresented as a zoning regression.

- [ ] **Step 5: Visual gate**

Generate the existing 1280x720 captures and inspect workshop, overview, graves and forest path for readable zone identity, clear cemetery enclosure, grave aisles, resource distribution, path continuity, repetition and scale.

- [ ] **Step 6: Commit**

Commit the zoning implementation and evidence-related test changes to `feat/main-map-rebuild-commercial-pass` only.