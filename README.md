# game1

RPG 2D de gestión, crafting, exploración y simulación construido con **Godot 4.x + GDScript**.

El objetivo actual es un vertical slice original y muy pulido. El desarrollo sigue `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md` y avanza fase por fase, manteniendo el proyecto ejecutable tras cada cambio importante.

## Estado

- Fase completada: **Fase 0 — Bootstrap**
- Próxima fase: **Fase 1 — Core / Walking Prototype**
- Godot objetivo de CI: **4.5**
- Rama principal: `main`
- Memoria de desarrollo: `DEV_MEMORY.md`
- CI: importación, ejecución smoke-test de `main.tscn` y tests headless validados correctamente.

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

## Arquitectura

Los Autoloads se limitan a servicios globales reales: `EventBus`, `GameManager`, `TimeManager`, `SaveManager` y `AudioManager`. Los sistemas de gameplay permanecerán desacoplados y preferentemente basados en Resources tipados.

## Tests

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
- `GAME_DESIGN.md`: diseño resumido del juego.
- `ARCHITECTURE.md`: decisiones técnicas.
- `ROADMAP.md`: fases y criterios de avance.
- `CHANGELOG.md`: cambios relevantes.
- `DEV_MEMORY.md`: memoria operativa para continuar exactamente donde se dejó.
