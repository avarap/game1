# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase completada más reciente: **Fase 5 — Simulación**
- Fase activa: **Fase 6 — RPG**
- Estado Fase 6: **Bloques 1 (diálogo bilingüe) y 2 (relaciones) completados y validados**; quests, economía y tecnologías siguen pendientes.
- Fuente de verdad: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Política concreta de idiomas: `LOCALIZATION.md`.
- Último bloque funcional: `fc446609004ea8031903c1c529144743cd963e51`.
- Última validación funcional y de calidad: `Godot CI` run `33299277228`, `success` en `gdscript-quality` y `validate-and-test`.

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

1. El master ya contemplaba localización y diálogos data-driven; se concreta el vertical slice en **inglés (`en`) y español (`es`)**, con fallback inglés.
2. `LocalizationService` encapsula locales soportados y `TranslationServer`; no se añade ningún Autoload.
3. `project.godot` registra `localization/en.po` y `localization/es.po`.
4. IDs, condiciones, saves y progreso nunca dependen de texto localizado. Los datos almacenan claves estables y la UI traduce al presentar.
5. Se añadieron Resources tipados: `DialogueConditionData`, `DialogueOptionData`, `DialogueNodeData` y `DialogueData`.
6. `DialogueService` mantiene el grafo/estado runtime como lógica pura, resuelve opciones disponibles y avanza por IDs estables.
7. `DialogueController` es UI local; usa el servicio y ofrece un selector técnico ES/EN en runtime. La UI no posee la lógica del grafo.
8. `DialogueInteractable` reutiliza `Interactable` y descubre el controller mediante el grupo semántico `dialogue_controller`.
9. Hermano Aldren tiene un primer diálogo original data-driven en `data/dialogues/brother_aldren/introduction.tres`.
10. El mismo grafo sirve para ambos idiomas; cambiar ES/EN actualiza nombre, texto y opciones sin mutar el estado del diálogo.
11. `test_dialogue_foundation.gd` cubre traducciones, locales soportados, condiciones, grafo/opciones y estabilidad del estado al cambiar idioma.
12. `test_dialogue_gameplay.gd` carga `world.tscn`, interactúa realmente con Aldren, valida texto español, selecciona una opción y cambia a inglés durante el diálogo.
13. El quality gate incluye todos los scripts y tests nuevos.
14. Implementación inicial: `60bc1e7e137fbbad61e8a6604aa52ae872b2415b`.
15. Run `33298684332`: importación, smoke test y suite headless en `success`; `gdformat --check` detectó únicamente formato en `test_dialogue_foundation.gd`.
16. Corrección de formato: `46a37e00c2ad968e91834da5577a6f512a28f0a9`.
17. Validación final del bloque: `Godot CI` run `33298737838`, ambos jobs `success`.
18. Documento de política: `LOCALIZATION.md`.

### Bloque 2 — Foundation de relaciones

1. `RelationshipData` define relaciones data-driven con ID estable y valor inicial dentro del rango 0-100.
2. `RelationshipService` mantiene el estado runtime, aplica cambios y clampa siempre entre 0 y 100; permanece como lógica pura y testeable.
3. `RelationshipController` es local/contextual en `world.tscn`; no se añade ningún Autoload y se mantiene el límite de cinco globales.
4. Hermano Aldren dispone de `data/relationships/brother_aldren.tres` con valor inicial 0.
5. `DialogueConditionData` amplía sus condiciones con `RELATIONSHIP_MIN` sin depender de texto localizado.
6. `DialogueInteractable` pasa al diálogo un contexto de relaciones obtenido del controller local.
7. El diálogo de Aldren incorpora una opción bilingüe adicional bloqueada hasta alcanzar relación 10.
8. `test_relationships.gd` cubre registro, valor inicial, clamp 0-100 y bloqueo/desbloqueo de la opción condicionada.
9. La importación de Godot, smoke test y suite headless validan además la integración real de `RelationshipController` en `world.tscn`.
10. El quality gate incluye scripts y tests de relaciones.
11. Implementación base: `6d9eb1d54ab97ea92a8ee533bec1d9523ee2d1a5`.
12. Run `33299203135`: `validate-and-test` fue `success`; `gdscript-quality` falló únicamente porque `DialogueInteractable` requería formato de `gdformat`.
13. Corrección de formato: `fc446609004ea8031903c1c529144743cd963e51`.
14. Validación final: `Godot CI` run `33299277228`, ambos jobs `success`.

## Decisiones vigentes

- Mantener exactamente cinco Autoloads globales.
- `TimeManager` es la única fuente de reloj/calendario.
- NPCs, diálogo, relaciones y otros sistemas de gameplay permanecen locales/contextuales.
- `TranslationServer` es la autoridad runtime de idioma; `LocalizationService` es un wrapper estático, no un Autoload.
- Idiomas iniciales oficiales del vertical slice: inglés y español; fallback inglés.
- Los Resources de diálogo contienen **claves de traducción**, nunca texto localizado usado como identidad o condición.
- Cambiar idioma no puede alterar grafo, quest IDs, relaciones, saves ni progreso.
- Relaciones usan IDs estables y rango 0-100; el diálogo consume un snapshot contextual, no referencias directas al controller.
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

1. Implementar foundation de quests data-driven con IDs estables y estados mínimos `unavailable`, `active` y `completed`.
2. Crear un servicio puro/testeable para iniciar y progresar quests sin acoplarlo a UI, traducciones ni NPC controllers.
3. Integrar una quest mínima de Hermano Aldren que pueda iniciarse desde contenido ya desbloqueado y progresar mediante un objetivo simple existente.
4. Añadir tests de transiciones e integración y ampliar quality gate.
5. Mantener las recompensas idempotentes como criterio obligatorio del sistema de quests, sin abrir aún economía ni tecnologías.

## Regla de continuidad

Al retomar:
1. Leer `DEV_MEMORY.md`, `ROADMAP.md` y `LOCALIZATION.md`.
2. Consultar la fase activa en el master spec.
3. Revisar el último CI de `main`.
4. Implementar un bloque coherente y pequeño.
5. Ejecutar quality gate, importación, smoke test y tests.
6. Corregir errores críticos antes de avanzar.
7. Actualizar `DEV_MEMORY.md`, `ROADMAP.md`, `CHANGELOG.md` y `README.md` cuando cambie el estado.
8. No marcar una fase como completada hasta cumplir todos sus criterios.
