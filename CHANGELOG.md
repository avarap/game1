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
- `DayNightMath` para fases e interpolación gradual entre amanecer, mediodía, atardecer y noche.
- `DayNightController` local basado en `CanvasModulate`, sincronizado con `TimeManager` mediante `time_changed`.
- `test_day_night_cycle.gd` para referencias horarias, interpolación, fases e integración del ciclo visual en el mundo.
- Instrumentación de suites headless y timeout de 30 segundos en CI para evitar bloqueos silenciosos.
- Job `gdscript-quality` independiente con Python + `gdtoolkit`, `gdlint` y `gdformat --check` para los scripts endurecidos.

### Changed
- El crafting instantáneo opera sobre `StorageNetwork` manteniendo compatibilidad con inventario individual.
- Las estaciones pueden descubrir storage por grupo o recibir providers explícitos para tests/alcances futuros.
- `StorageProvider` incorpora `scope_id`; Workbench y cofres declaran `storage_scope` y solo se conectan a providers del mismo scope.
- Las recetas con `duration_seconds > 0` consumen/reservan inputs al encolar y producen outputs al finalizar.
- La energía de producción temporizada se cobra una sola vez cuando el trabajo es aceptado.
- `SaveManager` mantiene `SAVE_VERSION = 1`, agrega/aplica providers locales y persiste/restaura el reloj mediante `TimeManager.snapshot()`/`apply_snapshot()`.
- Jugador y cofres exponen/resuelven `InventoryComponent` y `EnergyComponent` por contrato y tipo; crafting, recolección y sueño dejan de conocer nombres internos de nodo.
- `CemeteryAction` sustituye el `NodePath` relativo al controller por inyección tipada o descubrimiento mediante grupo `cemetery_controller`.
- El mundo incorpora `DayNightCycle`, cuyo color deriva del reloj global sin almacenar una copia local de hora/día.
- El quality gate incluye incrementalmente la lógica, controller y tests del ciclo día/noche.
- Fase 4 — Cementerio queda completada; Fase 5 — Simulación está activa.

### Fixed
- Inferencias `Variant` incompatibles con el modo estricto de Godot 4.5 en inventario.
- Recolección y crafting evitan pérdida parcial de recursos mediante simulación/atomicidad.
- `CraftingStation` evita `get_tree()` cuando se ejecuta off-tree en tests.
- Producción temporizada conserva outputs pendientes cuando el almacenamiento está lleno.
- Preparar un cadáver no modifica accidentalmente `CorpseData` compartido.
- Test de persistencia de cementerio resuelve el Autoload desde `/root/SaveManager` bajo ejecución `--script`.
- `SleepSpot` ya no asume que el actor está montado en `SceneTree`; usa el árbol propio y fallback headless seguro.
- Se elimina `CemeteryService.RESULT_ALREADY_OCCUPIED`, código muerto sin comportamiento asociado.
- El crafting ya no puede consumir automáticamente materiales de cofres pertenecientes a otro `storage_scope`.
- Se corrigieron los problemas detectados por `gdlint` (`max-returns` y longitud de línea) y los archivos señalados por `gdformat` sin desactivar reglas.
- `DayNightController` resuelve `EventBus`/`TimeManager` desde `/root` para compilar y funcionar también bajo tests `--script`.
- La transición visual nocturna atraviesa medianoche de forma continua hasta las 06:00.

### Validated
- Fase 0: run `33278173612`, `success`.
- Fase 1: run `33280758441`, `success`.
- Fase 2: run `33285578050`, `success`.
- Fase 3 producción temporizada/colas: commit `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`, `success`.
- Fase 4 cierre gameplay/persistencia: corrección `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`, `success`.
- Fase 5 bloque 1 tiempo/calendario + sueño: corrección `62cb2658bd169270fffcb59c34134493b787f327`, run `33294728470`, `success`.
- Hardening funcional de storage/dependencias: commit `0639a43b16c152bf7a8b9ad3b44e2aa4aa640a8a`, run `33294983254`, `success`.
- Desacoplamiento final de componentes por tipo: commit `b13d024143b5fb0ff8118a689da079c37916c554`, run `33295277286`, ambos jobs `success`.
- Fase 5 bloque 2 ciclo día/noche: implementación `5ea87dda3ce3b4dda9d09d8dadebcddd7d6a0a26`; run `33295708310` detectó longitud de línea; `f0c014bdebb13135428be1857e035ea8f6d70525` + run `33295738329` detectaron formato y resolución de Autoload bajo `--script`; corrección final `5c6467c5aad04b1d44c48cceef2280af5d049bf8`, run `33295805020`, `gdscript-quality` y `validate-and-test` en `success`.
