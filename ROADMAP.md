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
- [x] Ciclo día/noche observable por el mundo.
- [x] Dormir: avance al siguiente día y restauración de energía.
- [x] `NPCData` data-driven y primer NPC de prueba.
- [x] `NavigationAgent2D` y navegación básica.
- [ ] Rutinas/horarios con estados mínimos Idle/Walking/Working/Sleeping.
- [ ] Persistencia mínima de posición/estado de NPCs.
- [ ] Tests de aceptación y CI verde antes de cerrar.

Bloque 1 — tiempo/calendario y sueño:
- `TimeManager` centraliza snapshot/restauración, avance de día, semana ficticia de seis días y transición al amanecer.
- `SleepSpot` avanza al día siguiente a las 06:00 y restaura la energía.
- Validación final: `62cb2658bd169270fffcb59c34134493b787f327`, run `33294728470`, `success`.

Hardening transversal antes del bloque 2:
- [x] Storage limitado por `scope_id`/`storage_scope`.
- [x] Componentes de jugador/cofres resueltos por contrato/tipo.
- [x] `CemeteryAction` sin `NodePath` relativo frágil.
- [x] Código muerto eliminado.
- [x] Job `gdscript-quality` con `gdlint` y `gdformat --check`.
- Estado final: `b13d024143b5fb0ff8118a689da079c37916c554`, run `33295277286`, ambos jobs `success`.

Bloque 2 — ciclo día/noche:
- [x] `DayNightMath` encapsula fases e interpolación pura.
- [x] Referencias horarias: 06:00 amanecer, 12:00 mediodía, 18:00 atardecer, 22:00 noche.
- [x] Transición nocturna continua a través de medianoche.
- [x] `DayNightController` local basado en `CanvasModulate`, sin nuevo Autoload.
- [x] El controller observa `time_changed` y deriva todo el estado visual de `TimeManager`.
- [x] `world/world.tscn` contiene `DayNightCycle`.
- [x] Tests cubren referencias, interpolación, fases e integración de escena.
- [x] Nuevos scripts/tests incorporados al quality gate.
- Corrección final: `5c6467c5aad04b1d44c48cceef2280af5d049bf8`.
- Validación final: `Godot CI` run `33295805020`, ambos jobs `success`.

Bloque 3 — NPCData y navegación básica:
- [x] `NPCData` tipado con identidad, rol y velocidad de movimiento.
- [x] Primer recurso real `brother_aldren.tres`.
- [x] `NPCNavigationMath` separa la lógica pura de dirección/llegada.
- [x] `WorldNavigationRegion` proporciona geometría navegable mínima local.
- [x] `NPCController` usa `CharacterBody2D` + `NavigationAgent2D` y destinos explícitos.
- [x] `BrotherAldren` está integrado en `world/world.tscn` con navegación inicial.
- [x] `test_npc_navigation.gd` cubre datos, matemática, región, agente y escena.
- [x] Quality gate ampliado a scripts/tests NPC.
- Run `33296112250` detectó `class-definitions-order` en `NPCController`; se corrigió sin desactivar reglas.
- Corrección final: `03986401968c83b79527d15f47217f090de43ab2`.
- Validación final: `Godot CI` run `33296131085`, `gdscript-quality` y `validate-and-test` en `success`.

Próximo bloque: `ScheduleData` + estados mínimos Idle/Walking/Working/Sleeping y selección de rutina según `TimeManager`. Después, persistencia mínima de NPCs y aceptación final de Fase 5.

No implementar todavía diálogo, quests, economía o relaciones.

## Fase 6 — RPG
Diálogo, relaciones, quests, economía y tecnologías.

## Fase 7 — Mundo
Pueblo, bosque, mina, interiores, exploración y secretos.

## Fase 8 — Polish
Arte, animaciones, shaders, partículas, audio, UX y optimización.
