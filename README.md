# game1

RPG 2D de gestión, crafting, exploración y simulación construido con **Godot 4.7.2 + GDScript**.

Objetivo: un vertical slice original, jugable y con calidad visual de videojuego indie comercial.

## Fuentes de verdad actuales

- Producción/orquestación: `GAME1_RULES.md`.
- Skill de proceso: `.agents/skills/orchestrating-game-production/SKILL.md`.
- Estado operativo: `DEV_MEMORY.md`.
- Plan: `ROADMAP.md`.
- Arquitectura/spec: `docs/design/MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Diseño: `docs/design/GAME_DESIGN.md`.
- Dirección visual: `docs/art/ART_DIRECTION.md`.
- Índice documental: `docs/README.md`.
- Lecciones de producción: `docs/production/LESSONS_LEARNED.md`.

## Estado

- Fases 0–7: completadas.
- Fase 8 — Polish: activa.
- Runtime/CI objetivo: Godot 4.7.2.
- El mapa principal antiguo está descartado y no puede reutilizarse en layout/composición/patrones/distribución/diseño espacial.
- MAP #139 y PLAYER #140 fueron merged antes de aceptación. **Merged != accepted**.
- `main` sigue requiriendo remediación PLAYER para recuperar CI completamente verde.

## Workstreams canónicos

La identidad canónica es la rama; un PR merged pasa a ser histórico.

- **MAP** — `feat/main-map-rebuild-commercial-pass` — #139 histórico; una única PR secuencial de remediación puede reutilizar esta misma rama.
- **PLAYER** — `character/player-controller-polish-20260902` — #140 histórico; una única PR secuencial de remediación puede reutilizar esta misma rama.
- **INTEGRATION #138** — `automation/supervisor-player-map-integration` — PARKED/CLOSED hasta aceptación real de MAP+PLAYER; entonces se reabre la misma #138.

No crear ramas paralelas. Máximo una PR abierta por dominio. #138 nunca se usa para terminar deuda propia de MAP/PLAYER.

## Critical path

1. **PLAYER remediation:** systematic debugging -> `gdformat` + bootstrap green -> eliminar frames procedurales -> atlas authored/pixel-cleaned -> idle/walk/run/interact reales en 8 direcciones -> gameplay 1280x720.
2. **MAP remediation en paralelo:** mantener CI técnico verde -> terrain/path authored -> eliminar grid/banding/repetición -> landmarks/depth -> recaptura 1280x720 y crítica aceptada.
3. Reabrir #138 solo después de aceptación real de ambos dominios y resolver únicamente integración cross-domain.
4. Validar build, gameplay y evidencia visual sobre el mismo estado integrado.

## Pipeline de pixel art

art direction -> concept/base -> pixel cleanup -> asset-system assembly -> Godot integration -> captura 1280x720 -> critique/revision.

Una imagen generada, conceptual o sprite procedural no es un asset final hasta pasar el pipeline.

## Quality gates

- `gdlint`;
- `gdformat --check`;
- Godot 4.7.2 import/validation;
- smoke launch;
- suite headless relevante/completa;
- movimiento/colisiones/interacciones reales;
- navegación/rendimiento;
- capturas/video reales para revisión visual.

Tests solos nunca equivalen a aceptación visual o jugable.

## Branch cleanup

Las ramas stale verificadas sin trabajo único se contienen y no pueden volver a recibir trabajo. Cuando el tooling no permita borrarlas físicamente, apuntarlas a `main` es solo contención temporal; el borrado remoto sigue pendiente, pero no bloquea el trabajo en las ramas canónicas.

## Ejecutar

```bash
godot --headless --path . --script res://tests/run_tests.gd
```
