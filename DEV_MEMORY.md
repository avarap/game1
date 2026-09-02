# DEV MEMORY

Memoria operativa actual del proyecto `avarap/game1`. Leer junto con `GAME1_RULES.md` y `.agents/skills/orchestrating-game-production/SKILL.md` antes de continuar.

## Estado actual

- Rama principal: `main`.
- Runtime/CI objetivo: Godot 4.7.2.
- Fases 0–7: completadas.
- Fase 8 — Polish: activa.
- El mapa principal antiguo está descartado y no puede reutilizarse en layout, composición, patrones, distribución ni diseño espacial.
- Calidad objetivo: vertical slice jugable con acabado indie comercial; CI verde no sustituye evidencia jugable/visual.
- El 2026-09-02 las PR #139 MAP y #140 PLAYER fueron fusionadas a `main` antes de superar sus gates de aceptación. **Merged no significa accepted**.

## Gobernanza canónica

Workstreams autorizados para el foco actual:

- MAP — PR histórica/canónica #139 — `feat/main-map-rebuild-commercial-pass` — merged, gate visual pendiente.
- PLAYER — PR histórica/canónica #140 — `character/player-controller-polish-20260902` — merged, gates técnico/gameplay/visual pendientes.
- INTEGRATION — PR #138 — `automation/supervisor-player-map-integration` — aparcada/cerrada hasta que el estado integrado de MAP y PLAYER satisfaga sus gates; debe reabrirse la misma PR para integración final, no crearse otra.

No crear ramas/PR paralelas para estos dominios. #138 es solo integración cross-domain y no debe absorber deuda de implementación propia de MAP o PLAYER.

## Estado de gates al 2026-09-02

- MAP/#139: fusionada. Su HEAD pre-merge tenía CI verde y captura real 1280x720, pero la revisión visual seguía REJECTED por banding/grid de 32 px, terreno repetitivo, caminos ortogonales, props/graves alineados y débil profundidad/landmarks. `art/environment/cemetery/production/atlas/terrain_ground_paths_32.png` sigue ausente en `main`.
- PLAYER/#140: fusionada pese a CI rojo en su HEAD pre-merge. `main` conserva `PlayerVisual._build_production_animations()` / `_render_frame(...)`, es decir, generación procedural de frames rechazada por el pixel-art gate. No existe evidencia aceptada de atlas authored/pixel-cleaned + idle/walk/run/interact distintos en 8 direcciones + gameplay 1280x720.
- INTEGRATION/#138: cerrada/aparcada. No reabrir hasta que las deudas de dominio anteriores estén realmente verificadas.
- `main` integrado necesita CI de push + verificación jugable/visual; la ausencia de status en un merge commit no equivale a green.

## Branch cleanup

Las ramas supersedidas no se consideran limpias por apuntar al mismo SHA. La limpieza final requiere borrar el ref remoto cuando no exista trabajo único pendiente.

Los refs stale que se habían dado por eliminados vuelven a aparecer en la API de GitHub; tratarlos como deuda de higiene y evitar cualquier push/repoint. No congelar el progreso exclusivamente por cleanup histórico, pero tampoco permitir que vuelvan a convertirse en workstreams.

## Sandbox Verdant

`world/maps/verdant_test/` es un sandbox visual aislado. No es el mapa principal de producción y no debe registrarse en el world/save flow salvo promoción explícita después de revisión.

## Pipeline visual obligatorio

Para pixel art:

1. dirección artística/paleta/escala/perspectiva;
2. concepto o base generada cuando ayude;
3. limpieza pixel-art intencional;
4. ensamblaje en tilesets/spritesheets/familias de props;
5. integración Godot con filtering, pivots, escala, capas/Y-sort, colisión y navegación;
6. captura real 1280x720;
7. crítica visual y nueva iteración.

Arte conceptual/generado nunca equivale a asset de producción aceptado.

## Gates

Antes de aceptación exigir según aplique:

- gdlint/gdformat;
- import Godot 4.7.2;
- smoke launch;
- tests relevantes/bootstrap;
- movimiento/colisiones/interacciones reales;
- navegación y rendimiento;
- capturas/video reales;
- revisión visual contra el quality bar.

## Fuentes de verdad

- Producción/orquestación: `GAME1_RULES.md` + `.agents/skills/orchestrating-game-production/SKILL.md`.
- Arquitectura/spec: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Diseño: `GAME_DESIGN.md`.
- Planificación: `ROADMAP.md` + PR/issues canónicas.
- Dirección visual: `ART_DIRECTION.md` y benchmarks en `docs/`, sujetos a los gates actuales.
- Narrativa: `HISTORIA_PRINCIPAL.md`.
- Idiomas: `LOCALIZATION.md`.

## Prioridad inmediata

1. Verificar el estado combinado actual de `main` con CI completo; no asumir aceptación por los merges.
2. Resolver PLAYER: CI + atlas authored/pixel-cleaned + animaciones 8-dir reales + gameplay 1280x720.
3. Resolver MAP: terrain/path system authored, eliminar grid/repetición, landmarks/depth y recaptura 1280x720.
4. Reabrir/refrescar #138 solo después de aceptación real de ambos dominios.
5. Producir evidencia jugable/visual integrada final antes de declarar completado el slice.
