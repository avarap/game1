# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase completada más reciente: **Fase 6 — RPG**
- Fase activa: **Fase 7 — Mundo**
- Estado Fase 6: **COMPLETADA**. Diálogo bilingüe, relaciones, condiciones narrativas, quests, economía, tecnologías y persistencia RPG integral están validados conjuntamente.
- Fuente funcional/arquitectónica: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Fuente narrativa: `HISTORIA_PRINCIPAL.md` — **El Cementerio de Valdeniebla**, canónica y spoiler-light.
- Política de idiomas: `LOCALIZATION.md`.
- Último bloque funcional de Fase 6: `cc1351048609a474cedd524543f6c4370c46bea4`.
- Última validación funcional de Fase 6: `Godot CI` run `33305899447`, `success` en `gdscript-quality` y `validate-and-test`.

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

### Fase 6 — RPG
Diálogo/localización, relaciones, condiciones narrativas, quests, economía, tecnologías y persistencia conjunta mediante `SaveManager`. Cierre funcional `cc1351048609a474cedd524543f6c4370c46bea4`, run `33305899447`.

## Fase 6 — RPG — COMPLETADA

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

### Bloque 4 — Foundation de economía — COMPLETADO

1. `MoneyMath` usa cobre como unidad base y mantiene conversiones deterministas: `100 cobre = 1 plata`, `100 plata = 1 oro`.
2. `WalletState` mantiene saldo entero no negativo, validación de fondos, crédito/débito, clonación y aplicación de estado.
3. `MerchantOfferData` define IDs estables y precios enteros de compra/venta; `MerchantData` agrupa ofertas y stock inicial desacoplados de NPC/UI.
4. `MerchantState` mantiene stock lógico no negativo por `item_id`.
5. `EconomyService` es lógica pura: simula compra/venta, valida fondos/stock y produce `EconomyTransaction` antes de aplicar cambios.
6. Las transacciones rechazan estado obsoleto: una operación simulada no puede aplicarse si wallet o stock cambiaron entre simulación y commit.
7. `InventoryModel`/`InventoryComponent` exponen `can_add_item()` para validar capacidad antes de mutar una compra.
8. `EconomyController` es local, pertenece a `economy_controller` y `save_provider`, integra wallet + comerciante + inventario sin nuevo Autoload.
9. Compra inválida por fondos, stock o capacidad no modifica dinero, stock ni inventario; los fallos durante commit restauran los cambios de inventario.
10. Venta exige stock real del jugador y actualiza dinero, inventario y stock del comerciante de forma coordinada.
11. Primer comerciante data-driven: `yard_supplier`, con ofertas de madera y tablas y stock inicial definido en `data/economy/yard_supplier.tres`.
12. La economía persiste bajo `get_save_key() == "economy"`: saldo, `merchant_id` y stock del comerciante se restauran mediante el contrato genérico de `SaveManager`.
13. `test_economy_foundation.gd` cubre matemáticas monetarias, invariantes, compra/venta pura, atomicidad y rechazo de transacciones stale.
14. `test_economy_gameplay.gd` cubre el mundo real: compra, venta, inventario lleno atómico, stock, saldo y snapshot persistente.
15. `world.tscn` incorpora `EconomyController` contextual; no se implementaron fluctuaciones, múltiples comerciantes ni UI comercial final.

#### Incidencias del bloque
- PR #11 / merge `102a1f8fd0d4188677937baa937bd5a8e063e6e4`: foundation pura inicial validada, todavía sin inventario/persistencia/world integration.
- Commit `c1379f2d65f768b15d39df416fbe95d5f87c3409`: integración persistente completa. Run `33303874511`: importación, smoke y tests verdes; `gdlint` detectó exceso de returns en `EconomyController.buy()`.
- `c371147bf0f716c038eeef245ad6f7294421871e`: refactoriza commit de compra/venta sin alterar comportamiento; `gdlint` pasa y queda pendiente formato.
- Runs `33303932566` / `33303999957`: `gdformat` detectó formato no canónico; se mantuvo el gate estricto.
- Commit diagnóstico `1dbdd8640ae39de9cd634c172f618319f86c71fa` usó `gdformat --diff` para aislar la única diferencia restante; el workflow completo se restauró después.
- Formato final aplicado en `91f66bed3621fc8f8577c1553d755d010bc58dff` y quality gate restaurado en `184f2b6d9df6d0b26dcfeb7d2a2d8e3dc7604863`.
- Validación final: `Godot CI` `33304080534`, `gdscript-quality` y `validate-and-test` en `success`.

### Bloque 5 — Foundation de tecnologías — COMPLETADO

