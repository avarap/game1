# World Zone Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Connect all Phase 7 maps into one traversable world with one persistent player, valid save/load location and an acceptance gate that can close Phase 7.

**Architecture:** `world/world.tscn` becomes a persistent shell with one local `ZoneManager` and one `ZoneContainer`. `ZoneManager` loads exactly one map scene at a time, moves the existing Player to stable markers, creates transition interactables from a route table, updates camera bounds and exposes a save provider for world location. Persistent RPG/cemetery state stays outside the zone container.

**Tech Stack:** Godot 4.7.2, GDScript, Node2D, PackedScene, Area2D/Interactable, existing SaveManager provider contract, headless tests.

**Spec:** `docs/superpowers/specs/2026-08-30-world-zone-integration-design.md`

## Global Constraints
- Godot 4.7.2.
- Exactly five Autoloads.
- No Phase 8 art/polish.
- Do not recreate Player or RPG controllers during travel.
- Global `gdlint` and `gdformat --check` remain strict.

---

### Task 1: Zone manager and deterministic travel

**Files:**
- Create: `world/zones/zone_manager.gd`
- Create: `world/zones/zone_transition.gd`
- Test: `tests/test_world_zone_integration.gd`
- Modify: `tests/run_tests.gd`

**Interfaces:**
- Produces: `ZoneManager.travel_to(zone_id: StringName, marker_id: StringName) -> bool`
- Produces: `ZoneManager.get_active_zone_id() -> StringName`
- Produces: `ZoneManager.get_active_zone() -> Node2D`
- `ZoneTransition` exports `target_zone_id` and `target_marker_id` and delegates interaction to the nearest `ZoneManager` group member.

- [ ] Write a failing test that instantiates `world.tscn`, resolves `ZoneManager`, records the Player `instance_id`, travels cemetery -> forest -> village -> village interior -> mine -> cemetery, and asserts the same Player instance survives and every target marker resolves.
- [ ] Run the suite and confirm the new test fails because `ZoneManager` does not exist.
- [ ] Implement the minimal manager with a stable scene registry and recursive marker resolution. Validate target scene and marker before freeing the current zone. Only on successful validation replace the previous child in `ZoneContainer` and move Player.
- [ ] Add the route table and create transition Areas at source markers after each load.
- [ ] Run the focused test and full suite; keep all previous tests green.
- [ ] Commit.

### Task 2: Persistent world shell and zone-safe cemetery state

**Files:**
- Modify: `world/world.tscn`
- Modify: `world/maps/cemetery/cemetery_map.tscn`
- Test: `tests/test_world_zone_integration.gd`

**Interfaces:**
- `world.tscn` owns persistent Player, UI, DayNightCycle, RelationshipController, QuestController, EconomyController, TechnologyController, CemeteryController and BrotherAldren.
- `ZoneContainer` owns only the active map.

- [ ] Extend the failing integration test to record persistent controller instance IDs before travel and assert they remain unchanged after a full loop.
- [ ] Remove the duplicate `CemeteryController` from `cemetery_map.tscn`; its `CemeteryAction` nodes continue resolving the persistent controller through group `cemetery_controller`.
- [ ] Replace `TechnicalMap` and duplicated cemetery interactables in `world.tscn` with `ZoneManager` + `ZoneContainer`; initial zone is `cemetery` at `PlayerSpawn`.
- [ ] Keep BrotherAldren persistent and make the manager toggle his visibility when leaving/returning to cemetery without replacing the node.
- [ ] Run focused and full tests.
- [ ] Commit.

### Task 3: World location persistence and camera bounds

**Files:**
- Create: `world/zones/world_location_provider.gd`
- Modify: `world/zones/zone_manager.gd`
- Test: `tests/test_world_zone_integration.gd`

**Interfaces:**
- `WorldLocationProvider.get_save_key() -> StringName` returns `&"world_location"`.
- `WorldLocationProvider.get_save_data() -> Dictionary` returns `zone_id`, `marker_id`, `position`.
- `WorldLocationProvider.apply_save_data(data: Dictionary) -> void` restores through ZoneManager and falls back to cemetery/PlayerSpawn when invalid.

- [ ] Add a failing save/load test: travel to mine, mutate representative RPG/player state, save, travel elsewhere, load, assert mine location restored and persistent state preserved.
- [ ] Implement the local provider using the existing SaveManager provider contract; register/unregister through the same group pattern used by existing providers.
- [ ] After each zone load, read `get_world_rect()` when available and apply Camera2D limits; clamp restored position inside the rect with a small safe margin.
- [ ] Run focused and full tests.
- [ ] Commit.

### Task 4: #23 acceptance and issue completion

**Files:**
- Modify: `tests/test_world_zone_integration.gd`
- Modify: `DEV_MEMORY.md`
- Modify: `ROADMAP.md`
- Modify: `CHANGELOG.md`

- [ ] Extend the integration test to cover cemetery/property -> forest -> cemetery -> village/commercial state -> village interior -> village -> mine -> cemetery/property, including a forest resource interaction or equivalent reachable resource assertion and route/secret marker availability.
- [ ] Verify no invalid marker travel changes the active zone or Player position.
- [ ] Run global quality gate, Godot import, smoke and full headless suite in CI.
- [ ] Only after green CI, close issue #23 as completed and update docs to make #24 the sole remaining Phase 7 gate.
- [ ] Commit/merge through PR.

### Task 5: #24 final Phase 7 acceptance

**Files:**
- Create or extend: `tests/test_world_phase7_acceptance.gd`
- Modify: `tests/run_tests.gd`
- Modify: `DEV_MEMORY.md`
- Modify: `ROADMAP.md`
- Modify: `CHANGELOG.md`
- Modify: `README.md`

- [ ] Write the final acceptance test that loads every zone scene, verifies six TileMapLayer contract nodes, traverses all routes without changing Player identity, checks BrotherAldren schedule remains assigned, validates Y-sort/navigation nodes, tests save/load location, and verifies camera bounds after at least cemetery/forest/mine transitions.
- [ ] Run the test red first if any #24 criterion is not yet covered.
- [ ] Fix only Phase 7 integration defects found by the acceptance test; do not add Phase 8 content.
- [ ] Run `gdlint` + `gdformat --check` globally, Godot 4.7.2 import, smoke and full suite.
- [ ] Close #24 only with green CI; mark Fase 7 COMPLETADA and Fase 8 ACTIVA in all four docs.
- [ ] Merge final PR and verify the push CI of the resulting `main` HEAD is green.
