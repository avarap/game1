# ROADMAP

## Fase 0 — Bootstrap — COMPLETADA
- [x] Repositorio, Godot 4.x, escena raíz, estructura y Autoloads mínimos.
- [x] InputMap, logging, debug, persistencia inicial, tests y CI headless.
- Validación: `33278173612`.

## Fase 1 — Core / Walking Prototype — COMPLETADA
- [x] Mundo base, `CharacterBody2D`, movimiento 8 direcciones, cámara, colisiones y Y-sort.
- [x] `Interactable` reutilizable y aceptación de escenas.
- Validación: `33280758441`.

## Fase 2 — Items / Resource Loop — COMPLETADA
- [x] `ItemData`, inventario, stacks/capacidad, energía, recursos, herramientas y loot.
- [x] Tests del loop completo.
- Cierre: `c196e3ab5a42adffe97278f0b0daa8960c789e04`, run `33285578050`.

## Fase 3 — Crafting / Production Loop — COMPLETADA
- [x] Recetas data-driven, crafting atómico, `StorageNetwork` y producción temporizada.
- [x] Tests y CI final verdes.
- Cierre: `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`.

## Fase 4 — Cementerio — COMPLETADA
- [x] Cadáveres, descomposición, tumbas, rating, preparación/entierro/mejoras y persistencia.
- [x] Tests de aceptación y CI final verdes.
- Cierre: `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`.

## Fase 5 — Simulación — COMPLETADA
- [x] Reloj/calendario, ciclo día/noche y sueño.
- [x] `NPCData`, `NavigationAgent2D`, horarios, estados y persistencia NPC.
- [x] Aceptación integral y CI final verdes.
- Cierre: `f0290951a27d5e66581da2532151d957ec35075e`, run `33297774458`.

## Fase 6 — RPG — COMPLETADA

### Criterios de aceptación
- [x] Diálogos, condiciones y opciones funcionan desde datos.
- [x] El mismo grafo de diálogo funciona en inglés y español mediante claves estables.
- [x] Relaciones cambian y desbloquean contenido.
- [x] Quests pueden iniciarse, progresar y completarse.
- [x] Las recompensas de quests se conceden una sola vez.
- [x] La economía compra y vende correctamente.
- [x] Las tecnologías consumen puntos y desbloquean contenido.
- [x] Estado RPG completo persistente compatible con `SaveManager`.
- [x] Tests de aceptación del flujo RPG mínimo.
- [x] `gdscript-quality` verde sobre el HEAD funcional final de la fase.
- [x] CI funcional final verde antes de cerrar la fase.

### Política de localización
- Idiomas iniciales: `en` y `es`; fallback `en`.
- `TranslationServer` + `LocalizationService`, sin nuevo Autoload.
- IDs, condiciones, progreso y saves nunca dependen de texto traducido.
- Ver `LOCALIZATION.md`.

### Fuente narrativa
- `HISTORIA_PRINCIPAL.md` define la dirección canónica de **El Cementerio de Valdeniebla**.
- El documento y la implementación son deliberadamente spoiler-light.
- El Acto 1 debe introducir misterio mediante el trabajo cotidiano y cerrar preguntas, no resolver el misterio central.
- Los flags narrativos describen hechos observados, no interpretaciones verdaderas.

### Bloque 1 — Foundation de diálogo bilingüe — COMPLETADO
- [x] Resources tipados de diálogo + `DialogueService` puro.
- [x] `DialogueController` local, ES/EN en runtime y primer diálogo de Aldren.
- [x] Tests de foundation/gameplay y quality gate.
- Final: `46a37e00c2ad968e91834da5577a6f512a28f0a9`, run `33298737838`.

### Bloque 2 — Foundation de relaciones — COMPLETADO
- [x] `RelationshipData`, `RelationshipService`, `RelationshipController`, rango 0–100.
- [x] `RELATIONSHIP_MIN` integrado en diálogo.
- [x] Tests de rango, clamp y contenido desbloqueable.
- Final: `fc446609004ea8031903c1c529144743cd963e51`, run `33299277228`.

### Bloque 2B — Integración narrativa y condiciones contextuales — COMPLETADO
- [x] `HAS_ITEM`, `TIME_OF_DAY`, `QUEST_FLAG` y contexto desacoplado.
- [x] Opción nocturna real de Aldren y tests de condiciones.
- Final: `e1a19343e8303d1b28188a2a38c559d788c8087d`, run `33299990183`.

### Bloque 3 — Foundation de quests — COMPLETADO
- [x] `QuestObjectiveData`, `QuestRewardData`, `QuestData` y `QuestService` tipados/data-driven.
- [x] Estados `unavailable` → `active` → `completed` y dependencias.
- [x] Progreso por inventario con objetivo `ITEM_COUNT`.
- [x] Recompensas idempotentes con persistencia del estado `reward_claimed`.
- [x] `QuestController` local, `save_provider` y contexto `quest_flags` para diálogo.
- [x] `DialogueOptionData` soporta acciones `START` / `TURN_IN` sin mover lógica de negocio a UI.
- [x] Primera quest de Aldren jugable: diálogo → preparar 2 tablas → volver → completar → recompensa narrativa una sola vez.
- [x] Texto EN/ES y narrativa spoiler-light.
- [x] `test_quests.gd` + `test_quest_gameplay.gd` cubren estados, progreso, integración, recompensa y snapshot.
- [x] Quality gate ampliado a quests.
- Implementación inicial: `1745b106ff366c6d8c98014b905f9069613ee271`.
- Correcciones de lint/formato: `6fb3d7de1046433d08e1dd98759c378940ee0ef3` y posteriores.
- Final funcional: `979b2328cc01c8d5a7a0ae4201deabe58cf9cc38`.
- Validación: `Godot CI` run `33301533785`, `gdscript-quality` y `validate-and-test` en `success`.

