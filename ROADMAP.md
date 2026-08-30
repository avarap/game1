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
- [x] Energía, recursos recolectables, herramientas, loot y atomicidad.
- [x] Tests del loop completo y CI final.

Cierre: `c196e3ab5a42adffe97278f0b0daa8960c789e04`, run `33285578050`, `success`.

## Fase 3 — Crafting / Production Loop — COMPLETADA
- [x] Recetas data-driven, crafting atómico y estación local.
- [x] `StorageProvider`/`StorageNetwork` y crafting distribuido.
- [x] Producción temporizada, colas y outputs recuperables.
- [x] Tests y CI final verdes.

Cierre: `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`, `success`.

## Fase 4 — Cementerio — COMPLETADA
- [x] Cadáveres, descomposición, tumbas y rating data-driven.
- [x] Flujo recibir/preparar/enterrar/mejorar jugable.
- [x] Persistencia mediante guardado versionado.
- [x] Tests de aceptación y CI final verdes.

Cierre: `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`, `success`.

## Fase 5 — Simulación — COMPLETADA
- [x] Reloj/calendario sobre `TimeManager`.
- [x] Ciclo día/noche gradual y sueño.
- [x] `NPCData`, `NavigationAgent2D`, horarios y estados.
- [x] Persistencia NPC y estado temporal mediante `SaveManager`.
- [x] Aceptación integral y CI final verdes.

Cierre funcional: `f0290951a27d5e66581da2532151d957ec35075e`, run `33297774458`, ambos jobs `success`.

## Fase 6 — RPG — ACTIVA

### Criterios de aceptación
- [x] Diálogos, condiciones y opciones funcionan desde datos.
- [x] Los diálogos del vertical slice soportan inglés y español mediante claves estables, sin duplicar el grafo.
- [ ] Relaciones cambian y desbloquean contenido.
- [ ] Quests pueden iniciarse, progresar y completarse.
- [ ] Las recompensas de quests se conceden una sola vez.
- [ ] La economía compra y vende correctamente.
- [ ] Las tecnologías consumen puntos y desbloquean contenido.
- [ ] Estado RPG persistente compatible con `SaveManager`, cuando aplique.
- [ ] Tests de aceptación del flujo RPG mínimo.
- [ ] `gdscript-quality` verde sobre el HEAD final de la fase.
- [ ] CI final verde antes de cerrar la fase.

### Política de localización
- Idiomas iniciales: `en` y `es`; fallback `en`.
- `TranslationServer` + `LocalizationService`, sin nuevo Autoload.
- Catálogos `localization/en.po` y `localization/es.po`.
- IDs, condiciones, progreso y saves nunca dependen de texto traducido.
- Ver `LOCALIZATION.md`.

### Bloque 1 — Foundation de diálogo bilingüe — COMPLETADO
- [x] `DialogueConditionData`, `DialogueOptionData`, `DialogueNodeData` y `DialogueData` tipados.
- [x] `DialogueService` puro/testeable para iniciar, filtrar opciones y navegar por IDs.
- [x] `DialogueController` local: UI mínima y selector runtime ES/EN.
- [x] `DialogueInteractable` integrado con el sistema genérico de interacción.
- [x] Primer diálogo original de Hermano Aldren en un único grafo data-driven.
- [x] Traducciones inglesas y españolas registradas en Godot.
- [x] Cambio de idioma durante un diálogo sin alterar el nodo activo.
- [x] Tests de foundation y gameplay real en `world.tscn`.
- [x] Quality gate ampliado.
- Implementación: `60bc1e7e137fbbad61e8a6604aa52ae872b2415b`.
- Run `33298684332`: gameplay/tests verdes; `gdformat` detectó un único archivo sin formato.
- Corrección: `46a37e00c2ad968e91834da5577a6f512a28f0a9`.
- Validación: `Godot CI` run `33298737838`, `gdscript-quality` y `validate-and-test` en `success`.

### Próximo bloque
Foundation de relaciones: estado 0-100, datos desacoplados y condición de relación capaz de desbloquear una opción del diálogo de Hermano Aldren. Validar antes de abrir quests.

## Fase 7 — Mundo
Pueblo, bosque, mina, interiores, exploración y secretos.

## Fase 8 — Polish
Arte, animaciones, shaders, partículas, audio, feedback, UI final y optimización.
