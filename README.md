# game1

RPG 2D de gestión, crafting, exploración y simulación construido con **Godot 4.x + GDScript**.

El objetivo actual es un vertical slice original y muy pulido. El desarrollo sigue `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md` y avanza fase por fase, manteniendo el proyecto ejecutable tras cada cambio importante.

## Estado

- Fases completadas: **0 — Bootstrap, 1 — Core, 2 — Items, 3 — Crafting, 4 — Cementerio**
- Próxima fase: **Fase 5 — Simulación**
- Godot objetivo de CI: **4.5**
- Rama principal: `main`
- Memoria de desarrollo: `DEV_MEMORY.md`
- Última validación de fase: **Godot CI `33294286014` — success**

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

La build técnica actual permite probar movimiento, recolección, inventario, crafting/producción y el loop mínimo de cementerio. En la zona inicial existen interactuables para recibir un cadáver de prueba, prepararlo, enterrarlo y mejorar la tumba con lápida, valla y decoración. El estado del cementerio se integra con el guardado versionado.

## Arquitectura

Los Autoloads se limitan a servicios globales reales: `EventBus`, `GameManager`, `TimeManager`, `SaveManager` y `AudioManager`. Los sistemas de gameplay permanecen desacoplados, locales/contextuales cuando corresponde y preferentemente basados en Resources tipados.

`SaveManager` agrega estado persistente de sistemas locales mediante providers del grupo `save_provider`, evitando acoplar el Autoload a implementaciones concretas como cementerio, NPCs o futuros sistemas del mundo.

## Tests

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

En CI la suite usa un timeout explícito para evitar bloqueos silenciosos.

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
