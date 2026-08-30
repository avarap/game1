# game1

RPG 2D de gestión, crafting, exploración y simulación construido con **Godot 4.x + GDScript**.

El objetivo es un vertical slice original y pulido. El desarrollo sigue `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`, `ROADMAP.md` y las issues de integración/cierre asociadas a cada fase.

## Estado

- Fases completadas: **0 — Bootstrap, 1 — Core, 2 — Items, 3 — Crafting, 4 — Cementerio, 5 — Simulación**.
- Fase activa: **6 — RPG**.
- Fase 6 tiene validados diálogo bilingüe EN/ES, relaciones, condiciones narrativas, quests foundation, economía foundation, tecnologías foundation y persistencia conjunta básica.
- Pendientes obligatorios antes del cierre: **#6 comercio UI**, **#8 integración tecnología ↔ quests** y después **#9 aceptación/cierre real**.
- Fase 7 está bloqueada. El PR #32 permanece draft y no debe mergearse hasta completar las dependencias de cierre.
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

Hermano Aldren puede iniciar diálogo data-driven EN/ES. La primera quest jugable se acepta, progresa y entrega mediante los sistemas existentes, con recompensa `QUEST_FLAG` idempotente.

La foundation de **economía** ya ofrece APIs atómicas de compra/venta, saldo entero en cobre, precios/stock data-driven y persistencia. Falta la interacción/UI técnica definida en #6 para considerarla jugable desde la interfaz.

La foundation de **tecnologías** ya mantiene puntos rojo/verde/azul, desbloqueos persistentes e idempotentes. Falta #8: que las quests concedan puntos tecnológicos mediante una recompensa tipada/data-driven sin duplicarlos tras save/load.

## Arquitectura

Los Autoloads se limitan a cinco servicios globales: `EventBus`, `GameManager`, `TimeManager`, `SaveManager` y `AudioManager`.

Los sistemas RPG permanecen locales/contextuales y usan Resources tipados. `QuestService`, `EconomyService` y `TechnologyService` contienen lógica de negocio testeable; sus controllers conectan mundo/persistencia sin convertirse en servicios globales.

`SaveManager` agrega providers del grupo `save_provider`. Quests, relaciones, economía y tecnología mantienen claves de persistencia independientes.

## Calidad y tests

El CI ejecuta dos gates independientes:

- `gdscript-quality`: `gdlint` + `gdformat --check`.
- `validate-and-test`: importación Godot 4.5, smoke test y suite headless.

El run `33305899447` validó una aceptación RPG parcial, pero no representa el cierre definitivo de Fase 6 porque todavía no incluía #6 ni #8. El cierre real deberá ejecutarse de nuevo desde #9 sobre el HEAD final definitivo.

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
