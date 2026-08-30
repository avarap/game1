# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`.
- Rama principal: `main`.
- Runtime/CI objetivo: **Godot 4.7.2**.
- HEAD de integración de #23: `6c84c0f2d0e97e64c8f4f94f8de7ef144111c86a` (merge PR #53).
- CI final del PR #53: run `33331094583`, `success`.
- Fases 0–6: **COMPLETADAS**.
- Fase 7 — Mundo: **ACTIVA**.
- #17 contrato visual y #16 foundation `TileMapLayer`: completadas.
- Mapas independientes de Fase 7 #18–#22: integrados.
- **#23 — integración de zonas: COMPLETADA**, PR #53 fusionada; issue #23 cerrada como `completed`.
- Próximo bloque obligatorio: **#24 — aceptación integral de mundo**.
- Fase 7 no se considera completada hasta cerrar #24.
- Fase 8 y su sub-track visual #25–#31 permanecen bloqueados por #24.

## Fuentes de verdad

- Funcional/arquitectónica: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Planificación: `ROADMAP.md` + issues activas.
- Contrato visual: `ART_DIRECTION.md`.
- Narrativa: `HISTORIA_PRINCIPAL.md` — **El Cementerio de Valdeniebla**.
- Idiomas: `LOCALIZATION.md`.

## Fases completadas

- Fase 0 — Bootstrap: run `33278173612`.
- Fase 1 — Core: run `33280758441`.
- Fase 2 — Items: `c196e3ab5a42adffe97278f0b0daa8960c789e04`, run `33285578050`.
- Fase 3 — Crafting: `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`.
- Fase 4 — Cementerio: `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`.
- Fase 5 — Simulación: `f0290951a27d5e66581da2532151d957ec35075e`, run `33297774458`.
- Fase 6 — RPG: PR #39; aceptación integral HEAD `ea3543aba5b6d859266553a964d817f54670b9a3`, run `33308814397`.

## Fase 6 — RPG — estado estable

Sistemas existentes y validados:

- diálogo/localización EN/ES;
- relaciones 0–100 y condiciones contextuales;
- quests y recompensas idempotentes;
- economía atómica y UI de comercio;
- tecnologías rojo/verde/azul;
- integración quest → puntos tecnológicos;
- persistencia conjunta de providers RPG;
- aceptación integral con save/load y reconstrucción del mundo;
- quality gate global para todos los `*.gd`.

No modificar estos sistemas durante Fase 7 salvo corrección estrictamente necesaria por integración de escenas.

## Contrato visual/técnico vigente

`ART_DIRECTION.md` + #16 fijan:

- proyección 2D ortográfica cenital 3/4;
- tile lógico `32 x 32 px`;
- seis capas: `ground`, `paths`, `decoration_low`, `collision`, `objects_y_sorted`, `foreground_occlusion`;
- pivotes/Y-sort en pies;
- resolución de referencia `1280 x 720`, zoom base `1.5x`;
- `TileMapLayer` como base de composición;
- lógica de gameplay fuera de los tiles;
- TileSet técnico de colores solo como diagnóstico, no arte final.

## Fase 7 — Mundo — progreso integrado

### #16 — Foundation técnica — COMPLETADA
- PR #44; seis capas contractuales, bounds estables y colisión tile-based.
- GREEN: run funcional `33313715794`.

### #18 — Cementerio + taller — COMPLETADA
- PR #47; mapa, interacciones críticas, markers y navegación.
- GREEN: run `33316327221`.

### #19 — Bosque — COMPLETADA
- PR #48; caminos, navegación, recursos y secret clearing reservado.
- GREEN: run `33316454888`.

### #20 — Pueblo — COMPLETADA
- PR #46; entrada, plaza, merchant spot y markers de interiores.
- GREEN: run `33315626881`.

### #21 — Interiores — COMPLETADA
- PR #49; casa/taller, edificio de pueblo y transiciones estables.
- GREEN: run `33318051580`.

### #22 — Mina — COMPLETADA
- PR #50; entrada/salida, corredores, oclusión y landmark secreto.
- GREEN: run `33318407597`.

