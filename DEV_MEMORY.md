# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase completada más reciente: **Fase 3 — Crafting / Production Loop**
- Fase activa: **Fase 4 — Cementerio**
- Estado Fase 4: foundation y flujo lógico recibir/preparar/enterrar/mejorar implementados y validados; faltan persistencia versionada e integración contextual/interactuable antes de cerrar.
- Fuente de verdad: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Último bloque funcional: `c94bacac772f8f5a0075b972c56baeb86b37afa0`.
- Última validación funcional: `Godot CI` run `33293544721`, `success`.

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

## Fase 4 — Cementerio

### Bloque 1 — Foundation pura y rating
1. Se releyeron las secciones de Cementerio y Cadáveres del master spec antes de implementar.
2. Se creó `CorpseData` como `Resource` tipado con `id`, `quality`, `decay`, `preparation_level` y `burial_value`.
3. Se creó `CorpseState` como lógica pura (`RefCounted`) con descomposición progresiva determinista, clamp 0..1 y snapshot serializable.
4. Se creó `CemeteryRatingConfig` como Resource tipado y `data/cemetery/default_rating.tres` con valores configurables de lápida, valla y decoración.
5. Se creó `GraveRecord` independiente de escenas/UI. La contribución base del cadáver usa `burial_value`; lápida, valla y decoraciones añaden puntos definidos en `CemeteryRatingConfig`.
6. Se creó `CemeteryModel` como agregador puro de tumbas con cálculo de rating y snapshot serializable.
7. Se añadió `test_cemetery_foundation.gd` para carga de configuración, decay, clamp, contribución de cadáver, mejoras, agregación y snapshot.
8. Commit funcional: `6e2bdab525adcc3e3d0fe65714c7f725e43eef91`.
9. `Godot CI` run `33293105681` terminó con `success`.

### Bloque 2 — Preparación, entierro y mejoras
1. `CorpseState` mantiene ahora `current_preparation_level` como estado de instancia; preparar un cadáver no muta el `CorpseData` compartido.
2. Se añadió `CorpseState.prepare(amount)` y el snapshot usa el nivel de preparación actual.
3. Se creó `CemeteryService` local/contextual, sin Autoload, para recibir cadáveres pendientes, evitar ids duplicados, preparar, enterrar y aplicar mejoras.
4. `bury_corpse()` crea un `GraveRecord`, lo registra en `CemeteryModel` y elimina el cadáver de pendientes.
5. `install_headstone()`, `install_fence()` y `add_decoration()` alteran exclusivamente el estado de `GraveRecord`; el rating continúa calculándose mediante `CemeteryRatingConfig`.
6. Se añadió `test_cemetery_flow.gd` para el flujo completo lógico: recibir -> preparar -> decay -> enterrar -> lápida -> valla -> decoración -> rating -> snapshot.
7. El test verifica además que la preparación no muta el Resource compartido, que ids duplicados se rechazan y que índices de tumba inválidos no mutan estado.
8. `tests/run_tests.gd` ejecuta la nueva suite.
9. Commit funcional del bloque: `c94bacac772f8f5a0075b972c56baeb86b37afa0`.
10. `Godot CI` run `33293544721` terminó con `success`: importación, smoke test de `main.tscn`, tests headless y limpieza.

## Decisiones vigentes

- Mantener solo cinco Autoloads globales.
- Inventario, energía, recursos, crafting, storage y cementerio deben ser locales/contextuales salvo necesidad demostrada.
- La UI observa modelos/servicios; no posee estado de gameplay.
- Items, recetas y datos de cementerio se representan mediante Resources tipados/data-driven.
- La lógica pura se mantiene fuera de `Node` cuando sea posible y debe tener tests headless.
- Operaciones que consumen recursos deben ser atómicas o conservar un estado recuperable explícito.
- `CorpseData` es configuración compartida; estado mutable como decay y preparación vive en `CorpseState`.
- `CorpseData.burial_value` representa la contribución base del cadáver; las mejoras de tumba usan configuración independiente. No introducir todavía fórmulas complejas de calidad/preparación sin gameplay que las justifique.
- No entrar en NPCs/calendario/quests/economía antes de sus fases salvo dependencias mínimas inevitables.

## Próximo bloque — Fase 4 Cementerio

1. Integrar snapshot/restauración de `CemeteryService` con persistencia versionada sin convertir cementerio en Autoload.
2. Añadir reconstrucción de cadáveres/tumbas desde datos persistidos con un catálogo explícito de `CorpseData`.
3. Añadir un componente o escena contextual mínima para exponer preparación, parcela de entierro y mejoras mediante interacción.
4. Añadir test de guardado -> carga -> recuperación de rating, cadáveres pendientes, preparación y mejoras.
5. Ejecutar CI final de Fase 4 y cerrarla solo si toda la aceptación queda cubierta.

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
