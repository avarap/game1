# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`.
- Rama principal: `main`.
- HEAD de referencia de esta sincronización: `2f1f9a0345fb782bf67c18f09714ab674cc78981`.
- CI de `main` para ese HEAD: run `33386976569`, **success**.
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
- `WorldLocationProvider` persiste zona/marker/posición y restore no debe reinicializar actores persistentes como Brother Aldren.

## Fase 8A — estado integrado

- 8A.1 descomposición acelerada y 8A.2 conservación determinista: integradas.
- 8A.3 agricultura mínima: PR #76.
- 8A.4 recurso multiuso: #61 / PR #81.
- 8A.5 servicio funerario: #62 / PR #99.
- 8A.6 logística progresiva: #63 / PR #103.
- 8A.7 decisiones de cadáver: #64 / #104 integradas mediante PR #106. `cremate`/`research` son terminales, mutuamente excluyentes, idempotentes, persistentes y conceden recompensas data-driven mediante APIs públicas existentes. #64 y #104 cerradas.
- 8A.8 feedback/hooks: #65 sigue abierta y #111 `[AUTO][GAMEPLAY][P1]` está preparada/asignada para implementar eventos exactly-once desacoplados.
- 8A.9 #66 aceptación integral: bloqueada hasta integrar #65/#111.

## Reset visual — estado real

Los screenshots de `docs/` son el benchmark oficial. El arte integrado anteriormente puede seguir siendo funcional pero no se considera visualmente aceptado por el mero hecho de estar en `main`.

- #96 QA visual: **integrada y cerrada** mediante PR #108. Existe tooling determinista para capturas 1280x720 asociado a SHA, con cámara/zoom reales, manifest de personajes/NPCs, cementerio día/noche, arquitectura/props y UI core. El render perceptual se ejecuta localmente con display; CI valida contrato/smoke del flujo.
- PR #107 ARCH: **integrado**; documenta la recomendación de rechazar 32x48 como baseline hero, preferir 64x96 nativo para player/key NPCs y desacoplar canvas visual de colisión/navegación.
- #94 ARCH: **abierta intencionadamente**. La arquitectura ya está integrada, pero la aceptación perceptual requiere la comparación in-game real que produce #109.
- #109 CHARACTERS: preparada y asignada. Debe producir candidatos nativos 48x72 y 64x96, ocho direcciones coherentes y capturas deterministas usando #96; no vale escalar el arte 32x48 existente.
- `ART_DIRECTION.md` todavía contiene el contrato histórico 32x48/1.5x. **No modificarlo hasta que #94 quede validada**; después el supervisor debe actualizarlo para reflejar la decisión final.

## Estado visual/UI integrado frente a aceptación

- #25, #26, #28 y #29: implementaciones integradas, sujetas al reset visual donde aplique.
- PR #89 / #27 Brother Aldren: integrado funcionalmente; aceptación visual pendiente.
- PR #90 + #102 / #30 atmósfera: integrados funcionalmente; aceptación visual pendiente.
- PR #91 + #78 / #68 UI: integrados funcionalmente; aceptación visual final pendiente.
- #31 aceptación visual integral sigue pendiente.

## Quality bar visual obligatorio

Pixel-art oscuro de alto detalle; siluetas claras; ocho direcciones realmente coherentes; cara/cabello/ropa/equipamiento/materiales legibles; arquitectura con personalidad; entorno denso y artesanal; caminos integrados; vegetación abundante pero legible; props/lápidas con volumen; iluminación cálida localizada; sombras profundas; paleta medieval oscura rica/controlada y acabado profesional.

No existe restricción heredada de tamaño. Si 32x48, 32 px de tile visual u otra escala antigua obliga a reducir calidad, aumentar resolución/escala o ajustar cámara/zoom de forma planificada. CI verde no sustituye la revisión visual humana contra `docs/`.

## Cola autónoma actual

- GAMEPLAY: #111 asignada como siguiente unidad para #65. No preparar otra GAMEPLAY mientras #111 o su PR estén activos.
- CHARACTERS: #109 asignada como P0 visual para producir la prueba nativa 48x72/64x96.
- ARCH: #94 abierta pero bloqueada por #109; no duplicar trabajo hasta recibir capturas.
- AUDIO: #93 permanece bloqueada hasta integrar #65/#111; #67 depende del mismo gate.
- WORLD/UI/POLISH: no preparar/duplicar reworks finales hasta que #94/#109 generen evidencia suficiente; después crear issues independientes por ownership.
- Dos slots generales permanecen en STANDBY mientras no exista trabajo independiente preparado adicional.

## Coordinación del supervisor

- Solo el supervisor actualiza `ROADMAP.md`, `DEV_MEMORY.md`, `CHANGELOG.md` y `README.md`.
- Revisar `main`, CI, #82/#83, PRs, issues, scope, ownership, dependencias y mergeabilidad en cada ejecución.
- Integrar PRs uno a uno solo si están actualizados y verdes en gdlint, gdformat --check, Godot 4.7.2 import, smoke y suite.
- Tras cada merge, reevaluar `main` y la cola antes de integrar el siguiente.
- Diferenciar siempre implementación integrada de aceptación visual pendiente.
- No forzar merges ni rebajar gates.

## Trackers

- #71 — M8A Gameplay Depth: #64 completada, #65 siguiente vía #111, #66 gate final 8A.
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
