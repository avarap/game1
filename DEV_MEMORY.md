# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`.
- Rama principal: `main`.
- Runtime/CI objetivo: **Godot 4.7.2**.
- Fases 0–7: **COMPLETADAS**.
- Fase 7 — Mundo cerrada mediante #24.
- Integración #23: PR #53, merge `6c84c0f2d0e97e64c8f4f94f8de7ef144111c86a`.
- Aceptación #24: PR #54, acceptance HEAD `d4489ddae0467afeb262c2994e8b71f0f2afd311`, run `33331207740`, `success`.
- Merge funcional de #24 en `main`: `7e281255322b6c7444d4177d85295b353babb38f`.
- Fase 8 — Polish: **ACTIVA**.
- Próximo trabajo debe salir de #25–#31 respetando dependencias y `ART_DIRECTION.md`.

## Fuentes de verdad

- Funcional/arquitectónica: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
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

`ART_DIRECTION.md` + #16 fijan:

- proyección 2D ortográfica cenital 3/4;
- tile lógico `32 x 32 px`;
- capas `ground`, `paths`, `decoration_low`, `collision`, `objects_y_sorted`, `foreground_occlusion`;
- pivote/Y-sort en pies;
- resolución de referencia `1280 x 720`, zoom base `1.5x`;
- `TileMapLayer` como base de composición;
- gameplay fuera de los tiles.

El mundo integrado usa `world/world.tscn` como shell persistente. `ZoneManager` mantiene una sola zona bajo `ZoneContainer` y conecta cementerio/propiedad, bosque, pueblo, dos interiores y mina. Player, controllers RPG/cementerio y Brother Aldren mantienen identidad lógica durante viajes.

`WorldLocationProvider` persiste zona, marker y posición, con fallback/clamp seguro. La cámara adopta bounds de la zona activa. `TradePoint` solo se activa en pueblo y Aldren se oculta/pausa fuera del cementerio sin perder su provider persistente.

## Fase 7 — cierre #24

`TestWorldPhase7Acceptance` agrega explícitamente en un único gate final:

- foundation de mapas y seis `TileMapLayer`;
- cementerio/taller;
- bosque;
- pueblo;
- interiores;
- mina;
- recorrido completo de zonas y persistencia de Player/controllers;
- navegación de NPC;
- rutinas/schedule de Brother Aldren.

La suite final valida también save/load de ubicación, camera bounds, colisiones, spawns y transiciones mediante las suites especializadas que agrega. CI `33331207740` pasó `gdlint`, `gdformat --check`, import Godot 4.7.2, smoke y suite headless completa.

## Incidencias relevantes resueltas en Fase 7

- Los tests legacy dejaron de retener referencias a interactables de zonas destruidas durante reconstrucción por load.
- Restaurar `world_location` ya no sobreescribe el estado persistente de Brother Aldren.
- `zone_manager.gd` quedó en formato canónico de `gdformat`.
- El quality gate permanece global y estricto; no se relajaron reglas para cerrar la fase.
- No se introdujo arte final ni contenido de Fase 8 durante el cierre.

## Próximo paso — Fase 8

1. Revisar las issues #25–#31 y sus dependencias antes de empezar.
2. Elegir el primer bloque visual/polish desbloqueado.
3. Mantener `ART_DIRECTION.md` como contrato obligatorio.
4. No reabrir alcance funcional de Fases 0–7 salvo bug crítico demostrado por tests/CI.
5. Mantener Godot 4.7.2, quality gate global, import, smoke y suite headless verdes.

## Regla de continuidad

Al retomar:
1. Leer `DEV_MEMORY.md`, `ROADMAP.md`, `ART_DIRECTION.md` y la issue activa.
2. Revisar `main`, PRs abiertos y último CI.
3. Comprobar dependencias antes de iniciar trabajo nuevo.
4. Implementar un bloque coherente y pequeño.
5. Ejecutar quality gate, importación, smoke y suite headless.
6. Corregir errores críticos antes de avanzar.
7. Actualizar `DEV_MEMORY.md`, `ROADMAP.md` y `CHANGELOG.md`.
8. No marcar una fase completada antes de cumplir todos sus criterios de aceptación.
