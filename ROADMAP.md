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

Validación: workflow `Godot CI` run `33278173612` completado con éxito.

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

Implementación principal: `b0881d4983997b22f1678904d4cf3417a099f739`.
Validación de aceptación: `ae77e23a190c4cb7824eff0bce8c6cf672fb381f`.
Workflow: `33280758441`, `success`.

## Fase 2 — Items / Resource Loop — COMPLETADA

Criterios de aceptación de fase:
- [x] `ItemData` tipado y data-driven.
- [x] Modelo de inventario independiente de UI.
- [x] Stacks, capacidad, añadir, eliminar y consultar cantidades.
- [x] `InventoryComponent` local integrado en el jugador, sin Autoload.
- [x] Al menos un item real definido como `.tres`.
- [x] Tests unitarios de la lógica de inventario.
- [x] CI verde para el bloque base de items/inventario.
- [x] Recurso recolectable reutilizable mediante componente.
- [x] Loot conectado al inventario del jugador.
- [x] Herramienta/requisito mínimo para recolección donde aplique.
- [x] Energía consumida por una acción de recurso.
- [x] Feedback mínimo de recolección/inventario.
- [x] Test de aceptación del loop completo de recursos.
- [x] CI final de aceptación completado con éxito.

Bloque base: `f6d346a298910900785f19943bbf0680f33fde76`.
Corrección de tipado estricto: `2412414889c0a5d6e403c9178aede9b31fa045c5`.
Validación del bloque base: `Godot CI` run `33283283684`, `success`.
Resource loop completo: `c196e3ab5a42adffe97278f0b0daa8960c789e04`.
Validación final de Fase 2: `Godot CI` run `33285578050`, `success`.

## Fase 3 — Crafting / Production Loop — SIGUIENTE
RecipeData, estaciones, crafting, cofres y StorageNetwork.

Criterios iniciales a definir antes de implementar:
- `RecipeData` tipado y data-driven.
- Una estación mínima funcional.
- Consumo de inputs y producción de outputs de forma atómica.
- Integración con inventarios compatibles sin acoplar la UI.
- Test de aceptación del primer loop de crafting.
- CI verde final antes de cerrar la fase.

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
