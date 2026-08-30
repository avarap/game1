# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`.
- Rama principal: `main`.
- Runtime/CI objetivo: **Godot 4.7.2**.
- Fases 0–7: **COMPLETADAS**.
- Fase 8 — Polish: **ACTIVA**.
- #25 — Tileset exterior: completado en PR #56; run `33333578933`, success.
- Track **8A — Gameplay Depth & Feel**: diseño aprobado y en implementación.
- **8A.1 — Descomposición acelerada:** implementado en PR #57.
- **8A.2 — Conservación:** implementado en PR #59; CI funcional `33336387360`, success.
- Diseño 8A: `docs/superpowers/specs/2026-08-30-phase8a-cemetery-depth-design.md`.
- Próximo bloque del track de profundidad: **8A.3 — agricultura mínima**.

## Fuentes de verdad

- Funcional/arquitectónica: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Diseño jugable: `GAME_DESIGN.md` + spec 8A.
- Planificación: `ROADMAP.md` + issues activas.
- Contrato visual: `ART_DIRECTION.md`.
- Narrativa: `HISTORIA_PRINCIPAL.md` — **El Cementerio de Valdeniebla**.
- Idiomas: `LOCALIZATION.md`.

## Fases completadas

- Fase 0 — Bootstrap: run `33278173612`.
- Fase 1 — Core: run `33280758441`.
- Fase 2 — Items: run `33285578050`.
- Fase 3 — Crafting: run `33292481990`.
- Fase 4 — Cementerio: run `33294286014`.
- Fase 5 — Simulación: run `33297774458`.
- Fase 6 — RPG: PR #39, run `33308814397`.
- Fase 7 — Mundo: PR #54, run `33331207740`.

## Arquitectura estable

- Exactamente cinco Autoloads: `EventBus`, `GameManager`, `TimeManager`, `SaveManager`, `AudioManager`.
- `TimeManager` es la única fuente de reloj/calendario.
- RPG permanece local/contextual: diálogo, relaciones, quests, economía y tecnología.
- `SaveManager` agrega providers del grupo `save_provider`.
- UI observa controllers/modelos y emite intents; no contiene lógica de negocio.
- Quality gate descubre todos los `*.gd` y ejecuta `gdlint` + `gdformat --check` globalmente.
- Runtime y CI usan Godot 4.7.2.

## Contrato de mundo estable tras Fase 7

`ART_DIRECTION.md` + #16 fijan proyección 2D ortográfica cenital 3/4, tile lógico `32 x 32 px`, seis `TileMapLayer`, pivote/Y-sort en pies, resolución `1280 x 720`, zoom base `1.5x` y gameplay fuera de tiles.

`world/world.tscn` es el shell persistente. `ZoneManager` mantiene una sola zona bajo `ZoneContainer` y conecta cementerio/propiedad, bosque, pueblo, dos interiores y mina. Player, controllers y Brother Aldren preservan identidad lógica durante viajes. `WorldLocationProvider` persiste zona/marker/posición, la cámara adopta bounds de la zona activa y comercio/NPC se activan según zona.

## Fase 8 — visual

- #25 introdujo el atlas exterior original `256 x 256`, 64 celdas de `32 x 32`, desacoplado de gameplay/colisión/navegación.
- #26–#31 siguen su propio sub-track visual; pueden avanzar en trabajo independiente siempre que no pisen contratos de gameplay 8A.
- #29 permanece dependiente de los assets previos definidos en el roadmap.

## Fase 8A — decisiones aprobadas

### Cadáveres
- Estado canónico: `decay_percent: int` `0..100` y `age_minutes: int`.
- No existe obligación de compatibilidad con saves legacy porque aún no hay saves de jugadores en circulación.
- Estados visibles: Fresh `0–24`, Fading `25–49`, Decomposed `50–74`, Rotten `75–100`.
- Ritmo por edad: 0–24 h lento, 24–48 h medio, 48–72 h rápido, >72 h muy rápido.
- La implementación 8A.1 usa acumulador privado entero para conservar progreso subporcentual sin persistir floats.
- Calidad efectiva pierde 0/1/2/3 puntos según estado, con mínimo 0.
- Grandes saltos de tiempo producen el mismo resultado que avances equivalentes pequeños.
- Preparar no reduce edad ni descomposición.
- Objetivo posterior: preparar, enterrar, cremar e investigar con trade-offs distintos.

### Conservación — implementada en 8A.2
- `effective_rate = age_rate × technology_modifier × facility_modifier × tool_modifier`.
- `PreservationModifiers` usa basis points enteros (`10000 = 1.0`) para tecnología, instalación y utensilio.
- Los tres factores son neutrales por defecto, se normalizan a `1..10000` y se componen multiplicativamente.
- La conservación solo ralentiza deterioro futuro; nunca reduce `age_minutes`, `decay_percent`, unidades acumuladas ni el resto fraccional pendiente.
- `CorpseState` persiste los modificadores y `_preservation_remainder` para mantener determinismo y round-trip exacto.
- Cambiar de modificadores conserva el resto fraccional previo; descartarlo equivaldría a perdonar deterioro subporcentual.
- La rampa de entrega sigue siendo logística únicamente, sin bonus de conservación.

