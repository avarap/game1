# DEV MEMORY

Memoria operativa actual del proyecto `avarap/game1`. Leer junto con `GAME1_RULES.md` y `.agents/skills/orchestrating-game-production/SKILL.md` antes de continuar.

## Estado actual

- Rama principal: `main`.
- Runtime/CI objetivo: Godot 4.7.2.
- Fases 0–7: completadas.
- Fase 8 — Polish: activa.
- El mapa principal antiguo está descartado y no puede reutilizarse en layout, composición, patrones, distribución ni diseño espacial.
- Calidad objetivo: vertical slice jugable con acabado indie comercial; CI verde no sustituye evidencia jugable/visual.

## Gobernanza canónica

Solo existen tres workstreams autorizados para el foco actual:

- MAP — PR #139 — `feat/main-map-rebuild-commercial-pass`.
- PLAYER — PR #140 — `character/player-controller-polish-20260902`.
- INTEGRATION — PR #138 — `automation/supervisor-player-map-integration` — actualmente aparcada/cerrada hasta que #139 y #140 pasen sus gates; debe reabrirse la misma PR para integración final, no crearse otra.

No crear ramas/PR paralelas para estos dominios. #138 es solo integración cross-domain.

## Estado de PRs al 2026-09-02

- #139 MAP: abierta/draft. Rebuild completo del mapa desde cero; exige navegación/colisiones/interacciones, CI verde y evidencia real 1280x720. Debe eliminar repetición/proceduralidad visible y alcanzar composición authored de calidad comercial.
- #140 PLAYER: abierta/draft. Movimiento/facing/interacción y animaciones comerciales; no aceptar `run` como simple walk acelerado ni `interact` degradado a idle como solución final. Debe verificarse sobre el mapa nuevo.
- #138 INTEGRATION: cerrada/aparcada. Su diff histórico contiene implementación directa de MAP/PLAYER, por lo que no debe permanecer como superficie activa mientras los dominios no estén aceptados. Cuando #139/#140 estén listas, reabrir #138 y refrescar/reconstruir desde el estado canónico aceptado, conservando solo fixes cross-domain.

Los PR de dominio deben sincronizarse con `main` antes de aceptación; si GitHub marca `mergeable=false`, tratarlo como bloqueo de integración hasta resolver la causa.

## Branch cleanup

Las ramas supersedidas no se consideran limpias por apuntar al mismo SHA. La limpieza final requiere borrar el ref remoto cuando no exista trabajo único pendiente.

Mientras la herramienta actual no permita borrar refs, pueden repuntarse temporalmente al head canónico para eliminar divergencia, pero ese estado debe registrarse como **cleanup incompleto** y no como rama eliminada.

No volver a trabajar sobre ramas supersedidas.

## Sandbox Verdant

`world/maps/verdant_test/` es un sandbox visual aislado. No es el mapa principal de producción y no debe registrarse en el world/save flow salvo promoción explícita a través de #139 después de revisión.

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

Antes de merge/aceptación exigir según aplique:

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

1. Mantener #139/#140 activos y únicos; eliminar refs supersedidos cuando exista tooling capaz.
2. Llevar #140 a CI verde y restaurar atlas authored + animaciones reales.
3. Llevar #139 al gate visual comercial manteniendo CI verde.
4. Reabrir/refrescar #138 solo cuando ambos dominios estén aceptados.
5. Producir evidencia jugable/visual integrada final antes de declarar completado el slice.
