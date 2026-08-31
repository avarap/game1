# CHANGELOG

## Unreleased

### Added
- Bootstrap Godot 4.x, cinco Autoloads globales, InputMap, logging, debug, guardado versionado, tests y CI headless.
- Walking prototype, items/inventario, energía, recursos, crafting, `StorageNetwork`, producción temporizada y cementerio persistente.
- Simulación: reloj/calendario, sueño, ciclo día/noche, `NPCData`, navegación, horarios/estados y persistencia NPC.
- Localización EN/ES, diálogo data-driven, relaciones, quests, economía, comercio UI y tecnologías.
- Fase 7 completa: cementerio/taller, bosque, pueblo, interiores, mina, zonas, transiciones y persistencia de ubicación.
- **#25 Tileset exterior** y **#28 props/edificios/cementerio** como base visual original.
- **#29 Integración artística de mapas:** tileset/props aplicados a mapas de Fase 7 sin mover autoridad de gameplay; PR #80, merge `0e60751bf7346b597bbeba5fcd495b2b27445a27`.
- **#26 Player visual:** `AnimatedSprite2D`, personaje original y animaciones idle/walk en 8 direcciones; PR #75, integrado en HEAD `81021973025302213dc64ef8f4a4744673c5dd75`.
- **8A.1 Descomposición acelerada:** edad/minutos y deterioro entero 0–100 con bandas crecientes y determinismo temporal.
- **8A.2 Conservación:** modificadores enteros en basis points y remainder persistente para conservar precisión sin floats persistidos.
- **8A.3 Agricultura mínima:** `fodder_turnip_seed`/`fodder_turnip`, plantado atómico, crecimiento determinista y cosecha exactly-once.
- **8A.4 Recurso multiuso (#61):** `fodder_turnip` integrado en items/storage, economía y crafting; `fodder_turnip_mash` reutiliza `CraftingService`; PR #81, merge `3cab1b15c0e990a76d0e40df42362ff2b0f0dfb1`.
- **UI #68 incremento integrado:** theme reutilizable, HUD de estado y base de pause/settings localizados EN/ES mediante PR #78. #68 permanece abierta.
- Biblioteca `docs/design/` y backlog Post-MVP para economía local por profesión y automatización avanzada.

### Changed
- Runtime/CI objetivo: **Godot 4.7.2**.
- Quality gate global descubre todos los `*.gd` y ejecuta `gdlint` + `gdformat --check`.
- `world/world.tscn` es shell persistente y `ZoneManager` mantiene una sola zona activa.
- El contrato legacy de descomposición float lineal fue sustituido por estado entero y acumulación determinista.
- Fases 0–7 quedan completadas; Fase 8 — Polish permanece **ACTIVA**.
- Track 8A tiene integrados 8A.1–8A.4; el siguiente bloque funcional es #62.
- Sub-track visual tiene integrados #25, #26, #28 y #29; quedan #27, #30 y #31.
- El estándar visual de aceptación exige calidad percibida comparable al mockup oscuro aprobado: personajes detallados, iluminación cálida localizada, sombras profundas, entorno denso y ausencia de placeholders/blockout visibles.

### Fixed
- Restaurar `world_location` no debe sobreescribir el estado persistente de Brother Aldren.
- El restore puede omitir el refresco de actores persistentes para evitar reposicionarlos en spawn.
- **Pendiente de blindaje:** issue #82 añade el test de regresión específico para save/load de Aldren en cementerio.
- Cambiar modificadores de conservación conserva el remainder fraccional y no perdona deterioro acumulado.

### Project State / Gates
- HEAD sincronizado por esta documentación: `81021973025302213dc64ef8f4a4744673c5dd75`.
- CI de ese HEAD: run `33350515654`, success.
- Gate P0 temporal: cerrar #82 y #83 y dejar `main` verde antes de integrar más PRs de Fase 8.
- Trackers sincronizados: #71 refleja #60/#61 cerradas; #72 refleja #25/#26/#28/#29 cerradas.
- Cola preparada por supervisor: #82 GAMEPLAY/QA, #84 CHARACTERS, #85 WORLD y #86 UI.

### Validated
- Cierre Fase 6: PR #39, run `33308814397`, success.
- Godot 4.7.2: PR #41, run `33309144543`, success.
- Cierre Fase 7: PR #54, run `33331207740`, success.
- #28 props/edificios/cementerio: main run `33340142216`, success.
- 8A.3 agricultura mínima: main run `33342619691`, success.
- #29 integración artística de mapas: main run `33350442187`, success.
- #26 player visual / HEAD `8102197`: main run `33350515654`, success.

### Design Decisions — Phase 8A
- Descomposición integer 0–100 con estados Fresh/Fading/Decomposed/Rotten y aceleración con edad.
- Conservación mediante basis points enteros, sin rejuvenecimiento.
- Transporte funerario original al atardecer, objetivo 18:00; tras introducción requiere alimento cultivable y debe ser exactly-once con sueño/time-jump/save-load.
- Descarga inicial junto al camino y rampa desbloqueable posterior.
- `fodder_turnip` es cultivable, comprable, vendible, almacenable y reutilizable en crafting/cocina; cultivar es la estrategia sostenible.
- Cremar e investigar serán decisiones alternativas a enterrar.
- Feedback reutiliza EventBus/AudioManager sin acoplar reglas de gameplay.

### Design Decisions — Post-MVP
- Comerciantes por profesión mediante `MerchantProfile` data-driven y tags/categorías.
- Todo producto vendible debe tener salida económica salvo excepciones explícitas.
- Trabajadores originales para `HARVEST`, `MINE`, `CHOP`, `TRANSPORT` y `PROCESS`, evolucionando de trabajo manual a cadenas automatizadas.
