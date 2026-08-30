# ROADMAP

## Fase 0 — Bootstrap — COMPLETADA
- [x] Repositorio, Godot 4.x, escena raíz, estructura y Autoloads mínimos.
- [x] InputMap, logging, debug, persistencia inicial, tests y CI headless.
- Validación: `33278173612`.

## Fase 1 — Core / Walking Prototype — COMPLETADA
- [x] Mundo base, `CharacterBody2D`, movimiento 8 direcciones, cámara, colisiones y Y-sort.
- [x] `Interactable` reutilizable y aceptación de escenas.
- Validación: `33280758441`.

## Fase 2 — Items / Resource Loop — COMPLETADA
- [x] `ItemData`, inventario, stacks/capacidad, energía, recursos, herramientas y loot.
- [x] Tests del loop completo.
- Cierre: `c196e3ab5a42adffe97278f0b0daa8960c789e04`, run `33285578050`.

## Fase 3 — Crafting / Production Loop — COMPLETADA
- [x] Recetas data-driven, crafting atómico, `StorageNetwork` y producción temporizada.
- [x] Tests y CI final verdes.
- Cierre: `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`.

## Fase 4 — Cementerio — COMPLETADA
- [x] Cadáveres, descomposición, tumbas, rating, preparación/entierro/mejoras y persistencia.
- [x] Tests de aceptación y CI final verdes.
- Cierre: `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`.

## Fase 5 — Simulación — COMPLETADA
- [x] Reloj/calendario, ciclo día/noche y sueño.
- [x] `NPCData`, `NavigationAgent2D`, horarios, estados y persistencia NPC.
- [x] Aceptación integral y CI final verdes.
- Cierre: `f0290951a27d5e66581da2532151d957ec35075e`, run `33297774458`.

## Fase 6 — RPG — COMPLETADA
- [x] Diálogo/localización EN/ES, relaciones y condiciones contextuales.
- [x] Quests con recompensas idempotentes.
- [x] Economía atómica + comercio UI jugable.
- [x] Tecnologías + integración de puntos tecnológicos desde quests.
- [x] Persistencia conjunta de providers RPG.
- [x] Aceptación integral final #9 sobre `world.tscn` real.
- [x] Quality gate global para todos los `*.gd`.
- Cierre integral: PR #39, acceptance HEAD `ea3543aba5b6d859266553a964d817f54670b9a3`, run `33308814397`.
- Runtime/CI actualizado a **Godot 4.7.2** mediante PR #41.

## Transición pre-Fase 7 — COMPLETADA
1. [x] **#17 — Contrato visual**: `ART_DIRECTION.md` fija perspectiva, tile 32 px, escala/footprints, cámara, pivotes/Y-sort, capas, paleta, luz y convenciones de assets.
2. [x] **#16 — TileMapLayer foundation**: mapa técnico, seis capas contractuales y sustitución del blockout de suelo/colisión.

## Fase 7 — Mundo — COMPLETADA
Pueblo, bosque, mina, interiores, exploración y secretos.

### Bloques completados
- [x] **#16 — Foundation técnica `TileMapLayer`** — PR #44.
- [x] **#18 — Cementerio + taller del jugador** — PR #47, run `33316327221`.
- [x] **#19 — Bosque de recursos** — PR #48, run `33316454888`.
- [x] **#20 — Pueblo de Valdeniebla** — PR #46, run `33315626881`.
- [x] **#21 — Interiores modulares + transiciones** — PR #49, run `33318051580`.
- [x] **#22 — Mina inicial** — PR #50, run `33318407597`.
- [x] **#23 — Integración de zonas + exploración** — PR #53, merge `6c84c0f2d0e97e64c8f4f94f8de7ef144111c86a`.
- [x] **#24 — Aceptación integral de mundo** — PR #54, run `33331207740`.

Cierre funcional integrado: PR #54, merge `7e281255322b6c7444d4177d85295b353babb38f`.

## Fase 8 — Polish — ACTIVA
Arte, animaciones, shaders, partículas, audio, feedback, UI final y optimización. El polish incluye profundizar el núcleo jugable antes de escalar arte final cuando `GAME_DESIGN.md` lo exige.

### Track 8A — Gameplay Depth & Feel
Fuente: `docs/superpowers/specs/2026-08-30-phase8a-cemetery-depth-design.md`.

- [x] **8A.1 — Descomposición acelerada:** `decay_percent: int` 0–100, `age_minutes: int`, estados Fresh/Fading/Decomposed/Rotten, pérdida de calidad efectiva y tasas crecientes 0–24 / 24–48 / 48–72 / >72 h. Grandes saltos de tiempo son deterministas. PR #57, CI final pre-merge `33335150259` verde.
- [x] **8A.2 — Conservación:** modificadores enteros data-driven de tecnología, utensilios e instalaciones, neutrales por defecto y multiplicativos; ralentizan solo deterioro futuro, preservan progreso subporcentual y persisten en snapshot. PR #59, CI funcional `33336387360` verde.
- [ ] **8A.3 — Agricultura mínima:** `fodder_turnip_seed` → plantar → crecimiento por `TimeManager` → cosecha → persistencia.
- [ ] **8A.4 — Recurso multiuso:** nabo forrajero comprable/vendible, almacenamiento y cocina reutilizando crafting; cultivar debe ser la estrategia sostenible.
- [ ] **8A.5 — Servicio funerario:** entrega determinista al atardecer, objetivo 18:00; intro gratuita y después consumo de nabo desde comedero; exactamente una entrega por día incluso con sueño/time-jump/save-load.
- [ ] **8A.6 — Logística progresiva:** descarga inicial junto al camino y rampa desbloqueable al área de recepción sin bonus de conservación.
- [ ] **8A.7 — Decisiones de cadáver:** preparar/enterrar existentes + cremar/investigar con costes/recompensas distintos.
- [ ] **8A.8 — Feedback mínimo:** hooks EventBus/AudioManager para entrega y acciones permanentes.
- [ ] **8A.9 — Aceptación integral:** farming→comedero→18:00→cadáver→deterioro/conservación→decisión→save/load, con quality/import/smoke/suite verdes.

Decisiones de alcance 8A: sin hambre, estaciones/clima agrícola, riego/fertilizante complejo ni supply/demand. El transporte, animal/personaje, alimento, quest, textos y assets serán originales.

### Sub-track visual #25–#31
- [x] **#25 — Tileset exterior pixel-art original** — atlas `256 x 256`, cuadrícula `8 x 8` de tiles `32 x 32`, PR #56; run `33333578933` verde.
- [ ] **#26 — Player spritesheet + animaciones de movimiento**.
- [ ] **#27 — NPC visual base + Brother Aldren animado**.
- [ ] **#28 — Props, edificios y assets de cementerio**.
- [ ] **#29 — Integración artística de mapas y sustitución de placeholders** — bloqueada por #25 y #28.
- [ ] **#30 — Atmósfera: sombras, vegetación, iluminación y partículas** — bloqueada por #29.
- [ ] **#31 — Aceptación visual del vertical slice** — bloqueada por #25–#30.

Fase 8 permanece **ACTIVA**. El siguiente bloque del track de profundidad es **8A.3 — agricultura mínima**; el sub-track visual puede avanzar en tareas independientes sin pisar sistemas de gameplay.
