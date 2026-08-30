# CHANGELOG

## Unreleased

### Added
- Bootstrap Godot 4.x, cinco Autoloads globales, InputMap, logging, debug, guardado versionado, tests y CI headless.
- Walking prototype, items/inventario, energía, recursos, crafting, `StorageNetwork`, producción temporizada y cementerio persistente.
- Simulación: reloj/calendario, sueño, ciclo día/noche, `NPCData`, navegación, horarios/estados y persistencia NPC.
- Localización EN/ES, diálogo data-driven, relaciones, quests, economía y tecnologías como sistemas locales/contextuales.
- Primera quest jugable de Aldren, primer comerciante data-driven `yard_supplier` y primera tecnología `sturdy_joinery`.
- `test_rpg_acceptance.gd` para roundtrip conjunto básico de relaciones, quests, economía y tecnología mediante `SaveManager`.

### Changed
- `SaveManager` agrega/aplica providers locales sin convertir sistemas RPG en Autoloads.
- Dinero y precios usan cobre entero como unidad base; tecnologías usan puntos rojo/verde/azul enteros no negativos.
- **Corrección de planificación:** Fase 6 vuelve a estado **ACTIVA**. El cierre anterior se adelantó a las dependencias canónicas de las issues #6, #8 y #9.
- Fase 7 queda bloqueada; PR #32 permanece draft y no debe mergearse antes del cierre real de #9.
- Orden obligatorio restante: `#6 + #8 -> #9 -> #17 -> #16 -> #18/#19/#20/#21/#22`.

### Pending — Fase 6
- **#6:** interacción de comerciante + UI técnica de compra/venta, reusable, EN/ES y conectada a las APIs atómicas existentes.
- **#8:** recompensa tipada de puntos tecnológicos desde quests, idempotente tras save/load.
- **#9:** aceptación integral final incluyendo recompensa tecnológica, desbloqueo, compra + venta y persistencia conjunta sobre el HEAD definitivo.

### Fixed
- Inferencias `Variant`, problemas de atomicidad y lifecycle detectados en fases anteriores.
- `ScheduleEntryData` dejó de comparar resultados normalizados de tiempo con enteros incorrectamente.
- Correcciones de `gdlint`/`gdformat` en diálogo, quests, economía, tecnología y aceptación RPG sin relajar gates.
- Run `33305708696`: el test integral pasó a resolver `/root/SaveManager` desde el runner `--script`.
- Se corrigió la desincronización entre `ROADMAP.md`, `DEV_MEMORY.md`, `README.md`, backlog e inicio prematuro de Fase 7.

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
- Aceptación RPG parcial: `cc1351048609a474cedd524543f6c4370c46bea4`, run `33305899447`; verde técnicamente, pero no suficiente para cerrar #9 por faltar #6 y #8.
