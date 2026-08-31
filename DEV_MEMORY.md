# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`.
- Rama principal: `main`.
- HEAD de referencia de esta sincronización: `16f13eeaa306a048c7c397cc6b6687585b15b3f1`.
- Último CI de `main` para ese HEAD: run `33372934693`, success.
- Runtime/CI objetivo: **Godot 4.7.2**.
- Fases 0–7: **COMPLETADAS**.
- Fase 8 — Polish: **ACTIVA**.
- No declarar Fase 8 completa salvo cierre real de #70 sobre el mismo HEAD final.

## Gate P0 temporal — RESUELTO

La auditoría iniciada sobre HEAD `8102197` queda cerrada: #82 se integró mediante PR #92, #83 está cerrada y `main` permanece verde. La integración normal de Fase 8 continúa uno a uno sin relajar quality gates.

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

## Fase 8A — estado integrado

- 8A.1 descomposición acelerada y 8A.2 conservación determinista: integradas.
- 8A.3 agricultura mínima: integrada mediante PR #76.
- 8A.4 recurso multiuso: #61 cerrado mediante PR #81; `fodder_turnip` participa en storage, economía y crafting.
- 8A.5 servicio funerario: #62 cerrado tras PR #99, merge `bab397eca3f85d7d62af882751d250a2bc473248`. Consume `fodder_turnip` real mediante storage, entrega a las 18:00, primera gratuita y persiste exactly-once.
- 8A.6 logística progresiva: #100 tiene implementación en PR #101; el head `0ef0d900...` tiene CI verde, pero debe actualizarse contra el `main` real antes de revisión/merge.
- 8A.7 #64, 8A.8 #65 y 8A.9 #66: pendientes.

## Fase 8 — visual/UI integrado frente a aceptación

- #25, #26, #28 y #29: integrados.
- PR #89 / #84 (Brother Aldren visual) está integrado, pero #27 no debe declararse visualmente aceptado hasta resolver #94/#96 y disponer de evidencia renderizada suficiente.
- PR #90 (atmósfera/lighting/FX) está integrado; PR #102 corrigió el uso inválido de densidad de `CPUParticles2D` en runtime y añadió regresión live SceneTree. #30 sigue pendiente de aceptación visual verificable.
- PR #91 (paneles core UI) está integrado; #68 sigue pendiente de aceptación UI/visual final.
- #31 aceptación visual integral sigue pendiente.
- Commit `16f13ee` añadió capturas JPG bajo `docs/`; se tratan como material de referencia, no como evidencia determinista hasta que #96 establezca captura/procedencia reproducible asociada al HEAD evaluado.

## Quality bar visual obligatorio

Referencia aprobada: mockup pixel-art oscuro del cuidador del cementerio. Exigir personajes detallados y 8 direcciones coherentes, ropa/equipamiento legibles, paleta medieval oscura rica/controlada, iluminación cálida localizada, sombras profundas, entorno denso y acabado profesional. Tests verdes no sustituyen la revisión visual. Si 32x48 fuerza un downgrade, resolver #94 antes de aceptarlo.

## Cola autónoma actual

- GAMEPLAY: #100 tiene PR activo #101; no preparar otra tarea hasta resolverlo.
- #93 — `[AUTO][AUDIO][P1]` routing/ambiente/mezcla.
- #94 — `[AUTO][ARCH][P0]` reevaluación de escala/resolución visual.
- #96 — `[AUTO][QA][P0]` capturas visuales deterministas.
- CHARACTERS no recibe nueva tarea mientras #94/#96 bloqueen el siguiente paso.
- WORLD/UI: el código incremental está integrado; la aceptación visual pendiente no debe presentarse como trabajo autónomo desbloqueado mientras dependa de #96.

No preparar una segunda tarea del mismo carril mientras exista una issue preparada o PR activo.

## Coordinación del supervisor

- Solo el supervisor actualiza `ROADMAP.md`, `DEV_MEMORY.md`, `CHANGELOG.md` y `README.md`.
- Revisar scope, ownership, dependencias, tests, Godot 4.7.2, lint/format, smoke, suite y mergeabilidad.
- Integrar PRs uno a uno y reevaluar la cola tras cada merge.
- Diferenciar siempre estado integrado en `main` de aceptación pendiente o trabajo en ramas.
- No forzar merges ni relajar quality gates.

## Trackers

- #71 — M8A Gameplay Depth.
- #72 — M8V Visual slice.
- #73 — M8-RC Release Candidate.
- #70 es el único gate autorizado para declarar Fase 8 completada.

## Post-MVP registrado

### Economía local por profesión

Comerciantes opt-in mediante `MerchantProfile` data-driven; todo item vendible debe tener comprador compatible salvo excepciones explícitas.

### Automatización avanzada

Trabajadores originales del mundo de `game1`, sin copiar zombies del benchmark. Tareas previstas: `HARVEST`, `MINE`, `CHOP`, `TRANSPORT`, `PROCESS`, evolucionando de trabajo manual a cadenas automatizadas con infraestructura, rutas, storage y mantenimiento/energía.

## Regla de continuidad

Al retomar: leer memoria/roadmap/spec/arte; revisar HEAD, CI, issues y PRs; mantener el gate P0 cerrado; exigir quality/import/smoke/suite sobre Godot 4.7.2; mantener documentación y trackers alineados con código realmente integrado y con aceptación visual realmente demostrada.
