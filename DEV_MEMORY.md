# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase completada más reciente: **Fase 4 — Cementerio**
- Fase activa: **Fase 5 — Simulación**
- Estado Fase 5: tiempo/calendario, sueño, ciclo día/noche, `NPCData`, navegación y rutinas/horarios implementados y validados; falta persistencia mínima de NPCs y aceptación final antes de cerrar.
- Fuente de verdad: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Último bloque funcional: `82f5ccee1e109e2ad702532b7301922124548c7b`.
- Última validación funcional y de calidad: `Godot CI` run `33296648630`, `success` en `gdscript-quality` y `validate-and-test`.

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
1. `TimeManager` continúa siendo la única fuente global de tiempo y expone snapshot/restauración, avance de día y semana ficticia de seis días.
2. `SleepSpot` avanza al siguiente día a las 06:00 y restaura toda la energía del jugador.
3. `test_simulation_time.gd` cubre calendario, rollover, sueño y persistencia del tiempo.
4. Implementación inicial: `57d9cfdc010398cf5b34764131c7859dd7221084`.
5. Corrección headless: `62cb2658bd169270fffcb59c34134493b787f327`.
6. Validación final: run `33294728470`, `success`.

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
1. `DayNightMath` encapsula normalización, fases e interpolación gradual.
2. Referencias: 06:00 amanecer, 12:00 mediodía, 18:00 atardecer y 22:00 noche.
3. La transición nocturna cruza medianoche sin salto visual.
4. `DayNightController` local usa `CanvasModulate`, observa `time_changed` y deriva su estado de `TimeManager`.
5. `world/world.tscn` incorpora `DayNightCycle`; no se añade ningún Autoload.
6. `test_day_night_cycle.gd` cubre referencias, interpolación, fases e integración.
7. Implementación inicial: `5ea87dda3ce3b4dda9d09d8dadebcddd7d6a0a26`.
8. `f0c014bdebb13135428be1857e035ea8f6d70525` corrigió lint; el siguiente CI detectó formato y resolución de Autoload bajo `--script`.
9. Corrección final: `5c6467c5aad04b1d44c48cceef2280af5d049bf8`.
10. Validación final: run `33295805020`, ambos jobs `success`.

### Bloque 3 — NPCData y navegación básica
1. Se releyó la sección 25 del master spec: datos NPC desacoplados, uso obligatorio de `NavigationAgent2D` y estados/rutinas como bloque posterior.
2. Se creó `NPCData` como `Resource` tipado con `id`, `display_name`, `role` y `move_speed`, además de validación mínima.
3. Se añadió `data/npcs/brother_aldren.tres` para el primer NPC original: Hermano Aldren, sacerdote excéntrico.
4. Se creó `NPCNavigationMath`, lógica pura para velocidad direccional y comprobación de llegada.
5. Se creó `WorldNavigationRegion`, `NavigationRegion2D` local que genera la geometría navegable mínima del mapa sin nuevo Autoload.
6. Se creó `NPCController` sobre `CharacterBody2D` con `NavigationAgent2D`, movimiento frame-independent mediante `move_and_slide()` y señal de llegada.
7. `world/npcs/brother_aldren.tscn` encapsula visual provisional, colisión y agente de navegación.
8. `world/world.tscn` integra `NavigationRegion` y una instancia de `BrotherAldren`.
9. `test_npc_navigation.gd` valida `NPCData`, matemática de navegación, geometría de navegación, presencia del NPC y `NavigationAgent2D`.
10. La suite principal y `gdscript-quality` incluyen los nuevos scripts/tests.
11. Run `33296112250` detectó `class-definitions-order` en `NPCController`; no se relajó la regla.
12. Corrección final: `03986401968c83b79527d15f47217f090de43ab2`.
13. Validación final: `Godot CI` run `33296131085`, `success` en lint, format-check, importación, smoke test y suite headless.
14. Quedan cumplidos los criterios `NPCData data-driven y primer NPC de prueba` y `NavigationAgent2D y navegación básica`.

