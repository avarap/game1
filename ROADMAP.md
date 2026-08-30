# ROADMAP

## Fase 0 — Bootstrap — COMPLETADA
- [x] Repositorio, Godot 4.x, escena raíz, estructura y Autoloads mínimos.
- [x] InputMap, logging, debug, persistencia inicial, tests y CI headless.

Validación: `Godot CI` run `33278173612`, `success`.

## Fase 1 — Core / Walking Prototype — COMPLETADA
- [x] Mundo base, `CharacterBody2D`, movimiento 8 direcciones, cámara, colisiones y Y-sort.
- [x] `Interactable` reutilizable y aceptación de escenas.

Validación: `Godot CI` run `33280758441`, `success`.

## Fase 2 — Items / Resource Loop — COMPLETADA
- [x] `ItemData`, inventario data-driven, stacks/capacidad y `InventoryComponent` local.
- [x] `EnergyComponent`, recursos recolectables, herramientas, loot y atomicidad.
- [x] Tests del loop completo y CI final.

Implementación final: `c196e3ab5a42adffe97278f0b0daa8960c789e04`.
Validación: `Godot CI` run `33285578050`, `success`.

## Fase 3 — Crafting / Production Loop — COMPLETADA

Criterios principales:
- [x] Recetas tipadas/data-driven y primera receta real.
- [x] Crafting atómico, estación local, coste de energía correcto.
- [x] `StorageProvider`/`StorageNetwork` y crafting distribuido.
- [x] Producción temporizada y colas recuperables.
- [x] Outputs bloqueados reintentables sin perder materiales.
- [x] Tests y CI final verdes.

Cierre: `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`, `success`.

## Fase 4 — Cementerio — COMPLETADA

Criterios de aceptación:
- [x] `CorpseData`, estado de cadáver y descomposición progresiva.
- [x] Modelo de tumba/cementerio independiente de UI.
- [x] Rating encapsulado y configurable.
- [x] Recibir/preparar -> enterrar -> calcular contribución.
- [x] Lápida, valla y decoración alteran rating mediante datos.
- [x] Persistencia de tumbas/cadáveres con guardado versionado.
- [x] Tests de aceptación y CI final verdes.

Cierre: `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`, `success`.

## Fase 5 — Simulación — COMPLETADA

### Criterios de aceptación
- [x] Reloj, días y calendario consolidados sobre `TimeManager` sin duplicar estado.
- [x] Ciclo día/noche gradual observable por el mundo.
- [x] Dormir avanza al siguiente día y restaura energía.
- [x] `NPCData` data-driven y primer NPC de prueba.
- [x] `NavigationAgent2D` y navegación básica sin bloquear gameplay.
- [x] Rutinas/horarios con estados `Idle`/`Walking`/`Working`/`Sleeping`.
- [x] Persistencia de posición/estado/ruta relevante de NPCs mediante `SaveManager`.
- [x] El estado temporal y de NPCs sobrevive save/load.
- [x] Test de aceptación lógico del flujo completo de simulación.
- [x] `gdscript-quality` verde sobre los scripts tocados.
- [x] CI final verde antes de cerrar la fase.

### Bloque 1 — Tiempo/calendario y sueño
- `TimeManager` centraliza snapshot/restauración, semana ficticia de seis días y transición al amanecer.
- `SleepSpot` avanza al siguiente día a las 06:00 y restaura energía.
- Corrección final: `62cb2658bd169270fffcb59c34134493b787f327`.
- Validación: run `33294728470`, `success`.

### Hardening transversal
- [x] Storage limitado por scope.
- [x] Dependencias frágiles por nombres/NodePath reducidas.
- [x] Código muerto eliminado.
- [x] `gdlint` + `gdformat --check` añadidos como quality gate.
- Estado final: `b13d024143b5fb0ff8118a689da079c37916c554`, run `33295277286`, ambos jobs `success`.

