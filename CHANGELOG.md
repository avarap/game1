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
- **8A.2 Conservación:** `PreservationModifiers` añade factores data-driven en basis points enteros para tecnología, instalación y utensilio, neutrales por defecto y multiplicativos.
- `CorpseState` aplica conservación solo al deterioro futuro y persiste modificadores y resto fraccional; `TestCorpsePreservation` cubre neutralidad, reducción, composición, no-rewind, determinismo y round-trip.
- Spec detallado de Phase 8A para conservación, agricultura/nabo multiuso, servicio funerario a las 18:00, comedero, rampa, cremación/investigación y aceptación integral.
- **Post-MVP economía local por profesión:** todo item vendible debe tener comprador compatible; comerciantes opt-in por NPC y `MerchantProfile` data-driven basado en tags/categorías, con afinidad de precio, cupos y validación de items sin salida económica.
- **Post-MVP automatización:** trabajadores originales con tareas `HARVEST`, `MINE`, `CHOP`, `TRANSPORT` y `PROCESS`, dependientes de infraestructura y cadenas productivas.
- **Biblioteca `docs/design/`:** documentación categorizada de visión, orden de ejecución, loops, mundo, recursos, crafting, tecnología, construcción, economía, farming, NPCs, cementerio, tiempo/clima, exploración, automatización, UI, arte, progresión y arquitectura data-driven.
- **Backlog y prompts de diseño:** `19_IDEA_BACKLOG.md` clasifica ideas por MVP/post-MVP/expansión y `20_IMPLEMENTATION_PROMPTS.md` añade prompts reutilizables para elaborar e implementar bloques futuros sin saltar fases.

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
- Cambiar modificadores de conservación conserva el resto fraccional de deterioro acumulado para que aplicar una mejora no rejuvenezca ni perdone progreso previo.
- `docs/design/` queda explícitamente como dirección secundaria/backlog: no sustituye `ROADMAP.md` ni autoriza adelantar sistemas post-MVP.

### Design Decisions — Phase 8A
- Descomposición híbrida: almacenamiento integer 0–100, estados Fresh/Fading/Decomposed/Rotten y aceleración con la edad.
- Un acumulador privado entero conserva progreso subporcentual y evita depender de floats persistentes.
- Conservación mediante multiplicadores enteros de tecnología, utensilios e instalaciones; nunca rejuvenece y la rampa de entrega no aporta bonus.
- Transporte funerario original al atardecer, objetivo 18:00; tras quest requiere alimento cultivable y debe ser exactly-once con sueño/time-jump/save-load.
- Descarga inicial junto al camino; rampa desbloqueable dirige entregas al depósito sin bonus de conservación.
- `fodder_turnip` será cultivable, comprable, vendible, almacenable y utilizable en cocina; cultivar es la estrategia sostenible y comprar una salida de emergencia.
- Cocina reutiliza crafting y recupera energía; no se añade hambre.
- Cremar e investigar se añaden como decisiones distintas a enterrar; investigar consume tiempo mientras continúa el deterioro.
- Economía preparada para modificadores multiplicativos neutrales por defecto; no se añade supply/demand complejo.
- Feedback placeholder reutiliza EventBus/AudioManager; arte/audio final permanece en el sub-track visual.

### Design Decisions — Post-MVP
- Todo producto vendible debe tener al menos un `MerchantProfile` compatible salvo `quest_only`, `key_item` o `non_sellable`.
- No todos los aldeanos comercian; los comerciantes aceptan familias de recursos según profesión mediante tags/categorías.
- El herrero es el caso de referencia: acepta `iron`, `ore`, `metal_part` y `tool`, pero no productos agrícolas o madera no relacionada.
- Un comerciante general puede actuar como salida de seguridad con peores precios; la afinidad profesional y los cupos evitan que todos los NPCs sean equivalentes.
- Añadir o modificar recursos/comerciantes debe ser data-driven y validable, sin lógica específica dispersa por item.
- El diseño futuro prioriza recetas `N inputs → N outputs`, subproductos reutilizables, progreso visible del mundo, construcción/estaciones extensibles, logística que evoluciona de manual a automatizada y densidad de contenido antes que tamaño de mapa.

### Fixed
- Inferencias `Variant`, problemas de atomicidad y lifecycle detectados en fases anteriores.
- `ScheduleEntryData` dejó de comparar resultados normalizados de tiempo con enteros incorrectamente.
- El prompt del comercio se localiza con `UI_TRADE_PROMPT` y responde a cambio de idioma.
- #16 corrigió el orden de registro del atlas antes de crear geometría de colisión.
- Tests legacy ya no retienen `SleepSpot` de una zona destruida durante load.
- Restaurar `world_location` no sobreescribe el estado persistente de Brother Aldren.
- `zone_manager.gd` quedó normalizado por `gdformat` sin relajar el gate global.
- Durante 8A.1 se corrigieron únicamente discrepancias mecánicas de longitud/formato detectadas por el gate antes de aceptar el bloque.
- **8A.2:** `set_preservation_modifiers()` ya no reinicia `_preservation_remainder`; se evita descartar deterioro subporcentual acumulado al cambiar mejoras de conservación.

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
- **8A.2 conservación:** PR #59, run previo `33335651778` verde; RED de regresión `33336306728` falló exactamente por pérdida del resto fraccional; GREEN funcional `33336387360` pasó quality, import Godot 4.7.2, smoke y suite headless completa.
- Cambio documental `docs/design/`: no modifica GDScript, escenas ni assets; validación requerida es integridad/relectura de documentación y estado de `main`.
