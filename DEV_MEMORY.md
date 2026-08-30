# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`.
- Rama principal: `main`.
- Runtime/CI objetivo: **Godot 4.7.2**.
- HEAD integrado actual de `main`: `725529b9b5f9091853b1e78d8031d6dafcd2277a` (merge PR #50).
- Último CI de `main`: run `33325342447`, `success`.
- Fases 0–6: **COMPLETADAS**.
- Fase 7 — Mundo: **ACTIVA**.
- #17 contrato visual y #16 foundation `TileMapLayer`: completadas.
- Mapas independientes de Fase 7 #18–#22: **todos integrados en `main`**.
- No hay PR abiertos después de los merges #46–#50.
- Próximo bloque obligatorio: **#23 — integración de zonas + exploración y secretos**.
- Fase 7 solo puede cerrarse mediante **#24 — aceptación integral de mundo** después de #23.
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

No modificar estos sistemas durante #23 salvo corrección estrictamente necesaria por integración de escenas.

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

- `world/maps/technical_map.tscn` + `TechnicalMap`.
- 50x32 tiles, `1600 x 1024` px.
- Colisión tile-based y seis capas contractuales.
- `world.tscn` dejó atrás `Ground`, `Boundaries` y `WorkshopBlock` legacy.
- PR #44; run funcional `33313715794`; CI de merge verde.

### #18 — Cementerio + taller — COMPLETADA

- PR #47.
- `world/maps/cemetery/cemetery_map.tscn`.
- Reutiliza workbench, storage, sleep spot y cementerio existentes.
- Markers estables: player/Aldren, salidas a bosque/pueblo y expansión futura.
- Navegación y aceptación dedicada.
- GREEN: run `33316327221`.

### #19 — Bosque — COMPLETADA

- PR #48.
- `world/maps/forest/*`.
- Caminos primario/secundario, límites, navegación, recursos existentes y secret clearing reservado.
- GREEN: run `33316454888`.

### #20 — Pueblo — COMPLETADA

- PR #46.
- `world/maps/village/village_map.tscn`.
- Entrada, plaza, merchant spot, plots y markers de interiores.
- GREEN: run `33315626881`.

### #21 — Interiores — COMPLETADA

- PR #49.
- `home_workshop.tscn`, `village_building.tscn` e `InteriorTransition`.
- Mantiene la misma instancia del player al moverlo entre markers.
- SaveManager aún no persiste por sí mismo “interior activo”; #23/#24 deben resolver la ubicación válida dentro del contrato de integración, sin ampliar innecesariamente el sistema.
- GREEN: run `33318051580`.
- Issue #21 cerrada como `completed` tras detectar que había quedado abierta después del merge.

### #22 — Mina — COMPLETADA

- PR #50.
- `world/maps/mine/mine_map.tscn`.
- Entrada/salida, corredor principal, bifurcación, oclusión/foreground y landmark secreto.
- Reutiliza recursos existentes; no introduce combate/minería avanzada.
- GREEN: run `33318407597`.
- Merge final deja `main` en `725529b9b5f9091853b1e78d8031d6dafcd2277a`.
- Issue #22 cerrada como `completed` tras detectar que había quedado abierta después del merge.

## Limpieza de backlog realizada

- #5 economía ↔ inventario + persistencia: cerrada como `completed`; su alcance ya estaba implementado/validado en Fase 6.
- #7 tecnologías: cerrada como `completed`; su alcance ya estaba implementado/validado en Fase 6.
- #21 y #22: cerradas como `completed` después de confirmar sus PR merged y CI verdes.

## Próximo paso — #23 Integración de zonas

Trabajar exclusivamente sobre la integración del mundo modular:

1. Conectar cementerio/taller, bosque, pueblo, mina e interiores desde `world/world.tscn`.
2. Mantener una única instancia lógica del player.
3. Definir spawns/transiciones deterministas y seguros.
4. Adaptar cámara y bounds por zona.
5. Preservar inventario, energía, quests, economía, relaciones y tecnología.
6. Mantener navigation/schedules de NPCs.
7. Añadir solo el mínimo de rutas secundarias/secretos exigido por #23.
8. Validar el recorrido completo propiedad → cementerio → bosque → pueblo/comercio → interior → mina → propiedad.
9. Guardar/cargar debe conservar estado y producir una ubicación válida.

No empezar #24 hasta que #23 esté verde. No empezar Fase 8 hasta cerrar #24.

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
8. No marcar Fase 7 completada antes de cumplir #23 y #24.
