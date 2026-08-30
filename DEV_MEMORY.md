# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase completada más reciente: **Fase 3 — Crafting / Production Loop**
- Próxima fase: **Fase 4 — Cementerio**
- Fuente de verdad: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Último bloque funcional: `2252fcbd4280acec1e60530c026a8f5dd3365b91`.
- Última validación funcional: `Godot CI` run `33292481990`, `success`.

## Fases completadas

### Fase 0 — Bootstrap
- Godot 4.x, escena raíz, estructura y cinco Autoloads: `EventBus`, `GameManager`, `TimeManager`, `SaveManager`, `AudioManager`.
- InputMap, logging, panel debug, guardado versionado, tests y CI headless.
- Validación: run `33278173612`, `success`.

### Fase 1 — Core / Walking Prototype
- `world/world.tscn`, jugador `CharacterBody2D`, movimiento 8 direcciones con `PlayerMovement` puro.
- Cámara suave, límites, colisiones, Y-sort, `InteractionArea`, `Interactable` y `DebugSign`.
- Validación final: commit `ae77e23a190c4cb7824eff0bce8c6cf672fb381f`, run `33280758441`, `success`.

### Fase 2 — Items / Resource Loop
- `ItemData`, `InventoryStack`, `InventoryModel`, `InventoryComponent` local.
- `EnergyComponent`, `ResourceSourceComponent`, árbol recolectable, requisito de herramienta y loot.
- Recolección atómica ante herramienta incorrecta, energía insuficiente o inventario lleno.
- Implementación final: `c196e3ab5a42adffe97278f0b0daa8960c789e04`.
- Validación: run `33285578050`, `success`.

### Fase 3 — Crafting / Production Loop

#### Bloque 1 — Crafting instantáneo
- `RecipeIngredient` y `RecipeData` como Resources tipados.
- `plank.tres` y receta `wood_to_plank.tres`.
- `CraftingService` puro y crafting atómico.
- `CraftingStation`/`Workbench` local, feedback y coste de energía.
- Commit: `d284104ab8b9f300362413cd666bdab6b8855fbd`.
- Validación: run `33287832451`, `success`.

#### Bloque 2 — StorageNetwork
- `StorageProvider` y `StorageNetwork` con disponibilidad, consumo, depósito y búsqueda de fuentes.
- `StorageChest` compatible; estación desacoplada de cofres concretos.
- Crafting distribuido mantiene atomicidad clonando la red antes de aplicar cambios.
- Primer CI `33290155936` falló porque `CraftingStation` llamó `get_tree()` fuera del árbol durante tests.
- Corrección mediante `is_inside_tree()` y registro explícito de providers: `9f982b2e79e937449a5707f18287364bdec063b1`.
- Validación: run `33290225076`, `success`.

#### Bloque 3 — Producción temporizada y colas
- Se revisó el master spec: las estaciones deben soportar producción instantánea, temporizada y colas, dejando automatización compleja para futuro.
- Se creó `ProductionJob` con estado, tiempo transcurrido y progreso normalizado.
- Se creó `ProductionQueue` como lógica pura, sin `Node` ni UI.
- Al encolar una receta temporizada se validan y consumen/reservan los inputs de forma atómica.
- La salida no se produce hasta completar `duration_seconds`.
- Si al completar no hay espacio, el job pasa a `awaiting_output`; permanece en cola y puede reintentar el depósito sin perder materiales.
- `CraftingStation` soporta recetas instantáneas y temporizadas; la energía se cobra una sola vez cuando el job es aceptado.
- Se mantiene `StorageNetwork` como única abstracción de almacenamiento para inputs y outputs.
- Se añadió `test_production_queue.gd`: enqueue, progreso, finalización, inputs insuficientes, output bloqueado/reintento e integración jugador + banco.
- `tests/run_tests.gd` incluye la nueva suite.
- Commit funcional: `2252fcbd4280acec1e60530c026a8f5dd3365b91`.
- `Godot CI` run `33292481990` completó con `success`: inicialización, checkout, importación, smoke test de `main.tscn`, tests headless y limpieza.
- Con esto se cumplen todos los criterios de aceptación de Fase 3.

## Decisiones vigentes

- Mantener solo cinco Autoloads globales.
- Inventario, energía, recursos, crafting, storage y cementerio deben ser locales/contextuales salvo necesidad demostrada.
- La UI observa modelos/servicios; no posee estado de gameplay.
- Items, recetas y futuros datos de cementerio deben ser Resources tipados/data-driven.
- La lógica pura se mantiene fuera de `Node` cuando sea posible y debe tener tests headless.
- Operaciones que consumen recursos deben ser atómicas o conservar un estado recuperable explícito.
- No implementar automatización compleja de producción en el vertical slice inicial.
- No entrar en NPCs/calendario/quests/economía antes de sus fases salvo dependencias mínimas inevitables.

## Próximo bloque — Fase 4 Cementerio

1. Releer secciones 15 y 16 del master spec antes de escribir código.
2. Crear `CorpseData` tipado con `quality`, `decay`, `preparation_level` y `burial_value`.
3. Crear lógica pura mínima para decay y cálculo de contribución/valor de una tumba.
4. Encapsular rating del cementerio en un modelo/servicio configurable mediante datos.
5. Añadir tests unitarios antes de integrar escenas.
6. No implementar aún NPCs, calendario, quests, economía ni mapas adicionales.
7. Mantener Fase 4 abierta hasta completar entierro, mejoras básicas, persistencia mínima, aceptación y CI final.

## Regla de continuidad

Al retomar:
1. Leer este archivo.
2. Leer `ROADMAP.md`.
3. Consultar la fase activa en el master spec.
4. Revisar el último CI de `main`.
5. Implementar un bloque coherente y pequeño.
6. Ejecutar/verificar importación, smoke test y tests.
7. Corregir errores críticos antes de avanzar.
8. Actualizar `DEV_MEMORY.md`, `ROADMAP.md` y `CHANGELOG.md`.
9. No marcar una fase como completada hasta cumplir todos sus criterios.
