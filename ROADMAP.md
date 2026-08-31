# ROADMAP

## Estado global

- Fases 0–7: **COMPLETADAS**.
- Fase 8 — Polish: **ACTIVA**.
- Runtime/CI contractual: **Godot 4.7.2**.
- HEAD de referencia para esta sincronización: `16f13eeaa306a048c7c397cc6b6687585b15b3f1`.
- CI de `main` para ese HEAD: run `33372934693`, success.
- Gate P0 temporal de auditoría **SUPERADO**: #82 y #83 cerradas y `main` verde.

## Fases 0–6 — COMPLETADAS

- Fase 0 — Bootstrap: repositorio, escena raíz, Autoloads, InputMap, persistencia, tests y CI.
- Fase 1 — Core: movimiento 8 direcciones, cámara, colisiones, Y-sort e interacción.
- Fase 2 — Items: inventario, energía, recursos, herramientas y loot.
- Fase 3 — Crafting: recetas data-driven, crafting atómico, storage y producción temporizada.
- Fase 4 — Cementerio: cadáveres, tumbas, rating, preparación/entierro/mejoras y persistencia.
- Fase 5 — Simulación: reloj/calendario, día/noche, sueño, NPCs, navegación y horarios.
- Fase 6 — RPG: diálogo/localización EN/ES, relaciones, quests, economía, comercio, tecnología y aceptación integral. Cierre PR #39, run `33308814397`.

## Fase 7 — Mundo — COMPLETADA

- [x] #16 — Foundation `TileMapLayer` — PR #44.
- [x] #17 — Contrato visual `ART_DIRECTION.md`.
- [x] #18 — Cementerio + taller — PR #47.
- [x] #19 — Bosque — PR #48.
- [x] #20 — Pueblo — PR #46.
- [x] #21 — Interiores + transiciones — PR #49.
- [x] #22 — Mina — PR #50.
- [x] #23 — Integración de zonas + exploración — PR #53.
- [x] #24 — Aceptación integral de mundo — PR #54, run `33331207740`.

Cierre funcional integrado: PR #54, merge `7e281255322b6c7444d4177d85295b353babb38f`.

## Fase 8 — Polish — ACTIVA

Arte, animaciones, shaders, partículas, audio, feedback, UI final, profundidad jugable y optimización. No se declara completada hasta #70.

### Track 8A — Gameplay Depth & Feel

Fuente: `docs/superpowers/specs/2026-08-30-phase8a-cemetery-depth-design.md`.

