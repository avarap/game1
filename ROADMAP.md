# ROADMAP

## Estado global

- Fases 0–7: **COMPLETADAS**.
- Fase 8 — Polish: **ACTIVA**.
- Runtime/CI contractual: **Godot 4.7.2**.
- HEAD de referencia para esta sincronización: `98045f4cfe4d8ee1b6c7f8061c7bb17356f81001`.
- CI de `main` para ese HEAD: run `33395789790`, **success**.
- Gate P0 histórico **SUPERADO**: #82 y #83 cerradas.
- No declarar Fase 8 completa hasta #70 sobre el mismo HEAD final con gates funcionales, técnicos y visuales cumplidos.

## Fases 0–7 — COMPLETADAS

- Fase 0 — Bootstrap: repositorio, escena raíz, Autoloads, InputMap, persistencia, tests y CI.
- Fase 1 — Core: movimiento 8 direcciones, cámara, colisiones, Y-sort e interacción.
- Fase 2 — Items: inventario, energía, recursos, herramientas y loot.
- Fase 3 — Crafting: recetas data-driven, crafting atómico, storage y producción temporizada.
- Fase 4 — Cementerio: cadáveres, tumbas, rating, preparación/entierro/mejoras y persistencia.
- Fase 5 — Simulación: reloj/calendario, día/noche, sueño, NPCs, navegación y horarios.
- Fase 6 — RPG: diálogo/localización EN/ES, relaciones, quests, economía, comercio, tecnología y aceptación integral.
- Fase 7 — Mundo: maps/zonas/interiores/mina e integración de exploración, cerrada por #24 / PR #54.

## Fase 8 — Polish — ACTIVA

Arte, animaciones, shaders, partículas, audio, feedback, UI final, profundidad jugable, estabilidad y optimización.

### Track 8A — Gameplay Depth & Feel

Fuente: `docs/superpowers/specs/2026-08-30-phase8a-cemetery-depth-design.md`.

