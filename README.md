# game1

RPG 2D de gestión, crafting, exploración y simulación construido con **Godot 4.x + GDScript**.

El objetivo es un vertical slice original y pulido. El desarrollo sigue `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md` y avanza fase por fase, manteniendo el proyecto ejecutable y validado por CI.

## Estado

- Fases completadas: **0 — Bootstrap, 1 — Core, 2 — Items, 3 — Crafting, 4 — Cementerio, 5 — Simulación**
- Fase activa: **6 — RPG**
- Bloques validados: diálogo bilingüe EN/ES, relaciones 0-100 y condiciones narrativas contextuales.
- Fuente narrativa: **`HISTORIA_PRINCIPAL.md` — El Cementerio de Valdeniebla**, en versión spoiler-light.
- Próximo bloque: foundation de quests del Acto 1 con Hermano Aldren.
- Godot objetivo de CI: **4.5**
- Rama principal: `main`
- Memoria de desarrollo: `DEV_MEMORY.md`
- Última validación funcional: **Godot CI `33299990183` — success**

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

El vertical slice soporta actualmente:

- **English (`en`)**
- **Español (`es`)**

La UI técnica muestra botones `ES` / `EN` para cambiar idioma en runtime. El diálogo activo se refresca sin reiniciar ni cambiar el estado del grafo. Las traducciones usan `TranslationServer` y catálogos `.po`; IDs, condiciones, saves y progreso no dependen del texto traducido. Ver `LOCALIZATION.md`.

## Narrativa

`HISTORIA_PRINCIPAL.md` contiene la dirección narrativa de **El Cementerio de Valdeniebla**. El documento se mantiene deliberadamente sin spoilers fuertes: describe tono, personajes, tensiones y estructura general, pero no revela culpables, identidades ocultas, naturaleza final del misterio ni finales concretos.

La historia se integra con el trabajo cotidiano del cementerio. La prioridad es un Acto 1 pequeño en el que reparar, enterrar, fabricar, observar horarios y hablar con habitantes produzca preguntas nuevas de forma natural. Las pistas deben poder admitir más de una interpretación y ningún personaje se presenta demasiado pronto como dueño de toda la verdad.

## Loop jugable disponible

La build técnica permite probar movimiento, recolección, inventario, crafting/producción, cementerio y simulación. El estado de cementerio, tiempo y Hermano Aldren participa en el guardado versionado.

Hermano Aldren navega con `NavigationAgent2D`, sigue `ScheduleData`, usa estados `Idle`, `Walking`, `Working` y `Sleeping`, y puede ser abordado mediante el sistema genérico de interacción para iniciar diálogo data-driven.

El mismo diálogo funciona en español e inglés. Las opciones pueden depender de relaciones, inventario, hora y flags de quest. El diálogo de Aldren incluye una opción nocturna disponible entre las 22:00 y las 06:00.

## Arquitectura

Los Autoloads se limitan a cinco servicios globales: `EventBus`, `GameManager`, `TimeManager`, `SaveManager` y `AudioManager`. Los sistemas de gameplay permanecen locales/contextuales y preferentemente basados en Resources tipados.

`SaveManager` agrega estado persistente mediante providers del grupo `save_provider`. `TimeManager` es la única fuente de reloj/calendario. `TranslationServer` es la autoridad de idioma del motor; `LocalizationService` solo encapsula la política EN/ES y no se registra como Autoload.

Los datos de diálogo almacenan claves de traducción y referencias por ID. `DialogueInteractable` construye un snapshot contextual para `DialogueService`, por lo que el servicio no depende directamente del inventario, reloj, relaciones o quests.

La narrativa usa IDs neutrales y flags de hechos observados para evitar acoplar lógica o persistencia a una interpretación concreta del misterio.

## Calidad y tests

El CI ejecuta dos gates independientes:

- `gdscript-quality`: `gdlint` + `gdformat --check`.
- `validate-and-test`: importación Godot 4.5, smoke test y suite headless.

La suite cubre localización/diálogo, integración real con Aldren, relaciones y condiciones `HAS_ITEM`, `TIME_OF_DAY` y `QUEST_FLAG`, incluido el cruce de medianoche.

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
- `LOCALIZATION.md`: política concreta EN/ES, claves y reglas de localización.
- `GAME_DESIGN.md`: diseño resumido del juego.
- `ARCHITECTURE.md`: decisiones técnicas.
- `ROADMAP.md`: fases y criterios de avance.
- `CHANGELOG.md`: cambios relevantes.
- `DEV_MEMORY.md`: memoria operativa para continuar exactamente donde se dejó.
- `PHASE_TEMPLATE.md`: checklist para abrir/cerrar fases sin desincronizar código, CI y documentación.
