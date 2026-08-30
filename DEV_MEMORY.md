# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase completada más reciente: **Fase 5 — Simulación**
- Fase activa: **Fase 6 — RPG**
- Estado Fase 5: **COMPLETADA**. Reloj/calendario, sueño, ciclo día/noche, `NPCData`, navegación, rutinas/horarios y persistencia NPC están implementados y validados.
- Fuente de verdad: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Último bloque funcional de Fase 5: `f0290951a27d5e66581da2532151d957ec35075e`.
- Última validación funcional de Fase 5: `Godot CI` run `33297774458`, `success` en `gdscript-quality` y `validate-and-test`.

## Fases completadas

### Fase 0 — Bootstrap
- Godot 4.x, escena raíz, cinco Autoloads: `EventBus`, `GameManager`, `TimeManager`, `SaveManager`, `AudioManager`.
- InputMap, logging, debug, guardado versionado, tests y CI headless.
- Validación: run `33278173612`, `success`.

### Fase 1 — Core / Walking Prototype
- Mundo base, jugador `CharacterBody2D`, movimiento 8 direcciones, cámara, colisiones, Y-sort e interacción reusable.
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
- Gameplay contextual de recepción, preparación, entierro y mejoras.
- Persistencia por providers locales de `SaveManager`.
- Validación final: corrección `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`, `success`.

### Fase 5 — Simulación

#### Bloque 1 — Tiempo, calendario y sueño
1. `TimeManager` es la única fuente global de reloj/calendario y expone snapshot/restauración, avance de día y semana ficticia de seis días.
2. `SleepSpot` avanza al siguiente día a las 06:00 y restaura la energía del jugador.
3. `test_simulation_time.gd` cubre calendario, rollover, sueño y persistencia temporal.
4. Corrección final: `62cb2658bd169270fffcb59c34134493b787f327`.
5. Validación: run `33294728470`, `success`.

#### Hardening transversal
1. Storage limitado por `scope_id`/`storage_scope`.
2. Dependencias entre escenas endurecidas mediante contratos/tipos/grupos en vez de nombres o `NodePath` frágiles.
3. Código muerto de cementerio eliminado.
4. `gdscript-quality` con `gdlint` y `gdformat --check`.
5. Estado final: `b13d024143b5fb0ff8118a689da079c37916c554`, run `33295277286`, ambos jobs `success`.

#### Bloque 2 — Ciclo día/noche
1. `DayNightMath` encapsula fases e interpolación gradual.
2. Referencias: 06:00 amanecer, 12:00 mediodía, 18:00 atardecer y 22:00 noche.
3. `DayNightController` local usa `CanvasModulate` y observa `TimeManager` vía `EventBus`.
4. Corrección final: `5c6467c5aad04b1d44c48cceef2280af5d049bf8`.
5. Validación: run `33295805020`, ambos jobs `success`.

#### Bloque 3 — NPCData y navegación
1. `NPCData` tipado y primer NPC original: Hermano Aldren.
2. `NPCNavigationMath` para lógica pura de dirección/llegada.
3. `WorldNavigationRegion` local y `NPCController` sobre `CharacterBody2D` + `NavigationAgent2D`.
4. Run `33296112250` detectó `class-definitions-order`; se corrigió sin relajar reglas.
5. Corrección final: `03986401968c83b79527d15f47217f090de43ab2`.
6. Validación: run `33296131085`, ambos jobs `success`.

#### Bloque 4 — ScheduleData y rutinas
1. `ScheduleEntryData` y `ScheduleData` tipados con máscara de seis días, rangos que cruzan medianoche, actividad y destino.
2. `NPCStateMachine` con `Idle`, `Walking`, `Working` y `Sleeping`.
3. Hermano Aldren usa horario data-driven; `Walking` es transitorio hasta llegar a la actividad programada.
4. `test_npc_routines.gd` cubre resolución horaria, medianoche, transiciones e integración.
5. Run `33296549903` detectó comparación inválida `Dictionary`/`int` en `ScheduleEntryData`.
6. Corrección final: `82f5ccee1e109e2ad702532b7301922124548c7b`.
7. Validación: run `33296648630`, ambos jobs `success`.
8. `editorconfig` fue corregido a `.editorconfig`.

