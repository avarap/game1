# ROADMAP

## Estado global

- Fases 0–7: **COMPLETADAS**.
- Fase 8 — Polish: **ACTIVA**.
- Runtime/CI contractual: **Godot 4.7.2**.
- HEAD de referencia para esta sincronización: `0a16c3e53a0691227d6e73ae38c3cbb056f3a822`.
- CI de `main` para ese HEAD: run `33379879695`, success.
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
- [x] **8A.3 — Agricultura mínima:** `fodder_turnip_seed` → plantar → crecer → cosechar → persistir. PR #76.
- [x] **8A.4 — Recurso multiuso (#61):** `fodder_turnip` integrado en items/storage, economía y crafting mediante PR #81.
- [x] **8A.5 — Servicio funerario (#62):** entrega determinista a las 18:00, primera gratuita y consumo posterior de `fodder_turnip`; PR #99.
- [x] **8A.6 — Logística progresiva (#63):** descarga inicial `roadside_dropoff`, rampa desbloqueable y destino persistente por cadáver; PR #103, main run `33379879695`.
- [ ] **8A.7 — Decisiones de cadáver (#64):** cremar/investigar además de preparar/enterrar. Trabajo preparado: #104 `[AUTO][GAMEPLAY][P0]`.
- [ ] **8A.8 — Feedback/hooks (#65):** eventos desacoplados para audio/FX.
- [ ] **8A.9 — Aceptación integral (#66):** farming→comedero→18:00→cadáver→decisión→save/load.

Tracker: #71.

### Sub-track visual #25–#31

- [x] **#25 — Tileset exterior pixel-art original** — PR #56.
- [x] **#26 — Player spritesheet + animaciones** — PR #75.
- [ ] **#27 — NPC visual base + Brother Aldren animado** — implementación integrada mediante PR #89, aceptación visual pendiente de #94/#96 y evidencia verificable.
- [x] **#28 — Props, edificios y cementerio** — PR #79.
- [x] **#29 — Integración artística de mapas** — PR #80.
- [ ] **#30 — Atmósfera, iluminación, vegetación y partículas** — implementación integrada mediante PR #90 y corrección runtime PR #102; aceptación visual pendiente.
- [ ] **#31 — Aceptación visual del vertical slice**.

Tracker: #72.

### UI / audio / estabilidad

- [ ] **#68 — UI final y UX:** PR #78 integró HUD/pause/settings y PR #91 paneles core; aceptación visual final pendiente.
- [ ] **#67 — Audio final y mezcla básica** — bloqueada hasta #65; issue preparatoria #93 permanece `[BLOCKED]`.
- [ ] **#69 — Optimización, estabilidad y export**.
- [ ] **#70 — Aceptación integral / release candidate** — único gate autorizado para cerrar Fase 8.

Tracker final: #73.

## Gate P0 temporal de auditoría — SUPERADO

La auditoría iniciada sobre HEAD `81021973025302213dc64ef8f4a4744673c5dd75` queda resuelta:

- [x] #82 — regression test Brother Aldren cemetery save/load — PR #92.
- [x] #83 — sincronización documental.
- [x] `main` verde — HEAD `0a16c3e53a0691227d6e73ae38c3cbb056f3a822`, run `33379879695`, success.

## Reset visual y quality bar obligatorio

Los screenshots existentes en `docs/` son la referencia oficial de calidad percibida. El estado visual actual no se considera aceptado hasta demostrar comparabilidad mediante evidencia in-game reproducible.

**No existe restricción de escala heredada.** `32x48` no es un contrato obligatorio. Si hace falta aumentar resolución/escala de personajes, NPCs, casas, edificios, tiles, props, vegetación u objetos, o ajustar cámara/zoom, debe hacerse de forma planificada. No se preserva una escala histórica a costa de bajar calidad.

Quality bar: pixel-art oscuro de alto detalle, siluetas claras, 8 direcciones realmente coherentes, ropa/equipamiento/materiales legibles, arquitectura con personalidad, entorno denso y artesanal, vegetación/props integrados, iluminación cálida localizada, sombras profundas y acabado profesional. CI verde no equivale a aceptación visual.

Prioridad P0 visual:
- #94 `[AUTO][ARCH][P0]` — decidir escala/pipeline correctos para personajes + arquitectura + props + tiles/cámara.
- #96 `[AUTO][QA][P0]` — captura reproducible para comparaciones before/after contra `docs/`.
- Tras #94/#96, preparar reworks independientes CHARACTERS/WORLD/UI/POLISH según evidencia.
- `ART_DIRECTION.md` se actualizará solo cuando #94 produzca una decisión validada.

## Cola autónoma

- GAMEPLAY: #104 — decisiones finales de cadáver (#64).
- ARCH: #94 — escala/pipeline visual P0.
- QA: #96 — baseline/captura visual P0.
- AUDIO: #93 bloqueada hasta #65.
- CHARACTERS/WORLD/UI/POLISH: no preparar rework final hasta disponer de decisión/evidencia suficiente de #94/#96.

Máximo una tarea preparada por carril y ningún worker abandona un PR abierto para tomar trabajo nuevo.

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