### #23 — Integración de zonas + exploración — COMPLETADA

- PR #53 fusionada en `main` como `6c84c0f2d0e97e64c8f4f94f8de7ef144111c86a`.
- `world/world.tscn` es un shell persistente con un único Player y controllers RPG/cementerio persistentes.
- `ZoneManager` carga exactamente una zona en `ZoneContainer` y crea transiciones deterministas entre cementerio, bosque, pueblo, dos interiores y mina.
- Player y controllers conservan `instance_id` durante el recorrido completo.
- `WorldLocationProvider` persiste `zone_id`, marker y posición y restaura/clampa la ubicación con fallback seguro.
- Cámara adopta bounds de cada mapa.
- TradePoint se activa solo en pueblo; Aldren permanece persistente y se oculta/pausa fuera del cementerio.
- La restauración de ubicación no refresca ni reescribe estado persistente de NPCs.
- Los tests legacy re-resuelven interactables locales después de reconstruir una zona durante load.
- Aceptación #23 cubre transiciones, identidad persistente, recursos del bosque, secret clearing, merchant spot, interiores, secret landmark de mina, viajes inválidos y save/load de ubicación.
- GREEN final del PR: run `33331094583` — `gdscript-quality`, import Godot 4.7.2, smoke y suite headless completa.
- Issue #23 cerrada como `completed`.

## Errores detectados y decisiones durante #23

- `SleepSpot` quedaba como referencia obsoleta después de que `WorldLocationProvider` reconstruyera la zona al cargar; el test ahora re-resuelve el interactable de la instancia activa.
- La reconstrucción de zona podía sobreescribir el provider persistente de Aldren; `ZoneManager.travel_to` permite restaurar ubicación sin refrescar actores persistentes.
- `gdformat` exigía la forma canónica de `ROUTES`; se aplicó el formato exacto y el quality gate global queda verde.
- No se añadió arte/polish ni contenido de Fase 8.

## Próximo paso — #24 Aceptación integral de Fase 7

1. Revalidar todas las zonas y seis `TileMapLayer` contractuales.
2. Recorrer todas las rutas sin cambiar la identidad del Player.
3. Verificar navegación/schedule de Aldren, Y-sort, colisiones y spawns.
4. Revalidar save/load de ubicación y camera bounds en varias zonas.
5. Ejecutar `gdlint`, `gdformat --check`, import, smoke y suite completa.
6. Corregir únicamente defectos de integración de Fase 7.
7. Cerrar #24 solo con CI verde y entonces marcar Fase 7 COMPLETADA / Fase 8 ACTIVA en toda la documentación.

## Decisiones vigentes

- Mantener exactamente cinco Autoloads globales.
- `TimeManager` es la única fuente de reloj/calendario.
- NPCs, diálogo, relaciones, quests, economía y tecnología permanecen locales/contextuales.
- IDs, condiciones, saves y progreso son independientes del idioma.
- UI observa modelos/controllers y emite intents; no contiene lógica de negocio.
- Gameplay data-driven mediante Resources tipados cuando corresponda.
- Dinero/precios usan cobre entero; UI solo formatea oro/plata/cobre.
- Recompensas de quest e unlocks tecnológicos son idempotentes.
- Quality gate descubre todos los `*.gd` automáticamente.
- `TileMapLayer` compone el mapa; la lógica sigue en escenas/componentes/sistemas.
- No producir arte final hasta Fase 8.

## Regla de continuidad

Al retomar:
1. Leer `DEV_MEMORY.md`, `ROADMAP.md`, `ART_DIRECTION.md` y la issue activa.
2. Revisar `main`, PRs abiertos y último CI.
3. Comprobar dependencias antes de iniciar trabajo nuevo.
4. Implementar un bloque coherente y pequeño.
5. Ejecutar quality gate, importación, smoke y suite headless.
6. Corregir errores críticos antes de avanzar.
7. Actualizar `DEV_MEMORY.md`, `ROADMAP.md` y `CHANGELOG.md`.
8. No marcar Fase 7 completada antes de cerrar #24.
