# game1

RPG 2D de gestión, crafting, exploración y simulación construido con **Godot 4.7.2 + GDScript**.

El objetivo es un vertical slice original y pulido. El desarrollo sigue `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`, `ROADMAP.md`, `DEV_MEMORY.md` y las issues activas.

## Estado

- Fases **0–7 completadas**.
- Fase 8 — Polish está **activa**.
- HEAD de referencia de esta sincronización: `16f13eeaa306a048c7c397cc6b6687585b15b3f1`.
- CI de ese HEAD: run `33372934693`, success.
- Gate P0 temporal #82/#83: **superado**.
- Track 8A tiene integradas 8A.1–8A.5; 8A.6 tiene implementación en PR #101 con CI verde en su head previo y pendiente de actualización/revisión contra el HEAD actual.
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

Track 8A añade deterioro y conservación deterministas, agricultura mínima persistente, `fodder_turnip` integrado en storage/economía/crafting y el servicio funerario de #62: entrega diaria a las 18:00, primera gratuita y siguientes condicionadas al consumo real de `fodder_turnip`, con comportamiento exactly-once en tiempo normal, saltos, sueño y save/load. Este bloque se integró mediante PR #99.

El mundo modular conecta cementerio/propiedad, bosque, pueblo, interiores y mina mediante `ZoneManager`, preservando Player, controllers y Brother Aldren durante viajes. `WorldLocationProvider` guarda/resta zona, marker y posición. PR #92 añadió el test de regresión específico de Brother Aldren en cementerio.

## Estado visual

En `main` están integrados tileset exterior (#25), props/edificios/cementerio (#28), integración artística de mapas (#29), player 8 direcciones (#26), el incremento visual de Brother Aldren de PR #89, atmósfera/lighting/FX de PR #90 y paneles core UI de PR #91. PR #102 corrigió el error runtime de densidad de las motas `CPUParticles2D` y añadió regresión live SceneTree.

El commit `16f13ee` añadió capturas JPG bajo `docs/`. Se conservan como referencias visuales, pero no se consideran por sí mismas evidencia determinista de aceptación: #96 debe proporcionar un flujo reproducible y asociar explícitamente las capturas al HEAD evaluado.

La integración técnica no implica aceptación visual final: #94 debe decidir si 32x48 puede sostener el estándar de personaje y #96 debe proporcionar capturas reproducibles. #27/#30/#31 y la aceptación UI global no deben darse por completadas hasta satisfacer esos gates.

### Quality bar visual obligatorio

La referencia aprobada es un mockup pixel-art oscuro del cuidador del cementerio con alto detalle. El juego debe mantener personajes detallados y legibles, 8 direcciones coherentes, ropa/equipamiento reconocibles, paleta medieval oscura rica pero controlada, iluminación cálida localizada, sombras profundas, entorno denso con props/vegetación integrados y ausencia de placeholders/blockout. Si 32x48 impide ese detalle, debe reevaluarse escala/resolución antes de aceptar un downgrade.

## UI

PR #78 integró theme reutilizable, HUD y base de pause/settings EN/ES. PR #91 integró el incremento de paneles core. #68 permanece abierta hasta completar la aceptación UI/visual correspondiente.

## Gate P0 temporal

El gate iniciado sobre HEAD `8102197` está **cerrado**: #82 se integró mediante PR #92, #83 está cerrada y el `main` actual `16f13eeaa306a048c7c397cc6b6687585b15b3f1` tiene CI run `33372934693` en success.

## Arquitectura

Los Autoloads se limitan a `EventBus`, `GameManager`, `TimeManager`, `SaveManager` y `AudioManager`. Los sistemas RPG permanecen locales/contextuales y usan Resources tipados. UI observa modelos/controladores y emite intents; no contiene reglas de negocio. `SaveManager` agrega providers del grupo `save_provider`; `world/world.tscn` es el shell persistente y carga una zona activa bajo `ZoneContainer`.

## Calidad y tests

El CI ejecuta `gdscript-quality` (`gdlint` + `gdformat --check`) y `validate-and-test` (import Godot 4.7.2, smoke y suite headless completa).

Validaciones recientes:

- Cierre Fase 7 #24: PR #54, run `33331207740`.
- Agricultura mínima 8A.3: run `33342619691`.
- Integración artística #29: run `33350442187`.
- Player visual #26: run `33350515654`.
- Aldren save/load #82: run `33356344828`.
- Servicio funerario PR #99: exact head run `33359942851`.
- Main tras PR #90/#91: run `33364746590`.
- Main tras PR #102: run `33369187753`.
- Main actual tras incorporación de referencias visuales `docs/`: run `33372934693`.

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

## Cola autónoma de trabajo

- GAMEPLAY: #100 tiene PR activo #101; no preparar otra tarea hasta resolverlo.
- #93 — AUDIO: routing/ambiente/mezcla.
- #94 — ARCH: reevaluación de escala/resolución visual.
- #96 — QA: capturas visuales deterministas.
- CHARACTERS no recibe nueva tarea mientras #94/#96 bloqueen el siguiente paso.
- WORLD/UI: el código incremental está integrado; su aceptación visual pendiente no se considera trabajo autónomo desbloqueado mientras dependa de #96.

No se prepara una segunda tarea por carril mientras exista una issue preparada o PR activo.

## Documentación

- `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`: fuente funcional y arquitectónica.
- `ROADMAP.md`: fases, dependencias, gates y cola.
- `DEV_MEMORY.md`: memoria operativa.
- `ART_DIRECTION.md`: contrato visual y técnico.
- `CHANGELOG.md`: historial técnico.
- `HISTORIA_PRINCIPAL.md`: narrativa.
- `LOCALIZATION.md`: política EN/ES.
- `docs/design/`: biblioteca secundaria; no sustituye roadmap activo.

## Post-MVP

Se conserva la automatización avanzada con trabajadores originales de `game1` y tareas `HARVEST`, `MINE`, `CHOP`, `TRANSPORT` y `PROCESS`, evolucionando de trabajo manual a cadenas automatizadas mediante infraestructura, rutas y almacenamiento.
