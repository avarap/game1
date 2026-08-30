# game1

RPG 2D de gestión, crafting, exploración y simulación construido con **Godot 4.x + GDScript**.

El objetivo es un vertical slice original y pulido. El desarrollo sigue `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md` y avanza fase por fase, manteniendo el proyecto ejecutable y validado por CI.

## Estado

- Fases completadas: **0 — Bootstrap, 1 — Core, 2 — Items, 3 — Crafting, 4 — Cementerio, 5 — Simulación**
- Fase activa: **6 — RPG**
- Fase 5 cerrada con reloj/calendario, sueño, ciclo día/noche, `NPCData`, `NavigationAgent2D`, rutinas/horarios y persistencia NPC mediante `SaveManager`.
- Próximo bloque: foundation de diálogo data-driven con opciones/condiciones tipadas y una integración mínima original con Hermano Aldren.
- Godot objetivo de CI: **4.5**
- Rama principal: `main`
- Memoria de desarrollo: `DEV_MEMORY.md`
- Última validación funcional de fase: **Godot CI `33297774458` — success**

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

## Loop jugable disponible

La build técnica permite probar movimiento, recolección, inventario, crafting/producción y el loop mínimo de cementerio: recibir un cadáver, prepararlo, enterrarlo y mejorar la tumba con lápida, valla y decoración. El estado del cementerio se integra con el guardado versionado.

La simulación incluye reloj/calendario centralizado, dormir hasta el siguiente amanecer con recuperación de energía, ciclo día/noche gradual y Hermano Aldren como primer NPC data-driven. Aldren navega con `NavigationAgent2D`, selecciona destinos/estados desde `ScheduleData` y usa `Idle`, `Walking`, `Working` y `Sleeping`.

El estado de Aldren participa como `save_provider` local: el save/load restaura posición, estado actual/pendiente y ruta en curso cuando corresponde. El test integral de Fase 5 verifica además que, después de restaurar, los cambios posteriores de `TimeManager` vuelven a gobernar su rutina y que dormir actualiza NPC, energía y ciclo visual.

## Arquitectura

Los Autoloads se limitan a cinco servicios globales: `EventBus`, `GameManager`, `TimeManager`, `SaveManager` y `AudioManager`. Los sistemas de gameplay permanecen locales/contextuales y preferentemente basados en Resources tipados.

`SaveManager` agrega estado persistente mediante providers del grupo `save_provider`, evitando acoplar el Autoload a implementaciones concretas como cementerio o NPCs.

`TimeManager` es la única fuente de reloj/calendario. Los sistemas visuales y NPCs observan sus señales en vez de duplicar estado temporal.

## Calidad y tests

El CI ejecuta dos gates independientes:

- `gdscript-quality`: `gdlint` + `gdformat --check`.
- `validate-and-test`: importación Godot 4.5, smoke test de la escena principal y suite headless.

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

La suite se inicia de forma diferida una vez que `SceneTree` está operativo, de modo que los tests integrales pueden observar el lifecycle real de las escenas. En CI se mantiene un timeout explícito para evitar bloqueos silenciosos.

## Validación headless

```bash
godot --headless --path . --editor --quit
godot --headless --path . --quit-after 3
```

## Documentación

- `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`: fuente de verdad funcional y arquitectónica.
- `GAME_DESIGN.md`: diseño resumido del juego.
- `ARCHITECTURE.md`: decisiones técnicas.
- `ROADMAP.md`: fases y criterios de avance.
- `CHANGELOG.md`: cambios relevantes.
- `DEV_MEMORY.md`: memoria operativa para continuar exactamente donde se dejó.
- `PHASE_TEMPLATE.md`: checklist para abrir/cerrar fases sin desincronizar código, CI y documentación.
