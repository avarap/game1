# DEV MEMORY

Memoria operativa del proyecto. Este archivo debe actualizarse después de cada bloque significativo de trabajo para poder reanudar el desarrollo sin depender del historial del chat.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase completada más reciente: **Fase 1 — Core / Walking Prototype**
- Fase activa: **Fase 2 — Items / Resource Loop**
- Estado Fase 2: bloque base de items/inventario implementado y validado; fase todavía no completada.
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

## Trabajo realizado — Fase 2, bloque 1

1. Se analizaron los requisitos del master spec para items, inventario, recursos, herramientas y energía antes de escribir código.
2. Se definieron criterios de aceptación explícitos en `ROADMAP.md` para evitar cerrar la fase solo con infraestructura.
3. Se creó `items/definitions/item_data.gd` como `Resource` tipado con id, nombre, descripción, categoría, stack, valor e icono.
4. Se creó `InventoryStack` como unidad de stack independiente de UI.
5. Se creó `InventoryModel` como lógica pura para capacidad por slots, stacking, altas, bajas, conteo, disponibilidad y limpieza.
6. Se creó `InventoryComponent` como componente local de escena; no es Autoload y envuelve el modelo mediante señales locales.
7. `player/player.tscn` ahora posee un `InventoryComponent` de 20 slots.
8. Se añadió `data/items/wood.tres` como primer item data-driven real.
9. Se añadió `tests/test_inventory_model.gd` para stacking, overflow, capacidad, remove, count y has_item.
10. Se añadió `tests/test_items_foundation.gd` para validar carga del `.tres` e integración local del inventario en el jugador.
11. `tests/run_tests.gd` ejecuta también los tests de Fase 2.
12. Commit del bloque: `f6d346a298910900785f19943bbf0680f33fde76`.
13. El primer CI (`33283192098`) falló porque el proyecto trata warnings de inferencia `Variant` como errores en `InventoryModel`.
14. Se corrigió el tipado usando enteros explícitos y `mini`/`maxi` en `2412414889c0a5d6e403c9178aede9b31fa045c5`.
15. `Godot CI` run `33283283684` pasó completo: importación, smoke test de `main.tscn`, suite headless y limpieza en `success`.

## Decisiones tomadas

- Mantener solo cinco Autoloads globales.
- Inventario, crafting, quests, cementerio y economía siguen siendo sistemas locales/contextuales.
- `ItemData` usa `Resource` tipado y los items concretos viven como `.tres`.
- La UI no será dueña del estado de inventario.
- `InventoryModel` es reutilizable por jugador, cofres, comerciantes, estaciones y loot sin depender de `Node`.
- El componente de inventario solo adapta lifecycle/señales de escena al modelo puro.
- Mantener tipado explícito en lógica aritmética cuando Godot pueda inferir `Variant`, porque CI trata warnings como errores.
- No implementar crafting ni fases posteriores durante Fase 2.
- No marcar Fase 2 como completada hasta tener recolección + loot + energía + feedback + test de aceptación + CI verde final.

## Validaciones confirmadas

- Fase 0 y Fase 1 permanecen validadas en CI.
- El bloque base de Fase 2 carga y compila correctamente en Godot 4.5 headless.
- `main.tscn` sigue arrancando en smoke test.
- Los tests de `InventoryModel` y de integración del `InventoryComponent` pasan.
- El recurso `data/items/wood.tres` carga como `ItemData` real.
- `Godot CI` run `33283283684` completó con `success` sobre `2412414889c0a5d6e403c9178aede9b31fa045c5`.

## Próximo bloque de trabajo — Fase 2

1. Crear `ResourceSourceComponent` reutilizable con vida/cantidad y loot definidos mediante datos.
2. Añadir un recurso mínimo recolectable al mundo, inicialmente madera/árbol de prueba.
3. Conectar la recompensa al `InventoryComponent` del jugador sin acoplar el nodo de recurso a una UI.
4. Añadir un `EnergyComponent` local mínimo y consumir energía en la acción de recolección.
5. Dar feedback funcional mínimo de éxito, inventario lleno y energía insuficiente.
6. Añadir tests de lógica y escena para el primer loop completo `interactuar -> consumir energía -> recibir recurso`.
7. Mantener la fase abierta hasta cumplir todos los criterios de `ROADMAP.md`.

## Regla de continuidad

Al retomar el proyecto:

1. Leer primero este archivo.
2. Leer `ROADMAP.md`.
3. Consultar la sección de la fase activa en `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
4. Revisar el último CI antes de continuar.
5. Actualizar `DEV_MEMORY.md`, `ROADMAP.md` y `CHANGELOG.md` después de cada bloque significativo.
6. No asumir que una tarea está terminada si no figura aquí como validada.
