# DEV MEMORY

Memoria operativa del proyecto. Este archivo debe actualizarse después de cada bloque significativo de trabajo para poder reanudar el desarrollo sin depender del historial del chat.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase activa: **Fase 0 — Bootstrap**
- Objetivo inmediato: validar el bootstrap en GitHub Actions y después iniciar Fase 1.
- Fuente de verdad: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.

## Trabajo realizado — 2026-08-30

1. Se localizó `avarap/game1`; estaba vacío.
2. Se inicializó la rama `main` con `README.md`.
3. Se añadió `project.godot` configurado para Godot 4.x.
4. Se configuró la escena principal `main.tscn`.
5. Se añadieron Autoloads: `EventBus`, `GameManager`, `TimeManager`, `SaveManager`, `AudioManager`.
6. Se configuró InputMap para movimiento, interacción, acciones, inventario, mapa, pausa y panel debug.
7. Se añadió logging mínimo con `GameLogger`.
8. Se añadió `TimeMath` como primera unidad de lógica pura y testeable.
9. Se creó un panel debug mínimo con tiempo, FPS, avance de hora y guardado de prueba.
10. Se añadió guardado JSON versionado mínimo con `save_version = 1`.
11. Se añadió un test headless para `TimeMath`.
12. Se añadió workflow de GitHub Actions con Godot CI 4.5 para importar/validar el proyecto y ejecutar tests.
13. Se añadieron `GAME_DESIGN.md`, `ARCHITECTURE.md`, `ROADMAP.md`, `CHANGELOG.md` y `.gitignore`.
14. Se dejó preparada la estructura lógica de carpetas mediante archivos reales y `.gitkeep` donde todavía no existe implementación.

## Decisiones tomadas

- Mantener solo cinco Autoloads globales.
- No convertir inventario, crafting, quests, cementerio o economía en Autoloads.
- Empezar con lógica pura testeable antes de introducir sistemas dependientes de escenas.
- Mantener el guardado versionado desde el primer día.
- Usar `barichello/godot-ci:4.5` en CI.
- No empezar Fase 1 hasta comprobar CI y arranque del proyecto.

## Pendiente inmediato

1. Confirmar que el workflow de GitHub Actions pasa.
2. Si falla, corregir errores de parseo/configuración antes de avanzar.
3. Marcar Fase 0 como completada solo cuando el proyecto arranque sin errores y los tests pasen.
4. Después iniciar Fase 1 con `CharacterBody2D`, movimiento 8-direccional, cámara, colisiones, Y-sort e `Interactable`.

## Regla de continuidad

Al retomar el proyecto, leer primero este archivo, después `ROADMAP.md` y finalmente la sección correspondiente del master spec. No asumir que una tarea está terminada si no figura aquí como validada.
