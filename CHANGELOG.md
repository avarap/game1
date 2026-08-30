# CHANGELOG

## Unreleased

### Added
- Inicialización del proyecto Godot 4.x.
- Escena raíz ejecutable.
- Autoloads globales mínimos.
- InputMap base.
- Logging mínimo.
- Panel debug de bootstrap.
- Utilidad pura `TimeMath` y test headless.
- GitHub Actions para validación y tests.
- Documentación base y memoria de desarrollo.
- `world/world.tscn` como composición base del walking prototype.
- `player/player.tscn` con `CharacterBody2D`, colisión, `InteractionArea` y `Camera2D`.
- Movimiento 8-direccional con aceleración/desaceleración mediante `PlayerMovement`.
- Límites de mapa, obstáculo de prueba y Y-sort.
- Componente base `Interactable` y `DebugSign` funcional.
- Tests de movimiento del jugador.
- Test de aceptación `test_walking_prototype.gd` para validar escenas y componentes críticos de Fase 1.
- `ItemData` tipado y primer item data-driven `data/items/wood.tres`.
- `InventoryStack` e `InventoryModel` independientes de UI con stacking, capacidad, altas, bajas y consultas.
- `InventoryComponent` local integrado en el jugador.
- Tests `test_inventory_model.gd` y `test_items_foundation.gd` para la base de Fase 2.

### Changed
- La Fase 2 queda formalmente iniciada con criterios de aceptación explícitos en `ROADMAP.md`.
- `tests/run_tests.gd` incluye las pruebas de items/inventario.

### Validated
- Fase 0 validada mediante `Godot CI` run `33278173612`.
- Fase 1 validada mediante `Godot CI` run `33280758441` sobre `ae77e23a190c4cb7824eff0bce8c6cf672fb381f`.
- El último CI previo a Fase 2 (`33280827024`) completó con `success`.
- El bloque inicial de Fase 2 (`f6d346a298910900785f19943bbf0680f33fde76`) lanzó `Godot CI` run `33283192098`; su validación debe revisarse antes del siguiente bloque.
