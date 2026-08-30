# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`.
- Rama principal: `main`.
- Fase completada más reciente: **Fase 6 — RPG**.
- Cierre funcional de Fase 6: PR #39, merge `1efe0bc9a47c2a434c597276bc326d24713720aa`; aceptación HEAD `ea3543aba5b6d859266553a964d817f54670b9a3`, run `33308814397`.
- Runtime/CI objetivo: **Godot 4.7.2** por PR #41, merge `1b4ff623b45c465bfb9bd57f2b96b6ecec88a2ad`.
- **#17 — contrato visual** resuelto mediante `ART_DIRECTION.md`.
- **#16 — foundation técnica `TileMapLayer` cerrada mediante PR #44**: `technical_map.tscn` + `TechnicalMap`, seis capas contractuales, tiles de 32 px, bounds `1600 x 1024`, colisión tile-based e integración mínima en `world.tscn`.
- HEAD funcional validado de #16: `00264c1e3ff920a46bad908182a8a89fbbb20263`, run `33313715794`, ambos jobs `success` en Godot 4.7.2. Merge final `fec32bd85b78a60acc29dbd0c2b651cad735def7`; CI de `main` `33314012640`, ambos jobs `success`; issue #16 cerrada como `completed`.
- Fase 7 — Mundo permanece **ACTIVA**; #16 no cierra la fase.
- **Siguiente bloque obligatorio: #18 — mapa exterior cementerio + taller del jugador (P0)**. #19 — bosque es P1 y también queda desbloqueada tras #16/#17, pero no adelantarla antes de #18 en la ejecución secuencial actual.
- PR #32 está cerrado sin merge y marcado superseded; no reutilizarlo como implementación de Fase 7.
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
- reglas de contorno, detalle, dithering, nombres, carpetas y spritesheets.

## Fase 7 — Mundo — ACTIVA

### #16 — Foundation técnica de mapas — VALIDADA

Implementación:

- `world/maps/technical_map.tscn` define exactamente las seis capas de `ART_DIRECTION.md` como `TileMapLayer`.
- `world/maps/technical_map.gd` crea un TileSet técnico runtime de 32 px únicamente para diagnóstico/foundation; no es arte final ni debe convertirse en lógica de gameplay.
- Mapa técnico: `50 x 32` tiles = `1600 x 1024` px; `get_world_rect()` expone bounds estables.
- `ground`, `paths` y `decoration_low` no crean colisión; `collision` posee la physics layer y tiles de perímetro/obstáculo; `objects_y_sorted` mantiene Y-sort y `foreground_occlusion` queda por encima.
- `world.tscn` instancia `TechnicalMap` y elimina el blockout legacy `Ground`, `Boundaries` y `WorkshopBlock`; todos los sistemas de gameplay existentes permanecen.
- La Camera2D conserva límites compatibles con el mapa (`1600 x 1000`, dentro de `1600 x 1024`) y zoom `1.5x`.
- `NavigationRegion2D` conserva su comportamiento existente; tests de navegación/NPC siguen verdes.

TDD / validación:

- RED inicial `33313004010`: todos los sistemas previos verdes y único fallo `Technical TileMapLayer map should exist`.
- RED ampliado `33313174308`: 9 fallos exactamente ligados a bounds, tiles/physics e integración todavía ausentes; sin regresiones previas.
- Primer GREEN funcional detectó dos incidencias reales: `TileData` configuraba collision polygon antes de registrar el atlas en el `TileSet`, y `test_walking_prototype.gd` mantenía una aserción obsoleta que exigía el nodo legacy `Boundaries`.
- Se corrigió el orden de registro del atlas y el test legacy pasó a verificar la nueva colisión `TechnicalMap/collision` sin rebajar cobertura.
- El quality gate detectó únicamente formato de `technical_map.gd`; se obtuvo el diff canónico con un run diagnóstico temporal y el workflow estricto fue restaurado antes de validar.
- HEAD funcional final `00264c1e3ff920a46bad908182a8a89fbbb20263`, run `33313715794`: `gdlint` global, `gdformat --check` global, importación Godot 4.7.2, smoke y suite completa `success`; `MapFoundation` y `WalkingPrototype` 0 fallos.
- Merge final de #16: PR #44 → `fec32bd85b78a60acc29dbd0c2b651cad735def7`; run de `main` `33314012640` con quality, importación, smoke y suite headless `success`.
- Los mensajes `fontconfig` del contenedor 4.7.2 son ruido baseline del image CI; no hubo errores de `TechnicalMap`, TileSet, física o tests en el run final.

### Restricciones para mapas posteriores

- Reutilizar las seis capas y tile lógico de 32 px; no reintroducir Polygon2D/StaticBody blockout como foundation principal.
- La lógica de mundo no se incrusta en `TileMapLayer`; las capas presentan/componen y la lógica sigue en escenas/componentes/sistemas.
- El TileSet de colores de `TechnicalMap` es diagnóstico, no asset final ni paleta de producción cerrada.
- #18/#19/#20/#21/#22 deben trabajar en sus carpetas/ownership y respetar #16 + `ART_DIRECTION.md`.

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
- PR #32 queda solo como referencia histórica; está superseded y cerrado sin merge.

## Próximo paso

Implementar **#18 — Mapa exterior: cementerio + taller del jugador**. Debe vivir bajo `world/maps/cemetery/*`, reutilizar #16/#17, mantener accesibles las interacciones actuales y validar carga, colisión, navegación, Y-sort y posiciones críticas. No tocar `world/world.tscn`, otros mapas ni ampliar narrativa/gameplay fuera de la adaptación mínima permitida por la issue.

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
