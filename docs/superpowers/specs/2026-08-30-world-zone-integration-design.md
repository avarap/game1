# World Zone Integration Design

## Goal
Complete Phase 7 world integration by connecting cemetery/property, forest, village, interiors and mine through deterministic transitions while keeping one persistent player and preserving RPG state.

## Constraints
- Runtime/CI: Godot 4.7.2.
- Keep exactly five Autoloads; zone integration is local to `world/world.tscn`.
- No final art, shaders, particles, final audio or Phase 8 polish.
- Existing RPG controllers stay persistent and are not recreated during travel.
- `TileMapLayer` remains the map-composition foundation.

## Architecture
`world/world.tscn` becomes a persistent shell containing Player, UI, RPG controllers, Brother Aldren, day/night and one `ZoneManager`. A child `ZoneContainer` owns exactly one instantiated zone scene at a time.

`ZoneManager` owns a small registry of stable zone IDs to PackedScenes: `cemetery`, `forest`, `village`, `home_interior`, `village_interior`, `mine`. `travel_to(zone_id, marker_id)` unloads the current zone, instantiates the target zone, resolves a marker recursively by stable name, moves the existing Player to it, and updates camera bounds from `get_world_rect()` when the zone exposes that contract.

`ZoneTransition` is an `Interactable` carrying only `target_zone_id` and `target_marker_id`; it delegates to the local `ZoneManager`. Transition Areas are attached by `ZoneManager` to known marker nodes after each zone loads so the independent map scenes remain focused and do not own cross-zone routing logic.

## Route contract
- cemetery `ForestExit` -> forest `CemeteryEntrance`
- forest `CemeteryExit` -> cemetery `ForestExit`
- cemetery `VillageExit` -> village `Entrance`
- village `Entrance` -> cemetery `VillageExit`
- cemetery `PlayerSpawn` -> home_interior `entry_main`
- home_interior `exit_main` -> cemetery `PlayerSpawn`
- village `Workshop` under `InteriorAccess` -> village_interior `entry_main`
- village_interior `exit_main` -> village `Workshop`
- cemetery `FutureExpansion` -> mine `Entrance`
- mine `Exit` -> cemetery `FutureExpansion`

The route table is technical Phase 7 wiring only; names/layout may be replaced by final content later without changing the manager API.

## Persistent state
Player, inventory, energy, quest/economy/relationship/technology controllers and the persistent cemetery controller remain outside `ZoneContainer`; their object identity therefore survives zone unload/reload. Zone scenes may contain local resource nodes and technical visuals but must not create a second persistent RPG controller.

A local `WorldLocationProvider` registered as `save_provider` stores `zone_id`, `marker_id` and player position. On load, the provider asks `ZoneManager` to reconstruct a valid zone first, then restores/clamps the saved position inside the active zone bounds. Invalid/missing zone or marker falls back to `cemetery/PlayerSpawn`.

## Camera and safety
After every zone load, camera limits are set from the zone's `get_world_rect()` when available. A destination marker must resolve to `Node2D`; otherwise travel fails without unloading the current zone. Player identity never changes. Transition destinations use established safe markers and are validated by tests.

## NPC behavior
Brother Aldren remains in the persistent world shell so his schedule, navigation agent and saved state are not recreated. When the active zone is not cemetery, he is hidden/paused for map interaction while his simulation state remains persistent; returning to cemetery restores visibility and navigation without replacing the instance.

## Testing
`test_world_zone_integration.gd` covers direct travel through every zone, unchanged Player/controller instance IDs, deterministic markers, camera bounds and save/load location restoration. The Phase 7 acceptance test additionally exercises the minimum traversal loop cemetery/property -> forest -> village -> interior -> mine -> property, checks no invalid spawn/softlock, and confirms the existing full suite remains green.

## Phase closure
Issue #23 is complete only after its integration test and full CI are green. Phase 7 is complete only after #24 revalidates all map scenes, traversal, NPC/Y-sort, save/load, camera/collision/transitions, global gdlint/gdformat and Godot 4.7.2 import/smoke/full suite, followed by synchronized `DEV_MEMORY.md`, `ROADMAP.md`, `CHANGELOG.md` and `README.md`.
