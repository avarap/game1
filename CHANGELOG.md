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
- Representación monetaria entera con cobre como unidad base y conversión determinista a plata/oro.
- `WalletState`, `MerchantOfferData`, `MerchantData`, `MerchantState`, `EconomyTransaction` y `EconomyService` para economía pura y data-driven.
- `EconomyController` local con compra/venta integrada con inventario y persistencia mediante `save_provider`.
- Primer comerciante `yard_supplier`, con ofertas y stock inicial de madera y tablas en `data/economy/yard_supplier.tres`.
- `test_economy_foundation.gd` y `test_economy_gameplay.gd` para saldo, stock, atomicidad, transacciones stale, gameplay y snapshot.
- `TechnologyData` y `TechnologyService` para puntos rojo/verde/azul, desbloqueos idempotentes por ID y snapshots de progreso.
- `TechnologyController` local con `save_provider` y primera tecnología `sturdy_joinery`, que desbloquea `recipe_reinforced_fence`.
- `test_technology_foundation.gd` y `test_technology_gameplay.gd` para costes, rechazo sin puntos, idempotencia, integración de mundo y persistencia.
- `test_rpg_acceptance.gd` para aceptación conjunta de relaciones, quests, economía y tecnología mediante un único roundtrip de `SaveManager`.

### Changed
- `SaveManager` agrega/aplica providers locales y mantiene sistemas de gameplay desacoplados.
- `world.tscn` incorpora diálogo, relaciones, quests, economía y tecnología como controllers contextuales.
- El jugador se registra en el grupo `player` para resolución contextual sin rutas rígidas.
- Los textos se resuelven por claves de traducción; IDs, condiciones, quests y saves son independientes del idioma.
- `DialogueInteractable` compone snapshots contextuales desde inventario, reloj, relaciones y quests.
- `HISTORIA_PRINCIPAL.md` es una versión canónica spoiler-light; las quests introducen misterio mediante observaciones, no revelaciones prematuras.
- `InventoryModel` e `InventoryComponent` exponen comprobación de capacidad previa mediante `can_add_item()` para transacciones atómicas.
- El quality gate cubre ahora localización, diálogo, relaciones, condiciones narrativas, quests, economía, tecnología y aceptación RPG integral.
- **Fase 6 — RPG completada; Fase 7 — Mundo pasa a ser la fase activa.**

### Fixed
- Inferencias `Variant` incompatibles con Godot 4.5 y fallos históricos de atomicidad/lifecycle documentados en fases anteriores.
- `ScheduleEntryData` dejó de comparar el `Dictionary` de `TimeMath.normalize_total_minutes()` con enteros.
- El test integral de simulación dejó de producir falsos negativos por ejecutarse dentro de `SceneTree._initialize()`.
- Run `33298684332`: formato pendiente en `test_dialogue_foundation.gd`, corregido sin relajar el gate.
- Run `33299203135`: formato pendiente en `DialogueInteractable`, corregido en `fc446609004ea8031903c1c529144743cd963e51`.
- Run `33301360854`: `test_quest_gameplay.gd` superaba el límite de 100 caracteres; corregido en `6fb3d7de1046433d08e1dd98759c378940ee0ef3`.
- Runs posteriores de quests detectaron formato no canónico en `QuestData`/`QuestController`; se corrigió simplificando el código en vez de relajar `gdformat`.
- Run `33303874511`: la integración de economía era funcional y sus tests pasaban, pero `gdlint` detectó exceso de `return` en `EconomyController.buy()`; se extrajeron validación y commits de compra/venta.
- Runs `33303932566` y `33303999957`: `gdformat` detectó formato no canónico en `EconomyController`; se usó temporalmente `gdformat --diff` en `1dbdd8640ae39de9cd634c172f618319f86c71fa` para identificar la diferencia exacta y después se restauró el gate completo.
- `91f66bed3621fc8f8577c1553d755d010bc58dff` aplica el formato canónico final de economía sin modificar comportamiento.
- Run `33304983995`: tecnología pasó importación/smoke/tests, pero `gdlint` exigió ordenar `PointType` antes de constantes; corregido en `57a9fec427e171faf629e485a143f546dfc6f783`.
- Run `33305055491`: quedó una única diferencia de `gdformat` en `TechnologyService.snapshot()`; `ac13542a37641ce420567708e0a0cbf6b1a25996` aisló el diff y `444fc2995ab14b293188aba54a0f4099dc3c36b3` aplicó el formato canónico restaurando el gate normal.
- Run `33305661192`: el nuevo test de aceptación superaba el límite de 100 caracteres; se corrigió sin relajar `gdlint`.
- Run `33305708696`: el test accedía al Autoload por nombre global, no resoluble desde el runner `--script`; se cambió a resolución de `/root/SaveManager`. El mismo ciclo detectó EOF no canónico en dos tests, corregido manteniendo `gdformat --check` estricto.

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
- Foundation de economía: foundation pura merge `102a1f8fd0d4188677937baa937bd5a8e063e6e4`, integración gameplay `c1379f2d65f768b15d39df416fbe95d5f87c3409`, final validado `184f2b6d9df6d0b26dcfeb7d2a2d8e3dc7604863`, run `33304080534`, `gdscript-quality` y `validate-and-test` en `success`.
- Foundation de tecnologías: implementación `572e640f522b3c0fc788bc3cd3acd0c1b2832147`, final validado `444fc2995ab14b293188aba54a0f4099dc3c36b3`, run `33305211363`, `gdscript-quality` y `validate-and-test` en `success`.
- Cierre funcional de Fase 6: `cc1351048609a474cedd524543f6c4370c46bea4`, run `33305899447`, `gdscript-quality`, importación, smoke y suite headless en `success`.
