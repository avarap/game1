# CHANGELOG

## Unreleased

### Added
- Bootstrap Godot 4.x, cinco Autoloads globales, InputMap, logging, debug, guardado versionado, tests y CI headless.
- Walking prototype, items/inventario, energía, recursos, crafting, `StorageNetwork`, producción temporizada y cementerio persistente.
- Simulación completa: reloj/calendario, sueño, ciclo día/noche, `NPCData`, `NavigationAgent2D`, horarios/estados y persistencia NPC.
- `gdscript-quality` independiente con `gdlint` y `gdformat --check`.
- `LocalizationService` sobre `TranslationServer`, con idiomas iniciales `en` y `es` y fallback inglés.
- Catálogos `localization/en.po` y `localization/es.po` registrados en `project.godot`.
- Foundation de diálogo data-driven con `DialogueConditionData`, `DialogueOptionData`, `DialogueNodeData`, `DialogueData`, `DialogueService`, UI local y `DialogueInteractable`.
- Primer diálogo original bilingüe de Hermano Aldren.
- `LOCALIZATION.md` con la política de claves estables y ampliación de idiomas.
- `RelationshipData`, `RelationshipService` y `RelationshipController` para relaciones runtime 0-100 sin nuevo Autoload.
- Condición `RELATIONSHIP_MIN`, relación data-driven de Hermano Aldren y opción desbloqueada a relación 10.
- `HISTORIA_PRINCIPAL.md` como dirección narrativa de **El Cementerio de Valdeniebla**.
- Condiciones narrativas `HAS_ITEM`, `TIME_OF_DAY` y `QUEST_FLAG` en `DialogueConditionData`.
- Contexto de diálogo derivado del inventario relevante del actor, `TimeManager`, relaciones y futuro `quest_controller`.
- Opción nocturna bilingüe de Aldren disponible entre 22:00 y 06:00.
- `test_dialogue_conditions.gd` para inventario, horarios, cruce de medianoche, flags de quest e integración del diálogo nocturno.

### Changed
- `SaveManager` agrega/aplica providers locales y mantiene el estado global desacoplado de sistemas concretos.
- Storage se limita por scope y las dependencias entre escenas prefieren contratos/tipos/grupos.
- El runner de tests ejecuta suites después de inicializar `SceneTree` para probar lifecycle real.
- `world.tscn` incorpora diálogo y relaciones como sistemas contextuales.
- Hermano Aldren obtiene narrativa desde Resources de diálogo, sin codificarla en `NPCController`.
- Los textos de diálogo se resuelven por claves de traducción; grafo, condiciones e IDs son independientes del idioma.
- `DialogueInteractable` compone un snapshot contextual en vez de acoplar `DialogueService` a inventario, reloj, relaciones o quests.
- `TIME_OF_DAY` utiliza inicio inclusivo/final exclusivo y soporta ventanas que cruzan medianoche.
- `HISTORIA_PRINCIPAL.md` pasa de una propuesta con revelaciones explícitas a una **versión 2.0 canónica spoiler-light**: fija tono, personajes, tensiones y estructura, pero omite culpables, identidades ocultas, explicación final del misterio y finales concretos.
- La narrativa adopta como reglas perspectivas parciales, pistas con varias interpretaciones y flags que describen hechos observados en lugar de conclusiones.
- Las próximas quests del Acto 1 deben introducir misterio mediante consecuencias del trabajo cotidiano, sin resolverlo de forma prematura.
- El quality gate cubre localización, diálogo, relaciones, condiciones narrativas y sus tests.
- **Fase 6 sigue activa: diálogo, ES/EN, relaciones y condiciones narrativas están validados; quests es el siguiente bloque.**

### Fixed
- Inferencias `Variant` incompatibles con Godot 4.5 y fallos históricos de atomicidad/lifecycle documentados en fases anteriores.
- `ScheduleEntryData` dejó de comparar el `Dictionary` de `TimeMath.normalize_total_minutes()` con enteros.
- El test integral de simulación dejó de producir falsos negativos por ejecutarse dentro de `SceneTree._initialize()`.
- Run `33298684332` detectó formato pendiente en `test_dialogue_foundation.gd`; se corrigió sin relajar el gate.
- Run `33299203135` detectó formato pendiente en `DialogueInteractable`; se corrigió en `fc446609004ea8031903c1c529144743cd963e51`.

### Validated
- Fase 0: run `33278173612`, `success`.
- Fase 1: run `33280758441`, `success`.
- Fase 2: run `33285578050`, `success`.
- Fase 3: `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`, `success`.
- Fase 4: `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`, `success`.
- Fase 5 cierre: `f0290951a27d5e66581da2532151d957ec35075e`, run `33297774458`, ambos jobs `success`.
- Fase 6 bloque 1 final: `46a37e00c2ad968e91834da5577a6f512a28f0a9`, run `33298737838`, ambos jobs `success`.
- Fase 6 bloque 2 final: `fc446609004ea8031903c1c529144743cd963e51`, run `33299277228`, ambos jobs `success`.
- Condiciones narrativas: `e1a19343e8303d1b28188a2a38c559d788c8087d`, run `33299990183`, ambos jobs `success`.
