# DEV MEMORY

Memoria operativa del proyecto. Este archivo debe actualizarse después de cada bloque significativo de trabajo para poder reanudar el desarrollo sin depender del historial del chat.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase completada más reciente: **Fase 2 — Items / Resource Loop**
- Fase activa: **Fase 3 — Crafting / Production Loop**
- Estado Fase 3: bloque 1 de crafting instantáneo implementado; falta StorageNetwork/cofres/colas antes de cerrar la fase.
- Fuente de verdad: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.

## Trabajo realizado — Fase 0

1. Bootstrap Godot 4.x, escena raíz, estructura y Autoloads mínimos.
2. InputMap, logging, panel debug, guardado versionado, tests y GitHub Actions.
3. Validación final: `Godot CI` run `33278173612` en `success`.

## Trabajo realizado — Fase 1

1. `world/world.tscn`, jugador `CharacterBody2D`, movimiento 8 direcciones y lógica pura `PlayerMovement`.
2. `Camera2D`, colisiones, Y-sort, `InteractionArea` e `Interactable` reutilizable.
3. `DebugSign` como interacción funcional.
4. Tests de movimiento y aceptación de escenas.
5. Implementación principal: `b0881d4983997b22f1678904d4cf3417a099f739`.
6. Validación de aceptación: `ae77e23a190c4cb7824eff0bce8c6cf672fb381f`.
7. `Godot CI` run `33280758441` completó con `success`.

## Trabajo realizado — Fase 2

1. `ItemData`, `InventoryStack`, `InventoryModel` e `InventoryComponent` local.
2. `EnergyComponent` y `ResourceSourceComponent` reutilizables.
3. `ResourceNode`, árbol recolectable, loot de madera y coste de energía.
4. Recolección atómica ante herramienta incorrecta, energía insuficiente o inventario lleno.
5. Tests de inventario e integración del resource loop.
6. Commit funcional final: `c196e3ab5a42adffe97278f0b0daa8960c789e04`.
7. `Godot CI` run `33285578050` completó con `success`.
8. Fase 2 cerrada tras cumplir todos sus criterios.

## Trabajo realizado — Fase 3, bloque 1

1. Se revisaron las secciones 19 (Crafting), 20 (StorageNetwork) y 23 (Energía) del master spec antes de implementar.
2. `ROADMAP.md` contiene criterios completos de Fase 3 y mantiene la fase abierta hasta StorageNetwork/colas/CI final.
3. Se creó `RecipeIngredient` como Resource tipado para representar item + cantidad.
4. Se creó `RecipeData` con id, estación, inputs, outputs, duración y coste de energía.
5. Se añadió `data/items/plank.tres` como primer recurso procesado.
6. Se añadió `data/recipes/wood_to_plank.tres`: 2 madera -> 1 tabla en `workbench`, coste 2 de energía.
7. Se creó `CraftingService` como lógica pura y testeable sin `Node`.
8. El crafting simula primero sobre una copia de `InventoryModel`; solo reemplaza el estado real cuando inputs y outputs caben completamente.
9. Se cubren rechazos atómicos por receta inválida, estación incorrecta, inputs insuficientes e inventario sin espacio.
10. Se creó `CraftingStation` contextual heredando de `Interactable`; no se añadió ningún Autoload nuevo.
11. Se creó `world/buildings/workbench.tscn` con feedback mínimo y se integró en `world/world.tscn`.
12. El coste de energía se cobra solo después de que `CraftingService` confirme éxito.
13. Se añadió `tests/test_crafting_foundation.gd`, incluyendo receta data-driven, atomicidad, estación incorrecta, inputs insuficientes, inventario lleno e interacción real jugador + banco.
14. `tests/run_tests.gd` ejecuta el test de crafting.
15. Commit funcional del bloque: `d284104ab8b9f300362413cd666bdab6b8855fbd`.
16. CI del bloque funcional: `Godot CI` run `33287832451` lanzado; validar su resultado antes de considerar este bloque confirmado.

## Decisiones tomadas

- Mantener solo cinco Autoloads globales.
- Inventario, energía, recursos, crafting, quests, cementerio y economía permanecen locales/contextuales.
- Datos de items y recetas viven como Resources `.tres` tipados.
- La UI no posee estado de gameplay.
- `CraftingService` es lógica pura y no conoce escenas ni UI.
- La atomicidad de crafting se garantiza simulando sobre un inventario clon antes de mutar el real.
- `CraftingStation` conoce la abstracción de crafting/inventario, no implementaciones futuras de cofres.
- StorageNetwork se implementará en el siguiente bloque para evitar acoplar el banco a un cofre concreto.
- Producción temporizada/colas se pospone al siguiente bloque arquitectónico; no se implementa automatización compleja.
- No entrar en Fase 4 mientras Fase 3 no cumpla todos sus criterios.

## Validaciones confirmadas

- Fases 0, 1 y 2 permanecen validadas en CI.
- El último CI previo a Fase 3 (`33285670732`) sobre el commit de documentación de Fase 2 terminó en `success`.
- La implementación de Fase 3 bloque 1 está persistida en `main`.
- Falta confirmar el resultado final del run `33287832451`; no marcar el bloque ni la fase como validados hasta que sea verde.

## Próximo bloque de trabajo — Fase 3

1. Revisar primero el resultado del `Godot CI` run `33287832451` y corregir cualquier fallo crítico.
2. Diseñar una interfaz/abstracción `StorageProvider` pequeña y testeable para inventarios compatibles.
3. Crear `StorageNetwork` contextual con `has_item`, `get_available_amount`, `consume`, `deposit` y `find_sources`.
4. Crear un cofre mínimo que exponga inventario mediante la misma abstracción.
5. Refactorizar `CraftingService`/estación para consumir inputs y depositar outputs mediante StorageNetwork sin conocer cofres concretos.
6. Añadir soporte de estado mínimo para duración/cola sin implementar automatización compleja.
7. Añadir tests unitarios y aceptación de estación + jugador + cofre.
8. Ejecutar CI final y mantener Fase 3 abierta hasta cumplir todos los criterios.

## Regla de continuidad

Al retomar el proyecto:

1. Leer primero este archivo.
2. Leer `ROADMAP.md`.
3. Consultar la sección de la fase activa en `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
4. Revisar el último CI antes de continuar.
5. Actualizar `DEV_MEMORY.md`, `ROADMAP.md` y `CHANGELOG.md` después de cada bloque significativo.
6. No asumir que una tarea está terminada si no figura aquí como validada.
