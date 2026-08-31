# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`.
- Rama principal: `main`.
- HEAD de referencia de esta sincronización: `a0a54f5ede3d37602bed5594957305b92577bb96`.
- CI de `main`: run `33400411975`, **success**.
- Runtime/CI objetivo: **Godot 4.7.2**.
- Fases 0–7: **COMPLETADAS**.
- Fase 8 — Polish: **ACTIVA**.
- #70 es el único gate autorizado para declarar Fase 8 completa y debe evaluarse sobre el mismo HEAD final funcional/técnico/visual.

## Gate P0 histórico — RESUELTO

#82 y #83 permanecen cerradas. Si cualquiera reaparece abierta, bloquear nuevas integraciones de Fase 8 hasta resolverla y dejar `main` verde.

## Fuentes de verdad

- Funcional/arquitectónica: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Diseño jugable: `GAME_DESIGN.md` + spec 8A.
- Planificación: `ROADMAP.md` + issues activas.
- Contrato visual: `ART_DIRECTION.md`, sujeto al reset visual y a la decisión validada de #94.
- Benchmark perceptual oficial: screenshots existentes en `docs/`.
- Política de prompts visuales: `art/PROMPT_POLICY.md` + `PROMPT.md` por categoría, integrados por PR #118.
- Narrativa: `HISTORIA_PRINCIPAL.md`.
- Idiomas: `LOCALIZATION.md`.

## Arquitectura estable

- Exactamente cinco Autoloads: `EventBus`, `GameManager`, `TimeManager`, `SaveManager`, `AudioManager`.
- `TimeManager` es la única fuente de reloj/calendario.
- `SaveManager` agrega providers del grupo `save_provider`.
- UI observa controllers/modelos y emite intents; no contiene lógica de negocio.
- Quality gate descubre todos los `*.gd` y ejecuta `gdlint` + `gdformat --check` globalmente.
- Runtime y CI usan Godot 4.7.2.
- `world/world.tscn` es el shell persistente; `ZoneManager` mantiene una sola zona activa bajo `ZoneContainer`.
- `WorldLocationProvider` persiste zona/marker/posición y restore no debe reinicializar actores persistentes como Brother Aldren.

## Fase 8A — estado real

- 8A.1 descomposición acelerada y 8A.2 conservación determinista: integradas.
- 8A.3 agricultura mínima: PR #76.
- 8A.4 recurso multiuso: #61 / PR #81.
- 8A.5 servicio funerario: #62 / PR #99.
- 8A.6 logística progresiva: #63 / PR #103.
- 8A.7 decisiones de cadáver: #64 / #104 / PR #106.
- 8A.8 feedback/hooks: #65 / #111 / PR #112; eventos post-éxito, exactly-once y desacoplados.
- 8A.9 #66 aceptación integral: #115 activa mediante PR #121.

### Gate #115 / PR #121

El RED inicial confirmó una regresión real: `CemeteryController` creaba/restauraba `CemeteryService` sin la configuración de decisiones terminales y sin el `TechnologyService` real del mundo. El worker aplicó una corrección productiva mínima e incorporó el test end-to-end completo.

Estado actual de PR #121:
- head `e37dc433b2639950275dcfb337e3efd650f63a2c`;
- sincronizado con `main` `a0a54f5...` y mergeable;
- CI `33404377011`: gdlint, gdformat, Godot 4.7.2 import, smoke, `Phase8AAcceptance` y suite completa **verdes**;
- scope limitado a `tests/run_tests.gd`, `tests/test_phase8a_acceptance.gd` y `world/cemetery/cemetery_controller.gd`.

La integración supervisada está bloqueada únicamente porque el PR sigue marcado draft. El intento automático de `mark ready` falla por un error del conector GitHub sobre `Repository.fullDatabaseId`, y GitHub rechaza el merge REST mientras siga draft. **No forzar ni rebajar gates**; mantener el worker en GAMEPLAY hasta resolver readiness/integración.

## Reset visual — estado real

Los screenshots de `docs/` son el benchmark oficial. El arte integrado anteriormente puede seguir siendo funcional pero no se considera visualmente aceptado por el mero hecho de estar en `main`.

- #96 QA visual: **integrada y cerrada** mediante PR #108; tooling determinista para capturas 1280x720 asociado a SHA, cámara/zoom reales y manifest visual.
- PR #107 ARCH: **integrado**; recomendación de rechazar 32x48 como baseline hero, preferir 64x96 nativo para player/key NPCs y desacoplar canvas visual de colisión/navegación.
- PR #118: **integrado**; política P0 de prompts visuales y `docs/` como quality benchmark obligatorio.
- #94 ARCH: **abierta intencionadamente**; aceptación perceptual requiere evidencia in-game real de #109.
- #109 CHARACTERS: PR draft #114, head `4c3f26d59a3e66e98f4b684d9b5885328cd57105`, sincronizado/mergeable y CI `33405431151` verde. El gate perceptual **rechaza el candidato actual** por seguir leyendo como placeholder ampliado. Conservar la migración técnica, rehacer el arte y adjuntar capturas #96 contra `docs/`; CI verde no habilita merge.
- #113 WORLD: PR draft #116, head `3233226e36012565e4adf7d51b11802aa26532e8`, sincronizado/mergeable y CI `33403543515` verde. Sigue bloqueado por evidencia perceptual #96; si el SVG mantiene aspecto vectorial/plano, migrar a raster/layers antes de aceptación.
- #119 QA gameplay-video: **completada/cerrada**; PR #120 cerrada sin merge después de producir el MP4 solicitado del baseline `98045f4...`.
- `ART_DIRECTION.md` todavía contiene el contrato histórico 32x48/1.5x. **No modificarlo hasta que #94 quede validada**; entonces el supervisor debe actualizarlo.

