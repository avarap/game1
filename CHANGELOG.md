# CHANGELOG

## Unreleased

### Added
- Bootstrap Godot 4.x, cinco Autoloads globales, InputMap, logging, debug, guardado versionado, tests y CI headless.
- Walking prototype, items/inventario, energía, recursos, crafting, `StorageNetwork`, producción temporizada y cementerio persistente.
- Simulación completa: reloj/calendario, sueño, ciclo día/noche, `NPCData`, `NavigationAgent2D`, horarios/estados y persistencia NPC.
- `gdscript-quality` independiente con `gdlint` y `gdformat --check`.
- `LocalizationService` sobre `TranslationServer`, con idiomas iniciales `en` y `es` y fallback inglés.
- Catálogos `localization/en.po` y `localization/es.po` registrados en `project.godot`.
- `DialogueConditionData`, `DialogueOptionData`, `DialogueNodeData` y `DialogueData` para diálogos data-driven.
- `DialogueService` puro para resolver condiciones, opciones y navegación por el grafo.
- `DialogueController` local con UI mínima y selector técnico ES/EN en runtime.
- `DialogueInteractable` reutilizando el contrato `Interactable`.
- Primer diálogo original bilingüe de Hermano Aldren en `data/dialogues/brother_aldren/introduction.tres`.
- `test_dialogue_foundation.gd` y `test_dialogue_gameplay.gd`.
- `LOCALIZATION.md` con la política de claves estables y ampliación de idiomas.
- `RelationshipData`, `RelationshipService` y `RelationshipController` para relaciones runtime 0-100 sin nuevo Autoload.
- Condición de diálogo `RELATIONSHIP_MIN` y relación data-driven de Hermano Aldren.
- Opción bilingüe de Aldren desbloqueada al alcanzar relación 10, cubierta por `test_relationships.gd`.

### Changed
- `SaveManager` agrega/aplica providers locales y mantiene el estado global desacoplado de sistemas concretos.
- Storage se limita por scope y las dependencias entre escenas prefieren contratos/tipos/grupos.
- El runner de tests ejecuta suites después de inicializar `SceneTree` para probar lifecycle real.
- `world.tscn` incorpora la capa de diálogo local y un `RelationshipController` contextual.
- Hermano Aldren incorpora un `DialogueInteractable` con un recurso de diálogo, sin codificar narrativa en `NPCController`.
- `DialogueInteractable` incorpora el contexto de relaciones al iniciar el diálogo.
- Los textos de diálogo se resuelven por claves de traducción; el grafo, condiciones e IDs son independientes del idioma.
- El quality gate cubre la foundation de localización/diálogo, relaciones y sus tests.
- **Fase 5 — Simulación está completada; Fase 6 — RPG sigue activa.**

### Fixed
- Inferencias `Variant` incompatibles con Godot 4.5 y fallos históricos de atomicidad/lifecycle documentados en fases anteriores.
- `ScheduleEntryData` dejó de comparar el `Dictionary` de `TimeMath.normalize_total_minutes()` con enteros.
- El test integral de simulación dejó de producir falsos negativos por ejecutarse dentro de `SceneTree._initialize()`.
- Run `33298684332` detectó que `test_dialogue_foundation.gd` no cumplía `gdformat`; se corrigió sin relajar el gate.

### Validated
- Fase 0: run `33278173612`, `success`.
- Fase 1: run `33280758441`, `success`.
- Fase 2: run `33285578050`, `success`.
- Fase 3: `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`, `success`.
- Fase 4: `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`, `success`.
- Fase 5 cierre: `f0290951a27d5e66581da2532151d957ec35075e`, run `33297774458`, ambos jobs `success`.
- Fase 6 bloque 1 inicial: `60bc1e7e137fbbad61e8a6604aa52ae872b2415b`; run `33298684332` pasó importación, smoke y suite headless, pero falló únicamente `gdformat --check`.
- Fase 6 bloque 1 final: `46a37e00c2ad968e91834da5577a6f512a28f0a9`, run `33298737838`, `gdscript-quality` y `validate-and-test` en `success`.
- Fase 6 bloque 2 relaciones: implementación funcional `6d9eb1d54ab97ea92a8ee533bec1d9523ee2d1a5`; validación CI pendiente de este HEAD documental.
