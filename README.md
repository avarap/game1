# game1

RPG 2D de gestión, crafting, exploración y simulación construido con **Godot 4.7.2 + GDScript**.

Objetivo: un vertical slice original, jugable y con calidad visual de videojuego indie comercial.

## Fuentes de verdad actuales

- Producción/orquestación: `GAME1_RULES.md`.
- Skill de proceso: `.agents/skills/orchestrating-game-production/SKILL.md`.
- Estado operativo: `DEV_MEMORY.md`.
- Plan: `ROADMAP.md`.
- Arquitectura/spec: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Diseño: `GAME_DESIGN.md`.
- Dirección visual: `ART_DIRECTION.md` + benchmarks en `docs/`.

## Estado

- Fases 0–7: completadas.
- Fase 8 — Polish: activa.
- Runtime/CI objetivo: Godot 4.7.2.
- El mapa principal antiguo está descartado y no puede reutilizarse en layout/composición/patrones/distribución/diseño espacial.
- CI verde es obligatorio donde aplique, pero nunca sustituye la evidencia jugable/visual.

## Workstreams canónicos

- **MAP #139** — `feat/main-map-rebuild-commercial-pass`.
- **PLAYER #140** — `character/player-controller-polish-20260902`.
- **INTEGRATION #138** — `automation/supervisor-player-map-integration`.

No abrir ramas o PR paralelas para estos dominios mientras exista su workstream canónico.

## Critical path

1. Llevar #139 a mapa nuevo authored, navegable, interactuable y visualmente creíble.
2. Llevar #140 a protagonista de calidad comercial con movimiento/animación/interacción reales.
3. Integrar ambos en #138 y resolver solo regresiones cross-domain.
4. Validar build, gameplay real y capturas/video 1280x720.
5. Solo entonces avanzar al gate final del vertical slice.

## Pipeline de pixel art

El arte de producción sigue un pipeline especializado:

1. dirección artística/paleta/escala/perspectiva;
2. concepto o base generada si ayuda;
3. limpieza pixel-art intencional;
4. ensamblaje en tilesets/spritesheets/familias de props;
5. integración Godot con filtering, pivots, escala, capas/Y-sort, colisión y navegación;
6. captura in-game 1280x720;
7. crítica visual y revisión.

Una imagen generada o conceptual no es un asset final hasta pasar estas etapas.

## Sandbox Verdant

`world/maps/verdant_test/` es un sandbox visual aislado. No forma parte del world/save flow de producción. Solo puede aportar técnicas o assets individuales si #139 los adopta explícitamente tras revisión.

## Ejecutar

1. Instala Godot 4.7.2.
2. Clona el repositorio.
3. Abre `project.godot`.
4. Ejecuta la escena principal con F5.

## Controles base

- Movimiento: WASD
- Interactuar: E
- Acción primaria/secundaria: ratón
- Inventario: I
- Mapa: M
- Pausa: Esc
- Panel debug: F12

## Quality gates

El CI y la revisión de producción exigen según aplique:

- `gdlint`;
- `gdformat --check`;
- Godot 4.7.2 import/validation;
- smoke launch;
- suite headless relevante/completa;
- movimiento/colisiones/interacciones reales;
- navegación/rendimiento;
- capturas/video reales para revisión visual.

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

## Branch cleanup

Una rama supersedida debe borrarse cuando no contenga trabajo único. Reapuntarla temporalmente al SHA canónico solo contiene la divergencia; no cuenta como limpieza final.
