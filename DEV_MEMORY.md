# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase completada más reciente: **Fase 4 — Cementerio**
- Fase activa: **Fase 5 — Simulación**
- Estado Fase 5: tiempo/calendario, sueño y ciclo día/noche implementados y validados; falta NPC base, navegación, rutinas y persistencia NPC antes de cerrar.
- Fuente de verdad: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Último bloque funcional: `5c6467c5aad04b1d44c48cceef2280af5d049bf8`.
- Última validación funcional y de calidad: `Godot CI` run `33295805020`, `success` en `gdscript-quality` y `validate-and-test`.

## Fases completadas

### Fase 0 — Bootstrap
- Godot 4.x, escena raíz, cinco Autoloads: `EventBus`, `GameManager`, `TimeManager`, `SaveManager`, `AudioManager`.
- InputMap, logging, panel debug, guardado versionado, tests y CI headless.
- Validación: run `33278173612`, `success`.

### Fase 1 — Core / Walking Prototype
- `world/world.tscn`, jugador `CharacterBody2D`, movimiento 8 direcciones, cámara, colisiones, Y-sort, `InteractionArea` e `Interactable`.
- Validación final: run `33280758441`, `success`.

### Fase 2 — Items / Resource Loop
- `ItemData`, inventario data-driven, `EnergyComponent`, recursos recolectables, herramientas, loot y atomicidad.
- Implementación final: `c196e3ab5a42adffe97278f0b0daa8960c789e04`.
- Validación: run `33285578050`, `success`.

### Fase 3 — Crafting / Production Loop
- Recetas tipadas, crafting instantáneo, `StorageNetwork`, cofres, producción temporizada y colas recuperables.
- Validación final: `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`, `success`.

### Fase 4 — Cementerio
- `CorpseData`, `CorpseState`, `GraveRecord`, `CemeteryModel`, rating data-driven y `CemeteryService`.
- `CemeteryController` local con interactuables de recepción, preparación, entierro y mejora.
- Persistencia por snapshots y providers locales de `SaveManager`.
- Tests de foundation, flujo, gameplay y persistencia.
- Validación final: corrección `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`, `success`.

## Fase 5 — Simulación

### Bloque 1 — Tiempo, calendario y sueño
1. Se releyeron las secciones 14.3, 23, 24 y 25 del master spec antes de implementar.
2. `TimeManager` continúa siendo la única fuente global de tiempo y expone snapshot/restauración, avance de día y semana ficticia de seis días.
3. Se creó `SleepSpot` como `Interactable` local del mundo. Dormir avanza al siguiente día a las 06:00 y restaura toda la energía del jugador.
4. `test_simulation_time.gd` cubre calendario, rollover, sueño y persistencia del tiempo.
5. Implementación inicial: `57d9cfdc010398cf5b34764131c7859dd7221084`.
6. Corrección headless: `62cb2658bd169270fffcb59c34134493b787f327`.
7. Validación final del bloque: `Godot CI` run `33294728470`, `success`.

### Hardening transversal previo al bloque 2
1. `StorageProvider.scope_id` y `storage_scope` limitan redes de almacenamiento por contexto.
2. Jugador y cofres exponen componentes por contrato/tipo; crafting, recolección y sueño no dependen de nombres internos.
3. `CemeteryAction` usa inyección tipada o grupo `cemetery_controller` en lugar de `NodePath` relativo.
4. Se eliminó código muerto de cementerio.
5. Se añadió `gdscript-quality` con `gdlint` y `gdformat --check`, manteniendo el job Godot separado.
6. Implementación principal: `0639a43b16c152bf7a8b9ad3b44e2aa4aa640a8a`.
7. Desacoplamiento final: `b13d024143b5fb0ff8118a689da079c37916c554`.
8. Validación final: run `33295277286`, ambos jobs `success`.