### Bloque 4 — ScheduleData y rutinas NPC
1. Se revisó el HEAD externo `e2d1351d31576407caed9c983457c09c0a1e93c3`: solo añadió documentación/configuración auxiliar y su CI estaba verde; no alteró gameplay.
2. Se añadieron `ScheduleEntryData` y `ScheduleData` tipados. Las franjas soportan máscara de los seis días, rangos horarios normales o cruzando medianoche, estado de actividad y destino.
3. Se añadió `NPCStateMachine` con estados explícitos mínimos `Idle`, `Walking`, `Working` y `Sleeping`; `Walking` es transitorio mientras el agente navega al estado programado.
4. `brother_aldren_schedule.tres` define una rutina mínima completa: mañana idle, trabajo diurno, descanso vespertino y sueño nocturno.
5. `NPCController` observa `TimeManager` mediante `EventBus`, selecciona la franja correspondiente sin duplicar reloj y mantiene `NavigationAgent2D` como mecanismo de movimiento.
6. El destino inicial ad hoc de Aldren se eliminó del mundo; sus destinos pasan a ser propiedad de los datos de horario.
7. `test_npc_routines.gd` cubre resolución horaria, rango nocturno que cruza medianoche, transiciones `Walking -> Working`, `Sleeping` e integración del horario en escena.
8. `test_npc_navigation.gd` se actualizó para exigir un `ScheduleData` válido en lugar del antiguo `initial_target`.
9. `gdscript-quality` cubre todos los nuevos scripts y tests.
10. Run `33296549903` dejó lint/formato verdes pero detectó un error real: `ScheduleEntryData` comparaba el `Dictionary` devuelto por `TimeMath.normalize_total_minutes()` con enteros, degradando además los subresources de horario a `Resource`.
11. La corrección `82f5ccee1e109e2ad702532b7301922124548c7b` normaliza minutos como entero con `posmod()` y mantiene los Resources tipados operativos.
12. Validación final del bloque: `Godot CI` run `33296648630`, `success` en lint, format-check, importación, smoke test y suite headless completa.
13. Durante la revisión se detectó que el archivo subido como `editorconfig` no era reconocido por EditorConfig; se renombró correctamente a `.editorconfig`.
14. Queda cumplido el criterio `Rutinas/horarios con estados mínimos Idle/Walking/Working/Sleeping`.
15. Fase 5 permanece abierta.

## Decisiones vigentes

- Mantener solo cinco Autoloads globales.
- `TimeManager` es la única fuente de reloj/calendario; otros sistemas observan o invocan su API.
- Ciclo visual y NPCs son sistemas locales/contextuales.
- `NPCData` contiene identidad/configuración estable; `ScheduleData` contiene horarios/destinos y `NPCStateMachine` contiene el estado runtime.
- `Walking` es un estado transitorio: al llegar, el NPC adopta el estado de actividad programado (`Idle`, `Working` o `Sleeping`).
- El primer NPC usa `NavigationAgent2D`; no sustituir navegación por movimiento directo ad hoc.
- El `NavigationRegion2D` actual es geometría mínima de validación. Obstáculos/baking complejo pertenecen al crecimiento del mundo, no a esta fase.
- No introducir diálogo, relaciones, quests, economía ni tecnologías antes de Fase 6.
- `StorageProvider.scope_id` limita redes de almacenamiento por contexto/zona.
- Dependencias entre escenas deben preferir inyección tipada, contratos o grupos con semántica explícita frente a `NodePath` frágiles.
- La UI observa modelos/servicios; no posee estado de gameplay.
- Datos de gameplay deben ser Resources tipados cuando corresponda.
- La lógica pura debe ser testeable de forma aislada siempre que sea posible.
- El estado local persistente usa providers `save_provider`.
- `gdscript-quality` es un gate adicional; la autoridad funcional continúa siendo importación/smoke/tests de Godot.
- Ampliar cobertura de gdtoolkit incrementalmente con cada bloque nuevo.

## Próximo bloque — Fase 5

1. Añadir snapshot/restauración mínima de NPC (`id`, posición, estado actual/pending y destino cuando aplique) sin almacenar datos derivados innecesarios.
2. Integrar el NPC como `save_provider` local compatible con `SaveManager`, sin añadir Autoloads.
3. Probar save/load de posición y estado y que, tras restaurar, las futuras señales de `TimeManager` vuelven a gobernar la rutina.
4. Ejecutar test de aceptación final de Fase 5: reloj + día/noche + sueño + navegación + rutina + persistencia NPC.
5. Validar `gdscript-quality`, importación, smoke test y suite headless.
6. Solo si todos los criterios quedan en `[x]`, sincronizar `README.md`, `ROADMAP.md`, `DEV_MEMORY.md` y `CHANGELOG.md` y cerrar Fase 5.
7. No entrar en diálogo, relaciones, quests, economía ni tecnologías hasta abrir Fase 6.

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
