# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`.
- Rama principal: `main`.
- HEAD de referencia de esta sincronización: `81021973025302213dc64ef8f4a4744673c5dd75`.
- Último CI de `main` para ese HEAD: run `33350515654`, success.
- Runtime/CI objetivo: **Godot 4.7.2**.
- Fases 0–7: **COMPLETADAS**.
- Fase 8 — Polish: **ACTIVA**.
- No declarar Fase 8 completa salvo cierre real de #70 sobre el mismo HEAD final.

## Gate P0 temporal

Auditoría sobre HEAD `8102197` detectó dos cabos sueltos antes de seguir integrando Fase 8:

1. **#82** — falta test de regresión de save/load de Brother Aldren en cementerio. Debe verificar posición y estado/rutina persistentes y fallar si se revierte la protección de restore.
2. **#83** — sincronización de `ROADMAP.md`, `DEV_MEMORY.md`, `CHANGELOG.md` y `README.md` con el HEAD real.

Mientras #82 o #83 sigan abiertas, los workers pueden preparar trabajo independiente pero el supervisor **no fusiona** otros PRs de Fase 8. Tras cerrar ambos, exigir `main` verde antes de reanudar merges.

## Fuentes de verdad

- Funcional/arquitectónica: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Diseño jugable: `GAME_DESIGN.md` + spec 8A.
- Planificación: `ROADMAP.md` + issues activas.
- Contrato visual: `ART_DIRECTION.md`.
- Narrativa: `HISTORIA_PRINCIPAL.md`.
- Idiomas: `LOCALIZATION.md`.
- `docs/design/` es backlog/dirección secundaria; nunca sustituye roadmap ni gates.

## Arquitectura estable

- Exactamente cinco Autoloads: `EventBus`, `GameManager`, `TimeManager`, `SaveManager`, `AudioManager`.
- `TimeManager` es la única fuente de reloj/calendario.
- `SaveManager` agrega providers del grupo `save_provider`.
- UI observa controllers/modelos y emite intents; no contiene lógica de negocio.
- Quality gate descubre todos los `*.gd` y ejecuta `gdlint` + `gdformat --check` globalmente.
- Runtime y CI usan Godot 4.7.2.
- `world/world.tscn` es el shell persistente; `ZoneManager` mantiene una sola zona activa bajo `ZoneContainer`.
- `WorldLocationProvider` persiste zona/marker/posición y el restore no debe reinicializar actores persistentes como Brother Aldren.

## Fase 7 — mundo estable

Fase 7 quedó cerrada mediante #24 / PR #54. El mundo modular conecta cementerio/propiedad, bosque, pueblo, interiores y mina, preservando Player, controllers y Brother Aldren durante viajes. La cámara adopta bounds de la zona activa.

## Fase 8A — estado integrado

### 8A.1 — Descomposición acelerada

- `decay_percent: int` 0..100 y `age_minutes: int`.
- Estados: Fresh, Fading, Decomposed, Rotten.
- Tasas crecientes por edad y saltos temporales deterministas.
- Acumulador entero privado para progreso subporcentual.

### 8A.2 — Conservación

- `PreservationModifiers` usa basis points enteros (`10000 = 1.0`).
- Factores de tecnología/instalación/utensilio neutrales por defecto y multiplicativos.
- Conservación solo ralentiza deterioro futuro; no rejuvenece.
- `_preservation_remainder` persiste para mantener determinismo.

### 8A.3 — Agricultura mínima

- IDs estables `fodder_turnip_seed` y `fodder_turnip`.
- Plantado atómico, crecimiento gobernado por `TimeManager`, cosecha exactly-once y snapshot/restore determinista.
- PR #76; main run `33342619691` verde.

### 8A.4 — Recurso multiuso — INTEGRADO

- #61 cerrado mediante PR #81.
- `fodder_turnip` integrado en items/storage, economía y crafting.
- `fodder_turnip_mash` reutiliza `CraftingService`.
- Economía fija inicial: semilla 3 cobre, compra directa de nabo 5, venta 2; una semilla produce 2 unidades, por lo que cultivar es la ruta sostenible.
- Merge `3cab1b15c0e990a76d0e40df42362ff2b0f0dfb1`.

### Pendiente 8A

