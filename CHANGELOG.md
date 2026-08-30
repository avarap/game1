# CHANGELOG

## Unreleased

### Added
- Bootstrap Godot 4.x, cinco Autoloads globales, InputMap, logging, debug, guardado versionado, tests y CI headless.
- Walking prototype, items/inventario, energía, recursos, crafting, `StorageNetwork`, producción temporizada y cementerio persistente.
- Simulación: reloj/calendario, sueño, ciclo día/noche, `NPCData`, navegación, horarios/estados y persistencia NPC.
- Localización EN/ES, diálogo data-driven, relaciones, quests, economía y tecnologías como sistemas locales/contextuales.
- **#6 Comercio UI:** `TradeLayer`/`TradePanel`, `TradeInteractable` reutilizable, punto de comercio integrado, prompts/textos EN/ES y `test_trading_ui.gd`.
- **#8 Tecnología ↔ quests:** recompensa tipada `TECHNOLOGY_POINTS`, compatibilidad `QUEST_FLAG` e idempotencia tras save/load.
- **#9 Aceptación RPG final:** flujo integral relación→diálogo→quest→recompensa→unlock→compra/venta→save/load.
- **#17 Contrato visual:** `ART_DIRECTION.md` fija proyección, tiles de 32 px, escala, pivotes/Y-sort, capas, paleta, luz y convenciones.
- **#16 Foundation `TileMapLayer`:** `technical_map.tscn` + `TechnicalMap`, seis capas, bounds y colisión tile-based.
- **#18 Cementerio + taller:** `world/maps/cemetery/cemetery_map.tscn`, interacciones críticas, markers de conexión y navegación.
- **#19 Bosque:** mapa compacto con caminos, límites, recursos existentes, navegación y secret clearing reservado.
- **#20 Pueblo:** mapa de Valdeniebla con entrada, plaza, merchant spot, plots y markers de interiores.
- **#21 Interiores:** casa/taller y edificio de pueblo reutilizables, markers estables e `InteriorTransition` sin duplicar player.
- **#22 Mina inicial:** entrada/salida, corredor principal, bifurcación, oclusión y landmark secreto usando sistemas de recursos existentes.

### Changed
- `SaveManager` agrega/aplica providers locales sin convertir sistemas RPG en Autoloads.
- Dinero y precios usan cobre entero; tecnologías usan puntos rojo/verde/azul enteros no negativos.
- UI de comercio usa exclusivamente APIs atómicas de `EconomyController`.
- Quality gate global descubre todos los `*.gd` y ejecuta `gdlint` + `gdformat --check`.
- 39 scripts legacy fueron migrados al formato canónico de `gdformat`.
- **Fase 6 — RPG COMPLETADA** tras #6, #8 y #9.
- Runtime/CI objetivo actualizado a **Godot 4.7.2**.
- **Fase 7 — Mundo permanece ACTIVA**, pero #18–#22 ya están integrados.
- El siguiente bloque cambia de #18 a **#23 — integración de zonas + exploración y secretos**.
- Fase 8 permanece bloqueada por **#24 — aceptación final de Fase 7**.

### Fixed
- Inferencias `Variant`, problemas de atomicidad y lifecycle detectados en fases anteriores.
- `ScheduleEntryData` dejó de comparar resultados normalizados de tiempo con enteros incorrectamente.
- El prompt del comercio se localiza con `UI_TRADE_PROMPT` y responde a cambio de idioma.
- El cierre RPG se reforzó para comprobar diálogo condicionado, venta, origen de puntos tecnológicos y reconstrucción real de providers.
- #16 corrigió el orden de registro del atlas antes de crear geometría de colisión.
- Se eliminó la dependencia del test legacy respecto al nodo `Boundaries` sustituido por `TechnicalMap/collision`.
- **Backlog sincronizado:** #5 y #7 de Fase 6 se cerraron como `completed` al confirmar que su alcance ya estaba implementado y validado.
- **Backlog Fase 7 sincronizado:** #21 y #22 se cerraron como `completed` después de confirmar que PR #49/#50 estaban merged y verdes.
- `ROADMAP.md` y `DEV_MEMORY.md` dejaron de indicar #18 como siguiente tarea después de que #18–#22 ya hubieran sido fusionadas.

### Validated
- Fase 0: run `33278173612`, success.
- Fase 1: run `33280758441`, success.
- Fase 2: run `33285578050`, success.
- Fase 3: run `33292481990`, success.
- Fase 4: run `33294286014`, success.
- Fase 5: run `33297774458`, success.
- Comercio UI #6: run `33307358527`, success.
- Quality gate global #38: run `33308014015`, success.
- Cierre RPG #9: run `33308814397`, success.
- Godot 4.7.2: PR #41, run `33309144543`, success.
- Contrato visual #17: run `33311594061`, success.
- Foundation `TileMapLayer` #16: run funcional `33313715794`, success.
- Cementerio/taller #18: PR #47, run `33316327221`, success.
- Bosque #19: PR #48, run `33316454888`, success.
- Pueblo #20: PR #46, run `33315626881`, success.
- Interiores #21: PR #49, run `33318051580`, success.
- Mina #22: PR #50, run `33318407597`, success.
- Estado integrado actual de `main`: `725529b9b5f9091853b1e78d8031d6dafcd2277a`; Godot CI run `33325342447`, success.