### Servicio funerario
- Entrega diaria determinista al atardecer; objetivo inicial **18:00**.
- Cruzar las 18:00 mediante juego normal, sueño o salto de tiempo procesa como máximo una entrega por día.
- Save/load no puede duplicar entregas.
- Introducción temporalmente gratuita; tras quest requiere alimento cultivable desde un comedero.
- Sin alimento suficiente: entrega suspendida, sin inventario negativo.
- Personaje/animal/quest/textos/assets serán originales.

### Agricultura y recurso multiuso
- Stable IDs: `fodder_turnip_seed` y `fodder_turnip`.
- Loop mínimo: semilla → parcela → crecimiento por TimeManager → cosecha → inventario → persistencia.
- Usos: alimentar transporte, vender, comprar de emergencia, cocinar y almacenar.
- Cultivar debe ser más sostenible que comprar continuamente.
- Cocina reutiliza `RecipeData`/crafting y recupera energía; no introducir hambre.

### Logística, economía y feedback
- Inicio: descarga junto al camino; progresión: rampa desbloqueable al área de recepción.
- Pipeline futuro de precios: base × global × merchant × relationship, neutral `1.0` por defecto; sin supply/demand complejo.
- Feedback placeholder reutiliza EventBus/AudioManager.

## Implementación 8A.1

Archivos principales:
- `systems/cemetery/corpse_data.gd`: `decay_percent` entero 0–100.
- `systems/cemetery/corpse_state.gd`: `age_minutes`, integración acelerada por bandas, estados, calidad efectiva y snapshot integer.
- `world/cemetery/cemetery_controller.gd`: demo corpse migrado al nuevo contrato.
- `tests/test_corpse_decomposition.gd`: contrato específico de aceleración, thresholds, determinismo y persistencia.
- Tests legacy de cementerio actualizados para validar el nuevo contrato en vez del modelo float lineal eliminado.

## Implementación 8A.2

Archivos principales:
- `systems/cemetery/preservation_modifiers.gd`: Resource data-driven con factores technology/facility/tool en basis points enteros y composición multiplicativa.
- `systems/cemetery/corpse_state.gd`: aplica el factor compuesto a nuevas unidades de deterioro y persiste factor/resto sin rewind.
- `tests/test_corpse_preservation.gd`: neutralidad, reducción de velocidad, composición, no-rewind visible y subporcentual, determinismo y snapshot/restore.
- `tests/run_tests.gd`: registra la suite de conservación.

TDD/validación:
- El PR llegó a GREEN funcional en run `33335651778` antes de la auditoría adicional.
- Se detectó que `set_preservation_modifiers()` reiniciaba `_preservation_remainder`, descartando progreso fraccional ya acumulado.
- RED de regresión: run `33336306728` mantuvo import/smoke y todas las demás suites verdes y falló exactamente en `Changing preservation should preserve fractional decomposition progress`.
- GREEN tras corregir el reset: run `33336387360` pasó `gdlint`, `gdformat --check`, import Godot 4.7.2, smoke y suite headless completa.

## Scope fuera de 8A

- Hambre/sed.
- Estaciones/clima agrícola.
- Riego/fertilizante complejo.
- Mercado supply/demand.
- Combate nuevo.
- Mapas grandes nuevos.
- Copiar elementos específicos/protegidos del benchmark.

## Próximo paso

1. Integrar PR #59 solo con HEAD documental final y CI verde.
2. Verificar CI posterior al merge en `main`.
3. Empezar **8A.3 — agricultura mínima** con TDD: semilla → parcela → crecimiento por `TimeManager` → cosecha → persistencia.
4. Mantener independencia con el sub-track visual #26–#31.
5. No marcar Fase 8 ni Track 8A como completos al cerrar 8A.2.

## Regla de continuidad

Al retomar:
1. Leer `DEV_MEMORY.md`, `ROADMAP.md`, `GAME_DESIGN.md`, spec 8A, `ART_DIRECTION.md` y la issue/PR activo.
2. Revisar `main`, PRs abiertos y último CI.
3. Comprobar dependencias antes de iniciar trabajo nuevo.
4. Implementar un bloque coherente y pequeño mediante TDD cuando cambie comportamiento.
5. Ejecutar quality gate, importación, smoke y suite headless.
6. Corregir errores críticos antes de avanzar.
7. Actualizar `DEV_MEMORY.md`, `ROADMAP.md` y `CHANGELOG.md`.
8. No marcar una fase completada antes de cumplir todos sus criterios de aceptación.
