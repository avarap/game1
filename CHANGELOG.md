# CHANGELOG

## Unreleased

### Added
- Bootstrap Godot 4.x, escena raíz, cinco Autoloads globales, InputMap, logging, debug, guardado versionado, tests y CI headless.
- Walking prototype con mundo base, `CharacterBody2D`, movimiento 8 direcciones, cámara, colisiones, Y-sort e interacción reutilizable.
- Sistema de items/inventario data-driven con `ItemData`, stacks, capacidad e `InventoryComponent` local.
- `EnergyComponent`, recursos recolectables, herramienta requerida, loot y feedback mínimo.
- `RecipeIngredient`, `RecipeData`, `CraftingService`, `CraftingStation` y `Workbench`.
- `StorageProvider`, `StorageNetwork` y `StorageChest` para crafting distribuido desacoplado de cofres concretos.
- `ProductionJob` y `ProductionQueue` para recetas temporizadas y colas mínimas.
- Test `test_production_queue.gd` para enqueue, progreso, finalización, almacenamiento bloqueado/reintento e integración con estación.

### Changed
- El crafting instantáneo opera sobre `StorageNetwork` manteniendo compatibilidad con inventario individual.
- Las estaciones pueden descubrir storage por grupo o recibir providers explícitos para tests/alcances futuros.
- Las recetas con `duration_seconds > 0` consumen/reservan inputs al encolar y producen outputs al finalizar.
- `CraftingStation` conserva el flujo instantáneo y añade ejecución temporizada sin introducir nuevos Autoloads.
- La energía de producción temporizada se cobra una sola vez cuando el trabajo es aceptado.
- Fase 3 queda completada y Fase 4 — Cementerio pasa a ser la siguiente fase.

### Fixed
- Inferencias `Variant` incompatibles con el modo estricto de Godot 4.5 en inventario.
- Recolección y crafting evitan pérdida parcial de recursos mediante simulación/atomicidad.
- `CraftingStation` evita `get_tree()` cuando se ejecuta off-tree en tests.
- Producción temporizada no pierde outputs si el almacenamiento se llena al completar: el job queda en `awaiting_output` y reintenta el depósito.

### Validated
- Fase 0: `Godot CI` run `33278173612`, `success`.
- Fase 1: run `33280758441`, `success`.
- Fase 2: run `33285578050`, `success`.
- Fase 3 bloque 1 crafting: run `33287832451`, `success`.
- Fase 3 StorageNetwork: tras corregir el fallo off-tree detectado en `33290155936`, run `33290225076` finalizó en `success`.
- Fase 3 producción temporizada/colas: commit `2252fcbd4280acec1e60530c026a8f5dd3365b91`, `Godot CI` run `33292481990`, `success` con importación, smoke test de `main.tscn` y suite headless.
