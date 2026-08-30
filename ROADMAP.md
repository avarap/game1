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

## Fase 4 — Cementerio — SIGUIENTE

Criterios iniciales de aceptación derivados del master spec:
- [ ] `CorpseData` tipado con calidad, decay, preparación y valor de entierro.
- [ ] Modelo de tumba/cementerio independiente de UI y escenas visuales.
- [ ] Fórmula de rating encapsulada y configurable, no dispersa por escenas.
- [ ] Flujo mínimo: recibir/preparar cadáver -> enterrar -> calcular contribución de tumba.
- [ ] Lápida y valla como mejoras que alteran el rating mediante datos.
- [ ] Descomposición progresiva testeable.
- [ ] Persistencia mínima del estado de tumbas/cadáveres compatible con el guardado versionado.
- [ ] Test de aceptación del loop mínimo de cementerio.
- [ ] CI final verde antes de cerrar la fase.

No ampliar todavía a NPCs, calendario, quests o economía salvo la interfaz estrictamente necesaria para Fase 4.

## Fase 5 — Simulación
Tiempo, día/noche, calendario, NPCs, navegación y rutinas.

## Fase 6 — RPG
Diálogo, relaciones, quests, economía y tecnologías.

## Fase 7 — Mundo
Pueblo, bosque, mina, interiores, exploración y secretos.

## Fase 8 — Polish
Arte, animaciones, shaders, partículas, audio, UX y optimización.
