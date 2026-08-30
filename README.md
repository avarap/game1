# game1

RPG 2D de gestión, crafting, exploración y simulación construido con **Godot 4.7.2 + GDScript**.

El objetivo es un vertical slice original y pulido. El desarrollo sigue `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`, `ROADMAP.md`, `DEV_MEMORY.md` y las issues de cada fase.

## Estado

- Fases **0–7 completadas**.
- Fase 7 — Mundo cerrada mediante #24 / PR #54.
- Fase 8 — Polish está **activa**.
- Track 8A: descomposición, conservación y agricultura mínima ya integradas; siguiente bloque funcional #61 / 8A.4.
- Sub-track visual: #25 y #28 integradas; #26/#29 siguen pendientes de integración segura.
- Godot objetivo de runtime/CI: **4.7.2**.
- Rama principal: `main`.
- Contrato visual obligatorio: `ART_DIRECTION.md`.

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

La build técnica integra movimiento, recolección, inventario, energía, crafting/producción, cementerio, tiempo/día-noche, sueño, NPC con navegación/horarios persistentes, diálogo EN/ES, relaciones, quests, economía/comercio y tecnologías.

El track 8A añade deterioro acelerado de cadáveres, conservación data-driven y agricultura mínima persistente basada en `fodder_turnip_seed`/`fodder_turnip`, con crecimiento gobernado por `TimeManager`, cosecha exactly-once y snapshot/restore determinista.

El mundo modular conecta cementerio/propiedad, bosque, pueblo, interiores y mina mediante `ZoneManager`, conservando una sola instancia lógica del Player y los controllers persistentes. `WorldLocationProvider` guarda/resta zona, marker y posición; la cámara adapta sus bounds a cada zona.

Hermano Aldren mantiene diálogo data-driven, relación, quest, schedule y persistencia. La economía usa compra/venta atómica y el sistema tecnológico soporta recompensas tipadas e idempotentes desde quests.

## Contrato visual

`ART_DIRECTION.md` fija proyección 2D ortográfica cenital 3/4, tile lógico de 32 px, frame humano 32x48 px, pivote/Y-sort en pies, resolución 1280x720 a zoom base 1.5x y seis capas de mapa:

- `ground`
- `paths`
- `decoration_low`
- `collision`
- `objects_y_sorted`
- `foreground_occlusion`

Fase 8 debe sustituir progresivamente la representación técnica por arte/polish respetando este contrato, sin reabrir alcance funcional salvo bugs críticos.

## Arquitectura

Los Autoloads se limitan a cinco servicios globales: `EventBus`, `GameManager`, `TimeManager`, `SaveManager` y `AudioManager`.

Los sistemas RPG permanecen locales/contextuales y usan Resources tipados. `QuestService`, `EconomyService` y `TechnologyService` contienen lógica de negocio testeable; sus controllers conectan mundo/persistencia sin convertirse en servicios globales.

`SaveManager` agrega providers del grupo `save_provider`. El mundo usa `world/world.tscn` como shell persistente y carga una zona activa bajo `ZoneContainer`.

## Calidad y tests

El CI ejecuta dos gates independientes:

- `gdscript-quality`: descubre todos los `*.gd` y ejecuta `gdlint` + `gdformat --check` globalmente.
- `validate-and-test`: importación Godot 4.7.2, smoke test y suite headless completa.

`TestWorldPhase7Acceptance` agrega los contratos de mapas, recorrido, navegación y rutinas NPC como gate final de Fase 7.

Validaciones recientes:

- Cierre Fase 6: PR #39, run `33308814397`.
- Godot 4.7.2: PR #41, run `33309144543`.
- Cierre Fase 7 #24: PR #54, run `33331207740`.
- Props/edificios/cementerio #28: PR #79, main run `33340142216`.
- Agricultura mínima 8A.3 / #60: PR #76, main run `33342619691`.

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

## Documentación

- `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`: fuente funcional y arquitectónica.
- `ROADMAP.md`: fases, dependencias y criterios de avance.
- `DEV_MEMORY.md`: memoria operativa.
- `ART_DIRECTION.md`: contrato visual y técnico para mapas/assets.
- `CHANGELOG.md`: historial técnico relevante.
- `HISTORIA_PRINCIPAL.md`: dirección narrativa spoiler-light.
- `LOCALIZATION.md`: política EN/ES.
- `docs/design/`: biblioteca secundaria de ideas, backlog, orden futuro y prompts; no sustituye el roadmap activo.
