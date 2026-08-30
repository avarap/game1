# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase completada más reciente: **Fase 4 — Cementerio**
- Fase activa: **Fase 5 — Simulación**
- Estado Fase 5: bloque 1 tiempo/calendario + sueño implementado y validado; falta ciclo día/noche, NPC base, navegación, rutinas y persistencia NPC antes de cerrar.
- Fuente de verdad: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Último bloque funcional: `62cb2658bd169270fffcb59c34134493b787f327`.
- Última validación funcional: `Godot CI` run `33294728470`, `success`.

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
2. `TimeManager` continúa siendo la única fuente global de tiempo y ahora expone `snapshot()`, `apply_snapshot()`, `set_day()`, `advance_to_next_day()`, `get_weekday_index()` y `get_weekday_name()`.
3. Se implementó la semana ficticia de seis días: Sol, Luna, Hierro, Bosque, Espíritu y Comercio.
4. El rollover de minutos mantiene el avance de día y el nombre de día se repite correctamente cada seis jornadas.
5. `SaveManager` conserva `SAVE_VERSION = 1` y deja de manipular directamente `day/hour/minute`: usa la API de snapshot/restauración de `TimeManager`.
6. Se creó `SleepSpot` como `Interactable` local del mundo. Dormir avanza al siguiente día a las 06:00 y restaura toda la energía del jugador.
7. `world/world.tscn` incluye un `SleepSpot` mínimo y visible, sin introducir sistemas de fases posteriores.
8. Se añadió `test_simulation_time.gd` para calendario, rollover de medianoche, sueño, recuperación de energía y persistencia del tiempo.
9. Commit inicial: `57d9cfdc010398cf5b34764131c7859dd7221084`.
10. CI `33294671978`: importación y smoke test pasaron; la suite detectó que `SleepSpot` asumía que el actor estaba dentro de `SceneTree` durante tests `--script`.
11. Corrección: `SleepSpot` usa su árbol cuando está montado y el `SceneTree` principal como fallback headless seguro.
12. Commit corregido: `62cb2658bd169270fffcb59c34134493b787f327`.
13. Validación final del bloque: `Godot CI` run `33294728470`, `success` en importación, smoke test y suite completa.
14. Fase 5 permanece abierta.

## Decisiones vigentes

- Mantener solo cinco Autoloads globales.
- `TimeManager` es la única fuente de reloj/calendario; otros sistemas observan o invocan su API, no duplican tiempo.
- Inventario, energía, crafting, storage, cementerio, ciclo visual y NPCs deben ser locales/contextuales salvo necesidad demostrada.
- La UI observa modelos/servicios; no posee estado de gameplay.
- Datos de gameplay deben ser Resources tipados cuando corresponda.
- La lógica pura debe ser testeable de forma aislada siempre que sea posible.
- Operaciones que consumen recursos deben ser atómicas o conservar estado recuperable.
- El estado local persistente usa providers `save_provider`.
- Mantener timeout explícito de CI para evitar bloqueos headless silenciosos.
- No entrar en diálogo, relaciones, quests, economía ni tecnologías hasta Fase 6.

## Próximo bloque — Fase 5

1. Implementar ciclo día/noche mínimo observable con un controlador local del mundo.
2. Usar las referencias 06:00 amanecer, 12:00 mediodía, 18:00 atardecer y 22:00 noche.
3. Hacer que el controlador observe `TimeManager`/`EventBus` y module el mundo sin duplicar el reloj.
4. Añadir tests de cálculo/interpolación y aceptación de escena.
5. Validar CI antes de empezar `NPCData`.
6. Después crear primer NPC data-driven con `NavigationAgent2D` y rutina mínima.
7. Mantener Fase 5 abierta hasta persistencia de NPCs y CI final verde.

## Regla de continuidad

Al retomar:
1. Leer este archivo.
2. Leer `ROADMAP.md`.
3. Consultar la fase activa en el master spec.
4. Revisar el último CI de `main`.
5. Implementar un bloque coherente y pequeño.
6. Ejecutar/verificar importación, smoke test y tests.
7. Corregir errores críticos antes de avanzar.
8. Actualizar `DEV_MEMORY.md`, `ROADMAP.md` y `CHANGELOG.md`.
9. No marcar una fase como completada hasta cumplir todos sus criterios.