## Estado visual/UI integrado frente a aceptación

- #25, #26, #28 y #29: implementaciones integradas, sujetas al reset visual donde aplique.
- PR #89 / #27 Brother Aldren: integrado funcionalmente; aceptación visual pendiente.
- PR #90 + #102 / #30 atmósfera: integrados funcionalmente; aceptación visual pendiente.
- PR #91 + #78 / #68 UI: integrados funcionalmente; aceptación visual final pendiente.
- #31 aceptación visual integral sigue pendiente.

## Audio — estado real

- Hooks requeridos por audio integrados mediante #65/#111/PR #112.
- #93 `[AUTO][AUDIO][P1]` está activa mediante PR draft #122, head `d0464838bb3d8a43ccabaa3a086074742c2be47e`.
- CI `33404640239`: Godot 4.7.2 import, smoke y suite completa pasan; gdlint pasa; **gdformat --check falla**. No integrar hasta corregir formato y revalidar todos los gates.
- Scope se mantiene AUDIO-only y el worker permanece asignado al PR.

## Quality bar visual obligatorio

Pixel-art oscuro de alto detalle; siluetas claras; ocho direcciones realmente coherentes; cara/cabello/ropa/equipamiento/materiales legibles; arquitectura con personalidad; entorno denso y artesanal; caminos integrados; vegetación abundante pero legible; props/lápidas con volumen; iluminación cálida localizada; sombras profundas; paleta medieval oscura rica/controlada y acabado profesional.

No existe restricción heredada de tamaño. Si 32x48, 160x128 para edificios, 32 px de tile visual u otra escala antigua obliga a reducir calidad, aumentar resolución/escala o ajustar cámara/zoom de forma planificada. CI verde no sustituye la revisión visual humana contra `docs/`.

## Cola autónoma actual

- GAMEPLAY: #115 / PR #121; técnicamente verde pero bloqueado por estado draft/readiness del conector. Mantener worker.
- CHARACTERS: #109 / PR #114; técnicamente verde pero visualmente rechazado. Mantener worker hasta rework + evidencia.
- WORLD: #113 / PR #116; técnicamente verde, aceptación visual pendiente. Mantener worker.
- AUDIO: #93 / PR #122; CI rojo por gdformat. Mantener worker hasta corregir/revalidar.
- ARCH: #94 abierta pero bloqueada por evidencia de #109.
- UI/POLISH: sin slot mientras las cuatro unidades anteriores ocupen capacidad.

## Coordinación del supervisor

- Solo el supervisor actualiza `ROADMAP.md`, `DEV_MEMORY.md`, `CHANGELOG.md` y `README.md`.
- Revisar `main`, CI, #82/#83, PRs, issues, scope, ownership, dependencias y mergeabilidad en cada ejecución.
- Integrar PRs uno a uno solo si están actualizados y verdes en gdlint, gdformat --check, Godot 4.7.2 import, smoke y suite.
- Tras cada merge, reevaluar `main` y la cola antes de integrar el siguiente.
- Para PRs visuales, exigir además evidencia in-game reproducible y comparación humana contra `docs/`.
- Diferenciar siempre implementación integrada de aceptación visual pendiente.
- No forzar merges ni rebajar gates.

## Trackers

- #71 — M8A Gameplay Depth: #66 pendiente vía #115/#121.
- #72 — M8V Visual slice.
- #73 — M8-RC Release Candidate.
- #70 — gate final único de Fase 8.

## Post-MVP registrado

### Economía local por profesión

Comerciantes opt-in mediante `MerchantProfile` data-driven; todo item vendible debe tener comprador compatible salvo excepciones explícitas.

### Automatización avanzada

Mantener fuera del vertical slice actual. Trabajadores originales del mundo de `game1` con tareas `HARVEST`, `MINE`, `CHOP`, `TRANSPORT`, `PROCESS`, evolucionando de trabajo manual a cadenas automatizadas con infraestructura, rutas, storage y mantenimiento/energía.

## Regla de continuidad

Al retomar: leer memoria/roadmap/spec/arte; revisar HEAD, CI, #82/#83, issues, PRs y workers; exigir Godot 4.7.2 + quality/import/smoke/suite; mantener documentación alineada con código realmente integrado y aceptación visual realmente demostrada.
