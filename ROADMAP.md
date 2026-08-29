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

## Fase 1 — Core / Walking Prototype — SIGUIENTE
- [ ] Arquitectura de escena de mundo
- [ ] Jugador CharacterBody2D
- [ ] Movimiento 8 direcciones
- [ ] Cámara suave
- [ ] Colisiones
- [ ] Y-sort
- [ ] Interactable base
- [ ] Test de lógica creada

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
