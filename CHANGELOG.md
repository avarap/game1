# CHANGELOG

## Unreleased

### Added
- Bootstrap Godot 4.x, cinco Autoloads globales, InputMap, logging, debug, guardado versionado, tests y CI headless.
- Walking prototype, items/inventario, energía, recursos, crafting, `StorageNetwork`, producción temporizada y cementerio persistente.
- Simulación: reloj/calendario, sueño, ciclo día/noche, `NPCData`, navegación, horarios/estados y persistencia NPC.
- Localización EN/ES, diálogo data-driven, relaciones, quests, economía, comercio UI y tecnologías.
- Fase 7 completa: cementerio/taller, bosque, pueblo, interiores, mina, zonas, transiciones y persistencia de ubicación.
- Track 8A integrado hasta 8A.8: descomposición, conservación, agricultura mínima, recurso multiuso, servicio funerario 18:00, logística progresiva, decisiones terminales y feedback hooks exactly-once.
- #82 / PR #92: regresión específica para preservar posición/estado de Brother Aldren en save/load de cementerio.
- #96 / PR #108: tooling de captura visual reproducible 1280x720 ligado a SHA, con cámara/zoom reales.
- PR #107: decisión arquitectónica provisional fuerte para abandonar 32x48 como baseline hero y preferir 64x96 nativo con canvas visual desacoplado de colisión/navegación.
- PR #118: política de prompts de producción visual; los screenshots de `docs/` son benchmark obligatorio de calidad percibida sin copiar contenido protegido.
- #119: gameplay MP4 reproducible del baseline `98045f4...`; PR #120 cerrada sin merge después de producir el artefacto solicitado.

### Changed
- Runtime/CI objetivo: **Godot 4.7.2**.
- Quality gate global descubre todos los `*.gd` y ejecuta `gdlint` + `gdformat --check`.
- `world/world.tscn` es shell persistente y `ZoneManager` mantiene una sola zona activa.
- Fases 0–7 completadas; Fase 8 — Polish permanece **ACTIVA**.
- Reset visual: no existe restricción heredada 32x48/160x128; se prioriza calidad comparable a `docs/` y se permite aumentar resolución/escala o ajustar cámara/zoom de forma planificada.
- `ART_DIRECTION.md` conserva temporalmente el contrato histórico 32x48/1.5x hasta la validación perceptual final de #94 mediante #109/#96.

### Fixed
- Restaurar `world_location` no debe sobreescribir el estado persistente de Brother Aldren.
- El servicio funerario consume `fodder_turnip` real mediante storage.
- PR #102 corrige el error runtime de densidad de `CPUParticles2D` usando `amount` entero y añade regresión live SceneTree.

### Current Work / Gates
- HEAD sincronizado por esta documentación: `a0a54f5ede3d37602bed5594957305b92577bb96`.
- CI de ese HEAD: run `33400411975`, **success**.
- Gate P0 histórico #82/#83: **superado**.
- #115 / PR #121: aceptación integral 8A en RED. El test integral confirma una regresión real: un cadáver entregado por el flujo WORLD no puede ejecutar la decisión terminal `research`; además `gdformat --check` falla. No integrar hasta corrección mínima TDD y todos los gates verdes.
- #109 / PR #114: player 64x96 técnicamente verde en la rama, pero basado en `98045f4...`; requiere resync con `main` y evidencia visual #96 revisada contra `docs/`.
- #113 / PR #116: edificios de producción en rama con CI técnico previo verde, pero base antigua y PR no mergeable; requiere resync/conflict resolution y evidencia visual #96.
- #93 AUDIO: desbloqueada/asignada; sin PR abierto en esta sincronización.
- #94 ARCH: abierta y bloqueada por evidencia perceptual de #109.
- #70 sigue siendo el único gate autorizado para cerrar Fase 8.

### Validated
- Cierre Fase 6: PR #39, run `33308814397`, success.
- Godot 4.7.2: PR #41, run `33309144543`, success.
- Cierre Fase 7: PR #54, run `33331207740`, success.
- 8A.3 agricultura mínima: run `33342619691`, success.
- #29 integración artística: run `33350442187`, success.
- #26 player visual: run `33350515654`, success.
- #82 Aldren cemetery save/load: run `33356344828`, success.
- PR #99 funeral service: run `33359942851`, success.
- PR #103 logística progresiva: integrada.
- PR #106 decisiones terminales: integrada.
- PR #112 feedback hooks: main run `33395789790`, success.
- PR #118 política visual: main run `33400411975`, success.

### Design Decisions — Phase 8A
- Descomposición integer 0–100 con estados Fresh/Fading/Decomposed/Rotten y aceleración con edad.
- Conservación mediante basis points enteros, sin rejuvenecimiento.
- Transporte funerario original al atardecer, objetivo 18:00; tras introducción requiere alimento cultivable y es exactly-once con sueño/time-jump/save-load.
- Descarga inicial junto al camino y rampa desbloqueable posterior.
- `fodder_turnip` es cultivable, comprable, vendible, almacenable y reutilizable.
- Cremar e investigar son decisiones terminales alternativas y persistentes.
- Feedback reutiliza EventBus/AudioManager sin acoplar reglas de gameplay.

### Design Decisions — Visual Reset
- `docs/` es la referencia oficial de calidad percibida.
- CI verde no equivale a aceptación visual.
- 32x48 no es contrato de producción para personajes hero/key NPCs; 64x96 nativo es la recomendación provisional fuerte de #107.
- Pivote de pies, colisión, navegación e interacción se mantienen desacoplados del canvas visible.
- Arquitectura, props, tiles y VFX pueden aumentar resolución/escala si el resultado heredado obliga a un aspecto plano/blockout.

### Design Decisions — Post-MVP
- Comerciantes por profesión mediante `MerchantProfile` data-driven y tags/categorías.
- Todo producto vendible debe tener salida económica salvo excepciones explícitas.
- Trabajadores originales para `HARVEST`, `MINE`, `CHOP`, `TRANSPORT` y `PROCESS`, evolucionando de trabajo manual a cadenas automatizadas.
