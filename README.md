# game1

RPG 2D de gestión, crafting, exploración y simulación construido con **Godot 4.x + GDScript**.

El objetivo es un vertical slice original y pulido. El desarrollo sigue `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md` y avanza fase por fase, manteniendo el proyecto ejecutable y validado por CI.

## Estado

- Fases completadas: **0 — Bootstrap, 1 — Core, 2 — Items, 3 — Crafting, 4 — Cementerio, 5 — Simulación**
- Fase activa: **6 — RPG**
- Bloques validados: diálogo bilingüe EN/ES, relaciones 0-100, condiciones narrativas contextuales, quests, economía y **foundation de tecnologías**.
- Fuente narrativa: **`HISTORIA_PRINCIPAL.md` — El Cementerio de Valdeniebla**, en versión spoiler-light.
- Próximo bloque: **aceptación/persistencia integral y cierre de Fase 6**.
- Godot objetivo de CI: **4.5**
- Rama principal: `main`
- Memoria de desarrollo: `DEV_MEMORY.md`
- Última validación funcional: **Godot CI `33305211363` — success**

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

El vertical slice soporta **English (`en`)** y **Español (`es`)**, con fallback inglés. La UI técnica permite cambiar idioma durante un diálogo sin alterar el estado del grafo. Las traducciones usan `TranslationServer` y catálogos `.po`; IDs, condiciones, saves y progreso no dependen del texto localizado. Ver `LOCALIZATION.md`.

## Narrativa

`HISTORIA_PRINCIPAL.md` contiene la dirección narrativa de **El Cementerio de Valdeniebla** y se mantiene deliberadamente sin spoilers fuertes. La historia surge del trabajo cotidiano del cementerio y las pistas deben admitir más de una interpretación mientras sea razonable.

## Loop jugable disponible

La build técnica permite probar movimiento, recolección, inventario, energía, crafting/producción, cementerio, tiempo, día/noche, sueño y un NPC con navegación/horarios persistentes.

Hermano Aldren puede ser abordado mediante el sistema genérico de interacción para iniciar diálogo data-driven EN/ES. Sus opciones pueden depender de relaciones, inventario, hora y estado de quests.

La **primera quest jugable** ya está integrada: se acepta hablando con Aldren, progresa usando el inventario/crafting existente, se entrega mediante diálogo y su estado/recompensa se conserva mediante el sistema genérico de guardado. Las recompensas son idempotentes y no pueden concederse dos veces tras restaurar una partida.

La foundation de **economía** permite compra/venta atómica con inventario, saldo en cobre, precios y stock data-driven, con persistencia del wallet y del comerciante. La foundation de **tecnologías** añade puntos rojo/verde/azul y un desbloqueo persistente: `sturdy_joinery` consume 2 puntos rojos + 1 verde y habilita el ID `recipe_reinforced_fence`.

## Arquitectura

Los Autoloads se limitan a cinco servicios globales: `EventBus`, `GameManager`, `TimeManager`, `SaveManager` y `AudioManager`.

Los sistemas RPG permanecen locales/contextuales y usan Resources tipados. `QuestService`, `EconomyService` y `TechnologyService` contienen lógica de negocio testeable; sus controllers conectan mundo/persistencia sin convertirse en servicios globales. `DialogueController` emite intención y no posee lógica de quests.

`SaveManager` agrega providers del grupo `save_provider`. Quests, relaciones, economía y tecnología mantienen claves de persistencia independientes. `TimeManager` es la única fuente de reloj/calendario y `TranslationServer` es la autoridad de idioma.

## Calidad y tests

El CI ejecuta dos gates independientes:

- `gdscript-quality`: `gdlint` + `gdformat --check`.
- `validate-and-test`: importación Godot 4.5, smoke test y suite headless.

La suite cubre el flujo real de quests **diálogo → activar quest → progreso de inventario → entregar → recompensa única → restauración**, además de compra/venta atómica y persistencia de economía, y costes/idempotencia/snapshot de tecnologías.

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

## Validación headless

```bash
godot --headless --path . --editor --quit
godot --headless --path . --quit-after 3
```

## Documentación

- `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`: fuente de verdad funcional y arquitectónica.
- `HISTORIA_PRINCIPAL.md`: dirección narrativa spoiler-light de Valdeniebla.
- `LOCALIZATION.md`: política EN/ES.
- `GAME_DESIGN.md`: diseño resumido.
- `ARCHITECTURE.md`: decisiones técnicas.
- `ROADMAP.md`: fases y criterios de avance.
- `CHANGELOG.md`: cambios relevantes.
- `DEV_MEMORY.md`: memoria operativa.
- `PHASE_TEMPLATE.md`: checklist para abrir/cerrar fases.
