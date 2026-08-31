# game1

RPG 2D de gestión, crafting, exploración y simulación construido con **Godot 4.7.2 + GDScript**.

El objetivo es un vertical slice original y pulido. El desarrollo sigue `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`, `ROADMAP.md`, `DEV_MEMORY.md` y las issues activas.

## Estado

- Fases **0–7 completadas**.
- Fase 8 — Polish está **activa**.
- HEAD de referencia de esta sincronización: `81021973025302213dc64ef8f4a4744673c5dd75`.
- CI de ese HEAD: run `33350515654`, success.
- Track 8A tiene integradas descomposición, conservación, agricultura mínima y recurso multiuso (#61 / PR #81). El siguiente bloque funcional es #62.
- Sub-track visual tiene integrados #25, #26, #28 y #29. Quedan #27, #30 y #31.
- #68 sigue abierta, pero ya están integrados el HUD y la base de pause/settings mediante PR #78.
- Gate P0 temporal: no integrar más Fase 8 hasta cerrar #82 y #83 y dejar `main` verde.
- Godot objetivo de runtime/CI: **4.7.2**.
- Rama principal: `main`.

## Ejecutar

1. Instala Godot 4.7.2.
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

La build integrada incluye movimiento, recolección, inventario, energía, crafting/producción, cementerio, tiempo/día-noche, sueño, NPC con navegación/horarios persistentes, diálogo EN/ES, relaciones, quests, economía/comercio y tecnologías.

Track 8A añade:
- deterioro acelerado de cadáveres con estado entero y determinismo temporal;
- conservación data-driven en basis points enteros;
- agricultura mínima persistente basada en `fodder_turnip_seed`/`fodder_turnip`;
- integración multiuso de `fodder_turnip` con storage, economía y crafting mediante PR #81.

El mundo modular conecta cementerio/propiedad, bosque, pueblo, interiores y mina mediante `ZoneManager`, preservando Player, controllers y Brother Aldren durante viajes. `WorldLocationProvider` guarda/resta zona, marker y posición.

## Estado visual

Ya están integrados:
- tileset exterior original (#25);
- props/edificios/cementerio (#28);
- integración artística de mapas (#29 / PR #80);
- player con spritesheet original y animaciones idle/walk 8 direcciones (#26 / PR #75).

Pendientes principales:
- Brother Aldren visual + base reutilizable de NPC (#27);
- atmósfera, iluminación, vegetación y partículas (#30);
- aceptación visual integral (#31).

### Quality bar visual obligatorio

La referencia aprobada es un mockup pixel-art oscuro del cuidador del cementerio con alto detalle. El juego debe mantener:
- personajes detallados y legibles;
- 8 direcciones coherentes;
- ropa/equipamiento reconocibles;
- paleta medieval oscura rica pero controlada;
- iluminación cálida localizada y sombras profundas;
- entorno denso con props/vegetación integrados;
- ausencia de placeholders, blockout o escenarios visualmente vacíos.

Los tests técnicos verdes no bastan para aceptar un downgrade visual. Si el frame humano contractual 32x48 impide mantener ese detalle, debe reevaluarse escala/resolución antes de bajar calidad.

## UI

PR #78 integró theme reutilizable, HUD de estado y base de pause/settings localizada EN/ES. #68 permanece abierta porque aún faltan paneles/UX y aceptación completa.

## Gate P0 temporal

Antes de seguir fusionando trabajo de Fase 8:

- #82 debe añadir el test de regresión de Brother Aldren tras save/load en cementerio, comprobando posición y estado/rutina persistidos.
- #83 debe sincronizar la documentación global con el HEAD real.
- `main` debe quedar verde después de ambos cierres.

Los workers pueden preparar trabajo independiente durante este gate, pero el supervisor no lo integra todavía.

## Arquitectura

Los Autoloads se limitan a cinco servicios globales: `EventBus`, `GameManager`, `TimeManager`, `SaveManager` y `AudioManager`.

Los sistemas RPG permanecen locales/contextuales y usan Resources tipados. UI observa modelos/controladores y emite intents; no contiene reglas de negocio.

`SaveManager` agrega providers del grupo `save_provider`. `world/world.tscn` es el shell persistente y carga una zona activa bajo `ZoneContainer`.

## Calidad y tests

El CI ejecuta dos gates independientes:

- `gdscript-quality`: descubre todos los `*.gd` y ejecuta `gdlint` + `gdformat --check` globalmente.
- `validate-and-test`: importación Godot 4.7.2, smoke test y suite headless completa.

Validaciones recientes:

- Cierre Fase 7 #24: PR #54, run `33331207740`.
- Props/edificios/cementerio #28: main run `33340142216`.
- Agricultura mínima 8A.3: main run `33342619691`.
- Integración artística #29: PR #80, main run `33350442187`.
- Player visual #26: PR #75, main run `33350515654`.

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

## Cola autónoma de trabajo

- #82 — GAMEPLAY/QA: regresión save/load de Aldren.
- #84 — CHARACTERS: Brother Aldren visual, referencia #27.
- #85 — WORLD: atmósfera/lighting/FX, referencia #30.
- #86 — UI: visual/UX pass de paneles core, referencia #68.

## Documentación

- `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`: fuente funcional y arquitectónica.
- `ROADMAP.md`: fases, dependencias, gates y cola de trabajo.
- `DEV_MEMORY.md`: memoria operativa.
- `ART_DIRECTION.md`: contrato visual y técnico.
- `CHANGELOG.md`: historial técnico relevante.
- `HISTORIA_PRINCIPAL.md`: dirección narrativa.
- `LOCALIZATION.md`: política EN/ES.
- `docs/design/`: biblioteca secundaria de ideas/backlog; no sustituye roadmap activo.

## Post-MVP

Queda registrado un sistema futuro de automatización avanzada con trabajadores originales del universo de `game1` y tareas `HARVEST`, `MINE`, `CHOP`, `TRANSPORT` y `PROCESS`, evolucionando de trabajo manual a cadenas automatizadas mediante infraestructura, rutas y almacenamiento.
