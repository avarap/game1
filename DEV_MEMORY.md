# DEV MEMORY

Memoria operativa actual de `avarap/game1`. Leer junto con `GAME1_RULES.md` y `.agents/skills/orchestrating-game-production/SKILL.md`.

## Estado actual

- Rama principal: `main`.
- Runtime/CI contractual: Godot 4.7.2.
- Fases 0–7: completadas.
- Fase 8 — Polish: activa.
- Calidad objetivo: vertical slice jugable con acabado indie comercial.
- El mapa principal antiguo está descartado y no puede reutilizarse en layout/composición/patrones/distribución/diseño espacial.
- #139 MAP y #140 PLAYER fueron fusionadas prematuramente el 2026-09-02. **Merged != accepted**.
- `main` sigue con CI rojo por deuda PLAYER: formatting + bootstrap. Import/smoke y captura visual funcionan.

## Gobernanza canónica

La identidad canónica es la rama, no el número de PR histórico.

- MAP — rama `feat/main-map-rebuild-commercial-pass`; #139 es histórico/merged. La rama se reutiliza para una única PR secuencial de remediación hasta aceptación.
- PLAYER — rama `character/player-controller-polish-20260902`; #140 es histórico/merged. La rama se reutiliza para una única PR secuencial de remediación hasta aceptación.
- INTEGRATION — rama `automation/supervisor-player-map-integration`; PR #138 permanece PARKED/CLOSED hasta aceptación real de MAP y PLAYER y luego se reabre la misma #138.

Reglas:
- máximo una rama canónica por dominio;
- máximo una PR abierta de implementación/remediación por dominio;
- no crear ramas paralelas;
- no usar #138 para terminar deuda propia de MAP/PLAYER;
- si una PR se fusiona antes de aceptación, mover la misma rama canónica a `main` y continuar mediante una única PR secuencial de remediación.

## Gates pendientes

### PLAYER

Prioridad nº1.

- `gdformat --check` debe quedar verde;
- bootstrap debe quedar verde, incluyendo las regresiones Verdant de harvest/energy/depletion/stump;
- retirar generación procedural de frames en `PlayerVisual`;
- integrar spritesheet/atlas authored y pixel-cleaned;
- idle/walk/run/interact distintos en 8 direcciones;
- run no reutiliza walk e interact no cae a idle;
- colisiones/interacción direccional reales;
- captura gameplay 1280x720 sobre el mapa reconstruido.

### MAP

- gate técnico debe mantenerse verde;
- terrain/path system authored y pixel-cleaned;
- eliminar grid/banding/repetición matemática y caminos ortogonales obvios;
- reforzar landmarks y foreground/gameplay/background depth/Y-sort;
- nueva captura real 1280x720 y crítica visual aceptada.

### INTEGRATION #138

No reabrir hasta aceptación real de PLAYER y MAP. Después: solo cámara, escala, Y-sort/layers, spawn/traversal, navegación, colisiones, interacciones, rendimiento, capture tooling y regresiones cross-domain.

## Branch cleanup

Los refs históricos stale comprobados en esta pasada estaban `ahead_by=0` respecto a `main`; no contenían trabajo único. Se han contenido apuntándolos a `main` porque el conector actual no expone borrado de refs. Esto sigue siendo cleanup físico incompleto hasta su eliminación remota, pero no vuelve a bloquear producción ni puede convertirse en workstream.

## Pipeline visual obligatorio

1. dirección artística/paleta/escala/perspectiva;
2. concepto/base;
3. limpieza pixel-art intencional;
4. ensamblaje en tilesets/spritesheets/familias;
5. integración Godot con filtering/pivots/escala/capas/Y-sort/colisión/navegación;
6. captura real 1280x720;
7. crítica/revisión.

## Fuentes de verdad

- Producción/orquestación: `GAME1_RULES.md` + `.agents/skills/orchestrating-game-production/SKILL.md`.
- Estado operativo: este archivo.
- Planificación: `ROADMAP.md`.
- Arquitectura/spec: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Diseño: `GAME_DESIGN.md`.
- Dirección visual: `ART_DIRECTION.md`.

## Prioridad inmediata

1. PLAYER remediation en su rama canónica: causa raíz -> formatting/bootstrap green -> atlas authored -> gameplay 1280x720.
2. MAP remediation en paralelo: visual pass authored -> capture -> critique.
3. Reabrir #138 únicamente cuando ambos dominios estén accepted.
