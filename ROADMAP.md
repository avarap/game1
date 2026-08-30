# ROADMAP

## Fase 0 — Bootstrap — COMPLETADA
- [x] Repositorio, Godot 4.x, escena raíz, estructura y Autoloads mínimos.
- [x] InputMap, logging, debug, persistencia inicial, tests y CI headless.

Validación: `Godot CI` run `33278173612`, `success`.

## Fase 1 — Core / Walking Prototype — COMPLETADA
- [x] Mundo base, `CharacterBody2D`, movimiento 8 direcciones, cámara, colisiones y Y-sort.
- [x] `Interactable` reutilizable y aceptación de escenas.

Validación: `Godot CI` run `33280758441`, `success`.

## Fase 2 — Items / Resource Loop — COMPLETADA
- [x] `ItemData`, inventario data-driven, stacks/capacidad y `InventoryComponent` local.
- [x] Energía, recursos recolectables, herramientas, loot y atomicidad.
- [x] Tests del loop completo y CI final.

Cierre: `c196e3ab5a42adffe97278f0b0daa8960c789e04`, run `33285578050`, `success`.

## Fase 3 — Crafting / Production Loop — COMPLETADA
- [x] Recetas data-driven, crafting atómico y estación local.
- [x] `StorageProvider`/`StorageNetwork` y crafting distribuido.
- [x] Producción temporizada, colas y outputs recuperables.
- [x] Tests y CI final verdes.

Cierre: `2252fcbd4280acec1e60530c026a8f5dd3365b91`, run `33292481990`, `success`.

## Fase 4 — Cementerio — COMPLETADA
- [x] Cadáveres, descomposición, tumbas y rating data-driven.
- [x] Flujo recibir/preparar/enterrar/mejorar jugable.
- [x] Persistencia mediante guardado versionado.
- [x] Tests de aceptación y CI final verdes.

Cierre: `dc9b4adc2710a18f182bd4a04f676a3afc74c198`, run `33294286014`, `success`.

## Fase 5 — Simulación — COMPLETADA
- [x] Reloj/calendario sobre `TimeManager`.
- [x] Ciclo día/noche gradual y sueño.
- [x] `NPCData`, `NavigationAgent2D`, horarios y estados.
- [x] Persistencia NPC y estado temporal mediante `SaveManager`.
- [x] Aceptación integral y CI final verdes.

Cierre funcional: `f0290951a27d5e66581da2532151d957ec35075e`, run `33297774458`, ambos jobs `success`.

## Fase 6 — RPG — ACTIVA

### Criterios de aceptación
- [x] Diálogos, condiciones y opciones funcionan desde datos.
- [x] Los diálogos del vertical slice soportan inglés y español mediante claves estables, sin duplicar el grafo.
- [x] Relaciones cambian y desbloquean contenido.
- [ ] Quests pueden iniciarse, progresar y completarse.
- [ ] Las recompensas de quests se conceden una sola vez.
- [ ] La economía compra y vende correctamente.
- [ ] Las tecnologías consumen puntos y desbloquean contenido.
- [ ] Estado RPG persistente compatible con `SaveManager`, cuando aplique.
- [ ] Tests de aceptación del flujo RPG mínimo.
- [ ] `gdscript-quality` verde sobre el HEAD final de la fase.
- [ ] CI final verde antes de cerrar la fase.

### Política de localización
- Idiomas iniciales: `en` y `es`; fallback `en`.
- `TranslationServer` + `LocalizationService`, sin nuevo Autoload.
- Catálogos `localization/en.po` y `localization/es.po`.
- IDs, condiciones, progreso y saves nunca dependen de texto traducido.
- Ver `LOCALIZATION.md`.

### Fuente narrativa
- `HISTORIA_PRINCIPAL.md` define la dirección narrativa canónica de **El Cementerio de Valdeniebla**.
- El documento es deliberadamente **spoiler-light**: fija tono, personajes y estructura, pero no culpables, identidades ocultas, explicación final del misterio ni finales.
- Durante Fase 6 se prioriza un **Acto 1 pequeño y completo**: aprender el oficio, detectar contradicciones y cerrar con una pregunta, no con una explicación.
- La narrativa debe mantener perspectivas enfrentadas y al menos dos lecturas plausibles de las pistas importantes mientras sea razonable.
- Los flags narrativos describen hechos observados, no interpretaciones verdaderas.
- Los nuevos NPCs se incorporan gradualmente dentro del objetivo final de 8–10 NPCs y solo cuando aportan una función jugable concreta.

