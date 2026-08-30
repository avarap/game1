# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase completada más reciente: **Fase 5 — Simulación**
- Fase activa: **Fase 6 — RPG**
- Estado Fase 6: **diálogo bilingüe, relaciones y condiciones narrativas contextuales completados y validados**; quests, economía y tecnologías siguen pendientes.
- Fuente de verdad funcional/arquitectónica: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Fuente narrativa de Fase 6: `HISTORIA_PRINCIPAL.md` — **El Cementerio de Valdeniebla**.
- Política concreta de idiomas: `LOCALIZATION.md`.
- Último bloque funcional: `e1a19343e8303d1b28188a2a38c559d788c8087d`.
- Última validación funcional y de calidad: `Godot CI` run `33299990183`, `success` en `gdscript-quality` y `validate-and-test`.

## Fases completadas

### Fase 0 — Bootstrap
- Godot 4.x, escena raíz, cinco Autoloads: `EventBus`, `GameManager`, `TimeManager`, `SaveManager`, `AudioManager`.
- InputMap, logging, debug, guardado versionado, tests y CI headless.
- Validación: run `33278173612`, `success`.

### Fase 1 — Core / Walking Prototype
- Mundo base, jugador `CharacterBody2D`, movimiento 8 direcciones, cámara, colisiones, Y-sort e interacción reusable.
- Validación final: run `33280758441`, `success`.

### Fase 2 — Items / Resource Loop
- `ItemData`, inventario data-driven, energía, recursos, herramientas, loot y atomicidad.
- Implementación final: `c196e3ab5a42adffe97278f0b0daa8960c789e04`.
- Validación: run `33285578050`, `success`.

### Fase 3 — Crafting / Production Loop
- Recetas tipadas, crafting instantáneo, `StorageNetwork`, cofres, producción temporizada y colas recuperables.
- Validación final: `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`, `success`.

### Fase 4 — Cementerio
- Cadáveres, tumbas, rating data-driven, flujo jugable contextual y persistencia mediante providers locales.
- Validación final: `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`, `success`.

### Fase 5 — Simulación
- Tiempo/calendario y sueño: `62cb2658bd169270fffcb59c34134493b787f327`, run `33294728470`, `success`.
- Hardening de storage/dependencias/calidad: `b13d024143b5fb0ff8118a689da079c37916c554`, run `33295277286`, `success`.
- Día/noche: `5c6467c5aad04b1d44c48cceef2280af5d049bf8`, run `33295805020`, `success`.
- NPCData/navegación: `03986401968c83b79527d15f47217f090de43ab2`, run `33296131085`, `success`.
- Horarios/estados: `82f5ccee1e109e2ad702532b7301922124548c7b`, run `33296648630`, `success`.
- Persistencia NPC y aceptación: `f0290951a27d5e66581da2532151d957ec35075e`, run `33297774458`, `success`.
- El runner ejecuta suites después de inicializar `SceneTree`, permitiendo tests integrales con lifecycle real.

## Fase 6 — RPG — ACTIVA

### Bloque 1 — Foundation de diálogo + localización ES/EN

1. Idiomas iniciales oficiales: inglés (`en`) y español (`es`), fallback inglés.
2. `LocalizationService` encapsula `TranslationServer`; no se añade Autoload.
3. `DialogueConditionData`, `DialogueOptionData`, `DialogueNodeData` y `DialogueData` son Resources tipados.
4. `DialogueService` mantiene el grafo/estado runtime como lógica pura.
5. `DialogueController` es UI local y permite cambio ES/EN sin mutar el grafo activo.
6. Hermano Aldren tiene un primer diálogo original data-driven.
7. Tests de foundation y gameplay real en `world.tscn`.
8. Implementación final: `46a37e00c2ad968e91834da5577a6f512a28f0a9`.
9. Validación: run `33298737838`, ambos jobs `success`.

### Bloque 2 — Foundation de relaciones

1. `RelationshipData` define relaciones por ID estable y rango 0-100.
2. `RelationshipService` es puro, aplica cambios y clampa 0-100.
3. `RelationshipController` es local/contextual en `world.tscn`.
4. Hermano Aldren dispone de relación data-driven inicial 0.
5. `RELATIONSHIP_MIN` desbloquea contenido de diálogo sin depender de texto.
6. `test_relationships.gd` cubre rango, clamp y desbloqueo.
7. Implementación final: `fc446609004ea8031903c1c529144743cd963e51`.
8. Validación: run `33299277228`, ambos jobs `success`.

### Bloque 2B — Valdeniebla y condiciones contextuales

