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
- **#18 Cementerio + taller:** mapa, interacciones críticas, markers de conexión y navegación.
- **#19 Bosque:** caminos, límites, recursos existentes, navegación y secret clearing reservado.
- **#20 Pueblo:** Valdeniebla con entrada, plaza, merchant spot, plots y markers de interiores.
- **#21 Interiores:** casa/taller y edificio de pueblo reutilizables, markers estables y transición sin duplicar player.
- **#22 Mina inicial:** entrada/salida, corredor, bifurcación, oclusión y landmark secreto.
- **#23 Integración de zonas:** `ZoneManager`, `ZoneTransition`, `ZoneContainer` y `WorldLocationProvider` conectan todas las zonas manteniendo Player/controllers persistentes.
- **#24 Aceptación final:** `TestWorldPhase7Acceptance` agrega los contratos de mapas, recorrido, navegación y rutinas NPC como gate explícito de cierre.
- **#25 Tileset exterior:** atlas original `256 x 256` con 64 tiles de `32 x 32` para hierba/tierra, caminos/transiciones, cementerio, bosque, pueblo/plaza, bordes y `decoration_low`; incluye documentación estable de celdas.

### Changed
- `SaveManager` agrega/aplica providers locales sin convertir sistemas RPG en Autoloads.
- Dinero y precios usan cobre entero; tecnologías usan puntos rojo/verde/azul enteros no negativos.
- Quality gate global descubre todos los `*.gd` y ejecuta `gdlint` + `gdformat --check`.
- Runtime/CI objetivo actualizado a **Godot 4.7.2**.
- `world/world.tscn` es un shell persistente; el mapa activo vive bajo `ZoneContainer`.
- Brother Aldren permanece persistente y se oculta/pausa fuera del cementerio; `TradePoint` se activa solo en pueblo.
- **Fase 6 — RPG COMPLETADA** tras #6, #8 y #9.
- **Fase 7 — Mundo COMPLETADA** tras #16/#17/#18–#24.
- **Fase 8 — Polish pasa a ACTIVA**.
- #25 mantiene arte de terreno desacoplado de gameplay, colisión, navegación y escenas de mapa; su integración queda reservada a #29.

### Fixed
- Inferencias `Variant`, problemas de atomicidad y lifecycle detectados en fases anteriores.
- `ScheduleEntryData` dejó de comparar resultados normalizados de tiempo con enteros incorrectamente.
- El prompt del comercio se localiza con `UI_TRADE_PROMPT` y responde a cambio de idioma.
- #16 corrigió el orden de registro del atlas antes de crear geometría de colisión.
- Tests legacy ya no retienen `SleepSpot` de una zona destruida durante load.
- Restaurar `world_location` no sobreescribe el estado persistente de Brother Aldren.
- `zone_manager.gd` quedó normalizado por `gdformat` sin relajar el gate global.

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
- Foundation `TileMapLayer` #16: run `33313715794`, success.
- Cementerio/taller #18: PR #47, run `33316327221`, success.
- Bosque #19: PR #48, run `33316454888`, success.
- Pueblo #20: PR #46, run `33315626881`, success.
- Interiores #21: PR #49, run `33318051580`, success.
- Mina #22: PR #50, run `33318407597`, success.
- Integración #23: PR #53, merge `6c84c0f2d0e97e64c8f4f94f8de7ef144111c86a`, run `33331094583`, success.
- Cierre #24: PR #54, acceptance HEAD `d4489ddae0467afeb262c2994e8b71f0f2afd311`, run `33331207740`, success.
- Merge funcional #24: `7e281255322b6c7444d4177d85295b353babb38f`.
- Tileset exterior #25: PR #56, run funcional `33333578933`, `gdlint`, `gdformat --check`, import Godot 4.7.2, smoke y suite headless en `success`.