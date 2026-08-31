# Isoverse test map

This scene is a visual integration test for Zato's **Isoverse Medieval Outdoors Free** pack.

## Local asset setup

The third-party PNG is intentionally not committed because the pack page forbids redistribution of the asset files.

1. Download/extract the free pack from the creator.
2. Copy `Assets free version.png` to:
   `art/external/isoverse_medieval_outdoors/assets_free_version.png`
3. Open `world/maps/isoverse_test/isoverse_test_map.tscn` in Godot 4 and run the scene.

When the PNG is present, the map renders terrain, paths, trees, rocks and both free buildings directly from the Isoverse atlas. When it is absent (for example in CI), the scene builds simple fallback geometry so the project remains loadable and testable.

## Layout

- Logical size: 30 x 20 isometric cells.
- Main east-west path through the center.
- North-west building connected by a diagonal approach.
- East building connected to the central route.
- Trees around the perimeter and rocks as obstacles.
- `PlayerSpawn` is placed near the map center.
- Static collisions are generated for buildings, trees and rocks.

## Attribution

Isoverse Medieval Outdoors by Zato / ZatoArt. Keep the attribution required by the asset pack's license in the final game credits.