- [x] **8A.1 — Descomposición acelerada:** estado entero 0–100, edad en minutos, bandas crecientes y saltos temporales deterministas. PR #57.
- [x] **8A.2 — Conservación:** basis points enteros, composición multiplicativa y remainder persistente. PR #59.
- [x] **8A.3 — Agricultura mínima:** `fodder_turnip_seed` → plantar → crecer → cosechar → persistir. PR #76, main run `33342619691`.
- [x] **8A.4 — Recurso multiuso (#61):** `fodder_turnip` integrado en items/storage, economía y crafting mediante PR #81.
- [x] **8A.5 — Servicio funerario (#62):** entrega determinista a las 18:00, primera gratuita y consumo posterior de `fodder_turnip` real vía storage; PR #99.
- [ ] **8A.6 — Logística progresiva (#63):** implementación preparada en #100 / PR #101; CI del head resincronizado verde, pendiente de actualización contra el HEAD actual y revisión/merge.
- [ ] **8A.7 — Decisiones de cadáver (#64):** cremar/investigar además de preparar/enterrar.
- [ ] **8A.8 — Feedback/hooks (#65):** eventos desacoplados para audio/FX.
- [ ] **8A.9 — Aceptación integral (#66):** farming→comedero→18:00→cadáver→decisión→save/load.

Tracker: #71.

### Sub-track visual #25–#31

- [x] **#25 — Tileset exterior pixel-art original** — PR #56.
- [x] **#26 — Player spritesheet + animaciones** — PR #75.
- [ ] **#27 — NPC visual base + Brother Aldren animado** — implementación de #84 integrada mediante PR #89, pero la aceptación visual permanece pendiente de evidencia verificable y de #94/#96.
- [x] **#28 — Props, edificios y cementerio** — PR #79.
- [x] **#29 — Integración artística de mapas** — PR #80.
- [ ] **#30 — Atmósfera, iluminación, vegetación y partículas** — implementación WORLD integrada mediante PR #90; PR #102 corrigió la densidad runtime de `CPUParticles2D`. La aceptación visual sigue pendiente de evidencia reproducible.
- [ ] **#31 — Aceptación visual del vertical slice**.

Tracker: #72.

### UI / audio / estabilidad

- [ ] **#68 — UI final y UX:** PR #78 integró HUD/pause/settings y PR #91 integró paneles core; aceptación final todavía pendiente.
- [ ] **#67 — Audio final y mezcla básica** — #93 preparado.
- [ ] **#69 — Optimización, estabilidad y export**.
- [ ] **#70 — Aceptación integral / release candidate** — único gate autorizado para cerrar Fase 8.

Tracker final: #73.

## Gate P0 temporal de auditoría — SUPERADO

La auditoría iniciada sobre HEAD `81021973025302213dc64ef8f4a4744673c5dd75` queda resuelta:

- [x] **#82 — Regression test Brother Aldren cemetery save/load** — integrado mediante PR #92.
- [x] **#83 — Sincronización documental** — cerrada.
- [x] `main` verde — HEAD `16f13eeaa306a048c7c397cc6b6687585b15b3f1`, run `33372934693`, success.

La integración normal de Fase 8 continúa uno a uno, manteniendo todos los quality gates.

## Quality bar visual obligatorio

La referencia aprobada es el mockup pixel-art oscuro del cuidador del cementerio: personajes detallados y legibles, 8 direcciones coherentes, ropa/equipamiento reconocibles, paleta medieval oscura, iluminación cálida localizada, sombras profundas, entorno denso y props/vegetación integrados. No se aceptan downgrades a sprites planos, placeholders, blockout o escenarios vacíos aunque los tests técnicos estén verdes. Si 32x48 impide mantener el detalle exigido, debe reevaluarse la escala antes de aceptar una degradación.

Las capturas JPG añadidas en `docs/` por el commit `16f13ee` se conservan como material visual de referencia. No sustituyen el gate #96 ni se consideran evidencia determinista de aceptación hasta disponer de captura/procedencia reproducible y asociación explícita al HEAD evaluado.

## Cola autónoma

- GAMEPLAY: #100 tiene PR activo #101; no preparar otra tarea hasta resolverlo.
- AUDIO: #93 — `[AUTO][AUDIO][P1]` routing/ambiente/mezcla.
- ARCH: #94 — `[AUTO][ARCH][P0]` decisión de escala/resolución visual.
- QA: #96 — `[AUTO][QA][P0]` capturas visuales deterministas para aceptación.
- CHARACTERS: sin tarea preparada mientras #94/#96 bloqueen el siguiente paso.
- WORLD/UI: los incrementos ya están integrados; su aceptación visual se mantiene abierta pero no debe presentarse como trabajo autónomo desbloqueado mientras dependa de #96.

No preparar una segunda tarea del mismo carril mientras exista una issue preparada o PR activo de ese carril.

## Biblioteca de diseño y backlog

`docs/design/` es dirección secundaria: no sustituye este roadmap ni permite adelantar fases.

Orden futuro resumido: cerrar Fase 8/8A → consolidar catálogo/recetas/cadenas → tecnología/economía profesional → construcción/restauración/logística → clima/pesca → automatización avanzada.

## Post-MVP / Expansiones previstas

### Economía local por profesión

- Todo `ItemData` vendible debe tener al menos un comprador válido salvo `quest_only`, `key_item` o `non_sellable`.
- Comerciantes opt-in mediante `MerchantProfile` data-driven y afinidad por tags/categorías.
- Validación automática para detectar items vendibles sin salida económica.

### Automatización avanzada de producción

- Trabajadores originales del universo de `game1`, sin copiar zombies del benchmark.
- Tareas data-driven: `HARVEST`, `MINE`, `CHOP`, `TRANSPORT`, `PROCESS`.
- Progresión manual → automatización parcial → cadenas de producción completas.
- Dependencia de infraestructura, rutas, almacenamiento y mantenimiento/energía.