- #62 — servicio funerario 18:00.
- #63 — logística progresiva.
- #64 — cremar/investigar.
- #65 — feedback/hooks.
- #66 — aceptación integral.
- Tracker #71 ya refleja #60/#61 cerradas.

## Fase 8 — visual integrado

- #25 — tileset exterior integrado.
- #28 — props/edificios/cementerio integrado.
- #29 — integración artística de mapas integrada mediante PR #80, merge `0e60751bf7346b597bbeba5fcd495b2b27445a27`, main run `33350442187` verde.
- #26 — player spritesheet + animaciones integrado mediante PR #75, HEAD `8102197`, main run `33350515654` verde.
- Pendientes: #27 Brother Aldren visual, #30 atmósfera/lighting/FX, #31 aceptación visual.
- Tracker #72 ya refleja #25/#26/#28/#29 cerradas.

## UI integrado

- #68 sigue abierta.
- PR #78 ya integró theme reutilizable, HUD de estado y base de pause/settings con localización EN/ES.
- Merge `1536ece0e28a3c8da99aa415a557f951bed9613d`.
- El PR #78 no cierra #68; quedan paneles/UX y aceptación final.

## Quality bar visual obligatorio

Referencia aprobada por el usuario: mockup pixel-art oscuro del cuidador del cementerio.

Exigir:
- personajes detallados, silueta clara y 8 direcciones coherentes;
- ropa/equipamiento legibles;
- paleta medieval oscura rica pero controlada;
- iluminación cálida localizada y sombras profundas;
- entorno denso, vegetación y props integrados;
- acabado profesional sin apariencia de placeholder/blockout.

Un PR visual no se acepta solo por tests verdes. Si el contrato humano 32x48 fuerza una degradación evidente, abrir una decisión de arquitectura visual para reevaluar escala/resolución antes de bajar calidad.

## Cola autónoma actual

- #82 — `[AUTO][GAMEPLAY][P0]` regresión save/load de Aldren; prioridad absoluta del Gameplay Worker.
- #84 — `[AUTO][CHARACTERS][P0]` Brother Aldren visual, referencia #27.
- #85 — `[AUTO][WORLD][P1]` atmósfera/lighting/FX, referencia #30.
- #86 — `[AUTO][UI][P0]` visual/UX pass de paneles core, referencia #68.

Los workers pueden preparar estos PRs en paralelo por ownership separado; solo el supervisor integra y debe respetar el gate #82/#83.

## Coordinación del supervisor

- Solo el supervisor actualiza `ROADMAP.md`, `DEV_MEMORY.md`, `CHANGELOG.md` y `README.md`.
- Revisa scope, ownership, dependencias lógicas, tests, Godot 4.7.2, lint/format, smoke, suite y mergeabilidad.
- Integra PRs uno a uno y reevalúa cola después de cada merge.
- No fuerza merges ni relaja quality gates.
- Diferencia siempre estado de `main` frente a ramas/PRs aún no integrados.

## Trackers

- #71 — M8A Gameplay Depth, objetivo 3 Sep 2026.
- #72 — M8V Visual slice, objetivo 8 Sep 2026.
- #73 — M8-RC Release Candidate, objetivo 14 Sep 2026.
- #70 es el único gate autorizado para declarar Fase 8 completada.

## Post-MVP registrado

### Economía local por profesión

Comerciantes opt-in mediante `MerchantProfile` data-driven; todo item vendible debe tener comprador compatible salvo excepciones explícitas.

### Automatización avanzada

Trabajadores originales del mundo de `game1`, sin copiar zombies del benchmark. Tareas previstas: `HARVEST`, `MINE`, `CHOP`, `TRANSPORT`, `PROCESS`, evolucionando de trabajo manual a cadenas automatizadas con infraestructura, rutas, storage y mantenimiento/energía.

## Regla de continuidad

Al retomar:
1. Leer `DEV_MEMORY.md`, `ROADMAP.md`, spec activa, `ART_DIRECTION.md` e issue/PR activo.
2. Revisar HEAD de `main`, CI, issues y PRs.
3. Resolver gates P0 antes de integración normal.
4. Exigir quality/import/smoke/suite sobre Godot 4.7.2.
5. Mantener documentación y trackers alineados con código realmente integrado.
