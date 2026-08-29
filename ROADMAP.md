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

## Fase 1 — Core / Walking Prototype — VALIDACIÓN FINAL
- [x] Arquitectura de escena de mundo
- [x] Jugador CharacterBody2D
- [x] Movimiento 8 direcciones
- [x] Cámara suave
- [x] Colisiones
- [x] Y-sort
- [x] Interactable base
- [x] Test de lógica creada
- [x] Test de aceptación de escenas del walking prototype
- [ ] CI final de aceptación completado con éxito

Implementación principal: commit `b0881d4983997b22f1678904d4cf3417a099f739`.
Validación de aceptación añadida: commit `ae77e23a190c4cb7824eff0bce8c6cf672fb381f`.
No avanzar a Fase 2 hasta que el CI de aceptación sea `success`.

## Fase 2 — Items / Resource Loop
ItemData, inventario, recursos, herramientas, loot, energía y UI.

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