- [x] **8A.1 — Descomposición acelerada** — PR #57.
- [x] **8A.2 — Conservación** — PR #59.
- [x] **8A.3 — Agricultura mínima** — PR #76.
- [x] **8A.4 — Recurso multiuso (#61)** — PR #81.
- [x] **8A.5 — Servicio funerario (#62)** — PR #99.
- [x] **8A.6 — Logística progresiva (#63)** — PR #103.
- [x] **8A.7 — Decisiones de cadáver (#64)** — PR #106; #104 y #64 cerradas.
- [x] **8A.8 — Feedback/hooks (#65)** — #111 / PR #112 integrados; #65 y #111 cerradas.
- [ ] **8A.9 — Aceptación integral (#66)** — desbloqueada y preparada mediante #115 `[AUTO][GAMEPLAY][P0]`.

Tracker: #71.

### Sub-track visual #25–#31

- [x] **#25 — Tileset exterior pixel-art original** — PR #56.
- [x] **#26 — Player spritesheet + animaciones** — PR #75; implementación integrada, aceptación final reabierta por reset visual.
- [ ] **#27 — NPC visual base + Brother Aldren animado** — implementación PR #89 integrada; aceptación visual pendiente.
- [x] **#28 — Props, edificios y cementerio** — PR #79; implementación integrada, calidad final sujeta al reset visual.
- [x] **#29 — Integración artística de mapas** — PR #80; implementación integrada, calidad final sujeta al reset visual.
- [ ] **#30 — Atmósfera, iluminación, vegetación y partículas** — PR #90 + runtime fix #102 integrados; aceptación visual pendiente.
- [ ] **#31 — Aceptación visual del vertical slice** — bloqueada hasta evidencias/reworks.

Tracker: #72.

### UI / audio / estabilidad

- [ ] **#68 — UI final y UX** — PR #78 y #91 integrados; aceptación visual final pendiente.
- [ ] **#67 — Audio final y mezcla básica** — #93 `[AUTO][AUDIO][P1]` ya desbloqueada tras integrar #65/#111.
- [ ] **#69 — Optimización, estabilidad y export**.
- [ ] **#70 — Aceptación integral / release candidate** — único gate autorizado para cerrar Fase 8.

Tracker final: #73.

## Gate P0 histórico — SUPERADO

- [x] #82 — regression test Brother Aldren cemetery save/load — PR #92.
- [x] #83 — sincronización documental.
- [x] `main` verde en HEAD actual `98045f4cfe4d8ee1b6c7f8061c7bb17356f81001`, run `33395789790` success.

Si #82 o #83 reaparecen abiertas, queda bloqueada cualquier integración adicional de Fase 8 hasta resolverlas y recuperar `main` verde.

## Reset visual y quality bar obligatorio

Los screenshots existentes en `docs/` son la referencia oficial de calidad percibida. El estado visual actual no se considera aceptado hasta demostrar comparabilidad mediante evidencia in-game reproducible.

**No existe restricción de escala heredada.** `32x48` no es contrato obligatorio. Si hace falta aumentar resolución/escala de personajes, NPCs, casas, edificios, tiles, props, vegetación, objetos o VFX, o ajustar cámara/zoom, debe hacerse de forma planificada.

Quality bar: pixel-art oscuro de alto detalle, siluetas claras, 8 direcciones realmente coherentes, ropa/equipamiento/materiales legibles, arquitectura con personalidad, entorno denso y artesanal, vegetación/props integrados, iluminación cálida localizada, sombras profundas y acabado profesional. CI verde no equivale a aceptación visual.

### P0 visual actual

- #96 `[AUTO][QA][P0]` — **integrada y cerrada** mediante PR #108. Proporciona captura determinista 1280x720, cámara/zoom real, metadata por SHA y runner local reproducible.
- PR #107 ARCH — **integrado**. Establece la recomendación fuerte de abandonar 32x48 como baseline hero y preferir 64x96 nativo, con canvas visual desacoplado de colisión/navegación.
- #94 `[AUTO][ARCH][P0]` — **abierta intencionadamente**: arquitectura integrada, aceptación perceptual bloqueada por evidencia real de #109.
- #109 `[AUTO][CHARACTERS][P0]` — en ejecución mediante PR draft #114. El PR está deliberadamente en TDD RED contra el placeholder 32x48 y no puede integrarse hasta sustituir el asset real, aportar capturas #96 y dejar todos los gates verdes.
- #113 `[AUTO][WORLD][P0]` — preparada/asignada para sustituir `player_workshop.svg` y `village_house.svg` por arquitectura de producción, sin conservar la limitación 160x128.
- `ART_DIRECTION.md` no se actualiza todavía: la actualización contractual queda condicionada a la validación final de #94 con evidencia real de #109/#96.

## Cola autónoma actual

- GAMEPLAY: #115 `[AUTO][GAMEPLAY][P0]` asignada como gate integral de #66.
- CHARACTERS: #109 activa mediante PR draft #114; mantener el worker hasta corregir RED técnico, integrar el asset real y completar evidencia visual.
- WORLD: #113 preparada/asignada; no preparar otra WORLD mientras siga activa o exista su PR.
- AUDIO: #93 preparada/asignada y ya desbloqueada por #65/#111.
- ARCH: #94 abierta pero bloqueada por #109; no duplicar trabajo arquitectónico.
- UI/POLISH: no preparar otro rework final mientras los cuatro slots estén ocupados y no exista una unidad independiente de mayor prioridad.

## Post-MVP / Expansiones previstas

### Economía local por profesión

- Todo `ItemData` vendible debe tener comprador válido salvo `quest_only`, `key_item` o `non_sellable`.
- Comerciantes opt-in mediante `MerchantProfile` data-driven y afinidad por tags/categorías.
- Validación automática para detectar items vendibles sin salida económica.

### Automatización avanzada de producción

Conservar fuera del vertical slice actual: trabajadores originales del universo `game1` con tareas data-driven `HARVEST`, `MINE`, `CHOP`, `TRANSPORT`, `PROCESS`, evolucionando de trabajo manual a automatización parcial y cadenas completas con infraestructura, rutas, almacenamiento y mantenimiento/energía.
