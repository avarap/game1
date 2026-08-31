# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`.
- Rama principal: `main`.
- HEAD de referencia de esta sincronización: `9ff20a44db34cfa46b7b0cee7576735c6f283534`.
- CI de `main` para ese HEAD: run `33386137356`, **success**.
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
- 8A.6 logística progresiva: #63 integrada mediante PR #103; ya no hay trabajo activo en #100/#101.
- 8A.7 decisiones de cadáver: #104 abierta con PR #106 activo. Run `33385915562` deja import/smoke/suite verdes pero falla `gdformat --check`; no integrar hasta nueva validación completamente verde y resincronización con el HEAD actual de `main` si fuera necesaria.
- 8A.8 #65 y 8A.9 #66: pendientes.

## Reset visual — estado real

Los screenshots de `docs/` son el benchmark oficial. El arte integrado anteriormente puede seguir siendo funcional pero no se considera visualmente aceptado por el mero hecho de estar en `main`.

- #96 QA visual: **integrada y cerrada** mediante PR #108. Existe tooling determinista para capturas 1280x720 asociado a SHA, con cámara/zoom reales, manifest de personajes/NPCs, cementerio día/noche, arquitectura/props y UI core. El render perceptual se ejecuta localmente con display; CI valida contrato/smoke del flujo.
- PR #107 ARCH: **integrado** en `main` `9ff20a44...`; documenta la recomendación de rechazar 32x48 como baseline hero, preferir 64x96 nativo para player/key NPCs y desacoplar canvas visual de colisión/navegación.
- #94 ARCH: **reabierta por supervisor tras el merge de #107**. El cierre producido al mergear no satisface la aceptación perceptual porque #107 no incluye la comparación in-game requerida. #94 está bloqueada por #109 hasta disponer de baseline 32x48 frente a candidatos nativos 48x72/64x96 con zoom 1.0/1.25/1.5.
- #109 CHARACTERS: preparada y desbloqueada. Debe producir candidatos nativos 48x72 y 64x96, 8 direcciones coherentes y capturas deterministas usando #96. No vale escalar el arte 32x48 existente.
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

- GAMEPLAY: #104 / PR #106. Worker permanece en este PR hasta corregir `gdformat --check`, revalidar todos los gates y resincronizar con `main` cuando corresponda.
- CHARACTERS: #109 asignada como siguiente P0 visual para producir la prueba nativa 48x72/64x96.
- ARCH: #94 está abierta pero bloqueada por #109; el slot ARCH queda en STANDBY para evitar duplicar trabajo hasta que existan capturas.
- AUDIO: #93 permanece bloqueada hasta #65.
- WORLD/UI/POLISH: no preparar/duplicar reworks finales hasta que #94/#109 generen evidencia suficiente; después crear issues independientes por ownership.
- Existe además otro slot general en STANDBY mientras no haya una issue preparada y desbloqueada adicional.

## Coordinación del supervisor

- Solo el supervisor actualiza `ROADMAP.md`, `DEV_MEMORY.md`, `CHANGELOG.md` y `README.md`.
- Revisar `main`, CI, #82/#83, PRs, issues, scope, ownership, dependencias y mergeabilidad en cada ejecución.
- Integrar PRs uno a uno solo si están actualizados y verdes en gdlint, gdformat --check, Godot 4.7.2 import, smoke y suite.
- Tras cada merge, reevaluar `main` y la cola antes de integrar el siguiente.
- Diferenciar siempre implementación integrada de aceptación visual pendiente.
- No forzar merges ni rebajar gates.

## Trackers

- #71 — M8A Gameplay Depth.
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
