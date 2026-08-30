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
- `NPCData` tipado para identidad, rol y velocidad de movimiento de NPCs.
- Primer NPC data-driven: `Brother Aldren` / Hermano Aldren como sacerdote excéntrico.
- `NPCNavigationMath` para dirección/llegada testeables fuera de escena.
- `WorldNavigationRegion` local con geometría mínima navegable.
- `NPCController` sobre `CharacterBody2D` + `NavigationAgent2D` y escena `brother_aldren.tscn`.
- `ScheduleEntryData` y `ScheduleData` para horarios NPC data-driven con soporte de los seis días y rangos que cruzan medianoche.
- `NPCStateMachine` con estados explícitos `Idle`, `Walking`, `Working` y `Sleeping`.
- `brother_aldren_schedule.tres` con rutina mínima completa para Hermano Aldren.
- `test_npc_navigation.gd` para datos, navegación pura e integración del primer NPC.
- `test_npc_routines.gd` para horarios, medianoche, transiciones de estado e integración de escena.
- Instrumentación de suites headless y timeout de 30 segundos en CI para evitar bloqueos silenciosos.
- Job `gdscript-quality` independiente con Python + `gdtoolkit`, `gdlint` y `gdformat --check` para los scripts endurecidos.
- `.editorconfig` activo para normalizar tabulación GDScript y whitespace en archivos del proyecto.

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
- `world/world.tscn` incorpora `NavigationRegion` y `BrotherAldren`.
- `NPCController` selecciona rutina desde `ScheduleData` observando `TimeManager`/`EventBus`; los destinos iniciales ad hoc se sustituyen por destinos de horario.
- `Walking` pasa a ser estado transitorio: al llegar, el NPC adopta la actividad programada (`Idle`, `Working` o `Sleeping`).
- El quality gate incluye incrementalmente lógica, controllers y tests del ciclo día/noche, navegación y rutinas NPC.
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
- Se corrigieron los problemas detectados por `gdlint` y los archivos señalados por `gdformat` sin desactivar reglas.
- `DayNightController` resuelve `EventBus`/`TimeManager` desde `/root` para compilar y funcionar también bajo tests `--script`.
- La transición visual nocturna atraviesa medianoche de forma continua hasta las 06:00.
- `NPCController` respeta el orden de definiciones exigido por el quality gate.
- Los tests NPC ya no dependen del antiguo `initial_target`; validan el `ScheduleData` que realmente gobierna los destinos.
- `NPCController` resuelve `NavigationAgent2D` también fuera de `_ready()`, permitiendo pruebas off-tree sin falsear el lifecycle del juego.
- `ScheduleEntryData` usa minutos normalizados enteros; se eliminó la comparación inválida entre el `Dictionary` de `TimeMath.normalize_total_minutes()` y enteros.
- El archivo auxiliar `editorconfig` se renombró a `.editorconfig`, nombre efectivo del estándar EditorConfig.

### Validated
- Fase 0: run `33278173612`, `success`.
- Fase 1: run `33280758441`, `success`.
- Fase 2: run `33285578050`, `success`.
- Fase 3 producción temporizada/colas: commit `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`, `success`.
- Fase 4 cierre gameplay/persistencia: corrección `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`, `success`.
- Fase 5 bloque 1 tiempo/calendario + sueño: corrección `62cb2658bd169270fffcb59c34134493b787f327`, run `33294728470`, `success`.
- Hardening funcional de storage/dependencias: commit `0639a43b16c152bf7a8b9ad3b44e2aa4aa640a8a`, run `33294983254`, `success`.
- Desacoplamiento final de componentes por tipo: commit `b13d024143b5fb0ff8118a689da079c37916c554`, run `33295277286`, ambos jobs `success`.
- Fase 5 bloque 2 ciclo día/noche: corrección final `5c6467c5aad04b1d44c48cceef2280af5d049bf8`, run `33295805020`, `gdscript-quality` y `validate-and-test` en `success`.
- Fase 5 bloque 3 NPCData/navegación: run `33296112250` detectó `class-definitions-order`; corrección final `03986401968c83b79527d15f47217f090de43ab2`, run `33296131085`, ambos jobs `success`.
- Fase 5 bloque 4 rutinas: run `33296549903` detectó comparación `Dictionary`/`int` en horarios; corrección final `82f5ccee1e109e2ad702532b7301922124548c7b`, run `33296648630`, `gdscript-quality` y `validate-and-test` en `success`.