### Bloque 2 — Ciclo día/noche observable
1. Se releyó la especificación del ciclo visual: `CanvasModulate`/luces/shaders cuando aporten valor y referencias 06:00, 12:00, 18:00 y 22:00.
2. Se creó `DayNightMath`, lógica pura que normaliza hora/minuto, determina fase visual y calcula interpolación gradual de color.
3. Las referencias son: 06:00 amanecer, 12:00 mediodía, 18:00 atardecer y 22:00 noche.
4. La transición nocturna cruza medianoche de forma continua hasta el amanecer; no existe salto de color a las 00:00.
5. Se creó `DayNightController` local como `CanvasModulate`; observa la señal `time_changed` y aplica el resultado de `DayNightMath` sin duplicar el reloj.
6. El controller resuelve `EventBus` y `TimeManager` desde `/root` en `_ready()` para mantener compatibilidad con ejecución headless `--script`.
7. `world/world.tscn` incluye `DayNightCycle` como nodo local; no se añadieron nuevos Autoloads.
8. `test_day_night_cycle.gd` valida colores de referencia, interpolación, fases y presencia/aplicación del controller en la escena del mundo.
9. `tests/run_tests.gd` incorpora la suite `DayNightCycle` y el quality gate se amplió incrementalmente a los nuevos scripts/tests.
10. Implementación inicial: `5ea87dda3ce3b4dda9d09d8dadebcddd7d6a0a26`.
11. Run `33295708310` detectó dos líneas >100 caracteres en el nuevo test.
12. Corrección de lint: `f0c014bdebb13135428be1857e035ea8f6d70525`; run `33295738329` dejó lint verde pero detectó formato pendiente de `DayNightMath` y resolución de Autoload incompatible con `--script`.
13. Corrección final: `5c6467c5aad04b1d44c48cceef2280af5d049bf8`.
14. Validación final del bloque: `Godot CI` run `33295805020`, `success` en lint, format-check, importación, smoke test y suite headless completa.
15. El criterio "Ciclo día/noche observable por el mundo" queda cumplido; Fase 5 permanece abierta.

## Decisiones vigentes

- Mantener solo cinco Autoloads globales.
- `TimeManager` es la única fuente de reloj/calendario; otros sistemas observan o invocan su API, no duplican tiempo.
- El ciclo visual es local al mundo y deriva su estado exclusivamente de `TimeManager`/`EventBus`.
- La interpolación visual queda encapsulada en lógica pura (`DayNightMath`) para poder probarla sin escena/render.
- Inventario, energía, crafting, storage, cementerio, ciclo visual y NPCs deben ser locales/contextuales salvo necesidad demostrada.
- `StorageProvider.scope_id` limita redes de almacenamiento por contexto/zona.
- Los sistemas externos acceden a capacidades del actor mediante contratos y no mediante nombres de nodos internos.
- Dependencias entre escenas deben preferir inyección tipada o grupos con semántica explícita frente a `NodePath` relativos frágiles.
- La UI observa modelos/servicios; no posee estado de gameplay.
- Datos de gameplay deben ser Resources tipados cuando corresponda.
- La lógica pura debe ser testeable de forma aislada siempre que sea posible.
- Operaciones que consumen recursos deben ser atómicas o conservar estado recuperable.
- El estado local persistente usa providers `save_provider`.
- Mantener timeout explícito de CI para evitar bloqueos headless silenciosos.
- `gdscript-quality` es un gate adicional; la autoridad funcional continúa siendo importación/smoke/tests de Godot.
- Ampliar cobertura de gdtoolkit incrementalmente con cada bloque nuevo.
- No entrar en diálogo, relaciones, quests, economía ni tecnologías hasta Fase 6.

## Próximo bloque — Fase 5

1. Crear `NPCData` data-driven con la información mínima requerida para un NPC de prueba.
2. Crear un primer NPC local en el mundo con `NavigationAgent2D` y movimiento básico hacia destinos explícitos.
3. Mantener la lógica de navegación separada de diálogos/quests y sin entrar todavía en Fase 6.
4. Añadir tests de datos, escena y transición básica de navegación.
5. Incluir los nuevos scripts en `gdscript-quality` y validar CI completo.
6. Después implementar horarios/rutinas con estados mínimos Idle/Walking/Working/Sleeping.
7. Mantener Fase 5 abierta hasta persistencia mínima de posición/estado de NPCs y CI final verde.

## Regla de continuidad

Al retomar:
1. Leer este archivo.
2. Leer `ROADMAP.md`.
3. Consultar la fase activa en el master spec.
4. Revisar el último CI de `main`.
5. Implementar un bloque coherente y pequeño.
6. Ejecutar/verificar quality gate, importación, smoke test y tests.
7. Corregir errores críticos antes de avanzar.
8. Actualizar `DEV_MEMORY.md`, `ROADMAP.md` y `CHANGELOG.md`.
9. No marcar una fase como completada hasta cumplir todos sus criterios.
