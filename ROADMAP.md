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
- [x] **#16 — Foundation técnica `TileMapLayer`** — PR #44.
- [x] **#18 — Cementerio + taller del jugador** — PR #47. GREEN: `33316327221`.
- [x] **#19 — Bosque de recursos** — PR #48. GREEN: `33316454888`.
- [x] **#20 — Pueblo de Valdeniebla** — PR #46. GREEN: `33315626881`.
- [x] **#21 — Interiores modulares + transiciones** — PR #49. GREEN: `33318051580`.
- [x] **#22 — Mina inicial** — PR #50. GREEN: `33318407597`.
- [x] **#23 — Integración de zonas + exploración y secretos** — PR #53 fusionada como `6c84c0f2d0e97e64c8f4f94f8de7ef144111c86a`; issue #23 cerrada. GREEN final del PR: `33331094583`.

### #23 — criterios cubiertos
- [x] Cementerio/taller, bosque, pueblo, mina y dos interiores conectados desde un shell persistente.
- [x] Una única instancia lógica de Player y controllers persistentes durante transiciones.
- [x] Estado RPG/cementerio preservado durante viajes y save/load.
- [x] Spawns deterministas; viaje inválido conserva zona y posición.
- [x] Cámara/bounds se adaptan a la zona activa.
- [x] Aldren conserva identidad y estado persistente; se oculta/pausa fuera de cementerio.
- [x] Forest resources, secret clearing, merchant spot, interiores y secret landmark de mina cubiertos por aceptación.
- [x] `WorldLocationProvider` guarda/resta zona, marker y posición con fallback seguro.
- [x] `gdlint`, `gdformat --check`, Godot 4.7.2 import, smoke y suite headless verdes.

### Cierre de Fase 7: #24 — SIGUIENTE BLOQUE OBLIGATORIO
No marcar Fase 7 como completada hasta que #24 valide conjuntamente:
- [ ] todas las zonas cargables y seis `TileMapLayer` contractuales;
- [ ] recorrido integral sin softlocks y sin cambiar identidad del Player;
- [ ] navegación/schedule de NPC y Y-sort sin regresiones;
- [ ] save/load con ubicación válida;
- [ ] camera bounds, colisiones, spawns y transiciones correctas;
- [ ] `gdlint` + `gdformat --check` globales;
- [ ] Godot 4.7.2 import, smoke y suite completa verdes;
- [ ] `DEV_MEMORY.md`, `ROADMAP.md`, `CHANGELOG.md` y `README.md` sincronizados.

## Fase 8 — Polish — BLOQUEADA POR #24
Arte, animaciones, shaders, partículas, audio, feedback, UI final y optimización.

El sub-track visual #25–#31 no debe comenzar hasta cerrar Fase 7 mediante #24, respetando `ART_DIRECTION.md`.
