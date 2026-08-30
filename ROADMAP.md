# ROADMAP

## Fase 0 — Bootstrap — COMPLETADA
- [x] Repositorio, Godot 4.x, escena raíz, estructura y Autoloads mínimos.
- [x] InputMap, logging, debug, persistencia inicial, tests y CI headless.
- Validación: `33278173612`.

## Fase 1 — Core / Walking Prototype — COMPLETADA
- [x] Mundo base, `CharacterBody2D`, movimiento 8 direcciones, cámara, colisiones y Y-sort.
- [x] `Interactable` reutilizable y aceptación de escenas.
- Validación: `33280758441`.

## Fase 2 — Items / Resource Loop — COMPLETADA
- [x] `ItemData`, inventario, stacks/capacidad, energía, recursos, herramientas y loot.
- [x] Tests del loop completo.
- Cierre: `c196e3ab5a42adffe97278f0b0daa8960c789e04`, run `33285578050`.

## Fase 3 — Crafting / Production Loop — COMPLETADA
- [x] Recetas data-driven, crafting atómico, `StorageNetwork` y producción temporizada.
- [x] Tests y CI final verdes.
- Cierre: `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`.

## Fase 4 — Cementerio — COMPLETADA
- [x] Cadáveres, descomposición, tumbas, rating, preparación/entierro/mejoras y persistencia.
- [x] Tests de aceptación y CI final verdes.
- Cierre: `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`.

## Fase 5 — Simulación — COMPLETADA
- [x] Reloj/calendario, ciclo día/noche y sueño.
- [x] `NPCData`, `NavigationAgent2D`, horarios, estados y persistencia NPC.
- [x] Aceptación integral y CI final verdes.
- Cierre: `f0290951a27d5e66581da2532151d957ec35075e`, run `33297774458`.

## Fase 6 — RPG — COMPLETADA
- [x] Diálogo/localización EN/ES, relaciones y condiciones contextuales.
- [x] Quests con recompensas idempotentes.
- [x] Economía atómica + comercio UI jugable.
- [x] Tecnologías + integración de puntos tecnológicos desde quests.
- [x] Persistencia conjunta de providers RPG.
- [x] Aceptación integral final #9 sobre `world.tscn` real.
- [x] Quality gate global para todos los `*.gd`.
- Cierre integral: PR #39, acceptance HEAD `ea3543aba5b6d859266553a964d817f54670b9a3`, run `33308814397`.
- Runtime/CI actualizado a **Godot 4.7.2** mediante PR #41.

## Transición pre-Fase 7 — COMPLETADA
1. [x] **#17 — Contrato visual**: `ART_DIRECTION.md` fija perspectiva, tile 32 px, escala/footprints, cámara, pivotes/Y-sort, capas, paleta, luz y convenciones de assets.
2. [x] **#16 — TileMapLayer foundation**: mapa técnico, seis capas contractuales y sustitución del blockout de suelo/colisión.

## Fase 7 — Mundo — ACTIVA
Pueblo, bosque, mina, interiores, exploración y secretos.

### Bloques completados
- [x] **#16 — Foundation técnica `TileMapLayer`** — PR #44. Seis capas contractuales, tile lógico 32 px, bounds estables, colisión tile-based e integración mínima en `world.tscn`.
- [x] **#18 — Cementerio + taller del jugador** — PR #47. `world/maps/cemetery/cemetery_map.tscn`, interacciones críticas, markers, navegación y aceptación dedicada. GREEN: run `33316327221`.
- [x] **#19 — Bosque de recursos** — PR #48. Mapa compacto, caminos, límites, recursos existentes, landmarks/secret clearing y navegación. GREEN: run `33316454888`.
- [x] **#20 — Pueblo de Valdeniebla** — PR #46. Plaza, entrada, merchant spot, plots/markers de interiores y navegación. GREEN: run `33315626881`.
- [x] **#21 — Interiores modulares + transiciones** — PR #49. Casa/taller + edificio de pueblo, markers estables y transición sin duplicar player. GREEN: run `33318051580`.
- [x] **#22 — Mina inicial** — PR #50. Entrada/salida, corredor/bifurcación, oclusión, navegación y recursos existentes. GREEN: run `33318407597`.

### Estado integrado actual
- HEAD de `main`: `725529b9b5f9091853b1e78d8031d6dafcd2277a` (merge PR #50).
- CI de `main`: run `33325342447`, `success` en Godot 4.7.2.
- No hay PR abiertos en el repositorio tras la integración de #46–#50.
- Issues #21 y #22, que habían quedado abiertas pese a sus merges, se cerraron como `completed` durante la sincronización documental.

### Siguiente bloque obligatorio: #23 — Integración de zonas + exploración y secretos
- [ ] Conectar cementerio/taller, bosque, pueblo, mina e interiores desde `world/world.tscn`.
- [ ] Mantener una única instancia lógica del player durante transiciones.
- [ ] Preservar inventario, energía, quests, economía, relaciones y tecnología.
- [ ] Usar spawns deterministas y seguros y adaptar cámara/bounds por zona.
- [ ] Mantener navegación/schedules de NPCs sin regresiones.
- [ ] Añadir únicamente el mínimo de rutas secundarias/secretos requerido por #23.
- [ ] Validar recorrido integral: propiedad → cementerio → bosque → pueblo/comercio → interior → mina → propiedad.
- [ ] Guardar/cargar sin perder estado ni quedar en una ubicación inválida.

### Cierre de Fase 7: #24
No marcar Fase 7 como completada hasta que #23 esté verde y #24 valide conjuntamente:
- [ ] todas las zonas cargables y navegables;
- [ ] recorrido integral sin softlocks;
- [ ] navegación NPC y Y-sort sin regresiones;
- [ ] save/load con ubicación válida;
- [ ] camera bounds, colisiones y transiciones correctas;
- [ ] `gdlint` + `gdformat --check` globales;
- [ ] Godot 4.7.2 import, smoke y suite completa verdes;
- [ ] `DEV_MEMORY.md`, `ROADMAP.md`, `CHANGELOG.md` y `README.md` sincronizados.

## Fase 8 — Polish — BLOQUEADA POR #24
Arte, animaciones, shaders, partículas, audio, feedback, UI final y optimización.

El sub-track visual #25–#31 no debe comenzar hasta cerrar Fase 7 mediante #24, respetando `ART_DIRECTION.md`.