### Bloque 1 — Foundation de diálogo bilingüe — COMPLETADO
- [x] `DialogueConditionData`, `DialogueOptionData`, `DialogueNodeData` y `DialogueData` tipados.
- [x] `DialogueService` puro/testeable para iniciar, filtrar opciones y navegar por IDs.
- [x] `DialogueController` local: UI mínima y selector runtime ES/EN.
- [x] `DialogueInteractable` integrado con el sistema genérico de interacción.
- [x] Primer diálogo original de Hermano Aldren en un único grafo data-driven.
- [x] Traducciones inglesas y españolas registradas en Godot.
- [x] Cambio de idioma durante un diálogo sin alterar el nodo activo.
- [x] Tests de foundation y gameplay real en `world.tscn`.
- [x] Quality gate ampliado.
- Implementación: `60bc1e7e137fbbad61e8a6604aa52ae872b2415b`.
- Corrección: `46a37e00c2ad968e91834da5577a6f512a28f0a9`.
- Validación: `Godot CI` run `33298737838`, ambos jobs `success`.

### Bloque 2 — Foundation de relaciones — COMPLETADO
- [x] `RelationshipData` data-driven con IDs estables y rango 0-100.
- [x] `RelationshipService` puro con registro, lectura, cambios y clamp 0-100.
- [x] `RelationshipController` contextual en `world.tscn`, sin nuevo Autoload.
- [x] Relación de Hermano Aldren definida en `data/relationships/brother_aldren.tres`.
- [x] Condición `RELATIONSHIP_MIN` integrada en `DialogueConditionData`.
- [x] `DialogueInteractable` inyecta el contexto de relaciones al grafo.
- [x] Opción bilingüe de Aldren bloqueada bajo relación 10 y disponible desde 10.
- [x] `test_relationships.gd` cubre rango, clamp y desbloqueo de contenido.
- [x] Importación, smoke test, suite headless y quality gate verdes.
- Implementación: `6d9eb1d54ab97ea92a8ee533bec1d9523ee2d1a5`.
- Corrección: `fc446609004ea8031903c1c529144743cd963e51`.
- Validación: `Godot CI` run `33299277228`, ambos jobs `success`.

### Bloque 2B — Integración narrativa y condiciones contextuales — COMPLETADO
- [x] `HISTORIA_PRINCIPAL.md` incorporado como dirección narrativa de Valdeniebla.
- [x] `DialogueConditionData` soporta `HAS_ITEM`, `TIME_OF_DAY` y `QUEST_FLAG`, además de flags y relaciones.
- [x] `TIME_OF_DAY` soporta rangos que cruzan medianoche.
- [x] `DialogueInteractable` construye contexto desde inventario relevante, `TimeManager`, relaciones y futuro `quest_controller`.
- [x] Aldren ofrece una opción nocturna entre 22:00 y 06:00 con texto ES/EN.
- [x] `test_dialogue_conditions.gd` cubre inventario, hora, flags de quest y opción nocturna.
- Implementación narrativa inicial: `cf1e6fbaa6f562ca4d3a005496354ac996168ace`.
- Implementación funcional: `e1a19343e8303d1b28188a2a38c559d788c8087d`.
- Validación: `Godot CI` run `33299990183`, ambos jobs `success`.

### Próximo bloque
Foundation de quests basada en el Acto 1 de Valdeniebla: Resources/estado data-driven, servicio puro con transiciones `unavailable` → `active` → `completed`, primera quest mínima de Hermano Aldren y tests. La quest debe empezar como un encargo cotidiano y revelar como máximo una irregularidad observable, sin explicar el misterio central. Las recompensas deben ser idempotentes; no abrir economía ni tecnologías antes de validar el bloque.

## Fase 7 — Mundo
Pueblo, bosque, mina, interiores, exploración y secretos.

## Fase 8 — Polish
Arte, animaciones, shaders, partículas, audio, feedback, UI final y optimización.
