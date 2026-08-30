# DEV MEMORY

Memoria operativa del proyecto. Este archivo debe actualizarse después de cada bloque significativo de trabajo para poder reanudar el desarrollo sin depender del historial del chat.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase completada más reciente: **Fase 2 — Items / Resource Loop**
- Fase activa: **Fase 3 — Crafting / Production Loop**
- Estado Fase 3: crafting instantáneo y StorageNetwork/cofre implementados y validados; falta soporte mínimo de duración/cola antes de cerrar la fase.
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
16. `Godot CI` run `33287832451` completó con `success`: importación, smoke test de `main.tscn`, suite headless y limpieza.

## Trabajo realizado — Fase 3, bloque 2

1. Se creó `StorageProvider` como adaptador pequeño sobre `InventoryModel`, con disponibilidad, consumo, depósito, clonación y aplicación de estado.
2. Se creó `StorageNetwork` contextual con `has_item`, `get_available_amount`, `consume`, `deposit`, `find_sources`, clonación y commit de estado.
3. `CraftingService` mantiene el método previo `craft()` por compatibilidad, pero internamente delega en `craft_with_storage()` y trabaja contra `StorageNetwork`.
4. El crafting distribuido mantiene atomicidad clonando toda la red antes de consumir inputs y depositar outputs.
5. Se creó `StorageChest` con `InventoryComponent` local y `get_storage_provider()`, sin convertir almacenamiento en Autoload.
6. Se creó `world/storage/storage_chest.tscn`, marcado con grupo `storage_provider`, y se integró un cofre en `world/world.tscn` junto al banco.
7. `CraftingStation` construye una red con el inventario del actor y proveedores compatibles; en juego descubre nodos del grupo mediante la abstracción `get_storage_provider()` y no conoce la clase concreta del cofre.
8. Se añadió registro explícito de `StorageProvider` en `CraftingStation` para tests y futuros alcances por zona/distancia sin requerir árbol de escenas.
9. Se añadió `tests/test_storage_network.gd` con agregación de disponibilidad, `find_sources`, consumo distribuido, rechazo sin mutación e integración banco + jugador + cofre.
10. `tests/run_tests.gd` incluye el nuevo test.
11. Commit funcional inicial: `c7c3696a0fef2b1b3d4fee62027c9f85f0fe0ba3`.
12. Primer CI del bloque: `33290155936` falló únicamente en tests porque `CraftingStation` llamaba `get_tree()` estando fuera del árbol durante tests; importación y smoke test sí pasaron.
13. Se corrigió el fallo usando `is_inside_tree()` y proveedores registrados explícitamente para ejecución off-tree.
14. Commit de corrección: `9f982b2e79e937449a5707f18287364bdec063b1`.
15. `Godot CI` run `33290225076` completó con `success`: importación, smoke test y suite headless pasan.

## Decisiones tomadas

- Mantener solo cinco Autoloads globales.
- Inventario, energía, recursos, crafting, storage, quests, cementerio y economía permanecen locales/contextuales.
- Datos de items y recetas viven como Resources `.tres` tipados.
- La UI no posee estado de gameplay.
- `CraftingService` es lógica pura y no conoce escenas ni UI.
- La atomicidad de crafting se garantiza simulando sobre una copia antes de mutar el estado real.
- `CraftingStation` conoce `StorageNetwork`/`StorageProvider`, no implementaciones concretas de cofres.
- Los proveedores de almacenamiento pueden descubrirse por grupo cuando la estación está en el árbol o registrarse explícitamente; esto deja abierto alcance por zona/distancia sin acoplamiento.
- Producción temporizada/colas se mantiene como último bloque de Fase 3; no implementar automatización compleja.
- No entrar en Fase 4 mientras Fase 3 no cumpla todos sus criterios.

## Validaciones confirmadas

- Fases 0, 1 y 2 permanecen validadas en CI.
- Bloque 1 de Fase 3 validado por `Godot CI` run `33287832451`.
- Bloque 2 de StorageNetwork validado por `Godot CI` run `33290225076` sobre `9f982b2e79e937449a5707f18287364bdec063b1`.
- Importación, smoke test de `main.tscn` y todos los tests headless pasan con cofre y crafting distribuido integrados.
- El fallo de `33290155936` quedó identificado y corregido; no quedan errores críticos conocidos de este bloque.
- Fase 3 permanece abierta deliberadamente: soporte mínimo de duración/cola y CI final siguen pendientes.

## Próximo bloque de trabajo — Fase 3

1. Definir un estado de trabajo/cola pequeño y testeable para recetas con `duration > 0`.
2. Permitir encolar una receta validando y reservando/consumiendo inputs de forma atómica sin crear automatización compleja.
3. Exponer progreso/estado suficiente para que una estación pueda completar una tarea temporizada y depositar outputs mediante `StorageNetwork`.
4. Mantener crafting instantáneo (`duration <= 0`) funcionando sin regresiones.
5. Añadir tests de cola, progreso, finalización y casos de almacenamiento lleno.
6. Ejecutar CI final de Fase 3.
7. Solo si todos los criterios quedan verdes, marcar Fase 3 como completada y habilitar Fase 4.

## Regla de continuidad

Al retomar el proyecto:

1. Leer primero este archivo.
2. Leer `ROADMAP.md`.
3. Consultar la sección de la fase activa en `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
4. Revisar el último CI antes de continuar.
5. Actualizar `DEV_MEMORY.md`, `ROADMAP.md` y `CHANGELOG.md` después de cada bloque significativo.
6. No asumir que una tarea está terminada si no figura aquí como validada.
