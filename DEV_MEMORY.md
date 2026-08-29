# DEV MEMORY

Memoria operativa del proyecto. Este archivo debe actualizarse después de cada bloque significativo de trabajo para poder reanudar el desarrollo sin depender del historial del chat.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase completada más reciente: **Fase 1 — Core / Walking Prototype**
- Próxima fase: **Fase 2 — Items / Resource Loop**
- Objetivo inmediato de la próxima ejecución: analizar requisitos, dependencias y criterios de aceptación de Fase 2 antes de implementar `ItemData`, inventario y primer loop de recursos.
- Fuente de verdad: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.

## Trabajo realizado — Fase 0

1. Se inicializó el repositorio y `project.godot` para Godot 4.x.
2. Se configuró `main.tscn` como escena principal.
3. Se añadieron Autoloads: `EventBus`, `GameManager`, `TimeManager`, `SaveManager`, `AudioManager`.
4. Se configuró InputMap, logging mínimo, panel debug, guardado JSON versionado y tests headless.
5. Se añadió GitHub Actions con `barichello/godot-ci:4.5`.
6. Se añadieron documentación base, estructura del proyecto y el master spec.
7. La Fase 0 quedó validada por `Godot CI` run `33278173612` con importación, smoke test de `main.tscn` y tests en `success`.

## Trabajo realizado — Fase 1

1. Se creó `world/world.tscn` con composición base del mundo y Y-sort.
2. Se creó `player/player.tscn` con raíz `CharacterBody2D`.
3. Se implementó movimiento 8-direccional mediante `Input.get_vector`.
4. Se separó la lógica pura en `player/player_movement.gd` para poder testear aceleración, desaceleración y normalización de input.
5. Se añadió `Camera2D` con smoothing, zoom y límites del mapa.
6. Se añadieron colisiones exteriores y un obstáculo de prueba.
7. Se añadió `InteractionArea` al jugador.
8. Se creó `Interactable` reutilizable en `core/components/interactable.gd`.
9. Se añadió `DebugSign` como interactuable funcional de prueba.
10. Se añadieron tests de `PlayerMovement`.
11. Se añadió `tests/test_walking_prototype.gd` para validar la estructura real de las escenas: `CharacterBody2D`, cámara, límites, Y-sort, colisiones e `Interactable`.
12. El commit principal de implementación es `b0881d4983997b22f1678904d4cf3417a099f739`.
13. El commit de validación de aceptación es `ae77e23a190c4cb7824eff0bce8c6cf672fb381f`.
14. `Godot CI` run `33280758441` completó con `success` sobre el commit de aceptación.
15. La Fase 1 queda formalmente completada en `ROADMAP.md`.

## Validaciones confirmadas

- Godot importa el proyecto correctamente en modo headless.
- `main.tscn` arranca en smoke test headless.
- Los tests de bootstrap, tiempo, movimiento y walking prototype pasan.
- El jugador es un `CharacterBody2D` con movimiento 8-direccional independiente del framerate.
- La aceleración y desaceleración están aisladas en lógica testeable.
- La cámara tiene smoothing y límites válidos.
- El mundo usa Y-sort y contiene límites de colisión.
- Existe al menos un `Interactable` funcional dentro del mundo.
- El workflow CI real de GitHub Actions pasa con los criterios de aceptación de Fase 1.

## Decisiones tomadas

- Mantener solo cinco Autoloads globales.
- No convertir inventario, crafting, quests, cementerio o economía en Autoloads.
- Toda lógica que pueda vivir sin `Node` debe mantenerse testeable de forma aislada.
- Mantener guardado versionado desde el inicio.
- Mantener smoke test de la escena principal en cada push/PR a `main`.
- Usar validaciones de estructura de escenas además de tests de lógica pura para cerrar fases de gameplay.
- No avanzar de fase hasta confirmar CI real en GitHub Actions.

## Próximo bloque de trabajo — Fase 2

Antes de escribir código:

1. Leer la sección de items/inventario/recursos/energía del master spec.
2. Definir criterios de aceptación concretos para Fase 2.
3. Diseñar `ItemData` como `Resource` tipado y data-driven.
4. Diseñar un `InventoryComponent` local, no Autoload.
5. Definir operaciones puras testeables para stacks, capacidad y altas/bajas de items.
6. Añadir un recurso recolectable mínimo y feedback funcional.
7. Mantener el proyecto ejecutable y ampliar tests/CI.

No implementar crafting, cementerio, NPCs o sistemas de fases posteriores durante el primer bloque de Fase 2.

## Regla de continuidad

Al retomar el proyecto:

1. Leer primero este archivo.
2. Leer `ROADMAP.md`.
3. Consultar la sección de la fase activa en `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
4. Revisar el último CI antes de continuar.
5. Actualizar `DEV_MEMORY.md`, `ROADMAP.md` y `CHANGELOG.md` después de cada bloque significativo.
6. No asumir que una tarea está terminada si no figura aquí como validada.
