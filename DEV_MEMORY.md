# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`.
- Rama principal: `main`.
- Fase completada más reciente: **Fase 6 — RPG**.
- Cierre funcional de Fase 6 validado en PR #39, HEAD `ea3543aba5b6d859266553a964d817f54670b9a3`, Godot CI `33308814397`: `gdscript-quality` y `validate-and-test` en `success`.
- #8 — tecnología ↔ quests está cerrada: merge funcional `8cd26c98e3e43d982218ccf97869ab0c6a0830b3`; la validación global posterior de `main` fue `33308014015` sobre `cb4c14351abbee84f3162197cdf4ba794ab9846f`.
- #9 — aceptación RPG integral queda resuelta por el test reforzado de PR #39 y la sincronización documental de este bloque.
- Próximo bloque obligatorio: **#17 — contrato visual pre-Fase 7**.
- Fase 7 permanece **bloqueada** hasta cerrar #17; #16 depende de #17 y no debe adelantarse.
- PR #32 (`Phase 7: world zones foundation`) permanece fuera de `main` y no debe mergearse todavía.
- Fuente funcional/arquitectónica: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Fuente de planificación: `ROADMAP.md` + issues de integración/cierre.
- Fuente narrativa: `HISTORIA_PRINCIPAL.md` — **El Cementerio de Valdeniebla**, spoiler-light.
- Política de idiomas: `LOCALIZATION.md`.

## Fases completadas

- Fase 0 — Bootstrap: run `33278173612`.
- Fase 1 — Core: run `33280758441`.
- Fase 2 — Items: `c196e3ab5a42adffe97278f0b0daa8960c789e04`, run `33285578050`.
- Fase 3 — Crafting: `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`.
- Fase 4 — Cementerio: `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`.
- Fase 5 — Simulación: `f0290951a27d5e66581da2532151d957ec35075e`, run `33297774458`.
- Fase 6 — RPG: aceptación funcional HEAD `ea3543aba5b6d859266553a964d817f54670b9a3`, run `33308814397`.

## Fase 6 — RPG — COMPLETADA

### Sistemas validados

1. Diálogo/localización EN/ES: `46a37e00c2ad968e91834da5577a6f512a28f0a9`, run `33298737838`.
2. Relaciones 0–100: `fc446609004ea8031903c1c529144743cd963e51`, run `33299277228`.
3. Condiciones contextuales: `e1a19343e8303d1b28188a2a38c559d788c8087d`, run `33299990183`.
4. Quests foundation: `979b2328cc01c8d5a7a0ae4201deabe58cf9cc38`, run `33301533785`.
5. Economía foundation: `184f2b6d9df6d0b26dcfeb7d2a2d8e3dc7604863`, run `33304080534`.
6. Tecnología foundation: `444fc2995ab14b293188aba54a0f4099dc3c36b3`, run `33305211363`.
7. Comercio UI #6: merge `3d6252e840ae32e5445f454170d0856909bf6a2b`, run `33307358527`.
8. Tecnología ↔ quests #8: merge `8cd26c98e3e43d982218ccf97869ab0c6a0830b3`; recompensa tipada de puntos tecnológicos, compatibilidad `QUEST_FLAG`, idempotencia y persistencia verificadas por `test_technology_quest_integration.gd`.
9. Quality gate global #38: merge `cb4c14351abbee84f3162197cdf4ba794ab9846f`, run `33308014015`; 109 scripts GDScript cubiertos dinámicamente por `gdlint` + `gdformat --check`.
10. Cierre integral #9: `test_rpg_acceptance.gd` reforzado en `ea3543aba5b6d859266553a964d817f54670b9a3`, run `33308814397`.

### Aceptación integral final

El test de cierre usa `world.tscn` real y cubre en un único flujo:

- relación que desbloquea contenido de diálogo;
- inicio, progreso y entrega de `aldren_first_duty`;
- `QUEST_FLAG` y puntos tecnológicos concedidos exactamente una vez;
- reintento de recompensa sin duplicación;
- compra y venta con economía atómica;
- desbloqueo de `sturdy_joinery` consumiendo puntos;
- guardado con providers `relationships`, `quests`, `economy` y `technology`;
- destrucción y reconstrucción del mundo antes de cargar;
- restauración de relación, quest/flags, saldo, stock, puntos y unlock IDs;
- idempotencia posterior a load tanto de recompensas como del desbloqueo.

No fue necesario modificar lógica de producción para cerrar #9: el código existente ya cumplía el flujo cuando se amplió la cobertura de aceptación.

## Decisiones vigentes

- Mantener exactamente cinco Autoloads globales.
- `TimeManager` es la única fuente de reloj/calendario.
- NPCs, diálogo, relaciones, quests, economía y tecnología permanecen locales/contextuales.
- IDs, condiciones, saves y progreso son independientes del idioma.
- UI observa modelos/controllers y emite intents; no contiene lógica de negocio.
- Gameplay data-driven mediante Resources tipados cuando corresponda.
- Dinero y precios usan enteros en cobre; UI solo formatea oro/plata/cobre.
- Recompensas de quest son idempotentes para todos sus tipos.
- Los desbloqueos tecnológicos se identifican por IDs estables.
- El quality gate descubre todos los `*.gd` automáticamente; no volver a listas blancas manuales.
- No iniciar producción de mapas/assets de Fase 7 antes de fijar #17.

## Próximo paso

Implementar **#17 — Contrato visual: escala, tiles, paleta y perspectiva** como bloque documental/técnico aislado. Debe fijar métricas numéricas y convenciones que permitan después ejecutar #16 — foundation `TileMapLayer` sin decisiones visuales incompatibles. No mergear PR #32 ni producir assets definitivos antes de cerrar #17.

## Regla de continuidad

Al retomar:
1. Leer `DEV_MEMORY.md`, `ROADMAP.md` y la issue activa.
2. Revisar `main` y el último CI.
3. Comprobar dependencias antes de iniciar trabajo nuevo.
4. Implementar un bloque coherente y pequeño.
5. Ejecutar quality gate, importación, smoke y suite headless cuando corresponda.
6. Corregir errores críticos antes de avanzar.
7. Actualizar `DEV_MEMORY.md`, `ROADMAP.md` y `CHANGELOG.md`.
8. No marcar una fase o dependencia como completada sin cumplir sus criterios explícitos.
