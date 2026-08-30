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
- `EnergyComponent` local con gasto/restauración de energía y señales.
- `ResourceSourceComponent` reutilizable para loot, golpes restantes, coste de energía y herramienta requerida.
- `ResourceNode` interactuable y `tree_resource.tscn` como primer recurso recolectable real.
- Requisito mínimo de hacha mediante `equipped_tool_id` del jugador.
- Feedback local de recolección para éxito, herramienta incorrecta, energía insuficiente, inventario lleno y recurso agotado.
- Test de aceptación `test_resource_loop.gd` para el loop completo de recolección y sus principales errores.

### Changed
- La Fase 2 quedó formalmente iniciada con criterios de aceptación explícitos en `ROADMAP.md`.
- `tests/run_tests.gd` incluye las pruebas de items/inventario y resource loop.
- `InventoryModel` usa tipado entero explícito y `mini`/`maxi` para cumplir el modo estricto de CI.
- El jugador integra ahora `EnergyComponent` además de `InventoryComponent`.
- `world/world.tscn` incluye un árbol recolectable dentro de la zona inicial.
- La Fase 2 queda completada tras validar el resource loop completo.

### Fixed
- Corregidos warnings de inferencia `Variant` tratados como errores por Godot 4.5 en la lógica de inventario.
- La recolección revierte cualquier loot parcial cuando el inventario no puede aceptar la cantidad completa, evitando consumir energía o dejar estado parcial.

### Validated
- Fase 0 validada mediante `Godot CI` run `33278173612`.
- Fase 1 validada mediante `Godot CI` run `33280758441` sobre `ae77e23a190c4cb7824eff0bce8c6cf672fb381f`.
- El primer intento de Fase 2 (`33283192098`) detectó el problema de tipado estricto en `InventoryModel`.
- El bloque base corregido en `2412414889c0a5d6e403c9178aede9b31fa045c5` quedó validado mediante `Godot CI` run `33283283684`.
- El resource loop completo en `c196e3ab5a42adffe97278f0b0daa8960c789e04` quedó validado mediante `Godot CI` run `33285578050`: importación, smoke test y suite headless en `success`.
