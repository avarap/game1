# game1

RPG 2D de gestión, crafting, exploración y simulación construido con **Godot 4.x + GDScript**.

El objetivo es un vertical slice original y pulido. El desarrollo sigue `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md` y avanza fase por fase, manteniendo el proyecto ejecutable y validado por CI.

## Estado

- Fases completadas: **0 — Bootstrap, 1 — Core, 2 — Items, 3 — Crafting, 4 — Cementerio, 5 — Simulación**
- Fase activa: **6 — RPG**
- Bloque actual completado: **foundation de diálogo data-driven bilingüe EN/ES**.
- Próximo bloque: relaciones 0-100 y desbloqueo de opciones de diálogo mediante condiciones data-driven.
- Godot objetivo de CI: **4.5**
- Rama principal: `main`
- Memoria de desarrollo: `DEV_MEMORY.md`
- Última validación: **Godot CI `33298737838` — success**

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

La UI técnica muestra botones `ES` / `EN` para cambiar el idioma en runtime. El diálogo activo se refresca sin reiniciar ni cambiar el estado del grafo. Las traducciones usan `TranslationServer` y catálogos `.po`; IDs, condiciones, saves y progreso no dependen del texto traducido. Ver `LOCALIZATION.md`.

## Loop jugable disponible

La build técnica permite probar movimiento, recolección, inventario, crafting/producción, cementerio y simulación. El estado de cementerio, tiempo y Hermano Aldren participa en el guardado versionado.

Hermano Aldren navega con `NavigationAgent2D`, sigue `ScheduleData` y usa estados `Idle`, `Walking`, `Working` y `Sleeping`. Ahora también puede ser abordado mediante el sistema genérico de interacción para iniciar un primer diálogo original data-driven.

El mismo diálogo funciona en español e inglés. Sus opciones y condiciones viven en Resources tipados y `DialogueService` mantiene la lógica fuera de la UI.

## Arquitectura

Los Autoloads se limitan a cinco servicios globales: `EventBus`, `GameManager`, `TimeManager`, `SaveManager` y `AudioManager`. Los sistemas de gameplay permanecen locales/contextuales y preferentemente basados en Resources tipados.

`SaveManager` agrega estado persistente mediante providers del grupo `save_provider`. `TimeManager` es la única fuente de reloj/calendario. `TranslationServer` es la autoridad de idioma del motor; `LocalizationService` solo encapsula la política EN/ES y no se registra como Autoload.

Los datos de diálogo almacenan claves de traducción y referencias por ID. La UI traduce únicamente al presentar, por lo que añadir idiomas no requiere duplicar árboles de diálogo.

## Calidad y tests

El CI ejecuta dos gates independientes:

- `gdscript-quality`: `gdlint` + `gdformat --check`.
- `validate-and-test`: importación Godot 4.5, smoke test y suite headless.

La suite incluye tests puros de localización/diálogo y una integración que carga `world.tscn`, interactúa con Hermano Aldren, valida español, selecciona una opción y cambia a inglés durante la conversación.

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
- `LOCALIZATION.md`: política concreta EN/ES, claves y reglas de localización.
- `GAME_DESIGN.md`: diseño resumido del juego.
- `ARCHITECTURE.md`: decisiones técnicas.
- `ROADMAP.md`: fases y criterios de avance.
- `CHANGELOG.md`: cambios relevantes.
- `DEV_MEMORY.md`: memoria operativa para continuar exactamente donde se dejó.
- `PHASE_TEMPLATE.md`: checklist para abrir/cerrar fases sin desincronizar código, CI y documentación.