1. `TechnologyData` define ID estable, una de las siete categorías del master, costes rojo/verde/azul y una lista de unlock IDs.
2. `TechnologyService` mantiene puntos rojo, verde y azul como enteros no negativos y registra datos tecnológicos sin depender de escenas/UI.
3. `unlock()` valida existencia, idempotencia y saldo antes de mutar; un desbloqueo válido consume exactamente los puntos requeridos.
4. Un segundo desbloqueo devuelve `already_unlocked` y no vuelve a consumir puntos.
5. Un desbloqueo sin saldo suficiente devuelve `insufficient_points` y deja el snapshot idéntico.
6. Los IDs de contenido desbloqueado se derivan de `TechnologyData`; no se persiste texto ni estado de UI.
7. `snapshot()` guarda balances y tecnologías desbloqueadas; `apply_snapshot()` valida primero y reconstruye los unlock IDs desde los datos registrados.
8. `TechnologyController` es local, pertenece a `technology_controller` y `save_provider`, y persiste con `get_save_key() == "technology"`.
9. Primera tecnología mínima: `sturdy_joinery`, categoría Construcción, coste 2 rojo + 1 verde, que desbloquea `recipe_reinforced_fence`.
10. `world.tscn` incorpora `TechnologyController` con puntos iniciales 3 rojo, 2 verde y 1 azul.
11. `test_technology_foundation.gd` cubre costes exactos, idempotencia, rechazo sin puntos y snapshot.
12. `test_technology_gameplay.gd` cubre integración real de mundo, contrato de persistencia y restauración.
13. El quality gate incluye datos, servicio, controller y tests de tecnología.
14. Prerequisitos, árbol tecnológico, UI de tecnologías y contenido masivo quedan explícitamente fuera de esta foundation mínima.

#### Incidencias del bloque
- RED TDD confirmado en run `33304394505`: todas las suites previas seguían verdes y las nuevas suites fallaban porque aún no existían `TechnologyData`/`TechnologyService`.
- Implementación principal: `572e640f522b3c0fc788bc3cd3acd0c1b2832147`.
- Run `33304983995`: importación, smoke y suite funcional verdes; `gdlint` exigió ordenar `PointType` antes de constantes.
- `57a9fec427e171faf629e485a143f546dfc6f783` corrige el orden global sin cambiar comportamiento.
- Run `33305055491`: gameplay verde y `gdlint` verde; quedó una única diferencia de `gdformat` en el diccionario anidado del snapshot.
- `ac13542a37641ce420567708e0a0cbf6b1a25996` añadió temporalmente `gdformat --diff` para aislar la diferencia exacta.
- `444fc2995ab14b293188aba54a0f4099dc3c36b3` aplica el formato canónico y restaura el quality gate normal.
- Validación final: `Godot CI` `33305211363`, `gdscript-quality` y `validate-and-test` en `success`.

### Bloque 6 — Aceptación integral y cierre — COMPLETADO

1. `test_rpg_acceptance.gd` instancia `world.tscn` y usa los controllers reales de relaciones, quests, economía y tecnología.
2. El flujo cambia relación con Aldren, completa `aldren_first_duty`, realiza una compra y desbloquea `sturdy_joinery`.
3. Un único `SaveManager.save_game()` agrega los providers `relationships`, `quests`, `economy` y `technology`.
4. Tras mutar el estado y ejecutar `SaveManager.load_game()`, se restauran relación, quest completada y flags, wallet/stock, puntos y unlocks.
5. La recompensa de quest permanece reclamada después del load y no puede duplicarse.
6. Una tecnología ya desbloqueada devuelve `already_unlocked` después del load y no vuelve a consumir puntos.
7. `test_rpg_acceptance.gd` forma parte de `tests/run_tests.gd` y del quality gate.
8. No fue necesario modificar producción: el contrato genérico existente de `SaveManager` ya soportaba el roundtrip integral.

#### Incidencias del bloque
- Run `33305661192`: `gdlint` detectó una línea del nuevo test >100 caracteres; se corrigió sin relajar el gate.
- Run `33305708696`: importación y smoke verdes, pero el runner `--script` no resolvía el identificador global `SaveManager`; el test pasó a obtener el Autoload desde `/root/SaveManager`.
- El mismo ciclo mostró formato no canónico únicamente por EOF en `test_rpg_acceptance.gd` y `run_tests.gd`; se aplicó el formato canónico y se restauró `gdformat --check` estricto.
- Cierre funcional: `cc1351048609a474cedd524543f6c4370c46bea4`.
- Validación: `Godot CI` `33305899447`; `gdlint`, `gdformat`, importación Godot, smoke y suite headless completos en `success`.

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
- `SaveManager` agrega providers locales; quests, economía y tecnología usan keys independientes dentro del estado de mundo agregado.
- Recompensas de quests deben seguir siendo idempotentes cuando se añadan nuevos tipos de recompensa.
- Dinero y precios se representan exclusivamente como enteros en cobre; UI futura solo formatea oro/plata/cobre.
- Puntos tecnológicos se representan como enteros no negativos rojo/verde/azul.
- Los desbloqueos tecnológicos se identifican por IDs estables de contenido; la UI/árbol futuro no será fuente de verdad.
- Prerequisitos tecnológicos, árbol visual y contenido masivo no forman parte de la foundation mínima ya cerrada; solo introducirlos si una fase futura los exige.
- Economía dinámica, fluctuaciones de precio y múltiples comerciantes quedan fuera hasta fases posteriores/expansión de alcance.
- No introducir alcance de Fase 8 durante Fase 7.

## Fase 7 — Mundo — ACTIVA

Objetivo de alto nivel según `ROADMAP.md`: pueblo, bosque, mina, interiores, exploración y secretos.

## Próximo bloque — Fase 7

1. Releer la sección de Mundo del master spec antes de implementar.
2. Elegir el primer bloque mínimo y coherente de expansión del mundo que pueda validarse de extremo a extremo.
3. Mantener reutilizables los sistemas ya cerrados; no reabrir Fase 6 salvo regresión demostrada.
4. No adelantar arte/polish de Fase 8.
5. Añadir criterios y tests específicos del bloque antes de marcar progreso de Fase 7.

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
