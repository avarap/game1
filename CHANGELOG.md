# CHANGELOG

## Unreleased

### Added
- Bootstrap Godot 4.x, escena raíz, cinco Autoloads globales, InputMap, logging, debug, guardado versionado, tests y CI headless.
- Walking prototype con mundo base, `CharacterBody2D`, movimiento 8 direcciones, cámara, colisiones, Y-sort e interacción reutilizable.
- Sistema de items/inventario data-driven con `ItemData`, stacks, capacidad e `InventoryComponent` local.
- `EnergyComponent`, recursos recolectables, herramienta requerida, loot y feedback mínimo.
- `RecipeIngredient`, `RecipeData`, `CraftingService`, `CraftingStation` y `Workbench`.
- `StorageProvider`, `StorageNetwork` y `StorageChest` para crafting distribuido desacoplado de cofres concretos.
- `ProductionJob` y `ProductionQueue` para recetas temporizadas y colas mínimas.
- Test `test_production_queue.gd` para enqueue, progreso, finalización, almacenamiento bloqueado/reintento e integración con estación.
- `CorpseData` y `CorpseState` para datos, preparación por instancia y descomposición progresiva de cadáveres.
- `GraveRecord`, `CemeteryModel` y `CemeteryRatingConfig` para rating encapsulado/data-driven.
- `data/cemetery/default_rating.tres` con valores iniciales de lápida, valla y decoración.
- `CemeteryService` para recepción, preparación, entierro y mejoras sin introducir un nuevo Autoload.
- `CemeteryController` local al mundo y cuatro interactuables: recepción, preparación, entierro y mejora de tumba.
- Reconstrucción de cadáveres, tumbas, modelo y servicio desde snapshots serializados.
- Persistencia genérica de providers locales mediante el grupo `save_provider` en `SaveManager`.
- `test_cemetery_foundation.gd`, `test_cemetery_flow.gd`, `test_cemetery_persistence.gd` y `test_cemetery_gameplay.gd`.
- Instrumentación de suites headless y timeout de 30 segundos en CI para evitar bloqueos silenciosos.

### Changed
- El crafting instantáneo opera sobre `StorageNetwork` manteniendo compatibilidad con inventario individual.
- Las estaciones pueden descubrir storage por grupo o recibir providers explícitos para tests/alcances futuros.
- Las recetas con `duration_seconds > 0` consumen/reservan inputs al encolar y producen outputs al finalizar.
- `CraftingStation` conserva el flujo instantáneo y añade ejecución temporizada sin introducir nuevos Autoloads.
- La energía de producción temporizada se cobra una sola vez cuando el trabajo es aceptado.
- La contribución base de una tumba usa `CorpseData.burial_value`; las mejoras se calculan con configuración separada.
- La preparación mutable vive en `CorpseState.current_preparation_level`, evitando modificar `CorpseData` compartido.
- `SaveManager` mantiene el formato versionado y agrega/aplica estado de sistemas locales mediante una interfaz mínima de provider.
- Fase 4 — Cementerio queda completada y Fase 5 — Simulación pasa a ser la siguiente fase.

### Fixed
- Inferencias `Variant` incompatibles con el modo estricto de Godot 4.5 en inventario.
- Recolección y crafting evitan pérdida parcial de recursos mediante simulación/atomicidad.
- `CraftingStation` evita `get_tree()` cuando se ejecuta off-tree en tests.
- Producción temporizada no pierde outputs si el almacenamiento se llena al completar: el job queda en `awaiting_output` y reintenta el depósito.
- Se evita que preparar un cadáver modifique accidentalmente el `CorpseData` compartido por otras instancias.
- El test de persistencia de cementerio resuelve el Autoload real desde `/root/SaveManager` en ejecución `--script`, evitando el error de compilación por identificador no disponible.

### Validated
- Fase 0: `Godot CI` run `33278173612`, `success`.
- Fase 1: run `33280758441`, `success`.
- Fase 2: run `33285578050`, `success`.
- Fase 3 bloque 1 crafting: run `33287832451`, `success`.
- Fase 3 StorageNetwork: tras corregir el fallo off-tree detectado en `33290155936`, run `33290225076` finalizó en `success`.
- Fase 3 producción temporizada/colas: commit `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`, `success`.
- Fase 4 foundation: commit `6e2bdab525adcc3e3d0fe65714c7f725e43eef91`, run `33293105681`, `success`.
- Fase 4 flujo lógico: commit `c94bacac772f8f5a0075b972c56baeb86b37afa0`, run `33293544721`, `success`.
- Fase 4 cierre gameplay/persistencia: implementación `73e968a097c8b0107292d2958f7d61b7b5af21ff`; run diagnóstico `33294190219` localizó el fallo del test de Autoload; corrección `dc9b4adc2710a18f182bd4a04f676a3afc74c198` validada mediante `Godot CI` run `33294286014`, `success` con importación, smoke test, suite headless completa y cleanup.
