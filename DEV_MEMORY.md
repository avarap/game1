# DEV MEMORY

Memoria operativa del proyecto. Este archivo debe actualizarse después de cada bloque significativo de trabajo para poder reanudar el desarrollo sin depender del historial del chat.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase completada: **Fase 0 — Bootstrap**
- Próxima fase: **Fase 1 — Core / Walking Prototype**
- Objetivo inmediato: implementar jugador `CharacterBody2D`, movimiento 8 direcciones, cámara, colisiones, Y-sort e `Interactable` sin romper el bootstrap validado.
- Fuente de verdad: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.

## Trabajo realizado — 2026-08-30

1. Se localizó `avarap/game1`; estaba vacío.
2. Se inicializó la rama `main` con `README.md`.
3. Se añadió `project.godot` configurado para Godot 4.x.
4. Se configuró `main.tscn` como escena principal.
5. Se añadieron Autoloads: `EventBus`, `GameManager`, `TimeManager`, `SaveManager`, `AudioManager`.
6. Se configuró InputMap para movimiento, interacción, acciones, inventario, mapa, pausa y panel debug.
7. Se añadió logging mínimo con `GameLogger`.
8. Se añadió `TimeMath` como primera unidad de lógica pura y testeable.
9. Se creó un panel debug mínimo con tiempo, FPS, avance de hora y guardado de prueba.
10. Se añadió guardado JSON versionado mínimo con `save_version = 1`.
11. Se añadió un test headless para `TimeMath`.
12. Se añadió GitHub Actions con `barichello/godot-ci:4.5`.
13. Se añadieron `GAME_DESIGN.md`, `ARCHITECTURE.md`, `ROADMAP.md`, `CHANGELOG.md` y `.gitignore`.
14. Se creó la estructura lógica de carpetas del master spec, usando `.gitkeep` donde todavía no existe implementación.
15. Se añadió al repositorio el documento completo `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md` como fuente de verdad.
16. Se ejecutó el primer CI del bootstrap: importación del proyecto y tests pasaron.
17. Se endureció CI añadiendo un smoke test real de la escena principal con `godot --headless --path . --quit-after 3`.
18. Se ejecutó el workflow `Godot CI` run `33278173612` sobre el commit `746ea0b1e2dd7be95f5cb6a26548ba008c773620`.
19. La validación final pasó: inicialización del contenedor, checkout, importación/parseo, ejecución de `main.tscn`, tests bootstrap y limpieza finalizaron con `success`.
20. Se marcó la Fase 0 como completada en `ROADMAP.md`.

## Validaciones confirmadas

- Godot puede importar y validar el proyecto en modo headless.
- La escena principal arranca correctamente en smoke test headless.
- Los tests bootstrap pasan.
- El workflow CI real de GitHub Actions pasa.
- La estructura de carpetas y los cinco Autoloads están registrados.
- InputMap, logging y panel debug mínimo existen.

## Decisiones tomadas

- Mantener solo cinco Autoloads globales.
- No convertir inventario, crafting, quests, cementerio o economía en Autoloads.
- Empezar con lógica pura testeable antes de introducir sistemas dependientes de escenas.
- Mantener el guardado versionado desde el primer día.
- Usar `barichello/godot-ci:4.5` en CI.
- Mantener un smoke test de la escena principal en cada push/PR a `main`.
- No ampliar contenido fuera de la fase activa.

## Próximo bloque de trabajo — Fase 1

1. Crear `world/world.tscn` y composición base del mundo.
2. Crear `player/player.tscn` con `CharacterBody2D`.
3. Implementar movimiento 8-direccional mediante InputMap, independiente del FPS.
4. Añadir aceleración/desaceleración sin sobrecomplicar el controlador.
5. Añadir `Camera2D` con seguimiento suave y zoom configurable.
6. Añadir colisiones de prueba.
7. Configurar Y-sort correcto.
8. Crear `Interactable` base reutilizable.
9. Añadir al menos un objeto interactuable funcional.
10. Añadir tests de la lógica nueva y ampliar el smoke test si procede.
11. Ejecutar CI y no marcar Fase 1 completa hasta que todos sus criterios de aceptación pasen.

## Regla de continuidad

Al retomar el proyecto:

1. Leer primero este archivo.
2. Leer `ROADMAP.md`.
3. Consultar la sección de la fase activa en `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
4. Revisar el último CI antes de continuar.
5. Actualizar este archivo después de cada bloque significativo de cambios, incluyendo commits relevantes, pruebas ejecutadas, errores encontrados, correcciones y próximo paso.

No asumir que una tarea está terminada si no figura aquí como validada.