1. `HISTORIA_PRINCIPAL.md` incorpora la propuesta narrativa **El Cementerio de Valdeniebla**, con comedia negra, misterio progresivo, Aldren, María, Gregorio, Elvira, Morvan, Sociedad del Velo y El Cuervo.
2. La implementación inmediata se limita al **Acto 1 — El Trabajo Absurdo**; los actos 2 y 3 permanecen como diseño narrativo y no fuerzan sistemas de fases posteriores.
3. Los nuevos aldeanos del documento no sustituyen automáticamente a Mara Vell, Oren Brask y Silas Crow del master; se evaluarán dentro del objetivo final de 8–10 NPCs.
4. `DialogueConditionData` soporta ahora `FLAG`, `RELATIONSHIP_MIN`, `HAS_ITEM`, `TIME_OF_DAY` y `QUEST_FLAG`.
5. `TIME_OF_DAY` usa inicio inclusivo/final exclusivo y soporta rangos que cruzan medianoche.
6. `HAS_ITEM` evalúa cantidades desde un snapshot de inventario contextual.
7. `QUEST_FLAG` consume `context["quest_flags"]`, preparado para el futuro `quest_controller` sin acoplar la foundation de diálogo a quests.
8. `DialogueInteractable` construye contexto desde relaciones, inventario del actor, `TimeManager` y un futuro controller de quests si existe.
9. El diálogo de Aldren añade una opción nocturna 22:00–06:00. La respuesta española procede del diseño narrativo: «No te quedes despierto. Lo que sale de noche no es amable.»; inglés usa su traducción equivalente.
10. `test_dialogue_conditions.gd` cubre `HAS_ITEM`, `TIME_OF_DAY`, cruce de medianoche, `QUEST_FLAG` y la opción nocturna real de Aldren.
11. `gdscript-quality` incluye el test nuevo y todos los scripts modificados.
12. Documento narrativo: `cf1e6fbaa6f562ca4d3a005496354ac996168ace`.
13. Implementación funcional: `e1a19343e8303d1b28188a2a38c559d788c8087d`.
14. Validación: `Godot CI` run `33299990183`, ambos jobs `success`.

## Decisiones vigentes

- Mantener exactamente cinco Autoloads globales.
- `TimeManager` es la única fuente de reloj/calendario.
- NPCs, diálogo, relaciones, quests y otros sistemas RPG permanecen locales/contextuales.
- `TranslationServer` es la autoridad runtime de idioma; `LocalizationService` es wrapper estático, no Autoload.
- Idiomas iniciales: inglés y español; fallback inglés.
- Los Resources de diálogo contienen claves de traducción, nunca texto localizado usado como identidad o condición.
- Cambiar idioma no puede alterar grafo, quest IDs, relaciones, saves ni progreso.
- Relaciones usan IDs estables y rango 0-100.
- Condiciones narrativas consumen snapshots/contextos; no mantienen referencias directas a inventario, tiempo, relaciones o quests.
- `HISTORIA_PRINCIPAL.md` define contenido narrativo; `ROADMAP.md` sigue siendo la autoridad del orden de implementación.
- Durante el siguiente bloque se implementará solo una quest mínima del Acto 1 con Aldren; no añadir todavía los tres nuevos aldeanos ni eventos de Actos 2/3.
- La UI observa modelos/servicios y no posee estado de negocio.
- Datos de gameplay deben ser Resources tipados cuando corresponda.
- Lógica pura debe ser testeable de forma aislada siempre que sea posible.
- `gdscript-quality` es un gate adicional; la autoridad funcional sigue siendo importación/smoke/tests de Godot.
- No introducir sistemas de Fase 7/8 durante Fase 6.

## Criterios restantes de Fase 6

1. Quests pueden iniciarse, progresar y completarse.
2. Recompensas se conceden exactamente una vez.
3. Economía compra/vende correctamente.
4. Tecnologías consumen puntos y desbloquean contenido.
5. Estado RPG persistente compatible con `SaveManager` cuando aplique.
6. Aceptación integral y CI final verdes.

## Próximo bloque — Fase 6

1. Crear `QuestData`, objetivos/estado runtime y un `QuestService` puro con estados `unavailable`, `active`, `completed`.
2. Usar IDs estables y texto por claves de traducción; la quest no debe depender de idioma.
3. Integrar una primera quest de Hermano Aldren basada en el Acto 1 de Valdeniebla.
4. Diseñar recompensas idempotentes desde el principio: una recompensa no puede reclamarse/aplicarse dos veces.
5. Exponer `quest_flags` al contexto de diálogo mediante un controller local, aprovechando `QUEST_FLAG` ya implementado.
6. Añadir tests puros + integración y ampliar quality gate.
7. No abrir economía ni tecnologías hasta validar la foundation de quests.

## Regla de continuidad

Al retomar:
1. Leer `DEV_MEMORY.md`, `ROADMAP.md`, `HISTORIA_PRINCIPAL.md` y `LOCALIZATION.md`.
2. Consultar la fase activa en el master spec.
3. Revisar el último CI de `main`.
4. Implementar un bloque coherente y pequeño.
5. Ejecutar quality gate, importación, smoke test y tests.
6. Corregir errores críticos antes de avanzar.
7. Actualizar `DEV_MEMORY.md`, `ROADMAP.md`, `CHANGELOG.md` y `README.md` cuando cambie el estado.
8. No marcar una fase como completada hasta cumplir todos sus criterios.
