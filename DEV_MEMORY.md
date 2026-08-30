# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase completada más reciente: **Fase 5 — Simulación**.
- Fase activa: **Fase 6 — RPG**.
- El cierre documental previo de Fase 6 fue prematuro; #6 ya está completada, pero #8 y #9 siguen siendo dependencias obligatorias del cierre real.
- Fase 7 está **bloqueada**. PR #32 (`Phase 7: world zones foundation`) sigue fuera de `main` y no debe mergearse todavía.
- Fuente funcional/arquitectónica: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Fuente de planificación: `ROADMAP.md` + issues de integración/cierre.
- Fuente narrativa: `HISTORIA_PRINCIPAL.md` — **El Cementerio de Valdeniebla**, spoiler-light.
- Política de idiomas: `LOCALIZATION.md`.
- Último bloque completado de Fase 6: **#6 — Comercio UI**.
- Merge funcional #6: `3d6252e840ae32e5445f454170d0856909bf6a2b` (PR #35).
- Validación de `main` para #6: Godot CI `33307358527`, ambos jobs `success`.

## Fases completadas

- Fase 0 — Bootstrap: run `33278173612`.
- Fase 1 — Core: run `33280758441`.
- Fase 2 — Items: `c196e3ab5a42adffe97278f0b0daa8960c789e04`, run `33285578050`.
- Fase 3 — Crafting: `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`.
- Fase 4 — Cementerio: `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`.
- Fase 5 — Simulación: `f0290951a27d5e66581da2532151d957ec35075e`, run `33297774458`.

## Fase 6 — RPG — ACTIVA

### Ya validado

1. Diálogo/localización EN/ES: `46a37e00c2ad968e91834da5577a6f512a28f0a9`, run `33298737838`.
2. Relaciones 0–100: `fc446609004ea8031903c1c529144743cd963e51`, run `33299277228`.
3. Condiciones contextuales: `e1a19343e8303d1b28188a2a38c559d788c8087d`, run `33299990183`.
4. Quests foundation: `979b2328cc01c8d5a7a0ae4201deabe58cf9cc38`, run `33301533785`.
5. Economía foundation: `184f2b6d9df6d0b26dcfeb7d2a2d8e3dc7604863`, run `33304080534`.
6. Tecnología foundation: `444fc2995ab14b293188aba54a0f4099dc3c36b3`, run `33305211363`.
7. Roundtrip conjunto básico de providers: `cc1351048609a474cedd524543f6c4370c46bea4`, run `33305899447`. Es verde, pero no cierra #9 porque todavía falta #8 y la aceptación final debe usar el flujo actualizado.
8. **#6 — Comercio UI:** merge `3d6252e840ae32e5445f454170d0856909bf6a2b`, run `33307358527`.
   - `TradeInteractable` reutilizable y localizado EN/ES.
   - `TradePanel` observa `EconomyController`/inventario y usa `buy()`/`sell()` existentes.
   - Saldo/precios se presentan como oro/plata/cobre manteniendo cobre entero como unidad base.
   - Stock e inventario se refrescan tras operaciones; rechazos muestran feedback localizado sin mutar estado.
   - `test_trading_ui.gd` cubre apertura/cierre, compra, venta, rechazo, saldo/stock/inventario y localización.
   - Quality gate incluye los scripts/test nuevos y permanece estricto (`gdlint` + `gdformat --check`).

### Incidencias #6

- El primer cierre de Fase 6 había omitido esta UI y se corrigió la planificación antes de continuar.
- La prueba de prompt detectó que `TradePoint.prompt` no estaba localizado; se añadió `UI_TRADE_PROMPT` y actualización ante cambio de idioma.
- `gdformat` exigió formato canónico en dos expresiones multilínea de `trade_panel.gd`; se obtuvo el diff exacto y se aplicó sin relajar el gate.
- El conector GitHub falló al convertir el draft PR #34 a ready (`fullDatabaseId` GraphQL). Se sustituyó por PR #35 sobre el mismo HEAD validado; #35 fue mergeado. El PR redundante #36 se cerró sin merge.

### Pendientes obligatorios

#### #8 — Tecnología ↔ quests
- Extender `QuestRewardData` con recompensa tipada de puntos tecnológicos.
- Completar quest debe conceder puntos configurados exactamente una vez.
- Save/load no puede duplicar recompensa.
- `TechnologyController` continúa local/contextual.
- Regresión de `QUEST_FLAG` debe seguir verde.

#### #9 — Cierre real de Fase 6
Debe ejecutarse solo después de #8. La aceptación final debe incluir relación/diálogo, quest, progreso, entrega, recompensa única, puntos de tecnología obtenidos desde quest, desbloqueo, compra **y venta**, save/load conjunto e idempotencia posterior. CI y documentación deben corresponder al mismo HEAD final.

## Dependencias posteriores

Orden obligatorio:

`#8 -> #9 -> #17 -> #16 -> #18/#19/#20/#21/#22`

- #17 no empieza hasta cerrar #9.
- #16 exige #9 + #17.
- No producir mapas/assets ni mergear PR #32 mientras Fase 6 esté activa.

## Decisiones vigentes

- Mantener exactamente cinco Autoloads globales.
- `TimeManager` es la única fuente de reloj/calendario.
- NPCs, diálogo, relaciones, quests, economía y tecnología permanecen locales/contextuales.
- IDs, condiciones, saves y progreso son independientes del idioma.
- UI observa modelos/controllers y emite intents; no contiene lógica de negocio.
- Gameplay data-driven mediante Resources tipados cuando corresponda.
- Dinero y precios usan enteros en cobre; UI solo formatea oro/plata/cobre.
- Recompensas de quest deben ser idempotentes para todos sus tipos.
- Los desbloqueos tecnológicos se identifican por IDs estables.
- No introducir alcance de Fase 7/8 antes del cierre real de Fase 6.

## Próximo paso

Implementar **#8 — Integración tecnología ↔ quests y persistencia** con TDD. Añadir recompensa tipada de puntos tecnológicos, integrarla con `TechnologyController` de forma contextual, demostrar idempotencia tras save/load y mantener regresión `QUEST_FLAG`. Solo después ejecutar #9.

## Regla de continuidad

Al retomar:
1. Leer `DEV_MEMORY.md`, `ROADMAP.md` y las issues abiertas de la fase activa.
2. Revisar `main` y el último CI.
3. No inferir cierre de fase solo porque un CI esté verde: comprobar dependencias/issues de cierre.
4. Implementar un bloque coherente y pequeño.
5. Ejecutar quality gate, importación, smoke y suite headless.
6. Corregir errores antes de avanzar.
7. Actualizar `DEV_MEMORY.md`, `ROADMAP.md` y `CHANGELOG.md`.
8. No marcar una fase completa hasta cumplir todos sus criterios y dependencias explícitas.
