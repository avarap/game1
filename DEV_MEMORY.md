# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase completada más reciente: **Fase 5 — Simulación**
- Fase activa: **Fase 6 — RPG**
- Estado Fase 6: diálogo bilingüe, relaciones, condiciones narrativas y **foundation de quests** completados y validados; economía y tecnologías siguen pendientes.
- Fuente funcional/arquitectónica: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Fuente narrativa: `HISTORIA_PRINCIPAL.md` — **El Cementerio de Valdeniebla**, canónica y spoiler-light.
- Política de idiomas: `LOCALIZATION.md`.
- Último bloque funcional: `979b2328cc01c8d5a7a0ae4201deabe58cf9cc38`.
- Última validación: `Godot CI` run `33301533785`, `success` en `gdscript-quality` y `validate-and-test`.

## Fases completadas

### Fase 0 — Bootstrap
Godot 4.x, estructura, cinco Autoloads (`EventBus`, `GameManager`, `TimeManager`, `SaveManager`, `AudioManager`), InputMap, logging, guardado, tests y CI. Run final: `33278173612`.

### Fase 1 — Core
Movimiento 8 direcciones, cámara, colisiones, Y-sort e interacción reutilizable. Run final: `33280758441`.

### Fase 2 — Items
`ItemData`, inventario, energía, recursos, herramientas, loot y atomicidad. Commit final `c196e3ab5a42adffe97278f0b0daa8960c789e04`, run `33285578050`.

### Fase 3 — Crafting
Recetas tipadas, crafting, `StorageNetwork`, cofres y producción temporizada. Commit final `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`.

### Fase 4 — Cementerio
Cadáveres, preparación, tumbas, rating, mejoras y persistencia. Commit final `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`.

### Fase 5 — Simulación
Tiempo/calendario, sueño, día/noche, `NPCData`, navegación, horarios/estados y persistencia NPC. Cierre `f0290951a27d5e66581da2532151d957ec35075e`, run `33297774458`.

## Fase 6 — RPG — ACTIVA

### Bloque 1 — Diálogo + localización — COMPLETADO
- Resources tipados de diálogo y `DialogueService` puro.
- `DialogueController` local con ES/EN sobre `TranslationServer`.
- Primer diálogo de Hermano Aldren data-driven.
- Final `46a37e00c2ad968e91834da5577a6f512a28f0a9`, run `33298737838`.

### Bloque 2 — Relaciones — COMPLETADO
- `RelationshipData`, `RelationshipService`, `RelationshipController`, rango 0–100.
- Condición `RELATIONSHIP_MIN` integrada con diálogo.
- Final `fc446609004ea8031903c1c529144743cd963e51`, run `33299277228`.

### Bloque 2B — Condiciones contextuales — COMPLETADO
- Condiciones `FLAG`, `RELATIONSHIP_MIN`, `HAS_ITEM`, `TIME_OF_DAY`, `QUEST_FLAG`.
- Contexto desacoplado desde inventario, tiempo, relaciones y quests.
- Opción nocturna real de Aldren y tests de condiciones.
- Final `e1a19343e8303d1b28188a2a38c559d788c8087d`, run `33299990183`.

### Bloque 3 — Foundation de quests — COMPLETADO

1. `QuestObjectiveData` define objetivos tipados; primera implementación: `ITEM_COUNT`.
2. `QuestRewardData` define recompensas tipadas; primera implementación: `QUEST_FLAG`.
3. `QuestData` contiene ID estable, NPC otorgante, claves localizadas, objetivos, recompensas y dependencias.
4. `QuestService` es lógica pura y soporta transiciones `unavailable` → `active` → `completed`.
5. El progreso de objetivos se mantiene acotado y las dependencias deben estar completas antes de iniciar una quest.
6. `claim_rewards()` es idempotente mediante `reward_claimed`; una recompensa no puede aplicarse dos veces, incluso después de restaurar snapshot.
7. `QuestController` es local, pertenece a `quest_controller` y `save_provider`, sincroniza objetivos de inventario y expone `quest_flags` al diálogo.
8. `DialogueOptionData` soporta acciones de quest `START` y `TURN_IN`; `DialogueController` emite `option_committed` y no ejecuta lógica de negocio directamente.
9. El jugador se registra en el grupo `player` para resolución contextual sin rutas rígidas.
10. Primera quest jugable: `aldren_first_duty`. Se inicia hablando con Aldren, requiere preparar 2 tablas y se entrega de nuevo mediante diálogo.
11. La quest mantiene la política spoiler-light: empieza como trabajo cotidiano y solo deja una irregularidad observable menor al completarla.
12. Estado de quest y flags se persisten mediante el contrato genérico `save_provider` de `SaveManager`.
13. `test_quests.gd` cubre estados, progreso, idempotencia y snapshot.
14. `test_quest_gameplay.gd` cubre el loop real diálogo → quest → inventario → entrega → recompensa → persistencia.
15. `.github/workflows/ci.yml` incorpora todos los scripts/tests de quests al quality gate.

