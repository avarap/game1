# ROADMAP

## Fase 0 — Bootstrap — COMPLETADA
- [x] Repositorio, Godot 4.x, escena raíz, estructura y Autoloads mínimos.
- [x] InputMap, logging, debug, persistencia inicial, tests y CI headless.

Validación: `Godot CI` run `33278173612`, `success`.

## Fase 1 — Core / Walking Prototype — COMPLETADA
- [x] Mundo base, `CharacterBody2D`, movimiento 8 direcciones, cámara, colisiones y Y-sort.
- [x] `Interactable` reutilizable y aceptación de escenas.

Implementación: `b0881d4983997b22f1678904d4cf3417a099f739`.
Validación: `Godot CI` run `33280758441`, `success`.

## Fase 2 — Items / Resource Loop — COMPLETADA
- [x] `ItemData`, inventario data-driven, stacks/capacidad y `InventoryComponent` local.
- [x] `EnergyComponent`, recursos recolectables, herramienta requerida, loot y atomicidad.
- [x] Tests del loop completo y CI final.

Implementación final: `c196e3ab5a42adffe97278f0b0daa8960c789e04`.
Validación: `Godot CI` run `33285578050`, `success`.

## Fase 3 — Crafting / Production Loop — COMPLETADA

Criterios de aceptación:
- [x] `RecipeData` y `RecipeIngredient` tipados y data-driven.
- [x] Primera receta real `.tres` (`wood_to_plank`).
- [x] Crafting instantáneo con consumo/producción atómicos.
- [x] Rechazo sin mutación por estación incorrecta, inputs insuficientes o falta de espacio.
- [x] Estación local interactuable (`Workbench`) sin Autoload.
- [x] Coste de energía aplicado solo a crafting aceptado/exitoso.
- [x] `StorageProvider` y `StorageNetwork` desacoplados de cofres concretos.
- [x] Cofre compatible y crafting distribuido entre inventarios.
- [x] Producción temporizada y cola mínima mediante `ProductionJob`/`ProductionQueue`.
- [x] Inputs reservados atómicamente al encolar y progreso determinista.
- [x] Outputs bloqueados permanecen pendientes y pueden reintentarse sin perder materiales.
- [x] Crafting instantáneo permanece operativo sin regresiones.
- [x] Tests de cola, progreso, finalización, almacenamiento lleno e integración con estación.
- [x] CI final verde antes de cerrar la fase.

Bloque 1: `d284104ab8b9f300362413cd666bdab6b8855fbd` — run `33287832451`, `success`.
Bloque 2 StorageNetwork: `9f982b2e79e937449a5707f18287364bdec063b1` — run `33290225076`, `success`.
Bloque 3 producción temporizada: `2252fcbd4280acec1e60530c026a8f5dd3365b91` — run `33292481990`, `success`.

## Fase 4 — Cementerio — COMPLETADA

Criterios de aceptación derivados del master spec:
- [x] `CorpseData` tipado con calidad, decay, preparación y valor de entierro.
- [x] Modelo de tumba/cementerio independiente de UI y escenas visuales.
- [x] Fórmula de rating encapsulada y configurable, no dispersa por escenas.
- [x] Flujo mínimo: recibir/preparar cadáver -> enterrar -> calcular contribución de tumba.
- [x] Lápida y valla como mejoras jugables que alteran el rating mediante datos.
- [x] Descomposición progresiva testeable.
- [x] Persistencia mínima del estado de tumbas/cadáveres compatible con el guardado versionado.
- [x] Test de aceptación del loop mínimo de cementerio.
- [x] CI final verde antes de cerrar la fase.

Bloque 1 — foundation: `6e2bdab525adcc3e3d0fe65714c7f725e43eef91`, run `33293105681`, `success`.
Bloque 2 — flujo lógico: `c94bacac772f8f5a0075b972c56baeb86b37afa0`, run `33293544721`, `success`.
Bloque 3 — cierre gameplay/persistencia: implementación `73e968a097c8b0107292d2958f7d61b7b5af21ff`; corrección final `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`, `success`.

## Fase 5 — Simulación — ACTIVA

Criterios de aceptación:
- [x] Consolidar reloj, días y calendario sobre `TimeManager` sin duplicar estado.
- [ ] Ciclo día/noche observable por el mundo.
- [x] Dormir: avance al siguiente día y restauración de energía.
- [ ] `NPCData` data-driven y primer NPC de prueba.
- [ ] `NavigationAgent2D` y navegación básica.
- [ ] Rutinas/horarios con estados mínimos Idle/Walking/Working/Sleeping.
- [ ] Persistencia mínima de posición/estado de NPCs.
- [ ] Tests de aceptación y CI verde antes de cerrar.

Bloque 1 — tiempo/calendario y sueño:
- `TimeManager` centraliza snapshot/restauración, avance de día, semana ficticia de seis días y transición al amanecer.
- `SaveManager` persiste/restaura el tiempo exclusivamente mediante la API de `TimeManager`, conservando `save_version = 1`.
- `SleepSpot` es un `Interactable` del mundo que avanza al día siguiente a las 06:00 y restaura completamente la energía.
- `test_simulation_time.gd` cubre rollover de medianoche, semana ficticia, sueño y round-trip de guardado temporal.
- Implementación inicial: `57d9cfdc010398cf5b34764131c7859dd7221084`.
- Run `33294671978` detectó que `SleepSpot` asumía que el actor estaba dentro del árbol durante tests headless; importación y smoke test pasaron.
- Corrección: `62cb2658bd169270fffcb59c34134493b787f327` con fallback seguro al `SceneTree` principal.
- Validación final del bloque: `Godot CI` run `33294728470`, `success`.

Próximo bloque: ciclo día/noche observable mediante un controlador local del mundo que reaccione a `TimeManager`, sin introducir todavía NPCs.

No entrar en diálogo, relaciones, quests, economía o tecnologías salvo interfaces estrictamente necesarias para preparar Fase 6.

## Fase 6 — RPG
Diálogo, relaciones, quests, economía y tecnologías.

## Fase 7 — Mundo
Pueblo, bosque, mina, interiores, exploración y secretos.

## Fase 8 — Polish
Arte, animaciones, shaders, partículas, audio, UX y optimización.
