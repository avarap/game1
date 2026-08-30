# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`
- Rama: `main`
- Fase completada más reciente: **Fase 5 — Simulación**
- Fase activa: **Fase 6 — RPG**
- Estado Fase 6: **diálogo bilingüe, relaciones y condiciones narrativas contextuales completados y validados**; quests, economía y tecnologías siguen pendientes.
- Fuente de verdad funcional/arquitectónica: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Fuente narrativa: `HISTORIA_PRINCIPAL.md` — **El Cementerio de Valdeniebla**, versión canónica spoiler-light.
- Política concreta de idiomas: `LOCALIZATION.md`.
- Último bloque funcional: `e1a19343e8303d1b28188a2a38c559d788c8087d`.
- Última validación funcional y de calidad: `Godot CI` run `33299990183`, `success` en ambos jobs.

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

## Fase 6 — RPG — ACTIVA

### Bloque 1 — Foundation de diálogo + localización ES/EN

- `LocalizationService` encapsula `TranslationServer`; no hay Autoload nuevo.
- `DialogueConditionData`, `DialogueOptionData`, `DialogueNodeData` y `DialogueData` son Resources tipados.
- `DialogueService` mantiene el grafo/estado runtime como lógica pura.
- `DialogueController` es UI local y permite cambio ES/EN sin mutar el grafo activo.
- Hermano Aldren tiene un primer diálogo original data-driven.
- Implementación final: `46a37e00c2ad968e91834da5577a6f512a28f0a9`.
- Validación: run `33298737838`, ambos jobs `success`.

### Bloque 2 — Foundation de relaciones

- `RelationshipData` define relaciones por ID estable y rango 0-100.
- `RelationshipService` es puro y clampa 0-100.
- `RelationshipController` es local/contextual en `world.tscn`.
- `RELATIONSHIP_MIN` desbloquea opciones sin depender de texto.
- Implementación final: `fc446609004ea8031903c1c529144743cd963e51`.
- Validación: run `33299277228`, ambos jobs `success`.

### Bloque 2B — Valdeniebla y condiciones contextuales

- `DialogueConditionData` soporta `FLAG`, `RELATIONSHIP_MIN`, `HAS_ITEM`, `TIME_OF_DAY` y `QUEST_FLAG`.
- `TIME_OF_DAY` usa inicio inclusivo/final exclusivo y soporta rangos que cruzan medianoche.
- `DialogueInteractable` construye contexto desde relaciones, inventario del actor, `TimeManager` y futuro controller de quests.
- Aldren tiene una opción nocturna 22:00–06:00 con texto localizado EN/ES.
- `test_dialogue_conditions.gd` cubre inventario, hora, cruce de medianoche, `QUEST_FLAG` e integración real.
- Implementación funcional: `e1a19343e8303d1b28188a2a38c559d788c8087d`.
- Validación: run `33299990183`, ambos jobs `success`.

### Dirección narrativa revisada

- La propuesta narrativa v1 contenía revelaciones demasiado explícitas para alguien que quiere jugar el proyecto sin spoilers.
- `HISTORIA_PRINCIPAL.md` se redefine como documento canónico **spoiler-light**.
- Mantiene Valdeniebla, el cementerio, Aldren, el tono de comedia negra y misterio progresivo, y la estructura general por actos.
- No fija públicamente culpables, identidades ocultas, naturaleza exacta del misterio, lealtades finales ni finales concretos.
- Ningún personaje debe presentarse demasiado pronto como «villano verdadero»; las perspectivas deben poder contener razones válidas y errores simultáneamente.
- Las pistas importantes deben admitir más de una interpretación cuando aparecen.
- Los flags narrativos deben describir hechos observados (`read_old_register`, `saw_npc_at_cemetery_night`) y no conclusiones (`npc_is_traitor`).
- Evitar spoilers en nombres de Resources, archivos, IDs, tests y comentarios.
- La verdad de fondo solo se concreta cuando una implementación jugable la necesita y debe ser compatible con todas las pistas previas.

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
- `HISTORIA_PRINCIPAL.md` define dirección narrativa sin revelar respuestas finales; `ROADMAP.md` gobierna el orden de implementación.
- Fase 6 debe construir primero un Acto 1 pequeño y jugable, no escribir contenido masivo de actos posteriores.
- La primera quest debe parecer un encargo cotidiano y descubrir como máximo una irregularidad observable; no debe explicar el misterio central.
- La UI observa modelos/servicios y no posee estado de negocio.
- Datos de gameplay deben ser Resources tipados cuando corresponda.
- Lógica pura debe ser testeable de forma aislada siempre que sea posible.
- `gdscript-quality` es gate adicional; autoridad funcional: importación, smoke test y tests Godot.
- No introducir sistemas de Fase 7/8 durante Fase 6.

## Criterios restantes de Fase 6

1. Quests pueden iniciarse, progresar y completarse.
2. Recompensas se conceden exactamente una vez.
3. Economía compra/vende correctamente.
4. Tecnologías consumen puntos y desbloquean contenido.
5. Estado RPG persistente compatible con `SaveManager` cuando aplique.
6. Aceptación integral y CI final verdes.

## Próximo bloque — Fase 6

1. Crear `QuestData`, objetivos/estado runtime y `QuestService` puro con estados `unavailable`, `active`, `completed`.
2. Usar IDs neutrales, estables y sin spoilers; texto por claves de traducción.
3. Integrar una primera quest de Aldren del Acto 1 basada en un trabajo normal del cementerio.
4. Introducir como máximo una anomalía observable como resultado del encargo; no resolver su significado.
5. Diseñar recompensas idempotentes desde el principio.
6. Exponer `quest_flags` al diálogo mediante controller local, aprovechando `QUEST_FLAG`.
7. Añadir tests puros + integración y ampliar quality gate.
8. No abrir economía ni tecnologías hasta validar quests.

## Regla de continuidad

Al retomar:
1. Leer `DEV_MEMORY.md`, `ROADMAP.md`, `HISTORIA_PRINCIPAL.md` y `LOCALIZATION.md`.
2. Consultar la fase activa en el master spec.
3. Revisar el último CI de `main`.
4. Implementar un bloque coherente y pequeño.
5. Ejecutar quality gate, importación, smoke test y tests.
6. Corregir errores críticos antes de avanzar.
7. Actualizar documentación cuando cambie el estado.
8. No marcar una fase como completada hasta cumplir todos sus criterios.
