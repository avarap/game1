# ROADMAP

## Estado global

- Fases 0–7: **COMPLETADAS**.
- Fase 8 — Polish: **ACTIVA**.
- Runtime/CI contractual: **Godot 4.7.2**.
- HEAD de referencia para esta sincronización: `a0a54f5ede3d37602bed5594957305b92577bb96`.
- CI de `main` para ese HEAD: run `33400411975`, **success**.
- Gate P0 histórico **SUPERADO**: #82 y #83 cerradas.
- No declarar Fase 8 completa hasta #70 sobre el mismo HEAD final con gates funcionales, técnicos y visuales cumplidos.

## Fases 0–7 — COMPLETADAS

- Fase 0 — Bootstrap.
- Fase 1 — Core.
- Fase 2 — Items.
- Fase 3 — Crafting.
- Fase 4 — Cementerio.
- Fase 5 — Simulación.
- Fase 6 — RPG.
- Fase 7 — Mundo, cerrada por #24 / PR #54.

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
- [x] **8A.7 — Decisiones de cadáver (#64)** — PR #106.
- [x] **8A.8 — Feedback/hooks (#65)** — #111 / PR #112.
- [ ] **8A.9 — Aceptación integral (#66)** — #115 activa mediante PR #121. Head `e37dc433...`, CI `33404377011` completamente verde y PR mergeable/sincronizado. La integración está pendiente únicamente porque el PR continúa en estado draft y la transición automática a ready está bloqueada por un fallo del conector GitHub; no rebajar gates ni forzar merge.

Tracker: #71.

### Sub-track visual #25–#31

- [x] **#25 — Tileset exterior pixel-art original** — PR #56.
- [x] **#26 — Player spritesheet + animaciones** — PR #75; implementación integrada, aceptación final reabierta por reset visual.
- [ ] **#27 — NPC visual base + Brother Aldren animado** — implementación PR #89 integrada; aceptación visual pendiente.
- [x] **#28 — Props, edificios y cementerio** — PR #79; implementación integrada, calidad final sujeta al reset visual.
- [x] **#29 — Integración artística de mapas** — PR #80; implementación integrada, calidad final sujeta al reset visual.
- [ ] **#30 — Atmósfera, iluminación, vegetación y partículas** — PR #90 + fix #102 integrados; aceptación visual pendiente.
- [ ] **#31 — Aceptación visual del vertical slice** — bloqueada hasta evidencias/reworks.

Tracker: #72.

### UI / audio / estabilidad

- [ ] **#68 — UI final y UX** — PR #78 y #91 integrados; aceptación visual final pendiente.
- [ ] **#67 — Audio final y mezcla básica** — #93 activa mediante PR draft #122. Import, smoke y suite pasan; `gdformat --check` falla en el head actual, por lo que no es integrable.
- [ ] **#69 — Optimización, estabilidad y export**.
- [ ] **#70 — Aceptación integral / release candidate** — único gate autorizado para cerrar Fase 8.

Tracker final: #73.

## Gate P0 histórico — SUPERADO

- [x] #82 — regression test Brother Aldren cemetery save/load — PR #92.
- [x] #83 — sincronización documental.
- [x] `main` verde en HEAD `a0a54f5ede3d37602bed5594957305b92577bb96`, run `33400411975` success.

Si #82 o #83 reaparecen abiertas, queda bloqueada cualquier integración adicional de Fase 8 hasta resolverlas y recuperar `main` verde.

## Reset visual y quality bar obligatorio

Los screenshots existentes en `docs/` son la referencia oficial de calidad percibida. El estado visual actual no se considera aceptado hasta demostrar comparabilidad mediante evidencia in-game reproducible.

**No existe restricción de escala heredada.** `32x48` no es contrato obligatorio. Si hace falta aumentar resolución/escala de personajes, NPCs, casas, edificios, tiles, props, vegetación, objetos o VFX, o ajustar cámara/zoom, debe hacerse de forma planificada.

Quality bar: pixel-art oscuro de alto detalle, siluetas claras, 8 direcciones realmente coherentes, ropa/equipamiento/materiales legibles, arquitectura con personalidad, entorno denso y artesanal, vegetación/props integrados, iluminación cálida localizada, sombras profundas y acabado profesional. CI verde no equivale a aceptación visual.

### P0 visual actual

- #96 QA visual — **integrada y cerrada** mediante PR #108; captura determinista 1280x720 con cámara/zoom real y metadata por SHA.
- PR #107 ARCH — **integrado**; recomendación fuerte: abandonar 32x48 como baseline hero, preferir 64x96 nativo y desacoplar canvas visual de colisión/navegación.
- PR #118 — **integrado**; establece `docs/` como benchmark obligatorio y prompts de producción por categoría.
- #94 ARCH — **abierta intencionadamente**, bloqueada por evidencia real de #109.
- #109 CHARACTERS — PR draft #114, sincronizado con `main`, mergeable y CI técnico `33405431151` verde en head `4c3f26d5...`. **No aceptado visualmente**: el candidato actual sigue leyendo como placeholder ampliado; debe sustituirse/mejorarse y aportar capturas #96 comparadas contra `docs/`.
- #113 WORLD — PR draft #116, sincronizado con `main`, mergeable y CI `33403543515` verde en head `3233226e...`. Sigue bloqueado por aceptación perceptual: faltan capturas #96 revisadas contra `docs/`; migrar a raster si el SVG no alcanza el quality bar.
- #119 QA gameplay-video — **completada y cerrada**. PR #120 cerrada sin merge por diseño tras producir el MP4 solicitado del baseline `98045f4...`.
- `ART_DIRECTION.md` conserva todavía el contrato histórico 32x48/1.5x y **no debe actualizarse hasta validar #94** con evidencia real.

## Cola autónoma actual

- GAMEPLAY: #115 / PR #121 — P0 técnicamente verde; mantener worker hasta resolver estado draft/readiness e integración supervisada.
- CHARACTERS: #109 / PR #114 — mantener worker; rework visual + evidencia #96 obligatoria pese a CI verde.
- WORLD: #113 / PR #116 — mantener worker; evidencia perceptual #96 obligatoria pese a CI verde.
- AUDIO: #93 / PR #122 — mantener worker; corregir `gdformat --check` y revalidar todos los gates.
- ARCH: #94 abierta pero bloqueada por #109.
- UI/POLISH: no preparar otro rework mientras los cuatro slots estén ocupados y no exista una unidad independiente de mayor prioridad.

## Política de integración

- Integrar PRs uno a uno únicamente cuando estén actualizados con `main`, mergeables, dentro de scope y verdes en `gdlint`, `gdformat --check`, Godot 4.7.2 import, smoke y suite completa/relevante.
- Tras cada merge, reevaluar `main`, CI, issues y cola.
- Para PRs visuales, CI verde es necesario pero no suficiente: exigir evidencia in-game reproducible y comparación humana contra `docs/`.
- No forzar un PR draft ni rebajar gates por limitaciones del conector.

## Post-MVP / Expansiones previstas

### Economía local por profesión

- Todo `ItemData` vendible debe tener comprador válido salvo `quest_only`, `key_item` o `non_sellable`.
- Comerciantes opt-in mediante `MerchantProfile` data-driven y afinidad por tags/categorías.

### Automatización avanzada de producción

Conservar fuera del vertical slice actual: trabajadores originales del universo `game1` con tareas data-driven `HARVEST`, `MINE`, `CHOP`, `TRANSPORT`, `PROCESS`, evolucionando de trabajo manual a automatización parcial y cadenas completas con infraestructura, rutas, almacenamiento y mantenimiento/energía.
