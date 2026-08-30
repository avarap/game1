# ROADMAP

## Fase 0 — Bootstrap — COMPLETADA
- [x] Repositorio, Godot 4.x, escena raíz, estructura y Autoloads mínimos.
- [x] InputMap, logging, debug, persistencia inicial, tests y CI headless.
- Validación: `33278173612`.

## Fase 1 — Core / Walking Prototype — COMPLETADA
- [x] Mundo base, `CharacterBody2D`, movimiento 8 direcciones, cámara, colisiones y Y-sort.
- [x] `Interactable` reutilizable y aceptación de escenas.
- Validación: `33280758441`.

## Fase 2 — Items / Resource Loop — COMPLETADA
- [x] `ItemData`, inventario, stacks/capacidad, energía, recursos, herramientas y loot.
- [x] Tests del loop completo.
- Cierre: `c196e3ab5a42adffe97278f0b0daa8960c789e04`, run `33285578050`.

## Fase 3 — Crafting / Production Loop — COMPLETADA
- [x] Recetas data-driven, crafting atómico, `StorageNetwork` y producción temporizada.
- [x] Tests y CI final verdes.
- Cierre: `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`.

## Fase 4 — Cementerio — COMPLETADA
- [x] Cadáveres, descomposición, tumbas, rating, preparación/entierro/mejoras y persistencia.
- [x] Tests de aceptación y CI final verdes.
- Cierre: `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`.

## Fase 5 — Simulación — COMPLETADA
- [x] Reloj/calendario, ciclo día/noche y sueño.
- [x] `NPCData`, `NavigationAgent2D`, horarios, estados y persistencia NPC.
- [x] Aceptación integral y CI final verdes.
- Cierre: `f0290951a27d5e66581da2532151d957ec35075e`, run `33297774458`.

## Fase 6 — RPG — COMPLETADA

La fase se cierra solo después de #6, #8 y #9 y de comprobar el flujo integral actualizado sobre `world.tscn` real.

### Criterios de aceptación
- [x] Diálogos, condiciones y opciones funcionan desde datos.
- [x] El mismo grafo de diálogo funciona en inglés y español mediante claves estables.
- [x] Relaciones cambian y desbloquean contenido.
- [x] Quests pueden iniciarse, progresar y completarse.
- [x] Las recompensas `QUEST_FLAG` se conceden una sola vez.
- [x] Núcleo de economía compra y vende atómicamente.
- [x] **#6** Interacción de comerciante + UI técnica de compra/venta jugable, reutilizable y EN/ES.
- [x] Núcleo de tecnologías consume puntos y desbloquea contenido.
- [x] **#8** Integración tecnología ↔ quests: recompensa tipada de puntos tecnológicos e idempotencia tras save/load.
- [x] Providers RPG persisten conjuntamente mediante `SaveManager`.
- [x] **#9** Aceptación integral final: relación/diálogo, quest, recompensa única, puntos tecnológicos, unlock, compra + venta, reconstrucción de providers y save/load idempotente.
- [x] `gdscript-quality` global verde.
- [x] `validate-and-test` verde con importación Godot 4.5, smoke y suite headless.
- [x] Documentación e issues sincronizadas para el cierre.

### Bloques validados
- Diálogo/localización: `46a37e00c2ad968e91834da5577a6f512a28f0a9`, run `33298737838`.
- Relaciones: `fc446609004ea8031903c1c529144743cd963e51`, run `33299277228`.
- Condiciones contextuales: `e1a19343e8303d1b28188a2a38c559d788c8087d`, run `33299990183`.
- Quests foundation: `979b2328cc01c8d5a7a0ae4201deabe58cf9cc38`, run `33301533785`.
- Economía foundation: `184f2b6d9df6d0b26dcfeb7d2a2d8e3dc7604863`, run `33304080534`.
- Tecnología foundation: `444fc2995ab14b293188aba54a0f4099dc3c36b3`, run `33305211363`.
- Comercio UI #6: merge `3d6252e840ae32e5445f454170d0856909bf6a2b`, run `33307358527`.
- Tecnología ↔ quests #8: merge `8cd26c98e3e43d982218ccf97869ab0c6a0830b3`; validación global posterior en `main` run `33308014015`.
- Quality gate global #38: merge `cb4c14351abbee84f3162197cdf4ba794ab9846f`, run `33308014015`; todos los `*.gd` se descubren dinámicamente.
- Cierre integral #9: HEAD `ea3543aba5b6d859266553a964d817f54670b9a3`, PR #39, run `33308814397`; ambos jobs `success`.

### Política de localización
- Idiomas iniciales: `en` y `es`; fallback `en`.
- `TranslationServer` + `LocalizationService`, sin nuevo Autoload.
- IDs, condiciones, progreso y saves nunca dependen de texto traducido.
- Ver `LOCALIZATION.md`.

### Fuente narrativa
- `HISTORIA_PRINCIPAL.md` define la dirección canónica de **El Cementerio de Valdeniebla**.
- El documento y la implementación son deliberadamente spoiler-light.
- Los flags narrativos describen hechos observados, no interpretaciones verdaderas.

## Transición pre-Fase 7 — ACTIVA

### Orden obligatorio
1. **#17 — Contrato visual**: escala, tiles, paleta, perspectiva, footprints, cámara, Y-sort y convenciones de assets.
2. **#16 — TileMapLayer foundation**, solo después de cerrar #17.
3. Producción posterior de Fase 7 (#18/#19/#20/#21/#22) según dependencias.

No producir mapas/assets definitivos ni mergear PR #32 antes de cerrar #17.

## Fase 7 — Mundo — BLOQUEADA POR #17
Pueblo, bosque, mina, interiores, exploración y secretos.

## Fase 8 — Polish
Arte, animaciones, shaders, partículas, audio, feedback, UI final y optimización.