#### Incidencias del bloque
- Run `33301360854`: gameplay/import/smoke/tests verdes; `gdlint` detectó una línea >100 caracteres en `test_quest_gameplay.gd`.
- Commit `6fb3d7de1046433d08e1dd98759c378940ee0ef3`: corrige longitud de línea.
- Runs posteriores detectaron formato no canónico en `QuestData`/`QuestController`; no se relajó el gate.
- `QuestController` se simplificó para mantener formato canónico y menor complejidad accidental.
- Final funcional: `979b2328cc01c8d5a7a0ae4201deabe58cf9cc38`.
- Validación final: `Godot CI` `33301533785`, ambos jobs `success`.

## Dirección narrativa vigente

- `HISTORIA_PRINCIPAL.md` es deliberadamente spoiler-light.
- No documentar culpables, identidades ocultas, naturaleza final del misterio ni finales en archivos públicos de producción cuando no sea imprescindible.
- Las pistas importantes deben admitir varias interpretaciones inicialmente.
- Flags narrativos describen hechos observados, no conclusiones (`read_old_register`, no `npc_is_traitor`).
- La historia debe surgir del gameplay cotidiano y no de grandes bloques expositivos.

## Decisiones vigentes

- Mantener exactamente cinco Autoloads globales.
- `TimeManager` es la única fuente de reloj/calendario.
- NPCs, diálogo, relaciones, quests, economía y tecnología permanecen locales/contextuales.
- IDs, condiciones, saves y progreso son independientes del idioma.
- UI observa servicios/modelos y emite intents; no posee lógica de negocio.
- Gameplay data-driven mediante Resources tipados cuando corresponda.
- Lógica crítica pura y testeable de forma aislada.
- `SaveManager` agrega providers locales; las quests usan `get_save_key() == "quests"` dentro del estado de mundo agregado.
- Recompensas de quests deben seguir siendo idempotentes cuando se añadan nuevos tipos de recompensa.
- No abrir tecnologías antes de estabilizar economía.
- No introducir alcance de Fase 7/8 durante Fase 6.

## Criterios restantes de Fase 6

1. ~~Quests pueden iniciarse, progresar y completarse.~~ COMPLETADO.
2. ~~Recompensas se conceden exactamente una vez.~~ COMPLETADO.
3. Economía compra/vende correctamente.
4. Tecnologías consumen puntos y desbloquean contenido.
5. Estado RPG completo persiste de forma compatible con `SaveManager`.
6. Aceptación integral de Fase 6 y CI final verdes.

## Próximo bloque — Fase 6

**Foundation de economía**, sin abrir todavía tecnologías:

1. Representación monetaria estable usando cobre como unidad base y conversión `100 cobre = 1 plata`, `100 plata = 1 oro`.
2. Servicio puro para saldo, compra, venta y validación de fondos/stock.
3. Datos de comerciante/precios desacoplados de UI y NPC controller.
4. Una integración mínima con inventario existente que sea atómica: una compra/venta inválida no modifica dinero ni inventario.
5. Persistencia mediante provider local compatible con `SaveManager`.
6. Tests puros + integración mínima + quality gate.
7. No implementar fluctuaciones dinámicas ni múltiples comerciantes hasta validar la foundation.

## Regla de continuidad

Al retomar:
1. Leer `DEV_MEMORY.md`, `ROADMAP.md`, `HISTORIA_PRINCIPAL.md` y `LOCALIZATION.md`.
2. Consultar la fase activa en el master spec.
3. Revisar `main` y el último CI.
4. Implementar un bloque coherente y pequeño.
5. Ejecutar quality gate, importación, smoke test y suite headless.
6. Corregir errores antes de avanzar.
7. Actualizar `DEV_MEMORY.md`, `ROADMAP.md` y `CHANGELOG.md`.
8. No marcar una fase completa hasta cumplir todos sus criterios.
