# Modular interiors

Phase 7 interiors use the map-layer contract from `ART_DIRECTION.md` and keep gameplay systems outside the map scenes.

## Stable transition IDs

Each interior exposes:

- `EntryMarkers/entry_main`
- `EntryMarkers/exit_main`
- `SafeSpawn`

`InteriorTransition.move_body_to_marker()` moves the existing `Node2D` instance to one of these stable markers. It does not create a replacement player, reload the world, or mutate RPG state.

## Current save/load limit

`SaveManager` currently persists registered `save_provider` state but leaves the top-level `player` payload empty. Player position and the active interior are therefore not part of the current persistence contract.

This task does not modify `SaveManager`, because that file is outside issue #21 ownership. The interiors keep stable IDs and safe spawn markers so a later world-integration task can add position/interior restoration without changing these scenes.
