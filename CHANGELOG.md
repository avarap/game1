# CHANGELOG

## Unreleased

### Added
- Bootstrap Godot 4.x, cinco Autoloads globales, InputMap, logging, debug, guardado versionado, tests y CI headless.
- Walking prototype, items/inventario, energía, recursos, crafting, `StorageNetwork`, producción temporizada y cementerio persistente.
- Simulación: reloj/calendario, sueño, ciclo día/noche, `NPCData`, navegación, horarios/estados y persistencia NPC.
- Localización EN/ES, diálogo data-driven, relaciones, quests, economía, comercio UI y tecnologías.
- Fase 7 completa: cementerio/taller, bosque, pueblo, interiores, mina, zonas, transiciones y persistencia de ubicación.
- #25 tileset exterior, #28 props/edificios/cementerio, #29 integración artística de mapas y #26 player visual.
- 8A.1 descomposición acelerada, 8A.2 conservación, 8A.3 agricultura mínima y 8A.4 recurso multiuso.
- **8A.5 Servicio funerario (#62):** integrado mediante PR #99; entrega diaria determinista a las 18:00, primera gratuita y entregas posteriores consumiendo `fodder_turnip` real desde storage, con persistencia exactly-once.
- **#82 Regresión Aldren save/load:** cobertura integrada mediante PR #92 para preservar posición y estado/rutina persistentes en cementerio.
- Incrementos visuales de Brother Aldren (#84/PR #89), atmósfera/lighting/FX (PR #90) y paneles core UI (PR #91) están en `main`; su aceptación visual final sigue sujeta a evidencia verificable y quality bar.
- Biblioteca `docs/design/` y backlog Post-MVP para economía local por profesión y automatización avanzada.

### Changed
- Runtime/CI objetivo: **Godot 4.7.2**.
- Quality gate global descubre todos los `*.gd` y ejecuta `gdlint` + `gdformat --check`.
- `world/world.tscn` es shell persistente y `ZoneManager` mantiene una sola zona activa.
- Fases 0–7 quedan completadas; Fase 8 — Polish permanece **ACTIVA**.
- Track 8A tiene integrados 8A.1–8A.5; 8A.6 tiene implementación en PR #101 pendiente de resincronización/integración.
- El estándar visual exige calidad percibida comparable al mockup oscuro aprobado y evidencia renderizada; integración técnica no equivale automáticamente a aceptación visual.

### Fixed
- Restaurar `world_location` no debe sobreescribir el estado persistente de Brother Aldren.
- #82 / PR #92 blinda específicamente save/load de Aldren en cementerio.
- El servicio funerario consume `fodder_turnip` real mediante storage.
- PR #102 corrige el error runtime de densidad de `CPUParticles2D` usando `amount` entero y añade una regresión live SceneTree.

### Project State / Gates
- HEAD sincronizado por esta documentación: `adc78483e79661298a2fc36e49976325b35855b3`.
- CI de ese HEAD: run `33369187753`, success.
- Gate P0 temporal #82/#83: **superado**.
- #94 ARCH y #96 QA permanecen abiertos para resolver escala de personajes y capturas deterministas.
- #93 AUDIO está preparado; GAMEPLAY #100 tiene PR activo #101.

### Validated
- Cierre Fase 6: PR #39, run `33308814397`, success.
- Godot 4.7.2: PR #41, run `33309144543`, success.
- Cierre Fase 7: PR #54, run `33331207740`, success.
- 8A.3 agricultura mínima: main run `33342619691`, success.
- #29 integración artística: main run `33350442187`, success.
- #26 player visual: main run `33350515654`, success.
- #82 Aldren cemetery save/load: main run `33356344828`, success.
- PR #99 funeral service exact head: run `33359942851`, success.
- Main tras PR #90/#91: run `33364746590`, success.
- Main tras PR #102: HEAD `adc78483e79661298a2fc36e49976325b35855b3`, run `33369187753`, success.

### Design Decisions — Phase 8A
- Descomposición integer 0–100 con estados Fresh/Fading/Decomposed/Rotten y aceleración con edad.
- Conservación mediante basis points enteros, sin rejuvenecimiento.
- Transporte funerario original al atardecer, objetivo 18:00; tras introducción requiere alimento cultivable y es exactly-once con sueño/time-jump/save-load.
- Descarga inicial junto al camino y rampa desbloqueable posterior (#63 / #100 / PR #101).
- `fodder_turnip` es cultivable, comprable, vendible, almacenable y reutilizable en crafting/cocina.
- Cremar e investigar serán decisiones alternativas a enterrar.
- Feedback reutiliza EventBus/AudioManager sin acoplar reglas de gameplay.

### Design Decisions — Post-MVP
- Comerciantes por profesión mediante `MerchantProfile` data-driven y tags/categorías.
- Todo producto vendible debe tener salida económica salvo excepciones explícitas.
- Trabajadores originales para `HARVEST`, `MINE`, `CHOP`, `TRANSPORT` y `PROCESS`, evolucionando de trabajo manual a cadenas automatizadas.
