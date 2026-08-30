# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase completada más reciente: **Fase 4 — Cementerio**
- Próxima fase: **Fase 5 — Simulación**
- Fuente de verdad: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Último bloque funcional: `dc9b4adc2710a18f182bd4a04f676a3afc74c198`.
- Última validación funcional: `Godot CI` run `33294286014`, `success`.

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
- `RecipeIngredient`, `RecipeData`, `CraftingService`, `CraftingStation` y banco de trabajo.
- `StorageProvider`, `StorageNetwork`, `StorageChest` y crafting distribuido.
- `ProductionJob`/`ProductionQueue` para producción temporizada, colas y output pendiente recuperable.
- Validación final: commit `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`, `success`.

### Fase 4 — Cementerio

#### Bloque 1 — Foundation pura y rating
- `CorpseData` tipado con calidad, decay, preparación y valor base de entierro.
- `CorpseState` con decay determinista y estado mutable por instancia.
- `CemeteryRatingConfig`, `GraveRecord` y `CemeteryModel` independientes de UI.
- `data/cemetery/default_rating.tres` con puntos data-driven para lápida, valla y decoración.
- Test `test_cemetery_foundation.gd`.
- Commit funcional: `6e2bdab525adcc3e3d0fe65714c7f725e43eef91`.
- Validación: run `33293105681`, `success`.

#### Bloque 2 — Flujo lógico
- `CemeteryService` gestiona cadáveres pendientes, preparación, entierro y mejoras.
- La preparación mutable se mantiene en `CorpseState.current_preparation_level`, sin modificar el `Resource` compartido.
- `test_cemetery_flow.gd` cubre recibir -> preparar -> decay -> enterrar -> lápida -> valla -> decoración -> rating -> snapshot.
- Commit funcional: `c94bacac772f8f5a0075b972c56baeb86b37afa0`.
- Validación: run `33293544721`, `success`.

#### Bloque 3 — Gameplay y persistencia; cierre de fase
1. `CorpseState`, `GraveRecord`, `CemeteryModel` y `CemeteryService` pueden reconstruirse desde snapshots serializados.
2. Los snapshots conservan id, calidad, decay, velocidad de decay, preparación, valor de entierro y mejoras de tumba.
3. `SaveManager` conserva `save_version = 1` y ahora agrega/aplica estado de providers locales mediante el grupo `save_provider` y los métodos `get_save_key`, `get_save_data` y `apply_save_data`.
4. `CemeteryController` es local al mundo y expone el estado de cementerio a `SaveManager` sin crear nuevos Autoloads.
5. Se añadieron cuatro interactuables de gameplay en `world/world.tscn`: `CorpseDelivery`, `PreparationTable`, `GravePlot` y `GraveUpgrade`.
6. El flujo puede ejecutarse con interacción contextual: recibir cadáver -> preparar -> enterrar -> instalar lápida -> instalar valla -> añadir decoración.
7. `test_cemetery_persistence.gd` valida round-trip de snapshot y guardado JSON versionado mediante el Autoload real de `SaveManager`.
8. `test_cemetery_gameplay.gd` valida los cuatro interactuables del mundo y el rating resultante.
9. Se instrumentó el runner de tests y se añadió timeout de 30 segundos al paso headless de CI para evitar jobs bloqueados sin diagnóstico.
10. Primer run de diagnóstico `33294190219`: importación y smoke test pasaron; detectó que el test referenciaba `SaveManager` como identificador estático bajo `--script` y finalizó por timeout.
11. Corrección: resolver el singleton mediante `/root/SaveManager` en el test, manteniendo el Autoload real como objeto bajo prueba.
12. Commit corregido: `dc9b4adc2710a18f182bd4a04f676a3afc74c198`.
13. Validación final de Fase 4: `Godot CI` run `33294286014`, `success` en importación, smoke test, todas las suites headless y cleanup.
14. Todos los criterios de aceptación de Fase 4 quedan cumplidos.

## Decisiones vigentes

- Mantener solo cinco Autoloads globales.
- Inventario, energía, recursos, crafting, storage, cementerio y futuros sistemas de NPCs deben ser locales/contextuales salvo necesidad demostrada.
- La UI observa modelos/servicios; no posee estado de gameplay.
- Items, recetas y datos de cementerio se representan mediante Resources tipados/data-driven.
- La lógica pura se mantiene fuera de `Node` cuando sea posible y debe tener tests headless.
- Operaciones que consumen recursos deben ser atómicas o conservar un estado recuperable explícito.
- El estado local persistente se integra mediante providers registrados en `save_provider`, evitando acoplar `SaveManager` a sistemas concretos.
- `CorpseData.burial_value` representa la contribución base del cadáver; las mejoras de tumba usan configuración independiente.
- Mantener timeout explícito en la suite CI para evitar jobs headless bloqueados y facilitar diagnóstico.
- No entrar en diálogo, relaciones, quests, economía ni tecnologías hasta Fase 6.

## Próximo bloque — Fase 5 Simulación

1. Releer las secciones de tiempo/calendario, ciclo día-noche y NPCs del master spec.
2. Consolidar `TimeManager` como única fuente de reloj/día/calendario, manteniendo compatibilidad con guardado actual.
3. Crear lógica testeable de avance de días y calendario antes de efectos visuales.
4. Implementar dormir como transición al siguiente día y restauración de energía.
5. Añadir un ciclo día/noche mínimo observable sin entrar todavía en polish.
6. Después crear `NPCData` y un primer NPC con `NavigationAgent2D` y rutina mínima.
7. Mantener Fase 5 abierta hasta horarios, estados básicos, persistencia y CI final verde.

## Regla de continuidad

Al retomar:
1. Leer este archivo.
2. Leer `ROADMAP.md`.
3. Consultar la fase activa en el master spec.
4. Revisar el último CI de `main`.
5. Implementar un bloque coherente y pequeño.
6. Ejecutar/verificar importación, smoke test y tests.
7. Corregir errores críticos antes de avanzar.
8. Actualizar `DEV_MEMORY.md`, `ROADMAP.md`, `CHANGELOG.md` y el estado resumido del `README.md` cuando cambie de fase.
9. No marcar una fase como completada hasta cumplir todos sus criterios.
