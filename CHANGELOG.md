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
- **#18–#24 Mundo:** cementerio/taller, bosque, pueblo, interiores, mina, integración de zonas y aceptación integral.
- **#25 Tileset exterior:** atlas original `256 x 256` con 64 tiles de `32 x 32` y documentación estable de celdas.
- **8A.1 Descomposición acelerada:** `CorpseState` incorpora edad en minutos enteros, deterioro entero 0–100, cuatro estados legibles, aceleración por edad, calidad efectiva y persistencia determinista.
- `TestCorpseDecomposition` valida bandas 0–24/24–48/48–72/>72 h, equivalencia entre saltos grandes y pequeños, thresholds y round-trip integer.
- Spec detallado de Phase 8A para conservación, agricultura/nabo multiuso, servicio funerario a las 18:00, comedero, rampa, cremación/investigación y aceptación integral.

### Changed
- `SaveManager` agrega/aplica providers locales sin convertir sistemas RPG en Autoloads.
- Dinero y precios usan cobre entero; tecnologías usan puntos rojo/verde/azul enteros no negativos.
- Quality gate global descubre todos los `*.gd` y ejecuta `gdlint` + `gdformat --check`.
- Runtime/CI objetivo actualizado a **Godot 4.7.2**.
- `world/world.tscn` es un shell persistente; el mapa activo vive bajo `ZoneContainer`.
- Brother Aldren permanece persistente y se oculta/pausa fuera del cementerio; `TradePoint` se activa solo en pueblo.
- **Fase 6 — RPG COMPLETADA** tras #6, #8 y #9.
- **Fase 7 — Mundo COMPLETADA** tras #16/#17/#18–#24.
- **Fase 8 — Polish ACTIVA**.
- #25 mantiene arte de terreno desacoplado de gameplay, colisión, navegación y escenas de mapa; su integración queda reservada a #29.
- El contrato legacy de descomposición float lineal (`current_decay`/`decay_rate_per_hour`) se sustituye por `decay_percent: int` y `age_minutes: int`.
- `CorpseData` usa `decay_percent` entero 0–100; los tests históricos de cementerio se migran al nuevo comportamiento.
- No se implementa migración de saves legacy: no existen saves de jugadores que conservar.

### Design Decisions — Phase 8A
- Descomposición híbrida: almacenamiento integer 0–100, estados Fresh/Fading/Decomposed/Rotten y aceleración con la edad.
- Un acumulador privado entero conserva progreso subporcentual y evita depender de floats persistentes.
- Conservación futura mediante multiplicadores de tecnología, utensilios e instalaciones; nunca rejuvenece.
- Transporte funerario original al atardecer, objetivo 18:00; tras quest requiere alimento cultivable y debe ser exactly-once con sueño/time-jump/save-load.
- Descarga inicial junto al camino; rampa desbloqueable dirige entregas al depósito sin bonus de conservación.
- `fodder_turnip` será cultivable, comprable, vendible, almacenable y utilizable en cocina; cultivar es la estrategia sostenible y comprar una salida de emergencia.
- Cocina reutiliza crafting y recupera energía; no se añade hambre.
- Cremar e investigar se añaden como decisiones distintas a enterrar; investigar consume tiempo mientras continúa el deterioro.
- Economía preparada para modificadores multiplicativos neutrales por defecto; no se añade supply/demand complejo.
- Feedback placeholder reutiliza EventBus/AudioManager; arte/audio final permanece en el sub-track visual.

### Fixed
- Inferencias `Variant`, problemas de atomicidad y lifecycle detectados en fases anteriores.
- `ScheduleEntryData` dejó de comparar resultados normalizados de tiempo con enteros incorrectamente.
- El prompt del comercio se localiza con `UI_TRADE_PROMPT` y responde a cambio de idioma.
- #16 corrigió el orden de registro del atlas antes de crear geometría de colisión.
- Tests legacy ya no retienen `SleepSpot` de una zona destruida durante load.
- Restaurar `world_location` no sobreescribe el estado persistente de Brother Aldren.
- `zone_manager.gd` quedó normalizado por `gdformat` sin relajar el gate global.
- Durante 8A.1 se corrigieron únicamente discrepancias mecánicas de longitud/formato detectadas por el gate antes de aceptar el bloque.

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
- Integración #23: PR #53, run `33331094583`, success.
- Cierre #24: PR #54, run `33331207740`, success.
- Tileset exterior #25: PR #56, run `33333578933`, success.
- **8A.1 descomposición integer:** PR #57, run funcional `33334955947`: `gdlint`, `gdformat --check`, Godot 4.7.2 import, main-scene smoke y suite headless completa en success.
