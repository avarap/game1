# ROADMAP

## Estado global

- Fases 0–7: **COMPLETADAS**.
- Fase 8 — Polish: **ACTIVA**.
- Runtime/CI contractual: **Godot 4.7.2**.
- Gate final: no declarar el vertical slice completo sin gates técnicos, jugables y visuales sobre el mismo estado integrado.

## Critical path actual

### 1. MAP — PR #139

Rama canónica: `feat/main-map-rebuild-commercial-pass`.

Objetivo: reconstruir el mapa principal desde cero sin reutilizar layout/composición/patrones/distribución/diseño espacial antiguos.

Aceptación:
- composición authored y no procedural-looking;
- terreno/caminos/vegetación/props/landmarks con calidad comercial;
- navegación, colisiones e interacciones correctas;
- escala/capas/Y-sort coherentes;
- rendimiento adecuado;
- Godot import/smoke/tests/lint verdes;
- capturas/video reales 1280x720 revisados visualmente.

### 2. PLAYER — PR #140

Rama canónica: `character/player-controller-polish-20260902`.

Objetivo: protagonista de calidad comercial integrado en el mapa nuevo.

Aceptación:
- movimiento/facing fluidos y coherentes;
- idle/walk/run/interact reales;
- no aceptar run=walk acelerado como solución final;
- colisiones e interacción direccional funcionales;
- verificación sobre el mapa nuevo;
- Godot import/smoke/tests/lint verdes;
- evidencia jugable real.

### 3. INTEGRATION — PR #138

Rama canónica: `automation/supervisor-player-map-integration`.

No desarrolla features propias de mapa/personaje. Solo integra #139 + #140 y corrige regresiones cross-domain:
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

Para pixel art, seguir:

1. dirección artística/paleta/escala/perspectiva;
2. concepto/base generada si aporta valor;
3. limpieza pixel-art intencional;
4. ensamblaje en tilesets/spritesheets/familias de assets;
5. integración Godot con filtering/pivots/escala/capas/Y-sort/colisión/navegación;
6. captura in-game 1280x720;
7. crítica visual y revisión.

No aceptar imágenes conceptuales/generadas como assets finales sin pasar este pipeline.

## Sandbox Verdant

`world/maps/verdant_test/` es un sandbox visual deliberadamente aislado. No forma parte del world/save flow de producción. Solo puede aportar técnicas/assets individuales si #139 los adopta explícitamente tras revisión.

## Branch policy

- Un dominio = una rama canónica = una PR canónica.
- No abrir workstreams paralelos mientras exista la rama canónica.
- Las ramas supersedidas deben borrarse cuando el trabajo único haya sido portado o descartado.
- Reapuntar una rama supersedida al SHA canónico es contención temporal, no limpieza final.
- Si no existe tooling capaz de borrar el ref, registrar deuda de cleanup explícitamente.

## Documentación operativa

Fuentes vivas: `GAME1_RULES.md`, `.agents/skills/orchestrating-game-production/SKILL.md`, `DEV_MEMORY.md`, este `ROADMAP.md`, `CHANGELOG.md` y `README.md`.

No permitir que estas fuentes contradigan materialmente el estado real de `main` y las PR canónicas.

## Después del critical path

Una vez integrado #138 con evidencia aceptada:

- UI/UX final;
- audio final;
- estabilidad/export;
- optimización adicional;
- gate integral/release candidate.

Contenido post-MVP y automatización avanzada permanecen fuera del vertical slice hasta cerrar este critical path.