#### Bloque 5 — Persistencia NPC y cierre de Fase 5
1. `NPCStateMachine` soporta snapshot/restauración de estado actual y pendiente, preservando la invariante de `Walking`.
2. `NPCController` participa como `save_provider` local con clave estable `npc:<NPCData.id>`.
3. El snapshot NPC guarda `id`, posición, estado actual, estado pendiente, navegación activa y target solo cuando aplica.
4. `apply_save_data()` restaura posición/estado y reanuda una ruta en curso; las señales futuras de `TimeManager` vuelven a gobernar la rutina.
5. `test_simulation_acceptance.gd` ejecuta el flujo integrado de Fase 5: horario de Aldren, día/noche, save/load real mediante `SaveManager`, restauración NPC, cambio horario posterior y dormir hasta el amanecer con recuperación de energía.
6. Implementación inicial: `b8bd10cb2f014c64e4a9a5dbb30e6e041862d6be`.
7. Run `33297598359`: importación/smoke/quality verdes, pero 12 fallos en aceptación. El mundo se añadía al árbol desde `SceneTree._initialize()` antes del lifecycle normal.
8. `79670b23b1306031e21bf2a3403a90ced5edc383` movió contratos que deben existir al entrar al árbol (`save_provider` y conexiones de simulación) a `_enter_tree()`; run `33297716722` mantuvo los mismos 12 fallos y confirmó que el problema restante estaba en el harness.
9. `f0290951a27d5e66581da2532151d957ec35075e` difiere la ejecución de suites hasta después de la inicialización de `SceneTree`, permitiendo probar lifecycle real sin invocar manualmente `_ready()`.
10. Validación final: `Godot CI` run `33297774458`, `success` en lint, formato, importación, smoke test y suite headless completa.
11. Todos los criterios de aceptación de Fase 5 quedan cumplidos. **Fase 5 COMPLETADA**.

## Decisiones vigentes

- Mantener exactamente cinco Autoloads globales.
- `TimeManager` es la única fuente de reloj/calendario.
- Ciclo visual, NPCs y otros sistemas de gameplay permanecen locales/contextuales.
- `NPCData` contiene identidad/configuración estable; `ScheduleData` contiene horarios/destinos; `NPCStateMachine` contiene estado runtime.
- `NPCController` persiste mediante `save_provider` con clave estable derivada del ID, sin crear un manager global de NPCs.
- `Walking` es transitorio y conserva la actividad pendiente al persistir/restaurar.
- `NavigationAgent2D` sigue siendo el mecanismo de navegación; no sustituirlo por movimiento directo ad hoc.
- La UI observa modelos/servicios y no posee estado de gameplay.
- Datos de gameplay deben ser Resources tipados cuando corresponda.
- Lógica pura debe ser testeable de forma aislada siempre que sea posible.
- Las suites se lanzan de forma diferida tras inicializar `SceneTree` para que tests integrales observen lifecycle real.
- `gdscript-quality` es un gate adicional; la autoridad funcional sigue siendo importación/smoke/tests de Godot.
- No introducir sistemas de Fase 7/8 durante Fase 6.

## Fase 6 — RPG — ACTIVA

Criterios derivados del master spec que deberán cumplirse antes de cerrar:
1. Diálogos, condiciones y opciones funcionan desde datos.
2. Relaciones cambian y desbloquean contenido.
3. Quests pueden iniciarse, progresar y completarse.
4. Recompensas se conceden una sola vez.
5. Economía compra/vende correctamente.
6. Tecnologías consumen puntos y desbloquean contenido.
7. Estado persistente compatible con `SaveManager` y tests de aceptación/CI completos.

## Próximo bloque — Fase 6

1. Releer las secciones de diálogo, relaciones y quests del master spec antes de diseñar APIs.
2. Crear la foundation de diálogo data-driven con Resources tipados para nodos/opciones/condiciones mínimas.
3. Mantener la evaluación de condiciones como lógica pura y testeable; la UI solo presentará datos.
4. Integrar un diálogo mínimo original con Hermano Aldren solo para demostrar el flujo, sin adelantar quest/economía/tecnologías en el mismo bloque.
5. Añadir tests, ampliar `gdscript-quality` y validar CI completo.
6. Actualizar documentación tras el bloque; no marcar Fase 6 como completada hasta cumplir todos sus criterios.

## Regla de continuidad

Al retomar:
1. Leer este archivo.
2. Leer `ROADMAP.md`.
3. Consultar la fase activa en el master spec.
4. Revisar el último CI de `main`.
5. Implementar un bloque coherente y pequeño.
6. Ejecutar/verificar quality gate, importación, smoke test y tests.
7. Corregir errores críticos antes de avanzar.
8. Actualizar `DEV_MEMORY.md`, `ROADMAP.md`, `CHANGELOG.md` y `README.md` cuando cambie el estado de fase.
9. No marcar una fase como completada hasta cumplir todos sus criterios.