### Bloque 2 — Ciclo día/noche
- [x] `DayNightMath` e interpolación pura.
- [x] 06:00 amanecer, 12:00 mediodía, 18:00 atardecer, 22:00 noche.
- [x] Transición continua a través de medianoche.
- [x] `DayNightController` local y sincronizado con `TimeManager`.
- [x] Tests e integración de escena.
- Cierre: `5c6467c5aad04b1d44c48cceef2280af5d049bf8`, run `33295805020`, `success`.

### Bloque 3 — NPCData y navegación
- [x] `NPCData` tipado y recurso real de Hermano Aldren.
- [x] `NPCNavigationMath` puro.
- [x] Región navegable local y `NPCController` con `NavigationAgent2D`.
- [x] Tests de datos/navegación/escena.
- Run `33296112250` detectó `class-definitions-order`; corregido sin relajar reglas.
- Cierre: `03986401968c83b79527d15f47217f090de43ab2`, run `33296131085`, `success`.

### Bloque 4 — Horarios y estados NPC
- [x] `ScheduleEntryData`/`ScheduleData` tipados, seis días y rangos que cruzan medianoche.
- [x] `NPCStateMachine` con `Idle`, `Walking`, `Working`, `Sleeping`.
- [x] Hermano Aldren usa un horario real data-driven.
- [x] `TimeManager`/`EventBus` gobiernan la rutina; destinos pertenecen al horario.
- [x] Tests de rutina e integración.
- Run `33296549903` detectó comparación `Dictionary`/`int`; corregida en `82f5ccee1e109e2ad702532b7301922124548c7b`.
- Validación: run `33296648630`, `success`.

### Bloque 5 — Persistencia NPC y aceptación final
- [x] `NPCStateMachine` serializa/restaura estado actual y pendiente.
- [x] `NPCController` es `save_provider` local con clave estable `npc:<id>`.
- [x] Se guardan `id`, posición, estado actual/pending, navegación activa y target cuando aplica.
- [x] Save/load restaura una ruta en curso y futuras señales de `TimeManager` vuelven a gobernar la rutina.
- [x] `test_simulation_acceptance.gd` cubre horario, día/noche, persistencia real, navegación restaurada y sueño/energía.
- Implementación inicial: `b8bd10cb2f014c64e4a9a5dbb30e6e041862d6be`.
- Run `33297598359`: 12 fallos de aceptación por ejecutar escenas dentro de `SceneTree._initialize()`.
- `79670b23b1306031e21bf2a3403a90ced5edc383`: contratos de simulación activados al entrar al árbol; run `33297716722` mantuvo los 12 fallos y confirmó que el harness seguía siendo la causa.
- Corrección final: `f0290951a27d5e66581da2532151d957ec35075e`, suites diferidas hasta que el `SceneTree` está operativo.
- Validación final: `Godot CI` run `33297774458`, `gdscript-quality` y `validate-and-test` en `success`.

**Fase 5 cerrada: todos los criterios están cumplidos.**

## Fase 6 — RPG — ACTIVA

### Criterios de aceptación derivados del master spec
- [ ] Diálogos, condiciones y opciones funcionan desde datos.
- [ ] Relaciones cambian y desbloquean contenido.
- [ ] Quests pueden iniciarse, progresar y completarse.
- [ ] Las recompensas de quests se conceden una sola vez.
- [ ] La economía compra y vende correctamente.
- [ ] Las tecnologías consumen puntos y desbloquean contenido.
- [ ] Estado RPG persistente compatible con `SaveManager`, cuando aplique.
- [ ] Tests de aceptación del flujo RPG mínimo.
- [ ] `gdscript-quality` verde sobre los archivos tocados.
- [ ] CI final verde antes de cerrar la fase.

### Próximo bloque
Foundation de diálogo data-driven: Resources tipados para diálogo/opciones/condiciones, evaluación pura/testeable y una integración mínima original con Hermano Aldren. No adelantar relaciones, quests, economía y tecnologías hasta que la foundation esté validada.

## Fase 7 — Mundo
Pueblo, bosque, mina, interiores, exploración y secretos.

## Fase 8 — Polish
Arte, animaciones, shaders, partículas, audio, feedback, UI final y optimización.
