# ROADMAP

## Estado global

- Fases 0–7: **COMPLETADAS**.
- Fase 8 — Polish: **ACTIVA**.
- Runtime/CI contractual: **Godot 4.7.2**.
- HEAD de referencia para esta sincronización: `9ff20a44db34cfa46b7b0cee7576735c6f283534`.
- CI de `main` para ese HEAD: run `33386137356`, **success**.
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
- [ ] **8A.7 — Decisiones de cadáver (#64)** — issue automática #104, PR #106 abierto; no integrar hasta gdlint, gdformat --check, Godot 4.7.2 import, smoke y suite verdes.
- [ ] **8A.8 — Feedback/hooks (#65)** — pendiente tras #64.
- [ ] **8A.9 — Aceptación integral (#66)** — farming→comedero→18:00→cadáver→decisión→save/load.

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
- [ ] **#67 — Audio final y mezcla básica** — #93 bloqueada hasta #65.
- [ ] **#69 — Optimización, estabilidad y export**.
- [ ] **#70 — Aceptación integral / release candidate** — único gate autorizado para cerrar Fase 8.

Tracker final: #73.

## Gate P0 histórico — SUPERADO

- [x] #82 — regression test Brother Aldren cemetery save/load — PR #92.
- [x] #83 — sincronización documental.
- [x] `main` verde en HEAD actual `9ff20a44db34cfa46b7b0cee7576735c6f283534`, run `33386137356` success.

Si #82 o #83 reaparecen abiertas, queda bloqueada cualquier integración adicional de Fase 8 hasta resolverlas y recuperar `main` verde.

## Reset visual y quality bar obligatorio

Los screenshots existentes en `docs/` son la referencia oficial de calidad percibida. El estado visual actual no se considera aceptado hasta demostrar comparabilidad mediante evidencia in-game reproducible.

**No existe restricción de escala heredada.** `32x48` no es contrato obligatorio. Si hace falta aumentar resolución/escala de personajes, NPCs, casas, edificios, tiles, props, vegetación, objetos o VFX, o ajustar cámara/zoom, debe hacerse de forma planificada.

Quality bar: pixel-art oscuro de alto detalle, siluetas claras, 8 direcciones realmente coherentes, ropa/equipamiento/materiales legibles, arquitectura con personalidad, entorno denso y artesanal, vegetación/props integrados, iluminación cálida localizada, sombras profundas y acabado profesional. CI verde no equivale a aceptación visual.

### P0 visual actual

- #96 `[AUTO][QA][P0]` — **integrada y cerrada** mediante PR #108. Proporciona captura determinista 1280x720, cámara/zoom real, metadata por SHA y runner local reproducible.
- PR #107 ARCH — **integrado** en `main` `9ff20a44...`; establece una recomendación arquitectónica fuerte de abandonar 32x48 como baseline hero y preferir 64x96 nativo, con canvas visual desacoplado de colisión/navegación.
- #94 `[AUTO][ARCH][P0]` — **reabierta por supervisor** tras el merge de #107: la arquitectura está integrada, pero la aceptación perceptual sigue pendiente porque falta comparación in-game real 32x48/48x72/64x96. Queda bloqueada por #109.
- #109 `[AUTO][CHARACTERS][P0]` — preparado para crear candidatos nativos 48x72/64x96 y probarlos con el tooling #96 contra `docs/`, incluyendo zooms 1.0/1.25/1.5.
- `ART_DIRECTION.md` no se actualiza todavía: la actualización contractual queda condicionada a la validación final de #94 con evidencia #109/#96.

Tras validar #94, preparar reworks independientes de CHARACTERS/WORLD/UI/POLISH según evidencia; máximo una tarea preparada por carril.

## Cola autónoma actual

- GAMEPLAY: #104 / PR #106 abierto; worker permanece en el PR hasta dejarlo verde y actualizado.
- CHARACTERS: #109 preparado, desbloqueado por #96 y asignado a un único worker.
- ARCH: #94 abierta pero bloqueada por #109; slot ARCH en STANDBY para no duplicar trabajo.
- AUDIO: #93 bloqueada hasta #65.
- WORLD/UI/POLISH: no asignar reworks finales adicionales hasta que #94/#109 aporten evidencia suficiente y el supervisor prepare issues separadas.

## Post-MVP / Expansiones previstas

### Economía local por profesión

- Todo `ItemData` vendible debe tener comprador válido salvo `quest_only`, `key_item` o `non_sellable`.
- Comerciantes opt-in mediante `MerchantProfile` data-driven y afinidad por tags/categorías.
- Validación automática para detectar items vendibles sin salida económica.

### Automatización avanzada de producción

Conservar fuera del vertical slice actual: trabajadores originales del universo `game1` con tareas data-driven `HARVEST`, `MINE`, `CHOP`, `TRANSPORT`, `PROCESS`, evolucionando de trabajo manual a automatización parcial y cadenas completas con infraestructura, rutas, almacenamiento y mantenimiento/energía.
