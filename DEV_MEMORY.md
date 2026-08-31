# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`.
- Rama principal: `main`.
- HEAD de referencia de esta sincronización: `98045f4cfe4d8ee1b6c7f8061c7bb17356f81001`.
- CI de `main` para ese HEAD: run `33395789790`, **success**.
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
- 8A.7 decisiones de cadáver: #64 / #104 integradas mediante PR #106. `cremate`/`research` son terminales, mutuamente excluyentes, idempotentes, persistentes y conceden recompensas data-driven mediante APIs públicas existentes.
- 8A.8 feedback/hooks: #65 / #111 integradas mediante PR #112. Los eventos de entrega funeraria y decisión terminal se emiten post-éxito, exactly-once y desacoplados de listeners; #65 y #111 cerradas.
- 8A.9 #66 aceptación integral: desbloqueada; #115 `[AUTO][GAMEPLAY][P0]` preparada/asignada como gate end-to-end del track.

## Reset visual — estado real

Los screenshots de `docs/` son el benchmark oficial. El arte integrado anteriormente puede seguir siendo funcional pero no se considera visualmente aceptado por el mero hecho de estar en `main`.

- #96 QA visual: **integrada y cerrada** mediante PR #108. Existe tooling determinista para capturas 1280x720 asociado a SHA, con cámara/zoom reales, manifest de personajes/NPCs, cementerio día/noche, arquitectura/props y UI core. El render perceptual se ejecuta localmente con display; CI valida contrato/smoke del flujo.
- PR #107 ARCH: **integrado**; documenta la recomendación de rechazar 32x48 como baseline hero, preferir 64x96 nativo para player/key NPCs y desacoplar canvas visual de colisión/navegación.
- #94 ARCH: **abierta intencionadamente**. La arquitectura está integrada, pero la aceptación perceptual requiere evidencia in-game real de #109.
- #109 CHARACTERS: activa mediante PR draft #114. El head actual añade primero el contrato TDD del player 64x96; CI falla intencionadamente en 17 aserciones de `PlayerProductionVisual` contra el placeholder actual. Además existe un fallo no aceptable de `gdformat` en el test nuevo; el worker debe corregir formato, sustituir realmente el asset, aportar capturas #96 y dejar todos los gates verdes antes de readiness/merge.
- #113 WORLD: preparada/asignada para reemplazar los assets reales `player_workshop.svg` y `village_house.svg` por arquitectura de producción. No existe restricción 160x128 y puede migrar de SVG a raster/layers si mejora calidad.
- `ART_DIRECTION.md` todavía contiene el contrato histórico 32x48/1.5x. **No modificarlo hasta que #94 quede validada**; después el supervisor debe actualizarlo para reflejar la decisión final.

## Estado visual/UI integrado frente a aceptación

- #25, #26, #28 y #29: implementaciones integradas, sujetas al reset visual donde aplique.
- PR #89 / #27 Brother Aldren: integrado funcionalmente; aceptación visual pendiente.
- PR #90 + #102 / #30 atmósfera: integrados funcionalmente; aceptación visual pendiente.
- PR #91 + #78 / #68 UI: integrados funcionalmente; aceptación visual final pendiente.
- #31 aceptación visual integral sigue pendiente.

## Audio — estado real

- Los hooks requeridos por audio ya están integrados mediante #65/#111/PR #112.
- #93 ha sido desbloqueada y convertida en `[AUTO][AUDIO][P1]`; ownership AUDIO, sin tocar gameplay/UI/maps/personajes.
- Debe consumir EventBus existente, establecer buses Master/Music/Ambience/SFX, ambiente diferenciado y SFX mínimos, con licencias verificables y gates completos.

## Quality bar visual obligatorio

Pixel-art oscuro de alto detalle; siluetas claras; ocho direcciones realmente coherentes; cara/cabello/ropa/equipamiento/materiales legibles; arquitectura con personalidad; entorno denso y artesanal; caminos integrados; vegetación abundante pero legible; props/lápidas con volumen; iluminación cálida localizada; sombras profundas; paleta medieval oscura rica/controlada y acabado profesional.

No existe restricción heredada de tamaño. Si 32x48, 160x128 para edificios, 32 px de tile visual u otra escala antigua obliga a reducir calidad, aumentar resolución/escala o ajustar cámara/zoom de forma planificada. CI verde no sustituye la revisión visual humana contra `docs/`.

## Cola autónoma actual

- GAMEPLAY: #115 `[AUTO][GAMEPLAY][P0]` asignada para #66; gate integral de Track 8A.
- CHARACTERS: #109 activa mediante PR draft #114; no preparar otra CHARACTERS mientras esté abierta.
- WORLD: #113 preparada/asignada; no preparar otra WORLD mientras siga activa o exista su PR.
- AUDIO: #93 preparada/asignada; ya no está bloqueada por #65.
- ARCH: #94 abierta pero bloqueada por evidencia de #109; no duplicar trabajo.
- UI/POLISH: sin slot mientras las cuatro unidades prioritarias anteriores estén activas.

## Coordinación del supervisor

- Solo el supervisor actualiza `ROADMAP.md`, `DEV_MEMORY.md`, `CHANGELOG.md` y `README.md`.
- Revisar `main`, CI, #82/#83, PRs, issues, scope, ownership, dependencias y mergeabilidad en cada ejecución.
- Integrar PRs uno a uno solo si están actualizados y verdes en gdlint, gdformat --check, Godot 4.7.2 import, smoke y suite.
- Tras cada merge, reevaluar `main` y la cola antes de integrar el siguiente.
- Para PRs visuales, exigir además evidencia in-game reproducible y comparación humana contra `docs/`.
- Diferenciar siempre implementación integrada de aceptación visual pendiente.
- No forzar merges ni rebajar gates.

## Trackers

- #71 — M8A Gameplay Depth: #65 completada, #66 siguiente vía #115.
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
