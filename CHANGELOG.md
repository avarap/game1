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
- Sistema de cementerio con cadáveres, tumbas, rating data-driven, controller local, interactuables y persistencia.
- `TimeManager` ampliado con semana ficticia de seis días, snapshot/restauración y transición explícita al siguiente día.
- `SleepSpot` interactuable: dormir avanza al amanecer del día siguiente y restaura completamente la energía.
- `test_simulation_time.gd` para calendario, rollover de medianoche, sueño y persistencia temporal.
- Instrumentación de suites headless y timeout de 30 segundos en CI para evitar bloqueos silenciosos.

### Changed
- El crafting instantáneo opera sobre `StorageNetwork` manteniendo compatibilidad con inventario individual.
- Las estaciones pueden descubrir storage por grupo o recibir providers explícitos para tests/alcances futuros.
- Las recetas con `duration_seconds > 0` consumen/reservan inputs al encolar y producen outputs al finalizar.
- La energía de producción temporizada se cobra una sola vez cuando el trabajo es aceptado.
- `SaveManager` mantiene `SAVE_VERSION = 1`, agrega/aplica providers locales y ahora persiste/restaura el reloj mediante `TimeManager.snapshot()`/`apply_snapshot()` en lugar de manipular sus campos directamente.
- Fase 4 — Cementerio queda completada; Fase 5 — Simulación está activa.

### Fixed
- Inferencias `Variant` incompatibles con el modo estricto de Godot 4.5 en inventario.
- Recolección y crafting evitan pérdida parcial de recursos mediante simulación/atomicidad.
- `CraftingStation` evita `get_tree()` cuando se ejecuta off-tree en tests.
- Producción temporizada conserva outputs pendientes cuando el almacenamiento está lleno.
- Preparar un cadáver no modifica accidentalmente `CorpseData` compartido.
- Test de persistencia de cementerio resuelve el Autoload desde `/root/SaveManager` bajo ejecución `--script`.
- `SleepSpot` ya no asume que el actor está montado en `SceneTree`; usa el árbol propio y fallback headless seguro.

### Validated
- Fase 0: run `33278173612`, `success`.
- Fase 1: run `33280758441`, `success`.
- Fase 2: run `33285578050`, `success`.
- Fase 3 producción temporizada/colas: commit `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`, `success`.
- Fase 4 cierre gameplay/persistencia: corrección `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`, `success`.
- Fase 5 bloque 1 tiempo/calendario + sueño: implementación `57d9cfdc010398cf5b34764131c7859dd7221084`; run `33294671978` detectó el caso headless de `SleepSpot`; corrección `62cb2658bd169270fffcb59c34134493b787f327` validada por `Godot CI` run `33294728470`, `success` con importación, smoke test y suite headless completa.
