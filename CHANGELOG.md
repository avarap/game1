# CHANGELOG

## Unreleased

### Added
- Bootstrap Godot 4.x, cinco Autoloads globales, InputMap, logging, debug, guardado versionado, tests y CI headless.
- Walking prototype, items/inventario, energía, recursos, crafting, `StorageNetwork`, producción temporizada y cementerio persistente.
- Simulación: reloj/calendario, sueño, ciclo día/noche, `NPCData`, navegación, horarios/estados y persistencia NPC.
- Localización EN/ES, diálogo data-driven, relaciones, quests, economía y tecnologías como sistemas locales/contextuales.
- Primera quest jugable de Aldren, primer comerciante data-driven `yard_supplier` y primera tecnología `sturdy_joinery`.
- **#6 Comercio UI:** `TradeLayer`/`TradePanel`, `TradeInteractable` reutilizable, punto de comercio integrado, prompts/textos EN/ES y `test_trading_ui.gd`.
- **#8 Tecnología ↔ quests:** `QuestRewardData` admite recompensa tipada `TECHNOLOGY_POINTS`; `aldren_first_duty` concede 2 puntos rojos y 1 verde además de su `QUEST_FLAG`, con idempotencia tras save/load.
- **#9 Aceptación RPG final:** `test_rpg_acceptance.gd` cubre relación→diálogo, quest, recompensa única, puntos tecnológicos, unlock, compra + venta, guardado, reconstrucción del mundo, restore de providers e idempotencia post-load.

### Changed
- `SaveManager` agrega/aplica providers locales sin convertir sistemas RPG en Autoloads.
- Dinero y precios usan cobre entero como unidad base; tecnologías usan puntos rojo/verde/azul enteros no negativos.
- La UI de comercio presenta saldo/precios como oro/plata/cobre, pero ejecuta compra/venta exclusivamente mediante las APIs atómicas existentes de `EconomyController`.
- El quality gate dejó de mantener una whitelist manual: ahora descubre todos los `*.gd` del repositorio y ejecuta `gdlint` + `gdformat --check` globalmente.
- 39 scripts legacy fueron migrados al formato canónico de `gdformat`; `TimeManager.get_weekday_name()` quedó con un único return sin cambiar comportamiento.
- **Fase 6 — RPG queda COMPLETADA** tras cerrar #6, #8 y validar #9.
- El siguiente bloque obligatorio es **#17 — contrato visual pre-Fase 7**; #16 y la producción de mundo siguen bloqueados hasta cerrarlo.

### Fixed
- Inferencias `Variant`, problemas de atomicidad y lifecycle detectados en fases anteriores.
- `ScheduleEntryData` dejó de comparar resultados normalizados de tiempo con enteros incorrectamente.
- Correcciones de `gdlint`/`gdformat` en diálogo, quests, economía, tecnología y aceptación RPG sin relajar gates.
- Run `33305708696`: el test integral pasó a resolver `/root/SaveManager` desde el runner `--script`.
- Se corrigió la desincronización entre `ROADMAP.md`, `DEV_MEMORY.md`, `README.md`, backlog e inicio prematuro de Fase 7.
- #6: el prompt del punto de comercio ahora se localiza con `UI_TRADE_PROMPT` y se actualiza al cambiar idioma.
- #6: se aplicó el formato canónico exigido por `gdformat` en `TradePanel` manteniendo el gate estricto.
- #8 estaba implementada en `main` pero permanecía abierta/documentada como pendiente; se cerró con evidencia antes de ejecutar #9.
- El cierre integral previo no verificaba explícitamente relación→diálogo, venta, origen de puntos desde quest ni reconstrucción real de providers; `test_rpg_acceptance.gd` ahora cubre esos huecos.

### Validated
- Fase 0: run `33278173612`, success.
- Fase 1: run `33280758441`, success.
- Fase 2: run `33285578050`, success.
- Fase 3: `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`, success.
- Fase 4: `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`, success.
- Fase 5: `f0290951a27d5e66581da2532151d957ec35075e`, run `33297774458`, ambos jobs success.
- Diálogo: `46a37e00c2ad968e91834da5577a6f512a28f0a9`, run `33298737838`.
- Relaciones: `fc446609004ea8031903c1c529144743cd963e51`, run `33299277228`.
- Condiciones narrativas: `e1a19343e8303d1b28188a2a38c559d788c8087d`, run `33299990183`.
- Quests foundation: `979b2328cc01c8d5a7a0ae4201deabe58cf9cc38`, run `33301533785`.
- Economía foundation: `184f2b6d9df6d0b26dcfeb7d2a2d8e3dc7604863`, run `33304080534`.
- Tecnología foundation: `444fc2995ab14b293188aba54a0f4099dc3c36b3`, run `33305211363`.
- Comercio UI #6: merge `3d6252e840ae32e5445f454170d0856909bf6a2b`, run `33307358527`, ambos jobs success.
- Tecnología ↔ quests #8: merge `8cd26c98e3e43d982218ccf97869ab0c6a0830b3`; regresión incluida en CI global posterior.
- Quality gate global #38: merge `cb4c14351abbee84f3162197cdf4ba794ab9846f`, run `33308014015`, ambos jobs success sobre 109 scripts GDScript.
- Cierre RPG #9: acceptance HEAD `ea3543aba5b6d859266553a964d817f54670b9a3`, PR #39, run `33308814397`: `gdscript-quality` y `validate-and-test` success.
