# game1 — Biblioteca de diseño

Esta carpeta captura ideas de diseño, mejoras y líneas de expansión derivadas del análisis del proyecto y de referencias visuales de juegos de gestión/RPG. Las referencias se usan como benchmark funcional, de densidad, legibilidad y progresión; no se copian mapas, sprites, UI, nombres, textos, recetas, personajes ni contenido protegido.

## Reglas

1. `ROADMAP.md`, `DEV_MEMORY.md`, `GAME_DESIGN.md`, `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md` y specs aprobadas siguen siendo fuentes de verdad para ejecución.
2. Estos documentos son backlog/dirección de diseño. No adelantan fases ni convierten ideas post-MVP en alcance activo.
3. Todo sistema nuevo debe ser data-driven cuando sea razonable: añadir contenido no debe requerir condicionales hardcodeados por item/NPC/receta.
4. Cada idea se clasifica como `MVP`, `POST-MVP` o `EXPERIMENTAL`.
5. La prioridad es profundidad conectada antes que cantidad de contenido.

## Índice

- `00_VISION.md` — pilares y identidad.
- `01_EXECUTION_ORDER.md` — orden recomendado y dependencias.
- `02_GAMEPLAY_LOOP.md` — loop principal y loops secundarios.
- `03_WORLD_AND_ZONES.md` — mundo, densidad y restauración.
- `04_RESOURCES_AND_GATHERING.md` — catálogo y obtención.
- `05_CRAFTING_AND_PRODUCTION.md` — recetas, subproductos y cadenas.
- `06_TECHNOLOGY_TREE.md` — grafo de desbloqueos.
- `07_BUILDING_AND_WORKSHOP.md` — estaciones y crecimiento físico.
- `08_ECONOMY_AND_TRADING.md` — comercio por profesión.
- `09_FARMING.md` — agricultura extensible.
- `10_NPCS_AND_QUESTS.md` — mundo vivo y progresión social.
- `11_CEMETERY_AND_RESTORATION.md` — identidad central del juego.
- `12_DAY_NIGHT_WEATHER.md` — tiempo, iluminación y clima.
- `13_COMBAT_AND_EXPLORATION.md` — peligros, secretos y exploración.
- `14_AUTOMATION_AND_WORKERS.md` — automatización tardía.
- `15_UI_UX.md` — HUD y pantallas contextuales.
- `16_ART_AND_ATMOSPHERE.md` — densidad visual y atmósfera.
- `17_PROGRESSION.md` — progresión sistémica y visible.
- `18_DATA_ARCHITECTURE.md` — contratos data-driven.
- `19_IDEA_BACKLOG.md` — ideas priorizadas.
- `20_IMPLEMENTATION_PROMPTS.md` — prompts para elaborar/implementar cada bloque.

## Orden de lectura

Para decidir qué construir: `00` → `01` → categoría correspondiente → `18` → prompt de `20`.