### Bloque 4 — Foundation de economía — COMPLETADO
- [x] Cobre como unidad monetaria interna; `100 cobre = 1 plata`, `100 plata = 1 oro`.
- [x] `WalletState`, ofertas, `MerchantData`, `MerchantState`, `EconomyTransaction` y `EconomyService` puros/data-driven.
- [x] Compra/venta atómica con inventario, validando fondos, stock y capacidad antes del commit.
- [x] `EconomyController` local + `save_provider`; primer comerciante `yard_supplier` con madera y tablas.
- [x] Persistencia de saldo, `merchant_id` y stock mediante el contrato genérico de `SaveManager`.
- [x] Rechazo de transacciones stale y rollback de inventario ante fallo de commit.
- [x] `test_economy_foundation.gd` + `test_economy_gameplay.gd` cubren lógica pura, integración, atomicidad y snapshot.
- [x] Quality gate ampliado a economía e inventario tocado.
- Foundation pura inicial: PR #11, merge `102a1f8fd0d4188677937baa937bd5a8e063e6e4`.
- Integración gameplay: `c1379f2d65f768b15d39df416fbe95d5f87c3409`.
- Correcciones quality/formato: `c371147bf0f716c038eeef245ad6f7294421871e` y `91f66bed3621fc8f8577c1553d755d010bc58dff`.
- Final validado: `184f2b6d9df6d0b26dcfeb7d2a2d8e3dc7604863`, run `33304080534`, ambos jobs `success`.

### Bloque 5 — Foundation de tecnologías — COMPLETADO
- [x] Puntos de progreso rojo, verde y azul como enteros no negativos.
- [x] `TechnologyData` data-driven con ID estable, categoría, costes y unlock IDs.
- [x] `TechnologyService` puro para registrar tecnologías, validar puntos y desbloquear cada tecnología una sola vez.
- [x] El desbloqueo consume exactamente los puntos requeridos y una operación rechazada no modifica el estado.
- [x] Contenido desbloqueado expuesto mediante IDs estables, independiente de UI y texto.
- [x] `TechnologyController` local + `save_provider`, sin nuevo Autoload.
- [x] Primera tecnología mínima `sturdy_joinery`, que desbloquea `recipe_reinforced_fence`.
- [x] Persistencia de puntos y tecnologías desbloqueadas; el contenido desbloqueado se reconstruye desde los datos registrados.
- [x] `test_technology_foundation.gd` + `test_technology_gameplay.gd` cubren costes, idempotencia, rechazo sin puntos, integración de mundo y snapshot.
- [x] Quality gate ampliado a tecnología y tests.
- Implementación: `572e640f522b3c0fc788bc3cd3acd0c1b2832147`.
- Corrección de orden para `gdlint`: `57a9fec427e171faf629e485a143f546dfc6f783`.
- Diagnóstico de formato: `ac13542a37641ce420567708e0a0cbf6b1a25996`.
- Final validado: `444fc2995ab14b293188aba54a0f4099dc3c36b3`, run `33305211363`, ambos jobs `success`.
- Los prerequisitos, el árbol tecnológico y la UI completa quedan fuera de esta foundation mínima.

### Bloque 6 — Aceptación integral y cierre — COMPLETADO
- [x] `test_rpg_acceptance.gd` ejercita relaciones, quest, economía y tecnología sobre `world.tscn` real.
- [x] Roundtrip conjunto mediante `SaveManager` comprueba providers `relationships`, `quests`, `economy` y `technology` en un único save.
- [x] Tras cargar, se restauran relación, quest/flag/recompensa reclamada, saldo/stock y puntos/unlocks tecnológicos.
- [x] Recompensa de quest y desbloqueo tecnológico siguen siendo idempotentes después del load.
- [x] Test integrado incorporado al runner y al quality gate.
- Incidencias: run `33305661192` detectó una línea >100; run `33305708696` reveló acceso no resoluble al Autoload desde `--script` y EOF no canónico. Se corrigió el test sin tocar producción ni relajar gates.
- Cierre funcional: `cc1351048609a474cedd524543f6c4370c46bea4`, run `33305899447`, ambos jobs `success`.

## Fase 7 — Mundo — ACTIVA
Pueblo, bosque, mina, interiores, exploración y secretos.

### Próximo bloque
Definir e implementar el primer bloque mínimo coherente de mundo siguiendo el master spec, sin adelantar polish de Fase 8.

## Fase 8 — Polish
Arte, animaciones, shaders, partículas, audio, feedback, UI final y optimización.
