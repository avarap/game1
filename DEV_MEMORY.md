# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase completada más reciente: **Fase 3 — Crafting / Production Loop**
- Fase activa: **Fase 4 — Cementerio**
- Estado Fase 4: foundation pura/testeable implementada y validada; falta flujo contextual de preparación/entierro, mejoras jugables y persistencia antes de cerrar.
- Fuente de verdad: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Último bloque funcional: `6e2bdab525adcc3e3d0fe65714c7f725e43eef91`.
- Última validación funcional: `Godot CI` run `33293105681`, `success`.

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
8. `tests/run_tests.gd` ejecuta la nueva suite.
9. Commit funcional del bloque: `6e2bdab525adcc3e3d0fe65714c7f725e43eef91`.
10. `Godot CI` run `33293105681` terminó con `success`: importación, smoke test de `main.tscn`, suite headless y limpieza.

## Decisiones vigentes

- Mantener solo cinco Autoloads globales.
- Inventario, energía, recursos, crafting, storage y cementerio deben ser locales/contextuales salvo necesidad demostrada.
- La UI observa modelos/servicios; no posee estado de gameplay.
- Items, recetas y datos de cementerio se representan mediante Resources tipados/data-driven.
- La lógica pura se mantiene fuera de `Node` cuando sea posible y debe tener tests headless.
- Operaciones que consumen recursos deben ser atómicas o conservar un estado recuperable explícito.
- `CorpseData.burial_value` representa la contribución base del cadáver; las mejoras de tumba usan configuración independiente. No introducir todavía fórmulas complejas de calidad/preparación sin gameplay que las justifique.
- No entrar en NPCs/calendario/quests/economía antes de sus fases salvo dependencias mínimas inevitables.

## Próximo bloque — Fase 4 Cementerio

1. Crear una operación contextual para preparar un cadáver sin introducir NPCs/calendario.
2. Crear un plot/tumba interactuable o servicio local que permita enterrar un `CorpseState` y registrarlo en `CemeteryModel`.
3. Añadir mejoras básicas de lápida y valla mediante datos/estado, evitando lógica dispersa en escenas.
4. Probar el flujo preparar -> enterrar -> mejorar -> recalcular rating.
5. Después integrar persistencia mínima compatible con el guardado versionado.
6. Mantener Fase 4 abierta hasta test de aceptación completo y CI final verde.

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
