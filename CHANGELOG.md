# CHANGELOG

## Unreleased

### Added
- Bootstrap Godot 4.x, cinco Autoloads globales, InputMap, logging, debug, guardado versionado, tests y CI headless.
- Walking prototype con mundo base, movimiento 8 direcciones, cámara, colisiones, Y-sort e interacción reutilizable.
- Sistema de items/inventario data-driven, energía, recursos recolectables, herramientas y loot.
- Crafting data-driven, `StorageNetwork`, cofres y producción temporizada con colas recuperables.
- Sistema de cementerio con cadáveres, tumbas, rating data-driven, interactuables y persistencia.
- `TimeManager` ampliado con calendario de seis días, snapshot/restauración y avance al siguiente día.
- `SleepSpot`: dormir avanza al amanecer y restaura energía.
- `DayNightMath` + `DayNightController` para ciclo día/noche gradual sincronizado con `TimeManager`.
- `NPCData`, primer NPC Hermano Aldren, `NPCNavigationMath`, `WorldNavigationRegion` y `NPCController` con `NavigationAgent2D`.
- `ScheduleEntryData` y `ScheduleData` para horarios data-driven con rangos que pueden cruzar medianoche.
- `NPCStateMachine` con `Idle`, `Walking`, `Working` y `Sleeping`.
- Horario real `brother_aldren_schedule.tres`.
- Persistencia runtime de NPCs mediante provider local con clave estable `npc:<NPCData.id>`.
- Snapshot NPC de `id`, posición, estado actual/pending, navegación activa y target cuando aplica.
- `test_npc_navigation.gd`, `test_npc_routines.gd` y `test_simulation_acceptance.gd`.
- `gdscript-quality` independiente con `gdlint` y `gdformat --check`.
- `.editorconfig` activo para tabulación/whitespace consistentes.

### Changed
- `SaveManager` agrega/aplica providers locales y mantiene el estado global desacoplado de sistemas concretos.
- `StorageProvider.scope_id` limita redes de almacenamiento por contexto.
- Dependencias entre escenas prefieren contratos/tipos/grupos sobre nombres internos o `NodePath` relativos.
- El mundo deriva el ciclo visual del reloj global sin almacenar una copia de la hora.
- Hermano Aldren selecciona destinos y estados desde `ScheduleData` gobernado por `TimeManager`/`EventBus`.
- `Walking` es transitorio y conserva la actividad pendiente mientras el NPC navega.
- `NPCController.apply_save_data()` puede restaurar una ruta en curso; posteriores cambios de tiempo vuelven a gobernar la rutina.
- Los contratos de simulación que deben estar disponibles al entrar al árbol se activan desde `_enter_tree()`.
- El runner de tests difiere la ejecución de suites hasta después de inicializar `SceneTree`, permitiendo probar lifecycle real de escenas sin invocar manualmente callbacks.
- **Fase 5 — Simulación queda completada; Fase 6 — RPG pasa a estar activa.**

### Fixed
- Inferencias `Variant` incompatibles con el modo estricto de Godot 4.5.
- Recolección/crafting evitan pérdidas parciales mediante operaciones atómicas.
- Producción temporizada conserva outputs pendientes cuando storage está lleno.
- Preparación de cadáveres no muta `CorpseData` compartido.
- Persistencia de cementerio funciona bajo ejecución `--script` resolviendo Autoload desde `/root`.
- `SleepSpot`, crafting y componentes endurecidos contra ejecución off-tree.
- Código muerto `CemeteryService.RESULT_ALREADY_OCCUPIED` eliminado.
- Storage de scopes ajenos ya no participa automáticamente en crafting.
- Transición nocturna visual continua a través de medianoche.
- `DayNightController` resuelve dependencias globales de forma compatible con headless.
- Tests NPC ya no dependen del antiguo `initial_target`; validan `ScheduleData` real.
- `ScheduleEntryData` dejó de comparar el `Dictionary` de `TimeMath.normalize_total_minutes()` con enteros.
- `editorconfig` fue corregido a `.editorconfig`.
- El test integral de simulación dejó de producir falsos negativos por ejecutarse dentro de `SceneTree._initialize()`.

### Validated
- Fase 0: run `33278173612`, `success`.
- Fase 1: run `33280758441`, `success`.
- Fase 2: run `33285578050`, `success`.
- Fase 3: `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`, `success`.
- Fase 4: `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`, `success`.
- Fase 5 bloque 1: `62cb2658bd169270fffcb59c34134493b787f327`, run `33294728470`, `success`.
- Hardening: `b13d024143b5fb0ff8118a689da079c37916c554`, run `33295277286`, ambos jobs `success`.
- Fase 5 bloque 2: `5c6467c5aad04b1d44c48cceef2280af5d049bf8`, run `33295805020`, ambos jobs `success`.
- Fase 5 bloque 3: run `33296112250` detectó `class-definitions-order`; `03986401968c83b79527d15f47217f090de43ab2`, run `33296131085`, ambos jobs `success`.
- Fase 5 bloque 4: run `33296549903` detectó comparación `Dictionary`/`int`; `82f5ccee1e109e2ad702532b7301922124548c7b`, run `33296648630`, ambos jobs `success`.
- Fase 5 bloque 5, implementación inicial `b8bd10cb2f014c64e4a9a5dbb30e6e041862d6be`: run `33297598359` falló aceptación integral por lifecycle prematuro del harness.
- `79670b23b1306031e21bf2a3403a90ced5edc383`: run `33297716722` mantuvo los 12 fallos y permitió aislar el problema al runner.
- Cierre Fase 5: `f0290951a27d5e66581da2532151d957ec35075e`, run `33297774458`, `gdscript-quality` y `validate-and-test` completamente en `success`.
