# CHANGELOG

## Unreleased

### Added
- Bootstrap Godot 4.x, cinco Autoloads globales, InputMap, logging, debug, guardado versionado, tests y CI headless.
- Walking prototype, items/inventario, energía, recursos, crafting, `StorageNetwork`, producción temporizada y cementerio persistente.
- Simulación completa: reloj/calendario, sueño, ciclo día/noche, `NPCData`, `NavigationAgent2D`, horarios/estados y persistencia NPC.
- `LocalizationService` sobre `TranslationServer`, con `en`/`es` y fallback inglés.
- Foundation de diálogo data-driven y primer diálogo bilingüe de Hermano Aldren.
- `RelationshipData`, `RelationshipService` y `RelationshipController` para relaciones 0–100.
- Condiciones de diálogo `RELATIONSHIP_MIN`, `HAS_ITEM`, `TIME_OF_DAY` y `QUEST_FLAG`.
- `HISTORIA_PRINCIPAL.md` como dirección canónica spoiler-light de **El Cementerio de Valdeniebla**.
- `QuestObjectiveData`, `QuestRewardData`, `QuestData`, `QuestService` y `QuestController` para quests data-driven sin nuevo Autoload.
- Estados de quest `unavailable`, `active`, `completed`, dependencias, progreso por inventario y snapshots persistentes.
- Recompensas de quest idempotentes mediante estado `reward_claimed` persistente.
- Acciones `START` y `TURN_IN` en opciones de diálogo; `DialogueController` expone `option_committed` sin asumir lógica de quests.
- Primera quest jugable de Aldren, `aldren_first_duty`, localizada EN/ES: aceptar mediante diálogo, preparar dos tablas y entregar mediante diálogo.
- `test_quests.gd` y `test_quest_gameplay.gd` para estados, progreso, idempotencia, integración real y persistencia.

### Changed
- `SaveManager` agrega/aplica providers locales y mantiene sistemas de gameplay desacoplados.
- `world.tscn` incorpora diálogo, relaciones y quests como controllers contextuales.
- El jugador se registra en el grupo `player` para resolución contextual sin rutas rígidas.
- Los textos se resuelven por claves de traducción; IDs, condiciones, quests y saves son independientes del idioma.
- `DialogueInteractable` compone snapshots contextuales desde inventario, reloj, relaciones y quests.
- `HISTORIA_PRINCIPAL.md` es una versión canónica spoiler-light; las quests introducen misterio mediante observaciones, no revelaciones prematuras.
- El quality gate cubre ahora localización, diálogo, relaciones, condiciones narrativas, quests y sus tests.
- **Fase 6 sigue activa: diálogo, relaciones y quests están validados; economía es el siguiente bloque.**

### Fixed
- Inferencias `Variant` incompatibles con Godot 4.5 y fallos históricos de atomicidad/lifecycle documentados en fases anteriores.
- `ScheduleEntryData` dejó de comparar el `Dictionary` de `TimeMath.normalize_total_minutes()` con enteros.
- El test integral de simulación dejó de producir falsos negativos por ejecutarse dentro de `SceneTree._initialize()`.
- Run `33298684332`: formato pendiente en `test_dialogue_foundation.gd`, corregido sin relajar el gate.
- Run `33299203135`: formato pendiente en `DialogueInteractable`, corregido en `fc446609004ea8031903c1c529144743cd963e51`.
- Run `33301360854`: `test_quest_gameplay.gd` superaba el límite de 100 caracteres; corregido en `6fb3d7de1046433d08e1dd98759c378940ee0ef3`.
- Runs posteriores de quests detectaron formato no canónico en `QuestData`/`QuestController`; se corrigió simplificando el código en vez de relajar `gdformat`.

### Validated
- Fase 0: run `33278173612`, `success`.
- Fase 1: run `33280758441`, `success`.
- Fase 2: run `33285578050`, `success`.
- Fase 3: `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`, `success`.
- Fase 4: `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`, `success`.
- Fase 5: `f0290951a27d5e66581da2532151d957ec35075e`, run `33297774458`, ambos jobs `success`.
- Fase 6 diálogo: `46a37e00c2ad968e91834da5577a6f512a28f0a9`, run `33298737838`, ambos jobs `success`.
- Fase 6 relaciones: `fc446609004ea8031903c1c529144743cd963e51`, run `33299277228`, ambos jobs `success`.
- Condiciones narrativas: `e1a19343e8303d1b28188a2a38c559d788c8087d`, run `33299990183`, ambos jobs `success`.
- Foundation de quests: implementación inicial `1745b106ff366c6d8c98014b905f9069613ee271`, final funcional `979b2328cc01c8d5a7a0ae4201deabe58cf9cc38`, run `33301533785`, `gdscript-quality` y `validate-and-test` en `success`.
