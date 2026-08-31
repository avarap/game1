# ROADMAP

## Estado global

- Fases 0–7: **COMPLETADAS**.
- Fase 8 — Polish: **ACTIVA**.
- Runtime/CI contractual: **Godot 4.7.2**.
- HEAD de referencia para esta sincronización: `81021973025302213dc64ef8f4a4744673c5dd75`.
- CI de `main` para ese HEAD: run `33350515654`, success.
- Gate P0 temporal: no integrar nuevos PR de Fase 8 hasta cerrar #82 y #83 y dejar `main` verde.

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
- [x] **8A.4 — Recurso multiuso (#61):** `fodder_turnip` integrado en items/storage, economía y crafting mediante PR #81, merge `3cab1b15c0e990a76d0e40df42362ff2b0f0dfb1`.
- [ ] **8A.5 — Servicio funerario (#62):** entrega diaria determinista a las 18:00, intro gratuita y después consumo de alimento.
- [ ] **8A.6 — Logística progresiva (#63):** descarga inicial + rampa desbloqueable.
- [ ] **8A.7 — Decisiones de cadáver (#64):** cremar/investigar además de preparar/enterrar.
- [ ] **8A.8 — Feedback/hooks (#65):** eventos desacoplados para audio/FX.
- [ ] **8A.9 — Aceptación integral (#66):** farming→comedero→18:00→cadáver→decisión→save/load.

Tracker: #71.

### Sub-track visual #25–#31

- [x] **#25 — Tileset exterior pixel-art original** — PR #56.
- [x] **#26 — Player spritesheet + animaciones** — PR #75, integrado en HEAD `8102197`; main run `33350515654`.
- [ ] **#27 — NPC visual base + Brother Aldren animado**.
- [x] **#28 — Props, edificios y cementerio** — PR #79, main run `33340142216`.
- [x] **#29 — Integración artística de mapas** — PR #80, merge `0e60751bf7346b597bbeba5fcd495b2b27445a27`, main run `33350442187`.
- [ ] **#30 — Atmósfera, iluminación, vegetación y partículas**.
- [ ] **#31 — Aceptación visual del vertical slice**.

Tracker: #72.

### UI / audio / estabilidad

- [ ] **#68 — UI final y UX:** sigue abierta. Ya están integrados HUD y base de pause/settings mediante PR #78, merge `1536ece0e28a3c8da99aa415a557f951bed9613d`; queda trabajo de aceptación final.
- [ ] **#67 — Audio final y mezcla básica**.
- [ ] **#69 — Optimización, estabilidad y export**.
- [ ] **#70 — Aceptación integral / release candidate** — único gate autorizado para cerrar Fase 8.

Tracker final: #73.

## Gate P0 temporal de auditoría

Antes de fusionar más trabajo de Fase 8:

- [ ] **#82 — Regression test Brother Aldren cemetery save/load**: debe demostrar que el restore conserva posición/rutina persistidas y fallaría si se revierte la protección `refresh_persistent_actors=false` o equivalente.
- [ ] **#83 — Sincronización documental**: `ROADMAP.md`, `DEV_MEMORY.md`, `CHANGELOG.md` y `README.md` contra el HEAD real.
- [ ] `main` verde después de ambos cierres.

Mientras este gate esté activo, los workers pueden preparar PRs independientes, pero el supervisor no los integra.

## Quality bar visual obligatorio

La referencia aprobada es el mockup pixel-art oscuro del cuidador del cementerio: personajes detallados y legibles, 8 direcciones coherentes, ropa/equipamiento reconocibles, paleta medieval oscura, iluminación cálida localizada, sombras profundas, entorno denso y props/vegetación integrados. No se aceptan downgrades a sprites planos, placeholders, blockout o escenarios vacíos aunque los tests técnicos estén verdes. Si 32x48 impide mantener el detalle exigido, debe reevaluarse la escala antes de aceptar una degradación.

## Cola autónoma preparada

- #82 — `[AUTO][GAMEPLAY][P0]` regresión Aldren.
- #84 — `[AUTO][CHARACTERS][P0]` Brother Aldren visual base + animation, referencia #27.
- #85 — `[AUTO][WORLD][P1]` atmósfera/lighting/FX, referencia #30.
- #86 — `[AUTO][UI][P0]` core panels visual/UX pass, referencia #68.

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
