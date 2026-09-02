# ROADMAP

## Estado global

- Fases 0–7: **COMPLETADAS**.
- Fase 8 — Polish: **ACTIVA**.
- Runtime/CI contractual: **Godot 4.7.2**.
- Gate final: no declarar el vertical slice completo sin gates técnicos, jugables y visuales sobre el mismo estado integrado.
- #139 MAP y #140 PLAYER fueron fusionadas a `main` el 2026-09-02 antes de completar aceptación. **Merged != accepted**.

## Critical path actual

### 1. PLAYER — deuda de #140 ya presente en main

Origen canónico: PR #140 / `character/player-controller-polish-20260902`.

Estado: fusionado pero NO aceptado. El HEAD pre-merge tenía CI rojo y `main` mantiene generación procedural de frames en `PlayerVisual`, incompatible con el pixel-art gate.

Aceptación pendiente:
- CI completo verde: gdlint/gdformat, import, smoke y bootstrap;
- atlas/spritesheet authored y pixel-cleaned integrado con nearest filtering/pivots correctos;
- idle/walk/run/interact realmente distintos en 8 direcciones;
- run no reutiliza ni acelera walk;
- interact no cae a idle;
- colisiones e interacción direccional funcionales;
- evidencia gameplay real 1280x720 sobre el mapa reconstruido.

### 2. MAP — deuda de #139 ya presente en main

Origen canónico: PR #139 / `feat/main-map-rebuild-commercial-pass`.

Estado: fusionado con gate técnico pre-merge verde, pero gate visual REJECTED.

Aceptación pendiente:
- terreno/caminos authored sin banding/grid/repetición matemática;
- transiciones y path edges orgánicos y pixel-cleaned;
- landmarks claros para taller/cementerio/plaza;
- foreground/gameplay/background depth y Y-sort coherentes;
- navegación, colisiones e interacciones correctas;
- rendimiento adecuado;
- nueva captura real 1280x720 y crítica visual aceptada.

### 3. INTEGRATION — PR #138

Rama reservada: `automation/supervisor-player-map-integration`.

Estado actual: **PARKED/CLOSED**. No reabrirla solo porque #139/#140 estén merged: debe esperar a que las deudas de dominio anteriores satisfagan sus gates. Cuando ambos estados estén aceptados, reabrir la misma #138 y refrescar/reconstruir desde `main`; no abrir una PR de reemplazo.

#138 corrige exclusivamente regresiones cross-domain:
- cámara;
- escala;
- layers/Y-sort;
- spawn/traversal;
- navegación;
- colisiones;
- interacciones;
- rendimiento;
- capture tooling.

Aceptación: build integrado + suite + gameplay real + captura 1280x720 sin regresiones.

## Pipeline visual obligatorio

1. dirección artística/paleta/escala/perspectiva;
2. concepto/base generada si aporta valor;
3. limpieza pixel-art intencional;
4. ensamblaje en tilesets/spritesheets/familias de assets;
5. integración Godot con filtering/pivots/escala/capas/Y-sort/colisión/navegación;
6. captura in-game 1280x720;
7. crítica visual y revisión.

No aceptar imágenes conceptuales/generadas o sprites procedurales como assets finales sin pasar este pipeline.

## Sandbox Verdant

`world/maps/verdant_test/` es un sandbox visual deliberadamente aislado. No forma parte del world/save flow de producción.

## Branch policy

- No crear ramas/PR paralelas de MAP/PLAYER/INTEGRATION.
- Los refs stale históricos que reaparezcan no deben recibir pushes ni reapuntarse.
- La existencia de cleanup histórico no debe ocultar ni sustituir los gates técnicos/jugables/visuales actuales.
- Una PR merged sin evidencia de aceptación sigue generando deuda de producción.

## Documentación operativa

Fuentes vivas: `GAME1_RULES.md`, `.agents/skills/orchestrating-game-production/SKILL.md`, `DEV_MEMORY.md`, este `ROADMAP.md`, `CHANGELOG.md` y `README.md`.

## Después del critical path

Una vez reabierta e integrada #138 con evidencia aceptada:

- UI/UX final;
- audio final;
- estabilidad/export;
- optimización adicional;
- gate integral/release candidate.
