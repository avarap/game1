# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`.
- Rama principal: `main`.
- Fase completada más reciente: **Fase 6 — RPG**.
- Cierre funcional de Fase 6: PR #39, merge `1efe0bc9a47c2a434c597276bc326d24713720aa`; aceptación HEAD `ea3543aba5b6d859266553a964d817f54670b9a3`, run `33308814397`.
- Runtime/CI objetivo actualizado a **Godot 4.7.2** por PR #41, merge `1b4ff623b45c465bfb9bd57f2b96b6ecec88a2ad`; run de `main` `33309144543`, ambos jobs `success`.
- **#17 — contrato visual pre-Fase 7 resuelto en PR #42** mediante `ART_DIRECTION.md`: perspectiva cenital 3/4 ortográfica, tile 32 px, escala de personajes, footprints, cámara, pivotes/Y-sort, capas, paleta, luz, pixel-art, carpetas y spritesheets.
- El contrato conserva como referencia el footprint actual del player (`20 x 28 px`) y el zoom actual (`1.5x`) para no introducir gameplay en #17.
- **Siguiente bloque obligatorio: #16 — foundation técnica de mapas con `TileMapLayer`**.
- Fase 7 pasa de bloqueada a **activa**, pero no está completada; debe avanzar por sus issues y criterios de aceptación.
- PR #32 (`Phase 7: world zones foundation`) sigue fuera de `main`; no debe mergearse automáticamente porque nació antes del contrato visual y debe reevaluarse contra #17/#16.
- Fuente funcional/arquitectónica: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Fuente de planificación: `ROADMAP.md` + issues activas.
- Contrato visual: `ART_DIRECTION.md`.
- Fuente narrativa: `HISTORIA_PRINCIPAL.md` — **El Cementerio de Valdeniebla**, spoiler-light.
- Política de idiomas: `LOCALIZATION.md`.

## Fases completadas

- Fase 0 — Bootstrap: run `33278173612`.
- Fase 1 — Core: run `33280758441`.
- Fase 2 — Items: `c196e3ab5a42adffe97278f0b0daa8960c789e04`, run `33285578050`.
- Fase 3 — Crafting: `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`.
- Fase 4 — Cementerio: `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`.
- Fase 5 — Simulación: `f0290951a27d5e66581da2532151d957ec35075e`, run `33297774458`.
- Fase 6 — RPG: PR #39, merge `1efe0bc9a47c2a434c597276bc326d24713720aa`; run `33309017205` de `main` verde.

## Fase 6 — RPG — COMPLETADA

### Sistemas validados

1. Diálogo/localización EN/ES: `46a37e00c2ad968e91834da5577a6f512a28f0a9`, run `33298737838`.
2. Relaciones 0–100: `fc446609004ea8031903c1c529144743cd963e51`, run `33299277228`.
3. Condiciones contextuales: `e1a19343e8303d1b28188a2a38c559d788c8087d`, run `33299990183`.
4. Quests foundation: `979b2328cc01c8d5a7a0ae4201deabe58cf9cc38`, run `33301533785`.
5. Economía foundation: `184f2b6d9df6d0b26dcfeb7d2a2d8e3dc7604863`, run `33304080534`.
6. Tecnología foundation: `444fc2995ab14b293188aba54a0f4099dc3c36b3`, run `33305211363`.
7. Comercio UI #6: merge `3d6252e840ae32e5445f454170d0856909bf6a2b`, run `33307358527`.
8. Tecnología ↔ quests #8: merge `8cd26c98e3e43d982218ccf97869ab0c6a0830b3`; recompensa tipada, compatibilidad `QUEST_FLAG`, idempotencia y persistencia verificadas.
9. Quality gate global #38: merge `cb4c14351abbee84f3162197cdf4ba794ab9846f`, run `33308014015`; descubrimiento dinámico de todos los `*.gd`.
10. Cierre integral #9: `test_rpg_acceptance.gd` reforzado en `ea3543aba5b6d859266553a964d817f54670b9a3`, run `33308814397`.

### Aceptación integral final

El test de cierre usa `world.tscn` real y cubre en un único flujo relación→diálogo, quest, recompensa única, puntos tecnológicos, unlock, compra/venta, guardado, destrucción/reconstrucción del mundo, restauración de providers e idempotencia posterior a load.

## Transición visual pre-Fase 7 — #17 RESUELTA

`ART_DIRECTION.md` fija un contrato original y verificable para producción independiente:

- proyección: 2D ortográfica cenital 3/4, cuadrícula no isométrica;
- tile lógico: `32 x 32 px`, submódulos de 16/8 px;
- frame humano estándar: `32 x 48 px`, pivot/Y-sort en pies;
- footprint de referencia: `20 x 28 px` para player/NPC humano mientras una tarea de gameplay no lo cambie explícitamente;
- resolución de referencia: `1280 x 720`, zoom base `1.5x`, nearest filtering;
- capas: `ground`, `paths`, `decoration_low`, `collision`, `objects_y_sorted`, `foreground_occlusion`;
- paleta base original y rangos de valor por cementerio/bosque/pueblo/interiores;
- luz diurna desde arriba-izquierda y sombras abajo-derecha;
- reglas de contorno, detalle, dithering, nombres, carpetas y spritesheets;
- ejemplos numéricos de footprint de personaje y árbol Y-sorted.

#17 no modifica escenas, gameplay, Autoloads ni assets finales. Su función es eliminar decisiones visuales incompatibles antes de #16.

## Decisiones vigentes

- Mantener exactamente cinco Autoloads globales.
- `TimeManager` es la única fuente de reloj/calendario.
- NPCs, diálogo, relaciones, quests, economía y tecnología permanecen locales/contextuales.
- IDs, condiciones, saves y progreso son independientes del idioma.
- UI observa modelos/controllers y emite intents; no contiene lógica de negocio.
- Gameplay data-driven mediante Resources tipados cuando corresponda.
- Dinero y precios usan enteros en cobre; UI solo formatea oro/plata/cobre.
- Recompensas de quest son idempotentes para todos sus tipos.
- Los desbloqueos tecnológicos se identifican por IDs estables.
- El quality gate descubre todos los `*.gd` automáticamente; no volver a listas blancas manuales.
- Fase 7 debe respetar `ART_DIRECTION.md`; cualquier excepción de escala/pivote/capa debe justificarse explícitamente.
- `TileMapLayer` es la base técnica obligatoria de mapas; la lógica de mundo no debe incrustarse en sus tiles.
- No reutilizar PR #32 sin revisar su compatibilidad con el contrato visual y los criterios de #16.

## Próximo paso

Implementar **#16 — Foundation técnica de mapas con `TileMapLayer`**. Debe crear al menos un mapa técnico cargable con las seis capas contractuales, preservar movimiento, colisión, navegación, Y-sort/occlusion y camera bounds, y cerrar con smoke + suite headless + quality gate verdes. No producir todavía mapas o assets finales de #18/#19/#20/#21/#22.

## Regla de continuidad

Al retomar:
1. Leer `DEV_MEMORY.md`, `ROADMAP.md`, `ART_DIRECTION.md` y la issue activa.
2. Revisar `main` y el último CI.
3. Comprobar dependencias antes de iniciar trabajo nuevo.
4. Implementar un bloque coherente y pequeño.
5. Ejecutar quality gate, importación, smoke y suite headless cuando corresponda.
6. Corregir errores críticos antes de avanzar.
7. Actualizar `DEV_MEMORY.md`, `ROADMAP.md` y `CHANGELOG.md`.
8. No marcar una fase o dependencia como completada sin cumplir sus criterios explícitos.
