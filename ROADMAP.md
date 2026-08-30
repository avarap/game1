# ROADMAP

## Fase 0 — Bootstrap — COMPLETADA
- [x] Repositorio inicializado
- [x] `project.godot`
- [x] Escena raíz ejecutable
- [x] Estructura base
- [x] Autoloads mínimos
- [x] InputMap
- [x] Logging mínimo
- [x] Panel debug mínimo
- [x] Infraestructura de tests
- [x] CI headless
- [x] Validar CI real en GitHub Actions
- [x] Validar apertura/ejecución headless de la escena principal

Validación: workflow `Godot CI` run `33278173612` completado con éxito. Pasaron importación del proyecto, smoke test de `main.tscn` y tests bootstrap.

## Fase 1 — Core / Walking Prototype — COMPLETADA
- [x] Arquitectura de escena de mundo
- [x] Jugador CharacterBody2D
- [x] Movimiento 8 direcciones
- [x] Cámara suave
- [x] Colisiones
- [x] Y-sort
- [x] Interactable base
- [x] Test de lógica creada
- [x] Test de aceptación de escenas del walking prototype
- [x] CI final de aceptación completado con éxito

Implementación principal: commit `b0881d4983997b22f1678904d4cf3417a099f739`.
Validación de aceptación: commit `ae77e23a190c4cb7824eff0bce8c6cf672fb381f`.
Workflow de aceptación: `Godot CI` run `33280758441`, completado con `success`.

## Fase 2 — Items / Resource Loop — EN PROGRESO

Criterios de aceptación de fase:
- [x] `ItemData` tipado y data-driven.
- [x] Modelo de inventario independiente de UI.
- [x] Stacks, capacidad, añadir, eliminar y consultar cantidades.
- [x] `InventoryComponent` local integrado en el jugador, sin Autoload.
- [x] Al menos un item real definido como `.tres`.
- [x] Tests unitarios de la lógica de inventario.
- [ ] Recurso recolectable reutilizable mediante componente.
- [ ] Loot conectado al inventario del jugador.
- [ ] Herramienta/requisito mínimo para recolección donde aplique.
- [ ] Energía consumida por una acción de recurso.
- [ ] Feedback mínimo de recolección/inventario.
- [ ] Test de aceptación del loop completo de recursos.
- [ ] CI final de aceptación completado con éxito.

Primer bloque implementado en `f6d346a298910900785f19943bbf0680f33fde76`.
`Godot CI` run `33283192098` fue lanzado para validar este bloque; no cerrar la fase hasta completar el loop y confirmar el CI de aceptación final.

## Fase 3 — Crafting / Production Loop
RecipeData, estaciones, crafting, cofres y StorageNetwork.

## Fase 4 — Cementerio
Cadáveres, tumbas, preparación, entierro, rating y persistencia.

## Fase 5 — Simulación
Tiempo, día/noche, calendario, NPCs, navegación y rutinas.

## Fase 6 — RPG
Diálogo, relaciones, quests, economía y tecnologías.

## Fase 7 — Mundo
Pueblo, bosque, mina, interiores, exploración y secretos.

## Fase 8 — Polish
Arte, animaciones, shaders, partículas, audio, UX y optimización.
