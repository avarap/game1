# DEV MEMORY

Memoria operativa del proyecto. Este archivo debe actualizarse después de cada bloque significativo de trabajo para poder reanudar el desarrollo sin depender del historial del chat.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase completada más reciente: **Fase 2 — Items / Resource Loop**
- Próxima fase: **Fase 3 — Crafting / Production Loop**
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

1. Se definieron criterios de aceptación explícitos en `ROADMAP.md`.
2. Se creó `ItemData` como `Resource` tipado.
3. Se creó `InventoryStack` y `InventoryModel` independientes de UI.
4. Se creó `InventoryComponent` local al jugador con 20 slots.
5. Se añadió `data/items/wood.tres`.
6. Se añadieron tests de inventario e integración.
7. Commit base: `f6d346a298910900785f19943bbf0680f33fde76`.
8. El primer CI detectó warnings de inferencia `Variant` tratados como errores.
9. Se corrigió con tipado explícito y `mini`/`maxi` en `2412414889c0a5d6e403c9178aede9b31fa045c5`.
10. `Godot CI` run `33283283684` pasó completo.

## Trabajo realizado — Fase 2, bloque 2

1. Se creó `EnergyComponent` local y reutilizable con gasto, restauración y señales.
2. Se creó `ResourceSourceComponent` como componente reutilizable para vida/cantidad, loot, coste de energía y herramienta requerida.
3. La recolección es atómica: si falta herramienta, energía o espacio de inventario no se consume energía ni se concede loot parcial.
4. Se añadió requisito mínimo de herramienta mediante `equipped_tool_id`; el jugador equipa `axe` como herramienta inicial de prueba.
5. Se añadió `ResourceNode` como `Interactable` que delega la lógica al componente de recurso.
6. Se añadió `world/resources/tree_resource.tscn` con loot `wood.tres`, 3 golpes, 2 unidades de madera por golpe y coste de 4 de energía.
7. El árbol se integró en `world/world.tscn` dentro del radio inicial de interacción del jugador.
8. Se añadió feedback local mediante `FeedbackLabel` para éxito, herramienta incorrecta, energía insuficiente, inventario lleno y agotamiento.
9. Se añadió `tests/test_resource_loop.gd` para validar el loop `harvest -> loot -> energy`, además de fallos por herramienta, energía e inventario lleno.
10. `tests/run_tests.gd` incluye el nuevo test de aceptación.
11. Commit funcional: `c196e3ab5a42adffe97278f0b0daa8960c789e04`.
12. `Godot CI` run `33285578050` completó con `success`: importación, smoke test de `main.tscn`, suite headless y limpieza.
13. Con todos los criterios de aceptación cumplidos, la **Fase 2 queda completada**.

## Decisiones tomadas

- Mantener solo cinco Autoloads globales.
- Inventario, energía, recursos, crafting, quests, cementerio y economía permanecen como sistemas locales/contextuales.
- `ItemData` usa `Resource` tipado y los items concretos viven como `.tres`.
- La UI no posee estado de gameplay.
- `InventoryModel` es reutilizable sin depender de `Node`.
- `ResourceSourceComponent` contiene la lógica de recolección; `ResourceNode` solo adapta interacción/feedback de escena.
- El requisito de herramienta de Fase 2 es deliberadamente mínimo; durabilidad, niveles y herramientas avanzadas se posponen hasta que su fase lo requiera.
- Mantener tipado explícito en lógica aritmética cuando Godot pueda inferir `Variant`.
- No implementar crafting dentro de Fase 2.

## Validaciones confirmadas

- Fases 0, 1 y 2 permanecen validadas en CI.
- `main.tscn` arranca en smoke test headless con el árbol recolectable presente.
- El jugador dispone localmente de `InventoryComponent` y `EnergyComponent`.
- La madera se concede al inventario y la energía baja de 100 a 96 en una recolección válida.
- Herramienta incorrecta, energía insuficiente e inventario lleno no alteran indebidamente inventario/energía.
- `Godot CI` run `33285578050` pasó sobre `c196e3ab5a42adffe97278f0b0daa8960c789e04`.

## Próximo bloque de trabajo — Fase 3

1. Leer la sección de crafting y `StorageNetwork` del master spec antes de escribir código.
2. Definir criterios de aceptación completos de Fase 3 en `ROADMAP.md`.
3. Crear `RecipeData` tipado y al menos una receta `.tres` mínima.
4. Diseñar lógica pura de crafting que valide inputs y outputs de forma atómica.
5. Crear una estación mínima contextual, sin Autoload.
6. Integrar la estación con inventarios compatibles sin acoplarla a UI.
7. Añadir tests unitarios y un test de aceptación del primer loop completo de crafting.
8. Mantener Fase 3 abierta hasta cumplir todos sus criterios y tener CI verde final.

## Regla de continuidad

Al retomar el proyecto:

1. Leer primero este archivo.
2. Leer `ROADMAP.md`.
3. Consultar la sección de la fase activa en `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
4. Revisar el último CI antes de continuar.
5. Actualizar `DEV_MEMORY.md`, `ROADMAP.md` y `CHANGELOG.md` después de cada bloque significativo.
6. No asumir que una tarea está terminada si no figura aquí como validada.
