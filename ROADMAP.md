# ROADMAP

## Estado global

- Fases 0–7: **COMPLETADAS**.
- Fase 8 — Polish: **ACTIVA**.
- Runtime/CI contractual: **Godot 4.7.2**.
- Gate final: no declarar el vertical slice completo sin gates técnicos, jugables y visuales sobre el mismo estado integrado.
- #139 MAP y #140 PLAYER fueron fusionadas antes de aceptación. **Merged != accepted**.

## Gobernanza activa

La rama es la identidad canónica del dominio.

- MAP: `feat/main-map-rebuild-commercial-pass` — reutilizable para una única PR secuencial de remediación; #139 es histórica.
- PLAYER: `character/player-controller-polish-20260902` — reutilizable para una única PR secuencial de remediación; #140 es histórica.
- INTEGRATION: `automation/supervisor-player-map-integration` — #138 PARKED/CLOSED hasta aceptación real de MAP+PLAYER.

Máximo una PR abierta por dominio. Ninguna rama paralela. Si una PR se fusionó prematuramente, se continúa en la misma rama canónica desde `main`, nunca en #138.

## Critical path actual

### 1. PLAYER remediation

Prioridad absoluta.

Aceptación pendiente:
- systematic debugging de CI rojo;
- `gdformat --check` verde;
- bootstrap verde, incluidas regresiones Verdant harvest/energy/depletion/stump;
- eliminar generación procedural de frames en `PlayerVisual`;
- atlas/spritesheet authored + pixel-cleaned;
- idle/walk/run/interact distintos en 8 direcciones;
- run != walk acelerado/reutilizado;
- interact != idle fallback;
- colisiones e interacción direccional funcionales;
- gameplay real 1280x720 sobre el mapa reconstruido.

### 2. MAP remediation

Puede avanzar en paralelo manteniendo CI técnico verde.

Aceptación pendiente:
- terrain/path system authored;
- transiciones/path edges pixel-cleaned;
- eliminar banding/grid/repetición matemática y caminos ortogonales obvios;
- landmarks claros para taller/cementerio/plaza;
- foreground/gameplay/background depth y Y-sort coherentes;
- navegación/colisiones/interacciones/rendimiento correctos;
- nueva captura real 1280x720 y crítica visual aceptada.

### 3. INTEGRATION — #138

Estado: **PARKED/CLOSED**.

Solo cuando PLAYER y MAP estén accepted:
1. reabrir la misma #138;
2. refrescar su rama desde `main` accepted;
3. conservar solo deltas cross-domain;
4. ejecutar import/smoke/bootstrap/lint/integration;
5. demostrar gameplay y captura 1280x720 integrados.

## Cleanup

Las ramas stale verificadas en la pasada de gobernanza no contenían commits únicos (`ahead_by=0`). Se han contenido en `main` cuando no fue posible borrarlas mediante tooling. No pueden recibir trabajo. Su borrado físico sigue pendiente, pero no bloquea remediación en las ramas canónicas.

## Pipeline visual obligatorio

art direction -> concept/base -> pixel cleanup -> asset-system assembly -> Godot integration -> captura 1280x720 -> critique/revision.

## Después del critical path

- UI/UX final;
- audio final;
- estabilidad/export;
- optimización adicional;
- gate integral/release candidate.
