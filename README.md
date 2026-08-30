# game1

RPG 2D de gestión, crafting, exploración y simulación construido con **Godot 4.x + GDScript**.

El objetivo es un vertical slice original y pulido. El desarrollo sigue `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`, `ROADMAP.md` y las issues de integración/cierre asociadas a cada fase.

## Estado

- Fases completadas: **0 — Bootstrap, 1 — Core, 2 — Items, 3 — Crafting, 4 — Cementerio, 5 — Simulación, 6 — RPG**.
- Siguiente bloque obligatorio: **#17 — contrato visual pre-Fase 7**.
- Fase 7 — Mundo permanece bloqueada hasta cerrar #17; #16 — `TileMapLayer` foundation depende de ese contrato.
- PR #32 (`Phase 7: world zones foundation`) permanece fuera de `main` y no debe mergearse antes de #17.
- Godot objetivo de CI: **4.5**.
- Rama principal: `main`.
- Memoria de desarrollo: `DEV_MEMORY.md`.

## Ejecutar

1. Instala Godot 4.x.
2. Clona el repositorio.
3. Abre `project.godot`.
4. Ejecuta la escena principal con F5.

## Controles base

- Movimiento: WASD
- Interactuar: E
- Acción primaria/secundaria: ratón
- Inventario: I
- Mapa: M
- Pausa: Esc
- Panel debug: F12

## Idiomas

El vertical slice soporta **English (`en`)** y **Español (`es`)**, con fallback inglés. Las traducciones usan `TranslationServer` y catálogos `.po`; IDs, condiciones, saves y progreso no dependen del texto localizado. Ver `LOCALIZATION.md`.

## Loop jugable disponible

La build técnica permite probar movimiento, recolección, inventario, energía, crafting/producción, cementerio, tiempo, día/noche, sueño y un NPC con navegación/horarios persistentes.

Hermano Aldren dispone de diálogo data-driven EN/ES con contenido condicionado por relación, hora y estado de quest. `aldren_first_duty` puede iniciarse, progresar y entregarse; concede `QUEST_FLAG` y puntos tecnológicos exactamente una vez.

La economía es jugable mediante `TradeInteractable` + `TradePanel`: compra y venta usan las APIs atómicas de `EconomyController`, con saldo entero en cobre, precios/stock data-driven, feedback localizado y persistencia.

El sistema de tecnologías mantiene puntos rojo/verde/azul, consume puntos al desbloquear `sturdy_joinery`, expone unlock IDs y persiste el progreso. Las recompensas tecnológicas de quests son tipadas, data-driven e idempotentes tras save/load.

La aceptación integral de Fase 6 destruye y reconstruye el mundo antes de cargar para verificar conjuntamente relaciones, quests/flags, economía y tecnología.

## Arquitectura

Los Autoloads se limitan a cinco servicios globales: `EventBus`, `GameManager`, `TimeManager`, `SaveManager` y `AudioManager`.

Los sistemas RPG permanecen locales/contextuales y usan Resources tipados. `QuestService`, `EconomyService` y `TechnologyService` contienen lógica de negocio testeable; sus controllers conectan mundo/persistencia sin convertirse en servicios globales.

`SaveManager` agrega providers del grupo `save_provider`. Quests, relaciones, economía y tecnología mantienen claves de persistencia independientes.

## Calidad y tests

El CI ejecuta dos gates independientes:

- `gdscript-quality`: descubre todos los `*.gd` del repositorio y ejecuta `gdlint` + `gdformat --check` globalmente.
- `validate-and-test`: importación Godot 4.5, smoke test y suite headless.

Validaciones recientes:

- Quality gate global: merge `cb4c14351abbee84f3162197cdf4ba794ab9846f`, run `33308014015`.
- Cierre funcional de Fase 6: acceptance HEAD `ea3543aba5b6d859266553a964d817f54670b9a3`, PR #39, run `33308814397`, ambos jobs `success`.

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

## Documentación

- `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`: fuente funcional y arquitectónica.
- `ROADMAP.md`: fases, dependencias y criterios de avance.
- `DEV_MEMORY.md`: memoria operativa.
- `CHANGELOG.md`: historial técnico relevante.
- `HISTORIA_PRINCIPAL.md`: dirección narrativa spoiler-light.
- `LOCALIZATION.md`: política EN/ES.
